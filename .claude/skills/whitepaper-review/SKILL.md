---
name: whitepaper-review
description: Review white papers and technical documents as an editor, providing structured feedback on clarity, impact, and persuasiveness. Evaluates against a customizable rubric focused on communicating technical excellence to funding decision-makers. Does NOT edit files directly — provides copy-paste-ready suggestions.
---

# White Paper Review & Editorial Feedback

Review white papers, technical documents, and funding proposals from the perspective of a senior technical editor. Your goal is to help the document achieve maximum impact with both technical and non-technical audiences, particularly funding decision-makers.

## Core Objectives

A strong white paper should:
1. **Communicate technical prowess** — demonstrate deep expertise and rigorous methodology
2. **Be readable and exciting** — engage non-experts while maintaining professionalism
3. **Prove soundness** — show the ideas are well-founded and implementable
4. **Show advancement** — clearly articulate the step forward in capabilities
5. **Justify investment** — make the value proposition compelling
6. **Establish state-of-the-art positioning** — show competitive advantages where relevant

## Scope

By default, review the document(s) specified by the user. If the user points to a directory, ask which files to review. Supported formats include:
- Markdown (`.md`)
- Plain text (`.txt`)
- LaTeX (`.tex`)
- PDF (`.pdf`) — requires pdf skill
- Word (`.docx`) — requires docx skill

## Evaluation Rubric

The rubric is organized into categories. Each category has specific evaluation criteria. The user can customize this rubric by providing their own criteria before or during the review.

### 1. Technical Credibility (Weight: 25%)
**Goal:** Establish that the work is technically sound and rigorous.

Criteria:
- **Methodology clarity** — Is the technical approach clearly explained? Can an expert reproduce it?
- **Mathematical rigor** — Are equations, derivations, and proofs correct and well-presented?
- **Appropriate detail** — Is there enough technical depth without overwhelming non-experts?
- **Uncertainty acknowledgment** — Are limitations and assumptions stated clearly?
- **Evidence quality** — Are claims supported by data, experiments, or citations?

### 2. Narrative & Readability (Weight: 20%)
**Goal:** Ensure the document is engaging and digestible for non-experts.

Criteria:
- **Story arc** — Does it flow logically from problem → solution → impact?
- **Jargon management** — Is technical terminology introduced and explained appropriately?
- **Sentence clarity** — Are sentences concise and free of ambiguity?
- **Active voice** — Does it use strong, direct language vs. passive constructions?
- **Visual aids** — Are figures, tables, and diagrams used effectively?

### 3. Value Proposition (Weight: 20%)
**Goal:** Make the investment case compelling.

Criteria:
- **Problem significance** — Is the problem important and clearly articulated?
- **Impact potential** — Are the benefits and applications concrete and compelling?
- **Cost-benefit framing** — Is the return on investment clear?
- **Timeline realism** — Are milestones achievable and credible?
- **Risk mitigation** — Are risks identified and mitigation strategies provided?

### 4. Competitive Positioning (Weight: 15%)
**Goal:** Establish state-of-the-art status and differentiation.

Criteria:
- **Comparison to existing work** — How does this advance beyond current approaches?
- **Performance metrics** — Are improvements quantified with benchmarks?
- **Unique advantages** — What makes this approach superior or novel?
- **Market awareness** — Does it show understanding of the competitive landscape?
- **Defensibility** — Are there barriers to replication?

### 5. Professional Polish (Weight: 10%)
**Goal:** Ensure the document meets professional standards.

Criteria:
- **Grammar and spelling** — Is the writing error-free?
- **Consistency** — Are terminology, notation, and style consistent throughout?
- **Citation quality** — Are references appropriate, formatted correctly, and complete?
- **Formatting** — Is the document visually professional?
- **Tone appropriateness** — Is the tone confident but not arrogant?

### 6. Structure & Organization (Weight: 10%)
**Goal:** Ensure information is well-organized and easy to navigate.

Criteria:
- **Section logic** — Are sections organized in a logical progression?
- **Signposting** — Do introductions and transitions guide the reader?
- **Length appropriateness** — Is each section the right length (not too dense or sparse)?
- **Abstract/Executive Summary** — Does it capture the essence effectively?
- **Conclusions** — Does it reinforce key takeaways and next steps?

## Customizing the Rubric

Users can customize evaluation criteria in three ways:

