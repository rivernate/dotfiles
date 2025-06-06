# Dotfiles

The dotfiles are managed by [chezmoi](https://www.chezmoi.io/user-guide/setup/#use-a-hosted-repo-to-manage-your-dotfiles-across-multiple-machines)

## Setup
To setup a new machine using these dotfiles run:

```bash
sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply rivernate
```

## PHP Deps

```bash
yay -S re2c gd oniguruma unzip zip postgresql maria-db-clients libzi
```

