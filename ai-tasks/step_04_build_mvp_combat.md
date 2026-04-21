# STEP 04 — Build MVP Combat

## 🎯 Goal

Implement the first real gameplay loop on top of the 2.5D base:

* auto shooting
* projectile movement
* enemy spawning
* enemy chase
* damage and death

This step creates the first playable combat prototype.

---

# 🧠 Core Principle

> Keep combat simple, readable, and testable.

No advanced systems yet.
No weapon variety yet.
No boss yet.

---

# 🧩 Scope of This Step

You must implement:

* projectile scene
* basic enemy scene
* enemy spawner
* auto shooting
* projectile hit detection
* enemy damage
* enemy death

You must NOT implement:

* XP system
* level up
* boss system
* pet system
* weapon switching

---

# 🏗️ Required Scene Structure

## Main Scene

```text id="814392"
Main (Node3D)
├── Ground
├── Player
├── EnemyContainer
├── ProjectileContainer
├── EnemySpawner
├── Camera3D
├── DirectionalLight3D
└── UI
```

---

## Projectile Scene

```text id="814393"
Projectile (Area3D or Node3D)
├── CollisionShape3D
├── MeshInstance3D
```

---

## Enemy Scene

```text id="814394"
Enemy (CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D
```

---

# 🔫 Auto Shooting

## Behavior

* Player automatically shoots at a fixed interval
* No manual aiming
* No manual trigger

## Targeting

Use the simplest possible rule:

* shoot toward the nearest enemy
* if no enemy exists, do nothing

## Player Facing

Use weapon range as the boundary for combat facing:

* if the nearest enemy is inside current weapon range, face that enemy
* if no enemy is inside current weapon range, face the movement direction
* do not rotate toward enemies that are too far away to shoot

---

## Rules

* fixed fire rate
* single projectile type
* single damage value

---

# 💥 Projectile Logic

## Behavior

* projectile moves in a straight line
* projectile destroys itself on hit
* projectile also destroys itself after a max lifetime or distance

---

## Collision

* detect hit with enemy
* apply damage
* then destroy projectile

---

# 🧟 Enemy Logic

## Behavior

* spawn at set intervals or counts
* move directly toward player
* use simple chase logic
* damage player on contact is optional in this step, but can be added if simple

---

## Health

Each enemy has:

* HP
* move speed

---

## Death

When HP <= 0:

* enemy dies
* remove enemy from scene

Do not add ragdoll or advanced effects.

---

# 🌊 Enemy Spawning

## Behavior

* spawn enemies around the player or around the arena
* use simple spawn positions
* avoid advanced spawn logic

---

## Rules

* one enemy type only
* simple spawn timer or count-based spawner
* keep it deterministic and readable

---

# 🎮 Combat Rules

## Allowed

* one player
* one enemy type
* one projectile type
* one fire rate
* one damage value

---

## Not Allowed Yet

* multiple weapons
* status effects
* critical hits
* splash damage
* enemy variants
* advanced AI

---

# 🧠 Simplification Rules

Always choose:

* direct logic over generic combat systems
* explicit variables over deep data models
* one enemy over many enemy classes

---

# 📱 Mobile Consideration

* keep enemy count modest
* avoid expensive per-frame work
* use simple collision
* no unnecessary visual effects

---

# 🤖 Codex Instructions

* Work with existing files instead of recreating everything
* Only add or modify what is necessary
* Prefer simple, testable code
* Keep the system easy to extend later
* Avoid building a full weapon framework now

---

# 📦 Deliverables

Provide:

1. Enemy scene
2. Projectile scene
3. Spawner logic
4. Player auto-shoot logic
5. Enemy damage/death logic
6. Summary of combat flow

---

# 🎯 Acceptance Criteria

This step is complete when:

* enemies spawn into the scene
* enemies move toward the player
* player automatically shoots
* projectiles move and hit enemies
* enemies die when HP reaches zero
* the game feels like a basic playable combat prototype

---

# 🧠 Final Principle

> First make combat work. Then make it deeper.

---
