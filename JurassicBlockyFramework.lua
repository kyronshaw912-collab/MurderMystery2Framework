--!nonstrict
--[[
==============================================================================
    JurassicBlockyFramework.lua
    Roblox automation & utility framework for Jurassic Blocky.
    UI rendered with the bundled JBUI library.

    Author : Framework Template
    Version: v0.1.0
    Build  : 20260529-jb-initial-port
    Style  : Modular sections, Luau-native, single-file distributable.

    Ported from DinoFramework (Dinosaur Simulator) with:
      - DS-specific anti-cheat bypass removed (kept as optional generic path)
      - Aqua/SwimSpeed/Underwater CFrame TP removed
      - Farm targets and stat aliases re-keyworded for Jurassic Blocky
      - Code-review fixes applied (connection tracking, orphan-loop kill flag,
        cached remote lookups, noclip part cache, randomized instance names)
==============================================================================
--]]
local JB_BUILD = "v0.1.0 NameHub (jurassic-blocky-initial-port)"

------------------------------------------------------------------------------
-- 0. EXECUTOR GLOBAL POLYFILLS
--    These run before anything else so later code can rely on the helpers
--    even on executors that don't expose them. Polyfilled functions are
--    deliberately weak so we know "real" capability via _findExecFn below.
------------------------------------------------------------------------------
getgenv = getgenv or function() return _G end

local _RAND_SUFFIX = tostring(math.random(100000, 999999))  -- per-session salt
                                                            -- for instance names

------------------------------------------------------------------------------
-- 1. SERVICES
------------------------------------------------------------------------------
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
local VirtualUser       = game:GetService("VirtualUser")
local HttpService       = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")

------------------------------------------------------------------------------
-- 1b. CLEAN SLATE -- wipe any leftover GUIs / events / connections from a
--     previous load of this script. Match anchored at the START of the
--     ScreenGui name only, so unrelated GUIs that happen to contain
--     "JurassicBlocky" mid-name are left alone.
------------------------------------------------------------------------------
do
    if type(_G.JurassicBlocky_Shutdown) == "function" then
        pcall(_G.JurassicBlocky_Shutdown)
    end
    _G.JurassicBlocky_Shutdown = nil

    local roots: {Instance} = {}
    local g: any = _G
    if type(g.gethui) == "function" then
        local ok, h = pcall(g.gethui); if ok and h then table.insert(roots, h) end
    end
    pcall(function() table.insert(roots, CoreGui) end)
    local lp = Players.LocalPlayer
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        if pg then table.insert(roots, pg) end
    end

    local PURGE_PREFIXES = { "JurassicBlocky", "NameHub_JB" }
    local function killStale(root)
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("ScreenGui") then
                local n = d.Name or ""
                for _, prefix in ipairs(PURGE_PREFIXES) do
                    if n:sub(1, #prefix) == prefix then
                        pcall(function() d:Destroy() end)
                        break
                    end
                end
            end
        end
    end
    for _ = 1, 3 do
        for _, r in ipairs(roots) do pcall(killStale, r) end
    end
end

------------------------------------------------------------------------------
-- 2. CONFIGURATION
--    Jurassic Blocky is a much smaller game than DS with (as far as we know)
--    no aggressive anti-cheat. Defaults are tuned for "just work" rather than
--    "evade detection". Speed/jump caps are looser, TP is plain CFrame.
------------------------------------------------------------------------------
local CONFIG = {
    -- General
    DebugMode             = false,
    NotifyDuration        = 4,

    -- Player / Character
    DefaultWalkSpeed      = 16,
    DefaultJumpPower      = 50,
    BoostedWalkSpeed      = 80,
    BoostedJumpPower      = 100,
    FlySpeed              = 50,
    TweenTeleportSeconds  = 0.8,

    -- Auto-survival
    AutoEatThreshold      = 35,
    AutoDrinkThreshold    = 35,
    AutoSleepThreshold    = 25,
    AutoBreathThreshold   = 40,
    SurvivalLoopInterval  = 1.0,
    HungerDelay           = 0,
    ThirstDelay           = 0,
    StopInfHungerAt       = 100,
    RespawnDelay          = 0,
    AutofarmSpawnDelay    = 10,

    -- Auto farming
    AutoFarmRadius        = 1500,
    AutoFarmInterval      = 0.35,
    -- JB has no known speed-check kick. Defaults are still reasonable so the
    -- character doesn't visually warp absurdly fast (which gets you reported
    -- by other players). Crank these freely if your server doesn't kick.
    SafeFarmSpeed         = 250,
    SafeFarmSpeedMax      = 1000,
    SafeFarmHopCap        = 120,
    SafeFarmHopCapMax     = 300,
    SafeFarmInterHop      = 0.02,
    InstantFarmTP         = true,    -- JB default ON: plain CFrame TP works
    InstantTPMaxJump      = 80,      -- bigger hops fine without DS-style AC
    InstantTPInterJump    = 0.05,
    InstantTPSettleTime   = 0.15,
    InstantTPPostDelay    = 0.10,
    InstantTPBurstMode    = false,
    InstantTPBurstStuds   = 50,

    ------------------------------------------------------------------------
    -- TARGET LANDING OPTIONS
    ------------------------------------------------------------------------
    TargetLandingYOffset  = 4,
    TargetLandingXOffset  = 0,
    TargetLandingZOffset  = 0,
    TargetLandingJitter   = 0,
    TargetMinDistance     = 0,
    TargetTargetPriority  = "Closest",   -- Closest | Furthest | Largest | Random
    TargetSkipOccupied    = false,
    TargetOccupiedRadius  = 25,
    TargetMaxStuckHops    = 60,
    TargetPickupRetries   = 4,
    TargetPickupMethod    = "All",       -- All | ProximityPrompt | Touch | Click | Remote
    TargetPostCollectStep = 5,
    TargetHoverClearance  = 4,

    -- Game-specific defaults (Jurassic Blocky)
    FarmTarget            = "Berry",
    MinimumDay            = 0,

    -- Combat
    CombatOffsetX         = 0,
    CombatOffsetY         = -3,
    CombatRange           = 40,
    MaxTargetHP           = 0,
    MinTargetHP           = 0,
    DisengageAtHP         = 25,

    -- Visuals / Camera
    DefaultFOV            = 70,
    FreecamSpeed          = 10,
    LocalPlayerTransparency = 0,
    PlayerTransparency    = 0,

    -- Teleport
    TweenSpeed            = 40,
    TeleportLocations     = {} :: {[string]: Vector3},

    -- Server hop
    HopOnPlayerCount      = 0,

    -- Misc
    PriceLimit            = 100000,
    MissionClaimDelay     = 0,
    AdminKickOnDetection  = true,
    AntiAFKEnabled        = true,

    -- Webhook (BLANK by default - user must paste their own)
    WebhookLink           = "",
    DiscordWebhook        = "",
    WebhookIntervalMin    = 10,
    EmbedColor            = Color3.fromRGB(85, 200, 110),

    -- Remote / game-specific identifiers. JB names are guesses; the
    -- keyword-based discovery in Util.findRemoteByKeywords will find the
    -- real ones if these are wrong.
    Remotes = {
        Eat       = "Eat",
        Drink     = "Drink",
        Sleep     = "Sleep",
        Quest     = "ClaimQuest",
        Attack    = "Attack",
        Heal      = "Heal",
        Respawn   = "Respawn",
        SpawnDino = "Spawn",
        BuyDino   = "Buy",
        Pickup    = "Pickup",
    },

    -- GUI
    GUIName               = "JurassicBlocky",
    GUIToggleKey          = "RightControl",
    GUIAccentColor        = Color3.fromRGB(85, 200, 110),    -- jungle green
    GUIBackgroundColor    = Color3.fromRGB(22, 26, 24),
    ShowCustomCursor      = true,
    NotifySide            = "Right",

    -- Keybinds
    Keybinds = {
        InfHunger        = "Eight",
        InfThirst        = "Nine",
        InfOxygen        = "Zero",
        AddHunger        = "Four",
        AddThirst        = "B",
        EnableSpeed      = "Six",
        EnableJumppower  = "Seven",
        InfiniteJump     = "Y",
        Noclip           = "N",
        Fly              = "F",
        Teleport         = "L",
        ToggleAANP       = "V",
        Suicide          = "Delete",
    },
}

------------------------------------------------------------------------------
-- 3. STATE
------------------------------------------------------------------------------
local State = {
    -- Main / Farm
    AutoFarm              = false,
    AutoCollectAll        = false,
    AutoFindBerries       = false,
    ResourceESP           = false,

    -- Player / Survival
    AutoEat         = false,
    AutoDrink       = false,
    AutoSleep       = false,
    AutoBreath      = false,
    AutoQuest       = false,
    InfHunger       = false,
    InfThirst       = false,
    InfOxygen       = false,
    SafeFarmSpeed   = true,
    InstantFarmTP   = false,
    KickBypass      = false,
    StopEatInCombat = false,
    AutoRespawn     = false,

    -- Player / Movement
    SpeedBoost   = false,
    JumpBoost    = false,
    InfiniteJump = false,
    Noclip       = false,
    Fly          = false,
    AutoAttack   = false,
    AutoSpawn    = false,

    -- Player / Combat
    AutoHeal          = false,
    TargetPOV         = false,
    AutoAttackPlayers = false,
    AutoAttackNPCs    = false,

    -- Player / Keybinds
    EnableKeybinds        = false,
    EnableSpecialKeybinds = false,

    -- Visuals
    ESP                = false,
    SelfESP            = false,
    InfoText           = false,
    RemoveNameFromInfo = false,
    SpectatePlayer     = false,
    Freecam            = false,
    DisableLighting    = false,
    FullBright         = false,
    UnderwaterVision   = false,
    DisableVisualRain  = false,
    Disable3DRendering = false,
    DisableGameNotifs  = false,
    DisableScriptNotifs = false,
    NoclipCamera       = false,
    InfiniteZoom       = false,

    -- Misc
    AccurateGrowth  = false,
    FPSBoost        = false,
    KickOnAdmin     = true,
    MenuOnAdmin     = false,
    SpawnAfterAdmin = false,

    -- Missions
    AutoMission = false,

    -- Teleport
    HopOnFriendDetect = false,

    -- Webhook
    AnonymousMode = false,

    -- General
    StatMonitor = false,
    AntiAFK     = true,
}

------------------------------------------------------------------------------
-- 4. LIFECYCLE TRACKER + ALIVE FLAG
--    `Alive.value` is the single source of truth for "is the framework
--    still loaded?" Every long-running task.spawn loop checks it so unload
--    actually stops them instead of leaving orphan threads forever.
------------------------------------------------------------------------------
local LocalPlayer  = Players.LocalPlayer
local Character    : Model?
local Humanoid     : Humanoid?
local RootPart     : BasePart?

local Connections : {[string]: RBXScriptConnection} = {}
local Alive = { value = true }

local function trackConnection(name: string, conn: RBXScriptConnection)
    if Connections[name] then Connections[name]:Disconnect() end
    Connections[name] = conn
end

local function disconnectAll()
    for name, conn in pairs(Connections) do
        if conn.Connected then conn:Disconnect() end
        Connections[name] = nil
    end
end

------------------------------------------------------------------------------
-- 5. UTILITIES
------------------------------------------------------------------------------
local Util = {}

function Util.debug(...: any)
    if CONFIG.DebugMode then print("[JurassicBlocky]", ...) end
end

function Util.safe(fn: () -> (), label: string?)
    local ok, err = pcall(fn)
    if not ok then Util.debug("Error in", label or "anonymous", "->", err) end
end

local _Library: any = nil
function Util.setLibrary(lib: any) _Library = lib end

function Util.notify(title: string, text: string)
    if _Library and _Library.Notify then
        Util.safe(function()
            _Library:Notify({
                Title       = title,
                Description = text,
                Time        = CONFIG.NotifyDuration,
            })
        end, "libNotify")
        return
    end
    Util.safe(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title,
            Text     = text,
            Duration = CONFIG.NotifyDuration,
        })
    end, "notify")
end

function Util.waitForCharacter(): (Model, Humanoid, BasePart)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum  = char:WaitForChild("Humanoid", 10) :: Humanoid
    local root = char:WaitForChild("HumanoidRootPart", 10) :: BasePart
    return char, hum, root
end

function Util.distance(a: Vector3, b: Vector3): number
    return (a - b).Magnitude
end

function Util.tweenTo(targetCFrame: CFrame, seconds: number?)
    if not RootPart then return end
    local duration = seconds or CONFIG.TweenTeleportSeconds
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(RootPart, info, {CFrame = targetCFrame})
    tween:Play()
    -- Watchdog: never wait longer than 2x the tween duration.
    local done = false
    tween.Completed:Connect(function() done = true end)
    local started = os.clock()
    while not done and (os.clock() - started) < (duration * 2 + 0.5) do
        task.wait(0.05)
    end
end

-- Robust executor-function lookup. Different executors expose globals in
-- different places: script env (getfenv(0)), _G, shared, or via getgenv().
local function _findExecFn(name: string): (any?, string?)
    local ok1, env0 = pcall(function() return getfenv and getfenv(0) or _ENV end)
    if ok1 and type(env0) == "table" then
        local v = (env0 :: any)[name]
        if type(v) == "function" then return v, "getfenv(0)" end
    end
    local v2 = (_G :: any)[name]
    if type(v2) == "function" then return v2, "_G" end
    if type(shared) == "table" then
        local v3 = (shared :: any)[name]
        if type(v3) == "function" then return v3, "shared" end
    end
    local genvFn = ok1 and (env0 :: any).getgenv or (_G :: any).getgenv
    if type(genvFn) == "function" then
        local okg, env = pcall(genvFn)
        if okg and type(env) == "table" then
            local g = (env :: any)[name]
            if type(g) == "function" then return g, "getgenv()" end
        end
    end
    return nil, nil
end

-- Named-remote cache (key: remote name). `false` = known miss.
local _namedRemoteCache: {[string]: any} = {}
local function findRemoteByName(remoteName: string): Instance?
    local cached = _namedRemoteCache[remoteName]
    if cached == false then return nil end
    if cached and (cached :: Instance).Parent then return cached end
    local rem = ReplicatedStorage:FindFirstChild(remoteName, true)
    _namedRemoteCache[remoteName] = rem or false
    return rem
end

function Util.fireRemote(remoteName: string, ...)
    local remote = findRemoteByName(remoteName)
    if not remote then Util.debug("Remote not found:", remoteName); return end
    local args = table.pack(...)
    if remote:IsA("RemoteEvent") then
        Util.safe(function() remote:FireServer(table.unpack(args, 1, args.n)) end, "fire:"..remoteName)
    elseif remote:IsA("RemoteFunction") then
        Util.safe(function() remote:InvokeServer(table.unpack(args, 1, args.n)) end, "invoke:"..remoteName)
    end
end

-- Keyword-based remote discovery. Cached on first hit (and on first miss).
local _remoteCache: {[string]: any} = {}
local function findRemoteByKeywords(keywords: {string}): Instance?
    local key = table.concat(keywords, "|")
    local cached = _remoteCache[key]
    if cached == false then return nil end
    if cached and (cached :: Instance).Parent then return cached end
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            local lname = d.Name:lower()
            for _, kw in ipairs(keywords) do
                if lname:find(kw, 1, true) then
                    _remoteCache[key] = d
                    return d
                end
            end
        end
    end
    _remoteCache[key] = false
    return nil
end

local function fireRemoteOrInvoke(remote: Instance)
    if remote:IsA("RemoteEvent") then
        Util.safe(function() (remote :: RemoteEvent):FireServer() end, "fire:"..remote.Name)
    elseif remote:IsA("RemoteFunction") then
        Util.safe(function() (remote :: RemoteFunction):InvokeServer() end, "invoke:"..remote.Name)
    end
end

------------------------------------------------------------------------------
-- 6. CHARACTER LIFECYCLE
------------------------------------------------------------------------------
local function bindCharacter(char: Model)
    Character = char
    Humanoid  = char:WaitForChild("Humanoid", 10) :: Humanoid
    RootPart  = char:WaitForChild("HumanoidRootPart", 10) :: BasePart
    if Humanoid then
        Humanoid.WalkSpeed = State.SpeedBoost and CONFIG.BoostedWalkSpeed or CONFIG.DefaultWalkSpeed
        Humanoid.JumpPower = State.JumpBoost  and CONFIG.BoostedJumpPower  or CONFIG.DefaultJumpPower
    end
    Util.debug("Character bound:", char.Name)
end

if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end
trackConnection("CharacterAdded", LocalPlayer.CharacterAdded:Connect(bindCharacter))

------------------------------------------------------------------------------
-- 7. ANTI-AFK
------------------------------------------------------------------------------
trackConnection("AntiAFK", LocalPlayer.Idled:Connect(function()
    if not State.AntiAFK then return end
    Util.safe(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        Util.debug("Anti-AFK ping fired")
    end, "AntiAFK")
end))

