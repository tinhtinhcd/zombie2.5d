# STEP 11 — Add Boss

## 🎯 Goal

Add a **simple boss system** to create milestone encounters and break the normal combat rhythm.

This step improves:

* pacing
* excitement
* challenge spikes
* sense of progression

---

# 🧠 Core Principle

> A boss should feel special because of timing, presence, and pressure — not because of complex code.

---

# 🧩 Scope of This Step

You must implement:

* one boss type
* boss spawn timing
* boss health
* boss attack behavior (simple)
* boss defeat handling
* UI indication for boss encounter

You must NOT implement:

* multiple bosses
* cinematic intros
* advanced phase systems
* bullet hell patterns
* complex boss AI trees

---

# 👑 Boss Timing

## Spawn Rule

The boss should appear at a clear milestone.

Suggested MVP rule:

* every 10th wave
* or after a fixed survival time

Choose one simple rule and use it consistently.

---

# 🧟 Boss Identity

## One Boss Only

The boss should be a stronger version of the normal enemy fantasy:

* larger
* tougher
* more threatening
* visually distinct

---

## Boss Stats

Track:

```text
Boss
- id
- hp
- speed
- damage
- type
```

Boss must have:

* much higher HP than regular enemies
* slightly lower or similar speed
* stronger contact damage

---

# ⚔️ Boss Behavior

## Allowed Behavior

Keep boss behavior simple:

* chase player
* attack on contact
* optional simple special move if easy to implement

---

## Optional Simple Special Move

Only add if very simple:

* short dash
* short cooldown attack burst
* area slam

If special move adds too much complexity, skip it.

---

# 🎮 Encounter Rules

During boss encounter:

* normal gameplay continues
* boss becomes the primary threat
* player should clearly understand a boss is active

---

# 🧠 Boss Feel

The boss should feel different through:

* larger model or scale
* higher HP
* stronger damage
* UI announcement
* slower time-to-kill

---

# 📢 UI Requirements

When a boss appears, show:

* "Boss Incoming" or similar message
* boss health bar or boss HP indicator
* clear visual emphasis

---

# 💥 Boss Damage and Death

## Damage

Boss takes damage using the existing combat system.

Do NOT build a separate combat pipeline.

---

## Death

When boss HP reaches zero:

* remove boss
* optionally reward player
* return to normal wave flow

---

# 🎁 Reward Rule

Keep reward simple:

* extra XP
* or one guaranteed level-up
* or one bonus upgrade moment

Choose one simple reward.

---

# 🌊 Spawn Flow Integration

Update wave logic so that:

* normal waves continue normally
* boss wave replaces or overlays a normal wave
* once boss dies, wave progression resumes

Keep the wave flow readable.

---

# ⚠️ Avoid

Do NOT:

* build a full boss framework
* add multiple phases
* add cutscenes
* add several attack patterns
* overcomplicate encounter flow

---

# 🧠 Simplification Rules

Always choose:

* one boss over many
* one clear attack style over complex behavior
* reusing existing systems over new architecture

---

# 📱 Mobile Consideration

* boss visuals must remain readable
* keep effects lightweight
* boss health UI must be clear and not clutter the screen

---

# 🤖 Codex Instructions

* Reuse existing enemy and combat systems where possible
* Keep boss logic simple
* Add only the minimum UI required
* Avoid building future-proof boss architecture
* Prefer a strong simple encounter over a complex unfinished one

---

# 📦 Deliverables

Provide:

1. boss scene or boss variant
2. boss spawn logic
3. boss UI indicator
4. boss reward handling
5. summary of encounter flow

---

# 🎯 Acceptance Criteria

This step is complete when:

* a boss appears at a clear milestone
* boss is visibly distinct from normal enemies
* boss can fight and be defeated
* boss encounter feels different from normal waves
* wave progression resumes after boss death

---

# 🧠 Final Principle

> One memorable boss is better than a complicated boss system.

---
