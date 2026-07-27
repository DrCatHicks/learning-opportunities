# Override template

Copy structure; delete bullets the user did not choose. Replace bracketed placeholders.

```markdown
## Learning Opportunities

Use the `learning-opportunities` skill. Personal overrides:

- **Offer** after significant work (new files, schema/architecture, unfamiliar patterns, or "why" questions). Do not wait to be asked.
- **Cap:** at most 2 exercises per session. If declined, do not offer again that session.
- **Hook hard stop:** if `[learning-opportunities-auto]` appears in a PostToolUse result, the offer must be the next thing you say — no continuing the task first.
- **Questions only when stopped:** recall/quiz/exercise questions must be the last line of a stopped turn (no more tool calls after). Never bury a question under ongoing processing.
- **Background:** [language/area A] is newer (first principles); [language/area B] is stronger. Fade scaffolding as they navigate independently; tighten it when they struggle.
- **Preferred exercise style:** [e.g. walk-through / mental-model-building / predict-then-check]. Prefer [trace execution paths / teach-it-back / …]. Avoid [trivia / abstract toys / …].
- **Topic selection:** Tie exercises to the current work session. Avoid abstract or disconnected examples.
- **Session-start check-in** (once, optional): one brief recall question with an escape hatch on returning [harder domain] work.
- **Domain recall prompts** (when relevant): [2–4 sticky concepts].

### Session notes + weekly log

- After a **completed** exercise or mid-session concept explanation, add a short note under `## Learning` in [daily note path / other destination].
- After a **declined** exercise: [never log / ask once whether to add a note / always log a one-liner topic].
- After completed exercises / named gaps: append one line to `[path]/learning_this_week.md`. Do not read that file during sessions (write-only until a scheduled retrieval pass).
```
