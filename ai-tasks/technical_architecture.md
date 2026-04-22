# Technical Architecture

## Purpose

This document describes the current codebase structure for the Godot 4 zombie2.5d project. It should match the real repo, not future wishlist architecture.

## Responsibility Boundaries

### `GameManager.gd`

`scripts/autoload/GameManager.gd` owns runtime and session state:

* active run state
* score, XP, run level, wave state, mission progress
* selected loadout during runtime
* upgrade option selection and upgrade application
* permanent upgrade application
* signals consumed by gameplay and UI

`GameManager.gd` should not own large hardcoded content dictionaries. It reads content through `GameData.gd`.

### `GameData.gd`

`scripts/data/GameData.gd` is the content loading and validation layer.

It loads:

```text
/data/heroes.json
/data/weapons.json
/data/pets.json
/data/upgrades.json
/data/missions.json
/data/permanent_upgrades.json
```

It validates loaded JSON after parsing and protects the rest of the game from malformed data:

* missing dictionary fields are filled with safe defaults where practical
* invalid numeric weapon/pet/mission/permanent upgrade values are corrected
* invalid upgrade entries are skipped
* missing, malformed, empty, or wrong-type files fall back to built-in safe data
* validation warnings are logged with the `GameData warning:` prefix

Required fallback content is always available:

* `hero_knight`
* `weapon_basic`
* `pet_drone`

Public access remains stable through methods such as:

* `get_hero_definition(hero_id)`
* `get_weapon_definition(weapon_id)`
* `get_pet_definition(pet_id)`
* `get_upgrade_options()`
* `get_missions()`
* `get_hero_ids()`
* `get_weapon_ids()`
* `get_pet_ids()`

### `SaveManager.gd`

`scripts/autoload/SaveManager.gd` owns persistence and default progression state.

Fresh save defaults unlock only starter content:

```text
selected_hero_id = hero_knight
selected_weapon_id = weapon_basic
selected_pet_id = pet_drone
unlocked_heroes = [hero_knight]
unlocked_weapons = [weapon_basic]
unlocked_pets = [pet_drone]
```

Existing saves are merged with defaults but already-unlocked content is preserved. Save loading validates the selected loadout:

* selected hero must be unlocked
* selected weapon must be unlocked
* selected pet must be unlocked

If a selected item is invalid, it falls back to the starter ID.

## Data Flow

```text
/data/*.json
  -> GameData.gd loads and validates content
  -> GameManager.gd reads content definitions
  -> UI and gameplay request content through GameManager/GameData accessors

user://progression.save
  -> SaveManager.gd loads and merges progression state
  -> GameManager.gd applies selected loadout and progression to runtime
```

## UI Flow

The UI is a product shell first:

* visible screens show the intended flow
* locked content stays visible
* unavailable systems use locked/placeholder states
* only supported interactions should affect gameplay

Current main flow:

```text
Home -> Mode Select -> Hero Select -> Equipment Select -> Pet Select -> Gameplay
```

## Current Gameplay Systems

Implemented runtime systems include:

* X/Z plane player movement
* fixed camera follow
* auto shooting toward valid targets inside weapon range
* weapon data application
* enemy spawning, chasing, recycling, contact damage, and death
* XP, run level, upgrade selection, and mission progress
* boss wave support
* game over and result panels

## Placeholder Or Planned Systems

These are visible or represented but not complete gameplay systems yet:

* deep equipment/inventory
* armor and accessory effects
* unlock shop/economy
* non-Survival modes
* larger content expansion

## Safety Rules

* Keep schema changes synchronized with `ai-tasks/data_schema.md`.
* Keep content edits in `/data/*.json` unless code behavior must change.
* Keep `GameManager.gd` focused on runtime state.
* Keep `SaveManager.gd` focused on persistence and default progression.
* Keep invalid content from crashing gameplay by using `GameData.gd` validation.
