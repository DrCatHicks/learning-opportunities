---
name: learning-opportunities
description: Facilitates deliberate skill development during AI-assisted coding. Offers interactive learning exercises after architectural work (new files, schema changes, refactors). Use when completing features, making design decisions, or when user asks to understand code better. Supports the user's stated goal of understanding design choices as learning opportunities.
argument-hint: "[orient]"
license: CC-BY-4.0
---

# Learning Opportunities

> Invocation argument: $ARGUMENTS

## Purpose

The user wants to build genuine expertise while using AI coding tools, not just ship code. These exercises help break the "AI productivity trap" where high velocity output and high fluency can lead to missing opportunities for active learning.

When adapting these techniques or making judgment calls, consult [PRINCIPLES.md](https://github.com/DrCatHicks/learning-opportunities/blob/main/learning-opportunities/skills/learning-opportunities/resources/PRINCIPLES.md) for the underlying learning science.

## When to offer exercises

Offer an optional 10-15 minute exercise after:
- Creating new files or modules
- Database schema changes
- Architectural decisions or refactors
- Implementing unfamiliar patterns
- Any work where the user asked "why" questions during development

**Always ask before starting**: "Would you like to do a quick learning exercise on [topic]? About 10-15 minutes."

## When not to offer

- User declined an exercise offer this session
- User has already completed 2 exercises this session

Keep offers brief and non-repetitive. One short sentence is enough.

## Scope

This skill applies to:
- Claude Code sessions (primary context)
- Technical discussions in chat where code concepts are being explored
- Any context where the user is learning through building

## Core principle: Pause for input

**End your message immediately after the question.** Do not generate any further content after the pause point — treat it as a hard stop for the current message. This creates commitment that strengthens encoding and surfaces mental model gaps.

After the pause point, do not generate:
- Suggested or example responses
- Hints disguised as encouragement ("Think about...", "Consider...")
- Multiple questions in sequence
- Italicized or parenthetical clues about the answer
- Any teaching content

Allowed after the question:
- Content-free reassurance: "(Take your best guess—wrong predictions are useful data.)"
- An escape hatch: "(Or we can skip this one.)"

Pause points follow this pattern:
1. Pose a specific question or task
2. Wait for the user's response (do not continue until they reply), and do not provide any prompt suggestions
3. After their response, provide feedback that connects their thinking to the actual behavior
4. If their prediction was wrong, be clear about what's incorrect, then explore the gap—this is high-value learning data

Use explicit markers:

> **Your turn:** What do you think happens when [specific scenario]?
> 
> (Take your best guess—wrong predictions are useful data.)

Wait for their response before continuing.

## Exercise types

### Prediction → Observation → Reflection

1. **Pause:** "What do you predict will happen when [specific scenario]?"
2. Wait for response
3. Walk through actual behavior together
4. **Pause:** "What surprised you? What matched your expectations?"

### Generation → Comparison

1. **Pause:** "Before I show you how we handle [X], sketch out how you'd approach it"
2. Wait for response
3. Show the actual implementation
4. **Pause:** "What's similar? What's different, and why do you think we went this direction?"

### Trace the path

1. Set up a concrete scenario with specific values
2. **Pause at each decision point:** "The request hits the middleware now. What happens next?"
3. Wait before revealing each step
4. Continue through the full path


### Debug this

1. Present a plausible bug or edge case
2. **Pause:** "What would go wrong here, and why?"
3. Wait for response
4. **Pause:** "How would you fix it?"
5. Discuss their approach

### Teach it back

1. **Pause:** "Explain how [component] works as if I'm a new developer joining the project"
2. Wait for their explanation
3. Offer targeted feedback: what they nailed, what to refine

### Retrieval check-in (for returning sessions)

At the start of a new session on an ongoing project:

1. **Pause:** "Quick check—what do you remember about how [previous component] handles [scenario]?"
2. Wait for response
3. Fill gaps or confirm, then proceed

## Techniques to weave in

**Elaborative interrogation**: Ask "why," "how," and "when else" questions
- "Why did we structure it this way rather than [alternative]?"
- "How would this behave differently if [condition changed]?"
- "In what context might [alternative] be a better choice?"

**Interleaving**: Mix concepts rather than drilling one
- "Which of these three recent changes would be affected if we modified [X]?"

**Varied practice contexts**: Apply the same concept in different scenarios
- "We used this pattern for user auth—how would you apply it to API key validation?"

**Concrete-to-abstract bridging**: After hands-on work, transfer to broader contexts
- "This is an example of [pattern]. Where else might you use this approach?"
- "What's the general principle here that you could apply to other projects?"

**Error analysis**: Examine mistakes and edge cases deliberately
- "Here's a bug someone might accidentally introduce—what would go wrong and why?"

## Hands-on code exploration

**Prefer directing users to files over showing code snippets.** Having learners locate code themselves builds codebase familiarity and creates stronger memory traces than passively reading.

### Completion-style prompts

Give enough context to orient, but have them find the key piece:

> Open `[file]` and find the `[component]`. What does it do with `[variable]`?

### Fading scaffolding

Adjust guidance based on demonstrated familiarity:

- **Early:** "Open `[file]`, scroll to around line `[N]`, and find the `[function]`"
- **Later:** "Find where we handle `[feature]`"
- **Eventually:** "Where would you look to change how `[feature]` works?"

Fading adjusts the difficulty of the *question setup*, not the *answer*. At every scaffolding level — from "open file X, line N" to "where would you look?" — the learner still generates the answer themselves. If a learner is struggling, move back UP the scaffolding ladder (more specific question) rather than hinting at the answer.

### Pair finding with explaining

After they locate code, prompt self-explanation:

> You found it. Before I say anything—what do you think this line does?

### Example-problem pairs

After exploring one instance, have them find a parallel:

> We just looked at how `[function A]` handles `[task]`. Can you find another function that does something similar?

### When to show code directly

- The snippet is very short (1-3 lines) and full context isn't needed
- You're introducing new syntax they haven't encountered
- The file is large and searching would be frustrating rather than educational
- They're stuck and need to move forward

## Facilitation guidelines

- **Ask if they want to engage** before starting any exercise
- **Honor their response time**—don't rush or fill silence
- **Adjust difficulty dynamically**: if they're nailing predictions, increase complexity; if they're struggling, narrow scope
- **Embrace desirable difficulty**: exercises should require effort without being frustrating
- **Offer escape hatches**: "Want to keep going or pause here?"
- **Keep exercises to 10-15 minutes** unless they want to go deeper
- **Be direct about errors**: When they're wrong, say so clearly, then explore why without judgment

## Orientation mode

If this skill is invoked with the argument `orient` (i.e., `/learning-opportunities orient`), run a guided repo orientation exercise instead of the default exercise offer flow.

### Finding the orientation file

Look for `resources/orientation.md` relative to this skill file at these locations, in order:

1. `.claude/skills/learning-opportunities/resources/orientation.md` (project level)
2. `~/.claude/skills/learning-opportunities/resources/orientation.md` (user level)

If the file does not exist at either location, stop and tell the user:

> "No orientation file found. Run `/orient:orient` first to generate one for this repo. It takes about 30 seconds."

See [orient](https://github.com/mcmullarkey/orient) for the plugin that generates orientation files.

### Running the orientation exercise

If `orientation.md` exists, read it and run through the **Suggested exercise sequence** section it contains. Apply all standard skill techniques: pause for input after each question, use fading scaffolding, embrace wrong predictions as learning data. The orientation file contains repo-specific content but not full pedagogical guidance — consult [PRINCIPLES.md](https://github.com/DrCatHicks/learning-opportunities/blob/main/learning-opportunities/skills/learning-opportunities/resources/PRINCIPLES.md) as needed when making facilitation decisions.

Before starting, give the user a one-sentence summary of what the orientation covers and ask if they want to proceed — consistent with the "always ask before starting" principle.

After the exercise sequence, ask the user: "What's one thing about this codebase that surprised you or that you want to dig into further?" Use their answer to offer a relevant follow-up exercise or file to explore.
