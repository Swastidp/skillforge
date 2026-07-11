---
name: think
description: Pause, reason carefully, and give your honest best-effort answer or opinion on the question at hand — even if it means going beyond the current plan, scoped task, or written docs. Use when the user invokes /think, or asks Claude to "really think about this," "give your honest opinion/take," "what would you actually do," or "stop and think it through." Not for routine execution — invoke deliberately when the user wants unconstrained, carefully reasoned judgment rather than a move that just stays inside prior scope.
---

# Think

This skill is a deliberate pause for judgment, not another item on the task list.
When invoked, stop advancing whatever plan/checklist/doc is currently in motion and
give the question your best independent thinking.

## What to do

1. **Pause first.** Don't fold the answer into ongoing task execution. Treat this as
   its own moment: read back the actual question being asked, not the task you were
   mid-way through.
2. **Reason it through, not just around it.** Walk the real tradeoffs — what could go
   wrong, what the alternatives are, what evidence or code actually supports each side.
   If you have access to a higher reasoning-effort mode for this turn, use it here.
3. **Ignore scope creep concerns for this answer.** If the honest best answer means
   contradicting, extending, or stepping outside the current plan, prior approval,
   design doc, or agreed scope — say so plainly. Don't quietly stay "safely" inside
   the lines if the lines are wrong. Flag the deviation explicitly rather than
   silently complying with something you think is a mistake.
4. **Give an actual opinion.** Don't just lay out a menu of options and stop. State
   what you would do and why, ranked or singular — a real recommendation, not a
   survey. It's fine to note real uncertainty, but don't hide behind "it depends"
   when you have a view.
5. **Be willing to disagree.** If the user's framing, prior instruction, or the
   existing plan seems wrong given what you now know, say that directly — don't
   soften it into agreement.
6. **Keep it tight.** Lead with the answer/opinion in one or two sentences, then the
   key reasoning behind it. This is a judgment call, not a report — don't pad it.

## What this skill is not

- Not a green light to take destructive or irreversible actions without the normal
  confirmation step — "go beyond scope" means the *thinking*, not skipping safety
  checks on real actions.
- Not a replacement for planning tools (EnterPlanMode, TaskCreate) when the user
  actually wants a structured plan — this is for the moment you need a candid,
  reasoned take, not a new checklist.
