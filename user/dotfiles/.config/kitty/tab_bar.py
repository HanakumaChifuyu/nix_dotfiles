"""
Kitty custom tab bar

Layout:
    tabs | centered active cwd | network, memory, time

The callback draws exactly one tab at a time.  Kitty uses the returned end
position to build mouse hit boxes, so tabs must not be collected and drawn
later from the final callback.
"""

from __future__ import annotations

import datetime
import os
import re
import subprocess
import sys
import time
from pathlib import Path

from kitty.fast_data_types import Screen, add_timer, get_boss, wcswidth
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_title,
)
from kitty.utils import color_as_int


REFRESH_SECONDS = 2.0
MIN_TAB_WIDTH = 6
MAX_TAB_WIDTH = 16
MAX_CWD_WIDTH = 28
TAB_GAP = 1
SECTION_GAP = 1

ICON_FOLDER = '󰉋'
ICON_MEMORY = '󰍛'
ICON_TIME = '󰥔'

_timer_id = None
_metrics = {
    'sample_time': 0.0,
    'rx_total': None,
    'tx_total': None,
    'rx_rate': 0.0,
    'tx_rate': 0.0,
    'memory_percent': None,
}


# ─────────────────────────── Width helpers ───────────────────────────
def _width(text: str) -> int:
    """Return terminal cell width, never a negative wcwidth error value."""
    return max(0, wcswidth(text))


def _take_prefix(text: str, max_width: int) -> str:
    if max_width <= 0:
        return ''
    result = []
    used = 0
    for char in text:
        char_width = max(0, wcswidth(char))
        if used + char_width > max_width:
            break
        result.append(char)
        used += char_width
    return ''.join(result)


def _take_suffix(text: str, max_width: int) -> str:
    if max_width <= 0:
        return ''
    result = []
    used = 0
    for char in reversed(text):
        char_width = max(0, wcswidth(char))
        if used + char_width > max_width:
            break
        result.append(char)
        used += char_width
    return ''.join(reversed(result))


def _truncate_right(text: str, max_width: int) -> str:
    if _width(text) <= max_width:
        return text
    if max_width <= 0:
        return ''
    if max_width == 1:
        return '…'
    return _take_prefix(text, max_width - 1) + '…'


def _truncate_left(text: str, max_width: int) -> str:
    if _width(text) <= max_width:
        return text
    if max_width <= 0:
        return ''
    if max_width == 1:
        return '…'
    return '…' + _take_suffix(text, max_width - 1)


# ─────────────────────────── Data sources ───────────────────────────
def _active_cwd(os_window_id: int) -> str:
    try:
        manager = get_boss().os_window_map.get(os_window_id)
        tab = manager.active_tab if manager is not None else None
        return (tab.get_cwd_of_active_window() if tab is not None else '') or ''
    except Exception:
        return ''


def _tab_count(os_window_id: int, fallback: int) -> int:
    try:
        manager = get_boss().os_window_map.get(os_window_id)
        if manager is not None:
            return max(1, len(manager.tabs))
    except Exception:
        pass
    return max(1, fallback)


def _display_cwd(cwd: str) -> str:
    if not cwd:
        return ''

    home = os.path.expanduser('~')
    if cwd == home:
        return '~'
    if cwd.startswith(home + os.sep):
        return '~' + cwd[len(home):]
    return cwd


def _short_cwd(cwd: str, max_width: int) -> str:
    display = _display_cwd(cwd)
    if _width(display) <= max_width:
        return display

    # Prefer keeping the basename and one parent directory.
    parts = Path(display).parts
    if len(parts) >= 2:
        prefix = '/' if parts[0] == '/' else parts[0] + '/'
        candidate = prefix + '/'.join(('…', *parts[-2:]))
        if _width(candidate) <= max_width:
            return candidate

        candidate = '…/' + '/'.join(parts[-2:])
        if _width(candidate) <= max_width:
            return candidate

    return _truncate_left(display, max_width)


def _linux_memory_percent() -> int | None:
    try:
        info = {}
        with open('/proc/meminfo', encoding='ascii') as meminfo:
            for line in meminfo:
                key, _, value = line.partition(':')
                info[key] = int(value.strip().split()[0])
        total = info['MemTotal']
        available = info.get('MemAvailable', info.get('MemFree', 0))
        return round((total - available) * 100 / total)
    except (OSError, KeyError, ValueError, ZeroDivisionError):
        return None


