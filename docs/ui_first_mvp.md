# 🧠 UI-FIRST MVP DOCUMENT

## 🧟 Zombie Survival (2.5D)

---

# 🎯 1. Goal

Build the game using:

* Full product UI from the beginning
* MVP gameplay only
* No missing screens
* Placeholder for unfinished systems

---

# 🧠 2. Core Principle

> The player must see the entire product structure from the beginning.

---

# 🗺️ 3. Full Product Flow

```text id="l3t1bz"
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

# 🧱 4. Screen List (MANDATORY)

## Main Menu

* Play
* Settings
* Exit

---

## Mode Select

* Survival (enabled)
* Other modes (Coming Soon)

---

## Hero Select

* Multiple heroes visible
* Only one playable
* Others:

  * Locked
  * Coming Soon

---

## Equipment Select

* Weapon slot (functional later)
* Armor slot (placeholder)
* Accessory slot (placeholder)

---

## Pet Select

* Pet list visible
* All pets:

  * Coming Soon

---

## Inventory

* Grid layout
* Tabs (weapons / items / pets)
* Placeholder data only

---

## Gameplay HUD

* HP bar
* XP bar
* Level
* Timer
* Pause button

---

## Pause Menu

* Resume
* Settings
* Quit

---

## Upgrade Selection

* 3 upgrade options
* Basic upgrades only

---

## Game Over

* Stats
* Restart
* Exit

---

## Result Screen

* Time survived
* Kills
* XP gained

---

## Settings

* Sound toggle
* Music toggle
* Placeholder options

---

## Placeholder Popup

Reusable popup:

* Title
* Message
* Close button

---

# 🧠 5. MVP Gameplay Scope

## MUST implement

* Player movement (X/Z plane)
* Fixed-angle camera following the hero
* Large bounded repeated map
* Play area uses a fixed physical radius, default 600 meters
* Auto shooting
* Enemy spawn
* Enemy chase
* Damage system
* XP system
* Level up
* Game over

---

## NOT required yet

* Pet system logic
* Inventory logic
* Equipment system depth
* Multiple heroes
* Boss system
* Meta progression

---

# 🧩 6. Placeholder Rules

For all unfinished systems:

### Option 1 — Disabled UI

* Visible but not clickable

### Option 2 — Popup

* Show "Coming Soon"

### Option 3 — Mock Data

* Fake heroes/items/pets

---

# 📦 7. Data-Driven UI

All UI should be driven by data.

Example:

```json id="9wdl9x"
{
  "id": "hero_knight",
  "name": "Knight",
  "unlocked": true,
  "implemented": true
}
```

```json id="7f3sva"
{
  "id": "pet_drone",
  "name": "Drone",
  "unlocked": false,
  "implemented": false
}
```

---

# 🧠 8. UI Behavior Rules

* Navigation must always work
* No dead-end screens
* Back button always exists
* All buttons have feedback

---

# 🚀 9. Development Phases

## Phase 1 — UI Skeleton

* Build all screens
* Connect navigation
* Add placeholders

---

## Phase 2 — MVP Gameplay

* Implement survival mode
* Connect gameplay

---

## Phase 3 — Integration

* Replace placeholders gradually

---

# 🤖 10. AI Rules

* Do not remove UI screens
* Do not hide unfinished features
* Use placeholders instead
* Keep systems simple

---

# ⚠️ 11. Common Mistakes

Do NOT:

* Build gameplay first
* Hide unfinished features
* Skip screens
* Over-engineer UI

---

# 🎯 12. Success Criteria

* All screens exist
* Full navigation works
* Placeholder systems visible
* MVP gameplay playable

---

# 🧠 Final Note

> Build the shell first. Fill it later.

---
