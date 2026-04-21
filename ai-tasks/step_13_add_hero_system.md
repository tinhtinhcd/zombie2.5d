# STEP 13 — Add Hero System

## 🎯 Goal

Introduce a **real hero system** so the player can choose between different characters with distinct stats and playstyles.

This step improves:

* replayability
* build identity
* product depth
* long-term progression potential

---

# 🧠 Core Principle

> A hero should feel different because of a few clear gameplay differences, not because of a huge complex system.

---

# 🧩 Scope of This Step

You must implement:

* hero data definitions
* hero selection integration
* at least 2–3 playable heroes
* different base stats per hero
* one simple unique trait or passive per hero
* selected hero applied to gameplay

You must NOT implement:

* deep hero skill trees
* hero-specific cutscenes
* full talent systems
* hero-specific weapon inventories
* complex unlock conditions

---

# 🧍 Hero System Purpose

Heroes define the player's starting identity.

Each hero should change:

* starting stats
* preferred playstyle
* how the early game feels

---

# 📊 Hero Data

Each hero should define:

```text id="341270"
Hero
- id
- name
- description
- max_hp
- move_speed
- base_damage
- fire_rate_modifier
- unique_trait
- unlocked
```

---

# 🧩 Minimum Hero Roster

Implement at least 3 heroes.

## 1. Balanced Hero

### Role

* beginner-friendly
* no extreme strengths or weaknesses

### Example Traits

* medium HP
* medium speed
* medium damage

---

## 2. Fast Hero

### Role

* mobile survivor
* better repositioning

### Example Traits

* lower HP
* higher speed
* lower or normal damage

---

## 3. Power Hero

### Role

* slower but hits harder

### Example Traits

* higher HP
* lower speed
* higher damage

---

# ✨ Unique Trait Rules

Each hero should have one **simple** distinguishing trait.

Examples:

* +10% movement speed
* +15% damage
* +10 max HP
* slightly faster fire rate

Keep traits passive and easy to understand.

Do NOT add active hero abilities yet unless they are extremely simple.

---

# 🎮 Hero Selection Integration

Use the existing Hero Select UI.

Requirements:

* heroes visible in hero select screen
* hero card shows:

  * name
  * description
  * key stats
  * lock/unlock state
* selected hero persists into gameplay

---

# 🔄 Gameplay Integration

When a run starts:

* load selected hero
* apply hero stats to player
* update HUD or internal state if needed

This must affect actual gameplay, not just UI.

---

# 💾 Save / Meta Integration

If meta progression already exists:

* hero unlock state must persist
* selected hero must persist if appropriate

Keep this simple.

---

# 🧠 Simplification Rules

Always choose:

* passive differences over active systems
* clear stat identity over complicated skill kits
* data-driven hero definitions over hardcoded screen-only choices

---

# ⚠️ Avoid

Do NOT:

* create many heroes at once
* build hero trees
* add complex synergy systems
* build a giant hero framework

---

# 🎨 UI Requirements

Hero cards should clearly show:

* hero name
* short role description
* locked/unlocked state
* selected state

Optional:

* short stat summary
* icon or placeholder portrait

---

# 📱 Mobile Consideration

* hero cards must be easy to tap
* text must remain short and readable
* avoid too many details on one card

---

# 🤖 Codex Instructions

* Reuse the existing hero select screen
* Use simple hero data structures
* Keep hero traits passive and clear
* Apply hero stats directly to the player at run start
* Avoid building advanced hero systems

---

# 📦 Deliverables

Provide:

1. hero data definitions
2. updated hero select integration
3. selected hero gameplay application
4. at least 3 hero variations
5. summary of each hero's identity

---

# 🎯 Acceptance Criteria

This step is complete when:

* the player can choose between multiple heroes
* heroes have visibly different stats
* selected hero changes gameplay
* hero selection feels like a real product feature
* the system remains simple and stable

---

# 🧠 Final Principle

> A few strong hero identities are better than many shallow ones.

---
