# STEP 14 — Add Pet System

## 🎯 Goal

Introduce a **simple pet system** that provides passive support during gameplay.

This step improves:

* gameplay variety
* player assistance
* build diversity

---

# 🧠 Core Principle

> Pets should add support and flavor, not complexity.

---

# 🧩 Scope of This Step

You must implement:

* basic pet data structure
* pet selection integration (UI already exists)
* at least 1–2 working pets
* simple pet behavior
* pet presence in gameplay

You must NOT implement:

* multiple pet slots
* pet leveling system
* pet skill trees
* advanced AI behavior
* pet equipment system

---

# 🐾 Pet System Purpose

Pets act as **passive companions** that:

* assist the player
* enhance gameplay
* provide small but noticeable benefits

---

# 📊 Pet Data

Each pet should define:

```text id="482170"
Pet
- id
- name
- description
- type
- behavior
- effect
- unlocked
```

---

# 🧩 Pet Types (MVP)

Implement 1–2 simple types:

---

## 1. Attack Pet

### Behavior

* follows the player
* periodically attacks nearby enemies

### Purpose

* adds extra damage
* helps clear enemies

---

## 2. Support Pet (optional)

### Behavior

* follows the player
* provides passive bonus

### Examples

* +XP gain
* +pickup range
* small heal over time

---

# 🧠 Pet Behavior Rules

## Movement

* pet follows player at a fixed distance
* simple follow logic only
* no pathfinding

---

## Attack (if applicable)

* periodic attack
* simple targeting:

  * nearest enemy
* reuse projectile system if possible

---

# ⚙️ Implementation Strategy

## Keep It Simple

* reuse existing systems (projectile, targeting)
* avoid new complex logic
* use basic timers for behavior

---

## Example Logic

```text id="482171"
every X seconds:
    find nearest enemy
    perform action (attack or buff)
```

---

# 🎮 Gameplay Integration

## Rules

* pet is active during gameplay
* pet follows player automatically
* pet effect is always active

---

## Restrictions

* only 1 pet active (MVP)
* no switching mid-run

---

# 🎨 UI Integration

Use existing Pet Select screen.

## Requirements

* show pet list
* show pet name and description
* show locked/unlocked state
* allow selecting a pet

---

## Behavior

* selected pet is used in next run
* locked pets cannot be selected

---

# 💾 Save / Meta Integration

If meta progression exists:

* pet unlock state must persist
* selected pet must persist if needed

Keep it simple.

---

# ⚠️ Avoid

Do NOT:

* create complex AI
* create multiple pet interactions
* build pet upgrade systems
* overdesign pet behaviors

---

# 🧠 Simplification Rules

Always choose:

* one behavior per pet
* passive effects over active complexity
* reuse existing code over new systems

---

# 📱 Mobile Consideration

* pet must be clearly visible but not distracting
* avoid too many particles/effects
* keep performance light

---

# 🤖 Codex Instructions

* Reuse existing gameplay systems
* Keep pet logic minimal
* Use simple timers and direct logic
* Avoid creating new architecture layers
* Focus on visible gameplay impact

---

# 📦 Deliverables

Provide:

1. pet data definitions
2. pet selection integration
3. pet follow logic
4. pet behavior implementation
5. summary of pet effects

---

# 🎯 Acceptance Criteria

This step is complete when:

* player can select a pet
* pet appears in gameplay
* pet follows the player
* pet provides a visible effect
* system remains simple and stable

---

# 🧠 Final Principle

> A pet should feel helpful, not complicated.

---
