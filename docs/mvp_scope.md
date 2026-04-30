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

# ⚠️ 2. Current Scope Rule

> Keep the current playable loop stable before expanding any system further.

The project has moved past the first tiny MVP. Several formerly placeholder systems now have lightweight runtime behavior. They should stay simple unless a later task explicitly deepens them.

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
* Projectile-based attacks
* Weapon data can change damage, fire interval, range, speed, projectile count, and spread
* Hero facing follows combat range:

  * face the nearest enemy only when that enemy is inside current weapon range
  * face movement direction when no enemy is inside current weapon range

---

## Enemy

* Simple enemy variants: normal, fast, tank, boss
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
* +Max HP / restore HP
* Projectile speed, range, and count

---

## Game Over

* Player HP reaches 0
* Show Game Over screen
* Restart possible

---

## Lightweight Runtime Systems

These are real now, but intentionally shallow:

* Weapon selection and weapon stats
* Pet companion follow/attack behavior
* Mission progress text
* Boss wave support
* Soft currency, starter unlocks, and permanent upgrade persistence
* Mock inventory equip flow for armor/accessory presentation

Do not turn these into deep systems unless a later task explicitly calls for it.

---

# 🧱 4. UI-ONLY (PLACEHOLDER SYSTEMS)

These remain visible in UI but are not full gameplay systems:

## Hero System

* Show hero list
* Only starter hero is unlocked by default
* Locked heroes can be previewed but cannot be confirmed until unlocked

---

## Weapon System

* Show equipment slots
* Starter weapon is unlocked by default
* Additional weapon definitions exist, but unlock/economy depth is not complete

---

## Pet System

* Show pet list
* Starter pet is active
* Locked pets can be previewed but cannot be confirmed until unlocked

---

## Inventory

* Show UI
* Mock items only
* Armor/accessory equip presentation does not yet apply gameplay stats

---

## Loot System (Advanced)

* No real item drops
* XP is real
* Scrap/currency rewards are lightweight progression hooks

---

## Boss System

* Boss waves exist
* Boss Rush mode and deeper boss mechanics remain placeholder

---

## Meta Progression

* Basic persistence exists for starter unlocks, currency, inventory, and permanent upgrade ranks
* Shop/economy/unlock flow remains placeholder

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
* Full economy/shop system
* Complex save migrations

---

# 🧠 6. Simplification Rules

Always choose:

* simple logic over flexible systems
* simple JSON content data over complex config systems
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

The current playable vertical slice is complete when:

* Player can move
* Player auto shoots
* Enemies spawn and chase
* Zombies die
* XP is collected
* Player levels up
* Player dies
* Game restarts
* Basic hub/loadout/progression state remains stable

---

# ⚠️ 10. Common Mistakes

Do NOT:

* Add a second weapon architecture
* Expand enemy behavior into pathfinding or complex AI
* Present placeholder systems as finished
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
