See README.md for general project information.

## Coding Guidelines

### Haskell Coding Style

- Use `LambdaCase` and `where` for local functions
- Use `relude` over Prelude
- Use OverloadedRecordDot syntax for field access (e.g., `record.field`) - requires `{-# LANGUAGE OverloadedRecordDot #-}` extension

## Git

- DO NOT AUTOCOMMIT
- You must `git add` newly added files, otherwise `nix` won't recognize them.

## Reporting

Be concise in explanations. Stop saying "absolutely right", this is insulting. Treat me like an adult. Be direct and candid; avoid fluff.
