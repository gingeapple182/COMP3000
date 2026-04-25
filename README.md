# Project Mismanagement

**Project Mismanagement** is a 3D puzzle game developed in **Godot 4.6** for my COMP3000 final year project.

The game is set in a chaotic office environment where the player takes on the role of a new IT technician responsible for fixing broken office systems. These systems are represented through grid-based logic puzzles, where the player places signal blocks, connectors, and logic gates to produce the required output.

The project combines a first-person office hub with interactive puzzle scenes designed around digital logic concepts such as signal flow, Boolean values, and logic gates.

---

## Project Overview

The main gameplay loop involves exploring the office, interacting with broken systems, and completing logic-based puzzle boards.

In each puzzle, the player must arrange available components on a grid so that the correct signal reaches the output node. Components include:

- TRUE and FALSE value blocks
- Connectors for routing signals
- Logic gates such as AND, OR, NOT, NAND, NOR, XOR, and XNOR
- Output nodes with a required target result

The aim of the project is to turn abstract computing logic into a more interactive and visual experience, allowing players to test solutions, observe signal behaviour, and iterate on their layouts.

---

## Downloading the Playable Release

A standalone Windows build is available from the **Releases** section of this repository.

### Latest Release

Download the latest `.exe` file from the release page:

[Download Project Mismanagement Release](../../releases)

The current release uses an embedded `.pck`, so the game should run as a standalone executable without requiring any additional files.

### Running the Release Build

1. Go to the repository's **Releases** page.
2. Download the latest `ProjectMismanagement_*.exe` file.
3. Run the downloaded executable.

Depending on Windows security settings, you may need to confirm that you want to run the file.

---

## Running the Project in Godot

Markers or developers can also download the full project repository and run it directly in Godot.

This project was developed using:

**Godot 4.6 stable**

Godot 4.6 stable can be downloaded from the official Godot archive:

https://godotengine.org/download/archive/4.6-stable/

### Steps to Run from Source

1. Download or clone this repository.
2. Open **Godot 4.6 stable**.
3. Select **Import** from the Godot Project Manager.
4. Browse to the downloaded repository folder.
5. Select the `project.godot` file.
6. Open the project.
7. Press **Run Project** from the Godot editor.

The project should run directly from the Godot editor once imported.

---

## Repository Download Instructions

If downloading the repository manually:

1. Click the green **Code** button on this GitHub page.
2. Select **Download ZIP**.
3. Extract the downloaded ZIP file.
4. Open Godot 4.6 stable.
5. Import the extracted folder using the `project.godot` file.

Alternatively, the repository can be cloned using Git:

```bash
git clone https://github.com/gingeapple182/COMP3000.git
```

Then open the cloned folder in Godot 4.6 stable.

---

## Controls

Basic controls are:

| Action | Input |
|---|---|
| Move | WASD |
| Look Around | Mouse |
| Interact | E |
| Pause | Escape |
| Test Puzzle Solution | On-screen button |

Some controls may vary slightly depending on the current scene or puzzle interaction.

---

## Project Status

This project is currently in a pre-release state and was created as part of a university final year project submission.

A further release may be added before final submission, including final fixes, polish, or presentation improvements.

---

## Development

Developed by **Oliver Cole**  
Computer Science (Games Development)  
University of Plymouth

GitHub: [gingeapple182](https://github.com/gingeapple182)