let
  spaceBindings = [
    {
      key = "1";
      space = 1;
    }
    {
      key = "2";
      space = 2;
    }
    {
      key = "3";
      space = 3;
    }
    {
      key = "4";
      space = 4;
    }
    {
      key = "5";
      space = 5;
    }
    {
      key = "6";
      space = 6;
    }
    {
      key = "7";
      space = 7;
    }
    {
      key = "8";
      space = 8;
    }
    {
      key = "9";
      space = 9;
    }
    {
      key = "0";
      space = 10;
    }
  ];
in
{
  xdg.configFile."karabiner/karabiner.json" = {
    force = true;
    text = builtins.toJSON {
      global = {
        check_for_updates_on_startup = true;
        show_in_menu_bar = true;
      };

      profiles = [
        {
          name = "Default profile";
          selected = true;
          virtual_hid_keyboard.keyboard_type_v2 = "ansi";

          # Put macOS Command on the physical Alt/Option keys and use the
          # physical Command keys as the tiling-style Alt modifier.
          simple_modifications =
            map
              (binding: {
                from.key_code = binding.from;
                to = [ { key_code = binding.to; } ];
              })
              [
                {
                  from = "left_command";
                  to = "left_option";
                }
                {
                  from = "left_option";
                  to = "left_command";
                }
                {
                  from = "right_command";
                  to = "right_option";
                }
                {
                  from = "right_option";
                  to = "right_command";
                }
              ];

          complex_modifications.rules = [
            {
              description = "Alt+1-9/0: switch to macOS Desktop 1-10";
              # Simple modifications run first, so Option here is produced by
              # the physical Command keys after the Command/Option swap.
              manipulators = map (binding: {
                type = "basic";
                from = {
                  key_code = binding.key;
                  modifiers.mandatory = [ "option" ];
                };
                to = [
                  {
                    shell_command = "/Users/tohno/.local/bin/mac-space-check ${toString binding.space}";
                  }
                  {
                    # Let Mission Control perform the actual switch. The
                    # helper only reports a missing target Space.
                    key_code = binding.key;
                    modifiers = [ "control" ];
                  }
                  {
                    set_variable = {
                      name = "mac_window_filled_by_alt_a";
                      value = false;
                    };
                  }
                ];
              }) spaceBindings;
            }
            {
              description = "Alt+A: toggle window fill and previous size";
              # macOS exposes Fill as Fn+Control+F and Return to Previous Size
              # as Fn+Control+R. The variable remembers which action Alt+A
              # most recently applied.
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "a";
                    modifiers.mandatory = [ "option" ];
                  };
                  to = [
                    {
                      key_code = "r";
                      modifiers = [
                        "fn"
                        "control"
                      ];
                      repeat = false;
                    }
                    {
                      set_variable = {
                        name = "mac_window_filled_by_alt_a";
                        value = false;
                      };
                    }
                  ];
                  conditions = [
                    {
                      type = "variable_if";
                      name = "mac_window_filled_by_alt_a";
                      value = true;
                    }
                  ];
                }
                {
                  type = "basic";
                  from = {
                    key_code = "a";
                    modifiers.mandatory = [ "option" ];
                  };
                  to = [
                    {
                      key_code = "f";
                      modifiers = [
                        "fn"
                        "control"
                      ];
                      repeat = false;
                    }
                    {
                      set_variable = {
                        name = "mac_window_filled_by_alt_a";
                        value = true;
                      };
                    }
                  ];
                }
              ];
            }
            {
              description = "Caps Lock: tap Escape, hold Control (200 ms)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "caps_lock";
                    modifiers.optional = [ "any" ];
                  };
                  # Unlike keyd overloadt, a chord activates Control immediately
                  # instead of queuing intervening keys until the timeout.
                  to = [
                    {
                      key_code = "left_control";
                      lazy = true;
                    }
                  ];
                  to_if_alone = [ { key_code = "escape"; } ];
                  to_if_held_down = [ { key_code = "left_control"; } ];
                  parameters = {
                    "basic.to_if_alone_timeout_milliseconds" = 200;
                    "basic.to_if_held_down_threshold_milliseconds" = 200;
                  };
                }
              ];
            }
            {
              description = "Page Up/Down: scroll wheel";
              # Karabiner provides continuous scrolling rather than keyd's
              # macro2(100, 100, ...); speed also follows macOS mouse settings.
              manipulators =
                map
                  (binding: {
                    type = "basic";
                    from = {
                      key_code = binding.key;
                      modifiers.optional = [ "any" ];
                    };
                    to = [ { mouse_key.vertical_wheel = binding.speed; } ];
                  })
                  [
                    {
                      key = "page_up";
                      speed = -32;
                    }
                    {
                      key = "page_down";
                      speed = 32;
                    }
                  ];
            }
            {
              description = "Option+Shift+S: capture, save, and copy screenshot";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "s";
                    modifiers.mandatory = [
                      "option"
                      "shift"
                    ];
                  };
                  to = [
                    {
                      shell_command = "/Users/tohno/.local/bin/mac-screenshot";
                    }
                  ];
                }
              ];
            }
            {
              description = "Option+R: open Sol";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "r";
                    modifiers.mandatory = [ "option" ];
                  };
                  to = [
                    {
                      key_code = "spacebar";
                      modifiers = [ "option" ];
                    }
                  ];
                }
              ];
            }
            {
              description = "Ctrl+h/j/k/l to arrow keys";
              # No optional Shift: Ctrl+Shift+h/j/k/l pass through unchanged,
              # matching keyd's explicit control+shift layer.
              manipulators =
                map
                  (binding: {
                    type = "basic";
                    from = {
                      key_code = binding.from;
                      modifiers.mandatory = [ "control" ];
                    };
                    to = [ { key_code = binding.to; } ];
                  })
                  [
                    {
                      from = "h";
                      to = "left_arrow";
                    }
                    {
                      from = "j";
                      to = "down_arrow";
                    }
                    {
                      from = "k";
                      to = "up_arrow";
                    }
                    {
                      from = "l";
                      to = "right_arrow";
                    }
                  ];
            }
            {
              description = "Ctrl+C/V clipboard shortcuts with terminal exceptions";
              # Kitty handles both shortcuts itself. Ghostty must receive
              # Ctrl+C unchanged for SIGINT, while Ctrl+V continues to use
              # the macOS paste shortcut provided by this rule.
              manipulators =
                map
                  (binding: {
                    type = "basic";
                    from = {
                      key_code = binding.key;
                      modifiers.mandatory = [ "control" ];
                    };
                    to = [
                      {
                        key_code = binding.key;
                        modifiers = [ "command" ];
                      }
                    ];
                    conditions = [
                      {
                        type = "frontmost_application_unless";
                        bundle_identifiers = binding.excludedBundleIdentifiers;
                      }
                    ];
                  })
                  [
                    {
                      key = "c";
                      excludedBundleIdentifiers = [
                        "^net\\.kovidgoyal\\.kitty$"
                        "^com\\.mitchellh\\.ghostty$"
                      ];
                    }
                    {
                      key = "v";
                      excludedBundleIdentifiers = [ "^net\\.kovidgoyal\\.kitty$" ];
                    }
                  ];
            }
          ];
        }
      ];
    };
  };
}
