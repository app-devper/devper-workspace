---
name: git-flow
description: Git flow branching for app-devper/devper-workspace — main (production line), develop (default, integration), feature/*, release/*, hotfix/*. Flutter monorepo (melos 8 + fvm); no auto-deploy on merge (deploy is manual per app). Use when starting new work, opening a PR, cutting a release, hotfixing, or deciding which base branch a change targets.
---

# git-flow — branching + release model for this repo

Project override of the user-level `git-flow` skill (`~/.Codex/skills/git-flow/`)
— generic recipes live there; everything below is what's specific to
`app-devper/devper-workspace` (Flutter monorepo, `melos` 8 + `fvm`, Flutter 3.38.7).

## Branch map

| Branch | Role | PR target | After merge |
|---|---|---|---|
| `main` | production line — release/hotfix land here | — | back-merge into `develop` |
| `develop` | default branch, integration | — | — |
| `feature/<x>` | new work, fixes for next release | `develop` | delete branch |
| `release/<x.y.z>` | release cut from `develop` | `main` | back-merge `main` → `develop`, delete branch |
| `hotfix/<x>` | urgent production fix from `main` | `main` | back-merge `main` → `develop`, delete branch |

PRs land via **squash**. The `check` workflow
("Analyze + Test (Flutter/melos)") runs on every PR and on pushes to
`main`/`develop`.

## What merging `main` does — nothing automatic

Unlike the other migrated repos, **`devper-workspace` has no deploy pipeline**.
Merging `main` does NOT deploy or tag. Web deploys are **manual**, run from a
clean `main` (or `develop`) checkout after the release lands:

```bash
melos run build:web:pos        # flutter build web --release
melos run deploy:web:pos       # firebase deploy --only hosting:pos
melos run deploy:web:devper    # firebase deploy --only hosting:devper
```

Version lives in each app's own `pubspec.yaml` `version:` key
(`packages/applications/pos` → 1.0.9, `packages/applications/sm` → 1.0.0+1) —
there is no central version file. A `release/*` PR should bump the `version:`
of whichever app(s) it ships; tagging (if any) is manual on the squash commit.

## Recipes

### Feature

```bash
git checkout develop && git pull --ff-only
git checkout -b feature/<slug>
# work, commit
git push -u origin feature/<slug>
gh pr create --base develop --title "..." --body "..."
```

### Release

```bash
git checkout develop && git pull --ff-only
git checkout -b release/<x.y.z>
# bump version: in the shipping app's packages/applications/<app>/pubspec.yaml
gh pr create --base main --title "release: v<x.y.z>" --body "..."
```

### Hotfix

```bash
git checkout main && git pull --ff-only
git checkout -b hotfix/<slug>
# fix + bump the app's patch version
gh pr create --base main --title "fix(...): ..." --body "..."
```

### Back-merge (required after every merge into main)

```bash
git checkout main && git pull --ff-only
git checkout develop && git pull --ff-only
git merge main            # usually fast-forward; resolve if develop moved
git push origin develop
```

## Local checks before opening a PR

```bash
fvm dart pub global run melos bootstrap
fvm dart pub global run melos run analyze
melos exec -c 1 --dir-exists=test -- fvm flutter test
```

## Guard rails

- Never push directly to `main` or `develop` — always via PR.
- Never open a feature PR against `main`; only `release/*` and `hotfix/*`
  target `main`.
- Back-merge `main` → `develop` immediately after every main landing;
  a forgotten back-merge conflicts the next release PR.
- Landing PRs (merge + branch cleanup + sync + back-merge) is the **pr**
  skill's job — invoke `/pr` rather than hand-rolling the merge.
- **Branch protection is not enforced server-side** (private repo, free plan —
  the protection API returns 403). The `check` workflow still runs and reports;
  treat a red `check` as blocking by convention, not by GitHub enforcement.
