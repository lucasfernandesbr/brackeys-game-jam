# Detective

A pixel-art, first-person **investigation / mystery** game built in **Godot 4.x
(GDScript)** for desktop. You play a detective who works a case from evidence
accessed through a computer, then assembles the solution on an investigation
board — closing the case once you believe you have the answer.

Made for the **Brackeys Game Jam**.

## Gameplay

Two core mechanics, nothing beyond them:

- **Point & Click** — navigate between screens, use UI buttons, and interact
  with the PC desktop (open folders, read documents and witness reports).
- **Drag & Drop** — a single use: placing evidence on the investigation board.

### Screen flow

```
Start Screen
   ├── Start ──────────► Main Scene (hub, first person)
   │                          ├── [Desktop hotspot] ──► Desktop ──► back
   │                          └── [Board hotspot]   ──► Board ──► Close Case
   ├── Settings ──► resolution + audio, save/apply
   └── Quit
```

- **Desktop** — the computer screen, with the *Evidence* and *Witness Reports*
  folders and a button to return to the room.
- **Board** — drop evidence onto the board and press **Close Case** to be
  evaluated against the case's correct solution.

## Running the project

1. Install [Godot 4.7+](https://godotengine.org/download).
2. Open the project (`project.godot`) in the Godot editor.
3. Press **F5** (Play) to run from the main scene.

Target resolution is 1280×720 (16:9), `canvas_items` stretch, nearest texture
filtering for crisp pixel art.

## Project structure

One folder per unit (scene / component / autoload):

```
res://
├── autoloads/      # singletons: event_bus, settings_manager, audio_manager,
│                   #             game_state, scene_manager
├── components/     # reusable UI: hotspot, draggable_evidence, document_window,
│                   #              evidence_slot, menu_button, record_sheet, …
├── scenes/         # main_menu, settings, intro, case_presentation,
│                   #              main_scene, desktop, board, credits
├── data/           # case / evidence / record resources (separated from logic)
└── assets/         # sprites, fonts, audio
```

Settings are persisted to `user://` and applied to the game (resolution, master
volume via an Audio Bus).

## Development

- Scenes and scripts in `snake_case`; classes in `PascalCase`.
- UI font: **TinyUnicode** (`assets/fonts`).
- Run `gdformat` / `gdlint` (gdtoolkit) before committing GDScript. The project
  also ships the linter in `addons/gdscript-linter`.

See [`CLAUDE.md`](CLAUDE.md) and the [`context/`](context/) folder for the full
scope ([`game-design.md`](context/game-design.md)) and conventions
([`architecture.md`](context/architecture.md)).
