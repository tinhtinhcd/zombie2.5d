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

* Fixed position
* Fixed rotation
* No dynamic movement
* No follow logic (simple is better)

---

## Example Setup

```text
Position: (0, 10, 10)
Rotation: (-45°, 0, 0)
```

---

## Rules

* Do NOT rotate camera during gameplay
* Do NOT attach camera to player
* Keep camera stable

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
* Add camera tracking

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
* Camera is fixed and stable
* Scene runs without errors
* Movement feels smooth and controllable

---

# 🧠 Final Principle

> A stable base is more important than adding features early.

---
