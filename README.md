# 🧟 Zombie Survival (2.5D, AI-Driven)

A 2.5D zombie survival game built with a **UI-first approach** and **AI-assisted development (Codex)**.

This project focuses on:

* Fast gameplay iteration
* Clear product structure from the beginning
* Minimal manual coding effort

---

# 🎯 Project Vision

Create a zombie survival game that feels complete from the start:

> **Full product UI + MVP gameplay + iterative expansion**

The goal is not to build everything at once, but to:

* show the full experience early
* implement systems incrementally

---

# 🧠 Development Philosophy

## Roles

### 👤 Human (You)

* Game Designer
* System Designer
* Playtester
* Balancer

### 🤖 AI (Codex)

* Code implementation
* System integration
* Iterative updates

---

## Core Principles

* UI must be **complete from the beginning**
* Gameplay is built **in layers (MVP → expansion)**
* Unfinished systems must remain **visible in the UI**
* Use **placeholder states instead of hiding features**
* Prefer **simple, testable systems**

---

# 🧊 What is 2.5D in This Project?

This game uses:

* 3D world (characters, environment)
* Fixed camera (top-down / angled)
* 2D-like gameplay logic

### Key Rules:

* Movement only on **X/Z plane**
* No complex camera system
* No physics-heavy gameplay

---

# 🎮 Core Gameplay Loop

```text
Move → Auto Shoot → Kill Zombies → Gain XP → Level Up → Upgrade → Repeat
```

---

# 🧩 Product Structure (Full UI Flow)

```text
Main Menu
→ Play
→ Mode Select
→ Hero Select
→ Equipment Select
→ Pet Select
→ Start Game
→ Gameplay
→ Pause
→ Upgrade Selection
→ Game Over
→ Result Screen
→ Back to Main Menu
```

---

# 🧱 Systems Overview

## MVP Systems (Implemented First)

* Player movement
* Auto shooting
* Enemy spawn & chase
* Damage system
* XP & leveling
* Game over

---

## Full Systems (UI visible, logic may be placeholder)

* Hero system
* Weapon system
* Equipment system
* Pet system
* Inventory
* Loot system
* Boss system
* Meta progression

---

# 🧩 UI Strategy

All systems must be visible in the UI from the beginning.

If a system is not implemented:

* show UI normally
* disable interaction OR
* show "Coming Soon" OR
* use mock data

> ❗ Never remove UI for unfinished features

---

# 🏗️ Project Structure

```text
/scenes
  /ui
  /game

/scripts
  /ui
  /game
  /autoload

/docs
/ai_tasks
/assets
```

---

# 🎨 UI & Visual Strategy

## UI System

* Godot Control nodes
* Shared Theme
* Mobile-friendly layout

## Assets

* Use consistent 3D asset style (low poly recommended)
* Use a single UI asset pack
* Avoid mixing multiple visual styles

---

# 🤖 AI Development Rules

Codex must follow:

* Modify only necessary files
* Do not remove UI screens
* Use placeholders for unfinished systems
* Keep logic simple
* Follow existing structure and naming
* Avoid overengineering

---

# 🚀 Development Phases

## Phase 1 — UI Skeleton

* Build all UI screens
* Connect navigation
* Add placeholders

## Phase 2 — MVP Gameplay

* Core survival gameplay
* Connect gameplay to UI

## Phase 3 — System Expansion

* Weapons
* Heroes
* Equipment
* Loot

## Phase 4 — Polish

* Effects
* Animation
* Sound
* Mobile optimization

---

# ⚠️ Important Notes

* This project prioritizes **completion over perfection**
* Gameplay comes before visuals
* Iteration speed is critical
* Avoid building complex systems too early

---

# 🔥 Goal

Ship a playable zombie survival game that:

* Feels complete early
* Is expandable over time
* Requires minimal manual coding

---

# 🧠 Final Philosophy

> Build the shell first. Fill it later.

---
