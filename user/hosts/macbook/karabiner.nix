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

          complex_modifications.rules = [
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
              description = "Ctrl+C/V copy and paste outside Kitty";
              # Kitty handles copy_or_interrupt and paste_from_clipboard itself.
              manipulators =
                map
                  (key: {
                    type = "basic";
                    from = {
                      key_code = key;
                      modifiers.mandatory = [ "control" ];
                    };
                    to = [
                      {
                        key_code = key;
                        modifiers = [ "command" ];
                      }
                    ];
                    conditions = [
                      {
                        type = "frontmost_application_unless";
                        bundle_identifiers = [ "^net\\.kovidgoyal\\.kitty$" ];
                      }
                    ];
                  })
                  [
                    "c"
                    "v"
                  ];
            }
          ];
        }
      ];
    };
  };
}
