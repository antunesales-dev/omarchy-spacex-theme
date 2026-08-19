#!/bin/bash
# Apply SpaceX chrome that colors.toml cannot set: grayscale folders,
# D-DIN UI type, IBM Plex Mono in terminals, Adwaita cursor, clock/network
# overlays, lock designs, and a launch cache.
set -euo pipefail

THEME_DIR="$(cd "$(dirname "$0")" && pwd)"
FONT_DIR="$HOME/.local/share/fonts/spacex"
ICON_DIR="$HOME/.local/share/icons/SpaceX"
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

grayscale_png() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  magick "$src" -colorspace Gray "$dest"
}

recolor_folder_svg() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  python3 - "$src" "$dest" <<'PY'
import pathlib, re, sys
src, dest = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
text = src.read_text(encoding="utf-8")
# Adwaita folder blues -> stainless / charcoal
repl = {
    "#62a0ea": "#9a9a9a",
    "#62A0EA": "#9a9a9a",
    "#afd4ff": "#d0d0d0",
    "#AFD4FF": "#d0d0d0",
    "#438de6": "#7a7a7a",
    "#438DE6": "#7a7a7a",
    "#1c71d8": "#6a6a6a",
    "#1C71D8": "#6a6a6a",
    "#1a5fb4": "#5a5a5a",
    "#1A5FB4": "#5a5a5a",
    "#3584e4": "#8a8a8a",
    "#3584E4": "#8a8a8a",
    "#c0d5ea": "#c4c8cc",
    "#C0D5EA": "#c4c8cc",
    "#a4caee": "#b4b4b4",
    "#A4CAEE": "#b4b4b4",
    "#99c1f1": "#b0b0b0",
    "#99C1F1": "#b0b0b0",
}
for old, new in repl.items():
    text = text.replace(old, new)
text = re.sub(r'stop-color="#[0-9a-fA-F]{6}"', 'stop-color="#9a9a9a"', text)
dest.write_text(text, encoding="utf-8")
PY
}

copy_icon_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  case "$src" in
    *.png) grayscale_png "$src" "$dest" ;;
    *.svg) cp -f "$src" "$dest" ;;
  esac
}

install_sidebar_icons() {
  local name root src rel
  local names=(
    starred-symbolic
    non-starred-symbolic
    semi-starred-symbolic
    semi-starred-rtl-symbolic
    user-trash-symbolic
    user-trash-full-symbolic
    user-bookmarks-symbolic
  )
  local roots=(
    /usr/share/icons/Adwaita
    /usr/share/icons/AdwaitaLegacy
    /usr/share/icons/Yaru
    /usr/share/icons/Yaru-dark
  )

  for name in "${names[@]}"; do
    src=""
    for root in "${roots[@]}"; do
      [[ -d $root ]] || continue
      src="$(find "$root" \( -name "${name}.svg" -o -name "${name}.png" \) -print -quit 2>/dev/null || true)"
      [[ -n $src ]] || continue
      rel="${src#"$root"/}"
      # Nautilus sidebar looks up these in the Places context. Put the
      # glyphs in scalable/places so they are visible without declaring
      # a Status/symbolic tree that would hide other inherited icons.
      if [[ $src == *.svg ]]; then
        copy_icon_file "$src" "$ICON_DIR/scalable/places/${name}.svg"
        copy_icon_file "$src" "$ICON_DIR/scalable/status/${name}.svg"
      elif [[ $name == user-trash-symbolic || $name == user-trash-full-symbolic ]]; then
        copy_icon_file "$src" "$ICON_DIR/$rel"
      fi
      break
    done
  done

  # Yaru-dark has no trash rasters; copy Yaru's and desaturate.
  if [[ -d /usr/share/icons/Yaru ]]; then
    find /usr/share/icons/Yaru \( -name 'user-trash.png' -o -name 'user-trash-full.png' \) -print0 |
      while IFS= read -r -d '' src; do
        rel="${src#/usr/share/icons/Yaru/}"
        grayscale_png "$src" "$ICON_DIR/$rel"
      done
  fi
}

