# 🗂️ DATA SCHEMA

## 🧟 Zombie Survival (2.5D, Godot 4)

---

# 🎯 1. Purpose

Define the data shapes used by the game so that:

* gameplay data is consistent
* UI can read data safely
* Codex can add content without guessing
* future systems can expand without rewriting basic formats

This schema is intentionally simple.

---

# 🧠 2. Core Principles

* Use flat, readable data
* Prefer explicit fields over clever nesting
* Keep IDs stable
* Use booleans for UI states such as `unlocked` and `implemented`
* Keep MVP-compatible defaults

---

# 📁 3. Suggested Files

```text id="ds001"
/data
  heroes.json
  weapons.json
  pets.json
  upgrades.json
  items.json
  missions.json
  enemies.json
  rooms.json
  game_balance.json
```

---

# 🧩 4. Shared Rules

## ID format

Use lowercase snake_case:

```text id="ds002"
hero_knight
weapon_basic_gun
pet_drone
upgrade_fire_rate_01
enemy_fast_zombie
room_west_hall
```

## Common state fields

Use these where relevant:

```text id="ds003"
id
name
description
unlocked
implemented
icon
```

## Notes

* `unlocked` controls player access
* `implemented` controls whether the feature is real or still placeholder
* `icon` can be empty for placeholder content

---

# 🧍 5. Hero Schema

## Purpose

Defines selectable heroes and their starting identity.

## Fields

```text id="ds004"
id: string
name: string
description: string
max_hp: int
move_speed: float
base_damage: float
fire_rate_modifier: float
unique_trait_name: string
unique_trait_description: string
unlocked: bool
implemented: bool
icon: string
model_scene: string
```

## Example

```json id="ds005"
[
  {
    "id": "hero_knight",
    "name": "Knight",
    "description": "Balanced frontline survivor.",
    "max_hp": 120,
    "move_speed": 5.0,
    "base_damage": 10.0,
    "fire_rate_modifier": 1.0,
    "unique_trait_name": "Steady",
    "unique_trait_description": "Starts with balanced stats.",
    "unlocked": true,
    "implemented": true,
    "icon": "res://assets/ui/heroes/knight.png",
    "model_scene": "res://scenes/entities/heroes/Knight.tscn"
  }
]
```

---

# 🔫 6. Weapon Schema

## Purpose

Defines available weapons and their firing behavior.

## Fields

```text id="ds006"
id: string
name: string
description: string
weapon_type: string
damage: float
fire_rate: float
projectile_count: int
spread_angle: float
projectile_speed: float
range: float
unlocked: bool
implemented: bool
icon: string
projectile_scene: string
```

## `weapon_type` examples

```text id="ds007"
basic
spread
rapid
heavy
```

## Example

```json id="ds008"
[
  {
    "id": "weapon_basic_gun",
    "name": "Basic Gun",
    "description": "Reliable starter weapon.",
    "weapon_type": "basic",
    "damage": 10.0,
    "fire_rate": 0.45,
    "projectile_count": 1,
    "spread_angle": 0.0,
    "projectile_speed": 16.0,
    "range": 20.0,
    "unlocked": true,
    "implemented": true,
    "icon": "res://assets/ui/weapons/basic_gun.png",
    "projectile_scene": "res://scenes/entities/projectiles/Bullet.tscn"
  }
]
```

---

# 🐾 7. Pet Schema

## Purpose

Defines selectable pets and their passive or support behavior.

## Fields

```text id="ds009"
id: string
name: string
description: string
pet_type: string
behavior_type: string
effect_type: string
effect_value: float
cooldown: float
follow_distance: float
unlocked: bool
implemented: bool
icon: string
scene: string
```

## `behavior_type` examples

```text id="ds010"
attack
support
collect
```

## Example

```json id="ds011"
[
  {
    "id": "pet_drone",
    "name": "Drone",
    "description": "Attacks nearby enemies periodically.",
    "pet_type": "drone",
    "behavior_type": "attack",
    "effect_type": "damage",
    "effect_value": 6.0,
    "cooldown": 1.2,
    "follow_distance": 1.5,
    "unlocked": false,
    "implemented": false,
    "icon": "res://assets/ui/pets/drone.png",
    "scene": "res://scenes/entities/pets/Drone.tscn"
  }
]
```

---

# 📈 8. Upgrade Schema

## Purpose

Defines run-based upgrades shown during level-up.

## Fields

```text id="ds012"
id: string
name: string
description: string
upgrade_type: string
target_stat: string
value: float
max_stacks: int
implemented: bool
icon: string
```

## `upgrade_type` examples

```text id="ds013"
offense
mobility
survival
utility
```

## `target_stat` examples

```text id="ds014"
damage
fire_rate
move_speed
max_hp
projectile_count
pickup_range
```

## Example

```json id="ds015"
[
  {
    "id": "upgrade_damage_01",
    "name": "Sharpened Ammo",
    "description": "+15% damage.",
    "upgrade_type": "offense",
    "target_stat": "damage",
    "value": 0.15,
    "max_stacks": 5,
    "implemented": true,
    "icon": "res://assets/ui/upgrades/damage.png"
  }
]
```

---

# 🎁 9. Item Schema

## Purpose

Defines loot items used by inventory and drops.

## Fields

```text id="ds016"
id: string
name: string
description: string
item_type: string
effect_type: string
effect_value: float
consumable: bool
equippable: bool
unlocked: bool
implemented: bool
icon: string
```

## `item_type` examples

```text id="ds017"
consumable
equipment
utility
```