1. **Inline during review:** "Focus more on [X]" or "Skip [Y]"
2. **Provide a custom rubric file:** Point to a file with alternative criteria
3. **Voice/tone guidance:** "Use a [formal/casual/aggressive] editorial voice" or "This is for [academic/VC/government] audience"

## Procedure

1. **Look for a criteria file** in the same directory as the document(s) or in a location specified by the user:
   - Default location: `criteria.md` in the same directory as the document
   - User can specify: `/whitepaper-review --criteria=path/to/criteria.md document.md`
   - If no criteria file exists, **STOP and ask the user to create one** using the CRITERIA_TEMPLATE.md as a guide
2. **Read the criteria file** to understand the evaluation requirements, target audience, goals, and constraints.
3. **Read the document(s)** fully to understand the content, structure, and goals.
4. **Clarify any remaining context** with the user:
   - Are there specific sections of concern?
   - Should you use a particular editorial voice?
   - Any additional context not in the criteria file?
5. **Incorporate user-provided criteria** from the criteria file into your evaluation framework alongside the standard rubric.
6. **Evaluate against the rubric** systematically, taking notes on each criterion.
7. **Identify patterns** — Are there recurring issues (e.g., passive voice throughout, weak transitions)?
8. **Ask probing questions** when you identify issues but lack the context to suggest specific fixes.
9. **Prioritize feedback** — Focus on high-impact changes first.
10. **Generate the report** using the format below.

## Report Format

The report should have four sections:

### A. Alignment with User-Provided Criteria (from criteria.md)

First, summarize the criteria from the user's criteria file:

```
## Criteria Summary (from criteria.md)

**Target audience:** <from criteria file>
**Primary goal:** <from criteria file>
**Specific judging criteria:** <list from criteria file>
```

Then evaluate how well the document addresses each criterion:

```
## Alignment Assessment

For each criterion provided by the user:

**[Criterion Name]:** [Score: Strong/Adequate/Weak/Missing]
- Current status: <Brief assessment>
- Gap: <What's missing or needs improvement>
- Priority: <High/Medium/Low>

**Overall alignment:** <Summary of how well the document meets the specified criteria>
```

### B. Executive Summary
A brief (3-5 sentence) high-level assessment:
- Overall strength of the document
- 2-3 major strengths
- 2-3 critical improvements needed
- Overall readiness level (e.g., "Ready with minor edits", "Needs substantial revision")
- **How well it addresses user-provided criteria**

### C. Rubric Scorecard
Present scores and brief rationale for each category:

```
## Rubric Evaluation

### Technical Credibility: [Score/10]
**Strengths:** <1-2 sentences>
**Improvements needed:** <1-2 sentences>

### Narrative & Readability: [Score/10]
...

[Repeat for all categories]

### Overall: [Weighted Score/10]
```

### D. Detailed Feedback with Suggested Edits

Organize feedback by priority: **Critical**, **High Impact**, **Medium Impact**, **Minor Polish**, **Questions for Author**.

For each item, provide:
1. **Location:** Section, page, or paragraph identifier
2. **Issue:** What's wrong and why it matters
3. **Suggested revision OR probing questions:** One of three formats:
   - **Simple edits:** Sentence-by-sentence changes using before/after format
   - **Complex edits:** Full copy-paste-ready replacement paragraphs/sections
   - **Probing questions:** Questions to ask the author when you need more context

#### Format for Simple Edits:
```
**[Section Name] — [Issue Type]**

Location: [Section/paragraph identifier]
Issue: <Brief explanation of the problem and why it matters>

Changes:
- **Original:** "The model was trained on data."
  **Revised:** "We trained the model on 10M samples spanning 2020-2025."

- **Original:** "Results are good."
  **Revised:** "Our approach achieves 15% higher accuracy than the current state-of-the-art baseline."
```

#### Format for Complex Edits:
```
**[Section Name] — [Issue Type]**

Location: [Section/paragraph identifier]
Issue: <Explanation of why this section needs substantial rewriting>

**REPLACE THIS SECTION:**

[Copy the entire original section verbatim]

**WITH:**

[Provide the complete rewritten section, ready to copy-paste]

**Key changes made:**
- <Bullet list of the main improvements>
```

#### Format for Probing Questions:
```
**[Section Name] — Needs Clarification**

Location: [Section/paragraph identifier]
Issue: <What's unclear, unsupported, or missing>

**Questions for the author:**
1. <Specific question to gather information>
2. <Follow-up question if needed>
3. <Additional question if needed>

Once you provide this information, I can suggest specific revisions.
```

