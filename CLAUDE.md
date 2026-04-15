See README.md for general project information.

## Coding Guidelines

### Haskell Coding Style

- Use `LambdaCase` and `where` for local functions
- Use `relude` over Prelude
- Use OverloadedRecordDot syntax for field access (e.g., `record.field`) - requires `{-# LANGUAGE OverloadedRecordDot #-}` extension

## Testing

- Test changes using `nix run`
