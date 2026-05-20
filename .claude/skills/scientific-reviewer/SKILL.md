---
name: scientific-reviewer
description: "Reviews code that implements a scientific, mathematical, statistical, or numerical algorithm to verify that the implementation faithfully encodes the underlying theory. Use when the user asks to 'scientifically review', 'theory-check', 'math-check', 'verify the algorithm', 'compare to the paper', 'check this against the source', or any phrasing that targets correctness of the science rather than code style. Actively searches arXiv (and bioRxiv / ChemRxiv / SSRN / etc.) and the relevant conference proceedings (NeurIPS, ICML, ICLR, ACL, CVPR, USENIX, AAAI, IJCAI, …) and journal archives (Project Euclid, IEEE Xplore, ACM DL, PubMed Central, …) and standards bodies (IETF RFCs, NIST, W3C) for the primary source of each algorithm rather than relying on whatever citation the code already provides. Explicitly NOT a general code review: do not comment on naming, formatting, lint, performance, refactoring, or test coverage unless those issues directly cause a mathematical error. The skill assumes the code may have been adapted from blog posts, tutorials, Stack Overflow, or LLM output rather than the primary literature, and treats those secondary sources as untrusted."
license: MIT
---

# Scientific Reviewer

## Overview

This skill audits code that claims to implement an algorithm from the scientific or mathematical literature (machine learning, statistics, numerical methods, physics simulations, signal processing, optimization, bioinformatics, computational chemistry, etc.). The goal is **theoretical fidelity**, not code quality. A messy but correct implementation passes; an elegant but subtly wrong one fails.

Two assumptions drive the workflow:

1. **The code's provenance is suspect.** Working programmers often translate algorithms from blog posts, tutorial notebooks, Wikipedia, Stack Overflow answers, or LLM completions. Those secondary sources frequently propagate the same bug verbatim across thousands of repos. They are evidence of community consensus, not of correctness.
2. **Bugs in scientific code often type-check and run.** A wrong sign, a wrong index, a `n` vs. `n-1` denominator, a base-`e` vs. base-`2` log, a row-major vs. column-major convention, a discrete vs. continuous correction — none of these will raise an exception. They will silently produce plausible-looking numbers.

The reviewer's job is to recover the **primary source** for each algorithm in the diff and check the implementation against it line by line.

## When to Use This Skill

Trigger on requests like:
- "Scientifically review this PR"
- "Does this match the paper?"
- "Check my implementation of <algorithm name> against the original derivation"
- "Theory-check / math-check this file"
- "Verify my gradient / loss / sampler / estimator / integrator is correct"
- "Audit this notebook for algorithmic bugs"
- "Compare this to <Author, Year>"

Do NOT use this skill when:
- The user wants a general code review → use a code-review skill or do a normal review
- The user wants performance / readability / refactor feedback
- The user wants help **writing** an algorithm from scratch (this skill is for auditing existing code)
- The change is plumbing only (config, I/O, glue) with no scientific content

If the request is ambiguous — e.g. "review this ML code" — ask one clarifying question: is the goal to verify the math, or to review the code?

## Operating Principles

These principles override the rest of the workflow when they conflict.

1. **Primary sources only.** A primary source is the peer-reviewed paper, conference proceedings entry, arXiv (or bioRxiv / ChemRxiv / SSRN / etc.) preprint, textbook, technical report, or RFC where the algorithm was originally proposed or formally specified. Blog posts, Medium articles, Towards Data Science, GeeksforGeeks, Stack Overflow, Wikipedia, course slides, YouTube videos, and other LLMs' explanations are **not** primary sources and must not be the basis of a verdict. They may be used to *locate* the primary source, never to *substitute* for it. **Actively search arXiv and the relevant conference / journal proceedings for each algorithm** — do not assume the code's existing citation (if any) is correct or sufficient.
2. **Cite specifically.** Every claim about what the algorithm "should" do must point to a specific equation number, theorem, section, or page in a primary source. "The paper says…" with no locator is not acceptable.
3. **Quote the math.** Reproduce the relevant equation from the source in the review (in LaTeX or unambiguous ASCII), next to the corresponding code. Do not paraphrase math.
4. **Distinguish bug from variant.** Many algorithms have legitimate variants (biased vs. unbiased estimators, Glorot vs. He init, mean vs. sum reduction, natural vs. base-2 log). If the code implements a *known variant*, that is not a bug — note the variant, cite where it appears, and confirm with the user that the variant matches their intent.
5. **No style commentary.** Do not flag variable names, formatting, missing type hints, unused imports, function length, magic numbers, etc. The exception is when the style issue *is* the bug (e.g. a magic number `0.5772` that is silently approximating Euler–Mascheroni but should be `np.euler_gamma`, or a variable shadow that swaps two terms).
6. **No performance commentary** unless an optimization changes the mathematical result (e.g. fused multiply-add changing rounding in a numerically sensitive context, or a vectorization that quietly assumes commutativity).
7. **Honest uncertainty.** If the primary source cannot be located, or the algorithm is folklore with no canonical reference, say so explicitly and downgrade the verdict from "bug" to "unverified". Do not bluff a citation.

