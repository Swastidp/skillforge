---
name: review-changes
description: Review the current staged and unstaged changes — explain what each file is for, group them by concern/theme, flag likely bugs or accidental commits, and suggest logical commit groupings. Use when the user wants to understand their working-tree diff before committing (e.g. "review my changes", "what did I change", "help me commit this cleanly").
---

# Review Changes (staged & unstaged)

Use this skill when the user wants to make sense of their working-tree diff
before committing — what changed, why, and how to split it into clean commits.
The goal: a per-file explanation, a grouping into coherent themes, a short list
of things to double-check, and a suggested commit plan.

This is a Windows / PowerShell repo. Prefer the Bash tool for the git plumbing
below (works cross-shell); use the dedicated Read/Edit tools for files, not
`cat`/`sed`.

## Procedure

### 1. Snapshot the state

```bash
git status                 # staged / unstaged / untracked at a glance
git diff --stat            # unstaged line counts per file
git diff --cached --stat   # staged line counts per file
```

Keep staged vs unstaged distinct in your head — the user often cares which
bucket a file is in (they may have already staged a subset deliberately).

### 2. Read the actual diffs

Don't summarize from filenames alone — read the hunks.

```bash
git diff                   # all unstaged
git diff --cached          # all staged
git diff -- <path>         # narrow to one file/dir when a diff is large
```

For **untracked** files, the diff tools show nothing — open them with Read to
see what they contain. Also check whether they're meant to be tracked at all:

```bash
git check-ignore <path>    # is this file actually ignored?
```

### 3. Explain each file

For every changed file, state in one line **what it's for** — the intent, not a
restatement of the diff. Use clickable links: `[name.py](rel/path/name.py)` and
`file.js:42` for specific lines. Group the explanation by **theme/concern**, not
alphabetically — files that implement one feature belong together even across
frontend/backend.

### 4. Flag things to double-check

Call these out explicitly before suggesting commits:

- **Accidental / runtime artifacts** staged or untracked (logs, `.qs_storage/`,
  build output, local config). Suggest gitignoring rather than committing.
- **Likely bugs in the diff** — wrong port, leftover debug prints, commented-out
  code, a hardcoded path, a flag left in the wrong state.
- **Tracking surprises** — a file the user expects to commit that's actually
  ignored, or an ignore-exception line that's needed for new files to show up.
- **Mixed concerns** in a single file that can't be cleanly split by `git add`.

### 5. Suggest a commit plan

Propose grouped commits (one theme each), in a sensible order (e.g. backend
behaviour before the UI that depends on it). Offer to stage and commit them.
When staging a subset:

```bash
git add <files for theme>
git restore --staged <file>   # back out something staged by mistake
git status --short            # confirm exactly what's in the index
```

Before each commit, re-run `git status --short` so the user can see precisely
what the commit will contain. Use a clear, present-tense commit subject that
names the theme; put the "why" in the body.

## Decision checklist

- Is anything staged already? Respect it — the user may have curated the index.
- Are untracked files runtime junk or real source? `check-ignore` + Read to
  decide; default to **not** committing logs/storage.
- Can each proposed commit be formed with whole-file `git add`? If a file mixes
  two themes, say so rather than pretending a clean split exists.
- Did a needed `.gitignore` change get dropped? If new files are silently
  ignored, the exception line must be (re)added before they'll commit.

## What NOT to do

- Don't summarize files from their names — read the diff.
- Don't commit without showing the user the grouped plan and getting a go-ahead,
  unless they've already said "commit it".
- Don't `git add -A` / `git add .` when the point is a *grouped* commit — stage
  explicit paths so unrelated changes don't leak in.
- Don't use destructive cleanup (`git checkout --`, `git reset --hard`) to tidy
  the tree; this skill reviews and groups, it doesn't discard work.
- Don't fabricate a "what for" — if a change's intent is unclear from the diff,
  say so and ask.