def _darwin_memory_percent() -> int | None:
    try:
        result = subprocess.run(
            ['/usr/bin/memory_pressure', '-Q'],
            check=False,
            capture_output=True,
            text=True,
            timeout=0.5,
        )
        match = re.search(r'free percentage:\s*(\d+)%', result.stdout)
        return 100 - int(match.group(1)) if match else None
    except (OSError, subprocess.SubprocessError, ValueError):
        return None


def _memory_percent() -> int | None:
    if sys.platform.startswith('linux'):
        return _linux_memory_percent()
    if sys.platform == 'darwin':
        return _darwin_memory_percent()
    return None


def _linux_network_totals() -> tuple[int, int] | None:
    try:
        rx_total = tx_total = 0
        with open('/proc/net/dev', encoding='ascii') as netdev:
            next(netdev)
            next(netdev)
            for line in netdev:
                name, separator, counters = line.partition(':')
                if not separator:
                    continue
                name = name.strip()
                if name == 'lo' or name.startswith(
                    ('docker', 'veth', 'br-', 'virbr', 'podman', 'tailscale')
                ):
                    continue
                fields = counters.split()
                if len(fields) >= 9:
                    rx_total += int(fields[0])
                    tx_total += int(fields[8])
        return rx_total, tx_total
    except (OSError, StopIteration, ValueError):
        return None


def _darwin_network_totals() -> tuple[int, int] | None:
    try:
        result = subprocess.run(
            ['/usr/sbin/netstat', '-ibn'],
            check=False,
            capture_output=True,
            text=True,
            timeout=0.5,
        )
        lines = result.stdout.splitlines()
        if not lines:
            return None

        header = lines[0].split()
        name_index = header.index('Name')
        input_index = header.index('Ibytes')
        output_index = header.index('Obytes')
        per_interface: dict[str, tuple[int, int]] = {}

        for line in lines[1:]:
            fields = line.split()
            if len(fields) <= max(name_index, input_index, output_index):
                continue
            name = fields[name_index]
            if name == 'lo0' or name.startswith(('utun', 'awdl', 'llw')):
                continue
            rx = int(fields[input_index])
            tx = int(fields[output_index])
            old_rx, old_tx = per_interface.get(name, (0, 0))
            per_interface[name] = max(old_rx, rx), max(old_tx, tx)

        return (
            sum(value[0] for value in per_interface.values()),
            sum(value[1] for value in per_interface.values()),
        )
    except (OSError, subprocess.SubprocessError, ValueError):
        return None


def _network_totals() -> tuple[int, int] | None:
    if sys.platform.startswith('linux'):
        return _linux_network_totals()
    if sys.platform == 'darwin':
        return _darwin_network_totals()
    return None


def _sample_metrics() -> None:
    now = time.monotonic()
    totals = _network_totals()

    if totals is not None:
        rx_total, tx_total = totals
        previous_time = _metrics['sample_time']
        previous_rx = _metrics['rx_total']
        previous_tx = _metrics['tx_total']
        if previous_time and previous_rx is not None and previous_tx is not None:
            elapsed = max(now - previous_time, 0.001)
            _metrics['rx_rate'] = max(0.0, (rx_total - previous_rx) / elapsed)
            _metrics['tx_rate'] = max(0.0, (tx_total - previous_tx) / elapsed)
        _metrics['rx_total'] = rx_total
        _metrics['tx_total'] = tx_total

    _metrics['sample_time'] = now
    _metrics['memory_percent'] = _memory_percent()


def _format_rate(bytes_per_second: float) -> str:
    if bytes_per_second < 1024:
        return f'{bytes_per_second:.0f}B/s'
    if bytes_per_second < 1024**2:
        return f'{bytes_per_second / 1024:.0f}K/s'
    if bytes_per_second < 1024**3:
        return f'{bytes_per_second / 1024**2:.1f}M/s'
    return f'{bytes_per_second / 1024**3:.1f}G/s'


