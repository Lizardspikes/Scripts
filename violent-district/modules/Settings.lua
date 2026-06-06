return function(Library, Tabs)
    local Options = Library.Options

    local SettingsGroupbox = Tabs.Settings:AddLeftGroupbox("Settings")

    SettingsGroupbox:AddLabel("Menu Bind")
        :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu Keybind" })

    SettingsGroupbox:AddButton({
        Text = "Rejoin",
        Func = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
        end,
    })

    SettingsGroupbox:AddButton({
        Text = "Server Hop",
        Func = function()
            local Servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            for _, Server in ipairs(Servers.data) do
                if Server.id ~= game.JobId and Server.playing < Server.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Server.id, game.Players.LocalPlayer)
                    return
                end
            end
        end,
    })

    SettingsGroupbox:AddButton({
        Text = "Copy Job ID",
        Func = function()
            setclipboard(game.JobId)
        end,
    })

    SettingsGroupbox:AddButton({
        Text = "Unload",
        Func = function()
            Library:Unload()
        end,
    })

    Library.ToggleKeybind = Options.MenuKeybind
end