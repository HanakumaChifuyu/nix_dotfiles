{
  config,
  lib,
  pkgs,
  ...
}:

let
  solConfig = {
    # Sol only supports Command/Option/Control + Space for its main shortcut.
    # Karabiner maps Option+R to this internal Option+Space shortcut.
    globalShortcut = "option";
    showWindowOn = "screenWithFrontmost";
    launchAtLogin = true;

    # Keep integrations unrelated to app launching and clipboard history quiet.
    calendarEnabled = false;
    showAllDayEvents = false;
    showUpcomingEvent = false;
    showInAppBrowserBookMarks = false;
    mediaKeyForwardingEnabled = false;
    hyperKeyEnabled = false;

    searchFolders = [ ];
    searchEngine = "google";
    customSearchUrl = "https://google.com/search?q=%s";

    # Avoid Sol's default window-management and system-command hotkeys.
    shortcuts.clipboard_manager = "command+option+v";

    customItems = [ ];
    disabledItemIds = [ ];
    hasDismissedGettingStarted = true;
  };

  solStateFile = "${config.xdg.configHome}/sol/state.json";
in
{
  # config.json is immutable and declarative. Sol keeps usage history,
  # clipboard contents, and other runtime state separately in state.json.
  xdg.configFile."sol/config.json" = {
    force = true;
    text = builtins.toJSON solConfig;
  };

  # Clipboard persistence is intentionally stored in mutable runtime state by
  # Sol. Merge only its enable flag so existing history and rankings survive.
  home.activation.enableSolClipboardHistory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state_file=${lib.escapeShellArg solStateFile}
    state_dir="$(${pkgs.coreutils}/bin/dirname "$state_file")"
    ${pkgs.coreutils}/bin/mkdir -p "$state_dir"

    if [[ -f "$state_file" ]]; then
      state_tmp="$(${pkgs.coreutils}/bin/mktemp "$state_dir/.state.json.XXXXXX")"
      ${pkgs.jq}/bin/jq '.clipboard.saveHistory = true' "$state_file" > "$state_tmp"
      ${pkgs.coreutils}/bin/chmod 0644 "$state_tmp"
      ${pkgs.coreutils}/bin/mv -f "$state_tmp" "$state_file"
    else
      ${pkgs.jq}/bin/jq -n '{ clipboard: { saveHistory: true } }' > "$state_file"
      ${pkgs.coreutils}/bin/chmod 0644 "$state_file"
    fi
  '';
}
