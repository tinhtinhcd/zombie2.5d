# STEP 01 — Build UI Skeleton

## Goal

Build the **full product UI skeleton** for the zombie survival game before implementing most gameplay systems.

This step is about:

* creating all major screens
* connecting navigation flow
* showing placeholder states for unfinished systems
* establishing the complete product shell

This step is **NOT** about implementing full gameplay.

---

## Project Direction

Game type:

* top-down zombie survival
* mobile-first
* full product UI from the beginning
* MVP gameplay will be added later

---

## Core Rule

**Do not remove unfinished features from the UI.**
If a feature is not implemented yet:

* keep the screen visible
* use placeholder text
* use disabled buttons
* use mock data
* show "Coming Soon" where appropriate

The player must be able to see the full game structure from the beginning.

---

## Scope of This Step

Build these screens:

1. Main Menu
2. Mode Select
3. Hero Select
4. Equipment Select
5. Pet Select
6. Inventory
7. HUD
8. Pause Menu
9. Upgrade Selection
10. Game Over
11. Result Screen
12. Settings
13. Placeholder Popup

Also:

* connect navigation between screens
* add reusable placeholder states
* keep UI clean and mobile-friendly

---

## Required Navigation Flow

The following flow must work:

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

Not every branch needs real gameplay logic yet, but screen transitions must exist.

---

## Screen Requirements

### 1. Main Menu

Must contain:

* Play
* Settings
* Exit

Behavior:

* Play goes to Mode Select
* Settings opens Settings screen
* Exit can be a placeholder if platform behavior is different

---

### 2. Mode Select

Must contain:

* Survival (enabled)
* Additional mode slots (disabled or Coming Soon)

Behavior:

* Survival goes to Hero Select
* Other modes show placeholder popup

---

### 3. Hero Select

Must contain:

* multiple hero cards or slots
* hero name
* hero description
* hero status:

  * Available
  * Locked
  * Coming Soon

Behavior:

* only one hero needs to be playable for now
* selecting available hero enables Continue
* unavailable heroes should still be visible

Use mock data if needed.

---

### 4. Equipment Select

Must contain:

* weapon slot
* armor slot
* accessory slot
* selected loadout summary
* Continue button
* Back button

Behavior:

* only one weapon needs to be functional later
* armor/accessory can be placeholder for now
* unavailable systems remain visible

---

### 5. Pet Select

Must contain:

* pet slots or pet cards
* pet name
* pet description
* status label

Behavior:

* pets are visible but not implemented
* use Coming Soon or Locked states
* Continue still works

---

### 6. Inventory

Must contain:

* tab buttons such as:

  * Weapons
  * Items
  * Pets
  * Materials
* item grid
* item details panel or placeholder details area

Behavior:

* mock data is acceptable
* no real inventory logic required yet

---

### 7. Gameplay HUD

Must contain:

* HP bar
* XP bar
* level text
* timer text
* pause button

Behavior:

* values can be mock or basic placeholder for now
* layout must be mobile-friendly

---

### 8. Pause Menu

Must contain:

* Resume
* Settings
* Quit to Main Menu

Behavior:

* Resume closes pause menu
* Settings opens Settings
* Quit goes back to Main Menu

---

### 9. Upgrade Selection

Must contain:

* 3 upgrade choice cards
* title
* short descriptions
* select button or clickable cards

Behavior:

* only basic placeholder upgrade data is required for now

---

### 10. Game Over Screen

Must contain:

* Game Over title
* enemies killed
* time survived
* restart
* back to main menu

Behavior:

* buttons can be connected even if gameplay stats are temporary

---

### 11. Result Screen

Must contain:

* run summary
* score
* survival time
* xp gained
* continue/back button

Behavior:

* can use placeholder data for now

---

### 12. Settings

Must contain:

* sound toggle
* music toggle
* vibration toggle placeholder if appropriate
* back button

Behavior:

* real persistence is not required yet
* placeholder toggles are acceptable

---

### 13. Placeholder Popup

Create a reusable popup screen or component for unfinished systems.

Must contain:

* title
* message
* close button

Use it for:

* unimplemented modes
* locked systems
* future features

Suggested messages:

* "Coming Soon"
* "Not available in MVP"
* "This system is planned for a later milestone"

---

## UI Principles

* mobile-friendly layout
* clear buttons
* readable text
* simple hierarchy
* minimal visual clutter
* reusable popup/component patterns
* consistent spacing and naming

---

## Data Rules

UI should be driven by simple data where practical.

Use mock data for:

* heroes
* pets
* items
* upgrades
* modes

Each object can include fields like:

```json
{
  "id": "hero_knight",
  "name": "Knight",
  "description": "Balanced melee survivor.",
  "unlocked": true,
  "implemented": true
}
```

```json
{
  "id": "pet_drone",
  "name": "Drone",
  "description": "Automatically attacks nearby enemies.",
  "unlocked": false,
  "implemented": false
}
```

If `implemented = false`, the UI must still show the feature, but mark it clearly.

---

## What Not To Do

Do NOT:

* build full gameplay systems yet
* remove unfinished screens
* hide future systems
* over-engineer UI architecture
* create deep backend/data persistence for this step
* rewrite unrelated game systems

---

## Implementation Guidance

* work with existing files instead of recreating everything from scratch
* only add or modify what is necessary
* prefer simple, testable code over flexible abstractions
* use the existing architecture and naming style
* avoid rewriting unrelated files

---

## Deliverables

At the end of this step, provide:

1. all new UI scenes created
2. all UI scripts created
3. navigation flow summary
4. list of placeholder systems/screens
5. note on which screens are fully navigable
6. note on which gameplay parts are still mock/placeholder

---

## Acceptance Criteria

This step is complete when:

* all required screens exist
* navigation between screens works
* unfinished systems are visible in the UI
* placeholder popup works
* one can move through the full product flow without missing screens
* the project feels like a complete product shell, even though gameplay is still MVP-only

---

## Final Instruction

Build the **full UI skeleton first**.

Do not skip screens just because the underlying feature is not implemented yet.

Use placeholder states wherever necessary.
