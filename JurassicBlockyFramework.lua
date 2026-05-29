












local a = "v2.0.4 NameHub (jb-npc-target-20260529)"




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
    
    
    
    
    
    SkipPlayers       = true,

    
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
    UIScale           = 1,
    _ZoomPick         = "100%",

    
    Alive             = true,
    UIVisible         = true,
}

local x      = {}      
local y = {}      
local z    = {}      
local A     = {}      
local B   = {}      



local C




local D = {}

function D.safe(E, F)
    return function(...)
        local G, H = pcall(E, ...)
        if not G then
            warn(("[%s][%s] %s"):format(v.Brand, F or "?", H))
        end
        return G
    end
end

function D.spawn(E, F)
    return task.spawn(D.safe(E, F or "spawn"))
end

function D.conn(E, F)
    if x[E] and x[E].Connected then x[E]:Disconnect() end
    x[E] = F
    return F
end

function D.disconnect(E)
    if x[E] and x[E].Connected then x[E]:Disconnect() end
    x[E] = nil
end

function D.disconnectAll()
    for E, F in pairs(x) do
        if F and F.Connected then pcall(function() F:Disconnect() end) end
        x[E] = nil
    end
end

function D.rand(E) return (E or "_") .. tostring(math.random(100000, 999999)) end

function D.distance(E, F)
    if not E or not F then return math.huge end
    local G = typeof(E) == "Instance" and E.Position or E
    local H = typeof(F) == "Instance" and F.Position or F
    return (G - H).Magnitude
end

function D.contains(E, F)
    for G, H in ipairs(E) do if H == F then return true end end
    return false
end

function D.shallowCopy(E)
    local F = {}
    for G, H in pairs(E) do F[G] = H end
    return F
end

function D.color3ToHex(E)
    return string.format("#%02X%02X%02X",
        math.floor(E.R * 255 + 0.5),
        math.floor(E.G * 255 + 0.5),
        math.floor(E.B * 255 + 0.5))
end

function D.color3ToInt(E)
    return math.floor(E.R * 255) * 65536 + math.floor(E.G * 255) * 256 + math.floor(E.B * 255)
end

function D.color3ToTable(E)
    return { math.floor(E.R * 255), math.floor(E.G * 255), math.floor(E.B * 255) }
end

function D.tableToColor3(E)
    if type(E) ~= "table" or #E < 3 then return Color3.new(1, 1, 1) end
    return Color3.fromRGB(E[1], E[2], E[3])
end

