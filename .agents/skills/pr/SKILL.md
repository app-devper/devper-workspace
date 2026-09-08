---
name: pr
description: Land the current branch's open pull request in app-devper/devper-workspace — squash-merge (auto-merge if the check is still running), delete the branch, sync the base branch, and back-merge main into develop when the PR targeted main. Use when the user says "pr land", "merge it", "/pr", or otherwise asks to land the current PR.
---

# pr — land the current branch's PR

This repo follows **git flow** (see the `git-flow` skill): feature PRs target
`develop`; release/hotfix PRs target `main`. The `check` workflow
("Analyze + Test (Flutter/melos)") runs on both. PRs land via **squash**.

## Steps

1. **Find the PR for the current branch**
   ```bash
   gh pr view --json number,state,mergeable,mergeStateStatus,baseRefName,headRefName,title
   ```
   - No PR for this branch → stop and tell the user (offer `gh pr create`
     with the base the `git-flow` skill prescribes).
   - `state` is `MERGED`/`CLOSED` → report it; nothing to do.

2. **Push any unpushed commits first**
   ```bash
   git push
   ```

3. **Check mergeability.** `CONFLICTING` → stop and report — do **not**
   force. `UNKNOWN` → re-run step 1 once before proceeding.

4. **Squash-merge**
   ```bash
   gh pr checks <number>
   ```
   - Check passed → `gh pr merge <number> --squash --delete-branch`
   - Still running → `gh pr merge <number> --squash --auto --delete-branch`
     then watch until it lands:
     ```bash
     gh pr view <number> --json state -q .state   # poll / Monitor until MERGED
     ```
   - Check failed → stop, show the failure, do not merge.

5. **Sync the base branch and clean up**
   ```bash
   git checkout <baseRefName>
   git pull --ff-only origin <baseRefName>
   git branch -D <headRefName>
   git remote prune origin
   ```

6. **If the PR targeted `main`: back-merge into `develop`** (mandatory —
   see `git-flow` skill)
   ```bash
   git checkout develop && git pull --ff-only origin develop
   git merge main && git push origin develop
   ```
   No deploy fires automatically — if this release ships web, remind the user
   to run the manual deploy from a clean checkout
   (`melos run build:web:pos` → `melos run deploy:web:pos`).

7. **Report**: merged PR number + URL, the squash commit SHA on the base
   branch (`git log --oneline -1`), branch deleted local + remote, and for
   `main` landings whether a manual deploy is still owed.

## Notes

- Default strategy is `--squash`. Only `--merge` / `--rebase` if the user
  explicitly asks.
- A merge into `main` does **not** deploy (no pipeline) — deploys are manual
  per app. Confirm a release PR bumped the app's `version:` before landing.
- Branch protection is not enforced (free-plan private repo); still treat a
  red `check` as blocking and never merge over a failed check.
- Run from inside `/Users/admin/ProjectPos/devper-workspace`.
