# 3D Art Asset Requirements

The 3D project now supports external GLB assets. The fallback meshes are placeholders only; replace them with authored assets before calling the game visually finished.

## Required project paths

Place imported assets at these exact paths:

- `assets/vehicles/rally_suv.glb` — primary off-road rally vehicle.
- `assets/vegetation/fir_tree.glb` — tree model.
- `assets/rocks/boulder.glb` — rock/boulder model.
- `assets/materials/dirt_albedo.jpg` — road base-color texture.
- `assets/materials/dirt_normal.jpg` — tangent-space normal map (OpenGL orientation).
- `assets/materials/dirt_roughness.jpg` — roughness map.

Godot imports GLB/glTF scenes directly. Keep the vehicle facing local +X, local +Y up, and roughly 4.5 m long. Put the wheel pivots at wheel centers, align each wheel's local Z axis with its axle, and name it with `wheel` or `tire` so the controller can rotate it. If the source model uses another forward axis, correct its orientation in Blender before export.

Tree models should have their origin at ground level and a sensible real-world height (about 5–12 m). Rock models should have their origin near the bottom/ground contact point. Normalize model scale before export; runtime variation then adds modest scale and rotation changes.

## Candidate sources and licensing

- Off-road 4x4 game-ready GLB (about 19.9k triangles, 2K PBR maps, CC0): https://grab3d.com/models/vehicles/off-road-4x4/
- More realistic generic compact SUV GLB (4.6 MB, CC0; exterior visualization, no detailed suspension/powertrain): https://www.innerscene.com/tools/library/3d-parts/generic-compact-suv-9f157ee5
- Photoreal tree and rock library: https://polyhaven.com/models/nature/trees and https://polyhaven.com/models/nature/rocks
- Road/gravel PBR material example (CC0): https://ambientcg.com/view?id=Ground014
- Poly Haven license: https://polyhaven.com/license

Important mobile-performance note: do not import the full 8-million-triangle Fir Tree 01 source unoptimized. Use a game-ready low-poly/LOD variant or reduce it and bake detail into normal maps. Keep texture resolution appropriate for mobile (typically 1K–2K for hero assets, smaller for distant props), use LODs, and reuse materials/atlases.

## Current status

The code has optional loading hooks for the paths above and falls back to procedural placeholders when files are absent. The binary GLB and texture files are not yet present in this repository. The model pages and licenses must be checked again when downloading the final chosen files. No APK or in-editor validation has been completed.