## Core Workflow

### Step 1 — Inventory the scientific claims

Read the diff (or the file/range the user pointed at). For each block of code, write down — for your own use — what scientific object it claims to compute. Examples:

- "Lines 42–71 implement the score function of a Gaussian mixture model."
- "Function `welford_update` claims to be Welford's online variance algorithm."
- "Class `RungeKutta4` integrates an ODE with the classical 4th-order Runge–Kutta scheme."
- "The loss on line 188 is described as 'InfoNCE' in the docstring."

Be specific. "Implements attention" is too vague — is it scaled dot-product attention (Vaswani et al. 2017, eq. 1), additive attention (Bahdanau et al. 2014), or one of the linear-attention variants? Each has a different formula and different bugs.

If the docstring/comments/PR description name an algorithm or cite a paper, record that as the **claimed source**. If they don't, infer the most likely candidate from the code shape and record it as a **conjectured source** to be confirmed in Step 2.

### Step 2 — Locate the primary source

For each claim from Step 1, find the primary source. **Actively search arXiv, conference proceedings, and journal archives** — do not stop at whatever the code already cites, and do not rely on memory for the canonical reference. Order of preference:

1. The paper/textbook explicitly cited by the code or PR (still verify the citation actually contains the equation as described — code comments often misattribute).
2. The originating paper if the algorithm has a clear inventor (e.g. Kingma & Ba 2014 for Adam, Welford 1962 for the online variance, Metropolis et al. 1953 / Hastings 1970 for MH).
3. The canonical textbook treatment when the algorithm predates modern papers (e.g. Numerical Recipes, Press et al.; Pattern Recognition and Machine Learning, Bishop 2006; Elements of Statistical Learning, Hastie et al. 2009; Deep Learning, Goodfellow et al. 2016).
4. The official reference implementation released by the authors (if any), as a **secondary** check after the paper — author code can also contain bugs, but a disagreement between paper and author code is itself important to flag.
5. An RFC, ISO standard, or specification document for standardized algorithms (e.g. RFC 6979 for deterministic ECDSA, IEEE 754 for floating point).

**Where to look, by field.** Use WebSearch + WebFetch and target these archives directly rather than relying on a generic web search:

