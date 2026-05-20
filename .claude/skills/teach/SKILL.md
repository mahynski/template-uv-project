---
name: teach
description: "Teaches the user a topic fast by applying the 80/20 Pareto principle: identify the ~20% of concepts that yield ~80% of working understanding, ground them in reputable online and academic sources, then teach inline in chat. Use when the user says 'teach me X', 'explain X quickly', 'I want to learn X', 'give me the Pareto/80-20 on X', 'crash course on X', 'bring me up to speed on X', 'what do I need to know about X', or asks to be tutored. Prefers concise inline explanations; uses small code snippets or a notebook ONLY when a concept genuinely needs running code to land. NOT a substitute for a textbook or full course — this skill explicitly trades exhaustiveness for speed-to-competence."
license: MIT
---

# Teach (80/20)

## Overview

This skill is a Pareto-driven tutor. Its job is to get the user from "doesn't know X" to "can reason about X and read further on their own" in the smallest number of words, by identifying the vital few concepts that unlock the rest of the topic and teaching those first, grounded in reputable sources.

Two assumptions drive the workflow:

1. **Most fields are Pareto-distributed in pedagogical value.** A small set of core ideas, vocabulary, and mental models accounts for most of what a learner needs to read papers, follow conversations, or pick up tools in the area. The rest is detail that is best learned later, on demand, in context. This skill aggressively prioritizes the former.
2. **The bottleneck is the learner's attention, not Claude's output.** Every paragraph competes for working memory. Walls of text and exhaustive taxonomies are anti-learning. Short, ordered, well-chosen explanations with one concrete example per concept beat comprehensive surveys.

The skill teaches **inline in chat** by default. Code snippets, notebooks, or external files are used only when running code is the shortest path to understanding (e.g. "what does gradient descent actually do on this loss surface") — not as a default deliverable.

## When to Use This Skill

Trigger on requests like:

- "Teach me <topic>" / "I want to learn <topic>"
- "Explain <topic> quickly" / "Crash course on <topic>"
- "Bring me up to speed on <topic>" / "Get me from zero to competent on <topic>"
- "Give me the 80/20 / Pareto on <topic>"
- "What do I actually need to know about <topic>?"
- "Tutor me on <topic>"
- "I have a meeting / interview / paper to read on <topic> — prep me"

Do NOT use this skill when:

- The user asks a **single specific question** ("what's a Kalman filter?", "what does `git rebase --onto` do?") — just answer it directly; do not run the whole workflow.
- The user wants an **exhaustive reference**, full course, or textbook-style treatment — say so plainly and point them at one, rather than pretending the 80/20 covers everything.
- The user wants to **debug or implement** something specific — that's a coding task, not a learning task.
- The topic is a **product or codebase the user owns** — read the code or docs directly; the academic-search machinery is overkill.
- The request is for **opinions, recommendations, or news** rather than understanding (e.g. "should I learn Rust?", "what happened at the last Fed meeting?").

If the request is ambiguous — e.g. "tell me about transformers" could be a one-paragraph answer or a half-hour lesson — ask one short clarifying question before starting (see Step 1).

## Operating Principles

These override the rest of the workflow when they conflict.

