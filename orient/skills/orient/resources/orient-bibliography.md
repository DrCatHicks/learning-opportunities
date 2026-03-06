# Bibliography: Program Comprehension and Codebase Orientation

Sources for the exploration methodology used in the orient skill (Steps 3a–3f of SKILL.md).

---

Spinellis, D. (2003). *Code Reading: The Open Source Perspective*. Addison-Wesley. https://www.spinellis.gr/codereading/

- Basis for: start with the build system and README; read the directory tree as an architectural table of contents; identify architectural seams between components.

---

Hermans, F. (2021). *The Programmer's Brain*. Manning Publications. https://www.manning.com/books/the-programmers-brain

- Basis for: follow the entry point and call graph one level at a time; use "beacons" (recognizable patterns) to orient quickly; experts sample strategically rather than reading exhaustively.

---

Storey, M.-A., et al. (2006). How Software Developers Use Tools, Cognitive Strategies, and Representations to Navigate Code. *IEEE Transactions on Software Engineering*. https://ieeexplore.ieee.org/document/1579228

- Basis for: use the test suite as an executable specification; alternate between systematic and opportunistic traversal; follow data flow, not just control flow.

---

Storey, M.-A., Zimmermann, T., Bird, C., Czerwonka, J., Murphy, B., & Kalliamvakou, E. (2021). Towards a Theory of Software Developer Job Satisfaction and Perceived Productivity. *IEEE Transactions on Software Engineering*, 47(10), 2125–2142. https://ieeexplore.ieee.org/document/8851296

- Basis for: developer productivity is not separable from social and psychological context; orientation practices that ignore belonging and autonomy will underperform.

---

Spolsky, J. Practitioner writing on reading unfamiliar codebases. https://www.joelonsoftware.com

- Basis for: read git history to understand why code is the way it is; high-churn files are usually the core of the system.

---

Dagenais, B., et al. (2010). Moving into a New Software Project: Strangers in a Strange Land. *ICSE 2010*. https://dl.acm.org/doi/10.1145/1806799.1806842

- Basis for: every codebase has a "gateway artifact" that once understood makes everything else legible; prioritize runnable examples over documentation.
