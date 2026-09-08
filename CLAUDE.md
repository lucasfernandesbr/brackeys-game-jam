# CLAUDE.md — Project Context

> Context index for AI agents and for the developer.
> This file is the entry point: it brings the essentials inline and points to
> the detailed context documents (all versioned, under `context/`).

---

## Summary

A pixel-art, first-person **investigation / mystery** game, built in
**Godot 4.x (GDScript)** for desktop, controlled with the mouse. The player
investigates a case from evidence accessed through a computer and assembles the
solution on an investigation board, closing the case once they believe they
have the answer.

**Two core mechanics** (nothing beyond them without an explicit decision):

- **Point & Click** — navigation, UI buttons and interaction with the PC
  "desktop" (opening folders, reading documents).
- **Drag & Drop** — single use: placing evidence on the board.

**Screen flow:**

```
Start ──► Main Scene ──┬── [Desktop hotspot] ──► Desktop ──► back
          │            └── [Board hotspot]   ──► Board ──► Close Case
          ├── Settings
          └── Quit
```

---

## Context Documents

- [`context/game-design.md`](context/game-design.md) — full scope: overview,
  mechanics, screens/scenes, implementation checklist and open decisions.
  **Source of truth for scope.**
- [`context/architecture.md`](context/architecture.md) — repository structure
  (folder-per-unit, autoloads), code conventions, pixel art, UI and lint.

---

## Quick conventions

- Scenes and scripts in `snake_case`; classes in `PascalCase`.
- One folder per unit: `scenes/`, `components/`, `autoloads/`, `data/`.
- Autoloads: `scene_manager`, `settings_manager`, `audio_manager`, `event_bus`,
  `game_state`.
- UI uses the **TinyUnicode** font (`assets/fonts`) — not Minecraftia.
- Run `gdformat` / `gdlint` before committing GDScript.
