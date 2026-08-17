#!/bin/bash
# Apply SpaceX chrome that colors.toml cannot set: grayscale folders,
# D-DIN UI type, IBM Plex Mono in terminals, Adwaita cursor.
set -euo pipefail

THEME_DIR="$(cd "$(dirname "$0")" && pwd)"
FONT_DIR="$HOME/.local/share/fonts/spacex"
ICON_DIR="$HOME/.local/share/icons/spacex"
YARU_DARK="/usr/share/icons/Yaru-dark"

install_fonts() {
  mkdir -p "$FONT_DIR"
  local src="$THEME_DIR/fonts"
  if [[ -d $src ]]; then
    find "$src" -type f \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.txt' \) \
      -exec cp -f {} "$FONT_DIR/" \;
  fi
  fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
}

install_icons() {
  [[ -d $YARU_DARK ]] || return 0
  mkdir -p "$ICON_DIR"
  find "$YARU_DARK" -path '*/places/*' -name '*.png' -print0 |
    while IFS= read -r -d '' src; do
      rel="${src#"$YARU_DARK"/}"
      dest="$ICON_DIR/$rel"
      mkdir -p "$(dirname "$dest")"
      magick "$src" -colorspace Gray "$dest"
    done

  cat >"$ICON_DIR/index.theme" <<'EOF'
[Icon Theme]
Name=SpaceX
Comment=Yaru-dark with grayscale folders
Inherits=Yaru-dark,Yaru,Adwaita,hicolor
Example=folder
Directories=16x16/places,16x16@2x/places,24x24/places,24x24@2x/places,32x32/places,32x32@2x/places,48x48/places,48x48@2x/places,256x256/places,256x256@2x/places

[16x16/places]
Context=Places
Size=16
Type=Fixed

[16x16@2x/places]
Context=Places
Size=16
Scale=2
Type=Fixed

[24x24/places]
Context=Places
Size=24
Type=Fixed

[24x24@2x/places]
Context=Places
Size=24
Scale=2
Type=Fixed

[32x32/places]
Context=Places
Size=32
Type=Fixed

[32x32@2x/places]
Context=Places
Size=32
Scale=2
Type=Fixed

[48x48/places]
Context=Places
Size=48
Type=Fixed

[48x48@2x/places]
Context=Places
Size=48
Scale=2
Type=Fixed

[256x256/places]
Context=Places
Size=256
Type=Scalable
MinSize=56
MaxSize=512

[256x256@2x/places]
Context=Places
Size=256
Scale=2
Type=Scalable
MinSize=56
MaxSize=512
EOF

  if command -v gtk-update-icon-cache >/dev/null; then
    gtk-update-icon-cache -f "$ICON_DIR" >/dev/null 2>&1 || true
  fi
}

write_fontconfig() {
  mkdir -p "$HOME/.config/fontconfig"
  # Fontconfig treats '-' in a name string as a style separator, so
  # "D-DIN 11" would resolve as family=D. Expose a hyphen-free alias.
  cat >"$HOME/.config/fontconfig/fonts.conf" <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>SpaceX Sans</family>
    <prefer>
      <family>D-DIN</family>
    </prefer>
  </alias>
  <match target="pattern">
    <test name="family" qual="any">
      <string>sans-serif</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>D-DIN</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>IBM Plex Mono</string>
    </edit>
  </match>
</fontconfig>
XML
}

retint_terminals() {
  local mono="IBM Plex Mono"
  if [[ -f $HOME/.config/alacritty/alacritty.toml ]]; then
    sed -i "s/family = \".*\"/family = \"$mono\"/g" "$HOME/.config/alacritty/alacritty.toml"
  fi
  if [[ -f $HOME/.config/kitty/kitty.conf ]]; then
    sed -i "s/^font_family .*/font_family $mono/g" "$HOME/.config/kitty/kitty.conf"
  fi
  if [[ -f $HOME/.config/ghostty/config ]]; then
    sed -i "s/font-family = \".*\"/font-family = \"$mono\"/g" "$HOME/.config/ghostty/config"
  fi
  if [[ -f $HOME/.config/foot/foot.ini ]]; then
    sed -i "s/^font=.*/font=$mono:size=9/g" "$HOME/.config/foot/foot.ini"
  fi
}

apply_gsettings() {
  [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} ]] || return 0
  gsettings set org.gnome.desktop.interface icon-theme "SpaceX"
  gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  if [[ -f $HOME/.local/share/fonts/spacex/D-DIN.ttf ]]; then
    gsettings set org.gnome.desktop.interface font-name "SpaceX Sans 11"
    gsettings set org.gnome.desktop.interface document-font-name "SpaceX Sans 12"
  fi
  if [[ -f $HOME/.local/share/fonts/spacex/IBMPlexMono-Regular.ttf ]]; then
    gsettings set org.gnome.desktop.interface monospace-font-name "IBM Plex Mono 11"
  fi
}

install_fonts
install_icons
write_fontconfig
retint_terminals
apply_gsettings

printf 'SpaceX\n' >"$THEME_DIR/icons.theme"
