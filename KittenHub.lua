--!strict
-- KittenHub UI Library
-- Monochrome Roblox UI inspired by Project Real's visual language.

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer

local KittenHub = {}
KittenHub.Version = "0.5.5"
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
	Unload = "rbxassetid://93174476369835",
	ToggleUI = "rbxassetid://94264300792153",
}

-- Roblox cannot load Real's bundled Geist/JetBrains Mono WOFF2 files directly.
-- Fredoka One, Builder Sans, and Builder Mono provide a native visual equivalent.
local function font(family: string, weight: Enum.FontWeight, fallback: string): Font
	local ok, value = pcall(Font.new, "rbxasset://fonts/families/" .. family .. ".json", weight)
	if ok and value then
		return value
	end
	warn("[KittenHub] Font family unavailable:", family, "- falling back to", fallback)
	return Font.new("rbxasset://fonts/families/" .. fallback .. ".json", weight)
end

local Fonts = {
	Display = font("FredokaOne", Enum.FontWeight.Regular, "SourceSansPro"),
	Body = font("BuilderSans", Enum.FontWeight.Regular, "SourceSansPro"),
	Medium = font("BuilderSans", Enum.FontWeight.Medium, "SourceSansPro"),
	Semibold = font("BuilderSans", Enum.FontWeight.SemiBold, "SourceSansPro"),
	Bold = font("BuilderSans", Enum.FontWeight.Bold, "SourceSansPro"),
	Mono = font("BuilderMono", Enum.FontWeight.Regular, "RobotoMono"),
}

local MAX_NOTIFICATIONS = 5

local Theme = {
	Background = Color3.fromRGB(9, 10, 10),
	Surface = Color3.fromRGB(24, 25, 26),
	SurfaceHover = Color3.fromRGB(38, 39, 41),
	Selected = Color3.fromRGB(51, 52, 55),
	-- Borders read as a light tint at high transparency rather than a solid grey
	-- line, which is what separates an inset hairline from a drawn outline.
	Border = Color3.fromRGB(168, 170, 178),
	Divider = Color3.fromRGB(57, 58, 61),
	Text = Color3.fromRGB(244, 244, 245),
	MutedText = Color3.fromRGB(188, 188, 194),
	FaintText = Color3.fromRGB(113, 113, 122),
	Accent = Color3.fromRGB(255, 255, 255),
	AccentSoft = Color3.fromRGB(222, 222, 226),
	Track = Color3.fromRGB(61, 61, 65),
	-- Only non-monochrome value in the theme: close is the one destructive
	-- control, so its hover plate is the single place colour carries meaning.
	Danger = Color3.fromRGB(196, 72, 78),
	Shadow = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	Fonts = Fonts,
}

-- Parent is applied last so an instance is never shown with half of its
-- properties assigned (pairs() order is undefined), which caused a one frame
-- flicker and an extra layout pass for every created object.
local function create(className: string, properties: {[string]: any}?, children: {Instance}?): Instance
	local object = Instance.new(className)
	local parent: Instance? = nil
	for property, value in pairs(properties or {}) do
		if property == "Parent" then
			parent = value
		else
			(object :: any)[property] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = object
	end
	if parent then
		object.Parent = parent
	end
	return object
end

-- Engine capabilities that are not present on every client. UIStroke's border
-- positioning shipped 2025-12-04 and UIShadow 2026-06-23, so both are probed
-- once instead of assumed.
local Supports = {
	InnerStroke = (function(): boolean
		local ok = pcall(function()
			local probe = Instance.new("UIStroke")
			probe.BorderStrokePosition = Enum.BorderStrokePosition.Inner
			probe:Destroy()
		end)
		return ok
	end)(),
	Shadow = (function(): boolean
		local ok = pcall(function()
			Instance.new("UIShadow"):Destroy()
		end)
		return ok
	end)(),
}

local function corner(radius: number): UICorner
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }) :: UICorner
end

