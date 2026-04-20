# 🧠 MASTER GAME DESIGN DOCUMENT

## 🧟 Zombie Survival – Unified Design (Extracted from Existing Repositories)

---

# 🎯 1. Design Philosophy

This game combines:

* Modular RPG systems (Hero / Weapon / Pet / Items)
* Fast-paced survival gameplay
* Scalable progression systems

Design goal:

> Build a **simple core loop first**, then expand into a **system-rich survival RPG**

---

# 🧩 2. Core Gameplay Layer (MVP)

## Core Loop

```text
Move → Shoot → Kill → Gain XP → Level Up → Upgrade → Survive → Repeat
```

## Systems Included (MVP Only)

* Player movement
* Auto shooting
* Enemy spawning
* Basic XP system
* Simple upgrades
* Game over

---

# 🧍 3. Hero System

## Concept

Player selects a hero with unique base stats and traits.

## Structure

* Hero ID
* Base stats:

  * HP
  * Speed
  * Damage
  * Fire Rate
* Passive ability (optional)

## Future Expansion

* Active skills
* Skill tree
* Hero progression (meta)

---

# 🔫 4. Weapon System

## Concept

Weapons define how the player attacks.

## Core Properties

* Damage
* Fire Rate
* Projectile Type
* Range

## Types

* Basic gun
* Shotgun (spread)
* Laser (continuous)
* Explosive (AOE)

## Upgrade Paths

* Increase damage
* Increase fire rate
* Add special effects (pierce, bounce, explode)

---

# 🐾 5. Pet System

## Concept

Pets act as support units for the player.

## Behaviors

* Attack nearby enemies
* Provide buffs
* Collect items (optional)

## Design Direction

* Passive companion system
* Simple AI (follow + act)

---

# 🎁 6. Item / Loot System

## Loot Types

* XP drops
* Health pickups
* Buff items
* Equipment

## Behavior

* Drop from enemies
* Random spawn
* Player collects via collision

## Inventory (Future)

* Equipment slots
* Consumables

---

# 🧠 7. Skill & Upgrade System

## Level-Up Upgrade (Run-Based)

Player chooses 1 of 3:

* +Damage
* +Fire Rate
* +Speed
* +HP

## Advanced (Future)

* Skill tree
* Weapon-specific upgrades
* Pet upgrades

---

# 🧟 8. Enemy System

## Basic Enemy

* Chase player
* Simple AI

## Variants

* Fast zombie
* Tank zombie
* Ranged zombie
* Boss

## Scaling

* HP increases
* Speed increases
* Spawn rate increases

---

# 👑 9. Boss System

## Concept

Special enemies appearing at milestones.

## Behavior

* Higher HP
* Unique attack patterns
* Reward drops

---

# 🌊 10. Wave / Survival System

## Modes

### Endless Mode

* Infinite survival

### Round-Based Mode (Inspired by all_alone)

* Clear wave → short break → next wave

## Scaling Logic

* Enemies per wave increase
* Difficulty ramps gradually

---

# 🏠 11. Game Flow / UI System

## Flow

```text
Main Menu
 → Mode Select
 → Hero Select
 → Equipment Select
 → Gameplay
 → Game Over
```

## UI Components

* HUD (HP, XP, Level)
* Upgrade selection screen
* Inventory (future)
* Game over screen

---

# 📈 12. Progression System

## Run-Based Progression

* XP
* Level
* Temporary upgrades

## Meta Progression (Future)

* Unlock heroes
* Unlock weapons
* Permanent upgrades

---

# ⚙️ 13. System Layers (IMPORTANT)

## Layer 1 – Core (MVP)

* Player
* Enemy
* Shooting
* XP
* Wave

## Layer 2 – Expansion

* Weapon system
* Hero system
* Upgrade system

## Layer 3 – Advanced

* Pet system
* Inventory
* Boss
* Meta progression

---

# 🎨 14. Visual Direction

* Pixel art (top-down)
* Clear readability
* Consistent scale (32x32 or 64x64)

---

# 🔊 15. Audio Direction

* Minimal SFX
* Feedback-driven sounds:

  * hit
  * shoot
  * death

---

# 🤖 16. AI-Friendly Design Rules

* Systems must be modular
* Avoid deep dependencies
* Prefer simple logic
* One feature per task

---

# ⚠️ 17. Scope Control (CRITICAL)

## DO NOT INCLUDE in MVP

* Multiplayer
* Complex inventory
* Deep skill tree
* Network systems
* Full meta progression

---

# 🎯 18. Development Strategy

## Step 1

Build playable core

## Step 2

Add progression

## Step 3

Add depth

---

# 🧠 Final Insight

This project already contains **rich design ideas**.

The goal is NOT to add more ideas.

The goal is:

> Extract → Simplify → Prioritize → Build

---
