---
name: data-visualisation-expert
description: Use when planning or reviewing a dashboard or KPI panel whose purpose is unclear, whose metric list keeps growing, or whose audience is mixed, to question each metric against the decision it serves before anything is built.
---

# Data visualisation expert

Turn business requirements into dashboards where every element earns its place. Rather than building what is asked, question the request until each metric maps to a specific decision someone will make. For chart form, colour and marks, load the `dataviz` skill; this skill decides what belongs on the screen, not how it is drawn.

Use it when designing a new dashboard, reviewing one that feels cluttered or aimed at the wrong audience, or answering a request to add "just one more KPI". It is not for charting-library syntax or for restyling inside a design that is already approved.

## Phase 1: question the Product Owner

Ask these before recommending any layout or chart. A dashboard designed without a confirmed purpose tends to be rebuilt once people start using it, so this is the cheapest point to find out what it is for.

| Focus | Question | Principle |
|---|---|---|
| Purpose and action | What decision will the user make right after viewing this? | Every screen has one job |
| Essentials | If the user had 10 seconds, which three metrics must they see? What happens if we remove the rest? | Less is more |
| Context | How will the user know whether this metric is good or bad without a target, baseline or benchmark? | Numbers need anchors |
| Geography | Does location change the action taken, or is a map just interesting to look at? | Every chart justifies itself |
| Next question | After the overview, what does the user ask first, and which filter or drill-down answers it? | Design for the second question |
| Audience | Who actually uses this? Are we serving executives and floor managers on one screen? | One audience per dashboard |
| Time | Which decision cycle (daily, weekly, monthly) does this support? | Granularity follows the decision, not the data |

## Structure

- Put the single most important number top-left and let the rest read top-left to bottom-right, because that is the order people scan.
- State the time window on every view, and match trend granularity to the decision cycle from Phase 1.

## Scope control

- **Push back on "one more KPI".** If a metric does not serve the dashboard's primary decision, say so plainly: "We don't need to present this." Each extra tile dilutes the ones that matter.
- **One audience per dashboard.** When two roles need different answers, propose separate views or role-based tabs rather than one screen that serves neither well.
- **Removal is a valid recommendation.** In a review, name what to cut before suggesting anything to add.

## Common mistakes

| Mistake | Fix |
|---|---|
| Building what the Product Owner asked for without testing its purpose | Run Phase 1 first; it is far cheaper than a rebuild |
| Adding a map because it looks impressive | Ask the geography question explicitly |
| A KPI with no target or baseline | Add a goal line, historical average or benchmark |
| Dual-axis charts | Split into two charts |
| Several roles served on one screen | Separate views or role-based tabs |
| No path to the second question | Add the filter or drill-down that answers it |
