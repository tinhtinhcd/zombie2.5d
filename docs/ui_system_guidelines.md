# 🎨 UI SYSTEM GUIDELINES

## 🧟 Zombie Survival (2.5D)

---

# 🎯 1. Purpose

Define how UI must be built to ensure:

* Visual consistency
* Clean layout
* Mobile-friendly design
* Reusable components
* AI-generated UI is not messy

---

# 🧱 2. Core UI Technology

## MUST USE

* Godot `Control` nodes for all UI
* Layout containers:

  * `VBoxContainer`
  * `HBoxContainer`
  * `MarginContainer`
  * `ScrollContainer`
  * `GridContainer`
* `CanvasLayer` for UI overlay

---

## MUST NOT USE

* Raw `Node2D` for UI layout
* Absolute positioning everywhere
* Mixing 2D nodes with UI nodes

---

# 🎨 3. Theme System

## Use a shared Theme

* One global Theme file
* Applied to all UI screens

---

## Theme defines

* Font
* Font size
* Button style
* Panel style
* Colors

---

## Rules

* Do not style UI per screen
* Do not hardcode colors in scripts
* Use Theme consistently

---

# 🧩 4. UI Asset Strategy

## Use ONE UI asset pack

Recommended:

* Kenney UI Pack
* OR one consistent fantasy/pixel UI pack

---

## Do NOT

* Mix multiple UI styles
* Use default Godot buttons
* Use inconsistent icons

---

# 📐 5. Layout Rules

## General Layout

* Use containers for structure
* Avoid manual positioning
* Maintain spacing consistency

---

## Spacing

* Small spacing: 8px
* Medium spacing: 16px
* Large spacing: 24–32px

---

## Alignment

* Center major elements
* Use consistent margins
* Keep UI readable

---

# 📱 6. Mobile First Design

## Requirements

* Large buttons
* Easy touch targets
* Clear hierarchy
* Minimal clutter

---

## Avoid

* Tiny buttons
* Dense text
* Overlapping UI

---

# 🧩 7. Screen Structure Pattern

Each screen should follow:

```text id="v9e8jp"
Root (Control)
 ├── Header (title / back button)
 ├── Content (main UI)
 └── Footer (actions)
```

---

# 🔘 8. Button Design

## Buttons must have:

* Normal state
* Hover / focus state
* Pressed state
* Disabled state

---

## Disabled buttons

* Must still be visible
* Use lower opacity or grayscale
* Show tooltip or popup if needed

---

# 🧩 9. Placeholder Design

## For unfinished features

Use:

* "Coming Soon" label
* Disabled interaction
* Placeholder popup

---

## Rule

> Never remove UI for unfinished features

---

# 📦 10. Data-Driven UI

UI must read from data.

Example fields:

```json id="f6p1ya"
{
  "id": "weapon_basic",
  "name": "Basic Gun",
  "unlocked": true,
  "implemented": true
}
```

```json id="g9a2mz"
{
  "id": "pet_drone",
  "name": "Drone",
  "unlocked": false,
  "implemented": false
}
```

---

## Behavior

* implemented = false → show placeholder
* unlocked = false → show locked state

---

# 🧭 11. Navigation Rules

* Every screen must have a back button
* No dead-end screens
* Navigation must always work

---

# 🔄 12. Reusable Components

Create reusable UI elements:

* Button component
* Card (hero / weapon / pet)
* Popup
* List item
* Grid item

---

# ⚠️ 13. Common Mistakes

Do NOT:

* Hardcode UI layout
* Build each screen differently
* Mix styles
* Skip states (disabled / hover)
* Ignore mobile layout

---

# 🤖 14. AI (Codex) Rules

* Use Control nodes for UI
* Use containers for layout
* Follow shared Theme
* Reuse existing UI components
* Keep UI simple and consistent
* Do not invent new styles

---

# 🎯 15. Success Criteria

UI is correct when:

* All screens look consistent
* Navigation is smooth
* UI is readable on mobile
* Placeholder systems are visible
* No screen feels "unfinished"

---

# 🧠 Final Principle

> UI must look like a complete product, even if systems are not implemented.

---
