# Refine prompts

Hit/miss question bank and patch rules for `/learning-opportunities-setup refine`. Load when facilitating refine mode.

## Goals

- Tune from **recent experience**, not a second full questionnaire
- **Patch** the existing `## Learning Opportunities` section in place
- Preserve what still works; change only what they say is off

## Question bank (one per turn)

Skip any the user says is already fine. Prefer concrete episodes ("last week when…") over abstractions.

| ID | Ask | If they say… | Typical patch |
| --- | --- | --- | --- |
| R1 | Offers: too often, too rare, or wrong moments? | Too often | Raise bar for "significant work"; lower cap; or switch toward ask-only |
| | | Too rare | Auto-offer after significant work; ensure hook hard stop if they use auto |
| | | Wrong moments | Narrow or restate triggers; avoid offering mid-debug if they say so |
| R2 | Which exercise *types* helped vs felt like a miss? | Names helpers | Add/prefer those under preferred exercise style |
| | | Names misses | Add avoid list; keep core mix for the rest — do not delete the whole mix unless they ask |
| R3 | Scaffolding: too guided or too loose? | Too guided | Fade faster; prefer find-the-file over line numbers |
| | | Too loose | More guided paths; show paths vs hunt |
| R4 | Session notes: using them? drop, keep, or change destination? | Drop | Remove session-notes bullets |
| | | Change path | Update paths only |
| | | Not using but want to | Keep or simplify; do not create stubs unless they ask |
| R5 | Sticky/domain prompts: still useful, stale, or missing? | Stale | Remove or replace with what they name |
| | | Missing | Add only what they name — no invented project defaults |
| R6 | Cap, decline behavior, auto-hook hard stop, or questions-only-when-stopped: any friction? | Specific friction | Patch that knob only |

Escape anytime: "That's enough" → go to propose diff.

## Patch rules

1. **Read first** — never patch a section you have not loaded.
2. **Diff then confirm** — show before/after (or a unified diff of the section) and wait for yes.
3. **In place only** — replace the existing `## Learning Opportunities` section; do not append a second copy.
4. **Minimal edits** — change bullets they spoke to; leave the rest.
5. **No style bias inventing** — only add preferred-style lines if R2 (or clear prior override) supports it.
6. **No stub recreation** — do not create or wipe log files unless they explicitly ask to add a new log path.
7. **No full-setup restart** — if they need a greenfield rewrite, tell them to run `/learning-opportunities-setup` without `refine`.
8. **Secrets** — never copy customer data, keys, or private paths they did not ask to store into the override block.

## After patch

Confirm path + what changed in one short list. Remind them refine can run again anytime.
