# hint-demo

Nix-based demo of Haskell's `hint` library

> [!WARNING]
> This repo is a work-in-progress.

## Using hint with external libraries

Our `config.hs` has access to:

- Internal library, `packages/hint-demo-types`
- External libraries, `optics-core`, `optics-th`.

We must explicitly define these libraries in `hint.nix`.

Based on https://github.com/haskell-hint/hint/issues/79

## Running

To run:

```sh
# Nix
nix run

# Cabal
nix develop -c cabal run hint-demo

# ghcid
nix develop -c just run
```
