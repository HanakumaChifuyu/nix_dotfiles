{ config, pkgs, ... }:

let
  windowModifier = if pkgs.stdenv.isDarwin then "cmd" else "alt";
in
{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11.0;
    };

    settings = {
      cursor_blink_interval = 0;
      cursor_shape = "block";
      cursor_shape_unfocused = "hollow";
      cursor_beam_thickness = 1.5;
      cursor_underline_thickness = 2.0;

      confirm_os_window_close = 1;
      shell = "${pkgs.fish}/bin/fish";

      copy_on_select = "no";
      strip_trailing_spaces = "smart";

      draw_minimal_borders = "yes";
      window_border_width = "1pt";
      window_margin_width = 0;
      window_padding_width = 4;
      hide_window_decorations = "no";

      tab_bar_min_tabs = 2;
      tab_bar_edge = "bottom";
      tab_bar_style = "custom";
      tab_title_template = "{index}: {title[:20]}{'  :{}'.format(num_windows) if num_windows > 1 else ''}";

      enabled_layouts = "splits:split_axis=horizontal";
      shell_integration = "enabled";
      scrollback_lines = 10000;
      scrollback_pager_history_size = 200;
    };

    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";

      "ctrl+plus" = "change_font_size all +1";
      "ctrl+equal" = "change_font_size all +1";
      "ctrl+kp_add" = "change_font_size all +1";
      "ctrl+minus" = "change_font_size all -1";
      "ctrl+underscore" = "change_font_size all -1";
      "ctrl+kp_subtract" = "change_font_size all -1";
      "ctrl+0" = "change_font_size all 0";
      "ctrl+kp_0" = "change_font_size all 0";

      "ctrl+shift+i" = "new_tab";
      "ctrl+shift+h" = "previous_tab";
      "ctrl+shift+l" = "next_tab";

      "ctrl+shift+j" = "scroll_line_down";
      "ctrl+shift+k" = "scroll_line_up";

      "${windowModifier}+-" = "launch --location=hsplit --cwd=current";
      "${windowModifier}+\\" = "launch --location=vsplit --cwd=current";

      "${windowModifier}+k" = "neighboring_window up";
      "${windowModifier}+j" = "neighboring_window down";
      "${windowModifier}+h" = "neighboring_window left";
      "${windowModifier}+l" = "neighboring_window right";

      "${windowModifier}+shift+k" = "move_window up";
      "${windowModifier}+shift+j" = "move_window down";
      "${windowModifier}+shift+h" = "move_window left";
      "${windowModifier}+shift+l" = "move_window right";

      "${windowModifier}+up" = "resize_window taller";
      "${windowModifier}+down" = "resize_window shorter 3";
      "${windowModifier}+right" = "resize_window narrower";
      "${windowModifier}+left" = "resize_window wider 3";

      "ctrl+left" = "resize_window narrower 3";
      "ctrl+right" = "resize_window wider 3";
      "ctrl+up" = "resize_window taller 3";
      "ctrl+down" = "resize_window shorter 3";

      "${windowModifier}+q" = "close_window_with_confirmation";
      "${windowModifier}+/" =
        "launch --stdin-source=@screen_scrollback --type=overlay ${config.home.homeDirectory}/.config/kitty/scrollback-nvim.sh";
    };

    extraConfig = ''
      include themes/tokyonight_night.conf
    '';
  };

  xdg.configFile."kitty/tab_bar.py".source = ../dotfiles/.config/kitty/tab_bar.py;
  xdg.configFile."kitty/themes".source = ../dotfiles/.config/kitty/themes;
  xdg.configFile."kitty/scrollback-nvim.sh" = {
    source = ../dotfiles/.config/kitty/scrollback-nvim.sh;
    executable = true;
  };
}
