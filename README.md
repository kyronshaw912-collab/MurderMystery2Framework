# RivalsFramework

A focused Aimbot + ESP framework for the Roblox FPS **Rivals** (by Nosniy
Games), built by NameHub.

## Status

- Build: `v0.1.0` - initial release after pivoting from PriorExtinctionFramework.
- Scope: **Aimbot + ESP only**.

## Supported games

| PlaceId | Name |
| --- | --- |
| 17625359962 | Rivals (main) |

The script refuses to run on any other PlaceId.

> Note: Rivals runs Roblox's Hyperion / Byfron client anti-cheat. This
> script only works inside executors that bypass Hyperion (Solara, Wave,
> AWP, etc on PC; Delta / Codex / Hydrogen on mobile). If your executor
> can't inject into Rivals, the script will never reach the loadstring.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kyronshaw912-collab/RivalsFramework/main/RivalsFramework.lua"))()
```

## Features

### Aimbot (Aimbot tab)

- **FOV-circle target acquisition** - configurable pixel radius around the
  crosshair; only enemies whose target-bone projects inside the FOV are
  considered.
- **Bone selection** - `Head` (default), `UpperTorso`, `HumanoidRootPart`,
  `Random`.
- **Smoothness** - 0 = snap to target, 0.95 = barely move (legit-style).
- **Prediction** - lerps the target's position forward by their velocity *
  N seconds to compensate for network ping. 0.13 s is a good default for
  ~100 ms ping.
- **Team check** - skips friendlies whose `Player.Team` matches yours.
- **Visible check** - raycast from camera to the target; skips occluded
  enemies.
- **Sticky target** - keep aiming at the same player until they die /
  leave the FOV / become invisible (instead of re-acquiring every frame).
- **Hold / Toggle mode** - default is hold Right Mouse Button.
- **FOV circle visual** - thin circle around the crosshair so you can see
  the FOV radius. Colour-pickable, optionally filled.

### ESP (ESP tab)

- **Box ESP** - 2D bounding box around each enemy.
- **Name + distance** - tag with display name and distance in studs.
- **Healthbar** - vertical bar on the box, colour lerps red -> green.
- **Tracers** - line from screen origin (Bottom / Center / Mouse) to each
  enemy.
- **Chams** - through-wall character highlight via Roblox's native
  `Highlight` instance (works across executors).
- **Team check** - skip teammates.
- **Max distance** - hide ESP beyond N studs (default 2000).
- **Per-feature colours** - cycle through a small palette by clicking the
  swatch.

### Settings tab

- Live status (current target, candidates in FOV)
- Build label
- Unload Script button (cleans up all connections, Drawings, and the GUI)

## Build pipeline

`source.lua` is the readable Luau source; `RivalsFramework.lua` is the
darklua-processed build that ships via loadstring. The `obfuscate.js`
script (run automatically on every `git commit` via the pre-commit hook)
strips Luau type annotations, minifies, removes comments, and renames
locals.

## Files

- `source.lua` - readable source (gitignored).
- `RivalsFramework.lua` - the build that gets `HttpGet`'d.
- `obfuscate.js` - build pipeline.
- `.darklua.json` - darklua rules.
- `README.md` - this file.

## License

Personal use. Not affiliated with Rivals or Nosniy Games.
