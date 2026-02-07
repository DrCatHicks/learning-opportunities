# Learning Principles

This document provides the scientific rationale for the techniques in SKILL.md. Consult it when adapting techniques or making judgment calls about learning approaches.

## Core insight: We're often wrong about what helps us learn

Misconceptions about learning are common and predict long-term performance differences between efficient and inefficient learning approaches. Our minds can confuse the *experience of effort* with *actual learning*. Also, our minds can confuse the *experience of fluency* with *actual knowledge*. Strategies that learners assume are productive because they feel high effort often aren't, whereas study strategies that feel easy to learners can often work better than we expect. At the same time, productive struggle is more productive than we realize, and learners need to encounter mistakes and feedback to progress. 

Focusing on long-term learning outcomes, rather than short-term performance, helps learners.

---

## The Generation Effect & The Power of Testing 

**Finding:** Users encode information better when they produce it rather than passively consume it. Testing produces better delayed retention than passive consumption and passive review, even when immediate performance is worse.

**Mechanism:** Active retrieval strengthens memory traces in ways that passive review does not. The mind learns more accurately and deeply with hands-on engagement. Testing promotes strong positive effects on long-term retention.

**In practice:** Having learners generate predictions, explanations, or solutions—even wrong ones—produces better learning than showing them the answer first.

**Risk in AI-assisted work:** Becoming a passive recipient of generated solutions. If a user only reads and accepts output, they skip the generative processing that builds understanding.

**Application:** Prediction exercises, generation-before-instruction, teach-it-back prompts, having users sketch solutions before revealing implementations.

---

## Pre-testing (Potentiating a Learning Session)

**Finding:** Attempting to figure out an answer *before* learning new information produces stronger memory and deeper understanding for that new information—even when the pre-learning attempt was wrong.

**Mechanism:** Pre-testing directs attention to knowledge gaps and primes the mind to encode incoming information more effectively. A failed attempt makes the correct answer more memorable by contrast.

**Key research:** Giebl et al. found that novice programmers who attempted problems with incomplete information before searching performed better than those who searched immediately, even though the pretesting group was unable to solve the problem.

**Application:** Ask "what do you predict will happen" before tracing code. Ask "how would you approach this" before showing implementations. Interweave testing questions with revealing new information and concepts. Wrong predictions are valuable data, not failures.

---

## The Spacing Effect

**Finding:** Distributing learning over time produces better retention than massing it into a single session.

**Mechanism:** Spaced retrieval requires the brain to reconstruct knowledge repeatedly, strengthening long-term memory. Massed practice (cramming) creates fluency with short-term effects that fade quickly.

**Learner Misconception:** Spacing feels easier than cramming, so people rarely believe it works better. In studies, spacing produces better performance more effective for the majority of participants, yet most believe massing had been more effective.

**Risk in AI-assisted work:** Machine velocity and ease of AI generation can push a user into constant "cram"—completing work in singular large pushes rather than repeatedly returning to tasks with interruption.

**Application:** Retrieval check-ins at the start of sessions. Return to the same learning area at multiple times during a project. Build small and targeted reflection moments into workflows.

---

## The Worked Example Effect

**Finding:** Studying worked examples, complete solutions with some of the steps shown, produces better initial learning than problem-solving practice, particularly for novices. This effect can reverse for experts, where the shown steps are redundant information.

**Mechanism:** Problem-solving imposes high cognitive load because learners must simultaneously search for a solution strategy and learn the underlying concept. Worked examples can reduce extraneous load during initial learning, freeing cognitive resources for schema construction. As expertise develops, this reverses as worked examples become too redundant and going straight into problem-solving becomes more effective (the "expertise reversal effect").

**Learner Misconception:** Learners often do not seek out enough examples, but learners who study worked examples outperform those who spend equivalent time problem-solving with no example exposure.

**Risk in AI-assisted work:** AI-generated solutions can function like worked examples, which is beneficial for novices trying to build initial schemas. However, if learners never transition to generating solutions themselves, they miss the retrieval practice and generation effects that consolidate learning. The convenience of AI examples can keep learners perpetually in "novice mode."

**Application:** Use the fading technique: start with complete examples, then progressively remove steps and ask the learner to fill in gaps. Prompt learners to explain *why* each step works, not just *what* happens.

