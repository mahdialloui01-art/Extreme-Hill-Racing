# Extreme Hill Racing

Godot 4.3+ mobile-first 2.5D mountain driving game project.

## Mountain Stage 01

- Continuous 4,200-world-unit mountain route with terrain collision.
- Runtime-generated gravel road surface, painted road edges, broken centre markers and gravel shoulders.
- Layered distant mountain silhouettes and four visual regions: Pine Foothills, The Rock Pass, High Country and Summit Ridge.
- Imported spruce/rock GLB scenery with procedural fallbacks.
- Branded title screen, pause/resume overlay and direct garage upgrade shortcut.
- Wooden distance boards and named region landmarks.
- 3D rally SUV, touch gas/brake controls, keyboard controls, follow camera and restart.

## Gameplay systems added

- Fuel meter; fuel drains while accelerating.
- Fuel cans restore fuel and are placed along the route.
- Gold coin pickups award 10 coins each.
- Timber trail obstacles add collision challenges.
- Stage progress bar and a finish condition at 4,200 metres.
- Completing the stage awards a 500-coin completion bonus.
- Career wallet, best distance and engine upgrade level are saved locally with ConfigFile.
- Five engine power upgrade levels can be purchased with collected coins.
- Restart resets the run and respawns pickups.

## Run

1. Install Godot 4.3 or newer.
2. Download ZIP and extract it.
3. Import the folder containing `project.godot` in Godot.
4. Run the project.

## Controls

- Hold **GAS** or press **Right/D** to accelerate.
- Hold **BRAKE** or press **Left/A** to brake/reverse.
- Collect red fuel cans and gold coins.
- Avoid timber obstacles.
- Reach 4,200 m to finish the stage.
- Tap **Ⅱ** to pause, then resume or restart from the pause screen.
- Tap **↻** to restart.

## Remaining work before calling this a complete commercial game

The current repository is still a development build, not a 100 MB finished release. It still needs a proper title/menu and stage-select flow, multiple independently designed stages, a fuller garage with additional vehicle upgrades and vehicle selection, richer sourced PBR art/audio, mobile UI scaling and performance profiling, accessibility/options, Android export configuration and real-device testing. File size will come from legitimate high-quality assets, audio and level content—not padding or duplicated files.

A GitHub Actions workflow runs Godot headless import and scene checks on pushes. Check the Actions tab for the latest commit's result; a CI pass does not replace Android device testing.
