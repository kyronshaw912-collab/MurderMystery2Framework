





















if not game:IsLoaded() then game.Loaded:Wait() end

local a = "v0.1.0 NameHub (rivals-initial-20260530)"








local b = {
    [6035872082] = "Rivals",
}

if not b[game.GameId] then
    warn(("[NameHub] This script is for Rivals. Current PlaceId %d / UniverseId %d is not supported."):format(game.PlaceId, game.GameId))
    return
end




local c          = game:GetService("Players")
local d       = game:GetService("RunService")
local e = game:GetService("UserInputService")
local f     = game:GetService("TweenService")
local g        = game:GetService("Workspace")
local h       = game:GetService("StarterGui")
local i          = game:GetService("CoreGui")
local j         = game:GetService("Lighting")

local k = c.LocalPlayer
local l      = g.CurrentCamera
local m       = k:GetMouse()




local n = setclipboard or (toclipboard) or function(n) end
local o = (rawget and rawget(getfenv(), "mousemoverel")) or _G.mousemoverel




local p = {}

local q = {}

function q.safe(r, s)
    return function(...)
        local t, u = pcall(r, ...)
        if not t then
            warn(("[NameHub][%s] %s"):format(s or "?", tostring(u)))
        end
        return t
    end
end

function q.conn(r, s)
    if p[r] and p[r].Connected then p[r]:Disconnect() end
    p[r] = s
    return s
end

function q.disconnect(r)
    if p[r] and p[r].Connected then p[r]:Disconnect() end
    p[r] = nil
end

function q.distance(r, s)
    if not r or not s then return math.huge end
    return ((r.Position or r) - (s.Position or s)).Magnitude
end




local r = {
    
    AimEnabled         = true,
    AimMode            = "Hold",          
    AimKey             = Enum.UserInputType.MouseButton2,
    AimBone            = "Head",          
    AimFov             = 90,              
    AimSmoothness      = 0.35,            
    AimTeamCheck       = true,
    AimVisibleCheck    = true,            
    AimAliveCheck      = true,
    AimPrediction      = 0.13,            
    AimSticky          = false,           

    
    FovCircleEnabled   = true,
    FovCircleColor     = Color3.fromRGB(255, 255, 255),
    FovCircleFilled    = false,
    FovCircleThickness = 1,

    
    EspEnabled         = true,
    EspTeamCheck       = true,
    EspMaxDistance     = 2000,            

    
    EspBoxes           = true,
    EspBoxColor        = Color3.fromRGB(255, 60, 60),
    EspBoxThickness    = 1,

    
    EspNames           = true,
    EspNameColor       = Color3.fromRGB(255, 255, 255),
    EspNameSize        = 14,

    
    EspHealth          = true,
    EspHealthHigh      = Color3.fromRGB(60, 220, 80),
    EspHealthLow       = Color3.fromRGB(220, 60, 60),

    
    EspTracers         = false,
    EspTracerColor     = Color3.fromRGB(255, 60, 60),
    EspTracerOrigin    = "Bottom",        
    EspTracerThickness = 1,

    
    EspChams           = true,
    EspChamsFill       = Color3.fromRGB(255, 60, 60),
    EspChamsOutline    = Color3.fromRGB(255, 255, 255),
    EspChamsFillAlpha  = 0.5,

    
    Alive              = true,
    _CurrentTarget     = nil,             
    _AimActive         = false,
    _FoundTargets      = 0,
}







local s = {}

function s.isFriendly(t)
    if not t or t == k then return true end
    if not r.AimTeamCheck then return false end
    local u = k.Team
    if u and t.Team and t.Team == u then return true end
    return false
end

function s.isFriendlyForEsp(t)
    if not t or t == k then return true end
    if not r.EspTeamCheck then return false end
    local u = k.Team
    if u and t.Team and t.Team == u then return true end
    return false
