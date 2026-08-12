---
'tk-dotfiles': patch
---

Fix CI: read the Node version from `.node-version` instead of hardcoding Node 20, which is below the floor required by `@changesets/cli` v3 and `@commitlint` v21
