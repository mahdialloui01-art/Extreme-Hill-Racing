# Extreme Hill Racing

A mobile-first hill-driving game prototype made with **Godot 4**.

## Current prototype

- 2.5D-style layered mountain scenery with a parallax depth illusion.
- Procedurally generated rolling mountain road with collision.
- Extra terrain layers, grassy edges and scattered rock details.
- Improved hand-drawn vehicle with layered bodywork, glass, lights, suspension and detailed wheels.
- Arcade vehicle controller with acceleration, braking, gravity and air rotation.
- Touch controls for Android, plus keyboard controls for desktop testing.
- Follow camera, speed/distance HUD and restart button.
- Godot Compatibility renderer with 2D MSAA enabled for mobile-friendly rendering.

## Open the project

1. Install Godot 4.3 or newer (Godot 4.4.1 is recommended).
2. Download this repository as a ZIP or clone it.
3. In Godot, choose **Import** and select the folder containing `project.godot`.
4. Open the project and press **Run Project**.

## Controls

- Touch **GAS** to accelerate.
- Touch **BRAKE** to slow down and rotate in the air.
- On desktop: Right/D accelerates, Left/A brakes.
- Tap the ↻ button to restart after a crash.

## Important

The current 2.5D look is built with layered 2D artwork and parallax, not a full 3D renderer. This is an upgraded prototype and still needs testing on a real device. Advanced suspension, wheel-ground physics, menus, garage, upgrades, multiple environments, audio, progression, saving and online features remain future milestones.

## Project structure

```
project.godot
scenes/
  main.tscn
scripts/
  game.gd
  car.gd
  terrain.gd
```
