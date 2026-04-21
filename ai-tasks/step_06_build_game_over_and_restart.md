# STEP 06 — Build Game Over and Restart

## 🎯 Goal

Complete the core gameplay loop by adding:

* player death condition
* game over flow
* result summary
* restart functionality

This step makes the game fully playable from start → death → restart.

---

# 🧠 Core Principle

> The game loop is complete only when the player can lose and restart instantly.

---

# 🧩 Scope of This Step

You must implement:

* player health system
* damage to player from enemies
* death condition
* game over trigger
* result screen display
* restart game
* return to main menu

You must NOT implement:

* save system
* meta progression
* revive systems
* checkpoints
* advanced scoring systems

---

# 🧍 Player Health System

## Requirements

Track:

* max_hp
* current_hp

---

## Behavior

* player takes damage on enemy contact
* HP decreases accordingly

---

## Rules

* keep damage simple (fixed value per hit)
* no armor system yet
* no damage types

---

# 💥 Damage System

## Enemy → Player

When enemy touches player:

* apply damage
* optionally use cooldown to prevent instant death

---

## Suggested Rule

* small delay between hits (e.g. 0.5–1 second)
* prevents continuous instant damage

---

# 💀 Death Condition

When:

```text id="357191"
current_hp <= 0
```

Then:

* stop gameplay
* trigger Game Over screen

---

# 🧩 Game Over Flow

## Flow

```text id="357192"
Gameplay → Player dies → Game Over Screen → Result Screen → Restart / Exit
```

---

# 📊 Game Over Screen

Must contain:

* "Game Over" title
* stats:

  * time survived
  * enemies killed (if tracked)
* buttons:

  * Restart
  * Exit

---

# 📈 Result Screen

Must contain:

* summary of run
* time survived
* total XP gained
* optional stats

---

## Behavior

* shown after Game Over OR directly combined if simpler
* Continue → Main Menu

---

# 🔄 Restart System

## Requirements

Restart must:

* reset player stats
* reset enemies
* reset XP and level
* reset timers
* reset game state

---

## Behavior

* restart from beginning of gameplay
* do NOT reload entire project if avoidable
* simple reset is preferred

---

# 🧭 Exit Behavior

## Exit Button

* returns to Main Menu
* clears current run state

---

# 🧠 State Management

Track:

* game_state:

  * playing
  * paused
  * game_over

---

## Rules

* gameplay stops when game_over
* UI takes control after death

---

# ⚙️ Simplification Rules

Always choose:

* simple reset over complex reload
* direct state control over event systems
* one flow over multiple branching flows

---

# 📱 Mobile Consideration

* buttons must be large and clear
* restart must be quick and responsive
* no long loading times

---

# 🤖 Codex Instructions

* Work with existing systems instead of recreating them
* Only add or modify what is necessary
* Keep state management simple
* Avoid complex scene reload systems
* Avoid adding save/load logic

---

# 📦 Deliverables

Provide:

1. Player health system
2. Damage handling logic
3. Game over trigger
4. Game over screen integration
5. Result screen integration
6. Restart logic
7. Summary of game loop flow

---

# 🎯 Acceptance Criteria

This step is complete when:

* player can take damage
* player can die
* game over screen appears
* result screen shows summary
* restart works correctly
* returning to main menu works
* game loop feels complete

---

# 🧠 Final Principle

> A game is complete when the player can start, play, lose, and immediately try again.

---