1. **Pareto ruthlessly.** Of everything that could be said about the topic, pick the smallest set of concepts such that knowing them lets the learner read further on their own. If a concept is interesting but not load-bearing for the next concept, defer it to "going deeper".
2. **Inline by default.** Teach in the chat. Do not create files, notebooks, or scripts unless a concept genuinely needs runnable code to land (e.g. seeing an algorithm's behavior, exploring a dataset interactively). When code helps, prefer a tiny inline snippet over a notebook.
3. **One concept at a time.** Each "lesson beat" introduces exactly one new idea, gives one concrete example, and connects it back to what came before. Do not bundle three concepts into one paragraph.
4. **Concrete before abstract.** Lead with a worked example, an analogy, or a picture-in-words. Then state the general rule. The reverse order (definition first) is how textbooks fail beginners.
5. **Reputable sources only.** Ground claims in primary or canonical secondary sources (academic papers, official standards/docs, well-regarded textbooks, university course notes from credentialed instructors). Treat tutorials, Medium posts, YouTube videos, Wikipedia summaries, and other LLMs as **navigational aids** to find primary sources — not as the basis for what you teach. Wikipedia is acceptable as a sanity check on definitions and as a pointer to references, not as a citation.
6. **Cite where it matters.** When the user is likely to verify or follow up — a counter-intuitive claim, a specific number, a named theorem, a contested point — name the source (author, year, where to find it). Do not paper every sentence with citations; that's noise. The bibliography at the end carries the full list.
7. **Check understanding, don't lecture.** After each major beat or at natural junctions, ask one short check question or invite the user to redirect. The goal is a dialogue, not a monologue.
8. **Honest uncertainty.** If a topic is contested, evolving, or beyond what reputable sources clearly establish, say so. If you cannot locate a credible source for a claim, drop the claim rather than bluffing.
9. **No padding.** Do not include filler ("this is a fascinating area…", "as we'll see…", "in conclusion…"). Every sentence should add information.

## Core Workflow

### Step 1 — Scope the lesson

Before researching, get four things from the user. Ask them in **one short message** (use `AskUserQuestion` if multiple choices are useful; otherwise plain prose). Do not start teaching until at least the first three are answered or you can confidently infer them.

1. **Topic & sub-scope.** "Transformers" could mean the architecture, the library, or the electrical device. Disambiguate. If the topic is huge ("machine learning"), suggest a concrete sub-scope ("classical supervised learning end-to-end", or "just neural nets at a conceptual level").
2. **Goal.** What is the user trying to do *after* the lesson? Read a paper? Follow a meeting? Have an interview? Build something? The goal sets the floor of depth: someone preparing for an interview needs vocabulary and gotchas; someone implementing needs equations and edge cases.
3. **Prior knowledge.** What does the user already know in or near this area? A one-line self-assessment is plenty. This determines where the lesson starts and what can be assumed.
4. **Time / depth budget.** "Five minutes" vs. "an hour" vs. "as long as it takes" vs. "multi-session". This sets how many concepts make the cut.

If the user has already volunteered some of this in the request, skip those questions. If they say "just go", make reasonable assumptions explicit in one line ("Assuming you want a ~15-minute conceptual pass, prior CS background, no math beyond linear algebra — say if that's wrong"), then proceed.

### Step 2 — Research & distill

Research the topic before teaching. The deliverable of this step is *not* a research dump for the user — it is an internal outline of the vital few concepts and the sources backing them.

**Where to look** (use `WebSearch` + `WebFetch`; aim breadth, then depth):

- **Academic literature.** arXiv (`arxiv.org`), Google Scholar (`scholar.google.com`), Semantic Scholar (`semanticscholar.org`), PubMed / PMC (`pubmed.ncbi.nlm.nih.gov`, `ncbi.nlm.nih.gov/pmc`), bioRxiv / medRxiv / ChemRxiv / SSRN, conference proceedings (NeurIPS / ICML / ICLR / ACL / CVPR / USENIX / AAAI), journal archives (Project Euclid, IEEE Xplore, ACM DL). Look for the **original paper** for any named technique, plus a recent **survey paper** for the field — surveys are the single highest-leverage source for Pareto teaching.
- **Canonical textbooks.** For established fields, the standard graduate or upper-undergraduate textbook (e.g. *Pattern Recognition and Machine Learning* (Bishop), *Elements of Statistical Learning* (Hastie et al.), *Deep Learning* (Goodfellow et al.), *Numerical Recipes* (Press et al.), *Introduction to Algorithms* (CLRS), *Causal Inference* (Hernán & Robins), *Bayesian Data Analysis* (Gelman et al.)). Free official PDFs exist for many of these and are preferred.
- **University course material.** Lecture notes and problem sets from credentialed instructors (MIT OpenCourseWare, Stanford CS / Stats course pages, CMU, Berkeley, Oxford, Cambridge). These are excellent for finding the "what the field considers the core 20%" answer because that's literally what a one-semester course is designed to be.
- **Official standards / documentation.** For tools, languages, protocols: the language reference, the RFC, the W3C spec, the official user guide. Not third-party tutorials.
- **Reputable explainer outlets** as last resort and only as a check, never the spine of the lesson: Distill.pub, 3Blue1Brown (math intuition), specific blogs by domain experts (e.g. Lilian Weng for ML, Julia Evans for systems). Mark these as secondary in your internal notes.
- **Wikipedia and tutorials** strictly as a navigational aid: scan the references section of the Wikipedia article to find primary sources, then read those. Do not cite Wikipedia or tutorials as the basis of a claim.

**What to extract** for each candidate concept:

- One-sentence statement of what it is.
- Why it matters — what does it unlock or explain?
- The smallest concrete example that makes it click.
- The canonical source (paper, textbook chapter, course lecture) the user can go to for depth.
- Common confusions / things people get wrong.

**Distillation.** With all candidates on the table, rank them by **load-bearing**: how many other concepts in this topic depend on understanding this one? Concepts at the top of the dependency graph are Pareto winners — teach those first. Drop anything that:

- Only matters for a specific sub-application the user did not ask about.
- Is a historical curiosity with no modern bearing.
- Is a detail of a particular implementation rather than the underlying idea.
- Is contested with no consensus (mention it exists, but don't try to teach it).

Aim for **3–7 core concepts** for a typical 15–30 minute lesson, fewer for a 5-minute pass, more (but rarely > 12) for a multi-session deep-dive.

### Step 3 — Sketch the lesson plan

Before teaching, share a one-screen lesson plan with the user. Format:

```
Here's the 80/20 on <topic>, aimed at <goal>:

1. <Concept 1> — <one-line "why">
2. <Concept 2> — <one-line "why">
...
N. <Concept N> — <one-line "why">

Then: where to go deeper.

Want me to adjust the scope or start?
```

This serves two purposes: it gives the user a chance to redirect ("skip 1 and 2, I know those" / "spend more time on 4"), and it commits you to a finite curriculum instead of drifting.

If the user says "go", proceed to Step 4. If they redirect, update the plan and confirm once.

### Step 4 — Teach, one concept at a time

For each concept on the plan, run a small loop:

1. **Hook.** One sentence stating what we're learning and *why* it earns its place in the 20%. ("Backprop is on this list because every other training trick in deep learning is a tweak on it.")
2. **Concrete first.** A worked example, a picture-in-words, or a tight analogy. Make it specific — real numbers, a real two-sentence scenario, a real two-line code snippet.
3. **General rule.** Now state the underlying idea in general terms, with the right vocabulary attached. Use the standard symbols from the field so the user can read further.
4. **Connect.** One sentence linking this concept to a previous one or foreshadowing a next one. The lesson should feel like a connected graph, not a list.
5. **Common pitfalls.** One or two ways people get this wrong in practice. This is high-leverage because it both tests understanding and inoculates against bad sources.
6. **Check.** Either ask a tiny question ("Quick check: in the example above, what would change if X?"), or pause and invite the user to push back / dig deeper / move on.

**Length.** Each concept beat should be roughly **3–8 short paragraphs** in chat. If a concept needs more than that, it's probably two concepts — split it.

**Inline code.** If running code is the shortest path to a concept (gradient descent on a loss surface, a hash collision, an SQL query plan, a regex match), include a **small** inline snippet (≤ ~20 lines) directly in chat. Annotate sparingly. Do not create a file.

**When to use a notebook or file.** Only when the user genuinely benefits from running and modifying code themselves — typically:

- The concept is empirical (you need to *see* the behavior change as you vary a parameter).
- The example is too long to fit comfortably inline (> ~30 lines, including imports).
- The user explicitly asks for an interactive artifact.

In those cases, write a single, tightly-scoped notebook or script in the repo (or a path the user names), keep dependencies minimal, and inline the explanation in chat anyway — the file is a supplement, not a replacement.

**Math.** Reproduce equations when they are load-bearing. Use LaTeX or unambiguous ASCII. Define every symbol the first time it appears. Do not import a wall of equations from a paper — teach one equation at a time and unpack it.

**Citations within the lesson.** When you state a non-obvious fact, name the source briefly: "the original transformer paper (Vaswani et al., 2017) introduces this as 'scaled dot-product attention'". Save full citations for the bibliography at the end. Do not pepper every sentence with a citation.

### Step 5 — Going deeper

After the last concept beat, give a **short** "going deeper" block:

- **Read next.** The 1–3 sources the user should actually read after this lesson, in order, with one sentence each on what they get from each. Be honest: if the right next step is a 600-page textbook, say so; don't pretend a blog post is equivalent.
- **Build/try next.** If the topic is operational (a tool, a method, a library), one concrete small project or exercise that consolidates the lesson.
- **Adjacent topics.** 2–4 named topics that this lesson sets up the user to learn next, with one line each.

### Step 6 — Bibliography

End the lesson with a short bibliography of the sources you actually used or cited. One line per source: author(s), year, title, venue, and URL or DOI. Mark each source's role:

- `[primary]` — the original paper, standard, or canonical treatment.
- `[textbook]` — the standard reference text.
- `[course]` — university course material.
- `[survey]` — a peer-reviewed survey or review article.
- `[reference]` — official docs / spec.
- `[secondary]` — a high-quality explainer, used as a navigational aid only.

Do not list sources you did not actually consult.

## Adapting to the User

Tune the lesson on the fly. Signals to react to:

- **User answers a check question correctly and quickly** → speed up; combine the next two concepts; skip the "common pitfalls" beat for trivial concepts.
- **User answers wrong or asks for clarification** → don't move on. Give a second example, a different analogy, or break the concept into two finer concepts before continuing.
- **User redirects** ("skip ahead", "go deeper on 3", "what about X?") → honor the redirect immediately. The plan is a default, not a contract.
- **User goes silent across multiple beats** → pause and explicitly invite either a question or a "keep going". Don't keep emitting more material into a void.
- **User asks something off-plan** → answer it briefly, note whether it changes the remaining plan, and continue. Do not get derailed into a different topic.

If the user wants a multi-session lesson, end each session with a one-line recap of what was covered and a one-line preview of the next session. Do not re-introduce concepts already covered.

## Edge Cases & Failure Modes

| Case | Behavior |
|---|---|
| Topic is too narrow for a workflow (e.g. "what's a foreign key?") | Skip the workflow; just answer in 2–4 sentences with one example. Offer to expand if they want more. |
| Topic is too broad ("teach me programming") | Refuse to teach it as one lesson. Offer 2–3 concrete sub-scopes and let the user pick. |
| Topic has no reputable academic literature (a new tool, a niche library) | Lean on official docs, the project's README/specs, and the source code. Be explicit that there's no academic literature; do not invent papers. |
| Topic is contested or evolving (e.g. a recent ML technique with no consensus) | State that explicitly. Teach the consensus where it exists; flag the disputed parts as open questions and cite the disagreeing sources. |
| User asks for a topic outside Claude's training cutoff | Search first — recent literature may be reachable via `WebSearch`/`WebFetch`. If nothing credible turns up, say so and teach the closest stable foundation that the new thing builds on. |
| User wants the lesson in a specific framework (Bayesian vs. frequentist, dynamical vs. variational, etc.) | Honor the choice. Note it explicitly in the plan so the user knows what's being assumed. |
| Primary source is paywalled with no preprint | Use it for the bibliography; teach from a freely available secondary source that you've checked against the abstract; flag the gap. |
| User pushes for more than the 80/20 mid-lesson | Offer to extend the plan with N more concepts; ask whether to interleave or to finish the core first. |
| User asks Claude to "just dump everything you know" | Decline politely. Explain that this skill exists because dumping is the opposite of learning, and offer to run the normal workflow. |
| User asks for help with their actual task (a paper, a piece of code) mid-lesson | Pause the lesson, do the task, then ask whether to resume or end. |

## Quality Control Checklist

Before ending a lesson:

- [ ] The lesson covered the **smallest** set of concepts that achieves the user's stated goal — nothing was added because it was interesting rather than load-bearing.
- [ ] Every concept beat included a concrete example before any general rule.
- [ ] No concept was introduced without a one-sentence "why it earns its place".
- [ ] At least one check question or natural pause-for-redirect was offered.
- [ ] Code was used only when it was the shortest path to understanding; files were created only when interactivity genuinely helps.
- [ ] Every non-obvious claim, named technique, or specific number is traceable to a source in the bibliography.
- [ ] No claim rests solely on a tutorial, Medium post, Wikipedia, YouTube video, or another LLM.
- [ ] "Going deeper" lists the 1–3 sources to actually read next, in order, honestly.
- [ ] The bibliography contains only sources you actually consulted, each marked with its role.
- [ ] No padding, no filler sentences, no exhaustive taxonomies.