function D.tween(E, F, G)
    local H = TweenInfo.new(F or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    g:Create(E, H, G):Play()
end

function D.fmtTime(E)
    E = math.max(0, math.floor(E))
    local F = math.floor(E / 3600)
    local G = math.floor((E % 3600) / 60)
    local H = E % 60
    if F > 0 then return string.format("%dh %dm %ds", F, G, H) end
    if G > 0 then return string.format("%dm %ds", G, H) end
    return string.format("%ds", H)
end




local E = {}

function E.encode(F)
    local G, H = pcall(function() return l:JSONEncode(F) end)
    return G and H or "{}"
end

function E.decode(F)
    if type(F) ~= "string" or #F == 0 then return {} end
    local G, H = pcall(function() return l:JSONDecode(F) end)
    return G and H or {}
end




local F = {}

function F.send(G, H)
    H = H or 3
    if not _G._NHJB_NotifyGui or not _G._NHJB_NotifyGui.Parent then
        local I = Instance.new("ScreenGui")
        I.Name = D.rand("_NHJB_NF_")
        I.IgnoreGuiInset = true
        I.ResetOnSpawn   = false
        I.DisplayOrder   = 1000000
        local J = pcall(function() I.Parent = m end)
        if not J then
            local K = q:WaitForChild("PlayerGui", 5)
            if K then I.Parent = K end
        end
        _G._NHJB_NotifyGui = I
    end

    local I = Instance.new("Frame")
    I.Size = UDim2.fromOffset(280, 50)
    I.BackgroundColor3 = w.MainColor
    I.BorderSizePixel = 0
    I.Parent = _G._NHJB_NotifyGui
    Instance.new("UICorner", I).CornerRadius = UDim.new(0, 8)
    local J = Instance.new("UIStroke", I)
    J.Color = w.AccentColor
    J.Transparency = 0.5

    local K = Instance.new("TextLabel", I)
    K.Size = UDim2.new(1, -20, 1, -10)
    K.Position = UDim2.fromOffset(10, 5)
    K.BackgroundTransparency = 1
    K.Text = tostring(G)
    K.TextColor3 = w.FontColor
    K.Font = Enum.Font[w.FontFace] or Enum.Font.Gotham
    K.TextSize = 12
    K.TextWrapped = true
    K.TextXAlignment = Enum.TextXAlignment.Left

    table.insert(B, I)
local L=function()        

local L = w.NotificationSide
        local M = 0
        for N, O in ipairs(B) do
            if O == I then M = N break end
        end
        local N = 10 + (M - 1) * 58
        if L == "Right"  then I.Position = UDim2.new(1, -290, 0, N) end
        if L == "Left"   then I.Position = UDim2.new(0,   10, 0, N) end
        if L == "Top"    then I.Position = UDim2.new(0.5, -140 + (M - 1) * 0, 0, N) end
        if L == "Bottom" then I.Position = UDim2.new(0.5, -140, 1, -60 - (M - 1) * 58) end
end
    
L()
    task.delay(0, function()
        for M, N in ipairs(B) do
            local O = 0
            for P, Q in ipairs(B) do if Q == N then O = P break end end
            if O > 0 then
                local P = 10 + (O - 1) * 58
                local Q = w.NotificationSide
                if Q == "Right"  then N.Position = UDim2.new(1, -290, 0, P) end
                if Q == "Left"   then N.Position = UDim2.new(0,   10, 0, P) end
                if Q == "Bottom" then N.Position = UDim2.new(0.5, -140, 1, -60 - (O - 1) * 58) end
            end
        end
    end)

    task.delay(H, function()
        if not I or not I.Parent then return end
        D.tween(I, 0.25, { BackgroundTransparency = 1 })
        for M, N in ipairs(I:GetDescendants()) do
            if N:IsA("TextLabel") then D.tween(N, 0.25, { TextTransparency = 1 }) end
            if N:IsA("UIStroke")  then D.tween(N, 0.25, { Transparency = 1 })     end
        end
        task.wait(0.3)
        for M = #B, 1, -1 do
            if B[M] == I then table.remove(B, M) break end
        end
        I:Destroy()
    end)
end




local G = {}

function G.get()           return q.Character end
function G.root()
    local H = G.get(); if not H then return nil end
    return H:FindFirstChild("HumanoidRootPart") or H.PrimaryPart
end
function G.humanoid()
    local H = G.get(); if not H then return nil end
    return H:FindFirstChildOfClass("Humanoid")
end

function G.applySpeed()
    local H = G.humanoid(); if not H then return end
    H.WalkSpeed = w.Speed
end

function G.applyAnchor()
    local H = G.root(); if not H then return end
    H.Anchored = w.Anchored
end




local H = {}

local function walk(I, J, K)
    K = K or {}
    if not I or K[I] then return end
    K[I] = true
    for L, M in ipairs(I:GetChildren()) do
        J(M)
        walk(M, J, K)
    end
end


function H.remoteByName(I)
    if not I or I == "" then return nil end
    local J
    walk(i, function(K)
        if J then return end
        if (K:IsA("RemoteEvent") or K:IsA("RemoteFunction")) and K.Name == I then
            J = K
        end
    end)
    return J
end


function H.remoteByKeywords(I)
    for J, K in ipairs(I or {}) do
        local L = K:lower()
        local M
        walk(i, function(N)
            if M then return end
            if N:IsA("RemoteEvent") or N:IsA("RemoteFunction") then
                if N.Name:lower():find(L, 1, true) then M = N end
            end
        end)
        if M then return M, K end
    end
    return nil, nil
end

function H.allRemotes(I)
    I = I or 300
    local J = {}
    walk(i, function(K)
        if #J >= I then return end
        if K:IsA("RemoteEvent") or K:IsA("RemoteFunction") then
            J[#J + 1] = K:GetFullName() .. "  [" .. K.ClassName .. "]"
        end
    end)
    return J
end




local I = {}

function I.allWithHumanoid()
    local J = {}
    for K, L in ipairs(h:GetDescendants()) do
        if L:IsA("Model") and L ~= G.get() then
            local M = L:FindFirstChildOfClass("Humanoid")
            local N = L:FindFirstChild("HumanoidRootPart") or L.PrimaryPart
            if M and N and M.Health > 0 then J[#J + 1] = { model = L, hum = M, root = N } end
        end
    end
    return J
end

function I.matchesName(J, K)
    local L = d:GetPlayerFromCharacter(J) ~= nil

    if K == "Players"  then return L end
    if K == "All NPCs" then return not L end

    
    
    
    
    
    
    if w.SkipPlayers and L then return false end

    if not K or K == "" then return true end
    local M = J.Name:lower()
    return M:find(K:lower(), 1, true) ~= nil
end

function I.bestByPriority(J)
    local K = I.allWithHumanoid()
    local L   = G.root()
    if not L then return nil end

    
    for M, N in ipairs(J or {}) do
        local O ,P=(math.huge
)        for Q, R in ipairs(K) do
            if I.matchesName(R.model, N) then
                if w.MaxTargetHP == 0 or R.hum.Health <= w.MaxTargetHP then
                    if R.hum.Health >= w.MinTargetHP then
                        local S = D.distance(L, R.root)
                        if S < O then P, O = R, S end
                    end
                end
            end
        end
        if P then return P end
    end
    return nil
end

function I.dump(J)
    J = J or 50
    local K  = G.root()
    local L = {}
    for M, N in ipairs(I.allWithHumanoid()) do
        if #L >= J then break end
        local O = K and D.distance(K, N.root) or -1
        local P = d:GetPlayerFromCharacter(N.model)
        L[#L + 1] = ("%-30s HP=%-6.1f dist=%-6.1f %s"):format(
            N.model.Name:sub(1, 30), N.hum.Health, O, P and ("player=" .. P.Name) or "NPC")
    end
    return L
end




local J = {}
local K, L

function J.findRemote()
    if K and K.Parent then return K, L end
    
    for M, N in ipairs(v.JB_AttackNames) do
        local O = H.remoteByName(N)
        if O then K, L = O, N; return O, N end
    end
    
    local M, N = H.remoteByKeywords(v.AttackKeywords)
    K, L = M, N or ""
    return M, L
end

function J.invalidateCache() K, L = nil, nil end

function J.fireAt(M)
    local N, O = J.findRemote()
    if not N or not M then return false end

    local P
    if O == "successOnHit" then
        P = {
            { M.hum },
            { M.model },
            { M.root },
            { M.hum, M.root.Position },
            { M.model, M.root.Position },
            { { Target = M.hum }   },
            { { Target = M.model } },
        }
    elseif O == "tap" then
        P = {
            { M.root.Position },
            { M.model },
            { },
        }
    else
        P = { { M.model }, { M.hum }, { M.root }, { M.model.Name }, { } }
    end

    for Q, R in ipairs(P) do
        local S = pcall(function()
            if N:IsA("RemoteEvent") then N:FireServer(table.unpack(R))
            else N:InvokeServer(table.unpack(R)) end
        end)
        if S then return true end
    end
    return false
end


function J.collectNearby()
    for M, N in ipairs(v.JB_LootNames) do
        local O = H.remoteByName(N)
        if O then
            pcall(function()
                if O:IsA("RemoteEvent") then O:FireServer() else O:InvokeServer() end
            end)
        end
    end
end




local M = {}

function M.start()
    D.spawn(function()
        local N, O, P = 0, 0, 0
        while w.Alive and w.Autofarm do
            P = P + 1
            local Q = G.root()
            if Q then
                local R = (w.FarmPriority and #w.FarmPriority > 0) and w.FarmPriority or { w.FarmTarget }
                local S = I.bestByPriority(R)

                local T = G.humanoid()
                local U = (T and w.DisengageAt > 0 and T.Health < w.DisengageAt)

                if not U and S and S.model.Parent then
                    local V = D.distance(Q, S.root)
                    if V > w.Range then
                        local W = CFrame.new(S.root.Position) * CFrame.new(w.OffsetX, w.OffsetY, math.min(8, w.Range * 0.2))
                        W = CFrame.lookAt(W.Position, S.root.Position)
                        pcall(function() Q.CFrame = W end)
                    end

                    if tick() >= N then
                        local W = J.fireAt(S)
                        if W and w.StatsCounting then
                            w.CoinsGained = w.CoinsGained + 1
                        end
                        N = tick() + 0.35
                    end
                end

                if w.AutoLoot and tick() >= O then
                    J.collectNearby()
                    O = tick() + 3
                end
            end
            task.wait(0.1)
        end
    end, "AutoFarm.loop")
end




local N = {}

function N.start()
    D.spawn(function()
        local O = 0
        while w.Alive do
            if w.AutoAttackNearby or w.AutoAttack or w.AutoTPToPlayer then
                local P = G.root()
                if P then
                    local Q
                    if w.AutoTPToPlayer and w.TargetPlayer ~= "" then
                        local R = d:FindFirstChild(w.TargetPlayer)
                        if R and R.Character then
                            local S = R.Character:FindFirstChild("HumanoidRootPart")
                            local T = R.Character:FindFirstChildOfClass("Humanoid")
                            if S and T then
                                local U = CFrame.new(S.Position) * CFrame.new(w.OffsetX, w.OffsetY, 0)
                                U = CFrame.lookAt(U.Position, S.Position)
                                pcall(function() P.CFrame = U end)
                                if w.AutoAttack then
                                    Q = { model = R.Character, hum = T, root = S }
                                end
                            end
                        end
                    end

                    if not Q and w.AutoAttackNearby then
                        Q = I.bestByPriority({ "Players" })
                    end
                    if not Q and w.AutoAttack then
                        Q = I.bestByPriority(w.FarmPriority)
                    end

                    if Q and tick() >= O then
                        local R = D.distance(P, Q.root)
                        if R <= w.Range then
                            local S = G.humanoid()
                            if not S or S.Health >= w.DisengageAt or w.DisengageAt == 0 then
                                J.fireAt(Q)
                                O = tick() + 0.35
                            end
                        end
                    end

                    if w.TargetPOV and Q and Q.root then
                        pcall(function()
                            p.CameraType    = Enum.CameraType.Scriptable
                            p.CFrame        = CFrame.new(Q.root.Position + Vector3.new(0, 8, 12), Q.root.Position)
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




local O = {}

function O.clearAll()
    for P, Q in pairs(y) do
        if Q and Q.Parent then Q:Destroy() end
        y[P] = nil
    end
end

function O.applyHighlight(P, Q)
    if y[P] then return end
    local R = Instance.new("Highlight")
    R.Adornee = P
    R.FillColor = Q
    R.OutlineColor = Q
    R.FillTransparency    = w.FillTransparency
    R.OutlineTransparency = w.OutlineTransparency
    R.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    R.Parent = P
    y[P] = R
end

function O.refresh()
    
    for P, Q in pairs(y) do
        if Q and Q.Parent then
            Q.FillTransparency    = w.FillTransparency
            Q.OutlineTransparency = w.OutlineTransparency
        end
    end
end

function O.start()
    D.spawn(function()
        while w.Alive do
            
            for P, Q in pairs(y) do
                if not P.Parent or not Q.Parent then
                    if Q.Parent then Q:Destroy() end
                    y[P] = nil
                end
            end

            if w.GoatESP or w.AmberESP then
                for P, Q in ipairs(I.allWithHumanoid()) do
                    local R = Q.model.Name:lower()
                    if w.GoatESP and (R:find("goat", 1, true) or R:find("dino", 1, true) or d:GetPlayerFromCharacter(Q.model) == nil) then
                        O.applyHighlight(Q.model, w.GoatESPColor)
                    end
                end
                if w.AmberESP then
                    for P, Q in ipairs(h:GetDescendants()) do
                        if Q:IsA("Model") or Q:IsA("BasePart") then
                            local R = Q.Name:lower()
                            if R:find("amber", 1, true) and not y[Q] then
                                O.applyHighlight(Q, w.AmberESPColor)
                            end
                        end
                    end
                end
            else
                O.clearAll()
            end
            task.wait(0.5)
        end
        O.clearAll()
    end, "ESP.loop")
end




local P = {}
local Q, R, S

function P.enable()
    local T = G.get(); if not T then return end
    local U = G.root(); if not U then return end
    local V = G.humanoid()

    P.disable()
    S = {}

    Q = Instance.new("BodyVelocity")
    Q.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Q.Velocity = Vector3.zero
    Q.Parent = U

    R = Instance.new("BodyGyro")
    R.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    R.P = 1000
    R.CFrame = U.CFrame
    R.Parent = U

    if V then V.PlatformStand = true end

    D.conn("fly_input_began", f.InputBegan:Connect(function(W, X)
        if X then return end
        S[W.KeyCode] = true
    end))
    D.conn("fly_input_ended", f.InputEnded:Connect(function(W)
        S[W.KeyCode] = false
    end))

    D.conn("fly_step", e.RenderStepped:Connect(function()
        if not (w.Fly and Q and Q.Parent) then return end
        local W = p
        if not W then return end
        local X = Vector3.zero
        if S[Enum.KeyCode.W]      then X = X + W.CFrame.LookVector end
        if S[Enum.KeyCode.S]      then X = X - W.CFrame.LookVector end
        if S[Enum.KeyCode.A]      then X = X - W.CFrame.RightVector end
        if S[Enum.KeyCode.D]      then X = X + W.CFrame.RightVector end
        if S[Enum.KeyCode.Space]  then X = X + Vector3.new(0, 1, 0) end
        if S[Enum.KeyCode.LeftControl] then X = X - Vector3.new(0, 1, 0) end

        if X.Magnitude > 0 then X = X.Unit * w.FlySpeed
        else X = Vector3.zero end
        Q.Velocity = X
        R.CFrame = W.CFrame
    end))
end

function P.disable()
    D.disconnect("fly_input_began")
    D.disconnect("fly_input_ended")
    D.disconnect("fly_step")
    if Q then pcall(function() Q:Destroy() end); Q = nil end
    if R then pcall(function() R:Destroy() end); R = nil end
    local T = G.humanoid()
    if T then pcall(function() T.PlatformStand = false end) end
    S = nil
end




local T = {}

function T.respawn()
    local U = G.humanoid()
    if U then
        U.Health = 0
    else
        pcall(function() q.Character:BreakJoints() end)
    end
end

function T.openMenu()
    local U = H.remoteByKeywords(v.MenuKeywords)
    if U then
        pcall(function()
            if U:IsA("RemoteEvent") then U:FireServer() else U:InvokeServer() end
        end)
        return
    end
    
    pcall(function() k:CaptureController() end)
end

function T.attachAutoRespawn()
    D.conn("char_died_watch", q.CharacterAdded:Connect(function(U)
        local V = U:WaitForChild("Humanoid", 5)
        if not V then return end
        V.Died:Connect(function()
            if not w.AutoRespawn then return end
            task.wait(w.RespawnDelay)
            if not w.AutoRespawn then return end
            
            pcall(function() q:LoadCharacter() end)
        end)
    end))
end




local U = {}

function U.fetchServers()
    local V = game.PlaceId
    local W = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(V)
    local X = c({ Url = W, Method = "GET" })
    if not X or X.StatusCode ~= 200 then return {} end
    local Y = E.decode(X.Body or "")
    local Z = {}
    for _, aa in ipairs(Y.data or {}) do
        if aa.id and aa.id ~= game.JobId then
            Z[#Z + 1] = { id = aa.id, playing = aa.playing or 0, max = aa.maxPlayers or 0 }
        end
    end
    return Z
end

function U.joinJobId(aa)
    if not aa or aa == "" then return end
    pcall(function() n:TeleportToPlaceInstance(game.PlaceId, aa, q) end)
end

function U.rejoin()
    pcall(function() n:TeleportToPlaceInstance(game.PlaceId, game.JobId, q) end)
end

function U.randomHop()
    local aa = U.fetchServers()
    if #aa == 0 then F.send("No servers found.") return end
    local V = aa[math.random(1, #aa)]
    U.joinJobId(V.id)
end

function U.attachWatchers()
    
    D.conn("friend_watch", d.PlayerAdded:Connect(function(aa)
        if not w.HopOnFriend then return end
        local V, W = pcall(function() return q:IsFriendsWith(aa.UserId) end)
        if V and W then U.randomHop() end
    end))

    
    D.spawn(function()
        while w.Alive do
            if w.HopOnPlayerCount > 0 and #d:GetPlayers() <= w.HopOnPlayerCount then
                U.randomHop()
                task.wait(10)
            end
            task.wait(5)
        end
    end, "Hop.thresholdLoop")
end




local aa = {}

function aa.isAdmin(V)
    V = V:lower()
    for W, X in ipairs(w.AdminList) do
        if V:find(X, 1, true) then return true end
    end
    return false
end

function aa.attach()
    D.conn("admin_watch", d.PlayerAdded:Connect(function(V)
        if not w.KickOnAdmin then return end
        if aa.isAdmin(V.Name) or aa.isAdmin(V.DisplayName or "") then
            F.send("Admin detected: " .. V.Name .. " — kicking self.", 5)
            task.wait(0.3)
            pcall(function() q:Kick("[NameHub] Admin detected: " .. V.Name) end)
        end
    end))

    
    D.spawn(function()
        task.wait(2)
        if not w.KickOnAdmin then return end
        for V, W in ipairs(d:GetPlayers()) do
            if W ~= q and (aa.isAdmin(W.Name) or aa.isAdmin(W.DisplayName or "")) then
                F.send("Admin in server: " .. W.Name .. " — kicking self.", 5)
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
    if w.WebhookLink == "" then F.send("Set a webhook URL first.") return end

    local Y = w.StartTime and (os.time() - w.StartTime) or 0
    local Z    = Y > 0 and (w.CoinsGained / (Y / 60)) or 0

    local _ = w.WebhookAnonymous and "Anonymous" or q.Name
    local ab       = w.WebhookTimezone
    local ac   = os.time() + ab * 3600
    local ad   = os.date("!%Y-%m-%d %H:%M:%S", ac) .. (" UTC%+d"):format(ab)

    local ae = {
        username = "NameHub JB",
        embeds = {{
            title  = "NameHub Jurassic Blocky — Stats",
            color  = D.color3ToInt(w.WebhookColor),
            fields = {
                { name = "User",          value = _,                                inline = true },
                { name = "Server",        value = ("`%s`"):format(game.JobId or "n/a"),    inline = true },
                { name = "Time",          value = ad,                                  inline = false },
                { name = "Coins Gained",  value = tostring(w.CoinsGained),                 inline = true },
                { name = "Rate (per min)",value = string.format("%.1f", Z),             inline = true },
                { name = "Elapsed",       value = D.fmtTime(Y),                      inline = true },
                { name = "Auto-Farm",     value = w.Autofarm and "ON" or "OFF",            inline = true },
                { name = "Target",        value = w.FarmTarget,                            inline = true },
                { name = "Dino",          value = w.AutofarmDino,                          inline = true },
            },
            footer = { text = a },
        }},
    }
    local af = E.encode(ae)
    local ag = pcall(function()
        c({
            Url     = w.WebhookLink,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = af,
        })
    end)
    if ag then
        W = tick()
        if X then F.send("Webhook sent.") end
    elseif X then
        F.send("Webhook failed.")
    end
end

function V.attachInterval()
    D.spawn(function()
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
local ab=function()    




D.conn("antiafk", q.Idled:Connect(function()
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

local ac = {}

function ac.applyValues(ad)
    w.BgColor       = ad.Bg
    w.MainColor     = ad.Main
    w.AccentColor   = ad.Accent
    w.OutlineColor  = ad.Outline
    w.FontColor     = ad.Font
end

function ac.apply()
    for ad, ae in pairs(z) do
        if ae.themeUpdate then pcall(ae.themeUpdate) end
    end
end

function ac.load(ad)
    local ae = A[ad]
    if not ae then return end
    w.Theme = ad
    ac.applyValues(ae)
    ac.apply()
end

function ac.listNames()
    local ad = {}
    for ae in pairs(A) do ad[#ad + 1] = ae end
    table.sort(ad)
    return ad
end

function ac.saveCurrent(ad)
    if not ad or ad == "" then return false end
    local ae = {
        Bg      = D.color3ToTable(w.BgColor),
        Main    = D.color3ToTable(w.MainColor),
        Accent  = D.color3ToTable(w.AccentColor),
        Outline = D.color3ToTable(w.OutlineColor),
        Font    = D.color3ToTable(w.FontColor),
    }
    pcall(b.writefile, t .. "/" .. ad .. ".json", E.encode(ae))
    return true
end




local ad = {}

local ae = {
    "Autofarm", "FarmTarget", "FarmPriority", "Speed", "AutofarmDino", "SkipPlayers", "AutoLoot",
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
    "UIScale", "_ZoomPick",
}
local af=function()    

local af = {}
    for ag, X in ipairs(ae) do
        local Y = w[X]
        if typeof(Y) == "Color3" then
            af[X] = { _c3 = true, v = D.color3ToTable(Y) }
        else
            af[X] = Y
        end
    end
    return af
end local ag=function(

ag)    
for X, Y in pairs(ag or {}) do
        if type(Y) == "table" and Y._c3 then
            w[X] = D.tableToColor3(Y.v)
        else
            w[X] = Y
        end
    end
end

function ad.save(X)
    if not X or X == "" then F.send("Config name required.") return end
    pcall(b.writefile, s .. "/" .. X .. ".json", E.encode(af()))
    F.send("Saved config: " .. X)
end

function ad.load(X)
    if not X or X == "" then return end
    if not b.isfile(s .. "/" .. X .. ".json") then F.send("No config: " .. X) return end
    local Y = ""
    pcall(function() Y = b.readfile(s .. "/" .. X .. ".json") end)
    ag(E.decode(Y))
    
    for Z, _ in pairs(z) do
        if _.refresh then pcall(_.refresh) end
    end
    ac.apply()
    if C and C.uiScale then C.uiScale.Scale = w.UIScale or 1 end
    F.send("Loaded config: " .. X)
end

function ad.delete(X)
    if not X or X == "" then return end
    pcall(b.delfile, s .. "/" .. X .. ".json")
    F.send("Deleted config: " .. X)
end

function ad.list()
    local X = {}
    local Y, Z = pcall(b.listfiles, s)
    if not Y or type(Z) ~= "table" then return X end
    for _, ah in ipairs(Z) do
        local ai = ah:match("([^/\\]+)%.json$")
        if ai then X[#X + 1] = ai end
    end
    table.sort(X)
    return X
end

function ad.setAutoload(ah)
    pcall(b.writefile, u, ah or "")
    w.AutoloadConfig = ah or ""
end

function ad.resetAutoload()
    pcall(b.delfile, u)
    w.AutoloadConfig = ""
end

function ad.getAutoload()
    if not b.isfile(u) then return "" end
    local ah = ""
    pcall(function() ah = b.readfile(u) end)
    return (ah or ""):gsub("%s+$", "")
end

function ad.exportCurrent()
    return E.encode(af())
end

function ad.importString(ah)
    if not ah or ah == "" then F.send("Nothing to import.") return end
    local ai = E.decode(ah)
    if not ai or not next(ai) then F.send("Invalid import data.") return end
    ag(ai)
    for X, Y in pairs(z) do
        if Y.refresh then pcall(Y.refresh) end
    end
    ac.apply()
    if C and C.uiScale then C.uiScale.Scale = w.UIScale or 1 end
    F.send("Imported config.")
end





local ah = {}
local ai=function(
ai, X, Y)    
local Z = Instance.new(ai)
    for _, aj in pairs(X or {}) do Z[_] = aj end
    if Y then for aj, _ in ipairs(Y) do _.Parent = Z end end
    return Z
end local aj=function()

return Enum.Font[w.FontFace] or Enum.Font.Gotham end


function ah.newWindow(X)
    X = X or {}
    local Y = ai("ScreenGui", {
        Name = D.rand("_NHJB_"),
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

    local _ = ai("Frame", {
        Name = "Window",
        Position = UDim2.fromOffset(60, 60),
        Size     = UDim2.fromOffset(X.width or 760, X.height or 520),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel  = 0,
        Active           = true,
        Parent           = Y,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 10), Parent = _ })
    local ak = ai("UIStroke", { Color = w.OutlineColor, Transparency = 0.6, Thickness = 1, Parent = _ })

    
    
    
    
    local al = Instance.new("UIScale")
    al.Scale  = w.UIScale or 1
    al.Parent = _

    
    local am = ai("TextLabel", {
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
    
    local an = ai("Frame", {
        Parent = _,
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 10), Parent = an })
    
    ai("Frame", {
        Parent = an,
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.new(0, 12, 1, 0),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })

    local ao = ai("TextLabel", {
        Parent = an,
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.fromOffset(20, 18),
        BackgroundTransparency = 1,
        Text = v.Brand,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = w.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local ap = ai("Frame", {
        Parent = an,
        Position = UDim2.fromOffset(0, 70),
        Size = UDim2.new(1, 0, 1, -90),
        BackgroundTransparency = 1,
    })
    local aq = ai("UIListLayout", {
        Parent = ap,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })

    
    local ar = ai("Frame", {
        Parent = _,
        Position = UDim2.new(0, 150, 0, 0),
        Size = UDim2.new(1, -150, 0, 60),
        BackgroundTransparency = 1,
    })

    local as = ai("Frame", {
        Parent = ar,
        Position = UDim2.fromOffset(20, 16),
        Size = UDim2.new(1, -80, 0, 28),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 6), Parent = as })

    local at = ai("TextLabel", {
        Parent = as,
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.fromOffset(2, 0),
        BackgroundTransparency = 1,
        Text = "Q",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
    })

    local au = ai("TextBox", {
        Parent = as,
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.new(1, -36, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search",
        TextColor3 = w.FontColor,
        PlaceholderColor3 = Color3.fromRGB(120, 130, 140),
        Font = aj(),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })

    
    
    
    
    
    
    do
        local av, aw, ax
local ay=function(
ay, az)            
if not az or not az.Parent then return false end
            local aA, aB = az.AbsolutePosition, az.AbsoluteSize
            return ay.X >= aA.X and ay.X <= aA.X + aB.X
               and ay.Y >= aA.Y and ay.Y <= aA.Y + aB.Y
end local az=function(

az, aA)            
az.Active = true
            az.InputBegan:Connect(function(aB)
                if aB.UserInputType ~= Enum.UserInputType.MouseButton1
                   and aB.UserInputType ~= Enum.UserInputType.Touch then return end
                local aC = aB.Position
                if aA then
                    for aD, aE in ipairs(aA) do
                        if ay(aC, aE) then return end
                    end
                end
                av  = true
                aw = Vector2.new(aC.X, aC.Y)
                ax  = _.Position
                aB.Changed:Connect(function()
                    if aB.UserInputState == Enum.UserInputState.End then av = false end
                end)
            end)
end
        
az(am)
        az(ao)
        az(ar, { as })
        az(an, { ap })   

        f.InputChanged:Connect(function(aA)
            if not av then return end
            if aA.UserInputType ~= Enum.UserInputType.MouseMovement
               and aA.UserInputType ~= Enum.UserInputType.Touch then return end
            local aB = aA.Position
            local aC = Vector2.new(aB.X, aB.Y) - aw
            _.Position = UDim2.new(
                ax.X.Scale, ax.X.Offset + aC.X,
                ax.Y.Scale, ax.Y.Offset + aC.Y
            )
        end)
    end

    
    local av = ai("Frame", {
        Parent = _,
        Position = UDim2.new(0, 150, 0, 60),
        Size = UDim2.new(1, -150, 1, -84),
        BackgroundTransparency = 1,
    })

    
    local aw = ai("Frame", {
        Parent = _,
        Position = UDim2.new(0, 150, 1, -24),
        Size = UDim2.new(1, -150, 0, 24),
        BackgroundTransparency = 1,
    })
    ai("TextLabel", {
        Parent = aw,
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        Text = v.SubBrand,
        Font = aj(),
        TextSize = 12,
        TextColor3 = Color3.fromRGB(120, 130, 140),
    })
    local ax = ai("TextLabel", {
        Parent = aw,
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
        local ay, az, aA
        ax.InputBegan:Connect(function(aB)
            if aB.UserInputType == Enum.UserInputType.MouseButton1 or aB.UserInputType == Enum.UserInputType.Touch then
                ay = true
                az = aB.Position
                aA = _.Size
                aB.Changed:Connect(function()
                    if aB.UserInputState == Enum.UserInputState.End then ay = false end
                end)
            end
        end)
        f.InputChanged:Connect(function(aB)
            if ay and (aB.UserInputType == Enum.UserInputType.MouseMovement or aB.UserInputType == Enum.UserInputType.Touch) then
                local aC = aB.Position - az
                
                
                local aD = (al.Scale > 0) and al.Scale or 1
                _.Size = UDim2.new(0, math.max(560, aA.X.Offset + aC.X / aD),
                                     0, math.max(380, aA.Y.Offset + aC.Y / aD))
            end
        end)
    end

    local ay = {
        gui = Y, win = _, sidebar = an, pageList = ap,
        content = av, header = ar, searchBox = au, dragHandle = am,
        pages = {},   
        active = nil,
        winStroke = ak, resize = ax,
        uiScale = al,
    }

    
    table.insert(z, {
        themeUpdate = function()
            _.BackgroundColor3 = w.BgColor
            ak.Color = w.OutlineColor
            an.BackgroundColor3 = w.MainColor
            for az, aA in ipairs(an:GetChildren()) do
                if aA:IsA("Frame") then aA.BackgroundColor3 = w.MainColor end
            end
            ao.TextColor3 = w.AccentColor
            ao.Font = aj()
            as.BackgroundColor3 = w.MainColor
            at.TextColor3 = w.FontColor
            au.TextColor3 = w.FontColor
            au.Font = aj()
            am.TextColor3 = w.FontColor
            ax.TextColor3 = w.FontColor
            for az, aA in pairs(ay.pages) do
                if aA.refreshTheme then pcall(aA.refreshTheme) end
            end
        end
    })

    function ay:addPage(az)
        local aA = ai("TextButton", {
            Parent = ap,
            LayoutOrder = #ap:GetChildren(),
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        })
        local aB = ai("TextLabel", {
            Parent = aA,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.fromOffset(20, 0),
            BackgroundTransparency = 1,
            Text = az,
            Font = aj(),
            TextSize = 13,
            TextColor3 = w.FontColor,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local aC = ai("Frame", {
            Parent = aA,
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = w.AccentColor,
            BorderSizePixel = 0,
            Visible = false,
        })
local aD=function()            


aA.BackgroundColor3 = w.MainColor
            aB.TextColor3 = w.FontColor
            aB.Font = aj()
            aC.BackgroundColor3 = w.AccentColor
end
        
local aE = ai("Frame", {
            Parent = av,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
        })

        ay.pages[az] = {
            btn = aA, frame = aE, label = aB, indicator = aC,
            refreshTheme = aD,
        }

        aA.MouseButton1Click:Connect(function() ay:selectPage(az) end)
        if not ay.active then ay:selectPage(az) end
        return aE
    end

    function ay:selectPage(az)
        for aA, aB in pairs(ay.pages) do
            local aC = (aA == az)
            aB.frame.Visible = aC
            aB.indicator.Visible = aC
            aB.label.TextColor3 = aC and w.AccentColor or w.FontColor
        end
        ay.active = az
    end

    return ay
end


function ah.newColumn(ak, al)
    local am = ai("Frame", {
        Parent = ak,
        Size = UDim2.new(al or 0.5, -12, 1, -20),
        BackgroundTransparency = 1,
    })
    local an = ai("UIListLayout", {
        Parent = am,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })
    return am, an
end


function ah.newCard(ak, al)
    al = al or {}
    local am = ai("Frame", {
        Parent = ak,
        LayoutOrder = al.order or 0,
        Size = UDim2.new(1, 0, 0, al.height or 200),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 8), Parent = am })

    table.insert(z, {
        themeUpdate = function() am.BackgroundColor3 = w.MainColor end
    })

    local an
    local ao = ai("Frame", {
        Parent = am,
        Size = UDim2.new(1, 0, 1, al.tabs and -34 or 0),
        Position = UDim2.fromOffset(0, al.tabs and 34 or 0),
        BackgroundTransparency = 1,
    })

    local ap = {}
    if al.tabs then
        an = ai("Frame", {
            Parent = am,
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.fromOffset(10, 4),
            BackgroundTransparency = 1,
        })
        local aq = 1 / #al.tabs
        for ar, as in ipairs(al.tabs) do
            local at = ai("TextButton", {
                Parent = an,
                Size = UDim2.new(aq, -4, 1, 0),
                Position = UDim2.new((ar - 1) * aq, 2, 0, 0),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                Text = as,
                Font = aj(),
                TextSize = 12,
                TextColor3 = w.FontColor,
                AutoButtonColor = false,
            })
            ai("UICorner", { CornerRadius = UDim.new(0, 6), Parent = at })

            local au = ai("ScrollingFrame", {
                Parent = ao,
                Size = UDim2.new(1, -16, 1, -8),
                Position = UDim2.fromOffset(8, 4),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = w.AccentColor,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Visible = (ar == 1),
            })
            ai("UIListLayout", { Parent = au, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })
            ap[as] = { btn = at, frame = au }

            at.MouseButton1Click:Connect(function()
                for av, aw in pairs(ap) do
                    aw.frame.Visible = (av == as)
                    aw.btn.BackgroundColor3 = (av == as) and w.AccentColor or w.BgColor
                end
            end)

            if ar == 1 then at.BackgroundColor3 = w.AccentColor end

            table.insert(z, {
                themeUpdate = function()
                    at.Font = aj()
                    at.TextColor3 = w.FontColor
                    if au.Visible then at.BackgroundColor3 = w.AccentColor else at.BackgroundColor3 = w.BgColor end
                    au.ScrollBarImageColor3 = w.AccentColor
                end
            })
        end
        return am, ap
    else
        local aq = ai("ScrollingFrame", {
            Parent = ao,
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
        ai("UIListLayout", { Parent = aq, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })

        if al.title then
            local ar = ai("TextLabel", {
                Parent = am,
                Size = UDim2.new(1, -20, 0, 28),
                Position = UDim2.fromOffset(10, 4),
                BackgroundTransparency = 1,
                Text = al.title,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = w.FontColor,
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            ao.Position = UDim2.fromOffset(0, 30)
            ao.Size = UDim2.new(1, 0, 1, -30)
            table.insert(z, {
                themeUpdate = function() ar.TextColor3 = w.FontColor; ar.Font = Enum.Font.GothamBold end
            })
        end

        return am, aq
    end
end





function ah.label(ak, al, am)
    am = am or {}
    local an = ai("TextLabel", {
        Parent = ak,
        LayoutOrder = am.order or 0,
        Size = UDim2.new(1, 0, 0, am.height or 18),
        BackgroundTransparency = 1,
        Text = al,
        Font = aj(),
        TextSize = am.size or 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local ao = { instance = an, setText = function(ao, ap) an.Text = ap end }
    function ao.themeUpdate() an.TextColor3 = w.FontColor; an.Font = aj() end
    table.insert(z, ao)
    return ao
end

function ah.button(ak, al, am)
    local an = ai("TextButton", {
        Parent = ak,
        LayoutOrder = #ak:GetChildren(),
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = al,
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        AutoButtonColor = true,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 6), Parent = an })
    an.MouseButton1Click:Connect(function() pcall(am) end)

    local ao = { instance = an, label = al }
    function ao.themeUpdate()
        an.BackgroundColor3 = w.BgColor
        an.TextColor3 = w.FontColor
        an.Font = aj()
    end
    table.insert(z, ao)
    return ao
end

function ah.toggle(ak, al, am, an)
    local ao = ai("Frame", {
        Parent = ak,
        LayoutOrder = #ak:GetChildren(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    })
    local ap = ai("TextLabel", {
        Parent = ao,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = al,
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local aq = ai("TextButton", {
        Parent = ao,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(36, 18),
        BackgroundColor3 = w.BgColor,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    ai("UICorner", { CornerRadius = UDim.new(1, 0), Parent = aq })
    local ar = ai("Frame", {
        Parent = aq,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = w.FontColor,
        BorderSizePixel = 0,
    })
    ai("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ar })
local as=function()        

local as = w[am]
        if as then
            aq.BackgroundColor3 = w.AccentColor
            ar.Position = UDim2.new(1, -16, 0.5, 0)
        else
            aq.BackgroundColor3 = w.BgColor
            ar.Position = UDim2.new(0, 2, 0.5, 0)
        end
        ar.BackgroundColor3 = w.FontColor
end
    
as()

    aq.MouseButton1Click:Connect(function()
        w[am] = not w[am]
        as()
        if an then pcall(an, w[am]) end
    end)

    local at = { instance = ao, label = al, key = am }
    function at.themeUpdate() ap.TextColor3 = w.FontColor; ap.Font = aj(); as() end
    function at.refresh() as() end
    table.insert(z, at)
    return at
end

function ah.slider(ak, al, am, an, ao, ap, aq)
    ap = ap or 1
    local ar = ai("Frame", {
        Parent = ak,
        LayoutOrder = #ak:GetChildren(),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ar })

    local as = ai("Frame", {
        Parent = ar,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = w.AccentColor,
        BorderSizePixel = 0,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 4), Parent = as })

    local at = ai("TextLabel", {
        Parent = ar,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
    })
local au=function()        

local au = tonumber(w[am]) or an
        au = math.clamp(au, an, ao)
        local av = (ao == an) and 0 or (au - an) / (ao - an)
        as.Size = UDim2.new(av, 0, 1, 0)
        local aw
        if ap < 1 then aw = string.format("%s: %.2f", al, au) else aw = string.format("%s: %d", al, math.floor(au + 0.5)) end
        at.Text = aw
end
    
au()

    local av = false
local aw=function(aw)        
local ax = (aw - ar.AbsolutePosition.X) / ar.AbsoluteSize.X
        ax = math.clamp(ax, 0, 1)
        local ay = an + ax * (ao - an)
        ay = math.floor(ay / ap + 0.5) * ap
        ay = math.clamp(ay, an, ao)
        w[am] = ay
        au()
        if aq then pcall(aq, ay) end
end
    
ar.InputBegan:Connect(function(ax)
        if ax.UserInputType == Enum.UserInputType.MouseButton1 or ax.UserInputType == Enum.UserInputType.Touch then
            av = true
            aw(ax.Position.X)
        end
    end)
    ar.InputEnded:Connect(function(ax)
        if ax.UserInputType == Enum.UserInputType.MouseButton1 or ax.UserInputType == Enum.UserInputType.Touch then
            av = false
        end
    end)
    f.InputChanged:Connect(function(ax)
        if av and (ax.UserInputType == Enum.UserInputType.MouseMovement or ax.UserInputType == Enum.UserInputType.Touch) then
            aw(ax.Position.X)
        end
    end)

    local ax = { instance = ar, label = al, key = am }
    function ax.themeUpdate()
        ar.BackgroundColor3 = w.BgColor
        as.BackgroundColor3 = w.AccentColor
        at.TextColor3 = w.FontColor
        at.Font = aj()
    end
    function ax.refresh() au() end
    table.insert(z, ax)
    return ax
end

function ah.dropdown(ak, al, am, an, ao)
    local ap = ai("Frame", {
        Parent = ak,
        LayoutOrder = #ak:GetChildren(),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    local aq = ai("TextLabel", {
        Parent = ap,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = al,
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local ar = ai("TextButton", {
        Parent = ap,
        Position = UDim2.fromOffset(0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ar })
    local as = ai("TextLabel", {
        Parent = ar,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = tostring(w[am] or "---"),
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local at = ai("TextLabel", {
        Parent = ar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Text = "v",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
    })

    
    local au
local av=function()        
if au then au:Destroy(); au = nil; return end
        local av = ap:FindFirstAncestorOfClass("ScreenGui")
        if not av then return end
        au = ai("Frame", {
            Parent = av,
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        ai("UICorner", { CornerRadius = UDim.new(0, 4), Parent = au })
        ai("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = au })

        local aw = ar.AbsolutePosition
        local ax = ar.AbsoluteSize
        local ay = math.min(160, #an * 22 + 4)
        au.Position = UDim2.fromOffset(aw.X, aw.Y + ax.Y + 2)
        au.Size = UDim2.fromOffset(ax.X, ay)

        local az = ai("ScrollingFrame", {
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
        ai("UIListLayout", { Parent = az, SortOrder = Enum.SortOrder.LayoutOrder })

        for aA, aB in ipairs(an) do
            local aC = ai("TextButton", {
                Parent = az,
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                Text = tostring(aB),
                Font = aj(),
                TextSize = 12,
                TextColor3 = w.FontColor,
                AutoButtonColor = true,
                ZIndex = 52,
            })
            aC.MouseButton1Click:Connect(function()
                w[am] = aB
                as.Text = tostring(aB)
                if au then au:Destroy(); au = nil end
                if ao then pcall(ao, aB) end
            end)
        end
end
    
ar.MouseButton1Click:Connect(av)

    local aw = { instance = ap, label = al, key = am, options = an }
    function aw.setOptions(ax, ay)
        an = ay or {}
        aw.options = an
        if au then au:Destroy(); au = nil end
    end
    function aw.themeUpdate()
        aq.TextColor3 = w.FontColor; aq.Font = aj()
        ar.BackgroundColor3 = w.BgColor
        as.TextColor3 = w.FontColor; as.Font = aj()
        at.TextColor3 = w.FontColor
    end
    function aw.refresh() as.Text = tostring(w[am] or "---") end
    table.insert(z, aw)
    return aw
end

function ah.multiDropdown(ak, al, am, an, ao)
    
    local ap = ai("Frame", {
        Parent = ak,
        LayoutOrder = #ak:GetChildren(),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    local aq = ai("TextLabel", {
        Parent = ap,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = al,
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local ar = ai("TextButton", {
        Parent = ap,
        Position = UDim2.fromOffset(0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ar })
    local as = ai("TextLabel", {
        Parent = ar,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = "",
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local at = ai("TextLabel", {
        Parent = ar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Text = "v",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
    })
local au=function()        

local au = w[am] or {}
        as.Text = (#au > 0) and table.concat(au, ", ") or "---"
end    
au()

    local av
local aw=function()        
if av then av:Destroy(); av = nil; return end
        local aw = ap:FindFirstAncestorOfClass("ScreenGui")
        if not aw then return end
        av = ai("Frame", {
            Parent = aw,
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        ai("UICorner", { CornerRadius = UDim.new(0, 4), Parent = av })
        ai("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = av })

        local ax = ar.AbsolutePosition
        local ay = ar.AbsoluteSize
        local az = math.min(220, #an * 24 + 4)
        av.Position = UDim2.fromOffset(ax.X, ax.Y + ay.Y + 2)
        av.Size = UDim2.fromOffset(ay.X, az)

        local aA = ai("ScrollingFrame", {
            Parent = av,
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
        ai("UIListLayout", { Parent = aA, SortOrder = Enum.SortOrder.LayoutOrder })

        for aB, aC in ipairs(an) do
            local aD = ai("Frame", {
                Parent = aA,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                ZIndex = 52,
            })
            local aE = ai("TextLabel", {
                Parent = aD,
                Size = UDim2.fromOffset(20, 24),
                BackgroundTransparency = 1,
                Text = D.contains(w[am] or {}, aC) and "[X]" or "[ ]",
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = w.AccentColor,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 53,
            })
            local X = ai("TextLabel", {
                Parent = aD,
                Position = UDim2.fromOffset(24, 0),
                Size = UDim2.new(1, -24, 1, 0),
                BackgroundTransparency = 1,
                Text = tostring(aC),
                Font = aj(),
                TextSize = 12,
                TextColor3 = w.FontColor,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 53,
            })
            local Y = ai("TextButton", {
                Parent = aD,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 54,
            })
            Y.MouseButton1Click:Connect(function()
                w[am] = w[am] or {}
                local Z = w[am]
                local _
                for aF, aG in ipairs(Z) do if aG == aC then _ = aF break end end
                if _ then table.remove(Z, _) else table.insert(Z, aC) end
                aE.Text = D.contains(Z, aC) and "[X]" or "[ ]"
                au()
                if ao then pcall(ao, Z) end
            end)
        end
end
    
ar.MouseButton1Click:Connect(aw)

    local ax = { instance = ap, label = al, key = am, options = an }
    function ax.themeUpdate()
        aq.TextColor3 = w.FontColor; aq.Font = aj()
        ar.BackgroundColor3 = w.BgColor
        as.TextColor3 = w.FontColor; as.Font = aj()
        at.TextColor3 = w.FontColor
    end
    function ax.refresh() au() end
    table.insert(z, ax)
    return ax
end

function ah.colorPicker(ak, al, am, an)
    local ao = ai("Frame", {
        Parent = ak,
        LayoutOrder = #ak:GetChildren(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    })
    local ap = ai("TextLabel", {
        Parent = ao,
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = al,
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local aq = ai("TextButton", {
        Parent = ao,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(28, 18),
        BackgroundColor3 = w[am] or Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 3), Parent = aq })
    ai("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = aq })

    local ar
local as=function()        
aq.BackgroundColor3 = w[am] or Color3.new(1, 1, 1)
end local at=function()        


if ar then ar:Destroy(); ar = nil; return end
        local at = ao:FindFirstAncestorOfClass("ScreenGui")
        if not at then return end
        ar = ai("Frame", {
            Parent = at,
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        ai("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ar })
        ai("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = ar })

        local au = aq.AbsolutePosition
        ar.Position = UDim2.fromOffset(au.X - 160, au.Y + 24)
        ar.Size = UDim2.fromOffset(190, 130)
local av=function(
av, aw, ax)            
local ay = ai("Frame", {
                Parent = ar,
                Position = UDim2.fromOffset(36, ax),
                Size = UDim2.fromOffset(140, 16),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                ZIndex = 51,
            })
            ai("UICorner", { CornerRadius = UDim.new(0, 3), Parent = ay })
            local az = ai("Frame", {
                Parent = ay,
                Size = UDim2.new((w[am][aw] or 1), 0, 1, 0),
                BackgroundColor3 = aw == "R" and Color3.fromRGB(220, 38, 38)
                                or aw == "G" and Color3.fromRGB(34, 197, 94)
                                or                    Color3.fromRGB(59, 130, 246),
                BorderSizePixel = 0,
                ZIndex = 52,
            })
            ai("UICorner", { CornerRadius = UDim.new(0, 3), Parent = az })
            local aA = ai("TextLabel", {
                Parent = ar,
                Position = UDim2.fromOffset(8, ax),
                Size = UDim2.fromOffset(24, 16),
                BackgroundTransparency = 1,
                Text = av,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = w.FontColor,
                ZIndex = 51,
            })
            local aB = ai("TextLabel", {
                Parent = ar,
                Position = UDim2.fromOffset(178, ax),
                Size = UDim2.fromOffset(0, 16),
                BackgroundTransparency = 1,
                Text = "",
                Font = aj(),
                TextSize = 11,
                TextColor3 = w.FontColor,
                ZIndex = 51,
            })
local aC=function(aC)                
aC = math.clamp(aC, 0, 1)
                local aD = w[am]
                local aE, aF, aG = aD.R, aD.G, aD.B
                if aw == "R" then aE = aC end
                if aw == "G" then aF = aC end
                if aw == "B" then aG = aC end
                w[am] = Color3.new(aE, aF, aG)
                az.Size = UDim2.new(aC, 0, 1, 0)
                aB.Text = tostring(math.floor(aC * 255 + 0.5))
                as()
                if an then pcall(an, w[am]) end
end            
aB.Text = tostring(math.floor((w[am][aw] or 0) * 255 + 0.5))

            local aD
            ay.InputBegan:Connect(function(aE)
                if aE.UserInputType == Enum.UserInputType.MouseButton1 or aE.UserInputType == Enum.UserInputType.Touch then
                    aD = true
                    aC((aE.Position.X - ay.AbsolutePosition.X) / ay.AbsoluteSize.X)
                end
            end)
            ay.InputEnded:Connect(function(aE)
                if aE.UserInputType == Enum.UserInputType.MouseButton1 or aE.UserInputType == Enum.UserInputType.Touch then
                    aD = false
                end
            end)
            f.InputChanged:Connect(function(aE)
                if aD and (aE.UserInputType == Enum.UserInputType.MouseMovement or aE.UserInputType == Enum.UserInputType.Touch) then
                    aC((aE.Position.X - ay.AbsolutePosition.X) / ay.AbsoluteSize.X)
                end
            end)
end
        
av("R", "R", 10)
        av("G", "G", 36)
        av("B", "B", 62)

        local aw = ai("TextButton", {
            Parent = ar,
            Position = UDim2.fromOffset(36, 92),
            Size = UDim2.fromOffset(140, 24),
            BackgroundColor3 = w.AccentColor,
            BorderSizePixel = 0,
            Text = "Done",
            Font = aj(),
            TextSize = 12,
            TextColor3 = w.FontColor,
            AutoButtonColor = true,
            ZIndex = 51,
        })
        ai("UICorner", { CornerRadius = UDim.new(0, 4), Parent = aw })
        aw.MouseButton1Click:Connect(function()
            if ar then ar:Destroy(); ar = nil end
        end)
end
    
aq.MouseButton1Click:Connect(at)

    local au = { instance = ao, label = al, key = am }
    function au.themeUpdate()
        ap.TextColor3 = w.FontColor; ap.Font = aj()
        as()
    end
    function au.refresh() as() end
    table.insert(z, au)
    return au
end

function ah.textInput(ak, al, am, an, ao)
    local ap = ai("Frame", {
        Parent = ak,
        LayoutOrder = #ak:GetChildren(),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    local aq = ai("TextLabel", {
        Parent = ap,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = al,
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local ar = ai("TextBox", {
        Parent = ap,
        Position = UDim2.fromOffset(0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = tostring(w[am] or ""),
        PlaceholderText = an or "",
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        PlaceholderColor3 = Color3.fromRGB(120, 130, 140),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ar })
    local as = ai("UIPadding", { Parent = ar, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

    ar.FocusLost:Connect(function()
        w[am] = ar.Text
        if ao then pcall(ao, ar.Text) end
    end)

    local at = { instance = ap, label = al, key = am }
    function at.themeUpdate()
        aq.TextColor3 = w.FontColor; aq.Font = aj()
        ar.BackgroundColor3 = w.BgColor
        ar.TextColor3 = w.FontColor
        ar.Font = aj()
    end
    function at.refresh() ar.Text = tostring(w[am] or "") end
    table.insert(z, at)
    return at
end

function ah.keybind(ak, al, am, an)
    local ao = ai("Frame", {
        Parent = ak,
        LayoutOrder = #ak:GetChildren(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    })
    local ap = ai("TextLabel", {
        Parent = ao,
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Text = al,
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local aq = ai("TextButton", {
        Parent = ao,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(96, 22),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = tostring(w[am] or "None"),
        Font = aj(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        AutoButtonColor = true,
    })
    ai("UICorner", { CornerRadius = UDim.new(0, 4), Parent = aq })

    local ar = false
    aq.MouseButton1Click:Connect(function()
        ar = true
        aq.Text = "..."
    end)
    f.InputBegan:Connect(function(as, at)
        if not ar then return end
        if as.UserInputType ~= Enum.UserInputType.Keyboard then return end
        ar = false
        local au = as.KeyCode.Name
        w[am] = au
        aq.Text = au
        if an then pcall(an, au) end
    end)

    local as = { instance = ao, label = al, key = am }
    function as.themeUpdate()
        ap.TextColor3 = w.FontColor; ap.Font = aj()
        aq.BackgroundColor3 = w.BgColor
        aq.TextColor3 = w.FontColor; aq.Font = aj()
    end
    function as.refresh() aq.Text = tostring(w[am] or "None") end
    table.insert(z, as)
    return as
end
local ak=function()    




w.Alive = false
    w.Autofarm = false
    w.Fly = false
    w.AutoAttack = false
    w.AutoAttackNearby = false
    w.AutoTPToPlayer = false

    P.disable()
    O.clearAll()
    D.disconnectAll()
    if p.CameraType == Enum.CameraType.Scriptable then
        pcall(function() p.CameraType = Enum.CameraType.Custom end)
    end

    local ak = G.humanoid()
    if ak then pcall(function() ak.WalkSpeed = v.DefaultWS; ak.JumpPower = v.DefaultJP end) end
    local al = G.root()
    if al then pcall(function() al.Anchored = false end) end
local am=function(

am)        
if not am then return end
        for an, ao in ipairs(am:GetChildren()) do
            if ao:IsA("ScreenGui") and (ao.Name:sub(1, 6) == "_NHJB_" or ao.Name:sub(1, 9) == "_NHJB_NF_") then
                pcall(function() ao:Destroy() end)
            end
        end
end    
am(m)
    if q then am(q:FindFirstChild("PlayerGui")) end
    _G._NHJB_NotifyGui = nil

    getgenv()._NameHubJB_Alive  = false
    getgenv()._NameHubJB_Unload = nil
end




C = ah.newWindow({ width = 760, height = 520 })
local al, am, an, ao
local ap, aq, ar, as


local at = C:addPage("Main")

local au  = ah.newColumn(at, 0.5)
au.Position = UDim2.fromOffset(8, 8)

local av = ah.newColumn(at, 0.5)
av.Position = UDim2.new(0.5, 4, 0, 8)


local aw, ax = ah.newCard(au, { tabs = { "Main", "ESP" }, height = 360 })

do
    local ay = ax["Main"].frame
    ah.toggle(ay, "Autofarm", "Autofarm", function(az)
        if az then
            w.StartTime = w.StartTime or os.time()
            w.StatsCounting = true
            M.start()
        else
            G.applySpeed()
        end
    end)
    ah.dropdown(ay, "Farm Targets", "FarmTarget", v.FarmTargetOptions, function(az)
        
        if #w.FarmPriority == 0 then w.FarmPriority = { az } end
    end)
    ah.multiDropdown(ay, "Farm Priority List", "FarmPriority", v.FarmTargetOptions)
    ah.toggle(ay, "Skip Players (NPC-only autofarm)", "SkipPlayers")
    ah.slider(ay, "Speed", "Speed", 16, 200, 1, function() G.applySpeed() end)
    ah.dropdown(ay, "Autofarm Dino", "AutofarmDino", v.DinoOptions, function(az)
        local aA = H.remoteByKeywords(v.DinoChangeKeywords)
        if aA then
            pcall(function()
                if aA:IsA("RemoteEvent") then aA:FireServer(az) else aA:InvokeServer(az) end
            end)
        end
    end)

    local az = ah.label(ay, "Coins Gained: 0")
    local aA  = ah.label(ay, "Rate: N/A")
    local aB = ah.label(ay, "Time Elapsed: N/A")
    al, an, am = az, aA, aB

    ah.button(ay, "Start Counting Stats", function()
        w.CoinsGained = 0
        w.StartTime = os.time()
        w.StatsCounting = true
        F.send("Stats counter started.")
    end)
end

do
    local ay = ax["ESP"].frame
    ah.toggle(ay, "Goat ESP", "GoatESP", function(az)
        if az then O.start() end
    end)
    ah.colorPicker(ay, "Goat ESP Color", "GoatESPColor")
    ah.toggle(ay, "Amber ESP", "AmberESP", function(az)
        if az then O.start() end
    end)
    ah.colorPicker(ay, "Amber ESP Color", "AmberESPColor")
    ah.toggle(ay, "No Prompt Delay", "NoPromptDelay")
    ah.slider(ay, "Outline Transparency", "OutlineTransparency", 0, 1, 0.05, function() O.refresh() end)
    ah.slider(ay, "Fill Transparency", "FillTransparency", 0, 1, 0.05, function() O.refresh() end)
end


local ay, az = ah.newCard(av, { tabs = { "Player", "Combat" }, height = 360 })

do
    local aA = az["Player"].frame
    ah.toggle(aA, "Fly", "Fly", function(aB)
        if aB then P.enable() else P.disable() end
    end)
    ah.slider(aA, "Fly Speed", "FlySpeed", 10, 300, 1)
    ah.button(aA, "Respawn", function() T.respawn() end)
    ah.button(aA, "Menu", function() T.openMenu() end)
    ah.slider(aA, "Respawn Delay", "RespawnDelay", 0, 30, 1)
    ah.toggle(aA, "Auto Respawn", "AutoRespawn")
    ah.toggle(aA, "Anchored", "Anchored", function() G.applyAnchor() end)
end

do
    local aA = az["Combat"].frame
    ah.slider(aA, "Offset (X-axis)", "OffsetX", -20, 20, 1)
    ah.slider(aA, "Offset (Y-axis)", "OffsetY", -20, 20, 1)
    ah.slider(aA, "Range", "Range", 5, 200, 1)
    ah.slider(aA, "Max Target HP", "MaxTargetHP", 0, 5000, 10)
    ah.slider(aA, "Min Target HP", "MinTargetHP", 0, 5000, 10)
    ah.slider(aA, "Disengage At", "DisengageAt", 0, 1000, 10)
    ah.toggle(aA, "Target POV", "TargetPOV")
    ah.toggle(aA, "Auto Attack Nearby Player", "AutoAttackNearby")
    ah.toggle(aA, "Auto Attack", "AutoAttack")
    ah.toggle(aA, "Auto TP to Player", "AutoTPToPlayer")
local aB=function()        


local aB = { "" }
        for aC, aD in ipairs(d:GetPlayers()) do
            if aD ~= q then aB[#aB + 1] = aD.Name end
        end
        return aB
end    
as = ah.dropdown(aA, "Target Player", "TargetPlayer", aB())
    
    D.conn("tp_player_add", d.PlayerAdded:Connect(function() as:setOptions(aB()) end))
    D.conn("tp_player_rem", d.PlayerRemoving:Connect(function() as:setOptions(aB()) end))
end


local aA = C:addPage("Teleport")
local aB  = ah.newColumn(aA, 0.5)
aB.Position = UDim2.fromOffset(8, 8)
local aC, aD = ah.newCard(aB, { title = "Server Hop", height = 460 })

do
    ah.button(aD, "Join selected server", function()
        if w.SelectedJobId ~= "" then U.joinJobId(w.SelectedJobId) end
    end)
    ah.button(aD, "Refresh Server List", function()
        F.send("Fetching servers...")
        D.spawn(function()
            local aE = U.fetchServers()
            w.ServerListCache = aE
            local aF = {}
            for aG, X in ipairs(aE) do aF[#aF + 1] = ("%s  (%d/%d)"):format(X.id:sub(1, 8), X.playing, X.max) end
            if #aF == 0 then aF = { "(no servers)" } end
            ap:setOptions(aF)
            F.send(("Fetched %d servers"):format(#aE))
        end)
    end)
    ap = ah.dropdown(aD, "Server List", "SelectedJobId", { "---" }, function(aE)
        for aF, aG in ipairs(w.ServerListCache or {}) do
            if aE:sub(1, 8) == aG.id:sub(1, 8) then w.SelectedJobId = aG.id; return end
        end
    end)
    ah.button(aD, "Get PlayerCount", function()
        for aE, aF in ipairs(w.ServerListCache or {}) do
            if aF.id == w.SelectedJobId then
                F.send(("Server %s: %d/%d players"):format(aF.id:sub(1,8), aF.playing, aF.max))
                return
            end
        end
        F.send("Refresh server list first.")
    end)
    ah.button(aD, "Copy JobId", function()
        pcall(setclipboard, w.SelectedJobId)
        F.send("Copied JobId.")
    end)
    ah.button(aD, "Join Selected JobId", function()
        U.joinJobId(w.SelectedJobId)
    end)
    ah.textInput(aD, "JobId", "SelectedJobId", "Enter JobId here")
    ah.button(aD, "Rejoin Server", function() U.rejoin() end)
    ah.button(aD, "Server Hop", function() U.randomHop() end)
    ah.slider(aD, "Hop On Player Count", "HopOnPlayerCount", 0, 30, 1)
    ah.toggle(aD, "Hop On Friend Detection", "HopOnFriend")
end


local aE = C:addPage("Safety")
local aF = ah.newColumn(aE, 0.5)
aF.Position = UDim2.fromOffset(8, 8)
local aG, X = ah.newCard(aF, { title = "Admin Detection", height = 80 })
ah.toggle(X, "Kick On Detection", "KickOnAdmin")


local Y = C:addPage("Webhook")
local Z  = ah.newColumn(Y, 0.5)
Z.Position = UDim2.fromOffset(8, 8)
local _, aH = ah.newCard(Z, { title = "Webhook", height = 280 })
do
    ah.textInput(aH, "Webhook Link", "WebhookLink", "https://discord.com/api/webhooks/...")
    ah.slider(aH, "Webhook Interval (minutes)", "WebhookInterval", 1, 60, 1)
    ah.slider(aH, "Timezone (UTC offset)", "WebhookTimezone", -12, 12, 1)
    ah.colorPicker(aH, "Embed Color", "WebhookColor")
    ah.toggle(aH, "Anonymous Mode", "WebhookAnonymous")
    ah.button(aH, "Force Send Webhook Request", function() V.send(true) end)
end


local aI = C:addPage("Settings")

local aJ  = ah.newColumn(aI, 0.5)
aJ.Position = UDim2.fromOffset(8, 8)
local aK = ah.newColumn(aI, 0.5)
aK.Position = UDim2.new(0.5, 4, 0, 8)

local aL, aM = ah.newCard(aJ, { title = "Themes", height = 280 })
do
    ah.colorPicker(aM, "Background color", "BgColor",   function() ac.apply() end)
    ah.colorPicker(aM, "Main color",        "MainColor", function() ac.apply() end)
    ah.colorPicker(aM, "Accent color",      "AccentColor", function() ac.apply() end)
    ah.colorPicker(aM, "Outline color",     "OutlineColor", function() ac.apply() end)
    ah.colorPicker(aM, "Font color",        "FontColor", function() ac.apply() end)
    ah.dropdown(aM, "Font Face", "FontFace", v.FontOptions, function() ac.apply() end)
    ar = ah.dropdown(aM, "Theme list", "Theme", ac.listNames())
    ah.button(aM, "Load theme", function() ac.load(w.Theme) end)
    ah.button(aM, "Overwrite theme", function()
        if ac.saveCurrent(w.Theme) then F.send("Saved theme: " .. w.Theme) end
    end)
end

local aN, aO = ah.newCard(aK, { title = "Configuration", height = 320 })
do
    ah.textInput(aO, "Config name", "_cfgName", "name")
    ah.button(aO, "Create config", function() ad.save(w._cfgName or "") end)
    aq = ah.dropdown(aO, "Config list", "_cfgPicked", ad.list())
    ah.button(aO, "Refresh list", function() aq:setOptions(ad.list()) end)
    ah.button(aO, "Load config",      function() ad.load(w._cfgPicked or "") end)
    ah.button(aO, "Overwrite config", function() ad.save(w._cfgPicked or "") end)
    ah.button(aO, "Delete config",    function()
        ad.delete(w._cfgPicked or "")
        aq:setOptions(ad.list())
    end)
    ah.button(aO, "Set autoload",   function()
        if w._cfgPicked and w._cfgPicked ~= "" then
            ad.setAutoload(w._cfgPicked)
            if ao then ao:setText("Current autoload config: " .. w.AutoloadConfig) end
            F.send("Autoload set: " .. w.AutoloadConfig)
        end
    end)
    ah.button(aO, "Reset autoload", function()
        ad.resetAutoload()
        if ao then ao:setText("Current autoload config: none") end
    end)
    ao = ah.label(aO,
        "Current autoload config: " .. (ad.getAutoload() ~= "" and ad.getAutoload() or "none"))
    ah.textInput(aO, "Import Data", "_importData", "paste exported config here")
    ah.button(aO, "Export config", function()
        local aP = ad.exportCurrent()
        pcall(setclipboard, aP)
        F.send("Exported to clipboard.")
    end)
    ah.button(aO, "Import config", function() ad.importString(w._importData or "") end)
end

local aP, aQ = ah.newCard(aJ, { title = "Menu", height = 160 })
do
    ah.keybind(aQ, "Menu bind", "MenuBind")
    ah.toggle(aQ, "Autoexecute", "Autoexecute", function(aR)
        if aR then
            
            local aS = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/kyronshaw912-collab/NameHub/main/loader.lua"))() end)'
            local aT = { "autoexec/", "auto_exec/", "autoexecute/" }
            local aU
            for aV, aW in ipairs(aT) do
                local aX = pcall(b.writefile, aW .. "NameHubJB_loader.lua", aS)
                if aX then aU = aW; break end
            end
            if aU then F.send("Autoexec written: " .. aU) else F.send("Autoexec unsupported by executor.") end
        end
    end)
    ah.dropdown(aQ, "Notification Side", "NotificationSide", v.NotifySides)
    ah.dropdown(aQ, "UI Zoom", "_ZoomPick",
        { "75%", "100%", "125%", "150%", "175%", "200%", "250%" },
        function(aR)
            local aS = tonumber((aR:gsub("%%", "")))
            if aS and aS > 0 then
                w.UIScale = aS / 100
                if C and C.uiScale then C.uiScale.Scale = w.UIScale end
            end
        end
    )
end




C.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local aR = C.searchBox.Text:lower()
    for aS, aT in pairs(z) do
        if aT.instance and aT.label and aT.instance.Parent then
            local aU = (aR == "") or aT.label:lower():find(aR, 1, true)
            aT.instance.Visible = aU and true or false
        end
    end
end)




D.conn("ui_toggle", f.InputBegan:Connect(function(aR, aS)
    if aS then return end
    if aR.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if aR.KeyCode.Name == w.MenuBind then
        w.UIVisible = not w.UIVisible
        C.win.Visible = w.UIVisible
    end
end))




D.conn("stats_tick", e.Heartbeat:Connect(function()
    if not w.Alive then return end
    if al then al:setText("Coins Gained: " .. tostring(w.CoinsGained)) end
    if w.StartTime and w.StatsCounting then
        local aR = os.time() - w.StartTime
        if am  then am:setText("Time Elapsed: " .. D.fmtTime(aR)) end
        if an then
            local aS = aR > 0 and (w.CoinsGained / (aR / 60)) or 0
            an:setText(("Rate: %.1f/min"):format(aS))
        end
    else
        if am  then am:setText("Time Elapsed: N/A") end
        if an then an:setText("Rate: N/A") end
    end
end))




D.conn("charadded", q.CharacterAdded:Connect(function()
    task.wait(0.2)
    if w.Fly then P.enable() end
    G.applySpeed()
    G.applyAnchor()
end))




getgenv()._NameHubJB_Alive  = true
getgenv()._NameHubJB_Unload = ak

ab()
T.attachAutoRespawn()
U.attachWatchers()
aa.attach()
V.attachInterval()
N.start()


do
    local aR = ad.getAutoload()
    if aR ~= "" then
        w.AutoloadConfig = aR
        ad.load(aR)
        if ao then ao:setText("Current autoload config: " .. aR) end
    end
end

ac.apply()
F.send(v.Brand .. " " .. v.SubBrand .. " " .. a .. " loaded.", 4)

return true
