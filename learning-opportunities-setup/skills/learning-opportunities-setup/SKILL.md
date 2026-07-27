---
name: learning-opportunities-setup
description: Interviews the user about learning preferences and writes personal overrides for the learning-opportunities skill. Invoke when the user wants to personalize learning-opportunities, set up learning style prefs, or choose where to store exercise notes. Do not trigger automatically.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Personalize Learning Opportunities

## Purpose

Help the user customize [learning-opportunities](https://github.com/DrCatHicks/learning-opportunities) for *their* workflow: learning style, when to offer exercises, and where to store notes from completed or skipped sessions.

Output:
1. A ready-to-use override block in the instruction file they choose
2. Optional stub files for session / weekly logs (only if they want them)
3. A short how-to reminder

This skill does **not** run learning exercises. After setup, point them at `learning-opportunities` (and optionally `learning-opportunities-auto`, `orient`, or [learning-goal](https://github.com/DrCatHicks/learning-goal)).

Consult [resources/knobs.md](resources/knobs.md) if you need a refresher on what each preference controls. Consult [resources/override-template.md](resources/override-template.md) and [resources/log-stubs.md](resources/log-stubs.md) when writing the final artifacts.

---

## Core rule: pause for input

**Ask ONE question per turn. End the message immediately after the question.**

Do not:
- Dump the full questionnaire
- Offer multiple questions in sequence
- Write the final override block until the interview is done (or the user says "wrap up with defaults")
- Invent preferences they did not state

Allowed after a question:
- 2–4 brief options when that speeds answering (always allow free text)
- A content-free reassurance: "(Take your best guess—we can revise.)"
- An escape hatch: "(Or say wrap up with defaults.)"

Prefer the user's own words over jargon. Mirror their learning language back to them.

---

## Step 0: Orient (one short sentence, then first question)

Tell them you will interview them briefly, then write local overrides they can edit anytime. Then ask **A1** only.

---

## Interview outline

Cover each area. Skip anything they say does not apply. If they are unsure, propose a default from what they have already said and ask them to confirm or tweak.

### A. Context

- **A1.** Which agent tools are you personalizing for? (Claude Code, Cursor, Codex, mix)
- **A2.** Where should the override text live?
  - Claude Code: often `CLAUDE.local.md` (gitignored) or project `CLAUDE.md` / memory
  - Cursor: user or project rules
  - Codex: project instructions / AGENTS.md-style files
  - Other: let them name the path
- **A3.** What's stronger vs newer for you right now? (languages, domains, this codebase)

Warn once: prefer a **local / gitignored** file for personal prefs unless their team wants shared learning norms in-repo.

### B. Learning style

- **B1.** How do you usually "get it"? (big picture first / trace a path / predict-then-check / teach it back / debug a broken case / hands-on find-the-file / other)
- **B2.** What feels like a *bad* exercise for you?
- **B3.** Scaffolding: start more guided and fade, or assume you can hunt in the codebase?
- **B4.** Any processing or accessibility needs you want honored? (plain-language restate, backwards-design "where are we going," no quiz vibe, extra wait time — only what they volunteer; never probe)

### C. When to offer

- **C1.** Auto-offer after significant work, only when you ask, or both?
- **C2.** Keep the skill's default "significant work" triggers, or customize?
- **C3.** Session cap? (default: at most 2). Behavior after you decline? (default: no more offers that session)
- **C4.** Session-start recall check-ins: yes / no / only for certain topics?
- **C5.** Any sticky concepts you want as recurring retrieval prompts?

If they use or plan to use `learning-opportunities-auto`, ask whether the post-commit nudge should be a **hard stop** (offer before continuing other work). Default recommendation: yes.

Also recommend: exercise / recall questions only as the **last line of a stopped turn** (no more tool calls after the question). Include this unless they opt out.

### D. Documentation and storage

- **D1.** After a **completed** exercise (or mid-session concept that clicked), where should a short note go?
  - daily note (Obsidian / Notion / journal) under `## Learning`
  - project MEMORY / learning log file
  - dedicated learning vault / notebook
  - nowhere (exercises only; no written trail)
- **D2.** After a **skipped / declined** exercise: never log / ask once / always log a one-liner topic?
- **D3.** Rolling "this week" log for a later retrieval pass (write during the week, read only on review)? If yes: path + one-line format.
- **D4.** Filename / date conventions if notes are dated.
- **D5.** Anything that must **not** be written down (secrets, customer data)?

### E. Finish

1. Summarize choices in plain language and ask them to confirm.
2. On confirm (or "wrap up with defaults"), write the artifacts (Step 1–3 below).
3. Tell them how to re-run this skill anytime to revise.

---

## Step 1: Write the override block

Write (or append) a `## Learning Opportunities` section to the path chosen in A2.

Rules:
- Use the user's name or "the user" consistently with how their instruction files already refer to them
- Include only knobs they chose; do not pad with unused options
- Keep comments short; say the *why* when a choice is non-default
- If the target file already has a Learning Opportunities section, update it in place rather than duplicating
- Show them the final block in the chat as well as writing the file

Shape the section from [resources/override-template.md](resources/override-template.md), deleting unused bullets.

---

## Step 2: Optional stub files

Only create files they asked for in D.

- Daily-note `## Learning` section: do **not** create a dated daily note unless they explicitly ask and give a path/date. Prefer telling them the section heading to use.
- Weekly log / history stubs: create from [resources/log-stubs.md](resources/log-stubs.md) at the paths they chose. Do not overwrite non-empty log files; append a header comment only if missing.

---

## Step 3: Confirm to the user

Tell them:
- Where overrides were written
- Which stub files (if any) were created
- How to use next: keep coding; accept or decline exercise offers from `learning-opportunities`
- Optional next installs: `learning-opportunities-auto`, `orient`, [learning-goal](https://github.com/DrCatHicks/learning-goal)
- That they can re-run `/learning-opportunities-setup` to revise

Include a 3–5 line how-to reminder they can keep next to the overrides.