def _right_cell_texts() -> list[str]:
    cells = []
    if _metrics['rx_total'] is not None:
        cells.append(
            f'↓{_format_rate(_metrics["rx_rate"])} '
            f'↑{_format_rate(_metrics["tx_rate"])}'
        )

    memory_percent = _metrics['memory_percent']
    if memory_percent is not None:
        cells.append(f'{ICON_MEMORY} {memory_percent}%')

    cells.append(f'{ICON_TIME} {datetime.datetime.now():%H:%M}')
    return cells


# ─────────────────────────── Drawing helpers ───────────────────────────
def _rgb(color) -> int:
    return as_rgb(color_as_int(color))


def _set_base_style(draw_data: DrawData, screen: Screen) -> None:
    base = _rgb(draw_data.default_bg)
    screen.cursor.fg = base
    screen.cursor.bg = base
    screen.cursor.bold = False
    screen.cursor.italic = False
    screen.cursor.dim = False


def _cwd_text(
    cwd: str,
    max_width: int,
) -> str:
    icon_overhead = _width(f' {ICON_FOLDER}  ')
    if not cwd or max_width < icon_overhead + 1:
        return ''

    path = _short_cwd(cwd, min(MAX_CWD_WIDTH, max_width - icon_overhead))
    return f' {ICON_FOLDER} {path} ' if path else ''


def _draw_cwd(
    draw_data: DrawData,
    screen: Screen,
    text: str,
) -> None:
    screen.cursor.fg = _rgb(draw_data.active_fg)
    screen.cursor.bg = _rgb(draw_data.active_bg)
    screen.cursor.bold = True
    screen.draw(text)


def _centered_cwd(
    cwd: str,
    columns: int,
    count: int,
    right_width: int,
) -> tuple[str, int]:
    """Return cwd text and its absolute start column."""
    minimum_tabs = count * MIN_TAB_WIDTH
    right_start = columns - right_width
    right_limit = right_start - (SECTION_GAP if right_width else 0)

    # These limits keep the centered cell clear of both the compact tab area
    # on the left and the status cells on the right.
    max_for_tabs = columns - 2 * (minimum_tabs + SECTION_GAP)
    max_for_right = 2 * right_limit - columns
    max_width = min(MAX_CWD_WIDTH + _width(f' {ICON_FOLDER}  '), max_for_tabs, max_for_right)
    text = _cwd_text(cwd, max_width)
    if not text:
        return '', 0

    start = (columns - _width(text)) // 2
    if start < minimum_tabs + SECTION_GAP:
        return '', 0
    return text, start


def _fit_right_cells(max_width: int) -> list[str]:
    if max_width <= 0:
        return []

    cells = _right_cell_texts()
    selected: list[int] = []
    used = 0

    # Time is kept first, followed by memory and then network.  The result is
    # sorted back into display order after fitting by priority.
    for index in reversed(range(len(cells))):
        cell_width = _width(f' {cells[index]} ')
        extra = cell_width + (TAB_GAP if selected else 0)
        if used + extra <= max_width:
            selected.append(index)
            used += extra

    return [cells[index] for index in sorted(selected)]


def _right_width(cells: list[str]) -> int:
    if not cells:
        return 0
    return (
        sum(_width(f' {cell} ') for cell in cells)
        + TAB_GAP * (len(cells) - 1)
    )


def _draw_right(
    draw_data: DrawData,
    screen: Screen,
    cells: list[str],
) -> None:
    base = _rgb(draw_data.default_bg)
    foreground = _rgb(draw_data.inactive_fg)
    background = _rgb(draw_data.inactive_bg)

    for index, cell in enumerate(cells):
        if index:
            screen.cursor.fg = base
            screen.cursor.bg = base
            screen.draw(' ' * TAB_GAP)
        screen.cursor.fg = foreground
        screen.cursor.bg = background
        screen.cursor.bold = False
        screen.draw(f' {cell} ')


