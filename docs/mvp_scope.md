# 🎯 MVP SCOPE DOCUMENT

## 🧟 Zombie Survival (2.5D)

---

# 🧠 1. Purpose

Define exactly:

* What is implemented NOW
* What is UI-only (placeholder)
* What is NOT touched yet

This prevents:

* scope creep
* overengineering
* wasted effort

---

# ⚠️ 2. Core Rule

> If it is not in MVP, it must NOT be implemented now.

It can exist in UI, but not in logic.

---

# 🧩 3. MVP Gameplay (ONLY THESE ARE REAL)

## Player

* Movement (X/Z plane only)
* Basic stats:

  * HP
  * Speed

---

## Camera

* Fixed angle
* No rotation
* Follow the hero with a fixed offset
* No camera rotation during gameplay

---

## Map

* Large bounded repeated map
* Reuse a small ground tile around the hero
* Play area uses a fixed physical radius, default 600 meters
* Keep collision and terrain logic simple

---

## Combat

* Auto shooting
* Single projectile type
* Basic damage

---

## Enemy

* One zombie type only
* Simple behavior:

  * move toward player
  * damage on contact
  * recycle near the hero when too far away

---

## Wave System

* Continuous spawn
* Gradual increase

---

## XP System

* Enemy drops XP
* Player collects XP
* XP drop increases with the current game level

---

## Level Up

* Gain XP → level up
* Choose 1 of 3 upgrades

---

## Upgrade Types (LIMITED)

* +Damage
* +Fire Rate
* +Speed

---

## Game Over

* Player HP reaches 0
* Show Game Over screen
* Restart possible

---

# 🧱 4. UI-ONLY (PLACEHOLDER SYSTEMS)

These must exist in UI but have no real logic:

## Hero System

* Show hero list
* Only 1 usable
* Others locked / coming soon

---

## Weapon System

* Show equipment slots
* Only 1 weapon actually used

---

## Pet System

* Show pet list
* No real behavior

---

## Inventory

* Show UI
* Mock items only

---

## Loot System (Advanced)

* No real item drops
* Only XP is real

---

## Boss System

* No boss in MVP

---

## Meta Progression

* No persistent upgrades

---

## Multiple Game Modes

* Only Survival mode works

---

# 🚫 5. NOT INCLUDED AT ALL

Do NOT implement:

* Multiplayer
* Networking
* Complex physics
* Pathfinding system
* Skill trees
* Crafting system
* Economy/shop system
* Save/load complexity

---

# 🧠 6. Simplification Rules

Always choose:

* simple logic over flexible systems
* hardcoded values over config systems (for MVP)
* one system over many variations

---

# 📊 7. Technical Scope

## Allowed Complexity

* Simple scripts
* Direct logic
* Minimal abstraction

---

## Forbidden Complexity

* Generic system frameworks
* Plugin systems
* Deep inheritance structures

---

# 🚀 8. Development Order

## Step 1

* UI skeleton (all screens)

## Step 2

* Player + camera

## Step 3

* Enemy + movement

## Step 4

* Shooting + projectile

## Step 5

* XP + leveling

## Step 6

* Game over + restart

---

# 🎯 9. MVP Definition

The MVP is complete when:

* Player can move
* Player auto shoots
* Zombies spawn and chase
* Zombies die
* XP is collected
* Player levels up
* Player dies
* Game restarts

---

# ⚠️ 10. Common Mistakes

Do NOT:

* Add second weapon system
* Add more enemy types
* Add UI logic for non-MVP systems
* Try to complete all features at once

---

# 🧠 11. Decision Rule

If unsure:

> "Does this improve the core loop right now?"

If NO → do not implement.

---

# 🔥 Final Note

This MVP is intentionally small.

The goal is:

> **Playable first, expandable later**

---
