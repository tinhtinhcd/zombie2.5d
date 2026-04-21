# STEP 10 — Add Upgrade Depth

## 🎯 Goal

Expand the level-up system so upgrades feel more meaningful, varied, and replayable.

This step improves:

* progression depth
* build variety
* replay value

---

# 🧠 Core Principle

> Upgrades should create different playstyles, not just bigger numbers.

---

# 🧩 Scope of This Step

You must implement:

* more upgrade types
* weapon-related upgrades
* survivability upgrades
* simple stacking rules
* clearer upgrade effects

You must NOT implement:

* full skill tree
* permanent progression
* reroll/shop system
* rarity system
* complex dependency graphs

---

# 📈 Upgrade Categories

## 1. Offense Upgrades

* +Damage
* +Fire Rate
* +Projectile Count
* +Projectile Speed

---

## 2. Mobility Upgrades

* +Move Speed

---

## 3. Survival Upgrades

* +Max HP
* +Heal small amount
* +Damage reduction (optional only if simple)

---

## 4. Utility Upgrades

* +XP pickup range (optional)
* +XP gain bonus (optional)

---

# 🔫 Weapon Interaction

Upgrades must interact with the current weapon system.

Examples:

* Spread Shot becomes wider or gains extra projectile
* Rapid Gun becomes even faster
* Basic Gun becomes more powerful per shot

---

# 🧠 Upgrade Design Rules

Each upgrade must:

* have a clear name
* have a short description
* apply one obvious effect
* stack cleanly without confusion

---

# 📊 Example Upgrade Data

```text id="482640"
Upgrade
- id
- name
- description
- type
- value
```

---

# 🔄 Upgrade Selection Rules

* still show exactly 3 upgrade choices
* choices should come from a shared upgrade pool
* avoid showing duplicate upgrades in the same selection if possible

---

# ⚙️ Stacking Rules

Keep stacking simple:

* additive for damage
* additive or capped for projectile count
* multiplicative only if clearly needed
* no complex formulas

---

# 🎮 Gameplay Effect

The player should start forming builds such as:

* fast shooter
* heavy damage shooter
* spread crowd-control build
* mobile survivor build

---

# ⚠️ Avoid

Do NOT:

* create dozens of upgrades
* build synergy trees
* add overly complex conditional effects
* make upgrade descriptions vague

---

# 🧠 Simplification Rules

Always choose:

* simple stat modifiers
* direct implementation
* visible gameplay effect

---

# 📱 Mobile Consideration

* upgrade cards must remain readable
* descriptions must stay short
* avoid too much text

---

# 🤖 Codex Instructions

* Work with the existing level-up system
* Expand upgrade data and application logic
* Keep upgrades easy to test
* Avoid building a full RPG upgrade architecture

---

# 📦 Deliverables

Provide:

1. expanded upgrade pool
2. updated upgrade selection logic
3. upgrade stacking behavior
4. summary of upgrade categories
5. notes on how builds can differ

---

# 🎯 Acceptance Criteria

This step is complete when:

* level-up choices feel more varied
* upgrades create noticeably different runs
* upgrade logic remains simple and stable
* the game feels deeper without becoming complicated

---

# 🧠 Final Principle

> More upgrade depth should create more fun, not more complexity.

---
