{ pkgs, ... }:

let
  # Karabiner swaps Command and Option globally. skhd sees the logical modifier,
  # so `alt` below is triggered by the physical Command key.
  kitty = "/Users/mac/Applications/Home Manager Apps/kitty.app";
in
{
  services.yabai = {
    enable = true;
    package = pkgs.yabai;

    # Keep SIP fully enabled. Advanced scripting-addition features are disabled.
    enableScriptingAddition = false;

    config = {
      layout = "bsp";
      auto_balance = "off";
      split_ratio = 0.50;
      window_placement = "second_child";

      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 5;

      focus_follows_mouse = "off";
      mouse_follows_focus = "off";
      mouse_modifier = "alt";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";
    };

    extraConfig = ''
      # Float dialogs and utility windows, similar to the Hyprland rules.
      yabai -m rule --add subrole='AXDialog' manage=off
      yabai -m rule --add subrole='AXSystemDialog' manage=off
      yabai -m rule --add app='^(System Settings|Calculator|Archive Utility)$' manage=off
      yabai -m rule --add app='^Anki$' manage=off
      yabai -m rule --add title='^(Picture in Picture|About .*)$' manage=off
    '';
  };

  services.skhd = {
    enable = true;
    package = pkgs.skhd;

    skhdConfig = ''
      # Main modifier: physical Command (logical Option after Karabiner swap).

      # Applications and basic window actions.
      alt - return : open -na '${kitty}'
      alt - r      : open -a 'Raycast'
      alt - q      : yabai -m window --close
      alt - f      : yabai -m window --toggle zoom-fullscreen
      alt - a      : yabai -m window --toggle zoom-parent
      alt - space  : yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2
      alt - tab    : yabai -m window --focus recent

      # Screenshot: physical Option+Shift+S selects a region and copies it.
      # Physical Option is logical Command after the Karabiner swap.
      cmd + shift - s : /usr/sbin/screencapture -i -c
      alt + shift - s : /usr/sbin/screencapture -i -c

      # Focus windows with physical Command+h/j/k/l.
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      # Resize windows, following the Hyprland Shift+h/j/k/l bindings.
      alt + shift - h : yabai -m window --resize left:-20:0
      alt + shift - j : yabai -m window --resize bottom:0:20
      alt + shift - k : yabai -m window --resize top:0:-20
      alt + shift - l : yabai -m window --resize right:20:0

      # Move a tiled window in the tree. Physical Fn is logical Control because
      # Fn and Control are also swapped by Karabiner.
      alt + ctrl - h : yabai -m window --warp west
      alt + ctrl - j : yabai -m window --warp south
      alt + ctrl - k : yabai -m window --warp north
      alt + ctrl - l : yabai -m window --warp east

      # Layout controls.
      alt - e : yabai -m space --balance
      alt + shift - r : yabai -m space --rotate 90
      alt - x : yabai -m window --toggle split

      # Native macOS Spaces. Existing Spaces must be created in Mission Control.
      alt - 1 : yabai -m space --focus 1
      alt - 2 : yabai -m space --focus 2
      alt - 3 : yabai -m space --focus 3
      alt - 4 : yabai -m space --focus 4
      alt - 5 : yabai -m space --focus 5
      alt - 6 : yabai -m space --focus 6
      alt - 7 : yabai -m space --focus 7
      alt - 8 : yabai -m space --focus 8
      alt - 9 : yabai -m space --focus 9

      alt + shift - 1 : yabai -m window --space 1; yabai -m space --focus 1
      alt + shift - 2 : yabai -m window --space 2; yabai -m space --focus 2
      alt + shift - 3 : yabai -m window --space 3; yabai -m space --focus 3
      alt + shift - 4 : yabai -m window --space 4; yabai -m space --focus 4
      alt + shift - 5 : yabai -m window --space 5; yabai -m space --focus 5
      alt + shift - 6 : yabai -m window --space 6; yabai -m space --focus 6
      alt + shift - 7 : yabai -m window --space 7; yabai -m space --focus 7
      alt + shift - 8 : yabai -m window --space 8; yabai -m space --focus 8
      alt + shift - 9 : yabai -m window --space 9; yabai -m space --focus 9
    '';
  };

  # Keep native Space ordering deterministic for numeric workspace bindings.
  system.defaults.dock.mru-spaces = false;
  system.defaults.spaces.spans-displays = false;
}
