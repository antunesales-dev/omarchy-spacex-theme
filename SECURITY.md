# Security

This repository is a desktop theme: TOML, a few text files, and photographs. It does not run code at install time beyond what Omarchy already does (`git clone` into `~/.config/omarchy/themes/`).

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

Prefer HTTPS from this GitHub URL. After clone, the tree should contain only the files listed in the README. There is no install script and no GitHub Actions that write to your machine.