------------------------------------------------------------------------------
-- 8. INFINITE JUMP
------------------------------------------------------------------------------
trackConnection("InfiniteJump", UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

------------------------------------------------------------------------------
-- 9. NOCLIP (cached BasePart list, rebuilt on character change)
------------------------------------------------------------------------------
local NoclipParts: {BasePart} = {}
local function rebuildNoclipParts()
    NoclipParts = {}
    if not Character then return end
    for _, p in ipairs(Character:GetDescendants()) do
        if p:IsA("BasePart") then table.insert(NoclipParts, p) end
    end
end

trackConnection("CharacterAddedNoclipRebuild",
    LocalPlayer.CharacterAdded:Connect(function(c)
        c:WaitForChild("HumanoidRootPart", 5)
        rebuildNoclipParts()
    end))
if Character then rebuildNoclipParts() end

trackConnection("Noclip", RunService.Stepped:Connect(function()
    if not State.Noclip then return end
    for _, part in ipairs(NoclipParts) do
        if part.Parent and part.CanCollide then part.CanCollide = false end
    end
end))

------------------------------------------------------------------------------
-- 10. AUTO SURVIVAL LOOP
--    Stat-name aliases tuned for JB. The lookup is keyword-based so if JB
--    uses slightly different names than guessed, the script auto-adapts.
------------------------------------------------------------------------------
local STAT_ALIASES = {
    Hunger = { "Hunger", "Food", "Fullness", "Satiety", "Belly", "Stomach" },
    Thirst = { "Thirst", "Water", "Hydration", "Drink" },
    Oxygen = { "Oxygen", "Breath", "Breathe", "Air", "AirSupply", "Lungs", "Lung", "OxygenLevel" },
    Breath = { "Breath", "Oxygen", "Air" },
    Energy = { "Energy", "Sleep", "Stamina", "Rest", "Fatigue", "Sleepiness" },
    Health = { "Health", "HP", "Life" },
    -- Currency-ish; used by Session stats
    Coins  = { "Coins", "Cash", "Gold", "Money", "Credits", "Currency" },
    XP     = { "XP", "Experience", "EXP" },
    Level  = { "Level", "Lvl", "Lv" },
}

local function statContainers(): {Instance}
    local out: {Instance} = { LocalPlayer }
    for _, n in ipairs({"PlayerStats","Stats","Data","leaderstats","Status","Vitals","PlayerData","Survival"}) do
        local f = LocalPlayer:FindFirstChild(n)
        if f then table.insert(out, f) end
    end
    if Character then
        table.insert(out, Character)
        for _, n in ipairs({"Stats","PlayerStats","Status","Vitals"}) do
            local f = Character:FindFirstChild(n)
            if f then table.insert(out, f) end
        end
    end
    return out
end

local _statCache: {[string]: any} = {}

local function _findStatUncached(statName: string): (NumberValue | IntValue)?
    local aliases = STAT_ALIASES[statName] or { statName }
    for _, container in ipairs(statContainers()) do
        for _, alias in ipairs(aliases) do
            local v = container:FindFirstChild(alias)
            if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then return v :: any end
        end
    end
    local function scan(root: Instance, depth: number): (NumberValue | IntValue)?
        if depth > 4 then return nil end
        for _, child in ipairs(root:GetChildren()) do
            for _, alias in ipairs(aliases) do
                if child.Name == alias and (child:IsA("NumberValue") or child:IsA("IntValue")) then
                    return child :: any
                end
            end
            if not child:IsA("BasePart") and not child:IsA("Script") and not child:IsA("LocalScript") then
                local hit = scan(child, depth + 1); if hit then return hit end
            end
        end
        return nil
    end
    local hit = scan(LocalPlayer, 0); if hit then return hit end
    if Character then return scan(Character, 0) end
    return nil
end

local function findStat(statName: string): (NumberValue | IntValue)?
    local cached = _statCache[statName]
    if cached and cached.Parent then return cached end
    local v = _findStatUncached(statName)
    _statCache[statName] = v
    return v
end

trackConnection("CharacterAddedStatCacheReset",
    LocalPlayer.CharacterAdded:Connect(function() _statCache = {} end))

local function listAllStats(): {{name: string, value: number, path: string}}
    local out = {}
    local function visit(root: Instance, prefix: string, depth: number)
        if depth > 5 then return end
        for _, child in ipairs(root:GetChildren()) do
            local p = prefix .. "." .. child.Name
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                table.insert(out, {name = child.Name, value = child.Value, path = p})
            elseif not child:IsA("BasePart") and not child:IsA("Script") and not child:IsA("LocalScript") then
                visit(child, p, depth + 1)
            end
        end
    end
    visit(LocalPlayer, "Players.LocalPlayer", 0)
    if Character then visit(Character, "workspace." .. Character.Name, 0) end
    return out
end

local function listAllRemotes(): {{name: string, class: string, path: string}}
    local out = {}
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            table.insert(out, {name = d.Name, class = d.ClassName, path = d:GetFullName()})
        end
    end
    return out
end

local function getStat(name: string): number?
    local v = findStat(name); return v and v.Value or nil
end

local function inCombat(): boolean
    if Humanoid and Humanoid.Health < Humanoid.MaxHealth * 0.9 then return true end
    return false
end

-- Burst-fire refill for Inf Hunger / Inf Thirst.
local _burstActive = { Hunger = false, Thirst = false }
local _BURST_INTERVAL = 0.05
local _BURST_MAX      = 200

local function startBurstRefill(statKey: string, remoteName: string, keywords: {string})
    if _burstActive[statKey] then return end
    _burstActive[statKey] = true
    task.spawn(function()
        local fires = 0
        local startedAt = os.clock()
        while fires < _BURST_MAX and Alive.value do
            local stateOn = (statKey == "Hunger" and State.InfHunger)
                         or (statKey == "Thirst" and State.InfThirst)
            if not stateOn then break end
            if not (Character and Humanoid and Humanoid.Health > 0) then break end
            local v = findStat(statKey)
            local cap = CONFIG.StopInfHungerAt > 0 and CONFIG.StopInfHungerAt or 100
            if not v then break end
            if v.Value >= cap - 1 then break end
            Util.fireRemote(remoteName)
            local r = findRemoteByKeywords(keywords)
            if r then fireRemoteOrInvoke(r) end
            fires += 1
            task.wait(_BURST_INTERVAL)
        end
        Util.debug(("[InfStat] %s burst ended after %d fires in %.2fs"):format(statKey, fires, os.clock() - startedAt))
        _burstActive[statKey] = false
    end)
end

-- Inf Oxygen: cheap remote ping + client clamp + emergency surface-lift.
local _lastO2Lift     = 0
local _O2_LIFT_COOL   = 1.0
local _O2_LIFT_STUDS  = 60
local _O2_THRESHOLD   = 30
local _o2RemoteCache: any = nil

local function tryRefillOxygen(cap: number)
    local v = findStat("Oxygen")
    if not v then return end
    if _o2RemoteCache == nil then
        _o2RemoteCache = findRemoteByKeywords({"breath","oxygen","air","surface","lung"}) or false
    end
    if _o2RemoteCache and (_o2RemoteCache :: Instance).Parent then
        fireRemoteOrInvoke(_o2RemoteCache :: Instance)
    end
    local target = math.max(cap, v.Value)
    if v.Value < target then v.Value = target end
    if v.Value >= _O2_THRESHOLD then return end
    if tick() - _lastO2Lift < _O2_LIFT_COOL then return end
    if not RootPart then return end
    _lastO2Lift = tick()
    pcall(function()
        RootPart.CFrame = RootPart.CFrame + Vector3.new(0, _O2_LIFT_STUDS, 0)
        if RootPart.AssemblyLinearVelocity then
            local vel = RootPart.AssemblyLinearVelocity
            RootPart.AssemblyLinearVelocity = Vector3.new(vel.X, math.max(vel.Y, 0), vel.Z)
        end
    end)
end

-- High-frequency burst trigger loop.
task.spawn(function()
    while Alive.value and task.wait(0.25) do
        if not (Character and Humanoid and Humanoid.Health > 0) then continue end
        local cap = CONFIG.StopInfHungerAt > 0 and CONFIG.StopInfHungerAt or 100
        local combat = inCombat()
        if State.InfHunger and not (State.StopEatInCombat and combat) then
            local v = findStat("Hunger")
            if v and v.Value < cap - 1 and not _burstActive.Hunger then
                startBurstRefill("Hunger", CONFIG.Remotes.Eat, {"eat","feed","hunger","food","consume"})
            end
        end
        if State.InfThirst then
            local v = findStat("Thirst")
            if v and v.Value < cap - 1 and not _burstActive.Thirst then
                startBurstRefill("Thirst", CONFIG.Remotes.Drink, {"drink","thirst","hydrate","water"})
            end
        end
        if State.InfOxygen then tryRefillOxygen(cap) end
    end
end)

-- Threshold-driven auto-eat / drink / sleep / breath / heal.
task.spawn(function()
    while Alive.value and task.wait(CONFIG.SurvivalLoopInterval) do
        if not (Character and Humanoid and Humanoid.Health > 0) then continue end
        local combat = inCombat()
        if State.AutoEat then
            local hunger = getStat("Hunger")
            if hunger and hunger <= CONFIG.AutoEatThreshold and not (State.StopEatInCombat and combat) then
                if CONFIG.HungerDelay > 0 then task.wait(CONFIG.HungerDelay) end
                local r = findRemoteByKeywords({"eat","feed","hunger","food","consume"})
                if r then fireRemoteOrInvoke(r) end
            end
        end
        if State.AutoDrink then
            local thirst = getStat("Thirst")
            if thirst and thirst <= CONFIG.AutoDrinkThreshold then
                if CONFIG.ThirstDelay > 0 then task.wait(CONFIG.ThirstDelay) end
                local r = findRemoteByKeywords({"drink","thirst","hydrate","water"})
                if r then fireRemoteOrInvoke(r) end
            end
        end
        if State.AutoSleep then
            local energy = getStat("Energy")
            if energy and energy <= CONFIG.AutoSleepThreshold then
                local r = findRemoteByKeywords({"sleep","rest","energy","nap"})
                if r then fireRemoteOrInvoke(r) end
            end
        end
        if State.AutoBreath then
            local breath = getStat("Breath")
            if breath and breath <= CONFIG.AutoBreathThreshold and RootPart then
                RootPart.CFrame = RootPart.CFrame + Vector3.new(0, 30, 0)
            end
        end
        if State.AutoHeal and Humanoid.Health <= CONFIG.DisengageAtHP then
            local r = findRemoteByKeywords({"heal","health","regen","cure"})
            if r then fireRemoteOrInvoke(r) end
        end
    end
end)

------------------------------------------------------------------------------
-- 10b. AUTO RESPAWN
------------------------------------------------------------------------------
task.spawn(function()
    while Alive.value and task.wait(0.5) do
        if not State.AutoRespawn then continue end
        if Humanoid and Humanoid.Health <= 0 then
            if CONFIG.RespawnDelay > 0 then task.wait(CONFIG.RespawnDelay) end
            Util.fireRemote(CONFIG.Remotes.Respawn)
            local r = findRemoteByKeywords({"respawn","reload","revive","spawn"})
            if r then fireRemoteOrInvoke(r) end
        end
    end
end)

------------------------------------------------------------------------------
-- 10c. AUTO ATTACK (players / NPCs)
------------------------------------------------------------------------------
local function isValidCombatTarget(model: Model): boolean
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if CONFIG.MaxTargetHP > 0 and hum.MaxHealth > CONFIG.MaxTargetHP then return false end
    if hum.Health < CONFIG.MinTargetHP then return false end
    return true
end

task.spawn(function()
    while Alive.value and task.wait(0.25) do
        if not (State.AutoAttack or State.AutoAttackPlayers or State.AutoAttackNPCs) then continue end
        if not (Character and RootPart and Humanoid and Humanoid.Health > 0) then continue end
        local best, bestDist = nil :: Model?, math.huge
        local scanRoots: {Model} = {}
        if State.AutoAttackPlayers then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then table.insert(scanRoots, p.Character) end
            end
        end
        if State.AutoAttackNPCs then
            for _, m in ipairs(Workspace:GetChildren()) do
                if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(m) then
                    table.insert(scanRoots, m)
                end
            end
        end
        for _, m in ipairs(scanRoots) do
            local r = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            if r and r:IsA("BasePart") and isValidCombatTarget(m) then
                local d = (r.Position - RootPart.Position).Magnitude
                if d <= CONFIG.CombatRange and d < bestDist then best, bestDist = m, d end
            end
        end
        if best then
            Util.fireRemote(CONFIG.Remotes.Attack, best)
            local r = findRemoteByKeywords({"attack","damage","bite","strike","hit"})
            if r then
                if r:IsA("RemoteEvent") then Util.safe(function() r:FireServer(best) end, "attack")
                elseif r:IsA("RemoteFunction") then Util.safe(function() r:InvokeServer(best) end, "attack") end
            end
            if State.TargetPOV and Workspace.CurrentCamera then
                Workspace.CurrentCamera.CameraSubject = best:FindFirstChildOfClass("Humanoid")
            end
        end
    end
end)

------------------------------------------------------------------------------
-- 11. AUTO FARM (Jurassic Blocky--aware target keyword list)
--     The keyword list is the single most game-specific knob. Once you run
--     "Dump Workspace Names" in-game, replace these with the real ones.
------------------------------------------------------------------------------
local FARM_TARGETS: {[string]: {string}} = {
    -- Food
    Berry        = { "berry","berries","fruit","fruits","plant","bush" },
    Meat         = { "meat","steak","flesh","carcass","drumstick" },
    Fish         = { "fish","tuna","salmon","cod","trout","catfish","fishing" },
    -- Crafting / building
    Wood         = { "wood","log","logs","branch","stick","twig","plank","timber" },
    Stone        = { "stone","rock","cobble","boulder","pebble" },
    -- Collectibles
    Fossil       = { "fossil","bone","skeleton","skull","tooth" },
    Egg          = { "egg","eggs","nest","clutch" },
    -- Liquids / drinkable
    Water        = { "water","pond","river","stream","puddle","spring" },
    -- Mining / rare
    Iron         = { "iron","ironore","ore","metal","copper","tin" },
    Gold         = { "gold","goldore","nugget" },
    Diamond      = { "diamond","gem","crystal","ruby","sapphire","emerald" },
    -- Plants / saplings
    Sapling      = { "sapling","seedling","seed","seeds" },
    Mushroom     = { "mushroom","fungus","shroom","cap" },
    -- Generic loot bags / drops
    Loot         = { "loot","bag","drop","pickup","crate","chest" },
}

-- Cached Workspace descendants snapshot (refresh every 0.5s).
local _wsCache: {Instance} = {}
local _wsCacheTime = 0
local function workspaceSnapshot(): {Instance}
    if tick() - _wsCacheTime > 0.5 then
        _wsCache = Workspace:GetDescendants()
        _wsCacheTime = tick()
    end
    return _wsCache
end

local UnreachableTargets: {[BasePart]: number} = {}
local function isUnreachable(part: BasePart): boolean
    local expiry = UnreachableTargets[part]
    if not expiry then return false end
    if tick() >= expiry then UnreachableTargets[part] = nil; return false end
    return true
end

local function findFarmTargets(typeName: string): {BasePart}
    local results: {BasePart} = {}
    local seenOwner: {[Instance]: true} = {}
    local keywords = FARM_TARGETS[typeName]
    if not keywords then keywords = { typeName:lower() } end
    local function pickPart(model: Model): BasePart?
        return model.PrimaryPart
            or model:FindFirstChild("HumanoidRootPart") :: BasePart?
            or model:FindFirstChildWhichIsA("BasePart")
    end
    local function matches(name: string): boolean
        local lower = name:lower()
        for _, kw in ipairs(keywords) do
            if lower:find(kw, 1, true) then return true end
        end
        return false
    end
    for _, inst in ipairs(workspaceSnapshot()) do
        if matches(inst.Name) then
            if inst:IsA("BasePart") then
                local owner: Instance = inst.Parent or inst
                if owner:IsA("Model") then
                    if not seenOwner[owner] then
                        seenOwner[owner] = true
                        table.insert(results, inst)
                    end
                else
                    table.insert(results, inst)
                end
            elseif inst:IsA("Model") then
                if not seenOwner[inst] then
                    seenOwner[inst] = true
                    local p = pickPart(inst)
                    if p then table.insert(results, p) end
                end
            end
        end
    end
    return results
end

local Options : any = nil   -- populated after UI builds
local function getSelectedFarmTargets(): {string}
    local picked: {string} = {}
    local seen: {[string]: boolean} = {}
    local function add(name: string)
        if not name or name == "" or seen[name] then return end
        seen[name] = true; table.insert(picked, name)
    end
    local sel = (Options and Options.FarmTargets and Options.FarmTargets.Value) or CONFIG.FarmTarget
    if type(sel) == "string" then add(sel) end
    if Options and Options.FarmPriority and type(Options.FarmPriority.Value) == "table" then
        for k, v in pairs(Options.FarmPriority.Value) do
            if v and type(k) == "string" then add(k) end
        end
    end
    return picked
end

local _collectRemoteCache: any = nil
local function getCollectRemote(): Instance?
    if _collectRemoteCache and (_collectRemoteCache :: Instance).Parent then return _collectRemoteCache end
    _collectRemoteCache = findRemoteByKeywords({"collect","pickup","claim","harvest","gather","interact","grab"})
    return _collectRemoteCache
end

local function ownerOf(part: BasePart): Instance
    local cur: Instance = part
    while cur and not cur:IsA("Model") and cur.Parent and cur.Parent ~= Workspace do
        cur = cur.Parent
    end
    return cur or part
end

local function topSnapPosition(target: BasePart, owner: Instance): Vector3
    local clearance = math.max(CONFIG.TargetHoverClearance or 4, 1)
    if owner:IsA("Model") then
        local ok, cf, size = pcall(function() return (owner :: Model):GetBoundingBox() end)
        if ok and cf and size then
            local center = cf.Position
            local topY = center.Y + size.Y * 0.5
            return Vector3.new(center.X, topY + clearance, center.Z)
        end
    end
    return target.Position + Vector3.new(0, target.Size.Y * 0.5 + clearance, 0)
end

-- Cache executor pickup primitives once.
local _fireProx: ((p: ProximityPrompt) -> ())? = nil
local _fireTouch: any = nil
local _fireClick: any = nil
do
    local g: any = _G
    local function pick(...)
        for _, n in ipairs({...}) do
            local v = g[n]; if type(v) == "function" then return v end
            local syn = g.Synapse
            if type(syn) == "table" and type(syn[n]) == "function" then return syn[n] end
        end
        return nil
    end
    _fireProx  = pick("fireproximityprompt","fireProximityPrompt")
    _fireTouch = pick("firetouchinterest","fireTouchInterest")
    _fireClick = pick("fireclickdetector","fireClickDetector")
end

if _fireProx then print("[JurassicBlocky] fireproximityprompt available") end

local function fireAllPickups(target: BasePart)
    local owner = ownerOf(target)
    local root = Character and (Character:FindFirstChild("HumanoidRootPart") :: BasePart?) or nil
    local method = CONFIG.TargetPickupMethod or "All"
    local usePrompt = (method == "All" or method == "ProximityPrompt")
    local useTouch  = (method == "All" or method == "Touch")
    local useClick  = (method == "All" or method == "Click")
    local useRemote = (method == "All" or method == "Remote")

    -- One-shot diagnostic per target name (bounded - won't grow forever
    -- because we only ever store the names we've seen, which is a fixed
    -- set in any given server).
    if not _G.JBPickupDiag then _G.JBPickupDiag = {} end
    if not _G.JBPickupDiag[target.Name] then
        _G.JBPickupDiag[target.Name] = true
        local descs = owner:GetDescendants()
        local nPrompts, nClick, nParts, nTools = 0, 0, 0, 0
        for _, d in ipairs(descs) do
            if d:IsA("ProximityPrompt") then nPrompts += 1 end
            if d:IsA("ClickDetector") then nClick += 1 end
            if d:IsA("BasePart") then nParts += 1 end
            if d:IsA("Tool") then nTools += 1 end
        end
        local dist = root and (root.Position - target.Position).Magnitude or -1
        print(("[PickupDiag] %s: prompts=%d, clickdetectors=%d, parts=%d, tools=%d, dist=%.1f"):format(
            target.Name, nPrompts, nClick, nParts, nTools, dist))
    end

    if usePrompt then
        for _, d in ipairs(owner:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled then
                if _fireProx then
                    Util.safe(function() _fireProx(d) end, "fireProx")
                else
                    Util.safe(function()
                        local prev = d.HoldDuration
                        d.HoldDuration = 0
                        d:InputHoldBegin(); task.wait(0.05); d:InputHoldEnd()
                        d.HoldDuration = prev
                    end, "prompt")
                end
            end
        end
    end
    if useTouch and _fireTouch and root then
        for _, d in ipairs(owner:IsA("Model") and owner:GetDescendants() or {target}) do
            if d:IsA("BasePart") then
                Util.safe(function() _fireTouch(root, d, 0); task.wait(); _fireTouch(root, d, 1) end, "touch")
            end
        end
    end
    if useClick and _fireClick then
        for _, d in ipairs(owner:GetDescendants()) do
            if d:IsA("ClickDetector") then
                Util.safe(function() _fireClick(d, 0); _fireClick(d) end, "click")
            end
        end
    end
    if useRemote then
        local remote = getCollectRemote()
        if remote then
            Util.safe(function()
                if remote:IsA("RemoteEvent") then remote:FireServer(target, owner)
                elseif remote:IsA("RemoteFunction") then remote:InvokeServer(target, owner) end
            end, "collectRemote")
        end
    end
end

-- Plain chunked CFrame TP. JB has no known teleport-check so we can use
-- larger hops, but small chunks still help with collision/snap behavior.
local function instantTeleportToTarget(target: BasePart, owner: Instance): boolean
    if not RootPart then return false end
    local destPos: Vector3 = target.Position
    destPos = destPos + Vector3.new(
        CONFIG.TargetLandingXOffset,
        CONFIG.TargetLandingYOffset,
        CONFIG.TargetLandingZOffset)
    if CONFIG.TargetLandingJitter > 0 then
        local j = CONFIG.TargetLandingJitter
        destPos = destPos + Vector3.new(
            (math.random() - 0.5) * 2 * j, 0,
            (math.random() - 0.5) * 2 * j)
    end
    local burst   = CONFIG.InstantTPBurstMode
    local maxJump = burst and math.max(CONFIG.InstantTPBurstStuds, 5)
                          or math.max(CONFIG.InstantTPMaxJump, 5)
    local pause   = math.max(CONFIG.InstantTPInterJump, 0)
    local hops = 0
    local startDist = (destPos - RootPart.Position).Magnitude
    local stuckCheckDist = startDist
    local stuckCheckHops = 0
    local maxStuckHops = math.max(CONFIG.TargetMaxStuckHops, 10)

    while RootPart and Alive.value do
        if not State.AutoFarm then return false end
        local from = RootPart.Position
        local dist = (destPos - from).Magnitude
        if dist < maxJump then
            Util.safe(function() RootPart.CFrame = CFrame.new(destPos) end, "finalHop")
            return true
        end
        local step = from + (destPos - from).Unit * maxJump
        Util.safe(function() RootPart.CFrame = CFrame.new(step) end, "hop")
        hops += 1
        if hops % 5 == 0 then
            local expectedProgress = maxJump * 5 * 0.3
            if (stuckCheckDist - dist) < expectedProgress then
                stuckCheckHops += 1
                if stuckCheckHops >= 3 then
                    Util.debug("[InstantTP] STUCK - bailing")
                    return false
                end
            else stuckCheckHops = 0 end
            stuckCheckDist = dist
        end
        if hops >= maxStuckHops then
            Util.debug("[InstantTP] hop cap hit")
            return false
        end
        if burst then RunService.Heartbeat:Wait()
        elseif pause > 0 then task.wait(pause) end
    end
    return false
end

local function instantCollect(target: BasePart, maxAttempts: number?): boolean
    local owner = ownerOf(target)
    local attempts = maxAttempts or CONFIG.TargetPickupRetries or 3
    for i = 1, attempts do
        if not target.Parent or not owner.Parent then return true end
        if not State.AutoFarm then return false end
        instantTeleportToTarget(target, owner)
        if RootPart and target.Parent then
            local snap = topSnapPosition(target, owner)
            Util.safe(function() RootPart.CFrame = CFrame.new(snap) end, "snap1")
        end
        task.wait(CONFIG.InstantTPSettleTime)
        fireAllPickups(target)
        task.wait(0.08)
        if not target.Parent or not owner.Parent then return true end
        if RootPart and target.Parent then
            local snap = topSnapPosition(target, owner)
            Util.safe(function() RootPart.CFrame = CFrame.new(snap) end, "snap2")
        end
        fireAllPickups(target)
        task.wait(0.05)
        if not target.Parent or not owner.Parent then return true end
    end
    if RootPart and CONFIG.TargetPostCollectStep > 0 then
        local backDir = (RootPart.Position - target.Position)
        if backDir.Magnitude > 0.1 then
            local backStep = RootPart.Position + backDir.Unit * CONFIG.TargetPostCollectStep
            Util.safe(function() RootPart.CFrame = CFrame.new(backStep) end, "postCollectStep")
        end
    end
    return false
end

local function tryCollect(target: BasePart, maxAttempts: number?): boolean
    local owner = ownerOf(target)
    local attempts = maxAttempts or 6
    for i = 1, attempts do
        if not target.Parent or not owner.Parent then return true end
        fireAllPickups(target)
        if RootPart then
            local wiggle = Vector3.new(((i % 2) == 0 and 1 or -1) * 2, 0, ((i % 2) == 0 and -1 or 1) * 2)
            Util.safe(function() Util.tweenTo(RootPart.CFrame + wiggle, 0.08) end, "wiggle")
        end
        task.wait(0.12)
        if not target.Parent or not owner.Parent then return true end
    end
    return false
end

local function safeWalkTo(goal: CFrame)
    if not RootPart then return end
    local speed  = math.clamp(CONFIG.SafeFarmSpeed,  20, CONFIG.SafeFarmSpeedMax)
    local hopCap = math.clamp(CONFIG.SafeFarmHopCap, 10, CONFIG.SafeFarmHopCapMax)
    local pause  = math.max(CONFIG.SafeFarmInterHop, 0)
    if not State.SafeFarmSpeed then
        local dist = (RootPart.Position - goal.Position).Magnitude
        Util.tweenTo(goal, math.clamp(dist / 300, 0.2, 1.5))
        return
    end
    while RootPart and Alive.value do
        if not State.AutoFarm then return end
        local from = RootPart.Position
        local to   = goal.Position
        local d    = (to - from).Magnitude
        if d < 4 then return end
        if d <= hopCap then
            Util.tweenTo(goal, d / speed); return
        end
        local step = from + (to - from).Unit * hopCap
        Util.tweenTo(CFrame.new(step), hopCap / speed)
        if pause > 0 then task.wait(pause) end
    end
end

local _lastFarmLog = 0
local function farmDebug(msg: string)
    if not CONFIG.DebugMode then return end
    if tick() - _lastFarmLog < 1.5 then return end
    _lastFarmLog = tick()
    Util.debug("[Autofarm] " .. msg)
end

_G.JBAutoFarmHeartbeat = _G.JBAutoFarmHeartbeat or 0

task.spawn(function()
    while Alive.value and task.wait(CONFIG.AutoFarmInterval) do
        _G.JBAutoFarmHeartbeat = (_G.JBAutoFarmHeartbeat or 0) + 1
        if _G.JBAutoFarmHeartbeat % 60 == 0 then
            Util.debug(("[AutoFarm] heartbeat %d, AutoFarm=%s, InstantTP=%s"):format(
                _G.JBAutoFarmHeartbeat, tostring(State.AutoFarm), tostring(State.InstantFarmTP)))
        end
        local ok, err = pcall(function()
            if not State.AutoFarm then return end
            if not (Character and RootPart) then return end
            local targetTypes = getSelectedFarmTargets()
            if #targetTypes == 0 then farmDebug("no target selected"); return end

            local otherPlayers: {BasePart} = {}
            if CONFIG.TargetSkipOccupied then
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp:IsA("BasePart") then table.insert(otherPlayers, hrp) end
                    end
                end
            end
            local function isOccupied(p: BasePart): boolean
                if #otherPlayers == 0 then return false end
                local r = CONFIG.TargetOccupiedRadius
                for _, hrp in ipairs(otherPlayers) do
                    if (hrp.Position - p.Position).Magnitude <= r then return true end
                end
                return false
            end

            local candidates: {{part: BasePart, dist: number, vol: number}} = {}
            local totalFound, skippedUnreach, skippedClose, skippedOcc = 0, 0, 0, 0
            for _, t in ipairs(targetTypes) do
                local parts = findFarmTargets(t)
                for _, p in ipairs(parts) do
                    totalFound += 1
                    if isUnreachable(p) then skippedUnreach += 1; continue end
                    local d = (p.Position - RootPart.Position).Magnitude
                    if d < CONFIG.TargetMinDistance then skippedClose += 1; continue end
                    if d > CONFIG.AutoFarmRadius then continue end
                    if CONFIG.TargetSkipOccupied and isOccupied(p) then skippedOcc += 1; continue end
                    local vol = p.Size.X * p.Size.Y * p.Size.Z
                    table.insert(candidates, { part = p, dist = d, vol = vol })
                end
            end

            local best: BasePart? = nil
            local bestDist = math.huge
            if #candidates > 0 then
                local mode = CONFIG.TargetTargetPriority
                if mode == "Furthest" then
                    table.sort(candidates, function(a, b) return a.dist > b.dist end)
                    best = candidates[1].part; bestDist = candidates[1].dist
                elseif mode == "Largest" then
                    table.sort(candidates, function(a, b) return a.vol > b.vol end)
                    best = candidates[1].part; bestDist = candidates[1].dist
                elseif mode == "Random" then
                    local pick = candidates[math.random(1, #candidates)]
                    best = pick.part; bestDist = pick.dist
                else
                    table.sort(candidates, function(a, b) return a.dist < b.dist end)
                    best = candidates[1].part; bestDist = candidates[1].dist
                end
            end

            if totalFound == 0 then
                if tick() - (_G.JBAutoFarmNoTargetLog or 0) > 4 then
                    _G.JBAutoFarmNoTargetLog = tick()
                    print(("[AutoFarm] 0 in workspace for: %s"):format(table.concat(targetTypes, ", ")))
                end
                return
            end
            if not best then
                if tick() - (_G.JBAutoFarmAllFilteredLog or 0) > 4 then
                    _G.JBAutoFarmAllFilteredLog = tick()
                    print(("[AutoFarm] %d found, all filtered (range=%d). Raise Farm Range or move closer."):format(
                        totalFound, CONFIG.AutoFarmRadius))
                end
                return
            end

            local owner = ownerOf(best)
            if State.InstantFarmTP then
                farmDebug(("INSTANT TP %d studs"):format(math.floor(bestDist)))
                local got = instantCollect(best, CONFIG.TargetPickupRetries or 3)
                if not got then UnreachableTargets[best] = tick() + 6 end
                task.wait(CONFIG.InstantTPPostDelay)
            else
                farmDebug(("walking %d studs"):format(math.floor(bestDist)))
                local landCF = CFrame.new(topSnapPosition(best, owner))
                safeWalkTo(landCF)
                if best.Parent and owner.Parent then
                    local got = tryCollect(best, 6)
                    if not got then UnreachableTargets[best] = tick() + 10 end
                end
                task.wait(0.1)
            end
        end)
        if not ok then
            _G.JBAutoFarmLastError = tostring(err)
            warn("[JurassicBlocky] [AutoFarm] loop error: " .. tostring(err))
        end
    end
end)

------------------------------------------------------------------------------
-- 12. AUTO QUEST
------------------------------------------------------------------------------
task.spawn(function()
    while Alive.value and task.wait(5) do
        if not State.AutoQuest then continue end
        Util.fireRemote(CONFIG.Remotes.Quest)
        local r = findRemoteByKeywords({"quest","mission","claim","reward","complete"})
        if r then fireRemoteOrInvoke(r) end
    end
end)

------------------------------------------------------------------------------
-- 13. ESP (Instance-based, executor-agnostic)
------------------------------------------------------------------------------
local function isCreatureModel(inst: Instance): boolean
    if not inst:IsA("Model") then return false end
    local hum = inst:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return inst.PrimaryPart ~= nil
        or inst:FindFirstChild("HumanoidRootPart") ~= nil
        or inst:FindFirstChildWhichIsA("BasePart") ~= nil
end

local SCAN_MAX_DEPTH = 6
local function collectCreatureModels(): {[Model]: true}
    local found: {[Model]: true} = {}
    local function walk(parent: Instance, depth: number)
        if depth > SCAN_MAX_DEPTH then return end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("Model") then
                if isCreatureModel(child) then found[child :: Model] = true end
            elseif child:IsA("Folder") or child:IsA("Configuration") or child == Workspace then
                walk(child, depth + 1)
            end
        end
    end
    walk(Workspace, 0)
    for _, p in ipairs(Players:GetPlayers()) do
        local c = p.Character
        if c and isCreatureModel(c) then found[c] = true end
    end
    return found
end

local ESP = {
    Active = false, Entries = {} :: {[Model]: any},
    LastScan = 0, ScanInterval = 0.75, LastScanCount = 0,
    TracerGui = nil :: ScreenGui?,
    Settings = {
        Enabled = false, ShowSelf = false, ShowPlayers = true, ShowNPCs = true,
        ShowOwner = true, ShowTeam = true, TeamCheck = false, MaxDistance = 2000,
        Boxes = true, BoxType = "2D", BoxThickness = 1,
        Tracers = false, TracerOrigin = "Bottom", TracerThickness = 1,
        TracerStyle = "Solid", TracerTransparency = 0,
        TracerDistanceFade = false, TracerRainbow = false, TracerRainbowSpeed = 0.5,
        TracerOffscreenOnly = false, TracerOnPlayers = true, TracerOnNPCs = true,
        TracerEndDot = false, TracerOriginDot = false, TracerToHead = false,
        TracerTeamColor = false, TracerHealthColor = false,
        Names = true, Distance = true, HealthText = true, HealthBar = true, HeadDot = false,
        Chams = false, ChamsMode = "Standard", ChamsDepth = "AlwaysOnTop",
        ChamsDualColor = false, ChamsOnPlayers = true, ChamsOnNPCs = true,
        ChamsTeamColor = false, ChamsDistanceFade = false,
        ChamsPulseSpeed = 2, ChamsRainbowSpeed = 0.5,
        TextSize = 14, HeadDotRadius = 4,
        Colors = {
            Box = Color3.fromRGB(255, 255, 255), BoxOutline = Color3.fromRGB(0, 0, 0),
            Tracer = Color3.fromRGB(255, 255, 255), Name = Color3.fromRGB(255, 255, 255),
            Distance = Color3.fromRGB(200, 200, 200),
            HealthHi = Color3.fromRGB(0, 255, 0), HealthLo = Color3.fromRGB(255, 0, 0),
            HeadDot = Color3.fromRGB(255, 255, 255),
            ChamsFill = Color3.fromRGB(85, 200, 110), ChamsOutline = Color3.fromRGB(255, 255, 255),
            ChamsVisible = Color3.fromRGB(0, 255, 0), ChamsOccluded = Color3.fromRGB(255, 60, 60),
            ChamsPlayer = Color3.fromRGB(0, 170, 255), ChamsNPC = Color3.fromRGB(255, 170, 0),
            Player = Color3.fromRGB(0, 170, 255), NPC = Color3.fromRGB(255, 170, 0),
            Friendly = Color3.fromRGB(0, 255, 100), Enemy = Color3.fromRGB(255, 70, 70),
        },
        BoxFillTransparency = 0.5, ChamsFillTransparency = 0.5, ChamsOutlineTransparency = 0,
    },
}

local function modelInLOS(model: Model, cam: Camera): boolean
    local target = model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildWhichIsA("BasePart")
    if not target or not target:IsA("BasePart") then return false end
    local origin = cam.CFrame.Position
    local dir = target.Position - origin
    if dir.Magnitude < 1 then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { model, Character or LocalPlayer.Character or model }
    params.IgnoreWater = true
    return Workspace:Raycast(origin, dir, params) == nil
end

local function getAnchorPart(model: Model): BasePart?
    local p = model:FindFirstChild("Head")
        or model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChildWhichIsA("BasePart")
    if p and p:IsA("BasePart") then return p end
    return nil
end

local function ensureTracerGui(): ScreenGui
    if ESP.TracerGui and ESP.TracerGui.Parent then return ESP.TracerGui end
    local gui = Instance.new("ScreenGui")
    gui.Name = "JurassicBlocky_Tracers_" .. _RAND_SUFFIX
    gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local g: any = _G
    local parented = false
    if type(g.gethui) == "function" then
        local ok, h = pcall(g.gethui); if ok and h then gui.Parent = h; parented = true end
    end
    if not parented then
        local ok, c = pcall(function() return CoreGui end)
        if ok and c then gui.Parent = c; parented = true end
    end
    if not parented then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    ESP.TracerGui = gui
    return gui
end

local function createEntry(model: Model): any
    local e: any = {}
    local anchor = getAnchorPart(model)
    if not anchor then return e end

    local bb = Instance.new("BillboardGui")
    bb.Name = "JB_ESP"; bb.Adornee = anchor; bb.AlwaysOnTop = true
    bb.LightInfluence = 0; bb.Size = UDim2.new(0, 240, 0, 70)
    bb.StudsOffset = Vector3.new(0, 6, 0); bb.MaxDistance = 5000; bb.Parent = anchor
    e.billboard = bb

    local function mkLabel(name, sz, font, fontSize, color, pos)
        local l = Instance.new("TextLabel")
        l.Name = name; l.BackgroundTransparency = 1; l.Size = sz; l.Position = pos
        l.Font = font; l.TextSize = fontSize; l.TextColor3 = color
        l.TextStrokeTransparency = 0.3; l.TextStrokeColor3 = Color3.new(0, 0, 0)
        l.Text = ""; l.Parent = bb
        return l
    end
    e.nameLabel = mkLabel("Name",     UDim2.new(1,0,0,20), Enum.Font.GothamBold, ESP.Settings.TextSize, ESP.Settings.Colors.Name,     UDim2.fromOffset(0,0))
    e.nameLabel.Text = model.Name
    e.distLabel = mkLabel("Distance", UDim2.new(1,0,0,14), Enum.Font.Gotham,     math.max(10, ESP.Settings.TextSize - 2), ESP.Settings.Colors.Distance, UDim2.fromOffset(0,20))

    local hpBg = Instance.new("Frame")
    hpBg.Name = "HpBg"; hpBg.BackgroundColor3 = Color3.new(0,0,0); hpBg.BackgroundTransparency = 0.3
    hpBg.BorderSizePixel = 0; hpBg.Size = UDim2.new(1,-40,0,5); hpBg.Position = UDim2.new(0,20,0,38); hpBg.Parent = bb
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0,2)
    e.hpBg = hpBg
    local hpBar = Instance.new("Frame")
    hpBar.Name = "HpBar"; hpBar.BackgroundColor3 = ESP.Settings.Colors.HealthHi
    hpBar.BorderSizePixel = 0; hpBar.Size = UDim2.fromScale(1,1); hpBar.Parent = hpBg
    Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0,2)
    e.hpBar = hpBar
    e.hpText = mkLabel("HpText", UDim2.new(1,0,0,14), Enum.Font.Gotham, math.max(10, ESP.Settings.TextSize - 2), Color3.new(1,1,1), UDim2.fromOffset(0,46))

    local boxPart = Instance.new("Part")
    boxPart.Name = "JB_BoxAnchor"; boxPart.Anchored = true; boxPart.CanCollide = false
    boxPart.CanQuery = false; boxPart.CanTouch = false; boxPart.Massless = true
    boxPart.Transparency = 1; boxPart.Size = Vector3.new(4,6,4); boxPart.Parent = model
    e.boxPart = boxPart
    local boxSel = Instance.new("SelectionBox")
    boxSel.Adornee = boxPart; boxSel.LineThickness = 0.05
    boxSel.Color3 = ESP.Settings.Colors.Box; boxSel.SurfaceTransparency = 1
    boxSel.SurfaceColor3 = ESP.Settings.Colors.Box; boxSel.Visible = false; boxSel.Parent = boxPart
    e.boxSel = boxSel

    local head = model:FindFirstChild("Head") or model.PrimaryPart or anchor
    if head and head:IsA("BasePart") then
        local headBb = Instance.new("BillboardGui")
        headBb.Name = "JB_HeadDot"; headBb.Adornee = head; headBb.AlwaysOnTop = true
        headBb.LightInfluence = 0; headBb.Size = UDim2.fromOffset(12,12); headBb.Enabled = false
        headBb.MaxDistance = 5000; headBb.Parent = head
        local dot = Instance.new("Frame")
        dot.Name = "Dot"; dot.BackgroundColor3 = ESP.Settings.Colors.HeadDot
        dot.Size = UDim2.fromScale(1,1); dot.BorderSizePixel = 0; dot.Parent = headBb
        Instance.new("UICorner", dot).CornerRadius = UDim.new(0.5,0)
        e.headBb = headBb; e.headDot = dot
    end

    local tracerGui = ensureTracerGui()
    local tracer = Instance.new("Frame")
    tracer.Name = "JB_Tracer"; tracer.AnchorPoint = Vector2.new(0,0.5)
    tracer.BackgroundColor3 = ESP.Settings.Colors.Tracer; tracer.BorderSizePixel = 0
    tracer.Size = UDim2.fromOffset(0,1); tracer.Position = UDim2.fromOffset(0,0)
    tracer.Visible = false; tracer.ZIndex = 1; tracer.Parent = tracerGui
    local tracerGrad = Instance.new("UIGradient"); tracerGrad.Color = ColorSequence.new(ESP.Settings.Colors.Tracer); tracerGrad.Enabled = false; tracerGrad.Parent = tracer
    local tracerGlow = Instance.new("UIStroke"); tracerGlow.Color = ESP.Settings.Colors.Tracer; tracerGlow.Thickness = 2; tracerGlow.Transparency = 0.4; tracerGlow.Enabled = false; tracerGlow.Parent = tracer
    local endDot = Instance.new("Frame"); endDot.AnchorPoint = Vector2.new(0.5,0.5); endDot.Size = UDim2.fromOffset(6,6); endDot.BackgroundColor3 = ESP.Settings.Colors.Tracer; endDot.BorderSizePixel = 0; endDot.Visible = false; endDot.ZIndex = 2; endDot.Parent = tracerGui
    Instance.new("UICorner", endDot).CornerRadius = UDim.new(0.5,0)
    local originDot = endDot:Clone(); originDot.Parent = tracerGui

    e.tracer = tracer; e.tracerGrad = tracerGrad; e.tracerGlow = tracerGlow
    e.tracerEndDot = endDot; e.tracerOriginDot = originDot
    e.highlight = nil
    return e
end

local function destroyEntry(entry: any)
    if not entry then return end
    if entry.billboard then entry.billboard:Destroy() end
    if entry.headBb    then entry.headBb:Destroy()    end
    if entry.boxPart   then entry.boxPart:Destroy()   end
    if entry.tracer    then entry.tracer:Destroy()    end
    if entry.tracerEndDot    then entry.tracerEndDot:Destroy()    end
    if entry.tracerOriginDot then entry.tracerOriginDot:Destroy() end
    if entry.highlight then entry.highlight:Destroy() end
end

local function hideEntry(entry: any)
    if not entry then return end
    if entry.billboard then entry.billboard.Enabled = false end
    if entry.headBb    then entry.headBb.Enabled    = false end
    if entry.boxSel    then entry.boxSel.Visible    = false end
    if entry.tracer    then entry.tracer.Visible    = false end
    if entry.tracerEndDot    then entry.tracerEndDot.Visible    = false end
    if entry.tracerOriginDot then entry.tracerOriginDot.Visible = false end
end

local function modelOwner(model: Model): Player?
    return Players:GetPlayerFromCharacter(model)
end

local function colorForModel(model: Model): Color3
    local s = ESP.Settings
    local owner = modelOwner(model)
    if owner then
        if s.TeamCheck and owner.Team and LocalPlayer.Team then
            if owner.Team == LocalPlayer.Team then return s.Colors.Friendly else return s.Colors.Enemy end
        end
        return s.Colors.Player
    end
    return s.Colors.NPC
end

local function updateESP()
    if not ESP.Active then return end
    local s = ESP.Settings
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local camPos = cam.CFrame.Position

    if tick() - ESP.LastScan >= ESP.ScanInterval then
        ESP.LastScan = tick()
        local seen = collectCreatureModels()
        for m in pairs(seen) do
            if not ESP.Entries[m] then ESP.Entries[m] = createEntry(m) end
        end
        for model, entry in pairs(ESP.Entries) do
            if not seen[model] or not model.Parent then
                destroyEntry(entry); ESP.Entries[model] = nil
            end
        end
        local n = 0; for _ in pairs(ESP.Entries) do n += 1 end
        ESP.LastScanCount = n
    end

    for model, entry in pairs(ESP.Entries) do
        local hum   = model:FindFirstChildOfClass("Humanoid")
        local owner = modelOwner(model)
        local isPlayer = owner ~= nil
        local skip = false
        if not (hum and hum.Health > 0 and model.Parent) then skip = true end
        if not skip and not s.ShowSelf and model == Character then skip = true end
        if not skip and isPlayer and not s.ShowPlayers then skip = true end
        if not skip and not isPlayer and not s.ShowNPCs then skip = true end
        if not skip and owner and not s.ShowTeam
           and owner.Team and LocalPlayer.Team and owner.Team == LocalPlayer.Team then skip = true end
        if skip then hideEntry(entry); if entry.highlight then entry.highlight.Enabled = false end; continue end

        local ok, cf, size = pcall(function() local c, sz = model:GetBoundingBox(); return c, sz end)
        if not ok or not cf or not size then hideEntry(entry); continue end
        local distance = (cf.Position - camPos).Magnitude
        if distance > s.MaxDistance then hideEntry(entry); if entry.highlight then entry.highlight.Enabled = false end; continue end

        local color = colorForModel(model)
        local nameTxt = ""
        if s.Names then nameTxt = model.Name end
        if s.ShowOwner and owner then nameTxt = (nameTxt ~= "" and nameTxt .. " " or "") .. "[" .. owner.Name .. "]" end

        if entry.billboard then
            entry.billboard.Enabled = s.Names or s.ShowOwner or s.Distance or s.HealthText or s.HealthBar
            entry.nameLabel.Visible = (s.Names or s.ShowOwner) and nameTxt ~= ""
            if entry.nameLabel.Visible then
                entry.nameLabel.Text = nameTxt; entry.nameLabel.TextColor3 = s.Colors.Name; entry.nameLabel.TextSize = s.TextSize
            end
            entry.distLabel.Visible = s.Distance
            if s.Distance then
                entry.distLabel.Text = ("%d studs"):format(math.floor(distance))
                entry.distLabel.TextColor3 = s.Colors.Distance
                entry.distLabel.TextSize = math.max(10, s.TextSize - 2)
            end
            local hh = hum :: Humanoid
            local pct = math.clamp(hh.Health / math.max(1, hh.MaxHealth), 0, 1)
            local healthColor = s.Colors.HealthLo:Lerp(s.Colors.HealthHi, pct)
            if entry.hpBg and entry.hpBar then
                entry.hpBg.Visible = s.HealthBar; entry.hpBar.Visible = s.HealthBar
                if s.HealthBar then entry.hpBar.Size = UDim2.new(pct, 0, 1, 0); entry.hpBar.BackgroundColor3 = healthColor end
            end
            if entry.hpText then
                entry.hpText.Visible = s.HealthText
                if s.HealthText then
                    entry.hpText.Text = ("%d / %d"):format(math.floor(hh.Health), math.floor(hh.MaxHealth))
                    entry.hpText.TextColor3 = healthColor
                    entry.hpText.TextSize = math.max(10, s.TextSize - 2)
                end
            end
        end

        if entry.boxPart and entry.boxSel then
            if s.Boxes then
                entry.boxPart.CFrame = cf; entry.boxPart.Size = size
                entry.boxSel.Visible = true; entry.boxSel.Color3 = color
                entry.boxSel.LineThickness = 0.02 + s.BoxThickness * 0.04
                if s.BoxType == "Filled" then
                    entry.boxSel.SurfaceTransparency = 1 - s.BoxFillTransparency
                    entry.boxSel.SurfaceColor3 = color
                else entry.boxSel.SurfaceTransparency = 1 end
            else entry.boxSel.Visible = false end
        end

        if entry.tracer then
            local showTracer = s.Tracers and ((isPlayer and s.TracerOnPlayers) or (not isPlayer and s.TracerOnNPCs))
            if showTracer then
                local targetWorld = cf.Position
                if s.TracerToHead then
                    local head = model:FindFirstChild("Head")
                    if head and head:IsA("BasePart") then targetWorld = head.Position end
                end
                local screenPos: Vector3 = cam:WorldToViewportPoint(targetWorld)
                local view = cam.ViewportSize
                local onScreen = screenPos.Z > 0 and screenPos.X >= 0 and screenPos.X <= view.X and screenPos.Y >= 0 and screenPos.Y <= view.Y
                local passOffscreen = (not s.TracerOffscreenOnly) or (not onScreen)
                if screenPos.Z > 0 and passOffscreen then
                    local target = Vector2.new(screenPos.X, screenPos.Y)
                    local origin: Vector2
                    if s.TracerOrigin == "Top" then origin = Vector2.new(view.X * 0.5, 0)
                    elseif s.TracerOrigin == "Center" then origin = Vector2.new(view.X * 0.5, view.Y * 0.5)
                    elseif s.TracerOrigin == "Mouse" then local m = UserInputService:GetMouseLocation(); origin = Vector2.new(m.X, m.Y)
                    else origin = Vector2.new(view.X * 0.5, view.Y) end
                    local dv = target - origin
                    local len = dv.Magnitude
                    local angle = math.deg(math.atan2(dv.Y, dv.X))
                    local thick = math.max(1, s.TracerThickness)
                    local col = s.Colors.Tracer
                    if s.TracerRainbow then col = Color3.fromHSV((tick() * s.TracerRainbowSpeed) % 1, 1, 1)
                    elseif s.TracerHealthColor and hum then
                        local hh = hum :: Humanoid
                        local pct = math.clamp(hh.Health / math.max(1, hh.MaxHealth), 0, 1)
                        col = s.Colors.HealthLo:Lerp(s.Colors.HealthHi, pct)
                    elseif s.TracerTeamColor and owner and owner.Team and LocalPlayer.Team then
                        col = (owner.Team == LocalPlayer.Team) and s.Colors.Friendly or s.Colors.Enemy
                    end
                    local transparency = s.TracerTransparency
                    if s.TracerDistanceFade and s.MaxDistance > 0 then
                        transparency = math.clamp(transparency + math.clamp(distance / s.MaxDistance, 0, 1) * 0.75, 0, 1)
                    end
                    local t = entry.tracer
                    t.Visible = true; t.Position = UDim2.fromOffset(origin.X, origin.Y)
                    t.Size = UDim2.fromOffset(math.max(len, 1), thick); t.Rotation = angle
                    t.BackgroundColor3 = col; t.BackgroundTransparency = transparency
                    local style = s.TracerStyle
                    if style == "Glow" then
                        entry.tracerGrad.Enabled = false; entry.tracerGlow.Enabled = true
                        entry.tracerGlow.Color = col; entry.tracerGlow.Transparency = math.min(transparency + 0.3, 0.9)
                    elseif style == "Dashed" then
                        entry.tracerGlow.Enabled = false; entry.tracerGrad.Enabled = true
                        entry.tracerGrad.Color = ColorSequence.new(col)
                        local kps = {}
                        for i = 0, 11 do
                            table.insert(kps, NumberSequenceKeypoint.new(i / 11, (i % 2 == 0) and 0 or 1))
                        end
                        entry.tracerGrad.Transparency = NumberSequence.new(kps)
                    elseif style == "Gradient" then
                        entry.tracerGlow.Enabled = false; entry.tracerGrad.Enabled = true
                        entry.tracerGrad.Color = ColorSequence.new(col)
                        entry.tracerGrad.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
                        })
                    else
                        entry.tracerGlow.Enabled = false; entry.tracerGrad.Enabled = false
                    end
                    if entry.tracerEndDot then
                        entry.tracerEndDot.Visible = s.TracerEndDot
                        if s.TracerEndDot then
                            entry.tracerEndDot.Position = UDim2.fromOffset(target.X, target.Y)
                            entry.tracerEndDot.Size = UDim2.fromOffset(thick + 4, thick + 4)
                            entry.tracerEndDot.BackgroundColor3 = col
                            entry.tracerEndDot.BackgroundTransparency = transparency
                        end
                    end
                    if entry.tracerOriginDot then
                        entry.tracerOriginDot.Visible = s.TracerOriginDot
                        if s.TracerOriginDot then
                            entry.tracerOriginDot.Position = UDim2.fromOffset(origin.X, origin.Y)
                            entry.tracerOriginDot.Size = UDim2.fromOffset(thick + 4, thick + 4)
                            entry.tracerOriginDot.BackgroundColor3 = col
                            entry.tracerOriginDot.BackgroundTransparency = transparency
                        end
                    end
                else
                    entry.tracer.Visible = false
                    if entry.tracerEndDot    then entry.tracerEndDot.Visible    = false end
                    if entry.tracerOriginDot then entry.tracerOriginDot.Visible = false end
                end
            else
                entry.tracer.Visible = false
                if entry.tracerEndDot    then entry.tracerEndDot.Visible    = false end
                if entry.tracerOriginDot then entry.tracerOriginDot.Visible = false end
            end
        end

        if entry.headBb and entry.headDot then
            if s.HeadDot then
                entry.headBb.Enabled = true
                local d = math.max(6, s.HeadDotRadius * 2)
                entry.headBb.Size = UDim2.fromOffset(d, d)
                entry.headDot.BackgroundColor3 = s.Colors.HeadDot
            else entry.headBb.Enabled = false end
        end

        local showChams = s.Chams and ((isPlayer and s.ChamsOnPlayers) or (not isPlayer and s.ChamsOnNPCs))
        if showChams then
            if not entry.highlight then
                entry.highlight = Instance.new("Highlight"); entry.highlight.Name = "JB_Chams"
            end
            local h = entry.highlight
            local fill: Color3
            if s.ChamsMode == "Rainbow" then fill = Color3.fromHSV((tick() * s.ChamsRainbowSpeed) % 1, 1, 1)
            elseif s.ChamsMode == "Health-based" then
                local hh = hum :: Humanoid
                local p = math.clamp(hh.Health / math.max(1, hh.MaxHealth), 0, 1)
                fill = s.Colors.HealthLo:Lerp(s.Colors.HealthHi, p)
            elseif s.ChamsTeamColor and owner and owner.Team and LocalPlayer.Team then
                fill = (owner.Team == LocalPlayer.Team) and s.Colors.Friendly or s.Colors.Enemy
            elseif s.ChamsDualColor then
                fill = modelInLOS(model, cam) and s.Colors.ChamsVisible or s.Colors.ChamsOccluded
            else
                fill = isPlayer and s.Colors.ChamsPlayer or s.Colors.ChamsNPC
            end
            local fillOp = s.ChamsFillTransparency
            local outlineOp = 1 - s.ChamsOutlineTransparency
            if s.ChamsMode == "Outline Only" then fillOp = 0
            elseif s.ChamsMode == "Fill Only" then outlineOp = 0
            elseif s.ChamsMode == "Pulse" then
                local t = (math.sin(tick() * math.pi * 2 * s.ChamsPulseSpeed) + 1) * 0.5
                fillOp *= t; outlineOp *= t
            end
            if s.ChamsDistanceFade and s.MaxDistance > 0 then
                local k = 1 - math.clamp(distance / s.MaxDistance, 0, 1)
                fillOp *= k; outlineOp *= k
            end
            h.Adornee = model; h.FillColor = fill; h.OutlineColor = s.Colors.ChamsOutline
            h.FillTransparency    = 1 - math.clamp(fillOp,    0, 1)
            h.OutlineTransparency = 1 - math.clamp(outlineOp, 0, 1)
            h.DepthMode = (s.ChamsDepth == "AlwaysOnTop") and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
            h.Parent = model; h.Enabled = true
        elseif entry.highlight then entry.highlight.Enabled = false end
    end
