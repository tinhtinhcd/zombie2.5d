# STEP 15 — Add Inventory and Loot

## 🎯 Goal

Introduce a **simple inventory and loot system** to expand progression and reward structure.

This step adds:

* item drops beyond XP
* basic inventory UI functionality
* simple equip / use flow
* clearer reward loop

---

# 🧠 Core Principle

> Loot should feel rewarding and understandable, not complex.

---

# 🧩 Scope of This Step

You must implement:

* item drop system
* simple item types
* inventory data structure
* inventory UI integration (already exists)
* basic equip or use behavior

You must NOT implement:

* full RPG inventory system
* crafting system
* item rarity tiers (keep minimal)
* trading or economy
* complex stat stacking systems

---

# 🎁 Loot System

## Drop Behavior

Enemies can drop:

* XP (already exists)
* items (new)

---

## Drop Rules

* not every enemy drops items
* use simple chance:

  * e.g. 10–20% drop rate

---

# 📦 Item Types (MVP)

Implement 2–3 types only:

---

## 1. Consumable

### Examples

* small heal
* temporary buff

### Behavior

* used instantly or stored
* simple effect

---

## 2. Equipment (Basic)

### Examples

* +damage item
* +speed item

### Behavior

* equip to apply stat bonus

---

## 3. Utility (optional)

### Examples

* XP boost item
* pickup range increase

---

# 📊 Item Data

Each item should define:

```text id="759120"
Item
- id
- name
- type
- description
- effect
- value
```

---

# 🎒 Inventory System

## Requirements

* simple storage list
* display items in UI
* allow selecting an item
* basic item interaction

---

## Rules

* no stacking complexity
* no weight system
* no sorting system required
* keep inventory small

---

# 🔄 Item Interaction

## Consumables

* can be used
* apply effect immediately

---

## Equipment

* can be equipped
* apply stat bonus

---

## Rules

* one action per item
* no complex multi-step logic

---

# 🎮 Gameplay Integration

## Drop Flow

```text id="759121"
Enemy dies → Item drops → Player picks up → Item added to inventory
```

---

## Inventory Use

* open inventory
* select item
* use or equip

---

# 🎨 UI Integration

Use existing Inventory screen.

## Requirements

* display item list/grid
* show item name and description
* show item type
* allow selecting item

---

## Behavior

* selecting item shows details
* use/equip button available

---

# 💾 Save Integration

If meta progression exists:

* inventory may persist OR reset per run (choose one)

---

## Recommendation

For MVP:

* inventory resets each run

---

# ⚠️ Avoid

Do NOT:

* build full RPG inventory
* add many item types
* create complex UI interactions
* implement crafting or shops
* create item rarity systems

---

# 🧠 Simplification Rules

Always choose:

* small item pool
* simple effects
* direct logic
* visible impact

---

# 📱 Mobile Consideration

* items must be easy to tap
* UI must be clean and readable
* avoid clutter

---

# 🤖 Codex Instructions

* Reuse existing UI screens
* Keep inventory logic simple
* Avoid complex data models
* Focus on clarity and usability
* Do not overengineer item systems

---

# 📦 Deliverables

Provide:

1. item data definitions
2. loot drop system
3. inventory logic
4. inventory UI integration
5. item use/equip behavior
6. summary of loot flow

---

# 🎯 Acceptance Criteria

This step is complete when:

* enemies can drop items
* player can collect items
* items appear in inventory
* items can be used or equipped
* system is simple and functional
* gameplay feels more rewarding

---

# 🧠 Final Principle

> Loot should make the player feel rewarded, not overwhelmed.

---
