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

          simple_modifications = [
            {
              from.key_code = "caps_lock";
              to = [ { key_code = "escape"; } ];
            }
            {
              from.key_code = "left_control";
              to = [ { key_code = "fn"; } ];
            }
            {
              from.key_code = "fn";
              to = [ { key_code = "left_control"; } ];
            }
            {
              from.key_code = "left_command";
              to = [ { key_code = "left_option"; } ];
            }
            {
              from.key_code = "left_option";
              to = [ { key_code = "left_command"; } ];
            }
            {
              from.key_code = "right_command";
              to = [ { key_code = "right_option"; } ];
            }
            {
              from.key_code = "right_option";
              to = [ { key_code = "right_command"; } ];
            }
          ];

          complex_modifications.rules = [
            {
              description = "Ctrl+h/j/k/l to arrow keys";
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
              description = "Ctrl editing shortcuts to Command outside Kitty";
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
                    "a"
                    "c"
                    "v"
                    "x"
                    "z"
                  ];
            }
          ];
        }
      ];
    };
  };
}