end
local t=function(



t, u)    
if not t then return nil end
    if u == "Random" then
        local v = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }
        u = v[math.random(1, #v)]
    end
    local v = t:FindFirstChild(u)
    if v and v:IsA("BasePart") then return v end
    return t:FindFirstChild("HumanoidRootPart")
        or t:FindFirstChild("UpperTorso")
        or t:FindFirstChild("Torso")
        or t.PrimaryPart
end local u=function(

u)return u and u:FindFirstChildOfClass("Humanoid") end local v=function(

v)    
local w = v and v.Character
    local x = w and u(w)
    return x and x.Health > 0
end




local w = {}
local x=function(


x, y)    
local z = l.CFrame.Position
    local A = (x.Position - z)
    local B = RaycastParams.new()
    B.FilterType = Enum.RaycastFilterType.Exclude
    B.FilterDescendantsInstances = { k.Character, y, l }
    local C = g:Raycast(z, A, B)
    if not C then return true end
    return C.Instance:IsDescendantOf(y)
end local y=function(




y)    
if r.AimPrediction <= 0 then return y.Position end
    local z
    pcall(function() z = y.AssemblyLinearVelocity end)
    if not z then return y.Position end
    return y.Position + z * r.AimPrediction
end




function w.findTarget()
    if not r.AimEnabled then return nil end
    local z = Vector2.new(l.ViewportSize.X * 0.5, l.ViewportSize.Y * 0.5)
    local A, B
    local C = 0
    for D, E in ipairs(c:GetPlayers()) do
        if E ~= k
           and (not r.AimTeamCheck or not s.isFriendly(E))
           and (not r.AimAliveCheck or v(E)) then
            local F = E.Character
            local G = F and t(F, r.AimBone)
            if G then
                local H = y(G)
                local I, J = l:WorldToViewportPoint(H)
                if J and I.Z > 0 then
                    local K = (Vector2.new(I.X, I.Y) - z).Magnitude
                    if K <= r.AimFov and (not B or K < B) then
                        if not r.AimVisibleCheck or x(G, F) then
                            A, B = { plr = E, bone = G, screen = I }, K
                        end
                    end
                end
                C = C + 1
            end
        end
    end
    r._FoundTargets = C
    return A
end




function w.aimAt(z)
    if not z or not z.bone or not z.bone.Parent then return end
    local A = y(z.bone)
    local B = CFrame.lookAt(l.CFrame.Position, A)
    if r.AimSmoothness <= 0 then
        l.CFrame = B
    else
        
        
        local C = 1 - math.clamp(r.AimSmoothness, 0, 0.99)
        l.CFrame = l.CFrame:Lerp(B, C)
    end
end







local z = Drawing
local A=function(A, B)    
if not z then return nil end
    local C
    local D = pcall(function() C = z.new(A) end)
    if not D or not C then return nil end
    for E, F in pairs(B or {}) do
        pcall(function() C[E] = F end)
    end
    return C
end





local B = A("Circle", {
    Thickness   = r.FovCircleThickness,
    NumSides    = 60,
    Radius      = r.AimFov,
    Filled      = r.FovCircleFilled,
    Visible     = r.FovCircleEnabled,
    Color       = r.FovCircleColor,
    Transparency= 0.8,
})
local C=function()    

if not B then return end
    pcall(function()
        B.Radius    = r.AimFov
        B.Visible   = r.FovCircleEnabled
        B.Filled    = r.FovCircleFilled
        B.Color     = r.FovCircleColor
        B.Thickness = r.FovCircleThickness
        B.Position  = Vector2.new(l.ViewportSize.X * 0.5, l.ViewportSize.Y * 0.5)
    end)
end






local D = {}
local E=function(
E)    
local F = {
        plr = E,
        box     = A("Square",   { Thickness = 1, Filled = false, Visible = false, Color = r.EspBoxColor, Transparency = 1 }),
        boxOut  = A("Square",   { Thickness = 3, Filled = false, Visible = false, Color = Color3.new(0,0,0), Transparency = 0.7 }),
        name    = A("Text",     { Size = r.EspNameSize, Center = true, Outline = true, Visible = false, Color = r.EspNameColor, Font = 2 }),
        hbBg    = A("Square",   { Thickness = 1, Filled = true, Visible = false, Color = Color3.new(0,0,0), Transparency = 0.6 }),
        hbFg    = A("Square",   { Thickness = 1, Filled = true, Visible = false, Color = r.EspHealthHigh }),
        tracer  = A("Line",     { Thickness = r.EspTracerThickness, Visible = false, Color = r.EspTracerColor }),
        highlight = nil,
    }
    D[E] = F
    return F
end local F=function(

F)    
local G = D[F]
    if not G then return end
    for H, I in pairs(G) do
        if H ~= "plr" and I then
            pcall(function() I:Remove() end)
        end
    end
    D[F] = nil
end local G=function(




G)    
local H = G:FindFirstChild("Head")
    local I = G:FindFirstChild("HumanoidRootPart")
    if not (H and I) then return nil end
    local J, K   = l:WorldToViewportPoint(H.Position + Vector3.new(0, 1, 0))
    local L, M   = l:WorldToViewportPoint(I.Position - Vector3.new(0, 3, 0))
    if not (K or M) then return nil end
    local N = math.abs(J.Y - L.Y)
    local O  = N * 0.6
    local P      = (J.X + L.X) * 0.5 - O * 0.5
    local Q      = math.min(J.Y, L.Y)
    return P, Q, O, N
end local H=function(

H)    
local I = H.plr
    if not I or not I.Parent or I == k then return F(I) end
    local J = s.isFriendlyForEsp(I)
    local K = I.Character
    local L  = K and u(K)
    local M  = K and K:FindFirstChild("HumanoidRootPart")

    local N = not r.EspEnabled or J or not K or not L or L.Health <= 0 or not M

    if N then
        for O, P in pairs(H) do
            if O ~= "plr" and P and P.Visible ~= nil then pcall(function() P.Visible = false end) end
        end
        if H.highlight then pcall(function() H.highlight.Enabled = false end) end
        return
    end

    local O = k.Character and k.Character:FindFirstChild("HumanoidRootPart")
    local P = O and q.distance(O, M) or 0
    if P > r.EspMaxDistance then
        for Q, R in pairs(H) do
            if Q ~= "plr" and R and R.Visible ~= nil then pcall(function() R.Visible = false end) end
        end
        if H.highlight then pcall(function() H.highlight.Enabled = false end) end
        return
    end

    local Q, R, S, T = G(K)
    local U = Q ~= nil

    
    if H.box then
        pcall(function()
            H.box.Visible   = r.EspBoxes and U
            H.boxOut.Visible= r.EspBoxes and U
            if U then
                H.box.Size = Vector2.new(S, T)
                H.box.Position = Vector2.new(Q, R)
                H.box.Color = r.EspBoxColor
                H.box.Thickness = r.EspBoxThickness
                H.boxOut.Size = H.box.Size
                H.boxOut.Position = H.box.Position
            end
        end)
    end

    
    if H.name then
        pcall(function()
            H.name.Visible = r.EspNames and U
            if U then
                H.name.Text = ("%s [%dm]"):format(I.DisplayName or I.Name, math.floor(P))
                H.name.Color = r.EspNameColor
                H.name.Size = r.EspNameSize
                H.name.Position = Vector2.new(Q + S * 0.5, R - r.EspNameSize - 2)
            end
        end)
    end

    
    if H.hbBg and H.hbFg then
        pcall(function()
            local V = r.EspHealth and U
            H.hbBg.Visible = V
            H.hbFg.Visible = V
            if V then
                local W = math.max(L.MaxHealth, 1)
                local X = math.clamp(L.Health / W, 0, 1)
                local Y = Q - 6
                H.hbBg.Position = Vector2.new(Y, R)
                H.hbBg.Size     = Vector2.new(3, T)
                H.hbBg.Color    = Color3.new(0, 0, 0)
                H.hbFg.Position = Vector2.new(Y, R + T * (1 - X))
                H.hbFg.Size     = Vector2.new(3, T * X)
                H.hbFg.Color    = r.EspHealthLow:Lerp(r.EspHealthHigh, X)
            end
        end)
    end

    
    if H.tracer then
        pcall(function()
            local V = r.EspTracers and U
            H.tracer.Visible = V
            if V then
                local W
                if r.EspTracerOrigin == "Center" then
                    W = Vector2.new(l.ViewportSize.X * 0.5, l.ViewportSize.Y * 0.5)
                elseif r.EspTracerOrigin == "Mouse" then
                    W = e:GetMouseLocation()
                else
                    W = Vector2.new(l.ViewportSize.X * 0.5, l.ViewportSize.Y)
                end
                H.tracer.From = W
                H.tracer.To   = Vector2.new(Q + S * 0.5, R + T)
                H.tracer.Color = r.EspTracerColor
                H.tracer.Thickness = r.EspTracerThickness
            end
        end)
    end

    
    
    if r.EspChams then
        if not H.highlight then
            H.highlight = Instance.new("Highlight")
            H.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            H.highlight.Parent = i
        end
        H.highlight.Adornee         = K
        H.highlight.FillColor       = r.EspChamsFill
        H.highlight.OutlineColor    = r.EspChamsOutline
        H.highlight.FillTransparency= 1 - r.EspChamsFillAlpha
        H.highlight.Enabled         = true
    elseif H.highlight then
        H.highlight.Enabled = false
    end
end local I=function()    


for I, J in ipairs(c:GetPlayers()) do
        if J ~= k and not D[J] then E(J) end
    end
    for I, J in pairs(D) do
        if I.Parent then H(D[I]) else F(I) end
    end
end

c.PlayerAdded:Connect(function(J)
    if J ~= k then E(J) end
end)
c.PlayerRemoving:Connect(function(J)
    F(J)
end)
for J, K in ipairs(c:GetPlayers()) do
    if K ~= k then E(K) end
end




local J = false

q.conn("input_began", e.InputBegan:Connect(function(K, L)
    if L then return end
    if K.UserInputType == r.AimKey or K.KeyCode == r.AimKey then
        if r.AimMode == "Toggle" then
            J = not J
            r._AimActive = J
        else
            r._AimActive = true
        end
    end
end))

q.conn("input_ended", e.InputEnded:Connect(function(K)
    if K.UserInputType == r.AimKey or K.KeyCode == r.AimKey then
        if r.AimMode == "Hold" then r._AimActive = false end
    end
end))




q.conn("render", d.RenderStepped:Connect(function()
    C()
    I()

    if r.AimEnabled and r._AimActive then
        local K = r.AimSticky and r._CurrentTarget
        local L
        if K and K.plr and K.plr.Parent and v(K.plr) then
            local M = K.plr.Character
            local N = M and t(M, r.AimBone)
            if N then L = { plr = K.plr, bone = N } end
        end
        L = L or w.findTarget()
        r._CurrentTarget = L
        if L then w.aimAt(L) end
    else
        r._CurrentTarget = nil
    end
end))




local K = {
    bgDark   = Color3.fromRGB(15, 18, 24),
    bgPanel  = Color3.fromRGB(22, 26, 33),
    bgInput  = Color3.fromRGB(28, 33, 42),
    accent   = Color3.fromRGB(58, 212, 124),
    accentHi = Color3.fromRGB(78, 232, 144),
    text     = Color3.fromRGB(225, 230, 240),
    textDim  = Color3.fromRGB(150, 160, 180),
    stroke   = Color3.fromRGB(45, 52, 65),
}
local L=function(
L, M)local N = Instance.new("UICorner"); N.CornerRadius = UDim.new(0, M or 8); N.Parent = L; return N end local M=function(
M, N, O)local P = Instance.new("UIStroke"); P.Color = N or K.stroke; P.Thickness = O or 1; P.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; P.Parent = M; return P end local N=function(
N, O)local P = Instance.new("UIPadding"); P.PaddingTop = UDim.new(0, O); P.PaddingBottom = UDim.new(0, O); P.PaddingLeft = UDim.new(0, O); P.PaddingRight = UDim.new(0, O); P.Parent = N; return P end local O=function(

O, P, Q)    
local R = Instance.new(O)
    for S, T in pairs(Q or {}) do R[S] = T end
    if P then R.Parent = P end
    return R
end

pcall(function()
    local P = i:FindFirstChild("NameHubRivals")
    if P then P:Destroy() end
    local Q = k:FindFirstChild("PlayerGui")
    if Q then
        local R = Q:FindFirstChild("NameHubRivals"); if R then R:Destroy() end
    end
end)

local P = O("ScreenGui", nil, {
    Name = "NameHubRivals",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})
local Q = pcall(function() P.Parent = i end)
if not Q then P.Parent = k:WaitForChild("PlayerGui") end

local R = O("Frame", P, {
    Name = "Root",
    Size = UDim2.new(0, 560, 0, 420),
    Position = UDim2.new(0.5, -280, 0.5, -210),
    BackgroundColor3 = K.bgDark,
    BorderSizePixel = 0,
    Active = true,
})
L(R, 12); M(R, K.stroke, 1)

local S = O("Frame", R, {
    Size = UDim2.new(0, 140, 1, 0),
    BackgroundColor3 = K.bgPanel,
    BorderSizePixel = 0,
})
L(S, 12)
O("Frame", S, {
    Size = UDim2.new(0, 16, 1, 0),
    Position = UDim2.new(1, -16, 0, 0),
    BackgroundColor3 = K.bgPanel,
    BorderSizePixel = 0,
})
local T = O("TextLabel", S, {
    Text = "NameHub",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = K.accent,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 50),
    Position = UDim2.new(0, 0, 0, 4),
    TextXAlignment = Enum.TextXAlignment.Center,
})
O("TextLabel", S, {
    Text = "Rivals",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = K.textDim,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 0, 50),
    TextXAlignment = Enum.TextXAlignment.Center,
})

