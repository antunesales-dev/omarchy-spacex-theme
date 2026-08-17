# Security

This repository is a desktop theme: TOML, QML overlays, photographs, OFL fonts, and a small apply script. `omarchy theme install` only `git clone`s into `~/.config/omarchy/themes/`. Extra identity work runs when you execute `apply-identity.sh` or when the installed `theme-set` hook fires.

## What is in scope

- Accidental secrets or credentials committed to the repo
- Malicious or unexpected files added to a release or to `main`
- License or attribution errors that would make redistribution unsafe

## What is not in scope

- Omarchy, Hyprland, or terminal vulnerabilities
- Screenshot or wallpaper content

## Reporting

Please do **not** open a public issue for a suspected secret or malicious commit.

- Use [GitHub private vulnerability reporting](https://github.com/antunesales-dev/omarchy-spacex-theme/security/advisories/new)
- Or email **antunesales.developer@gmail.com**

Include the file path, commit SHA, and what you found. We will rotate anything leaked and rewrite history only if a live secret was published.

## Install safely

```bash
omarchy theme install https://github.com/antunesales-dev/omarchy-spacex-theme.git
```

Prefer HTTPS from this GitHub URL. After clone, the tree should contain only the files listed in the README. GitHub Actions here only validate the tree; they do not write to your machine.

`apply-identity.sh` is the only extra installer. It:

- Copies fonts and grayscale folder icons into `~/.local/share/`
- Writes GTK 3/4 settings, fontconfig, and an xdg-desktop-portal-gtk drop-in
- Clones first-party `omarchy.clock` / `omarchy.network` if missing, then overlays `extras/plugins/`
- Optionally `git clone`s [Lock Screen Explorer](https://github.com/SirJul1337/omarchy-lock-explorer) when that plugin is absent
- Fetches public Launch Library 2 JSON (no API key) into `~/.cache/omarchy-spacex/`

Review that script before the first run if you want to audit the extra steps.
