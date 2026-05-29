












local a = "v2.0.1 NameHub (jb-aqua-fix-20260529)"




getgenv          = getgenv          or function() return _G end
hookmetamethod   = hookmetamethod   or function() end
getrawmetatable  = getrawmetatable  or function(b) return getmetatable(b) end
setreadonly      = setreadonly      or function() end
getnamecallmethod = getnamecallmethod or function() return "" end
setclipboard     = setclipboard     or function() end

local b = {
    isfolder   = isfolder   or function() return false end,
    makefolder = makefolder or function() end,
    isfile     = isfile     or function() return false end,
    readfile   = readfile   or function() return "" end,
    writefile  = writefile  or function() end,
    delfile    = delfile    or function() end,
    listfiles  = listfiles  or function() return {} end,
    appendfile = appendfile or function() end,
}

local c = (syn and syn.request) or (http and http.request) or request or http_request or function()
    return { StatusCode = 0, Body = "", Success = false }
end




do
    local d = { [11653088948] = true }
    if not d[game.PlaceId] then
        local e = ("[NameHub Jurassic Blocky] Wrong game (PlaceId=%d)."):format(game.PlaceId)
        warn(e)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "NameHub", Text = "Wrong game.", Duration = 6,
            })
        end)
        error(e, 0)
    end
end




do
    local d = getgenv()
    if d._NameHubJB_Alive and type(d._NameHubJB_Unload) == "function" then
        pcall(d._NameHubJB_Unload)
    end
end




local d           = game:GetService("Players")
local e        = game:GetService("RunService")
local f  = game:GetService("UserInputService")
local g      = game:GetService("TweenService")
local h         = game:GetService("Workspace")
local i = game:GetService("ReplicatedStorage")
local j        = game:GetService("StarterGui")
local k       = game:GetService("VirtualUser")
local l       = game:GetService("HttpService")
local m           = game:GetService("CoreGui")
local n   = game:GetService("TeleportService")
local o          = game:GetService("Lighting")
local p            = h.CurrentCamera

local q = d.LocalPlayer
if not q then
    d.PlayerAdded:Wait()
    q = d.LocalPlayer
end




local r    = "NameHubJB"
local s     = r .. "/configs"
local t   = r .. "/themes"
local u  = r .. "/autoload.txt"

pcall(function()
    if not b.isfolder(r)  then b.makefolder(r)  end
    if not b.isfolder(s)   then b.makefolder(s)   end
    if not b.isfolder(t) then b.makefolder(t) end
end)




local v = {
    Brand         = "NameHub",
    SubBrand      = "Jurassic Blocky",
    DefaultWS     = 16,
    DefaultJP     = 50,

    DinoOptions = {
        "Gallimimus", "Triceratops", "T-Rex", "Spinosaurus",
        "Velociraptor", "Stegosaurus", "Brachiosaurus", "Ankylosaurus",
        "Carnotaurus", "Allosaurus", "Pteranodon", "Parasaurolophus",
    },

    FarmTargetOptions = {
        "Goat", "D-Rex", "Amber", "Bambiraptor", "Triceratops",
        "T-Rex", "Spinosaurus", "Stegosaurus", "Velociraptor",
        "Players", "All NPCs",
    },

    FontOptions = {
        "Gotham", "GothamBold", "GothamMedium", "GothamSemibold",
        "SourceSans", "SourceSansBold", "RobotoMono", "Arial", "Code", "Highway",
    },

    NotifySides = { "Right", "Left", "Top", "Bottom" },

    
    JB_AttackNames    = { "successOnHit", "tap" },
    JB_LootNames      = { "collectAmber", "collect", "collectPresent" },
    JB_SpawnName      = "spawn",

    AttackKeywords = { "successOnHit", "successonhit", "hit", "bite", "claw", "swing", "attack", "damage", "combat", "kill" },
    LootKeywords   = { "collectAmber", "collect", "claim", "pickup", "loot", "reward" },
    DinoChangeKeywords = { "spawn", "selectdino", "changedino", "playas", "dinoselect" },
    RespawnKeywords    = { "respawn", "reset", "revive" },
    MenuKeywords       = { "menu", "openmenu", "togglemenu" },
}




local w = {
    
    Autofarm          = false,
    FarmTarget        = "Goat",
    FarmPriority      = { "D-Rex", "Goat" },
    Speed             = 16,
    AutoLoot          = true,
    AutofarmDino      = "Gallimimus",
    CoinsGained       = 0,
    StartTime         = nil,
    StatsCounting     = false,

    
    GoatESP           = false,
    GoatESPColor      = Color3.fromRGB(255, 255, 255),
    AmberESP          = false,
    AmberESPColor     = Color3.fromRGB(245, 158, 11),
    NoPromptDelay     = false,
    OutlineTransparency = 0,
    FillTransparency    = 0.5,

    
    Fly               = false,
    FlySpeed          = 90,
    RespawnDelay      = 0,
    AutoRespawn       = false,
    Anchored          = false,

    
    OffsetX           = 5,
    OffsetY           = 5,
    Range             = 50,
    MaxTargetHP       = 0,           
    MinTargetHP       = 0,
    DisengageAt       = 300,
    TargetPOV         = false,
    AutoAttackNearby  = false,
    AutoAttack        = false,
    AutoTPToPlayer    = false,
    TargetPlayer      = "",

    
    HopOnPlayerCount  = 0,
    HopOnFriend       = false,
    SelectedJobId     = "",
    ServerListCache   = {},

    
    KickOnAdmin       = false,
    AdminList         = { "admin", "staff", "moderator", "developer", "owner" },

    
    WebhookLink       = "",
    WebhookInterval   = 10,
    WebhookTimezone   = 0,
    WebhookColor      = Color3.fromRGB(59, 130, 246),
    WebhookAnonymous  = false,

    
    Theme             = "Default",
    BgColor           = Color3.fromRGB(10, 12, 16),
    MainColor         = Color3.fromRGB(18, 22, 28),
    AccentColor       = Color3.fromRGB(34, 197, 94),
    OutlineColor      = Color3.fromRGB(34, 197, 94),
    FontColor         = Color3.fromRGB(235, 240, 245),
    FontFace          = "Gotham",
    MenuBind          = "LeftAlt",
    Autoexecute       = false,
    NotificationSide  = "Right",
    AutoloadConfig    = "",

    
    Alive             = true,
    UIVisible         = true,
}

local x      = {}      
local y = {}      
local z    = {}      
local A     = {}      
local B   = {}      




local C = {}

function C.safe(D, E)
    return function(...)
        local F, G = pcall(D, ...)
        if not F then
            warn(("[%s][%s] %s"):format(v.Brand, E or "?", G))
        end
        return F
    end
end

function C.spawn(D, E)
    return task.spawn(C.safe(D, E or "spawn"))
end

function C.conn(D, E)
    if x[D] and x[D].Connected then x[D]:Disconnect() end
    x[D] = E
    return E
end

function C.disconnect(D)
    if x[D] and x[D].Connected then x[D]:Disconnect() end
    x[D] = nil
end

function C.disconnectAll()
    for D, E in pairs(x) do
        if E and E.Connected then pcall(function() E:Disconnect() end) end
        x[D] = nil
    end
end

function C.rand(D) return (D or "_") .. tostring(math.random(100000, 999999)) end

function C.distance(D, E)
    if not D or not E then return math.huge end
    local F = typeof(D) == "Instance" and D.Position or D
    local G = typeof(E) == "Instance" and E.Position or E
    return (F - G).Magnitude
end

function C.contains(D, E)
    for F, G in ipairs(D) do if G == E then return true end end
    return false
end

function C.shallowCopy(D)
    local E = {}
    for F, G in pairs(D) do E[F] = G end
    return E
end

function C.color3ToHex(D)
    return string.format("#%02X%02X%02X",
        math.floor(D.R * 255 + 0.5),
        math.floor(D.G * 255 + 0.5),
        math.floor(D.B * 255 + 0.5))
end

function C.color3ToInt(D)
    return math.floor(D.R * 255) * 65536 + math.floor(D.G * 255) * 256 + math.floor(D.B * 255)
end

function C.color3ToTable(D)
    return { math.floor(D.R * 255), math.floor(D.G * 255), math.floor(D.B * 255) }
end

function C.tableToColor3(D)
    if type(D) ~= "table" or #D < 3 then return Color3.new(1, 1, 1) end
    return Color3.fromRGB(D[1], D[2], D[3])
end