install_icons() {
  mkdir -p "$ICON_DIR"
  if [[ -d $YARU_DARK ]]; then
    find "$YARU_DARK" -path '*/places/*' \( -name '*.png' -o -name '*folder*' -o -name '*inode-directory*' \) -print0 |
      while IFS= read -r -d '' src; do
        rel="${src#"$YARU_DARK"/}"
        case "$src" in
          *.png) grayscale_png "$src" "$ICON_DIR/$rel" ;;
        esac
      done
  fi

  # GTK file choosers (Chromium portal) prefer Adwaita's scalable blue SVGs.
  local adwaita
  for adwaita in /usr/share/icons/Adwaita /usr/share/icons/AdwaitaLegacy; do
    [[ -d $adwaita ]] || continue
    find "$adwaita" \( -iname '*folder*' -o -iname '*inode-directory*' \) \( -name '*.png' -o -name '*.svg' \) -print0 |
      while IFS= read -r -d '' src; do
        rel="${src#"$adwaita"/}"
        case "$src" in
          *.png) grayscale_png "$src" "$ICON_DIR/$rel" ;;
          *.svg) recolor_folder_svg "$src" "$ICON_DIR/$rel" ;;
        esac
      done
  done

  install_sidebar_icons

  # Incomplete symbolic/ trees hide inherited sidebar icons. Keep only
  # scalable/status for starred/trash and places for folders.
  rm -rf "$ICON_DIR/symbolic" "$ICON_DIR"/[0-9]*/status "$ICON_DIR"/*@2x/status "$ICON_DIR/scalable/extra"

  cat >"$ICON_DIR/index.theme" <<'EOF'
[Icon Theme]
Name=SpaceX
Comment=Yaru-dark with grayscale folders
Inherits=Yaru-dark,Yaru,Adwaita,hicolor
Example=folder
Directories=16x16/places,16x16@2x/places,24x24/places,24x24@2x/places,32x32/places,32x32@2x/places,48x48/places,48x48@2x/places,256x256/places,256x256@2x/places,scalable/places,scalable/status

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

[scalable/places]
Context=Places
Size=128
MinSize=8
MaxSize=512
Type=Scalable

[scalable/status]
Context=Status
Size=16
MinSize=8
MaxSize=512
Type=Scalable
EOF

  if command -v gtk4-update-icon-cache >/dev/null; then
    gtk4-update-icon-cache -f "$ICON_DIR" >/dev/null 2>&1 || true
  elif command -v gtk-update-icon-cache >/dev/null; then
    gtk-update-icon-cache -f "$ICON_DIR" >/dev/null 2>&1 || true
  fi
}

write_fontconfig() {
  mkdir -p "$HOME/.config/fontconfig/conf.d"
  # Fontconfig parses "D-DIN" as family=D + style=DIN, then falls back to
  # Liberation for missing weights. Keep a hyphen-free alias and remap that
  # split so every size stays on D-DIN.
  cat >"$HOME/.config/fontconfig/conf.d/50-spacex.conf" <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>~/.local/share/fonts/spacex</dir>

  <match target="pattern">
    <test name="family"><string>D</string></test>
    <test name="style" compare="contains"><string>DIN Condensed</string></test>
    <edit name="family" mode="assign" binding="strong"><string>D-DIN Condensed</string></edit>
  </match>
  <match target="pattern">
    <test name="family"><string>D</string></test>
    <test name="style" compare="contains"><string>DINExp</string></test>
    <edit name="family" mode="assign" binding="strong"><string>D-DINExp</string></edit>
  </match>
  <match target="pattern">
    <test name="family"><string>D</string></test>
    <test name="style" compare="contains"><string>DIN</string></test>
    <edit name="family" mode="assign" binding="strong"><string>D-DIN</string></edit>
  </match>

  <alias binding="strong">
    <family>SpaceX Sans</family>
    <prefer><family>D-DIN</family></prefer>
    <default><family>D-DIN</family></default>
  </alias>
  <alias binding="same">
    <family>D-DIN</family>
    <default><family>D-DIN</family></default>
  </alias>

  <match target="pattern">
    <test name="family" qual="any"><string>sans-serif</string></test>
    <edit name="family" mode="prepend_first" binding="strong"><string>D-DIN</string></edit>
  </match>
  <match target="pattern">
    <test name="family" qual="any"><string>monospace</string></test>
    <edit name="family" mode="prepend_first" binding="strong"><string>IBM Plex Mono</string></edit>
  </match>

  <match target="font">
    <test name="family" compare="contains"><string>D-DIN</string></test>
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
    <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
    <edit name="embeddedbitmap" mode="assign"><bool>false</bool></edit>
  </match>
</fontconfig>
XML

  cat >"$HOME/.config/fontconfig/fonts.conf" <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <include ignore_missing="yes">conf.d</include>
  <!-- "D-DIN" parses as family=D. Remap before fallback. -->
  <match target="pattern">
    <test name="family"><string>D</string></test>
    <edit name="family" mode="assign" binding="strong"><string>D-DIN</string></edit>
  </match>
  <alias>
    <family>SpaceX Sans</family>
    <prefer><family>D-DIN</family></prefer>
  </alias>
  <match target="pattern">
    <test name="family" qual="any"><string>sans-serif</string></test>
    <edit name="family" mode="prepend_first" binding="strong"><string>D-DIN</string></edit>
  </match>
  <match target="pattern">
    <test name="family" qual="any"><string>monospace</string></test>
    <edit name="family" mode="prepend_first" binding="strong"><string>IBM Plex Mono</string></edit>
  </match>
  <!-- D-DIN stores styles as DIN-Bold / DIN-Italic, not Bold / Italic. -->
  <match target="pattern">
    <test name="family"><string>D-DIN</string></test>
    <test name="weight" compare="more_eq"><int>200</int></test>
    <edit name="style" mode="assign" binding="strong"><string>DIN-Bold</string></edit>
  </match>
  <match target="pattern">
    <test name="family"><string>D-DIN</string></test>
    <test name="slant" compare="not_eq"><const>roman</const></test>
    <edit name="style" mode="assign" binding="strong"><string>DIN-Italic</string></edit>
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
  # Adwaita default accent is blue — that is the Chromium/GTK "Open" button.
  gsettings set org.gnome.desktop.interface accent-color "slate"
  if [[ -f $HOME/.local/share/fonts/spacex/D-DIN.ttf ]]; then
    gsettings set org.gnome.desktop.interface font-name "SpaceX Sans 12"
    gsettings set org.gnome.desktop.interface document-font-name "SpaceX Sans 12"
  fi
  gsettings set org.gnome.nautilus.icon-view default-zoom-level "small" || true
  gsettings set org.gnome.nautilus.list-view default-zoom-level "small" || true
  if [[ -f $HOME/.local/share/fonts/spacex/IBMPlexMono-Regular.ttf ]]; then
    gsettings set org.gnome.desktop.interface monospace-font-name "IBM Plex Mono 11"
  fi
}

write_gtk_settings() {
  local dir ini css
  for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
    mkdir -p "$dir"
    ini="$dir/settings.ini"
    cat >"$ini" <<'EOF'
# omarchy-spacex
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=SpaceX
gtk-cursor-theme-name=Adwaita
gtk-font-name=SpaceX Sans 12
gtk-application-prefer-dark-theme=1
EOF
  done

  # GTK3 file chooser (xdg-desktop-portal-gtk) used by Chromium uploads.
  css="$HOME/.config/gtk-3.0/gtk.css"
  cat >"$css" <<'EOF'
/* omarchy-spacex */
@define-color accent_bg_color #FFFFFF;
@define-color accent_fg_color #000000;
@define-color accent_color #FFFFFF;
@define-color theme_selected_bg_color #FFFFFF;
@define-color theme_selected_fg_color #000000;

