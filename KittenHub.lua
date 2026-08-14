--!strict
-- KittenHub UI Library
-- Monochrome Roblox UI inspired by Project Real's visual language.

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer

local KittenHub = {}
KittenHub.__index = KittenHub
KittenHub.Version = "0.5.3"
KittenHub.AssetId = "rbxassetid://102065448126548"
KittenHub.DefaultAssets = {
	Logo = "rbxassetid://102065448126548",
	Paw = "rbxassetid://131136157222328",
	Heart = "rbxassetid://107252414250704",
	Sleeping = "rbxassetid://112356892711029",
	Peek = "rbxassetid://133697879389288",
	Curled = "rbxassetid://101414414893719",
	DarkCat = "rbxassetid://118910476036241",
	DropdownCat = "rbxassetid://98425969504037",
	Sparkles = "rbxassetid://114850152769331",
	Home = "rbxassetid://118174015024924",
	Plus = "rbxassetid://98329354716868",
	Players = "rbxassetid://125376145853165",
	Settings = "rbxassetid://87200505076227",
	Bell = "rbxassetid://80479928306450",
}

-- Roblox cannot load Real's bundled Geist/JetBrains Mono WOFF2 files directly.
-- Fredoka One, Builder Sans, and Builder Mono provide a native visual equivalent.
local Fonts = {
	Display = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular),
	Body = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular),
	Medium = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
	Semibold = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
	Bold = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
	Mono = Font.new("rbxasset://fonts/families/BuilderMono.json", Enum.FontWeight.Regular),
}

local Theme = {
	Background = Color3.fromRGB(9, 10, 10),
	Surface = Color3.fromRGB(24, 25, 26),
	SurfaceHover = Color3.fromRGB(38, 39, 41),
	Selected = Color3.fromRGB(51, 52, 55),
	Border = Color3.fromRGB(76, 77, 81),
	Divider = Color3.fromRGB(57, 58, 61),
	Text = Color3.fromRGB(244, 244, 245),
	MutedText = Color3.fromRGB(188, 188, 194),
	FaintText = Color3.fromRGB(113, 113, 122),
	Accent = Color3.fromRGB(255, 255, 255),
	AccentSoft = Color3.fromRGB(222, 222, 226),
	Track = Color3.fromRGB(61, 61, 65),
	Shadow = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	Fonts = Fonts,
}

local function create(className: string, properties: {[string]: any}?, children: {Instance}?): Instance
	local object = Instance.new(className)
	for property, value in pairs(properties or {}) do
		(object :: any)[property] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = object
	end
	return object
end

local function corner(radius: number): UICorner
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }) :: UICorner
end

local function stroke(color: Color3?, transparency: number?): UIStroke
	return create("UIStroke", {
		Color = color or Theme.Border,
		Thickness = 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}) :: UIStroke
end

local function padding(top: number, right: number, bottom: number, left: number): UIPadding
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
	}) :: UIPadding
end

local function listLayout(paddingAmount: number): UIListLayout
	return create("UIListLayout", {
		Padding = UDim.new(0, paddingAmount),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
	}) :: UIListLayout
end

local function gradient(topColor: Color3, bottomColor: Color3, rotation: number?): UIGradient
	return create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, topColor),
			ColorSequenceKeypoint.new(1, bottomColor),
		}),
		Rotation = rotation or 90,
	}) :: UIGradient
end

local function dashedLine(parent: Instance, y: number, left: number, right: number, width: number)
	local holder = create("Frame", {
		Name = "DashedDivider",
		Position = UDim2.new(0, left, 0, y),
		Size = UDim2.new(1, -(left + right), 0, 1),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent,
	}) :: Frame
	local count = math.max(1, math.floor(width / 18))
	for index = 0, count - 1 do
		create("Frame", {
			Position = UDim2.new(index / count, 0, 0, 0),
			Size = UDim2.fromOffset(9, 1),
			BackgroundColor3 = Theme.FaintText,
			BackgroundTransparency = 0.38,
			BorderSizePixel = 0,
			Parent = holder,
		})
	end
	return holder
end

local function imageOrGlyph(parent: Instance, properties: {[string]: any}, imageId: string?, glyph: string): GuiObject
	if imageId and imageId ~= "" then
		local fallbackProperties = {
			Name = (properties.Name or "Image") .. "Fallback",
			AnchorPoint = properties.AnchorPoint or Vector2.zero,
			Position = properties.Position or UDim2.fromOffset(0, 0),
			Size = properties.Size or UDim2.fromScale(1, 1),
			Rotation = properties.Rotation or 0,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Fonts.Display,
			Text = glyph,
			TextColor3 = Theme.FaintText,
			TextTransparency = properties.TextTransparency or 0,
			TextSize = properties.TextSize or 18,
			TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Center,
			TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center,
			Visible = false,
			ZIndex = properties.ZIndex or 1,
			Parent = parent,
		}
		properties.TextTransparency = nil
		properties.TextSize = nil
		properties.TextXAlignment = nil
		properties.TextYAlignment = nil
		properties.TextColor3 = nil
		properties.FontFace = nil
		properties.TextWrapped = nil
		properties.Image = imageId
		properties.ScaleType = properties.ScaleType or Enum.ScaleType.Fit
		properties.BackgroundTransparency = 1
		properties.Parent = parent
		local image = create("ImageLabel", properties) :: ImageLabel
		local fallback = create("TextLabel", fallbackProperties) :: TextLabel
		local warned = false
		local function updateLoadedState()
			if not image.Parent or not fallback.Parent then
				return
			end
			image.Visible = image.IsLoaded
			fallback.Visible = not image.IsLoaded
			if not image.IsLoaded and not warned then
				warned = true
				warn("[KittenHub] Image asset could not be loaded:", imageId, "Check moderation and Asset Privacy/Open Use permissions.")
			end
		end
		image:GetPropertyChangedSignal("IsLoaded"):Connect(updateLoadedState)
		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync({ image })
			end)
			updateLoadedState()
		end)
		return image
	end
	properties.ImageTransparency = nil
	properties.ImageColor3 = nil
	properties.ScaleType = nil
	properties.BackgroundTransparency = 1
	properties.BorderSizePixel = 0
	properties.FontFace = Fonts.Display
	properties.Text = glyph
	properties.TextColor3 = Theme.FaintText
	properties.TextTransparency = properties.TextTransparency or 0
	properties.Parent = parent
	return create("TextLabel", properties) :: TextLabel
