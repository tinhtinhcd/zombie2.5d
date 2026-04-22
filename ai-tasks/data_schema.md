# Data Schema

## Purpose

This document describes the data files currently used by the project. It matches the JSON files in `/data` and the validation rules in `scripts/data/GameData.gd`.

The schema is intentionally small. Do not add fields unless the code that reads them is also updated.

## Data Files

```text
/data
  heroes.json
  weapons.json
  pets.json
  upgrades.json
  missions.json
  permanent_upgrades.json
```

There are no active JSON files for items, enemies, rooms, or global balance yet.

## Loading And Validation

`GameData.gd` loads all data once and validates it after parsing.

File-level safety:

* missing file -> use fallback data and log a warning
* malformed JSON -> use fallback data and log a warning
* wrong top-level type -> use fallback data and log a warning
* empty file data -> use fallback data and log a warning

Required fallback IDs are always available:

* `hero_knight`
* `weapon_basic`
* `pet_drone`

Warnings use this style:

```text
GameData warning: weapons.json entry "weapon_basic" invalid fire_rate; using 0.5.
```

## ID Rules

Use stable lowercase snake_case IDs.

Examples:

```text
hero_knight
weapon_basic
pet_drone
projectile_damage
mission_kills
perm_max_hp
```

## Heroes

File: `/data/heroes.json`

Top-level type: object keyed by hero ID.

Required fields:

```text
display_name: string
max_hp_bonus: int or float
move_speed_bonus: int or float
projectile_damage_bonus: int or float
```

Example:

```json
{
  "hero_knight": {
    "display_name": "Knight",
    "max_hp_bonus": 4,
    "move_speed_bonus": 0.0,
    "projectile_damage_bonus": 1
  }
}
```

Validation behavior:

* missing or invalid `display_name` -> fill safe display name
* missing or invalid numeric fields -> fill safe numeric defaults
* missing `hero_knight` -> inject fallback hero

## Weapons

File: `/data/weapons.json`

Top-level type: object keyed by weapon ID.

Required fields used by gameplay/UI:

```text
id: string
display_name: string
damage: int or float
fire_rate: int or float
projectile_count: int or float
spread_angle: int or float
projectile_speed: int or float
range: int or float
```

Additional fields currently present and preserved:

```text
description: string
weapon_type: string
unlocked: bool
implemented: bool
icon: string
projectile_scene: string
```

Example:

```json
{
  "weapon_basic": {
    "id": "weapon_basic",
    "display_name": "Basic Gun",
    "description": "Reliable starter weapon.",
    "weapon_type": "basic",
    "damage": 1,
    "fire_rate": 0.6,
    "projectile_count": 1,
    "spread_angle": 0.0,
    "projectile_speed": 14.0,
    "range": 20.0,
    "unlocked": true,
    "implemented": true,
    "icon": "",
    "projectile_scene": "res://scenes/effects/projectile.tscn"
  }
}
```

Validation behavior:

* missing or invalid required fields -> fill safe defaults
* `projectile_count < 1` -> set to `1`
* `fire_rate <= 0` -> set to `0.5`
* `range <= 0` -> set to `20.0`
* missing `weapon_basic` -> inject fallback weapon

Gameplay notes:

* `fire_rate` is the firing interval in seconds.
* `range` controls both projectile max distance and combat target eligibility.
* Hero facing uses active weapon range: face nearest enemy inside range; otherwise face movement direction.

## Pets

File: `/data/pets.json`

Top-level type: object keyed by pet ID.

Required fields:

```text
display_name: string
damage: int or float
attack_interval: int or float
```

Example:

```json
{
  "pet_drone": {
    "display_name": "Drone",
    "damage": 1,
    "attack_interval": 1.2
  }
}
```

Validation behavior:

* missing or invalid required fields -> fill safe defaults
* `attack_interval <= 0` -> set to `1.0`
* missing `pet_drone` -> inject fallback pet

## Upgrades

File: `/data/upgrades.json`

Top-level type: array.

Required fields:

```text
id: string
title: string
description: string
```

Example:

```json
[
  {
    "id": "projectile_damage",
    "title": "Power Shot",
    "description": "Increase projectile damage by 1."
  }
]
```

Validation behavior:

* invalid entry type -> skip entry
* missing `id`, `title`, or `description` -> skip entry
* if no valid entries remain -> use fallback upgrades

Current upgrade IDs are handled by `GameManager.gd`. Do not add new upgrade IDs unless upgrade application logic is also updated.

## Missions

File: `/data/missions.json`

Top-level type: array.

Required fields:

```text
id: string
label: string
stat: string
target: int or float
```

Example:

```json
[
  {
    "id": "mission_kills",
    "label": "Defeat 15 enemies",
    "stat": "kills",
    "target": 15
  }
]
```

Validation behavior:

* missing or invalid fields -> fill safe defaults
* `target <= 0` -> set to `1`
* if no valid entries remain -> use fallback missions

Current mission `stat` values used by the game include:

```text
kills
xp
wave
```

## Permanent Upgrades

File: `/data/permanent_upgrades.json`

Top-level type: object keyed by permanent upgrade ID.

Required fields:

```text
title: string
description: string
max_rank: int or float
```

Example:

```json
{
  "perm_max_hp": {
    "title": "Vitality",
    "description": "Permanent +2 max HP per rank.",
    "max_rank": 5
  }
}
```

Validation behavior:

* missing or invalid fields -> fill safe defaults
* `max_rank < 1` -> set to `1`

Permanent upgrade effects are applied in `GameManager.gd`. Do not add new permanent upgrade IDs unless application logic supports them.

## Save Data

Save data is owned by `scripts/autoload/SaveManager.gd`.

Current default save shape:

```json
{
  "version": 1,
  "highest_unlocked_level": 1,
  "permanent_upgrades": {},
  "soft_currency": 0,
  "selected_hero_id": "hero_knight",
  "selected_weapon_id": "weapon_basic",
  "selected_pet_id": "pet_drone",
  "unlocked_heroes": ["hero_knight"],
  "unlocked_weapons": ["weapon_basic"],
  "unlocked_pets": ["pet_drone"],
  "inventory": {},
  "settings": {}
}
```

Rules:

* fresh saves unlock only starter content
* existing saved unlock arrays are preserved
* empty or missing unlock arrays are initialized with starter defaults
* selected loadout must be unlocked or it falls back to starter IDs

## Placeholder Rules

Locked or placeholder content may remain visible in UI.

Do not mark a system as playable in docs just because its UI exists. The current UI shell includes placeholders for deeper inventory, armor/accessory gameplay, and future modes.

## Codex Rules For Data

* edit the existing JSON files instead of creating parallel data files
* keep field names compatible with this schema
* keep IDs stable once used in saves
* avoid changing save format unless explicitly required
* update this document when code starts reading a new field