end

function ESP.add(model: Model)
    if ESP.Entries[model] then return end
    ESP.Entries[model] = createEntry(model)
end
function ESP.remove(model: Model)
    local e = ESP.Entries[model]
    if e then destroyEntry(e) end
    ESP.Entries[model] = nil
end
function ESP.enable()
    if ESP.Active then return end
    ESP.Active = true; ESP.Settings.Enabled = true; ESP.LastScan = 0
    local accum = 0
    trackConnection("ESP_RenderStepped", RunService.RenderStepped:Connect(function(dt)
        accum += dt; if accum < (1/30) then return end; accum = 0; updateESP()
    end))
    task.defer(function()
        local seen = collectCreatureModels()
        local n = 0
        for m in pairs(seen) do
            if not ESP.Entries[m] then ESP.Entries[m] = createEntry(m) end
            n += 1
        end
        ESP.LastScanCount = n; ESP.LastScan = tick()
        Util.notify("ESP", ("Tracking %d creature%s"):format(n, n == 1 and "" or "s"))
    end)
end
function ESP.disable()
    ESP.Active = false; ESP.Settings.Enabled = false
    for m in pairs(ESP.Entries) do ESP.remove(m) end
    if Connections.ESP_RenderStepped then Connections.ESP_RenderStepped:Disconnect(); Connections.ESP_RenderStepped = nil end
    if ESP.TracerGui then pcall(function() ESP.TracerGui:Destroy() end); ESP.TracerGui = nil end
end

------------------------------------------------------------------------------
-- 13b. RESOURCE ESP
------------------------------------------------------------------------------
local ResourceESP = {
    Enabled = false, Entries = {} :: {[Instance]: any},
    Colors = {
        Berry    = Color3.fromRGB(230,  90, 130),
        Meat     = Color3.fromRGB(220,  90,  90),
        Fish     = Color3.fromRGB( 95, 175, 230),
        Wood     = Color3.fromRGB(160, 110,  60),
        Stone    = Color3.fromRGB(170, 170, 180),
        Fossil   = Color3.fromRGB(230, 220, 180),
        Egg      = Color3.fromRGB(240, 230, 200),
        Water    = Color3.fromRGB( 80, 180, 240),
        Iron     = Color3.fromRGB(150, 150, 160),
        Gold     = Color3.fromRGB(255, 215,  90),
        Diamond  = Color3.fromRGB( 90, 245, 255),
        Sapling  = Color3.fromRGB(120, 220, 130),
        Mushroom = Color3.fromRGB(210, 130, 210),
        Loot     = Color3.fromRGB(255, 200,  80),
        Default  = Color3.fromRGB(255, 200,   0),
    },
}

local function resourceColor(typeName: string): Color3
    return (ResourceESP.Colors :: any)[typeName] or ResourceESP.Colors.Default
