-- KittenHub example / visual test

local REPO = "enesserper9-stack/KittenHub"
local BRANCH = "main"

local function httpGet(url: string): string?
	local ok, body = pcall(game.HttpGet, game, url, true)
	if ok and type(body) == "string" then
		return body
	end
	return nil
end

-- Branch URLs are served from the raw.githubusercontent CDN, which can keep
-- returning the previous revision for minutes after a push (query strings like
-- ?v=... are not a reliable cache key). A commit URL is immutable, so resolving
-- the branch head first guarantees the newest file.
local function resolveLibraryUrl(): (string, string)
	-- The API URL needs its own cache buster: it is otherwise identical on every
	-- run, so the client serves the first response back and the resolver keeps
	-- pinning to a stale commit. GitHub ignores unknown query parameters.
	local body = httpGet("https://api.github.com/repos/" .. REPO .. "/commits/" .. BRANCH .. "?_=" .. tostring(os.time()))
	local commit = body and string.match(body, '"sha"%s*:%s*"(%x+)"') or nil
	if commit then
		return "https://raw.githubusercontent.com/" .. REPO .. "/" .. commit .. "/KittenHub.lua", commit
	end
	warn("[KittenHub Example] Commit cozumlenemedi, dal URL'sine dusuluyor (CDN bayat olabilir)")
	return "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/KittenHub.lua?v=" .. tostring(os.time()), BRANCH
end

local LIBRARY_URL, LIBRARY_REF = resolveLibraryUrl()
local source = httpGet(LIBRARY_URL)
assert(source, "KittenHub indirilemedi: " .. LIBRARY_URL)
local loader, compileError = loadstring(source)

assert(loader, "KittenHub derlenemedi: " .. tostring(compileError))

local KittenHub = loader()
assert(type(KittenHub) == "table", "KittenHub yukleyicisi tablo yerine " .. typeof(KittenHub) .. " dondurdu")
assert(type(KittenHub.CreateWindow) == "function", "KittenHub.CreateWindow bulunamadi; GitHub dosyasi eski veya eksik")
-- Not an assert: uploading KittenHub.lua and Example.lua as two separate commits
-- leaves a window where this file already expects the newer version and the
-- library does not have it yet. That mismatch is only worth a warning, since the
-- previous library still runs. Upload both files in one commit to avoid it.
local EXPECTED_VERSION = "0.5.7"
if KittenHub.Version ~= EXPECTED_VERSION then
	warn(
		"[KittenHub Example] Surum uyusmazligi - beklenen: "
			.. EXPECTED_VERSION
			.. ", gelen: "
			.. tostring(KittenHub.Version)
			.. " (ref: "
			.. LIBRARY_REF
			.. "). Iki dosya ayni commit'te degil; yeni ozellikler eksik olabilir."
	)
end
warn("[KittenHub Example] Loaded version:", KittenHub.Version, "ref:", LIBRARY_REF)

local Window = KittenHub:CreateWindow({
	Title = "KittenHub",
	Icon = "rbxassetid://102065448126548",
	Size = Vector2.new(1280, 760),
	Scale = 0.78,
	-- Heading for the landing page only. Later tabs use their own name, or their
	-- own PageTitle when AddTab passes one.
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
		Unload = "rbxassetid://93174476369835",
		ToggleUI = "rbxassetid://94264300792153",
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
Interface:AddLabel({ Text = "Toggle UI: RightShift", IconRole = "ToggleUI" })
Interface:AddButton({
	Text = "Unload KittenHub",
	IconRole = "Unload",
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
