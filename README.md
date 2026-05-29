# JurassicBlockyFramework

A Roblox automation / utility framework for **Jurassic Blocky**, ported from
`DinoFramework` (Dinosaur Simulator).

## Status

- Build: `v0.1.0` — initial port, untested in-game.
- Targets, stat names, and remote names are **best-guess keyword-based** until
  the diagnostic buttons are run inside Jurassic Blocky.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/<your-fork>/JurassicBlockyFramework/main/JurassicBlockyFramework.lua"))()
```

(Update the URL to your fork; the default is a placeholder.)

## What it does

- **Autofarm** — keyword-matched farm targets (berries, meat, fish, fossils,
  eggs, wood, stone, …). Add/remove keywords from the Farm tab.
- **Survival** — Inf Hunger / Inf Thirst / Inf Energy / Inf Oxygen via burst
  refill of detected remotes + client-side clamp fallback.
- **Movement** — speed boost, jump boost, infinite jump, noclip, fly,
  free-cam, instant teleport.
- **Combat** — auto-attack nearest player / NPC, auto-heal, target POV.
- **Visuals** — full ESP (boxes, tracers, chams, health bars, head dots),
  resource ESP, fullbright, no-fog, FOV slider.
- **Misc** — anti-AFK, stat-monitor HUD, info HUD (FPS/ping/coords),
  webhook reporting, config save/load, theme picker.

## What's different from DinoFramework

| Area | DinoFramework (DS) | JurassicBlockyFramework |
| --- | --- | --- |
| Anti-cheat | Aggressive AC-bypass with `__namecall` hooks, void-RE, FlingPrevention/InteriaHandler kill | Removed. Only a generic kick-bypass remains (off by default). |
| Movement TP | Chunked CFrame TP, underwater dive path, SwimSpeed velocity-fly | Plain CFrame TP + simple speed boost. Add chunking later only if JB kicks. |
| Farm targets | Meteorites, amber, SDNA/glass beams, diamond rocks | Berries, meat, fish, fossils, eggs, wood, stone (keyword-based, easy to extend) |
| File layout | 3000-line monolith | Same file, but with code-review fixes applied (see CHANGES below) |

## CHANGES (over the original DS port)

- `getgenv` polyfill moved to the top of the file.
- All `Connect()` calls go through `trackConnection` / `Library:_track`.
- Background `task.spawn` loops respect a single `Alive` flag, so
  `Library:Unload()` actually stops them.
- `swimSpeedTravelToTarget` removed entirely (JB doesn't need it).
- Velocity-fly / AlignPosition / underwater-TP code removed.
- `Util.fireRemote` and `findRemoteByKeywords` both cache lookups; the
  named-remote cache resolves once per server.
- Noclip uses a per-character BasePart cache instead of walking
  `Character:GetDescendants()` every physics step.
- Workspace instance names randomized per session (no `_DinoFramework_*` tells).
- `purgeStaleGuis` matches only ScreenGui names anchored at the start, not
  any substring.
- Hardcoded Discord webhook URL removed; the field is empty by default.
- `_G.JBPickupDiag` keyed once-per-target with a clear button.

## Tuning workflow (in-game)

1. Spawn into Jurassic Blocky.
2. Open the menu (default keybind: **Right Ctrl**).
3. **Survival → Print Diagnostics** — dumps every stat and remote name to F9
   and your clipboard.
4. **Main → Farm → Dump Workspace Names** — finds collectible-like instances
   in workspace.
5. Tell me the names that match your stats / collectibles and I'll widen the
   keyword lists.

## Files

- `JurassicBlockyFramework.lua` — the script. Distributable as a single
  loadstring.
- `README.md` — this file.
- `.gitignore` — standard editor/junk filter.

## License

Personal use. Not affiliated with the Jurassic Blocky game or its devs.
