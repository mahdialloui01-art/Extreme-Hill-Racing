# Extreme Hill Racing

A mobile-first mountain racing prototype built with **Godot 4**.

## Current direction: true 3D with a side 2.5D camera

The active main scene has been converted to `Node3D` and now uses a real 3D world viewed from a side-follow camera.

### Implemented foundation
- Procedurally generated 3D mountain terrain with a continuous collision mesh.
- A raised dirt racing surface with visible track-edge details.
- 3D tree and rock loaders using `spruce-tree.glb` and `low-poly-nature-rock-cluster (1).glb`, with procedural fallbacks.
- A 3D rally SUV loader that uses the repository's `off-road-4x4 (2).glb` model when it imports successfully, with a procedural vehicle fallback.
- Basic 3D driving controller with acceleration, braking, gravity, slope alignment and restart.
- Orthographic side camera with smooth follow.
- On-screen touch controls, speed/distance HUD and keyboard support.
- Directional sunlight, shadows, ambient lighting and a procedural sky.
- Compatibility renderer selected for broad mobile support.

## Open the project

1. Install Godot 4.3 or newer.
2. Download this repository as a ZIP or clone it.
3. In Godot, choose **Import** and select the folder containing `project.godot`.
4. Open the project and press **Run Project**.

## Controls

- Hold **GAS** to accelerate.
- Hold **BRAKE** to slow down or reverse.
- Desktop: **Right/D** accelerates; **Left/A** brakes.
- Tap **↻** to restart.

## Status and limitations

This is the first true-3D conversion foundation, not a finished commercial-quality game. Imported vehicle, tree and rock assets are now referenced by the runtime scripts. The road still has a safe solid-color material fallback: the optional dirt albedo, normal and roughness images under `assets/materials/` are not currently present in the repository. The project has not yet been opened or run in the Godot editor in this environment, and no Android APK has been built or device-tested.

Next milestones include refined vehicle and terrain models, proper suspension and wheel contact, track materials and decals, dust/impact particles, engine and environment audio, menus, garage and upgrades, multiple biomes, progression and save data, performance profiling, and Android export testing.

## Project structure

```
project.godot
scenes/
  main.tscn
scripts/
  game_3d.gd
  car_3d.gd
  terrain_3d.gd
  game.gd       # retained 2D prototype
  car.gd        # retained 2D prototype
  terrain.gd    # retained 2D prototype
```