end

local function spriteOrGlyph(parent: Instance, properties: {[string]: any}, assets: {[string]: any}, role: string, glyph: string): GuiObject
	local direct = assets[role]
	if not direct and role == "Logo" then
		direct = assets.Logo or assets.RowIcon
	elseif not direct and role == "Curled" then
		direct = assets.RowIcon
	elseif not direct and role == "Sleeping" then
		direct = assets.CornerCat
	end
	return imageOrGlyph(parent, properties, direct, glyph)
end

local function addSoftPattern(parent: Instance, assets: {[string]: any})
	local marks = {
		{0.08, 0.12, 18, 0.84}, {0.23, 0.34, 26, 0.9}, {0.47, 0.16, 16, 0.92},
		{0.66, 0.58, 25, 0.89}, {0.88, 0.31, 18, 0.91}, {0.76, 0.86, 14, 0.92},
	}
	for index, mark in ipairs(marks) do
		local item = spriteOrGlyph(parent, {
			Name = "Pattern" .. index,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(mark[1], mark[2]),
			Size = UDim2.fromOffset(mark[3], mark[3]),
			ImageTransparency = mark[4],
			TextTransparency = mark[4],
			TextSize = mark[3],
			ZIndex = 1,
		}, assets, "Paw", "✦")
		item.Rotation = (index % 2 == 0) and 12 or -10
	end
end

local function label(properties: {[string]: any}): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Fonts.Body,
		TextColor3 = Theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	for key, value in pairs(properties) do
		defaults[key] = value
	end
	return create("TextLabel", defaults) :: TextLabel
end

local function button(properties: {[string]: any}, children: {Instance}?): TextButton
	local defaults = {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Fonts.Body,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 15,
	}
	for key, value in pairs(properties) do
		defaults[key] = value
	end
	return create("TextButton", defaults, children) :: TextButton
end

local function tween(instance: Instance, duration: number, properties: {[string]: any})
	TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
end

local function safeCallback(callback: ((...any) -> ())?, ...: any)
	if not callback then
		return
	end
	task.spawn(function(...)
		local ok, message = pcall(callback :: any, ...)
		if not ok then
			warn("[KittenHub] Callback error:", message)
		end
	end, ...)
end

local function getParent(): Instance
	local ok, hiddenUi = pcall(function()
		if typeof(gethui) == "function" then
			return gethui()
		end
		return nil
	end)
	if ok and hiddenUi then
		return hiddenUi
	end
	return game:GetService("CoreGui")
end

local function disconnectAll(connections: {RBXScriptConnection})
	for _, connection in ipairs(connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(connections)
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods

local TabMethods = {}
TabMethods.__index = TabMethods

local SectionMethods = {}
SectionMethods.__index = SectionMethods

local function makeDraggable(window: any, handle: GuiObject, target: GuiObject)
	local dragging = false
	local dragStart = Vector2.zero
	local startPosition = target.Position
	local shadowStart = window._shadow and window._shadow.Position or nil

	table.insert(window._connections, handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPosition = target.Position
			shadowStart = window._shadow and window._shadow.Position or nil
		end
	end))

	table.insert(window._connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end))

	table.insert(window._connections, UserInputService.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
		if window._shadow and shadowStart then
			window._shadow.Position = UDim2.new(
				shadowStart.X.Scale,
				shadowStart.X.Offset + delta.X,
				shadowStart.Y.Scale,
				shadowStart.Y.Offset + delta.Y
			)
		end
	end))
end

local function updateResponsiveScale(window: any)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local usableWidth = math.max(viewport.X - 40, 320)
	local usableHeight = math.max(viewport.Y - 40, 240)
	-- 1280x760 is the design canvas; UIScale preserves the composition on smaller viewports.
	local scale = math.min(window._designScale, usableWidth / window._baseSize.X, usableHeight / window._baseSize.Y)
	window._uiScale.Scale = math.clamp(scale, 0.48, 1)
	if window._shadow then
		window._shadow.Size = UDim2.fromOffset((window._baseSize.X + 18) * scale, (window._baseSize.Y + 18) * scale)
	end
end