-- Native drop shadow. Returns nil on clients without UIShadow so callers can
-- fall back. Roblox recommends staying under 100 shadows on screen.
local function dropShadow(parent: GuiObject, blur: number, spread: number, transparency: number, offsetY: number): Instance?
	if not Supports.Shadow then
		return nil
	end
	return create("UIShadow", {
		BlurRadius = UDim.new(0, blur),
		Spread = UDim2.fromOffset(spread, spread),
		Offset = UDim2.fromOffset(0, offsetY),
		Color = Theme.Shadow,
		Transparency = transparency,
		Parent = parent,
	})
end

-- `lit` gives the stroke a top-to-bottom transparency ramp so the border catches
-- light along the upper edge and fades out at the bottom. UIStroke only shows a
-- child UIGradient's colour when its own Color is white, hence the swap.
local function stroke(color: Color3?, transparency: number?, lit: boolean?): UIStroke
	local base = color or Theme.Border
	local alpha = transparency or 0
	local instance = create("UIStroke", {
		Color = lit and Theme.White or base,
		Thickness = 1,
		Transparency = lit and 0 or alpha,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}) :: UIStroke

	-- Default BorderStrokePosition is Outer, which draws the hairline outside the
	-- rounded shape and reads as a hard outline instead of an inset edge.
	if Supports.InnerStroke then
		instance.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	end

	if lit then
		create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(base, base),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, alpha),
				NumberSequenceKeypoint.new(0.55, math.clamp(alpha + 0.18, 0, 1)),
				NumberSequenceKeypoint.new(1, math.clamp(alpha + 0.3, 0, 1)),
			}),
			Parent = instance,
		})
	end

	return instance
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

local function dashedLine(parent: Instance, y: number, left: number, right: number, fallbackWidth: number)
	local holder = create("Frame", {
		Name = "DashedDivider",
		Position = UDim2.new(0, left, 0, y),
		Size = UDim2.new(1, -(left + right), 0, 1),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = parent,
	}) :: Frame

	-- Dash count follows the real rendered width instead of a hardcoded 900px,
	-- and is only rebuilt when the count actually changes.
	local currentCount = -1
	local function rebuild()
		local width = holder.AbsoluteSize.X
		if width <= 0 then
			width = fallbackWidth
		end
		local count = math.max(1, math.floor(width / 18))
		if count == currentCount then
			return
		end
		currentCount = count
		for _, child in ipairs(holder:GetChildren()) do
			if child.Name == "Dash" then
				child:Destroy()
			end
		end
		for index = 0, count - 1 do
			create("Frame", {
				Name = "Dash",
				Position = UDim2.new(index / count, 0, 0, 0),
				Size = UDim2.fromOffset(9, 1),
				BackgroundColor3 = Theme.FaintText,
				BackgroundTransparency = 0.38,
				BorderSizePixel = 0,
				Parent = holder,
			})
		end
	end

	holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(rebuild)
	rebuild()
	return holder
end

