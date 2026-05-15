# White Paper Review Skill

An editorial skill for reviewing technical white papers, proposals, and funding documents. Provides structured feedback based on a customizable rubric without directly modifying your documents.

## Quick Start (3 Steps)

### Step 1: Copy the Template
```bash
cp .claude/skills/whitepaper-review/CRITERIA_TEMPLATE.md your_directory/criteria.md
```

Or look at the example first:
```bash
cat .claude/skills/whitepaper-review/EXAMPLE_criteria.md
```

### Step 2: Fill Out Your Criteria
Edit `your_directory/criteria.md` with:
- **Target audience:** Who will read this?
- **Primary goal:** What decision should they make?
- **Specific judging criteria:** What rubric/requirements apply?
- **Additional context:** What concerns you? Past feedback?

### Step 3: Run the Review
```bash
/whitepaper-review your_directory/document.md
```
The skill automatically looks for `criteria.md` in the same directory. To use a different criteria file:
```bash
/whitepaper-review --criteria=path/to/criteria.md path/to/document.md
```

### What You'll Get

✅ **Alignment assessment** — How well does your document meet each criterion?  
✅ **Scored rubric** — Ratings on technical credibility, readability, value proposition, etc.  
✅ **Copy-paste edits** — Ready-to-use improvements for weak sections  
✅ **Probing questions** — When the reviewer needs more context from you  
✅ **Positive highlights** — What's already working well

## What This Skill Does

Reviews documents with focus on:
1. **Your specific criteria** — Evaluates against the actual rubric/requirements you'll be judged on
2. **Technical credibility** — Is the work sound and rigorous?
3. **Readability** — Can non-experts understand and stay engaged?
4. **Value proposition** — Is the investment case compelling?
5. **Competitive positioning** — Does it establish state-of-the-art status?
6. **Professional polish** — Is it error-free and well-formatted?
7. **Structure** — Is information well-organized?

The reviewer will also **ask clarifying questions** when issues are identified but more context is needed to provide actionable suggestions.

## What This Skill Does NOT Do

- ❌ Edit your files directly
- ❌ Rewrite entire documents without your input
- ❌ Invent facts or data to strengthen arguments
- ❌ Make decisions about document structure without discussion

All suggestions are provided for you to review and selectively apply.

## Customizing the Evaluation

### Option 1: Inline Guidance

Just tell the reviewer what to focus on:

```
/whitepaper-review white_paper/main.md

"Focus heavily on readability for non-experts, this is going to a mixed audience"
```

### Option 2: Custom Rubric File

Create a custom rubric file (see `examples/custom_rubric_template.md`):

```markdown
# Custom Rubric for [Your Document Type]

## Category 1: [Name] (Weight: X%)
**Goal:** [What this category evaluates]

Criteria:
- [Criterion 1]
- [Criterion 2]
...

## Category 2: [Name] (Weight: Y%)
...
```

Then invoke with:
```
/whitepaper-review --rubric=path/to/custom_rubric.md white_paper/main.md
```

### Option 3: Specify Audience/Voice

The reviewer adapts its editorial voice based on your target audience:

```
/whitepaper-review --audience=VC white_paper/main.md          # Venture capital
/whitepaper-review --audience=academic white_paper/main.md    # Academic reviewers
/whitepaper-review --audience=government white_paper/main.md  # Government agencies
```

## Before You Start: Create a Criteria File

**IMPORTANT:** This skill requires a `criteria.md` file that specifies how the document will be evaluated. 

### Creating Your Criteria File

1. **Copy the template:**
   ```bash
   cp .claude/skills/whitepaper-review/CRITERIA_TEMPLATE.md your_directory/criteria.md
   ```

2. **Fill it out with your specific requirements:**
   - Target audience and their background
   - Primary goal (secure funding, win contract, get approval)
   - Specific judging criteria (official rubric, RFP requirements, etc.)
   - Additional context (constraints, concerns, competition)

3. **Save it in the same directory as your document** (or specify path with `--criteria=`)

