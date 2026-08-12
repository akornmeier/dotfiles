---
'tk-dotfiles': patch
---

Fix release CI so versions are actually tagged and published as GitHub Releases: the Release workflow now runs `changeset tag` as its publish step (with full git history so existing tags are detected), and changesets is configured to tag this private package.