function KittenHub:CreateWindow(options: {[string]: any}?)
	options = options or {}
	local baseSize = options.Size or Vector2.new(1280, 760)
	local designScale = options.Scale or 0.78
	local title = options.Title or "KittenHub"
	local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
	local assets = options.Assets or {}
	assets.Logo = assets.Logo or options.Icon or KittenHub.DefaultAssets.Logo
	assets.Paw = assets.Paw or KittenHub.DefaultAssets.Paw
	assets.Heart = assets.Heart or KittenHub.DefaultAssets.Heart
	assets.Sleeping = assets.Sleeping or KittenHub.DefaultAssets.Sleeping
	assets.Peek = assets.Peek or KittenHub.DefaultAssets.Peek
	assets.Curled = assets.Curled or KittenHub.DefaultAssets.Curled
	assets.DarkCat = assets.DarkCat or KittenHub.DefaultAssets.DarkCat
	assets.DropdownCat = assets.DropdownCat or KittenHub.DefaultAssets.DropdownCat
	assets.Sparkles = assets.Sparkles or KittenHub.DefaultAssets.Sparkles
	assets.Home = assets.Home or KittenHub.DefaultAssets.Home
	assets.Plus = assets.Plus or KittenHub.DefaultAssets.Plus
	assets.Players = assets.Players or KittenHub.DefaultAssets.Players
	assets.Settings = assets.Settings or KittenHub.DefaultAssets.Settings
	assets.Bell = assets.Bell or KittenHub.DefaultAssets.Bell
	assets.RowIcon = assets.RowIcon or assets.Logo

	local existing = getParent():FindFirstChild("KittenHubUI")
	if existing then
		existing:Destroy()
	end

	local screenGui = create("ScreenGui", {
		Name = "KittenHubUI",
		DisplayOrder = 999,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = getParent(),
	}) :: ScreenGui

	local shadow = create("Frame", {
		Name = "WindowShadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 8),
		Size = UDim2.fromOffset(baseSize.X + 18, baseSize.Y + 18),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.48,
		BorderSizePixel = 0,
		Parent = screenGui,
	}, { corner(24) }) :: Frame

	local root = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(baseSize.X, baseSize.Y),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui,
	}, {
		corner(18),
		stroke(Theme.Border, 0.1),
		gradient(Color3.fromRGB(12, 13, 13), Color3.fromRGB(7, 8, 8), 115),
	}) :: Frame
	addSoftPattern(root, assets)

	local uiScale = create("UIScale", { Scale = 1, Parent = root }) :: UIScale

	local topbar = create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 94),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = root,
	}) :: Frame

	create("Frame", {
		Name = "TopDivider",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 306, 1, 0),
		Size = UDim2.new(1, -320, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = topbar,
	})

	local brand = create("Frame", {
		Name = "Brand",
		Size = UDim2.fromOffset(306, 94),
		BackgroundTransparency = 1,
		Parent = topbar,
	}) :: Frame

	spriteOrGlyph(brand, {
		Name = "KittenIcon",
		Position = UDim2.fromOffset(24, 22),
		Size = UDim2.fromOffset(52, 52),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 28,
	}, assets, "Logo", "✦")

	label({
		Name = "Title",
		Position = UDim2.fromOffset(86, 0),
		Size = UDim2.new(1, -98, 1, 0),
		FontFace = Fonts.Display,
		Text = title,
		TextSize = 34,
		Parent = brand,
	})
	spriteOrGlyph(brand, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(32, 32),
		TextSize = 21,
		ImageTransparency = 0.08,
		TextTransparency = 0.08,
	}, assets, "Paw", "✦")
	spriteOrGlyph(brand, {
		Name = "BrandSparkles",
		Position = UDim2.fromOffset(258, 10),
		Size = UDim2.fromOffset(36, 30),
		ImageTransparency = 0.05,
		TextTransparency = 0.05,
		TextSize = 23,
		ZIndex = 5,
	}, assets, "Sparkles", "✧")

	local windowControls = create("Frame", {
		Name = "WindowControls",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.fromOffset(132, 94),
		BackgroundTransparency = 1,
		Parent = topbar,
	}) :: Frame

	local controlsLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 2),
		Parent = windowControls,
	}) :: UIListLayout
	local _controlsLayout = controlsLayout

	local minimize = button({
		Name = "Minimize",
		Size = UDim2.fromOffset(40, 40),
		Text = "—",
		TextColor3 = Theme.MutedText,
		TextSize = 18,
		LayoutOrder = 1,
		Parent = windowControls,
	})
	local maximize = button({
		Name = "Center",
		Size = UDim2.fromOffset(40, 40),
		Text = "□",
		TextColor3 = Theme.MutedText,
		TextSize = 17,
		LayoutOrder = 2,
		Parent = windowControls,
	})
	local close = button({
		Name = "Close",
		Size = UDim2.fromOffset(40, 40),
		Text = "×",
		TextColor3 = Theme.MutedText,
		TextSize = 24,
		LayoutOrder = 3,
		Parent = windowControls,
	})

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(14, 164),
		Size = UDim2.new(0, 276, 1, -178),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = root,
	}, {
		corner(20),
		stroke(Theme.Border, 0.05),
		gradient(Color3.fromRGB(27, 27, 29), Color3.fromRGB(13, 14, 15), 110),
	}) :: Frame
	addSoftPattern(sidebar, assets)
	spriteOrGlyph(root, {
		Name = "SidebarPeek",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromOffset(152, 170),
		Size = UDim2.fromOffset(150, 88),
		TextSize = 30,
		ImageTransparency = 0,
		TextTransparency = 0,
		ZIndex = 5,
	}, assets, "Peek", "^")

	create("Frame", {
		Name = "SidebarDivider",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	local tabList = create("ScrollingFrame", {
		Name = "TabList",
		Position = UDim2.fromOffset(12, 30),
		Size = UDim2.new(1, -24, 1, -150),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Border,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	}, { listLayout(7), padding(0, 3, 0, 3) }) :: ScrollingFrame

	local footer = create("Frame", {
		Name = "Footer",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, -12),
		Size = UDim2.new(1, -24, 0, 86),
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		Parent = sidebar,
	}, { corner(17), stroke(Theme.Border, 0.12) }) :: Frame

	spriteOrGlyph(footer, {
		Name = "Avatar",
		Position = UDim2.fromOffset(12, 14),
		Size = UDim2.fromOffset(58, 58),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 26,
	}, assets, "Logo", "✦")

	label({
		Position = UDim2.fromOffset(82, 14),
		Size = UDim2.new(1, -112, 0, 28),
		FontFace = Fonts.Bold,
		Text = options.UserName or (LocalPlayer and LocalPlayer.DisplayName) or "Player",
		TextSize = 17,
		Parent = footer,
	})
	label({
		Position = UDim2.fromOffset(82, 43),
		Size = UDim2.new(1, -112, 0, 24),
		Text = options.UserStatus or "Signed in",
		TextColor3 = Theme.MutedText,
		TextSize = 14,
		Parent = footer,
	})
	label({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(12, 30),
		Text = "⋮",
		TextColor3 = Theme.FaintText,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = footer,
	})

	local content = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(306, 76),
		Size = UDim2.new(1, -320, 1, -90),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = root,
	}, {
		corner(20),
		stroke(Theme.Border, 0.05),
		gradient(Color3.fromRGB(27, 28, 29), Color3.fromRGB(11, 12, 12), 105),
	}) :: Frame
	addSoftPattern(content, assets)
	dashedLine(content, baseSize.Y - 120, 0, 0, 900)
	spriteOrGlyph(root, {
		Name = "BottomPaw",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 8, 1, 8),
		Size = UDim2.fromOffset(72, 72),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 28,
		Rotation = -18,
		ZIndex = 4,
	}, assets, "Paw", "*")
	spriteOrGlyph(content, {
		Name = "CornerMascot",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 22),
		Size = UDim2.fromOffset(142, 82),
		TextSize = 26,
		ImageTransparency = 0,
		TextTransparency = 0.18,
		ZIndex = 4,
	}, assets, "Sleeping", "♡")

	local pages = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = content,
	}) :: Frame

	local window = setmetatable({
		Gui = screenGui,
		Root = root,
		_shadow = shadow,
		Sidebar = sidebar,
		TabList = tabList,
		Pages = pages,
		Theme = Theme,
		Assets = assets,
		Tabs = {},
		Flags = {},
		_connections = {},
		_baseSize = baseSize,
		_designScale = math.clamp(designScale, 0.48, 1),
		_uiScale = uiScale,
		_selectedTab = nil,
		_visible = true,
		_minimized = false,
		_destroyed = false,
	}, WindowMethods)

	makeDraggable(window, topbar, root)
	updateResponsiveScale(window)

	if workspace.CurrentCamera then
		table.insert(window._connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			updateResponsiveScale(window)
		end))
	end

	table.insert(window._connections, UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			window:Toggle()
		end
	end))

	table.insert(window._connections, minimize.MouseButton1Click:Connect(function()
		window._minimized = not window._minimized
		if window._minimized then
			tween(root, 0.25, { Size = UDim2.fromOffset(baseSize.X, 76) })
			shadow.Visible = false
		else
			tween(root, 0.25, { Size = UDim2.fromOffset(baseSize.X, baseSize.Y) })
			shadow.Visible = true
		end
	end))

	table.insert(window._connections, maximize.MouseButton1Click:Connect(function()
		root.Position = UDim2.fromScale(0.5, 0.5)
		shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
		updateResponsiveScale(window)
	end))

	table.insert(window._connections, close.MouseButton1Click:Connect(function()
		window:Destroy()
	end))

	for _, control in ipairs({ minimize, maximize, close }) do
		table.insert(window._connections, control.MouseEnter:Connect(function()
			control.TextColor3 = Theme.Text
		end))
		table.insert(window._connections, control.MouseLeave:Connect(function()
			control.TextColor3 = Theme.MutedText
		end))
	end

	return window
