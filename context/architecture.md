# Architecture & Conventions (Godot 4.x)

> Repository structure and code conventions for the project.

---

## 1. Repository Structure

**One folder per unit** convention (scene / component / autoload):

```
res://
├── autoloads/          # singletons (one per folder)
│   ├── audio_manager/      # volume control / Audio Bus
│   ├── event_bus/          # decoupled signal-based communication
│   ├── game_state/         # match / case state
│   ├── scene_manager/      # navigation between scenes
│   └── settings_manager/   # persistence and application of settings
├── components/         # reusable components:
│                       #   hotspot, draggable_evidence, document_window,
│                       #   evidence_list, evidence_slot, folder_item,
│                       #   menu_button, record_sheet, close_window_tab_button
├── scenes/             # main_menu, settings, main_scene, desktop, board,
│                       #   intro, case_presentation, credits, dev
├── data/               # cases, records, resources (case_data, evidence_data)
└── assets/             # sprites, fonts, audio
```

⚠️ When moving/renaming scenes, watch out for Godot regenerating `.tscn` at the
old path — verify the result after refactoring the structure.

---

## 2. Code Conventions

- Scenes and scripts in `snake_case`; classes in `PascalCase`.
- Scene navigation and settings/audio via autoload/singleton
  (`scene_manager`, `settings_manager`, `audio_manager`); decoupled
  communication via `event_bus`; game state in `game_state`.
- Settings persisted in `user://` (e.g. `ConfigFile`).
- Audio controlled through an Audio Bus, wired to the settings slider.
- Case content (evidence, witnesses, correct answer) in data files
  (`.json`/`.tres`), separated from logic.

---

## 3. Pixel Art

- **Nearest** texture filter.
- `snap_2d_transforms_to_pixel` enabled.
- 16:9 viewport with `canvas_items` stretch mode.

---

## 4. UI

- UI font: **TinyUnicode** (`assets/fonts`).

---

## 5. Lint & Formatting

The project uses gdtoolkit (`gdformat` / `gdlint`) and the linter in
`addons/gdscript-linter`. Run the formatter/linter before committing GDScript
changes.
