---
name: find-context
description: Load prior work for the current repo from ~/.claude/save-context/<cwd-slug>/ — codebase map, subagent research, user behavior, open threads, chat snapshots. Selective (only pulls what matches the current task, not everything) and ends with predicted next steps as SUGGESTIONS the user must approve, never applied. **PROACTIVELY auto-invoke at the start of any non-trivial task in a repo where `~/.claude/save-context/<cwd-slug>/` exists — don't wait for the user to ask.** Fire before you would otherwise run Explore/Plan/general-purpose agents, before broad grep sweeps, or before asking the user to re-explain context that a prior session already captured. Run at most once per session (accumulator files are small; the whole load is a few Reads). If the per-cwd dir doesn't exist, exit silently — cost is one `ls`. Also fires when the user explicitly says "find context", "recall this repo", "what do we know", "load memory", "what did we discuss", etc.
---

# Find Context

Load what past sessions have saved for the current repo so you don't re-derive it. The goal is token frugality — don't dump every file, pull only what's relevant to the current task. End with predicted next steps as **suggestions only** (never applied without explicit user approval).

## Where to look

`~/.claude/save-context/<cwd-slug>/` where the slug is the current cwd with each single `:`, `\`, `/`, or whitespace character replaced by one `-` (per-char, not collapsed runs — so a leading `d:\` produces `d--`, not `d-`). Examples:

- Windows: `d:\Projects\my-repo` → `d--Projects-my-repo`
- macOS/Linux: `/Users/you/code/my-repo` → `-Users-you-code-my-repo`

`~` resolves to the user's home directory on every platform (`$HOME` on macOS/Linux, `%USERPROFILE%` on Windows). If the directory doesn't exist, no prior context has been saved — say so plainly ("no saved context for this repo yet") and stop. Do NOT invent fallbacks.

## What to load, in this exact order

1. **Always load, in full** (they're small and essential):
   - `INDEX.md` — chat list. Tells you how deep the history goes.
   - `behavior.md` — user preferences that shape how you should work.
   - `open-threads.md` — actionable items carried over from prior sessions.

2. **Selectively load** based on the task/query:
   - `codebase.md` — search for headings + surrounding paragraphs that match keywords in the current task. If no query is given, load the whole file (usually still small enough).
   - `research.md` — same treatment. Skip entries marked `**Stale as of ...**` unless the user is asking about history.

3. **Rarely load** — only when the earlier steps didn't answer the current question:
   - Individual chat snapshots under `chats/`. Pick by INDEX.md entry (topic line). Load one, maybe two, never a bulk read. Each one is expensive to process.

If the user gave a topic hint (e.g. `/find-context quantization`), use it to filter aggressively. If they didn't, use the current task's keywords (from the last user message, todo list, or current file focus).

## What to return

A concise brief the current session can act on — not a dump of files. Structure:

```
## What's known about this repo (relevant to <task>)

- <fact> — `<file:line>` (from codebase.md)
- ...

## Prior subagent research relevant here

- **Q:** <question> → <one-line conclusion>. Verified: <yes/partial/no>. Full entry in `research.md`.
- ...

## User's preferences that apply

- <preference>
- ...

## Open threads from prior sessions

- [<status>] <thread> — Why: <if given>
- ...

## Suggested next steps (NOT applied — awaiting your approval)

1. <suggestion, most likely to be what the user wants first>
2. <alternate>
3. ...
```

Order the "Suggested next steps" by likelihood, based on:
- What's still `[open]` in open-threads.md that matches the current task.
- The most recent chat snapshot's "Open threads / next steps" section.
- User preferences that hint at direction (e.g. "user prefers to run full verification before committing" → suggest a verify step).

Each suggestion is short and actionable. Never more than 5. If nothing sensible to suggest, drop this section entirely.

## Suggest, never apply

This skill only READS `~/.claude/save-context/<slug>/`. It does NOT:
- Modify the repo.
- Start servers or run tests.
- Create git commits.
- Invoke other skills.

Suggestions are text output for the user to accept or override. Wait for them.

## Hygiene

- **Prefer the accumulator files over chat snapshots.** Chat snapshots are the fallback when a specific question isn't answered by the durable notes. If you keep needing them, that's a signal `save-context` didn't distil enough — mention it in your report so the user knows to tighten future saves.
- **Cite file paths from the codebase itself** (not just the memory file) when passing along a fact. Future you will want to jump to the code.
- **Don't re-derive.** If a fact is already in `codebase.md`, don't run grep to confirm it unless the user is challenging it. Trust the note; verification costs tokens.
- **Flag drift honestly.** If a note references a file that no longer exists (rename, delete), say so instead of guessing. Suggest an `open-threads.md` entry to reconcile.
- **Cap output length.** If the brief would exceed ~400 lines, chunk it: return the most-relevant sections first, offer to load more on request.

## Rule the skill enforces

Load, distil, suggest. Don't act. This is a read-only lookup, not a task executor.
