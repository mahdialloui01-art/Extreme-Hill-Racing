# Extreme Hill Racing

A mobile-first mountain racing game prototype built with Godot 4.3+.

## Current build: Mountain Stage 01

The project is being rebuilt from a minimal driving prototype into a designed side-view 2.5D mountain stage.

### Implemented in this rebuild
- A continuous 4.2 km mountain route with generated collision terrain.
- A procedural gravel/dirt road texture generated at runtime (no missing external texture dependency).
- Visible pale road-edge lines, broken centre guide markings and loose-gravel shoulders.
- Two distant mountain silhouette layers to add depth behind the playable ridge.
- Four distinct roadside environment zones: green foothill forest, exposed rocky pass, highland scrub and sparse summit.
- Roadside trees, bushes and boulders, using imported GLB assets when available and procedural fallbacks otherwise.
- Wooden distance boards with billboarded metre labels along the stage.
- Existing 3D rally vehicle, touch controls, speed/distance HUD and restart retained.

## Open the project
1. Install Godot 4.3 or newer.
2. Download the repository ZIP or clone the repository.
3. In Godot, choose **Import** and select the folder containing `project.godot`.
4. Open the project and press **Run Project**.

## Controls
- Hold **GAS** to accelerate.
- Hold **BRAKE** to slow down or reverse.
- Desktop: **Right/D** accelerates; **Left/A** brakes.
- Tap **↻** to restart.

## Honest development status

This is a substantial environment rebuild, not yet a finished commercial-quality game. Stage 01 now has a road surface treatment, road markings, background mountain layers and four scenery zones. The gameplay loop still needs stage objectives, fuel and collectible systems, obstacles, menus, garage/upgrades, audio, save/progression, device performance profiling and Android export testing.

The repository includes a GitHub Actions Godot validation workflow. A workflow run is triggered by each push, but a successful run and an Android device test must be confirmed before calling the build verified.

## Project structure
```
project.godot
scenes/
  main.tscn
scripts/
  game_3d.gd
  car_3d.gd
  terrain_3d.gd
  game.gd
  car.gd
  terrain.gd
```
