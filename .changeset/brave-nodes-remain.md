---
'tk-dotfiles': patch
---

Stop `dot` from uninstalling Homebrew's `node`, which broke every formula that depends on it. `brew uninstall --ignore-dependencies node` ran in `cmd_install`, `cmd_update`, and `fnm/install.sh`, so each `dot` run left `pi-coding-agent` and `mongosh` with a dangling `/opt/homebrew/opt/node/bin/node` shebang (`bad interpreter`). The removal was already obsolete: FNM's per-shell shim outranks `/opt/homebrew/bin` on `$PATH`, so Homebrew's node cannot shadow it. Also drops the `/usr/local/bin/{node,npm,npx,corepack}` symlink block from `cmd_install`, which recreated the exact symlinks `fnm/install.sh` deletes as legacy moments later in the same run.
