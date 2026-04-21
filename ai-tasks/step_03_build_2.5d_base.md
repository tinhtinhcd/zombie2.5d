# STEP 03 — Build 2.5D Base

## 🎯 Goal

Create the **core 2.5D gameplay foundation**:

* 3D scene setup
* Fixed camera
* Player movement (X/Z plane only)

No combat yet.
No enemies yet.
No complex systems.

---

# 🧠 Core Principle

> Build a stable and simple 2.5D foundation before adding gameplay systems.

---

# 🧩 Scope of This Step

You must implement:

* Main 3D scene
* Fixed camera
* Player entity
* Player movement

You must NOT implement:

* Shooting
* Enemy AI
* XP system
* Combat logic

---

# 🏗️ Scene Setup

## Main Scene

```text
Main (Node3D)
├── Ground (MeshInstance3D)
├── Player (CharacterBody3D)
├── Camera3D
├── Light (DirectionalLight3D)
└── UI (CanvasLayer)
```

---

# 🌍 Ground Setup

* Use a simple plane mesh
* Scale it large enough for movement
* Apply basic material

---

# 🎥 Camera Setup (CRITICAL)

## Requirements

* Fixed angle
* Fixed offset from hero
* Fixed rotation
* Follow the hero position only
* No camera rotation during gameplay

---

## Example Setup

```text
Position: (0, 10, 10)
Rotation: (-45°, 0, 0)
```

---

## Rules

* Do NOT rotate camera during gameplay
* Do NOT attach camera directly to player
* Keep camera movement stable and predictable

---

# Endless Map Setup

## Requirements

* Use repeated ground tiles
* Keep only a small grid of tiles around the hero
* Reposition tiles as the hero moves
* Reuse the same lightweight tile art
* Clamp the playable map to a large fixed physical radius, default 600 meters

## Rules

* Do NOT build procedural generation yet
* Do NOT build rooms, doors, or pathfinding here
* Keep the map visually continuous for basic survival movement

---

# 🧍 Player Setup

## Node Structure

```text
Player (CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D
```

---

## Movement Rules

* Movement only on X/Z plane
* No vertical movement
* No jump
* No gravity needed

---

# 🎮 Movement Logic

## Input

* Forward / Backward
* Left / Right

---

## Behavior

* Smooth movement
* Constant speed
* No acceleration system required

---

## Example Concept

```text
direction = input_vector (x, z)
velocity = direction * speed
move_and_slide()
```

---

# 🧠 Constraints

## MUST

* Keep movement simple
* Use CharacterBody3D
* Keep code readable

---

## MUST NOT

* Add physics complexity
* Add animation system yet
* Add rotation smoothing system
* Add camera behavior beyond fixed-offset hero follow

---

# 🎨 Visual Rules

* Use placeholder 3D models
* Use consistent scale
* Do not optimize visuals yet

---

# 📱 Mobile Consideration

* Keep scene lightweight
* Avoid heavy assets
* Avoid high poly models

---

# 🤖 Codex Instructions

* Work with existing files if present
* Only add what is necessary
* Keep implementation minimal
* Do not overengineer movement system

---

# 📦 Deliverables

Provide:

1. Main 3D scene
2. Player scene
3. Movement script
4. Camera setup
5. Confirmation that movement works

---

# 🎯 Acceptance Criteria

This step is complete when:

* Player can move on X/Z plane
* Camera follows the hero with fixed angle and offset
* Endless repeated map stays under the hero
* Scene runs without errors
* Movement feels smooth and controllable

---

# 🧠 Final Principle

> A stable base is more important than adding features early.

---