-- Roblox has no dashed UIStroke, so the panel outlines from the reference are
-- drawn as individual dash segments along each edge, skipping the rounded
-- corners. Segments are rebuilt only when the panel size actually changes.
local function dashedBorder(frame: GuiObject, radius: number, transparency: number?, color: Color3?)
	local holder = create("Frame", {
		Name = "DashedBorder",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = frame,
	}) :: Frame

	local dashLength, gap, thickness = 7, 6, 1
	local dashColor = color or Theme.Border
	local alpha = transparency or 0.35
	local lastWidth, lastHeight = -1, -1

	local function dash(position: UDim2, size: UDim2)
		create("Frame", {
			Name = "Dash",
			Position = position,
			Size = size,
			BackgroundColor3 = dashColor,
			BackgroundTransparency = alpha,
			BorderSizePixel = 0,
			Parent = holder,
		})
	end

	local function rebuild()
		local size = holder.AbsoluteSize
		local width, height = math.floor(size.X), math.floor(size.Y)
		if width <= 0 or height <= 0 or (width == lastWidth and height == lastHeight) then
			return
		end
		lastWidth, lastHeight = width, height
		holder:ClearAllChildren()

		local step = dashLength + gap
		local horizontalSpan = math.max(width - (radius * 2), 0)
		local verticalSpan = math.max(height - (radius * 2), 0)
		local horizontalCount = math.max(1, math.floor((horizontalSpan + gap) / step))
		local verticalCount = math.max(1, math.floor((verticalSpan + gap) / step))
		local horizontalPad = (horizontalSpan - ((horizontalCount * step) - gap)) / 2
		local verticalPad = (verticalSpan - ((verticalCount * step) - gap)) / 2

		for index = 0, horizontalCount - 1 do
			local x = radius + horizontalPad + (index * step)
			dash(UDim2.fromOffset(x, 0), UDim2.fromOffset(dashLength, thickness))
			dash(UDim2.new(0, x, 1, -thickness), UDim2.fromOffset(dashLength, thickness))
		end
		for index = 0, verticalCount - 1 do
			local y = radius + verticalPad + (index * step)
			dash(UDim2.fromOffset(0, y), UDim2.fromOffset(thickness, dashLength))
			dash(UDim2.new(1, -thickness, 0, y), UDim2.fromOffset(thickness, dashLength))
		end
	end

	holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(rebuild)
	task.defer(rebuild)
	return holder
end

-- One PreloadAsync per icon opened ~60 separate requests, and ContentProvider
-- starved the ones queued last: the final tab's rows never resolved. Everything
-- created in the same frame is fetched as a single batched request instead.
local preloadQueue: {Instance} = {}
local preloadRunning = false
-- One line per failing asset instead of one per element that references it.
local warnedAssets: {[string]: boolean} = {}

local preloadCallbacks: {() -> ()} = {}

-- PreloadAsync only returns once every asset in the batch has settled, so its
-- completion is the reliable signal for "this image is done". ImageLabel.IsLoaded
-- does not dependably raise a property changed event, which left glyph fallbacks
-- drawn on top of images that had in fact arrived.
local function queuePreload(instance: Instance, onSettled: () -> ())
	table.insert(preloadQueue, instance)
	table.insert(preloadCallbacks, onSettled)
	if preloadRunning then
		return
	end
	preloadRunning = true
	task.defer(function()
		while #preloadQueue > 0 do
			local batch = preloadQueue
			local callbacks = preloadCallbacks
			preloadQueue = {}
			preloadCallbacks = {}
			pcall(function()
				ContentProvider:PreloadAsync(batch)
			end)
			for _, callback in ipairs(callbacks) do
				pcall(callback)
			end
		end
		preloadRunning = false
	end)
end