end

function WindowMethods:Toggle(force: boolean?)
	if self._destroyed then
		return
	end
	if force == nil then
		self._visible = not self._visible
	else
		self._visible = force
	end
	self.Gui.Enabled = self._visible
end

function WindowMethods:Notify(options: {[string]: any}?)
	if self._destroyed then
		return
	end
	options = options or {}
	local previousOverlay = self.Gui:FindFirstChild("NotificationOverlay")
	if previousOverlay then
		previousOverlay:Destroy()
	end

	local holder = self.Gui:FindFirstChild("Notifications") :: Frame?
	if not holder then
		holder = create("Frame", {
			Name = "Notifications",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -22, 1, -22),
			Size = UDim2.fromOffset(330, 400),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 50,
			Parent = self.Gui,
		}, {
			create("UIListLayout", {
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = UDim.new(0, 9),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}) :: UIListLayout,
		}) :: Frame
	end

	local slot = create("Frame", {
		Name = "NotificationSlot",
		Size = UDim2.fromOffset(330, 86),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 51,
		Parent = holder,
	}) :: Frame
	local notification = create("Frame", {
		Name = "Notification",
		Position = UDim2.fromOffset(38, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 52,
		Parent = slot,
	}, {
		corner(14),
		stroke(Theme.Border, 0.04),
		gradient(Color3.fromRGB(48, 49, 51), Color3.fromRGB(25, 26, 27), 105),
	}) :: Frame
	create("Frame", {
		Name = "InnerBorder",
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 53,
		Parent = notification,
	}, { corner(11), stroke(Theme.Border, 0.58) })
	local iconTile = create("Frame", {
		Name = "IconTile",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		ZIndex = 54,
		Parent = notification,
	}, { corner(12), stroke(Theme.Border, 0.2) }) :: Frame
	spriteOrGlyph(iconTile, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(38, 34),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 20,
		ZIndex = 55,
	}, self.Assets, "Logo", "✦")
	label({
		Name = "Title",
		Position = UDim2.fromOffset(72, 9),
		Size = UDim2.new(1, -158, 0, 27),
		FontFace = Fonts.Bold,
		Text = options.Title or "KittenHub",
		TextSize = 16,
		ZIndex = 55,
		Parent = notification,
	})
	label({
		Name = "Content",
		Position = UDim2.fromOffset(72, 36),
		Size = UDim2.new(1, -158, 0, 39),
		Text = options.Content or "Notification",
		TextColor3 = Theme.MutedText,
		TextSize = 12,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 55,
		Parent = notification,
	})
	spriteOrGlyph(notification, {
		Name = "DarkCat",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 5),
		Size = UDim2.fromOffset(66, 57),
		ImageTransparency = 0.18,
		TextTransparency = 0.35,
		TextSize = 24,
		ZIndex = 55,
	}, self.Assets, "DarkCat", "=^.^=")
	spriteOrGlyph(notification, {
		Name = "Sparkles",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 6),
		Size = UDim2.fromOffset(24, 19),
		ImageTransparency = 0.18,
		TextTransparency = 0.18,
		TextSize = 13,
		ZIndex = 56,
	}, self.Assets, "Sparkles", "✧")
	local dismissButton = button({
		Name = "Dismiss",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 57,
		Parent = notification,
	})

	local closing = false
	local function dismiss()
		if closing or not slot.Parent then
			return
		end
		closing = true
		tween(notification, 0.25, { Position = UDim2.fromOffset(350, 0) })
		task.delay(0.27, function()
			if slot.Parent then
				slot:Destroy()
			end
		end)
	end
	table.insert(self._connections, dismissButton.MouseButton1Click:Connect(dismiss))
	tween(notification, 0.3, { Position = UDim2.fromOffset(0, 0) })
	task.delay(options.Duration or 4, dismiss)
