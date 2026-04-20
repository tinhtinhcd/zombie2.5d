# 🧟 Zombie Survival (2.5D / 2D Hybrid)

A fast-paced zombie survival game focused on **gameplay loop, progression, and replayability**.
This project is designed to be **AI-assisted (Codex-driven)** where the human role focuses on **game design, balancing, and testing**, not coding.

---

# 🎯 Project Vision

This game aims to deliver a simple but addictive gameplay loop:

> **Move → Shoot → Survive → Upgrade → Repeat**

Inspired by:

* Vampire Survivors
* Brotato
* Classic zombie survival games

---

# 🧠 Development Philosophy

This project follows a unique workflow:

* ❌ No manual coding (or minimal)

* ❌ No manual art creation

* ❌ No manual audio production

* ✅ Focus on **game design**

* ✅ Focus on **gameplay feel**

* ✅ Focus on **iteration and testing**

* ✅ Use AI (Codex) for implementation

---

# 🎮 Core Gameplay

## Player

* 8-direction movement
* Auto shooting
* Stats:

  * Movement Speed
  * Fire Rate
  * Damage
  * HP

## Enemies (Zombies)

* Spawn in waves
* Move toward player
* Scale difficulty over time

## Combat

* Projectile-based shooting
* Hit detection
* Enemy death + rewards

## Progression

* Gain XP from kills
* Level up system
* Choose upgrades:

  * +Damage
  * +Fire Rate
  * +Movement Speed

## Game Loop

```text
Move → Shoot → Kill → Gain XP → Level Up → Upgrade → Stronger → More Zombies
```

---

# 🧩 Systems Overview

## GameManager

* Handles game state
* Player stats
* Score & progression

## WaveManager

* Controls enemy spawning
* Difficulty scaling

## Player System

* Movement
* Shooting
* Stat scaling

## Enemy System

* AI movement (chase player)
* Health & damage

## Projectile System

* Bullet movement
* Collision detection

## XP & Pickup System

* XP drops
* Collection logic

---

# 🏗️ Project Structure

```text
/scenes
  main.tscn
  player.tscn
  enemy.tscn
  projectile.tscn
  hud.tscn

/scripts
  player.gd
  enemy.gd
  projectile.gd
  wave_manager.gd
  game_manager.gd

/assets
  sprites/
  audio/
```

---

# 🤖 AI Development Rules (IMPORTANT)

This project is designed to work with AI agents (Codex).

## Rules:

* Modify only necessary files
* Do NOT rewrite entire systems
* Keep code simple and explicit
* Prefer readable logic over abstraction
* Follow existing naming conventions
* Avoid unnecessary refactoring

## Workflow:

1. Define feature clearly
2. Let AI implement
3. Playtest
4. Give feedback
5. Iterate

---

# 🚀 Development Roadmap

## Phase 1 — Core Gameplay

* Player movement
* Shooting system
* Basic enemies
* Collision & damage

## Phase 2 — Game Loop

* Wave system
* XP & leveling
* Game over

## Phase 3 — Progression

* Upgrade system
* Difficulty scaling

## Phase 4 — Polish

* Animation
* Effects
* Sound

---

# 🎨 Assets Strategy

* Use free assets (itch.io, Kenney, OpenGameArt)
* Keep consistent visual style
* Replace assets later if needed

---

# 📱 Target Platforms

* Android
* iOS

---

# ⚠️ Important Notes

* This project prioritizes **completion over perfection**
* Gameplay comes before visuals
* Iteration speed is critical

---

# 🔥 Goal

Ship a playable, fun, replayable zombie survival game
with minimal manual coding effort.

---

# 👤 Role Definition

## You (Human)

* Game Designer
* Tester
* Balancer

## AI (Codex)

* Developer
* Implementer
* Refactor assistant

---

# 🧠 Final Philosophy

> A fun game beats a perfect system.

---