local function imageOrGlyph(parent: Instance, sourceProperties: {[string]: any}, imageId: string?, glyph: string): GuiObject
	-- Work on a copy: the branches below strip keys, and mutating the caller's
	-- table breaks any table that is reused for a second element.
	local properties: {[string]: any} = {}
	for key, value in pairs(sourceProperties) do
		properties[key] = value
	end

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

		-- The ImageLabel is never hidden. Roblox only downloads an image once the
		-- label actually renders, so setting Visible = false while IsLoaded was
		-- still false deadlocked it: invisible, therefore never fetched,
		-- therefore never loaded. An unloaded label simply draws nothing, so
		-- toggling the glyph behind it is enough.
		-- The fallback starts hidden and is only revealed once the fetch has
		-- settled without producing an image, so a loaded icon never shows a glyph
		-- stacked on top of it and a pending icon does not flash one.
		local function updateLoadedState()
			if not fallback.Parent then
				return
			end
			fallback.Visible = not image.IsLoaded
		end
		image:GetPropertyChangedSignal("IsLoaded"):Connect(updateLoadedState)
		queuePreload(image, updateLoadedState)

		task.delay(10, function()
			if image.Parent and not image.IsLoaded and not warnedAssets[imageId] then
				warnedAssets[imageId] = true
				warn(
					"[KittenHub] Image asset still not loaded after 10s:",
					imageId,
					"Check moderation and Asset Privacy/Open Use permissions."
				)
			end
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

local function isPressInput(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMoveInput(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

-- Every control used to open its own global UserInputService connection, so a
-- window with ten sliders ran ten callbacks per mouse move. Each window now owns
-- exactly three connections and fans them out to the registered handlers.
local function fireInputHandlers(handlers: {(InputObject, boolean) -> ()}, input: InputObject, processed: boolean)
	for _, handler in ipairs(handlers) do
		local ok, message = pcall(handler, input, processed)
		if not ok then
			warn("[KittenHub] Input handler error:", message)
		end
	end
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
		if isPressInput(input) then
			dragging = true
			dragStart = input.Position
			startPosition = target.Position
			shadowStart = window._shadow and window._shadow.Position or nil
		end
	end))

	table.insert(window._inputEnded, function(input)
		if isPressInput(input) then
			dragging = false
		end
	end)

	table.insert(window._inputChanged, function(input)
		if not dragging or not isMoveInput(input) then
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
	end)
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
	-- Overlay popups are positioned in absolute screen space, so a resize
	-- invalidates them.
	window:ClosePopups()
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
	assets.Unload = assets.Unload or KittenHub.DefaultAssets.Unload
	assets.ToggleUI = assets.ToggleUI or KittenHub.DefaultAssets.ToggleUI
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

	-- Without native UIShadow the fallback is a hard-edged rounded rectangle
	-- behind the window, which reads as a grey slab rather than a shadow. Only
	-- create it when the engine cannot draw a real one.
	local shadow: Frame? = nil
	if not Supports.Shadow then
		shadow = create("Frame", {
			Name = "WindowShadow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 8),
			Size = UDim2.fromOffset(baseSize.X + 18, baseSize.Y + 18),
			BackgroundColor3 = Theme.Shadow,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0,
			Parent = screenGui,
		}, { corner(24) }) :: Frame
	end

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
		stroke(Theme.Border, 0.74, true),
		gradient(Color3.fromRGB(12, 13, 13), Color3.fromRGB(7, 8, 8), 115),
	}) :: Frame
	dropShadow(root, 54, 6, 0.34, 14)
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

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		-- Without this the layout falls back to sorting by Name, which ordered the
		-- controls alphabetically as Center, Close, Minimize.
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = windowControls,
	})

	-- Window controls are drawn from primitives instead of "—", "□" and "×" text
	-- glyphs: font glyphs sit on different baselines, so the three never lined up
	-- and their weights did not match. Each is a hit target with a hover plate
	-- behind a hairline-thin icon.
	local minimize, maximize, close
	local controlParts: {{ Plate: Frame, Icon: Frame, Danger: boolean }} = {}
	do
		local function controlButton(name: string, order: number, danger: boolean?)
			local hit = button({
				Name = name,
				Size = UDim2.fromOffset(34, 34),
				BackgroundTransparency = 1,
				Text = "",
				LayoutOrder = order,
				Parent = windowControls,
			}, { corner(10) })

			local plate = create("Frame", {
				Name = "Plate",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = danger and Theme.Danger or Theme.SurfaceHover,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = hit,
			}, { corner(10) }) :: Frame

			local icon = create("Frame", {
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(12, 12),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = hit,
			}) :: Frame

			table.insert(controlParts, { Plate = plate, Icon = icon, Danger = danger == true })
			return hit, plate, icon
		end

		local function bar(parent: Instance, position: UDim2, size: UDim2, rotation: number?)
			return create("Frame", {
				Position = position,
				Size = size,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Rotation = rotation or 0,
				BackgroundColor3 = Theme.MutedText,
				BorderSizePixel = 0,
				Parent = parent,
			}, { corner(1) }) :: Frame
		end

		local minimizeIcon, maximizeIcon, closeIcon
		minimize, _, minimizeIcon = controlButton("Minimize", 1)
		bar(minimizeIcon, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(12, 2))

		maximize, _, maximizeIcon = controlButton("Center", 2)
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(11, 11),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = maximizeIcon,
		}, { corner(3), stroke(Theme.MutedText, 0) })

		close, _, closeIcon = controlButton("Close", 3, true)
		bar(closeIcon, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(13, 2), 45)
		bar(closeIcon, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(13, 2), -45)
	end

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(14, 164),
		Size = UDim2.new(0, 276, 1, -178),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = root,
	}, {
		corner(20),
		stroke(Theme.Border, 0.8, true),
		gradient(Color3.fromRGB(23, 24, 26), Color3.fromRGB(16, 17, 18), 110),
	}) :: Frame
	dropShadow(sidebar, 26, 0, 0.55, 8)
	dashedBorder(sidebar, 20)
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
	}, { corner(17), stroke(Theme.Border, 0.82, true) }) :: Frame
	dropShadow(footer, 16, 0, 0.6, 5)
	dashedBorder(footer, 17)


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
		stroke(Theme.Border, 0.8, true),
		gradient(Color3.fromRGB(23, 24, 26), Color3.fromRGB(15, 16, 17), 105),
	}) :: Frame
	dropShadow(content, 26, 0, 0.55, 8)
	dashedBorder(content, 20)
	addSoftPattern(content, assets)
	local contentFooterLine = dashedLine(content, baseSize.Y - 120, 0, 0, 900)
	spriteOrGlyph(contentFooterLine, {
		Name = "FooterHeart",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(26, 24),
		ImageTransparency = 0.25,
		TextTransparency = 0.25,
		TextSize = 16,
		ZIndex = 3,
	}, assets, "Heart", "♥")
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

	-- Popups live outside the window frame: Content and every page ScrollingFrame
	-- clip their descendants, so a dropdown list parented to its own row was cut
	-- off. The overlay sits directly under the ScreenGui and is unclipped.
	local overlay = create("Frame", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 40,
		Parent = screenGui,
	}) :: Frame

	local window = setmetatable({
		Gui = screenGui,
		Root = root,
		Overlay = overlay,
		_shadow = shadow,
		Sidebar = sidebar,
		TabList = tabList,
		Pages = pages,
		Theme = Theme,
		Assets = assets,
		Tabs = {},
		Flags = {},
		_connections = {},
		_inputBegan = {},
		_inputChanged = {},
		_inputEnded = {},
		_popups = {},
		_baseSize = baseSize,
		_designScale = math.clamp(designScale, 0.48, 1),
		_uiScale = uiScale,
		_selectedTab = nil,
		_visible = true,
		_minimized = false,
		_destroyed = false,
	}, WindowMethods)

	table.insert(window._connections, UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			window:Toggle()
		end
		fireInputHandlers(window._inputBegan, input, processed)
	end))
	table.insert(window._connections, UserInputService.InputChanged:Connect(function(input, processed)
		fireInputHandlers(window._inputChanged, input, processed)
	end))
	table.insert(window._connections, UserInputService.InputEnded:Connect(function(input, processed)
		fireInputHandlers(window._inputEnded, input, processed)
	end))

	makeDraggable(window, topbar, root)
	updateResponsiveScale(window)

	if workspace.CurrentCamera then
		table.insert(window._connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			updateResponsiveScale(window)
		end))
	end

	-- Collapsing only shrank the window frame, so the sidebar, the content panel
	-- and the root decorations kept rendering inside a 76px strip: the page title
	-- bled through the top bar and the bottom-right paw jumped up into it.
	-- Everything below the top bar is hidden for the duration instead.
	local collapsibles: {GuiObject} = { sidebar, content }
	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("GuiObject") and child ~= topbar and child ~= sidebar and child ~= content then
			table.insert(collapsibles, child)
		end
	end

	local collapseToken = 0
	table.insert(window._connections, minimize.MouseButton1Click:Connect(function()
		window:ClosePopups()
		window._minimized = not window._minimized
		local minimized = window._minimized
		collapseToken += 1
		local token = collapseToken

		if minimized then
			for _, element in ipairs(collapsibles) do
				element.Visible = false
			end
		end
		tween(root, 0.25, {
			Size = UDim2.fromOffset(baseSize.X, minimized and 76 or baseSize.Y),
		})
		if not minimized then
			-- Wait for the frame to be tall enough again before revealing, so the
			-- panels do not pop in against a clipped window.
			task.delay(0.18, function()
				if token ~= collapseToken or window._destroyed then
					return
				end
				for _, element in ipairs(collapsibles) do
					element.Visible = true
				end
			end)
		end
		if shadow then
			shadow.Visible = not minimized
		end
	end))

	table.insert(window._connections, maximize.MouseButton1Click:Connect(function()
		root.Position = UDim2.fromScale(0.5, 0.5)
		if shadow then
			shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
		end
		updateResponsiveScale(window)
	end))

	table.insert(window._connections, close.MouseButton1Click:Connect(function()
		window:Destroy()
	end))

	for index, control in ipairs({ minimize, maximize, close }) do
		local parts = controlParts[index]
		local function paint(hovered: boolean)
			tween(parts.Plate, 0.14, { BackgroundTransparency = hovered and 0.12 or 1 })
			local tint = hovered and (parts.Danger and Theme.White or Theme.Text) or Theme.MutedText
			for _, piece in ipairs(parts.Icon:GetChildren()) do
				if piece:IsA("Frame") then
					tween(piece, 0.14, { BackgroundColor3 = tint })
					local pieceStroke = piece:FindFirstChildOfClass("UIStroke")
					if pieceStroke then
						tween(pieceStroke, 0.14, { Color = tint })
					end
				end
			end
		end
		table.insert(window._connections, control.MouseEnter:Connect(function()
			paint(true)
		end))
		table.insert(window._connections, control.MouseLeave:Connect(function()
			paint(false)
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
	if not self._visible then
		self:ClosePopups()
	end
	self.Gui.Enabled = self._visible
end

-- Closes every overlay popup (currently dropdown lists). `except` stays open so
-- opening one dropdown can close the others in a single call.
function WindowMethods:ClosePopups(except: any?)
	for _, popup in ipairs(self._popups) do
		if popup ~= except then
			popup.Close()
		end
	end
end

function WindowMethods:Notify(options: {[string]: any}?)
	if self._destroyed then
		return
	end
	options = options or {}

	local holder = self.Gui:FindFirstChild("Notifications") :: Frame?
	if not holder then
		-- AutomaticSize instead of a fixed 400px column: the old holder let the
		-- fifth notification render past the top of its own frame.
		holder = create("Frame", {
			Name = "Notifications",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -22, 1, -22),
			Size = UDim2.fromOffset(330, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
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

	local liveSlots = {}
	for _, child in ipairs((holder :: Frame):GetChildren()) do
		if child:IsA("Frame") then
			table.insert(liveSlots, child)
		end
	end
	for index = 1, #liveSlots - (MAX_NOTIFICATIONS - 1) do
		liveSlots[index]:Destroy()
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
		stroke(Theme.Border, 0.76, true),
		gradient(Color3.fromRGB(38, 39, 42), Color3.fromRGB(24, 25, 27), 105),
	}) :: Frame
	create("Frame", {
		Name = "InnerBorder",
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 53,
		Parent = notification,
	}, { corner(11), stroke(Theme.Border, 0.9) })
	local iconTile = create("Frame", {
		Name = "IconTile",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		ZIndex = 54,
		Parent = notification,
	}, { corner(12), stroke(Theme.Border, 0.8, true) }) :: Frame
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
	-- The dismiss connection is owned by the slot, not by the window: pushing it
	-- into _connections leaked one dead entry per notification.
	local dismissConnection: RBXScriptConnection? = nil
	local function dismiss()
		if closing or not slot.Parent then
			return
		end
		closing = true
		if dismissConnection then
			dismissConnection:Disconnect()
			dismissConnection = nil
		end
		tween(notification, 0.25, { Position = UDim2.fromOffset(350, 0) })
		task.delay(0.27, function()
			if slot.Parent then
				slot:Destroy()
			end
		end)
	end
	dismissConnection = dismissButton.MouseButton1Click:Connect(dismiss)
	slot.Destroying:Connect(function()
		if dismissConnection then
			dismissConnection:Disconnect()
			dismissConnection = nil
		end
	end)
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
		gradient(Color3.fromRGB(46, 47, 50), Color3.fromRGB(31, 32, 35), 100),
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
	}, self.Assets, order == 1 and "Paw" or "DarkCat", "*")

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
	self:ClosePopups()
	for _, item in ipairs(self.Tabs) do
		local selected = item == tab
		item.Page.Visible = selected
		tween(item.Button, 0.18, { BackgroundTransparency = selected and 0 or 1 })
		if item.Stroke then
			tween(item.Stroke, 0.18, { Transparency = selected and 0.76 or 1 })
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
	self:ClosePopups()
	disconnectAll(self._connections)
	table.clear(self._inputBegan)
	table.clear(self._inputChanged)
	table.clear(self._inputEnded)
	table.clear(self._popups)
	table.clear(self.Flags)
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
		stroke(Theme.Border, 0.84, true),
		padding(8, 18, 8, 18),
		listLayout(0),
		gradient(Color3.fromRGB(31, 32, 34), Color3.fromRGB(22, 23, 25), 105),
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

