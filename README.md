# SpaceX — Omarchy theme

Unofficial black-and-white [Omarchy](https://omarchy.org/) theme. Canvas is black, type is white, the only metal is stainless. No accent hue.

Not affiliated with SpaceX or NASA.

## Install

```bash
omarchy theme install https://github.com/antunesales-dev/omarchy-spacex-theme.git
```

Or from the Omarchy menu: **Install → Theme**, paste the URL above.

Update later with `omarchy theme update`.

## Palette

| Role | Hex |
| --- | --- |
| Background | `#000000` |
| Foreground | `#F5F5F5` |
| Accent / stainless | `#C4C8CC` |
| Muted | `#5A5A5A` |
| Selection | `#2A2A2A` |

Syntax colors are grayscale steps. Folders use a grayscale **SpaceX** icon theme (Yaru-dark with the Ubuntu orange stripped). App icons stay inherited so brands stay recognizable.

## Type

SpaceX’s public face is **D-DIN** (DIN 1451, SIL OFL). This theme ships it and maps UI chrome to that cut.

| Surface | Face | Why |
| --- | --- | --- |
| GTK / Files / documents | D-DIN (aliased as SpaceX Sans) | Closest legal match to the SpaceX wordmark |
| Terminals + Omarchy bar | IBM Plex Mono | Industrial mono; D-DIN is not monospaced |
| Cursor | Adwaita | Already black and white |
| Chromium / GTK file picker | SpaceX icons + slate/stainless buttons | Portal was still Adwaita blue |

After install, run `~/.config/omarchy/themes/spacex/apply-identity.sh` (or switch to the theme again). A `theme-set` hook re-applies this on every SpaceX theme switch.

## Backgrounds

Real photographs, converted to black and white:

1. **2015** — Falcon 9 first landing on LZ-1
2. **2018** — Falcon Heavy twin side-booster landing
3. **2020** — Crew Dragon Demo-2 launch from LC-39A
4. **2021** — Starship SN20 hexagonal heat tiles on 301 stainless
5. **2024** — Super Heavy Booster 12 on approach to the chopsticks (Flight 5)

Cycle with `omarchy theme bg next`. Photo licenses and authors are in [NOTICE](NOTICE) and [CREDITS.md](CREDITS.md).

## Layout

```
colors.toml          Omarchy semantic palette (source of truth)
icons.theme          SpaceX (grayscale folders, inherits Yaru-dark)
keyboard.rgb         stainless #c4c8cc
preview.png          theme-switcher / gallery card
apply-identity.sh    icons, D-DIN, Plex Mono, cursor
fonts/               D-DIN + IBM Plex Mono (OFL)
backgrounds/         five dated photographs
```

Omarchy generates terminal, Hyprland, Neovim, and shell colors from `colors.toml`.

## What else can be matched

HUD chrome (`shell.toml`): slimmer black bar, 1px stainless hairlines, inverted steel selected rows in menus/launcher, opaque notification cards, heavier scrim. Windows get 1px steel borders and tighter gaps (`hyprland.lua`).

The [Lock Screen Explorer](https://github.com/SirJul1337/omarchy-lock-explorer) plugin is recommended. This theme ships `lock-designs/Pad.qml` (letterbox + T+ clock over the catch wallpaper). Browse the other designs with:

```bash
omarchy-shell lock explore
```

Screensaver branding is a Starship ASCII that TTE animates. Preview with Super+Escape or `omarchy screensaver`.

Still optional if you want to go further:

| Surface | How |
| --- | --- |
| Lock / Plymouth glyph | `unlock.png` + `preview-unlock.png` |
| Lock field colors | `shell.lock.toml` |
| Bar / notifications | `shell.toml` (colors already generated) |
| Hyprland gaps / border width | `hyprland.lua` |
| Neovim | generated `aether.nvim` from the palette |
| VS Code | generated theme JSON, or a `vscode.json` marketplace id |
| Chromium / GTK file picker | `gtk-3.0` / `gtk-4.0` settings + stainless `gtk.css` (applied by the hook) |
| RGB keyboard | `keyboard.rgb` is already stainless |

App icons (Firefox, etc.) stay colored on purpose. The SpaceX site is black/white chrome with photography doing the color — same idea.

## License

Theme configuration is [MIT](LICENSE). Photographs keep their original licenses (CC0, NASA public domain, CC BY 2.0, CC BY-SA 2.0). D-DIN and IBM Plex Mono are SIL OFL 1.1. See [NOTICE](NOTICE).
