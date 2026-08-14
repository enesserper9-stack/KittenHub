-- KittenHub example / visual test

local KittenHub = loadstring(game:HttpGet("YOUR_RAW_KITTENHUB_URL_HERE"))()

local Window = KittenHub:CreateWindow({
	Title = "KittenHub",
	Icon = "rbxassetid://89700767026016",
	Size = Vector2.new(1248, 687),
	PageTitle = "Home",
	ToggleKey = Enum.KeyCode.RightShift,
})

local Overview = Window:AddTab({ Name = "Overview", Icon = "◇" })
local NewTab = Window:AddTab({ Name = "New Tab", Icon = "+" })
local Players = Window:AddTab({ Name = "Players", Icon = "○" })
local Settings = Window:AddTab({ Name = "Settings", Icon = "⚙" })

local General = Overview:AddSection("General")
General:AddLabel({
	Text = "Welcome to KittenHub",
	Description = "A clean monochrome Roblox UI library.",
})
General:AddButton({
	Text = "Notification",
	Description = "Show a small KittenHub notification.",
	ButtonText = "Show",
	Callback = function()
		Window:Notify({
			Title = "KittenHub",
			Content = "The first UI preview is working.",
			Duration = 4,
		})
	end,
})

local Controls = Overview:AddSection("Example Controls")
Controls:AddToggle({
	Text = "Example Toggle",
	Description = "A black and white switch control.",
	Default = true,
	Flag = "ExampleToggle",
	Callback = function(value)
		print("Toggle:", value)
	end,
})
Controls:AddSlider({
	Text = "Example Slider",
	Min = 0,
	Max = 100,
	Default = 42,
	Increment = 1,
	Suffix = "%",
	Flag = "ExampleSlider",
	Callback = function(value)
		print("Slider:", value)
	end,
})
Controls:AddDropdown({
	Text = "Example Dropdown",
	Values = { "Option One", "Option Two", "Option Three" },
	Default = "Option One",
	Flag = "ExampleDropdown",
	Callback = function(value)
		print("Dropdown:", value)
	end,
})

local Inputs = NewTab:AddSection("Inputs")
Inputs:AddTextbox({
	Text = "Text Input",
	Placeholder = "Type something...",
	Flag = "ExampleText",
	Callback = function(value)
		print("Textbox:", value)
	end,
})
Inputs:AddKeybind({
	Text = "Example Keybind",
	Default = Enum.KeyCode.F,
	Flag = "ExampleKeybind",
	Callback = function()
		print("Keybind pressed")
	end,
})

local PlayerSection = Players:AddSection("Player List")
PlayerSection:AddLabel({
	Text = "No player selected",
	Description = "This tab is temporary and will be redesigned later.",
})

local Interface = Settings:AddSection("Interface")
Interface:AddLabel({ Text = "Toggle UI: RightShift" })
Interface:AddButton({
	Text = "Unload KittenHub",
	ButtonText = "Unload",
	Callback = function()
		Window:Destroy()
	end,
})

Window:Notify({
	Title = "KittenHub",
	Content = "Loaded successfully. Press RightShift to hide the UI.",
	Duration = 5,
})
