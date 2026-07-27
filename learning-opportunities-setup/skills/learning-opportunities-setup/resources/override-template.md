# Override template

Copy structure; delete bullets the user did not choose. Replace bracketed placeholders. See [example-minimal.md](example-minimal.md) and [example-richer.md](example-richer.md) for filled shapes.

```markdown
## Learning Opportunities

Use the `learning-opportunities` skill. Personal overrides:

- **Offer** after significant work (new files, schema/architecture, unfamiliar patterns, or "why" questions). Do not wait to be asked.
- **Cap:** at most 2 exercises per session. If declined, do not offer again that session.
- **Hook hard stop:** if `[learning-opportunities-auto]` appears in a PostToolUse result, the offer must be the next thing you say — no continuing the task first.
- **Questions only when stopped:** recall/quiz/exercise questions must be the last line of a stopped turn (no more tool calls after). Never bury a question under ongoing processing.
- **Background:** [language/area A] is newer (first principles); [language/area B] is stronger. On this codebase they are mostly [orienting / contributing / owning] — [scaffolding implication].
- **Preferred exercise style:** [only if they opted in at B1 — list chosen styles]. Prefer […]. Avoid […].
- **Interaction prefs:** [only what they volunteered — e.g. plain-language restate, no quiz vibe].
- **Topic selection:** Tie exercises to the current work session. Avoid abstract or disconnected examples.
- **Session-start check-in** (once, optional): one brief recall question with an escape hatch on returning [harder domain] work.
- **Domain recall prompts** (when relevant): [only concepts they named].

### Session notes + weekly log

- After a **completed** exercise or mid-session concept explanation, add a short note under `## Learning` in [daily note path / journal destination].
- After a **declined** exercise: [never log / ask once whether to add a note / always log a one-liner topic].
- After completed exercises / named gaps: append one line to `[path]/learning_this_week.md`. Do not read that file during sessions (write-only until [their review cadence]).
- [Optional archive:] After each retrieval pass, move cleared weekly bullets to `[path]/learning_history.md`.
```

Omit the entire session-notes subsection when storage is **none**. When storage is **both**, keep daily and rolling-log bullets together.
