



































local a = "v0.2.0 NameHub (rivals-linoria-20260530)"




local b = {
    [6035872082] = "Rivals",
}
if not b[game.GameId] then
    warn(("[NameHub] This script is for Rivals. Current PlaceId %d / UniverseId %d is not supported."):format(game.PlaceId, game.GameId))
    return
end




do
    local c = game:GetService("Players")
    local d   = c.LocalPlayer

    
    
    
    local e = Instance.new("RemoteEvent")
    e.Name   = "ClientAlert"
    e.Parent = d

    
    pcall(function()
        local f   = getrawmetatable(d)
        local g = f.__namecall
        setreadonly(f, false)
        f.__namecall = newcclosure(function(h, ...)
            if getnamecallmethod() == "WaitForChild" and select(1, ...) == "ClientAlert" then
                return e
            end
            return g(h, ...)
        end)
        setreadonly(f, true)
    end)

    
    pcall(function()
        local f  = getrawmetatable(game)
        local g = f.__namecall
        setreadonly(f, false)
        f.__namecall = newcclosure(function(h, ...)
            local i = getnamecallmethod()
            if h == d and (i == "Kick" or i == "kick") then return end
            if i:lower():find("kick") or i == "Shutdown" then return end
            if i == "FireServer" and h == e then return end
            return g(h, ...)
        end)
        setreadonly(f, true)
    end)

    
    
    
    task.defer(function()
        local f  = game:GetService("ReplicatedFirst")
        local g = f:FindFirstChild("LocalScript3") or f:WaitForChild("LocalScript3", 2.5)
        if not g then return end

        local h = os.clock() + 4
        local i  = 0
        local j, k = pcall(getgc, false)
        if not j or type(k) ~= "table" then return end

        for l, m in ipairs(k) do
            i += 1
            if i % 80 == 0 then
                if os.clock() > h then return end
                task.wait()
            end
            if typeof(m) == "function" then
                local n, o = pcall(getfenv, m)
                if n and type(o) == "table" then
                    local p = rawget(o, "script")
                    if p and (p == g or tostring(p):find("LoadingScreen")) then
                        local q, r = pcall(debug.getconstants, m)
                        if q and type(r) == "table" then
                            for s, t in ipairs(r) do
                                if typeof(t) == "string" and (t:find("TakeTheL") or t:find("ban") or t:find("kick")) then
                                    pcall(hookfunction, m, function() end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end




task.defer(function()
local aa, ab = pcall(function()




if not game:IsLoaded() then
    local c = os.clock() + 5
    while not game:IsLoaded() and os.clock() < c do
        task.wait(0.05)
    end
end














local c = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local d    = "NameHub_Linoria"
local e=function()    

if typeof(makefolder) == "function" then pcall(makefolder, d) end
end local f=function(

f)    
if typeof(isfile) == "function" and typeof(readfile) == "function" then
        local g, h = pcall(isfile, f)
        if g and h then
            local i, j = pcall(readfile, f)
            if i and type(j) == "string" and #j > 200 then
                return j
            end
        end
    end
    return nil
end local g=function(

g, h)    
if typeof(writefile) == "function" then
        pcall(writefile, g, h)
    end
end local h=function(

h, i)    
local j = d .. "/" .. h
    local k = f(j)
    if k then return k end
    local l, m = pcall(game.HttpGet, game, c .. i)
    if not l or type(m) ~= "string" or #m < 200 then return nil end
    e()
    g(j, m)
    return m
end

local i = {}
local j = {
    { key = "library", name = "Library.lua",      relPath = "Library.lua" },
    { key = "theme",   name = "ThemeManager.lua", relPath = "addons/ThemeManager.lua" },
    { key = "save",    name = "SaveManager.lua",  relPath = "addons/SaveManager.lua" },
}

local k = #j
for l, m in ipairs(j) do
    task.spawn(function()
        i[m.key] = h(m.name, m.relPath)
        k -= 1
    end)
end

local l = os.clock() + 25
while k > 0 and os.clock() < l do
    task.wait(0.03)
end

if not (i.library and i.theme and i.save) then
    error("[NameHub] Failed to fetch Linoria sources. Check HTTP permissions.", 0)
end

local m      = (loadstring(i.library, "=NH_Linoria_Library"))()
local n = (loadstring(i.theme,   "=NH_Linoria_ThemeManager"))()
local o  = (loadstring(i.save,    "=NH_Linoria_SaveManager"))()

if not Drawing or not Drawing.new then
    error("[NameHub] Drawing API required for ESP.", 0)
end




local p           = game:GetService("Players")
local q        = game:GetService("RunService")
local r  = game:GetService("UserInputService")
local s = game:GetService("ReplicatedStorage")
local t       = game:GetService("HttpService")
local u          = game:GetService("Lighting")

local v = clonefunction and clonefunction(getrawmetatable) or getrawmetatable
local w     = newcclosure or function(w) return w end

local x = p.LocalPlayer
local y      = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    y = workspace.CurrentCamera
end)




local z = false
local aa=function()    
if z then
        m:Notify("Unlock All already loaded!", 3)
        return
    end
    m:Notify("Unlock All Loading...", 5)
    task.spawn(function()
    local A = x.PlayerScripts
    local B   = A.Controllers
    local C    = require(s.Modules:WaitForChild("EnumLibrary", 10))
    if C then C:WaitForEnumBuilder() end
    local D = require(s.Modules:WaitForChild("CosmeticLibrary", 10))
    local E         = require(s.Modules:WaitForChild("ItemLibrary", 10))
    local F  = require(B:WaitForChild("PlayerDataController", 10))

    local G, H = {}, {}
    local I, J     
local K local L=function(

L, M, N)        
local O = D.Cosmetics[L]
        if not O then return nil end
        local P = {}
        for Q, R in pairs(O) do P[Q] = R end
        P.Name = L
        P.Type = P.Type or M
        P.Seed = P.Seed or math.random(1, 1000000)
        if C then
            local Q, R = pcall(C.ToEnum, C, L)
            if Q and R then P.Enum, P.ObjectID = R, P.ObjectID or R end
        end
        if N then
            if N.inverted      ~= nil then P.Inverted         = N.inverted end
            if N.favoritesOnly ~= nil then P.OnlyUseFavorites = N.favoritesOnly end
        end
        return P
end
    
local M = "unlockall/config.json"
local N=function()        
if not writefile then return end
        pcall(function()
            local N = { equipped = {}, favorites = H }
            for O, P in pairs(G) do
                N.equipped[O] = {}
                for Q, R in pairs(P) do
                    if R and R.Name then
                        N.equipped[O][Q] = {
                            name = R.Name, seed = R.Seed, inverted = R.Inverted
                        }
                    end
                end
            end
            makefolder("unlockall")
            writefile(M, t:JSONEncode(N))
        end)
end local O=function()        


if not readfile or not isfile or not isfile(M) then return end
        pcall(function()
            local O = t:JSONDecode(readfile(M))
            if O.equipped then
                for P, Q in pairs(O.equipped) do
                    G[P] = {}
                    for R, S in pairs(Q) do
                        local T = L(S.name, R, { inverted = S.inverted })
                        if T then T.Seed = S.seed G[P][R] = T end
                    end
                end
            end
            H = O.favorites or {}
        end)
end
    
D.OwnsCosmeticNormally    = function() return true end
    D.OwnsCosmeticUniversally = function() return true end
    D.OwnsCosmeticForWeapon   = function() return true end
    local P = D.OwnsCosmetic
    D.OwnsCosmetic = function(Q, R, S, T)
        if S:find("MISSING_") then return P(Q, R, S, T) end
        return true
    end

    local Q = F.Get
    F.Get = function(R, S)
        local T = Q(R, S)
        if S == "CosmeticInventory" then
            local U = {}
            if T then for V, W in pairs(T) do U[V] = W end end
            return setmetatable(U, { __index = function() return true end })
        end
        if S == "FavoritedCosmetics" then
            local U = T and table.clone(T) or {}
            for V, W in pairs(H) do
                U[V] = U[V] or {}
                for X, Y in pairs(W) do U[V][X] = Y end
            end
            return U
        end
        return T
    end

    local R = F.GetWeaponData
    F.GetWeaponData = function(S, T)
        local U = R(S, T)
        if not U then return nil end
        local V = {}
        for W, X in pairs(U) do V[W] = X end
        V.Name = T
        if G[T] then
            for W, X in pairs(G[T]) do V[W] = X end
        end
        return V
    end

    local S
    pcall(function() S = require(B:WaitForChild("FighterController", 10)) end)

    if hookmetamethod then
        local T           = s:FindFirstChild("Remotes")
        local U       = T and T:FindFirstChild("Data")
        local V       = U and U:FindFirstChild("EquipCosmetic")
        local W    = U and U:FindFirstChild("FavoriteCosmetic")
        local X = T and T:FindFirstChild("Replication")
        local Y    = X and X:FindFirstChild("Fighter")
        local Z     = Y and Y:FindFirstChild("UseItem")

        if V then
            local _
            _ = hookmetamethod(game, "__namecall", function(aa, ...)
                if getnamecallmethod() ~= "FireServer" then return _(aa, ...) end
                local ab = { ... }

                if Z and aa == Z then
                    local ac = ab[1]
                    if S then
                        pcall(function()
                            local ad = S:GetFighter(x)
                            if ad and ad.Items then
                                for ae, af in pairs(ad.Items) do
                                    if af:Get("ObjectID") == ac then
                                        K = af.Name
                                        break
                                    end
                                end
                            end
                        end)
                    end
                end

                if aa == V then
                    local ac, ad, ae, af = ab[1], ab[2], ab[3], ab[4] or {}
                    if ae and ae ~= "None" and ae ~= "" then
                        local ag = F:Get("CosmeticInventory")
                        if ag and rawget(ag, ae) then return _(aa, ...) end
                    end
                    G[ac] = G[ac] or {}
                    if not ae or ae == "None" or ae == "" then
                        G[ac][ad] = nil
                        if not next(G[ac]) then G[ac] = nil end
                    else
                        local ag = L(ae, ad, { inverted = af.IsInverted, favoritesOnly = af.OnlyUseFavorites })
                        if ag then G[ac][ad] = ag end
                    end
                    task.defer(function()
                        pcall(function() F.CurrentData:Replicate("WeaponInventory") end)
                        task.wait(0.2)
                        N()
                    end)
                    return
                end

                if aa == W then
                    H[ab[1] ] = H[ab[1] ] or {}
                    H[ab[1] ][ab[2] ] = ab[3] or nil
                    N()
                    task.spawn(function() pcall(function() F.CurrentData:Replicate("FavoritedCosmetics") end) end)
                    return
                end

                return _(aa, ...)
            end)
        end
    end

    local aa
    pcall(function() aa = require(x.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)
    if aa and aa._CreateViewModel then
        local ab = aa._CreateViewModel
        aa._CreateViewModel = function(ac, ad)
            local ae   = ac.Name
            local af = ac.ClientFighter and ac.ClientFighter.Player
            I = (af == x) and ae or nil
            if af == x and G[ae] and G[ae].Skin and ad then
                local ag, T, U = ac:ToEnum("Data"), ac:ToEnum("Skin"), ac:ToEnum("Name")
                if ad[ag] then
                    ad[ag][T] = G[ae].Skin
                    ad[ag][U] = G[ae].Skin.Name
                elseif ad.Data then
                    ad.Data.Skin = G[ae].Skin
                    ad.Data.Name = G[ae].Skin.Name
                end
            end
            local ag = ab(ac, ad)
            I = nil
            return ag
        end
    end

    local ab = x.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
    if ab then
        local ac = require(ab)
        if ac.GetWrap then
            local ad = ac.GetWrap
            ac.GetWrap = function(ae)
                local af   = ae.ClientItem and ae.ClientItem.Name
                local ag = ae.ClientItem and ae.ClientItem.ClientFighter and ae.ClientItem.ClientFighter.Player
                if af and ag == x and G[af] and G[af].Wrap then
                    return G[af].Wrap
                end
                return ad(ae)
            end
        end
        local ad = ac.new
        ac.new = function(ae, af)
            local ag = af.ClientFighter and af.ClientFighter.Player
            local T   = I or af.Name
            if ag == x and G[T] then
                local U = require(s.Modules.ReplicatedClass)
                local V = U:ToEnum("Data")
                ae[V] = ae[V] or {}
                local W = G[T]
                if W.Skin  then ae[V][U:ToEnum("Skin")]  = W.Skin  end
                if W.Wrap  then ae[V][U:ToEnum("Wrap")]  = W.Wrap  end
                if W.Charm then ae[V][U:ToEnum("Charm")] = W.Charm end
            end
            local U = ad(ae, af)
            if ag == x and G[T] and G[T].Wrap and U._UpdateWrap then
                U:_UpdateWrap()
                task.delay(0.1, function() if not U._destroyed then U:_UpdateWrap() end end)
            end
            return U
        end
    end

    local ac = E.GetViewModelImageFromWeaponData
    E.GetViewModelImageFromWeaponData = function(ad, ae, af)
        if not ae then return ac(ad, ae, af) end
        local ag = ae.Name
        local T = (ae.Skin and G[ag] and ae.Skin == G[ag].Skin)
            or (J == x and G[ag] and G[ag].Skin)
        if T and G[ag] and G[ag].Skin then
            local U = ad.ViewModels[G[ag].Skin.Name]
            if U then return U[af and "ImageHighResolution" or "Image"] or U.Image end
        end
        return ac(ad, ae, af)
    end

    pcall(function()
        local ad = require(x.PlayerScripts.Modules.Pages.ViewProfile)
        if ad and ad.Fetch then
            local ae = ad.Fetch
            ad.Fetch = function(af, ag)
                J = ag
                return ae(af, ag)
            end
        end
    end)

    local ad
    pcall(function() ad = require(x.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity) end)
    if ad and ad.ReplicateFromServer then
        local ae = ad.ReplicateFromServer
        ad.ReplicateFromServer = function(af, ag, ...)
            if ag == "FinisherEffect" then
                local T        = { ... }
                local U  = T[3]
                local V = U
                if type(U) == "userdata" and C and C.FromEnum then
                    local W, X = pcall(C.FromEnum, C, U)
                    if W and X then V = X end
                end
                local W = tostring(V) == x.Name
                    or tostring(V):lower() == x.Name:lower()
                if W and K and G[K] and G[K].Finisher then
                    local X = G[K].Finisher
                    local Y = X.Enum
                    if not Y and C then
                        local Z, _ = pcall(C.ToEnum, C, X.Name)
                        if Z and _ then Y = _ end
                    end
                    if Y then
                        T[1] = Y
                        return ae(af, ag, unpack(T))
                    end
                end
            end
            return ae(af, ag, ...)
        end
    end

    O()
    z = true
    m:Notify("Unlocked Everything!", 4)
    end)
end




local ab
local ac=function()    
if ab ~= nil then return ab end
    local ac = s:FindFirstChild("Modules") or s:WaitForChild("Modules", 20)
    if not ac then return nil end
    local ad = ac:FindFirstChild("ItemLibrary") or ac:WaitForChild("ItemLibrary", 20)
    if not ad then return nil end
    local ae, af = pcall(require, ad)
    ab = (ae and af) or nil
    return ab
end

local ad = 350
local ae=function(ae, af)    
local ag = 0
    local A = {}
    local function walk(B)
        if typeof(B) ~= "table" or A[B] then return end
        A[B] = true
        for C, D in pairs(B) do
            if typeof(D) == "table" then
                af(D)
                ag += 1
                if ag >= ad then
                    ag = 0
                    task.wait()
                end
                walk(D)
            end
        end
    end
    walk(ae)
end local af=function(

af)    
task.spawn(function()
        local ag = ac()
        if ag then ae(ag, af) end
    end)
end

local ag = {}
local A=function(A)    
if ag[A] then return end
    if A.ShootRecoil == nil and A.ShootSpread == nil and A.ShootAccuracy == nil and A.ShootCooldown == nil then return end
    local B = {}
    if A.ShootRecoil   ~= nil then B.ShootRecoil   = A.ShootRecoil   end
    if A.ShootSpread   ~= nil then B.ShootSpread   = A.ShootSpread   end
    if A.ShootAccuracy ~= nil then B.ShootAccuracy = A.ShootAccuracy end
    if A.ShootCooldown ~= nil then B.ShootCooldown = A.ShootCooldown end
    ag[A] = B
end local B=function(
B, C)    
local D = ag[B]
    if not D or D[C] == nil or B[C] == nil then return end
    B[C] = D[C]
end




local C, D, E, F = 2.72, 5.2, 1.5, 0.05
local G     = 500
local H    = 1
local I = 1
local J 
local K = 1
local L    = 14
local M    = 13
local N   = 0.1
local O   = 1
local P  = "Bottom"
local Q    = "Full"

local R = {
    { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}
local S = {
    { "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
    { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
}
local T         = 32
local U = 14
local V = 0.04
local W=function(
W, X)    
local Y, Z = W:GetFullName(), X:GetFullName()
    return Y < Z and (Y .. "\0" .. Z) or (Z .. "\0" .. Y)
end local ah=function(

X, Y)    
local Z = X:FindFirstChild(Y)
    if Z and Z:IsA("BasePart") then return Z end
    for _, ah in ipairs(X:GetChildren()) do
        if ah:IsA("Model") then
            local ai = ah:FindFirstChild(Y)
            if ai and ai:IsA("BasePart") then return ai end
        end
    end
    return nil
end local ai=function(

ai)    
local X, Y = {}, {}
local Z=function(Z)        
if Y[Z] then return false end
        Y[Z] = true
        return true
end local aj=function(
_, aj)        
if #X >= T then return end
        if not _ or not aj or not _:IsA("BasePart") or not aj:IsA("BasePart") then return end
        if not _:IsDescendantOf(ai) or not aj:IsDescendantOf(ai) then return end
        if Z("P" .. W(_, aj)) then table.insert(X, { parts = { _, aj } }) end
end
    
local _ = 0
    for ak, al in ipairs(ai:GetDescendants()) do
        if #X >= T then break end
        _ += 1
        if _ % 400 == 0 then task.wait() end
        if al:IsA("Motor6D") then aj(al.Part0, al.Part1) end
    end

    for ak, al in ipairs(R) do
        if #X >= T then break end
        aj(ah(ai, al[1]), ah(ai, al[2]))
    end
    task.wait()
    for ak, al in ipairs(S) do
        if #X >= T then break end
        aj(ah(ai, al[1]), ah(ai, al[2]))
    end
    return X
end

local aj = {}
local ak=function(
ak, al)return (ak and ak.Value) or al end local al=function()    


aj.maxDistSq    = G * G
    aj.boxThick     = H
    aj.outlineThick = I
    aj.outlineTrans = J
    aj.tracerThick  = K
    aj.nameSize     = L
    aj.distSize     = M
    aj.fillTrans    = N
    aj.skelThick    = O
    aj.tracerFrom   = P
    aj.boxStyle     = Q

    aj.cBox           = ak(Options.ColESPBox,          Color3.fromRGB(255, 60, 60))
    aj.cOutline       = ak(Options.ColESPOutline,      Color3.new(0, 0, 0))
    aj.cName          = ak(Options.ColESPName,         Color3.fromRGB(255, 255, 255))
    aj.cDist          = ak(Options.ColESPDist,         Color3.fromRGB(200, 200, 255))
    aj.cTracer        = ak(Options.ColESPTracer,       Color3.fromRGB(255, 60, 60))
    aj.cSkel          = ak(Options.ColESPSkeleton,     Color3.fromRGB(255, 255, 255))
    aj.cHpBg          = ak(Options.ColESPHpBg,         Color3.fromRGB(25, 25, 25))
    aj.cHpLow         = ak(Options.ColESPHpLow,        Color3.fromRGB(200, 40, 40))
    aj.cHpHigh        = ak(Options.ColESPHpHigh,       Color3.fromRGB(60, 220, 90))
    aj.cPlayerOutline = ak(Options.ColESPPlayerOutline, Color3.fromRGB(255, 255, 255))
end local X=function(

X)return X == x end

local Y, Z = {}, {}
local _, am, an

local ao, ap = {}, {}
local aq, ar
local as = 0
local at=function(
at)    
if not at or not at.skelLines then return end
    for au = 1, T do
        local av = at.skelLines[au]
        if av then av.Visible = false end
    end
end local au=function(

au)    
if not au then return end
    if au.boxFill         then au.boxFill.Visible         = false end
    if au.boxOutlineOuter then au.boxOutlineOuter.Visible = false end
    if au.boxOutlineInner then au.boxOutlineInner.Visible = false end
    if au.boxLine         then au.boxLine.Visible         = false end
    for av = 1, 8 do
        local aw = au.cornerLines and au.cornerLines[av]
        if aw then aw.Visible = false end
    end
    if au.name   then au.name.Visible   = false end
    if au.dist   then au.dist.Visible   = false end
    if au.tracer then au.tracer.Visible = false end
    if au.hpBg   then au.hpBg.Visible   = false end
    if au.hpFill then au.hpFill.Visible = false end
end local av=function(

av)    
au(av)
    at(av)
end local aw=function(

aw)    
local ax = Y[aw]
    if not ax then return end
    av(ax)
    for ay, az in ipairs({
        ax.boxFill, ax.boxOutlineOuter, ax.boxOutlineInner, ax.boxLine,
        ax.name, ax.dist, ax.tracer, ax.hpBg, ax.hpFill,
    }) do
        if az then az:Remove() end
    end
    if ax.cornerLines then for ay, az in ipairs(ax.cornerLines) do az:Remove() end end
    if ax.skelLines   then for ay, az in ipairs(ax.skelLines)   do az:Remove() end end
    Y[aw] = nil
end local ax=function(

ax)ax.skelCache = nil end local ay=function(
ay, az)if az ~= nil and ay then ay.Transparency = az end end local az=function(

az)    
if Y[az] then return Y[az] end
    local aA = { cornerLines = {}, skelLines = {} }

    aA.boxFill         = Drawing.new("Square"); aA.boxFill.Visible = false; aA.boxFill.Filled = true
    aA.boxOutlineOuter = Drawing.new("Square"); aA.boxOutlineOuter.Filled = false; aA.boxOutlineOuter.Visible = false
    aA.boxOutlineInner = Drawing.new("Square"); aA.boxOutlineInner.Filled = false; aA.boxOutlineInner.Visible = false
    aA.boxLine         = Drawing.new("Square"); aA.boxLine.Filled = false; aA.boxLine.Visible = false

    ay(aA.boxOutlineOuter, J)
    ay(aA.boxOutlineInner, J)
    ay(aA.boxLine,         J)

    for aB = 1, 8 do
        local aC = Drawing.new("Line"); aC.Visible = false
        aA.cornerLines[aB] = aC
    end
    for aB = 1, T do
        local aC = Drawing.new("Line"); aC.Visible = false
        aA.skelLines[aB] = aC
    end

    aA.name = Drawing.new("Text"); aA.name.Visible = false; aA.name.Center = true; aA.name.Outline = true; aA.name.Font = 2
    aA.dist = Drawing.new("Text"); aA.dist.Visible = false; aA.dist.Center = true; aA.dist.Outline = true; aA.dist.Font = 2
    aA.tracer = Drawing.new("Line"); aA.tracer.Visible = false
    aA.hpBg = Drawing.new("Square"); aA.hpBg.Filled = true; aA.hpBg.Visible = false
    aA.hpFill = Drawing.new("Square"); aA.hpFill.Filled = true; aA.hpFill.Visible = false

    Y[az] = aA
    return aA
end local aA=function()    


return (Toggles.ESPBox and Toggles.ESPBox.Value)
        or (Toggles.ESPName and Toggles.ESPName.Value)
        or (Toggles.ESPDistance and Toggles.ESPDistance.Value)
        or (Toggles.ESPTracer and Toggles.ESPTracer.Value)
        or (Toggles.ESPHealth and Toggles.ESPHealth.Value)
        or (Toggles.ESPSkeleton and Toggles.ESPSkeleton.Value)
end local aB=function()    


return Toggles.ESPPlayerOutline and Toggles.ESPPlayerOutline.Value
end local aC=function(

aC)    
local aD = ao[aC]
    if aD then aD:Destroy(); ao[aC] = nil end
end local aD=function(

aD)    
aC(aD)
    if ap[aD] then ap[aD]:Disconnect(); ap[aD] = nil end
end local aE=function(

aE, aF)    
aC(aE)
    if not aF or not aB() then return end
    al()
    local aG = Instance.new("Highlight")
    aG.Name               = "_RivalsPlayerOutline"
    aG.Parent             = aF
    aG.FillColor          = Color3.new(1, 1, 1)
    aG.FillTransparency   = 1
    aG.OutlineColor       = aj.cPlayerOutline
    aG.OutlineTransparency = 0
    aG.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
    ao[aE] = aG
end local aF=function()    


if not aB() then return end
    al()
    for aF, aG in pairs(ao) do
        if aG and aG.Parent then
            aG.FillTransparency    = 1
            aG.OutlineColor        = aj.cPlayerOutline
            aG.OutlineTransparency = 0
        end
    end
end local aG=function(

aG)    
if X(aG) then return end
    aD(aG)
    ap[aG] = aG.CharacterAdded:Connect(function(aH)
        if aB() then
            task.defer(function() aE(aG, aH) end)
        end
    end)
    if aG.Character and aB() then
        aE(aG, aG.Character)
    end
end local aH=function()    


as += 1
    if aq    then aq:Disconnect();    aq    = nil end
    if ar then ar:Disconnect(); ar = nil end
    for aH in pairs(ao) do aD(aH) end
    for aH, aI in pairs(ap) do
        if aI then aI:Disconnect() end
        ap[aH] = nil
    end
end local aI=function()    


as += 1
    local aI = as
    task.spawn(function()
        while aI == as do
            task.wait(1)
            if aI ~= as or not aB() then break end
            al()
            for aJ, aK in ipairs(p:GetPlayers()) do
                if not X(aK) and aK.Character then
                    aE(aK, aK.Character)
                end
            end
        end
    end)
end local aJ=function()    


if aq then return end
    for aJ, aK in ipairs(p:GetPlayers()) do
        if not X(aK) then aG(aK) end
    end
    aq = p.PlayerAdded:Connect(function(aJ)
        if aB() and not X(aJ) then aG(aJ) end
    end)
    ar = p.PlayerRemoving:Connect(function(aJ) aD(aJ) end)
    aI()
end local aK=function(

aK, aL, aM, aN, aO)    
local aP = aO or aN.boxStyle

    if aP == "Fast" then
        local aQ = aM:WorldToViewportPoint(aK.Position)
        if aQ.Z <= 0 then return nil end
        local aR = aQ.Z
        local aS  = math.clamp(2800 / aR, 22, 420)
        local aT  = aS * 0.47
        return {
            minX = aQ.X - aT * 0.5, maxX = aQ.X + aT * 0.5,
            minY = aQ.Y - aS * 0.55, maxY = aQ.Y + aS * 0.45,
            centerX = aQ.X, topY = aQ.Y - aS * 0.55, bottomY = aQ.Y + aS * 0.45,
        }
    end

    if aP ~= "Full" and aP ~= "Corners" then return nil end

    local aQ = aK.CFrame
    local aR, aS, aT, aU = C, D, E, F
    local aV = {
        aQ:PointToWorldSpace(Vector3.new(-aR/2,  aS/2+aU, -aT/2)),
        aQ:PointToWorldSpace(Vector3.new( aR/2,  aS/2+aU, -aT/2)),
        aQ:PointToWorldSpace(Vector3.new(-aR/2,  aS/2+aU,  aT/2)),
        aQ:PointToWorldSpace(Vector3.new( aR/2,  aS/2+aU,  aT/2)),
        aQ:PointToWorldSpace(Vector3.new(-aR/2, -aS/2,      -aT/2)),
        aQ:PointToWorldSpace(Vector3.new( aR/2, -aS/2,      -aT/2)),
        aQ:PointToWorldSpace(Vector3.new(-aR/2, -aS/2,       aT/2)),
        aQ:PointToWorldSpace(Vector3.new( aR/2, -aS/2,       aT/2)),
    }

    local aW, aX, aY, aZ = math.huge, -math.huge, math.huge, -math.huge
    local a_ = false
    for a0, a1 in ipairs(aV) do
        local a2 = aM:WorldToViewportPoint(a1)
        if a2.Z > 0 then
            a_  = true
            aW = math.min(aW, a2.X); aX = math.max(aX, a2.X)
            aY = math.min(aY, a2.Y); aZ = math.max(aZ, a2.Y)
        end
    end

    if not a_ or aX <= aW or aZ <= aY then return nil end
    return {
        minX = aW, maxX = aX, minY = aY, maxY = aZ,
        centerX = (aW + aX) * 0.5, topY = aY, bottomY = aZ,
    }
end local aL=function(

aL, aM, aN, aO, aP, aQ, aR, aS)    
local aT = math.clamp(math.min(aN - aM, aP - aO) * 0.22, 6, 48)
    if not aS then
        for aU = 1, 8 do aL[aU].Visible = false end
        return
    end
    for aU = 1, 8 do
        aL[aU].Visible = true; aL[aU].Color = aQ; aL[aU].Thickness = aR
    end
    aL[1].From = Vector2.new(aM, aO); aL[1].To = Vector2.new(aM + aT, aO)
    aL[2].From = Vector2.new(aM, aO); aL[2].To = Vector2.new(aM,      aO + aT)
    aL[3].From = Vector2.new(aN, aO); aL[3].To = Vector2.new(aN - aT, aO)
    aL[4].From = Vector2.new(aN, aO); aL[4].To = Vector2.new(aN,      aO + aT)
    aL[5].From = Vector2.new(aM, aP); aL[5].To = Vector2.new(aM + aT, aP)
    aL[6].From = Vector2.new(aM, aP); aL[6].To = Vector2.new(aM,      aP - aT)
    aL[7].From = Vector2.new(aN, aP); aL[7].To = Vector2.new(aN - aT, aP)
    aL[8].From = Vector2.new(aN, aP); aL[8].To = Vector2.new(aN,      aP - aT)
end local aM=function(

aM, aN, aO, aP, aQ)    
if not (Toggles.ESPSkeleton and Toggles.ESPSkeleton.Value) then at(aM); return end
    if not aM.skelCache or aM.skelCacheChar ~= aN then
        aM.skelCache     = ai(aN)
        aM.skelCacheChar = aN
    end
    local aR = aM.skelCache
    local aS, aT = aQ.cSkel, aQ.skelThick
    for aU = 1, T do
        local aV = aM.skelLines[aU]
        local aW = aR[aU]
        if not aW or not aW.parts then
            aV.Visible = false
        else
            local aX, aY = aW.parts[1], aW.parts[2]
            if not aX.Parent or not aY.Parent then
                aV.Visible = false
            else
                local aZ, a_ = aX.Position, aY.Position
                local a0 = (aZ - a_).Magnitude
                if a0 < V or a0 > U then
                    aV.Visible = false
                else
                    local a1 = aP:WorldToViewportPoint(aZ)
                    local a2 = aP:WorldToViewportPoint(a_)
                    if a1.Z > 0 and a2.Z > 0 then
                        aV.From = Vector2.new(a1.X, a1.Y); aV.To = Vector2.new(a2.X, a2.Y)
                        aV.Color = aS; aV.Thickness = aT; aV.Visible = true
                    else
                        aV.Visible = false
                    end
                end
            end
        end
    end
end local aN=function(

aN, aO, aP, aQ, aR)    
local aS = aN.Character
    local aT    = Y[aN]
    if not aS or not aT then
        if aT then av(aT) end
        return
    end

    local aU = aS:FindFirstChild("HumanoidRootPart")
    local aV = aS:FindFirstChildOfClass("Humanoid")
    if not aU or not aV or aV.Health <= 0 then
        av(aT); ax(aT); return
    end

    local aW = aU.Position - aP
    local aX = aW.X*aW.X + aW.Y*aW.Y + aW.Z*aW.Z
    if aX > aQ.maxDistSq then av(aT); return end

    local aY    = Toggles.ESPBox and Toggles.ESPBox.Value
    local aZ = (Toggles.ESPName and Toggles.ESPName.Value)
        or (Toggles.ESPDistance and Toggles.ESPDistance.Value)
        or (Toggles.ESPTracer and Toggles.ESPTracer.Value)
        or (Toggles.ESPHealth and Toggles.ESPHealth.Value)
    local a_      = aQ.boxStyle
    local a0 = (not aY and aZ) and "Fast" or a_
    local a1     = aK(aU, aV, aO, aQ, a0)

    if not a1 then au(aT); aM(aT, aS, aV, aO, aQ); return end

    local a2, a3, a4, a5 = a1.minX, a1.maxX, a1.minY, a1.maxY
    local a6, a7, a8 = a1.centerX, a1.topY, a1.bottomY or a5

    local a9      = aQ.cBox
    local ba = aY and a_ == "Corners"
    local bb    = aY and (a_ == "Full" or a_ == "Fast")
    local bc     = aY and Toggles.ESPFilled  and Toggles.ESPFilled.Value  and not ba
    local bd    = aY and Toggles.ESPOutline and Toggles.ESPOutline.Value

    if ba then
        aT.boxLine.Visible = false; aT.boxFill.Visible = false
        aT.boxOutlineOuter.Visible = false; aT.boxOutlineInner.Visible = false
        aL(aT.cornerLines, a2, a3, a4, a5, a9, aQ.boxThick, true)
    elseif bb then
        for be = 1, 8 do aT.cornerLines[be].Visible = false end
        local be  = Vector2.new(a3 - a2, a5 - a4)
        local bf = Vector2.new(a2, a4)

        aT.boxFill.Filled       = bc
        aT.boxFill.Color        = a9
        aT.boxFill.Transparency = bc and aQ.fillTrans or 1
        aT.boxFill.Size         = be
        aT.boxFill.Position     = bf
        aT.boxFill.Visible      = bc

        aT.boxLine.Color     = a9
        aT.boxLine.Thickness = aQ.boxThick
        ay(aT.boxLine, aQ.outlineTrans)
        aT.boxLine.Size     = be; aT.boxLine.Position = bf; aT.boxLine.Visible = true

        if bd then
            local bg   = aQ.cOutline
            local bh     = aQ.outlineTrans
            local bi = math.max(1, aQ.outlineThick)
            local bj, bk = 1, 1
            aT.boxOutlineOuter.Color     = bg
            aT.boxOutlineOuter.Thickness = bi
            ay(aT.boxOutlineOuter, bh)
            aT.boxOutlineOuter.Filled   = false
            aT.boxOutlineOuter.Size     = be + Vector2.new(bj*2, bj*2)
            aT.boxOutlineOuter.Position = bf - Vector2.new(bj, bj)
            aT.boxOutlineOuter.Visible  = true
            local bl = be - Vector2.new(bk*2, bk*2)
            if bl.X > 4 and bl.Y > 4 then
                aT.boxOutlineInner.Color     = bg
                aT.boxOutlineInner.Thickness = bi
                ay(aT.boxOutlineInner, bh)
                aT.boxOutlineInner.Filled   = false
                aT.boxOutlineInner.Size     = bl
                aT.boxOutlineInner.Position = bf + Vector2.new(bk, bk)
                aT.boxOutlineInner.Visible  = true
            else
                aT.boxOutlineInner.Visible = false
            end
        else
            aT.boxOutlineOuter.Visible = false; aT.boxOutlineInner.Visible = false
        end
    else
        for be = 1, 8 do aT.cornerLines[be].Visible = false end
        aT.boxLine.Visible = false; aT.boxFill.Visible = false
        aT.boxOutlineOuter.Visible = false; aT.boxOutlineInner.Visible = false
    end

    if Toggles.ESPName and Toggles.ESPName.Value then
        aT.name.Visible = true
        aT.name.Text    = aN.DisplayName ~= "" and aN.DisplayName or aN.Name
        aT.name.Color   = aQ.cName; aT.name.Size = aQ.nameSize
        aT.name.Position = Vector2.new(a6, a7 - aQ.nameSize - 4)
    else aT.name.Visible = false end

    if Toggles.ESPDistance and Toggles.ESPDistance.Value then
        local be = math.floor(math.sqrt(aX) + 0.5)
        aT.dist.Visible = true; aT.dist.Text = tostring(be) .. "m"
        aT.dist.Color = aQ.cDist; aT.dist.Size = math.max(10, aQ.distSize)
        aT.dist.Position = Vector2.new(a6, a8 + 4)
    else aT.dist.Visible = false end

    if Toggles.ESPTracer and Toggles.ESPTracer.Value then
        local be = aQ.tracerFrom == "Center"
            and Vector2.new(aR.X * 0.5, aR.Y * 0.5)
            or  Vector2.new(aR.X * 0.5, aR.Y)
        aT.tracer.Visible   = true; aT.tracer.Color = aQ.cTracer
        aT.tracer.Thickness = math.max(1, aQ.tracerThick)
        aT.tracer.From      = be
        aT.tracer.To        = Vector2.new((a2 + a3) * 0.5, a5)
    else aT.tracer.Visible = false end

    if Toggles.ESPHealth and Toggles.ESPHealth.Value then
        local be  = aV.MaxHealth
        local bf = be > 0 and math.clamp(aV.Health / be, 0, 1) or 0
        local bg  = math.clamp(3 + aQ.boxThick, 3, 8)
        local bh  = a5 - a4
        local bi    = a2 - bg - 4
        aT.hpBg.Color = aQ.cHpBg; aT.hpBg.Size = Vector2.new(bg, bh)
        aT.hpBg.Position = Vector2.new(bi, a4); aT.hpBg.Visible = true
        aT.hpFill.Color = aQ.cHpLow:Lerp(aQ.cHpHigh, bf)
        aT.hpFill.Size  = Vector2.new(bg - 2, (bh - 2) * bf)
        aT.hpFill.Position = Vector2.new(bi + 1, a4 + bh - 1 - (bh - 2) * bf)
        aT.hpFill.Visible = true
    else aT.hpBg.Visible = false; aT.hpFill.Visible = false end

    aM(aT, aS, aV, aO, aQ)
end local aO=function()    


if not y then return end
    if not aA() then return end
    al()
    local aO = y
    local aP = aO.CFrame.Position
    local aQ = aO.ViewportSize
    for aR, aS in ipairs(p:GetPlayers()) do
        if X(aS) then
            local aT = Y[aS]
            if aT then av(aT) end
        else
            if aS.Character and not Y[aS] then az(aS) end
            aN(aS, aO, aP, aj, aQ)
        end
    end
end local aP=function(

aP)    
if Z[aP] then Z[aP]:Disconnect() end
    Z[aP] = aP.CharacterAdded:Connect(function(aQ)
        if aA() then
            task.defer(function()
                local aR = az(aP)
                ax(aR)
            end)
        end
    end)
end local aQ=function()    


if _         then _:Disconnect();         _         = nil end
    if am    then am:Disconnect();    am    = nil end
    if an then an:Disconnect(); an = nil end
    for aQ in pairs(Y) do aw(aQ) end
    for aQ, aR in pairs(Z) do
        if aR then aR:Disconnect() end
        Z[aQ] = nil
    end
end local aR=function()    


if _ then return end
    for aR, aS in ipairs(p:GetPlayers()) do
        if not X(aS) then
            aP(aS)
            if aS.Character then az(aS) end
        end
    end
    am = p.PlayerAdded:Connect(function(aR)
        if not aA() then return end
        if not X(aR) then
            aP(aR)
            if aR.Character then az(aR) end
        end
    end)
    an = p.PlayerRemoving:Connect(function(aR)
        aw(aR)
        if Z[aR] then Z[aR]:Disconnect(); Z[aR] = nil end
    end)
    _ = q.RenderStepped:Connect(aO)
end local aS=function()    


if aA() then aR() else aQ() end
    if aB() then aJ(); aF() else aH() end
end




local aT, aU
local aV, aW
local aX = false
local aY=function()    

local aY, aZ = pcall(function()
        local aY = x:FindFirstChild("PlayerGui"); if not aY then return false end
        local aZ = aY:FindFirstChild("MainGui", true); if not aZ then return false end
        local a_ = aZ:FindFirstChild("Lobby", true); if not a_ then return false end
        local a0 = a_:FindFirstChild("Currency", true)
        return a0 and a0.Visible == true
    end)
    return aY and aZ == true
end local aZ=function()    


local aZ = {}
    for a_, a0 in workspace:GetChildren() do
        if a0:FindFirstChildOfClass("Humanoid") then
            table.insert(aZ, a0)
        elseif a0.Name == "HurtEffect" then
            for a1, a2 in a0:GetChildren() do
                if a2.ClassName ~= "Highlight" then table.insert(aZ, a2) end
            end
        end
    end
    return aZ
end local a_=function()    


local a_ = workspace.CurrentCamera
    if not a_ then return nil end
    local a0 = x.Character
    if not a0 then return nil end
    local a1    = (Options.SilentAimFOV and Options.SilentAimFOV.Value) or 120
    local a2 = Toggles.CombatTargetTeammates and Toggles.CombatTargetTeammates.Value
    local a3   = Vector2.new(a_.ViewportSize.X * 0.5, a_.ViewportSize.Y * 0.5)
    local a4 ,a5=(math.huge
)    for a6, a7 in aZ() do
        if a7 ~= a0 and a7:FindFirstChild("HumanoidRootPart") then
            local a8 = a7:FindFirstChildOfClass("Humanoid")
            if a8 and a8.Health > 0 then
                local a9 = p:GetPlayerFromCharacter(a7)
                local ba = not a2 and a9 and x.Team and a9.Team and a9.Team == x.Team
                if not ba then
                    local bb = a7.HumanoidRootPart
                    local bc, bd = a_:WorldToViewportPoint(bb.Position)
                    local be = (bd == true) or (bd == nil and bc.Z > 0)
                    if be then
                        local bf = (a3 - Vector2.new(bc.X, bc.Y)).Magnitude
                        if bf <= a1 and bf < a4 then
                            a5 = a7; a4 = bf
                        end
                    end
                end
            end
        end
    end
    return a5
end local a0=function(...)    


if aY() or not (Toggles.SilentAimEnabled and Toggles.SilentAimEnabled.Value) then
        return aW(...)
    end
    local a0 = { ... }
    if #a0 > 0 and a0[4] == 999 then
        if r:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local a1 = a_()
            if a1 and a1:FindFirstChild("Head") then
                a0[3] = a1.Head.Position
            end
            return aW(table.unpack(a0))
        end
    end
    return aW(...)
end local a1=function()    


if aX then return end
    local a1    = s:FindFirstChild("Modules")
    local a2 = a1 and a1:FindFirstChild("Utility")
    if not a2 then return end
    local a3, a4 = pcall(require, a2)
    if not a3 or type(a4) ~= "table" or type(a4.Raycast) ~= "function" then return end
    aV      = a4
    aW = a4.Raycast
    aX   = true
    a4.Raycast = a0
end local a2=function()    


if aX and aV and aW then
        aV.Raycast = aW
    end
    aX = false; aV = nil; aW = nil
end local a3=function()    


if Toggles.SilentAimEnabled and Toggles.SilentAimEnabled.Value then
        a1()
    else
        a2()
    end
end




local a4
local a5=function()    

pcall(function()
        local a5 = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
        local a6 = a5 and a5:FindFirstChild("UserInterface", true)
        local a7 = a6 and a6:FindFirstChild("FlashbangGui", true)
        if a7 then a7:Destroy() end
    end)
    pcall(function()
        local a5 = x:FindFirstChild("PlayerScripts")
        local a6 = a5 and a5:FindFirstChild("UserInterface", true)
        local a7 = a6 and a6:FindFirstChild("FlashbangGui", true)
        if a7 then a7:Destroy() end
    end)
end local a6=function()    


if Toggles.MiscRemoveFlashbang and Toggles.MiscRemoveFlashbang.Value then
        if not a4 then
            a4 = q.Heartbeat:Connect(a5)
        end
    else
        if a4 then a4:Disconnect(); a4 = nil end
    end
end local a7=function()    


if a4 then a4:Disconnect(); a4 = nil end
end local a8=function(

a8, a9)    
if math.abs(a8) < 0.2 and math.abs(a9) < 0.2 then return end
    local ba = math.floor(a8 + (a8 >= 0 and 0.5 or -0.5))
    local bb = math.floor(a9 + (a9 >= 0 and 0.5 or -0.5))
    if ba == 0 and bb == 0 then return end
    pcall(function()
        if typeof(mousemoverel) == "function" then mousemoverel(ba, bb) end
    end)
end local a9=function(

a9)    
local ba = a9.ViewportSize
    return Vector2.new(ba.X * 0.5, ba.Y * 0.5)
end local ba=function(

ba)    
if not ba or not ba:IsA("BasePart") then return nil end
    if ba.Name == "Head" then return ba.Position + Vector3.new(0, ba.Size.Y * 0.35, 0) end
    return ba.Position
end local bb=function(

bb, bc, bd, be)    
if bc <= 0 or not bb then return nil, nil, nil end
    local bf = a9(bb)
    local bg, bh,bi,bj =(math.huge)    
for bk, bl in ipairs(p:GetPlayers()) do
        if bl ~= x and bl.Character then
            local bm = not be and x.Team and bl.Team and bl.Team == x.Team
            if not bm then
                local bn = bl.Character:FindFirstChildOfClass("Humanoid")
                if bn and bn.Health > 0 then
                    local bo = bl.Character:FindFirstChild(bd) or bl.Character:FindFirstChild("Head")
                    if bo and bo:IsA("BasePart") then
                        local bp = ba(bo)
                        local bq = bb:WorldToViewportPoint(bp)
                        if bq.Z > 0 then
                            local br = Vector2.new(bq.X, bq.Y)
                            local bs  = (br - bf).Magnitude
                            if bs <= bc and bs < bg then
                                bg = bs; bh = bl; bi = bp; bj = br
                            end
                        end
                    end
                end
            end
        end
    end
    return bh, bi, bj
end local bc=function()    


return (Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value)
        or (Toggles.SilentAimEnabled and Toggles.SilentAimEnabled.Value)
end local bd=function()    


local bd = Toggles.AimbotEnabled    and Toggles.AimbotEnabled.Value    and Toggles.AimbotShowFov and Toggles.AimbotShowFov.Value
    local be = Toggles.SilentAimEnabled and Toggles.SilentAimEnabled.Value and Toggles.SilentShowFov and Toggles.SilentShowFov.Value
    return bd or be
end local be=function()    


local be = 0
    if Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value and Toggles.AimbotShowFov and Toggles.AimbotShowFov.Value then
        local bf = Options.AimbotFOV and Options.AimbotFOV.Value or 120
        if bf > be then be = bf end
    end
    if Toggles.SilentAimEnabled and Toggles.SilentAimEnabled.Value and Toggles.SilentShowFov and Toggles.SilentShowFov.Value then
        local bf = Options.SilentAimFOV and Options.SilentAimFOV.Value or 120
        if bf > be then be = bf end
    end
    return be
end local bf=function()    


if aU then
        pcall(function() aU:Remove() end)
        aU = nil
    end
end local bg=function()    


if not aU then
        aU              = Drawing.new("Circle")
        aU.Filled       = false
        aU.Visible      = false
        aU.Thickness    = 1
        aU.Color        = Color3.fromRGB(255, 255, 255)
        aU.Transparency = 0.5
        aU.NumSides     = 64
    end
    return aU
end local bh=function()    


if aT then aT:Disconnect(); aT = nil end
    bf()
end local bi=function()    


local bi = workspace.CurrentCamera
    if not bi then return end

    local bj = bd() and bc()
    local bk    = be()
    if bj and bk > 0 then
        local bl = bg()
        bl.Position = a9(bi)
        bl.Radius   = bk
        bl.Visible  = true
    else
        if aU then aU.Visible = false end
    end

    if aY() then return end

    local bl   = (Options.CombatHitpart and Options.CombatHitpart.Value) or "Head"
    local bm = Toggles.CombatTargetTeammates and Toggles.CombatTargetTeammates.Value

    if Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value then
        local bn = Options.AimbotKeybind and Options.AimbotKeybind.GetState and Options.AimbotKeybind:GetState()
        if bn then
            local bo = Options.AimbotFOV and Options.AimbotFOV.Value or 120
            local bp, bq, br = bb(bi, bo, bl, bm)
            if bq and br then
                local bs  = r:GetMouseLocation()
                local bt     = br.X - bs.X
                local bu     = br.Y - bs.Y
                local bv = Options.AimbotSmooth and Options.AimbotSmooth.Value or 50
                local bw  = math.clamp((101 - bv) / 100, 0.03, 1)
                a8(bt * bw, bu * bw)
            end
        end
    end
end local bj=function()    


if bc() then
        if not aT then aT = q.RenderStepped:Connect(bi) end
    else
        bh()
    end
end




local bk = {
    { label = "Off (restore original sky)", faces = nil },
    { label = "Preset 0",  faces = { Bk="rbxassetid://12635309703", Dn="rbxassetid://12635311686", Ft="rbxassetid://12635312870", Lf="rbxassetid://12635313718", Rt="rbxassetid://12635315817", Up="rbxassetid://12635316856" } },
    { label = "Preset 1",  faces = { Bk="rbxassetid://12064107",    Dn="rbxassetid://12064152",    Ft="rbxassetid://12064121",    Lf="rbxassetid://12063984",    Rt="rbxassetid://12064115",    Up="rbxassetid://12064131"    } },
    { label = "Preset 2",  faces = { Bk="rbxassetid://271042516",   Dn="rbxassetid://271077243",   Ft="rbxassetid://271042556",   Lf="rbxassetid://271042310",   Rt="rbxassetid://271042467",   Up="rbxassetid://271077958"   } },
    { label = "Preset 3",  faces = { Bk="rbxassetid://1876545003",  Dn="rbxassetid://1876544331",  Ft="rbxassetid://1876542941",  Lf="rbxassetid://1876543392",  Rt="rbxassetid://1876543764",  Up="rbxassetid://1876544642"  } },
    { label = "Preset 4",  faces = { Bk="rbxassetid://116758234",   Dn="rbxassetid://116758314",   Ft="rbxassetid://116758367",   Lf="rbxassetid://116758446",   Rt="rbxassetid://116758478",   Up="rbxassetid://116758496"   } },
    { label = "Preset 5",  faces = { Bk="rbxassetid://1233158420",  Dn="rbxassetid://1233158838",  Ft="rbxassetid://1233157105",  Lf="rbxassetid://1233157640",  Rt="rbxassetid://1233157995",  Up="rbxassetid://1233159158"  } },
    { label = "Preset 6",  faces = { Bk="rbxassetid://1327358",     Dn="rbxassetid://1327359",     Ft="rbxassetid://1327355",     Lf="rbxassetid://1327357",     Rt="rbxassetid://1327356",     Up="rbxassetid://1327360"     } },
    { label = "Preset 7",  faces = { Bk="rbxassetid://570555736",   Dn="rbxassetid://570555964",   Ft="rbxassetid://570555800",   Lf="rbxassetid://570555840",   Rt="rbxassetid://570555882",   Up="rbxassetid://570555929"   } },
    { label = "Preset 8",  faces = { Bk="rbxassetid://95020137072033",  Dn="rbxassetid://92862258103959",  Ft="rbxassetid://107665368823185", Lf="rbxassetid://126542804346203", Rt="rbxassetid://103716549795832", Up="rbxassetid://131036626982613" } },
    { label = "Preset 9",  faces = { Bk="rbxassetid://169210090",   Dn="rbxassetid://169210108",   Ft="rbxassetid://169210121",   Lf="rbxassetid://169210133",   Rt="rbxassetid://169210143",   Up="rbxassetid://169210149"   } },
    { label = "Preset 10", faces = { Bk="rbxassetid://47974894",    Dn="rbxassetid://47974690",    Ft="rbxassetid://47974821",    Lf="rbxassetid://47974776",    Rt="rbxassetid://47974859",    Up="rbxassetid://47974909"    } },
}
local bl=function()    

local bl = {}
    for bm, bn in ipairs({ "Ambient","Brightness","ClockTime","ColorShift_Bottom","ColorShift_Top",
        "EnvironmentDiffuseScale","EnvironmentSpecularScale","ExposureCompensation",
        "FogColor","FogEnd","FogStart","GeographicLatitude","OutdoorAmbient" }) do
        local bo, bp = pcall(function() return u[bn] end)
        if bo then bl[bn] = bp end
    end
    local bm, bn = pcall(function() return u.GlobalShadows end)
    if bm then bl.GlobalShadows = bn end
    return bl
end

local bm    = bl()
local bn  = {}
local bo = u:FindFirstChildOfClass("Atmosphere")
local bp       
if bo then
    local bq, br = pcall(function()
        return {
            Density = bo.Density, Offset = bo.Offset,
            Color   = bo.Color,   Decay  = bo.Decay,
            Glare   = bo.Glare,   Haze   = bo.Haze,
        }
    end)
    if bq then bp = br end
end
local bq=function()    

for bq, br in pairs(bm) do pcall(function() u[bq] = br end) end
end local br=function()    

if bo and bo.Parent and bp then
        for br, bs in pairs(bp) do pcall(function() bo[br] = bs end) end
    end
end local bs=function()    

for bs, bt in pairs(bn) do
        if typeof(bs) == "Instance" and bs.Parent and bs:IsA("Sky") then
            for bu, bv in pairs(bt) do pcall(function() bs[bu] = bv end) end
        end
    end
end local bt=function()    

bq()
    br()
    bs()
end local bu=function()    


for bu, bv in ipairs(u:GetDescendants()) do if bv:IsA("Sky") then return bv end end
    for bu, bv in ipairs(workspace:GetDescendants()) do if bv:IsA("Sky") then return bv end end
    return nil
end local bv=function(

bv)    
for bw, bx in ipairs(bk) do if bx.label == bv then return bx end end
    return nil
end local bw=function(

bw)    
if not bw or not bw:IsA("Sky") or bn[bw] then return end
    bn[bw] = {
        SkyboxBk = bw.SkyboxBk, SkyboxDn = bw.SkyboxDn, SkyboxFt = bw.SkyboxFt,
        SkyboxLf = bw.SkyboxLf, SkyboxRt = bw.SkyboxRt, SkyboxUp = bw.SkyboxUp,
    }
end local bx=function(

bx)    
if not bx then return end
    if not bx.faces then bs(); return end
    local by = bu()
    if not by then m:Notify("No Sky found under Lighting or Workspace.", 3); return end
    bw(by)
    local bz = bx.faces
    pcall(function()
        by.SkyboxBk = bz.Bk; by.SkyboxDn = bz.Dn; by.SkyboxFt = bz.Ft
        by.SkyboxLf = bz.Lf; by.SkyboxRt = bz.Rt; by.SkyboxUp = bz.Up
    end)
end




local by = m:CreateWindow({
    Title        = "NameHub - Rivals " .. a,
    Center       = true,
    AutoShow     = true,
    TabPadding   = 8,
    MenuFadeTime = 0.2,
})

local bz = {
    Combat   = by:AddTab("Combat"),
    Visuals  = by:AddTab("Visuals"),
    World    = by:AddTab("World Modulation"),
    Misc     = by:AddTab("Misc"),
    Settings = by:AddTab("UI Settings"),
}

local bA = bz.Combat:AddLeftTabbox("Combat")
local bB = bA:AddTab("Aimbot")
local bC = bA:AddTab("Silent Aim")

local bD = bC:AddLabel(
    "DANGEROUS - Hooks ReplicatedStorage.Modules.Utility.Raycast (high detection risk). Do not use with mouse aimbot while firing.",
    true
)
bD.TextLabel.TextColor3 = Color3.fromRGB(255, 220, 50)

bC:AddToggle("SilentAimEnabled",    { Text = "Enable silent aim",      Default = false })
bC:AddToggle("silent_manipulation", { Text = "Direction manipulation", Default = false })
bC:AddToggle("SilentShowFov",       { Text = "Show FOV circle",        Default = true  })
bC:AddSlider("SilentAimFOV", { Text = "FOV radius (px)", Min = 20, Max = 400, Default = 120, Rounding = 0 })
bC:AddLabel("Aim part & teammates: set under Aimbot subtab.", true)

bB:AddLabel("Mouse only (mousemoverel), never Camera.CFrame.", true)
bB:AddToggle("AimbotEnabled", { Text = "Enable mouse aimbot", Default = false })
bB:AddToggle("AimbotShowFov", { Text = "Show FOV circle",     Default = true  })
bB:AddSlider("AimbotFOV",    { Text = "FOV radius (px)",                  Min = 20, Max = 400, Default = 120, Rounding = 0 })
bB:AddSlider("AimbotSmooth", { Text = "Smoothing (higher = slower / smoother)", Min = 5, Max = 95, Default = 50, Rounding = 0 })
bB:AddLabel("Hold key / mouse to aim"):AddKeyPicker("AimbotKeybind", {
    Default = "MB2", Mode = "Hold", Text = "Aimbot", NoUI = true,
})
bB:AddDropdown("CombatHitpart", { Values = { "Head", "HumanoidRootPart" }, Default = 1, Text = "Aim part" })
bB:AddToggle("CombatTargetTeammates", { Text = "Target teammates", Default = false })

local bE = bz.Misc:AddLeftGroupbox("Weapons")
bE:AddToggle("NoRecoil",           { Text = "No Recoil",         Default = false })
bE:AddToggle("NoSpread",           { Text = "No Spread",         Default = false })
bE:AddToggle("exploits_no_spread", { Text = "No Spread (FireServer-Hook)", Default = false })
bE:AddToggle("NoAccuracy",         { Text = "Perfect Accuracy",  Default = false })
bE:AddDivider()
bE:AddToggle("RapidFire", { Text = "Rapid Fire", Default = false })
bE:AddDivider()
bE:AddButton({
    Text = "Apply All",
    Func = function()
        Toggles.NoRecoil:SetValue(true);   Toggles.NoSpread:SetValue(true)
        Toggles.NoAccuracy:SetValue(true); Toggles.RapidFire:SetValue(true)
    end,
}):AddButton({
    Text = "Reset All",
    Func = function()
        Toggles.NoRecoil:SetValue(false);   Toggles.NoSpread:SetValue(false)
        Toggles.NoAccuracy:SetValue(false); Toggles.RapidFire:SetValue(false)
    end,
})
bE:AddDivider()
bE:AddToggle("MiscRemoveFlashbang", {
    Text    = "Remove flashbang effect",
    Default = false,
    Tooltip = "Heartbeat: destroys FlashbangGui under StarterPlayerScripts / PlayerScripts -> UserInterface.",
})
bE:AddDivider()
bE:AddButton({
    Text = "Unlock All",
    Func = function() aa() end,
})

local bF = bz.Visuals:AddLeftGroupbox("ESP")
bF:AddToggle("ESPBox",           { Text = "Box ESP",                Default = false })
bF:AddToggle("ESPOutline",       { Text = "Box outer outline (2D)", Default = true  })
bF:AddToggle("ESPFilled",        { Text = "Box fill",               Default = false })
bF:AddToggle("ESPName",          { Text = "Name",                   Default = false })
bF:AddToggle("ESPDistance",      { Text = "Distance",               Default = false })
bF:AddToggle("ESPTracer",        { Text = "Tracer (from bottom)",   Default = false })
bF:AddToggle("ESPHealth",        { Text = "Health bar",             Default = false })
bF:AddToggle("ESPSkeleton",      { Text = "Skeleton",               Default = false })
bF:AddToggle("ESPPlayerOutline", {
    Text    = "Player outline (Highlight, fill off)",
    Default = false,
    Tooltip = "Highlight with FillTransparency = 1, outline only.",
})

local bG = bz.Visuals:AddRightGroupbox("Colors")
bG:AddLabel("Box / corner / tracer"):AddColorPicker("ColESPBox",     { Default = Color3.fromRGB(255, 60, 60),   Title = "Box",          Callback = function() end })
bG:AddLabel("2D box outline stroke"):AddColorPicker("ColESPOutline", { Default = Color3.fromRGB(0, 0, 0),       Title = "Box outline",  Callback = function() end })
bG:AddLabel("Name"):AddColorPicker("ColESPName",                     { Default = Color3.fromRGB(255, 255, 255), Title = "Name",         Callback = function() end })
bG:AddLabel("Distance"):AddColorPicker("ColESPDist",                 { Default = Color3.fromRGB(200, 200, 255), Title = "Distance",     Callback = function() end })
bG:AddLabel("Tracer"):AddColorPicker("ColESPTracer",                 { Default = Color3.fromRGB(255, 80, 80),   Title = "Tracer",       Callback = function() end })
bG:AddLabel("Skeleton"):AddColorPicker("ColESPSkeleton",             { Default = Color3.fromRGB(255, 255, 255), Title = "Skeleton",     Callback = function() end })
bG:AddLabel("Health bar background"):AddColorPicker("ColESPHpBg",    { Default = Color3.fromRGB(30, 30, 30),    Title = "HP background", Callback = function() end })
bG:AddLabel("Health (low)"):AddColorPicker("ColESPHpLow",            { Default = Color3.fromRGB(220, 50, 50),   Title = "HP low",       Callback = function() end })
bG:AddLabel("Health (high)"):AddColorPicker("ColESPHpHigh",          { Default = Color3.fromRGB(55, 220, 90),   Title = "HP high",      Callback = function() end })
bG:AddLabel("Player outline (Highlight)"):AddColorPicker("ColESPPlayerOutline", { Default = Color3.fromRGB(255, 255, 255), Title = "Player outline", Callback = function() end })

local bH = bz.World:AddLeftGroupbox("World")
local bI  = typeof(bm.Brightness)            == "number" and bm.Brightness            or 2
local bJ = typeof(bm.ClockTime)             == "number" and bm.ClockTime             or 14
local bK = typeof(bm.ExposureCompensation) == "number" and bm.ExposureCompensation  or 0
local bL = typeof(bm.FogStart)              == "number" and bm.FogStart              or 0
local bM = typeof(bm.FogEnd)                == "number" and bm.FogEnd                or 500
local bN = bm.FogColor or Color3.fromRGB(191, 191, 191)
local bO = bm.Ambient or Color3.fromRGB(128, 128, 128)

local bP = {}
for bQ, bR in ipairs(bk) do table.insert(bP, bR.label) end

bH:AddToggle("WorldModEnabled", { Text = "Enable world modulation", Default = false })
bH:AddSlider("WModBrightness", { Text = "Brightness",   Min = 0,  Max = 10,   Default = math.clamp(bI,   0,  10),   Rounding = 2 })
bH:AddSlider("WModExposure",   { Text = "Exposure",     Min = -3, Max = 3,    Default = math.clamp(bK,-3,  3),    Rounding = 2 })
bH:AddSlider("WModClockTime",  { Text = "Clock time",   Min = 0,  Max = 24,   Default = math.clamp(bJ,  0,  24),   Rounding = 2 })
bH:AddSlider("WModFogStart",   { Text = "Fog start",    Min = 0,  Max = 2500, Default = math.clamp(bL,  0,  2500), Rounding = 0 })
bH:AddSlider("WModFogEnd",     { Text = "Fog end",      Min = 0,  Max = 2500, Default = math.clamp(bM,  0,  2500), Rounding = 0 })
bH:AddLabel("Fog color"):AddColorPicker("WModFogColor", { Default = bN,  Title = "Fog color", Callback = function() end })
bH:AddLabel("Ambient"):AddColorPicker("WModAmbient",    { Default = bO, Title = "Ambient",   Callback = function() end })
bH:AddDivider()
bH:AddDropdown("WorldModSkyPreset", { Values = bP, Default = bP[1], Text = "Sky preset" })
local bQ=function()    

if not Toggles.WorldModEnabled or not Toggles.WorldModEnabled.Value then return end
    pcall(function()
        u.Brightness           = Options.WModBrightness.Value
        u.ExposureCompensation = Options.WModExposure.Value
        u.ClockTime            = Options.WModClockTime.Value
        u.FogStart             = Options.WModFogStart.Value
        u.FogEnd               = Options.WModFogEnd.Value
        u.FogColor             = Options.WModFogColor.Value
        u.Ambient              = Options.WModAmbient.Value
    end)
end local bR=function()    


if not Toggles.WorldModEnabled or not Toggles.WorldModEnabled.Value then return end
    local bR = Options.WorldModSkyPreset and Options.WorldModSkyPreset.Value
    bx(bv(bR))
end local bS=function()    


if Toggles.WorldModEnabled.Value then
        bQ()
        bR()
    else
        bq(); br(); bs()
    end
end
Toggles.WorldModEnabled:OnChanged(bS)
local bT=function(
bT)    
if bT and bT.OnChanged then
        bT:OnChanged(function() if Toggles.WorldModEnabled.Value then bQ() end end)
    end
end
bT(Options.WModBrightness)
bT(Options.WModExposure)
bT(Options.WModClockTime)
bT(Options.WModFogStart)
bT(Options.WModFogEnd)
Options.WModFogColor:OnChanged(function() if Toggles.WorldModEnabled.Value then bQ() end end)
Options.WModAmbient:OnChanged(function()  if Toggles.WorldModEnabled.Value then bQ() end end)
Options.WorldModSkyPreset:OnChanged(function() bR() end)

Toggles.NoRecoil:OnChanged(function()
    af(function(bU)
        if bU.ShootRecoil == nil then return end
        if Toggles.NoRecoil.Value then A(bU); bU.ShootRecoil = 0
        else B(bU, "ShootRecoil") end
    end)
end)
Toggles.NoSpread:OnChanged(function()
    af(function(bU)
        if bU.ShootSpread == nil then return end
        if Toggles.NoSpread.Value then A(bU); bU.ShootSpread = 0
        else B(bU, "ShootSpread") end
    end)
end)
Toggles.NoAccuracy:OnChanged(function()
    af(function(bU)
        if bU.ShootAccuracy == nil then return end
        if Toggles.NoAccuracy.Value then A(bU); bU.ShootAccuracy = 0
        else B(bU, "ShootAccuracy") end
    end)
end)
Toggles.RapidFire:OnChanged(function()
    af(function(bU)
        if bU.ShootCooldown == nil then return end
        if Toggles.RapidFire.Value then A(bU); bU.ShootCooldown = 0.0000000001
        else B(bU, "ShootCooldown") end
    end)
end)
local bU=function(
bU)if bU then bU:OnChanged(aS) end end
bU(Toggles.ESPBox)
bU(Toggles.ESPName)
bU(Toggles.ESPDistance)
bU(Toggles.ESPTracer)
bU(Toggles.ESPHealth)
bU(Toggles.ESPSkeleton)
Toggles.ESPPlayerOutline:OnChanged(aS)
if Options.ColESPPlayerOutline and Options.ColESPPlayerOutline.OnChanged then
    Options.ColESPPlayerOutline:OnChanged(aF)
end
local bV=function(
bV)if bV then bV:OnChanged(function() bj() end) end end
bV(Toggles.AimbotEnabled)
if Toggles.SilentAimEnabled then
    Toggles.SilentAimEnabled:OnChanged(function() a3(); bj() end)
end
if Toggles.MiscRemoveFlashbang then
    Toggles.MiscRemoveFlashbang:OnChanged(a6)
end
bV(Toggles.AimbotShowFov)
bV(Toggles.SilentShowFov)

local bW = bz.Settings:AddLeftGroupbox("Menu")
bW:AddButton("Unload", function()
    aQ(); aH(); bh()
    a7(); a2(); bt()
    m:Unload()
end)
bW:AddLabel("Menu key"):AddKeyPicker("MenuKeybind", {
    Default = "Insert", NoUI = true, Text = "Menu key",
})
m.ToggleKeybind = Options.MenuKeybind

n:SetLibrary(m)
o:SetLibrary(m)
o:IgnoreThemeSettings()
o:SetIgnoreIndexes({ "MenuKeybind" })
n:SetFolder("RivalsNameHub")
o:SetFolder("RivalsNameHub/config")
o:BuildConfigSection(bz.Settings)
n:ApplyToTab(bz.Settings)
task.defer(function() o:LoadAutoloadConfig() end)

m:OnUnload(function()
    aQ(); aH(); bh()
    a7(); a2(); bt()
end)







do
    local bX = s:FindFirstChild("Remotes")
    local bY = { targetPosition = nil, active = false }

    if hookmetamethod and bX then
        local bZ
        bZ = hookmetamethod(game, "__namecall", function(b_, ...)
            local b0 = getnamecallmethod()
            if b0 == "FireServer" and b_.Name and b_:IsDescendantOf(bX) then
                local b1 = b_.Name
                if b1 == "ReplicateFromServer" or b1 == "Shoot" or b1 == "Fire" then
                    local b2 = { ... }
                    if Toggles.exploits_no_spread and Toggles.exploits_no_spread.Value then
                        pcall(function()
                            for b3, b4 in ipairs(b2) do
                                if type(b4) == "table" then
                                    if b4._ProjectileEffect then
                                        b4._ProjectileEffect.Spread      = Vector3.zero
                                        b4._ProjectileEffect.SpreadAngle = 0
                                    end
                                    if b4.Spread      then b4.Spread      = Vector3.zero end
                                    if b4.SpreadAngle then b4.SpreadAngle = 0 end
                                end
                            end
                        end)
                    end
                    if Toggles.silent_manipulation and Toggles.silent_manipulation.Value and bY.targetPosition then
                        pcall(function()
                            for b3, b4 in ipairs(b2) do
                                if type(b4) == "table" then
                                    if b4.Direction then
                                        local b5 = workspace.CurrentCamera
                                        b4.Direction = (bY.targetPosition - b5.CFrame.Position).Unit
                                    end
                                    if b4.Origin then
                                        b4.Origin = workspace.CurrentCamera.CFrame.Position
                                    end
                                end
                            end
                        end)
                    end
                end
            end
            return bZ(b_, ...)
        end)
    end

    if Toggles.silent_manipulation then
        Toggles.silent_manipulation:OnChanged(function()
            bY.active = Toggles.silent_manipulation.Value
        end)
    end
end

task.defer(aS)
task.defer(bj)
task.defer(a3)
task.defer(a6)

m:Notify("NameHub Rivals " .. a .. " loaded.", 4)
end) 
if not aa then
    warn("[NameHub-Rivals] Init failed:", ab)
end
end) 
