---
"tk-dotfiles": patch
---

Make `gsync` cleanup squash-aware: check fetched origin history, identical file trees, and merged GitHub PRs matching the exact local tip. Keep confirmation when merge status is uncertain, and retain branches on end-of-input.
