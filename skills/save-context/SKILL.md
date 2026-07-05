---
name: save-context
description: Snapshot this chat's material findings into a per-repo memory store under ~/.claude/save-context/, updating durable accumulator files (codebase map, subagent research, user behavior, open threads) in place AND appending a self-contained chronological snapshot at `chats/context_<ts>.md`. The goal is to make future sessions in the same cwd cheap — no re-exploration, no re-derivation. **PROACTIVELY auto-invoke at natural checkpoints, without waiting for the explicit ask**: (a) after a substantial multi-step change has landed and been verified, (b) when the user signals wrap-up ("done for now", "good work", "let's commit", "wrapping up", "that's enough for today"), (c) after subagent research produces findings worth keeping (Explore/Plan agents returned material insight), (d) when a major decision was made with non-obvious rationale, or (e) when the user explicitly says "save context", "remember this chat", "checkpoint", "save this". Skip trivial chats (single Q&A, no decisions) — but write a stub INDEX entry so history stays gapless. Always ends by telling the user what was saved so they can override.
---

# Save Context (smart accumulator)

Each save has two jobs:

1. **Append** a self-contained per-chat snapshot under `chats/context_<ts>.md` (history — never overwritten).
2. **Update in place** the durable accumulator files that future sessions load via the `find-context` skill: `codebase.md`, `research.md`, `behavior.md`, `open-threads.md`. This is the part that stops future you from re-doing work.

## When this fires (auto-invoke checkpoints)

There is no timer — saving is not on a clock. It triggers at **semantic checkpoints**
that you recognise in the flow of the conversation. Auto-invoke, without waiting for the
user to ask, at any of these:

- **(a) A substantial multi-step change landed *and was verified.*** Not merely "files
  were edited" — the work completed and was confirmed (tests passed, the app ran, the fix
  was checked). A finished, verified unit of work is the classic checkpoint.
- **(b) The user signals wrap-up** — "done for now", "good work", "let's commit",
  "wrapping up", "that's enough for today". The session's thinking is worth keeping before
  it ends.
- **(c) Subagent research returned something worth keeping** — an Explore / Plan /
  general-purpose agent came back with material findings, so that expensive research
  doesn't have to be re-run next session.
- **(d) A major decision was made with non-obvious rationale** — approach X was chosen
  over Y for a reason future sessions would otherwise forget. The *why* is the payload.
- **(e) The user asked explicitly** — "save context", "remember this chat", "checkpoint",
  "save this", or the `/save-context` command.

Notes:
- **This is judgment, not automation.** You decide a checkpoint was reached by reading the
  conversation. A long chat that never hits one of these (open-ended exploration, nothing
  landed, no decision) may not warrant a self-triggered save — and that's fine.
- **Don't save the same checkpoint twice.** If you already saved after a unit of work,
  don't re-fire on the next small confirmation. One save per meaningful checkpoint.
- **Trivial chats are skipped but not silently** — see Hygiene: still write the chat
  snapshot + INDEX line so history stays gapless; just skip the accumulator updates.

## Where things live

Root: `~/.claude/save-context/<cwd-slug>/`

`~` resolves to the user's home directory on every platform (`$HOME` on macOS/Linux, `%USERPROFILE%` on Windows).

Slug rule: cwd with each single `:`, `\`, `/`, or whitespace character replaced by one `-` (per-char, not collapsed runs — so a leading `d:\` produces `d--`, not `d-`). Examples:

- Windows: `d:\Projects\my-repo` → `d--Projects-my-repo`
- macOS/Linux: `/Users/you/code/my-repo` → `-Users-you-code-my-repo`

Layout:

```
<slug>/
  INDEX.md            – chronological chat list, latest first
  codebase.md         – running map of how this repo works
  research.md         – subagent findings + verification, keyed by question
  behavior.md         – user preferences, style, dos/donts
  open-threads.md     – suggested next steps for future sessions
  chats/
    context_<ts>.md   – per-chat snapshot (append-only)
```

Create the dir + all four accumulator files with skeleton headers on first save.

## Step 1 — Gather what to save

Look across the chat and produce structured material for each accumulator. **Prioritise ratio of value-to-tokens** — a future session paying tokens to read `codebase.md` should get more than they'd get by re-exploring. Skip filler.

### `codebase.md` material

Facts about **how this repo works** that were confirmed this chat and would take non-trivial exploration to re-derive. Keyed by topic (headings like `## Request routing`, `## Config resolver`, `## Auth middleware`).

Each fact records:
- The claim (one sentence).
- Cite `path/to/file.ext:line_or_range` so future you can jump to it.
- If the claim was *verified* (grep confirmed, code read), note that. If it's just an assumption, mark `[unverified]` or drop it.