See:
- [CRITERIA_TEMPLATE.md](CRITERIA_TEMPLATE.md) — Blank template with common evaluation frameworks
- [EXAMPLE_criteria.md](EXAMPLE_criteria.md) — Filled-out example showing what good criteria look like

### Example Criteria Types

- DARPA BAA evaluation factors (technical merit, team qualifications, cost realism)
- VC pitch deck requirements (market size, traction, differentiation)
- Journal submission guidelines (novelty, reproducibility, significance)
- RFP scoring rubric (technical approach, past performance, price)
- Internal review board checklist

If you don't have formal criteria, describe:
- Who will read this and what's their background?
- What decision will they make based on this document?
- What are your biggest concerns or areas of uncertainty?

## Understanding the Output

### 1. Criteria Summary & Alignment Assessment
- Summary of the criteria from your `criteria.md` file
- Assessment of how well the document meets each criterion you specified
- Identified gaps and priorities

### 2. Executive Summary
A 3-5 sentence high-level assessment of document readiness.

### 3. Rubric Scorecard
Scores (out of 10) for each evaluation category with brief rationale.

### 4. Detailed Feedback
Organized by priority (Critical → High → Medium → Minor → Questions):

**For simple edits:**
```
- **Original:** "Results are good."
  **Revised:** "Our approach achieves 15% higher accuracy than baseline."
```

**For complex edits:**
```
**REPLACE THIS SECTION:**
[Full original text]

**WITH:**
[Full rewritten text — ready to copy-paste]
```

**For issues needing clarification:**
```
**Questions for the author:**
1. Can you provide specific metrics from past deployments?
2. What evidence do you have for this claim?
3. Are there case studies or references you can cite?
```

### 5. Positive Highlights
Recognition of what's working well (so you know what to keep).

## Tips for Best Results

1. **Create a detailed criteria.md file:** The more specific you are about evaluation criteria, the more targeted the feedback
2. **Include the "why" in your criteria:** Explain what concerns you most and any past feedback you've received
3. **Specify weights:** If your criteria have different importance levels, note the percentages
4. **Quote official rubrics:** If you have formal evaluation criteria, copy them exactly into your criteria file
5. **Focus the review:** Tell the reviewer if certain sections worry you more than others
6. **Answer probing questions:** When the reviewer asks clarifying questions, answer them to get specific revision suggestions
7. **Iterate:** Update your criteria.md as priorities change, and run the review multiple times as your document evolves
8. **Be selective:** You don't need to apply every suggestion

## Examples

### Example 1: Full Review

**Create `white_paper/criteria.md`:**
```markdown
## Evaluation Criteria

**Target audience:** DARPA program managers (technical background, not DL experts)

**Primary goal:** Win Phase I SBIR funding ($250K)

**Specific judging criteria:**
- Technical merit (40%): Novel approach, sound methodology, feasibility
- Team qualifications (30%): Relevant expertise and past performance
- Impact potential (20%): Military applications and transition path
- Cost realism (10%): Budget justified and reasonable

**Additional context:** We need to emphasize deployment readiness and robustness 
over bleeding-edge performance. Previous feedback said we were too academic.
```

**Run the review:**
```bash
/whitepaper-review white_paper/draft_v3.md
```

### Example 2: Focused Review

**Using the same criteria file, focus on specific sections:**
```bash
/whitepaper-review white_paper/draft_v3.md

[After it starts, tell it:]
"Only review the Results and Discussion sections. I'm worried they're too 
dense and not making the impact case clearly."
```

### Example 3: Custom Criteria Location

**Store criteria separately from the document:**
```bash
/whitepaper-review --criteria=../shared_criteria/darpa_sbir_criteria.md white_paper/final_draft.md
```

### Example 4: Quick Polish Pass

**Adjust the criteria file to focus on polish:**
```markdown
**Primary goal:** Final polish before submission

**Specific judging criteria:**
- Grammar, spelling, and punctuation
- Professional tone and clarity
- Consistent terminology and notation
- Formatting and visual polish
```

