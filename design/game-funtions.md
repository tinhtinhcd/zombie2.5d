# 🧠 MASTER GAME DESIGN (Extracted from Existing Repos)

## 🧟 Project: Zombie Survival (Modular System Design)

---

# 🎯 1. Design Philosophy

This game is built around **modular systems**:

* Hero-based gameplay
* Weapon-driven combat
* Optional companion (pet)
* Loot & upgrade progression
* Session-based survival loop

---

# 🧩 2. Core Game Loop

```text
Enter Game → Choose Hero → Equip Loadout → Survive → Kill → Loot → Upgrade → Repeat → Die → Restart
```

---

# 🧍 3. Hero System

## Purpose

Define player identity and playstyle

## Features

* Multiple heroes
* Each hero has:

  * Base stats
  * Unique skill (active/passive)
* Hero selection before game

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

## Future Expansion

* Skill tree
* Hero leveling
* Unlock system

---

# 🔫 4. Weapon System

## Purpose

Main source of combat variation

## Features

* Multiple weapons
* Each weapon has:

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

## Systems

* Weapon switching
* Weapon upgrades
* Weapon-specific skills

---

# 🐾 5. Pet System

## Purpose

Add passive gameplay support

## Features

* Optional companion
* Auto behavior:

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

* Attack pet (shoot enemies)
* Support pet (+XP gain)
* Collector pet (auto pickup)

---

# 🎁 6. Loot & Item System

## Purpose

Reward player and create progression

## Features

* Enemies drop:

  * XP
  * items
  * rare loot

## Types

* XP pickup
* Health pickup
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

# 🎒 7. Inventory & Equipment

## Purpose

Manage player loadout

## Features

* Equipment slots:

  * weapon
  * armor
  * accessory
* Inventory storage
* Equip / unequip

---

# ⚔️ 8. Combat System

## Features

* Auto targeting
* Projectile-based
* Damage calculation
* Hit detection

## Enemy Behavior

* Chase player
* Attack on contact

---

# 🧟 9. Enemy System

## Types

* Basic zombie
* Fast zombie
* Tank zombie
* Boss

## Scaling

* HP increases
* Speed increases
* Spawn rate increases

---

# 👑 10. Boss System

## Features

* Spawn at milestone (e.g. wave 10)
* Unique abilities
* High HP

## Purpose

* Break monotony
* Skill check

---

# 🌊 11. Wave System

## Features

* Continuous spawn
* Increasing difficulty

## Variables

* spawn_rate
* enemy_count
* difficulty multiplier

---

# 📈 12. Progression System

## In-Run Progression

* XP → Level up
* Choose upgrade

## Upgrade Types

* +Damage
* +Speed
* +Fire rate
* Special effect

---

# 🧭 13. Game Flow (UI / UX)

```text
Main Menu
 → Mode Select
 → Hero Select
 → Equipment Select
 → Start Game
 → Gameplay
 → Game Over
 → Restart / Exit
```

---

# 🎮 14. Game Modes

## Current

* Survival mode

## Future

* Endless
* Challenge mode
* Boss rush

---

# 💾 15. Save & Meta Progression

## Features

* Save player progress
* Unlock heroes
* Unlock weapons

---

# ⚙️ 16. System Priority (VERY IMPORTANT)

## MVP (build first)

* Player
* Enemy
* Shooting
* Wave
* XP
* Game Over

## Phase 2

* Weapon system
* Upgrade system

## Phase 3

* Hero system
* Loot system

## Phase 4

* Pet
* Inventory
* Boss

---

# ⚠️ 17. Critical Insight

This design is **too big for MVP**

Must be implemented in layers.

---

# 🧠 18. Final Strategy

Start with:

```text
Simple survival game
```

Then gradually evolve into:

```text
Hero + Weapon + Pet + Loot system
```

---

# 🔥 Final Note

This document is NOT new design.

It is extracted and organized from:

* existing repos
* system structure
* naming patterns
* gameplay direction

---
