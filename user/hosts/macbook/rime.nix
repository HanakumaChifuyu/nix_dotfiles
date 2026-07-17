{ pkgs, lib, ... }:

{
  home.activation = {
    installSquirrelRimeIce = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      RIME_DIR="$HOME/Library/Rime"
      MARKER="$RIME_DIR/rime_ice.schema.yaml"
      ZIP_FILE="$RIME_DIR/rime-ice.zip"
      EXTRACT_DIR="$RIME_DIR/.rime-ice-extract"

      mkdir -p "$RIME_DIR"

      if [ ! -f "$MARKER" ]; then
        find "$RIME_DIR" -mindepth 1 \
          -not -name rime_ice.userdb \
          -not -name rime-ice.zip \
          -exec rm -rf {} +

        if [ ! -f "$ZIP_FILE" ]; then
          ${pkgs.curl}/bin/curl -fSL -o "$ZIP_FILE" \
            "https://github.com/iDvel/rime-ice/releases/download/2026.06.03/full.zip"
        fi

        rm -rf "$EXTRACT_DIR"
        mkdir -p "$EXTRACT_DIR"
        ${pkgs.unzip}/bin/unzip -o "$ZIP_FILE" -d "$EXTRACT_DIR"
        cp -R "$EXTRACT_DIR/full/." "$RIME_DIR/"
        rm -rf "$EXTRACT_DIR"
      fi

      cp -f ${../../dotfiles/rime/default.yaml} "$RIME_DIR/default.yaml"
    '';
  };
}