end
local function resourceAnchorPart(inst: Instance): BasePart?
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst.PrimaryPart or inst:FindFirstChild("HumanoidRootPart") :: BasePart?
            or inst:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function buildResourceEntry(inst: Instance, typeName: string)
    local anchor = resourceAnchorPart(inst)
    if not anchor then return nil end
    local color = resourceColor(typeName)
    local highlight = Instance.new("Highlight")
    highlight.Name = "JurassicBlocky_ResourceESP_" .. _RAND_SUFFIX
    highlight.FillColor = color; highlight.OutlineColor = Color3.new(1,1,1)
    highlight.FillTransparency = 0.55; highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = inst; highlight.Parent = inst
    local bb = Instance.new("BillboardGui")
    bb.Name = "JurassicBlocky_ResourceLabel_" .. _RAND_SUFFIX
    bb.AlwaysOnTop = true; bb.LightInfluence = 0
    bb.Size = UDim2.new(0,140,0,32); bb.StudsOffsetWorldSpace = Vector3.new(0,4,0)
    bb.Adornee = anchor; bb.Parent = anchor
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1; title.Size = UDim2.new(1,0,0,16)
    title.TextColor3 = color; title.TextStrokeTransparency = 0; title.TextStrokeColor3 = Color3.new(0,0,0)
    title.Font = Enum.Font.GothamSemibold; title.TextSize = 13; title.Text = typeName; title.Parent = bb
    local dist = Instance.new("TextLabel")
    dist.BackgroundTransparency = 1; dist.Position = UDim2.new(0,0,0,16); dist.Size = UDim2.new(1,0,0,14)
    dist.TextColor3 = Color3.fromRGB(225,228,235); dist.TextStrokeTransparency = 0; dist.TextStrokeColor3 = Color3.new(0,0,0)
    dist.Font = Enum.Font.Gotham; dist.TextSize = 11; dist.Text = "0 studs"; dist.Parent = bb
    return { inst = inst, anchor = anchor, typeName = typeName, highlight = highlight, billboard = bb, title = title, dist = dist }
end

local function destroyResourceEntry(entry)
    if not entry then return end
    if entry.highlight then pcall(function() entry.highlight:Destroy() end) end
    if entry.billboard then pcall(function() entry.billboard:Destroy() end) end
end

function ResourceESP.clear()
    for inst, entry in pairs(ResourceESP.Entries) do
        destroyResourceEntry(entry); ResourceESP.Entries[inst] = nil
    end
end
function ResourceESP.disable()
    ResourceESP.Enabled = false
    if Connections.ResourceESP_Tick then
        Connections.ResourceESP_Tick:Disconnect(); Connections.ResourceESP_Tick = nil
    end
    ResourceESP.clear()
end
function ResourceESP.rescan()
    if not ResourceESP.Enabled then return end
    local types = getSelectedFarmTargets()
    if #types == 0 then table.insert(types, "Berry") end
    local alive: {[Instance]: string} = {}
    for _, t in ipairs(types) do
        for _, part in ipairs(findFarmTargets(t)) do
            local owner = ownerOf(part); alive[owner] = t
        end
    end
    for owner, typeName in pairs(alive) do
        if not ResourceESP.Entries[owner] then
            local entry = buildResourceEntry(owner, typeName)
            if entry then ResourceESP.Entries[owner] = entry end
        end
    end
    for owner, entry in pairs(ResourceESP.Entries) do
        if not alive[owner] or not owner.Parent then
            destroyResourceEntry(entry); ResourceESP.Entries[owner] = nil
        end
    end
end
function ResourceESP.enable()
    if ResourceESP.Enabled then return end
    ResourceESP.Enabled = true; ResourceESP.rescan()
    task.spawn(function()
        while Alive.value and ResourceESP.Enabled do
            ResourceESP.rescan(); task.wait(1.0)
        end
    end)
    local accum = 0
    Connections.ResourceESP_Tick = RunService.Heartbeat:Connect(function(dt)
        if not ResourceESP.Enabled or not RootPart then return end
        accum += dt; if accum < 0.16 then return end; accum = 0
        local myPos = RootPart.Position
        for inst, entry in pairs(ResourceESP.Entries) do
            if entry.anchor and entry.anchor.Parent then
                local d = (entry.anchor.Position - myPos).Magnitude
                entry.dist.Text = ("%d studs"):format(math.floor(d))
            else
                destroyResourceEntry(entry); ResourceESP.Entries[inst] = nil
            end
        end
    end)
end

------------------------------------------------------------------------------
-- 14. TELEPORT UTILITIES
------------------------------------------------------------------------------
local Teleport = {}
function Teleport.toPosition(pos: Vector3, smooth: boolean?)
    if not RootPart then return end
    local cf = CFrame.new(pos)
    if smooth then Util.tweenTo(cf) else RootPart.CFrame = cf end
end
function Teleport.toPlayer(targetName: string, smooth: boolean?)
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character then Util.notify("Teleport", "Player not found."); return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if smooth then Util.tweenTo(root.CFrame + Vector3.new(0,0,3))
    elseif RootPart then RootPart.CFrame = root.CFrame + Vector3.new(0,0,3) end
end

------------------------------------------------------------------------------
-- 15. STAT MONITOR HUD
------------------------------------------------------------------------------
local StatMonitor = { Frame = nil :: Frame?, Gui = nil :: ScreenGui? }
function StatMonitor.start()
    if StatMonitor.Frame then return end
    local hudParent: Instance = LocalPlayer:WaitForChild("PlayerGui")
    Util.safe(function() if CoreGui then hudParent = CoreGui end end, "StatMonitor parent")
    local gui = Instance.new("ScreenGui")
    gui.Name = "JurassicBlocky_HUD_" .. _RAND_SUFFIX; gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true; gui.Parent = hudParent
    StatMonitor.Gui = gui
    local frame = Instance.new("Frame")
    frame.Name = "StatMonitor"; frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1,-10,0,10); frame.Size = UDim2.new(0,180,0,110)
    frame.BackgroundColor3 = CONFIG.GUIBackgroundColor; frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0; frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0,2); layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    local pad = Instance.new("UIPadding", frame)
    pad.PaddingLeft = UDim.new(0,8); pad.PaddingTop = UDim.new(0,6)
    StatMonitor.Frame = frame
    task.spawn(function()
        while Alive.value and StatMonitor.Frame and StatMonitor.Frame.Parent do
            task.wait(0.5)
            if not State.StatMonitor then StatMonitor.Frame.Visible = false; continue end
            StatMonitor.Frame.Visible = true
            for _, c in ipairs(StatMonitor.Frame:GetChildren()) do
                if c:IsA("TextLabel") then c:Destroy() end
            end
            for _, statName in ipairs({"Hunger","Thirst","Energy","Breath","Health"}) do
                local val = getStat(statName)
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-8,0,18)
                lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextColor3 = Color3.new(1,1,1)
                lbl.Text = ("%s: %s"):format(statName, val and tostring(math.floor(val)) or "-")
                lbl.Parent = StatMonitor.Frame
            end
        end
    end)
end
function StatMonitor.stop()
    if StatMonitor.Gui then StatMonitor.Gui:Destroy() end
    StatMonitor.Gui = nil; StatMonitor.Frame = nil
end

------------------------------------------------------------------------------
-- 15a. INFO HUD (FPS / Ping / Memory / Coords / Time)
------------------------------------------------------------------------------
local InfoHUD = {
    Gui = nil :: ScreenGui?, Labels = {} :: {[string]: TextLabel}, Conn = nil,
    Visible = { FPS = true, Ping = true, Memory = false, Coords = false, Time = false },
    Anchor = "TopLeft",
    _fpsAccum = 0, _fpsFrames = 0, _fpsCurrent = 0,
}
local function _anchorPosition(anchor: string): (Vector2, UDim2)
    if anchor == "TopRight"     then return Vector2.new(1,0), UDim2.new(1,-12,0,12) end
    if anchor == "BottomLeft"   then return Vector2.new(0,1), UDim2.new(0,12,1,-12) end
    if anchor == "BottomRight"  then return Vector2.new(1,1), UDim2.new(1,-12,1,-12) end
    return Vector2.new(0,0), UDim2.new(0,12,0,12)
end
function InfoHUD.start()
    if InfoHUD.Gui and InfoHUD.Gui.Parent then return end
    local g = Instance.new("ScreenGui")
    g.Name = "JurassicBlocky_InfoHUD_" .. _RAND_SUFFIX; g.ResetOnSpawn = false; g.IgnoreGuiInset = true; g.DisplayOrder = 8
    local globals: any = _G
    if type(globals.gethui) == "function" then
        local ok, h = pcall(globals.gethui); if ok and h then g.Parent = h end
    end
    if not g.Parent then pcall(function() g.Parent = CoreGui end) end
    if not g.Parent then g.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    local anchor, pos = _anchorPosition(InfoHUD.Anchor)
    local panel = Instance.new("Frame")
    panel.Name = "Panel"; panel.AnchorPoint = anchor; panel.Position = pos
    panel.Size = UDim2.new(0,170,0,0); panel.AutomaticSize = Enum.AutomaticSize.Y
    panel.BackgroundColor3 = Color3.fromRGB(15,17,24); panel.BackgroundTransparency = 0.15
    panel.BorderSizePixel = 0; panel.Parent = g
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,8)
    local stk = Instance.new("UIStroke", panel)
    stk.Color = Color3.fromRGB(70,78,100); stk.Thickness = 1; stk.Transparency = 0.4
    local pad = Instance.new("UIPadding", panel)
    pad.PaddingTop = UDim.new(0,8); pad.PaddingBottom = UDim.new(0,8)
    pad.PaddingLeft = UDim.new(0,10); pad.PaddingRight = UDim.new(0,10)
    local layout = Instance.new("UIListLayout", panel)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0,3); layout.SortOrder = Enum.SortOrder.LayoutOrder
    local function mkLabel(key: string, order: number)
        local l = Instance.new("TextLabel")
        l.Name = key; l.BackgroundTransparency = 1
        l.Size = UDim2.new(1,0,0,16)
        l.Font = Enum.Font.GothamSemibold; l.TextSize = 12
        l.TextColor3 = Color3.fromRGB(235,238,245)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.LayoutOrder = order; l.Text = key .. ": -"; l.Parent = panel
        InfoHUD.Labels[key] = l
    end
    mkLabel("FPS",1); mkLabel("Ping",2); mkLabel("Memory",3); mkLabel("Coords",4); mkLabel("Time",5)
    InfoHUD.Gui = g
    InfoHUD.Conn = RunService.RenderStepped:Connect(function(dt)
        InfoHUD._fpsAccum += dt; InfoHUD._fpsFrames += 1
        if InfoHUD._fpsAccum >= 0.5 then
            InfoHUD._fpsCurrent = math.floor(InfoHUD._fpsFrames / InfoHUD._fpsAccum + 0.5)
            InfoHUD._fpsAccum = 0; InfoHUD._fpsFrames = 0
        end
        for key, label in pairs(InfoHUD.Labels) do label.Visible = InfoHUD.Visible[key] == true end
        if InfoHUD.Visible.FPS then
            local fps = InfoHUD._fpsCurrent
            local col = fps >= 50 and Color3.fromRGB(95,215,135)
                or fps >= 30 and Color3.fromRGB(255,185,95)
                or Color3.fromRGB(245,105,120)
            InfoHUD.Labels.FPS.Text = ("FPS: %d"):format(fps); InfoHUD.Labels.FPS.TextColor3 = col
        end
        if InfoHUD.Visible.Ping then
            local stats = game:GetService("Stats")
            local ok, ms = pcall(function() return stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
            local pingNum = ok and math.floor(ms) or -1
            local col = pingNum < 100 and Color3.fromRGB(95,215,135)
                or pingNum < 200 and Color3.fromRGB(255,185,95)
                or Color3.fromRGB(245,105,120)
            InfoHUD.Labels.Ping.Text = pingNum >= 0 and ("Ping: %d ms"):format(pingNum) or "Ping: ?"
            InfoHUD.Labels.Ping.TextColor3 = col
        end
        if InfoHUD.Visible.Memory then
            local stats = game:GetService("Stats")
            InfoHUD.Labels.Memory.Text = ("Mem: %d MB"):format(math.floor(stats:GetTotalMemoryUsageMb()))
        end
        if InfoHUD.Visible.Coords then
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local p = (Character.HumanoidRootPart :: BasePart).Position
                InfoHUD.Labels.Coords.Text = ("X %d  Y %d  Z %d"):format(math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
            else InfoHUD.Labels.Coords.Text = "Coords: -" end
        end
        if InfoHUD.Visible.Time then
            local t = Lighting.ClockTime
            local h = math.floor(t); local m = math.floor((t - h) * 60)
            InfoHUD.Labels.Time.Text = ("Time: %02d:%02d"):format(h, m)
        end
    end)
end
function InfoHUD.stop()
    if InfoHUD.Conn then InfoHUD.Conn:Disconnect(); InfoHUD.Conn = nil end
    if InfoHUD.Gui then InfoHUD.Gui:Destroy() end
    InfoHUD.Gui = nil; InfoHUD.Labels = {}
end
function InfoHUD.refreshAnchor()
    if not InfoHUD.Gui then return end
    local panel = InfoHUD.Gui:FindFirstChild("Panel")
    if not panel or not panel:IsA("Frame") then return end
    local a, p = _anchorPosition(InfoHUD.Anchor); panel.AnchorPoint = a; panel.Position = p
end

------------------------------------------------------------------------------
-- 15c. SESSION STATS - tracks first detected coin/XP value
------------------------------------------------------------------------------
local Session = { StartTime = tick(), StartCoins = nil :: number?, LastCoins = nil :: number?, CoinsGained = 0, CoinsSpent = 0 }
local function findCoinValue(): ValueBase?
    local lp = LocalPlayer
    local roots: {Instance} = { lp }
    local ls = lp:FindFirstChild("leaderstats"); if ls then table.insert(roots, ls) end
    local data = lp:FindFirstChild("Data") or lp:FindFirstChild("PlayerData"); if data then table.insert(roots, data) end
    if Character then table.insert(roots, Character) end
    local aliases = STAT_ALIASES.Coins
    for _, root in ipairs(roots) do
        for _, c in ipairs(root:GetDescendants()) do
            if (c:IsA("NumberValue") or c:IsA("IntValue")) then
                local nm = c.Name:lower()
                for _, a in ipairs(aliases) do
                    if nm == a:lower() then return c end
                end
            end
        end
    end
    return nil
end
local function pollCoins()
    local v = findCoinValue(); if not v then return end
    local cur = (v :: any).Value
    if not Session.StartCoins then Session.StartCoins = cur end
    if Session.LastCoins and cur < Session.LastCoins then
        Session.CoinsSpent += (Session.LastCoins - cur)
    end
    if cur >= (Session.StartCoins or 0) then
        Session.CoinsGained = cur - (Session.StartCoins or 0)
    end
    Session.LastCoins = cur
end
task.spawn(function() while Alive.value and task.wait(1) do pcall(pollCoins) end end)

------------------------------------------------------------------------------
-- 15d. CONFIG IO - save / load named configs
------------------------------------------------------------------------------
local ConfigIO = { Folder = "JurassicBlockyFramework_Configs" }
local function _hasFS(): boolean
    return type((_G :: any).writefile) == "function"
       and type((_G :: any).readfile) == "function"
       and type((_G :: any).isfile)   == "function"
end
local function _mkfolder()
    local g: any = _G
    if type(g.makefolder) == "function" and type(g.isfolder) == "function" then
        if not g.isfolder(ConfigIO.Folder) then pcall(g.makefolder, ConfigIO.Folder) end
    end
end
function ConfigIO.list(): {string}
    local g: any = _G
    if type(g.listfiles) ~= "function" then return {} end
    local out: {string} = {}
    local ok, files = pcall(g.listfiles, ConfigIO.Folder)
    if not ok or not files then return out end
    for _, path in ipairs(files) do
        local name = tostring(path):match("([^/\\]+)%.json$") or tostring(path):match("([^/\\]+)$")
        if name then table.insert(out, name) end
    end
    return out
end
function ConfigIO.save(name: string, lib: any): (boolean, string?)
    if not _hasFS() then return false, "Executor has no file-system functions" end
    if type(name) ~= "string" or name == "" then return false, "Config name empty" end
    _mkfolder()
    local data: {[string]: any} = { _version = 1, Toggles = {}, Options = {} }
    if lib and lib.Toggles then
        for k, t in pairs(lib.Toggles) do
            if type(t) == "table" and t.Value ~= nil then data.Toggles[k] = t.Value end
        end
    end
    if lib and lib.Options then
        for k, o in pairs(lib.Options) do
            if type(o) == "table" then
                local v = o.Value
                if typeof(v) == "Color3" then data.Options[k] = { _kind = "Color3", R = v.R, G = v.G, B = v.B }
                elseif type(v) == "table" then
                    local copy = {}
                    for kk, vv in pairs(v) do
                        if type(vv) == "boolean" or type(vv) == "number" or type(vv) == "string" then copy[kk] = vv end
                    end
                    data.Options[k] = copy
                elseif v ~= nil and (type(v) == "boolean" or type(v) == "number" or type(v) == "string") then
                    data.Options[k] = v
                end
            end
        end
    end
    local json = HttpService:JSONEncode(data)
    local ok, err = pcall((_G :: any).writefile, ConfigIO.Folder .. "/" .. name .. ".json", json)
    if not ok then return false, tostring(err) end
    return true
end
function ConfigIO.load(name: string, lib: any): (boolean, string?)
    if not _hasFS() then return false, "Executor has no file-system functions" end
    local path = ConfigIO.Folder .. "/" .. name .. ".json"
    if not (_G :: any).isfile(path) then return false, "Config not found" end
    local ok, raw = pcall((_G :: any).readfile, path); if not ok then return false, tostring(raw) end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw); if not ok2 then return false, "JSON parse error" end
    if not lib then return false, "Library missing" end
    if data.Toggles then
        for k, v in pairs(data.Toggles) do
            local t = lib.Toggles[k]; if t and t.SetValue then pcall(t.SetValue, t, v) end
        end
    end
    if data.Options then
        for k, v in pairs(data.Options) do
            local o = lib.Options[k]; if not o then continue end
            if type(v) == "table" and v._kind == "Color3" then
                if o.SetValueRGB then pcall(o.SetValueRGB, o, Color3.new(v.R, v.G, v.B))
                elseif o.SetValue then pcall(o.SetValue, o, Color3.new(v.R, v.G, v.B)) end
            elseif type(v) == "table" then
                if o.SetValue then pcall(o.SetValue, o, v) end
            else
                if o.SetValue then pcall(o.SetValue, o, v) end
            end
        end
    end
    return true
end
function ConfigIO.delete(name: string): (boolean, string?)
    local g: any = _G
    if type(g.delfile) ~= "function" then return false, "delfile not available" end
    local path = ConfigIO.Folder .. "/" .. name .. ".json"
    if not g.isfile(path) then return false, "Config not found" end
    local ok, err = pcall(g.delfile, path)
    return ok, ok and nil or tostring(err)
end

------------------------------------------------------------------------------
-- 15b. VISUAL / CAMERA / FLY / FREECAM (simplified)
------------------------------------------------------------------------------
local function setFOV(value: number)
    local cam = Workspace.CurrentCamera
    if cam then cam.FieldOfView = value end
end
local _defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance
local function setInfiniteZoom(on: boolean)
    LocalPlayer.CameraMaxZoomDistance = on and math.huge or _defaultMaxZoom
end
local function applyCharTransparency(value: number)
    if not Character then return end
    for _, p in ipairs(Character:GetDescendants()) do
        if p:IsA("BasePart") then p.LocalTransparencyModifier = value end
    end
end

local FullBright = { Active = false, Saved = nil :: {[string]: any}? }
function FullBright.start()
    if FullBright.Active then return end
    FullBright.Saved = {
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
    }
    FullBright.Active = true
    Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1)
    Lighting.Brightness = 2; Lighting.ClockTime = 14
    Lighting.FogEnd = 1e9; Lighting.FogStart = 1e9; Lighting.GlobalShadows = false
end
function FullBright.stop()
    if not FullBright.Active or not FullBright.Saved then return end
    for key, val in pairs(FullBright.Saved) do
        Util.safe(function() (Lighting :: any)[key] = val end, "FullBright." .. key)
    end
    FullBright.Active = false; FullBright.Saved = nil
end

local _lightingEffectsSaved: {[Instance]: boolean} = {}
local function setLightingEffectsEnabled(enabled: boolean)
    for _, fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("PostEffect") then
            local fxAny = fx :: any
            if not enabled then _lightingEffectsSaved[fx] = fxAny.Enabled; fxAny.Enabled = false
            else fxAny.Enabled = _lightingEffectsSaved[fx] ~= false end
        end
    end
end

local WEATHER_KEYWORDS = { "rain", "snow", "storm", "weather", "fog", "mist", "dust", "lightning", "blizzard" }
local function isWeatherName(name: string): boolean
    local n = name:lower()
    for _, kw in ipairs(WEATHER_KEYWORDS) do if n:find(kw, 1, true) then return true end end
    return false
end
local _rainSaved: {[Instance]: boolean} = {}
local function setRainEnabled(enabled: boolean)
    local function visit(roots: {Instance})
        for _, root in ipairs(roots) do
            for _, p in ipairs(root:GetDescendants()) do
                if (p:IsA("ParticleEmitter") or p:IsA("Beam") or p:IsA("Trail")) and isWeatherName(p.Name) then
                    if not enabled then _rainSaved[p] = (p :: any).Enabled; (p :: any).Enabled = false
                    else (p :: any).Enabled = _rainSaved[p] ~= false end
                end
            end
        end
    end
    visit({ Workspace, Lighting })
end

local _underwaterSaved: {[Instance]: any} = {}
local _underwaterFog: {[string]: any} = {}
local _underwaterActive = false
local function setUnderwaterVision(enabled: boolean)
    if enabled and not _underwaterActive then
        _underwaterActive = true
        _underwaterFog = { FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, FogColor = Lighting.FogColor }
        Lighting.FogEnd = 1e9; Lighting.FogStart = 1e9
        for _, fx in ipairs(Lighting:GetDescendants()) do
            if fx:IsA("ColorCorrectionEffect") or fx:IsA("BlurEffect")
               or fx:IsA("DepthOfFieldEffect") or fx:IsA("Atmosphere") then
                _underwaterSaved[fx] = { Enabled = (fx :: any).Enabled }
                if fx:IsA("Atmosphere") then _underwaterSaved[fx].Density = fx.Density; fx.Density = 0
                else (fx :: any).Enabled = false end
            end
        end
    elseif (not enabled) and _underwaterActive then
        _underwaterActive = false
        for fx, saved in pairs(_underwaterSaved) do
            if fx.Parent then
                if fx:IsA("Atmosphere") and saved.Density ~= nil then (fx :: any).Density = saved.Density end
                if saved.Enabled ~= nil then (fx :: any).Enabled = saved.Enabled end
            end
        end
        _underwaterSaved = {}
        for k, v in pairs(_underwaterFog) do (Lighting :: any)[k] = v end
        _underwaterFog = {}
    end
end

local Fly = { Active = false, BV = nil :: BodyVelocity?, Gyro = nil :: BodyGyro?, Conn = nil :: RBXScriptConnection? }
function Fly.start()
    if Fly.Active then return end
    if not RootPart or not Humanoid then return end
    Fly.Active = true
    local bv = Instance.new("BodyVelocity")
    bv.Name = "JB_FlyVel_" .. _RAND_SUFFIX; bv.MaxForce = Vector3.new(1,1,1) * 9e9
    bv.Velocity = Vector3.new(); bv.P = 1250; bv.Parent = RootPart; Fly.BV = bv
    local gyro = Instance.new("BodyGyro")
    gyro.Name = "JB_FlyGyro_" .. _RAND_SUFFIX; gyro.MaxTorque = Vector3.new(1,1,1) * 9e9
    gyro.P = 1250; gyro.CFrame = RootPart.CFrame; gyro.Parent = RootPart; Fly.Gyro = gyro
    Fly.Conn = RunService.RenderStepped:Connect(function()
        if not (Fly.Active and RootPart and bv.Parent and Workspace.CurrentCamera) then return end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        bv.Velocity = (dir.Magnitude > 0 and dir.Unit or Vector3.new()) * CONFIG.FlySpeed
        gyro.CFrame = cam.CFrame
    end)
end
function Fly.stop()
    Fly.Active = false
    if Fly.Conn then Fly.Conn:Disconnect(); Fly.Conn = nil end
    if Fly.BV   then Fly.BV:Destroy();      Fly.BV   = nil end
    if Fly.Gyro then Fly.Gyro:Destroy();    Fly.Gyro = nil end
end

local Freecam = { Active = false, Conn = nil :: RBXScriptConnection?, OldType = Enum.CameraType.Custom }
function Freecam.start()
    if Freecam.Active then return end
    local cam = Workspace.CurrentCamera; if not cam then return end
    Freecam.Active = true; Freecam.OldType = cam.CameraType
    cam.CameraType = Enum.CameraType.Scriptable
    Freecam.Conn = RunService.RenderStepped:Connect(function(dt)
        if not Freecam.Active then return end
        cam = Workspace.CurrentCamera; if not cam then return end
        local speed = CONFIG.FreecamSpeed * dt * 10
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0,1,0) end
        cam.CFrame = cam.CFrame + dir * speed
    end)
end
function Freecam.stop()
    if not Freecam.Active then return end
    Freecam.Active = false
    if Freecam.Conn then Freecam.Conn:Disconnect(); Freecam.Conn = nil end
    local cam = Workspace.CurrentCamera; if cam then cam.CameraType = Freecam.OldType end
end

