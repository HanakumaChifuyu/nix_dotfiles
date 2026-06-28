"""
~/.config/kitty/tab_bar.py
三段式: 左 cwd / 中 tab 列表 / 右 网速+内存+时间
基于 Cell 抽象 + 自适应折叠 + 圆角胶囊
"""
from enum import Enum
from typing import Callable
from pathlib import Path
import os
import datetime
import time

from kitty.fast_data_types import Screen, add_timer, get_boss, get_options
from kitty.tab_bar import DrawData, TabBarData, ExtraData, TabAccessor, as_rgb
from kitty.utils import color_as_int

opts = None
BG = FG = COLOR_TAB = COLOR_TAB_ACTIVE = COLOR_TIME = COLOR_NET = COLOR_MEM = COLOR_CWD = 0


def _init_colors():
    global opts, BG, FG, COLOR_TAB, COLOR_TAB_ACTIVE
    global COLOR_TIME, COLOR_NET, COLOR_MEM, COLOR_CWD
    if opts is not None:
        return
    opts = get_options()
    BG_COLOR = opts.color19 if hasattr(opts, 'color19') else opts.background
    BG = as_rgb(color_as_int(BG_COLOR))
    FG = as_rgb(color_as_int(opts.color7))
    COLOR_TAB        = as_rgb(color_as_int(opts.color3))
    COLOR_TAB_ACTIVE = as_rgb(color_as_int(opts.color5))
    COLOR_TIME       = as_rgb(color_as_int(opts.color4))
    COLOR_NET        = as_rgb(color_as_int(opts.color6))
    COLOR_MEM        = as_rgb(color_as_int(opts.color2))
    COLOR_CWD        = as_rgb(color_as_int(opts.color4))

# 圆角胶囊 (左帽 / 右帽), 替换为 (' ', ' ') 即可方角
BORDER_L, BORDER_R = '', ''

REFRESH_TIME = 2.0
MAX_LENGTH_PATH = 3

ICON_FOLDER = ' '
ICON_TIME   = '󰥔 '
ICON_NET    = ' '
ICON_MEM    = ' '

_net_state = {'t': 0.0, 'rx': 0, 'tx': 0}


# ─────────────────────────── Cell ───────────────────────────
class Cell:
    def __init__(self, icon, text_fn, tab=None,
                 bg=None, fg=None, color=None,
                 separator='', border=None):
        if border is None:
            border = (BORDER_L, BORDER_R)
        self.tab = tab
        self.fg = fg if fg is not None else FG
        self.bg = bg if bg is not None else BG
        self.color = color if color is not None else COLOR_TAB
        self.icon = icon; self.text_fn = text_fn
        self.border = border; self.separator = separator
        self.text_length_overhead = (
            len(border[0] + border[1] + separator + icon) + 1
        )

    def draw(self, screen: Screen, max_size: int):
        text = self.text_fn(max_size - self.text_length_overhead, self.tab)
        if text is None:
            return
        screen.cursor.dim = False; screen.cursor.italic = False
        screen.cursor.bg = 0; screen.cursor.fg = self.color
        screen.draw(self.border[0])
        screen.cursor.bg = self.color; screen.cursor.fg = self.bg
        screen.cursor.bold = True
        screen.draw(self.icon)
        screen.cursor.bold = False
        if text == '':
            screen.cursor.bg = 0; screen.cursor.fg = self.color
            screen.draw(self.border[1])
        else:
            screen.cursor.bg = self.bg; screen.cursor.fg = self.color
            screen.draw(self.separator)
            screen.cursor.fg = self.fg
            screen.draw(f' {text}')
            screen.cursor.fg = self.bg; screen.cursor.bg = 0
            screen.draw(self.border[1])

    def length(self, max_size):
        text = self.text_fn(max_size - self.text_length_overhead, self.tab)
        if text is None: return 0
        if text == '':   return len(self.icon + self.border[0] + self.border[1])
        return len(text) + self.text_length_overhead


# ─────────────────────────── 数据源 ───────────────────────────
def get_wd(max_size, tab):
    try:
        accessor = TabAccessor(tab.tab_id)
        wd = Path(accessor.active_wd)
        home = Path(os.getenv('HOME') or '/')
        if wd == home:
            wd = Path('~')
        elif wd.is_relative_to(home):
            wd = Path('~') / wd.relative_to(home)
        parts = list(wd.parts)
        compressed = False
        if len(parts) > MAX_LENGTH_PATH:
            compressed = True
            parts = [parts[0], '..'] + parts[-MAX_LENGTH_PATH:]
        cnt = 1 + compressed
        while cnt != len(parts):
            s = '/'.join(parts[0:1 + compressed] + parts[cnt:])
            if len(s) <= max_size:
                return s
            cnt += 1
        if len(parts[-1]) <= max_size:
            return parts[-1]
    except Exception:
        pass
    return None


def get_time(max_size, tab):
    return datetime.datetime.now().strftime('%H:%M') if max_size >= 5 else None


def get_tab_text(max_size, tab):
    try:
        accessor = TabAccessor(tab.tab_id)
        if tab.title and tab.title[0] == '#':
            text = tab.title[1:]
        else:
            text = str(accessor.active_exe)
        return '' if max_size <= len(text) else text
    except Exception:
        return ''


