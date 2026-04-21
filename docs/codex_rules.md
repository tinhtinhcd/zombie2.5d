# 🤖 CODEX RULES

## 🧟 Zombie Survival (2.5D)

---

# 🎯 1. Purpose

Define strict rules for AI (Codex) to ensure:

* Consistent architecture
* Clean code
* Correct project direction
* No overengineering
* No UI-breaking changes

---

# 🧠 2. Core Principles

* Modify only what is necessary
* Keep code simple and readable
* Follow existing structure and naming
* Do not rewrite working systems
* Prefer explicit logic over abstraction

---

# ⚠️ 3. Critical Rules (MUST FOLLOW)

## UI Rules

* Do NOT remove UI screens
* Do NOT hide unfinished features
* Always use placeholders instead
* All screens must remain accessible
* UI must follow UI-first strategy

---

## Architecture Rules

* Use existing project structure
* Do not introduce new architecture layers
* Do not refactor unrelated files
* Avoid deep inheritance or complex patterns

---

## Code Rules

* Keep functions small and clear
* Avoid unnecessary abstraction
* Avoid generic systems for MVP
* Avoid dynamic systems unless required
* Prefer hardcoded values in MVP

---

## Scope Rules

* Only implement features defined in MVP scope
* Do not implement future systems early
* Do not expand beyond the current task

---

# 🧩 4. 2.5D Gameplay Rules

* Use `CharacterBody3D` for player and enemies
* Movement only on X/Z plane
* Do NOT implement jump or vertical gameplay
* Camera must remain fixed
* No dynamic camera system
* No complex physics

---

# 🎮 5. Gameplay Rules

* Auto shooting only
* No manual aiming system
* Enemy AI must be simple:

  * move toward player
* No pathfinding system
* No advanced combat system

---

# 🎨 6. UI Implementation Rules

* Use `Control` nodes only
* Use containers for layout
* Follow shared Theme
* Reuse existing UI components
* Keep UI mobile-friendly

---

# 📦 7. Data Rules

* Use simple data structures
* Avoid complex data systems
* Use mock data for placeholder systems
* Do not build full data persistence yet

---

# 🚫 8. Forbidden Actions

Codex MUST NOT:

* Remove or skip UI screens
* Build full systems outside MVP
* Add multiplayer
* Add networking
* Add complex AI
* Add physics-heavy systems
* Replace existing working logic unnecessarily

---

# 🧠 9. Implementation Strategy

For every task:

1. Read existing code
2. Modify only relevant files
3. Keep changes minimal
4. Test logic
5. Return clean code

---

# 🔁 10. Iteration Workflow

* Implement small features
* Keep changes isolated
* Avoid large rewrites
* Ensure game remains playable

---

# 📄 11. Output Requirements

When implementing changes:

* Provide full updated file(s)
* Do not omit context
* Do not include unnecessary explanations
* Keep output clean and usable

---

# 🎯 12. Decision Rule

If uncertain:

> Choose the simplest working solution.

---

# 🧠 13. Priority Order

1. UI consistency
2. Gameplay correctness
3. Code simplicity
4. Performance (later)

---

# 🔥 14. Final Principle

> Build small. Keep it working. Expand later.

---
