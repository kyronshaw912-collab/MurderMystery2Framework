












local a = "v2.0.6.1 NameHub (jb-movement-fix-20260529)"




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

    MovementOptions = { "Teleport", "Fly", "Walk" },

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
    
    
    
    
    
    
    
    
    AutofarmMovement  = "Teleport",
    
    
    StopDistance      = 10,
    
    
    
    _FarmStatus       = "Idle",
    _LastTarget       = "",
    _LastDistance     = 0,
    _LastFire         = "",
    _AttackRemote     = "",
    _TargetsFound     = 0,
    _NamedFound       = 0,

    
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






function I.allByName(J)
    if not J or J == "" then return {} end
    local K = J:lower()
    local L = {}
    local M = G.get()
    for N, O in ipairs(h:GetDescendants()) do
        if O:IsA("Model") and O ~= M and O.Name:lower():find(K, 1, true) then
            if not (w.SkipPlayers and d:GetPlayerFromCharacter(O) ~= nil) then
                local P = O:FindFirstChild("HumanoidRootPart") or O.PrimaryPart
                if not P then
                    
                    for Q, R in ipairs(O:GetChildren()) do
                        if R:IsA("BasePart") then P = R; break end
                    end
                end
                local Q = O:FindFirstChildOfClass("Humanoid")
                if P then
                    L[#L + 1] = { model = O, hum = Q, root = P }
                end
            end
        end
    end
    return L
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

                
                
                
                
                if not S then
                    local T = math.huge
                    for U, V in ipairs(R) do
                        for W, X in ipairs(I.allByName(V)) do
                            local Y = D.distance(Q, X.root)
                            if Y < T then S = X; T = Y end
                        end
                        if S then break end
                    end
                end

                local T = G.humanoid()
                local U = (T and w.DisengageAt > 0 and T.Health < w.DisengageAt)

                if U then
                    w._FarmStatus = ("Retreating (HP %d < %d)"):format(math.floor(T.Health), w.DisengageAt)
                    
                    
                    
                    if w.AutofarmMovement == "Fly" and FarmMove.flyActive() then
                        _fmBV.Velocity = Vector3.zero
                    end
                elseif S and S.model.Parent and S.root then
                    local V = D.distance(Q, S.root)
                    w._FarmStatus    = ("Engaging %s @ %.0fm"):format(S.model.Name, V)
                    w._LastTarget    = S.model.Name
                    w._LastDistance  = V
                    w._TargetsFound  = (w._TargetsFound or 0)

                    
                    
                    
                    
                    
                    
                    
                    
                    if w.AutofarmMovement == "Fly" then
                        if V > w.StopDistance then
                            FarmMove.flyToward(S.root.Position)
                        elseif FarmMove.flyActive() then
                            _fmBV.Velocity = Vector3.zero
                        end
                    elseif w.AutofarmMovement == "Walk" then
                        if V > w.StopDistance then
                            FarmMove.walkTo(S.root.Position)
                        end
                    else
                        
                        
                        
                        
                        if V > w.Range then
                            FarmMove.tpTo(S.root.Position)
                        end
                    end

                    if V <= w.Range and tick() >= N then
                        local W, X = J.findRemote()
                        w._AttackRemote = X or "(none)"
                        local Y = J.fireAt(S)
                        w._LastFire = Y and "OK" or "FAIL"
                        if Y and w.StatsCounting then
                            w.CoinsGained = w.CoinsGained + 1
                        end
                        N = tick() + 0.35
                    end
                else
                    w._FarmStatus = ("Searching for: %s"):format(table.concat(R, ", "))
                    
                    if w.AutofarmMovement == "Fly" and FarmMove.flyActive() then
                        _fmBV.Velocity = Vector3.zero
                    end
                end

                
                if P % 5 == 0 then
                    local V = #I.allWithHumanoid()
                    local W = 0
                    for X, Y in ipairs(R) do
                        W = W + #I.allByName(Y)
                    end
                    w._TargetsFound = V
                    w._NamedFound   = W
                end

                if w.AutoLoot and tick() >= O then
                    J.collectNearby()
                    O = tick() + 3
                end
            else
                w._FarmStatus = "No character"
            end
            task.wait(0.1)
        end
        
        
        FarmMove.stopFly()
        w._FarmStatus = "Idle"
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
local U, V

function T.startFly()
    local W = G.root(); if not W then return end
    T.stopFly()
    U = Instance.new("BodyVelocity")
    U.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    U.Velocity = Vector3.zero
    U.Parent = W
    V = Instance.new("BodyGyro")
    V.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    V.P = 1000
    V.CFrame = W.CFrame
    V.Parent = W
    local X = G.humanoid()
    if X then X.PlatformStand = true end
end

function T.stopFly()
    if U then pcall(function() U:Destroy() end); U = nil end
    if V then pcall(function() V:Destroy() end); V = nil end
    
    if not w.Fly then
        local W = G.humanoid()
        if W then pcall(function() W.PlatformStand = false end) end
    end
end



function T.flyActive()
    return U ~= nil and U.Parent ~= nil
end



function T.flyToward(W)
    local X = G.root(); if not X then return end
    if not T.flyActive() then T.startFly() end
    if not U then return end
    local Y = W - X.Position
    local Z = Y.Magnitude
    if Z < 0.5 then
        U.Velocity = Vector3.zero
        return
    end
    U.Velocity = Y.Unit * w.FlySpeed
    if V then V.CFrame = CFrame.lookAt(X.Position, W) end
end


function T.tpTo(W)
    local X = G.root(); if not X then return end
    local Y = CFrame.new(W) * CFrame.new(w.OffsetX, w.OffsetY, math.min(8, w.Range * 0.2))
    Y = CFrame.lookAt(Y.Position, W)
    pcall(function() X.CFrame = Y end)
end


function T.walkTo(W)
    local X = G.humanoid()
    if X then pcall(function() X:MoveTo(W) end) end
end




local W = {}

function W.respawn()
    local X = G.humanoid()
    if X then
        X.Health = 0
    else
        pcall(function() q.Character:BreakJoints() end)
    end
end

function W.openMenu()
    local X = H.remoteByKeywords(v.MenuKeywords)
    if X then
        pcall(function()
            if X:IsA("RemoteEvent") then X:FireServer() else X:InvokeServer() end
        end)
        return
    end
    
    pcall(function() k:CaptureController() end)
end

function W.attachAutoRespawn()
    D.conn("char_died_watch", q.CharacterAdded:Connect(function(X)
        local Y = X:WaitForChild("Humanoid", 5)
        if not Y then return end
        Y.Died:Connect(function()
            if not w.AutoRespawn then return end
            task.wait(w.RespawnDelay)
            if not w.AutoRespawn then return end
            
            pcall(function() q:LoadCharacter() end)
        end)
    end))
end




local X = {}

function X.fetchServers()
    local Y = game.PlaceId
    local Z = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(Y)
    local _ = c({ Url = Z, Method = "GET" })
    if not _ or _.StatusCode ~= 200 then return {} end
    local aa = E.decode(_.Body or "")
    local ab = {}
    for ac, ad in ipairs(aa.data or {}) do
        if ad.id and ad.id ~= game.JobId then
            ab[#ab + 1] = { id = ad.id, playing = ad.playing or 0, max = ad.maxPlayers or 0 }
        end
    end
    return ab
end

function X.joinJobId(aa)
    if not aa or aa == "" then return end
    pcall(function() n:TeleportToPlaceInstance(game.PlaceId, aa, q) end)
end

function X.rejoin()
    pcall(function() n:TeleportToPlaceInstance(game.PlaceId, game.JobId, q) end)
end

function X.randomHop()
    local aa = X.fetchServers()
    if #aa == 0 then F.send("No servers found.") return end
    local ab = aa[math.random(1, #aa)]
    X.joinJobId(ab.id)
end

function X.attachWatchers()
    
    D.conn("friend_watch", d.PlayerAdded:Connect(function(aa)
        if not w.HopOnFriend then return end
        local ab, ac = pcall(function() return q:IsFriendsWith(aa.UserId) end)
        if ab and ac then X.randomHop() end
    end))

    
    D.spawn(function()
        while w.Alive do
            if w.HopOnPlayerCount > 0 and #d:GetPlayers() <= w.HopOnPlayerCount then
                X.randomHop()
                task.wait(10)
            end
            task.wait(5)
        end
    end, "Hop.thresholdLoop")
end




local aa = {}

function aa.isAdmin(ab)
    ab = ab:lower()
    for ac, ad in ipairs(w.AdminList) do
        if ab:find(ad, 1, true) then return true end
    end
    return false
end

function aa.attach()
    D.conn("admin_watch", d.PlayerAdded:Connect(function(ab)
        if not w.KickOnAdmin then return end
        if aa.isAdmin(ab.Name) or aa.isAdmin(ab.DisplayName or "") then
            F.send("Admin detected: " .. ab.Name .. " — kicking self.", 5)
            task.wait(0.3)
            pcall(function() q:Kick("[NameHub] Admin detected: " .. ab.Name) end)
        end
    end))

    
    D.spawn(function()
        task.wait(2)
        if not w.KickOnAdmin then return end
        for ab, ac in ipairs(d:GetPlayers()) do
            if ac ~= q and (aa.isAdmin(ac.Name) or aa.isAdmin(ac.DisplayName or "")) then
                F.send("Admin in server: " .. ac.Name .. " — kicking self.", 5)
                task.wait(0.3)
                pcall(function() q:Kick("[NameHub] Admin in server: " .. ac.Name) end)
                return
            end
        end
    end, "Safety.initScan")
end




local ab = {}
local ac = 0

function ab.send(ad)
    if not ad and w.WebhookLink == "" then return end
    if w.WebhookLink == "" then F.send("Set a webhook URL first.") return end

    local Y = w.StartTime and (os.time() - w.StartTime) or 0
    local Z    = Y > 0 and (w.CoinsGained / (Y / 60)) or 0

    local _ = w.WebhookAnonymous and "Anonymous" or q.Name
    local ae       = w.WebhookTimezone
    local af   = os.time() + ae * 3600
    local ag   = os.date("!%Y-%m-%d %H:%M:%S", af) .. (" UTC%+d"):format(ae)

    local ah = {
        username = "NameHub JB",
        embeds = {{
            title  = "NameHub Jurassic Blocky — Stats",
            color  = D.color3ToInt(w.WebhookColor),
            fields = {
                { name = "User",          value = _,                                inline = true },
                { name = "Server",        value = ("`%s`"):format(game.JobId or "n/a"),    inline = true },
                { name = "Time",          value = ag,                                  inline = false },
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
    local ai = E.encode(ah)
    local aj = pcall(function()
        c({
            Url     = w.WebhookLink,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = ai,
        })
    end)
    if aj then
        ac = tick()
        if ad then F.send("Webhook sent.") end
    elseif ad then
        F.send("Webhook failed.")
    end
end

function ab.attachInterval()
    D.spawn(function()
        while w.Alive do
            if w.WebhookLink ~= "" and w.WebhookInterval > 0 then
                if tick() - ac >= w.WebhookInterval * 60 then
                    ab.send(false)
                end
            end
            task.wait(30)
        end
    end, "Webhook.interval")
end
local ad=function()    




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

local ae = {}

function ae.applyValues(af)
    w.BgColor       = af.Bg
    w.MainColor     = af.Main
    w.AccentColor   = af.Accent
    w.OutlineColor  = af.Outline
    w.FontColor     = af.Font
end

function ae.apply()
    for af, ag in pairs(z) do
        if ag.themeUpdate then pcall(ag.themeUpdate) end
    end
end

function ae.load(af)
    local ag = A[af]
    if not ag then return end
    w.Theme = af
    ae.applyValues(ag)
    ae.apply()
end

function ae.listNames()
    local af = {}
    for ag in pairs(A) do af[#af + 1] = ag end
    table.sort(af)
    return af
end

function ae.saveCurrent(af)
    if not af or af == "" then return false end
    local ag = {
        Bg      = D.color3ToTable(w.BgColor),
        Main    = D.color3ToTable(w.MainColor),
        Accent  = D.color3ToTable(w.AccentColor),
        Outline = D.color3ToTable(w.OutlineColor),
        Font    = D.color3ToTable(w.FontColor),
    }
    pcall(b.writefile, t .. "/" .. af .. ".json", E.encode(ag))
    return true
end




local af = {}

local ag = {
    "Autofarm", "FarmTarget", "FarmPriority", "Speed", "AutofarmDino", "SkipPlayers", "AutoLoot",
    "AutofarmMovement", "StopDistance",
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
local ah=function()    

local ah = {}
    for ai, aj in ipairs(ag) do
        local Y = w[aj]
        if typeof(Y) == "Color3" then
            ah[aj] = { _c3 = true, v = D.color3ToTable(Y) }
        else
            ah[aj] = Y
        end
    end
    return ah
end local ai=function(

ai)    
for aj, Y in pairs(ai or {}) do
        if type(Y) == "table" and Y._c3 then
            w[aj] = D.tableToColor3(Y.v)
        else
            w[aj] = Y
        end
    end
end

function af.save(aj)
    if not aj or aj == "" then F.send("Config name required.") return end
    pcall(b.writefile, s .. "/" .. aj .. ".json", E.encode(ah()))
    F.send("Saved config: " .. aj)
end

function af.load(aj)
    if not aj or aj == "" then return end
    if not b.isfile(s .. "/" .. aj .. ".json") then F.send("No config: " .. aj) return end
    local Y = ""
    pcall(function() Y = b.readfile(s .. "/" .. aj .. ".json") end)
    ai(E.decode(Y))
    
    for Z, _ in pairs(z) do
        if _.refresh then pcall(_.refresh) end
    end
    ae.apply()
    if C and C.uiScale then C.uiScale.Scale = w.UIScale or 1 end
    F.send("Loaded config: " .. aj)
end

function af.delete(aj)
    if not aj or aj == "" then return end
    pcall(b.delfile, s .. "/" .. aj .. ".json")
    F.send("Deleted config: " .. aj)
end

function af.list()
    local aj = {}
    local Y, Z = pcall(b.listfiles, s)
    if not Y or type(Z) ~= "table" then return aj end
    for _, ak in ipairs(Z) do
        local al = ak:match("([^/\\]+)%.json$")
        if al then aj[#aj + 1] = al end
    end
    table.sort(aj)
    return aj
end

function af.setAutoload(aj)
    pcall(b.writefile, u, aj or "")
    w.AutoloadConfig = aj or ""
end

function af.resetAutoload()
    pcall(b.delfile, u)
    w.AutoloadConfig = ""
end

function af.getAutoload()
    if not b.isfile(u) then return "" end
    local aj = ""
    pcall(function() aj = b.readfile(u) end)
    return (aj or ""):gsub("%s+$", "")
end

function af.exportCurrent()
    return E.encode(ah())
end

function af.importString(aj)
    if not aj or aj == "" then F.send("Nothing to import.") return end
    local ak = E.decode(aj)
    if not ak or not next(ak) then F.send("Invalid import data.") return end
    ai(ak)
    for al, Y in pairs(z) do
        if Y.refresh then pcall(Y.refresh) end
    end
    ae.apply()
    if C and C.uiScale then C.uiScale.Scale = w.UIScale or 1 end
    F.send("Imported config.")
end





local aj = {}
local ak=function(
ak, al, Y)    
local Z = Instance.new(ak)
    for _, am in pairs(al or {}) do Z[_] = am end
    if Y then for am, _ in ipairs(Y) do _.Parent = Z end end
    return Z
end local al=function()

return Enum.Font[w.FontFace] or Enum.Font.Gotham end


function aj.newWindow(am)
    am = am or {}
    local Y = ak("ScreenGui", {
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

    local _ = ak("Frame", {
        Name = "Window",
        Position = UDim2.fromOffset(60, 60),
        Size     = UDim2.fromOffset(am.width or 760, am.height or 520),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel  = 0,
        Active           = true,
        Parent           = Y,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 10), Parent = _ })
    local an = ak("UIStroke", { Color = w.OutlineColor, Transparency = 0.6, Thickness = 1, Parent = _ })

    
    
    
    
    local ao = Instance.new("UIScale")
    ao.Scale  = w.UIScale or 1
    ao.Parent = _

    
    local ap = ak("TextLabel", {
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
    
    local aq = ak("Frame", {
        Parent = _,
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 10), Parent = aq })
    
    ak("Frame", {
        Parent = aq,
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.new(0, 12, 1, 0),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })

    local ar = ak("TextLabel", {
        Parent = aq,
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.fromOffset(20, 18),
        BackgroundTransparency = 1,
        Text = v.Brand,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = w.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local as = ak("Frame", {
        Parent = aq,
        Position = UDim2.fromOffset(0, 70),
        Size = UDim2.new(1, 0, 1, -90),
        BackgroundTransparency = 1,
    })
    local at = ak("UIListLayout", {
        Parent = as,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })

    
    local au = ak("Frame", {
        Parent = _,
        Position = UDim2.new(0, 150, 0, 0),
        Size = UDim2.new(1, -150, 0, 60),
        BackgroundTransparency = 1,
    })

    local av = ak("Frame", {
        Parent = au,
        Position = UDim2.fromOffset(20, 16),
        Size = UDim2.new(1, -80, 0, 28),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 6), Parent = av })

    local aw = ak("TextLabel", {
        Parent = av,
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.fromOffset(2, 0),
        BackgroundTransparency = 1,
        Text = "Q",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
    })

    local ax = ak("TextBox", {
        Parent = av,
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.new(1, -36, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search",
        TextColor3 = w.FontColor,
        PlaceholderColor3 = Color3.fromRGB(120, 130, 140),
        Font = al(),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })

    
    
    
    
    
    
    do
        local ay, az, aA
local aB=function(
aB, aC)            
if not aC or not aC.Parent then return false end
            local aD, aE = aC.AbsolutePosition, aC.AbsoluteSize
            return aB.X >= aD.X and aB.X <= aD.X + aE.X
               and aB.Y >= aD.Y and aB.Y <= aD.Y + aE.Y
end local aC=function(

aC, aD)            
aC.Active = true
            aC.InputBegan:Connect(function(aE)
                if aE.UserInputType ~= Enum.UserInputType.MouseButton1
                   and aE.UserInputType ~= Enum.UserInputType.Touch then return end
                local aF = aE.Position
                if aD then
                    for aG, aH in ipairs(aD) do
                        if aB(aF, aH) then return end
                    end
                end
                ay  = true
                az = Vector2.new(aF.X, aF.Y)
                aA  = _.Position
                aE.Changed:Connect(function()
                    if aE.UserInputState == Enum.UserInputState.End then ay = false end
                end)
            end)
end
        
aC(ap)
        aC(ar)
        aC(au, { av })
        aC(aq, { as })   

        f.InputChanged:Connect(function(aD)
            if not ay then return end
            if aD.UserInputType ~= Enum.UserInputType.MouseMovement
               and aD.UserInputType ~= Enum.UserInputType.Touch then return end
            local aE = aD.Position
            local aF = Vector2.new(aE.X, aE.Y) - az
            _.Position = UDim2.new(
                aA.X.Scale, aA.X.Offset + aF.X,
                aA.Y.Scale, aA.Y.Offset + aF.Y
            )
        end)
    end

    
    local ay = ak("Frame", {
        Parent = _,
        Position = UDim2.new(0, 150, 0, 60),
        Size = UDim2.new(1, -150, 1, -84),
        BackgroundTransparency = 1,
    })

    
    local az = ak("Frame", {
        Parent = _,
        Position = UDim2.new(0, 150, 1, -24),
        Size = UDim2.new(1, -150, 0, 24),
        BackgroundTransparency = 1,
    })
    ak("TextLabel", {
        Parent = az,
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        Text = v.SubBrand,
        Font = al(),
        TextSize = 12,
        TextColor3 = Color3.fromRGB(120, 130, 140),
    })
    local aA = ak("TextLabel", {
        Parent = az,
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
        local aB, aC, aD
        aA.InputBegan:Connect(function(aE)
            if aE.UserInputType == Enum.UserInputType.MouseButton1 or aE.UserInputType == Enum.UserInputType.Touch then
                aB = true
                aC = aE.Position
                aD = _.Size
                aE.Changed:Connect(function()
                    if aE.UserInputState == Enum.UserInputState.End then aB = false end
                end)
            end
        end)
        f.InputChanged:Connect(function(aE)
            if aB and (aE.UserInputType == Enum.UserInputType.MouseMovement or aE.UserInputType == Enum.UserInputType.Touch) then
                local aF = aE.Position - aC
                
                
                local aG = (ao.Scale > 0) and ao.Scale or 1
                _.Size = UDim2.new(0, math.max(560, aD.X.Offset + aF.X / aG),
                                     0, math.max(380, aD.Y.Offset + aF.Y / aG))
            end
        end)
    end

    local aB = {
        gui = Y, win = _, sidebar = aq, pageList = as,
        content = ay, header = au, searchBox = ax, dragHandle = ap,
        pages = {},   
        active = nil,
        winStroke = an, resize = aA,
        uiScale = ao,
    }

    
    table.insert(z, {
        themeUpdate = function()
            _.BackgroundColor3 = w.BgColor
            an.Color = w.OutlineColor
            aq.BackgroundColor3 = w.MainColor
            for aC, aD in ipairs(aq:GetChildren()) do
                if aD:IsA("Frame") then aD.BackgroundColor3 = w.MainColor end
            end
            ar.TextColor3 = w.AccentColor
            ar.Font = al()
            av.BackgroundColor3 = w.MainColor
            aw.TextColor3 = w.FontColor
            ax.TextColor3 = w.FontColor
            ax.Font = al()
            ap.TextColor3 = w.FontColor
            aA.TextColor3 = w.FontColor
            for aC, aD in pairs(aB.pages) do
                if aD.refreshTheme then pcall(aD.refreshTheme) end
            end
        end
    })

    function aB:addPage(aC)
        local aD = ak("TextButton", {
            Parent = as,
            LayoutOrder = #as:GetChildren(),
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        })
        local aE = ak("TextLabel", {
            Parent = aD,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.fromOffset(20, 0),
            BackgroundTransparency = 1,
            Text = aC,
            Font = al(),
            TextSize = 13,
            TextColor3 = w.FontColor,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local aF = ak("Frame", {
            Parent = aD,
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = w.AccentColor,
            BorderSizePixel = 0,
            Visible = false,
        })
local aG=function()            


aD.BackgroundColor3 = w.MainColor
            aE.TextColor3 = w.FontColor
            aE.Font = al()
            aF.BackgroundColor3 = w.AccentColor
end
        
local aH = ak("Frame", {
            Parent = ay,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
        })

        aB.pages[aC] = {
            btn = aD, frame = aH, label = aE, indicator = aF,
            refreshTheme = aG,
        }

        aD.MouseButton1Click:Connect(function() aB:selectPage(aC) end)
        if not aB.active then aB:selectPage(aC) end
        return aH
    end

    function aB:selectPage(aC)
        for aD, aE in pairs(aB.pages) do
            local aF = (aD == aC)
            aE.frame.Visible = aF
            aE.indicator.Visible = aF
            aE.label.TextColor3 = aF and w.AccentColor or w.FontColor
        end
        aB.active = aC
    end

    return aB
end


function aj.newColumn(am, an)
    local ao = ak("Frame", {
        Parent = am,
        Size = UDim2.new(an or 0.5, -12, 1, -20),
        BackgroundTransparency = 1,
    })
    local ap = ak("UIListLayout", {
        Parent = ao,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })
    return ao, ap
end


function aj.newCard(am, an)
    an = an or {}
    local ao = ak("Frame", {
        Parent = am,
        LayoutOrder = an.order or 0,
        Size = UDim2.new(1, 0, 0, an.height or 200),
        BackgroundColor3 = w.MainColor,
        BorderSizePixel = 0,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ao })

    table.insert(z, {
        themeUpdate = function() ao.BackgroundColor3 = w.MainColor end
    })

    local ap
    local aq = ak("Frame", {
        Parent = ao,
        Size = UDim2.new(1, 0, 1, an.tabs and -34 or 0),
        Position = UDim2.fromOffset(0, an.tabs and 34 or 0),
        BackgroundTransparency = 1,
    })

    local ar = {}
    if an.tabs then
        ap = ak("Frame", {
            Parent = ao,
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.fromOffset(10, 4),
            BackgroundTransparency = 1,
        })
        local as = 1 / #an.tabs
        for at, au in ipairs(an.tabs) do
            local av = ak("TextButton", {
                Parent = ap,
                Size = UDim2.new(as, -4, 1, 0),
                Position = UDim2.new((at - 1) * as, 2, 0, 0),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                Text = au,
                Font = al(),
                TextSize = 12,
                TextColor3 = w.FontColor,
                AutoButtonColor = false,
            })
            ak("UICorner", { CornerRadius = UDim.new(0, 6), Parent = av })

            local aw = ak("ScrollingFrame", {
                Parent = aq,
                Size = UDim2.new(1, -16, 1, -8),
                Position = UDim2.fromOffset(8, 4),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = w.AccentColor,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Visible = (at == 1),
            })
            ak("UIListLayout", { Parent = aw, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })
            ar[au] = { btn = av, frame = aw }

            av.MouseButton1Click:Connect(function()
                for ax, ay in pairs(ar) do
                    ay.frame.Visible = (ax == au)
                    ay.btn.BackgroundColor3 = (ax == au) and w.AccentColor or w.BgColor
                end
            end)

            if at == 1 then av.BackgroundColor3 = w.AccentColor end

            table.insert(z, {
                themeUpdate = function()
                    av.Font = al()
                    av.TextColor3 = w.FontColor
                    if aw.Visible then av.BackgroundColor3 = w.AccentColor else av.BackgroundColor3 = w.BgColor end
                    aw.ScrollBarImageColor3 = w.AccentColor
                end
            })
        end
        return ao, ar
    else
        local as = ak("ScrollingFrame", {
            Parent = aq,
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
        ak("UIListLayout", { Parent = as, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })

        if an.title then
            local at = ak("TextLabel", {
                Parent = ao,
                Size = UDim2.new(1, -20, 0, 28),
                Position = UDim2.fromOffset(10, 4),
                BackgroundTransparency = 1,
                Text = an.title,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = w.FontColor,
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            aq.Position = UDim2.fromOffset(0, 30)
            aq.Size = UDim2.new(1, 0, 1, -30)
            table.insert(z, {
                themeUpdate = function() at.TextColor3 = w.FontColor; at.Font = Enum.Font.GothamBold end
            })
        end

        return ao, as
    end
end





function aj.label(am, an, ao)
    ao = ao or {}
    local ap = ak("TextLabel", {
        Parent = am,
        LayoutOrder = ao.order or 0,
        Size = UDim2.new(1, 0, 0, ao.height or 18),
        BackgroundTransparency = 1,
        Text = an,
        Font = al(),
        TextSize = ao.size or 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local aq = { instance = ap, setText = function(aq, ar) ap.Text = ar end }
    function aq.themeUpdate() ap.TextColor3 = w.FontColor; ap.Font = al() end
    table.insert(z, aq)
    return aq
end

function aj.button(am, an, ao)
    local ap = ak("TextButton", {
        Parent = am,
        LayoutOrder = #am:GetChildren(),
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = an,
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        AutoButtonColor = true,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ap })
    ap.MouseButton1Click:Connect(function() pcall(ao) end)

    local aq = { instance = ap, label = an }
    function aq.themeUpdate()
        ap.BackgroundColor3 = w.BgColor
        ap.TextColor3 = w.FontColor
        ap.Font = al()
    end
    table.insert(z, aq)
    return aq
end

function aj.toggle(am, an, ao, ap)
    local aq = ak("Frame", {
        Parent = am,
        LayoutOrder = #am:GetChildren(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    })
    local ar = ak("TextLabel", {
        Parent = aq,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = an,
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local as = ak("TextButton", {
        Parent = aq,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(36, 18),
        BackgroundColor3 = w.BgColor,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    ak("UICorner", { CornerRadius = UDim.new(1, 0), Parent = as })
    local at = ak("Frame", {
        Parent = as,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = w.FontColor,
        BorderSizePixel = 0,
    })
    ak("UICorner", { CornerRadius = UDim.new(1, 0), Parent = at })
local au=function()        

local au = w[ao]
        if au then
            as.BackgroundColor3 = w.AccentColor
            at.Position = UDim2.new(1, -16, 0.5, 0)
        else
            as.BackgroundColor3 = w.BgColor
            at.Position = UDim2.new(0, 2, 0.5, 0)
        end
        at.BackgroundColor3 = w.FontColor
end
    
au()

    as.MouseButton1Click:Connect(function()
        w[ao] = not w[ao]
        au()
        if ap then pcall(ap, w[ao]) end
    end)

    local av = { instance = aq, label = an, key = ao }
    function av.themeUpdate() ar.TextColor3 = w.FontColor; ar.Font = al(); au() end
    function av.refresh() au() end
    table.insert(z, av)
    return av
end

function aj.slider(am, an, ao, ap, aq, ar, as)
    ar = ar or 1
    local at = ak("Frame", {
        Parent = am,
        LayoutOrder = #am:GetChildren(),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 4), Parent = at })

    local au = ak("Frame", {
        Parent = at,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = w.AccentColor,
        BorderSizePixel = 0,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 4), Parent = au })

    local av = ak("TextLabel", {
        Parent = at,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
    })
local aw=function()        

local aw = tonumber(w[ao]) or ap
        aw = math.clamp(aw, ap, aq)
        local ax = (aq == ap) and 0 or (aw - ap) / (aq - ap)
        au.Size = UDim2.new(ax, 0, 1, 0)
        local ay
        if ar < 1 then ay = string.format("%s: %.2f", an, aw) else ay = string.format("%s: %d", an, math.floor(aw + 0.5)) end
        av.Text = ay
end
    
aw()

    local ax = false
local ay=function(ay)        
local az = (ay - at.AbsolutePosition.X) / at.AbsoluteSize.X
        az = math.clamp(az, 0, 1)
        local aA = ap + az * (aq - ap)
        aA = math.floor(aA / ar + 0.5) * ar
        aA = math.clamp(aA, ap, aq)
        w[ao] = aA
        aw()
        if as then pcall(as, aA) end
end
    
at.InputBegan:Connect(function(az)
        if az.UserInputType == Enum.UserInputType.MouseButton1 or az.UserInputType == Enum.UserInputType.Touch then
            ax = true
            ay(az.Position.X)
        end
    end)
    at.InputEnded:Connect(function(az)
        if az.UserInputType == Enum.UserInputType.MouseButton1 or az.UserInputType == Enum.UserInputType.Touch then
            ax = false
        end
    end)
    f.InputChanged:Connect(function(az)
        if ax and (az.UserInputType == Enum.UserInputType.MouseMovement or az.UserInputType == Enum.UserInputType.Touch) then
            ay(az.Position.X)
        end
    end)

    local az = { instance = at, label = an, key = ao }
    function az.themeUpdate()
        at.BackgroundColor3 = w.BgColor
        au.BackgroundColor3 = w.AccentColor
        av.TextColor3 = w.FontColor
        av.Font = al()
    end
    function az.refresh() aw() end
    table.insert(z, az)
    return az
end

function aj.dropdown(am, an, ao, ap, aq)
    local ar = ak("Frame", {
        Parent = am,
        LayoutOrder = #am:GetChildren(),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    local as = ak("TextLabel", {
        Parent = ar,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = an,
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local at = ak("TextButton", {
        Parent = ar,
        Position = UDim2.fromOffset(0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 4), Parent = at })
    local au = ak("TextLabel", {
        Parent = at,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = tostring(w[ao] or "---"),
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local av = ak("TextLabel", {
        Parent = at,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Text = "v",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
    })

    
    local aw
local ax=function()        
if aw then aw:Destroy(); aw = nil; return end
        local ax = ar:FindFirstAncestorOfClass("ScreenGui")
        if not ax then return end
        aw = ak("Frame", {
            Parent = ax,
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        ak("UICorner", { CornerRadius = UDim.new(0, 4), Parent = aw })
        ak("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = aw })

        local ay = at.AbsolutePosition
        local az = at.AbsoluteSize
        local aA = math.min(160, #ap * 22 + 4)
        aw.Position = UDim2.fromOffset(ay.X, ay.Y + az.Y + 2)
        aw.Size = UDim2.fromOffset(az.X, aA)

        local aB = ak("ScrollingFrame", {
            Parent = aw,
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
        ak("UIListLayout", { Parent = aB, SortOrder = Enum.SortOrder.LayoutOrder })

        for aC, aD in ipairs(ap) do
            local aE = ak("TextButton", {
                Parent = aB,
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                Text = tostring(aD),
                Font = al(),
                TextSize = 12,
                TextColor3 = w.FontColor,
                AutoButtonColor = true,
                ZIndex = 52,
            })
            aE.MouseButton1Click:Connect(function()
                w[ao] = aD
                au.Text = tostring(aD)
                if aw then aw:Destroy(); aw = nil end
                if aq then pcall(aq, aD) end
            end)
        end
end
    
at.MouseButton1Click:Connect(ax)

    local ay = { instance = ar, label = an, key = ao, options = ap }
    function ay.setOptions(az, aA)
        ap = aA or {}
        ay.options = ap
        if aw then aw:Destroy(); aw = nil end
    end
    function ay.themeUpdate()
        as.TextColor3 = w.FontColor; as.Font = al()
        at.BackgroundColor3 = w.BgColor
        au.TextColor3 = w.FontColor; au.Font = al()
        av.TextColor3 = w.FontColor
    end
    function ay.refresh() au.Text = tostring(w[ao] or "---") end
    table.insert(z, ay)
    return ay
end

function aj.multiDropdown(am, an, ao, ap, aq)
    
    local ar = ak("Frame", {
        Parent = am,
        LayoutOrder = #am:GetChildren(),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    local as = ak("TextLabel", {
        Parent = ar,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = an,
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local at = ak("TextButton", {
        Parent = ar,
        Position = UDim2.fromOffset(0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 4), Parent = at })
    local au = ak("TextLabel", {
        Parent = at,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = "",
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local av = ak("TextLabel", {
        Parent = at,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Text = "v",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = w.FontColor,
    })
local aw=function()        

local aw = w[ao] or {}
        au.Text = (#aw > 0) and table.concat(aw, ", ") or "---"
end    
aw()

    local ax
local ay=function()        
if ax then ax:Destroy(); ax = nil; return end
        local ay = ar:FindFirstAncestorOfClass("ScreenGui")
        if not ay then return end
        ax = ak("Frame", {
            Parent = ay,
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        ak("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ax })
        ak("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = ax })

        local az = at.AbsolutePosition
        local aA = at.AbsoluteSize
        local aB = math.min(220, #ap * 24 + 4)
        ax.Position = UDim2.fromOffset(az.X, az.Y + aA.Y + 2)
        ax.Size = UDim2.fromOffset(aA.X, aB)

        local aC = ak("ScrollingFrame", {
            Parent = ax,
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
        ak("UIListLayout", { Parent = aC, SortOrder = Enum.SortOrder.LayoutOrder })

        for aD, aE in ipairs(ap) do
            local aF = ak("Frame", {
                Parent = aC,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                ZIndex = 52,
            })
            local aG = ak("TextLabel", {
                Parent = aF,
                Size = UDim2.fromOffset(20, 24),
                BackgroundTransparency = 1,
                Text = D.contains(w[ao] or {}, aE) and "[X]" or "[ ]",
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = w.AccentColor,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 53,
            })
            local aH = ak("TextLabel", {
                Parent = aF,
                Position = UDim2.fromOffset(24, 0),
                Size = UDim2.new(1, -24, 1, 0),
                BackgroundTransparency = 1,
                Text = tostring(aE),
                Font = al(),
                TextSize = 12,
                TextColor3 = w.FontColor,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 53,
            })
            local Y = ak("TextButton", {
                Parent = aF,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 54,
            })
            Y.MouseButton1Click:Connect(function()
                w[ao] = w[ao] or {}
                local Z = w[ao]
                local _
                for aI, aJ in ipairs(Z) do if aJ == aE then _ = aI break end end
                if _ then table.remove(Z, _) else table.insert(Z, aE) end
                aG.Text = D.contains(Z, aE) and "[X]" or "[ ]"
                aw()
                if aq then pcall(aq, Z) end
            end)
        end
end
    
at.MouseButton1Click:Connect(ay)

    local az = { instance = ar, label = an, key = ao, options = ap }
    function az.themeUpdate()
        as.TextColor3 = w.FontColor; as.Font = al()
        at.BackgroundColor3 = w.BgColor
        au.TextColor3 = w.FontColor; au.Font = al()
        av.TextColor3 = w.FontColor
    end
    function az.refresh() aw() end
    table.insert(z, az)
    return az
end

function aj.colorPicker(am, an, ao, ap)
    local aq = ak("Frame", {
        Parent = am,
        LayoutOrder = #am:GetChildren(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    })
    local ar = ak("TextLabel", {
        Parent = aq,
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = an,
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local as = ak("TextButton", {
        Parent = aq,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(28, 18),
        BackgroundColor3 = w[ao] or Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 3), Parent = as })
    ak("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = as })

    local at
local au=function()        
as.BackgroundColor3 = w[ao] or Color3.new(1, 1, 1)
end local av=function()        


if at then at:Destroy(); at = nil; return end
        local av = aq:FindFirstAncestorOfClass("ScreenGui")
        if not av then return end
        at = ak("Frame", {
            Parent = av,
            BackgroundColor3 = w.MainColor,
            BorderSizePixel = 0,
            ZIndex = 50,
        })
        ak("UICorner", { CornerRadius = UDim.new(0, 6), Parent = at })
        ak("UIStroke", { Color = w.OutlineColor, Transparency = 0.5, Parent = at })

        local aw = as.AbsolutePosition
        at.Position = UDim2.fromOffset(aw.X - 160, aw.Y + 24)
        at.Size = UDim2.fromOffset(190, 130)
local ax=function(
ax, ay, az)            
local aA = ak("Frame", {
                Parent = at,
                Position = UDim2.fromOffset(36, az),
                Size = UDim2.fromOffset(140, 16),
                BackgroundColor3 = w.BgColor,
                BorderSizePixel = 0,
                ZIndex = 51,
            })
            ak("UICorner", { CornerRadius = UDim.new(0, 3), Parent = aA })
            local aB = ak("Frame", {
                Parent = aA,
                Size = UDim2.new((w[ao][ay] or 1), 0, 1, 0),
                BackgroundColor3 = ay == "R" and Color3.fromRGB(220, 38, 38)
                                or ay == "G" and Color3.fromRGB(34, 197, 94)
                                or                    Color3.fromRGB(59, 130, 246),
                BorderSizePixel = 0,
                ZIndex = 52,
            })
            ak("UICorner", { CornerRadius = UDim.new(0, 3), Parent = aB })
            local aC = ak("TextLabel", {
                Parent = at,
                Position = UDim2.fromOffset(8, az),
                Size = UDim2.fromOffset(24, 16),
                BackgroundTransparency = 1,
                Text = ax,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = w.FontColor,
                ZIndex = 51,
            })
            local aD = ak("TextLabel", {
                Parent = at,
                Position = UDim2.fromOffset(178, az),
                Size = UDim2.fromOffset(0, 16),
                BackgroundTransparency = 1,
                Text = "",
                Font = al(),
                TextSize = 11,
                TextColor3 = w.FontColor,
                ZIndex = 51,
            })
local aE=function(aE)                
aE = math.clamp(aE, 0, 1)
                local aF = w[ao]
                local aG, aH, aI = aF.R, aF.G, aF.B
                if ay == "R" then aG = aE end
                if ay == "G" then aH = aE end
                if ay == "B" then aI = aE end
                w[ao] = Color3.new(aG, aH, aI)
                aB.Size = UDim2.new(aE, 0, 1, 0)
                aD.Text = tostring(math.floor(aE * 255 + 0.5))
                au()
                if ap then pcall(ap, w[ao]) end
end            
aD.Text = tostring(math.floor((w[ao][ay] or 0) * 255 + 0.5))

            local aF
            aA.InputBegan:Connect(function(aG)
                if aG.UserInputType == Enum.UserInputType.MouseButton1 or aG.UserInputType == Enum.UserInputType.Touch then
                    aF = true
                    aE((aG.Position.X - aA.AbsolutePosition.X) / aA.AbsoluteSize.X)
                end
            end)
            aA.InputEnded:Connect(function(aG)
                if aG.UserInputType == Enum.UserInputType.MouseButton1 or aG.UserInputType == Enum.UserInputType.Touch then
                    aF = false
                end
            end)
            f.InputChanged:Connect(function(aG)
                if aF and (aG.UserInputType == Enum.UserInputType.MouseMovement or aG.UserInputType == Enum.UserInputType.Touch) then
                    aE((aG.Position.X - aA.AbsolutePosition.X) / aA.AbsoluteSize.X)
                end
            end)
end
        
ax("R", "R", 10)
        ax("G", "G", 36)
        ax("B", "B", 62)

        local ay = ak("TextButton", {
            Parent = at,
            Position = UDim2.fromOffset(36, 92),
            Size = UDim2.fromOffset(140, 24),
            BackgroundColor3 = w.AccentColor,
            BorderSizePixel = 0,
            Text = "Done",
            Font = al(),
            TextSize = 12,
            TextColor3 = w.FontColor,
            AutoButtonColor = true,
            ZIndex = 51,
        })
        ak("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ay })
        ay.MouseButton1Click:Connect(function()
            if at then at:Destroy(); at = nil end
        end)
end
    
as.MouseButton1Click:Connect(av)

    local aw = { instance = aq, label = an, key = ao }
    function aw.themeUpdate()
        ar.TextColor3 = w.FontColor; ar.Font = al()
        au()
    end
    function aw.refresh() au() end
    table.insert(z, aw)
    return aw
end

function aj.textInput(am, an, ao, ap, aq)
    local ar = ak("Frame", {
        Parent = am,
        LayoutOrder = #am:GetChildren(),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    local as = ak("TextLabel", {
        Parent = ar,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = an,
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local at = ak("TextBox", {
        Parent = ar,
        Position = UDim2.fromOffset(0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = tostring(w[ao] or ""),
        PlaceholderText = ap or "",
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        PlaceholderColor3 = Color3.fromRGB(120, 130, 140),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 4), Parent = at })
    local au = ak("UIPadding", { Parent = at, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

    at.FocusLost:Connect(function()
        w[ao] = at.Text
        if aq then pcall(aq, at.Text) end
    end)

    local av = { instance = ar, label = an, key = ao }
    function av.themeUpdate()
        as.TextColor3 = w.FontColor; as.Font = al()
        at.BackgroundColor3 = w.BgColor
        at.TextColor3 = w.FontColor
        at.Font = al()
    end
    function av.refresh() at.Text = tostring(w[ao] or "") end
    table.insert(z, av)
    return av
end

function aj.keybind(am, an, ao, ap)
    local aq = ak("Frame", {
        Parent = am,
        LayoutOrder = #am:GetChildren(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    })
    local ar = ak("TextLabel", {
        Parent = aq,
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Text = an,
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local as = ak("TextButton", {
        Parent = aq,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(96, 22),
        BackgroundColor3 = w.BgColor,
        BorderSizePixel = 0,
        Text = tostring(w[ao] or "None"),
        Font = al(),
        TextSize = 12,
        TextColor3 = w.FontColor,
        AutoButtonColor = true,
    })
    ak("UICorner", { CornerRadius = UDim.new(0, 4), Parent = as })

    local at = false
    as.MouseButton1Click:Connect(function()
        at = true
        as.Text = "..."
    end)
    f.InputBegan:Connect(function(au, av)
        if not at then return end
        if au.UserInputType ~= Enum.UserInputType.Keyboard then return end
        at = false
        local aw = au.KeyCode.Name
        w[ao] = aw
        as.Text = aw
        if ap then pcall(ap, aw) end
    end)

    local au = { instance = aq, label = an, key = ao }
    function au.themeUpdate()
        ar.TextColor3 = w.FontColor; ar.Font = al()
        as.BackgroundColor3 = w.BgColor
        as.TextColor3 = w.FontColor; as.Font = al()
    end
    function au.refresh() as.Text = tostring(w[ao] or "None") end
    table.insert(z, au)
    return au
end
local am=function()    




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

    local am = G.humanoid()
    if am then pcall(function() am.WalkSpeed = v.DefaultWS; am.JumpPower = v.DefaultJP end) end
    local an = G.root()
    if an then pcall(function() an.Anchored = false end) end
local ao=function(

ao)        
if not ao then return end
        for ap, aq in ipairs(ao:GetChildren()) do
            if aq:IsA("ScreenGui") and (aq.Name:sub(1, 6) == "_NHJB_" or aq.Name:sub(1, 9) == "_NHJB_NF_") then
                pcall(function() aq:Destroy() end)
            end
        end
end    
ao(m)
    if q then ao(q:FindFirstChild("PlayerGui")) end
    _G._NHJB_NotifyGui = nil

    getgenv()._NameHubJB_Alive  = false
    getgenv()._NameHubJB_Unload = nil
end




C = aj.newWindow({ width = 760, height = 520 })
local an, ao, ap, aq
local ar, as, at, au


local av = C:addPage("Main")

local aw  = aj.newColumn(av, 0.5)
aw.Position = UDim2.fromOffset(8, 8)

local ax = aj.newColumn(av, 0.5)
ax.Position = UDim2.new(0.5, 4, 0, 8)


local ay, az = aj.newCard(aw, { tabs = { "Main", "ESP" }, height = 360 })

do
    local aA = az["Main"].frame
    aj.toggle(aA, "Autofarm", "Autofarm", function(aB)
        if aB then
            w.StartTime = w.StartTime or os.time()
            w.StatsCounting = true
            M.start()
        else
            G.applySpeed()
        end
    end)
    aj.dropdown(aA, "Farm Targets", "FarmTarget", v.FarmTargetOptions, function(aB)
        
        if #w.FarmPriority == 0 then w.FarmPriority = { aB } end
    end)
    aj.multiDropdown(aA, "Farm Priority List", "FarmPriority", v.FarmTargetOptions)
    aj.toggle(aA, "Skip Players (NPC-only autofarm)", "SkipPlayers")
    
    aj.dropdown(aA, "Movement Mode", "AutofarmMovement", v.MovementOptions, function(aB)
        
        
        if aB ~= "Fly" then T.stopFly() end
    end)
    aj.slider(aA, "Stop Distance (Fly/Walk only)", "StopDistance", 2, 30, 1)
    aj.slider(aA, "Speed", "Speed", 16, 200, 1, function() G.applySpeed() end)
    aj.dropdown(aA, "Autofarm Dino", "AutofarmDino", v.DinoOptions, function(aB)
        local aC = H.remoteByKeywords(v.DinoChangeKeywords)
        if aC then
            pcall(function()
                if aC:IsA("RemoteEvent") then aC:FireServer(aB) else aC:InvokeServer(aB) end
            end)
        end
    end)

    local aB = aj.label(aA, "Coins Gained: 0")
    local aC  = aj.label(aA, "Rate: N/A")
    local aD = aj.label(aA, "Time Elapsed: N/A")
    an, ap, ao = aB, aC, aD

    
    
    
    local aE  = aj.label(aA, "Status: Idle")
    local aF   = aj.label(aA, "Targets: 0 humanoids / 0 by name")
    local aG  = aj.label(aA, "Attack remote: (not discovered)")
    local aH = aj.label(aA, "Last fire: -")
    _G._JB_StatusLbl  = aE
    _G._JB_FoundLbl   = aF
    _G._JB_RemoteLbl  = aG
    _G._JB_LastFireLbl = aH

    aj.button(aA, "Start Counting Stats", function()
        w.CoinsGained = 0
        w.StartTime = os.time()
        w.StatsCounting = true
        F.send("Stats counter started.")
    end)

    
    
    
    
    aj.button(aA, "Copy Diagnostics", function()
        local aI = { "=== NameHub JB Diagnostics ===", "Build: " .. a }
        aI[#aI + 1] = "FarmTarget: " .. tostring(w.FarmTarget)
        aI[#aI + 1] = "FarmPriority: " .. table.concat(w.FarmPriority or {}, ", ")
        aI[#aI + 1] = "SkipPlayers: " .. tostring(w.SkipPlayers)
        aI[#aI + 1] = "Status: " .. tostring(w._FarmStatus)
        aI[#aI + 1] = "LastTarget: " .. tostring(w._LastTarget) .. " @ " .. tostring(math.floor(w._LastDistance or 0)) .. "m"
        aI[#aI + 1] = "AttackRemote: " .. tostring(w._AttackRemote)
        aI[#aI + 1] = "LastFire: " .. tostring(w._LastFire)
        aI[#aI + 1] = "TargetsFound (humanoid): " .. tostring(w._TargetsFound)
        aI[#aI + 1] = "TargetsFound (name fallback): " .. tostring(w._NamedFound)
        aI[#aI + 1] = ""
        aI[#aI + 1] = "--- Nearby humanoid targets (top 20) ---"
        for aJ, Y in ipairs(I.dump(20)) do
            aI[#aI + 1] = Y
        end
        aI[#aI + 1] = ""
        aI[#aI + 1] = "--- Name-fallback matches per priority ---"
        local aJ = G.root()
        for Y, Z in ipairs(w.FarmPriority or {}) do
            aI[#aI + 1] = ("> %s:"):format(Z)
            local _ = I.allByName(Z)
            local aK = 0
            for aL, aM in ipairs(_) do
                if aK >= 10 then break end
                local aN = aJ and D.distance(aJ, aM.root) or -1
                aI[#aI + 1] = ("    %-30s dist=%-6.1f hum=%s"):format(
                    aM.model.Name:sub(1, 30), aN, aM.hum and "yes" or "no")
                aK = aK + 1
            end
            if #_ == 0 then aI[#aI + 1] = "    (none found)" end
        end
        aI[#aI + 1] = ""
        aI[#aI + 1] = "--- Remotes in ReplicatedStorage (top 40) ---"
        for aK, aL in ipairs(H.allRemotes(40)) do
            aI[#aI + 1] = aL
        end
        local aK = table.concat(aI, "\n")
        pcall(setclipboard, aK)
        F.send(("Diagnostics copied to clipboard (%d lines). Paste in Discord."):format(#aI), 5)
    end)
end

do
    local aA = az["ESP"].frame
    aj.toggle(aA, "Goat ESP", "GoatESP", function(aB)
        if aB then O.start() end
    end)
    aj.colorPicker(aA, "Goat ESP Color", "GoatESPColor")
    aj.toggle(aA, "Amber ESP", "AmberESP", function(aB)
        if aB then O.start() end
    end)
    aj.colorPicker(aA, "Amber ESP Color", "AmberESPColor")
    aj.toggle(aA, "No Prompt Delay", "NoPromptDelay")
    aj.slider(aA, "Outline Transparency", "OutlineTransparency", 0, 1, 0.05, function() O.refresh() end)
    aj.slider(aA, "Fill Transparency", "FillTransparency", 0, 1, 0.05, function() O.refresh() end)
end


local aA, aB = aj.newCard(ax, { tabs = { "Player", "Combat" }, height = 360 })

do
    local aC = aB["Player"].frame
    aj.toggle(aC, "Fly", "Fly", function(aD)
        if aD then P.enable() else P.disable() end
    end)
    aj.slider(aC, "Fly Speed", "FlySpeed", 10, 300, 1)
    aj.button(aC, "Respawn", function() W.respawn() end)
    aj.button(aC, "Menu", function() W.openMenu() end)
    aj.slider(aC, "Respawn Delay", "RespawnDelay", 0, 30, 1)
    aj.toggle(aC, "Auto Respawn", "AutoRespawn")
    aj.toggle(aC, "Anchored", "Anchored", function() G.applyAnchor() end)
end

do
    local aC = aB["Combat"].frame
    aj.slider(aC, "Offset (X-axis)", "OffsetX", -20, 20, 1)
    aj.slider(aC, "Offset (Y-axis)", "OffsetY", -20, 20, 1)
    aj.slider(aC, "Range", "Range", 5, 200, 1)
    aj.slider(aC, "Max Target HP", "MaxTargetHP", 0, 5000, 10)
    aj.slider(aC, "Min Target HP", "MinTargetHP", 0, 5000, 10)
    aj.slider(aC, "Disengage At", "DisengageAt", 0, 1000, 10)
    aj.toggle(aC, "Target POV", "TargetPOV")
    aj.toggle(aC, "Auto Attack Nearby Player", "AutoAttackNearby")
    aj.toggle(aC, "Auto Attack", "AutoAttack")
    aj.toggle(aC, "Auto TP to Player", "AutoTPToPlayer")
local aD=function()        


local aD = { "" }
        for aE, aF in ipairs(d:GetPlayers()) do
            if aF ~= q then aD[#aD + 1] = aF.Name end
        end
        return aD
end    
au = aj.dropdown(aC, "Target Player", "TargetPlayer", aD())
    
    D.conn("tp_player_add", d.PlayerAdded:Connect(function() au:setOptions(aD()) end))
    D.conn("tp_player_rem", d.PlayerRemoving:Connect(function() au:setOptions(aD()) end))
end


local aC = C:addPage("Teleport")
local aD  = aj.newColumn(aC, 0.5)
aD.Position = UDim2.fromOffset(8, 8)
local aE, aF = aj.newCard(aD, { title = "Server Hop", height = 460 })

do
    aj.button(aF, "Join selected server", function()
        if w.SelectedJobId ~= "" then X.joinJobId(w.SelectedJobId) end
    end)
    aj.button(aF, "Refresh Server List", function()
        F.send("Fetching servers...")
        D.spawn(function()
            local aG = X.fetchServers()
            w.ServerListCache = aG
            local aH = {}
            for aI, aJ in ipairs(aG) do aH[#aH + 1] = ("%s  (%d/%d)"):format(aJ.id:sub(1, 8), aJ.playing, aJ.max) end
            if #aH == 0 then aH = { "(no servers)" } end
            ar:setOptions(aH)
            F.send(("Fetched %d servers"):format(#aG))
        end)
    end)
    ar = aj.dropdown(aF, "Server List", "SelectedJobId", { "---" }, function(aG)
        for aH, aI in ipairs(w.ServerListCache or {}) do
            if aG:sub(1, 8) == aI.id:sub(1, 8) then w.SelectedJobId = aI.id; return end
        end
    end)
    aj.button(aF, "Get PlayerCount", function()
        for aG, aH in ipairs(w.ServerListCache or {}) do
            if aH.id == w.SelectedJobId then
                F.send(("Server %s: %d/%d players"):format(aH.id:sub(1,8), aH.playing, aH.max))
                return
            end
        end
        F.send("Refresh server list first.")
    end)
    aj.button(aF, "Copy JobId", function()
        pcall(setclipboard, w.SelectedJobId)
        F.send("Copied JobId.")
    end)
    aj.button(aF, "Join Selected JobId", function()
        X.joinJobId(w.SelectedJobId)
    end)
    aj.textInput(aF, "JobId", "SelectedJobId", "Enter JobId here")
    aj.button(aF, "Rejoin Server", function() X.rejoin() end)
    aj.button(aF, "Server Hop", function() X.randomHop() end)
    aj.slider(aF, "Hop On Player Count", "HopOnPlayerCount", 0, 30, 1)
    aj.toggle(aF, "Hop On Friend Detection", "HopOnFriend")
end


local aG = C:addPage("Safety")
local aH = aj.newColumn(aG, 0.5)
aH.Position = UDim2.fromOffset(8, 8)
local aI, aJ = aj.newCard(aH, { title = "Admin Detection", height = 80 })
aj.toggle(aJ, "Kick On Detection", "KickOnAdmin")


local aK = C:addPage("Webhook")
local aL  = aj.newColumn(aK, 0.5)
aL.Position = UDim2.fromOffset(8, 8)
local aM, aN = aj.newCard(aL, { title = "Webhook", height = 280 })
do
    aj.textInput(aN, "Webhook Link", "WebhookLink", "https://discord.com/api/webhooks/...")
    aj.slider(aN, "Webhook Interval (minutes)", "WebhookInterval", 1, 60, 1)
    aj.slider(aN, "Timezone (UTC offset)", "WebhookTimezone", -12, 12, 1)
    aj.colorPicker(aN, "Embed Color", "WebhookColor")
    aj.toggle(aN, "Anonymous Mode", "WebhookAnonymous")
    aj.button(aN, "Force Send Webhook Request", function() ab.send(true) end)
end


local Y = C:addPage("Settings")

local Z  = aj.newColumn(Y, 0.5)
Z.Position = UDim2.fromOffset(8, 8)
local _ = aj.newColumn(Y, 0.5)
_.Position = UDim2.new(0.5, 4, 0, 8)

local aO, aP = aj.newCard(Z, { title = "Themes", height = 280 })
do
    aj.colorPicker(aP, "Background color", "BgColor",   function() ae.apply() end)
    aj.colorPicker(aP, "Main color",        "MainColor", function() ae.apply() end)
    aj.colorPicker(aP, "Accent color",      "AccentColor", function() ae.apply() end)
    aj.colorPicker(aP, "Outline color",     "OutlineColor", function() ae.apply() end)
    aj.colorPicker(aP, "Font color",        "FontColor", function() ae.apply() end)
    aj.dropdown(aP, "Font Face", "FontFace", v.FontOptions, function() ae.apply() end)
    at = aj.dropdown(aP, "Theme list", "Theme", ae.listNames())
    aj.button(aP, "Load theme", function() ae.load(w.Theme) end)
    aj.button(aP, "Overwrite theme", function()
        if ae.saveCurrent(w.Theme) then F.send("Saved theme: " .. w.Theme) end
    end)
end

local aQ, aR = aj.newCard(_, { title = "Configuration", height = 320 })
do
    aj.textInput(aR, "Config name", "_cfgName", "name")
    aj.button(aR, "Create config", function() af.save(w._cfgName or "") end)
    as = aj.dropdown(aR, "Config list", "_cfgPicked", af.list())
    aj.button(aR, "Refresh list", function() as:setOptions(af.list()) end)
    aj.button(aR, "Load config",      function() af.load(w._cfgPicked or "") end)
    aj.button(aR, "Overwrite config", function() af.save(w._cfgPicked or "") end)
    aj.button(aR, "Delete config",    function()
        af.delete(w._cfgPicked or "")
        as:setOptions(af.list())
    end)
    aj.button(aR, "Set autoload",   function()
        if w._cfgPicked and w._cfgPicked ~= "" then
            af.setAutoload(w._cfgPicked)
            if aq then aq:setText("Current autoload config: " .. w.AutoloadConfig) end
            F.send("Autoload set: " .. w.AutoloadConfig)
        end
    end)
    aj.button(aR, "Reset autoload", function()
        af.resetAutoload()
        if aq then aq:setText("Current autoload config: none") end
    end)
    aq = aj.label(aR,
        "Current autoload config: " .. (af.getAutoload() ~= "" and af.getAutoload() or "none"))
    aj.textInput(aR, "Import Data", "_importData", "paste exported config here")
    aj.button(aR, "Export config", function()
        local aS = af.exportCurrent()
        pcall(setclipboard, aS)
        F.send("Exported to clipboard.")
    end)
    aj.button(aR, "Import config", function() af.importString(w._importData or "") end)
end

local aS, aT = aj.newCard(Z, { title = "Menu", height = 160 })
do
    aj.keybind(aT, "Menu bind", "MenuBind")
    aj.toggle(aT, "Autoexecute", "Autoexecute", function(aU)
        if aU then
            
            local aV = 'pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/kyronshaw912-collab/NameHub/main/loader.lua"))() end)'
            local aW = { "autoexec/", "auto_exec/", "autoexecute/" }
            local aX
            for aY, aZ in ipairs(aW) do
                local a_ = pcall(b.writefile, aZ .. "NameHubJB_loader.lua", aV)
                if a_ then aX = aZ; break end
            end
            if aX then F.send("Autoexec written: " .. aX) else F.send("Autoexec unsupported by executor.") end
        end
    end)
    aj.dropdown(aT, "Notification Side", "NotificationSide", v.NotifySides)
    aj.dropdown(aT, "UI Zoom", "_ZoomPick",
        { "75%", "100%", "125%", "150%", "175%", "200%", "250%" },
        function(aU)
            local aV = tonumber((aU:gsub("%%", "")))
            if aV and aV > 0 then
                w.UIScale = aV / 100
                if C and C.uiScale then C.uiScale.Scale = w.UIScale end
            end
        end
    )
end




C.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local aU = C.searchBox.Text:lower()
    for aV, aW in pairs(z) do
        if aW.instance and aW.label and aW.instance.Parent then
            local aX = (aU == "") or aW.label:lower():find(aU, 1, true)
            aW.instance.Visible = aX and true or false
        end
    end
end)




D.conn("ui_toggle", f.InputBegan:Connect(function(aU, aV)
    if aV then return end
    if aU.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if aU.KeyCode.Name == w.MenuBind then
        w.UIVisible = not w.UIVisible
        C.win.Visible = w.UIVisible
    end
end))




D.conn("stats_tick", e.Heartbeat:Connect(function()
    if not w.Alive then return end
    if an then an:setText("Coins Gained: " .. tostring(w.CoinsGained)) end
    if w.StartTime and w.StatsCounting then
        local aU = os.time() - w.StartTime
        if ao  then ao:setText("Time Elapsed: " .. D.fmtTime(aU)) end
        if ap then
            local aV = aU > 0 and (w.CoinsGained / (aU / 60)) or 0
            ap:setText(("Rate: %.1f/min"):format(aV))
        end
    else
        if ao  then ao:setText("Time Elapsed: N/A") end
        if ap then ap:setText("Rate: N/A") end
    end
    
    if _G._JB_StatusLbl   then _G._JB_StatusLbl  :setText("Status: " .. tostring(w._FarmStatus)) end
    if _G._JB_FoundLbl    then _G._JB_FoundLbl   :setText(("Targets: %d humanoids / %d by name"):format(w._TargetsFound or 0, w._NamedFound or 0)) end
    if _G._JB_RemoteLbl   then _G._JB_RemoteLbl  :setText("Attack remote: " .. (w._AttackRemote ~= "" and w._AttackRemote or "(not discovered)")) end
    if _G._JB_LastFireLbl then _G._JB_LastFireLbl:setText("Last fire: " .. (w._LastFire ~= "" and w._LastFire or "-")) end
end))




D.conn("charadded", q.CharacterAdded:Connect(function()
    task.wait(0.2)
    if w.Fly then P.enable() end
    G.applySpeed()
    G.applyAnchor()
end))




getgenv()._NameHubJB_Alive  = true
getgenv()._NameHubJB_Unload = am

ad()
W.attachAutoRespawn()
X.attachWatchers()
aa.attach()
ab.attachInterval()
N.start()


do
    local aU = af.getAutoload()
    if aU ~= "" then
        w.AutoloadConfig = aU
        af.load(aU)
        if aq then aq:setText("Current autoload config: " .. aU) end
    end
end

ae.apply()
F.send(v.Brand .. " " .. v.SubBrand .. " " .. a .. " loaded.", 4)

return true