end

function WindowMethods:AddTab(options: any)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local tabName = options.Name or "New Tab"
	local tabIcon = options.Icon or "✦"
	local tabIconRole = options.IconRole
	local order = #self.Tabs + 1
	local tabStroke = stroke(Theme.Border, 1)

	local tabButton = button({
		Name = tabName,
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = order,
		Parent = self.TabList,
	}, {
		corner(14),
		tabStroke,
		gradient(Color3.fromRGB(52, 52, 55), Color3.fromRGB(32, 32, 35), 100),
	})

	local tabIconImage = if type(tabIcon) == "string" and string.find(tabIcon, "rbxasset", 1, true) == 1
		then tabIcon
		else (tabIconRole and self.Assets[tabIconRole] or nil)
	local hasTabIconImage = type(tabIconImage) == "string" and tabIconImage ~= ""
	imageOrGlyph(tabButton, {
		Name = "Icon",
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.fromOffset(32, 66),
		TextSize = 24,
		ImageTransparency = 0.25,
		TextTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, hasTabIconImage and tabIconImage or nil, tostring(tabIcon))
	label({
		Name = "TabName",
		Position = UDim2.fromOffset(58, 0),
		Size = UDim2.new(1, -98, 1, 0),
		FontFace = Fonts.Semibold,
		Text = tabName,
		TextColor3 = Theme.Text,
		TextSize = 19,
		Parent = tabButton,
	})
	spriteOrGlyph(tabButton, {
		Name = "TabDecoration",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		ImageTransparency = order == 1 and 0.08 or 0,
		TextTransparency = 0.2,
		TextSize = 17,
	}, self.Assets, order == 1 and "Paw" or ((self.Assets.DarkCat ~= "" and "DarkCat") or "Logo"), "*")

	local page = create("ScrollingFrame", {
		Name = tabName .. "Page",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Border,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.Pages,
	}, { padding(34, 34, 34, 34), listLayout(22) }) :: ScrollingFrame

	local pageHeader = create("Frame", {
		Name = "PageHeader",
		Size = UDim2.new(1, 0, 0, 82),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 0,
		Parent = page,
	}) :: Frame
	label({
		Name = "PageTitle",
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -220, 0, 58),
		FontFace = Fonts.Display,
		Text = tabName,
		TextSize = 40,
		Parent = pageHeader,
	})
	spriteOrGlyph(pageHeader, {
		Name = "PageTitlePaw",
		Position = UDim2.fromOffset(math.clamp((#tabName * 22) + 18, 160, 300), 11),
		Size = UDim2.fromOffset(36, 36),
		ImageTransparency = 0.08,
		TextTransparency = 0.08,
		TextSize = 24,
		ZIndex = 3,
	}, self.Assets, "Paw", "*")
	local pageDivider = dashedLine(pageHeader, 72, 0, 0, 900)
	pageDivider.LayoutOrder = 0
	spriteOrGlyph(pageDivider, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -170, 0.5, 0),
		Size = UDim2.fromOffset(48, 44),
		TextSize = 20,
		ImageTransparency = 0,
		TextTransparency = 0,
		ZIndex = 3,
	}, self.Assets, "Heart", "♥")

	local tab = setmetatable({
		Window = self,
		Name = tabName,
		Button = tabButton,
		Page = page,
		Sections = {},
		Order = order,
		Stroke = tabStroke,
	}, TabMethods)
	table.insert(self.Tabs, tab)

	table.insert(self._connections, tabButton.MouseEnter:Connect(function()
		if self._selectedTab ~= tab then
			tween(tabButton, 0.18, { BackgroundTransparency = 0.55 })
		end
	end))
	table.insert(self._connections, tabButton.MouseLeave:Connect(function()
		if self._selectedTab ~= tab then
			tween(tabButton, 0.18, { BackgroundTransparency = 1 })
		end
	end))
	table.insert(self._connections, tabButton.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end))

	if not self._selectedTab then
		self:SelectTab(tab)
	end
	return tab
end