- **Preprint servers.** arXiv (`arxiv.org` — physics, math, CS, stats, q-bio, q-fin, eess, econ; use the abstract page `arxiv.org/abs/NNNN.NNNNN` and the PDF `arxiv.org/pdf/NNNN.NNNNN`), bioRxiv and medRxiv (`biorxiv.org`, `medrxiv.org` — life sciences and medicine), ChemRxiv (`chemrxiv.org` — chemistry), SSRN (`ssrn.com` — economics, finance, social science), PsyArXiv (`psyarxiv.com` — psychology), EarthArXiv (`eartharxiv.org` — earth sciences), HAL (`hal.science` — French open archive). Prefer the latest version (`v2`, `v3`…) — early arXiv versions are a common source of bugs that the published version corrects.
- **ML / AI conferences.** NeurIPS (`papers.nips.cc` / `proceedings.neurips.cc`), ICML (`proceedings.mlr.press` — also hosts AISTATS, UAI, COLT, CoRL), ICLR (`openreview.net`), ACL Anthology (`aclanthology.org` — ACL, EMNLP, NAACL, EACL, COLING, TACL), CVPR/ICCV/ECCV and other CVF venues (`openaccess.thecvf.com`), AAAI (`ojs.aaai.org`), IJCAI (`ijcai.org/proceedings`), KDD/WWW/SIGIR (ACM DL).
- **CS / systems.** ACM Digital Library (`dl.acm.org` — SIGCOMM, SOSP, OSDI via USENIX, PLDI, POPL, etc.), USENIX (`usenix.org/conferences` — OSDI, NSDI, ATC, Security), IEEE Xplore (`ieeexplore.ieee.org` — INFOCOM, S&P, ICDE), DBLP (`dblp.org`) to enumerate venues an author has published in.
- **Math / stats / physics.** Project Euclid (`projecteuclid.org` — Annals of Statistics, Annals of Probability, etc.), JSTOR, MathSciNet/zbMATH for metadata, INSPIRE-HEP (`inspirehep.net` — high-energy physics), ADS (`ui.adsabs.harvard.edu` — astronomy/astrophysics).
- **Life sciences / chemistry / medicine.** PubMed and PubMed Central (`pubmed.ncbi.nlm.nih.gov`, `ncbi.nlm.nih.gov/pmc` — PMC is the open-access subset and is your best bet for full text), Europe PMC (`europepmc.org`), bioRxiv, ChemRxiv, RSC and ACS journals (often paywalled — fall back to the author's institutional repository).
- **Cross-venue search and metadata.** Google Scholar (`scholar.google.com` — fastest way to find an arXiv mirror or author PDF for a paywalled paper; check the "All N versions" link), Semantic Scholar (`semanticscholar.org` — good for follow-up papers and errata), OpenReview (`openreview.net` — reviews and rebuttals often surface known bugs), Connected Papers / Litmaps for citation graphs, Crossref (`api.crossref.org`) and DOI.org for canonical metadata.
- **Standards and specifications.** IETF RFCs (`rfc-editor.org`, `datatracker.ietf.org`), NIST publications (`csrc.nist.gov` — FIPS, SP 800 series for crypto), ISO (paywalled — search for the freely available draft or a citing paper), W3C (`w3.org/TR`), Khronos (`registry.khronos.org`).
- **Author / lab pages and code.** The author's personal or lab website often hosts the preprint, errata, and the reference implementation. The official GitHub repo's README and `CITATION.cff` usually point at the canonical paper version.

**Search tactics.**

- Start with the most specific query you can form: full algorithm name + first author surname + year if you know any of them ("Adam optimizer Kingma 2014 site:arxiv.org").
- If you only have a name, search the name in quotes plus a distinctive symbol or phrase from the equation ("InfoNCE" "log frac").
- If a paywalled version is the only hit, search Google Scholar for the title and look under "All N versions" for an arXiv, institutional-repository, or author-page PDF.
- Resolve the DOI to confirm the venue and year; an algorithm often has a workshop version, a conference version, and a journal version that differ in minor but bug-relevant ways.
- When the algorithm has both an arXiv preprint and a published version, **fetch both** and note any differences — published versions frequently fix bugs that are still propagating from the arXiv version through copy-paste.
- For algorithms named after people (Welford, Kahan, Metropolis–Hastings, Box–Muller), search for the original paper rather than relying on the textbook restatement; older papers are often on JSTOR, Project Euclid, or the journal's archive and may need a library proxy.

If after a focused search across the relevant archives no primary source can be found, mark the claim as **unverified** and continue. Do not fabricate a citation, and do not substitute a tutorial or blog post.

### Step 3 — Extract the reference equations

From the primary source, extract:

- The exact equation(s) the code claims to implement, with equation numbers.
- The definition of every symbol in those equations (what is a scalar, vector, matrix; what is the indexing convention; what is summed over what).
- The stated assumptions (i.i.d. samples? stationary process? convex objective? bounded support? regularity conditions?).
- Any preprocessing or postprocessing the paper specifies (centering, normalization, bias correction, projection back to a manifold, etc.).
- The numerical-stability tricks the paper or a follow-up paper recommends (log-sum-exp, Kahan summation, two-pass vs. one-pass formulas, parameterization changes).

Reproduce the equations in the review. Do not paraphrase. If the paper uses a notation the reader of the review won't recognize, translate it but keep both forms.

### Step 4 — Line-by-line comparison

Walk the code against the extracted equations. For each line that implements part of an equation, ask:

- **Symbol mapping.** Does each variable in the code correspond to the symbol the paper says it should? Watch for transposed dimensions, swapped arguments (e.g. `KL(p || q)` vs. `KL(q || p)`), and off-by-one shifts in indexing.
- **Operator fidelity.** Is the operator the same? `np.log` is natural log; `math.log2` is base 2. `np.var` defaults to `ddof=0` (population); `statistics.variance` defaults to sample. `torch.nn.CrossEntropyLoss` already includes a softmax; passing softmaxed logits in is a double-softmax bug. `scipy.signal.convolve` flips the kernel; `np.correlate` does not. Note every such default.
- **Boundary terms.** Does the sum start at 0 or 1? Inclusive or exclusive upper bound? Does the recursion need a base case the code is missing? Does an integral need an endpoint correction (trapezoidal vs. Simpson)?
- **Normalization.** Is the prefactor right? `1/N` vs. `1/(N-1)`. `1/sqrt(d_k)` in scaled dot-product attention. `(2π)^(-d/2) |Σ|^(-1/2)` in a Gaussian density. Softmax temperature. Bessel's correction. Jacobian for change of variables. Partition function `Z`.
- **Sign and direction.** Loss being minimized vs. likelihood being maximized. Gradient ascent vs. descent. KL divergence asymmetry. Sign of an eigenvalue. Direction of an inequality used for early stopping.
- **Numerical pitfalls.** Naive softmax without max-subtraction; naive variance with sum-of-squares minus square-of-sum; `1 - x` near 1; `log(1+x)` vs. `np.log1p`; matrix inversion where a solve would do; division by a quantity that can be zero or negative when the math guarantees only nonnegative.
- **Random number conventions.** Inclusive vs. exclusive bounds (`numpy.random.randint` is half-open; `random.randint` is closed). Sampling with vs. without replacement. Whether a reported "log probability" includes the Jacobian for a reparameterized sample. PRNG seeding scope.
- **Linear algebra conventions.** Row vectors vs. column vectors. Whether a "weight matrix W" multiplies inputs as `Wx` or `xW`. Batch-first vs. time-first tensors. Whether a covariance is `X^T X / n` or `X X^T / n`. Whether an "orthogonal" matrix is over reals or includes complex unitaries.
- **Discrete vs. continuous.** Discrete distributions parameterized by logits vs. probabilities. Time-discrete vs. continuous-time corrections (e.g. SDE discretization: Euler–Maruyama vs. Milstein). Forward-Euler instability for stiff ODEs.

Maintain a running list of findings, each tagged with one of:

- **bug** — the code provably disagrees with the cited source; running it will produce wrong numbers (in expectation, or for some inputs the paper explicitly covers).
- **likely bug** — disagreement is highly suspicious but depends on an unstated assumption; needs the author to confirm intent.
- **variant** — disagreement, but the code matches a known alternative formulation; cite where that alternative is published and confirm intent.
- **unverified** — could not locate a primary source within the time budget; describe what would need to be checked.

### Step 5 — Reproduce, if cheap

When practical, sanity-check a finding by running the code on a tiny input where the correct answer is known analytically or from a trusted reference implementation:

- A 2×2 case for a matrix routine.
- A two-sample case for a statistic with a closed form (mean, variance, t-statistic).
- A constant function for a numerical integrator (should be exact).
- A linear function for a 1st-order method, a quadratic for a 2nd-order method (order-of-accuracy check).
- Compare against `scipy`, `numpy`, `statsmodels`, `torch`, `jax`, `pytorch`'s `F.*`, or the authors' released code on a fixed seed.

A failing tiny case is the strongest possible evidence; promote a "likely bug" to "bug". A passing tiny case does **not** clear a "likely bug" — many algorithms agree with reference implementations on toy inputs and diverge on real ones. Note the test and move on.

Do not invest in elaborate reproduction harnesses unless the user asks. If a check would take more than a few minutes to set up, describe what test the author should run instead.

### Step 6 — Produce the review

The review is organized **by finding**, not by file. Each finding is a self-contained block:

```
Finding N — <one-line summary>
Severity: bug | likely bug | variant | unverified
Location: <file>:<line range>
Code (as written):
    <minimal snippet>
Reference (from primary source):
    <equation in LaTeX/ASCII, with equation number and citation locator>
Source: <Author Year>, "<Title>", <venue>, <equation/section/page>, <URL or DOI>
Why this is wrong:
    <one paragraph explaining the discrepancy in plain terms — what the code computes
    vs. what the paper specifies — and the consequence on outputs>
How to fix:
    <minimal change, or two alternatives if there's a legitimate choice>
If reproducible: <tiny input that distinguishes correct from incorrect output>
```

At the top of the review, include a one-paragraph **summary** listing each algorithm audited, the primary source used, and the verdict (number of bugs / likely bugs / variants / unverified). At the bottom, include a **bibliography** with every primary source cited, in a stable format (author, year, title, venue, DOI/arXiv ID, URL).

Order findings by severity (bugs first), then by location.

If there are no findings, say so plainly: state which algorithms were audited against which sources, what was checked, and that no theoretical discrepancies were identified within the scope. Do not invent issues to pad the review.

## Common Bug Patterns (Non-Exhaustive Checklist)

Use this list as prompts during Step 4 — it is not exhaustive and is not a substitute for actually reading the source.

**Statistics / probability**
- `ddof=0` vs. `ddof=1` (population vs. sample variance/std).
- Standard error using `n` vs. `n-1` in the denominator of the variance estimate.
- Confidence intervals using the normal quantile when a t-quantile is required.
- p-values: one-sided vs. two-sided; tail used; log-space vs. linear-space comparisons.
- Bayes factor or likelihood ratio: confusing odds and probabilities.
- Sampling without replacement implemented as sampling with replacement.
- Beta/Dirichlet/Gamma parameterizations: shape-rate vs. shape-scale; mean-precision vs. mean-variance.

**Information theory**
- `log` base inconsistent with the unit reported (nats vs. bits vs. dits).
- KL direction: `D_KL(p || q)` vs. `D_KL(q || p)`. ELBO sign.
- Cross-entropy with softmax built in vs. softmax applied separately (double softmax).
- Mutual information estimators with bias corrections (e.g. Miller–Madow, NSB) silently dropped.

**Optimization**
- Adam: epsilon position (inside vs. outside the sqrt), bias-correction order, weight decay vs. L2 (AdamW distinction).
- Momentum: Polyak vs. Nesterov; sign of the lookahead step.
- Learning-rate schedules: warmup interacting with bias correction; cosine schedule period off by one.
- Line search: Armijo vs. Wolfe conditions; missing curvature condition.
- Constrained optimization: projection step omitted; Lagrange multiplier sign.

**Linear algebra / numerics**
- `np.linalg.inv(A) @ b` instead of `np.linalg.solve(A, b)` — usually a stability issue, occasionally a correctness one when `A` is near-singular.
- Cholesky on a matrix that is only positive *semi*-definite.
- SVD truncation: keeping smallest singular values instead of largest (sign of a sort flip).
- Eigenvectors not orthonormalized when the algorithm assumes they are.
- Naive variance / covariance from sum-of-squares minus square-of-sums (catastrophic cancellation).
- Softmax / logsumexp without max-subtraction.
- `log(1 + x)` for small `x` not using `log1p`; `exp(x) - 1` not using `expm1`.

**Machine learning specifics**
- Scaled dot-product attention missing the `/ sqrt(d_k)` factor.
- LayerNorm using `var` with `ddof=1` when the paper specifies population variance, or vice versa.
- BatchNorm: train/eval mode confusion; running stats not updated in train mode; momentum convention (PyTorch's is `1 - paper's`).
- Dropout scaling: inverted dropout vs. classical dropout; not scaling at train time when using inverted dropout.
- Initialization: Glorot/He variance with `fan_in`, `fan_out`, or `(fan_in + fan_out)/2` — the choice depends on the activation and the paper.
- Positional encoding: sinusoidal frequencies; whether `2i` or `i` indexes pairs; whether `10000` is the base.
- Cross-entropy with class weights: weights normalized vs. not, affecting the gradient scale.
- ROC-AUC / PR-AUC with ties handled by `'macro'` vs. `'micro'` vs. `'weighted'`.

**Numerical integration / ODE / SDE**
- Forward Euler used where stability requires implicit / Runge–Kutta.
- RK4 with wrong stage weights (the classical 1/6, 1/3, 1/3, 1/6).
- Symplectic integrator (e.g. leapfrog/Verlet) replaced with non-symplectic step, breaking energy conservation for long horizons.
- SDE: Euler–Maruyama where Milstein or stronger is required for the convergence order claimed.
- Adaptive step size with tolerance applied to absolute error when relative is needed (or vice versa).

**Signal processing**
- FFT normalization: `numpy.fft` does not normalize the forward transform; `scipy.fft` with `norm='ortho'` does; MATLAB differs again.
- Window function applied twice or omitted before FFT for spectral estimation.
- `np.correlate` vs. `scipy.signal.correlate` vs. `np.convolve`: which one flips the kernel.
- Sampling rate vs. Nyquist: filter cutoff expressed as fraction of Nyquist vs. Hz.

**Physics / chemistry / simulation**
- Units: SI vs. Gaussian vs. atomic units; factors of `4πε₀`, `ℏ`, `kB`.
- Periodic boundary conditions: minimum-image convention applied to distances but not to forces (or vice versa).
- Thermostat / barostat: timestep coupling constant in wrong units.
- Quantum: Hermitian conjugate vs. transpose for complex matrices.

**Bioinformatics**
- 0-indexed vs. 1-indexed coordinates (BED vs. GFF/VCF).
- Half-open vs. closed intervals.
- Reverse complement: T↔A vs. T→A only; handling N and IUPAC codes.
- Phred quality: `+33` vs. `+64` offset; rounding direction.

## Edge Cases & Failure Modes

| Case | Behavior |
|---|---|
| Primary source is behind a paywall and no preprint exists | Fetch what is public (abstract, figures), state the gap, and mark affected findings as **unverified** with a note on what the author needs to check. |
| Algorithm is folklore with no canonical paper (e.g. "the standard trick for…") | Cite the earliest textbook treatment you can find; if none, mark **unverified** and stop. Do not promote a blog post. |
| The user supplies a citation that turns out not to contain the equation as described | Note the discrepancy; search for the actual primary source; if found, use it; if not, mark **unverified** and ask the user where they got the formula. |
| Code matches a widely copied reference implementation that itself contains a known bug (e.g. an early-version arXiv release that was later corrected) | Cite both versions; flag as **bug** with reference to the corrected version (errata, v2 of the preprint, the journal version). |
| Code implements a legitimate variant (e.g. AdamW vs. Adam) | Mark as **variant**, not bug. Cite the variant's source. Ask the user whether the variant matches their intent. |
| Two primary sources disagree (e.g. a paper and its own released code) | Report both; explain which the code follows; flag the inconsistency and let the user decide. |
| The diff includes both scientific code and unrelated plumbing | Ignore the plumbing entirely. Do not comment on it. |
| The user asks for "any" review and the diff is purely scientific | Do the scientific review and say at the top: "I am not commenting on style, performance, or test coverage — request a separate review for those." |
| No scientific content in the diff | Say so and stop. Do not invent a scientific angle on plumbing code. |
| Reproduction of a finding would be expensive (large model, long run) | Describe the test the author should run, but do not run it yourself. |

## Quality Control Checklist

Before returning the review:

- [ ] Each finding cites a **primary** source with a specific locator (equation number, theorem, section, or page).
- [ ] arXiv (and/or the relevant proceedings: NeurIPS, ICML, ICLR, ACL, CVPR, USENIX, Project Euclid, PubMed Central, IETF, NIST, etc.) was searched for the canonical paper — not just the citation the code already provides.
- [ ] When both an arXiv preprint and a published version exist, the latest version was used and any preprint-vs-published differences relevant to the finding are noted.
- [ ] No finding rests solely on a blog post, Wikipedia, Stack Overflow, course slides, or another LLM's explanation.
- [ ] The relevant equation is reproduced in the review, not paraphrased.
- [ ] Each finding distinguishes **bug** vs. **likely bug** vs. **variant** vs. **unverified**.
- [ ] No finding is about naming, formatting, lint, performance, refactoring, or test coverage unless that issue is the mechanism of a mathematical error.
- [ ] Every cited source appears in the bibliography at the bottom of the review with author, year, title, venue, and DOI/arXiv/URL.
- [ ] If no issues were found, the review states that plainly, lists what was audited against what, and does not invent findings.
- [ ] If a source could not be located, the affected findings are marked **unverified** rather than guessed.
