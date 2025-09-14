# hint-demo

Nix-based demo of Haskell's `hint` library

> [!WARNING]
> This repo is a work-in-progress.

## Using hint with external libraries

Based on https://github.com/haskell-hint/hint/issues/79

See `hint.nix` for Nix implementation.

To run:

```sh
# Nix
nix run

# Cabal
nix develop -c cabal run hint-demo

# ghcid
nix develop -c just run
```