function WindowMethods:SelectTab(tab: any)
	if self._selectedTab == tab then
		return
	end
	for _, item in ipairs(self.Tabs) do
		local selected = item == tab
		item.Page.Visible = selected
		tween(item.Button, 0.18, { BackgroundTransparency = selected and 0 or 1 })
		if item.Stroke then
			tween(item.Stroke, 0.18, { Transparency = selected and 0.08 or 1 })
		end
		local icon = item.Button:FindFirstChild("Icon")
		if icon and icon:IsA("TextLabel") then
			icon.TextColor3 = selected and Theme.Text or Theme.MutedText
		elseif icon and icon:IsA("ImageLabel") then
			icon.ImageColor3 = selected and Theme.Text or Theme.MutedText
			icon.ImageTransparency = selected and 0 or 0.25
		end
	end
	self._selectedTab = tab
end

function WindowMethods:GetFlag(flag: string)
	local control = self.Flags[flag]
	return control and control.Value or nil
end

function WindowMethods:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	disconnectAll(self._connections)
	if self.Gui then
		self.Gui:Destroy()
	end
end

function TabMethods:AddSection(options: any)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local name = options.Name or "Section"
	local order = #self.Sections + 2

	local wrapper = create("Frame", {
		Name = name,
		Size = UDim2.new(1, -2, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = self.Page,
	}) :: Frame

	label({
		Name = "SectionTitle",
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -34, 0, 38),
		FontFace = Fonts.Semibold,
		Text = name,
		TextColor3 = Theme.Text,
		TextSize = 20,
		Parent = wrapper,
	})
	spriteOrGlyph(wrapper, {
		Position = UDim2.fromOffset(0, 4),
		Size = UDim2.fromOffset(28, 28),
		TextSize = 18,
		ImageTransparency = 0.12,
		TextTransparency = 0.12,
	}, self.Window.Assets, "Paw", "✦")

	local card = create("Frame", {
		Name = "Card",
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = wrapper,
	}, {
		corner(22),
		stroke(Theme.Border, 0.05),
		padding(8, 18, 8, 18),
		listLayout(0),
		gradient(Color3.fromRGB(45, 46, 48), Color3.fromRGB(24, 25, 26), 105),
	}) :: Frame

	local section = setmetatable({
		Tab = self,
		Window = self.Window,
		Name = name,
		Wrapper = wrapper,
		Card = card,
		Controls = {},
	}, SectionMethods)
	table.insert(self.Sections, section)
	return section
end

local function addDivider(parent: Instance)
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = parent,
	})
end

local function controlRow(section: any, height: number, title: string, description: string?, iconRole: string?): Frame
	if #section.Controls > 0 then
		addDivider(section.Card)
	end
	local row = create("Frame", {
		Name = title,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = section.Card,
	}) :: Frame
	local iconTile = create("Frame", {
		Name = "IconTile",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 0),
		Size = UDim2.fromOffset(58, 58),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		Parent = row,
	}, { corner(14), stroke(Theme.Border, 0.12) }) :: Frame
	spriteOrGlyph(iconTile, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(46, 46),
		TextSize = 25,
		ImageTransparency = 0,
		TextTransparency = 0,
	}, section.Window.Assets, iconRole or "Logo", "✦")
	label({
		Name = "Title",
		Position = UDim2.fromOffset(78, description and 9 or 0),
		Size = UDim2.new(0.62, -78, 0, description and 32 or height),
		FontFace = Fonts.Semibold,
		Text = title,
		TextSize = 18,
		Parent = row,
	})
	if description then
		label({
			Name = "Description",
			Position = UDim2.fromOffset(78, 39),
			Size = UDim2.new(0.75, -78, 0, 25),
			Text = description,
			TextColor3 = Theme.MutedText,
			TextSize = 14,
			Parent = row,
		})
	end
	table.insert(section.Controls, row)
	return row
end

local function registerFlag(section: any, flag: string?, control: any)
	if flag and flag ~= "" then
		section.Window.Flags[flag] = control
	end
	return control
end

function SectionMethods:AddLabel(options: any)
	if type(options) == "string" then
		options = { Text = options }
	end
	options = options or {}
	local text = options.Text or "Label"
	local row = controlRow(self, options.Description and 68 or 56, text, options.Description, options.IconRole or "Logo")
	local control = { Type = "Label", Value = text, Instance = row }
	function control:Set(value: string)
		self.Value = value
		local title = row:FindFirstChild("Title") :: TextLabel
		title.Text = value
	end
	return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddButton(options: any)
	if type(options) == "string" then
		options = { Text = options }
	end
	options = options or {}
	local text = options.Text or "Button"
	local row = controlRow(self, options.Description and 82 or 68, text, options.Description, options.IconRole or "Bell")
	local action = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(166, 54),
		BackgroundTransparency = 1,
		Text = "",
		Parent = row,
	}, {
		corner(12),
		stroke(Theme.Border, 0.05),
	})
	local actionSurface = create("Frame", {
		Name = "Surface",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		ZIndex = action.ZIndex,
		Parent = action,
	}, {
		corner(12),
		gradient(Color3.fromRGB(82, 82, 85), Color3.fromRGB(46, 46, 49), 105),
	}) :: Frame
	create("Frame", {
		Name = "InnerBorder",
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = action.ZIndex + 1,
		Parent = action,
	}, { corner(9), stroke(Theme.Border, 0.5) })
	spriteOrGlyph(action, {
		Name = "ButtonKitten",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.fromOffset(34, 30),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 18,
		ZIndex = action.ZIndex + 2,
	}, self.Window.Assets, "Logo", "✦")
	label({
		Name = "ButtonText",
		Position = UDim2.fromOffset(58, 0),
		Size = UDim2.new(1, -70, 1, 0),
		FontFace = Fonts.Semibold,
		Text = options.ButtonText or "Run",
		TextColor3 = Theme.Text,
		TextSize = 17,
		ZIndex = action.ZIndex + 2,
		Parent = action,
	})
	table.insert(self.Window._connections, action.MouseEnter:Connect(function()
		tween(actionSurface, 0.15, { BackgroundTransparency = 0.12 })
	end))
	table.insert(self.Window._connections, action.MouseLeave:Connect(function()
		tween(actionSurface, 0.15, { BackgroundTransparency = 0 })
	end))
	table.insert(self.Window._connections, action.MouseButton1Click:Connect(function()
		safeCallback(options.Callback)
	end))
	local control = { Type = "Button", Instance = row }
	function control:Fire()
		safeCallback(options.Callback)
	end
	return control
