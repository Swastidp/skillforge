---
name: update-docs
description: Find every doc file tied to the current repo (README, CLAUDE.md, docs/**, CHANGELOG, ARCHITECTURE, and anything they link to) — including gitignored/untracked docs like local notes, scratch writeups, or private-config docs — and bring them all in line with the repo's actual current state — recent commits, new/removed files, changed commands, updated metrics. Use when the user says "update docs", "sync the docs", "docs are stale", "update the README", or after landing a feature/fix when they want the write-up to catch up. Works on any repo — discovers doc locations rather than assuming a fixed layout. Verifies every factual claim against the real codebase before editing (file exists, command still valid, number still current) rather than guessing from doc text alone. Only edits docs, never source code, and never commits — leaves changes for the user to review.
---

# Update Docs

Bring a repo's documentation back in sync with what the code and git history
actually say. This is a **global** skill — it makes no assumption about repo
layout or subject matter; it discovers what docs exist and what "current" means
per-repo, each time it runs.

## Procedure

### 1. Discover the doc set

Don't assume `README.md` + `docs/` is the whole story — repos vary. Glob broadly,
then prune:

```
**/*.md
**/*.mdx
**/README*
**/CHANGELOG*
**/ARCHITECTURE*
**/CONTRIBUTING*
```

Exclude dependency/build clutter regardless of tracked status —
`node_modules/`, `.git/`, `vendor/`, `.venv/`, `venv/`, `target/`, `dist/`,
`build/`, and any third-party package's own docs. **Do not exclude gitignored
project docs.** A `.gitignore` entry usually means "don't track" (local notes,
scratch writeups, machine-specific setup docs, generated-but-hand-edited
reports), not "not a real doc" — those are exactly the kind of doc that drifts
fastest because no one reviews it in PRs. Use `git check-ignore -v <path>` to
see *why* something is ignored (a blanket `*.md` rule vs. a targeted
`/vendor/` rule) — that tells you whether it's a project doc worth updating or
genuine dependency/build output to leave alone.

Also **follow references**: open the top-level README and any CLAUDE.md /
AGENTS.md first — they often link out to writeup docs (e.g. "see
`docs/ARCHITECTURE_NOTES.md`") that a flat glob would still catch, but reading
the links tells you which docs are load-bearing vs incidental (a vendored
CHANGELOG from a dependency isn't yours to edit).

If the repo has a CLAUDE.md / AGENTS.md, **read it for house rules** — required
terminology (e.g. a naming convention that must never be violated), file
conventions, things marked "don't commit", etc. Any doc edit must honor those
rules, not just be factually correct.

### 2. Establish what "current" means

Figure out what's actually changed since each doc was last true:

```bash
git log -1 --format=%ai -- <doc-path>      # when this doc last changed
git log --oneline -20                       # recent shipped work
git log --stat <doc-last-commit>..HEAD      # what changed since, in detail
git status --short                          # uncommitted work in flight too
```

Prioritize docs whose last-touch commit is far behind HEAD, or where recent
commits clearly touch what the doc describes (a commit renaming a script that
the README still calls by its old name, a new module with no doc mention).

### 3. Verify every claim before touching it

Docs go stale in specific, checkable ways. For each doc, read it and check its
concrete claims against the real state — don't rewrite from vibes:

- **Paths/filenames it names** — still exist? (Glob/Read) Renamed or moved?
- **Commands/flags it shows** — still valid? Grep the actual CLI/script for the
  flag names and defaults it claims.
- **Numbers/metrics/verdicts** — if a doc cites a result (benchmark, perf
  number, pass/fail gate) backed by a results file, re-read that file for the
  current value rather than trusting the doc's cached copy.
- **Feature/module lists** — cross-check against what's actually in the source
  tree now; note both additions (shipped but undocumented) and removals
  (documented but deleted).
- **Status language** ("in progress", "TODO", "not yet implemented", "primary
  path is X") — check if code now contradicts it (the TODO was done; the
  "primary path" moved).

If you can't verify a claim (e.g. it depends on external state you can't
check), leave it alone rather than guessing — flag it in your summary instead.

### 4. Edit, minimally and in the doc's own voice

Use Edit, not full rewrites — change only what's actually stale. Match the
existing doc's tone, heading structure, and any house terminology from
CLAUDE.md/AGENTS.md. Don't:

- Add new sections the doc didn't have unless the repo genuinely gained a
  feature category with nowhere else to go.
- Editorialize, add marketing language, or "improve" prose that wasn't wrong.
- Touch vendored/dependency docs that belong to someone else's package, or
  auto-generated output (a build's `dist/README`, a coverage report) that gets
  regenerated and would just be overwritten next build.
- Fabricate a number, date, or status you couldn't verify in step 3.

### 5. Report, don't commit

Summarize per-file what changed and why (one line each is usually enough), and
call out anything you deliberately left alone because you couldn't verify it.
**Never run `git commit`** — leave the edits unstaged/uncommitted for the user
to review and commit themselves, per standing git policy.

## What NOT to do

- Don't assume every repo has the same doc layout — always discover first.
- Don't trust a doc's own claims as ground truth — the code and git log are
  ground truth; the doc is the thing being corrected.
- Don't do a bulk find-and-replace across all docs without reading each one —
  context (a code sample vs. a prose reference) changes whether an edit is
  correct.
- Don't touch source code, tests, or config — this skill is docs-only.
- Don't commit, stage-and-forget, or push. Report and stop.
