-- KittenHub example / visual test

local LIBRARY_URL = "https://raw.githubusercontent.com/enesserper9-stack/KittenHub/main/KittenHub.lua?v=10"
local source = game:HttpGet(LIBRARY_URL, true)
local loader, compileError = loadstring(source)

assert(loader, "KittenHub derlenemedi: " .. tostring(compileError))

local KittenHub = loader()
assert(type(KittenHub) == "table", "KittenHub yukleyicisi tablo yerine " .. typeof(KittenHub) .. " dondurdu")
assert(type(KittenHub.CreateWindow) == "function", "KittenHub.CreateWindow bulunamadi; GitHub dosyasi eski veya eksik")

local Window = KittenHub:CreateWindow({
	Title = "KittenHub",
	Icon = "rbxassetid://102065448126548",
	Size = Vector2.new(1280, 760),
	Scale = 0.78,
	PageTitle = "Home",
	ToggleKey = Enum.KeyCode.RightShift,
	Assets = {
		Logo = "rbxassetid://102065448126548",
		Paw = "rbxassetid://131136157222328",
		Heart = "rbxassetid://107252414250704",
		Sleeping = "rbxassetid://112356892711029",
		Peek = "rbxassetid://133697879389288",
		Curled = "rbxassetid://101414414893719",
		DarkCat = "rbxassetid://118910476036241",
		DropdownCat = "rbxassetid://98425969504037",
		Sparkles = "rbxassetid://114850152769331",
		-- Upload assets/icon-*.png separately, then paste each image ID below.
		Home = "rbxassetid://118174015024924",
		Plus = "rbxassetid://98329354716868",
		Players = "rbxassetid://125376145853165",
		Settings = "rbxassetid://87200505076227",
		Bell = "rbxassetid://80479928306450",
	},
})

local Overview = Window:AddTab({ Name = "Overview", Icon = "⌂", IconRole = "Home" })
local NewTab = Window:AddTab({ Name = "New Tab", Icon = "+", IconRole = "Plus" })
local Players = Window:AddTab({ Name = "Players", Icon = "●", IconRole = "Players" })
local Settings = Window:AddTab({ Name = "Settings", Icon = "⚙", IconRole = "Settings" })

local General = Overview:AddSection("General")
General:AddLabel({
	Text = "Welcome to KittenHub",
	Description = "A clean monochrome Roblox UI library.",
})
General:AddButton({
	Text = "Notification",
	Description = "Show a small KittenHub notification.",
	IconRole = "Bell",
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