**Do NOT copy code snippets** unless they're 5 lines or fewer and the point isn't obvious from the file/line reference. Prose is denser.

### `research.md` material

Any Explore / Plan / general-purpose subagent output that has lasting value. For each:
- **Question** (heading) — what the agent was asked to find out.
- **Findings** — the agent's conclusion, condensed. Cite file paths.
- **Verified** — was this verified against code afterwards (yes / partial / no).
- **Chat** — the timestamp of the chat that produced it (so it can be superseded).

If a prior research entry is contradicted or updated by this chat's findings, **mark the old one stale** by adding a line at the top of that entry: `**Stale as of <YYYY-MM-DD>:** superseded by …`. Don't delete it — future you may need to see what changed.

### `behavior.md` material

Preferences the user expressed **that should shape future behavior in this repo**. Not universal traits (those belong in your global memory). Examples (illustrative — replace with what the user actually says):
- "This user prefers small, focused commits over one big one."
- "Ask before touching shared modules (auth, billing)."
- "Auto-mode is often on; when off, ask before non-trivial decisions."

Update in place — if a new observation refines an old one, edit the old line, don't stack duplicates. If a preference is **retracted** (user changes their mind), strike it: `~~old rule~~ (retracted <date>: user now prefers X)`.

### `open-threads.md` material

Concrete next steps that are actionable. Each item:
- One line, imperative form.
- Optional `Why:` clause.
- Status marker: `[open]`, `[blocked: <reason>]`, `[done <date>]`, `[cancelled <date>]`.

When you save, also **update prior entries**: mark completed ones `[done]` with the date, mark cancelled ones. Never delete — a struck-through history is more useful than a fresh list.

### `chats/context_<ts>.md` (per-chat snapshot)

Full chat summary — topic, background, decisions with why, files modified, gotchas, references, open threads for this chat. See "File format" below.

## Step 2 — Capture subagent outputs explicitly

Subagent output (task-notification results from Explore / Plan / general-purpose agents) contains rich research. Before writing `research.md`, check the current session for:

- Any `<task-notification>` blocks with subagent results earlier in this chat.
- Any referenced subagent output files.

For each finding worth keeping, add an entry to `research.md` with the question + condensed conclusion + citations. Do NOT paste the full agent transcript.

## Step 3 — Per-chat snapshot format

```markdown
---
saved_at: 2026-07-01T13:21:55
cwd: /Users/you/code/my-repo
slug: -Users-you-code-my-repo
git_branch: <branch>
git_head: <short SHA>
topic: <one-sentence summary>
---

# {{topic}}

## Background
{{...}}

## Decisions
- **{{decision}}** — Why: {{...}}. Alternatives considered: {{...}}.

## Files modified / created
- `path/to/file.ext` — {{why in one line}}

## Subagent research this chat
- {{question}} → summary → citation (also copied into research.md)

## User preferences / feedback voiced
- {{...}}  (also merged into behavior.md)

## State at save time
- {{running processes, branch, verified vs unverified}}

## Gotchas
- {{...}}  (also merged into codebase.md when the gotcha is a durable repo fact)

## External references
- {{...}}

## Open threads / next steps
- {{...}}  (also merged into open-threads.md)
```

Drop empty sections.

## Step 4 — INDEX.md

Add one line to the top under the header (latest first):

```
- [{{YYYY-MM-DD HH:MM}}](chats/context_{{ts}}.md) — {{topic one-liner}}
```

## Step 5 — Report to user

Tell the user:
- Full path of the new chat snapshot.
- Which accumulator files were updated + roughly how much was added (e.g. "3 new entries in `codebase.md`, 1 stale marker in `research.md`, 2 items marked done in `open-threads.md`").
- Anything you considered saving but skipped (so they can override).

## Hygiene

- **Never overwrite chat snapshots.** Accumulator files ARE overwritten (that's their point) — but overwrites are additive/edits, not blank slates.
- **Cite file paths** for every claim in `codebase.md` and `research.md`. Uncited facts are folklore; don't save folklore.
- **Resolve relative time** to absolute dates.
- **When in doubt, save it** — a stale entry with a marker is more useful than a missing one.
- **If nothing worth saving** (trivial chat), still write the chat snapshot (so INDEX.md accounts for it) but skip accumulator updates. Note this in the report.

## Rule the skill enforces

Saving is not applying. This skill only writes to `~/.claude/save-context/<slug>/`. It does NOT touch the repo, git, config, or the running app. Anything you notice while writing that you *could* act on — turn it into an `open-threads.md` entry, don't apply it.
