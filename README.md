# Zombie Survival 2.5D

A Godot 4 zombie survival prototype built with a UI-first product shell and incremental gameplay implementation.

The project aims to keep the full product flow visible early while implementing gameplay systems in small, testable steps.

## Current Loop

```text
Move -> Auto Shoot -> Kill Zombies -> Gain XP -> Level Up -> Choose Upgrade -> Repeat
```

## Product Flow

```text
Main Menu
-> Mode Select
-> Hero Select
-> Equipment Select
-> Pet Select
-> Gameplay
-> Pause / Upgrade Selection
-> Game Over
-> Result Screen
-> Main Menu
```

Some screens include locked or placeholder content by design. The UI should show the intended product structure without pretending unfinished systems are fully playable.

## Current Architecture

Runtime and content data are separated:

* `GameManager.gd` manages runtime/session state, gameplay progression, selected loadout, mission progress, and upgrade application.
* `GameData.gd` loads and validates content definitions from `/data/*.json`.
* `SaveManager.gd` owns persistence, fresh-save defaults, merge behavior, and selected loadout validation.

Content definitions are no longer hardcoded as large dictionaries inside `GameManager.gd`.

## Data Layer

Content lives in simple JSON files:

```text
/data
  heroes.json
  weapons.json
  pets.json
  upgrades.json
  missions.json
  permanent_upgrades.json
```

`scripts/data/GameData.gd` loads these files once, validates their shape, fills safe defaults where possible, skips invalid upgrade entries, and injects required fallback content when needed.

Required fallback IDs:

* `hero_knight`
* `weapon_basic`
* `pet_drone`

If a JSON file is missing, malformed, empty, or has the wrong top-level type, `GameData.gd` falls back to built-in safe data and logs warnings such as:

```text
GameData warning: weapons.json entry "weapon_basic" invalid fire_rate; using 0.5.
```

## Progression Defaults

A fresh save starts with minimal starter content:

* unlocked heroes: `["hero_knight"]`
* unlocked weapons: `["weapon_basic"]`
* unlocked pets: `["pet_drone"]`

Existing saves are preserved. Loading a save merges with defaults, keeps already-unlocked content, and validates the selected loadout. If a selected hero, weapon, or pet is missing from its unlocked list, `SaveManager.gd` falls back to the starter IDs above.

## Implemented Now

* Mobile-oriented UI shell
* Hero, weapon, and pet selection with locked states
* Data-driven hero, weapon, pet, upgrade, mission, and permanent upgrade definitions
* Save/load progression defaults
* Player movement on the X/Z plane
* Fixed camera
* Auto shooting with weapon range
* Enemy spawning, chasing, recycling, contact damage, and death
* XP, level-up upgrade selection, missions, boss wave support, game over, and result flow

## Placeholder Or Planned

* Deep inventory and equipment logic
* Armor and accessory gameplay
* Full unlock economy/shop
* Additional modes beyond Survival
* Larger content batches

## Project Structure

```text
/data                 JSON content definitions
/scenes               Godot scenes
  /core
  /effects
  /enemy
  /entities
  /levels
  /player
  /ui
/scripts              GDScript logic
  /autoload
  /camera
  /core
  /data
  /effects
  /enemy
  /entities
  /levels
  /player
  /test
  /ui
/docs                 Design docs
/ai-tasks             Implementation task docs and schema notes
/assets               External art/audio assets, ignored by Git
```

## Asset Setup

The project currently references external KayKit, Styloo, Wenrexa, and character/animation assets under `/assets`. That folder is ignored by Git, so a fresh checkout needs those packs restored locally before Godot can load every scene without missing-resource errors. Hero models and weapon models are separate assets; weapons are attached at runtime to the hero `handslot.r` bone.

Referenced folders include:

```text
assets/KayKit_Adventurers_2.0_FREE
assets/KayKit_Skeletons_1.1_FREE
assets/KayKit_Forest_Nature_Pack_1.0_FREE
assets/KayKit_DungeonRemastered_1.1_FREE
assets/Modular Character Outfits - Fantasy[Standard]
assets/Styloo Guns Asset Pack GLTF FBX V1.1
assets/Universal Animation Library[Standard]
assets/wenrexa_ui_sci_fi_01
```

## Development Rules

* Keep UI screens visible even when systems are unfinished.
* Use locked or placeholder states for incomplete features.
* Keep data readable and compatible with `GameData.gd`.
* Do not add new schema fields without updating the schema document.
* Keep gameplay changes small and verify with the smoke test.

## Smoke Test

Use a Godot 4.5 console/headless binary and point it at this project:

```powershell
& "C:\Users\tinht\Downloads\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64_console.exe" --headless --path "C:\Users\tinht\Godot2_5DScaffold" --script "res://scripts/test/smoke_test.gd"
```

On macOS/Linux, use the same arguments with the local Godot binary path and this repository path.
