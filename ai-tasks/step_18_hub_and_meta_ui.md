# STEP 18 — Add Hub and Meta UI

## 🎯 Goal

Introduce a **hub layer and meta UI structure** outside the core run so the game feels like a complete product, not just a gameplay prototype.

This step improves:

* product structure
* player orientation
* long-term progression clarity
* feature discoverability

---

# 🧠 Core Principle

> The hub is where the player understands progress, choices, and long-term goals.

---

# 🧩 Scope of This Step

You must implement:

* a hub-style main progression screen
* navigation to major meta screens
* clear separation between "outside run" and "inside run"
* visible unlock/progression summaries
* placeholder support for unfinished meta features

You must NOT implement:

* deep economy systems
* live service systems
* daily login system
* cloud sync
* social systems
* complex backend logic

---

# 🏗️ Hub Purpose

The hub acts as the player's **home screen** between runs.

It should answer:

* What can I do now?
* What have I unlocked?
* What should I improve next?
* Where do I start the next run?

---

# 🗺️ Hub Flow

```text id="436180"
Main Menu
→ Hub
   ├── Start Run
   ├── Hero Select
   ├── Weapon / Equipment
   ├── Pet Select
   ├── Inventory
   ├── Missions
   ├── Progress / Unlocks
   └── Settings
```

---

# 🧱 Required Screens / Sections

## 1. Hub Main Screen

Must contain:

* Start Run
* current selected hero
* current selected weapon
* current selected pet
* currency / points
* mission summary
* progression summary

Purpose:

* act as the central navigation point

---

## 2. Progress / Unlock Screen

Must contain:

* unlocked heroes
* unlocked weapons
* unlocked pets
* future unlock categories if needed

Behavior:

* clearly show locked vs unlocked
* use placeholder states where systems are not complete

---

## 3. Mission Overview Screen

Must contain:

* active missions
* completed missions
* rewards preview if appropriate

Behavior:

* simple list view is enough
* do not build a heavy mission board

---

## 4. Loadout Summary Section

Must contain:

* selected hero
* selected weapon
* selected pet
* short stat summary

Purpose:

* player sees current build before run

---

## 5. Currency / Resource Display

Must contain:

* current meta currency
* optional unlock points

Behavior:

* always visible in hub
* no complex wallet/economy behavior

---

# 🔄 Navigation Rules

* Hub must become the primary entry point after Main Menu
* Player should be able to navigate from Hub to all major meta screens
* Starting a run should happen from Hub
* After finishing a run, player may return to:

  * Result Screen
  * then Hub

---

# 🎮 Product Flow Update

New recommended structure:

```text id="436181"
Main Menu
→ Hub
→ Select / Review Build
→ Start Run
→ Gameplay
→ Result Screen
→ Hub
```

This means the Hub replaces the feeling of disconnected menus.

---

# 🧠 Meta UI Rules

## Must Do

* show progression clearly
* show what is selected now
* show what is locked
* show what can be improved next

---

## Must Not Do

* overwhelm the player with too many panels
* expose unfinished deep systems as if they are fully implemented
* create unnecessary nested navigation

---

# 📦 Data Requirements

Hub should read simple data such as:

```text id="436182"
MetaState
- selected_hero
- selected_weapon
- selected_pet
- currency
- unlocked_heroes
- unlocked_weapons
- unlocked_pets
- missions
```

Use the existing data model where possible.

---

# 🎨 UI Layout Guidance

Hub should feel:

* clean
* central
* readable
* mobile-friendly

Suggested layout:

```text id="436183"
Hub
 ├── Header
 │    ├── Currency
 │    └── Profile / title
 ├── Main Action
 │    └── Start Run
 ├── Current Loadout Summary
 ├── Progress Summary
 ├── Mission Summary
 └── Navigation Buttons
```

---

# 🧩 Placeholder Policy

If a meta system is not fully implemented yet:

* keep its entry visible
* show locked state or Coming Soon
* or allow entering the screen with mock / placeholder content

Examples:

* future upgrade lab
* archive
* leaderboard
* events

Do NOT remove them if they are part of the intended product structure.

---

# 📱 Mobile Consideration

* large touch targets
* no dense dashboard clutter
* summary-first layout
* avoid deep tap chains

---

# ⚠️ Avoid

Do NOT:

* build a full backend-driven profile system
* add monetization/store logic
* create an overly complex hub scene hierarchy
* build too many submenus at once
* tightly couple hub logic to in-run gameplay

---

# 🧠 Simplification Rules

Always choose:

* summary panels over complex dashboards
* direct navigation over nested navigation
* data display over heavy UI logic
* one hub over many disconnected top-level screens

---

# 🤖 Codex Instructions

* Reuse existing UI screens where practical
* Create a clear hub screen as the central meta UI
* Keep hub logic simple and data-driven
* Do not build advanced live-ops or account systems
* Preserve placeholder support for future features
* Avoid rewriting unrelated gameplay systems

---

# 📦 Deliverables

Provide:

1. hub main screen
2. hub navigation flow
3. progress / unlock screen
4. mission overview integration
5. loadout summary integration
6. currency display integration
7. summary of updated product flow

---

# 🎯 Acceptance Criteria

This step is complete when:

* the player can enter a clear hub after Main Menu
* the hub serves as the central place for meta navigation
* current hero / weapon / pet selections are visible
* progression and mission summaries are visible
* starting a run from the hub works cleanly
* the game feels more like a complete product than a prototype

---

# 🧠 Final Principle

> A strong hub makes progression visible, goals clear, and the whole game feel intentional.

---
