local obsidian = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local repo = "https://raw.githubusercontent.com/Lizardspikes/Scripts/refs/heads/main/violent-district/"

local Library = loadstring(game:HttpGet(obsidian .. "Library.lua"))()
local Options = Library.Options

local Window = Library:CreateWindow({
    Title = "Staff Panel",
    Footer = "v1.0",
})

local Tabs = {
    Visuals  = Window:AddTab("Visuals"),
    Game     = Window:AddTab("Game"),
    Settings = Window:AddTab("Settings"),
}

loadstring(game:HttpGet(repo .. "modules/ESP.lua"))(Library, Tabs)
loadstring(game:HttpGet(repo .. "modules/Game.lua"))(Library, Tabs)
loadstring(game:HttpGet(repo .. "modules/Settings.lua"))(Library, Tabs)

Library.ToggleKeybind = Options.MenuKeybind