button.suggested-action,
button.default,
.suggested-action {
  background-image: none;
  background-color: #C4C8CC;
  color: #000000;
  border-color: #A7A9AC;
}

button.suggested-action:hover,
button.default:hover,
.suggested-action:hover {
  background-image: none;
  background-color: #E8E8E8;
  color: #000000;
}
EOF

  # GTK4 / libadwaita (newer pickers and Settings).
  css="$HOME/.config/gtk-4.0/gtk.css"
  cat >"$css" <<'EOF'
/* omarchy-spacex */
@define-color accent_bg_color #FFFFFF;
@define-color accent_fg_color #000000;
@define-color accent_color #FFFFFF;
@define-color theme_selected_bg_color #FFFFFF;
@define-color theme_selected_fg_color #000000;

:root {
  --accent-bg-color: #FFFFFF;
  --accent-fg-color: #000000;
  --accent-color: #FFFFFF;
}

window.nautilus-window,
.nautilus-window,
.nautilus-window label,
.nautilus-window .sidebar,
.nautilus-window .sidebar label,
.nautilus-window .icon-ui-labels-box,
.nautilus-window .icon-ui-labels-box label,
.nautilus-window .column-name-labels-box,
.nautilus-window .column-name-labels-box label {
  font-size: 12px;
}