## Example

```json id="ds018"
[
  {
    "id": "item_small_medkit",
    "name": "Small Medkit",
    "description": "Restore a small amount of HP.",
    "item_type": "consumable",
    "effect_type": "heal",
    "effect_value": 20.0,
    "consumable": true,
    "equippable": false,
    "unlocked": true,
    "implemented": true,
    "icon": "res://assets/ui/items/medkit_small.png"
  }
]
```

---

# 🎯 10. Mission Schema

## Purpose

Defines missions for in-run or meta progression.

## Fields

```text id="ds019"
id: string
name: string
description: string
mission_type: string
target_value: int
reward_type: string
reward_value: int
implemented: bool
```

## `mission_type` examples

```text id="ds020"
kill
survive
boss
collect
```

## `reward_type` examples

```text id="ds021"
xp
currency
unlock_point
upgrade
```

## Example

```json id="ds022"
[
  {
    "id": "mission_kill_50",
    "name": "Zombie Cleaner",
    "description": "Kill 50 zombies in one run.",
    "mission_type": "kill",
    "target_value": 50,
    "reward_type": "currency",
    "reward_value": 100,
    "implemented": true
  }
]
```

---

# 🧟 11. Enemy Schema

## Purpose

Defines enemy variants using data instead of hardcoding each one.

## Fields

```text id="ds023"
id: string
name: string
description: string
enemy_type: string
max_hp: float
move_speed: float
contact_damage: float
xp_drop: int
item_drop_chance: float
boss: bool
implemented: bool
icon: string
scene: string
```

## `enemy_type` examples

```text id="ds024"
basic
fast
tank
boss
```

## Example

```json id="ds025"
[
  {
    "id": "enemy_fast_zombie",
    "name": "Fast Zombie",
    "description": "Low HP but closes distance quickly.",
    "enemy_type": "fast",
    "max_hp": 18.0,
    "move_speed": 6.2,
    "contact_damage": 10.0,
    "xp_drop": 8,
    "item_drop_chance": 0.08,
    "boss": false,
    "implemented": true,
    "icon": "res://assets/ui/enemies/fast_zombie.png",
    "scene": "res://scenes/entities/enemies/FastZombie.tscn"
  }
]
```

---

# 🗺️ 12. Room Schema

## Purpose

Defines rooms or map areas for room progression.

## Fields

```text id="ds026"
id: string
name: string
description: string
unlock_type: string
unlock_value: int
spawn_profile: string
implemented: bool
scene: string
```

## `unlock_type` examples

```text id="ds027"
kill_count
time
currency
boss_clear
```

## Example

```json id="ds028"
[
  {
    "id": "room_west_hall",
    "name": "West Hall",
    "description": "A wider room with heavier enemy density.",
    "unlock_type": "kill_count",
    "unlock_value": 30,
    "spawn_profile": "mid_density",
    "implemented": true,
    "scene": "res://scenes/game/rooms/WestHall.tscn"
  }
]
```

---

# 💾 13. Meta Save Schema

## Purpose

Defines persistent player progress between runs.

## Fields

```text id="ds029"
currency: int
selected_hero_id: string
selected_weapon_id: string
selected_pet_id: string
unlocked_heroes: string[]
unlocked_weapons: string[]
unlocked_pets: string[]
completed_missions: string[]
settings: object
```

## Example

```json id="ds030"
{
  "currency": 250,
  "selected_hero_id": "hero_knight",
  "selected_weapon_id": "weapon_basic_gun",
  "selected_pet_id": "",
  "unlocked_heroes": ["hero_knight", "hero_runner"],
  "unlocked_weapons": ["weapon_basic_gun"],
  "unlocked_pets": [],
  "completed_missions": ["mission_kill_50"],
  "settings": {
    "music_enabled": true,
    "sound_enabled": true,
    "vibration_enabled": false
  }
}
```

---

# ⚖️ 14. Game Balance Schema

## Purpose

Centralize global balancing values.

## Fields

```text id="ds031"
player_contact_damage_cooldown: float
base_xp_to_next_level: int
xp_growth_per_level: float
boss_wave_interval: int
max_active_enemies: int
item_drop_base_chance: float
```

## Example

```json id="ds032"
{
  "player_contact_damage_cooldown": 0.75,
  "base_xp_to_next_level": 25,
  "xp_growth_per_level": 1.2,
  "boss_wave_interval": 10,
  "max_active_enemies": 40,
  "item_drop_base_chance": 0.12
}
```

---

# 🧭 15. UI Placeholder Rules

For any data entry where a feature is not ready yet:

* keep the entry in data
* set `implemented: false`
* allow UI to display it
* prevent gameplay usage if needed

This supports the UI-first strategy.

---

# ⚠️ 16. Validation Rules

Codex should follow these rules when adding data:

* every object must have a stable `id`
* no duplicate IDs
* no missing required fields
* use correct field types
* do not invent new fields unless the schema is updated
* if a new field is needed, update this document first

---

# 🤖 17. Codex Rules for Data Files

* modify existing data files instead of inventing parallel ones
* keep field order consistent
* add new content in the same style as existing entries
* do not mix placeholder-only objects with fully implemented objects without using `implemented`

---

# 🎯 18. Success Criteria

The schema is working well when:

* UI can display all major systems safely
* gameplay systems can load data without guessing
* placeholder content can coexist with real content
* Codex can add heroes, weapons, pets, items, and missions consistently

---

# 🧠 Final Principle

> Good data structure makes expansion easier than new code.

---