------------------------------------------------------------------------------
-- 15e. WEBHOOK
------------------------------------------------------------------------------
local function getExecRequest(): (((req: {[string]: any}) -> any)?, string?)
    local scopes: {{[string]: any}} = {}
    local genvFn = (rawget(_G, "getgenv") or (getfenv and getfenv(0).getgenv)) :: any
    if type(genvFn) == "function" then
        local ok, env = pcall(genvFn)
        if ok and type(env) == "table" then table.insert(scopes, env) end
    end
    table.insert(scopes, _G :: any)
    if type(shared) == "table" then table.insert(scopes, shared :: any) end
    if getfenv then
        local ok, env0 = pcall(getfenv, 0)
        if ok and type(env0) == "table" then table.insert(scopes, env0 :: any) end
    end
    for _, env in ipairs(scopes) do
        for _, n in ipairs({"request","http_request","httprequest"}) do
            local v = env[n]; if type(v) == "function" then return v, n end
        end
        for _, ns in ipairs({"syn","fluxus","http","Krnl","krnl","Synapse","secure"}) do
            local nsTbl = env[ns]
            if type(nsTbl) == "table" then
                for _, n in ipairs({"request","httprequest"}) do
                    local fn = nsTbl[n]; if type(fn) == "function" then return fn, ns .. "." .. n end
                end
            end
        end
    end
    return nil, nil
end

local function sendWebhook(url: string, payload: {[string]: any})
    if type(url) ~= "string" or url == "" then
        Util.notify("Webhook", "URL is empty - paste a webhook link first."); return
    end
    if not url:lower():find("^https?://") then
        Util.notify("Webhook", "URL must start with https://"); return
    end
    local body = HttpService:JSONEncode(payload)
    local req, reqName = getExecRequest()
    task.spawn(function()
        if not req then
            Util.notify("Webhook", "No executor request function. Try a newer executor."); return
        end
        local ok, resp = pcall(req, {
            Url = url, Method = "POST",
            Headers = { ["Content-Type"] = "application/json" }, Body = body,
        })
        if not ok then Util.notify("Webhook", ("Threw: %s"):format(tostring(resp))); return end
        local status = (type(resp) == "table") and (resp.StatusCode or resp.statusCode or resp.status or resp.Status) or nil
        if type(status) == "number" then
            if status >= 200 and status < 300 then Util.notify("Webhook", ("Sent OK (HTTP %d via %s)"):format(status, reqName or "?"))
            else Util.notify("Webhook", ("Failed HTTP %d"):format(status)) end
        else Util.notify("Webhook", ("Sent (via %s)"):format(reqName or "?")) end
    end)
end

------------------------------------------------------------------------------
-- 15f. OPTIONAL KICK BYPASS (generic, off by default; no DS-specific kills)
------------------------------------------------------------------------------
local KickBypass = { Installed = false, BlockedCount = 0, LastError = nil :: string? }
local function installKickBypass(): (boolean, string)
    KickBypass.LastError = nil
    local LP = Players.LocalPlayer
    if not LP then KickBypass.LastError = "no LocalPlayer"; return false, KickBypass.LastError end
    local hookmm = _findExecFn("hookmetamethod")
    local hookF = _findExecFn("hookfunction") or _findExecFn("replaceclosure")
    local newcc = _findExecFn("newcclosure") or function(f) return f end
    local hooked = false
    if type(hookF) == "function" then
        local ok = pcall(function()
            local oldKick
            oldKick = hookF(LP.Kick, newcc(function(self, reason)
                if self == LP then
                    KickBypass.BlockedCount += 1
                    warn(("[JurassicBlocky] [KickBypass] Blocked Kick: %s"):format(tostring(reason)))
                    return
                end
                return oldKick(self, reason)
            end))
        end)
        if ok then hooked = true end
    end
    if type(hookmm) == "function" then
        local getNC = _findExecFn("getnamecallmethod")
        if type(getNC) == "function" then
            local ok = pcall(function()
                local oldNamecall
                oldNamecall = hookmm(game, "__namecall", function(self, ...)
                    if self == LP and getNC() == "Kick" then
                        KickBypass.BlockedCount += 1
                        warn(("[JurassicBlocky] [KickBypass] Blocked __namecall Kick: %s"):format(tostring((...))))
                        return
                    end
                    return oldNamecall(self, ...)
                end)
            end)
            if ok then hooked = true end
        end
    end
    if hooked then KickBypass.Installed = true; return true, "Kick hook installed" end
    KickBypass.LastError = "no hooking primitives available"
    return false, KickBypass.LastError
end