end

function SectionMethods:AddToggle(options: any)
	options = options or {}
	local text = options.Text or "Toggle"
	local row = controlRow(self, options.Description and 82 or 68, text, options.Description, options.IconRole or "Sleeping")
	local track = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(82, 42),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Parent = row,
	}, { corner(21), stroke(Theme.Border, 0.05) })
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 0),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = Theme.MutedText,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(17) }) :: Frame
	spriteOrGlyph(knob, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(25, 25),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 15,
		ZIndex = 3,
	}, self.Window.Assets, "Paw", "✦")
	spriteOrGlyph(row, {
		Name = "ToggleSparkles",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -108, 0.5, 0),
		Size = UDim2.fromOffset(34, 28),
		ImageTransparency = 0.1,
		TextTransparency = 0.1,
		TextSize = 20,
		ZIndex = 4,
	}, self.Window.Assets, "Sparkles", "✧")
	local control = { Type = "Toggle", Value = options.Default == true, Instance = row }
	function control:Set(value: boolean, silent: boolean?)
		self.Value = value == true
		tween(track, 0.18, { BackgroundColor3 = self.Value and Theme.White or Theme.Selected })
		tween(knob, 0.18, {
			Position = self.Value and UDim2.new(1, -38, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
			BackgroundColor3 = self.Value and Theme.Black or Theme.MutedText,
		})
		if not silent then
			safeCallback(options.Callback, self.Value)
		end
	end
	function control:OnChanged(callback)
		options.Callback = callback
		return self
	end
	control:Set(control.Value, true)
	table.insert(self.Window._connections, track.MouseButton1Click:Connect(function()
		control:Set(not control.Value)
	end))
	return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddSlider(options: any)
	options = options or {}
	local text = options.Text or "Slider"
	local minimum = options.Min or 0
	local maximum = options.Max or 100
	local increment = options.Increment or 1
	local row = controlRow(self, 104, text, options.Description, options.IconRole or "Peek")
	local valueLabel = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -5, 0, 3),
		Size = UDim2.fromOffset(100, 28),
		Text = "",
		FontFace = Fonts.Mono,
		TextColor3 = Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})
	local bar = button({
		Position = UDim2.new(0, 78, 1, -29),
		Size = UDim2.new(1, -88, 0, 10),
		BackgroundColor3 = Theme.Track,
		BackgroundTransparency = 0,
		Parent = row,
	}, { corner(5) })
	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = bar,
	}, { corner(5) }) :: Frame
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(34, 28),
		BackgroundColor3 = Theme.White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = bar,
	}) :: Frame
	spriteOrGlyph(knob, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(34, 28),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 16,
		ZIndex = 4,
	}, self.Window.Assets, "Peek", "●")
	local control = { Type = "Slider", Value = options.Default or minimum, Instance = row }
	local dragging = false

	function control:Set(value: number, silent: boolean?)
		value = math.clamp(value, minimum, maximum)
		value = math.floor((value / increment) + 0.5) * increment
		self.Value = value
		local alpha = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)
		valueLabel.Text = tostring(value) .. (options.Suffix or "")
		if not silent then
			safeCallback(options.Callback, value)
		end
	end
	function control:OnChanged(callback)
		options.Callback = callback
		return self
	end
	local function updateFromInput(input)
		local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		control:Set(minimum + ((maximum - minimum) * alpha))
	end
	table.insert(self.Window._connections, bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateFromInput(input)
		end
	end))
	table.insert(self.Window._connections, UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromInput(input)
		end
	end))
	table.insert(self.Window._connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end))
	control:Set(control.Value, true)
	return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddDropdown(options: any)
	options = options or {}
	local text = options.Text or "Dropdown"
	local values = options.Values or {}
	local row = controlRow(self, 86, text, options.Description, options.IconRole or "Peek")
	local dropdown = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(268, 56),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Text = "",
		Parent = row,
	}, {
		corner(12),
		stroke(Theme.Border, 0.05),
		gradient(Color3.fromRGB(72, 72, 75), Color3.fromRGB(43, 43, 46), 105),
	})
	local valueText = label({
		Position = UDim2.fromOffset(18, 0),
		Size = UDim2.new(1, -62, 1, 0),
		FontFace = Fonts.Medium,
		Text = "Select",
		TextSize = 16,
		Parent = dropdown,
	})
	local dropdownCatRole = if self.Window.Assets.DropdownCat ~= "" then "DropdownCat" else "Peek"
	spriteOrGlyph(dropdown, {
		Name = "DropdownKitten",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 0, 4),
		Size = UDim2.fromOffset(62, 35),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 18,
		ZIndex = 8,
	}, self.Window.Assets, dropdownCatRole, "^")
	local chevron = create("Frame", {
		Name = "Chevron",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 2),
		Size = UDim2.fromOffset(18, 12),
		BackgroundTransparency = 1,
		Parent = dropdown,
	}) :: Frame
	for index, rotation in ipairs({ 45, -45 }) do
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = index == 1 and UDim2.fromOffset(5, 5) or UDim2.fromOffset(13, 5),
			Size = UDim2.fromOffset(11, 3),
			Rotation = rotation,
			BackgroundColor3 = Theme.Text,
			BorderSizePixel = 0,
			Parent = chevron,
		}, { corner(2) })
	end
	local list = create("Frame", {
		Name = "Options",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 1, 8),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 30,
		Parent = dropdown,
	}, {
		corner(12),
		stroke(Theme.Border, 0.02),
		padding(7, 7, 7, 7),
		listLayout(3),
		gradient(Color3.fromRGB(58, 59, 62), Color3.fromRGB(34, 35, 37), 105),
	}) :: Frame
	local control = { Type = "Dropdown", Value = options.Default or values[1], Values = values, Instance = row }
	function control:Set(value: any, silent: boolean?)
		if not table.find(self.Values, value) then
			return
		end
		self.Value = value
		valueText.Text = tostring(value)
		list.Visible = false
		if not silent then
			safeCallback(options.Callback, value)
		end
	end
	function control:Refresh(newValues: {any}, keepValue: boolean?)
		self.Values = newValues
		for _, child in ipairs(list:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		if not keepValue or not table.find(newValues, self.Value) then
			self.Value = newValues[1]
		end
		self:_build()
		if self.Value then
			self:Set(self.Value, true)
		end
	end
	function control:_build()
		for index, value in ipairs(self.Values) do
			local option = button({
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = Theme.Selected,
				BackgroundTransparency = 1,
				Text = tostring(value),
				TextColor3 = Theme.Text,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = index,
				ZIndex = 31,
				Parent = list,
			}, { corner(6), padding(0, 8, 0, 8) })
			table.insert(control.Window._connections, option.MouseEnter:Connect(function()
				tween(option, 0.12, { BackgroundTransparency = 0.2 })
			end))
			table.insert(control.Window._connections, option.MouseLeave:Connect(function()
				tween(option, 0.12, { BackgroundTransparency = 1 })
			end))
			table.insert(control.Window._connections, option.MouseButton1Click:Connect(function()
				control:Set(value)
			end))
		end
	end
	control.Window = self.Window
	control:_build()
	if control.Value then
		control:Set(control.Value, true)
	end
	table.insert(self.Window._connections, dropdown.MouseButton1Click:Connect(function()
		if list.Visible then
			list.Visible = false
			return
		end
		list.Visible = true
		task.defer(function()
			if not list.Parent then
				return
			end
			local pageBottom = self.Window.Pages.AbsolutePosition.Y + self.Window.Pages.AbsoluteSize.Y
			local dropdownBottom = dropdown.AbsolutePosition.Y + dropdown.AbsoluteSize.Y
			local spaceBelow = pageBottom - dropdownBottom
			if spaceBelow < list.AbsoluteSize.Y + 14 then
				list.AnchorPoint = Vector2.new(0, 1)
				list.Position = UDim2.new(0, 0, 0, -8)
			else
				list.AnchorPoint = Vector2.new(0, 0)
				list.Position = UDim2.new(0, 0, 1, 8)
			end
		end)
	end))
	return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddTextbox(options: any)
	options = options or {}
	local text = options.Text or "Textbox"
	local row = controlRow(self, 82, text, options.Description, options.IconRole or "Logo")
	local textbox = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(240, 44),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		FontFace = Fonts.Mono,
		PlaceholderText = options.Placeholder or "Type here...",
		PlaceholderColor3 = Theme.FaintText,
		Text = options.Default or "",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	}, { corner(12), stroke(Theme.Border, 0.05), padding(0, 13, 0, 13) }) :: TextBox
	local control = { Type = "Textbox", Value = textbox.Text, Instance = row }
	function control:Set(value: string, silent: boolean?)
		self.Value = tostring(value)
		textbox.Text = self.Value
		if not silent then
			safeCallback(options.Callback, self.Value)
		end
	end
	table.insert(self.Window._connections, textbox.FocusLost:Connect(function(enterPressed)
		control.Value = textbox.Text
		if not options.Finished or enterPressed then
			safeCallback(options.Callback, control.Value)
		end
	end))
	return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddKeybind(options: any)
	options = options or {}
	local text = options.Text or "Keybind"
	local row = controlRow(self, 76, text, options.Description, options.IconRole or "Logo")
	local keyButton = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(96, 38),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Text = "",
		Parent = row,
	}, { corner(11), stroke(Theme.Border, 0.05) })
	local keyLabel = label({
		Size = UDim2.fromScale(1, 1),
		Text = "",
		FontFace = Fonts.Mono,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = keyButton,
	})
	local control = { Type = "Keybind", Value = options.Default or Enum.KeyCode.RightShift, Instance = row, Listening = false }
	function control:Set(value: Enum.KeyCode, silent: boolean?)
		self.Value = value
		keyLabel.Text = value.Name
		if not silent then
			safeCallback(options.ChangedCallback, value)
		end
	end
	control:Set(control.Value, true)
	table.insert(self.Window._connections, keyButton.MouseButton1Click:Connect(function()
		control.Listening = true
		keyLabel.Text = "..."
	end))
	table.insert(self.Window._connections, UserInputService.InputBegan:Connect(function(input, processed)
		if control.Listening then
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				control.Listening = false
				control:Set(input.KeyCode)
			end
			return
		end
		if not processed and input.KeyCode == control.Value then
			safeCallback(options.Callback)
		end
	end))
	return registerFlag(self, options.Flag, control)
end

return KittenHub
