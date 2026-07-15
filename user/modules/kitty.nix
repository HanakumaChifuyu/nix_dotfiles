{ config, ... }:

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
      shell = "fish";

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

      "alt+-" = "launch --location=hsplit --cwd=current";
      "alt+\\" = "launch --location=vsplit --cwd=current";

      "alt+k" = "neighboring_window up";
      "alt+j" = "neighboring_window down";
      "alt+h" = "neighboring_window left";
      "alt+l" = "neighboring_window right";

      "alt+shift+k" = "move_window up";
      "alt+shift+j" = "move_window down";
      "alt+shift+h" = "move_window left";
      "alt+shift+l" = "move_window right";

      "alt+up" = "resize_window taller";
      "alt+down" = "resize_window shorter 3";
      "alt+right" = "resize_window narrower";
      "alt+left" = "resize_window wider 3";

      "ctrl+left" = "resize_window narrower 3";
      "ctrl+right" = "resize_window wider 3";
      "ctrl+up" = "resize_window taller 3";
      "ctrl+down" = "resize_window shorter 3";

      "alt+q" = "close_window_with_confirmation";
      "alt+/" =
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
