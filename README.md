# MurderMystery2Framework

NameHub's framework for **Roblox - Murder Mystery 2** (PlaceId `142823291`, UniverseId `66654135`).

## What it does

- **Role detection** - identifies the Murderer (knife) and Sheriff (gun) every 0.5s.
- **Player ESP** - box / name / `[Role]` tag / distance / health / tracer, color-coded by role.
- **Highlight chams** - per-role toggle + fill transparency + color picker.
- **Item ESP** - Gun-drop ESP (when the Sheriff dies) and Coin ESP.
- **Auto-grab coins** - configurable radius TP-pickup.
- **Movement** - walk-speed / jump-power overrides, infinite jump, noclip, full fly (WASD + Space/Ctrl).
- **Teleports** - TP-to-Murderer / TP-to-Sheriff / TP-to-Gun + Shift+Click teleport.
- **Sheriff aimbot** - mouse-only (mousemoverel), FOV circle, smoothing, optional murderer-only targeting.
- **Misc** - Anti-AFK, no-fall-damage, manual reset.
- **Linoria UI** - Theme + Save managers under `MM2NameHub/`.

## How it's loaded

This file is **auto-built** by `obfuscate.js` from `source.lua`. The published binary is `MurderMystery2Framework.lua` and is consumed by the NameHub universal loader.

Direct loadstring:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kyronshaw912-collab/MurderMystery2Framework/main/MurderMystery2Framework.lua"))()
```

Universal loader (auto-detects MM2 by PlaceId / UniverseId):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kyronshaw912-collab/NameHub/main/loader.lua"))()
```

## Notes

- No Hyperion bypass needed - MM2 doesn't ship the LocalScript3 / ClientAlert anti-cheat that Rivals does. Any modern Roblox executor is enough.
- The game guard accepts either the MM2 UniverseId (`66654135`) or PlaceId (`142823291`), so VIP servers / re-skins of the main place still load the script correctly.
- Linoria source files (Library / ThemeManager / SaveManager) are **cached on disk** under `NameHub_Linoria/` after the first run, so subsequent loads start in under a second.