Then run:
```bash
/whitepaper-review white_paper/final_draft.md
```

## Customizing for Different Document Types

The default rubric is optimized for **technical white papers seeking funding**. You can adapt for:

### Academic Papers
Focus on: methodology rigor, literature review completeness, reproducibility, statistical validity

### Product Whitepapers
Focus on: use case clarity, feature-benefit mapping, competitive differentiation, customer pain points

### Grant Proposals
Focus on: broader impacts, team qualifications, budget justification, timeline feasibility

### Technical Blog Posts
Focus on: accessibility, engaging narrative, code examples, actionable takeaways

Create a custom rubric for your document type and save it for reuse.

## Default Rubric Weights

- Technical Credibility: 25%
- Narrative & Readability: 20%
- Value Proposition: 20%
- Competitive Positioning: 15%
- Structure & Organization: 10%
- Professional Polish: 10%

You can adjust these in a custom rubric if your priorities differ.

## Supported File Formats

- Markdown (`.md`) — native support
- Plain text (`.txt`) — native support
- LaTeX (`.tex`) — native support
- PDF (`.pdf`) — requires `/pdf` skill
- Word (`.docx`) — requires `/docx` skill

## FAQ

**Q: Will this edit my files directly?**
A: No. All suggestions are provided in a report for you to manually apply.

**Q: Can I use this for non-technical documents?**
A: Yes, but you should provide a custom rubric since the default focuses on technical white papers.

**Q: How long does a review take?**
A: Depends on document length. ~5-20 minutes for typical white papers (10-30 pages).

**Q: Can I review multiple files at once?**
A: Yes, point to a directory and the skill will ask which files to include.

**Q: What if I disagree with the feedback?**
A: That's fine! This is editorial *guidance*, not requirements. Use your judgment.

**Q: Can the reviewer check factual accuracy?**
A: It will flag claims that seem unsupported, but it won't verify facts. That's your responsibility.

**Q: Will it preserve my writing voice?**
A: Yes, suggested edits aim to improve clarity while maintaining your style.

**Q: What if the reviewer asks me questions instead of giving edits?**
A: That means it identified an issue but needs more context to suggest a fix. Answer the questions and the reviewer will provide specific revision suggestions. This is better than generic advice like "add more detail."

**Q: Do I have to answer all the probing questions?**
A: No, but the more you answer, the more actionable the suggestions will be. If you can't answer (e.g., info is confidential), say so and the reviewer will suggest alternative approaches.

## Troubleshooting

**"The suggestions are too aggressive"**
→ Ask for "gentle polish" or "minor edits only"

**"The suggestions are too vague"**
→ Ask for "specific, copy-paste-ready edits"

**"It's focusing on the wrong things"**
→ Provide explicit priorities: "Focus on [X], ignore [Y]"

**"I need formatting help, not content help"**
→ Ask for "professional polish pass only"

**"I don't know what criteria to provide"**
→ Check CRITERIA_TEMPLATE.md for examples of common frameworks, or just describe your audience and goals in your own words in the criteria.md file

**"The reviewer is asking too many questions and not giving enough edits"**
→ Answer the questions with whatever info you have, even if incomplete. The reviewer uses questions when it can't guess what you mean.

**"Can I reuse the same criteria.md for multiple documents?"**
→ Yes! Store it once and use `--criteria=path/to/criteria.md` for each review. Good for reviewing multiple drafts or related documents.

## File Structure

Your project should look like:
```
your_project/
├── white_paper/
│   ├── criteria.md          # Your evaluation criteria
│   ├── draft_v1.md          # The document to review
│   └── draft_v2.md
└── .claude/
    └── skills/
        └── whitepaper-review/
            ├── SKILL.md              # The skill definition (don't edit)
            ├── README.md             # This file
            └── CRITERIA_TEMPLATE.md  # Template to copy and customize
```

## Version History

- **v1.0** (2026-05-15): Initial release with default rubric for technical white papers