### E. Positive Highlights

Always include a section celebrating what's working well:
```
## What's Working Well

- <Specific example of strong writing/argumentation>
- <Another positive element worth preserving>
- <Effective figure/table/visualization>
```

This helps the author know what to preserve during revisions.

## Editorial Voice Guidelines

Default to a **constructive, senior editor** voice:
- Direct but respectful
- Focused on impact and clarity
- Assumes the author is competent and wants honest feedback
- Balances criticism with recognition of strengths

Adjust based on user preference:
- **Formal/Academic:** More measured language, focus on rigor and citations
- **Startup/VC:** Emphasize impact, disruption, and market opportunity
- **Government/Agency:** Stress reliability, risk mitigation, and public benefit

## Probing Questions

When you identify an issue but don't have enough information to suggest a specific fix, **ask the author clarifying questions** instead of guessing. This is especially important when:

- A section lacks detail but you don't know what specifics to recommend
- Claims need support but you're unsure what evidence the author has available
- Context is missing that would help you understand the intent
- Multiple approaches could work and the choice depends on strategy or constraints

**Format for probing questions:**
```
**[Section Name] — Needs Clarification**

Location: [Section/paragraph identifier]
Issue: <What's unclear or missing>

**Questions for the author:**
1. <Specific question to help you provide better guidance>
2. <Another question if needed>
3. <Optional third question>

Once you clarify this, I can provide specific revision suggestions.
```

**Example:**
```
**Section 3.2 — Needs Clarification**

Location: "Past Performance" paragraph
Issue: The section mentions "successful deployments" but provides no concrete examples. Generic claims reduce credibility.

**Questions for the author:**
1. Can you provide 2-3 specific examples from past deployments with metrics (e.g., "Deployed system X for Client Y, achieving Z% improvement")?
2. Are there any case studies, testimonials, or published results you can reference?
3. If details are confidential, can you at least provide anonymized metrics or industry sectors?

Once you clarify this, I can help craft a more compelling narrative with specific evidence.
```

## Guardrails

- **Read-only:** Do NOT use Edit or Write tools on the source document
- **No direct file modifications:** All suggestions must be provided in the report for manual application
- **Be specific:** Vague feedback like "improve this section" is not helpful
- **Ask when uncertain:** If you can't provide actionable suggestions due to missing context, ask probing questions instead
- **Preserve author's voice:** Edits should improve clarity while maintaining the original style where appropriate
- **Copy-paste ready:** For complex edits, provide the ENTIRE rewritten section, not just fragments
- **Quote accurately:** When showing originals, quote them exactly as they appear
- **Flag assumptions:** If you're uncertain about terminology or intent, note it
- **Don't invent facts:** If a section lacks detail, suggest what *type* of information to add, but don't fabricate specifics
- **Respect scope:** Don't suggest major restructuring unless the document truly needs it

## Example Invocations

- `whitepaper-review white_paper/main.md` — Review document (looks for `white_paper/criteria.md`)
- `whitepaper-review --criteria=custom_criteria.md white_paper/main.md` — Use specific criteria file
- `whitepaper-review white_paper/` — Review all documents in directory (looks for `white_paper/criteria.md`)

**Important:** The skill requires a `criteria.md` file. If it doesn't exist, you'll be asked to create one using CRITERIA_TEMPLATE.md as a guide.

## Tips for Users

To get the most value from this skill:

1. **Provide context upfront:** Tell the reviewer who will read this and what decision they'll make
2. **Identify concerns:** If you're worried about specific sections, say so
3. **Set the tone:** Let the reviewer know if you want gentle suggestions or aggressive red-penning
4. **Iterate:** Use this skill multiple times as the document evolves
5. **Cherry-pick edits:** You don't have to accept all suggestions — use judgment

## Customization for This Project

Given that this skill is in the FROG project context, the reviewer will automatically:
- Recognize FROG-specific terminology (ContiFormer, CT-MHA, GMMs, etc.)
- Understand continuous-time transformers and Neural ODEs
- Appreciate the marine/air/land tracking use case
- Know the competitive landscape for foundation models in spatiotemporal prediction

If reviewing FROG white papers, the reviewer will assess whether the document effectively communicates:
- The novelty of continuous-time attention
- The advantages over discrete-time approaches
- The uncertainty quantification capabilities
- The multimodal fusion potential
- Real-world deployment readiness
