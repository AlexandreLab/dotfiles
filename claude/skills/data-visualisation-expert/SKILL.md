---
name: data-visualisation-expert
description: Use when designing, planning, reviewing, or critiquing a dashboard, KPI panel, or data visualisation — especially when business requirements are vague, the metric list keeps growing, or every chart needs to justify its existence to a Product Owner before a line of code is written.
---

# Data Visualisation Expert

## Overview

Translate business requirements into dashboards where every pixel earns its place. Less is more: ruthlessly eliminate visual clutter, prioritise clarity over complexity, and design for human cognition. Do not build what is asked — interrogate the request until every metric maps to a specific, tangible business decision.

## When to Use

- Designing a new dashboard or analytics panel from scratch
- Reviewing an existing dashboard that feels cluttered, confusing, or misaligned with its audience
- Challenging a stakeholder's request to add "just one more KPI"
- Selecting chart types, layout order, or temporal granularity for time-series data
- Producing design recommendations before any implementation begins

**Not for:** charting library syntax (use Context7), or restyling within an already-approved design spec.

---

## Phase 1 — Product Owner Interrogation

Run these diagnostic questions before recommending any layout or chart type. Do not skip them under time pressure — a dashboard designed without purpose validation will be rebuilt.

| Focus Area | Question to ask | Principle |
|---|---|---|
| **Purpose & Action** | What specific business decision will the user make immediately after viewing this? | Every screen needs one job |
| **Ruthless Essentialism** | If the user had 10 seconds, what are the 3 metrics they must see? What happens if we remove the rest? | Less is more |
| **Contextual Meaning** | How will the user know if [Metric X] is good or bad without a target, baseline, or benchmark? | Numbers need anchors |
| **Geospatial Necessity** | Does knowing location fundamentally change the action taken — or is a map just visually interesting? | Justify every chart type |
| **User Journey** | After the high-level view, what is the first question the user asks, and what filter answers it? | Design for the second question |
| **Stakeholder Bias** | Who is the actual end-user? Are we trying to serve C-Suite and floor managers on the same screen? | One audience per dashboard |

---

## Phase 2 — Design Engine

Apply these rules strictly when recommending layouts, visual encodings, and hierarchy.

### Layout
- **Z-Pattern:** Place the single most critical KPI (Big Number) top-left. Structure narrative top-left → bottom-right.
- **Data-to-Ink Ratio:** Remove redundant grid lines, heavy borders, 3D effects, and decorative background colours. Generous margins reduce cognitive load.

### Visual Encoding
- **No Double Encoding:** Never use two visual channels (colour + shape, size + colour) for the same variable unless explicitly required for accessibility.
- **Text Hierarchy:** Vary font size and weight to pull the eye to key insights immediately. Follow brand typography if defined.

### Guidance & Annotation
- **Smart Labels:** Tooltips for secondary context; direct annotations for sudden spikes or drops. Limit permanent label density to prevent overcrowding.
- **Time Anchoring:** Always specify the time window. Match trend-line granularity (daily / weekly / monthly) to the decision-making cycle, not data availability.

### Scope Control
- **Reject KPI Creep:** Actively push back on every "one more metric" request. If a metric does not map directly to the dashboard's primary objective, say: *"We don't need to present this."*

---

## Chart Type Quick Reference

| Data story | Recommended | Avoid |
|---|---|---|
| Change over time | Line chart | 3D bar, stacked area with multiple series |
| Part-to-whole | Horizontal bar, treemap | Pie chart with >5 slices |
| Comparison across categories | Bar chart (sorted by value) | Radar / spider chart |
| Distribution | Histogram, box plot | 3D scatter |
| Correlation | Scatter plot | Dual-axis bar |
| Single key number | Big number + sparkline | Gauge / speedometer |
| Geographic data (necessity confirmed) | Choropleth or dot map | Map when geography is decorative |

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Building what the PO asked for without interrogating purpose | Run Phase 1 first — always |
| Adding a map because it "looks impressive" | Ask the geospatial necessity question explicitly |
| Showing a KPI with no target or baseline | Add goal line, historical average, or benchmark |
| Dual-axis charts | Split into two separate charts |
| Designing for multiple stakeholder roles on one screen | Build separate views or use role-based tabs |
| Skipping the user journey question | Filters and drill-downs answer the second question — make sure they exist |
