return function(Library, Tabs)
    local Options = Library.Options
    local Toggles = Library.Toggles

    local KillerGroupbox   = Tabs.Game:AddLeftGroupbox("Killer")
    local SurvivorGroupbox = Tabs.Game:AddRightGroupbox("Survivor")
    local MovementGroupbox = Tabs.Game:AddLeftGroupbox("Movement")
    local MiscGroupbox     = Tabs.Game:AddRightGroupbox("Misc")

    KillerGroupbox:AddToggle("ForceAttack",        { Text = "Force Attack",          Default = false })
    KillerGroupbox:AddToggle("NoHitSlowdown",      { Text = "No Slowdown After Hit", Default = false })
    KillerGroupbox:AddToggle("CancelHitAnimation", { Text = "Cancel Hit Animation",  Default = false })

    KillerGroupbox:AddSlider("KillerWalkSpeed", {
        Text     = "Walk Speed",
        Default  = 16,
        Min      = 0,
        Max      = 100,
        Rounding = 0,
    })

    KillerGroupbox:AddButton({
        Text = "Reset Walk Speed",
        Func = function()
            Options.KillerWalkSpeed:SetValue(16)
        end,
    })

    SurvivorGroupbox:AddToggle("Moonwalk",  { Text = "Moonwalk",   Default = false })
    SurvivorGroupbox:AddToggle("AutoParry", { Text = "Auto Parry", Default = false })

    SurvivorGroupbox:AddDropdown("AutoSkillCheck", {
        Text    = "Auto Skill Check",
        Values  = { "Disabled", "Legit", "Perfect" },
        Default = 1,
    })

    SurvivorGroupbox:AddSlider("SurvivorWalkSpeed", {
        Text     = "Walk Speed",
        Default  = 16,
        Min      = 0,
        Max      = 100,
        Rounding = 0,
    })

    SurvivorGroupbox:AddButton({
        Text = "Reset Walk Speed",
        Func = function()
            Options.SurvivorWalkSpeed:SetValue(16)
        end,
    })

    MovementGroupbox:AddToggle("Fly",          { Text = "Fly",           Default = false })
    MovementGroupbox:AddToggle("Noclip",       { Text = "Noclip",        Default = false })
    MovementGroupbox:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false })
    MovementGroupbox:AddToggle("AlwaysSprint", { Text = "Always Sprint", Default = false })
    MovementGroupbox:AddToggle("AntiAfk",      { Text = "Anti-AFK",      Default = false })

    MiscGroupbox:AddSlider("CameraDistance", {
        Text     = "Camera Distance",
        Default  = 12,
        Min      = 5,
        Max      = 100,
        Rounding = 0,
    })

    MiscGroupbox:AddToggle("NoFallSlow", { Text = "No Fall Slow Effect", Default = false })

    MiscGroupbox:AddButton({
        Text = "Reset Character",
        Func = function()
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
        end,
    })

    MiscGroupbox:AddButton({
        Text = "Load Infinite Yield",
        Func = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end,
    })
end