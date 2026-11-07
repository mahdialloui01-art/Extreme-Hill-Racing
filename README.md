# Extreme Hill Racing

Godot 4.3+ mobile-first 2.5D mountain driving game project.

## Five-stage career

- Five unlockable routes: Pine Foothills, Rock Pass, Desert Dunes, Frozen Ridge and Volcano Run.
- Five separately scripted maps now run 4,200 m, 4,600 m, 5,000 m, 5,500 m and 6,000 m, with Rookie, Easy, Medium, Hard and Extreme difficulty labels.
- Each stage loads its own map script with a distinct terrain-height profile, scenery distribution, landmark structures and biome palette; the five routes are no longer palette-only variants.
- Biome-specific scenery includes pine forests and timber bridges, canyon arches and rock spires, desert cacti and sandstone monoliths, glacier crystals and ice walls, plus volcanic vents and obsidian formations.
- Each biome has its own collision hazards: logs and stumps, boulders and stone pillars, cacti and sand barriers, ice spikes and snow blocks, or lava vents and obsidian spikes. Hazard spacing tightens on harder maps.
- Clear a stage to unlock the next one; unlocked progress, wallet, best distance and engine level are saved locally.

## Driving world

- Continuous mountain route with terrain collision.
- Runtime-generated gravel road surface, painted road edges, broken centre markers and gravel shoulders.
- Layered distant mountain silhouettes and four visual regions: Pine Foothills, The Rock Pass, High Country and Summit Ridge.
- Imported spruce/rock GLB scenery with procedural fallbacks.
- Branded title screen, stage selector, pause/resume overlay and direct garage upgrade shortcut.
- Wooden distance boards and named region landmarks.
- 3D rally SUV, touch gas/brake controls, keyboard controls, follow camera and restart.

## Gameplay systems added

- Fuel meter; fuel drains while accelerating.
- Fuel cans restore fuel and are placed along the route.
- Gold coin pickups award 10 coins each.
- Timber trail obstacles add collision challenges.
- Stage progress bar and finish lines matched to each route length (2,400–4,200 metres).
- Stage completion rewards increase from 500 coins on the first route by 150 coins per later route.
- Career wallet, best distance and engine upgrade level are saved locally with ConfigFile.
- Five engine power upgrade levels can be purchased with collected coins.
- Procedurally synthesized looping mountain soundtrack, variable-pitch engine loop, and pickup, fuel, crash, finish and upgrade sound effects.
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
- Reach the distance shown for the selected stage to finish it and unlock the next route.
- Tap **Ⅱ** to pause, then resume or restart from the pause screen.
- Tap **↻** to restart.

## Remaining work before calling this a complete commercial game

The current repository is still a development build, not a 100 MB finished release. The five routes now use separate procedural map scripts and unique biome landmark/hazard sets, while sharing a common terrain-rendering foundation. They still need higher-resolution sourced PBR asset packs, recorded audio, and additional authored set pieces. The soundtrack and effects are synthesized in code rather than recorded production audio. A fuller garage with additional vehicles, richer sourced PBR assets, mobile UI scaling and performance profiling, accessibility/options, Android export configuration and real-device testing remain. File size will come from legitimate high-quality assets, audio and level content—not padding or duplicated files.

A GitHub Actions workflow runs Godot headless import and scene checks on pushes. Check the Actions tab for the latest commit's result; a CI pass does not replace Android device testing.
