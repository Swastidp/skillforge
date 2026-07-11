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

| Skill | What it does | Invoke |
|-------|--------------|--------|
| [**context-memory**](#context-memory) (`save-context` + `find-context`) | Persistent, per-repo memory so Claude Code stops re-exploring your codebase every session | auto + `/save-context`, `/find-context` |
| [**update-docs**](#update-docs) | Finds every doc tied to a repo — tracked or gitignored — and syncs them with its actual current state, verifying each claim before editing | `/update-docs` |
| [**review-changes**](#review-changes) | Explains your staged/unstaged diff file-by-file, groups it by theme, flags likely bugs or accidental commits, and proposes a commit plan | `/review-changes` |
| [**chit-chat**](#chit-chat) | Repo-scoped conversation mode *template* — Claude answers only questions related to your project and politely declines everything else | `/chit-chat` |
| [**think**](#think) | Deliberate pause for judgment — gives an honest, reasoned opinion instead of staying safely inside the current plan or scope | `/think` |

*(more to come — this list grows as skills prove themselves)*

## Install

One command. Skills land in `~/.claude/skills/`, which Claude Code auto-discovers — no
config needed.

**macOS / Linux / Git-Bash**

Everything

```bash
curl -fsSL https://raw.githubusercontent.com/Swastidp/skillforge/master/install.sh | bash
```

Only the skills you name

```bash
curl -fsSL https://raw.githubusercontent.com/Swastidp/skillforge/master/install.sh | bash -s -- find-context save-context
```

**Windows (PowerShell)**

Everything

```powershell
irm https://raw.githubusercontent.com/Swastidp/skillforge/master/install.ps1 | iex
```

Selected skills, single command

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Swastidp/skillforge/master/install.ps1))) find-context save-context
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
  ┌────────────────┐        writes           ┌───────────────────────────┐
  │  session ends  │ ───► save-context ───►  │  ~/.claude/save-context/  │
  └────────────────┘                         │        <repo-slug>/       │
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

## update-docs

Docs drift. A README claims a command that no longer exists, a metric goes stale, a file
it references got renamed. `update-docs` brings a repo's documentation back in line with
what the code and git history *actually* say.

It makes no assumption about layout — it discovers what docs exist (README, `CLAUDE.md`,
`docs/**`, `CHANGELOG`, `ARCHITECTURE`, and anything they link to), **including gitignored
or untracked files** like local notes and scratch write-ups. Before changing a line it
verifies the claim against the real codebase: the file still exists, the command still
runs, the number is still current — rather than trusting the old doc text.

Safe by construction: it edits *only* docs, never source, and never commits — you review
the diff.

- Fires on "update docs", "sync the docs", "docs are stale", "update the README", or after
  landing a feature when the write-up needs to catch up.
- Manual: `/update-docs`.

## review-changes

Makes sense of your working-tree diff *before* you commit. Given your staged and unstaged
changes it produces four things: a per-file explanation of what each change is for, a
grouping into coherent themes, a short list of things to double-check (likely bugs,
debug leftovers, accidental commits), and a suggested commit plan that splits the work
into clean, logical commits.

It reads git and explains — it does not stage, commit, or modify your files.

- Fires on "review my changes", "what did I change", "help me commit this cleanly".
- Manual: `/review-changes`.

## chit-chat

Repo-scoped conversation mode: Claude answers freely, but *only* about topics connected to
the current project — its domain concepts, codebase structure, interfaces, dependencies —
and politely declines anything unrelated. Useful when you want to think out loud about a
project without Claude wandering off-topic.

> **This one is a template.** Before using it, open `skills/chit-chat/SKILL.md` and replace
> `<PROJECT NAME>` / `<path/to/project>` and the "In scope" bullets with your own repo's
> details. Out of the box it has placeholders, not your project.

- Manual: `/chit-chat`.

## think

A deliberate pause for judgment, not another task-list item. When invoked, Claude stops
advancing whatever plan is in motion, reasons through the real tradeoffs, and gives an
honest, best-effort opinion — even if that means contradicting or stepping outside the
current plan, prior approval, or design doc. It flags the deviation rather than quietly
staying "safely" inside lines that might be wrong.

Reach for it deliberately — it's for the moments you want unconstrained reasoned judgment,
not routine execution.

- Fires on "really think about this", "give your honest take", "what would you actually
  do", "stop and think it through".
- Manual: `/think`.

## Add your own

Skills are just folders, so extending the collection is copy-and-edit:

1. Create `skills/<your-skill>/SKILL.md` with a `name` and a `description` — the
   description is what tells Claude Code *when* to reach for the skill, so make it specific.
2. Add supporting files in the same folder if the skill needs them.
3. Add a row to the table above and (optionally) a section here.

Then install it like any other: `./install.sh <your-skill>`.

## Privacy

Everything stays on your machine. Memory stores live under your own `~/.claude/` and
nothing is uploaded anywhere. Each repo gets its own folder (keyed by a slug of its
path), so contexts never bleed between projects.

> **Note:** the store can contain code excerpts, file paths, and design notes from your
> repos. It's local, but treat `~/.claude/save-context/` as you would the repos it
> describes — don't sync it somewhere public.

## License

[MIT](LICENSE)
