# STEP 02 — Connect UI Navigation

## 🎯 Goal

Connect all UI screens created in Step 01 into a **fully navigable product flow**.

After this step:

* All screens must be reachable
* Navigation must work end-to-end
* No dead-end UI
* Placeholder systems must still be visible

---

# 🧠 Core Principle

> Every screen must be reachable and every action must lead somewhere.

Even if gameplay is not implemented yet:

* navigation must still work
* use placeholder states instead of blocking flow

---

# 🗺️ Required Navigation Flow

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

# 🧩 Scope of This Step

You must:

* Connect buttons across all screens
* Implement screen transitions
* Add back navigation everywhere
* Add placeholder popup behavior
* Ensure no screen is isolated

You must NOT:

* Implement gameplay systems yet
* Add complex logic
* Refactor unrelated files

---

# 🧱 Navigation Requirements

## Global Rules

* Every screen must have a **Back button**
* No dead-end screens
* Buttons must provide feedback
* Navigation must be predictable

---

## Screen-by-Screen Behavior

### 1. Main Menu

* Play → Mode Select
* Settings → Settings Screen
* Exit → platform-specific or placeholder

---

### 2. Mode Select

* Survival → Hero Select
* Other modes → Placeholder Popup

---

### 3. Hero Select

* Select hero → highlight selection
* Continue → Equipment Select
* Back → Mode Select

---

### 4. Equipment Select

* Continue → Pet Select
* Back → Hero Select

---

### 5. Pet Select

* Continue → Gameplay (temporary entry point)
* Back → Equipment Select

---

### 6. Inventory

* Back → previous screen
* Tabs switch UI only

---

### 7. Gameplay

* Pause button → Pause Menu
* (temporary trigger) → Upgrade Selection
* (temporary trigger) → Game Over

Note:

* You may simulate triggers using simple buttons or debug keys

---

### 8. Pause Menu

* Resume → Gameplay
* Settings → Settings
* Quit → Main Menu

---

### 9. Upgrade Selection

* Select upgrade → return to Gameplay

---

### 10. Game Over

* Restart → Gameplay
* Exit → Result Screen

---

### 11. Result Screen

* Continue → Main Menu

---

### 12. Settings

* Back → previous screen

---

### 13. Placeholder Popup

Must support:

* Open from any screen
* Close and return to previous screen

---

# 🔄 Navigation Implementation

## Recommended Approach

* Use a simple UI manager or navigation controller
* Load/unload scenes OR show/hide screens
* Keep logic simple

---

## Example Concepts

* `show_screen(screen_name)`
* `hide_screen(current)`
* `go_back()`

---

# 🧩 Placeholder Behavior

For unimplemented features:

* Button click → show popup
* Popup message:

  * "Coming Soon"
  * "Not available in MVP"

---

# 🎮 Temporary Gameplay Hooks

Since gameplay is not fully implemented:

Add temporary triggers:

* Button to simulate upgrade screen
* Button to simulate game over
* Optional debug keys

---

# 🧠 UI State Rules

* Selected hero must persist (simple variable)
* Selected equipment must persist (simple variable)
* No need for save system yet

---

# ⚠️ Common Mistakes

Do NOT:

* Leave screens disconnected
* Block navigation because feature is missing
* Implement gameplay logic here
* Overcomplicate navigation system

---

# 🤖 Codex Instructions

* Work with existing files instead of recreating everything
* Only add or modify what is necessary
* Prefer simple navigation logic
* Avoid complex scene management systems
* Keep all screens accessible

---

# 📦 Deliverables

Provide:

1. Updated UI scenes with connected navigation
2. Navigation logic scripts
3. List of screen transitions
4. Confirmation that all screens are reachable
5. List of placeholder-triggered actions

---

# 🎯 Acceptance Criteria

This step is complete when:

* You can start at Main Menu and reach every screen
* You can go back from every screen
* No screen is isolated
* Placeholder systems still appear in UI
* Navigation feels smooth and complete

---

# 🧠 Final Principle

> Navigation defines the product structure before gameplay exists.

---