def _draw_tab_body(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    index: int,
    budget: int,
    is_last: bool,
) -> int:
    budget = max(1, budget)
    gap_width = 0 if is_last else min(TAB_GAP, max(0, budget - 1))
    body_width = max(1, budget - gap_width)

    screen.cursor.fg = as_rgb(draw_data.tab_fg(tab))
    screen.cursor.bg = as_rgb(draw_data.tab_bg(tab))
    screen.cursor.bold = tab.is_active
    screen.cursor.italic = False
    screen.cursor.dim = False

    start = screen.cursor.x
    if body_width < 3:
        screen.draw(_truncate_right(str(index), body_width))
    else:
        screen.draw(' ')
        title_start = screen.cursor.x
        title_width = body_width - 2
        draw_title(draw_data, screen, tab, index, title_width)
        title_end = title_start + title_width
        if screen.cursor.x > title_end:
            screen.cursor.x = max(title_start, title_end - 1)
            screen.cursor.fg = as_rgb(draw_data.tab_fg(tab))
            screen.cursor.bg = as_rgb(draw_data.tab_bg(tab))
            screen.cursor.bold = tab.is_active
            screen.draw('…')
        screen.cursor.x = min(screen.cursor.x, title_end)
        screen.cursor.fg = as_rgb(draw_data.tab_fg(tab))
        screen.cursor.bg = as_rgb(draw_data.tab_bg(tab))
        screen.cursor.bold = tab.is_active
        screen.draw(' ')

    # Defensive clamp for a wide glyph at the boundary.
    if screen.cursor.x > start + body_width:
        screen.cursor.x = start + body_width
    tab_end = screen.cursor.x

    if gap_width:
        _set_base_style(draw_data, screen)
        screen.draw(' ' * gap_width)
    return tab_end


def _ensure_timer() -> None:
    global _timer_id
    if _timer_id is None:
        _sample_metrics()
        _timer_id = add_timer(_redraw, REFRESH_SECONDS, True)


def _redraw(_timer_id) -> None:
    _sample_metrics()
    try:
        for manager in get_boss().all_tab_managers:
            manager.mark_tab_bar_dirty()
    except Exception:
        pass


# ─────────────────────────── Kitty entry point ───────────────────────────
def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    _ensure_timer()

    count = _tab_count(tab.os_window_id, index)
    cwd = _active_cwd(tab.os_window_id)

    # Status cells collapse in the order network -> memory -> time.
    max_right_width = max(
        0,
        screen.columns - count * MIN_TAB_WIDTH - max(0, count - 1) * TAB_GAP,
    )
    right_cells = _fit_right_cells(max_right_width)
    status_width = _right_width(right_cells)
    cwd_text, cwd_start = _centered_cwd(
        cwd, screen.columns, count, status_width
    )

    if extra_data.for_layout:
        # Kitty calls draw_tab once for measurement and once for rendering.
        # Only measure the current compact tab here; absolute-positioned
        # center/right sections are rendered during the real pass.
        return _draw_tab_body(
            draw_data,
            screen,
            tab,
            index,
            min(max_title_length, MAX_TAB_WIDTH),
            is_last,
        )

    right_start = screen.columns - status_width
    if cwd_text:
        tab_area = cwd_start - SECTION_GAP
    elif right_cells:
        tab_area = right_start - SECTION_GAP
    else:
        tab_area = screen.columns

    # Divide only the left-hand area among tabs, and cap every tab even when
    # Kitty offers more space.  This keeps the group visually compact.
    slot_width, remainder = divmod(max(1, tab_area), count)
    slot_width += int(index <= remainder)
    budget = max(1, min(max_title_length, MAX_TAB_WIDTH, slot_width))

    tab_end = _draw_tab_body(
        draw_data, screen, tab, index, budget, is_last
    )

    if is_last and cwd_text and screen.cursor.x <= cwd_start:
        _set_base_style(draw_data, screen)
        if screen.cursor.x < cwd_start:
            screen.draw(' ' * (cwd_start - screen.cursor.x))
        _draw_cwd(draw_data, screen, cwd_text)

    if is_last and right_cells:
        _set_base_style(draw_data, screen)
        if screen.cursor.x < right_start:
            screen.draw(' ' * (right_start - screen.cursor.x))

        available = max(0, screen.columns - screen.cursor.x)
        cells_to_draw = _fit_right_cells(available)
        if cells_to_draw:
            right_start = screen.columns - _right_width(cells_to_draw)
            if screen.cursor.x < right_start:
                screen.draw(' ' * (right_start - screen.cursor.x))
            _draw_right(draw_data, screen, cells_to_draw)

    # Exclude the right-side status area from the last tab's mouse hit box.
    return tab_end