local function addDivider(parent: Instance, order: number)
	create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = parent,
	})
end

local function controlRow(section: any, height: number, title: string, description: string?, iconRole: string?): Frame
	-- Rows and dividers used to share LayoutOrder 0, which left the card order up
	-- to undefined tie-breaking inside UIListLayout. Every child now gets an
	-- explicit slot: divider = even, row = odd.
	local order = (#section.Controls * 2) + 1
	if #section.Controls > 0 then
		addDivider(section.Card, order - 1)
	end
	local row = create("Frame", {
		Name = title,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = order,
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
	}, { corner(14), stroke(Theme.Border, 0.82, true) }) :: Frame
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
		stroke(Theme.Border, 0.84, true),
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
		gradient(Color3.fromRGB(62, 63, 67), Color3.fromRGB(40, 41, 44), 105),
	}) :: Frame
	create("Frame", {
		Name = "InnerBorder",
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = action.ZIndex + 1,
		Parent = action,
	}, { corner(9), stroke(Theme.Border, 0.9) })
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
	return registerFlag(self, options.Flag, control)
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
	}, { corner(21), stroke(Theme.Border, 0.8, true) })
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
		local width = bar.AbsoluteSize.X
		if width <= 0 then
			return
		end
		local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / width, 0, 1)
		control:Set(minimum + ((maximum - minimum) * alpha))
	end
	table.insert(self.Window._connections, bar.InputBegan:Connect(function(input)
		if isPressInput(input) then
			dragging = true
			updateFromInput(input)
		end
	end))
	table.insert(self.Window._inputChanged, function(input)
		if dragging and isMoveInput(input) then
			updateFromInput(input)
		end
	end)
	table.insert(self.Window._inputEnded, function(input)
		if isPressInput(input) then
			dragging = false
		end
	end)
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
		stroke(Theme.Border, 0.84, true),
		gradient(Color3.fromRGB(56, 57, 61), Color3.fromRGB(36, 37, 40), 105),
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
	-- The option list lives in the window overlay instead of inside the row: both
	-- Content and the page ScrollingFrame clip descendants, so an in-row list was
	-- cut off no matter how high its ZIndex was.
	local listScale = create("UIScale", { Scale = 1 }) :: UIScale
	local list = create("Frame", {
		Name = "Options",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(268, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 41,
		Parent = self.Window.Overlay,
	}, {
		listScale,
		corner(12),
		stroke(Theme.Border, 0.76, true),
		padding(7, 7, 7, 7),
		listLayout(3),
		gradient(Color3.fromRGB(50, 51, 55), Color3.fromRGB(32, 33, 36), 105),
	}) :: Frame
	local control = { Type = "Dropdown", Value = options.Default or values[1], Values = values, Instance = row }
	local window = self.Window
	local popup = {}
	local trackConnection: RBXScriptConnection? = nil

	local function positionList()
		local anchor = dropdown.AbsolutePosition
		local anchorSize = dropdown.AbsoluteSize
		local scale = window._uiScale.Scale
		listScale.Scale = scale
		-- Width is set pre-scale so that after UIScale it matches the button.
		list.Size = UDim2.fromOffset(anchorSize.X / scale, 0)

		local camera = workspace.CurrentCamera
		local viewportHeight = camera and camera.ViewportSize.Y or 0
		local listHeight = list.AbsoluteSize.Y
		local spaceBelow = viewportHeight - (anchor.Y + anchorSize.Y)
		if viewportHeight > 0 and spaceBelow < listHeight + (14 * scale) then
			list.AnchorPoint = Vector2.new(0, 1)
			list.Position = UDim2.fromOffset(anchor.X, anchor.Y - (8 * scale))
		else
			list.AnchorPoint = Vector2.new(0, 0)
			list.Position = UDim2.fromOffset(anchor.X, anchor.Y + anchorSize.Y + (8 * scale))
		end
	end

	function popup.Close()
		if not list.Visible then
			return
		end
		list.Visible = false
		if trackConnection then
			trackConnection:Disconnect()
			trackConnection = nil
		end
	end

	function popup.Open()
		window:ClosePopups(popup)
		list.Visible = true
		positionList()
		-- Scrolling the page or dragging the window moves the button; follow it.
		trackConnection = dropdown:GetPropertyChangedSignal("AbsolutePosition"):Connect(positionList)
		task.defer(function()
			if list.Visible then
				positionList()
			end
		end)
	end

	table.insert(window._popups, popup)

	function control:Set(value: any, silent: boolean?)
		if not table.find(self.Values, value) then
			return
		end
		self.Value = value
		valueText.Text = tostring(value)
		popup.Close()
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
				ZIndex = 42,
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
	table.insert(window._connections, dropdown.MouseButton1Click:Connect(function()
		if list.Visible then
			popup.Close()
		else
			popup.Open()
		end
	end))

	-- Clicking anywhere outside the button and the list closes the dropdown.
	table.insert(window._inputBegan, function(input)
		if not list.Visible or not isPressInput(input) then
			return
		end
		local point = Vector2.new(input.Position.X, input.Position.Y)
		local function contains(element: GuiObject): boolean
			local origin = element.AbsolutePosition
			local size = element.AbsoluteSize
			return point.X >= origin.X and point.X <= origin.X + size.X
				and point.Y >= origin.Y and point.Y <= origin.Y + size.Y
		end
		if not contains(dropdown) and not contains(list) then
			popup.Close()
		end
	end)

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
	}, { corner(12), stroke(Theme.Border, 0.84, true), padding(0, 13, 0, 13) }) :: TextBox
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
	}, { corner(11), stroke(Theme.Border, 0.8, true) })
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
		keyLabel.Text = value == Enum.KeyCode.Unknown and "None" or value.Name
		if not silent then
			safeCallback(options.ChangedCallback, value)
		end
	end
	control:Set(control.Value, true)
	table.insert(self.Window._connections, keyButton.MouseButton1Click:Connect(function()
		control.Listening = true
		keyLabel.Text = "..."
	end))
	table.insert(self.Window._inputBegan, function(input, processed)
		if control.Listening then
			-- Without the `processed` guard, typing into any textbox rebound the
			-- key. Escape cancels, Backspace clears the bind.
			if processed or input.KeyCode == Enum.KeyCode.Unknown then
				return
			end
			control.Listening = false
			if input.KeyCode == Enum.KeyCode.Escape then
				control:Set(control.Value, true)
			elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
				control:Set(Enum.KeyCode.Unknown)
			else
				control:Set(input.KeyCode)
			end
			return
		end
		if not processed and control.Value ~= Enum.KeyCode.Unknown and input.KeyCode == control.Value then
			safeCallback(options.Callback)
		end
	end)
	return registerFlag(self, options.Flag, control)
end

return KittenHub