function C.tween(D, E, F)
    local G = TweenInfo.new(E or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    g:Create(D, G, F):Play()
end

function C.fmtTime(D)
    D = math.max(0, math.floor(D))
    local E = math.floor(D / 3600)
    local F = math.floor((D % 3600) / 60)
    local G = D % 60
    if E > 0 then return string.format("%dh %dm %ds", E, F, G) end
    if F > 0 then return string.format("%dm %ds", F, G) end
    return string.format("%ds", G)
end




local D = {}

function D.encode(E)
    local F, G = pcall(function() return l:JSONEncode(E) end)
    return F and G or "{}"
end

function D.decode(E)
    if type(E) ~= "string" or #E == 0 then return {} end
    local F, G = pcall(function() return l:JSONDecode(E) end)
    return F and G or {}
end




local E = {}

function E.send(F, G)
    G = G or 3
    if not _G._NHJB_NotifyGui or not _G._NHJB_NotifyGui.Parent then
        local H = Instance.new("ScreenGui")
        H.Name = C.rand("_NHJB_NF_")
        H.IgnoreGuiInset = true
        H.ResetOnSpawn   = false
        H.DisplayOrder   = 1000000
        local I = pcall(function() H.Parent = m end)
        if not I then
            local J = q:WaitForChild("PlayerGui", 5)
            if J then H.Parent = J end
        end
        _G._NHJB_NotifyGui = H
    end

    local H = Instance.new("Frame")
    H.Size = UDim2.fromOffset(280, 50)
    H.BackgroundColor3 = w.MainColor
    H.BorderSizePixel = 0
    H.Parent = _G._NHJB_NotifyGui
    Instance.new("UICorner", H).CornerRadius = UDim.new(0, 8)
    local I = Instance.new("UIStroke", H)
    I.Color = w.AccentColor
    I.Transparency = 0.5

    local J = Instance.new("TextLabel", H)
    J.Size = UDim2.new(1, -20, 1, -10)
    J.Position = UDim2.fromOffset(10, 5)
    J.BackgroundTransparency = 1
    J.Text = tostring(F)
    J.TextColor3 = w.FontColor
    J.Font = Enum.Font[w.FontFace] or Enum.Font.Gotham
    J.TextSize = 12
    J.TextWrapped = true
    J.TextXAlignment = Enum.TextXAlignment.Left

    table.insert(B, H)
local K=function()        

local K = w.NotificationSide
        local L = 0
        for M, N in ipairs(B) do
            if N == H then L = M break end
        end
        local M = 10 + (L - 1) * 58
        if K == "Right"  then H.Position = UDim2.new(1, -290, 0, M) end
        if K == "Left"   then H.Position = UDim2.new(0,   10, 0, M) end
        if K == "Top"    then H.Position = UDim2.new(0.5, -140 + (L - 1) * 0, 0, M) end
        if K == "Bottom" then H.Position = UDim2.new(0.5, -140, 1, -60 - (L - 1) * 58) end
end
    
K()
    task.delay(0, function()
        for L, M in ipairs(B) do
            local N = 0
            for O, P in ipairs(B) do if P == M then N = O break end end
            if N > 0 then
                local O = 10 + (N - 1) * 58
                local P = w.NotificationSide
                if P == "Right"  then M.Position = UDim2.new(1, -290, 0, O) end
                if P == "Left"   then M.Position = UDim2.new(0,   10, 0, O) end
                if P == "Bottom" then M.Position = UDim2.new(0.5, -140, 1, -60 - (N - 1) * 58) end
            end
        end
    end)

    task.delay(G, function()
        if not H or not H.Parent then return end
        C.tween(H, 0.25, { BackgroundTransparency = 1 })
        for L, M in ipairs(H:GetDescendants()) do
            if M:IsA("TextLabel") then C.tween(M, 0.25, { TextTransparency = 1 }) end
            if M:IsA("UIStroke")  then C.tween(M, 0.25, { Transparency = 1 })     end
        end
        task.wait(0.3)
        for L = #B, 1, -1 do
            if B[L] == H then table.remove(B, L) break end
        end
        H:Destroy()
    end)
end




local F = {}

function F.get()           return q.Character end
function F.root()
    local G = F.get(); if not G then return nil end
    return G:FindFirstChild("HumanoidRootPart") or G.PrimaryPart
end
function F.humanoid()
    local G = F.get(); if not G then return nil end
    return G:FindFirstChildOfClass("Humanoid")
end

function F.applySpeed()
    local G = F.humanoid(); if not G then return end
    G.WalkSpeed = w.Speed
end

function F.applyAnchor()
    local G = F.root(); if not G then return end
    G.Anchored = w.Anchored
end




local G = {}

local function walk(H, I, J)
    J = J or {}
    if not H or J[H] then return end
    J[H] = true
    for K, L in ipairs(H:GetChildren()) do
        I(L)
        walk(L, I, J)
    end
end


function G.remoteByName(H)
    if not H or H == "" then return nil end
    local I
    walk(i, function(J)
        if I then return end
        if (J:IsA("RemoteEvent") or J:IsA("RemoteFunction")) and J.Name == H then
            I = J
        end
    end)
    return I
end


function G.remoteByKeywords(H)
    for I, J in ipairs(H or {}) do
        local K = J:lower()
        local L
        walk(i, function(M)
            if L then return end
            if M:IsA("RemoteEvent") or M:IsA("RemoteFunction") then
                if M.Name:lower():find(K, 1, true) then L = M end
            end
        end)
        if L then return L, J end
    end
    return nil, nil
end

function G.allRemotes(H)
    H = H or 300
    local I = {}
    walk(i, function(J)
        if #I >= H then return end
        if J:IsA("RemoteEvent") or J:IsA("RemoteFunction") then
            I[#I + 1] = J:GetFullName() .. "  [" .. J.ClassName .. "]"
        end
    end)
    return I
end




local H = {}

function H.allWithHumanoid()
    local I = {}
    for J, K in ipairs(h:GetDescendants()) do
        if K:IsA("Model") and K ~= F.get() then
            local L = K:FindFirstChildOfClass("Humanoid")
            local M = K:FindFirstChild("HumanoidRootPart") or K.PrimaryPart
            if L and M and L.Health > 0 then I[#I + 1] = { model = K, hum = L, root = M } end
        end
    end
    return I
end

function H.matchesName(I, J)
    if not J or J == "" then return true end
    if J == "Players"  then return d:GetPlayerFromCharacter(I) ~= nil end
    if J == "All NPCs" then return d:GetPlayerFromCharacter(I) == nil end
    local K = I.Name:lower()
    return K:find(J:lower(), 1, true) ~= nil
end

function H.bestByPriority(I)
    local J = H.allWithHumanoid()
    local K   = F.root()
    if not K then return nil end

    
    for L, M in ipairs(I or {}) do
        local N ,O=(math.huge
)        for P, Q in ipairs(J) do
            if H.matchesName(Q.model, M) then
                if w.MaxTargetHP == 0 or Q.hum.Health <= w.MaxTargetHP then
                    if Q.hum.Health >= w.MinTargetHP then
                        local R = C.distance(K, Q.root)
                        if R < N then O, N = Q, R end
                    end
                end
            end
        end
        if O then return O end
    end
    return nil
end

function H.dump(I)
    I = I or 50
    local J  = F.root()
    local K = {}
    for L, M in ipairs(H.allWithHumanoid()) do
        if #K >= I then break end
        local N = J and C.distance(J, M.root) or -1
        local O = d:GetPlayerFromCharacter(M.model)
        K[#K + 1] = ("%-30s HP=%-6.1f dist=%-6.1f %s"):format(
            M.model.Name:sub(1, 30), M.hum.Health, N, O and ("player=" .. O.Name) or "NPC")
    end
    return K
end




local I = {}
local J, K

function I.findRemote()
    if J and J.Parent then return J, K end
    
    for L, M in ipairs(v.JB_AttackNames) do
        local N = G.remoteByName(M)
        if N then J, K = N, M; return N, M end
    end
    
    local L, M = G.remoteByKeywords(v.AttackKeywords)
    J, K = L, M or ""
    return L, K
end

function I.invalidateCache() J, K = nil, nil end

function I.fireAt(L)
    local M, N = I.findRemote()
    if not M or not L then return false end

    local O
    if N == "successOnHit" then
        O = {
            { L.hum },
            { L.model },
            { L.root },
            { L.hum, L.root.Position },
            { L.model, L.root.Position },
            { { Target = L.hum }   },
            { { Target = L.model } },
        }
    elseif N == "tap" then
        O = {
            { L.root.Position },
            { L.model },
            { },
        }
    else
        O = { { L.model }, { L.hum }, { L.root }, { L.model.Name }, { } }
    end

    for P, Q in ipairs(O) do
        local R = pcall(function()
            if M:IsA("RemoteEvent") then M:FireServer(table.unpack(Q))
            else M:InvokeServer(table.unpack(Q)) end
        end)
        if R then return true end
    end
    return false
end


function I.collectNearby()
    for L, M in ipairs(v.JB_LootNames) do
        local N = G.remoteByName(M)
        if N then
            pcall(function()
                if N:IsA("RemoteEvent") then N:FireServer() else N:InvokeServer() end
            end)
        end
    end
end




local L = {}

function L.start()
    C.spawn(function()
        local M, N, O = 0, 0, 0
        while w.Alive and w.Autofarm do
            O = O + 1
            local P = F.root()
            if P then
                local Q = (w.FarmPriority and #w.FarmPriority > 0) and w.FarmPriority or { w.FarmTarget }
                local R = H.bestByPriority(Q)

                local S = F.humanoid()
                local T = (S and w.DisengageAt > 0 and S.Health < w.DisengageAt)

                if not T and R and R.model.Parent then
                    local U = C.distance(P, R.root)
                    if U > w.Range then
                        local V = CFrame.new(R.root.Position) * CFrame.new(w.OffsetX, w.OffsetY, math.min(8, w.Range * 0.2))
                        V = CFrame.lookAt(V.Position, R.root.Position)
                        pcall(function() P.CFrame = V end)
                    end

                    if tick() >= M then
                        local V = I.fireAt(R)
                        if V and w.StatsCounting then
                            w.CoinsGained = w.CoinsGained + 1
                        end
                        M = tick() + 0.35
                    end
                end

                if w.AutoLoot and tick() >= N then
                    I.collectNearby()
                    N = tick() + 3
                end
            end
            task.wait(0.1)
        end
    end, "AutoFarm.loop")
end




local M = {}

function M.start()
    C.spawn(function()
        local N = 0
        while w.Alive do
            if w.AutoAttackNearby or w.AutoAttack or w.AutoTPToPlayer then
                local O = F.root()
                if O then
                    local P
                    if w.AutoTPToPlayer and w.TargetPlayer ~= "" then
                        local Q = d:FindFirstChild(w.TargetPlayer)
                        if Q and Q.Character then
                            local R = Q.Character:FindFirstChild("HumanoidRootPart")
                            local S = Q.Character:FindFirstChildOfClass("Humanoid")
                            if R and S then
                                local T = CFrame.new(R.Position) * CFrame.new(w.OffsetX, w.OffsetY, 0)
                                T = CFrame.lookAt(T.Position, R.Position)
                                pcall(function() O.CFrame = T end)
                                if w.AutoAttack then
                                    P = { model = Q.Character, hum = S, root = R }
                                end
                            end
                        end
                    end

                    if not P and w.AutoAttackNearby then
                        P = H.bestByPriority({ "Players" })
                    end
                    if not P and w.AutoAttack then
                        P = H.bestByPriority(w.FarmPriority)
                    end

                    if P and tick() >= N then
                        local Q = C.distance(O, P.root)
                        if Q <= w.Range then
                            local R = F.humanoid()
                            if not R or R.Health >= w.DisengageAt or w.DisengageAt == 0 then
                                I.fireAt(P)
                                N = tick() + 0.35
                            end
                        end
                    end

                    if w.TargetPOV and P and P.root then
                        pcall(function()
                            p.CameraType    = Enum.CameraType.Scriptable
                            p.CFrame        = CFrame.new(P.root.Position + Vector3.new(0, 8, 12), P.root.Position)
                        end)
                    end
                end
            else
                if p.CameraType == Enum.CameraType.Scriptable then
                    pcall(function() p.CameraType = Enum.CameraType.Custom end)
                end
            end
            task.wait(0.1)
        end
    end, "Combat.loop")
end




local N = {}

function N.clearAll()
    for O, P in pairs(y) do
        if P and P.Parent then P:Destroy() end
        y[O] = nil
    end
end

function N.applyHighlight(O, P)
    if y[O] then return end
    local Q = Instance.new("Highlight")
    Q.Adornee = O
    Q.FillColor = P
    Q.OutlineColor = P
    Q.FillTransparency    = w.FillTransparency
    Q.OutlineTransparency = w.OutlineTransparency
    Q.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Q.Parent = O
    y[O] = Q
end

function N.refresh()
    
    for O, P in pairs(y) do
        if P and P.Parent then
            P.FillTransparency    = w.FillTransparency
            P.OutlineTransparency = w.OutlineTransparency
        end
    end
end

function N.start()
    C.spawn(function()
        while w.Alive do
            
            for O, P in pairs(y) do
                if not O.Parent or not P.Parent then
                    if P.Parent then P:Destroy() end
                    y[O] = nil
                end
            end

            if w.GoatESP or w.AmberESP then
                for O, P in ipairs(H.allWithHumanoid()) do
                    local Q = P.model.Name:lower()
                    if w.GoatESP and (Q:find("goat", 1, true) or Q:find("dino", 1, true) or d:GetPlayerFromCharacter(P.model) == nil) then
                        N.applyHighlight(P.model, w.GoatESPColor)
                    end
                end
                if w.AmberESP then
                    for O, P in ipairs(h:GetDescendants()) do
                        if P:IsA("Model") or P:IsA("BasePart") then
                            local Q = P.Name:lower()
                            if Q:find("amber", 1, true) and not y[P] then
                                N.applyHighlight(P, w.AmberESPColor)
                            end
                        end
                    end
                end
            else
                N.clearAll()
            end
            task.wait(0.5)
        end
        N.clearAll()
    end, "ESP.loop")
end




local O = {}
local P, Q, R

function O.enable()
    local S = F.get(); if not S then return end
    local T = F.root(); if not T then return end
    local U = F.humanoid()

    O.disable()
    R = {}

    P = Instance.new("BodyVelocity")
    P.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    P.Velocity = Vector3.zero
    P.Parent = T

    Q = Instance.new("BodyGyro")
    Q.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    Q.P = 1000
    Q.CFrame = T.CFrame
    Q.Parent = T

    if U then U.PlatformStand = true end

    C.conn("fly_input_began", f.InputBegan:Connect(function(V, W)
        if W then return end
        R[V.KeyCode] = true
    end))
    C.conn("fly_input_ended", f.InputEnded:Connect(function(V)
        R[V.KeyCode] = false
    end))

    C.conn("fly_step", e.RenderStepped:Connect(function()
        if not (w.Fly and P and P.Parent) then return end
        local V = p
        if not V then return end
        local W = Vector3.zero
        if R[Enum.KeyCode.W]      then W = W + V.CFrame.LookVector end
        if R[Enum.KeyCode.S]      then W = W - V.CFrame.LookVector end
        if R[Enum.KeyCode.A]      then W = W - V.CFrame.RightVector end
        if R[Enum.KeyCode.D]      then W = W + V.CFrame.RightVector end
        if R[Enum.KeyCode.Space]  then W = W + Vector3.new(0, 1, 0) end
        if R[Enum.KeyCode.LeftControl] then W = W - Vector3.new(0, 1, 0) end

        if W.Magnitude > 0 then W = W.Unit * w.FlySpeed
        else W = Vector3.zero end
        P.Velocity = W
        Q.CFrame = V.CFrame
    end))
end

function O.disable()
    C.disconnect("fly_input_began")
    C.disconnect("fly_input_ended")
    C.disconnect("fly_step")
    if P then pcall(function() P:Destroy() end); P = nil end
    if Q then pcall(function() Q:Destroy() end); Q = nil end
    local S = F.humanoid()
    if S then pcall(function() S.PlatformStand = false end) end
    R = nil
end




local S = {}

function S.respawn()
    local T = F.humanoid()
    if T then
        T.Health = 0
    else
        pcall(function() q.Character:BreakJoints() end)
    end
end

function S.openMenu()
    local T = G.remoteByKeywords(v.MenuKeywords)
    if T then
        pcall(function()
            if T:IsA("RemoteEvent") then T:FireServer() else T:InvokeServer() end
        end)
        return
    end
    
    pcall(function() k:CaptureController() end)
end

function S.attachAutoRespawn()
    C.conn("char_died_watch", q.CharacterAdded:Connect(function(T)
        local U = T:WaitForChild("Humanoid", 5)
        if not U then return end
        U.Died:Connect(function()
            if not w.AutoRespawn then return end
            task.wait(w.RespawnDelay)
            if not w.AutoRespawn then return end
            
            pcall(function() q:LoadCharacter() end)
        end)
    end))
end




local T = {}

function T.fetchServers()
    local U = game.PlaceId
    local V = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(U)
    local W = c({ Url = V, Method = "GET" })
    if not W or W.StatusCode ~= 200 then return {} end
    local X = D.decode(W.Body or "")
    local Y = {}
    for Z, _ in ipairs(X.data or {}) do
        if _.id and _.id ~= game.JobId then
            Y[#Y + 1] = { id = _.id, playing = _.playing or 0, max = _.maxPlayers or 0 }
        end
    end
    return Y
end

function T.joinJobId(U)
    if not U or U == "" then return end
    pcall(function() n:TeleportToPlaceInstance(game.PlaceId, U, q) end)
end

function T.rejoin()
    pcall(function() n:TeleportToPlaceInstance(game.PlaceId, game.JobId, q) end)
end

function T.randomHop()
    local U = T.fetchServers()
    if #U == 0 then E.send("No servers found.") return end
    local V = U[math.random(1, #U)]
    T.joinJobId(V.id)
end

function T.attachWatchers()
    
    C.conn("friend_watch", d.PlayerAdded:Connect(function(U)
        if not w.HopOnFriend then return end
        local V, W = pcall(function() return q:IsFriendsWith(U.UserId) end)
        if V and W then T.randomHop() end
    end))

    
    C.spawn(function()
        while w.Alive do
            if w.HopOnPlayerCount > 0 and #d:GetPlayers() <= w.HopOnPlayerCount then
                T.randomHop()
                task.wait(10)
            end
            task.wait(5)
        end
    end, "Hop.thresholdLoop")
end




local U = {}

function U.isAdmin(V)
    V = V:lower()
    for W, X in ipairs(w.AdminList) do
        if V:find(X, 1, true) then return true end
    end
    return false
end

function U.attach()
    C.conn("admin_watch", d.PlayerAdded:Connect(function(V)
        if not w.KickOnAdmin then return end
        if U.isAdmin(V.Name) or U.isAdmin(V.DisplayName or "") then
            E.send("Admin detected: " .. V.Name .. " — kicking self.", 5)
            task.wait(0.3)
            pcall(function() q:Kick("[NameHub] Admin detected: " .. V.Name) end)
        end
    end))

    
    C.spawn(function()
        task.wait(2)
        if not w.KickOnAdmin then return end
        for V, W in ipairs(d:GetPlayers()) do
            if W ~= q and (U.isAdmin(W.Name) or U.isAdmin(W.DisplayName or "")) then
                E.send("Admin in server: " .. W.Name .. " — kicking self.", 5)
                task.wait(0.3)
                pcall(function() q:Kick("[NameHub] Admin in server: " .. W.Name) end)
                return
            end
        end
    end, "Safety.initScan")
end




local V = {}
local W = 0

function V.send(X)
    if not X and w.WebhookLink == "" then return end
    if w.WebhookLink == "" then E.send("Set a webhook URL first.") return end

    local Y = w.StartTime and (os.time() - w.StartTime) or 0
    local Z    = Y > 0 and (w.CoinsGained / (Y / 60)) or 0

    local _ = w.WebhookAnonymous and "Anonymous" or q.Name
    local aa       = w.WebhookTimezone
    local ab   = os.time() + aa * 3600
    local ac   = os.date("!%Y-%m-%d %H:%M:%S", ab) .. (" UTC%+d"):format(aa)

    local ad = {
        username = "NameHub JB",
        embeds = {{
            title  = "NameHub Jurassic Blocky — Stats",
            color  = C.color3ToInt(w.WebhookColor),
            fields = {
                { name = "User",          value = _,                                inline = true },
                { name = "Server",        value = ("`%s`"):format(game.JobId or "n/a"),    inline = true },
                { name = "Time",          value = ac,                                  inline = false },
                { name = "Coins Gained",  value = tostring(w.CoinsGained),                 inline = true },
                { name = "Rate (per min)",value = string.format("%.1f", Z),             inline = true },
                { name = "Elapsed",       value = C.fmtTime(Y),                      inline = true },
                { name = "Auto-Farm",     value = w.Autofarm and "ON" or "OFF",            inline = true },
                { name = "Target",        value = w.FarmTarget,                            inline = true },
                { name = "Dino",          value = w.AutofarmDino,                          inline = true },
            },
            footer = { text = a },
        }},
    }
    local ae = D.encode(ad)
    local af = pcall(function()
        c({
            Url     = w.WebhookLink,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = ae,
        })
    end)
    if af then
        W = tick()
        if X then E.send("Webhook sent.") end
    elseif X then
        E.send("Webhook failed.")
    end
end

function V.attachInterval()
    C.spawn(function()
        while w.Alive do
            if w.WebhookLink ~= "" and w.WebhookInterval > 0 then
                if tick() - W >= w.WebhookInterval * 60 then
                    V.send(false)
                end
            end
            task.wait(30)
        end
    end, "Webhook.interval")
end
local aa=function()    




C.conn("antiafk", q.Idled:Connect(function()
        if not w.Alive then return end
        pcall(function()
            k:Button2Down(Vector2.new(0, 0), h.CurrentCamera.CFrame)
            task.wait(1)
            k:Button2Up(Vector2.new(0, 0), h.CurrentCamera.CFrame)
        end)
    end))
end




A = {
    Default = {
        Bg      = Color3.fromRGB(10, 12, 16),
        Main    = Color3.fromRGB(18, 22, 28),
        Accent  = Color3.fromRGB(34, 197, 94),
        Outline = Color3.fromRGB(34, 197, 94),
        Font    = Color3.fromRGB(235, 240, 245),
    },
    Obsidian = {
        Bg = Color3.fromRGB(0, 0, 0), Main = Color3.fromRGB(10, 10, 10),
        Accent = Color3.fromRGB(6, 182, 212), Outline = Color3.fromRGB(6, 182, 212),
        Font = Color3.fromRGB(229, 231, 235),
    },
    BBot = {
        Bg = Color3.fromRGB(10, 14, 26), Main = Color3.fromRGB(20, 26, 43),
        Accent = Color3.fromRGB(236, 72, 153), Outline = Color3.fromRGB(236, 72, 153),
        Font = Color3.fromRGB(243, 244, 246),
    },
    Fatality = {
        Bg = Color3.fromRGB(13, 10, 20), Main = Color3.fromRGB(26, 20, 36),
        Accent = Color3.fromRGB(233, 30, 99), Outline = Color3.fromRGB(124, 58, 237),
        Font = Color3.fromRGB(255, 255, 255),
    },
    Jester = {
        Bg = Color3.fromRGB(10, 10, 15), Main = Color3.fromRGB(21, 21, 31),
        Accent = Color3.fromRGB(168, 85, 247), Outline = Color3.fromRGB(168, 85, 247),
        Font = Color3.fromRGB(245, 245, 245),
    },
    Mint = {
        Bg = Color3.fromRGB(6, 41, 31), Main = Color3.fromRGB(10, 58, 44),
        Accent = Color3.fromRGB(16, 185, 129), Outline = Color3.fromRGB(16, 185, 129),
        Font = Color3.fromRGB(236, 253, 245),
    },
    ["Tokyo Night"] = {
        Bg = Color3.fromRGB(26, 27, 38), Main = Color3.fromRGB(36, 40, 59),
        Accent = Color3.fromRGB(122, 162, 247), Outline = Color3.fromRGB(122, 162, 247),
        Font = Color3.fromRGB(192, 202, 245),
    },
    Ubuntu = {
        Bg = Color3.fromRGB(44, 0, 30), Main = Color3.fromRGB(60, 14, 45),
        Accent = Color3.fromRGB(233, 84, 32), Outline = Color3.fromRGB(233, 84, 32),
        Font = Color3.fromRGB(252, 252, 252),
    },
}

local ab = {}

function ab.applyValues(ac)
    w.BgColor       = ac.Bg
    w.MainColor     = ac.Main
    w.AccentColor   = ac.Accent
    w.OutlineColor  = ac.Outline
    w.FontColor     = ac.Font
end

function ab.apply()
    for ac, ad in pairs(z) do
        if ad.themeUpdate then pcall(ad.themeUpdate) end
    end
end

function ab.load(ac)
    local ad = A[ac]
    if not ad then return end
    w.Theme = ac
    ab.applyValues(ad)
    ab.apply()
end

function ab.listNames()
    local ac = {}
    for ad in pairs(A) do ac[#ac + 1] = ad end
    table.sort(ac)
    return ac
end

function ab.saveCurrent(ac)
    if not ac or ac == "" then return false end
    local ad = {
        Bg      = C.color3ToTable(w.BgColor),
        Main    = C.color3ToTable(w.MainColor),
        Accent  = C.color3ToTable(w.AccentColor),
        Outline = C.color3ToTable(w.OutlineColor),
        Font    = C.color3ToTable(w.FontColor),
    }
    pcall(b.writefile, t .. "/" .. ac .. ".json", D.encode(ad))
    return true
end




local ac = {}

local ad = {
    "Autofarm", "FarmTarget", "FarmPriority", "Speed", "AutofarmDino",
    "GoatESP", "GoatESPColor", "AmberESP", "AmberESPColor", "NoPromptDelay",
    "OutlineTransparency", "FillTransparency",
    "Fly", "FlySpeed", "RespawnDelay", "AutoRespawn", "Anchored",
    "OffsetX", "OffsetY", "Range", "MaxTargetHP", "MinTargetHP", "DisengageAt",
    "TargetPOV", "AutoAttackNearby", "AutoAttack", "AutoTPToPlayer", "TargetPlayer",
    "HopOnPlayerCount", "HopOnFriend",
    "KickOnAdmin",
    "WebhookLink", "WebhookInterval", "WebhookTimezone", "WebhookColor", "WebhookAnonymous",
    "Theme", "BgColor", "MainColor", "AccentColor", "OutlineColor", "FontColor",
    "FontFace", "MenuBind", "Autoexecute", "NotificationSide",
}
local ae=function()    

local ae = {}
    for af, X in ipairs(ad) do
        local Y = w[X]
        if typeof(Y) == "Color3" then
            ae[X] = { _c3 = true, v = C.color3ToTable(Y) }
        else
            ae[X] = Y
        end
    end
    return ae
end local af=function(

af)    
for X, Y in pairs(af or {}) do
        if type(Y) == "table" and Y._c3 then
            w[X] = C.tableToColor3(Y.v)
        else
            w[X] = Y
        end
    end
end

function ac.save(X)
    if not X or X == "" then E.send("Config name required.") return end
    pcall(b.writefile, s .. "/" .. X .. ".json", D.encode(ae()))
    E.send("Saved config: " .. X)
end

function ac.load(X)
    if not X or X == "" then return end
    if not b.isfile(s .. "/" .. X .. ".json") then E.send("No config: " .. X) return end
    local Y = ""
    pcall(function() Y = b.readfile(s .. "/" .. X .. ".json") end)
    af(D.decode(Y))
    
    for Z, _ in pairs(z) do
        if _.refresh then pcall(_.refresh) end
    end
    ab.apply()
    E.send("Loaded config: " .. X)
end

function ac.delete(X)
    if not X or X == "" then return end
    pcall(b.delfile, s .. "/" .. X .. ".json")
    E.send("Deleted config: " .. X)
end

function ac.list()
    local X = {}
    local Y, Z = pcall(b.listfiles, s)
    if not Y or type(Z) ~= "table" then return X end
    for _, ag in ipairs(Z) do
        local ah = ag:match("([^/\\]+)%.json$")
        if ah then X[#X + 1] = ah end
    end
    table.sort(X)
    return X
end

function ac.setAutoload(ag)
    pcall(b.writefile, u, ag or "")
    w.AutoloadConfig = ag or ""
end

function ac.resetAutoload()
    pcall(b.delfile, u)
    w.AutoloadConfig = ""
end

function ac.getAutoload()
    if not b.isfile(u) then return "" end
    local ag = ""
    pcall(function() ag = b.readfile(u) end)
    return (ag or ""):gsub("%s+$", "")
end

function ac.exportCurrent()
    return D.encode(ae())
end

function ac.importString(ag)
    if not ag or ag == "" then E.send("Nothing to import.") return end
    local ah = D.decode(ag)
    if not ah or not next(ah) then E.send("Invalid import data.") return end
    af(ah)
    for X, Y in pairs(z) do
        if Y.refresh then pcall(Y.refresh) end
    end
    ab.apply()
    E.send("Imported config.")
end





local ag = {}
local ah=function(
ah, X, Y)    
local Z = Instance.new(ah)
    for _, ai in pairs(X or {}) do Z[_] = ai end
    if Y then for ai, _ in ipairs(Y) do _.Parent = Z end end
    return Z
end local ai=function()

return Enum.Font[w.FontFace] or Enum.Font.Gotham end


function ag.newWindow(X)
    X = X or {}
    local Y = ah("ScreenGui", {
        Name = C.rand("_NHJB_"),
        IgnoreGuiInset = true,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder   = 2000000,
    })
    local Z = pcall(function() Y.Parent = m end)
    if not Z then
        local _ = q:WaitForChild("PlayerGui", 5)
        if _ then Y.Parent = _ end
    end

    local _ = ah("Frame", {
        Name = "Window",
        Position = UDim2.fromOffset(60, 60),
        Size     = UDim2.fromOffset(X.width or 760, X.height or 520),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel  = 0,
        Active           = true,
        Parent           = Y,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 10), Parent = _ })
    local aj = ah("UIStroke", { Color = w.OutlineColor, Transparency = 0.6, Thickness = 1, Parent = _ })

    
    local ak = ah("TextLabel", {
        Parent = _,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        Text = "+",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = w.FontColor,
    })
    
    do
        local al, am, an
local ao=function(ao)            
al = true
            am = ao.Position
            an  = _.Position
            ao.Changed:Connect(function()
                if ao.UserInputState == Enum.UserInputState.End then al = false end
            end)
end        
ak.InputBegan:Connect(function(ap)
            if ap.UserInputType == Enum.UserInputType.MouseButton1 or ap.UserInputType == Enum.UserInputType.Touch then
                ao(ap)
            end
        end)
        f.InputChanged:Connect(function(ap)
            if al and (ap.UserInputType == Enum.UserInputType.MouseMovement or ap.UserInputType == Enum.UserInputType.Touch) then
                local aq = ap.Position - am
                _.Position = UDim2.new(an.X.Scale, an.X.Offset + aq.X,
                                         an.Y.Scale, an.Y.Offset + aq.Y)
            end
        end)
    end

    
    local al = ah("Frame", {
        Parent = _,
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 10), Parent = al })
    
    ah("Frame", {
        Parent = al,
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.new(0, 12, 1, 0),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })

    local am = ah("TextLabel", {
        Parent = al,
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.fromOffset(20, 18),
        BackgroundTransparency = 1,
        Text = v.Brand,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = w.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local an = ah("Frame", {
        Parent = al,
        Position = UDim2.fromOffset(0, 70),
        Size = UDim2.new(1, 0, 1, -90),
        BackgroundTransparency = 1,
    })
    local ao = ah("UIListLayout", {
        Parent = an,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })

    
    local ap = ah("Frame", {
        Parent = _,
        Position = UDim2.new(0, 150, 0, 0),
        Size = UDim2.new(1, -150, 0, 60),
        BackgroundTransparency = 1,
    })

    local aq = ah("Frame", {
        Parent = ap,
        Position = UDim2.fromOffset(20, 16),
        Size = UDim2.new(1, -80, 0, 28),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 6), Parent = aq })

    local ar = ah("TextLabel", {
        Parent = aq,
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.fromOffset(2, 0),
        BackgroundTransparency = 1,
        Text = "Q",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
    })

    local as = ah("TextBox", {
        Parent = aq,
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.new(1, -36, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search",
        TextColor3 = w.FontColor,
        PlaceholderColor3 = Color3.fromRGB(120, 130, 140),
        Font = ai(),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })

    
    local at = ah("Frame", {
        Parent = _,
        Position = UDim2.new(0, 150, 0, 60),
        Size = UDim2.new(1, -150, 1, -84),
        BackgroundTransparency = 1,
    })

    
    local au = ah("Frame", {
        Parent = _,
        Position = UDim2.new(0, 150, 1, -24),
        Size = UDim2.new(1, -150, 0, 24),
        BackgroundTransparency = 1,
    })
    ah("TextLabel", {
        Parent = au,
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        Text = v.SubBrand,
        Font = ai(),
        TextSize = 12,
        TextColor3 = Color3.fromRGB(120, 130, 140),
    })
    local av = ah("TextLabel", {
        Parent = au,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        Text = "<>",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
        Rotation = 45,
    })
    
    do
        local aw, ax, ay
        av.InputBegan:Connect(function(az)
            if az.UserInputType == Enum.UserInputType.MouseButton1 or az.UserInputType == Enum.UserInputType.Touch then
                aw = true
                ax = az.Position
                ay = _.Size
                az.Changed:Connect(function()
                    if az.UserInputState == Enum.UserInputState.End then aw = false end
                end)
            end
        end)
        f.InputChanged:Connect(function(az)
            if aw and (az.UserInputType == Enum.UserInputType.MouseMovement or az.UserInputType == Enum.UserInputType.Touch) then
                local aA = az.Position - ax
                _.Size = UDim2.new(0, math.max(560, ay.X.Offset + aA.X), 0, math.max(380, ay.Y.Offset + aA.Y))
            end
        end)
    end

    local aw = {
        gui = Y, win = _, sidebar = al, pageList = an,
        content = at, header = ap, searchBox = as, dragHandle = ak,
        pages = {},   
        active = nil,
        winStroke = aj, resize = av,
    }

    
    table.insert(z, {
        themeUpdate = function()
            _.BackgroundColor3 = w.BgColor
            aj.Color = w.OutlineColor
            al.BackgroundColor3 = w.MainColor
            for ax, ay in ipairs(al:GetChildren()) do
                if ay:IsA("Frame") then ay.BackgroundColor3 = w.MainColor end
            end
            am.TextColor3 = w.AccentColor
            am.Font = ai()
            aq.BackgroundColor3 = w.MainColor
            ar.TextColor3 = w.FontColor
            as.TextColor3 = w.FontColor
            as.Font = ai()
            ak.TextColor3 = w.FontColor
            av.TextColor3 = w.FontColor
            for ax, ay in pairs(aw.pages) do
                if ay.refreshTheme then pcall(ay.refreshTheme) end
            end
        end
    })

    function aw:addPage(ax)
        local ay = ah("TextButton", {
            Parent = an,
            LayoutOrder = #an:GetChildren(),
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        })
        local az = ah("TextLabel", {
            Parent = ay,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.fromOffset(20, 0),
            BackgroundTransparency = 1,
            Text = ax,
            Font = ai(),
            TextSize = 13,
            TextColor3 = w.FontColor,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local aA = ah("Frame", {
            Parent = ay,
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = w.AccentColor,
            BorderSizePixel = 0,
            Visible = false,
        })
local aB=function()            


ay.BackgroundColor3 = w.MainColor
            az.TextColor3 = w.FontColor
            az.Font = ai()
            aA.BackgroundColor3 = w.AccentColor
end
        
local aC = ah("Frame", {
            Parent = at,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
        })

        aw.pages[ax] = {
            btn = ay, frame = aC, label = az, indicator = aA,
            refreshTheme = aB,
        }

        ay.MouseButton1Click:Connect(function() aw:selectPage(ax) end)
        if not aw.active then aw:selectPage(ax) end
        return aC
    end

    function aw:selectPage(ax)
        for ay, az in pairs(aw.pages) do
            local aA = (ay == ax)
            az.frame.Visible = aA
            az.indicator.Visible = aA
            az.label.TextColor3 = aA and w.AccentColor or w.FontColor
        end
        aw.active = ax
    end

    return aw
end


function ag.newColumn(aj, ak)
    local al = ah("Frame", {
        Parent = aj,
        Size = UDim2.new(ak or 0.5, -12, 1, -20),
        BackgroundTransparency = 1,
    })
    local am = ah("UIListLayout", {
        Parent = al,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })
    return al, am
end


function ag.newCard(aj, ak)
    ak = ak or {}
    local al = ah("Frame", {
        Parent = aj,
        LayoutOrder = ak.order or 0,
        Size = UDim2.new(1, 0, 0, ak.height or 200),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 8), Parent = al })

    table.insert(z, {
        themeUpdate = function() al.BackgroundColor3 = w.MainColor end
    })

    local am
    local an = ah("Frame", {
        Parent = al,
        Size = UDim2.new(1, 0, 1, ak.tabs and -34 or 0),
        Position = UDim2.fromOffset(0, ak.tabs and 34 or 0),
        BackgroundTransparency = 1,
    })

    local ao = {}
    if ak.tabs then
        am = ah("Frame", {
            Parent = al,
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.fromOffset(10, 4),
            BackgroundTransparency = 1,
        })
        local ap = 1 / #ak.tabs
        for aq, ar in ipairs(ak.tabs) do
            local as = ah("TextButton", {
                Parent = am,
                Size = UDim2.new(ap, -4, 1, 0),
                Position = UDim2.new((aq - 1) * ap, 2, 0, 0),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                Text = ar,
                Font = ai(),
                TextSize = 12,
                TextColor3 = w.FontColor,
                AutoButtonColor = false,
            })
            ah("UICorner", { CornerRadius = UDim.new(0, 6), Parent = as })

            local at = ah("ScrollingFrame", {
                Parent = an,
                Size = UDim2.new(1, -16, 1, -8),
                Position = UDim2.fromOffset(8, 4),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = w.AccentColor,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Visible = (aq == 1),
            })
            ah("UIListLayout", { Parent = at, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })
            ao[ar] = { btn = as, frame = at }

            as.MouseButton1Click:Connect(function()
                for au, av in pairs(ao) do
                    av.frame.Visible = (au == ar)
                    av.btn.BackgroundColor3 = (au == ar) and w.AccentColor or w.BgColor
                end
            end)

            if aq == 1 then as.BackgroundColor3 = w.AccentColor end

            table.insert(z, {
                themeUpdate = function()
                    as.Font = ai()
                    as.TextColor3 = w.FontColor
                    if at.Visible then as.BackgroundColor3 = w.AccentColor else as.BackgroundColor3 = w.BgColor end
                    at.ScrollBarImageColor3 = w.AccentColor
                end
            })
        end
        return al, ao
    else
        local ap = ah("ScrollingFrame", {
            Parent = an,
            Size = UDim2.new(1, -16, 1, -8),
            Position = UDim2.fromOffset(8, 4),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = w.AccentColor,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        })
        ah("UIListLayout", { Parent = ap, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })

        if ak.title then
            local aq = ah("TextLabel", {
                Parent = al,
                Size = UDim2.new(1, -20, 0, 28),
                Position = UDim2.fromOffset(10, 4),
                BackgroundTransparency = 1,
                Text = ak.title,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = w.FontColor,
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            an.Position = UDim2.fromOffset(0, 30)
            an.Size = UDim2.new(1, 0, 1, -30)
            table.insert(z, {
                themeUpdate = function() aq.TextColor3 = w.FontColor; aq.Font = Enum.Font.GothamBold end
            })
        end

        return al, ap
    end
end





function ag.label(aj, ak, al)
    al = al or {}
    local am = ah("TextLabel", {
        Parent = aj,
        LayoutOrder = al.order or 0,
        Size = UDim2.new(1, 0, 0, al.height or 18),
        BackgroundTransparency = 1,
        Text = ak,
        Font = ai(),
        TextSize = al.size or 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local an = { instance = am, setText = function(an, ao) am.Text = ao end }
    function an.themeUpdate() am.TextColor3 = w.FontColor; am.Font = ai() end
    table.insert(z, an)
    return an
end

function ag.button(aj, ak, al)
    local am = ah("TextButton", {
        Parent = aj,
        LayoutOrder = #aj:GetChildren(),
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = ak,
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        AutoButtonColor = true,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 6), Parent = am })
    am.MouseButton1Click:Connect(function() pcall(al) end)

    local an = { instance = am, label = ak }
    function an.themeUpdate()
        am.BackgroundColor3 = w.BgColor
        am.TextColor3 = w.FontColor
        am.Font = ai()
    end
    table.insert(z, an)
    return an
end

function ag.toggle(aj, ak, al, am)
    local an = ah("Frame", {
        Parent = aj,
        LayoutOrder = #aj:GetChildren(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    })
    local ao = ah("TextLabel", {
        Parent = an,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = ak,
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local ap = ah("TextButton", {
        Parent = an,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(36, 18),
        BackgroundColor3 = w.BgColor,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    ah("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ap })
    local aq = ah("Frame", {
        Parent = ap,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = w.FontColor,
        BorderSizePixel = 0,
    })
    ah("UICorner", { CornerRadius = UDim.new(1, 0), Parent = aq })
local ar=function()        

local ar = w[al]
        if ar then
            ap.BackgroundColor3 = w.AccentColor
            aq.Position = UDim2.new(1, -16, 0.5, 0)
        else
            ap.BackgroundColor3 = w.BgColor
            aq.Position = UDim2.new(0, 2, 0.5, 0)
        end
        aq.BackgroundColor3 = w.FontColor
end
    
ar()

    ap.MouseButton1Click:Connect(function()
        w[al] = not w[al]
        ar()
        if am then pcall(am, w[al]) end
    end)

    local as = { instance = an, label = ak, key = al }
    function as.themeUpdate() ao.TextColor3 = w.FontColor; ao.Font = ai(); ar() end
    function as.refresh() ar() end
    table.insert(z, as)
    return as
end

function ag.slider(aj, ak, al, am, an, ao, ap)
    ao = ao or 1
    local aq = ah("Frame", {
        Parent = aj,
        LayoutOrder = #aj:GetChildren(),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 4), Parent = aq })

    local ar = ah("Frame", {
        Parent = aq,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = w.AccentColor,
        BorderSizePixel = 0,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ar })

    local as = ah("TextLabel", {
        Parent = aq,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
    })
local at=function()        

local at = tonumber(w[al]) or am
        at = math.clamp(at, am, an)
        local au = (an == am) and 0 or (at - am) / (an - am)
        ar.Size = UDim2.new(au, 0, 1, 0)
        local av
        if ao < 1 then av = string.format("%s: %.2f", ak, at) else av = string.format("%s: %d", ak, math.floor(at + 0.5)) end
        as.Text = av
end
    
at()

    local au = false
local av=function(av)        
local aw = (av - aq.AbsolutePosition.X) / aq.AbsoluteSize.X
        aw = math.clamp(aw, 0, 1)
        local ax = am + aw * (an - am)
        ax = math.floor(ax / ao + 0.5) * ao
        ax = math.clamp(ax, am, an)
        w[al] = ax
        at()
        if ap then pcall(ap, ax) end
end
    
aq.InputBegan:Connect(function(aw)
        if aw.UserInputType == Enum.UserInputType.MouseButton1 or aw.UserInputType == Enum.UserInputType.Touch then
            au = true
            av(aw.Position.X)
        end
    end)
    aq.InputEnded:Connect(function(aw)
        if aw.UserInputType == Enum.UserInputType.MouseButton1 or aw.UserInputType == Enum.UserInputType.Touch then
            au = false
        end
    end)
    f.InputChanged:Connect(function(aw)
        if au and (aw.UserInputType == Enum.UserInputType.MouseMovement or aw.UserInputType == Enum.UserInputType.Touch) then
            av(aw.Position.X)
        end
    end)

    local aw = { instance = aq, label = ak, key = al }
    function aw.themeUpdate()
        aq.BackgroundColor3 = w.BgColor
        ar.BackgroundColor3 = w.AccentColor
        as.TextColor3 = w.FontColor
        as.Font = ai()
    end
    function aw.refresh() at() end
    table.insert(z, aw)
    return aw
end

function ag.dropdown(aj, ak, al, am, an)
    local ao = ah("Frame", {
        Parent = aj,
        LayoutOrder = #aj:GetChildren(),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    local ap = ah("TextLabel", {
        Parent = ao,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = ak,
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local aq = ah("TextButton", {
        Parent = ao,
        Position = UDim2.fromOffset(0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 4), Parent = aq })
    local ar = ah("TextLabel", {
        Parent = aq,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = tostring(w[al] or "---"),
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local as = ah("TextLabel", {
        Parent = aq,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Text = "v",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
    })

    
    local at
local au=function()        
if at then at:Destroy(); at = nil; return end
        local au = ao:FindFirstAncestorOfClass("ScreenGui")
        if not au then return end
        at = ah("Frame", {
            Parent = au,
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        ah("UICorner", { CornerRadius = UDim.new(0, 4), Parent = at })
        ah("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = at })

        local av = aq.AbsolutePosition
        local aw = aq.AbsoluteSize
        local ax = math.min(160, #am * 22 + 4)
        at.Position = UDim2.fromOffset(av.X, av.Y + aw.Y + 2)
        at.Size = UDim2.fromOffset(aw.X, ax)

        local ay = ah("ScrollingFrame", {
            Parent = at,
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.fromOffset(2, 2),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = w.AccentColor,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 51,
        })
        ah("UIListLayout", { Parent = ay, SortOrder = Enum.SortOrder.LayoutOrder })

        for az, aA in ipairs(am) do
            local aB = ah("TextButton", {
                Parent = ay,
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                Text = tostring(aA),
                Font = ai(),
                TextSize = 12,
                TextColor3 = w.FontColor,
                AutoButtonColor = true,
                ZIndex = 52,
            })
            aB.MouseButton1Click:Connect(function()
                w[al] = aA
                ar.Text = tostring(aA)
                if at then at:Destroy(); at = nil end
                if an then pcall(an, aA) end
            end)
        end
end
    
aq.MouseButton1Click:Connect(au)

    local av = { instance = ao, label = ak, key = al, options = am }
    function av.setOptions(aw, ax)
        am = ax or {}
        av.options = am
        if at then at:Destroy(); at = nil end
    end
    function av.themeUpdate()
        ap.TextColor3 = w.FontColor; ap.Font = ai()
        aq.BackgroundColor3 = w.BgColor
        ar.TextColor3 = w.FontColor; ar.Font = ai()
        as.TextColor3 = w.FontColor
    end
    function av.refresh() ar.Text = tostring(w[al] or "---") end
    table.insert(z, av)
    return av
end

function ag.multiDropdown(aj, ak, al, am, an)
    
    local ao = ah("Frame", {
        Parent = aj,
        LayoutOrder = #aj:GetChildren(),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    local ap = ah("TextLabel", {
        Parent = ao,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = ak,
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local aq = ah("TextButton", {
        Parent = ao,
        Position = UDim2.fromOffset(0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 4), Parent = aq })
    local ar = ah("TextLabel", {
        Parent = aq,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = "",
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local as = ah("TextLabel", {
        Parent = aq,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Text = "v",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
    })
local at=function()        

local at = w[al] or {}
        ar.Text = (#at > 0) and table.concat(at, ", ") or "---"
end    
at()

    local au
local av=function()        
if au then au:Destroy(); au = nil; return end
        local av = ao:FindFirstAncestorOfClass("ScreenGui")
        if not av then return end
        au = ah("Frame", {
            Parent = av,
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        ah("UICorner", { CornerRadius = UDim.new(0, 4), Parent = au })
        ah("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = au })

        local aw = aq.AbsolutePosition
        local ax = aq.AbsoluteSize
        local ay = math.min(220, #am * 24 + 4)
        au.Position = UDim2.fromOffset(aw.X, aw.Y + ax.Y + 2)
        au.Size = UDim2.fromOffset(ax.X, ay)

        local az = ah("ScrollingFrame", {
            Parent = au,
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.fromOffset(2, 2),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = w.AccentColor,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 51,
        })
        ah("UIListLayout", { Parent = az, SortOrder = Enum.SortOrder.LayoutOrder })

        for aA, aB in ipairs(am) do
            local aC = ah("Frame", {
                Parent = az,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                ZIndex = 52,
            })
            local X = ah("TextLabel", {
                Parent = aC,
                Size = UDim2.fromOffset(20, 24),
                BackgroundTransparency = 1,
                Text = C.contains(w[al] or {}, aB) and "[X]" or "[ ]",
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = w.AccentColor,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 53,
            })
            local Y = ah("TextLabel", {
                Parent = aC,
                Position = UDim2.fromOffset(24, 0),
                Size = UDim2.new(1, -24, 1, 0),
                BackgroundTransparency = 1,
                Text = tostring(aB),
                Font = ai(),
                TextSize = 12,
                TextColor3 = w.FontColor,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 53,
            })
            local Z = ah("TextButton", {
                Parent = aC,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 54,
            })
            Z.MouseButton1Click:Connect(function()
                w[al] = w[al] or {}
                local _ = w[al]
                local aD
                for aE, aF in ipairs(_) do if aF == aB then aD = aE break end end
                if aD then table.remove(_, aD) else table.insert(_, aB) end
                X.Text = C.contains(_, aB) and "[X]" or "[ ]"
                at()
                if an then pcall(an, _) end
            end)
        end
end
    
aq.MouseButton1Click:Connect(av)

    local aw = { instance = ao, label = ak, key = al, options = am }
    function aw.themeUpdate()
        ap.TextColor3 = w.FontColor; ap.Font = ai()
        aq.BackgroundColor3 = w.BgColor
        ar.TextColor3 = w.FontColor; ar.Font = ai()
        as.TextColor3 = w.FontColor
    end
    function aw.refresh() at() end
    table.insert(z, aw)
    return aw
end

function ag.colorPicker(aj, ak, al, am)
    local an = ah("Frame", {
        Parent = aj,
        LayoutOrder = #aj:GetChildren(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    })
    local ao = ah("TextLabel", {
        Parent = an,
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = ak,
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local ap = ah("TextButton", {
        Parent = an,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(28, 18),
        BackgroundColor3 = w[al] or Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 3), Parent = ap })
    ah("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = ap })

    local aq
local ar=function()        
ap.BackgroundColor3 = w[al] or Color3.new(1, 1, 1)
end local as=function()        


if aq then aq:Destroy(); aq = nil; return end
        local as = an:FindFirstAncestorOfClass("ScreenGui")
        if not as then return end
        aq = ah("Frame", {
            Parent = as,
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        ah("UICorner", { CornerRadius = UDim.new(0, 6), Parent = aq })
        ah("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = aq })

        local at = ap.AbsolutePosition
        aq.Position = UDim2.fromOffset(at.X - 160, at.Y + 24)
        aq.Size = UDim2.fromOffset(190, 130)
local au=function(
au, av, aw)            
local ax = ah("Frame", {
                Parent = aq,
                Position = UDim2.fromOffset(36, aw),
                Size = UDim2.fromOffset(140, 16),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                ZIndex = 51,
            })
            ah("UICorner", { CornerRadius = UDim.new(0, 3), Parent = ax })
            local ay = ah("Frame", {
                Parent = ax,
                Size = UDim2.new((w[al][av] or 1), 0, 1, 0),
                BackgroundColor3 = av == "R" and Color3.fromRGB(220, 38, 38)
                                or av == "G" and Color3.fromRGB(34, 197, 94)
                                or                    Color3.fromRGB(59, 130, 246),
                BorderSizePixel = 0,
                ZIndex = 52,
            })
            ah("UICorner", { CornerRadius = UDim.new(0, 3), Parent = ay })
            local az = ah("TextLabel", {
                Parent = aq,
                Position = UDim2.fromOffset(8, aw),
                Size = UDim2.fromOffset(24, 16),
                BackgroundTransparency = 1,
                Text = au,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = w.FontColor,
                ZIndex = 51,
            })
            local aA = ah("TextLabel", {
                Parent = aq,
                Position = UDim2.fromOffset(178, aw),
                Size = UDim2.fromOffset(0, 16),
                BackgroundTransparency = 1,
                Text = "",
                Font = ai(),
                TextSize = 11,
                TextColor3 = w.FontColor,
                ZIndex = 51,
            })
local aB=function(aB)                
aB = math.clamp(aB, 0, 1)
                local aC = w[al]
                local aD, aE, aF = aC.R, aC.G, aC.B
                if av == "R" then aD = aB end
                if av == "G" then aE = aB end
                if av == "B" then aF = aB end
                w[al] = Color3.new(aD, aE, aF)
                ay.Size = UDim2.new(aB, 0, 1, 0)
                aA.Text = tostring(math.floor(aB * 255 + 0.5))
                ar()
                if am then pcall(am, w[al]) end
end            
aA.Text = tostring(math.floor((w[al][av] or 0) * 255 + 0.5))

            local aC
            ax.InputBegan:Connect(function(aD)
                if aD.UserInputType == Enum.UserInputType.MouseButton1 or aD.UserInputType == Enum.UserInputType.Touch then
                    aC = true
                    aB((aD.Position.X - ax.AbsolutePosition.X) / ax.AbsoluteSize.X)
                end
            end)
            ax.InputEnded:Connect(function(aD)
                if aD.UserInputType == Enum.UserInputType.MouseButton1 or aD.UserInputType == Enum.UserInputType.Touch then
                    aC = false
                end
            end)
            f.InputChanged:Connect(function(aD)
                if aC and (aD.UserInputType == Enum.UserInputType.MouseMovement or aD.UserInputType == Enum.UserInputType.Touch) then
                    aB((aD.Position.X - ax.AbsolutePosition.X) / ax.AbsoluteSize.X)
                end
            end)
end
        
au("R", "R", 10)
        au("G", "G", 36)
        au("B", "B", 62)

        local av = ah("TextButton", {
            Parent = aq,
            Position = UDim2.fromOffset(36, 92),
            Size = UDim2.fromOffset(140, 24),
            BackgroundColor3 = w.AccentColor,
            BorderSizePixel = 0,
            Text = "Done",
            Font = ai(),
            TextSize = 12,
            TextColor3 = w.FontColor,
            AutoButtonColor = true,
            ZIndex = 51,
        })
        ah("UICorner", { CornerRadius = UDim.new(0, 4), Parent = av })
        av.MouseButton1Click:Connect(function()
            if aq then aq:Destroy(); aq = nil end
        end)
end
    
ap.MouseButton1Click:Connect(as)

    local at = { instance = an, label = ak, key = al }
    function at.themeUpdate()
        ao.TextColor3 = w.FontColor; ao.Font = ai()
        ar()
    end
    function at.refresh() ar() end
    table.insert(z, at)
    return at
end

function ag.textInput(aj, ak, al, am, an)
    local ao = ah("Frame", {
        Parent = aj,
        LayoutOrder = #aj:GetChildren(),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    local ap = ah("TextLabel", {
        Parent = ao,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = ak,
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local aq = ah("TextBox", {
        Parent = ao,
        Position = UDim2.fromOffset(0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = tostring(w[al] or ""),
        PlaceholderText = am or "",
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        PlaceholderColor3 = Color3.fromRGB(120, 130, 140),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 4), Parent = aq })
    local ar = ah("UIPadding", { Parent = aq, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

    aq.FocusLost:Connect(function()
        w[al] = aq.Text
        if an then pcall(an, aq.Text) end
    end)

    local as = { instance = ao, label = ak, key = al }
    function as.themeUpdate()
        ap.TextColor3 = w.FontColor; ap.Font = ai()
        aq.BackgroundColor3 = w.BgColor
        aq.TextColor3 = w.FontColor
        aq.Font = ai()
    end
    function as.refresh() aq.Text = tostring(w[al] or "") end
    table.insert(z, as)
    return as
end

function ag.keybind(aj, ak, al, am)
    local an = ah("Frame", {
        Parent = aj,
        LayoutOrder = #aj:GetChildren(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    })
    local ao = ah("TextLabel", {
        Parent = an,
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Text = ak,
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local ap = ah("TextButton", {
        Parent = an,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(96, 22),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = tostring(w[al] or "None"),
        Font = ai(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        AutoButtonColor = true,
    })
    ah("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ap })

    local aq = false
    ap.MouseButton1Click:Connect(function()
        aq = true
        ap.Text = "..."
    end)
    f.InputBegan:Connect(function(ar, as)
        if not aq then return end
        if ar.UserInputType ~= Enum.UserInputType.Keyboard then return end
        aq = false
        local at = ar.KeyCode.Name
        w[al] = at
        ap.Text = at
        if am then pcall(am, at) end
    end)

    local ar = { instance = an, label = ak, key = al }
    function ar.themeUpdate()
        ao.TextColor3 = w.FontColor; ao.Font = ai()
        ap.BackgroundColor3 = w.BgColor
        ap.TextColor3 = w.FontColor; ap.Font = ai()
    end
    function ar.refresh() ap.Text = tostring(w[al] or "None") end
    table.insert(z, ar)
    return ar
end
local aj=function()    




w.Alive = false
    w.Autofarm = false
    w.Fly = false
    w.AutoAttack = false
    w.AutoAttackNearby = false
    w.AutoTPToPlayer = false

    O.disable()
    N.clearAll()
    C.disconnectAll()
    if p.CameraType == Enum.CameraType.Scriptable then
        pcall(function() p.CameraType = Enum.CameraType.Custom end)
    end

    local aj = F.humanoid()
    if aj then pcall(function() aj.WalkSpeed = v.DefaultWS; aj.JumpPower = v.DefaultJP end) end
    local ak = F.root()
    if ak then pcall(function() ak.Anchored = false end) end
local al=function(

al)        
if not al then return end
        for am, an in ipairs(al:GetChildren()) do
            if an:IsA("ScreenGui") and (an.Name:sub(1, 6) == "_NHJB_" or an.Name:sub(1, 9) == "_NHJB_NF_") then
                pcall(function() an:Destroy() end)
            end
        end
end    
al(m)
    if q then al(q:FindFirstChild("PlayerGui")) end
    _G._NHJB_NotifyGui = nil

    getgenv()._NameHubJB_Alive  = false
    getgenv()._NameHubJB_Unload = nil
end




local ak = ag.newWindow({ width = 760, height = 520 })
local al, am, an, ao
local ap, aq, ar, as


local at = ak:addPage("Main")

local au  = ag.newColumn(at, 0.5)
au.Position = UDim2.fromOffset(8, 8)

local av = ag.newColumn(at, 0.5)
av.Position = UDim2.new(0.5, 4, 0, 8)


local aw, ax = ag.newCard(au, { tabs = { "Main", "ESP" }, height = 360 })

do
    local ay = ax["Main"].frame
    ag.toggle(ay, "Autofarm", "Autofarm", function(az)
        if az then
            w.StartTime = w.StartTime or os.time()
            w.StatsCounting = true
            L.start()
        else
            F.applySpeed()
        end
    end)
    ag.dropdown(ay, "Farm Targets", "FarmTarget", v.FarmTargetOptions, function(az)
        
        if #w.FarmPriority == 0 then w.FarmPriority = { az } end
    end)
    ag.multiDropdown(ay, "Farm Priority List", "FarmPriority", v.FarmTargetOptions)
    ag.slider(ay, "Speed", "Speed", 16, 200, 1, function() F.applySpeed() end)
    ag.dropdown(ay, "Autofarm Dino", "AutofarmDino", v.DinoOptions, function(az)
        local aA = G.remoteByKeywords(v.DinoChangeKeywords)
        if aA then
            pcall(function()
                if aA:IsA("RemoteEvent") then aA:FireServer(az) else aA:InvokeServer(az) end
            end)
        end
    end)

    local az = ag.label(ay, "Coins Gained: 0")
    local aA  = ag.label(ay, "Rate: N/A")
    local aB = ag.label(ay, "Time Elapsed: N/A")
    al, an, am = az, aA, aB

    ag.button(ay, "Start Counting Stats", function()
        w.CoinsGained = 0
        w.StartTime = os.time()
        w.StatsCounting = true
        E.send("Stats counter started.")
    end)
end

do
    local ay = ax["ESP"].frame
    ag.toggle(ay, "Goat ESP", "GoatESP", function(az)
        if az then N.start() end
    end)
    ag.colorPicker(ay, "Goat ESP Color", "GoatESPColor")
    ag.toggle(ay, "Amber ESP", "AmberESP", function(az)
        if az then N.start() end
    end)
    ag.colorPicker(ay, "Amber ESP Color", "AmberESPColor")
    ag.toggle(ay, "No Prompt Delay", "NoPromptDelay")
    ag.slider(ay, "Outline Transparency", "OutlineTransparency", 0, 1, 0.05, function() N.refresh() end)
    ag.slider(ay, "Fill Transparency", "FillTransparency", 0, 1, 0.05, function() N.refresh() end)
end


local ay, az = ag.newCard(av, { tabs = { "Player", "Combat" }, height = 360 })

do
    local aA = az["Player"].frame
    ag.toggle(aA, "Fly", "Fly", function(aB)
        if aB then O.enable() else O.disable() end
    end)
    ag.slider(aA, "Fly Speed", "FlySpeed", 10, 300, 1)
    ag.button(aA, "Respawn", function() S.respawn() end)
    ag.button(aA, "Menu", function() S.openMenu() end)
    ag.slider(aA, "Respawn Delay", "RespawnDelay", 0, 30, 1)
    ag.toggle(aA, "Auto Respawn", "AutoRespawn")
    ag.toggle(aA, "Anchored", "Anchored", function() F.applyAnchor() end)
end

do
    local aA = az["Combat"].frame
    ag.slider(aA, "Offset (X-axis)", "OffsetX", -20, 20, 1)
    ag.slider(aA, "Offset (Y-axis)", "OffsetY", -20, 20, 1)
    ag.slider(aA, "Range", "Range", 5, 200, 1)
    ag.slider(aA, "Max Target HP", "MaxTargetHP", 0, 5000, 10)
    ag.slider(aA, "Min Target HP", "MinTargetHP", 0, 5000, 10)
    ag.slider(aA, "Disengage At", "DisengageAt", 0, 1000, 10)
    ag.toggle(aA, "Target POV", "TargetPOV")
    ag.toggle(aA, "Auto Attack Nearby Player", "AutoAttackNearby")
    ag.toggle(aA, "Auto Attack", "AutoAttack")
    ag.toggle(aA, "Auto TP to Player", "AutoTPToPlayer")
local aB=function()        


local aB = { "" }
        for aC, aD in ipairs(d:GetPlayers()) do
            if aD ~= q then aB[#aB + 1] = aD.Name end
        end
        return aB
end    
as = ag.dropdown(aA, "Target Player", "TargetPlayer", aB())
    
    C.conn("tp_player_add", d.PlayerAdded:Connect(function() as:setOptions(aB()) end))
    C.conn("tp_player_rem", d.PlayerRemoving:Connect(function() as:setOptions(aB()) end))
end


local aA = ak:addPage("Teleport")
local aB  = ag.newColumn(aA, 0.5)
aB.Position = UDim2.fromOffset(8, 8)
local aC, aD = ag.newCard(aB, { title = "Server Hop", height = 460 })

do
    ag.button(aD, "Join selected server", function()
        if w.SelectedJobId ~= "" then T.joinJobId(w.SelectedJobId) end
    end)
    ag.button(aD, "Refresh Server List", function()
        E.send("Fetching servers...")
        C.spawn(function()
            local aE = T.fetchServers()
            w.ServerListCache = aE
            local aF = {}
            for X, Y in ipairs(aE) do aF[#aF + 1] = ("%s  (%d/%d)"):format(Y.id:sub(1, 8), Y.playing, Y.max) end
            if #aF == 0 then aF = { "(no servers)" } end
            ap:setOptions(aF)
            E.send(("Fetched %d servers"):format(#aE))
        end)
    end)
    ap = ag.dropdown(aD, "Server List", "SelectedJobId", { "---" }, function(aE)
        for aF, X in ipairs(w.ServerListCache or {}) do
            if aE:sub(1, 8) == X.id:sub(1, 8) then w.SelectedJobId = X.id; return end
        end
    end)
    ag.button(aD, "Get PlayerCount", function()
        for aE, aF in ipairs(w.ServerListCache or {}) do
            if aF.id == w.SelectedJobId then
                E.send(("Server %s: %d/%d players"):format(aF.id:sub(1,8), aF.playing, aF.max))
                return
            end
        end
        E.send("Refresh server list first.")
    end)
    ag.button(aD, "Copy JobId", function()
        pcall(setclipboard, w.SelectedJobId)
        E.send("Copied JobId.")
    end)
    ag.button(aD, "Join Selected JobId", function()
        T.joinJobId(w.SelectedJobId)
    end)
    ag.textInput(aD, "JobId", "SelectedJobId", "Enter JobId here")
    ag.button(aD, "Rejoin Server", function() T.rejoin() end)
    ag.button(aD, "Server Hop", function() T.randomHop() end)
    ag.slider(aD, "Hop On Player Count", "HopOnPlayerCount", 0, 30, 1)
    ag.toggle(aD, "Hop On Friend Detection", "HopOnFriend")
end


local aE = ak:addPage("Safety")
local aF = ag.newColumn(aE, 0.5)
aF.Position = UDim2.fromOffset(8, 8)
local X, Y = ag.newCard(aF, { title = "Admin Detection", height = 80 })
ag.toggle(Y, "Kick On Detection", "KickOnAdmin")


local Z = ak:addPage("Webhook")
local _  = ag.newColumn(Z, 0.5)
_.Position = UDim2.fromOffset(8, 8)
local aG, aH = ag.newCard(_, { title = "Webhook", height = 280 })
do
    ag.textInput(aH, "Webhook Link", "WebhookLink", "https://discord.com/api/webhooks/...")
    ag.slider(aH, "Webhook Interval (minutes)", "WebhookInterval", 1, 60, 1)
    ag.slider(aH, "Timezone (UTC offset)", "WebhookTimezone", -12, 12, 1)
    ag.colorPicker(aH, "Embed Color", "WebhookColor")
    ag.toggle(aH, "Anonymous Mode", "WebhookAnonymous")
    ag.button(aH, "Force Send Webhook Request", function() V.send(true) end)
end


local aI = ak:addPage("Settings")

local aJ  = ag.newColumn(aI, 0.5)
aJ.Position = UDim2.fromOffset(8, 8)
local aK = ag.newColumn(aI, 0.5)
aK.Position = UDim2.new(0.5, 4, 0, 8)

local aL, aM = ag.newCard(aJ, { title = "Themes", height = 280 })
do
    ag.colorPicker(aM, "Background color", "BgColor",   function() ab.apply() end)
    ag.colorPicker(aM, "Main color",        "MainColor", function() ab.apply() end)
    ag.colorPicker(aM, "Accent color",      "AccentColor", function() ab.apply() end)
    ag.colorPicker(aM, "Outline color",     "OutlineColor", function() ab.apply() end)
    ag.colorPicker(aM, "Font color",        "FontColor", function() ab.apply() end)
    ag.dropdown(aM, "Font Face", "FontFace", v.FontOptions, function() ab.apply() end)
    ar = ag.dropdown(aM, "Theme list", "Theme", ab.listNames())
    ag.button(aM, "Load theme", function() ab.load(w.Theme) end)
    ag.button(aM, "Overwrite theme", function()
        if ab.saveCurrent(w.Theme) then E.send("Saved theme: " .. w.Theme) end
    end)
end

local aN, aO = ag.newCard(aK, { title = "Configuration", height = 320 })
do
    ag.textInput(aO, "Config name", "_cfgName", "name")
    ag.button(aO, "Create config", function() ac.save(w._cfgName or "") end)
    aq = ag.dropdown(aO, "Config list", "_cfgPicked", ac.list())
    ag.button(aO, "Refresh list", function() aq:setOptions(ac.list()) end)
    ag.button(aO, "Load config",      function() ac.load(w._cfgPicked or "") end)
    ag.button(aO, "Overwrite config", function() ac.save(w._cfgPicked or "") end)
    ag.button(aO, "Delete config",    function()
        ac.delete(w._cfgPicked or "")
        aq:setOptions(ac.list())
    end)
    ag.button(aO, "Set autoload",   function()
        if w._cfgPicked and w._cfgPicked ~= "" then
            ac.setAutoload(w._cfgPicked)
            if ao then ao:setText("Current autoload config: " .. w.AutoloadConfig) end
            E.send("Autoload set: " .. w.AutoloadConfig)
        end
    end)
    ag.button(aO, "Reset autoload", function()
        ac.resetAutoload()
        if ao then ao:setText("Current autoload config: none") end
    end)
    ao = ag.label(aO,
        "Current autoload config: " .. (ac.getAutoload() ~= "" and ac.getAutoload() or "none"))
    ag.textInput(aO, "Import Data", "_importData", "paste exported config here")
    ag.button(aO, "Export config", function()
        local aP = ac.exportCurrent()
        pcall(setclipboard, aP)
        E.send("Exported to clipboard.")
    end)
    ag.button(aO, "Import config", function() ac.importString(w._importData or "") end)
end

local aP, aQ = ag.newCard(aJ, { title = "Menu", height = 110 })
do
    ag.keybind(aQ, "Menu bind", "MenuBind")
    ag.toggle(aQ, "Autoexecute", "Autoexecute", function(aR)
        if aR then
            
            local aS = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/kyronshaw912-collab/NameHub/main/loader.lua"))() end)'
            local aT = { "autoexec/", "auto_exec/", "autoexecute/" }
            local aU
            for aV, aW in ipairs(aT) do
                local aX = pcall(b.writefile, aW .. "NameHubJB_loader.lua", aS)
                if aX then aU = aW; break end
            end
            if aU then E.send("Autoexec written: " .. aU) else E.send("Autoexec unsupported by executor.") end
        end
    end)
    ag.dropdown(aQ, "Notification Side", "NotificationSide", v.NotifySides)
end




ak.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local aR = ak.searchBox.Text:lower()
    for aS, aT in pairs(z) do
        if aT.instance and aT.label and aT.instance.Parent then
            local aU = (aR == "") or aT.label:lower():find(aR, 1, true)
            aT.instance.Visible = aU and true or false
        end
    end
end)




C.conn("ui_toggle", f.InputBegan:Connect(function(aR, aS)
    if aS then return end
    if aR.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if aR.KeyCode.Name == w.MenuBind then
        w.UIVisible = not w.UIVisible
        ak.win.Visible = w.UIVisible
    end
end))




C.conn("stats_tick", e.Heartbeat:Connect(function()
    if not w.Alive then return end
    if al then al:setText("Coins Gained: " .. tostring(w.CoinsGained)) end
    if w.StartTime and w.StatsCounting then
        local aR = os.time() - w.StartTime
        if am  then am:setText("Time Elapsed: " .. C.fmtTime(aR)) end
        if an then
            local aS = aR > 0 and (w.CoinsGained / (aR / 60)) or 0
            an:setText(("Rate: %.1f/min"):format(aS))
        end
    else
        if am  then am:setText("Time Elapsed: N/A") end
        if an then an:setText("Rate: N/A") end
    end
end))




C.conn("charadded", q.CharacterAdded:Connect(function()
    task.wait(0.2)
    if w.Fly then O.enable() end
    F.applySpeed()
    F.applyAnchor()
end))




getgenv()._NameHubJB_Alive  = true
getgenv()._NameHubJB_Unload = aj

aa()
S.attachAutoRespawn()
T.attachWatchers()
U.attach()
V.attachInterval()
M.start()


do
    local aR = ac.getAutoload()
    if aR ~= "" then
        w.AutoloadConfig = aR
        ac.load(aR)
        if ao then ao:setText("Current autoload config: " .. aR) end
    end
end

ab.apply()
E.send(v.Brand .. " " .. v.SubBrand .. " " .. a .. " loaded.", 4)

return true