---

## Desirable Difficulties

**Finding:** Conditions that make learning slower or harder in the short term often produce better long-term retention and transfer.

**Mechanism:** Effort during encoding creates stronger, more durable learning. Specific and manageable challenges also promote knowledge transfer.

**Risk in AI-assisted work:** Users often optimize for short-term performance (feeling fluent, moving fast) at the expense of long-term capability, while underestimating the learning gain from productive struggle. 

**Implications:**
- Exercises should require effort without being frustrating
- Struggle during learning is often a sign it's working, not failing
- Slowing down can produce more value over time than optimizing for throughput

**Application:** Don't simplify exercises just because the learner struggles. Embrace productive difficulty. Scaffold when stuck, but don't eliminate the challenge.

---

## Illusions of Learning

### Fluency Illusion

**Finding:** When information feels easy to process or easy to look up, we overestimate how well we've learned it.

**Learner Misconception:** Smooth reading or easy recognition creates a sense of familiarity that we mistake for durable knowledge.

**Risk in AI-assisted work:** Generated code that's quickly produced can make users feel the illusion that they understand it even when they don't. The fluency of the output masks gaps in your mental model.

**Application:** Encourage user to self-navigate through new files and do hands-on testing of their understanding. Unpack mental models by asking about consequences of specific changes. 

### Effort Illusion

**Finding:** Because of misconceptions about effort, users can also mistake the *feeling* of working hard for actual learning.

**Learner Misconception:** Grinding through tasks creates a sense of productivity that may not correspond to skill development. High output can coexist with skill stagnation.

**Risk in AI-assisted work:** Shipping lots of code can feel like growth even when you're not building transferable understanding. Users may not notice production fatigue and burnout that decreases their ability to verification and self-monitoring. 

**Application:** Use retrieval exercises to test actual understanding. Identify learning opportunities at major project turning points.

---

## Active vs. Passive Processing

**Finding:** Active engagement (retrieving, explaining, generating) beats passive review (reading, watching, accepting).

**Mechanism:** Passive exposure creates recognition and familiarity but is less efficient for long-term retention, whereas active processing builds retrieval and transfer.

**Application:** 
- Asking "what do you think this does" beats explaining what it does
- Having users locate code beats showing them code
- Teach-it-back exercises test real understanding

---

## Dynamic Testing

**Finding:** Errors during learning, when followed by corrective feedback, enhance retention compared to error-free learning. Allowing learners to adjust their answer with feedback provides a more accurate view of their learning.

**Mechanism:** Errors create prediction violations that the brain encodes strongly. The surprise of being wrong can make the correct information more memorable and helps learners adjust their mental models.

**Critical nuance:** This requires clear feedback. Errors without correction, or with vague/softened feedback, don't produce the benefit.

**Application:** When learners are wrong, be direct about what's incorrect, then explore why. Don't soften wrongness into ambiguity.

---

## Transfer and Interleaving

**Finding:** Learning transfers better when explicitly connected to underlying principles. Learners build mental models and schema knowledge more efficiently when presented with concepts in varied contexts.

**Mechanism:** Knowledge encoded with a single context tends to stay bound to that context. Explicit abstraction and varied examples build flexible knowledge.

**Application:** After hands-on practice, prompt transfer: "This is an example of [pattern]. Where else might you use this?" Apply the same concept in different scenarios rather than drilling identical cases.

---

## Metacognition Awareness

**Finding:** Learners who monitor and adjust their own learning strategies outperform those who don't, independent of raw ability. Experts learn to harness strategic metacognitive practices to transcend their original cognitive constraints while problem-solving.

**Key capabilities:**
- Monitoring: Knowing when you understand vs. when you don't
- Control: Adjusting strategies based on that monitoring
- Calibration: Accurately judging your own competence

**Risk in AI-assisted work:** Constant production velocity can suppress metacognitive monitoring. Users who don't pause to ask "am I actually learning this?" may not develop metacognitive awareness.

**Application:** Build reflection moments into workflows. Prompt self-assessment. Make space for learners to notice and explore their own mental models and gaps.

---

## What this means for AI-assisted development

The combination of these principles points to a specific risk profile for AI-assisted coding:

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

---

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