def get_mem(max_size, tab=None):
    try:
        info = {}
        with open('/proc/meminfo') as f:
            for line in f:
                k, _, rest = line.partition(':')
                info[k] = int(rest.strip().split()[0])
        total = info['MemTotal']
        avail = info.get('MemAvailable', info.get('MemFree', 0))
        s = f'{int((total - avail) * 100 / total)}%'
        return s if len(s) <= max_size else None
    except Exception:
        return None


def _fmt(bps):
    if bps < 1024: return f'{int(bps)}B'
    if bps < 1024 * 1024: return f'{bps/1024:.0f}K'
    return f'{bps/1024/1024:.1f}M'


def get_net(max_size, tab=None):
    try:
        rx = tx = 0
        with open('/proc/net/dev') as f:
            next(f); next(f)
            for line in f:
                name, _, rest = line.partition(':')
                name = name.strip()
                if name == 'lo' or name.startswith(('docker', 'veth', 'br-', 'virbr')):
                    continue
                fs = rest.split()
                rx += int(fs[0]); tx += int(fs[8])
        now = time.time()
        prev_t = _net_state['t']; prev_rx = _net_state['rx']; prev_tx = _net_state['tx']
        _net_state['t'] = now; _net_state['rx'] = rx; _net_state['tx'] = tx
        if prev_t == 0:
            s = '0K 0K'
        else:
            dt = max(now - prev_t, 0.001)
            s = f'{_fmt((rx-prev_rx)/dt)} {_fmt((tx-prev_tx)/dt)}'
        return s if len(s) <= max_size else None
    except Exception:
        return None


def get_tab_cell(tab):
    color = COLOR_TAB_ACTIVE if tab.is_active else COLOR_TAB
    return Cell(f' {tab.tab_id} '.strip() + ' ', get_tab_text, tab, color=color)


# ─────────────────────────── 自适应中段 ───────────────────────────
class Strategy(Enum):
    EXPAND_ALL = 0
    EXPAND_ACTIVE = 1
    NO_EXPAND = 2
    SHOW_ACTIVE = 3
    SHOW_ACTIVE_NO_EXPAND = 4


_center: list = []
_active_index = 0
_timer_id = None


def _strategy(screen):
    n = len(_center)
    length = n - 1 + sum(c.length(screen.columns) for c in _center)
    if length < screen.columns:
        return Strategy.EXPAND_ALL, length
    length = n - 1
    for i, c in enumerate(_center):
        length += c.length(screen.columns) if i == _active_index else c.length(0)
    if length < screen.columns:
        return Strategy.EXPAND_ACTIVE, length
    length = n - 1 + sum(c.length(0) for c in _center)
    if length < screen.columns:
        return Strategy.NO_EXPAND, length
    length = _center[_active_index].length(screen.columns)
    if length < screen.columns:
        return Strategy.SHOW_ACTIVE, length
    return Strategy.SHOW_ACTIVE_NO_EXPAND, _center[_active_index].length(0)


def _draw_center(screen, strategy):
    if strategy is Strategy.EXPAND_ALL:
        for i, c in enumerate(_center):
            if i: screen.draw(' ')
            c.draw(screen, screen.columns)
    elif strategy is Strategy.EXPAND_ACTIVE:
        for i, c in enumerate(_center):
            if i: screen.draw(' ')
            c.draw(screen, screen.columns * (i == _active_index))
    elif strategy is Strategy.NO_EXPAND:
        for i, c in enumerate(_center):
            if i: screen.draw(' ')
            c.draw(screen, 0)
    elif strategy is Strategy.SHOW_ACTIVE:
        _center[_active_index].draw(screen, screen.columns)
    else:
        _center[_active_index].draw(screen, 0)


def _draw_left(screen, max_length):
    if not _center: return
    Cell(ICON_FOLDER, get_wd, _center[_active_index].tab, color=COLOR_CWD)\
        .draw(screen, max_length)


def _draw_right(screen):
    max_size = screen.columns - screen.cursor.x
    cells = [
        Cell(ICON_NET,  get_net, color=COLOR_NET),
        Cell(ICON_MEM,  get_mem, color=COLOR_MEM),
        Cell(ICON_TIME, get_time, color=COLOR_TIME),
    ]
    sizes = []
    remaining = max_size
    for c in cells:
        l = c.length(remaining)
        sizes.append(l)
        if l: remaining -= l + 1
    total = sum(s for s in sizes if s) + max(0, sum(1 for s in sizes if s) - 1)
    pad = max_size - total
    if pad > 0:
        screen.draw(' ' * pad)
    first = True
    for c, l in zip(cells, sizes):
        if l == 0: continue
        if not first: screen.draw(' ')
        c.draw(screen, max_size)
        first = False


def _redraw(_):
    tm = get_boss().active_tab_manager
    if tm: tm.mark_tab_bar_dirty()


def draw_tab(draw_data: DrawData, screen: Screen, tab: TabBarData,
             before: int, max_title_length: int, index: int,
             is_last: bool, extra_data: ExtraData) -> int:
    global _center, _active_index, _timer_id
    _init_colors()
    if _timer_id is None:
        _timer_id = add_timer(_redraw, REFRESH_TIME, True)
    if tab.is_active:
        _active_index = index - 1
    _center.append(get_tab_cell(tab))
    if is_last:
        strategy, length = _strategy(screen)
        center_start = (screen.columns - length) // 2
        _draw_left(screen, max(0, center_start - 1))
        screen.cursor.x = center_start
        _draw_center(screen, strategy)
        screen.draw(' ')
        _draw_right(screen)
        _center = []
    return screen.cursor.x