------------------------------------------------------------------------------
-- 16. JBUI - bundled UI library (lightly trimmed from DinoUI)
--     - Randomized instance names per session
--     - Same widget set (Toggle/Slider/Dropdown/Input/Button/KeyPicker/ColorPicker)
------------------------------------------------------------------------------
local JBUI = {} do
    local THEME_PRESETS = {
        Jungle = {
            Background = Color3.fromRGB(20,26,22), BackgroundAlt = Color3.fromRGB(26,32,28),
            Sidebar = Color3.fromRGB(22,28,24), SidebarHi = Color3.fromRGB(30,38,32),
            Header = Color3.fromRGB(26,34,28), Surface = Color3.fromRGB(34,42,36),
            SurfaceAlt = Color3.fromRGB(42,52,44), SurfaceHi = Color3.fromRGB(54,66,56),
            Border = Color3.fromRGB(48,58,50), BorderLight = Color3.fromRGB(80,100,82),
            Text = Color3.fromRGB(235,242,232), TextDim = Color3.fromRGB(160,178,156),
            Subtle = Color3.fromRGB(100,118,98),
            Accent = Color3.fromRGB(85,200,110), AccentBright = Color3.fromRGB(140,230,150),
            AccentDim = Color3.fromRGB(60,160,80), AccentDeep = Color3.fromRGB(40,130,60),
            AccentCyan = Color3.fromRGB(110,220,170),
            Risky = Color3.fromRGB(245,105,120), RiskyDim = Color3.fromRGB(170,60,75),
            ToggleOff = Color3.fromRGB(50,60,52),
            Success = Color3.fromRGB(95,215,135), Warning = Color3.fromRGB(255,185,95),
            Tooltip = Color3.fromRGB(10,14,10), Shadow = Color3.new(0,0,0),
        },
        Indigo = {
            Background = Color3.fromRGB(15,17,24), BackgroundAlt = Color3.fromRGB(20,22,32),
            Sidebar = Color3.fromRGB(18,20,28), SidebarHi = Color3.fromRGB(26,30,42),
            Header = Color3.fromRGB(22,25,36), Surface = Color3.fromRGB(28,32,44),
            SurfaceAlt = Color3.fromRGB(38,43,58), SurfaceHi = Color3.fromRGB(48,54,72),
            Border = Color3.fromRGB(42,47,64), BorderLight = Color3.fromRGB(70,78,100),
            Text = Color3.fromRGB(238,241,248), TextDim = Color3.fromRGB(160,168,188),
            Subtle = Color3.fromRGB(100,108,128),
            Accent = Color3.fromRGB(120,162,255), AccentBright = Color3.fromRGB(160,195,255),
            AccentDim = Color3.fromRGB(70,105,200), AccentDeep = Color3.fromRGB(85,75,220),
            AccentCyan = Color3.fromRGB(110,220,245),
            Risky = Color3.fromRGB(245,105,120), RiskyDim = Color3.fromRGB(170,60,75),
            ToggleOff = Color3.fromRGB(48,52,68),
            Success = Color3.fromRGB(95,215,135), Warning = Color3.fromRGB(255,185,95),
            Tooltip = Color3.fromRGB(10,11,15), Shadow = Color3.new(0,0,0),
        },
        Midnight = {
            Background = Color3.fromRGB(5,6,10), BackgroundAlt = Color3.fromRGB(8,10,16),
            Sidebar = Color3.fromRGB(7,9,14), SidebarHi = Color3.fromRGB(12,14,22),
            Header = Color3.fromRGB(10,12,18), Surface = Color3.fromRGB(14,16,24),
            SurfaceAlt = Color3.fromRGB(20,23,33), SurfaceHi = Color3.fromRGB(28,32,44),
            Border = Color3.fromRGB(22,25,36), BorderLight = Color3.fromRGB(45,50,65),
            Text = Color3.fromRGB(230,235,245), TextDim = Color3.fromRGB(140,150,170),
            Subtle = Color3.fromRGB(85,92,110),
            Accent = Color3.fromRGB(140,180,255), AccentBright = Color3.fromRGB(180,210,255),
            AccentDim = Color3.fromRGB(80,115,195), AccentDeep = Color3.fromRGB(60,85,175),
            AccentCyan = Color3.fromRGB(95,195,230),
            Risky = Color3.fromRGB(245,105,120), RiskyDim = Color3.fromRGB(170,60,75),
            ToggleOff = Color3.fromRGB(30,33,45),
            Success = Color3.fromRGB(95,215,135), Warning = Color3.fromRGB(255,185,95),
            Tooltip = Color3.fromRGB(0,0,0), Shadow = Color3.new(0,0,0),
        },
        Crimson = {
            Background = Color3.fromRGB(24,10,14), BackgroundAlt = Color3.fromRGB(32,14,18),
            Sidebar = Color3.fromRGB(28,12,16), SidebarHi = Color3.fromRGB(44,20,26),
            Header = Color3.fromRGB(36,16,22), Surface = Color3.fromRGB(48,22,28),
            SurfaceAlt = Color3.fromRGB(64,30,38), SurfaceHi = Color3.fromRGB(82,40,50),
            Border = Color3.fromRGB(70,32,40), BorderLight = Color3.fromRGB(120,55,70),
            Text = Color3.fromRGB(250,235,235), TextDim = Color3.fromRGB(215,170,175),
            Subtle = Color3.fromRGB(145,100,110),
            Accent = Color3.fromRGB(255,75,90), AccentBright = Color3.fromRGB(255,120,130),
            AccentDim = Color3.fromRGB(210,50,70), AccentDeep = Color3.fromRGB(165,30,50),
            AccentCyan = Color3.fromRGB(255,145,145),
            Risky = Color3.fromRGB(255,165,60), RiskyDim = Color3.fromRGB(180,110,40),
            ToggleOff = Color3.fromRGB(64,28,36),
            Success = Color3.fromRGB(130,220,130), Warning = Color3.fromRGB(255,200,110),
            Tooltip = Color3.fromRGB(12,4,6), Shadow = Color3.new(0,0,0),
        },
    }

    local _savedThemeName = "Jungle"
    do
        local execFn = function(name)
            return rawget(getfenv(0), name)
                or (type(getgenv) == "function" and getgenv()[name])
                or rawget(_G, name)
        end
        local rf = execFn("readfile")
        if type(rf) == "function" then
            local ok, content = pcall(function() return rf("JurassicBlockyFramework_Theme.txt") end)
            if ok and type(content) == "string" then
                local name = content:gsub("%s+", "")
                if THEME_PRESETS[name] then _savedThemeName = name end
            end
        end
    end

    local THEME = {}
    for k, v in pairs(THEME_PRESETS[_savedThemeName]) do THEME[k] = v end
    local _currentThemeName = _savedThemeName
    local function setThemeNamed(name: string): (boolean, string?)
        local preset = THEME_PRESETS[name]
        if not preset then return false, "no such theme" end
        for k, v in pairs(preset) do THEME[k] = v end
        _currentThemeName = name
        local execFn = function(n)
            return rawget(getfenv(0), n)
                or (type(getgenv) == "function" and getgenv()[n])
                or rawget(_G, n)
        end
        local wf = execFn("writefile")
        if type(wf) == "function" then pcall(function() wf("JurassicBlockyFramework_Theme.txt", name) end) end
        return true
    end

    local TS = game:GetService("TweenService")
    local QUICK  = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local MEDIUM = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function px(n) return UDim.new(0, n) end
    local function create(class: string, props: {[string]: any}?, children: {Instance}?): Instance
        local inst = Instance.new(class)
        if props then for k, v in pairs(props) do (inst :: any)[k] = v end end
        if children then for _, c in ipairs(children) do c.Parent = inst end end
        return inst
    end
    local function corner(parent: Instance, radius: number)
        create("UICorner", { CornerRadius = px(radius), Parent = parent })
    end
    local function stroke(parent: Instance, color: Color3, thickness: number?, transparency: number?)
        return create("UIStroke", {
            Color = color, Thickness = thickness or 1, Transparency = transparency or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent,
        }) :: UIStroke
    end
    local function pad(parent: Instance, p: number, lr: number?)
        create("UIPadding", {
            PaddingTop = px(p), PaddingBottom = px(p),
            PaddingLeft = px(lr or p), PaddingRight = px(lr or p), Parent = parent,
        })
    end
    local function vlayout(parent: Instance, gap: number?, align: any?)
        return create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = align or Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder, Padding = px(gap or 6), Parent = parent,
        }) :: UIListLayout
    end
    local function tween(obj: any, props: {[string]: any}, info: TweenInfo?)
        if not obj then return nil end
        local ok, t = pcall(function() return TS:Create(obj, info or QUICK, props) end)
        if not ok or not t then return nil end
        pcall(function() t:Play() end); return t
    end

    local function accentGradient(parent: Instance, vertical: boolean?)
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   THEME.Accent),
            ColorSequenceKeypoint.new(0.5, THEME.AccentCyan),
            ColorSequenceKeypoint.new(1,   THEME.AccentDeep),
        })
        g.Rotation = vertical and 90 or 0; g.Parent = parent
        return g
    end
    local function depthGradient(parent: Instance, top: Color3, bottom: Color3)
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, top), ColorSequenceKeypoint.new(1, bottom) })
        g.Rotation = 90; g.Parent = parent
        return g
    end
    local function parentToBest(gui: Instance)
        local g: any = _G
        local container: any
        if type(g.gethui) == "function" then
            local ok, h = pcall(g.gethui); if ok and h then container = h end
        end
        if not container then
            local ok, h = pcall(function() return CoreGui end); if ok and h then container = h end
        end
        if not container then container = LocalPlayer:WaitForChild("PlayerGui") end
        gui.Parent = container
    end

    local Library: any = {}
    Library.Toggles = {}
    Library.Options = {}
    Library.Unloaded = false
    Library.NotifySide = "Right"
    Library.ShowCustomCursor = false
    Library.ForceCheckbox = false
    Library.ShowToggleFrameInKeybinds = true
    Library.MinimizeKey = Enum.KeyCode.RightControl
    Library.ToggleKeybind = nil
    Library._unloadHooks = {}
    Library._dpi = 1
    Library._connections = {}
    Library._searchable = {} :: {{label: string, row: Instance, parentTab: string}}
    Library._activeTab = nil
    Library._ThemePresets = THEME_PRESETS
    Library.CurrentTheme = _currentThemeName
    function Library:SetTheme(name)
        local ok, err = setThemeNamed(name)
        if ok then Library.CurrentTheme = _currentThemeName end
        return ok, err
    end
    function Library:_track(conn) table.insert(self._connections, conn); return conn end
    function Library:OnUnload(fn) table.insert(self._unloadHooks, fn) end
    function Library:Unload()
        if self.Unloaded then return end
        self.Unloaded = true
        Alive.value = false
        for _, fn in ipairs(self._unloadHooks) do pcall(fn) end
        for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
        if self._gui  then pcall(function() self._gui:Destroy()  end) end
        if self._note then pcall(function() self._note:Destroy() end) end
    end
    function Library:SetNotifySide(side) self.NotifySide = side end
    function Library:SetDPIScale(n) self._dpi = (n or 100) / 100; if self._uiScale then self._uiScale.Scale = self._dpi end end

    -- Notification dock
    local NOTIFY_WIDTH = 240
    local function buildNotifyGui()
        local g = create("ScreenGui", {
            Name = "JurassicBlocky_Notify_" .. _RAND_SUFFIX, ResetOnSpawn = false,
            IgnoreGuiInset = true, DisplayOrder = 100,
        })
        local stack = create("Frame", {
            AnchorPoint = Vector2.new(1,1), Position = UDim2.new(1,-12,1,-12),
            Size = UDim2.new(0, NOTIFY_WIDTH, 1, -24), BackgroundTransparency = 1, Parent = g,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            SortOrder = Enum.SortOrder.LayoutOrder, Padding = px(6), Parent = stack,
        })
        Library._noteStack = stack
        parentToBest(g); Library._note = g
    end
    function Library:Notify(opts)
        if type(opts) == "string" then opts = { Title = "NameHub", Description = opts } end
        local title = opts.Title or "Notice"
        local desc  = opts.Description or opts.Content or ""
        local dur   = opts.Time or 4
        if not self._noteStack then buildNotifyGui() end
        local isLeft = (self.NotifySide == "Left")
        local stack: any = self._noteStack
        if isLeft then
            stack.AnchorPoint = Vector2.new(0,1); stack.Position = UDim2.new(0,12,1,-12)
            local L = stack:FindFirstChildWhichIsA("UIListLayout")
            if L then (L :: any).HorizontalAlignment = Enum.HorizontalAlignment.Left end
        else
            stack.AnchorPoint = Vector2.new(1,1); stack.Position = UDim2.new(1,-12,1,-12)
            local R = stack:FindFirstChildWhichIsA("UIListLayout")
            if R then (R :: any).HorizontalAlignment = Enum.HorizontalAlignment.Right end
        end
        local frame = create("Frame", {
            Size = UDim2.new(0, NOTIFY_WIDTH, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = THEME.Surface, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = self._noteStack,
        })
        corner(frame, 6); stroke(frame, THEME.Border, 1, 0.3); pad(frame, 8)
        create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = px(2), Parent = frame })
        local titleLbl = create("TextLabel", {
            Size = UDim2.new(1,0,0,16), BackgroundTransparency = 1, TextTransparency = 1,
            Font = Enum.Font.GothamSemibold, TextSize = 13, Text = title,
            TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame, LayoutOrder = 1,
        })
        local descLbl = create("TextLabel", {
            Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, TextTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 11, Text = desc, TextWrapped = true,
            TextColor3 = THEME.TextDim, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame, LayoutOrder = 2,
        })
        tween(frame,    {BackgroundTransparency = 0}, MEDIUM)
        tween(titleLbl, {TextTransparency = 0}, MEDIUM)
        tween(descLbl,  {TextTransparency = 0}, MEDIUM)
        task.delay(dur, function()
            if frame and frame.Parent then
                tween(frame,    {BackgroundTransparency = 1}, QUICK)
                tween(titleLbl, {TextTransparency = 1}, QUICK)
                tween(descLbl,  {TextTransparency = 1}, QUICK)
                task.wait(0.14); frame:Destroy()
            end
        end)
    end

    local TAB_ICONS = {
        Main = "M", Player = "P", Visuals = "V", Misc = "+",
        Missions = "!", Teleport = "T", Stats = "S", Settings = "*",
    }
    local function iconFor(name: string): string
        return TAB_ICONS[name] or (name:sub(1, 1):upper())
    end

    function Library:CreateWindow(opts: {[string]: any})
        opts = opts or {}
        local titleText  = opts.Title  or "NameHub"
        local footerText = opts.Footer or ""
        self.NotifySide  = opts.NotifySide or "Right"

        local gui = create("ScreenGui", {
            Name = "JurassicBlocky_UI_" .. _RAND_SUFFIX, ResetOnSpawn = false,
            IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 10,
        })
        self._gui = gui
        local scale = create("UIScale", { Scale = self._dpi, Parent = gui }) :: UIScale
        self._uiScale = scale

        local shadowOuter = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,30),
            Size = UDim2.new(0,980,0,680), BackgroundTransparency = 1,
            Image = "rbxassetid://5028857084", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.55,
            ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24,24,276,276), Parent = gui,
        })
        local shadow = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,14),
            Size = UDim2.new(0,940,0,660), BackgroundTransparency = 1,
            Image = "rbxassetid://5028857084", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.3,
            ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24,24,276,276), Parent = gui,
        })
        local glow = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(0,920,0,640), BackgroundTransparency = 1,
            Image = "rbxassetid://5028857084", ImageColor3 = THEME.Accent, ImageTransparency = 0.78,
            ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24,24,276,276), Parent = gui,
        })

        local root = create("Frame", {
            Name = "Window", AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(0,880,0,600), BackgroundColor3 = THEME.Background,
            BorderSizePixel = 0, ClipsDescendants = true, Parent = gui,
        })
        corner(root, 16); depthGradient(root, THEME.BackgroundAlt, THEME.Background); stroke(root, THEME.Border, 1)
        create("UIStroke", {
            Color = THEME.BorderLight, Thickness = 1, Transparency = 0.6,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = root,
        })
        local topStripe = create("Frame", {
            Size = UDim2.new(1,0,0,3), BackgroundColor3 = THEME.Accent,
            BorderSizePixel = 0, ZIndex = 5, Parent = root,
        })
        accentGradient(topStripe)

        local header = create("Frame", {
            Position = UDim2.new(0,0,0,3), Size = UDim2.new(1,0,0,54),
            BackgroundColor3 = THEME.Header, BorderSizePixel = 0, Parent = root,
        })
        depthGradient(header, THEME.Header, THEME.Background)
        local headerDiv = create("Frame", {
            Position = UDim2.new(0,0,1,-1), Size = UDim2.new(1,0,0,1),
            BackgroundColor3 = THEME.Border, BorderSizePixel = 0, Parent = header,
        })
        local headerDivGrad = accentGradient(headerDiv)
        ;(headerDivGrad :: any).Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.2), NumberSequenceKeypoint.new(1, 1),
        })

        local titleHolder = create("Frame", {
            Position = UDim2.new(0,14,0,0), Size = UDim2.new(0,200,1,0),
            BackgroundTransparency = 1, Parent = header,
        })
        create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0,19,0.5,0),
            Size = UDim2.new(0,48,0,48), BackgroundTransparency = 1,
            Image = "rbxassetid://5028857084", ImageColor3 = THEME.Accent, ImageTransparency = 0.55,
            ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24,24,276,276), Parent = titleHolder, ZIndex = 0,
        })
        local logoDot = create("Frame", {
            AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0,4,0.5,0),
            Size = UDim2.new(0,28,0,28), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0,
            Parent = titleHolder, ZIndex = 2,
        })
        corner(logoDot, 14); accentGradient(logoDot)
        local titleLbl = create("TextLabel", {
            Position = UDim2.new(0,44,0,0), Size = UDim2.new(1,-44,1,0),
            BackgroundTransparency = 1, Text = titleText, TextColor3 = THEME.Text,
            Font = Enum.Font.GothamBold, TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = titleHolder,
        })
        titleHolder.Size = UDim2.new(0, 48 + titleLbl.TextBounds.X + 14, 1, 0)

        local searchBox = create("Frame", {
            AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0,220,0.5,0),
            Size = UDim2.new(1,-390,0,32), BackgroundColor3 = THEME.Surface,
            BorderSizePixel = 0, Parent = header,
        })
        corner(searchBox, 8); local searchStroke = stroke(searchBox, THEME.Border, 1, 0.3)
        local iconHolder = create("Frame", {
            Position = UDim2.new(0,10,0.5,-6), Size = UDim2.new(0,12,0,12),
            BackgroundTransparency = 1, Parent = searchBox,
        })
        local iconCircle = create("Frame", {
            Size = UDim2.new(0,8,0,8), Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1, BorderSizePixel = 0, Parent = iconHolder,
        })
        corner(iconCircle, 4); stroke(iconCircle, THEME.TextDim, 1.5)
        create("Frame", {
            Position = UDim2.new(0,7,0,7), Size = UDim2.new(0,4,0,1.5),
            BackgroundColor3 = THEME.TextDim, BorderSizePixel = 0, Rotation = 45, Parent = iconHolder,
        })
        local searchInput = create("TextBox", {
            Position = UDim2.new(0,30,0,0), Size = UDim2.new(1,-36,1,0),
            BackgroundTransparency = 1, Text = "", PlaceholderText = "Search features...",
            Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = THEME.Text,
            PlaceholderColor3 = THEME.Subtle, ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = searchBox,
        }) :: TextBox
        searchInput.Focused:Connect(function()
            tween(searchStroke, {Color = THEME.Accent, Transparency = 0})
            tween(searchBox,    {BackgroundColor3 = THEME.SurfaceAlt})
        end)
        searchInput.FocusLost:Connect(function()
            tween(searchStroke, {Color = THEME.Border, Transparency = 0.3})
            tween(searchBox,    {BackgroundColor3 = THEME.Surface})
        end)
        local dragHandle = create("TextLabel", {
            AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-16,0.5,0),
            Size = UDim2.new(0,80,1,0), BackgroundTransparency = 1, Text = ":: drag",
            Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = THEME.Subtle,
            TextXAlignment = Enum.TextXAlignment.Right, Parent = header,
        })

        searchInput:GetPropertyChangedSignal("Text"):Connect(function()
            local q = searchInput.Text:lower()
            for _, entry in ipairs(Library._searchable) do
                local matchTab = (entry.parentTab == Library._activeTab) or (entry.parentTab == nil)
                if q == "" then entry.row.Visible = true
                else entry.row.Visible = matchTab and (entry.label:lower():find(q, 1, true) ~= nil) end
            end
        end)

        local body = create("Frame", {
            Position = UDim2.new(0,0,0,57), Size = UDim2.new(1,0,1,-77),
            BackgroundTransparency = 1, Parent = root,
        })
        local sidebar = create("Frame", {
            Size = UDim2.new(0,160,1,0), BackgroundColor3 = THEME.Sidebar,
            BorderSizePixel = 0, Parent = body,
        })
        depthGradient(sidebar, THEME.SidebarHi, THEME.Sidebar)
        create("Frame", {
            Position = UDim2.new(1,-1,0,0), Size = UDim2.new(0,1,1,0),
            BackgroundColor3 = THEME.Border, BorderSizePixel = 0, ZIndex = 2, Parent = sidebar,
        })
        local tabsHost = create("Frame", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ZIndex = 2, Parent = sidebar,
        })
        pad(tabsHost, 12, 10); vlayout(tabsHost, 4, Enum.HorizontalAlignment.Left)
        local activeIndicator = create("Frame", {
            Position = UDim2.new(0,4,0,12), Size = UDim2.new(0,3,0,30),
            BackgroundColor3 = THEME.Accent, BorderSizePixel = 0, Visible = false,
            ZIndex = 5, Parent = sidebar,
        })
        corner(activeIndicator, 2); accentGradient(activeIndicator, true)

        local content = create("Frame", {
            Position = UDim2.new(0,160,0,0), Size = UDim2.new(1,-160,1,0),
            BackgroundTransparency = 1, Parent = body,
        })
        local footer = create("TextLabel", {
            Position = UDim2.new(0,0,1,-20), Size = UDim2.new(1,0,0,20),
            BackgroundTransparency = 1, Text = footerText, TextColor3 = THEME.Subtle,
            Font = Enum.Font.Gotham, TextSize = 11, Parent = root,
        })

        local function makeWinBtn(text, x, normal, hover)
            local b = create("TextButton", {
                AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,x,0.5,0),
                Size = UDim2.new(0,20,0,20), BackgroundColor3 = normal, BorderSizePixel = 0,
                Text = text, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = THEME.Text,
                AutoButtonColor = false, Parent = header,
            }) :: TextButton
            corner(b, 4)
            b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = hover}) end)
            b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = normal}) end)
            return b
        end
        local closeBtn = makeWinBtn("X", -100, THEME.RiskyDim, THEME.Risky)
        local minBtn   = makeWinBtn("-", -124, THEME.Surface,  THEME.SurfaceAlt)
        closeBtn.MouseButton1Click:Connect(function() Library:Unload() end)
        dragHandle.Size = UDim2.new(0,50,1,0); dragHandle.Position = UDim2.new(1,-154,0.5,0)

        local dragging, dragStart, startPos = false, Vector2.new(), root.Position
        local function bindDrag(target)
            target.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; dragStart = input.Position; startPos = root.Position
                end
            end)
            target.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end
        bindDrag(header)
        Library:_track(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                root.Position = newPos
                shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset, newPos.Y.Scale, newPos.Y.Offset + 8)
            end
        end))

        local Window: any = { Tabs = {}, _activeTab = nil }
        Window._root = root; Window._sidebar = sidebar; Window._content = content

        local function moveIndicator(targetRow)
            if not targetRow then activeIndicator.Visible = false; return end
            activeIndicator.Visible = true
            local rel = targetRow.AbsolutePosition - sidebar.AbsolutePosition
            tween(activeIndicator, {
                Position = UDim2.new(0,4,0, rel.Y + 4),
                Size = UDim2.new(0,3,0, math.max(targetRow.AbsoluteSize.Y - 8, 18)),
            })
        end

        local function selectTab(name)
            for tn, t in pairs(Window.Tabs) do
                local active = (tn == name)
                t._page.Visible = active
                if t._row then
                    tween(t._row, {
                        BackgroundColor3 = active and THEME.SurfaceAlt or THEME.Surface,
                        BackgroundTransparency = active and 0 or 0.55,
                    })
                end
                if t._icon then tween(t._icon, {TextColor3 = active and THEME.Accent or THEME.TextDim}) end
                if t._name then tween(t._name, {TextColor3 = active and THEME.Accent or THEME.Text}) end
                if active then moveIndicator(t._row) end
            end
            Window._activeTab = name
            Library._activeTab = name
            if searchInput.Text ~= "" then
                local q = searchInput.Text:lower()
                for _, entry in ipairs(Library._searchable) do
                    local matchTab = (entry.parentTab == name) or (entry.parentTab == nil)
                    entry.row.Visible = matchTab and (entry.label:lower():find(q, 1, true) ~= nil)
                end
            end
        end

        function Window:AddTab(name: string, _icon: string?)
            local row = create("Frame", {
                Size = UDim2.new(1,0,0,34), BackgroundColor3 = THEME.Surface,
                BackgroundTransparency = 0.75, BorderSizePixel = 0, ZIndex = 3, Parent = tabsHost,
            })
            corner(row, 8)
            local btn = create("TextButton", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                Text = "", AutoButtonColor = false, ZIndex = 4, Parent = row,
            }) :: TextButton
            local iconLbl = create("TextLabel", {
                Position = UDim2.new(0,14,0,0), Size = UDim2.new(0,20,1,0),
                BackgroundTransparency = 1, Text = iconFor(name),
                Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = THEME.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = row,
            })
            local nameLbl = create("TextLabel", {
                Position = UDim2.new(0,38,0,0), Size = UDim2.new(1,-40,1,0),
                BackgroundTransparency = 1, Text = name,
                Font = Enum.Font.GothamSemibold, TextSize = 13, TextColor3 = THEME.Text,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = row,
            })
            btn.MouseEnter:Connect(function() if Window._activeTab ~= name then tween(row, {BackgroundTransparency = 0.5}, QUICK) end end)
            btn.MouseLeave:Connect(function() if Window._activeTab ~= name then tween(row, {BackgroundTransparency = 0.75}, QUICK) end end)

            local page = create("Frame", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, Parent = content,
            })
            pad(page, 12, 16)

            local left = create("ScrollingFrame", {
                Size = UDim2.new(0.5,-8,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
                CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.BorderLight, Parent = page,
            })
            vlayout(left, 12, Enum.HorizontalAlignment.Center); pad(left, 0, 2)
            local right = create("ScrollingFrame", {
                Position = UDim2.new(0.5,8,0,0), Size = UDim2.new(0.5,-8,1,0),
                BackgroundTransparency = 1, BorderSizePixel = 0,
                CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.BorderLight, Parent = page,
            })
            vlayout(right, 12, Enum.HorizontalAlignment.Center); pad(right, 0, 2)

            local tab: any = { _btn = btn, _icon = iconLbl, _name = nameLbl,
                _page = page, _row = row, _left = left, _right = right, _tabName = name }

            local function makeGroupHeader(parent: Instance, gname: string)
                local outer = create("Frame", {
                    Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = THEME.Surface, BorderSizePixel = 0,
                    BackgroundTransparency = 0.15, Parent = parent,
                })
                corner(outer, 10); stroke(outer, THEME.Border, 1, 0.4)
                create("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new(THEME.Surface, THEME.BackgroundAlt),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.05),
                        NumberSequenceKeypoint.new(1, 0.35),
                    }),
                    Parent = outer,
                })
                create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = outer, Padding = px(6) })
                pad(outer, 10, 12)
                local headerRow = create("Frame", { Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Parent = outer, LayoutOrder = 1 })
                local dot = create("Frame", {
                    AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0,0,0.5,0),
                    Size = UDim2.new(0,7,0,7), BackgroundColor3 = THEME.Accent,
                    BorderSizePixel = 0, Parent = headerRow,
                })
                corner(dot, 4); accentGradient(dot)
                create("TextLabel", {
                    Position = UDim2.new(0,16,0,0), Size = UDim2.new(1,-16,1,0),
                    BackgroundTransparency = 1, Text = gname,
                    Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.Text,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = headerRow,
                })
                local underline = create("Frame", {
                    Size = UDim2.new(1,0,0,1), BackgroundColor3 = THEME.Border,
                    BorderSizePixel = 0, Parent = outer, LayoutOrder = 2,
                })
                local ug = accentGradient(underline)
                ;(ug :: any).Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.7, 0.6),
                    NumberSequenceKeypoint.new(1, 1),
                })
                local bodyFrame = create("Frame", {
                    Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1, Parent = outer, LayoutOrder = 3,
                })
                vlayout(bodyFrame, 7, Enum.HorizontalAlignment.Center)
                return JBUI._makeContainer(outer, bodyFrame, name)
            end
            local function makeTabbox(parent: Instance)
                local outer = create("Frame", {
                    Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1, Parent = parent,
                })
                create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = outer, Padding = px(4) })
                local tabRow = create("Frame", { Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Parent = outer, LayoutOrder = 1 })
                create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal, Padding = px(14),
                    SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabRow,
                })
                local bodyArea = create("Frame", {
                    Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1, Parent = outer, LayoutOrder = 2,
                })
                vlayout(bodyArea, 6, Enum.HorizontalAlignment.Center)
                local tabbox: any = { _subTabs = {}, _activeSubtab = nil }
                local function selectSubTab(sname)
                    for n, st in pairs(tabbox._subTabs) do
                        local active = (n == sname)
                        st._page.Visible = active
                        tween(st._btn, {TextColor3 = active and THEME.Accent or THEME.TextDim})
                    end
                    tabbox._activeSubtab = sname
                end
                function tabbox:AddTab(stname: string)
                    local b = create("TextButton", {
                        Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1, AutoButtonColor = false,
                        Text = stname, Font = Enum.Font.GothamSemibold, TextSize = 13,
                        TextColor3 = THEME.TextDim, Parent = tabRow,
                    }) :: TextButton
                    local stPage = create("Frame", {
                        Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1, Visible = false, Parent = bodyArea,
                    })
                    vlayout(stPage, 6, Enum.HorizontalAlignment.Center)
                    local subtab = JBUI._makeContainer(outer, stPage, name)
                    subtab._btn = b; subtab._page = stPage
                    tabbox._subTabs[stname] = subtab
                    b.MouseButton1Click:Connect(function() selectSubTab(stname) end)
                    if tabbox._activeSubtab == nil then selectSubTab(stname) end
                    return subtab
                end
                return tabbox
            end
            function tab:AddLeftGroupbox(gn: string, _i: string?)  return makeGroupHeader(left,  gn) end
            function tab:AddRightGroupbox(gn: string, _i: string?) return makeGroupHeader(right, gn) end
            function tab:AddLeftGroupBox(gn: string, _i: string?)  return makeGroupHeader(left,  gn) end
            function tab:AddRightGroupBox(gn: string, _i: string?) return makeGroupHeader(right, gn) end
            function tab:AddLeftTabbox()  return makeTabbox(left)  end
            function tab:AddRightTabbox() return makeTabbox(right) end

            Window.Tabs[name] = tab
            btn.MouseButton1Click:Connect(function() selectTab(name) end)
            if not Window._activeTab then task.defer(function() selectTab(name) end) end
            return tab
        end

        local minimized = false
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            body.Visible = not minimized; footer.Visible = not minimized
            tween(root,   {Size = minimized and UDim2.new(0,800,0,44) or UDim2.new(0,800,0,520)}, MEDIUM)
            tween(shadow, {ImageTransparency = minimized and 0.75 or 0.5})
        end)

        Library:_track(UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            local kc = Library.ToggleKeybind and Library.ToggleKeybind.Value
            if kc and input.KeyCode == Enum.KeyCode[tostring(kc)] then gui.Enabled = not gui.Enabled
            elseif (not kc) and input.KeyCode == Library.MinimizeKey then gui.Enabled = not gui.Enabled end
        end))

        parentToBest(gui)
        return Window
    end

    local Container: any = {}
    Container.__index = Container
    function JBUI._makeContainer(_outer: Instance, body: Instance, tabName: string?)
        return setmetatable({ _body = body, _tab = tabName }, Container)
    end

    local function registerSearchable(container, row, label)
        if container and container._tab then
            table.insert(Library._searchable, { label = label or "", row = row, parentTab = container._tab })
        end
    end
    local function rowFrame(parent: Instance, h: number?)
        return create("Frame", { Size = UDim2.new(1,0,0, h or 26), BackgroundTransparency = 1, Parent = parent })
    end

    function Container:AddToggle(idx: string, info: {[string]: any})
        info = info or {}
        local row = rowFrame(self._body, 28)
        local lbl = create("TextLabel", {
            Position = UDim2.new(0,4,0,0), Size = UDim2.new(1,-56,1,0),
            BackgroundTransparency = 1, Text = info.Text or idx,
            Font = Enum.Font.Gotham, TextSize = 13,
            TextColor3 = info.Risky and THEME.Risky or THEME.Text,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
        })
        local track = create("TextButton", {
            AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-4,0.5,0),
            Size = UDim2.new(0,40,0,20),
            BackgroundColor3 = info.Default and THEME.Accent or THEME.ToggleOff,
            BorderSizePixel = 0, AutoButtonColor = false, Text = "", Parent = row,
        }) :: TextButton
        corner(track, 10)
        local trackGrad = accentGradient(track)
        ;(trackGrad :: any).Transparency = NumberSequence.new(info.Default and 0 or 1)
        local trackGlow = stroke(track, THEME.Accent, 1.5, info.Default and 0.4 or 1)
        local knob = create("Frame", {
            AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0, info.Default and 22 or 2, 0.5, 0),
            Size = UDim2.new(0,16,0,16), BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0, Parent = track,
        })
        corner(knob, 8)
        local obj: any = { Value = info.Default or false, _changed = {}, _row = row, _label = lbl, Type = "Toggle" }
        function obj:OnChanged(fn) table.insert(self._changed, fn) end
        function obj:SetText(t) lbl.Text = t end
        function obj:SetValue(v)
            self.Value = v and true or false
            tween(track, {BackgroundColor3 = self.Value and THEME.Accent or THEME.ToggleOff})
            tween(knob,  {Position         = UDim2.new(0, self.Value and 22 or 2, 0.5, 0)})
            tween(trackGlow, {Transparency = self.Value and 0.4 or 1})
            ;(trackGrad :: any).Transparency = NumberSequence.new(self.Value and 0 or 1)
            if info.Callback then pcall(info.Callback, self.Value) end
            for _, fn in ipairs(self._changed) do pcall(fn, self.Value) end
        end
        function obj:AddKeyPicker(kpIdx, kpInfo)   return Container.AddKeyPicker({_body = row},   kpIdx, kpInfo, lbl) end
        function obj:AddColorPicker(cpIdx, cpInfo) return Container.AddColorPicker({_body = row}, cpIdx, cpInfo, lbl) end
        track.MouseButton1Click:Connect(function() obj:SetValue(not obj.Value) end)
        create("TextButton", {
            Size = UDim2.new(1,-50,1,0), BackgroundTransparency = 1, Text = "", Parent = row,
        }).MouseButton1Click:Connect(function() obj:SetValue(not obj.Value) end)
        Library.Toggles[idx] = obj
        registerSearchable(self, row, info.Text or idx)
        return obj
    end

    function Container:AddSlider(idx: string, info: {[string]: any})
        info = info or {}
        local mn, mx = info.Min or 0, info.Max or 100
        local rounding = info.Rounding or 0
        local function snap(v) local m = 10 ^ rounding; return math.floor(v * m + 0.5) / m end
        local row = rowFrame(self._body, 42)
        create("TextLabel", {
            Size = UDim2.new(1,-80,0,18), Position = UDim2.new(0,4,0,0),
            BackgroundTransparency = 1, Text = info.Text or idx,
            Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = THEME.Text,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
        })
        local valLbl = create("TextLabel", {
            AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-4,0,0),
            Size = UDim2.new(0,80,0,18), BackgroundTransparency = 1,
            Text = tostring(snap(info.Default or mn)) .. (info.Suffix or ""),
            Font = Enum.Font.GothamSemibold, TextSize = 13, TextColor3 = THEME.Accent,
            TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
        })
        local track = create("Frame", {
            Position = UDim2.new(0,4,0,24), Size = UDim2.new(1,-8,0,8),
            BackgroundColor3 = THEME.Surface, BorderSizePixel = 0, Parent = row,
        })
        corner(track, 4); stroke(track, THEME.Border, 1, 0.5)
        local fill = create("Frame", { Size = UDim2.new(0,0,1,0), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0, Parent = track })
        corner(fill, 4); accentGradient(fill)
        local handle = create("Frame", {
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0,0,0.5,0),
            Size = UDim2.new(0,16,0,16), BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0, ZIndex = 3, Parent = track,
        })
        corner(handle, 8); stroke(handle, THEME.AccentBright, 1.5, 0.1)

        local obj: any = { Value = info.Default or mn, _changed = {}, Type = "Slider", Min = mn, Max = mx }
        local function refresh()
            local frac = (obj.Value - mn) / math.max(mx - mn, 0.0001)
            local c = math.clamp(frac, 0, 1)
            fill.Size = UDim2.new(c, 0, 1, 0)
            handle.Position = UDim2.new(c, 0, 0.5, 0)
            valLbl.Text = tostring(snap(obj.Value)) .. (info.Suffix or "")
        end
        function obj:OnChanged(fn) table.insert(self._changed, fn) end
        function obj:SetValue(v)
            v = math.clamp(snap(v), mn, mx); self.Value = v; refresh()
            if info.Callback then pcall(info.Callback, v) end
            for _, fn in ipairs(self._changed) do pcall(fn, v) end
        end
        local sliding = false
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                local abs, sz = track.AbsolutePosition, track.AbsoluteSize
                obj:SetValue(mn + ((input.Position.X - abs.X) / sz.X) * (mx - mn))
            end
        end)
        track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
        Library:_track(UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local abs, sz = track.AbsolutePosition, track.AbsoluteSize
                obj:SetValue(mn + ((input.Position.X - abs.X) / sz.X) * (mx - mn))
            end
        end))
        refresh()
        Library.Options[idx] = obj
        registerSearchable(self, row, info.Text or idx)
        return obj
    end

    function Container:AddDropdown(idx: string, info: {[string]: any})
        info = info or {}
        local multi = info.Multi == true
        local values: {string} = info.Values or {}
        local row = rowFrame(self._body, 46)
        create("TextLabel", {
            Position = UDim2.new(0,4,0,0), Size = UDim2.new(1,-8,0,16),
            BackgroundTransparency = 1, Text = info.Text or idx,
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
        })
        local btn = create("TextButton", {
            Position = UDim2.new(0,4,0,20), Size = UDim2.new(1,-8,0,24),
            BackgroundColor3 = THEME.Surface, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false, Parent = row,
        }) :: TextButton
        corner(btn, 6); stroke(btn, THEME.Border, 1, 0.4)
        local valLbl = create("TextLabel", {
            Size = UDim2.new(1,-22,1,0), Position = UDim2.new(0,12,0,0),
            BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.Text,
            TextXAlignment = Enum.TextXAlignment.Center, Parent = btn,
        })
        create("TextLabel", {
            AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-8,0.5,0),
            Size = UDim2.new(0,16,0,16), BackgroundTransparency = 1, Text = "v",
            Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = THEME.TextDim, Parent = btn,
        })
        local obj: any = { Type = "Dropdown", _changed = {}, Values = values, Multi = multi }
        if multi then obj.Value = (type(info.Default) == "table") and info.Default or {}
        else obj.Value = info.Default or (values[1] or "") end
        local function display()
            if multi then
                local picked = {}
                for k, v in pairs(obj.Value) do if v then table.insert(picked, k) end end
                if #picked == 0 then valLbl.Text = "---" else valLbl.Text = table.concat(picked, ", ") end
            else valLbl.Text = tostring(obj.Value) end
        end
        display()
        function obj:OnChanged(fn) table.insert(self._changed, fn) end
        function obj:SetValue(v)
            self.Value = v; display()
            if info.Callback then pcall(info.Callback, v) end
            for _, fn in ipairs(self._changed) do pcall(fn, v) end
        end
        function obj:SetValues(nv)
            self.Values = nv or {}; values = self.Values
            if not multi and not table.find(values, self.Value) then self.Value = values[1] or "" end
            display()
        end
        local popup
        local function closePopup() if popup then popup:Destroy(); popup = nil end end
        btn.MouseButton1Click:Connect(function()
            if popup then closePopup() return end
            popup = create("Frame", {
                Size = UDim2.new(0, btn.AbsoluteSize.X, 0, math.min(#values * 24 + 8, 200)),
                Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 2),
                BackgroundColor3 = THEME.Header, BorderSizePixel = 0, ZIndex = 50, Parent = Library._gui,
            })
            corner(popup :: any, 6); stroke(popup :: any, THEME.BorderLight, 1, 0.3)
            local scroll = create("ScrollingFrame", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
                ScrollBarThickness = 3, ZIndex = 51,
                CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = popup,
            })
            vlayout(scroll, 0, Enum.HorizontalAlignment.Center); pad(scroll, 3, 3)
            for _, v in ipairs(values) do
                local item = create("TextButton", {
                    Size = UDim2.new(1,0,0,22), BackgroundColor3 = THEME.Surface, BorderSizePixel = 0,
                    Text = tostring(v), Font = Enum.Font.Gotham, TextSize = 12,
                    TextColor3 = THEME.Text, ZIndex = 52, AutoButtonColor = false, Parent = scroll,
                }) :: TextButton
                corner(item, 4)
                if multi and obj.Value[v] then item.BackgroundColor3 = THEME.Accent end
                item.MouseEnter:Connect(function() tween(item, {BackgroundColor3 = multi and obj.Value[v] and THEME.Accent or THEME.SurfaceAlt}) end)
                item.MouseLeave:Connect(function() tween(item, {BackgroundColor3 = multi and obj.Value[v] and THEME.Accent or THEME.Surface}) end)
                item.MouseButton1Click:Connect(function()
                    if multi then
                        obj.Value[v] = not obj.Value[v]
                        item.BackgroundColor3 = obj.Value[v] and THEME.Accent or THEME.Surface
                        display(); if info.Callback then pcall(info.Callback, obj.Value) end
                        for _, fn in ipairs(obj._changed) do pcall(fn, obj.Value) end
                    else obj:SetValue(v); closePopup() end
                end)
            end
        end)
        Library.Options[idx] = obj
        registerSearchable(self, row, info.Text or idx)
        return obj
    end

    function Container:AddInput(idx: string, info: {[string]: any})
        info = info or {}
        local row = rowFrame(self._body, 46)
        create("TextLabel", {
            Position = UDim2.new(0,4,0,0), Size = UDim2.new(1,-8,0,16),
            BackgroundTransparency = 1, Text = info.Text or idx,
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
        })
        local input = create("TextBox", {
            Position = UDim2.new(0,4,0,20), Size = UDim2.new(1,-8,0,24),
            BackgroundColor3 = THEME.Surface, BorderSizePixel = 0, ClearTextOnFocus = false,
            Text = tostring(info.Default or ""), PlaceholderText = tostring(info.Placeholder or ""),
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.Text,
            PlaceholderColor3 = THEME.TextDim, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
        }) :: TextBox
        corner(input, 6); stroke(input, THEME.Border, 1, 0.4)
        create("UIPadding", { PaddingLeft = px(8), PaddingRight = px(8), Parent = input })
        local obj: any = { Value = tostring(info.Default or ""), _changed = {}, Type = "Input" }
        function obj:OnChanged(fn) table.insert(self._changed, fn) end
        function obj:SetValue(v) self.Value = tostring(v); input.Text = self.Value end
        input:GetPropertyChangedSignal("Text"):Connect(function()
            if info.Numeric then input.Text = input.Text:gsub("[^%-%.%d]", "") end
            obj.Value = input.Text
            if info.Callback then pcall(info.Callback, obj.Value) end
            for _, fn in ipairs(obj._changed) do pcall(fn, obj.Value) end
        end)
        Library.Options[idx] = obj
        registerSearchable(self, row, info.Text or idx)
        return obj
    end

    function Container:AddButton(info: {[string]: any})
        info = info or {}
        local row = rowFrame(self._body, 30)
        local baseCol  = info.Risky and THEME.RiskyDim or THEME.Surface
        local hoverCol = info.Risky and THEME.Risky    or THEME.SurfaceAlt
        local b = create("TextButton", {
            Size = UDim2.new(1,-8,1,-2), Position = UDim2.new(0,4,0,0),
            BackgroundColor3 = baseCol, BorderSizePixel = 0,
            Text = info.Text or "Button", Font = Enum.Font.GothamSemibold, TextSize = 12,
            TextColor3 = THEME.Text, AutoButtonColor = false, Parent = row,
        }) :: TextButton
        corner(b, 6); stroke(b, info.Risky and THEME.Risky or THEME.Border, 1, 0.4)
        b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = hoverCol}) end)
        b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = baseCol}) end)
        local clicks = 0
        b.MouseButton1Click:Connect(function()
            if info.DoubleClick then
                clicks += 1
                if clicks == 1 then
                    local original = b.Text; b.Text = "Click again to confirm"
                    task.delay(2, function() if clicks == 1 then clicks = 0; b.Text = original end end)
                    return
                end
                clicks = 0
            end
            if info.Func then pcall(info.Func) end
        end)
        local obj: any = { Type = "Button", _btn = b }
        function obj:SetText(t) b.Text = t end
        registerSearchable(self, row, info.Text or "")
        return obj
    end

    function Container:AddKeyPicker(idx: string, info: {[string]: any}, attachLabel: Instance?)
        info = info or {}
        local parent = self._body
        local row
        if attachLabel then
            row = create("Frame", {
                AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-4,0.5,0),
                Size = UDim2.new(0,64,0,18), BackgroundTransparency = 1, Parent = parent,
            })
        else
            row = rowFrame(parent, 26)
            create("TextLabel", {
                Position = UDim2.new(0,4,0,0), Size = UDim2.new(1,-80,1,0),
                BackgroundTransparency = 1, Text = info.Text or idx,
                Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = THEME.Text,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
            })
        end
        local btn = create("TextButton", {
            AnchorPoint = Vector2.new(1,0.5),
            Position = attachLabel and UDim2.new(1,0,0.5,0) or UDim2.new(1,-4,0.5,0),
            Size = UDim2.new(0,64,0,20), BackgroundColor3 = THEME.Surface, BorderSizePixel = 0,
            Text = tostring(info.Default or "None"), Font = Enum.Font.GothamSemibold, TextSize = 11,
            TextColor3 = THEME.Accent, AutoButtonColor = false, Parent = row,
        }) :: TextButton
        corner(btn, 4); stroke(btn, THEME.Border, 1, 0.4)
        local obj: any = { Value = tostring(info.Default or "None"), Mode = info.Mode or "Toggle", _changed = {}, Type = "KeyPicker" }
        function obj:OnChanged(fn) table.insert(self._changed, fn) end
        function obj:SetValue(v) self.Value = tostring(v); btn.Text = self.Value end
        local waiting = false
        btn.MouseButton1Click:Connect(function() waiting = true; btn.Text = "..." end)
        Library:_track(UserInputService.InputBegan:Connect(function(input, gpe)
            if Library.Unloaded then return end
            if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                obj:SetValue(input.KeyCode.Name); waiting = false
                if info.Callback then pcall(info.Callback, obj.Value) end
                return
            end
            if (not gpe) and input.UserInputType == Enum.UserInputType.Keyboard
                and input.KeyCode.Name == obj.Value then
                if info.Callback then pcall(info.Callback) end
            end
        end))
        Library.Options[idx] = obj
        return obj
    end

    function Container:AddColorPicker(idx: string, info: {[string]: any}, attachLabel: Instance?)
        info = info or {}
        local parent = self._body
        local row
        if attachLabel then
            row = create("Frame", {
                AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-4,0.5,0),
                Size = UDim2.new(0,28,0,16), BackgroundTransparency = 1, Parent = parent,
            })
        else
            row = rowFrame(parent, 26)
            create("TextLabel", {
                Position = UDim2.new(0,4,0,0), Size = UDim2.new(1,-44,1,0),
                BackgroundTransparency = 1, Text = info.Title or idx,
                Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = THEME.Text,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
            })
        end
        local swatch = create("TextButton", {
            AnchorPoint = Vector2.new(1,0.5),
            Position = attachLabel and UDim2.new(1,0,0.5,0) or UDim2.new(1,-4,0.5,0),
            Size = UDim2.new(0,28,0,16), Text = "", BorderSizePixel = 0,
            BackgroundColor3 = info.Default or Color3.new(1,1,1), AutoButtonColor = false, Parent = row,
        }) :: TextButton
        corner(swatch, 4); stroke(swatch, THEME.BorderLight, 1, 0.2)
        local obj: any = { Value = info.Default or Color3.new(1,1,1), _changed = {}, Type = "ColorPicker" }
        function obj:OnChanged(fn) table.insert(self._changed, fn) end
        function obj:SetValueRGB(c)
            self.Value = c; swatch.BackgroundColor3 = c
            if info.Callback then pcall(info.Callback, c) end
            for _, fn in ipairs(self._changed) do pcall(fn, c) end
        end
        function obj:SetValue(c) self:SetValueRGB(c) end
        local popup
        local function close() if popup then popup:Destroy(); popup = nil end end
        swatch.MouseButton1Click:Connect(function()
            if popup then close() return end
            popup = create("Frame", {
                Size = UDim2.new(0,220,0,120),
                Position = UDim2.new(0, swatch.AbsolutePosition.X - 220, 0, swatch.AbsolutePosition.Y + swatch.AbsoluteSize.Y + 4),
                BackgroundColor3 = THEME.Header, BorderSizePixel = 0, ZIndex = 60, Parent = Library._gui,
            })
            corner(popup :: any, 8); stroke(popup :: any, THEME.BorderLight, 1, 0.3)
            pad(popup :: any, 10); vlayout(popup :: any, 6, Enum.HorizontalAlignment.Center)
            local function chan(label: string, get, set)
                local rr = create("Frame", { Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, Parent = popup, ZIndex = 61 })
                create("TextLabel", {
                    Size = UDim2.new(0,14,1,0), BackgroundTransparency = 1, Text = label, ZIndex = 61,
                    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = THEME.Text, Parent = rr,
                })
                local track = create("Frame", {
                    Position = UDim2.new(0,18,0.5,-3), Size = UDim2.new(1,-50,0,6),
                    BackgroundColor3 = THEME.Surface, BorderSizePixel = 0, ZIndex = 61, Parent = rr,
                })
                corner(track :: any, 3)
                local fill = create("Frame", { Size = UDim2.new(get(),0,1,0), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0, ZIndex = 62, Parent = track })
                corner(fill :: any, 3)
                local txt = create("TextLabel", {
                    AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,0,0.5,0),
                    Size = UDim2.new(0,28,1,0), BackgroundTransparency = 1, ZIndex = 61,
                    Text = tostring(math.floor(get() * 255)), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = THEME.TextDim, Parent = rr,
                })
                local function update(input)
                    local frac = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(frac, 0, 1, 0); txt.Text = tostring(math.floor(frac * 255)); set(frac)
                end
                local d = false
                track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then d = true; update(input) end end)
                track.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
                Library:_track(UserInputService.InputChanged:Connect(function(input) if d and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end))
            end
            chan("R", function() return obj.Value.R end, function(v) obj:SetValueRGB(Color3.new(v, obj.Value.G, obj.Value.B)) end)
            chan("G", function() return obj.Value.G end, function(v) obj:SetValueRGB(Color3.new(obj.Value.R, v, obj.Value.B)) end)
            chan("B", function() return obj.Value.B end, function(v) obj:SetValueRGB(Color3.new(obj.Value.R, obj.Value.G, v)) end)
        end)
        Library.Options[idx] = obj
        return obj
    end

    function Container:AddLabel(text: string, doubleLine: boolean?, optionsId: string?)
        local row = rowFrame(self._body, doubleLine and 34 or 20)
        local lbl = create("TextLabel", {
            Position = UDim2.new(0,4,0,0), Size = UDim2.new(1,-72,1,0),
            BackgroundTransparency = 1, Text = text or "",
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = doubleLine or false, Parent = row,
        })
        local obj: any = { Type = "Label", _row = row, _lbl = lbl, Value = text }
        function obj:SetText(t) self.Value = t; lbl.Text = t end
        function obj:AddKeyPicker(kpIdx, kpInfo)   return Container.AddKeyPicker({_body = row},   kpIdx, kpInfo, lbl) end
        function obj:AddColorPicker(cpIdx, cpInfo) return Container.AddColorPicker({_body = row}, cpIdx, cpInfo, lbl) end
        if optionsId then Library.Options[optionsId] = obj end
        return obj
    end

    function Container:AddDivider()
        return create("Frame", {
            Size = UDim2.new(1,-8,0,1), BackgroundColor3 = THEME.Border, BorderSizePixel = 0, Parent = self._body,
        })
    end

    JBUI._Library = Library
    function JBUI.GetLibrary() return Library end
