# 🧹 CODE STYLE GUIDELINES

## 🧟 Zombie Survival (2.5D, Godot 4)

---

# 🎯 1. Purpose

Define coding style rules so the codebase stays:

* readable
* consistent
* easy for humans to review
* easy for Codex to extend safely

---

# 🧠 2. Core Philosophy

* Prefer simple code over clever code
* Prefer explicit code over generic code
* Prefer stable code over flexible code
* Prefer small changes over rewrites

---

# ⚠️ 3. General Rules

## MUST

* keep functions short
* use clear names
* keep logic local when possible
* write code that is easy to test manually

---

## MUST NOT

* overengineer
* introduce deep abstractions
* create frameworks for small problems
* refactor unrelated files in the same task

---

# 🏗️ 4. File Organization

## One file should have one clear responsibility

Examples:

* `Player.gd` → player behavior
* `Enemy.gd` → enemy behavior
* `MissionSystem.gd` → mission logic
* `UIManager.gd` → UI navigation

---

## Avoid

* giant files that do many unrelated things
* utility dumping grounds
* mixed UI + gameplay logic in one file

---

# 🧩 5. Naming Conventions

## Files

Use clear PascalCase for major scripts if matching scene/entity names:

```text id="cs001"
Player.gd
Enemy.gd
Boss.gd
MissionSystem.gd
UIManager.gd
```

If the repo already uses another naming style, follow the existing style consistently.

---

## Variables

Use descriptive `snake_case` names:

```gdscript
var current_hp: int
var move_speed: float
var xp_to_next_level: int
```

Avoid vague names like:

* `a`
* `tmp`
* `data2`
* `obj`

---

## Functions

Use action-based names:

```gdscript
func take_damage(amount: int) -> void
func spawn_enemy() -> void
func update_mission_progress() -> void
func show_game_over() -> void
```

Avoid unclear names like:

* `do_stuff`
* `handle_all`
* `process_data`

---

# 🧠 6. Function Design

## Rules

* one function = one purpose
* keep branching shallow
* avoid long parameter lists
* return early when useful

---

## Good

```gdscript
func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return

	current_hp -= amount

	if current_hp <= 0:
		die()
```

---

## Bad

```gdscript
func take_damage(amount, source, play_effect, force, extra, flags):
	# too many responsibilities
```

---

# 📏 7. Function Size

## Preferred

* 5–25 lines for most functions

## Acceptable

* longer only if the logic is still very clear

## Avoid

* very large functions with mixed responsibilities

---

# 🧩 8. State Management

## Keep state explicit

Good examples:

* `is_dead`
* `is_paused`
* `current_level`
* `selected_hero_id`

---

## Avoid hidden state

Do not spread one feature's state across many unrelated files unless clearly necessary.

---

# 🎮 9. Gameplay Logic Rules

## Keep gameplay logic direct

* player handles player behavior
* enemy handles enemy behavior
* systems coordinate, not own everything

---

## Avoid

* giant central controller for all gameplay
* too many cross-dependencies
* magic behavior hidden in UI files

---

# 🧱 10. UI Code Rules

## UI must stay separate from gameplay logic

UI scripts should:

* show data
* read selections
* trigger navigation
* call game systems when needed

UI scripts should NOT:

* own combat logic
* own enemy logic
* calculate progression rules

---

# 📦 11. Data Rules

## Prefer simple data structures

Use:

* dictionaries
* arrays
* simple JSON
* light resource data

---

## Avoid

* deeply nested config systems
* unnecessary data wrappers
* dynamic schemas for MVP features

---

# 🔄 12. Reuse Rules

## Reuse existing code when possible

Before adding new code:

* check if a similar pattern already exists
* extend small existing systems when reasonable

---

## Do NOT

* duplicate large logic blocks
* create a second system for the same purpose

---

# 🧪 13. Testing Style

## Code should be easy to verify manually

When adding a feature:

* make the result visible
* keep flow easy to test in-game
* avoid hidden side effects

---

## Prefer

* obvious state changes
* visible UI updates
* simple debug-friendly flow

---

# 📝 14. Comments

## Use comments sparingly

Only comment when:

* intent is not obvious
* a design choice needs context
* a workaround is necessary

---

## Do NOT

* comment trivial lines
* narrate obvious code
* leave outdated comments

---

## Good

```gdscript
# Prevent rapid repeated damage when enemy stays in contact.
var hit_cooldown: float = 0.75
```

---

## Bad

```gdscript
# Set hp
current_hp = max_hp
```

---

# 🧠 15. Constants and Magic Numbers

## Rule

If a number has gameplay meaning, give it a clear name.

Good:

```gdscript
const DEFAULT_FIRE_RATE: float = 0.4
const CONTACT_DAMAGE_COOLDOWN: float = 0.75
```

Avoid unexplained values scattered through code.

---

# ⚠️ 16. Error Prevention

## Prefer safe checks

* check for null when appropriate
* guard against invalid states
* avoid assuming nodes always exist unless guaranteed

---

## Example

```gdscript
if target_enemy == null:
	return
```

---

# 🚫 17. Anti-Patterns

Do NOT:

* create giant manager classes
* introduce unnecessary inheritance trees
* build event systems for simple direct calls
* create “universal” helpers too early
* make the architecture more abstract than the game needs

---

# 🤖 18. Codex-Specific Rules

Codex must:

* modify only relevant files
* keep naming consistent with the repo
* avoid style drift across files
* avoid speculative refactors
* return complete, usable code
* preserve existing architecture unless the task requires a focused change

---

# 🔧 19. Preferred Change Pattern

For most tasks:

1. read existing file
2. make minimal change
3. keep behavior local
4. verify side effects are limited
5. keep output clean

---

# 🎯 20. Success Criteria

Code style is correct when:

* another developer can read it quickly
* Codex can continue from it safely
* features are easy to test
* files stay focused
* changes do not create confusion

---

# 🧠 Final Principle

> Clear code scales better than smart code.

---
