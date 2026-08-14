--!strict
-- KittenHub UI Library
-- Monochrome Roblox UI inspired by Project Real's visual language.

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local KittenHub = {}
KittenHub.__index = KittenHub
KittenHub.Version = "0.2.0"
KittenHub.AssetId = "rbxassetid://89700767026016"
KittenHub.SpriteSheetId = "rbxassetid://75770413731434"

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
	Background = Color3.fromRGB(10, 10, 11),
	Surface = Color3.fromRGB(16, 16, 18),
	SurfaceHover = Color3.fromRGB(23, 23, 26),
	Selected = Color3.fromRGB(29, 29, 32),
	Border = Color3.fromRGB(42, 42, 46),
	Divider = Color3.fromRGB(31, 31, 34),
	Text = Color3.fromRGB(244, 244, 245),
	MutedText = Color3.fromRGB(161, 161, 170),
	FaintText = Color3.fromRGB(113, 113, 122),
	Accent = Color3.fromRGB(255, 255, 255),
	AccentSoft = Color3.fromRGB(222, 222, 226),
	Track = Color3.fromRGB(61, 61, 65),
	Shadow = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	Fonts = Fonts,
}

-- Rectangles for assets/kitten-sprites.png (1254x1254).
local SpriteRects = {
	Logo = { Offset = Vector2.new(40, 251), Size = Vector2.new(378, 333) },
	Paw = { Offset = Vector2.new(418, 288), Size = Vector2.new(418, 274) },
	Heart = { Offset = Vector2.new(917, 283), Size = Vector2.new(278, 260) },
	Sleeping = { Offset = Vector2.new(28, 712), Size = Vector2.new(390, 259) },
	Peek = { Offset = Vector2.new(418, 732), Size = Vector2.new(418, 245) },
	Curled = { Offset = Vector2.new(836, 706), Size = Vector2.new(373, 275) },
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
		return create("ImageLabel", properties) :: ImageLabel
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
	local rect = SpriteRects[role]
	if assets.SpriteSheet and assets.SpriteSheet ~= "" and rect then
		properties.ImageRectOffset = rect.Offset
		properties.ImageRectSize = rect.Size
		return imageOrGlyph(parent, properties, assets.SpriteSheet, glyph)
	end
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
	assets.SpriteSheet = assets.SpriteSheet or KittenHub.SpriteSheetId
	assets.Logo = assets.Logo or options.Icon or KittenHub.AssetId
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
		Size = UDim2.new(1, 0, 0, 76),
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
		Size = UDim2.fromOffset(306, 76),
		BackgroundTransparency = 1,
		Parent = topbar,
	}) :: Frame

	spriteOrGlyph(brand, {
		Name = "KittenIcon",
		Position = UDim2.fromOffset(22, 16),
		Size = UDim2.fromOffset(44, 44),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 28,
	}, assets, "Logo", "✦")

	label({
		Name = "Title",
		Position = UDim2.fromOffset(76, 0),
		Size = UDim2.new(1, -88, 1, 0),
		FontFace = Fonts.Display,
		Text = title,
		TextSize = 28,
		Parent = brand,
	})
	spriteOrGlyph(brand, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		TextSize = 21,
		ImageTransparency = 0.08,
		TextTransparency = 0.08,
	}, assets, "Paw", "✦")

	local windowControls = create("Frame", {
		Name = "WindowControls",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.fromOffset(132, 76),
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
		Position = UDim2.fromOffset(14, 142),
		Size = UDim2.new(0, 276, 1, -156),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = root,
	}, {
		corner(20),
		stroke(Theme.Border, 0.05),
		gradient(Color3.fromRGB(27, 27, 29), Color3.fromRGB(13, 14, 15), 110),
	}) :: Frame
	addSoftPattern(sidebar, assets)

	create("Frame", {
		Name = "SidebarDivider",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	local sidebarHeader = label({
		Name = "SidebarHeader",
		Position = UDim2.fromOffset(20, 18),
		Size = UDim2.new(1, -40, 0, 52),
		FontFace = Fonts.Display,
		Text = options.PageTitle or "Home",
		TextSize = 25,
		Parent = sidebar,
	})
	local _sidebarHeader = sidebarHeader

	local tabList = create("ScrollingFrame", {
		Name = "TabList",
		Position = UDim2.fromOffset(12, 82),
		Size = UDim2.new(1, -24, 1, -174),
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
		Size = UDim2.new(1, -24, 0, 66),
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		Parent = sidebar,
	}, { corner(15), stroke(Theme.Border, 0.2) }) :: Frame

	spriteOrGlyph(footer, {
		Name = "Avatar",
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(46, 46),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 26,
	}, assets, "Logo", "✦")

	label({
		Position = UDim2.fromOffset(68, 9),
		Size = UDim2.new(1, -96, 0, 24),
		FontFace = Fonts.Bold,
		Text = options.UserName or (LocalPlayer and LocalPlayer.DisplayName) or "Player",
		TextSize = 14,
		Parent = footer,
	})
	label({
		Position = UDim2.fromOffset(68, 33),
		Size = UDim2.new(1, -96, 0, 20),
		Text = options.UserStatus or "Signed in",
		TextColor3 = Theme.MutedText,
		TextSize = 12,
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
		Position = UDim2.fromOffset(306, 64),
		Size = UDim2.new(1, -320, 1, -78),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = root,
	}, {
		corner(20),
		stroke(Theme.Border, 0.05),
		gradient(Color3.fromRGB(19, 20, 20), Color3.fromRGB(10, 11, 11), 105),
	}) :: Frame
	addSoftPattern(content, assets)
	spriteOrGlyph(content, {
		Name = "CornerMascot",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -24, 0, 14),
		Size = UDim2.fromOffset(108, 66),
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
	local holder = self.Gui:FindFirstChild("Notifications") :: Frame?
	if not holder then
		holder = create("Frame", {
			Name = "Notifications",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -22, 1, -22),
			Size = UDim2.fromOffset(330, 400),
			BackgroundTransparency = 1,
			Parent = self.Gui,
		}, {
			create("UIListLayout", {
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}) :: UIListLayout,
		}) :: Frame
	end

	local notification = create("Frame", {
		Size = UDim2.fromOffset(330, 86),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Parent = holder,
	}, { corner(10), stroke(Theme.Border, 0.15), padding(13, 15, 13, 15) }) :: Frame
	label({
		Size = UDim2.new(1, 0, 0, 24),
		FontFace = Fonts.Bold,
		Text = options.Title or "KittenHub",
		TextSize = 15,
		Parent = notification,
	})
	label({
		Position = UDim2.fromOffset(0, 27),
		Size = UDim2.new(1, 0, 0, 34),
		Text = options.Content or "Notification",
		TextColor3 = Theme.MutedText,
		TextSize = 13,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = notification,
	})
	notification.Position = UDim2.fromOffset(30, 0)
	tween(notification, 0.32, { Position = UDim2.fromOffset(0, 0) })
	task.delay(options.Duration or 4, function()
		if notification.Parent then
			tween(notification, 0.25, { BackgroundTransparency = 1 })
			task.wait(0.28)
			notification:Destroy()
		end
	end)
end

function WindowMethods:AddTab(options: any)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local tabName = options.Name or "New Tab"
	local tabIcon = options.Icon or "✦"
	local order = #self.Tabs + 1

	local tabButton = button({
		Name = tabName,
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = order,
		Parent = self.TabList,
	}, {
		corner(14),
		stroke(Theme.Border, 0.35),
		gradient(Color3.fromRGB(52, 52, 55), Color3.fromRGB(32, 32, 35), 100),
	})

	local tabIconImage = if type(tabIcon) == "string" and string.find(tabIcon, "rbxasset", 1, true) == 1 then tabIcon else nil
	imageOrGlyph(tabButton, {
		Name = "Icon",
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.fromOffset(28, 56),
		TextSize = 20,
		ImageTransparency = 0.25,
		TextTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, tabIconImage, tabIconImage and "" or tostring(tabIcon))
	label({
		Name = "TabName",
		Position = UDim2.fromOffset(55, 0),
		Size = UDim2.new(1, -62, 1, 0),
		FontFace = Fonts.Semibold,
		Text = tabName,
		TextColor3 = Theme.Text,
		TextSize = 16,
		Parent = tabButton,
	})

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
	}, { padding(30, 28, 30, 28), listLayout(18) }) :: ScrollingFrame

	label({
		Name = "PageTitle",
		Size = UDim2.new(1, 0, 0, 58),
		FontFace = Fonts.Display,
		Text = tabName,
		TextSize = 32,
		LayoutOrder = 0,
		Parent = page,
	})
	local pageDivider = dashedLine(page, 0, 0, 0, 900)
	spriteOrGlyph(pageDivider, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(28, 28),
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
		Position = UDim2.fromOffset(30, 0),
		Size = UDim2.new(1, -30, 0, 32),
		FontFace = Fonts.Semibold,
		Text = name,
		TextColor3 = Theme.Text,
		TextSize = 16,
		Parent = wrapper,
	})
	spriteOrGlyph(wrapper, {
		Position = UDim2.fromOffset(0, 3),
		Size = UDim2.fromOffset(22, 22),
		TextSize = 18,
		ImageTransparency = 0.12,
		TextTransparency = 0.12,
	}, self.Window.Assets, "Paw", "✦")

	local card = create("Frame", {
		Name = "Card",
		Position = UDim2.fromOffset(0, 38),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = wrapper,
	}, {
		corner(18),
		stroke(Theme.Border, 0.05),
		padding(6, 16, 6, 16),
		listLayout(0),
		gradient(Color3.fromRGB(31, 31, 33), Color3.fromRGB(20, 21, 22), 105),
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

local function controlRow(section: any, height: number, title: string, description: string?): Frame
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
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		Parent = row,
	}, { corner(12), stroke(Theme.Border, 0.15) }) :: Frame
	spriteOrGlyph(iconTile, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(36, 36),
		TextSize = 22,
		ImageTransparency = 0,
		TextTransparency = 0,
	}, section.Window.Assets, "Curled", "✦")
	label({
		Name = "Title",
		Position = UDim2.fromOffset(66, description and 7 or 0),
		Size = UDim2.new(0.62, -66, 0, description and 28 or height),
		FontFace = Fonts.Semibold,
		Text = title,
		TextSize = 14,
		Parent = row,
	})
	if description then
		label({
			Name = "Description",
			Position = UDim2.fromOffset(66, 32),
			Size = UDim2.new(0.75, -66, 0, 23),
			Text = description,
			TextColor3 = Theme.MutedText,
			TextSize = 12,
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
	local row = controlRow(self, options.Description and 58 or 48, text, options.Description)
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
	local row = controlRow(self, options.Description and 70 or 60, text, options.Description)
	local action = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(136, 42),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Text = options.ButtonText or "Run",
		TextColor3 = Theme.Text,
		TextSize = 13,
		Parent = row,
	}, {
		corner(12),
		stroke(Theme.Border, 0.05),
		gradient(Color3.fromRGB(67, 67, 70), Color3.fromRGB(40, 40, 43), 105),
	})
	table.insert(self.Window._connections, action.MouseEnter:Connect(function()
		tween(action, 0.15, { BackgroundColor3 = Theme.SurfaceHover })
	end))
	table.insert(self.Window._connections, action.MouseLeave:Connect(function()
		tween(action, 0.15, { BackgroundColor3 = Theme.Selected })
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
	local row = controlRow(self, options.Description and 70 or 60, text, options.Description)
	local track = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(68, 34),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Parent = row,
	}, { corner(17), stroke(Theme.Border, 0.05) })
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Theme.MutedText,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(13) }) :: Frame
	local control = { Type = "Toggle", Value = options.Default == true, Instance = row }
	function control:Set(value: boolean, silent: boolean?)
		self.Value = value == true
		tween(track, 0.18, { BackgroundColor3 = self.Value and Theme.White or Theme.Selected })
		tween(knob, 0.18, {
			Position = self.Value and UDim2.new(1, -30, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
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
	local row = controlRow(self, 88, text, options.Description)
	local valueLabel = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -5, 0, 3),
		Size = UDim2.fromOffset(100, 28),
		Text = "",
		FontFace = Fonts.Mono,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})
	local bar = button({
		Position = UDim2.new(0, 66, 1, -25),
		Size = UDim2.new(1, -76, 0, 8),
		BackgroundColor3 = Theme.Track,
		BackgroundTransparency = 0,
		Parent = row,
	}, { corner(4) })
	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = bar,
	}, { corner(4) }) :: Frame
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = bar,
	}, { corner(10), stroke(Theme.Border, 0.05) }) :: Frame
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
	local row = controlRow(self, 68, text, options.Description)
	local dropdown = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(220, 44),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Text = "",
		Parent = row,
	}, {
		corner(12),
		stroke(Theme.Border, 0.05),
		gradient(Color3.fromRGB(59, 59, 62), Color3.fromRGB(38, 38, 41), 105),
	})
	local valueText = label({
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -42, 1, 0),
		Text = "Select",
		TextSize = 13,
		Parent = dropdown,
	})
	label({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		Text = "⌄",
		TextColor3 = Theme.MutedText,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = dropdown,
	})
	local list = create("Frame", {
		Name = "Options",
		Position = UDim2.new(0, 0, 1, 6),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
		Parent = dropdown,
	}, { corner(8), stroke(Theme.Border), padding(5, 5, 5, 5), listLayout(3) }) :: Frame
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
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = Theme.Selected,
				BackgroundTransparency = 1,
				Text = tostring(value),
				TextColor3 = Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = index,
				ZIndex = 21,
				Parent = list,
			}, { corner(6), padding(0, 8, 0, 8) })
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
		list.Visible = not list.Visible
	end))
	return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddTextbox(options: any)
	options = options or {}
	local text = options.Text or "Textbox"
	local row = controlRow(self, 68, text, options.Description)
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
	local row = controlRow(self, 62, text, options.Description)
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
