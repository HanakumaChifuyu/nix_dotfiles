{ pkgs, lib, ... }:

{
  home.activation = {
    installSquirrelRimeIce = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      RIME_DIR="$HOME/Library/Rime"
      MARKER="$RIME_DIR/rime_ice.schema.yaml"
      CACHE_DIR="$HOME/Library/Caches/rime-ice"
      ZIP_FILE="$CACHE_DIR/rime-ice.zip"
      EXTRACT_DIR="$CACHE_DIR/extract"

      mkdir -p "$RIME_DIR"
      mkdir -p "$CACHE_DIR"

      if [ ! -f "$MARKER" ]; then
        if [ ! -f "$ZIP_FILE" ]; then
          ${pkgs.curl}/bin/curl -fSL -o "$ZIP_FILE" \
            "https://github.com/iDvel/rime-ice/releases/download/2026.06.03/full.zip"
        fi

        rm -rf "$EXTRACT_DIR"
        mkdir -p "$EXTRACT_DIR"
        ${pkgs.unzip}/bin/unzip -o "$ZIP_FILE" -d "$EXTRACT_DIR"

        if [ ! -f "$EXTRACT_DIR/full/rime_ice.schema.yaml" ]; then
          echo "rime_ice.schema.yaml not found in rime-ice archive" >&2
          exit 1
        fi

        find "$RIME_DIR" -mindepth 1 \
          -not -name rime_ice.userdb \
          -exec rm -rf {} +
        cp -R "$EXTRACT_DIR/full/." "$RIME_DIR/"
        rm -rf "$EXTRACT_DIR"
      fi

      cp -f ${../../dotfiles/rime/default.yaml} "$RIME_DIR/default.yaml"
    '';
  };
}