/* Nautilus 50 "small" zoom is still 48px. Cap the custom icon widget. */
.nautilus-grid-view gridview > child {
  padding: 2px 4px;
}

.nautilus-grid-view image,
.nautilus-grid-view NautilusImage {
  -gtk-icon-size: 32px;
  min-width: 32px;
  min-height: 32px;
  max-width: 32px;
  max-height: 32px;
}

.nautilus-list-view image,
.nautilus-list-view NautilusImage {
  -gtk-icon-size: 16px;
  min-width: 16px;
  min-height: 16px;
  max-width: 16px;
  max-height: 16px;
}

gridview > child:selected,
gridview > child:selected:hover,
.nautilus-grid-view > child:selected,
listview > row:selected,
.nautilus-list-view row:selected {
  background-color: #FFFFFF;
  color: #000000;
  outline-color: #000000;
}

gridview > child:selected label,
gridview > child:selected .dim-label,
listview > row:selected label {
  color: #000000;
}

gridview > child:selected image,
.nautilus-grid-view > child:selected image {
  color: #000000;
}
EOF
}

write_portal_env() {
  mkdir -p "$HOME/.config/environment.d"
  cat >"$HOME/.config/environment.d/80-spacex.conf" <<'EOF'
# omarchy-spacex
GTK_ICON_THEME=SpaceX
GTK_THEME=Adwaita:dark
GTK_USE_PORTAL=1
EOF

  mkdir -p "$HOME/.config/systemd/user/xdg-desktop-portal-gtk.service.d"
  cat >"$HOME/.config/systemd/user/xdg-desktop-portal-gtk.service.d/spacex.conf" <<'EOF'
# omarchy-spacex
[Service]
Environment=GTK_THEME=Adwaita:dark
Environment=GTK_ICON_THEME=SpaceX
Environment=XDG_DATA_HOME=%h/.local/share
EOF
  systemctl --user daemon-reload >/dev/null 2>&1 || true
}

restart_file_chooser() {
  systemctl --user daemon-reload >/dev/null 2>&1 || true
  systemctl --user restart xdg-desktop-portal-gtk.service >/dev/null 2>&1 || true
  systemctl --user restart xdg-desktop-portal.service >/dev/null 2>&1 || true
}

ensure_theme_hook() {
  local src="$THEME_DIR/hooks/theme-set.sh"
  local dest="$HOME/.config/omarchy/hooks/theme-set.d/theme-set.sh"
  [[ -f $src ]] || return 0
  mkdir -p "$(dirname "$dest")"
  cp -f "$src" "$dest"
  chmod 755 "$dest"
}

plugin_user_id() {
  local source_id="$1"
  printf '%s.%s\n' "${USER:-$(id -un)}" "${source_id#omarchy.}"
}

