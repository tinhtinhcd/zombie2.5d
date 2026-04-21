# STEP 12 — Add Meta Progression

## 🎯 Goal

Introduce **meta progression** (outside of a single run) to:

* increase long-term retention
* give players a reason to replay
* make the game feel like a real product

---

# 🧠 Core Principle

> A run ends, but player progress continues.

---

# 🧩 Scope of This Step

You must implement:

* persistent currency or points
* basic unlock system
* simple save/load
* at least one unlockable element

You must NOT implement:

* complex skill trees
* economy system
* shop system
* multiple currencies
* cloud save

---

# 📈 Meta Progression Types

Choose ONE simple system:

## Option A — Unlock System (Recommended)

Player unlocks:

* heroes
* weapons
* or pets

---

## Option B — Permanent Upgrade

Player gains small permanent bonuses:

* +HP
* +Damage
* +XP gain

---

## Recommendation

Start with:

> Unlock system (hero or weapon)

---

# 💰 Currency System

## Basic Idea

Player earns currency at end of run.

Example:

* coins
* points
* XP

---

## Rule

Currency is:

* earned from gameplay
* used for unlocks
* saved between runs

---

# 📊 Data Needed

Track:

```text id="604280"
MetaData
- currency
- unlocked_items
```

---

# 💾 Save System (Simple)

## Requirements

* save after each run
* load on game start

---

## Rules

* use simple file save
* no encryption
* no cloud system

---

# 🔓 Unlock System

## Example

* Hero A: unlocked
* Hero B: locked → requires currency

---

## Behavior

* UI shows locked/unlocked state
* locked items are visible but not selectable
* unlock action changes state permanently

---

# 🎮 UI Integration

Update existing UI:

## Hero Select

* show locked heroes
* show unlock cost
* allow unlock action

---

## Weapon Select (optional)

* similar logic

---

# 🧠 Simplification Rules

Always choose:

* one currency
* one unlock type
* simple conditions
* direct logic

---

# ⚠️ Avoid

Do NOT:

* build shop UI complexity
* add multiple upgrade trees
* introduce complex balancing systems
* overdesign economy

---

# 📱 Mobile Consideration

* UI must clearly show unlock state
* currency must be visible
* unlocking must be quick and satisfying

---

# 🤖 Codex Instructions

* Reuse existing UI screens
* Add minimal new UI elements
* Keep save system simple
* Avoid complex data models
* Focus on clarity over flexibility

---

# 📦 Deliverables

Provide:

1. simple save/load system
2. currency system
3. unlock logic
4. UI updates for unlocks
5. summary of meta progression flow

---

# 🎯 Acceptance Criteria

This step is complete when:

* player earns currency after a run
* currency persists between runs
* at least one item can be unlocked
* unlocked state is saved and loaded correctly
* UI reflects unlock state properly

---

# 🧠 Final Principle

> Players return when progress continues beyond a single run.

---
