---
'tk-dotfiles': minor
---

Add iterm2 topic installer that auto-installs the it2 CLI via uv tool when iTerm2 is present, and upgrades it on dot update. Introduces a DOT_MODE env signal so topic installers can branch on install vs update lifecycle.
