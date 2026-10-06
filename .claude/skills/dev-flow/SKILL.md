---
name: dev-flow
description: End-to-end delivery flow for app-devper/devper-workspace — from an idea or bug through shaping, design, test-first build, verify, review, PR into develop, release PR into main, tag, deploy check and back-merge. Says which skill to use at each stage. Use when starting any change, when unsure what comes next, or when asked to ship, release or hotfix.
---

# dev-flow — idea → release for devper-workspace

One flow, nine stages. Each stage names the skill that does the work and the
exit check that must hold before moving on. Skip a stage only where it says
so. Branching and PR mechanics are owned by `git-flow` and `pr`; this skill
only sequences them.

## 0. Pick the track

| Track | Starts at | Branch from → PR into |
|---|---|---|
| Feature / change | 1 | `develop` → `develop` (`feature/<slug>`) |
| Bug fix (not urgent) | 1 (short) | `develop` → `develop` (`feature/fix-<slug>`) |
| Refactor | 1 via `improve-codebase-architecture` | `develop` → `develop` |
| Release | 8 | `develop` → `main` (`release/X.Y.Z`) |
| Hotfix (production broken) | 9 | `main` → `main` (`hotfix/<slug>`) |

## 1. Shape — agree on what and why

- New behaviour or unclear requirement → `/grill-with-docs` (runs `grilling`
  + `domain-modeling`). Terms go into `CONTEXT.md`, hard-to-reverse decisions
  into `docs/adr/`.
- Small, well-understood fix → `grilling` only, a few questions, no docs.
- Refactor → `/improve-codebase-architecture` picks the candidate and grills it.

**Exit:** one or two sentences stating the change and how we will know it works.

## 2. Design — decide the shape of the code

- `codebase-design` for module/interface boundaries (deep modules, seams).
- Stack references: `dart-flutter-patterns` (this repo's layers, view models, data layer, errors and tests); follow the existing `get_it` + `http` setup — do not introduce BLoC/Riverpod/Dio.

**Exit:** files/modules to touch are known; any new term is in `CONTEXT.md`.

## 3. Branch

`git-flow` → `feature/<slug>` from an up-to-date `develop`. One concern per
branch.

## 4. Build

Test first: `tdd-workflow`; tests live in each package's `test/` and run with `flutter test`.

Commit in small conventional commits: `feat(scope): …`, `fix(scope): …`,
`refactor(scope): …`, `test(scope): …`, `chore(scope): …`.

## 5. Verify locally — same gates as CI (`Analyze + Test (Flutter/melos)`)

```bash
melos bootstrap
melos run analyze
melos exec -c 1 --dir-exists=test -- flutter test
```

Run the affected app (`packages/applications/<app>`) and walk the changed flow.

**Exit:** everything above is green and the change was seen working — not
just compiled.

## 6. Review

`flutter-dart-code-review` (only where it fits `dart-flutter-patterns`), `coding-standards`, then `/code-review`. Fix findings before opening the PR.

## 7. PR into develop

```bash
git push -u origin feature/<slug>
gh pr create --base develop --title "feat(scope): …" --body "…"
```

Body: what changed, why, how it was verified (stage 5). Land it with the
`pr` skill (squash, delete branch, sync `develop`). Never push to `develop`
directly.

## 8. Release — develop → main

1. **Pick the version** from what landed since the last tag
   (`git log $(git describe --tags --abbrev=0 --match 'v*' origin/main)..origin/develop --oneline`):
   breaking → major, any `feat` → minor, only `fix` → patch.
2. **Cut the branch:** `git-flow` release recipe → `release/X.Y.Z` from `develop`.
3. **Version:** Bump `version:` in the `pubspec.yaml` of each app that ships (`packages/applications/pos`, `packages/applications/sm`). There is no central version file.
4. **PR:** `gh pr create --base main --title "release: vX.Y.Z" --body "<changelog: PR list since last tag>"`.
   CI `Analyze + Test (Flutter/melos)` must be green.
5. **Land:** `pr` skill (squash into `main`).
6. **Deploy:** **No pipeline** — merging `main` deploys nothing. Deploy by hand from a clean `main` checkout after the release lands.
7. **Tag:** Tag by hand — nothing tags automatically.
   ```bash
   git checkout main && git pull --ff-only
   git tag -a vX.Y.Z -m "vX.Y.Z" HEAD   # HEAD = the "release: vX.Y.Z (#n)" squash commit
   git push origin vX.Y.Z
   ```
8. **Back-merge** `main` → `develop` (`git-flow`; the `pr` skill does it
   after a PR into `main`).
9. **Check the deploy:**
   ```bash
   git checkout main && git pull --ff-only
   # pos shipped
   melos run build:web:pos && melos run deploy:web:pos
   melos run deploy:web:devper   # devper hosting also serves the pos build
   # sm shipped
   melos run build:web:sm && melos run deploy:web:sm   # https://devper-sm.web.app
   ```

**Exit:** tag `vX.Y.Z` on `main`, app deployed by hand from `main`, `develop` contains `main`.

## 9. Hotfix — production is broken

`git-flow` hotfix recipe: `hotfix/<slug>` from `main` → stages 4–6 (test
reproducing the bug first) → PR into `main` titled `fix(scope): …` → release
steps 3 and 5–9 with a **patch** bump.

## Guard rails

- No direct pushes to `main` or `develop`; every change goes through a PR
  with `Analyze + Test (Flutter/melos)` green.
- A merge into `main` is a release —
  only `release/*` and `hotfix/*` PRs target `main`.
- Never tag a commit that is not on `main`; never move or delete a pushed tag.
