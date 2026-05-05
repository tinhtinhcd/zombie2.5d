# Commit 8 MVP Completion Notes

## Scope

- Added explicit `assets/audio/sfx/` and `assets/audio/music/` directories.
- Centralized required SFX and music paths in `AudioManager`.
- Missing audio files now warn once per path and never block gameplay.
- Daily quests now generate three entries from `data/missions.json`, reset once per calendar day, and persist through `SaveManager`.
- Added a permanent upgrade shop tab with rank, max rank, cost, effect text, and disabled purchase states.
- Replaced placeholder hero/guard shop messaging with upgrade lists.
- Added one new playable level, `level_003` / Overpass Ruins, after Factory Yard.

## Notes

- Actual `.ogg` assets are still placeholders/missing by design; runtime handling is safe until final audio is sourced.
- Hero and guard shop upgrades are lightweight MVP progression: levels persist and selected hero/guard gameplay stats receive small bonuses.