end

------------------------------------------------------------------------------
-- 17. GUI BUILD
------------------------------------------------------------------------------
local Library : any = nil
local Window  : any = nil
local Tabs    : {[string]: any} = {}
local Toggles : any = nil

local function bindToggle(toggleName: string, stateKey: string, sideEffect: ((boolean) -> ())?)
    Toggles[toggleName]:OnChanged(function()
        local v = Toggles[toggleName].Value
        State[stateKey] = v
        if sideEffect then sideEffect(v) end
    end)
end

local function buildUI()
    Library = JBUI.GetLibrary()
    Toggles = Library.Toggles
    Options = Library.Options
    Util.setLibrary(Library)

    Window = Library:CreateWindow({
        Title            = "NameHub",
        Footer           = "Jurassic Blocky -- " .. JB_BUILD,
        NotifySide       = CONFIG.NotifySide,
        ShowCustomCursor = CONFIG.ShowCustomCursor,
    })

    Tabs = {
        Main     = Window:AddTab("Main"),
        Player   = Window:AddTab("Player"),
        Visuals  = Window:AddTab("Visuals"),
        Misc     = Window:AddTab("Misc"),
        Teleport = Window:AddTab("Teleport"),
        Stats    = Window:AddTab("Stats"),
        Settings = Window:AddTab("Settings"),
    }

    --==========================================================================
    -- MAIN tab
    --==========================================================================
    do
        local FarmTab = Tabs.Main:AddLeftTabbox():AddTab("Farm")
        FarmTab:AddToggle("Autofarm", { Text = "Autofarm", Default = State.AutoFarm })
        FarmTab:AddDropdown("FarmTargets", {
            Values  = { "Berry","Meat","Fish","Wood","Stone","Fossil","Egg","Water","Iron","Gold","Diamond","Sapling","Mushroom","Loot" },
            Default = CONFIG.FarmTarget, Text = "Farm Target",
            Tooltip = "Primary farm target. Keyword-matched against workspace names; the keyword list lives in FARM_TARGETS in the script.",
            Callback = function(v) CONFIG.FarmTarget = v end,
        })
        FarmTab:AddDropdown("FarmPriority", {
            Values  = { "Berry","Meat","Fish","Wood","Stone","Fossil","Egg","Water","Iron","Gold","Diamond","Sapling","Mushroom","Loot" },
            Default = {}, Multi = true,
            Text    = "Additional Farm Targets",
            Tooltip = "Anything ticked here is farmed IN ADDITION to the primary target.",
        })
        FarmTab:AddSlider("FarmRange", {
            Text = "Farm Range", Default = CONFIG.AutoFarmRadius, Min = 100, Max = 6000, Rounding = 0, Suffix = " studs",
            Callback = function(v) CONFIG.AutoFarmRadius = v end,
        })
        FarmTab:AddToggle("SafeFarmSpeed", { Text = "Safe-Speed Tween Walk", Default = State.SafeFarmSpeed })
        FarmTab:AddSlider("SafeFarmSpeedValue", {
            Text = "Walk Speed", Default = CONFIG.SafeFarmSpeed,
            Min = 20, Max = CONFIG.SafeFarmSpeedMax, Rounding = 0, Suffix = " studs/s",
            Callback = function(v) CONFIG.SafeFarmSpeed = v end,
        })
        FarmTab:AddSlider("SafeFarmHopCap", {
            Text = "Hop Distance", Default = CONFIG.SafeFarmHopCap,
            Min = 10, Max = CONFIG.SafeFarmHopCapMax, Rounding = 0, Suffix = " studs",
            Callback = function(v) CONFIG.SafeFarmHopCap = v end,
        })
        FarmTab:AddSlider("SafeFarmInterHop", {
            Text = "Inter-Hop Pause", Default = CONFIG.SafeFarmInterHop,
            Min = 0, Max = 0.5, Rounding = 2, Suffix = "s",
            Callback = function(v) CONFIG.SafeFarmInterHop = v end,
        })
        bindToggle("SafeFarmSpeed", "SafeFarmSpeed")

        FarmTab:AddDivider()
        FarmTab:AddLabel("Instant TP (plain CFrame; JB has no known teleport check)")
        FarmTab:AddToggle("InstantFarmTP", { Text = "Instant TP Mode", Default = State.InstantFarmTP })
        FarmTab:AddSlider("InstantTPMaxJump", {
            Text = "Max Jump Per Hop", Default = CONFIG.InstantTPMaxJump,
            Min = 5, Max = 250, Rounding = 0, Suffix = " studs",
            Callback = function(v) CONFIG.InstantTPMaxJump = v end,
        })
        FarmTab:AddSlider("InstantTPInterJump", {
            Text = "Inter-Hop Pause", Default = CONFIG.InstantTPInterJump,
            Min = 0, Max = 1.0, Rounding = 2, Suffix = "s",
            Callback = function(v) CONFIG.InstantTPInterJump = v end,
        })
        FarmTab:AddSlider("InstantTPSettleTime", {
            Text = "Pickup Settle Time", Default = CONFIG.InstantTPSettleTime,
            Min = 0.05, Max = 0.5, Rounding = 2, Suffix = "s",
            Callback = function(v) CONFIG.InstantTPSettleTime = v end,
        })
        FarmTab:AddToggle("InstantTPBurstMode", { Text = "Burst Mode (~60Hz hops)", Default = CONFIG.InstantTPBurstMode })
        Toggles.InstantTPBurstMode:OnChanged(function() CONFIG.InstantTPBurstMode = Toggles.InstantTPBurstMode.Value end)
        FarmTab:AddSlider("InstantTPBurstStuds", {
            Text = "Burst Studs Per Frame", Default = CONFIG.InstantTPBurstStuds,
            Min = 10, Max = 250, Rounding = 0, Suffix = " studs",
            Callback = function(v) CONFIG.InstantTPBurstStuds = v end,
        })

        FarmTab:AddDivider()
        FarmTab:AddLabel("Target landing options")
        FarmTab:AddDropdown("TargetTargetPriority", {
            Values = { "Closest","Furthest","Largest","Random" },
            Default = CONFIG.TargetTargetPriority, Text = "Target Priority",
            Callback = function(v) CONFIG.TargetTargetPriority = v end,
        })
        FarmTab:AddSlider("TargetLandingYOffset", {
            Text = "Landing Y Offset", Default = CONFIG.TargetLandingYOffset, Min = -10, Max = 30, Rounding = 0, Suffix = " studs",
            Callback = function(v) CONFIG.TargetLandingYOffset = v end,
        })
        FarmTab:AddSlider("TargetLandingJitter", {
            Text = "Landing Jitter", Default = CONFIG.TargetLandingJitter, Min = 0, Max = 15, Rounding = 0, Suffix = " studs",
            Callback = function(v) CONFIG.TargetLandingJitter = v end,
        })
        FarmTab:AddSlider("TargetMinDistance", {
            Text = "Min Distance Filter", Default = CONFIG.TargetMinDistance, Min = 0, Max = 200, Rounding = 0, Suffix = " studs",
            Callback = function(v) CONFIG.TargetMinDistance = v end,
        })
        FarmTab:AddToggle("TargetSkipOccupied", { Text = "Skip Targets Near Other Players", Default = CONFIG.TargetSkipOccupied })
        Toggles.TargetSkipOccupied:OnChanged(function() CONFIG.TargetSkipOccupied = Toggles.TargetSkipOccupied.Value end)
        FarmTab:AddSlider("TargetPickupRetries", {
            Text = "Pickup Attempts", Default = CONFIG.TargetPickupRetries, Min = 1, Max = 10, Rounding = 0,
            Callback = function(v) CONFIG.TargetPickupRetries = v end,
        })
        FarmTab:AddDropdown("TargetPickupMethod", {
            Values = { "All","ProximityPrompt","Touch","Click","Remote" },
            Default = CONFIG.TargetPickupMethod, Text = "Pickup Method",
            Callback = function(v) CONFIG.TargetPickupMethod = v end,
        })

        FarmTab:AddDivider()
        FarmTab:AddLabel("Diagnostics")
        FarmTab:AddButton({
            Text = "Scan For Targets",
            Func = function()
                local types = getSelectedFarmTargets()
                if #types == 0 then Util.notify("Autofarm", "No farm target selected."); return end
                local lines = {"=== Farm Scan ==="}
                for _, t in ipairs(types) do
                    table.insert(lines, ("  %-10s = %d"):format(t, #findFarmTargets(t)))
                end
                local blob = table.concat(lines, "\n")
                print(blob); Util.notify("Autofarm", blob)
            end,
        })
        FarmTab:AddButton({
            Text = "Dump Workspace Names",
            Tooltip = "Lists up to 80 workspace Models/BaseParts whose names look resource-like. Use this to find the real names JB uses.",
            Func = function()
                local hits = {}
                local seen: {[string]: true} = {}
                local hintWords = {"berry","fruit","meat","fish","wood","log","stone","rock","fossil","bone","egg","water","iron","gold","diamond","sapling","mushroom","loot","drop","ore","resource","plant","tree"}
                for _, inst in ipairs(Workspace:GetDescendants()) do
                    if inst:IsA("Model") or inst:IsA("BasePart") then
                        local lower = inst.Name:lower()
                        for _, w in ipairs(hintWords) do
                            if lower:find(w, 1, true) then
                                if not seen[inst.Name] then
                                    seen[inst.Name] = true
                                    table.insert(hits, inst.Name .. "  (" .. inst.ClassName .. ", " .. inst:GetFullName() .. ")")
                                    if #hits >= 80 then break end
                                end
                                break
                            end
                        end
                        if #hits >= 80 then break end
                    end
                end
                local blob = "=== Workspace Resource Names ===\n" .. table.concat(hits, "\n")
                if #hits == 0 then blob = blob .. "  (nothing matched - stand near a collectible)" end
                print(blob)
                local sc = _findExecFn("setclipboard")
                if type(sc) == "function" then Util.safe(function() sc(blob) end, "clip") end
                Util.notify("Autofarm", ("Found %d hits. Console + clipboard."):format(#hits))
            end,
        })
        FarmTab:AddButton({
            Text = "Reset Skipped Targets",
            Func = function()
                local n = 0
                for k in pairs(UnreachableTargets) do UnreachableTargets[k] = nil; n += 1 end
                Util.notify("Autofarm", ("Cleared %d skipped."):format(n))
            end,
        })
        FarmTab:AddButton({
            Text = "Diagnose Autofarm",
            Func = function()
                local lines = {"=== Autofarm Diagnostic ==="}
                table.insert(lines, ("AutoFarm enabled : %s"):format(tostring(State.AutoFarm)))
                table.insert(lines, ("InstantFarmTP    : %s"):format(tostring(State.InstantFarmTP)))
                table.insert(lines, ("Character / Root : %s / %s"):format(tostring(Character ~= nil), tostring(RootPart ~= nil)))
                table.insert(lines, ("Farm Range       : %d studs"):format(CONFIG.AutoFarmRadius))
                local types = getSelectedFarmTargets()
                table.insert(lines, ("Selected types   : %s"):format(#types == 0 and "(NONE)" or table.concat(types, ", ")))
                for _, t in ipairs(types) do
                    local found = findFarmTargets(t)
                    local closest, dist = nil, math.huge
                    if RootPart then
                        for _, p in ipairs(found) do
                            local d = (p.Position - RootPart.Position).Magnitude
                            if d < dist then dist = d; closest = p end
                        end
                    end
                    if closest then
                        table.insert(lines, ("  %s : %d, closest %d studs (%s)"):format(t, #found, math.floor(dist), closest:GetFullName()))
                    else
                        table.insert(lines, ("  %s : %d, RootPart missing"):format(t, #found))
                    end
                end
                local blob = table.concat(lines, "\n")
                print(blob); Util.notify("Autofarm Diagnostic", blob)
            end,
        })

        bindToggle("Autofarm", "AutoFarm", function(v)
            if not v then Util.notify("Autofarm", "Disabled."); return end
            for k in pairs(UnreachableTargets) do UnreachableTargets[k] = nil end
            local types = getSelectedFarmTargets()
            if #types == 0 then Util.notify("Autofarm", "No target selected."); return end
            local total = 0
            for _, t in ipairs(types) do total += #findFarmTargets(t) end
            Util.notify("Autofarm", ("Enabled (%d targets in workspace)"):format(total))
        end)
        bindToggle("InstantFarmTP", "InstantFarmTP")

        local ESPMain = Tabs.Main:AddRightGroupbox("Resource ESP")
        ESPMain:AddToggle("ResourceESP", { Text = "Resource ESP", Default = State.ResourceESP })
        bindToggle("ResourceESP", "ResourceESP", function(v)
            if v then ResourceESP.enable() else ResourceESP.disable() end
        end)

        local StatsBox = Tabs.Main:AddRightGroupbox("Live Stats")
        StatsBox:AddLabel("Items Collected: 0", false, "ItemsCollected")
        StatsBox:AddLabel("Coins Gained: 0", false, "CoinsGained2")
        StatsBox:AddLabel("Farm Time: 0", false, "FarmTime")
    end

    --==========================================================================
    -- PLAYER tab
    --==========================================================================
    do
        local LeftTabbox  = Tabs.Player:AddLeftTabbox()
        local SurvivalTab = LeftTabbox:AddTab("Survival")
        SurvivalTab:AddToggle("InfHunger", { Text = "Inf Hunger", Default = State.InfHunger })
        SurvivalTab:AddToggle("InfThirst", { Text = "Inf Thirst", Default = State.InfThirst })
        SurvivalTab:AddToggle("InfOxygen", { Text = "Inf Oxygen", Default = State.InfOxygen })
        SurvivalTab:AddToggle("AutoEat",   { Text = "Auto Eat at Threshold",   Default = State.AutoEat })
        SurvivalTab:AddToggle("AutoDrink", { Text = "Auto Drink at Threshold", Default = State.AutoDrink })
        SurvivalTab:AddToggle("AutoSleep", { Text = "Auto Sleep at Threshold", Default = State.AutoSleep })
        SurvivalTab:AddSlider("AutoEatThreshold", {
            Text = "Auto Eat At", Default = CONFIG.AutoEatThreshold, Min = 5, Max = 95, Rounding = 0, Suffix = "%",
            Callback = function(v) CONFIG.AutoEatThreshold = v end,
        })
        SurvivalTab:AddSlider("AutoDrinkThreshold", {
            Text = "Auto Drink At", Default = CONFIG.AutoDrinkThreshold, Min = 5, Max = 95, Rounding = 0, Suffix = "%",
            Callback = function(v) CONFIG.AutoDrinkThreshold = v end,
        })
        SurvivalTab:AddSlider("StopInfHungerAt", {
            Text = "Stat Cap", Default = CONFIG.StopInfHungerAt, Min = 10, Max = 100, Rounding = 0, Suffix = "%",
            Callback = function(v) CONFIG.StopInfHungerAt = v end,
        })
        SurvivalTab:AddToggle("StopEatInCombat", { Text = "Stop Eating In Combat", Default = State.StopEatInCombat })
        SurvivalTab:AddToggle("AutoRespawn", { Text = "Auto Respawn", Default = State.AutoRespawn })
        SurvivalTab:AddButton({
            Text = "Print Diagnostics",
            Tooltip = "Dumps stats + remotes to console & clipboard so we can target JB precisely.",
            Func = function()
                local stats = listAllStats()
                local remotes = listAllRemotes()
                local lines = {"=== JurassicBlocky Diagnostics ==="}
                table.insert(lines, ("Stats found: %d"):format(#stats))
                for _, s in ipairs(stats) do
                    table.insert(lines, ("  %-24s = %s   (%s)"):format(s.name, tostring(s.value), s.path))
                end
                table.insert(lines, ("Remotes found: %d"):format(#remotes))
                for _, r in ipairs(remotes) do
                    table.insert(lines, ("  [%s] %s   (%s)"):format(r.class, r.name, r.path))
                end
                local blob = table.concat(lines, "\n")
                print(blob)
                local sc = _findExecFn("setclipboard")
                if type(sc) == "function" then Util.safe(function() sc(blob) end, "clip") end
                Util.notify("Diagnostics", ("%d stats, %d remotes printed%s."):format(#stats, #remotes, sc and " + clipboard" or ""))
            end,
        })

        bindToggle("InfHunger", "InfHunger")
        bindToggle("InfThirst", "InfThirst")
        bindToggle("InfOxygen", "InfOxygen")
        bindToggle("AutoEat",   "AutoEat")
        bindToggle("AutoDrink", "AutoDrink")
        bindToggle("AutoSleep", "AutoSleep")
        bindToggle("StopEatInCombat", "StopEatInCombat")
        bindToggle("AutoRespawn", "AutoRespawn")

        local PlayerTab = Tabs.Player:AddRightGroupbox("Movement")
        PlayerTab:AddToggle("EnableSpeed",     { Text = "Enable Speed",     Default = State.SpeedBoost })
        PlayerTab:AddToggle("EnableJumppower", { Text = "Enable Jumppower", Default = State.JumpBoost  })
        PlayerTab:AddSlider("Speed", {
            Text = "Speed", Default = CONFIG.BoostedWalkSpeed, Min = 16, Max = 500, Rounding = 0,
            Callback = function(v) CONFIG.BoostedWalkSpeed = v; if State.SpeedBoost and Humanoid then Humanoid.WalkSpeed = v end end,
        })
        PlayerTab:AddSlider("Jumppower", {
            Text = "Jumppower", Default = CONFIG.BoostedJumpPower, Min = 50, Max = 500, Rounding = 0,
            Callback = function(v) CONFIG.BoostedJumpPower = v; if State.JumpBoost and Humanoid then Humanoid.JumpPower = v end end,
        })
        PlayerTab:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = State.InfiniteJump })
        PlayerTab:AddToggle("Noclip", { Text = "Noclip", Default = State.Noclip, Risky = true })
        PlayerTab:AddToggle("Fly",    { Text = "Fly",    Default = State.Fly })
        PlayerTab:AddSlider("FlySpeed", {
            Text = "Fly Speed", Default = CONFIG.FlySpeed, Min = 5, Max = 250, Rounding = 0,
            Callback = function(v) CONFIG.FlySpeed = v end,
        })

        bindToggle("EnableSpeed", "SpeedBoost", function(v)
            if Humanoid then Humanoid.WalkSpeed = v and CONFIG.BoostedWalkSpeed or CONFIG.DefaultWalkSpeed end
        end)
        bindToggle("EnableJumppower", "JumpBoost", function(v)
            if Humanoid then Humanoid.JumpPower = v and CONFIG.BoostedJumpPower or CONFIG.DefaultJumpPower end
        end)
        bindToggle("InfiniteJump", "InfiniteJump")
        bindToggle("Noclip", "Noclip")
        bindToggle("Fly", "Fly", function(v) if v then Fly.start() else Fly.stop() end end)

        local CombatTab = Tabs.Player:AddRightGroupbox("Combat")
        CombatTab:AddToggle("AutoAttack",        { Text = "Auto Attack",          Default = State.AutoAttack })
        CombatTab:AddToggle("AutoAttackPlayers", { Text = "Auto Attack Players",  Default = State.AutoAttackPlayers })
        CombatTab:AddToggle("AutoAttackNPCs",    { Text = "Auto Attack NPCs",     Default = State.AutoAttackNPCs })
        CombatTab:AddToggle("AutoHeal",          { Text = "Auto Heal",            Default = State.AutoHeal })
        CombatTab:AddSlider("CombatRange", {
            Text = "Range", Default = CONFIG.CombatRange, Min = 5, Max = 500, Rounding = 0, Suffix = " studs",
            Callback = function(v) CONFIG.CombatRange = v end,
        })
        CombatTab:AddSlider("DisengageAtHP", {
            Text = "Heal Below", Default = CONFIG.DisengageAtHP, Min = 0, Max = 500, Rounding = 0, Suffix = " HP",
            Callback = function(v) CONFIG.DisengageAtHP = v end,
        })
        bindToggle("AutoAttack",        "AutoAttack")
        bindToggle("AutoAttackPlayers", "AutoAttackPlayers")
        bindToggle("AutoAttackNPCs",    "AutoAttackNPCs")
        bindToggle("AutoHeal",          "AutoHeal")
    end

    --==========================================================================
    -- VISUALS tab
    --==========================================================================
    do
        local function espToggle(box: any, idx: string, label: string, key: string)
            box:AddToggle(idx, { Text = label, Default = ESP.Settings[key], Callback = function(v) ESP.Settings[key] = v end })
        end
        local function espSlider(box: any, idx: string, label: string, key: string, mn: number, mx: number, rnd: number?, suffix: string?)
            box:AddSlider(idx, {
                Text = label, Default = ESP.Settings[key], Min = mn, Max = mx,
                Rounding = rnd or 1, Suffix = suffix or "",
                Callback = function(v) ESP.Settings[key] = v end,
            })
        end
        local function espColor(box: any, idx: string, label: string, colorKey: string)
            box:AddLabel(label):AddColorPicker(idx, {
                Default = ESP.Settings.Colors[colorKey], Title = label,
                Callback = function(c) ESP.Settings.Colors[colorKey] = c end,
            })
        end

        local ESPTabbox = Tabs.Visuals:AddLeftTabbox()
        local ESPMain = ESPTabbox:AddTab("ESP")
        ESPMain:AddToggle("ESP", { Text = "Master ESP", Default = State.ESP })
        bindToggle("ESP", "ESP", function(v) if v then ESP.enable() else ESP.disable() end end)
        espToggle(ESPMain, "ESP_ShowPlayers", "Show Player Creatures", "ShowPlayers")
        espToggle(ESPMain, "ESP_ShowNPCs",    "Show Wild / NPCs", "ShowNPCs")
        espToggle(ESPMain, "ESP_ShowSelf",    "Show Self", "ShowSelf")
        espToggle(ESPMain, "ESP_ShowOwner",   "Show Owner Name", "ShowOwner")
        espSlider(ESPMain, "ESP_MaxDistance", "Max Distance", "MaxDistance", 50, 5000, 0, " studs")
        espSlider(ESPMain, "ESP_TextSize",    "Text Size", "TextSize", 8, 28, 0)

        local BoxTracerTab = ESPTabbox:AddTab("Box & Tracer")
        espToggle(BoxTracerTab, "ESP_Boxes", "Boxes", "Boxes")
        BoxTracerTab:AddDropdown("ESP_BoxType", {
            Values = { "2D","Corner","Filled" }, Default = ESP.Settings.BoxType, Text = "Box Type",
            Callback = function(v) ESP.Settings.BoxType = v end,
        })
        espSlider(BoxTracerTab, "ESP_BoxThickness", "Box Thickness", "BoxThickness", 1, 5, 0)
        espToggle(BoxTracerTab, "ESP_Tracers", "Tracers", "Tracers")
        BoxTracerTab:AddDropdown("ESP_TracerStyle", {
            Values = { "Solid","Glow","Dashed","Gradient" }, Default = ESP.Settings.TracerStyle, Text = "Tracer Style",
            Callback = function(v) ESP.Settings.TracerStyle = v end,
        })
        BoxTracerTab:AddDropdown("ESP_TracerOrigin", {
            Values = { "Top","Center","Bottom","Mouse" }, Default = ESP.Settings.TracerOrigin, Text = "Tracer Origin",
            Callback = function(v) ESP.Settings.TracerOrigin = v end,
        })
        espSlider(BoxTracerTab, "ESP_TracerThickness", "Tracer Thickness", "TracerThickness", 1, 6, 0)
        espToggle(BoxTracerTab, "ESP_TracerRainbow", "Rainbow Tracer", "TracerRainbow")

        local ElementsTab = ESPTabbox:AddTab("Elements")
        espToggle(ElementsTab, "ESP_Names",      "Species Name", "Names")
        espToggle(ElementsTab, "ESP_Distance",   "Distance",     "Distance")
        espToggle(ElementsTab, "ESP_HealthText", "Health Text",  "HealthText")
        espToggle(ElementsTab, "ESP_HealthBar",  "Health Bar",   "HealthBar")
        espToggle(ElementsTab, "ESP_HeadDot",    "Head Dot",     "HeadDot")

        local ChamsTab = ESPTabbox:AddTab("Chams")
        espToggle(ChamsTab, "ESP_Chams", "Enable Chams", "Chams")
        ChamsTab:AddDropdown("ESP_ChamsMode", {
            Values = { "Standard","Outline Only","Fill Only","Rainbow","Pulse","Health-based" },
            Default = ESP.Settings.ChamsMode, Text = "Mode",
            Callback = function(v) ESP.Settings.ChamsMode = v end,
        })
        ChamsTab:AddDropdown("ESP_ChamsDepth", {
            Values = { "AlwaysOnTop","Occluded" }, Default = ESP.Settings.ChamsDepth, Text = "Depth Mode",
            Callback = function(v) ESP.Settings.ChamsDepth = v end,
        })

        local ColorsTab = ESPTabbox:AddTab("Colors")
        espColor(ColorsTab, "ESP_Color_Box",      "Box", "Box")
        espColor(ColorsTab, "ESP_Color_Tracer",   "Tracer", "Tracer")
        espColor(ColorsTab, "ESP_Color_Name",     "Name", "Name")
        espColor(ColorsTab, "ESP_Color_Distance", "Distance", "Distance")
        espColor(ColorsTab, "ESP_Color_Player",   "Player", "Player")
        espColor(ColorsTab, "ESP_Color_NPC",      "NPC", "NPC")

        local GenBox = Tabs.Visuals:AddRightGroupbox("General")
        GenBox:AddSlider("FOV", {
            Text = "FOV", Default = CONFIG.DefaultFOV, Min = 30, Max = 120, Rounding = 0,
            Callback = function(v) CONFIG.DefaultFOV = v; setFOV(v) end,
        })
        GenBox:AddSlider("FreecamSpeed", {
            Text = "Freecam Speed", Default = CONFIG.FreecamSpeed, Min = 1, Max = 50, Rounding = 0,
            Callback = function(v) CONFIG.FreecamSpeed = v end,
        })
        GenBox:AddToggle("Freecam", { Text = "Freecam", Default = State.Freecam })
        GenBox:AddToggle("DisableLighting", { Text = "Disable Lighting Effects", Default = State.DisableLighting })
        GenBox:AddToggle("FullBright", { Text = "Full Bright", Default = State.FullBright })
        GenBox:AddToggle("DisableVisualRain", { Text = "Disable Visual Weather", Default = State.DisableVisualRain })
        GenBox:AddToggle("InfiniteZoom", { Text = "Infinite Zoom", Default = State.InfiniteZoom })
        GenBox:AddSlider("LocalPlayerTransparency", {
            Text = "Self Transparency", Default = CONFIG.LocalPlayerTransparency, Min = 0, Max = 1, Rounding = 2,
            Callback = function(v) CONFIG.LocalPlayerTransparency = v; applyCharTransparency(v) end,
        })
        bindToggle("Freecam", "Freecam", function(v) if v then Freecam.start() else Freecam.stop() end end)
        bindToggle("DisableLighting", "DisableLighting", function(v) setLightingEffectsEnabled(not v) end)
        bindToggle("FullBright", "FullBright", function(v) if v then FullBright.start() else FullBright.stop() end end)
        bindToggle("DisableVisualRain", "DisableVisualRain", function(v) setRainEnabled(not v) end)
        bindToggle("InfiniteZoom", "InfiniteZoom", function(v) setInfiniteZoom(v) end)
    end

    --==========================================================================
    -- MISC tab
    --==========================================================================
    do
        local MiscBox = Tabs.Misc:AddLeftGroupbox("General")
        MiscBox:AddToggle("FPSBoost", { Text = "FPS Boost", Default = State.FPSBoost })
        MiscBox:AddToggle("KickBypass", {
            Text = "Generic Kick Bypass (off by default)", Default = State.KickBypass,
            Risky = true,
            Tooltip = "Hooks LocalPlayer:Kick to swallow client-initiated kicks. JB doesn't appear to use Kick aggressively; only enable if you're getting unexplained disconnects.",
        })
        MiscBox:AddToggle("AntiAFK", { Text = "Anti-AFK", Default = State.AntiAFK })
        MiscBox:AddToggle("StatMonitor", { Text = "Stat Monitor HUD", Default = State.StatMonitor })
        MiscBox:AddToggle("DebugMode", { Text = "Debug Mode", Default = CONFIG.DebugMode,
            Callback = function(v) CONFIG.DebugMode = v end,
        })
        MiscBox:AddButton({ Text = "Show Kick Bypass Stats", Func = function()
            local lines = {"=== Kick Bypass Stats ==="}
            table.insert(lines, ("Installed     : %s"):format(tostring(KickBypass.Installed)))
            table.insert(lines, ("Blocked kicks : %d"):format(KickBypass.BlockedCount))
            if KickBypass.LastError then table.insert(lines, "Last error: " .. KickBypass.LastError) end
            local blob = table.concat(lines, "\n")
            print(blob); Util.notify("Kick Bypass", blob)
        end })
        bindToggle("FPSBoost", "FPSBoost", function(v)
            Util.safe(function() settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end, "FPSBoost")
        end)
        bindToggle("KickBypass", "KickBypass", function(v)
            if v then
                local ok, msg = installKickBypass()
                Util.notify("Kick Bypass", ok and ("Installed: " .. msg) or ("Failed: " .. msg))
            else
                Util.notify("Kick Bypass", "Disabled (reload to fully unhook).")
            end
        end)
        bindToggle("AntiAFK", "AntiAFK")
        bindToggle("StatMonitor", "StatMonitor")
    end

    --==========================================================================
    -- TELEPORT tab
    --==========================================================================
    do
        local TBox = Tabs.Teleport:AddLeftGroupbox("Teleport")
        TBox:AddDropdown("TPPlayer", {
            Values = {}, Default = "", SpecialType = "Player", ExcludeLocalPlayer = true, Text = "Player",
        })
        TBox:AddButton({ Text = "Teleport To Player", Func = function()
            local name = Options.TPPlayer and Options.TPPlayer.Value
            if type(name) == "string" and name ~= "" then Teleport.toPlayer(name, true) end
        end })
        TBox:AddButton({ Text = "Teleport To Safety", Func = function()
            if RootPart then RootPart.CFrame = RootPart.CFrame + Vector3.new(0,500,0) end
        end })
        TBox:AddInput("CoordX", { Default = "0", Text = "X", Numeric = true })
        TBox:AddInput("CoordY", { Default = "0", Text = "Y", Numeric = true })
        TBox:AddInput("CoordZ", { Default = "0", Text = "Z", Numeric = true })
        TBox:AddButton({ Text = "Tween to Coordinates", Func = function()
            local x = tonumber(Options.CoordX.Value) or 0
            local y = tonumber(Options.CoordY.Value) or 0
            local z = tonumber(Options.CoordZ.Value) or 0
            Util.tweenTo(CFrame.new(x, y, z), CONFIG.TweenTeleportSeconds)
        end })
        TBox:AddButton({ Text = "Rejoin Server", Func = function()
            Util.safe(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end, "Rejoin")
        end })
        TBox:AddButton({ Text = "Copy JobId", Func = function()
            local sc = _findExecFn("setclipboard")
            if type(sc) == "function" then pcall(sc, game.JobId); Util.notify("Teleport", "JobId copied.") end
        end })
    end

    --==========================================================================
    -- STATS tab
    --==========================================================================
    do
        local DinoBox = Tabs.Stats:AddLeftGroupbox("Character")
        DinoBox:AddLabel("Health: -",    false, "DinoHealth")
        DinoBox:AddLabel("Hunger: -",    false, "DinoHunger")
        DinoBox:AddLabel("Thirst: -",    false, "DinoThirst")
        DinoBox:AddLabel("Energy: -",    false, "DinoEnergy")
        DinoBox:AddLabel("Oxygen: -",    false, "DinoOxygen")
        DinoBox:AddLabel("Position: -",  false, "DinoPosition")
        DinoBox:AddLabel("Walkspeed: -", false, "DinoWalkSpeed")
        DinoBox:AddButton({ Text = "Reset Session", Func = function()
            Session.StartTime = tick(); Session.StartCoins = Session.LastCoins
            Session.CoinsGained = 0; Session.CoinsSpent = 0
            Util.notify("Stats", "Session reset.")
        end })

        task.spawn(function()
            while Alive.value do
                task.wait(0.5)
                if Library and Library.Unloaded then break end
                Util.safe(function()
                    if Character and Character:FindFirstChild("HumanoidRootPart") then
                        local p = (Character.HumanoidRootPart :: BasePart).Position
                        if Options.DinoPosition then
                            Options.DinoPosition:SetText(("Position: %d, %d, %d"):format(math.floor(p.X), math.floor(p.Y), math.floor(p.Z)))
                        end
                    end
                    local hum = Character and Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        if Options.DinoHealth    then Options.DinoHealth:SetText(("Health: %d / %d"):format(math.floor(hum.Health), math.floor(hum.MaxHealth))) end
                        if Options.DinoWalkSpeed then Options.DinoWalkSpeed:SetText(("Walkspeed: %d"):format(math.floor(hum.WalkSpeed))) end
                    end
                    local function readStat(name, alias)
                        local s = findStat(alias)
                        if s and Options[name] then Options[name]:SetText(alias .. ": " .. tostring(math.floor((s :: any).Value))) end
                    end
                    readStat("DinoHunger", "Hunger")
                    readStat("DinoThirst", "Thirst")
                    readStat("DinoEnergy", "Energy")
                    readStat("DinoOxygen", "Oxygen")
                end, "stats-live")
            end
        end)

        local SessionBox = Tabs.Stats:AddRightGroupbox("Session")
        SessionBox:AddLabel("Session Time: 0s", false, "SessionTime")
        SessionBox:AddLabel("Coins Gained: 0",  false, "CoinsGained")
        SessionBox:AddLabel("Coin Rate: 0/hr",  false, "CoinRate")
        SessionBox:AddLabel("Coins Total: 0",   false, "CoinsTotal")
        SessionBox:AddLabel("Coins Spent: 0",   false, "CoinsSpent")
        SessionBox:AddDivider()
        SessionBox:AddInput("WebhookLink", {
            Default = CONFIG.WebhookLink, Text = "Webhook Link",
            Placeholder = "https://discord.com/api/webhooks/...",
            Callback = function(v) CONFIG.WebhookLink = v end,
        })
        SessionBox:AddToggle("AnonymousMode", { Text = "Anonymous Mode", Default = State.AnonymousMode })
        SessionBox:AddButton({ Text = "Send Test Webhook", Func = function()
            local url = CONFIG.WebhookLink
            if (not url or url == "") and Options.WebhookLink and Options.WebhookLink.Value then
                url = Options.WebhookLink.Value; CONFIG.WebhookLink = url
            end
            local c = CONFIG.EmbedColor or Color3.fromRGB(85,200,110)
            local intColor = math.floor(c.R*255)*65536 + math.floor(c.G*255)*256 + math.floor(c.B*255)
            local username = State.AnonymousMode and "Anonymous" or LocalPlayer.Name
            sendWebhook(url, {
                username = username,
                embeds = {{
                    title = "JurassicBlocky -- Test",
                    description = ("Webhook test from **%s**"):format(username),
                    color = intColor,
                    timestamp = DateTime.now():ToIsoDate(),
                    footer = { text = ("PlaceId: %d"):format(game.PlaceId) },
                }},
            })
        end })
        bindToggle("AnonymousMode", "AnonymousMode")

        Session.StartTime = tick()
        task.spawn(function()
            while Alive.value do
                task.wait(1)
                if Library and Library.Unloaded then break end
                local elapsed = tick() - Session.StartTime
                local h = math.floor(elapsed / 3600)
                local m = math.floor((elapsed % 3600) / 60)
                local s = math.floor(elapsed % 60)
                local timeStr = h > 0 and ("%dh %dm %ds"):format(h,m,s) or ("%dm %ds"):format(m,s)
                local current = Session.LastCoins or 0
                local rate = elapsed > 1 and math.floor(Session.CoinsGained / elapsed * 3600) or 0
                Util.safe(function()
                    if Options.SessionTime then Options.SessionTime:SetText("Session Time: " .. timeStr) end
                    if Options.CoinsGained then Options.CoinsGained:SetText(("Coins Gained: %s"):format(tostring(Session.CoinsGained))) end
                    if Options.CoinRate    then Options.CoinRate:SetText(("Coin Rate: %s/hr"):format(tostring(rate))) end
                    if Options.CoinsTotal  then Options.CoinsTotal:SetText(("Coins Total: %s"):format(tostring(current))) end
                    if Options.CoinsSpent  then Options.CoinsSpent:SetText(("Coins Spent: %s"):format(tostring(Session.CoinsSpent))) end
                end, "stats-tab")
            end
        end)
    end

    --==========================================================================
    -- SETTINGS tab
    --==========================================================================
    do
        local Menu = Tabs.Settings:AddLeftGroupbox("Menu")
        Menu:AddToggle("ShowCustomCursor", { Text = "Custom Cursor", Default = CONFIG.ShowCustomCursor,
            Callback = function(v) Library.ShowCustomCursor = v end,
        })
        local themeNames = {}
        if Library._ThemePresets then
            for n, _ in pairs(Library._ThemePresets) do table.insert(themeNames, n) end
            table.sort(themeNames)
        else themeNames = { "Jungle" } end
        Menu:AddDropdown("Theme", {
            Values = themeNames, Default = Library.CurrentTheme or "Jungle", Text = "Theme",
            Tooltip = "Pick a theme; saves to disk. Re-execute the loadstring to fully apply.",
            Callback = function(v)
                if Library.SetTheme then
                    local ok = Library:SetTheme(v)
                    if ok then Util.notify("Theme", ("Saved '%s' - reload to fully apply"):format(v)) end
                end
            end,
        })
        Menu:AddDropdown("NotifySide", {
            Values = { "Left","Right" }, Default = CONFIG.NotifySide, Text = "Notification Side",
            Callback = function(v) Library:SetNotifySide(v) end,
        })
        Menu:AddDropdown("DPIScale", {
            Values = { "75%","100%","125%","150%" }, Default = "100%", Text = "DPI Scale",
            Callback = function(v) Library:SetDPIScale(tonumber((v:gsub("%%", "")))) end,
        })
        Menu:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
            Default = CONFIG.GUIToggleKey, NoUI = true, Text = "Toggle UI",
        })
        Menu:AddButton({ Text = "Unload", Func = function() Library:Unload() end, DoubleClick = true, Risky = true })
        Library.ToggleKeybind = Options.MenuKeybind

        local HUD = Tabs.Settings:AddLeftGroupbox("Info HUD")
        HUD:AddToggle("InfoHUD", { Text = "Enable HUD", Default = false,
            Callback = function(v) if v then InfoHUD.start() else InfoHUD.stop() end end,
        })
        HUD:AddToggle("HUD_FPS",    { Text = "Show FPS",    Default = true,  Callback = function(v) InfoHUD.Visible.FPS = v end })
        HUD:AddToggle("HUD_Ping",   { Text = "Show Ping",   Default = true,  Callback = function(v) InfoHUD.Visible.Ping = v end })
        HUD:AddToggle("HUD_Memory", { Text = "Show Memory", Default = false, Callback = function(v) InfoHUD.Visible.Memory = v end })
        HUD:AddToggle("HUD_Coords", { Text = "Show Coords", Default = false, Callback = function(v) InfoHUD.Visible.Coords = v end })
        HUD:AddToggle("HUD_Time",   { Text = "Show Time",   Default = false, Callback = function(v) InfoHUD.Visible.Time = v end })
        HUD:AddDropdown("HUD_Anchor", {
            Values = { "TopLeft","TopRight","BottomLeft","BottomRight" }, Default = InfoHUD.Anchor, Text = "HUD Corner",
            Callback = function(v) InfoHUD.Anchor = v; InfoHUD.refreshAnchor() end,
        })

        local Perf = Tabs.Settings:AddRightGroupbox("Performance")
        Perf:AddDropdown("PerfPreset", {
            Values = { "Default","Low","Medium","High" }, Default = "Default", Text = "Graphics Preset",
            Callback = function(v)
                if v == "Low" then setLightingEffectsEnabled(false); setRainEnabled(false); Lighting.GlobalShadows = false; Lighting.FogEnd = 1e6
                    Util.notify("Performance", "Low preset applied.")
                elseif v == "Medium" then setLightingEffectsEnabled(true); setRainEnabled(false); Lighting.GlobalShadows = false
                    Util.notify("Performance", "Medium preset applied.")
                elseif v == "High" then setLightingEffectsEnabled(true); setRainEnabled(true); Lighting.GlobalShadows = true
                    Util.notify("Performance", "High preset applied.")
                else Util.notify("Performance", "Default preset.") end
            end,
        })
        Perf:AddToggle("DisableShadows", { Text = "Disable Shadows", Default = false,
            Callback = function(v) Lighting.GlobalShadows = not v end })
        Perf:AddToggle("DisableFog", { Text = "Disable Fog", Default = false,
            Callback = function(v) Lighting.FogEnd = v and 1e6 or 500 end })
        Perf:AddSlider("CharTransparency", {
            Text = "Character Transparency", Default = 0, Min = 0, Max = 1, Rounding = 2,
            Callback = function(v) applyCharTransparency(v) end,
        })
        Perf:AddSlider("CameraFOV", {
            Text = "Camera FOV", Default = 70, Min = 30, Max = 120, Rounding = 0,
            Callback = function(v) setFOV(v) end,
        })

        local Cfg = Tabs.Settings:AddRightGroupbox("Configs")
        local cfgList = ConfigIO.list()
        if #cfgList == 0 then cfgList = { "---" } end
        Cfg:AddInput("ConfigName", { Text = "Config Name", Default = "default", Placeholder = "Name your config" })
        Cfg:AddDropdown("ConfigList", { Values = cfgList, Default = cfgList[1] or "---", Text = "Saved Configs" })
        local function refreshList()
            local l = ConfigIO.list()
            if #l == 0 then l = { "---" } end
            if Options.ConfigList and Options.ConfigList.SetValues then Options.ConfigList:SetValues(l) end
        end
        Cfg:AddButton({ Text = "Save Config", Func = function()
            local n = Options.ConfigName and Options.ConfigName.Value or ""
            if n == "" then Util.notify("Config", "Type a name first."); return end
            local ok, err = ConfigIO.save(n, Library)
            if ok then Util.notify("Config", "Saved '" .. n .. "'"); refreshList()
            else Util.notify("Config", "Save failed: " .. tostring(err)) end
        end })
        Cfg:AddButton({ Text = "Load Config", Func = function()
            local n = Options.ConfigList and Options.ConfigList.Value or ""
            if n == "" or n == "---" then Util.notify("Config", "No config selected."); return end
            local ok, err = ConfigIO.load(n, Library)
            if ok then Util.notify("Config", "Loaded '" .. n .. "'")
            else Util.notify("Config", "Load failed: " .. tostring(err)) end
        end })
        Cfg:AddButton({ Text = "Delete Config", Risky = true, DoubleClick = true, Func = function()
            local n = Options.ConfigList and Options.ConfigList.Value or ""
            if n == "" or n == "---" then Util.notify("Config", "No config selected."); return end
            local ok, err = ConfigIO.delete(n)
            if ok then Util.notify("Config", "Deleted '" .. n .. "'"); refreshList()
            else Util.notify("Config", "Delete failed: " .. tostring(err)) end
        end })
        Cfg:AddButton({ Text = "Refresh List", Func = refreshList })
    end

    Library:OnUnload(function()
        Alive.value = false
        disconnectAll()
        ESP.disable()
        ResourceESP.disable()
        Fly.stop()
        Freecam.stop()
        FullBright.stop()
        setUnderwaterVision(false)
        setRainEnabled(true)
        setLightingEffectsEnabled(true)
        setInfiniteZoom(false)
        StatMonitor.stop()
        InfoHUD.stop()
        Util.debug("Library unloaded; framework cleaned up.")
    end)
end

------------------------------------------------------------------------------
-- 18. BOOTSTRAP
------------------------------------------------------------------------------
Util.safe(function()
    Util.waitForCharacter()
    StatMonitor.start()
    buildUI()
    Util.notify("JurassicBlocky " .. JB_BUILD,
        "Loaded. RightCtrl toggles the menu. Run Print Diagnostics in the Player tab to surface JB's real remote/stat names.")
    print(("[JurassicBlocky] %s loaded successfully"):format(JB_BUILD))
    Util.debug("Bootstrap complete")
end, "Bootstrap")

------------------------------------------------------------------------------
-- 19. CLEAN SHUTDOWN
--    Call JurassicBlocky_Shutdown() from the dev console to fully unload.
------------------------------------------------------------------------------
getgenv().JurassicBlocky_Shutdown = function()
    Alive.value = false
    if Library and not Library.Unloaded then
        Library:Unload()
    else
        disconnectAll()
        ESP.disable()
        ResourceESP.disable()
        Fly.stop()
        Freecam.stop()
        FullBright.stop()
        setUnderwaterVision(false)
        setRainEnabled(true)
        setLightingEffectsEnabled(true)
        setInfiniteZoom(false)
        StatMonitor.stop()
    end
    Util.notify("JurassicBlocky", "Shut down cleanly.")
end
