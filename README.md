# Learning Opportunities: A Claude Code Skill for Deliberate Skill Development

**Build your expertise, not just your projects.**

This skill uses an adaptive "dynamic textbook" approach to help you integrate science-based expertise building exercises while doing agentic coding.

When you complete architectural work (new files, schema changes, refactors), Claude offers optional 10-15 minute learning exercises grounded in evidence-based learning science. The exercises use techniques like prediction, generation, retrieval practice, and spaced repetition to provide you with semi-worked examples from across your own project work.

## Why You Might Want to Experiment with This Skill

AI coding tools can create a specific risks for decreasing users' engagement in learning, and introducing inefficient learning habits:

1. **Generation effect undermined:** Accepting generated code skips the active processing that builds understanding
2. **Fluency illusion amplified:** Clean generated code feels understood even when it isn't
3. **Spacing effect eliminated:** Machine velocity pushes toward constant cramming
4. **Metacognition suppressed:** Fast workflows don't leave room to monitor learning and develop schema representation
5. **Testing and retrieval underused** Fewer opportunities to benefit from testing

The techniques in SKILL.md are designed to counteract these specific risks by reintroducing:
- Active generation (predictions, explanations, sketches)
- Retrieval practice (check-ins, teach-it-back, self-testing)
- Deliberate pauses (spacing, reflection)
- Explicit metacognition (self-assessment, gap identification)

This skill interrupts that pattern by reminding you to consider investing in reflection and learning. 

## Installation

