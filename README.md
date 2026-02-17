# Learning Opportunities: A Claude Code Skill for Deliberate Skill Development

**Build your expertise, not just your projects.**

This skill uses an adaptive "dynamic textbook" approach to help you integrate science-based expertise building exercises while doing agentic coding.

When you complete architectural work (new files, schema changes, refactors), Claude offers optional 10-15 minute learning exercises grounded in evidence-based learning science. The exercises use techniques like prediction, generation, retrieval practice, and spaced repetition to provide you with semi-worked examples from across your own project work.

## Why You Might Want to Experiment with This Skill

AI coding tools can create specific risks for decreasing users' engagement in learning by introducing inefficient learning habits. These effects can be anticipated based on several foundational science-backed learning principles:

1. **Generation effect:** Accepting generated code and decreasing generating one's own code can skip the active processing that builds understanding. 
2. **Fluency illusion:** Clean generated code can be perceived as more understood than it truly is; likewise, easily accessible knowledge from search can promote the illusion of knowledge and the illusion of more complete mental models.
3. **Spacing effect:** Machine velocity can push users toward constant cramming and long production sessions without the cadence, reflection and spacing of learning that leads to longer-term retention.
4. **Metacognition:** Fast workflows often don't leave room to monitor learning and develop schema representation as well as a user's sense of their own level of relative expertise and knowledge when working with novel technology.
5. **Testing and retrieval:** Agentic models push toward giving complete answers, which could result in users taking fewer opportunities to benefit from self-testing and retrieving specific components of new knowledge, which strengthens retention.

The techniques in SKILL.md are designed to counteract these risks by reintroducing:
- Active generation (predictions, explanations, sketches)
- Retrieval practice (check-ins, teach-it-back, self-testing)
- Deliberate pauses (spacing, reflection)
- Explicit metacognition (self-assessment, gap identification)

This skill interrupts that pattern by reminding you to consider investing in reflection and learning. It introduces a different "mode" of interacting with Claude, which will intentionally feel different than highly fluent and fast agentic coding in the service of helping you reflect and explore your generated work. This skill may be particularly useful for users who are experimenting with developing discrete projects with agentic coding that involve multiple unfamiliar languages, techniques, or architectural patterns. 

## Installation

See [Claude Code's skill installation guide](https://code.claude.com/docs/en/skills) for how to add skills to your setup.

## How It Works

After you complete significant work (which you can self-define, but I've suggested: creating new files or modules, database schema changes, architectural decisions or refactors, implementing unfamiliar patterns, any work where the user asked "why" questions during development. The key idea is to find a moment in your personal flow where a learning opportunity is most beneficial) Claude will ask:

> "Would you like to do a quick learning exercise on [topic]? About 10-15 minutes."

If you accept, Claude runs you through an interactive exercise. A key design principle: **Claude pauses and waits for your input** rather than answering its own questions. This can feel frustrating, but this pushes against Claude's default to always provide the full answer and encourages your own mental effort and learning. You may encounter and need to design against Claude's defaults to provide the complete answer; please feel free let me know if you find gotchas or conflicts in your own workflow that you think will generalize to others so that I can incorporate in the Skill to improve this (e.g., I learned we needed to suppress prompt suggestions).

### Exercise Types

- **Prediction → Observation → Reflection**: What do you expect to happen? Now let's see. What surprised you?
- **Generation → Comparison**: Sketch how you'd approach this before seeing the implementation
- **Trace the path**: Walk through execution step by step, predicting each transition
- **Debug this**: What would go wrong here, and why?
- **Teach it back**: Explain this component as if onboarding a new developer
- **Retrieval check-in**: At the start of a session, what do you remember from last time?

### Will Not Suggest Learning Opportunities When...

Two suppression conditions are currently suggested which can be adapted to your workflow needs. 
Claude will not prompt learning opportunities when:
- You've already declined an exercise this session
- You've completed 2 exercises this session

## The Science Behind It & Resources

The exercises draw from well-established findings in learning science, along with substantive research on typical learner misconceptions. Design choices also draw from multiple qualitative interviews with developers about what aspects of rapid agentic coding they find most frustrating, worrisome, or difficult when it comes to their own learning and development.

See PRINCIPLES.md for detailed explanations which can help you develop new exercise types or simply learn more about strategies to help your own learning.

## NEW: Measure This, A Lightweight Playbook for Making A Team Experiment Visible

If you're trying this skill with your team, you can layer on a lightweight pre/post measurement to make the experiment more visible and valued in your organization. 

[**MEASURE-THIS.md**](agent-learning%20opportunities/resources/MEASURE-THIS.md) is a companion playbook that includes:

- **A curated set of validated survey items** from our peer-reviewed research on developer thriving and AI skill threat, ready to copy into a Google Form or team channel
- **Guidance on what to do (and not do) with your results** including why variance matters as much as averages, and some guardrails on how I think about these types of measures
- **A "team boast" template** a fill-in-the-blank paragraph for packaging your experiment into an email to leadership, grounded in real research
- **Claude.md nudges for statistical rigor** if you want to use Claude for more complex analysis, these nudges help guard against common AI-assisted statistical mistakes

The measures are free and open access under a CC-BY-SA 4.0 license. For the full set of measures and design notes, see [the AI Skill Threat open access measures supplement](https://osf.io/preprints/psyarxiv/2gej5) and [the Developer Thriving open access measures supplement](https://ieeexplore.ieee.org/ielx7/52/10547603/10491133/supp1-3382957.pdf?arnumber=10491133).

## Customization

This skill can be significantly refined and adapted. You might want to:

- Include information about your own technical expertise and existing knowledge to start the exercises at the right level (e.g. known languages, learning goals)
- Prompt Claude to include insights from the learning opportunities into your project Claude.md 
- Adjust trigger conditions for your workflow
- Add project-specific examples to the exercises
- Change the soft cap on exercises per session
- Add domain-specific retrieval check-in questions
- Explore adding evaluation checks to assess how successfully this skill is fulfilling its instructions

## Background

This skill was developed based on learning science and informed by multiple qualitative interviews with software development professionals about their concerns around agentic coding, as part of my open science empirical evidence about developer thriving and skill development in AI-assisted workflows. [In my research with thousands of developers](https://osf.io/preprints/psyarxiv/2gej5_v2), I've also found that a strong value and commitment to learning predicts that developers feel less threat, worry and anxiety when imagining needing to adjust to agentic coding. Learning culture also associates with increases in team effectiveness overall, not just individual productivity. 

I'd love to know if you enjoy this and what you learn! Sharing open science resources helps researchers like me create more things to help software teams. I always appreciate a shout-out or a share in public, which helps more people learn about the psychology of software teams. Get updates and access to more of the psychology of software teams at my newsletter: [Fight for the Human](https://www.fightforthehuman.com/)

## Author

**Dr. Cat Hicks**  
I'm a psychological scientist studying software teams and technology work, an author, a public speaker, a research architect, and an empirical interventionist who builds radical research teams that put answers behind questions everyone is asking but few people are gathering real evidence about.

- Website: [drcathicks.com](https://drcathicks.com)
- Software Team & Eng Leadership Consulting: [catharsisinsight.com](https://www.catharsisinsight.com/)
- Upcoming Book: *The Psychology of Software Teams* (2026)

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

## License

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

This work is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
