# Content Roadmap

## Purpose

Define how game content should be expanded over time while keeping the current implementation honest.

This roadmap distinguishes:

* implemented now
* visible placeholder UI
* planned later content

## Current Implementation Snapshot

### Implemented Now

* Survival flow is playable.
* Hero, weapon, pet, upgrade, mission, and permanent upgrade content lives in `/data/*.json`.
* `GameData.gd` loads and validates JSON content.
* Fresh saves unlock only starter content:

  * `hero_knight`
  * `weapon_basic`
  * `pet_drone`

* Locked heroes, weapons, and pets remain visible in UI.
* Auto-fire, weapon range, enemy chase, XP, level-up upgrades, missions, boss wave support, game over, and result flow exist.

### Placeholder In UI

* Armor slot
* Accessory slot
* Deep inventory behavior
* Additional modes beyond Survival
* Shop-style unlock economy

### Planned Later

* More unlock paths
* More enemy behaviors
* More bosses
* Deeper inventory and equipment effects
* Larger content batches

Do not describe placeholder UI as playable content until gameplay logic exists.

## Core Philosophy

* Start small, expand gradually.
* Each addition must improve gameplay.
* Avoid content explosion.
* Prioritize meaningful variation.
* Do not add new content types until existing ones feel good.

## Phase Overview

### Phase 1 - MVP Content

Minimal playable survival content:

* starter hero unlocked: `hero_knight`
* starter weapon unlocked: `weapon_basic`
* starter pet unlocked: `pet_drone`
* basic enemy pressure
* boss wave support
* bounded repeated map
* simple missions

### Phase 2 - Core Expansion

Add meaningful variety without making placeholder UI look fully playable:

* unlock paths for existing locked heroes
* unlock paths for existing locked weapons
* unlock paths for existing locked pets
* 2-3 enemy types with clear behavior differences
* 1-2 boss variations
* 3-5 missions
* first real equipment/inventory effects only if the core loop is stable

### Phase 3 - Depth Expansion

Enhance replayability:

* 5+ heroes
* 5+ weapons
* 4+ enemy types
* 3+ bosses
* 4-6 room/map variations
* 6-10 missions
* 3-5 pets

### Phase 4 - Content Scaling

Expand content volume:

* more variations
* themed content packs
* challenge modes

## Hero Roadmap

### Phase 1

* `hero_knight` is the only fresh-save unlocked hero.
* Other hero entries may be visible but should remain locked until progression supports them.

### Phase 2

* Add unlock paths for current locked heroes.
* Add one more hero only after hero selection and save validation remain stable.

### Phase 3

* Specialist hero
* Tank hero

Design rule: each hero must feel different and be understandable in under 5 seconds.

## Weapon Roadmap

### Phase 1

* `weapon_basic` is the only fresh-save unlocked weapon.
* Other weapon entries may exist in data/UI but should remain locked until progression supports them.

### Phase 2

* Add unlock paths for current locked weapons.
* Tune spread, rapid, and heavy style weapons after starter combat feels stable.

### Phase 3

* Piercing weapon
* Area damage weapon
* More distinct weapon behavior

Design rule: each weapon must change gameplay behavior, not just increase numbers.

## Pet Roadmap

### Phase 1

* `pet_drone` is unlocked by default as the safe starter pet option.
* Other pets may remain visible as locked content.

### Phase 2

* Add unlock paths for additional pets.
* Expand pet behavior only after basic combat readability is stable.

### Phase 3

* Collector pet
* Hybrid pet

Design rule: each pet must provide a visible benefit without complex interaction.

## Enemy Roadmap

### Phase 1

* Basic zombie pressure.
* Simple enemy variants and boss support may exist in code, but deeper enemy content should stay lightweight.

### Phase 2

* Fast zombie
* Tank zombie

### Phase 3

* Ranged enemy
* Special ability enemy

Design rule: enemies must change player behavior and create pressure or strategy.

## Boss Roadmap

### Phase 1

* Basic boss wave support.

### Phase 2

* 1-2 variations
* slightly different behaviors

### Phase 3

* more distinct bosses
* unique mechanics that remain simple

Design rule: bosses must feel like milestones without requiring complex AI.

## Map And Room Roadmap

### Phase 1

* Large bounded repeated map.

### Phase 2

* 2-3 simple area variations.

### Phase 3

* 4-6 themed area variations.

Design rule: maps should change spatial gameplay while staying lightweight.

## Mission Roadmap

### Phase 1

* simple kill mission
* simple XP mission
* simple wave mission

### Phase 2

* boss mission
* mixed missions

### Phase 3

* multi-condition missions
* meta missions

Design rule: missions must be clear, short, and immediately understandable.

## Content Scaling Strategy

Add content when:

* current content feels repetitive
* player has mastered current systems
* gameplay needs variety

Do not add content when:

* bugs exist
* performance issues exist
* systems are unstable

## Mobile Consideration

* limit simultaneous entities
* avoid visual clutter
* keep UI readable in portrait
* keep touch targets large enough

## Codex Instructions

* add content using the existing schema
* place supported content definitions in `/data/*.json`
* keep `GameData.gd` validation assumptions in sync with new fields
* follow naming conventions
* keep balance reasonable
* do not introduce new systems when adding content
* keep additions small and testable
* do not present locked or placeholder content as already playable

## Success Criteria

Content roadmap is working when:

* game feels progressively richer
* no sudden complexity spikes
* player always has new goals
* development remains controlled

## Final Principle

Add content to improve gameplay, not just to increase quantity.
