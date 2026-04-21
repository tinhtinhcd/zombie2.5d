# STEP 09 — Add Weapon System

## 🎯 Goal

Introduce a **basic weapon system** to increase combat variety.

This step adds:

* multiple weapons
* different shooting behaviors
* simple weapon switching

---

# 🧠 Core Principle

> Weapon variety should feel different, but implementation must stay simple.

---

# 🧩 Scope of This Step

You must implement:

* at least 2–3 weapon types
* different firing behavior per weapon
* weapon selection (simple)
* weapon stats

You must NOT implement:

* full inventory system
* weapon rarity system
* crafting system
* complex upgrade trees

---

# 🔫 Weapon Types (MVP)

## 1. Basic Gun (existing)

* single projectile
* medium fire rate
* medium damage

---

## 2. Spread Shot

### Behavior

* fires multiple bullets at once
* spread angle

### Purpose

* good for crowd control

---

## 3. Rapid Gun

### Behavior

* very fast fire rate
* lower damage per shot

### Purpose

* high DPS feeling

---

# 📊 Weapon Data

Each weapon should define:

```text id="91k3lz"
Weapon
- id
- damage
- fire_rate
- projectile_count
- spread_angle
```

---

# 🔄 Weapon Switching

## MVP Approach

* player starts with 1 weapon
* weapon can change via:

  * simple selection
  * or temporary testing button

---

## Rules

* no UI complexity yet
* no inventory logic
* keep switching simple

---

# 🔫 Shooting Behavior

Update shooting logic to:

* use current weapon stats
* spawn projectiles based on weapon config

---

## Example

* Basic: 1 bullet
* Spread: 3 bullets with angle
* Rapid: faster shoot interval

---

# 💥 Projectile Variations

Keep simple:

* same projectile scene
* different direction / count
* optional small speed variation

---

# ⚔️ Gameplay Impact

Weapon differences must:

* change combat feel
* change how player handles enemies
* improve replayability

---

# 🧠 Simplification Rules

Always choose:

* config-based weapon logic
* reuse projectile scene
* minimal branching logic

---

# ⚠️ Avoid

* building a full weapon framework
* deep class hierarchy
* dynamic weapon scripting system

---

# 📱 Mobile Consideration

* avoid too many projectiles
* limit spread count
* maintain performance

---

# 🤖 Codex Instructions

* Modify existing shooting system
* Add simple weapon configs
* Keep code readable and small
* Do not create complex weapon architecture

---

# 📦 Deliverables

Provide:

1. weapon configurations
2. updated shooting logic
3. weapon switching mechanism
4. demonstration of different weapon behaviors
5. summary of weapon differences

---

# 🎯 Acceptance Criteria

This step is complete when:

* multiple weapons exist
* weapons feel different
* shooting behavior changes correctly
* player can switch or test weapons
* gameplay feels more varied

---

# 🧠 Final Principle

> Weapons change how the game feels, not just how it works.

---