See [Claude Code's skill installation guide](https://code.claude.com/docs/en/skills) for how to add skills to your setup.

## How It Works

After you complete significant work (which you can self-define, but I've suggested: creating new files or modules, database schema changes, architectural decisions or refactors, implementing unfamiliar patterns, any work where the user asked "why" questions during development) Claude will ask:

> "Would you like to do a quick learning exercise on [topic]? About 10-15 minutes."

If you accept, Claude runs you through an interactive exercise. A key design principle: **Claude pauses and waits for your input** rather than answering its own questions. This pushes against Claude's default to always provide the full answer and encourages your own mental effort and learning. 

### Exercise Types

- **Prediction → Observation → Reflection**: What do you expect to happen? Now let's see. What surprised you?
- **Generation → Comparison**: Sketch how you'd approach this before seeing the implementation
- **Trace the path**: Walk through execution step by step, predicting each transition
- **Debug this**: What would go wrong here, and why?
- **Teach it back**: Explain this component as if onboarding a new developer
- **Retrieval check-in**: At the start of a session, what do you remember from last time?

### When It Stays Quiet

It backs off when:
- You've already declined an exercise this session
- You've completed 2 exercises this session

## The Science Behind It

The exercises draw from well-established findings in learning science:

| Principle | What it means | How the skill applies it |
|-----------|---------------|--------------------------|
| **Testing effect** | Retrieval strengthens memory more than re-studying | Prediction and generation exercises |
| **Generation effect** | Producing information beats passively receiving it | "How would you approach this?" before showing solutions |
| **Desirable difficulties** | Harder learning = more durable learning | Exercises require effort; Claude doesn't simplify when you struggle |
| **Spacing effect** | Distributed practice beats cramming | Retrieval check-ins across sessions |
| **Worked example effect** | Novices benefit from studying solutions; experts benefit from problem-solving | Fading scaffolding based on demonstrated competence |

See [PRINCIPLES.md](PRINCIPLES.md) for detailed explanations which can help you refine this skill to your .

## Customization

This skill can be refined and adapted. You might want to:

- Include information about your own technical expertise and existing knowledge (e.g. known languages, learning goals)
- Adjust trigger conditions for your workflow
- Add project-specific examples to the exercises
- Change the soft cap on exercises per session
- Add domain-specific retrieval check-in questions
- Explore iteration and adding evaluation checks to how successfully this skill is fulfilling its instructions

The skill lives in your `~/.claude/skills/` directory—edit SKILL.md directly and restart Claude Code to see changes.

## Evaluating the Skill

The repo includes a suggested [EVALUATIONS.md](EVALUATIONS.md) with test scenarios:

1. Does it trigger after architectural work?
2. Does it recognize curiosity signals ("why did you...")?
3. Does it exit gracefully when you need to ship?
4. Does it actually pause for input?
5. Does it respect your decline?

Running through evaluation scenarios periodically can help you modify the skill, or encourage Claude to iterate the skill based on your experience with the learning opportunities.

## Background

This skill was developed based on my own learning science background and informed by multiple qualitative interviews with software development professionals about their concerns around agentic coding, as part of my open science empirical evidence about developer thriving and skill development in AI-assisted workflows. [In my research](https://osf.io/preprints/psyarxiv/2gej5_v2), I've found that a strong value and commitment to learning predicts that developers feel less threat, worry and anxiety when imagining needing to adjust to agentic coding.

I'd love to know if you enjoy this! 

## Author

**Dr. Cat Hicks**  
I'm a psychological scientist studying software teams and technology work, an author, a public speaker, a research architect, and an empirical interventionist who builds radical research teams that put answers behind questions everyone is asking but few people are gathering real evidence about.

- Website: [drcathicks.com](https://drcathicks.com)
- Software Team & Eng Leadership Consulting: [catharsisinsight.com](https://www.catharsisinsight.com/)
- Newsletter: [Fight for the Human](https://fightforthehuman.com)
- Upcoming Book: *Fight for the Human: Psychology for Software Teams* (2026)

## Sources

- Bjork, R. A., Dunlosky, J., & Kornell, N. (2013). Self-regulated learning: Beliefs, techniques, and illusions. Annual review of psychology, 64(1), 417-444. 
- Dunlosky, J., Rawson, K. A., Marsh, E. J., Nathan, M. J., & Willingham, D. T. (2013). Improving students’ learning with effective learning techniques: Promising directions from cognitive and educational psychology. Psychological Science in the Public interest, 14(1), 4-58.
- Ericsson, K. A., Hoffman, R. R., & Kozbelt, A. (Eds.). (2018). The Cambridge handbook of expertise and expert performance. Cambridge University Press.
- Giebl, S., Mena, S., Storm, B. C., Bjork, E. L., & Bjork, R. A. (2021). Answer first or Google first? Using the Internet in ways that enhance, not impair, one’s subsequent retention of needed information. Psychology Learning & Teaching, 20(1), 58-75.
- Hicks, C. M., Lee, C. S., & Foster-Marks, K. (2025, March 15). The New Developer: AI Skill Threat, Identity Change & Developer Thriving in the Transition to AI-Assisted Software Development. https://doi.org/10.31234/osf.io/2gej5_v2
- Kalyuga, S. (2007). Expertise reversal effect and its implications for learner-tailored instruction. Educational psychology review, 19(4), 509-539.
- Kang, S. H. (2016). Spaced repetition promotes efficient and effective learning: Policy implications for instruction. Policy Insights from the Behavioral and Brain Sciences, 3(1), 12-19.
- Kornell, N. (2009). Optimising learning using flashcards: Spacing is more effective than cramming. Applied Cognitive Psychology: The Official Journal of the Society for Applied Research in Memory and Cognition, 23(9), 1297-1317.
- Murphy, D. H., Little, J. L., & Bjork, E. L. (2023). The value of using tests in education as tools for learning—not just for assessment. Educational Psychology Review, 35(3), 89.
- Roediger III, H. L., & Karpicke, J. D. (2006). The power of testing memory: Basic research and implications for educational practice. Perspectives on psychological science, 1(3), 181-210.
- Rohrer, D., & Taylor, K. (2007). The shuffling of mathematics problems improves learning. Instructional Science, 35(6), 481-498.
- Skulmowski, A., & Xu, K. M. (2022). Understanding cognitive load in digital and online learning: A new perspective on extraneous cognitive load. Educational psychology review, 34(1), 171-196.
- Soderstrom, N. C., & Bjork, R. A. (2015). Learning versus performance: An integrative review. Perspectives on Psychological Science, 10(2), 176-199.
- Sweller, J., & Cooper, G. A. (1985). The use of worked examples as a substitute for problem solving in learning algebra. Cognition and instruction, 2(1), 59-89.
- Tankelevitch, L., Kewenig, V., Simkute, A., Scott, A. E., Sarkar, A., Sellen, A., & Rintel, S. (2024, May). The metacognitive demands and opportunities of generative AI. In Proceedings of the 2024 CHI Conference on Human Factors in Computing Systems (pp. 1-24).
- Hicks, C. (2025). Cognitive helmets for the AI bicycle: Part 1. *Fight for the Human*. https://www.fightforthehuman.com/cognitive-helmets-for-the-ai-bicycle-part-1/
