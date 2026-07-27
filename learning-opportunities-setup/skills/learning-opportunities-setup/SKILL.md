---
name: learning-opportunities-setup
description: Interviews the user about learning preferences and writes personal overrides for the learning-opportunities skill. Supports first-time setup and refine mode after hits/misses. Invoke when the user wants to personalize learning-opportunities, set up learning style prefs, choose where to store exercise notes, or retune after experimenting. Do not trigger automatically.
argument-hint: "[refine]"
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

**Resources:** [knobs.md](resources/knobs.md), [override-template.md](resources/override-template.md), [log-stubs.md](resources/log-stubs.md), [example-minimal.md](resources/example-minimal.md), [example-richer.md](resources/example-richer.md), [refine-prompts.md](resources/refine-prompts.md).

---

## Argument check

You were invoked with arguments: `$ARGUMENTS`

If the argument is `refine` (or contains `refine`), skip to the **Refine path** section below.

Otherwise continue with the **Setup path** (default).

---

## Core rule: pause for input

**Ask ONE question per turn. End the message immediately after the question.**

Do not:
- Dump the full questionnaire
- Offer multiple questions in sequence
- Write or patch the final override block until the interview is done (or the user says "wrap up with defaults")
- Invent preferences they did not state

Allowed after a question:
- 2–4 brief options when that speeds answering (always allow free text)
- A content-free reassurance: "(Take your best guess—we can revise.)"
- An escape hatch: "(Or say wrap up with defaults.)"

Prefer the user's own words over jargon. Mirror their learning language back to them.

---

# Setup path (default)

## Step 0: Orient and choose speed

One short sentence: you will interview them briefly, then write local overrides they can edit anytime (and later retune with `/learning-opportunities-setup refine`).

Then ask **S1** only:

- **S1.** Quick path (~3 minutes — stronger/newer, offer timing, cap, one storage choice, sensible defaults for the rest) or full path (~10–15 minutes — more style, scaffolding, and logging detail)?

**Adaptive depth:** If they say anything like "just make it work," "defaults," or "quick," use the **Quick path** without re-asking. Open full-path branches only when answers show they care about that area.

Warn once (during A2 or when writing): prefer a **local / gitignored** file for personal prefs unless their team wants shared learning norms in-repo.

---

## Quick path

Ask these in order (one per turn). Apply [resources/knobs.md](resources/knobs.md) defaults for everything not asked. Do not invent a preferred-exercise-style bias unless they volunteer one.

1. **Q1.** What's stronger vs newer for you right now? (languages, domains)
2. **Q2.** On *this* codebase, are you mostly **orienting**, **contributing**, or **owning**? (maps to scaffolding: more guided → fade → assume hunt)
3. **Q3.** Auto-offer after significant work, only when you ask, or both?
4. **Q4.** Session cap? (default: at most 2). After decline: stop offering that session? (default: yes)
5. **Q5.** Where should the override text live? (primary place only — see Multi-tool below)
6. **Q6.** Session notes: **none** / **daily note or journal** / **rolling log** / **both**? (tool-agnostic; do not lead with a specific app). If none, skip logging detail. If daily and/or log, ask only for the path(s) needed; use defaults for declined-exercise handling (ask once) and write-only weekly log if they chose a rolling log.

Then jump to **Finish (setup)** — summarize, confirm, write artifacts. Include C6/C7 defaults (hook hard stop yes; questions only when stopped yes) unless they opted out earlier.

---

## Full path

Cover each area below. Skip anything they say does not apply. If unsure, propose a default and ask them to confirm or tweak.

### A. Context

- **A1.** Which agent tools are you personalizing for? (Claude Code, Cursor, Codex, mix)
- **A2.** Where should the **primary** override text live?
  - Claude Code: often `CLAUDE.local.md` (gitignored) or project `CLAUDE.md` / memory
  - Cursor: user or project rules
  - Codex: project instructions / AGENTS.md-style files
  - Other: let them name the path
- **A3.** What's stronger vs newer for you right now? (languages, domains, this codebase)
- **A4.** On *this* codebase, are you mostly **orienting**, **contributing**, or **owning**?

**Multi-tool (optional last step, not required):** If A1 is a mix and they may need the same block in a second tool, after Finish offer once: "Want a copy of this section into a second path?" Do not dual-write in the happy path.

### B. Learning style

- **B1.** Which of these help you learn? **Pick any that apply** (multi-select): big picture first / trace a path / predict-then-check / teach it back / debug a broken case / hands-on find-the-file / other. Default if unsure: keep the core skill's full mix — do **not** bias toward one style unless they opt in.
- **B2.** What feels like a *bad* exercise for you?
- **B3.** Scaffolding: start more guided and fade, assume you can hunt, or match A4 (orienting → more guided; owning → more hunt)?
- **B4.** Optional interaction prefs — only what they volunteer; **never probe**; frame as preferences, not diagnosis. Offer a short menu if useful: plain-language restate / big-picture first / no quiz vibe / more wait time / show file paths vs hunt / none of these.

### C. When to offer