ensure_cloned_plugin() {
  local source_id="$1"
  local dest_id dest
  dest_id="$(plugin_user_id "$source_id")"
  dest="$HOME/.config/omarchy/plugins/$dest_id"
  [[ -d $dest ]] && return 0

  mkdir -p "$HOME/.config/omarchy/plugins"
  if command -v omarchy >/dev/null && omarchy plugin clone "$source_id" >/dev/null 2>&1; then
    [[ -d $dest ]] && return 0
  fi

  local source_dir=""
  if command -v omarchy-plugin-catalog >/dev/null; then
    source_dir="$(omarchy-plugin-catalog | jq -r --arg id "$source_id" '
      [.[] | select(.firstParty and .id == $id) | .sourceDir][0] // empty
    ')"
  fi
  [[ -n $source_dir && -d $source_dir ]] || return 1

  mkdir -p "$dest"
  cp -aL "$source_dir/." "$dest/"
  if [[ -f $dest/manifest.json ]] && command -v jq >/dev/null; then
    jq --arg id "$dest_id" --arg sourceId "$source_id" --arg name "My ${source_id#omarchy.}" '
      .id = $id
      | .name = $name
      | if (.barWidget | type) == "object" then .barWidget.displayName = $name else . end
      | .omarchy = ((.omarchy // {}) + {clonedFrom: $sourceId})
      | del(.omarchy.clonePaths)
    ' "$dest/manifest.json" >"$dest/manifest.json.tmp"
    mv "$dest/manifest.json.tmp" "$dest/manifest.json"
  fi
}

overlay_plugin() {
  local extra_dir="$1"
  local source_id="$2"
  local dest_id dest file
  dest_id="$(plugin_user_id "$source_id")"
  dest="$HOME/.config/omarchy/plugins/$dest_id"
  [[ -d $extra_dir ]] || return 0
  ensure_cloned_plugin "$source_id" || return 0

  shopt -s nullglob
  for file in "$extra_dir"/*; do
    case "$(basename "$file")" in
      manifest.json) continue ;;
    esac
    cp -f "$file" "$dest/"
  done
  shopt -u nullglob

  if [[ -f $extra_dir/manifest.json ]] && command -v jq >/dev/null; then
    jq --arg id "$dest_id" --arg sourceId "$source_id" '
      .id = $id
      | .omarchy = ((.omarchy // {}) + {clonedFrom: $sourceId})
    ' "$extra_dir/manifest.json" >"$dest/manifest.json"
  fi

  if command -v omarchy-shell >/dev/null; then
    omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  fi
  if command -v omarchy >/dev/null; then
    omarchy plugin enable "$dest_id" >/dev/null 2>&1 || true
  fi
}

apply_bar_spacex_widgets() {
  local clock_id network_id menu_id
  clock_id="$(plugin_user_id omarchy.clock)"
  network_id="$(plugin_user_id omarchy.network)"
  menu_id="$(plugin_user_id omarchy.menu)"
  python3 - "$clock_id" "$network_id" "$menu_id" <<'PY'
import json
import pathlib
import sys

clock_id, network_id, menu_id = sys.argv[1], sys.argv[2], sys.argv[3]
path = pathlib.Path.home() / ".config/omarchy/shell.json"
if not path.exists():
    raise SystemExit(0)
data = json.loads(path.read_text(encoding="utf-8"))
bar = data.setdefault("bar", {})
layout = bar.setdefault("layout", {})


def item_id(item):
    if isinstance(item, dict):
        return item.get("id")
    return item


def replace_or_insert(section, old, new, extra=None, after_id=None, before_id=None):
    items = layout.setdefault(section, [])
    found = False
    for item in items:
        iid = item_id(item)
        if iid in (old, new) and isinstance(item, dict):
            item["id"] = new
            if extra:
                for key, value in extra.items():
                    item.setdefault(key, value)
            found = True
        elif iid in (old, new):
            found = True
    if found:
        return
    obj = {"id": new}
    if extra:
        obj.update(extra)
    ids = [item_id(item) for item in items]
    if after_id in ids:
        items.insert(ids.index(after_id) + 1, obj)
        return
    if before_id in ids:
        items.insert(ids.index(before_id), obj)
        return
    items.append(obj)


replace_or_insert(
    "center",
    "omarchy.clock",
    clock_id,
    extra={
        "format": "ddd d MMM HH:mm",
        "formatAlt": "HH:mm:ss",
        "verticalFormat": "HH\n—\nmm",
    },
    before_id="omarchy.weather",
)
replace_or_insert(
    "right",
    "omarchy.network",
    network_id,
    after_id="omarchy.bluetooth",
    before_id="omarchy.audio",
)
replace_or_insert("left", "omarchy.menu", menu_id)

anchor = bar.get("centerAnchor")
if anchor in (None, "", "omarchy.clock"):
    bar["centerAnchor"] = clock_id

path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
}

install_plugin_overlays() {
  overlay_plugin "$THEME_DIR/extras/plugins/clock" omarchy.clock
  overlay_plugin "$THEME_DIR/extras/plugins/network" omarchy.network
  overlay_plugin "$THEME_DIR/extras/plugins/menu" omarchy.menu
  apply_bar_spacex_widgets
}

install_lock_explorer() {
  local id="io.github.sirjul1337.lock-explorer"
  local dest="$HOME/.config/omarchy/plugins/$id"
  [[ -d $dest ]] && return 0
  command -v omarchy >/dev/null || return 0
  omarchy plugin add https://github.com/SirJul1337/omarchy-lock-explorer.git --enable --yes >/dev/null 2>&1 || true
}

restore_other_theme() {
  local dir
  for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
    if [[ -f $dir/settings.ini ]] && grep -q '^# omarchy-spacex' "$dir/settings.ini"; then
      rm -f "$dir/settings.ini"
    fi
    if [[ -f $dir/gtk.css ]] && grep -q 'omarchy-spacex' "$dir/gtk.css"; then
      rm -f "$dir/gtk.css"
    fi
  done
  if [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
    gsettings set org.gnome.desktop.interface accent-color "blue" || true
  fi
  rm -f "$HOME/.config/environment.d/80-spacex.conf"
  rm -f "$HOME/.config/systemd/user/xdg-desktop-portal-gtk.service.d/spacex.conf"
  rm -f "$HOME/.config/fontconfig/conf.d/50-spacex.conf"
  restart_file_chooser
}

apply_lock_and_brand() {
  mkdir -p "$HOME/.config/omarchy/branding" "$HOME/.config/omarchy/lock-designs"
  if [[ -f $THEME_DIR/branding/screensaver.txt ]]; then
    cp "$THEME_DIR/branding/screensaver.txt" "$HOME/.config/omarchy/branding/screensaver.txt"
  fi
  if [[ -x $THEME_DIR/scripts/fetch-spacex-launches.sh ]]; then
    "$THEME_DIR/scripts/fetch-spacex-launches.sh" >/dev/null 2>&1 || true
  fi
  if [[ -d $THEME_DIR/lock-designs ]]; then
    cp -f "$THEME_DIR"/lock-designs/*.qml "$HOME/.config/omarchy/lock-designs/" 2>/dev/null || true
    if command -v omarchy-shell >/dev/null && [[ -d $HOME/.config/omarchy/plugins/io.github.sirjul1337.lock-explorer ]]; then
      omarchy-shell lock rescanDesigns >/dev/null 2>&1 || true
      omarchy-shell lock setDesign my-pad >/dev/null 2>&1 || true
    fi
  fi
}

THEME_NAME="${1:-spacex}"
if [[ $THEME_NAME != spacex ]]; then
  restore_other_theme
  exit 0
fi

ensure_theme_hook
install_fonts
install_icons
write_fontconfig
retint_terminals
apply_gsettings
write_gtk_settings
write_portal_env
install_plugin_overlays
install_lock_explorer
apply_lock_and_brand
restart_file_chooser

printf 'SpaceX\n' >"$THEME_DIR/icons.theme"
