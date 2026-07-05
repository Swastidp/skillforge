# skillforge

**A growing, curated collection of skills for [Claude Code](https://claude.com/claude-code).**

Each skill here earns its place by solving a real friction I hit while working with
Claude Code. They get refined over time as I learn what actually holds up in daily use —
this is a forge, not a museum. Take the ones you want; they're all self-contained.

## What's a skill?

A [skill](https://docs.claude.com/en/docs/claude-code/skills) is a folder with a
`SKILL.md` that teaches Claude Code a repeatable capability and tells it *when* to reach
for it. Claude Code auto-discovers any skill in `~/.claude/skills/`, and you can always
invoke one by hand with `/<skill-name>`.

## Skills in this collection

| Skill | What it does |
|-------|--------------|
| [**context-memory**](#context-memory) (`save-context` + `find-context`) | Persistent, per-repo memory so Claude Code stops re-exploring your codebase every session |

*(more to come — this list grows as skills prove themselves)*

## Install

One command. Skills land in `~/.claude/skills/`, which Claude Code auto-discovers — no
config needed.

**macOS / Linux / Git-Bash**

```bash
# everything
curl -fsSL https://raw.githubusercontent.com/Swastidp/skillforge/main/install.sh | bash

# only the skills you name
curl -fsSL https://raw.githubusercontent.com/Swastidp/skillforge/main/install.sh | bash -s -- find-context save-context
```

**Windows (PowerShell)**

```powershell
# everything
irm https://raw.githubusercontent.com/Swastidp/skillforge/main/install.ps1 | iex

# only selected skills: clone, then pass names
git clone https://github.com/Swastidp/skillforge.git
.\skillforge\install.ps1 find-context save-context
```

Prefer to do it by hand? Clone and copy the folders you want into `~/.claude/skills/`.
Re-running the installer is safe — it overwrites in place, so it doubles as an updater.

---

## context-memory

Claude Code starts every session with a blank slate. It re-explores your codebase,
re-runs the same greps, and re-asks questions a past session already answered — burning
tokens and your time on work that was already done.

Two skills fix that as a loop:

- **`save-context`** distils a session into a durable, local memory store for the repo.
- **`find-context`** loads only the *relevant* parts of that store at the start of the
  next session — before Claude reaches for exploration agents or broad searches.

```
  ┌────────────────┐        writes         ┌───────────────────────────┐
  │  session ends  │ ───► save-context ───► │  ~/.claude/save-context/  │
  └────────────────┘                        │        <repo-slug>/       │
                                             │  codebase.md              │
  ┌────────────────┐                         │  research.md              │
  │ session starts │ ◄── find-context ◄───── │  behavior.md              │
  └────────────────┘        reads            │  open-threads.md          │
                                             │  chats/context_<ts>.md    │
                                             └───────────────────────────┘
```

Memory is split into purpose-built files so the next session loads only what it needs:

| File | Holds |
|------|-------|
| `codebase.md` | How the repo works — facts with `file:line` citations, marked verified or not |
| `research.md` | Conclusions from Explore/Plan subagents, keyed by question, with stale markers |
| `behavior.md` | Preferences that shape how Claude should work *in this repo* |
| `open-threads.md` | Actionable next steps carried across sessions, with status markers |
| `chats/context_<ts>.md` | Append-only per-session snapshots (full history, never overwritten) |
| `INDEX.md` | Chronological list of every saved chat |

Both fire proactively, but you can invoke them by hand:

- `/save-context` — snapshot the session (also auto-fires on wrap-up signals or after a
  verified multi-step change).
- `/find-context` — load prior context (also auto-fires at the start of a non-trivial task
  when a store exists). Add a topic hint to filter: `/find-context auth`.

`save-context` writes; `find-context` only reads and *suggests* — it never edits your
repo, runs anything, or commits on its own.

## Privacy

Everything stays on your machine. Memory stores live under your own `~/.claude/` and
nothing is uploaded anywhere. Each repo gets its own folder (keyed by a slug of its
path), so contexts never bleed between projects.

> **Note:** the store can contain code excerpts, file paths, and design notes from your
> repos. It's local, but treat `~/.claude/save-context/` as you would the repos it
> describes — don't sync it somewhere public.

## License

[MIT](LICENSE)
