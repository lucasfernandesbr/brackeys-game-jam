# Game Design — Investigation Game (Game Jam)

> Game scope. Source of truth for what is inside the jam's scope.
> Anything **not** here is out of scope, unless explicitly decided otherwise.

---

## 1. Overview

| Field | Value |
|---|---|
| **Genre** | Investigation / Mystery |
| **Player goal** | Correctly fill in an investigation board and solve the mystery |
| **Perspective** | First person |
| **Visual style** | Pixel art |
| **Engine** | Godot 4.x (GDScript) |
| **Target platform** | Desktop |
| **Jam deadline** | 7 days |
| **Input** | Mouse (point & click + drag & drop) |

**One-sentence pitch:** the player investigates a case from evidence accessed
through a computer and assembles the solution on an investigation board, closing
the case once they believe they have the answer.

---

## 2. Mechanics

Only two core mechanics. Nothing beyond this should be implemented without an
explicit decision.

### 2.1 Point & Click (mouse)
- Navigation between screens and scenes.
- Interaction with interface buttons.
- Interaction with the PC "desktop": opening folders, opening and reading
  documents.

### 2.2 Drag & Drop
- Single use: placing evidence on the investigation board.
- The player drags an evidence item and drops it at a position on the board.

---

## 3. Screen and Scene Structure

```
Start Screen
   ├── Start ──────────► Main Scene
   │                          ├── [Desktop button] ──► Desktop (Scene 2) ──► back ► Main Scene
   │                          └── [Board button] ──► Board (Scene 3) ──► Close Case
   ├── Settings ──► Settings Screen ──► Save ► back to Start
   └── Quit ──────────► exits the game
```

### 3.1 Start Screen
- **Start button** — loads the Main Scene.
- **Settings button** — opens the Settings Screen.
- **Quit Game button** — closes the application.

### 3.2 Settings Screen
- **Resolution** — 16:9. *(pending: list of selectable resolutions or fixed aspect ratio only)*
- **Audio slider** — raises or lowers the game volume.
- **Save button** — persists the settings made on the screen.

Rule: saved settings must be applied to the game.

### 3.3 Main Scene (main game scene)
It is the hub. The player is in first person and has two interaction points:
- **Desktop button / hotspot** (mouse click) — leads to Scene 2 (Desktop), where the evidence is.
- **Board button / hotspot** (mouse click) — leads to Scene 3 (evidence Board).

### 3.4 Desktop — Scene 2
Represents the computer's **desktop**.
- **"Evidence" folder**
- **"Witness Reports" folder**
- **Close-PC button** — returns to the Main Scene.

Rules:
- All interaction in this scene is **point & click**.
- This is where the player consults the case's investigative content.

### 3.5 Board — Scene 3
Investigation board where the deduction is recorded.
- **Board area** — receives evidence via **drag & drop**.
- **"Close Case" button** — finalizes the investigation with the board's current state.

Rules:
- Placing evidence is the game's only drag & drop action.
- "Close Case" evaluates how the board is filled in (win/lose condition).

---

## 4. Scope — Implementation Checklist

### Screens
- [ ] Start Screen (Start / Settings / Quit)
- [ ] Settings Screen (resolution, audio slider, save)
- [ ] Main Scene with 2 hotspots (Desktop and Board)
- [ ] Scene 2 — Desktop with clickable icons + EmailApp + close button
- [ ] Scene 3 — Board with evidence drop + Close Case button

### Systems
- [ ] Navigation between scenes
- [ ] Point & click / hotspot system
- [ ] Evidence drag & drop system
- [ ] Persistence and application of settings
- [ ] Global volume control
- [ ] Board evaluation when closing the case

### Content
- [ ] Pixel-art assets for the scenes (menu, room, PC, board)
- [ ] Evidence content
- [ ] Witness report content
- [ ] Audio

---

## 5. Open Decisions

Items not defined in the original scope. They need a decision before or during
implementation:

1. **Mystery / narrative** — what the case is, the characters and the correct solution.
2. **Board structure** — how many slots, whether they are categorized (suspect / weapon / motive / location) or free.
3. **Validation rule** — how "Close Case" determines right or wrong.
4. **End-game feedback** — is there a win/lose screen? Does it allow retrying?
5. **Evidence** — quantity, format (text, image, both) and whether all start available.
6. **Witness reports** — quantity and format.
7. **Evidence ↔ board relation** — are all PC evidence items draggable, or only a selection?
8. **Resolution** — selectable options or fixed 16:9 only.
9. **Progression** — does the game have a time limit, a number of attempts, or is it open-ended?
10. **Audio** — which sounds/music exist and whether the slider is a single master or separate (music/SFX).
