# 🧠 UI-FIRST MVP DOCUMENT

## 🧟 Zombie Survival (Full UI + MVP Gameplay)

---

# 🎯 1. Goal

Build the game using:

* ✅ Full product UI from the beginning
* ✅ MVP gameplay only
* ❌ No missing screens
* ✅ Use placeholders for unfinished features

---

# 🧠 2. Core Principle

> The player must see the **entire product structure**, even if some features are not implemented.

---

# 🧩 3. UI Strategy

## Rules

* Every major system must have a screen
* No feature should be hidden
* If not implemented:

  * show UI
  * disable interaction OR
  * show "Coming Soon"

---

# 🗺️ 4. Full Product Flow

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

# 🧱 5. Screen List (MANDATORY)

## 5.1 Main Menu

* Play
* Settings
* Exit

---

## 5.2 Mode Select

* Survival (enabled)
* Other modes (disabled / Coming Soon)

---

## 5.3 Hero Select

* Show multiple heroes
* Only 1 hero playable
* Others:

  * Locked OR Coming Soon

---

## 5.4 Equipment Select

* Weapon slot
* Armor slot (placeholder)
* Accessory slot (placeholder)
* Only 1 weapon usable

---

## 5.5 Pet Select

* Show pet slots
* No real functionality yet
* All marked "Coming Soon"

---

## 5.6 Inventory

* Grid layout
* Tabs (weapons / items / etc.)
* No real logic required yet

---

## 5.7 Gameplay HUD

* HP bar
* XP bar
* Level
* Timer
* Pause button

---

## 5.8 Pause Menu

* Resume
* Settings
* Quit

---

## 5.9 Upgrade Selection

* Show 3 upgrade choices
* Only basic upgrades implemented

---

## 5.10 Game Over Screen

* Show stats
* Restart
* Exit

---

## 5.11 Result Screen

* Time survived
* Enemies killed
* XP gained

---

## 5.12 Settings

* Sound toggle
* Music toggle
* Placeholder options

---

## 5.13 Placeholder Popup

Reusable popup:

* Title: "Coming Soon"
* Description
* Close button

---

# 🧠 6. MVP Gameplay Scope

## MUST implement:

* Player movement
* Auto shooting
* Enemy spawn
* Enemy chase
* Damage system
* XP system
* Level up
* Game over

---

## NOT required yet:

* Pet system
* Inventory logic
* Equipment logic
* Multiple weapons
* Advanced enemy types
* Boss system

---

# 🧩 7. Placeholder Rules

## For all unfinished systems:

Use one of:

### 1. Disabled UI

* Button visible but not clickable

### 2. Popup

* Show "Coming Soon"

### 3. Mock Data

* Show fake items/heroes/pets

---

# 📦 8. Data Structure (IMPORTANT)

All UI must be data-driven.

Example:

```json
{
  "id": "hero_knight",
  "name": "Knight",
  "unlocked": true,
  "implemented": true
}
```

```json
{
  "id": "pet_drone",
  "name": "Drone",
  "unlocked": false,
  "implemented": false
}
```

---

## Rule:

* UI reads data
* If `implemented = false` → show "Coming Soon"

---

# 🧠 9. UI Behavior Rules

* Navigation must always work
* No dead-end screens
* Back button always available
* All buttons have visual feedback

---

# 🚀 10. Development Phases

## Phase 1 — UI Skeleton

* Build all screens
* Connect navigation
* Add placeholder states

---

## Phase 2 — MVP Gameplay

* Implement survival mode only
* Connect gameplay to UI

---

## Phase 3 — Integration

* Replace placeholder systems gradually

---

# 🤖 11. AI Development Rules

## MUST FOLLOW:

* Do not remove UI screens
* Do not hide unfinished features
* Use placeholder instead
* Build UI first, then gameplay
* Keep systems simple

---

## IMPORTANT:

```text
Full UI must exist even if gameplay is incomplete.
Never remove UI for unfinished features.
Always use placeholder or disabled states.
```

---

# ⚠️ 12. Common Mistakes (DO NOT DO)

❌ Build gameplay first, UI later
❌ Hide unfinished features
❌ Hardcode UI without data
❌ Remove screens because logic is missing

---

# 🎯 13. Success Criteria

* All screens exist
* Navigation works fully
* Player can play core loop
* Placeholder systems visible
* Game feels like a “complete product shell”

---

# 🧠 Final Note

This project is built as:

> **Full product UX + incremental gameplay implementation**

---
