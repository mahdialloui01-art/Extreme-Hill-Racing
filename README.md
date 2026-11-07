# Extreme Hill Racing

A mobile-first 2D hill-driving game prototype made with **Godot 4**.

## Current prototype

- Procedurally generated rolling hills with collision.
- Arcade vehicle controller with acceleration, braking, gravity and air rotation.
- Touch controls for Android, plus keyboard controls for desktop testing.
- Follow camera, speed/distance HUD and restart button.
- Lightweight Compatibility renderer target for a broad range of Android devices.

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

This is the first playable foundation, not a finished Hill Climb Racing 2-level game yet. Vehicle suspension, wheel-ground physics, menus, garage, upgrades, multiple environments, audio, progression, saving and online features are planned for later milestones.

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
