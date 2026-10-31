# Plan

Work queued for this repo. Each item says what done looks like. Remove an item once it lands; its commit body keeps the reasoning.

## 1. `detect` only sees the last commit of a push

`build.yml`'s `detect` diffs `HEAD^..HEAD`, so a push of two commits builds only the images the last one touched. Diff from `github.event.before` instead, building everything when it is all zeros (a new branch or the first push).

Done: a two-commit push touching two image folders builds both.