- **C1.** Auto-offer after significant work, only when you ask, or both?
- **C2.** Keep the skill's default "significant work" triggers, or customize?
- **C3.** Session cap? (default: at most 2). Behavior after you decline? (default: no more offers that session)
- **C4.** Session-start recall check-ins: yes / no / only for certain topics?
- **C5.** Any sticky concepts you want as recurring retrieval prompts? (optional; do not invent project-specific defaults)
- **C6.** If you use or plan to use `learning-opportunities-auto`, should the post-commit nudge be a **hard stop** (offer before continuing other work)? Default: yes.
- **C7.** Should exercise / recall questions appear only as the **last line of a stopped turn** (no more tool calls after the question)? Default: yes.

### D. Documentation and storage

Storage is first-class including **none**. Be tool-agnostic (daily note or journal — examples only if needed: Obsidian, Notion, etc.; do not lead with one app).

- **D1.** After a **completed** exercise (or mid-session concept that clicked), where should a short note go? Explicit choices: **none** / **daily note or journal** / **rolling weekly-style log** / **both** (daily + rolling is allowed and explicit).
- **D2.** After a **skipped / declined** exercise: never log / ask once / always log a one-liner topic? (skip if D1 is none)
- **D3.** If they chose a rolling log: write-only during sessions vs readable mid-session? Who reviews later (you / scheduled review / agent-assisted retrieval / undecided)? Path + one-line format.
- **D4.** Filename / date conventions if notes are dated.
- **D5.** Archive / history file for cleared weekly logs? (full path only; skip on quick path)
- **D6.** Anything that must **not** be written down (secrets, customer data)?

### E. Finish (setup)

1. Summarize choices in plain language and ask them to confirm.
2. On confirm (or "wrap up with defaults"), write the artifacts (Write steps below).
3. Tell them they can run `/learning-opportunities-setup refine` later after hits and misses — do not re-run full setup just to tweak.

When writing, use [resources/example-minimal.md](resources/example-minimal.md) and [resources/example-richer.md](resources/example-richer.md) as shape references (minimal vs richer). Prefer minimal shape for quick path; richer only when they chose those knobs.

---

## Write steps (setup)

### Step 1: Write the override block

Write (or append) a `## Learning Opportunities` section to the path chosen as primary.

Rules:
- Use the user's name or "the user" consistently with how their instruction files already refer to them
- Include only knobs they chose (or quick-path defaults); do not pad with unused options
- Do **not** add a preferred-exercise-style bias unless they opted in at B1
- Keep comments short; say the *why* when a choice is non-default
- If the target file already has a Learning Opportunities section, update it in place rather than duplicating
- Show them the final block in the chat as well as writing the file

Shape the section from [resources/override-template.md](resources/override-template.md), deleting unused bullets.

### Step 2: Optional stub files

Only create files they asked for in D.

- Daily-note `## Learning` section: do **not** create a dated daily note unless they explicitly ask and give a path/date. Prefer telling them the section heading to use.
- Weekly log / history stubs: create from [resources/log-stubs.md](resources/log-stubs.md) at the paths they chose. Do not overwrite non-empty log files; append a header comment only if missing.

### Step 3: Confirm to the user

Tell them:
- Where overrides were written
- Which stub files (if any) were created
- How to use next: keep coding; accept or decline exercise offers from `learning-opportunities`
- Optional next installs: `learning-opportunities-auto`, `orient`, [learning-goal](https://github.com/DrCatHicks/learning-goal)
- That after experimenting, they should prefer `/learning-opportunities-setup refine` over re-running full setup
- Optional multi-tool copy (once), if relevant

Include a 3–5 line how-to reminder they can keep next to the overrides.

---

# Refine path

Use when `$ARGUMENTS` is `refine`. Consult [resources/refine-prompts.md](resources/refine-prompts.md) for the question bank and patch rules.

This path is **episode-based**: tune from recent hits and misses. Do **not** re-ask the full A–E setup questionnaire. Do **not** recreate log stubs unless they ask to add logging they did not have.

## Refine Step 0: Locate overrides

Find an existing `## Learning Opportunities` section:

1. Check common paths relative to the project and user instructions (`CLAUDE.local.md`, `CLAUDE.md`, `AGENTS.md`, Cursor rules if known, memory files the user points to).
2. If not found, ask which file holds their overrides.
3. If none exist, stop and offer to run full setup instead (`/learning-opportunities-setup` with no argument). Do not invent a block.

## Refine Step 1: Summarize and confirm mode

In one short block, summarize the current knobs. Ask once: ready to tune from recent experience? (escape: wrap up / cancel)

## Refine Step 2: Hit/miss interview

Ask **ONE** question per turn. Prefer concrete recent experience over abstract style. Cover only areas that seem relevant; skip what they say is fine. Suggested order (from refine-prompts.md):

- **R1.** Offers: too often / too rare / wrong moments?
- **R2.** Which exercise *types* helped vs felt like a miss?
- **R3.** Scaffolding: too guided / too loose?
- **R4.** Session notes: actually using them? drop, keep, or change destination?
- **R5.** Sticky/domain prompts: still useful, stale, or missing?
- **R6.** Cap / decline behavior / auto-hook hard stop / questions-only-when-stopped: any friction?

Stop early if they say that's enough.

## Refine Step 3: Propose diff and patch

1. Show a clear **diff** (or before/after) of the `## Learning Opportunities` section only.
2. Ask them to confirm.
3. On confirm, **patch in place** — update the existing section; never duplicate it; never rewrite unrelated file content.
4. Do not recreate log stubs unless they explicitly asked to add new logging paths.

## Refine Step 4: Confirm

Tell them what changed, where, and that they can run refine again anytime (or full setup only if starting over).
