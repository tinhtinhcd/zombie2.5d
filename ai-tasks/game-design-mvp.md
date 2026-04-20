# 🧠 GAME DESIGN DOCUMENT

## 🧟 Zombie Survival (AI-Driven Development)

---

# 🎯 1. Game Overview

**Genre:**
Top-down Zombie Survival / Roguelite

**Core Experience:**
Survive as long as possible against endless waves of zombies while becoming stronger through upgrades.

**Target Platform:**

* Mobile (Android / iOS)

---

# 🔥 2. Core Gameplay Loop

```text
Move → Auto Shoot → Kill Zombies → Gain XP → Level Up → Choose Upgrade → Repeat
```

### Design Goals:

* Fast-paced
* Easy to learn
* Addictive progression
* Short play sessions (5–15 minutes)

---

# 🧍 3. Player Design

## Movement

* 8-direction (WASD / joystick)
* Smooth and responsive

## Combat

* Auto shooting (no manual aiming required)
* Always targets nearest enemy

## Stats

| Stat      | Description        |
| --------- | ------------------ |
| HP        | Health points      |
| Speed     | Movement speed     |
| Fire Rate | Time between shots |
| Damage    | Damage per bullet  |

---

# 🧟 4. Enemy Design

## Basic Zombie

* Moves toward player
* Low HP
* Medium speed

## Variants (later phase)

* Fast zombie
* Tank zombie (high HP)
* Ranged zombie (optional)

## Behavior

* Simple chase AI
* Increase difficulty over time

---

# 🔫 5. Combat System

## Shooting

* Auto-fire
* Fixed interval (based on Fire Rate)

## Projectile

* Straight line movement
* Destroy on hit

## Hit Logic

* Reduce enemy HP
* Spawn XP on death

---

# 📈 6. Progression System

## XP System

* Zombies drop XP
* Player collects XP

## Level Up

* Every X XP → level up

## Upgrade Selection

Player chooses 1 of 3 random upgrades:

* +Damage
* +Fire Rate
* +Speed
* +Max HP (optional)
* Special effect (later phase)

---

# 🌊 7. Wave & Difficulty System

## Wave Logic

* Enemies spawn continuously
* Increase over time

## Difficulty Scaling

* Spawn rate increases
* Enemy HP increases
* Enemy speed increases

---

# 💀 8. Game Over

Game ends when:

* Player HP = 0

Show:

* Score
* Time survived
* Restart button

---

# 🎁 9. Reward System (Optional Phase)

* XP pickup
* Health pickup
* Rare upgrade drops

---

# 🧩 10. Systems Breakdown

## Core Systems (MVP)

* Player Movement
* Auto Shooting
* Enemy Spawning
* Collision & Damage
* XP & Leveling
* Game Over

## Advanced Systems (Later)

* Weapon system
* Upgrade tree
* Boss system
* Map variation

---

# 🎮 11. Controls

## Mobile

* Virtual joystick (movement)
* Auto shooting

## PC (dev/testing)

* WASD movement

---

# 🎨 12. Visual Direction

* Pixel art (top-down)
* Simple, readable sprites
* Clear enemy distinction

---

# 🔊 13. Audio Direction

* Minimal SFX:

  * shooting
  * hit
  * zombie death
* Background loop music

---

# ⚖️ 14. Balancing Principles

* Player should feel stronger over time
* Game should become harder continuously
* Avoid sudden difficulty spikes

---

# 🚀 15. Development Strategy

## Phase 1 (MVP)

* Core loop working

## Phase 2

* Progression & upgrades

## Phase 3

* Polish (effects, animation)

---

# 🤖 16. AI Development Strategy

## Rules for AI (Codex)

* Implement one system at a time
* Do not over-engineer
* Keep logic simple
* Reuse existing systems

## Workflow

1. Define feature clearly
2. AI implements
3. Playtest
4. Adjust values

---

# 🧠 17. Key Design Philosophy

> Simple systems + good progression = addictive gameplay

---

# 🎯 18. Success Criteria

* Game is playable within 5 minutes
* Player understands mechanics instantly
* Game becomes challenging over time
* Player wants to replay

---

# 🔥 19. Future Expansion

* Boss fights
* Skill system
* Meta progression
* Multiple maps
* Multiplayer (optional)

---

# 🧩 Final Note

This project prioritizes:

* Gameplay over visuals
* Iteration over perfection
* Simplicity over complexity

---
