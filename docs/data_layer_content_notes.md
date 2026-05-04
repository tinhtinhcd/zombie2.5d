# Data Layer Content Notes

## P2 Content Scope

The P2 data pass defines the planned five-hero, five-pet, five-guardian roster.

## Current Hero Roster

- Knight
- Rogue
- Mage
- Engineer
- Medic

Engineer and Medic are the current final roster choices in code. Older Ranger/Paladin references should be treated as replaced by Engineer/Medic unless a future design pass reintroduces them.

## Current Weapon Roster

- Basic Gun
- Spread Shot
- Rapid Blaster
- Heavy Launcher
- Chain Gun
- Bouncer

## Placeholder Runtime Mappings

- `hero_engineer` uses the Ranger model from the available KayKit pack until a dedicated Engineer asset is added.
- `hero_medic` uses the Barbarian model from the available KayKit pack until a dedicated Medic asset is added.
- `pet_beetle` currently reuses the Drone companion scene until a dedicated pet asset is added.
- `pet_orb` currently reuses the Wisp companion scene until a dedicated pet asset is added.
- Shooter-style guardian entries use `res://scenes/entities/shooter_guard.tscn` as a safe placeholder model path until dedicated guardian scenes land.
- Bruiser Guard uses `res://scenes/entities/guardians/bruiser_guard.tscn`.

These mappings are intentional data fallbacks so future systems can resolve complete content IDs without breaking the current gameplay loop.
