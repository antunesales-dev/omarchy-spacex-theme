# SpaceX — Omarchy theme

Unofficial black-and-white [Omarchy](https://omarchy.org/) theme. Canvas is black, type is white, the only metal is stainless. No accent hue.

Not affiliated with SpaceX or NASA.

## Install

```bash
omarchy theme install https://github.com/antunesales-dev/omarchy-spacex-theme.git
~/.config/omarchy/themes/spacex/apply-identity.sh
```

Or from the Omarchy menu: **Install → Theme**, paste the URL, then run `apply-identity.sh` once.

That first run installs fonts, grayscale folders, GTK / portal chrome, the clock and network overlays, the Pad lock design, and a `theme-set` hook. After that, switching back to SpaceX re-applies everything.

Update later with `omarchy theme update`.

## Palette

| Role | Hex |
| --- | --- |
| Background | `#000000` |
| Foreground | `#F5F5F5` |
| Accent / stainless | `#C4C8CC` |
| Muted | `#5A5A5A` |
| Selection | `#2A2A2A` |

Syntax colors are grayscale steps. Folders use a grayscale **SpaceX** icon theme (Yaru-dark plus Adwaita folder SVGs, with Ubuntu orange and GNOME blue stripped). App icons stay inherited so brands stay recognizable.

## Type

SpaceX’s public face is **D-DIN** (DIN 1451, SIL OFL). This theme ships the full family and maps UI chrome to that cut.

| Surface | Face | Why |
| --- | --- | --- |
| GTK / Files / documents | D-DIN (aliased as SpaceX Sans) | Closest legal match to the SpaceX wordmark |
| Terminals + Omarchy bar | IBM Plex Mono | Industrial mono; D-DIN is not monospaced |
| Cursor | Adwaita | Already black and white |
| Chromium / GTK file picker | SpaceX icons + slate/stainless buttons | Portal was still Adwaita blue |

## Backgrounds

Real photographs, converted to black and white:

1. **2015** — Falcon 9 first landing on LZ-1
2. **2018** — Falcon Heavy twin side-booster landing
3. **2020** — Crew Dragon Demo-2 launch from LC-39A
4. **2021** — Starship SN20 hexagonal heat tiles on 301 stainless
5. **2024** — Super Heavy Booster 12 on approach to the chopsticks (Flight 5)

Cycle with `omarchy theme bg next`. Photo licenses and authors are in [NOTICE](NOTICE) and [CREDITS.md](CREDITS.md).

## What apply-identity sets

HUD chrome (`shell.toml`): slimmer black bar, 1px stainless hairlines, white-on-black selected rows in menus and the launcher, opaque notification cards, heavier scrim. Windows get 1px steel borders and tighter gaps (`hyprland.lua`).

Files (Nautilus) uses 10px type, 32px icons, and white selection with black labels. The Chromium / portal file chooser gets the same SpaceX icon theme and stainless suggested buttons.

### Clock calendar

`apply-identity.sh` clones `omarchy.clock` into `~/.config/omarchy/plugins/<user>.clock` and overlays [extras/plugins/clock](extras/plugins/clock). Click a day to see flights. The cache is both upcoming and previous SpaceX missions from [Launch Library 2](https://ll.thespacedevs.com/) (`lsp__id=121`), written to `~/.cache/omarchy-spacex/launches.json`.

Clock and weather stay in the bar center. Refresh the cache with:

```bash
~/.config/omarchy/themes/spacex/scripts/fetch-spacex-launches.sh
```

### Starlink easter egg

The network overlay clones `omarchy.network`. If the live SSID contains `starlink` (or the typo `starklink`), the Wi-Fi panel swaps its connection phrases for constellation copy — “Talking to the constellation”, “Phased array locked”, and so on. Other networks stay stock.

### Lock and screensaver

[Lock Screen Explorer](https://github.com/SirJul1337/omarchy-lock-explorer) is installed on first apply if it is missing. This theme ships `lock-designs/Pad.qml` (letterbox + MET clock + GO/NO-GO) and `lock-designs/Cinema.qml`. Switch with `omarchy-shell lock setDesign my-pad` or `my-cinema`. Browse the rest with:

```bash
omarchy-shell lock explore
```

Screensaver branding is a Starship ASCII that TTE animates. Preview with Super+Escape or `omarchy screensaver`.

## Layout

```
colors.toml              Omarchy semantic palette (source of truth)
icons.theme              SpaceX (grayscale folders, inherits Yaru-dark)
keyboard.rgb             stainless #c4c8cc
preview.png              theme-switcher / gallery card
apply-identity.sh        fonts, icons, GTK, plugins, lock, hook
fonts/                   D-DIN + IBM Plex Mono (OFL)
backgrounds/             five dated photographs
extras/plugins/clock     Launch Library calendar overlay
extras/plugins/network   Starlink Wi-Fi easter egg
lock-designs/            Pad + Cinema lock screens
scripts/                 launch cache fetcher
```

Omarchy generates terminal, Hyprland, Neovim, and shell colors from `colors.toml`.

Still optional if you want to go further:

| Surface | How |
| --- | --- |
| Lock / Plymouth glyph | `unlock.png` + `preview-unlock.png` |
| Lock field colors | `shell.lock.toml` |
| Bar / notifications | `shell.toml` |
| Hyprland gaps / border width | `hyprland.lua` |
| Neovim | generated `aether.nvim` from the palette |
| VS Code | generated theme JSON, or a `vscode.json` marketplace id |
| RGB keyboard | `keyboard.rgb` is already stainless |

App icons (Firefox, etc.) stay colored on purpose. The SpaceX site is black/white chrome with photography doing the color — same idea.

## License

Theme configuration is [MIT](LICENSE). Photographs keep their original licenses (CC0, NASA public domain, CC BY 2.0, CC BY-SA 2.0). D-DIN and IBM Plex Mono are SIL OFL 1.1. Clock and network extras are modified Omarchy plugins (MIT). See [NOTICE](NOTICE).
