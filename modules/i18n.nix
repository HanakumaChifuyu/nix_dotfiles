{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Select internationalisation properties.
  # Keep en_US as default locale to avoid TTY garbled text.
  # Chinese display is handled by fonts and input method.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
  };
}
