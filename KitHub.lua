--// Kitsune UI v2
--// Своя UI-библиотека в стиле фрукта Kitsune.
--// Поддерживает два стиля вызова:
--//   1) короткий:  Tab:AddToggle("Текст", false, function(v) end)
--//   2) таблицей (как в redz): Tab:AddToggle({Name = "Текст", Default = false, Callback = function(v) end})
--// Поэтому скрипты, написанные под redz-библиотеку, работают без переделки.
 
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
 
local Theme = {
	Bg = Color3.fromRGB(27, 26, 74),
	Panel = Color3.fromRGB(59, 47, 143),
	Dark = Color3.fromRGB(20, 18, 56),
	Cyan = Color3.fromRGB(41, 211, 255),
	LightCyan = Color3.fromRGB(127, 243, 255),
	Purple = Color3.fromRGB(106, 76, 255),
	Muted = Color3.fromRGB(165, 165, 225),
	Font = Enum.Font.GothamBold,
	FontLight = Enum.Font.Gotham,
}
 
local W, H = 560, 380 -- размер окна
 
--// Помощники
local function new(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do obj[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = obj end
	return obj
end
 
local function corner(r) return new("UICorner", {CornerRadius = UDim.new(0, r)}) end
 
local function stroke(color, thickness, transparency)
	return new("UIStroke", {
		Color = color or Theme.Cyan,
		Thickness = thickness or 1.5,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end
 
local function tween(obj, time, props)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
 
-- первое значение, которое не nil
local function pick(...)
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if v ~= nil then return v end
	end
end
 
-- безопасный вызов callback: ошибка в одной функции не ломает остальные
local function safe(cb, ...)
	if type(cb) ~= "function" then return end
	local ok, err = pcall(cb, ...)
	if not ok then warn("[KitsuneUI] ошибка в callback: " .. tostring(err)) end
end
 
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
 
local function makeDraggable(handle, target)
	local dragging, startPos, startInput
	handle.InputBegan:Connect(function(input)
		if isPress(input) then
			dragging, startPos, startInput = true, target.Position, input.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - startInput
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end
 
--// Библиотека
local Kitsune = {}
 
function Kitsune:SetScale(n)
	if self._uiScale then
		self._uiScale.Scale = math.clamp(600 / (tonumber(n) or 600), 0.6, 1.5)
	end
end
 
function Kitsune:CreateWindow(arg)
	local title = (type(arg) == "table") and pick(arg.Title, arg.Name, "Kitsune Hub") or arg or "Kitsune Hub"
 
	local parent
	pcall(function() parent = (gethui and gethui()) or game:GetService("CoreGui") end)
	if not parent then parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
 
	local old = parent:FindFirstChild("KitsuneUI")
	if old then old:Destroy() end
 
	local gui = new("ScreenGui", {Name = "KitsuneUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
	gui.Parent = parent
 
	local holder = new("Frame", {
		Size = UDim2.fromOffset(W, H),
		Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	Kitsune._uiScale = new("UIScale", {Scale = 1, Parent = holder})
 
	-- Лисьи ушки
	local function ear(x)
		local e = new("Frame", {
			Size = UDim2.fromOffset(38, 38), Position = UDim2.new(0, x, 0, -14), Rotation = 45,
			BackgroundColor3 = Theme.Panel, ZIndex = 1, Parent = holder,
		}, {corner(6), stroke(Theme.Cyan, 2)})
		new("Frame", {
			Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(11, 11),
			BackgroundColor3 = Theme.Cyan, BackgroundTransparency = 0.5, ZIndex = 1, Parent = e,
		}, {corner(4)})
	end
	ear(40)
	ear(W - 40 - 38)
 
	local main = new("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Bg,
		ClipsDescendants = true, ZIndex = 2, Parent = holder,
	}, {corner(16)})
	local mainStroke = stroke(Theme.Cyan, 2.5)
	mainStroke.Parent = main
	new("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(70, 55, 170), Theme.Bg), Rotation = 90, Parent = main})
 
	TweenService:Create(mainStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.65}):Play()
 
	-- Шапка
	local top = new("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, ZIndex = 3, Parent = main})
	new("TextLabel", {
		Text = "🦊  " .. tostring(title), Font = Theme.Font, TextSize = 17, TextColor3 = Theme.LightCyan,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -100, 1, 0),
		ZIndex = 3, Parent = top,
	})
	new("Frame", {
		Size = UDim2.new(1, -24, 0, 2), Position = UDim2.new(0, 12, 1, -2),
		BackgroundColor3 = Theme.Cyan, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 3, Parent = top,
	})
 
	local body = new("Frame", {
		Size = UDim2.new(1, 0, 1, -42), Position = UDim2.fromOffset(0, 42),
		BackgroundTransparency = 1, ZIndex = 3, Parent = main,
	})
 
	local function topButton(text, xOffset, callback)
		local b = new("TextButton", {
			Text = text, Font = Theme.Font, TextSize = 16, TextColor3 = Theme.LightCyan,
			Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, xOffset, 0, 7),
			BackgroundColor3 = Theme.Dark, AutoButtonColor = false, ZIndex = 4, Parent = top,
		}, {corner(8), stroke(Theme.Cyan, 1.2, 0.4)})
		b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundColor3 = Theme.Purple}) end)
		b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = Theme.Dark}) end)
		b.MouseButton1Click:Connect(callback)
	end
 
	local minimized = false
	topButton("–", -70, function()
		minimized = not minimized
		body.Visible = not minimized
		tween(holder, 0.25, {Size = minimized and UDim2.fromOffset(W, 42) or UDim2.fromOffset(W, H)})
	end)
	topButton("✕", -36, function() gui:Destroy() end)
 
	makeDraggable(top, holder)
 
	UserInputService.InputBegan:Connect(function(i, gp)
		if not gp and i.KeyCode == Enum.KeyCode.RightShift then holder.Visible = not holder.Visible end
	end)
 
	-- Сайдбар и контент
	local sidebar = new("ScrollingFrame", {
		Size = UDim2.new(0, 130, 1, -16), Position = UDim2.fromOffset(10, 8),
		BackgroundColor3 = Theme.Dark, BackgroundTransparency = 0.3,
		ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0, ZIndex = 3, Parent = body,
	}, {
		corner(12), stroke(Theme.Purple, 1.2, 0.3),
		new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}),
		new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}),
	})
 
	local content = new("Frame", {
		Size = UDim2.new(1, -160, 1, -16), Position = UDim2.fromOffset(150, 8),
		BackgroundTransparency = 1, ZIndex = 3, Parent = body,
	})
 
	local Window = {}
	local tabs = {}
 
	function Window:SetScale(n) Kitsune:SetScale(n) end
	function Window:Destroy() gui:Destroy() end
 
	-- Плавающая кнопка сворачивания (открывает / прячет окно)
	function Window:AddMinimizeButton(o)
		o = o or {}
		local b = new("Frame", {
			Size = o.Size or UDim2.fromOffset(40, 40), Position = UDim2.new(0, 16, 0.5, 0),
			BackgroundColor3 = Theme.Dark, ZIndex = 10, Parent = gui,
		}, {corner(12), stroke(Theme.Cyan, 2)})
		new("TextLabel", {
			Text = "🦊", Font = Theme.Font, TextSize = 22, BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1), ZIndex = 11, Parent = b,
		})
		makeDraggable(b, b)
		local downAt
		b.InputBegan:Connect(function(i) if isPress(i) then downAt = i.Position end end)
		b.InputEnded:Connect(function(i)
			if isPress(i) and downAt and (i.Position - downAt).Magnitude < 6 then
				holder.Visible = not holder.Visible
			end
		end)
	end
 
	function Window:CreateTab(arg)
		local name = (type(arg) == "table") and tostring(pick(arg[1], arg.Name, arg.Title, "Tab")) or tostring(arg or "Tab")
 
		local btn = new("TextButton", {
			Text = name, Font = Theme.Font, TextSize = 14, TextColor3 = Theme.LightCyan,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Panel,
			BackgroundTransparency = 1, AutoButtonColor = false, LayoutOrder = #tabs + 1,
			ZIndex = 4, Parent = sidebar,
		}, {corner(10)})
 
		local page = new("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false,
			ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Cyan,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0, ZIndex = 3, Parent = content,
		}, {
			new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}),
			new("UIPadding", {PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8)}),
		})
 
		local function select()
			for _, t in ipairs(tabs) do
				t.page.Visible = false
				tween(t.btn, 0.2, {BackgroundTransparency = 1})
			end
			page.Visible = true
			tween(btn, 0.2, {BackgroundTransparency = 0.2})
		end
		btn.MouseButton1Click:Connect(select)
		table.insert(tabs, {btn = btn, page = page})
		if #tabs == 1 then select() end
 
		-- порядок элементов на странице
		local order = 0
		local function nextOrder() order = order + 1 return order end
 
		local function card(height)
			return new("Frame", {
				Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = Theme.Panel,
				BackgroundTransparency = 0.25, LayoutOrder = nextOrder(), ZIndex = 4, Parent = page,
			}, {corner(12), stroke(Theme.Cyan, 1.2, 0.55)})
		end
 
		local function heightFor(desc) return (desc ~= nil and desc ~= "") and 50 or 38 end
 
		-- название (+ описание под ним)
		local function nameDesc(c, name, desc, reserve, center)
			local has = desc ~= nil and desc ~= ""
			local align = center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
			local x = center and 0 or 12
			local width = center and UDim2.new(1, 0, 0, 0) or UDim2.new(1, -(reserve + 12), 0, 0)
			new("TextLabel", {
				Text = tostring(name), Font = Theme.Font, TextSize = 14, TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = align, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
				Position = UDim2.fromOffset(x, has and 5 or 0),
				Size = UDim2.new(width.X.Scale, width.X.Offset, 0, has and 20 or 38),
				ZIndex = 5, Parent = c,
			})
			if has then
				new("TextLabel", {
					Text = tostring(desc), Font = Theme.FontLight, TextSize = 12, TextColor3 = Theme.Muted,
					TextXAlignment = align, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
					Position = UDim2.fromOffset(x, 25),
					Size = UDim2.new(width.X.Scale, width.X.Offset, 0, 18),
					ZIndex = 5, Parent = c,
				})
			end
		end
 
		local Tab = {}
 
		--// Заголовок раздела
		function Tab:AddSection(a)
			local text = (type(a) == "table") and pick(a[1], a.Name, a.Title, "") or a
			local f = new("Frame", {
				Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = page,
			})
			new("TextLabel", {
				Text = string.upper(tostring(text)), Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Cyan,
				TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
				Position = UDim2.fromOffset(4, 0), Size = UDim2.new(1, -4, 1, -4), ZIndex = 4, Parent = f,
			})
			new("Frame", {
				Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -2),
				BackgroundColor3 = Theme.Cyan, BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 4, Parent = f,
			})
		end
 
		--// Текстовый блок с заголовком (обновляется через :Set)
		function Tab:AddParagraph(o)
			if type(o) ~= "table" then o = {Title = tostring(o), Content = ""} end
			local c = new("Frame", {
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.25,
				LayoutOrder = nextOrder(), ZIndex = 4, Parent = page,
			}, {
				corner(12), stroke(Theme.Cyan, 1.2, 0.55),
				new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}),
				new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}),
			})
			new("TextLabel", {
				Text = tostring(pick(o.Title, o.Name, "")), Font = Theme.Font, TextSize = 14, TextColor3 = Theme.LightCyan,
				TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, ZIndex = 5, Parent = c,
			})
			local contentLbl = new("TextLabel", {
				Text = tostring(pick(o.Content, o.Text, "")), Font = Theme.FontLight, TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, ZIndex = 5, Parent = c,
			})
			local obj = {}
			function obj:Set(text) contentLbl.Text = tostring(text) end
			return obj
		end
 
		--// Простая строка текста
		function Tab:AddLabel(text)
			return Tab:AddParagraph({Title = tostring(text), Content = ""})
		end
 
		--// Кнопка
		function Tab:AddButton(a, b)
			local name, desc, callback
			if type(a) == "table" then
				name, desc, callback = pick(a.Name, a.Title, "Button"), pick(a.Description, a.Desc, ""), a.Callback
			else
				name, desc, callback = a, "", b
			end
			local c = card(heightFor(desc))
			nameDesc(c, name, desc, 0, true)
			local s = c:FindFirstChildOfClass("UIStroke")
			local hit = new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 7, Parent = c})
			hit.MouseEnter:Connect(function() tween(s, 0.15, {Transparency = 0}) tween(c, 0.15, {BackgroundColor3 = Theme.Purple}) end)
			hit.MouseLeave:Connect(function() tween(s, 0.15, {Transparency = 0.55}) tween(c, 0.15, {BackgroundColor3 = Theme.Panel}) end)
			hit.MouseButton1Click:Connect(function() safe(callback) end)
		end
 
		--// Переключатель
		function Tab:AddToggle(a, b, cb)
			local name, desc, default, callback
			if type(a) == "table" then
				name, desc = pick(a.Name, a.Title, "Toggle"), pick(a.Description, a.Desc, "")
				default, callback = pick(a.Default, a.Value, false), a.Callback
			else
				name, desc, default, callback = a, "", b or false, cb
			end
			local state = default and true or false
			local c = card(heightFor(desc))
			nameDesc(c, name, desc, 60, false)
			local track = new("Frame", {
				Size = UDim2.fromOffset(44, 22), Position = UDim2.new(1, -56, 0.5, -11),
				BackgroundColor3 = state and Theme.Cyan or Theme.Dark, ZIndex = 5, Parent = c,
			}, {corner(11), stroke(Theme.Cyan, 1.2, 0.3)})
			local knob = new("Frame", {
				Size = UDim2.fromOffset(16, 16),
				Position = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3),
				BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 6, Parent = track,
			}, {corner(8)})
 
			local function set(v, fire)
				state = v and true or false
				tween(track, 0.2, {BackgroundColor3 = state and Theme.Cyan or Theme.Dark})
				tween(knob, 0.2, {Position = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)})
				if fire then safe(callback, state) end
			end
			new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 7, Parent = c})
				.MouseButton1Click:Connect(function() set(not state, true) end)
 
			if state then task.defer(safe, callback, state) end -- синхронизируем включённое по умолчанию
 
			local obj = {}
			function obj:Set(v) set(v, true) end
			function obj:Get() return state end
			return obj
		end
 
		--// Слайдер
		function Tab:AddSlider(a, mn, mx, def, cb)
			local name, min, max, step, default, callback
			if type(a) == "table" then
				name, min, max = pick(a.Name, a.Title, "Slider"), pick(a.Min, 0), pick(a.Max, 100)
				step, default, callback = pick(a.Increase, a.Step, 1), pick(a.Default, a.Value), a.Callback
			else
				name, min, max, step, default, callback = a, mn, mx, 1, def, cb
			end
			default = default or min
			local value = default
			local c = card(52)
			new("TextLabel", {
				Text = tostring(name), Font = Theme.Font, TextSize = 14, TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -80, 0, 26), ZIndex = 5, Parent = c,
			})
			local valLabel = new("TextLabel", {
				Text = tostring(value), Font = Theme.Font, TextSize = 14, TextColor3 = Theme.LightCyan,
				TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1,
				Position = UDim2.new(1, -62, 0, 0), Size = UDim2.fromOffset(50, 26), ZIndex = 5, Parent = c,
			})
			local bar = new("Frame", {
				Size = UDim2.new(1, -24, 0, 8), Position = UDim2.new(0, 12, 0, 32),
				BackgroundColor3 = Theme.Dark, ZIndex = 5, Parent = c,
			}, {corner(4)})
			local fill = new("Frame", {
				Size = UDim2.fromScale(math.clamp((value - min) / (max - min), 0, 1), 1),
				BackgroundColor3 = Theme.Cyan, ZIndex = 6, Parent = bar,
			}, {corner(4), new("UIGradient", {Color = ColorSequence.new(Theme.Purple, Theme.LightCyan)})})
 
			local function apply(v, fire)
				v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
				value = math.floor(v * 1000 + 0.5) / 1000
				fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
				valLabel.Text = tostring(value)
				if fire then safe(callback, value) end
			end
			local function fromX(x)
				apply(min + (max - min) * math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), true)
			end
 
			local sliding = false
			bar.InputBegan:Connect(function(i) if isPress(i) then sliding = true fromX(i.Position.X) end end)
			UserInputService.InputEnded:Connect(function(i) if isPress(i) then sliding = false end end)
			UserInputService.InputChanged:Connect(function(i)
				if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					fromX(i.Position.X)
				end
			end)
 
			local obj = {}
			function obj:Set(v) apply(v, true) end
			return obj
		end
 
		--// Выпадающий список
		function Tab:AddDropdown(a, opts, def, cb)
			local name, options, default, callback
			if type(a) == "table" then
				name, options = pick(a.Name, a.Title, "Dropdown"), a.Options or {}
				default, callback = pick(a.Default, a.Value), a.Callback
			else
				name, options, default, callback = a, opts or {}, def, cb
			end
			local HEAD = 38
			local selected = default
			local c = card(HEAD)
			c.ClipsDescendants = true
			new("TextLabel", {
				Text = tostring(name), Font = Theme.Font, TextSize = 14, TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.5, -18, 0, HEAD), ZIndex = 5, Parent = c,
			})
			local head = new("TextButton", {
				Text = "", Size = UDim2.new(0.5, -12, 0, 26), Position = UDim2.new(0.5, 0, 0, 6),
				BackgroundColor3 = Theme.Dark, AutoButtonColor = false, ZIndex = 5, Parent = c,
			}, {corner(8), stroke(Theme.Cyan, 1.2, 0.4)})
			local headText = new("TextLabel", {
				Text = "", Font = Theme.Font, TextSize = 13, TextColor3 = Theme.LightCyan, TextTruncate = Enum.TextTruncate.AtEnd,
				BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -24, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = head,
			})
			new("TextLabel", {
				Text = "▾", Font = Theme.Font, TextSize = 14, TextColor3 = Theme.Cyan, BackgroundTransparency = 1,
				Position = UDim2.new(1, -18, 0, 0), Size = UDim2.fromOffset(14, 26), ZIndex = 6, Parent = head,
			})
			local list = new("ScrollingFrame", {
				Position = UDim2.fromOffset(12, HEAD + 4), Size = UDim2.new(1, -24, 0, 0),
				BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Cyan,
				CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, ZIndex = 5, Parent = c,
			}, {new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})})
 
			local open = false
			local function listHeight() return math.min(#options * 30, 150) end
			local function resize()
				tween(c, 0.2, {Size = UDim2.new(1, 0, 0, open and (HEAD + 10 + listHeight()) or HEAD)})
			end
			local function setText() headText.Text = selected ~= nil and tostring(selected) or "Select" end
 
			local function choose(v, fire)
				selected = v
				setText()
				if fire then safe(callback, v) end
			end
 
			local function rebuild()
				for _, ch in ipairs(list:GetChildren()) do
					if ch:IsA("TextButton") then ch:Destroy() end
				end
				list.Size = UDim2.new(1, -24, 0, listHeight())
				for idx, v in ipairs(options) do
					local ob = new("TextButton", {
						Text = tostring(v), Font = Theme.FontLight, TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, -6, 0, 26), BackgroundColor3 = Theme.Dark, AutoButtonColor = false,
						LayoutOrder = idx, ZIndex = 6, Parent = list,
					}, {corner(8)})
					ob.MouseEnter:Connect(function() tween(ob, 0.1, {BackgroundColor3 = Theme.Purple}) end)
					ob.MouseLeave:Connect(function() tween(ob, 0.1, {BackgroundColor3 = Theme.Dark}) end)
					ob.MouseButton1Click:Connect(function()
						choose(v, true)
						open = false
						resize()
					end)
				end
			end
 
			head.MouseButton1Click:Connect(function() open = not open resize() end)
			rebuild()
			setText()
			if default ~= nil then task.defer(safe, callback, default) end
 
			local obj = {}
			function obj:Set(v) choose(v, true) end
			function obj:Refresh(newOptions)
				options = newOptions or {}
				rebuild()
				if open then resize() end
			end
			obj.SetOptions = obj.Refresh
			return obj
		end
 
		--// Текстовое поле
		function Tab:AddTextbox(a, ph, cb)
			local name, placeholder, default, callback
			if type(a) == "table" then
				name, placeholder = pick(a.Name, a.Title, "Textbox"), pick(a.PlaceholderText, a.Placeholder, "")
				default, callback = pick(a.Default, a.Value, ""), a.Callback
			else
				name, placeholder, default, callback = a, ph or "", "", cb
			end
			local c = card(38)
			new("TextLabel", {
				Text = tostring(name), Font = Theme.Font, TextSize = 14, TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.4, -12, 1, 0), ZIndex = 5, Parent = c,
			})
			local box = new("TextBox", {
				Text = tostring(default), PlaceholderText = tostring(placeholder), Font = Theme.Font, TextSize = 13,
				TextColor3 = Theme.LightCyan, PlaceholderColor3 = Color3.fromRGB(120, 120, 180),
				Size = UDim2.new(0.6, -12, 0, 26), Position = UDim2.new(0.4, 0, 0.5, -13),
				BackgroundColor3 = Theme.Dark, ClearTextOnFocus = false, ZIndex = 5, Parent = c,
			}, {corner(8), stroke(Theme.Cyan, 1.2, 0.4)})
			box.FocusLost:Connect(function() safe(callback, box.Text) end)
			local obj = {}
			function obj:Set(v) box.Text = tostring(v) end
			return obj
		end
		Tab.AddTextBox = Tab.AddTextbox
 
		--// Карточка с приглашением в Discord
		function Tab:AddDiscordInvite(o)
			o = o or {}
			local c = card(56)
			new("TextLabel", {
				Text = tostring(pick(o.Name, "Discord")), Font = Theme.Font, TextSize = 14, TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -100, 0, 20), ZIndex = 5, Parent = c,
			})
			new("TextLabel", {
				Text = tostring(pick(o.Description, "")), Font = Theme.FontLight, TextSize = 12, TextColor3 = Theme.Muted,
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 28), Size = UDim2.new(1, -100, 0, 18), ZIndex = 5, Parent = c,
			})
			local b = new("TextButton", {
				Text = "Copy", Font = Theme.Font, TextSize = 13, TextColor3 = Theme.LightCyan,
				Size = UDim2.fromOffset(64, 28), Position = UDim2.new(1, -76, 0.5, -14),
				BackgroundColor3 = Theme.Dark, AutoButtonColor = false, ZIndex = 6, Parent = c,
			}, {corner(8), stroke(Theme.Cyan, 1.2, 0.3)})
			b.MouseButton1Click:Connect(function()
				if setclipboard and o.Invite then
					pcall(setclipboard, o.Invite)
					b.Text = "Copied"
					task.delay(1.5, function() b.Text = "Copy" end)
				end
			end)
		end
 
		return Tab
	end
 
	-- совместимость с redz: Window:MakeTab({"Имя", "иконка"})
	Window.MakeTab = Window.CreateTab
 
	return Window
end
 
-- совместимость с redz: Library:MakeWindow({Title = "..."})
Kitsune.MakeWindow = Kitsune.CreateWindow
 
--[[ ПРИМЕР
 
local Window = Kitsune:CreateWindow("Kitsune Hub")
local Main = Window:CreateTab("Main")
 
Main:AddSection("Фарм")
Main:AddToggle("Auto Farm", false, function(v) print("Auto Farm:", v) end)
Main:AddToggle({Name = "Fast Attack", Description = "Быстрые удары", Default = true, Callback = function(v) print(v) end})
Main:AddSlider({Name = "Скорость", Min = 1, Max = 100, Increase = 1, Default = 50, Callback = function(v) print(v) end})
Main:AddDropdown({Name = "Оружие", Options = {"Melee", "Sword", "Gun"}, Default = "Melee", Callback = function(v) print(v) end})
Main:AddTextbox("Job ID", "вставь ID", function(t) print(t) end)
Main:AddButton("Нажми меня", function() print("ok") end)
 
local status = Main:AddParagraph({Title = "Статус", Content = "Загрузка..."})
status:Set("Готово")
 
]]
 
return Kitsune
