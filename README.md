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

Syntax colors are grayscale steps. Icons use `Yaru-dark`.

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
colors.toml      Omarchy semantic palette (source of truth)
icons.theme      Yaru-dark
keyboard.rgb     stainless #c4c8cc
preview.png      theme-switcher / gallery card
backgrounds/     five dated photographs
```

Omarchy generates terminal, Hyprland, Neovim, and shell colors from `colors.toml`.

## License

Theme configuration is [MIT](LICENSE). Photographs keep their original licenses (CC0, NASA public domain, CC BY 2.0, CC BY-SA 2.0). See [NOTICE](NOTICE).
