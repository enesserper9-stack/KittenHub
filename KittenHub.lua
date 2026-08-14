--!strict
-- KittenHub UI Library
-- Monochrome Roblox UI inspired by Project Real's visual language.

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local KittenHub = {}
KittenHub.__index = KittenHub
KittenHub.Version = "0.1.0"
KittenHub.AssetId = "rbxassetid://89700767026016"

local Theme = {
	Background = Color3.fromRGB(9, 10, 10),
	Surface = Color3.fromRGB(15, 16, 16),
	SurfaceHover = Color3.fromRGB(22, 23, 23),
	Selected = Color3.fromRGB(27, 28, 28),
	Border = Color3.fromRGB(37, 38, 38),
	Divider = Color3.fromRGB(27, 28, 28),
	Text = Color3.fromRGB(245, 245, 247),
	MutedText = Color3.fromRGB(153, 153, 159),
	FaintText = Color3.fromRGB(105, 105, 110),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
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

local function label(properties: {[string]: any}): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
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
		Font = Enum.Font.Gotham,
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

	table.insert(window._connections, handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPosition = target.Position
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
	-- 1248x687 is the design canvas, not the final unscaled Roblox footprint.
	-- A default 0.8 scale keeps the entire window near 1248x687 on 125% DPI displays.
	local scale = math.min(window._designScale, usableWidth / window._baseSize.X, usableHeight / window._baseSize.Y)
	window._uiScale.Scale = math.clamp(scale, 0.48, 1)
end

function KittenHub:CreateWindow(options: {[string]: any}?)
	options = options or {}
	local baseSize = options.Size or Vector2.new(1248, 687)
	local designScale = options.Scale or 0.8
	local title = options.Title or "KittenHub"
	local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift

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

	local root = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(baseSize.X, baseSize.Y),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui,
	}, { corner(13), stroke(Theme.Border) }) :: Frame

	local uiScale = create("UIScale", { Scale = 1, Parent = root }) :: UIScale

	local topbar = create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = root,
	}) :: Frame

	create("Frame", {
		Name = "TopDivider",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 252, 1, 0),
		Size = UDim2.new(1, -252, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = topbar,
	})

	local brand = create("Frame", {
		Name = "Brand",
		Size = UDim2.fromOffset(252, 70),
		BackgroundTransparency = 1,
		Parent = topbar,
	}) :: Frame

	create("ImageLabel", {
		Name = "KittenIcon",
		Position = UDim2.fromOffset(16, 18),
		Size = UDim2.fromOffset(34, 34),
		BackgroundTransparency = 1,
		Image = options.Icon or KittenHub.AssetId,
		ScaleType = Enum.ScaleType.Fit,
		Parent = brand,
	})

	label({
		Name = "Title",
		Position = UDim2.fromOffset(58, 0),
		Size = UDim2.new(1, -68, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextSize = 22,
		Parent = brand,
	})

	local windowControls = create("Frame", {
		Name = "WindowControls",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.fromOffset(126, 70),
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
		Position = UDim2.fromOffset(0, 70),
		Size = UDim2.new(0, 252, 1, -70),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = root,
	}) :: Frame

	create("Frame", {
		Name = "SidebarDivider",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	local sidebarHeader = label({
		Name = "SidebarHeader",
		Position = UDim2.fromOffset(17, 15),
		Size = UDim2.new(1, -34, 0, 56),
		Font = Enum.Font.GothamBold,
		Text = options.PageTitle or "Home",
		TextSize = 27,
		Parent = sidebar,
	})
	local _sidebarHeader = sidebarHeader

	local tabList = create("ScrollingFrame", {
		Name = "TabList",
		Position = UDim2.fromOffset(8, 78),
		Size = UDim2.new(1, -16, 1, -166),
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
		Position = UDim2.new(0, 9, 1, -10),
		Size = UDim2.new(1, -18, 0, 57),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = sidebar,
	}, { corner(12) }) :: Frame

	create("ImageLabel", {
		Name = "Avatar",
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(37, 37),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Image = KittenHub.AssetId,
		ScaleType = Enum.ScaleType.Fit,
		Parent = footer,
	}, { corner(19) })

	label({
		Position = UDim2.fromOffset(57, 7),
		Size = UDim2.new(1, -84, 0, 24),
		Font = Enum.Font.GothamBold,
		Text = options.UserName or (LocalPlayer and LocalPlayer.DisplayName) or "Player",
		TextSize = 14,
		Parent = footer,
	})
	label({
		Position = UDim2.fromOffset(57, 27),
		Size = UDim2.new(1, -84, 0, 20),
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
		Position = UDim2.fromOffset(252, 70),
		Size = UDim2.new(1, -252, 1, -70),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = root,
	}) :: Frame

	local pages = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = content,
	}) :: Frame

	local window = setmetatable({
		Gui = screenGui,
		Root = root,
		Sidebar = sidebar,
		TabList = tabList,
		Pages = pages,
		Theme = Theme,
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
			tween(root, 0.25, { Size = UDim2.fromOffset(baseSize.X, 70) })
		else
			tween(root, 0.25, { Size = UDim2.fromOffset(baseSize.X, baseSize.Y) })
		end
	end))

	table.insert(window._connections, maximize.MouseButton1Click:Connect(function()
		root.Position = UDim2.fromScale(0.5, 0.5)
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
	}, { corner(11), stroke(Theme.Border), padding(13, 15, 13, 15) }) :: Frame
	label({
		Size = UDim2.new(1, 0, 0, 24),
		Font = Enum.Font.GothamBold,
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
	local tabIcon = options.Icon or "◇"
	local order = #self.Tabs + 1

	local tabButton = button({
		Name = tabName,
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = order,
		Parent = self.TabList,
	}, { corner(11) })

	label({
		Name = "Icon",
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.fromOffset(24, 48),
		Text = tabIcon,
		TextColor3 = Theme.MutedText,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = tabButton,
	})
	label({
		Name = "TabName",
		Position = UDim2.fromOffset(49, 0),
		Size = UDim2.new(1, -62, 1, 0),
		Font = Enum.Font.GothamSemibold,
		Text = tabName,
		TextColor3 = Theme.Text,
		TextSize = 15,
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
	}, { padding(24, 35, 30, 31), listLayout(14) }) :: ScrollingFrame

	label({
		Name = "PageTitle",
		Size = UDim2.new(1, 0, 0, 40),
		Font = Enum.Font.GothamBold,
		Text = tabName,
		TextSize = 24,
		LayoutOrder = 0,
		Parent = page,
	})

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
		local icon = item.Button:FindFirstChild("Icon") :: TextLabel?
		if icon then
			icon.TextColor3 = selected and Theme.Text or Theme.MutedText
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
		Size = UDim2.new(1, 0, 0, 28),
		Font = Enum.Font.GothamSemibold,
		Text = name,
		TextColor3 = Theme.MutedText,
		TextSize = 13,
		Parent = wrapper,
	})

	local card = create("Frame", {
		Name = "Card",
		Position = UDim2.fromOffset(0, 32),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = wrapper,
	}, { corner(12), stroke(Theme.Border, 0.45), padding(4, 14, 4, 14), listLayout(0) }) :: Frame

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
	label({
		Name = "Title",
		Position = UDim2.fromOffset(6, description and 6 or 0),
		Size = UDim2.new(0.62, -6, 0, description and 28 or height),
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextSize = 14,
		Parent = row,
	})
	if description then
		label({
			Name = "Description",
			Position = UDim2.fromOffset(6, 31),
			Size = UDim2.new(0.75, -6, 0, 23),
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
	local row = controlRow(self, options.Description and 62 or 52, text, options.Description)
	local action = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(104, 34),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Text = options.ButtonText or "Run",
		TextColor3 = Theme.Text,
		TextSize = 13,
		Parent = row,
	}, { corner(8), stroke(Theme.Border) })
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
	local row = controlRow(self, options.Description and 62 or 52, text, options.Description)
	local track = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(42, 23),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Parent = row,
	}, { corner(12), stroke(Theme.Border) })
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(17, 17),
		BackgroundColor3 = Theme.MutedText,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(9) }) :: Frame
	local control = { Type = "Toggle", Value = options.Default == true, Instance = row }
	function control:Set(value: boolean, silent: boolean?)
		self.Value = value == true
		tween(track, 0.18, { BackgroundColor3 = self.Value and Theme.White or Theme.Selected })
		tween(knob, 0.18, {
			Position = self.Value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
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
	local row = controlRow(self, 78, text, options.Description)
	local valueLabel = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -5, 0, 3),
		Size = UDim2.fromOffset(100, 28),
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})
	local bar = button({
		Position = UDim2.new(0, 6, 1, -24),
		Size = UDim2.new(1, -12, 0, 5),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Parent = row,
	}, { corner(3) })
	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = bar,
	}, { corner(3) }) :: Frame
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(13, 13),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = bar,
	}, { corner(7), stroke(Theme.Border) }) :: Frame
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
	local row = controlRow(self, 58, text, options.Description)
	local dropdown = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(190, 36),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Text = "",
		Parent = row,
	}, { corner(8), stroke(Theme.Border) })
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
	local row = controlRow(self, 58, text, options.Description)
	local textbox = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(220, 36),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = options.Placeholder or "Type here...",
		PlaceholderColor3 = Theme.FaintText,
		Text = options.Default or "",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	}, { corner(8), stroke(Theme.Border), padding(0, 11, 0, 11) }) :: TextBox
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
	local row = controlRow(self, 52, text, options.Description)
	local keyButton = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(82, 32),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Text = "",
		Parent = row,
	}, { corner(8), stroke(Theme.Border) })
	local keyLabel = label({
		Size = UDim2.fromScale(1, 1),
		Text = "",
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