local U = O("Frame", S, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -20, 1, -90),
    Position = UDim2.new(0, 10, 0, 80),
})
O("UIListLayout", U, { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })

local V = O("Frame", R, {
    BackgroundColor3 = K.bgDark,
    Size = UDim2.new(1, -150, 1, -20),
    Position = UDim2.new(0, 145, 0, 10),
    BorderSizePixel = 0,
})

local W = {}
local X=function(X)    
for Y, Z in pairs(W) do
        Z.frame.Visible = (Y == X)
        Z.btn.BackgroundColor3 = (Y == X) and K.accent or K.bgInput
        Z.btn.TextColor3 = (Y == X) and K.bgDark or K.text
    end
end local Y=function(
Y)    
local Z = O("TextButton", U, {
        Text = Y, Font = Enum.Font.GothamMedium, TextSize = 14,
        AutoButtonColor = false, BackgroundColor3 = K.bgInput, TextColor3 = K.text,
        Size = UDim2.new(1, 0, 0, 32), BorderSizePixel = 0,
    })
    L(Z, 6)
    local _ = O("ScrollingFrame", V, {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, ScrollBarImageColor3 = K.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    })
    O("UIListLayout", _, { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
    N(_, 8)
    W[Y] = { btn = Z, frame = _ }
    Z.MouseButton1Click:Connect(function() X(Y) end)
end
Y("Aimbot"); Y("ESP"); Y("Settings"); X("Aimbot")




local Z = {}
local _ = {}

function Z.row(aa, ab)
    local ac = O("Frame", aa, {
        BackgroundColor3 = K.bgPanel, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, ab or 36),
    })
    L(ac, 6); N(ac, 8); return ac
end

function Z.label(aa, ab)
    local ac = Z.row(aa, 28)
    return O("TextLabel", ac, {
        Text = ab, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = K.textDim,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
end

function Z.toggle(aa, ab, ac, ad)
    local ae = Z.row(aa)
    O("TextLabel", ae, {
        Text = ab, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = K.text,
        BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local af = O("TextButton", ae, {
        AutoButtonColor = false, BackgroundColor3 = r[ac] and K.accent or K.bgInput,
        Size = UDim2.new(0, 38, 0, 20), Position = UDim2.new(1, -38, 0.5, -10),
        Text = "", BorderSizePixel = 0,
    })
    L(af, 10)
    local ag = O("Frame", af, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = r[ac] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(240, 240, 240), BorderSizePixel = 0,
    })
    L(ag, 8)
    af.MouseButton1Click:Connect(function()
        r[ac] = not r[ac]
        af.BackgroundColor3 = r[ac] and K.accent or K.bgInput
        f:Create(ag, TweenInfo.new(0.15), {
            Position = r[ac] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        }):Play()
        if ad then pcall(ad, r[ac]) end
    end)
end

function Z.dropdown(aa, ab, ac, ad, ae)
    local af = Z.row(aa)
    O("TextLabel", af, {
        Text = ab, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = K.text,
        BackgroundTransparency = 1, Size = UDim2.new(0.45, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local ag = O("TextButton", af, {
        Text = tostring(r[ac] or ad[1] or "-"),
        Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false,
        BackgroundColor3 = K.bgInput, TextColor3 = K.text,
        Size = UDim2.new(0.55, 0, 0, 24), Position = UDim2.new(0.45, 0, 0.5, -12),
        BorderSizePixel = 0,
    })
    L(ag, 6)
    local ah = O("Frame", ag, {
        BackgroundColor3 = K.bgInput,
        Size = UDim2.new(1, 0, 0, math.min(#ad, 6) * 26),
        Position = UDim2.new(0, 0, 1, 4), Visible = false, BorderSizePixel = 0, ZIndex = 5,
    })
    L(ah, 6); M(ah, K.stroke, 1)
    O("UIListLayout", ah, { SortOrder = Enum.SortOrder.LayoutOrder })
    for ai, aj in ipairs(ad) do
        local ak = O("TextButton", ah, {
            Text = aj, Font = Enum.Font.Gotham, TextSize = 12, BackgroundTransparency = 1,
            TextColor3 = K.text, Size = UDim2.new(1, 0, 0, 26), BorderSizePixel = 0, ZIndex = 6,
        })
        ak.MouseButton1Click:Connect(function()
            r[ac] = aj; ag.Text = aj; ah.Visible = false
            if ae then pcall(ae, aj) end
        end)
    end
    ag.MouseButton1Click:Connect(function() ah.Visible = not ah.Visible end)
end

function Z.slider(aa, ab, ac, ad, ae, af, ag)
    af = af or 1
    local ah = Z.row(aa, 44)
    local ai = O("TextLabel", ah, {
        Text = ("%s: %s"):format(ab, tostring(r[ac])),
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = K.text,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left,
    })
    local aj = O("Frame", ah, {
        BackgroundColor3 = K.bgInput, Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -10), BorderSizePixel = 0,
    })
    L(aj, 3)
    local ak = ((r[ac] or ad) - ad) / (ae - ad)
    local al = O("Frame", aj, {
        BackgroundColor3 = K.accent, Size = UDim2.new(ak, 0, 1, 0), BorderSizePixel = 0,
    })
    L(al, 3)
    local am = false
local an=function(an)        
local ao = math.clamp((an - aj.AbsolutePosition.X) / aj.AbsoluteSize.X, 0, 1)
        local ap = ad + (ae - ad) * ao
        ap = math.floor(ap / af + 0.5) * af
        r[ac] = ap
        al.Size = UDim2.new(ao, 0, 1, 0)
        ai.Text = ("%s: %s"):format(ab, tostring(ap))
        if ag then pcall(ag, ap) end
end    
aj.InputBegan:Connect(function(ao)
        if ao.UserInputType == Enum.UserInputType.MouseButton1 or ao.UserInputType == Enum.UserInputType.Touch then
            am = true; an(ao.Position.X)
        end
    end)
    e.InputEnded:Connect(function(ao)
        if ao.UserInputType == Enum.UserInputType.MouseButton1 or ao.UserInputType == Enum.UserInputType.Touch then
            am = false
        end
    end)
    e.InputChanged:Connect(function(ao)
        if am and (ao.UserInputType == Enum.UserInputType.MouseMovement or ao.UserInputType == Enum.UserInputType.Touch) then
            an(ao.Position.X)
        end
    end)
end



function Z.colorPick(aa, ab, ac)
    local ad = Z.row(aa)
    O("TextLabel", ad, {
        Text = ab, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = K.text,
        BackgroundTransparency = 1, Size = UDim2.new(1, -36, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local ae = O("TextButton", ad, {
        Text = "", AutoButtonColor = false, BackgroundColor3 = r[ac] or Color3.new(1, 1, 1),
        Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -28, 0.5, -12),
        BorderSizePixel = 0,
    })
    L(ae, 4)
    local af = {
        Color3.fromRGB(255, 60, 60),
        Color3.fromRGB(255, 160, 60),
        Color3.fromRGB(255, 230, 60),
        Color3.fromRGB(60, 220, 80),
        Color3.fromRGB(60, 180, 255),
        Color3.fromRGB(180, 80, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(0, 0, 0),
    }
    local ag = 0
    ae.MouseButton1Click:Connect(function()
        ag = (ag % #af) + 1
        r[ac] = af[ag]
        ae.BackgroundColor3 = af[ag]
    end)
end

function Z.button(aa, ab, ac)
    local ad = O("TextButton", aa, {
        Text = ab, Font = Enum.Font.GothamMedium, TextSize = 13,
        AutoButtonColor = false, BackgroundColor3 = K.accent, TextColor3 = K.bgDark,
        Size = UDim2.new(1, 0, 0, 32), BorderSizePixel = 0,
    })
    L(ad, 6)
    ad.MouseButton1Click:Connect(function() pcall(ac) end)
end

function Z.statLabel(aa, ab)
    local ac = Z.row(aa, 26)
    local ad = O("TextLabel", ac, {
        Text = ab(), Font = Enum.Font.Code, TextSize = 12, TextColor3 = K.textDim,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    table.insert(_, function() ad.Text = ab() end)
end


do
    local aa, ab, ac
local ad=function(ad)        
if ad.UserInputType ~= Enum.UserInputType.MouseButton1
            and ad.UserInputType ~= Enum.UserInputType.Touch then return end
        aa = true; ab = ad.Position; ac = R.Position
end    
S.InputBegan:Connect(ad)
    T.InputBegan:Connect(ad)
    e.InputChanged:Connect(function(ae)
        if aa and (ae.UserInputType == Enum.UserInputType.MouseMovement or ae.UserInputType == Enum.UserInputType.Touch) then
            local af = ae.Position - ab
            R.Position = UDim2.new(ac.X.Scale, ac.X.Offset + af.X, ac.Y.Scale, ac.Y.Offset + af.Y)
        end
    end)
    e.InputEnded:Connect(function(ae)
        if ae.UserInputType == Enum.UserInputType.MouseButton1
            or ae.UserInputType == Enum.UserInputType.Touch then aa = false end
    end)
end


do
    local aa = W["Aimbot"].frame
    Z.toggle(aa, "Aimbot Enabled", "AimEnabled")
    Z.dropdown(aa, "Mode", "AimMode", { "Hold", "Toggle" })
    Z.dropdown(aa, "Aim Bone", "AimBone", { "Head", "UpperTorso", "HumanoidRootPart", "Random" })
    Z.slider(aa, "FOV (px)", "AimFov", 10, 500, 5, function() C() end)
    Z.slider(aa, "Smoothness", "AimSmoothness", 0, 0.95, 0.01)
    Z.slider(aa, "Prediction (s)", "AimPrediction", 0, 0.5, 0.01)
    Z.toggle(aa, "Team Check", "AimTeamCheck")
    Z.toggle(aa, "Visible Check", "AimVisibleCheck")
    Z.toggle(aa, "Alive Check", "AimAliveCheck")
    Z.toggle(aa, "Sticky Target", "AimSticky")
    Z.label(aa, "Hold Right Mouse Button to aim")
    Z.label(aa, "")

    Z.toggle(aa, "FOV Circle", "FovCircleEnabled", function() C() end)
    Z.toggle(aa, "FOV Circle Filled", "FovCircleFilled", function() C() end)
    Z.colorPick(aa, "FOV Circle Color", "FovCircleColor")
end


do
    local aa = W["ESP"].frame
    Z.toggle(aa, "ESP Enabled", "EspEnabled")
    Z.toggle(aa, "Team Check", "EspTeamCheck")
    Z.slider(aa, "Max Distance", "EspMaxDistance", 100, 5000, 50)
    Z.label(aa, "")

    Z.toggle(aa, "Box ESP", "EspBoxes")
    Z.colorPick(aa, "Box Color", "EspBoxColor")

    Z.toggle(aa, "Name + Distance", "EspNames")
    Z.colorPick(aa, "Name Color", "EspNameColor")
    Z.slider(aa, "Name Size", "EspNameSize", 8, 24, 1)

    Z.toggle(aa, "Healthbar", "EspHealth")

    Z.toggle(aa, "Tracers", "EspTracers")
    Z.colorPick(aa, "Tracer Color", "EspTracerColor")
    Z.dropdown(aa, "Tracer Origin", "EspTracerOrigin", { "Bottom", "Center", "Mouse" })

    Z.toggle(aa, "Chams (through wall)", "EspChams")
    Z.colorPick(aa, "Cham Fill", "EspChamsFill")
    Z.colorPick(aa, "Cham Outline", "EspChamsOutline")
    Z.slider(aa, "Cham Alpha", "EspChamsFillAlpha", 0, 1, 0.05)
end


do
    local aa = W["Settings"].frame
    Z.statLabel(aa, function()
        local ab = r._CurrentTarget
        return "Aim target: " .. (ab and ab.plr and ab.plr.Name or "(none)")
    end)
    Z.statLabel(aa, function() return ("Aim active: %s"):format(tostring(r._AimActive)) end)
    Z.statLabel(aa, function() return ("Candidates in FOV: %d"):format(r._FoundTargets or 0) end)
    Z.statLabel(aa, function() return "Build: " .. a end)
    Z.button(aa, "Unload Script", function()
        r.Alive = false
        for ab, ac in pairs(p) do pcall(function() ac:Disconnect() end) end
        if B then pcall(function() B:Remove() end) end
        for ab, ac in pairs(D) do F(ab) end
        pcall(function() P:Destroy() end)
    end)
end


q.conn("ui_refresh", d.Heartbeat:Connect(function()
    for aa, ab in ipairs(_) do pcall(ab) end
end))


pcall(function()
    h:SetCore("SendNotification", {
        Title = "NameHub",
        Text = ("Rivals loaded (%s). Hold RMB to aim."):format(a),
        Duration = 5,
    })
end)
