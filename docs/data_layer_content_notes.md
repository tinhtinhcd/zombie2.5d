# Data Layer Content Notes

## P2 Content Scope

The P2 data pass defines the planned five-hero, five-pet, five-guardian roster while preserving the currently playable three-hero and three-pet UI flow.

## Placeholder Runtime Mappings

- `hero_engineer` currently reuses the Knight model path until a dedicated hero asset is added.
- `hero_medic` currently reuses the Mage model path until a dedicated hero asset is added.
- `pet_beetle` currently reuses the Drone companion scene until a dedicated pet asset is added.
- `pet_orb` currently reuses the Wisp companion scene until a dedicated pet asset is added.
- Guardian entries use `res://scenes/entities/shooter_guard.tscn` as a safe placeholder model path until dedicated guardian scenes land.

These mappings are intentional data fallbacks so future systems can resolve complete content IDs without breaking the current gameplay loop.
