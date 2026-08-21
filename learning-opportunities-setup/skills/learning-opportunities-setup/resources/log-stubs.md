# Log stubs

Create these only when the user opted into written trails. Do not overwrite non-empty files. Be tool-agnostic — use the paths they gave.

## Daily note section

Tell the user to use this heading in their existing daily note or journal (do not invent a dated file unless they give an exact path):

```markdown
## Learning

- [concept] — [what clicked or where the gap was]
```

## Rolling weekly log

Suggested filename: `learning_this_week.md` (or the name they chose)

```markdown
# Learning log

<!-- Format: - YYYY-MM-DD: [concept] — [what was understood or where the gap was] -->
<!-- Only log entries where active learning happened — not every topic mentioned -->
<!-- Write during sessions; read on a scheduled retrieval pass if they opted in. -->
```

## Archive history (full path only)

Suggested filename: `learning_history.md`

```markdown
# Learning history

<!-- Append-only. Never clear this file. -->
<!-- Move cleared weekly-log bullets here after each retrieval pass. -->
<!-- Format:
## Week of YYYY-MM-DD
- YYYY-MM-DD: [concept] — [what was understood or where the gap was]
-->
```
