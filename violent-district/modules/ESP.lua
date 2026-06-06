return function(Library, Tabs)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Options = Library.Options
    local Toggles = Library.Toggles
    local LocalPlayer = Players.LocalPlayer

    local ActiveESPs    = {}
    local ActiveGens    = {}
    local ActiveHooks   = {}
    local ActivePallets = {}

    local EspGroupbox    = Tabs.Visuals:AddLeftGroupbox("ESP")
    local TracerGroupbox = Tabs.Visuals:AddRightGroupbox("Tracers")
    local WorldGroupbox  = Tabs.Visuals:AddRightGroupbox("World")

    EspGroupbox:AddToggle("KillerEsp", { Text = "Killer", Default = false })
        :AddColorPicker("KillerEspColor", { Default = Color3.fromRGB(255, 0, 0) })

    EspGroupbox:AddToggle("SurvivorEsp", { Text = "Survivor", Default = false })
        :AddColorPicker("SurvivorEspColor", { Default = Color3.fromRGB(0, 255, 0) })

    EspGroupbox:AddToggle("GeneratorEsp", { Text = "Generator", Default = false })
        :AddColorPicker("GeneratorEspColor", { Default = Color3.fromRGB(255, 200, 0) })

    EspGroupbox:AddToggle("HookEsp", { Text = "Hook", Default = false })
        :AddColorPicker("HookEspColor", { Default = Color3.fromRGB(255, 140, 0) })

    EspGroupbox:AddToggle("PalletEsp", { Text = "Pallet", Default = false })
        :AddColorPicker("PalletEspColor", { Default = Color3.fromRGB(0, 180, 255) })

    EspGroupbox:AddToggle("VaultEsp", { Text = "Vault", Default = false })
        :AddColorPicker("VaultEspColor", { Default = Color3.fromRGB(180, 0, 255) })

    EspGroupbox:AddToggle("GateEsp", { Text = "Exit Gate", Default = false })
        :AddColorPicker("GateEspColor", { Default = Color3.fromRGB(0, 255, 180) })

    EspGroupbox:AddToggle("ShowNames",       { Text = "Show Names",        Default = false })
    EspGroupbox:AddToggle("ShowDistances",   { Text = "Show Distances",    Default = false })
    EspGroupbox:AddToggle("ShowGenProgress", { Text = "Show Gen Progress", Default = false })

    TracerGroupbox:AddToggle("KillerTracers", { Text = "Killer Tracers", Default = false })
        :AddColorPicker("KillerTracerColor", { Default = Color3.fromRGB(255, 0, 0) })

    TracerGroupbox:AddDropdown("TracerOrigin", {
        Text    = "Tracer Origin",
        Values  = { "Bottom", "Center", "Top" },
        Default = 1,
    })

    TracerGroupbox:AddSlider("TracerMaxDistance", {
        Text     = "Max Distance",
        Default  = 1000,
        Min      = 100,
        Max      = 5000,
        Rounding = 0,
    })

    WorldGroupbox:AddToggle("Fullbright",     { Text = "Fullbright",              Default = false })
    WorldGroupbox:AddToggle("NoFog",          { Text = "No Fog",                  Default = false })
    WorldGroupbox:AddToggle("RemoveDarkness", { Text = "Remove Darkness Effects", Default = false })

    local function IsVisible(Origin, Position, Filter)
        local Camera = workspace.CurrentCamera
        local From = Origin or Camera.CFrame.Position
        local Direction = Position - From
        local RayParams = RaycastParams.new()
        RayParams.FilterDescendantsInstances = Filter
        RayParams.FilterType = Enum.RaycastFilterType.Exclude
        local Result = workspace:Raycast(From, Direction, RayParams)
        return Result == nil
    end

    local function ApplyESP(Character, Player, Color)
        local Hrp = Character:FindFirstChild("HumanoidRootPart")
        if not Hrp then return end

        local Highlight = Instance.new("Highlight")
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.FillColor = Color
        Highlight.OutlineColor = Color
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.Adornee = Character
        Highlight.Parent = Character

        local Light = Instance.new("PointLight")
        Light.Color = Color
        Light.Brightness = 5
        Light.Range = 16
        Light.Parent = Hrp

        local Billboard = Instance.new("BillboardGui")
        Billboard.AlwaysOnTop = true
        Billboard.Size = UDim2.new(0, 0, 0, 0)
        Billboard.StudsOffsetWorldSpace = Vector3.new(0, -2, 0)
        Billboard.MaxDistance = 1000
        Billboard.Adornee = Hrp
        Billboard.Parent = Character

        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0, 100, 0, 30)
        Label.Position = UDim2.new(0.5, -50, 0.5, -15)
        Label.Font = Enum.Font.GothamBold
        Label.TextColor3 = Color
        Label.TextStrokeTransparency = 0
        Label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Label.TextScaled = false
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Center
        Label.Parent = Billboard

        ActiveESPs[Player] = {
            Highlight = Highlight,
            Light = Light,
            Label = Label,
            Hrp = Hrp,
            Character = Character,
        }
    end

    local function OnPlayerAdded(Player)
        if Player == LocalPlayer then return end

        local function Check()
            local Team = Player.Team
            if not Team or not Player.Character then return end
            local IsKiller = Team.Name == "Killer"
            local IsSurvivor = Team.Name == "Survivors"
            if IsKiller and Toggles.KillerEsp.Value then
                ApplyESP(Player.Character, Player, Options.KillerEspColor.Value)
            elseif IsSurvivor and Toggles.SurvivorEsp.Value then
                ApplyESP(Player.Character, Player, Options.SurvivorEspColor.Value)
            end
        end

        Player.CharacterAdded:Connect(function()
            ActiveESPs[Player] = nil
            Check()
        end)

        Player:GetPropertyChangedSignal("Team"):Connect(Check)
        Check()
    end

    local function ApplyGenESP(Generator)
        local Body = Generator:FindFirstChild("GeneratorBody")
        if not Body then return end

        local Color = Options.GeneratorEspColor.Value

        local Highlight = Instance.new("Highlight")
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.FillColor = Color
        Highlight.OutlineColor = Color
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.Adornee = Generator
        Highlight.Parent = Generator

        local Light = Instance.new("PointLight")
        Light.Color = Color
        Light.Brightness = 5
        Light.Range = 16
        Light.Parent = Body

        local Billboard = Instance.new("BillboardGui")
        Billboard.AlwaysOnTop = true
        Billboard.Size = UDim2.new(0, 0, 0, 0)
        Billboard.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
        Billboard.MaxDistance = 1000
        Billboard.Adornee = Body
        Billboard.Parent = Generator

        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0, 120, 0, 40)
        Label.Position = UDim2.new(0.5, -60, 0.5, -20)
        Label.Font = Enum.Font.GothamBold
        Label.TextColor3 = Color
        Label.TextStrokeTransparency = 0
        Label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Label.TextScaled = false
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Center
        Label.Parent = Billboard

        ActiveGens[Generator] = { Highlight = Highlight, Light = Light, Label = Label, Body = Body }
    end

    local function ApplyHookESP(Hook)
        local Hitbox = Hook:FindFirstChild("HitBox")
        if not Hitbox then return end

        local Color = Options.HookEspColor.Value

        local Highlight = Instance.new("Highlight")
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.FillColor = Color
        Highlight.OutlineColor = Color
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.Adornee = Hook
        Highlight.Parent = Hook

        local Light = Instance.new("PointLight")
        Light.Color = Color
        Light.Brightness = 5
        Light.Range = 16
        Light.Parent = Hitbox

        local Billboard = Instance.new("BillboardGui")
        Billboard.AlwaysOnTop = true
        Billboard.Size = UDim2.new(0, 0, 0, 0)
        Billboard.MaxDistance = 1000
        Billboard.Adornee = Hitbox
        Billboard.Parent = Hook

        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0, 100, 0, 30)
        Label.Position = UDim2.new(0.5, -50, 0.5, -15)
        Label.Font = Enum.Font.GothamBold
        Label.TextColor3 = Color
        Label.TextStrokeTransparency = 0
        Label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Label.TextScaled = false
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Center
        Label.Parent = Billboard

        ActiveHooks[Hook] = { Highlight = Highlight, Light = Light, Label = Label, Hitbox = Hitbox }
    end

    local function ApplyPalletESP(Pallet)
        local PrimaryPart = Pallet:FindFirstChild("PrimaryPartPallet")
        if not PrimaryPart then return end

        local Color = Options.PalletEspColor.Value

        local Highlight = Instance.new("Highlight")
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.FillColor = Color
        Highlight.OutlineColor = Color
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.Adornee = Pallet
        Highlight.Parent = Pallet

        local Light = Instance.new("PointLight")
        Light.Color = Color
        Light.Brightness = 5
        Light.Range = 16
        Light.Parent = PrimaryPart

        local Billboard = Instance.new("BillboardGui")
        Billboard.AlwaysOnTop = true
        Billboard.Size = UDim2.new(0, 0, 0, 0)
        Billboard.MaxDistance = 1000
        Billboard.Adornee = PrimaryPart
        Billboard.Parent = Pallet

        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0, 100, 0, 30)
        Label.Position = UDim2.new(0.5, -50, 0.5, -15)
        Label.Font = Enum.Font.GothamBold
        Label.TextColor3 = Color
        Label.TextStrokeTransparency = 0
        Label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Label.TextScaled = false
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Center
        Label.Parent = Billboard

        ActivePallets[Pallet] = { Highlight = Highlight, Light = Light, Label = Label, PrimaryPart = PrimaryPart }
    end

    local function FindAllGenerators()
        local Map = workspace:WaitForChild("Map")
        for _, Child in ipairs(Map:GetChildren()) do
            if Child.Name:lower():find("generator") then
                for _, Generator in ipairs(Child:GetChildren()) do
                    if Generator.Name == "Generator" then
                        ApplyGenESP(Generator)
                    end
                end
            end
        end
    end

    local function FindAllHooks()
        local Map = workspace:WaitForChild("Map")
        for _, Desc in ipairs(Map:GetDescendants()) do
            if Desc.Name == "Hook" and Desc:FindFirstChild("HitBox") then
                ApplyHookESP(Desc)
            end
        end
    end

    local function FindAllPallets()
        local Map = workspace:WaitForChild("Map")
        for _, Desc in ipairs(Map:GetDescendants()) do
            if Desc.Name == "Palletwrong" and Desc:FindFirstChild("PrimaryPartPallet") then
                ApplyPalletESP(Desc)
            end
        end
    end

    local function ClearESP(Table)
        for Key, Esp in pairs(Table) do
            if Esp.Highlight then Esp.Highlight:Destroy() end
            if Esp.Light then Esp.Light:Destroy() end
            if Esp.Label and Esp.Label.Parent then Esp.Label.Parent:Destroy() end
            Table[Key] = nil
        end
    end

    Toggles.KillerEsp:OnChanged(function(State)
        if State then
            for _, Player in ipairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Team and Player.Team.Name == "Killer" and Player.Character then
                    ApplyESP(Player.Character, Player, Options.KillerEspColor.Value)
                end
            end
        else
            for Player, Esp in pairs(ActiveESPs) do
                if Player.Team and Player.Team.Name == "Killer" then
                    if Esp.Highlight then Esp.Highlight:Destroy() end
                    if Esp.Light then Esp.Light:Destroy() end
                    if Esp.Label and Esp.Label.Parent then Esp.Label.Parent:Destroy() end
                    ActiveESPs[Player] = nil
                end
            end
        end
    end)

    Toggles.SurvivorEsp:OnChanged(function(State)
        if State then
            for _, Player in ipairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Team and Player.Team.Name == "Survivors" and Player.Character then
                    ApplyESP(Player.Character, Player, Options.SurvivorEspColor.Value)
                end
            end
        else
            for Player, Esp in pairs(ActiveESPs) do
                if Player.Team and Player.Team.Name == "Survivors" then
                    if Esp.Highlight then Esp.Highlight:Destroy() end
                    if Esp.Light then Esp.Light:Destroy() end
                    if Esp.Label and Esp.Label.Parent then Esp.Label.Parent:Destroy() end
                    ActiveESPs[Player] = nil
                end
            end
        end
    end)

    Toggles.GeneratorEsp:OnChanged(function(State)
        if State then FindAllGenerators() else ClearESP(ActiveGens) end
    end)

    Toggles.HookEsp:OnChanged(function(State)
        if State then FindAllHooks() else ClearESP(ActiveHooks) end
    end)

    Toggles.PalletEsp:OnChanged(function(State)
        if State then FindAllPallets() else ClearESP(ActivePallets) end
    end)

    for _, Player in ipairs(Players:GetPlayers()) do
        OnPlayerAdded(Player)
    end

    Players.PlayerAdded:Connect(OnPlayerAdded)
    Players.PlayerRemoving:Connect(function(Player)
        ActiveESPs[Player] = nil
    end)

    RunService.Heartbeat:Connect(function()
        local LocalChar = LocalPlayer.Character
        local LocalHRP = LocalChar and LocalChar:FindFirstChild("HumanoidRootPart")
        if not LocalHRP then return end

        local CameraPos = workspace.CurrentCamera.CFrame.Position
        local ShowNames = Toggles.ShowNames.Value
        local ShowDistances = Toggles.ShowDistances.Value
        local ShowGenProgress = Toggles.ShowGenProgress.Value
        local MaxDistance = Options.TracerMaxDistance.Value

        for Player, Esp in pairs(ActiveESPs) do
            local Hrp = Esp.Hrp
            if not Hrp or not Hrp.Parent then
                ActiveESPs[Player] = nil
                continue
            end

            local Distance = (Hrp.Position - LocalHRP.Position).Magnitude
            if Distance > MaxDistance then
                Esp.Label.Text = ""
                continue
            end

            local Meters = math.round(Distance * 0.28)
            local NameText = ShowNames and Player.DisplayName or ""
            local DistText = ShowDistances and ("[" .. Meters .. "m]") or ""
            Esp.Label.Text = NameText .. (NameText ~= "" and DistText ~= "" and "\n" or "") .. DistText

            local Visible = IsVisible(CameraPos, Hrp.Position, { LocalChar, Hrp.Parent })
            Esp.Highlight.FillTransparency = Visible and 1 or 0.5
            Esp.Highlight.OutlineTransparency = Visible and 1 or 0
            Esp.Light.Brightness = Visible and 0 or 5
        end

        for Generator, Esp in pairs(ActiveGens) do
            if not Generator or not Generator.Parent then
                ActiveGens[Generator] = nil
                continue
            end

            local Body = Esp.Body
            if not Body or not Body.Parent then continue end

            local Distance = (Body.Position - LocalHRP.Position).Magnitude
            if Distance > MaxDistance then
                Esp.Label.Text = ""
                continue
            end

            local Meters = math.round(Distance * 0.28)
            local Progress = math.floor(Generator:GetAttribute("RepairProgress") or 0)

            if Progress >= 100 then
                Esp.Highlight:Destroy()
                Esp.Light:Destroy()
                Esp.Label.Parent:Destroy()
                ActiveGens[Generator] = nil
                continue
            end

            local ProgressText = ShowGenProgress and (" [" .. Progress .. "%]") or ""
            local DistText = ShowDistances and ("\n[" .. Meters .. "m]") or ""
            Esp.Label.Text = "Generator" .. ProgressText .. DistText

            local Visible = IsVisible(CameraPos, Body.Position, { LocalChar, Generator })
            Esp.Highlight.FillTransparency = Visible and 1 or 0.5
            Esp.Highlight.OutlineTransparency = Visible and 1 or 0
            Esp.Light.Brightness = Visible and 0 or 5
        end

        for Hook, Esp in pairs(ActiveHooks) do
            if not Hook or not Hook.Parent then
                ActiveHooks[Hook] = nil
                continue
            end

            local Hitbox = Esp.Hitbox
            if not Hitbox or not Hitbox.Parent then continue end

            local Distance = (Hitbox.Position - LocalHRP.Position).Magnitude
            if Distance > MaxDistance then
                Esp.Label.Text = ""
                continue
            end

            local Meters = math.round(Distance * 0.28)
            local DistText = ShowDistances and ("\n[" .. Meters .. "m]") or ""
            Esp.Label.Text = "Hook" .. DistText

            local Visible = IsVisible(CameraPos, Hitbox.Position, { LocalChar, Hook })
            Esp.Highlight.FillTransparency = Visible and 1 or 0.5
            Esp.Highlight.OutlineTransparency = Visible and 1 or 0
            Esp.Light.Brightness = Visible and 0 or 5
        end

        for Pallet, Esp in pairs(ActivePallets) do
            if not Pallet or not Pallet.Parent then
                ActivePallets[Pallet] = nil
                continue
            end

            local PrimaryPart = Esp.PrimaryPart
            if not PrimaryPart or not PrimaryPart.Parent then continue end

            local Distance = (PrimaryPart.Position - LocalHRP.Position).Magnitude
            if Distance > MaxDistance then
                Esp.Label.Text = ""
                continue
            end

            local Meters = math.round(Distance * 0.28)
            local DistText = ShowDistances and ("\n[" .. Meters .. "m]") or ""
            Esp.Label.Text = "Pallet" .. DistText

            local Visible = IsVisible(CameraPos, PrimaryPart.Position, { LocalChar, Pallet })
            Esp.Highlight.FillTransparency = Visible and 1 or 0.5
            Esp.Highlight.OutlineTransparency = Visible and 1 or 0
            Esp.Light.Brightness = Visible and 0 or 5
        end
    end)
end