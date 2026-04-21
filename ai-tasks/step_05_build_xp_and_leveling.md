# STEP 05 — Build XP and Leveling

## 🎯 Goal

Add the first real progression layer to the MVP combat loop:

* XP drops from enemies
* player collects XP
* XP fills a progress bar
* player levels up
* upgrade selection appears
* player chooses 1 of 3 upgrades

This step turns the combat prototype into a real survival progression loop.

---

# 🧠 Core Principle

> Keep progression simple, visible, and satisfying.

No deep meta progression yet.
No permanent upgrades yet.
No complex skill trees yet.

---

# 🧩 Scope of This Step

You must implement:

* XP drop on enemy death
* XP pickup collection
* current XP tracking
* level tracking
* XP requirement per level
* level up trigger
* upgrade selection UI activation
* applying one chosen upgrade

You must NOT implement:

* permanent progression
* inventory-based upgrades
* hero skill trees
* reroll/shop systems
* rare upgrade systems

---

# 🏗️ Required Elements

## XP Pickup Scene

```text id="286410"
XPPickup (Area3D or Node3D)
├── CollisionShape3D
├── MeshInstance3D
```

Behavior:

* spawned when enemy dies
* collectible by player
* grants fixed XP value
* destroys itself after collection

---

## UI Updates

HUD must support:

* XP bar
* current level display

Upgrade Selection screen must support:

* 3 upgrade choices
* title
* short descriptions
* selection action

---

# 📈 XP System

## Rules

* Every killed enemy drops XP
* XP value can be fixed for MVP
* XP is collected by touching the pickup

---

## Data Needed

Track:

* current_level
* current_xp
* xp_to_next_level

---

## Level Up Rule

When:

```text id="286411"
current_xp >= xp_to_next_level
```

Then:

* increase level
* subtract or reset XP appropriately
* increase requirement for next level
* open Upgrade Selection UI

---

# 🧮 XP Scaling

Keep it simple.

Suggested MVP approach:

* Level 1 → 2: fixed XP target
* Every next level increases slightly

Use a simple formula or small hardcoded table.

Do NOT build a complex balancing system yet.

---

# 🎁 Upgrade Selection

## Rules

Show exactly 3 choices.

For MVP, allowed upgrades:

* +Damage
* +Fire Rate
* +Speed

---

## Behavior

When level up happens:

* pause combat flow if needed
* show Upgrade Selection UI
* player selects one option
* apply upgrade immediately
* return to gameplay

---

## Upgrade Requirements

Each upgrade must:

* have a title
* have a short description
* have a direct gameplay effect

---

# ⚙️ Upgrade Application

## Allowed MVP effects

### Damage Upgrade

* increase projectile damage

### Fire Rate Upgrade

* reduce shoot interval

### Speed Upgrade

* increase player move speed

---

## Rules

* upgrade effects should be immediately visible
* keep upgrade values simple
* store upgrade state in a clear place

Do NOT build a generic upgrade engine yet.

---

# 🧍 Player Progression Rules

The player must visibly feel stronger over time.

That means:

* shooting improves
* movement improves
* combat pacing feels better

---

# 🧠 Simplification Rules

Always choose:

* fixed XP values over loot rarity systems
* hardcoded upgrade list over procedural design
* one level up screen over many progression layers

---

# 📱 Mobile Consideration

* XP pickups must be visually readable
* upgrade selection must be easy to tap
* avoid overly dense upgrade text

---

# 🤖 Codex Instructions

* Work with existing files instead of recreating everything
* Only add or modify what is necessary
* Prefer simple, testable logic
* Keep progression readable and easy to verify
* Avoid building permanent progression systems now

---

# 📦 Deliverables

Provide:

1. XP pickup scene
2. XP tracking logic
3. Level tracking logic
4. Upgrade selection integration
5. Upgrade application logic
6. HUD updates for XP and level
7. Summary of progression flow

---

# 🎯 Acceptance Criteria

This step is complete when:

* enemies drop XP
* player can collect XP
* XP bar updates correctly
* player levels up
* upgrade selection appears
* one selected upgrade changes gameplay immediately
* gameplay feels more rewarding than pure combat only

---

# 🧠 Final Principle

> Combat makes the game playable. Progression makes the game addictive.

---
