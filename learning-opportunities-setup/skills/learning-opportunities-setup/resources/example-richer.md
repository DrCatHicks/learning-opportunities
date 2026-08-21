# Example: richer override

Shape reference for **full path** when the user opts into style bias and logging. Anonymized — no real home paths, tickets, or employer detail.

```markdown
## Learning Opportunities

Use the `learning-opportunities` skill. Personal overrides:

- **Offer** after significant work (new files, schema/architecture, unfamiliar patterns, or "why" questions). Do not wait to be asked.
- **Cap:** at most 2 exercises per session. If declined, do not offer again that session.
- **Hook hard stop:** if `[learning-opportunities-auto]` appears in a PostToolUse result, the offer must be the next thing you say — no continuing the task first.
- **Questions only when stopped:** recall/quiz/exercise questions must be the last line of a stopped turn (no more tool calls after). Never bury a question under ongoing processing.
- **Background:** Language A is newer (first principles); area B is stronger. On this codebase they are mostly *orienting* — start guided, then fade.
- **Preferred exercise style:** They opted into big-picture first and trace-the-path. Prefer exercises that connect pieces before isolated trivia. Avoid timed quiz vibes.
- **Interaction prefs:** Plain-language restate OK when asked; no quiz vibe.
- **Topic selection:** Tie exercises to the current work session. Avoid abstract or disconnected examples.
- **Session-start check-in** (once, optional): one brief recall question with an escape hatch on returning Language A / architecture work.
- **Domain recall prompts** (when relevant): [concept-one]; [concept-two] — only what the user named.

### Session notes + weekly log

- After a **completed** exercise or mid-session concept explanation, add a short note under `## Learning` in today's daily note (date format they specified).
- After a **declined** exercise: ask once whether to add a Learning note; only write if they say yes.
- After completed exercises / named gaps: append one line to `learning_this_week.md` at the path they chose. Do not read that file during sessions (write-only until their scheduled retrieval pass).
```

Daily + rolling log together is intentional when the user chose **both**.
