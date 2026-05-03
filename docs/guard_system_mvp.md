# Guard System MVP (Shooter Guard)

## Scope
- Adds an MVP guard system with one hireable guard type: `guard_shooter`.
- Guard is the active attacker companion.
- Pet remains visible/support but no longer acts as primary active attacker.

## Implemented Components
- `scripts/entities/shooter_guard.gd`
- `scenes/entities/shooter_guard.tscn`
- Guard runtime spawn path in `scripts/core/game.gd`.
- Guard hire API in `scripts/autoload/GameManager.gd`:
  - `request_hire_guard(guard_id)`
  - `hire_guard_after_ad_success(guard_id)` (placeholder)
- Upgrade entry for hiring guard in `data/upgrades.json`.

## Gameplay Behavior
- Shooter Guard follows near player.
- Scans nearest alive enemy every `target_scan_interval`.
- Attacks on timer (`attack_interval`) using projectile.
- Stops behavior when gameplay is paused/game over.
- Max guards limited to 1 for MVP.
- Guard exists for the run and is cleared on scene exit.

## Future TODOs
- Add data-driven `guards.json` and load guard definitions from GameData.
- Add currency and rewarded-ad hire flow integration.
- Add more guard types.
