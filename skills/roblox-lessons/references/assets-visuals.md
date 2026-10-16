# Assets and visuals lessons

## Importing safely
- **Reject any third-party model containing a script** (Script, LocalScript, ModuleScript — even disabled). Don't strip scripts; reject the asset. Free models often carry backdoors.
- Insert in Edit into a quarantine folder in ServerStorage (scripts don't run there), scan `GetDescendants()` for `LuaSourceContainer`, then move it into place. An approved exception (e.g. an NPC with dialogue scripts) is reviewed line by line first.
- Audio: use Roblox-licensed library audio (APM Music, Pro Sound Effects) or `rbxasset://sounds` — private audio from other creators won't play in your game. Some catalog audio is "not approved" for use; test that it actually plays.
- Studio-made models live in the place file — save the place and declare their folders in Rojo with `$ignoreUnknownInstances`.

## Meshes and models
- **Textured MeshParts ignore `BasePart.Color`.** Tint through `SurfaceAppearance.Color` (writable at runtime). `SurfaceAppearance.ColorMap` can only be set in Edit (plugin context).
- `AssetService:CreateMeshPartAsync` works in Edit.
- **Setting `Model.WorldPivot` drops the PrimaryPart's rotation** in some cases; set `PrimaryPart.PivotOffset = PrimaryPart.CFrame:Inverse() * desiredPivot` explicitly instead.
- Convention that kept code simple: PrimaryPart named `Body`, facing −Z, pivot at the feet; size via `Model:ScaleTo`.
- Terrain snaps to a 4-stud grid (ground surface at y = 2 for a flat fill); thin parts over terrain grass let grass blades poke through — turn the terrain under paths to a grassless material.
- Generate worlds from a builder script (re-runnable, versioned) rather than hand-placing objects other code depends on.

## Particles and light
- Small, additive particles vanish in daylight and get buried inside avatars. For character effects: emit from an invisible, non-colliding, massless part sized to the character's bounding box (welded to the root), `ShapeStyle = Surface`, `ShapeInOut = Outward`, `LightInfluence = 0`, and use `Brightness` (2–4) on glowing layers; too much makes a white blob.
- A light/white avatar hides white/blue effects — check effects on both light and dark avatars.
- Cosmetics that recolour the world: store each part's original `BaseColor`/`BaseMaterial` as attributes when building, so unequip/reset restores it. Make cosmetics obvious at a glance (a colour change on grass-coloured grass reads as broken).
