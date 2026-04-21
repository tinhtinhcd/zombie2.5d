# STEP 16 — Add Mission System

## 🎯 Goal

Introduce a **mission system** to provide structured objectives beyond survival.

This step improves:

* player motivation
* replayability
* progression clarity

---

# 🧠 Core Principle

> Missions guide the player without restricting gameplay freedom.

---

# 🧩 Scope of This Step

You must implement:

* basic mission structure
* at least 2–3 mission types
* mission tracking
* mission completion detection
* reward system (simple)

You must NOT implement:

* complex quest chains
* branching story missions
* daily/weekly systems
* UI-heavy mission boards

---

# 🎯 Mission Types (MVP)

Implement simple and clear missions:

---

## 1. Kill Mission

* kill X enemies

---

## 2. Survival Mission

* survive X seconds

---

## 3. Boss Mission

* defeat boss

---

# 📊 Mission Data

Each mission should define:

```text
Mission
- id
- type
- target_value
- current_value
- completed
- reward
```

---

# 🎮 Mission Flow

```text
Start Run → Mission Active → Track Progress → Complete → Reward → Continue
```

---

# ⚙️ Tracking Logic

## Examples

* Kill mission:

  * increment when enemy dies

* Survival mission:

  * track time

* Boss mission:

  * trigger on boss death

---

# 🎁 Reward System

Keep simple:

* bonus XP
* or currency
* or instant upgrade

---

## Rule

* reward immediately on completion
* no delayed reward system

---

# 🎨 UI Integration

## Minimal UI

* show active mission
* show progress:

  * e.g. "Kill 50 enemies (23/50)"

---

## Behavior

* update in real-time
* show completion feedback

---

# 🧠 Simplification Rules

Always choose:

* one mission active at a time (MVP)
* clear objective
* direct tracking

---

# ⚠️ Avoid

Do NOT:

* create many missions at once
* add mission chains
* build complex UI
* add too many mission types

---

# 📱 Mobile Consideration

* mission text must be readable
* avoid clutter
* keep UI small

---

# 🤖 Codex Instructions

* Add mission tracking to existing systems
* Keep logic simple and centralized
* Avoid creating full quest framework
* Reuse existing UI

---

# 📦 Deliverables

Provide:

1. mission data structure
2. mission tracking logic
3. UI integration
4. reward handling
5. summary of mission types

---

# 🎯 Acceptance Criteria

This step is complete when:

* player has an active mission
* mission progress updates correctly
* mission completes when condition met
* reward is applied immediately
* system is simple and stable

---

# 🧠 Final Principle

> Missions give players a goal beyond survival.

---
