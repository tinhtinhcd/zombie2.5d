# 🧠 MASTER GAME DESIGN

## 🧟 Zombie Survival (2.5D)

---

# 🎯 1. Design Goal

Build a zombie survival game with:

* Modular systems
* Strong progression
* Replayable gameplay loop
* Expandable architecture

---

# 🧩 2. Core Gameplay Loop

```text
Enter Run → Survive → Kill → Loot → Upgrade → Get Stronger → Die → Repeat
```

---

# 🧊 3. Game Type

* 2.5D (3D world + fixed camera)
* Top-down / angled view
* Session-based survival (roguelite)

---

# 🧍 4. Hero System

## Purpose

Define player identity and playstyle

## Features

* Multiple heroes
* Each hero has:

  * Base stats
  * Unique skill (active or passive)

## Data Model

```text
Hero
- id
- name
- base_hp
- base_speed
- base_damage
- skill
```

## Future

* Hero unlock system
* Hero progression
* Skill upgrade

---

# 🔫 5. Weapon System

## Purpose

Primary combat variation

## Features

* Multiple weapons
* Each weapon defines:

  * Fire rate
  * Damage
  * Projectile type
  * Special effect

## Data Model

```text
Weapon
- id
- type
- damage
- fire_rate
- projectile
- modifiers
```

## Future

* Weapon upgrades
* Weapon rarity
* Weapon-specific abilities

---

# 🐾 6. Pet System

## Purpose

Provide passive support

## Features

* Companion entity
* Autonomous behavior:

  * attack
  * buff
  * collect

## Data Model

```text
Pet
- id
- type
- behavior
- bonus
```

## Examples

* Attack drone
* XP collector
* Buff pet

---

# 🎁 7. Loot & Item System

## Purpose

Reward and progression

## Loot Types

* XP
* Health
* Buff item
* Equipment

## Data Model

```text
Item
- id
- type
- rarity
- effect
```

---

# 🎒 8. Inventory & Equipment

## Purpose

Manage loadout

## Features

* Equipment slots:

  * weapon
  * armor
  * accessory
* Inventory storage
* Equip / unequip

---

# ⚔️ 9. Combat System

## Mechanics

* Auto targeting
* Projectile-based attacks
* Damage calculation
* Hero facing uses weapon range:

  * nearest enemy inside weapon range takes facing priority
  * movement direction controls facing when enemies are outside weapon range

## Flow

```text
Shoot → Hit → Reduce HP → Enemy dies → Drop loot
```

---

# 🧟 10. Enemy System

## Types

* Basic zombie
* Fast zombie
* Tank zombie
* Boss

## Behavior

* Move toward player
* Attack on contact

## Scaling

* HP increases
* Speed increases
* Spawn rate increases

---

# 👑 11. Boss System

## Features

* Spawn at milestones
* High HP
* Special abilities

## Purpose

* Break gameplay monotony
* Increase challenge

---

# 🌊 12. Wave System

## Behavior

* Continuous spawn
* Increasing difficulty

## Variables

* spawn_rate
* enemy_count
* difficulty_multiplier

---

# 📈 13. Progression System

## In-run Progression

* Gain XP
* Level up
* Choose upgrade

## Upgrade Types

* +Damage
* +Fire rate
* +Speed
* Special effects

---

# 🧭 14. Game Flow (UI Driven)

```text
Main Menu
→ Mode Select
→ Hero Select
→ Equipment Select
→ Pet Select
→ Gameplay
→ Upgrade
→ Game Over
→ Result
```

---

# 🎮 15. Game Modes

## Current

* Survival

## Future

* Endless
* Challenge
* Boss rush

---

# 💾 16. Meta Progression

## Features

* Unlock heroes
* Unlock weapons
* Persistent upgrades

---

# ⚙️ 17. System Priority (CRITICAL)

## MVP (build first)

* Player
* Enemy
* Shooting
* Wave
* XP
* Game Over

---

## Phase 2

* Weapon system
* Upgrade system

---

## Phase 3

* Hero system
* Loot system

---

## Phase 4

* Pet system
* Inventory
* Boss

---

# ⚠️ 18. Design Constraint

This design is intentionally larger than MVP.

Must be implemented in layers.

---

# 🧠 19. Design Strategy

Start simple:

```text
Minimal survival loop
```

Then expand into:

```text
Full RPG-like system
```

---

# 🔥 20. Key Principle

> Systems must be modular and replaceable

---

# 🧠 Final Note

This document represents the **extracted design from existing repos**, not a new design.

---
