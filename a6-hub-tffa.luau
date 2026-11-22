-- A6 Hub | TFFA
-- A6 Hub - TFFA | Dark UI
-- Throwing / Training / Index / Shop / Animals / Rewards / Teleports / Movement / QoL / Stats / Settings

local _g = (type(getgenv) == "function" and getgenv()) or _G
local function setId()
	if type(setthreadidentity) == "function" then pcall(setthreadidentity, 8) end
end
setId()
if _g.A6HubCleanup then
	pcall(_g.A6HubCleanup)
	_g.A6HubCleanup = nil
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local V = {
	conns = {}, Flags = {}, Setters = {}, Defaults = {}, Tickers = {},
	pages = {}, tabButtons = {}, alive = true, loading = false,
	cfgName = "default", state = {tab = "throwing"},
}
local G = {}   -- game modules
local F = {}   -- feature functions

local function track(c) V.conns[#V.conns + 1] = c; return c end

-- ===============================================================
-- THEME (A6 Hub / Dark AMOLED)
-- ===============================================================
local T = {
	bg = Color3.fromRGB(0, 0, 0), panel = Color3.fromRGB(0, 0, 0), raised = Color3.fromRGB(24, 24, 24),
	text = Color3.fromRGB(255, 255, 255), dim = Color3.fromRGB(160, 160, 160), accent = Color3.fromRGB(255, 255, 255),
	onAccent = Color3.fromRGB(0, 0, 0), stroke = Color3.fromRGB(38, 38, 38), rule = Color3.fromRGB(26, 26, 26),
	selection = Color3.fromRGB(22, 22, 22), overlay = Color3.fromRGB(12, 12, 12), modalStroke = Color3.fromRGB(55, 55, 55),
	good = Color3.fromRGB(120, 255, 120), bad = Color3.fromRGB(255, 90, 90),
}
V.T = T

-- Connections that belong to one build of the UI; they are dropped when the UI is rebuilt (language / theme change)
V.uiConns = {}
local function uiTrack(c) V.uiConns[#V.uiConns + 1] = c; return c end

-- ===============================================================
-- THEMES
-- ===============================================================
local function hexColor(h)
	return Color3.fromRGB(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16))
end
V.ThemePalettes = {
	-- Core
	Red = {"60241E", "95271D", "B34A44", "E77B49"},
	Green = {"092328", "12544F", "2A835F", "8BBB92"},
	Blue = {"293681", "4274D9", "95CCDD", "D0E7E6"},
	Brown = {"000000", "1F150C", "412D15", "E1DCC9"},
	Purple = {"4C2365", "7F5D99", "9E7EB5", "C4A4DA"},
	Orange = {"2A1508", "7A3A12", "C45E1A", "F0A35A"},
	Pink = {"2A1020", "7A2A55", "C45A90", "F0A0C8"},
	Cyan = {"062028", "0E5A68", "2AA8B8", "A0E8F0"},
	Gold = {"1A1408", "6B4E12", "C9A227", "F5E6A3"},
	Midnight = {"050510", "12122A", "2A2A55", "A0A0D0"},
	Crimson = {"1A0508", "6B1018", "C02030", "F08090"},
	Forest = {"05140A", "0E3A1C", "1E7A3A", "90D0A8"},
	-- Requested pack
	Shadow = {"0A0612", "1A0F2A", "3A2060", "C8B0E8"},
	Violet = {"1A0A28", "3A1A5A", "7A3AB0", "D8B8F8"},
	Scarlet = {"28080C", "6A1018", "C01828", "F09098"},
	Obsidian = {"080808", "141414", "2A2A2A", "C0C0C0"},
	Slate = {"12161C", "1E2630", "3A4A5A", "C8D0D8"},
	Silver = {"1A1C20", "2E3238", "8A9098", "E8ECF0"},
	Sepia = {"1C140C", "3A2A18", "8A6A3A", "E8D8B8"},
	Ocean = {"041820", "0A3A4A", "1A7A90", "A0D8E8"},
	Sky = {"0C1828", "1A3A5A", "4A90C8", "C0E0F8"},
	Teal = {"062018", "0E4A40", "1A9080", "A0E8D8"},
	Indigo = {"0C0C28", "1A1A5A", "3A3AA0", "B0B0F0"},
	Nord = {"0C141C", "1A2838", "4A6A88", "C0D0E0"},
	Emerald = {"041810", "0A3A24", "18A060", "90E8C0"},
	Mint = {"0C1C18", "1A3A34", "40A890", "B8F0E0"},
	Olive = {"14180C", "2A3418", "6A7A30", "D0D8A0"},
	Lime = {"101808", "2A3A10", "70B020", "D0F080"},
	Amber = {"1C1408", "4A3010", "C08020", "F0D080"},
	Sunset = {"281408", "6A2810", "E06020", "F0B080"},
	Coral = {"281010", "6A2828", "E06060", "F0B0B0"},
	Rose = {"241018", "5A2030", "C05070", "F0B0C0"},
	Lavender = {"181028", "3A2858", "8870B8", "D8C8F0"},
	Magenta = {"240818", "5A1038", "C02080", "F090C8"},
	Charcoal = {"0E0E10", "1A1A1E", "3A3A42", "B8B8C0"},
	Graphite = {"101214", "1C2024", "3A4248", "B0B8C0"},
	Ash = {"161616", "262626", "4A4A4A", "C8C8C8"},
	Ivory = {"E8E4D8", "F2EEE4", "D8D0C0", "2A2820"},
	Cream = {"F0EBE0", "F8F4EC", "E0D8C8", "2C2820"},
	Cobalt = {"081428", "102860", "2050C0", "A0C0F0"},
	Navy = {"060E1C", "0C1C38", "1A3A70", "90B0D8"},
	Azure = {"081828", "103A60", "2088D0", "A0D8F8"},
	Turquoise = {"06201C", "0E4A44", "18A090", "90E8E0"},
	Glacier = {"0C1820", "1A3040", "60A0B8", "D0E8F0"},
	Sage = {"141C14", "2A3A2A", "6A8A68", "C8D8C0"},
	Jade = {"081C14", "103A28", "28A070", "A0E8C8"},
	Moss = {"10180C", "243818", "4A7040", "B0D0A0"},
	Pine = {"08140C", "102818", "1A5030", "90C0A0"},
	Matcha = {"141C10", "2A3A1C", "70A040", "D0E8A8"},
	Peach = {"281810", "6A3A28", "E09060", "F8D0B0"},
	Terracotta = {"24140C", "5A2A18", "C05030", "E8A888"},
	Ruby = {"20080C", "5A1018", "C01838", "F08098"},
	Maroon = {"18080C", "401018", "801828", "D08090"},
	Sand = {"1C1810", "4A3C28", "C0A070", "F0E0C0"},
	Coffee = {"140E08", "2A1C10", "5A3A20", "D0B090"},
	Bronze = {"1A1008", "3A2410", "8A5A20", "E0C090"},
	Plum = {"180C18", "3A1838", "7A3068", "D8A0C8"},
	Orchid = {"1C1024", "3A2050", "8A50A0", "E0B8F0"},
	Lilac = {"1C1828", "3A3050", "9080B8", "E0D8F0"},
	Blush = {"28181C", "5A3038", "C08090", "F0D0D8"},
	Sakura = {"281820", "5A3040", "E090A8", "F8D8E0"},
	Neon = {"0A0014", "1A0030", "A020F0", "E080FF"},
	Galaxy = {"080818", "14103A", "4A28A0", "C0A0F8"},
	Twilight = {"140C18", "3A1830", "A04060", "F0B0C0"},
	Aurora = {"06141C", "0E3A48", "30A090", "A0F0E0"},
	Rainbow = {"0A0A12", "1A1228", "8844CC", "F0E0FF"},
}
V.ThemeOrder = {
	"Dark", "DarkGlass", "Obsidian", "Charcoal", "Graphite", "Ash", "Slate", "Silver",
	"Light", "LightGlass", "Ivory", "Cream",
	"Shadow", "Midnight", "Navy", "Indigo", "Cobalt", "Blue", "Azure", "Sky", "Ocean", "Teal", "Turquoise", "Cyan", "Glacier", "Nord",
	"Forest", "Pine", "Moss", "Jade", "Emerald", "Green", "Sage", "Matcha", "Mint", "Olive", "Lime",
	"Brown", "Coffee", "Bronze", "Sand", "Sepia", "Gold", "Amber", "Peach", "Orange", "Sunset", "Terracotta",
	"Red", "Scarlet", "Crimson", "Ruby", "Maroon", "Coral", "Rose", "Blush", "Sakura", "Pink",
	"Purple", "Violet", "Plum", "Orchid", "Lilac", "Lavender", "Magenta",
	"Neon", "Galaxy", "Twilight", "Aurora", "Rainbow",
}
V.Themes = {}
do
	local function gray(n) return Color3.fromRGB(n, n, n) end
	local dark = {
		bg = gray(0), panel = gray(0), surface = gray(0), raised = gray(24), text = gray(255), dim = gray(160), accent = gray(255),
		onAccent = gray(0), art = gray(14), artHover = gray(22), stroke = gray(38), rule = gray(26), input = gray(12), dock = gray(10),
		progress = gray(28), overlay = gray(12), selection = gray(22), modalStroke = gray(55),
	}
	V.Themes.Dark = dark
	local light = {
		bg = Color3.fromRGB(242, 243, 247), panel = Color3.fromRGB(255, 255, 255), raised = Color3.fromRGB(225, 228, 237),
		text = Color3.fromRGB(28, 32, 43), dim = Color3.fromRGB(94, 102, 122), accent = Color3.fromRGB(63, 80, 170),
		onAccent = Color3.new(1, 1, 1), art = Color3.fromRGB(232, 234, 240), artHover = Color3.fromRGB(220, 224, 234),
		stroke = Color3.fromRGB(190, 195, 209),
	}
	light.surface = light.panel; light.rule = light.stroke; light.input = light.panel; light.dock = light.panel
	light.progress = light.raised; light.overlay = light.panel; light.selection = light.raised; light.modalStroke = light.stroke
	V.Themes.Light = light
	for name, hx in pairs(V.ThemePalettes) do
		local a, b, c, d = hexColor(hx[1]), hexColor(hx[2]), hexColor(hx[3]), hexColor(hx[4])
		V.Themes[name] = {
			bg = a, panel = a:Lerp(b, 0.18), surface = a:Lerp(b, 0.12), raised = a:Lerp(b, 0.65), art = a:Lerp(b, 0.4), artHover = b,
			text = d:Lerp(Color3.new(1, 1, 1), 0.85), dim = d:Lerp(Color3.new(1, 1, 1), 0.3), accent = d, onAccent = Color3.new(),
			progress = b, input = a:Lerp(b, 0.22), dock = a:Lerp(b, 0.22), stroke = a:Lerp(c, 0.6), rule = a:Lerp(c, 0.4),
			overlay = a:Lerp(b, 0.25), selection = a:Lerp(b, 0.72), modalStroke = c,
		}
	end
	local brown = V.Themes.Brown   -- Brown has hand-tuned surfaces
	brown.panel = hexColor("1F150C"); brown.surface = brown.panel:Lerp(brown.bg, 0.4); brown.raised = hexColor("412D15")
	brown.art = brown.panel; brown.artHover = brown.raised; brown.input = brown.surface; brown.dock = brown.panel
	brown.selection = brown.raised; brown.overlay = brown.panel; brown.rule = brown.raised
	local glass = table.clone(dark); glass.panel = gray(10); glass.surface = gray(8)
	V.Themes.DarkGlass = glass
	-- Light glass (frosted white)
	local lg = table.clone(light)
	lg.bg = Color3.fromRGB(248, 250, 255); lg.panel = Color3.fromRGB(255, 255, 255)
	lg.surface = Color3.fromRGB(245, 247, 252); lg.raised = Color3.fromRGB(230, 234, 245)
	lg.stroke = Color3.fromRGB(200, 208, 230); lg.modalStroke = lg.stroke
	lg.overlay = Color3.fromRGB(252, 253, 255); lg.selection = lg.raised
	V.Themes.LightGlass = lg
end
V.theme = "Dark"
V.themeFx = nil   -- RunService connection for animated themes
V.AnimatedThemes = {Rainbow = true, Aurora = true, Galaxy = true, Neon = true, Twilight = true}

local function hsv(h, s, v)
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p, q, t_ = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
	i = i % 6
	if i == 0 then return Color3.new(v, t_, p)
	elseif i == 1 then return Color3.new(q, v, p)
	elseif i == 2 then return Color3.new(p, v, t_)
	elseif i == 3 then return Color3.new(p, q, v)
	elseif i == 4 then return Color3.new(t_, p, v)
	else return Color3.new(v, p, q) end
end

function V.stopThemeFx()
	if V.themeFx then V.themeFx:Disconnect(); V.themeFx = nil end
end

function V.startThemeFx(name)
	V.stopThemeFx()
	if not V.AnimatedThemes[name] then return end
	local t0 = os.clock()
	V.themeFx = RunService.RenderStepped:Connect(function()
		if not V.alive or V.theme ~= name then V.stopThemeFx() return end
		local u = (os.clock() - t0) * 0.12
		local accent, raised, stroke
		if name == "Rainbow" then
			accent = hsv((u * 0.35) % 1, 0.85, 1)
			raised = hsv((u * 0.35 + 0.08) % 1, 0.55, 0.28)
			stroke = hsv((u * 0.35 + 0.2) % 1, 0.4, 0.45)
		elseif name == "Aurora" then
			local h = 0.45 + 0.12 * math.sin(u * 1.3)
			accent = hsv(h % 1, 0.7, 0.95)
			raised = hsv((h + 0.15) % 1, 0.45, 0.22)
			stroke = hsv((h + 0.25) % 1, 0.35, 0.4)
		elseif name == "Galaxy" then
			local h = 0.72 + 0.08 * math.sin(u)
			accent = hsv(h % 1, 0.75, 1)
			raised = hsv((h + 0.1) % 1, 0.5, 0.2)
			stroke = hsv((h + 0.18) % 1, 0.4, 0.38)
		elseif name == "Neon" then
			local pulse = 0.55 + 0.45 * (0.5 + 0.5 * math.sin(u * 4))
			accent = hsv(0.78, 0.9, pulse)
			raised = Color3.fromRGB(26, 0, 48)
			stroke = hsv(0.78, 0.6, 0.5)
		else -- Twilight
			local h = 0.95 + 0.08 * math.sin(u * 0.8)
			accent = hsv(h % 1, 0.7, 0.95)
			raised = hsv((h + 0.12) % 1, 0.45, 0.22)
			stroke = hsv((h + 0.2) % 1, 0.35, 0.4)
		end
		T.accent = accent
		T.raised = raised
		T.stroke = stroke
		T.selection = raised
		T.progress = raised
		-- live paint a few key surfaces if UI exists
		if V.window then
			for _, o in ipairs(V.window:GetDescendants()) do
				if o:IsA("UIStroke") and o.Name ~= "HoverStroke" then
					o.Color = stroke
				elseif o:IsA("TextButton") and o.BackgroundColor3 == T.raised then
					-- skip busy update
				end
			end
		end
		if V.paint then pcall(V.paint) end
	end)
end

function V.applyTheme(name)
	if not V.Themes[name] then name = "Dark" end
	V.stopThemeFx()
	V.theme = name
	for k, v in pairs(V.Themes[name]) do T[k] = v end
	V.startThemeFx(name)
end

-- ===============================================================
-- LANGUAGES
-- ===============================================================
V.lang = "EN"
V.Translations = {}   -- english text -> {TR = ..., ES = ..., ...} (filled from the table at the end of this file)
local function L(s)
	if V.lang == "EN" or type(s) ~= "string" then return s end
	local e = V.Translations[s]
	return (e and e[V.lang]) or s
end
local function LF(fmt, ...) return string.format(L(fmt), ...) end
local function LS(suffix)   -- translate a suffix like " throws" but keep its surrounding spaces
	if not suffix or suffix == "" then return "" end
	local pre, word, post = suffix:match("^(%s*)(.-)(%s*)$")
	return pre .. L(word) .. post
end
V.L = L
function V.upper(s)   -- unicode aware upper-case (Turkish i/ı, accented Latin, Cyrillic)
	local ok, res = pcall(function()
		local out = {}
		for _, c in utf8.codes(s) do
			if c < 128 then
				if V.lang == "TR" and c == 105 then c = 0x130 elseif c >= 97 and c <= 122 then c = c - 32 end
			elseif c >= 0xE0 and c <= 0xFE and c ~= 0xF7 then c = c - 32
			elseif c == 0x131 then c = 73
			elseif c == 0x11F or c == 0x15F or c == 0x153 then c = c - 1
			elseif c >= 0x430 and c <= 0x44F then c = c - 32
			elseif c >= 0x450 and c <= 0x45F then c = c - 80 end
			out[#out + 1] = utf8.char(c)
		end
		return table.concat(out)
	end)
	return ok and res or s:upper()
end

-- ===============================================================
-- HELPERS
-- ===============================================================
local function make(class, props, parent)
	local o = Instance.new(class)
	if o:IsA("GuiBase2d") then o.AutoLocalize = false end
	for k, v in pairs(props or {}) do
		if (k == "Text" or k == "PlaceholderText") and type(v) == "string" then v = L(v) end
		o[k] = v
	end
	if class == "ScrollingFrame" then
		o.ScrollBarThickness = 3
		o.ScrollBarImageColor3 = T.dim
		o.ScrollBarImageTransparency = 0.2
		o.Active = true
	end
	o.Parent = parent
	return o
end
local function round(o, r) make("UICorner", {CornerRadius = UDim.new(0, r or 10)}, o) end
local function stroke(p, c, t) return make("UIStroke", {Color = c or T.stroke, Thickness = 1, Transparency = t or 0.2}, p) end
local function tween(o, goals, d, style)
	if not o or not o.Parent then return end
	local tw = TS:Create(o, TweenInfo.new(d or 0.16, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goals)
	tw:Play()
	return tw
end
local function label(parent, text, size, dim)
	return make("TextLabel", {
		BackgroundTransparency = 1, Text = text, TextSize = size or 14, Font = Enum.Font.Gotham,
		TextColor3 = dim and T.dim or T.text, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, 0, 0, 24),
	}, parent)
end

local SUF = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
local function fmtNum(n)
	n = tonumber(n) or 0
	local i = 1
	while math.abs(n) >= 1000 and i < #SUF do n = n / 1000; i = i + 1 end
	local s
	if i == 1 then s = tostring(math.floor(n + 0.5))
	else s = string.format("%.2f", n):gsub("0+$", ""):gsub("%.$", "") end
	return s .. SUF[i]
end
V.fmtNum = fmtNum

-- UI lives under PlayerGui (CoreGui/gethui raises thread capability errors)
local function guiParent()
	return playerGui
end

-- ===============================================================
-- NOTIFICATIONS + MODAL
-- ===============================================================
function V.notify(title, body)
	if not V.gui then return end
	V.toastVersion = (V.toastVersion or 0) + 1
	local version = V.toastVersion
	if V.toast then V.toast:Destroy() end
	local toast = make("Frame", {
		ClipsDescendants = true, Name = "Toast", AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, 0), Size = UDim2.fromOffset(340, 70),
		BackgroundColor3 = T.overlay, BorderSizePixel = 0, ZIndex = 50,
	}, V.gui)
	round(toast, 14); stroke(toast, T.modalStroke)
	local a = label(toast, tostring(title), 14); a.Position = UDim2.fromOffset(16, 10); a.Size = UDim2.new(1, -32, 0, 24); a.ZIndex = 51
	local b = label(toast, tostring(body or ""), 11, true); b.Position = UDim2.fromOffset(16, 36); b.Size = UDim2.new(1, -32, 0, 24); b.ZIndex = 51
	if V.icon then
		local ic = V.icon(toast, "info", 22, T.text, function()
			a.Position = UDim2.fromOffset(46, 10); a.Size = UDim2.new(1, -62, 0, 24)
			b.Position = UDim2.fromOffset(46, 36); b.Size = UDim2.new(1, -62, 0, 24)
		end)
		ic.Position = UDim2.fromOffset(14, 16); ic.ZIndex = 51
	end
	V.toast = toast
	tween(toast, {Position = UDim2.new(1, -24, 1, -24)}, 0.25)
	task.delay(3.5, function()
		if V.toastVersion ~= version or not toast.Parent then return end
		local tw = tween(toast, {Position = UDim2.new(1, -24, 1, 0)}, 0.16)
		if tw then tw.Completed:Wait() end
		if toast.Parent and V.toastVersion == version then toast:Destroy() end
	end)
end

local function button(parent, text, cb, width)
	local b = make("TextButton", {
		Name = text, Text = text, TextSize = 13, Font = Enum.Font.GothamMedium, TextColor3 = T.text,
		BackgroundColor3 = T.raised, BorderSizePixel = 0, AutoButtonColor = false,
		Size = UDim2.fromOffset(width or 96, 34),
	}, parent)
	round(b, 8)
	local sc = make("UIScale", {Name = "PressScale", Scale = 1}, b)
	local edge = make("UIStroke", {Name = "HoverStroke", Thickness = 1, Color = T.text, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, b)
	b.MouseEnter:Connect(function() tween(edge, {Transparency = 0.72}) end)
	b.MouseLeave:Connect(function() tween(edge, {Transparency = 1}); tween(sc, {Scale = 1}) end)
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tween(sc, {Scale = 0.97}) end
	end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tween(sc, {Scale = 1}) end
	end)
	b.Activated:Connect(function()
		if not cb or b:GetAttribute("Busy") then return end
		b:SetAttribute("Busy", true)
		local ok, err = pcall(cb, b)
		if b.Parent then b:SetAttribute("Busy", false) end
		if not ok then V.notify("Action failed", tostring(err):sub(1, 90)) end
	end)
	return b
end
V.button = button

function V.modal(title, build, width, height, noCancel)
	if V.modalShade then V.modalShade:Destroy() end
	width, height = width or 390, height or 420
	local shade = make("TextButton", {
		Name = "Dialog", Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 20,
	}, V.gui)
	local panel = make("Frame", {
		ClipsDescendants = true, Name = "Panel", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = T.bg, BorderSizePixel = 0, ZIndex = 21,
	}, shade)
	round(panel, 16); stroke(panel, T.modalStroke)
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local fit = math.min(1, (viewport.X - 24) / width, (viewport.Y - 28) / height)
	local zoom = make("UIScale", {Scale = fit * 0.96}, panel)
	local head = label(panel, title, 18); head.Position = UDim2.fromOffset(18, 14); head.Size = UDim2.new(1, -36, 0, 28); head.ZIndex = 22
	local list = make("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(18, 52),
		Size = UDim2.new(1, -36, 1, noCancel and -72 or -112), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(), ZIndex = 22,
	}, panel)
	make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, list)
	local closing = false
	local function close()
		if closing then return end
		closing = true
		tween(zoom, {Scale = fit * 0.96}, 0.16)
		local tw = tween(shade, {BackgroundTransparency = 1}, 0.16)
		task.delay(0.17, function()
			if V.modalShade == shade then V.modalShade = nil end
			if shade.Parent then shade:Destroy() end
		end)
	end
	build(list, close)
	if not noCancel then
		local cancel = button(panel, "Close", close, width - 36)
		cancel.AnchorPoint = Vector2.new(0, 1); cancel.Position = UDim2.new(0, 18, 1, -16); cancel.ZIndex = 22
	end
	for _, o in ipairs(panel:GetDescendants()) do if o:IsA("GuiObject") then o.ZIndex = 22 end end
	V.modalShade = shade
	tween(shade, {BackgroundTransparency = 0.4}, 0.25)
	tween(zoom, {Scale = fit}, 0.25)
	return close
end

function V.confirm(text, action)
	V.modal("Are you sure?", function(list, close)
		local d = label(list, text, 14); d.Size = UDim2.new(1, 0, 0, 80); d.TextWrapped = true; d.TextTruncate = Enum.TextTruncate.None
		d.TextYAlignment = Enum.TextYAlignment.Top
		button(list, "Confirm", function() close(); task.spawn(action) end, 354)
	end, 390, 280)
end

-- ===============================================================
-- GAME MODULES
-- ===============================================================
local function req(name, getter)
	local ok, res = pcall(getter)
	if ok then G[name] = res else warn("[A6Hub] " .. name .. " failed to load: " .. tostring(res)) end
end
function G.load()
	local Client = player:WaitForChild("PlayerScripts"):WaitForChild("Client", 15)
	local C = Client and Client:WaitForChild("Controllers", 15)
	if not C then return false end
	local Cfg = RS:WaitForChild("Config", 15)
	req("Remotes", function() return require(RS.Shared.Remotes) end)
	req("Data", function() return require(C.DataController) end)
	req("State", function() return require(C.ClientState) end)
	req("Throw", function() return require(C.ThrowController) end)
	req("Meter", function() return require(C.ThrowMeter) end)
	req("Super", function() return require(C.SuperThrow) end)
	req("Reveal", function() return require(C.RevealSequence) end)
	req("Input", function() return require(C.InputActions) end)
	req("Training", function() return require(C.TrainingController) end)
	req("Plot", function() return require(C.PlotController) end)
	req("Areas", function() return require(RS.Shared.AreaUtil) end)
	req("TMM", function() return require(RS.Shared.ThrowMeterMath) end)
	req("AreasCfg", function() return require(Cfg.AreasConfig) end)
	req("Foods", function() return require(Cfg.FoodsConfig) end)
	req("LevelCfg", function() return require(Cfg.LevelConfig) end)
	req("Econ", function() return require(Cfg.AnimalEconomy) end)
	req("AnimalsData", function() return require(RS.AnimalsData) end)
	req("Rarity", function() return require(Cfg.RarityConfig) end)
	req("Mut", function() return require(Cfg.MutationsConfig) end)
	req("Fence", function() return require(Cfg.FenceConfig) end)
	req("GameCfg", function() return require(Cfg.GameConfig) end)
	return G.Remotes ~= nil and G.Data ~= nil and G.State ~= nil
end

local function inv(name, ...)
	if not G.Remotes then return {Ok = false, Reason = "NoRemotes"} end
	local ok, res = pcall(G.Remotes.Invoke, name, ...)
	if not ok then return {Ok = false, Reason = tostring(res)} end
	if type(res) ~= "table" then return {Ok = res and true or false, Reason = "Raw"} end
	return res
end
local function D(key)
	if not G.Data then return nil end
	local ok, v = pcall(function() return G.Data:Get(key) end)
	if ok then return v end
	return nil
end
local function busy() return G.State and G.State.Busy end
local function char() return player.Character end
local function hrp() local c = char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = char(); return c and c:FindFirstChildOfClass("Humanoid") end
local function sleep(t) local e = os.clock() + t; while V.alive and os.clock() < e do task.wait(0.1) end end

-- ===============================================================
-- FEATURES: THROWING
-- ===============================================================
function F.maxPower()
	if not G.LevelCfg then return 0 end
	local ok, v = pcall(G.LevelCfg.ThrowPowerForLevel, D("Level") or 1)
	return ok and tonumber(v) or 0
end
function F.minPower()
	return (G.LevelCfg and tonumber(G.LevelCfg.MinThrowPower)) or 1
end
function F.effPower()
	if not G.LevelCfg then return 0 end
	local ok, v = pcall(G.LevelCfg.EffectiveThrowPower, D("Level") or 1, D("ThrowPower"))
	return ok and tonumber(v) or F.maxPower()
end
function F.bonus()
	local b = G.GameCfg and G.GameCfg.Throw and G.GameCfg.Throw.MeterBonusStuds or 20
	local _, p = F.meterPlan()
	return b * (p or ((V.Flags.accuracy or 90) / 100))
end
function F.bestArea()
	if not G.Areas then return 1 end
	local ok, v = pcall(G.Areas.MaxReachableArea, F.maxPower() + F.bonus())
	return ok and v or 1
end
function F.areaKey(index)
	local a = G.AreasCfg and G.AreasCfg.List and G.AreasCfg.List[index]
	return a and a.Key
end

-- The lowest reachable area that still has a missing animal in the Index
function F.nextMissingArea()
	if not (G.AnimalsData and G.AreasCfg) then return nil end
	local idx = D("Index") or {}
	local reach = F.bestArea()
	local bestIdx, bestKey, bestName
	for key, list in pairs(G.AnimalsData) do
		local ai = G.AreasCfg.IndexByKey and G.AreasCfg.IndexByKey[key]
		if ai and ai <= reach and type(list) == "table" then
			for _, a in pairs(list) do
				if type(a) == "table" and a.ModelName and not idx[a.ModelName] then
					if not bestIdx or ai < bestIdx then bestIdx, bestKey, bestName = ai, key, a.Name or a.ModelName end
					break
				end
			end
		end
	end
	return bestKey, bestName
end

function F.desiredArea()
	if V.Flags.autoIndex then
		local k, n = F.nextMissingArea()
		if k then return k, LF("Index: %s", tostring(n)) end
	end
	return V.Flags.targetArea or "Best"
end

function F.applyTarget()
	if not (G.Areas and G.AreasCfg) then return end
	local want = F.desiredArea()
	local power = 0
	if want ~= "Best" then
		local idx = G.AreasCfg.IndexByKey and G.AreasCfg.IndexByKey[want]
		if idx then
			local okd, dist = pcall(G.Areas.TargetDistanceForArea, idx)
			if okd then
				local need = math.floor(dist - F.bonus())
				local maxP = F.maxPower()
				need = math.clamp(need, F.minPower(), math.max(F.minPower(), maxP))
				power = (need >= maxP) and 0 or need
			end
		end
	end
	if V.lastPower ~= power then
		local r = inv("Player_SetThrowPower", power)
		if r.Ok then V.lastPower = power end
	end
end

-- Tap time for the meter target (first moment where ThrowMeterMath.Position(t) >= target)
-- maxT: wait at most this many seconds; if the target is unreachable in that time, pick the highest value reachable within it
function F.tapTime(acc, maxT)
	if not G.TMM then return 1 end
	local best, bestT = -1, 0.4
	local goal = math.clamp(acc, 0, 1)
	maxT = math.clamp(maxT or 8, 0.4, 8)
	local steps = math.floor((maxT - 0.4) / 0.005)
	for i = 0, steps do
		local t = 0.4 + i * 0.005
		local ok, p = pcall(G.TMM.Position, t)
		if ok and p then
			if p >= goal then return t, p end
			if p > best then best, bestT = p, t end
		end
	end
	return bestT, best
end
function F.meterPlan()
	local acc = (V.Flags.accuracy or 90) / 100
	local t, p = F.tapTime(acc, V.Flags.meterWait or 2)
	return t, p
end
function F.savedSupers() return (D("SuperThrows") or 0) + (D("FreeSuperThrows") or 0) end

function F.setMeterAuto(on)
	if not G.Meter then return end
	if on then
		local t = F.meterPlan()
		if V.Flags.useSuper and F.savedSupers() > 0 then t = math.max(t, 1.6) end
		G.Meter.TestAutoTap = t
	else
		G.Meter.TestAutoTap = nil
	end
end

function F.throwOnce()
	if busy() then return false end
	if G.Training and G.Training.IsRunning and G.Training.IsRunning() then
		pcall(G.Training.Stop)
		local e = os.clock() + 6
		while busy() and os.clock() < e and V.alive do task.wait(0.1) end
	end
	local sa = workspace:FindFirstChild("StarterArea")
	local line = sa and sa:FindFirstChild("CrossLine")
	local root = hrp()
	if not (sa and line and root) then return false end
	F.applyTarget()
	F.setMeterAuto(true)
	local top = sa.Position.Y + sa.Size.Y / 2
	local throwsBefore = D("Throws") or 0
	-- first step behind the line so the server sees our position, then cross it (otherwise it refuses with "TooFar")
	root.AssemblyLinearVelocity = Vector3.zero
	root.CFrame = CFrame.new(sa.Position.X, top + 3.5, line.Position.Z + 1.5)
	task.wait(0.45)
	root = hrp()
	if not root or busy() then return false end
	root.CFrame = CFrame.new(sa.Position.X, top + 3.5, line.Position.Z - 3)
	-- the game's own line check triggers Start; start it manually if that does not happen
	local e = os.clock() + 2.5
	while os.clock() < e and V.alive and busy() ~= "Throw" do task.wait(0.05) end
	if busy() ~= "Throw" and not busy() then
		task.spawn(G.Throw.Start)
		e = os.clock() + 2
		while os.clock() < e and V.alive and busy() ~= "Throw" do task.wait(0.05) end
	end
	if busy() ~= "Throw" then return false end
	e = os.clock() + 90
	while busy() == "Throw" and os.clock() < e and V.alive do task.wait(0.1) end
	task.wait(0.3)
	local landed = (D("Throws") or 0) > throwsBefore
	if landed then V.throwCount = (V.throwCount or 0) + 1 end
	return landed
end

function F.throwLoop()
	while V.alive do
		if V.Flags.autoThrow and G.Throw then
			if V.Flags.autoThrow and not V.autoSkipSet then
				V.autoSkipSet = true
				task.spawn(inv, "Player_SetSetting", "AutoSkip", true)
			end
			local ok, err = pcall(F.throwOnce)
			if not ok then warn("[A6Hub] throw: " .. tostring(err)) end
			sleep(math.max(1.55, V.Flags.throwDelay or 1.7))
		else
			if G.Meter and G.Meter.TestAutoTap then F.setMeterAuto(false) end
			task.wait(0.3)
		end
	end
end

-- Skip the reveal cutscene where the animal approaches: force CanSkip=true on Run and fire the game's "Confirm" skip callback
function F.hookReveal()
	if not (G.Reveal and G.Input) or V.origRun then return end
	V.origRun = G.Reveal.Run
	V.origBind = G.Input.BindPressed
	V.skipCbs = {}
	V.skipLog = {}
	G.Input.BindPressed = function(name, prio, cb, ...)
		-- Training bonus circle: the game binds a claim callback to the "Special" action; firing it imitates a real tap
		if name == "Special" and type(cb) == "function" then V.specialCb = cb; V.specialT = os.clock() end
		if V.revealing and name == "Confirm" and type(cb) == "function" then
			V.skipCbs[#V.skipCbs + 1] = {cb = cb, t = os.clock()}
			V.skipLog[#V.skipLog + 1] = string.format("bind#%d +%.2fs", #V.skipCbs, os.clock() - (V.revealStart or os.clock()))
		end
		return V.origBind(name, prio, cb, ...)
	end
	G.Reveal.Run = function(opts, ...)
		local skipPov, skipCard = V.Flags.skipCutscene == true, V.Flags.skipCard == true
		if not (skipPov or skipCard) or type(opts) ~= "table" then return V.origRun(opts, ...) end
		if skipPov then opts.CanSkip = true end
		V.revealing, V.skipCbs, V.revealStart, V.skipLog = true, {}, os.clock(), {}
		task.spawn(function()
			setId()
			while V.revealing and V.alive do
				for i, e in ipairs(V.skipCbs) do
					-- 1st registration: the animal approach cutscene (CanSkip). The rest: the result card "tap to continue"
					local allowed = (i == 1 and skipPov) or (i > 1 and V.Flags.skipCard == true)
					if allowed and not e.done and os.clock() - e.t >= 0.5 and os.clock() - (e.last or 0) >= 0.2 then
						e.last = os.clock()
						e.tries = (e.tries or 0) + 1
						local ok, res = pcall(e.cb)
						if i == 1 or (ok and res == true) or e.tries >= 15 then
							e.done = true
							if i == 1 then V.skipCount = (V.skipCount or 0) + 1 end
							V.skipLog[#V.skipLog + 1] = string.format("skip#%d +%.2fs (try %d, res=%s)", i, os.clock() - V.revealStart, e.tries, tostring(res))
						end
					end
				end
				task.wait(0.05)
			end
		end)
		local res = table.pack(pcall(V.origRun, opts, ...))
		V.revealing = false
		V.skipLog[#V.skipLog + 1] = string.format("done +%.2fs", os.clock() - V.revealStart)
		if not res[1] then error(res[2], 0) end
		return table.unpack(res, 2, res.n)
	end
end

function F.superLoop()
	local lastSuper
	while V.alive do
		local cur = V.curSuper
		if V.Flags.useSuper and V.Flags.autoThrow and cur and cur ~= lastSuper and not cur.Dead and cur.State == "Offer" and F.savedSupers() > 0 then
			lastSuper = cur
			pcall(function() cur:UseSaved() end)
		end
		task.wait(0.1)
	end
end

-- ===============================================================
-- FEATURES: TRAINING
-- ===============================================================
function F.tpTraining()
	local root = hrp()
	local props = workspace:FindFirstChild("LocalPlotProps")
	local ta = props and props:FindFirstChild("TrainingArea")
	local spot = ta and ta:FindFirstChild("TrainingSpot")
	if not (root and spot) then return false end
	root.AssemblyLinearVelocity = Vector3.zero
	root.CFrame = spot.CFrame * CFrame.new(0, spot.Size.Y / 2 + 3.5, 0)
	return true
end
-- Auto-tap the x2 bonus circle shown while training (Training_Bonus event -> Training_TapBonus)
function F.bonusHook()
	if V.bonusConn or not G.Remotes then return end
	local ok, ev = pcall(G.Remotes.Event, "Training_Bonus")
	if not ok or not ev then return end
	V.bonusConn = track(ev.OnClientEvent:Connect(function(id, expiry)
		if not V.Flags.autoTapBonus or id == nil then return end
		task.spawn(function()
			setId()
			task.wait(math.random(25, 50) / 100)
			if not V.alive then return end
			if (tonumber(expiry) or 0) - workspace:GetServerTimeNow() < 0.15 then return end
			-- 1) the game's own claim (visual circle + effect + remote)
			local cb = V.specialCb
			if cb and os.clock() - (V.specialT or 0) < 3 then
				local ok, res = pcall(cb)
				if ok and res == true then V.bonusCount = (V.bonusCount or 0) + 1; return end
			end
			-- 2) fallback: call the remote directly
			local r = inv("Training_TapBonus", id)
			if r.Ok then V.bonusCount = (V.bonusCount or 0) + 1 end
		end)
	end))
end
function F.trainLoop()
	F.bonusHook()
	while V.alive do
		if V.Flags.autoTrain and G.Training then
			if V.Flags.autoThrow then
				-- Throwing has priority
			elseif not busy() and not (G.Training.IsRunning and G.Training.IsRunning()) then
				if F.tpTraining() then
					task.wait(0.5)
					task.spawn(G.Training.Start)
					sleep(3)
				end
			end
		elseif G.Training and G.Training.IsRunning and G.Training.IsRunning() and V.trainStarted then
			V.trainStarted = nil
			pcall(G.Training.Stop)
		end
		if G.Training and G.Training.IsRunning and G.Training.IsRunning() then V.trainStarted = true end
		task.wait(0.5)
	end
end


-- ===============================================================
-- FEATURES: THANKSGIVING EVENT
-- Event every ~30 min, lasts ~5 min. Map theme + ingredients on throws.
-- Regular=3, Big=6, Mega=9 ingredients. Cook at feast hub left of safe zone.
-- ===============================================================
V.tg = { active = false, endsAt = 0, wasTrain = false, wasThrow = false, powerSnap = nil }

function F.tgDetectActive()
	-- Live Feast only (theme / NPC / attributes). False outside the 5-min window.
	local names = {
		"Thanksgiving", "Feast", "TurkeyChef", "Turkey Chef", "PicnicTable", "EventHub",
		"ThanksgivingTheme", "FeastActive", "EventThanksgiving",
	}
	for _, n in ipairs(names) do
		local o = workspace:FindFirstChild(n, true)
		if o then
			-- ignore permanent lobby props that always exist; prefer Active/Enabled flags
			local a = o:GetAttribute("Active")
			if a == nil or a == true then
				if o:GetAttribute("Enabled") == false then
					-- skip disabled
				else
					return true
				end
			end
		end
	end
	local attr = workspace:GetAttribute("ThanksgivingActive")
		or workspace:GetAttribute("FeastActive")
		or workspace:GetAttribute("EventActive")
	if attr == true then return true end
	if player:GetAttribute("Thanksgiving") == true then return true end
	if G.State then
		local s = G.State
		if s.Thanksgiving == true or s.Feast == true or s.EventName == "Thanksgiving" then return true end
		if type(s.Get) == "function" then
			local ok, v = pcall(s.Get, s, "Thanksgiving")
			if ok and v then return true end
		end
	end
	-- ReplicatedStorage flag folders
	local rs = game:GetService("ReplicatedStorage")
	for _, n in ipairs({"Thanksgiving", "Feast", "Events"}) do
		local f = rs:FindFirstChild(n)
		if f and (f:GetAttribute("Active") == true or f:GetAttribute("Enabled") == true) then return true end
	end
	return false
end

function F.tgSetPowerPlus20()
	local maxP = F.maxPower()
	local minP = F.minPower()
	local cur = F.effPower()
	local want = math.clamp((cur > 0 and cur or maxP) + 20, minP, math.max(minP, maxP))
	-- 0 means max in this game's SetThrowPower convention when at ceiling
	local power = (want >= maxP) and 0 or want
	local r = inv("Player_SetThrowPower", power)
	if r.Ok then V.lastPower = power end
	return power
end

function F.tgStart()
	if V.tg.active then return end
	V.tg.active = true
	V.tg.endsAt = os.clock() + 300
	V.tg.wasTrain = V.Flags.autoTrain == true
	V.tg.wasThrow = V.Flags.autoThrow == true
	V.tg.powerSnap = V.lastPower
	-- stop training priority
	if V.SilentSetters and V.SilentSetters.autoTrain then V.SilentSetters.autoTrain(false) end
	if G.Training and G.Training.IsRunning and G.Training.IsRunning() then pcall(G.Training.Stop) end
	F.tgSetPowerPlus20()
	if V.SilentSetters and V.SilentSetters.autoThrow then
		V.autoSkipSet = false
		V.SilentSetters.autoThrow(true)
		if V.SilentSetters.skipCutscene then V.SilentSetters.skipCutscene(true) end
		if V.SilentSetters.skipCard then V.SilentSetters.skipCard(true) end
	end
	V.notify("Thanksgiving Event", "Auto Throw Event started (+20 power)")
end

function F.tgStop()
	if not V.tg.active then return end
	V.tg.active = false
	-- ALWAYS restore prior mode (do not keep throwing after Feast)
	if V.SilentSetters and V.SilentSetters.autoThrow then
		V.SilentSetters.autoThrow(V.tg.wasThrow == true)
	end
	if V.Flags then
		-- hard sync flag if silent setter missing
		if not V.SilentSetters or not V.SilentSetters.autoThrow then
			V.Flags.autoThrow = (V.tg.wasThrow == true)
		end
	end
	if V.SilentSetters and V.SilentSetters.autoTrain then
		V.SilentSetters.autoTrain(V.tg.wasTrain == true)
	end
	if V.tg.powerSnap ~= nil then
		inv("Player_SetThrowPower", V.tg.powerSnap)
		V.lastPower = V.tg.powerSnap
	end
	V.notify("Thanksgiving Event", "Event ended — resumed previous mode")
end

function F.tgFindFeast()
	-- Picnic / Turkey Chef / Feast hub left of safe zone
	local names = {
		"Thanksgiving", "Feast", "TurkeyChef", "Turkey Chef", "PicnicTable", "Picnic Table",
		"EventHub", "Event Hub", "FeastHub", "Feast Hub", "ThanksgivingFeast", "CookTable",
	}
	for _, n in ipairs(names) do
		local o = workspace:FindFirstChild(n, true)
		if o then
			if o:IsA("BasePart") then return o end
			local p = o:FindFirstChildWhichIsA("BasePart", true)
			if p then return p end
			local pp = o.PrimaryPart or (o:IsA("Model") and o:FindFirstChild("HumanoidRootPart"))
			if pp then return pp end
		end
	end
	-- ProximityPrompt tagged cook
	for _, pr in ipairs(workspace:GetDescendants()) do
		if pr:IsA("ProximityPrompt") then
			local a = (pr.ActionText or "") .. " " .. (pr.ObjectText or "")
			if a:lower():find("cook") or a:lower():find("feast") or a:lower():find("thanksgiving") then
				local part = pr.Parent
				if part and part:IsA("BasePart") then return part end
				if part then
					local bp = part:FindFirstChildWhichIsA("BasePart") or part.Parent and part.Parent:FindFirstChildWhichIsA("BasePart")
					if bp then return bp end
				end
			end
		end
	end
	return nil
end

function F.tpFeast()
	local part = F.tgFindFeast()
	if not part then return false end
	return F.tpPart(part, 3)
end

function F.tgCook(size)
	-- Only ONE size at a time (dropdown flag). TP to feast hub then cook.
	size = size or V.Flags.tgSandwich or "Regular"
	if size ~= "Regular" and size ~= "Big" and size ~= "Mega" then size = "Regular" end
	if V.tgCooking then return false end
	V.tgCooking = true
	local okAny = false
	local ok, err = pcall(function()
		if not F.tpFeast() then
			V.notify("Cook failed", "Feast hub not found")
			return
		end
		task.wait(0.35)
		-- try proximity prompt near feast
		local part = F.tgFindFeast()
		if part then
			for _, pr in ipairs(part:GetDescendants()) do
				if pr:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(pr) end) end
			end
			if part.Parent then
				for _, pr in ipairs(part.Parent:GetDescendants()) do
					if pr:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(pr) end) end
				end
			end
		end
		task.wait(0.25)
		local remotes = {
			"Thanksgiving_Cook", "Feast_Cook", "Event_CookSandwich", "Thanksgiving_CookSandwich",
			"CookSandwich", "Feast_CookSandwich",
		}
		for _, name in ipairs(remotes) do
			local r = inv(name, size)
			if r.Ok then
				okAny = true
				V.notify("Cooked", tostring(size) .. " sandwich")
				break
			end
		end
		if not okAny and G.Remotes then
			for _, name in ipairs({"Thanksgiving_Cook", "Feast_Cook", "CookSandwich"}) do
				local ok2, ev = pcall(G.Remotes.Event, name)
				if ok2 and ev then
					pcall(function() ev:FireServer(size) end)
					okAny = true
					V.notify("Cooked", tostring(size) .. " sandwich")
					break
				end
			end
		end
		if not okAny then
			V.notify("Cook failed", "Remote not found — open Feast menu once")
		end
	end)
	V.tgCooking = false
	if not ok then warn("[A6Hub] tgCook: " .. tostring(err)) end
	return okAny
end

function F.tgLoop()
	local lastCheck = 0
	while V.alive do
		local ok, err = pcall(function()
			local now = os.clock()
			-- Auto Throw Event: ONLY throw while Feast is live. Never outside the window.
			if V.Flags.autoTgThrow then
				if now - lastCheck >= 1.5 then
					lastCheck = now
					local live = F.tgDetectActive()
					if live and not V.tg.active then
						F.tgStart()
					elseif V.tg.active then
						-- hard stop at 5 min or when theme ends
						if (not live) or now >= (V.tg.endsAt or 0) then
							F.tgStop()
						else
							-- keep throw ON only during active window
							if V.SilentSetters and V.SilentSetters.autoThrow and V.Flags.autoThrow ~= true then
								V.SilentSetters.autoThrow(true)
							end
						end
					end
				end
			else
				if V.tg.active then F.tgStop() end
			end
			-- Auto Cook: only during active event, one size, TP to feast first
			if V.Flags.autoTgCook and V.tg.active and not V.tgCooking then
				F.tgCook(V.Flags.tgSandwich or "Regular")
				task.wait(3.5)
			end
		end)
		if not ok then warn("[A6Hub] tg: " .. tostring(err)) end
		task.wait(0.4)
	end
end


-- ===============================================================
-- FEATURES: SHOP
-- ===============================================================
function F.ownedFood(i)
	local owned = D("OwnedFoods") or {}
	return owned[i] == true or owned[tostring(i)] == true
end
function F.bestOwnedFood()
	local list = G.Foods and G.Foods.List
	if not list then return nil end
	for i = #list, 1, -1 do if F.ownedFood(i) then return i end end
	return nil
end
function F.buyBestFood(silent)
	local list = G.Foods and G.Foods.List
	if not list then return false, "NoData" end
	local money = D("Money") or 0
	local ownedBest = F.bestOwnedFood() or 0
	for i = #list, ownedBest + 1, -1 do
		local f = list[i]
		if f and not F.ownedFood(i) and (f.Price or math.huge) <= money then
			local r = inv("Shop_Buy", i)
			if r.Ok then
				if not silent then V.notify("Food purchased", tostring(f.Name)) end
				return true
			elseif r.Reason ~= "Money" then
				-- locked / level requirement: try the next food down
			end
		end
	end
	return false, "Nothing"
end
function F.equipBestFood(silent)
	local best = F.bestOwnedFood()
	if not best then return false end
	if D("EquippedFood") == best then return false end
	local r = inv("Shop_Equip", best)
	if r.Ok and not silent then
		local f = G.Foods.List[best]
		V.notify("Food equipped", tostring(f and f.Name or best))
	end
	return r.Ok
end
function F.upgrade(remote, silent)
	local r = inv(remote)
	if r.Ok and not silent then V.notify("Upgrade successful", remote == "Stand_Upgrade" and "Bar" or "Fence") end
	return r.Ok, r.Reason
end
function F.shopLoop()
	local nextBar, nextFence = 0, 0
	while V.alive do
		local ok, err = pcall(function()
			if V.Flags.autoBuyFood then F.buyBestFood(true) end
			if V.Flags.autoEquipFood then F.equipBestFood(true) end
			if V.Flags.autoUpBar and os.clock() >= nextBar then
				local o, why = F.upgrade("Stand_Upgrade", true)
				nextBar = os.clock() + (o and 1 or (why == "Money" and 6 or 30))
			end
			if V.Flags.autoUpFence and os.clock() >= nextFence then
				local o, why = F.upgrade("Plot_UpgradeFence", true)
				nextFence = os.clock() + (o and 1 or (why == "Money" and 6 or 30))
			end
		end)
		if not ok then warn("[A6Hub] shop: " .. tostring(err)) end
		task.wait(1.5)
	end
end

-- ===============================================================
-- FEATURES: ANIMALS
-- ===============================================================
function F.rarityOf(modelName)
	if not G.Econ then return nil end
	local ok, e = pcall(G.Econ.Get, modelName)
	return ok and type(e) == "table" and e.Rarity or nil
end
-- ----- Auto Place -----
-- Income = base income x mutation multiplier x Size^IncomeExponent (verified against the game's total income)
function F.animalValue(a)
	local e = G.Econ and G.Econ.Get(a.ModelName)
	local inc = e and tonumber(e.Income) or 0
	local m = 1
	if a.Mutation and G.Mut and G.Mut.ByName and G.Mut.ByName[a.Mutation] then m = G.Mut.ByName[a.Mutation].Multiplier or 1 end
	local ex = G.Mut and G.Mut.Size and G.Mut.Size.IncomeExponent or 1.8
	return inc * m * ((tonumber(a.Size) or 1) ^ ex)
end
function F.rarityIdx(a)
	local r = F.rarityOf(a.ModelName)
	local e = r and G.Rarity and G.Rarity.ByName and G.Rarity.ByName[r]
	return e and e.Index or 0
end
function F.plotSlots()
	if G.Fence and G.Fence.SlotsFor then
		local ok, s = pcall(G.Fence.SlotsFor, D("FenceLevel") or 0)
		if ok and tonumber(s) then return tonumber(s) end
	end
	return G.Fence and G.Fence.BaseSlots or 10
end
function F.animalName(a)
	return (a.Mutation and (a.Mutation .. " ") or "") .. tostring(a.ModelName) .. ((tonumber(a.Size) or 1) > 1 and (" x" .. tostring(a.Size)) or "")
end
function F.plotState()
	local animals = D("Animals")
	local placed, unplaced = {}, {}
	if type(animals) == "table" then
		for id, a in pairs(animals) do
			if type(a) == "table" then
				local row = {id = id, a = a, v = F.animalValue(a), r = F.rarityIdx(a)}
				if a.Placed then placed[#placed + 1] = row else unplaced[#unplaced + 1] = row end
			end
		end
	end
	table.sort(placed, function(x, y) return x.v < y.v end)   -- worst first
	return placed, unplaced
end
local PLACE_ORDERS = {
	income = function(x, y) return x.v > y.v end,
	rarity = function(x, y) if x.r ~= y.r then return x.r > y.r end return x.v > y.v end,
	mutation = function(x, y)
		local mx, my = x.a.Mutation and 1 or 0, y.a.Mutation and 1 or 0
		if mx ~= my then return mx > my end
		return x.v > y.v
	end,
	size = function(x, y)
		local sx, sy = tonumber(x.a.Size) or 1, tonumber(y.a.Size) or 1
		if sx ~= sy then return sx > sy end
		return x.v > y.v
	end,
}
function F.minRarityIdx()
	local n = V.Flags.placeMinRarity or "Common"
	local e = G.Rarity and G.Rarity.ByName and G.Rarity.ByName[n]
	return e and e.Index or 1
end
-- would the candidate be placed? (the sell filter uses this too)
function F.wouldPlace(row, placed, slots)
	if row.r < F.minRarityIdx() then return false end
	if #placed < slots then return true end
	if V.Flags.replaceWorst then
		local worst
		for _, p in ipairs(placed) do
			if not (V.Flags.protectMutations and p.a.Mutation) then worst = p break end
		end
		return worst ~= nil and row.v > worst.v * (1 + (V.Flags.replaceMargin or 10) / 100)
	end
	return false
end
function F.placeTick(announce)
	local placed, unplaced = F.plotState()
	local slots = F.plotSlots()
	local cands = {}
	local minIdx = F.minRarityIdx()
	for _, row in ipairs(unplaced) do
		if row.r >= minIdx and not row.a.Locked then cands[#cands + 1] = row end
	end
	table.sort(cands, PLACE_ORDERS[V.Flags.placeOrder or "income"] or PLACE_ORDERS.income)
	local added, swapped, actions = 0, 0, 0
	for _, c in ipairs(cands) do
		if not V.alive or actions >= 8 then break end
		if #placed < slots then
			local r = inv("Plot_EquipAnimal", c.id)
			actions = actions + 1
			if r.Ok then
				added = added + 1
				placed[#placed + 1] = c
				table.sort(placed, function(x, y) return x.v < y.v end)
			elseif r.Reason == "Full" then
				slots = #placed
			end
			task.wait(0.2)
		elseif V.Flags.replaceWorst then
			local wi
			for i, p in ipairs(placed) do
				if not (V.Flags.protectMutations and p.a.Mutation) then wi = i break end
			end
			local worst = wi and placed[wi]
			if worst and c.v > worst.v * (1 + (V.Flags.replaceMargin or 10) / 100) then
				local pr = inv("Plot_PickUpAnimal", worst.id, true)
				actions = actions + 1
				task.wait(0.25)
				if pr.Ok then
					local er = inv("Plot_EquipAnimal", c.id)
					task.wait(0.25)
					if er.Ok then
						swapped = swapped + 1
						table.remove(placed, wi)
						placed[#placed + 1] = c
						table.sort(placed, function(x, y) return x.v < y.v end)
					else
						inv("Plot_EquipAnimal", worst.id)   -- on failure, put the old animal back
						task.wait(0.2)
					end
				end
			elseif PLACE_ORDERS[V.Flags.placeOrder or "income"] == PLACE_ORDERS.income then
				break   -- sorted by income: no better candidates left
			end
		else
			break
		end
	end
	if announce and (added > 0 or swapped > 0) then
		V.notify("Plot updated", LF("Placed: %d  •  Swapped: %d", added, swapped))
	end
	return added, swapped
end

function F.sellFiltered(silent)
	local animals = D("Animals")
	if type(animals) ~= "table" then return 0 end
	local sell = V.Flags.sellRarities or {}
	local keep = V.Flags.keepMutations or {}
	local sold, gained = 0, 0
	local placedList, slots
	if V.Flags.autoPlace then placedList, slots = (F.plotState()), F.plotSlots() end
	for id, a in pairs(animals) do
		if not V.alive then break end
		if type(a) == "table" and not a.Placed and not a.Locked and not a.Favorite then
			local rarity = F.rarityOf(a.ModelName)
			local special = a.Mutation and keep[a.Mutation]
			local large = V.Flags.keepLarge and (tonumber(a.Size) or 1) > 1
			-- do not sell animals that Auto Place would place
			local placeable = placedList and F.wouldPlace({a = a, v = F.animalValue(a), r = F.rarityIdx(a)}, placedList, slots)
			if rarity and sell[rarity] and not special and not large and not placeable then
				local r = inv("Plot_SellAnimal", id)
				if r.Ok then sold = sold + 1; gained = gained + (r.Money or 0) end
				task.wait(0.15)
			end
		end
	end
	if sold > 0 and not silent then V.notify(LF("Sold: %d animals", sold), "+$" .. fmtNum(gained)) end
	return sold
end
function F.animalsLoop()
	local nextEquip, nextSell, nextPlace = 0, 0, 0
	while V.alive do
		local ok, err = pcall(function()
			if V.Flags.autoPlace and os.clock() >= nextPlace then
				nextPlace = os.clock() + 5
				F.placeTick(true)
			end
			if V.Flags.autoEquipAnimals and os.clock() >= nextEquip then
				nextEquip = os.clock() + 10
				inv("Plot_EquipBest")
			end
			if V.Flags.autoSell and os.clock() >= nextSell then
				nextSell = os.clock() + 8
				F.sellFiltered(true)
			end
		end)
		if not ok then warn("[A6Hub] animals: " .. tostring(err)) end
		task.wait(1)
	end
end

-- ===============================================================
-- FEATURES: REWARDS
-- ===============================================================
function F.voteHook()
	if V.voteConn or not G.Remotes then return end
	local ok, ev = pcall(G.Remotes.Event, "AdminAbuse_VoteState")
	if not ok or not ev then return end
	V.voteConn = track(ev.OnClientEvent:Connect(function(state)
		if not V.Flags.autoVote or type(state) ~= "table" then return end
		local choice, top = nil, -1
		if type(state.Counts) == "table" then
			for k, c in pairs(state.Counts) do
				local n = tonumber(c) or 0
				if n > top then choice, top = k, n end
			end
		end
		if choice ~= nil and V.lastVote ~= choice then
			V.lastVote = choice
			task.delay(math.random(5, 20) / 10, function()
				local ok2, e2 = pcall(function() G.Remotes.Event("AdminAbuse_Vote"):FireServer(choice) end)
				if not ok2 then warn("[A6Hub] vote: " .. tostring(e2)) end
			end)
		end
	end))
end
function F.rewardsLoop()
	local nextGift, nextOffline = 0, 0
	while V.alive do
		pcall(function()
			if V.Flags.autoGifts and os.clock() >= nextGift then
				nextGift = os.clock() + 30
				inv("Shop_ClaimFree")
			end
			if V.Flags.autoOffline and os.clock() >= nextOffline then
				nextOffline = os.clock() + 30
				local p = D("OfflinePending")
				if type(p) == "table" and (p.Seconds or 0) > 0 then inv("Offline_Claim") end
			end
			if V.Flags.autoVote then F.voteHook() end
		end)
		task.wait(1)
	end
end

-- ===============================================================
-- AUTO FARM (orchestrator that drives every automation from one place)
-- ===============================================================
V.farmOwned = {}
V.farmMap = {
	farmPlace = {"autoPlace"},
	farmFood = {"autoBuyFood", "autoEquipFood"},
	farmUpgrades = {"autoUpBar", "autoUpFence"},
	farmSell = {"autoSell"},
	farmRewards = {"autoGifts", "autoOffline", "autoVote"},
	farmIndex = {"autoIndex"},
}
-- Auto Farm "owns" the settings it turns on; when it stops it only turns off what it enabled itself
function F.farmSet(key, want)
	local cur = V.Flags[key] == true
	local setter = V.SilentSetters and V.SilentSetters[key]
	if not setter then return end
	if want and not cur then
		setter(true); V.farmOwned[key] = true
	elseif not want and cur and V.farmOwned[key] then
		setter(false); V.farmOwned[key] = nil
	end
end
function F.applyFarm()
	local on = V.Flags.autoFarm == true
	for mod, keys in pairs(V.farmMap) do
		for _, k in ipairs(keys) do F.farmSet(k, on and V.Flags[mod] == true) end
	end
	if not on then
		F.farmSet("autoThrow", false); F.farmSet("autoTrain", false); F.farmSet("skipCutscene", false); F.farmSet("skipCard", false)
		V.farm = nil
	elseif V.farm then
		V.farm.phase = nil   -- re-evaluate the throw/train phase
	end
end
function F.stopFarm(reason)
	if V.SilentSetters and V.SilentSetters.autoFarm then V.SilentSetters.autoFarm(false) end
	F.applyFarm()
	V.notify("Auto Farm stopped", tostring(reason or ""))
end
function F.farmStats()
	local f = V.farm
	if not f then return nil end
	local el = os.clock() - f.t0
	local gained = (D("Money") or 0) - f.money0
	return {
		elapsed = el, throws = (V.throwCount or 0) - f.throws0, gained = gained,
		perHour = el > 30 and gained / el * 3600 or 0, phase = f.phase,
	}
end
function F.farmTick()
	if V.Flags.autoFarm ~= true then V.farm = nil; return end
	local f = V.farm
	if not f then
		f = {t0 = os.clock(), throws0 = V.throwCount or 0, money0 = D("Money") or 0}
		V.farm = f
		if V.Flags.farmThrow then F.farmSet("skipCutscene", true); F.farmSet("skipCard", true) end
	end
	local stopThrows = V.Flags.farmStopThrows or 0
	if stopThrows > 0 and (V.throwCount or 0) - f.throws0 >= stopThrows then F.stopFarm("Throw target reached"); return end
	local stopMin = V.Flags.farmStopMinutes or 0
	if stopMin > 0 and (os.clock() - f.t0) / 60 >= stopMin then F.stopFarm("Time limit reached"); return end
	local wantThrow, wantTrain = V.Flags.farmThrow == true, V.Flags.farmTrain == true
	local phase
	if wantThrow and not wantTrain then phase = "throw"
	elseif wantTrain and not wantThrow then phase = "train"
	elseif not wantThrow and not wantTrain then phase = "none"
	else
		local mode = V.Flags.farmMode or "throw"
		if mode == "throw" then phase = "throw"
		elseif mode == "train" then phase = "train"
		else
			f.cyc = f.cyc or {phase = "throw", t = os.clock(), c = V.throwCount or 0}
			local c = f.cyc
			if c.phase == "throw" and (V.throwCount or 0) - c.c >= (V.Flags.farmCycleThrows or 5) and not busy() then
				c.phase, c.t = "train", os.clock()
			elseif c.phase == "train" and os.clock() - c.t >= (V.Flags.farmCycleTrain or 60) then
				c.phase, c.t, c.c = "throw", os.clock(), V.throwCount or 0
			end
			phase = c.phase
		end
	end
	if f.phase ~= phase then
		f.phase = phase
		-- turn off what must close first, then turn on what must open (never both at once)
		if phase ~= "throw" then F.farmSet("autoThrow", false) end
		if phase ~= "train" then F.farmSet("autoTrain", false) end
		if phase == "throw" then V.autoSkipSet = false; F.farmSet("autoThrow", true) end
		if phase == "train" then F.farmSet("autoTrain", true) end
		-- keep the module flags up to date too
		for mod, keys in pairs(V.farmMap) do
			for _, k in ipairs(keys) do F.farmSet(k, V.Flags[mod] == true) end
		end
	end
end
function F.farmLoop()
	while V.alive do
		local ok, err = pcall(F.farmTick)
		if not ok then warn("[A6Hub] farm: " .. tostring(err)) end
		task.wait(0.5)
	end
end

-- ===============================================================
-- TELEPORTS
-- ===============================================================
function F.tp(cf)
	local root = hrp()
	if not root then return false end
	if busy() then V.notify("Not possible right now", "Wait for the throw/training to finish") return false end
	root.AssemblyLinearVelocity = Vector3.zero
	root.CFrame = cf
	return true
end
function F.tpPart(part, up)
	if part and part:IsA("BasePart") then return F.tp(part.CFrame * CFrame.new(0, part.Size.Y / 2 + (up or 4), 0)) end
	return false
end
function F.tpLine()
	local sa = workspace:FindFirstChild("StarterArea")
	local line = sa and sa:FindFirstChild("CrossLine")
	if sa and line then
		F.tp(CFrame.new(sa.Position.X, sa.Position.Y + sa.Size.Y / 2 + 3.5, line.Position.Z + 4))
	end
end
function F.tpPlot(i)
	local plots = workspace:FindFirstChild("Plots")
	local p = plots and plots:FindFirstChild(tostring(i))
	if not p then V.notify("Plot not found", tostring(i)) return end
	F.tpPart(p, 5)
end
function F.tpMyPlot()
	local i = player:GetAttribute("PlotIndex")
	if i then F.tpPlot(i) else V.notify("No plot", "PlotIndex is not assigned") end
end
function F.tpShop()
	if busy() then return end
	local ok = G.Plot and G.Plot.TeleportToShop and pcall(G.Plot.TeleportToShop)
	if not ok then
		local props = workspace:FindFirstChild("LocalPlotProps")
		local s = props and props:FindFirstChild("FoodShop")
		if s then F.tp(s:GetPivot() * CFrame.new(0, 4, 6)) end
	end
end
function F.tpStand()
	if busy() then return end
	local ok = G.Plot and G.Plot.TeleportToStand and pcall(G.Plot.TeleportToStand)
	if not ok then V.notify("Stand not found", "") end
end
function F.tpSell()
	local sp = workspace:FindFirstChild("SellPlace")
	local pad = sp and sp:FindFirstChild("ZonePad")
	if not F.tpPart(pad, 4) then V.notify("Sell Stand not found", "") end
end

-- ===============================================================
-- MOVEMENT
-- ===============================================================
function F.moveStart()
	local h0 = hum()
	V.defaultWS = V.defaultWS or (h0 and h0.WalkSpeed) or 16
	V.defaultJP = V.defaultJP or (h0 and h0.JumpPower) or 50
	track(RunService.Heartbeat:Connect(function()
		if not V.alive then return end
		local h = hum()
		if h and not busy() then
			local ws, jp = V.Flags.walkSpeed, V.Flags.jumpPower
			if ws and V.wsTouched and h.WalkSpeed ~= ws then h.WalkSpeed = ws end
			if jp and V.jpTouched then
				if not h.UseJumpPower then h.UseJumpPower = true end
				if h.JumpPower ~= jp then h.JumpPower = jp end
			end
		end
	end))
	track(RunService.Stepped:Connect(function()
		if not V.alive or not V.Flags.noclip or busy() then return end
		local c = char()
		if not c then return end
		for _, p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
		end
	end))
	track(UIS.JumpRequest:Connect(function()
		if V.Flags.infJump then
			local h = hum()
			if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end))
end

-- ===============================================================
-- QoL
-- ===============================================================
function F.antiAfk()
	track(player.Idled:Connect(function()
		if not V.Flags.antiAfk then return end
		local ok, vu = pcall(function() return game:GetService("VirtualUser") end)
		if ok and vu then
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end
	end))
	task.spawn(function()
		setId()
		while V.alive do
			task.wait(55)
			if V.Flags.antiAfk and not busy() then
				local ok, vu = pcall(function() return game:GetService("VirtualUser") end)
				if ok and vu then pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end) end
			end
		end
	end)
end
function F.rejoin()
	V.notify("Rejoining", "Returning to the same server")
	task.delay(0.4, function()
		pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
	end)
end
local function httpGet(url)
	local fn = (syn and syn.request) or request or http_request or (http and http.request)
	if fn then
		local ok, r = pcall(fn, {Url = url, Method = "GET"})
		if ok and r and r.Body then return r.Body end
	end
	local ok, b = pcall(function() return game:HttpGet(url) end)
	return ok and b or nil
end
-- ===============================================================
-- PRESENCE: active user counter shared through the A6 API
-- The server counts Emote and Hub users together (each Roblox user once), so this script
-- registers itself as a Hub user and reads back that same total.
-- Sent data: Roblox user id / names, place, job id, executor name and the script version.
-- ===============================================================
local API_BASE = "https://a6hub.example/api"
local HUB_VERSION = "A6 TFFA 1.0"
local function httpJson(method, url, body)
	local fn = (syn and syn.request) or request or http_request or (http and http.request) or (fluxus and fluxus.request)
	if not fn then return nil, 0 end
	local req = {Url = url, Method = method, Headers = {["Content-Type"] = "application/json"}}
	if body then req.Body = HttpService:JSONEncode(body) end
	local ok, res = pcall(fn, req)
	if not ok or type(res) ~= "table" then return nil, 0 end
	local dok, data = pcall(HttpService.JSONDecode, HttpService, res.Body or "")
	return dok and data or nil, res.StatusCode or 0
end
function V.sendHeartbeat()
	if not V.placeName then
		local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
		V.placeName = (ok and type(info) == "table" and tostring(info.Name or "")) or ""
		if V.placeName == "" then V.placeName = "Throw Food For Animals" end
	end
	local executor = "Unknown"
	if type(identifyexecutor) == "function" then
		local ok, name = pcall(identifyexecutor)
		if ok and name then executor = tostring(name) end
	end
	local data = httpJson("POST", API_BASE .. "/hub/heartbeat", {
		userId = player.UserId, username = player.Name, displayName = player.DisplayName,
		placeId = game.PlaceId, placeName = V.placeName, jobId = tostring(game.JobId),
		executor = executor, version = HUB_VERSION,
	})
	V.apiOk = type(data) == "table" and data.ok == true
end
function V.sendDisconnect()
	pcall(httpJson, "POST", API_BASE .. "/hub/disconnect", {userId = player.UserId})
end
function V.fetchActive()
	local data = httpJson("GET", API_BASE .. "/emote/active-avatars")
	local n = type(data) == "table" and tonumber(data.active)
	if n and n == n and n >= 0 and n < math.huge then V.activeUsers = math.floor(n) end
end
function F.presenceLoop()
	local nextBeat, nextCount = 0, 0
	while V.alive do
		local t = os.clock()
		if t >= nextBeat then
			nextBeat = t + 25   -- the server forgets a hub user after 75 s without a heartbeat
			pcall(V.sendHeartbeat)
			nextCount = math.min(nextCount, t)   -- read the total right after registering
		end
		if t >= nextCount then
			nextCount = t + 30
			pcall(V.fetchActive)
		end
		task.wait(1)
	end
end

function F.serverHop()
	V.notify("Searching for a server", "Picking an emptier server")
	local body = httpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
	local ok, data = pcall(function() return HttpService:JSONDecode(body or "{}") end)
	if not ok or type(data) ~= "table" or type(data.data) ~= "table" then V.notify("Could not fetch the server list", "Try again later") return end
	local pick
	for _, s in ipairs(data.data) do
		if s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 0) - 1 then
			if not pick or (s.playing or 0) < (pick.playing or 0) then pick = s end
		end
	end
	if not pick then V.notify("No suitable server", "") return end
	pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, player) end)
end

-- ===============================================================
-- CONFIG
-- ===============================================================
local FOLDER = "A6HubAnimalThrow"
local hasFS = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
local function ensureFolder()
	if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(FOLDER) then pcall(makefolder, FOLDER) end
end
function V.configList()
	local out = {}
	if hasFS and type(listfiles) == "function" and type(isfolder) == "function" and isfolder(FOLDER) then
		local ok, files = pcall(listfiles, FOLDER)
		if ok then
			for _, f in ipairs(files) do
				local n = tostring(f):match("([^/\\]+)%.json$")
				if n then out[#out + 1] = n end
			end
		end
	end
	table.sort(out)
	return out
end
function V.saveConfig(name)
	if not hasFS then V.notify("Could not save config", "Your executor does not support the file system") return false end
	name = (name and name ~= "" and name or V.cfgName):gsub("[^%w%-_ ]", "")
	if name == "" then name = "default" end
	ensureFolder()
	local ok, err = pcall(function() writefile(FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(V.Flags)) end)
	if ok then V.cfgName = name else V.notify("Could not save config", tostring(err):sub(1, 80)) end
	return ok
end
function V.loadConfig(name)
	if not hasFS then V.notify("Could not load config", "Your executor does not support the file system") return false end
	local path = FOLDER .. "/" .. tostring(name) .. ".json"
	if not isfile(path) then V.notify("Config not found", tostring(name)) return false end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not ok or type(data) ~= "table" then V.notify("Config is corrupted", tostring(name)) return false end
	V.loading = true
	for key, setter in pairs(V.Setters) do
		if data[key] ~= nil and key ~= "autoSave" and key ~= "autoLoadCfg" then pcall(setter, data[key]) end
	end
	if data.autoSave ~= nil and V.Setters.autoSave then pcall(V.Setters.autoSave, data.autoSave) end
	V.loading = false
	V.cfgName = name
	return true
end
function V.deleteConfig(name)
	local path = FOLDER .. "/" .. tostring(name) .. ".json"
	if hasFS and type(delfile) == "function" and isfile(path) then
		pcall(delfile, path)
		return true
	end
	return false
end
function V.setAutoLoad(name)
	if not hasFS then return end
	ensureFolder()
	if name then pcall(writefile, FOLDER .. "/autoload.txt", name)
	elseif type(delfile) == "function" and isfile(FOLDER .. "/autoload.txt") then pcall(delfile, FOLDER .. "/autoload.txt") end
end
function V.getAutoLoad()
	if hasFS and isfile(FOLDER .. "/autoload.txt") then
		local ok, n = pcall(readfile, FOLDER .. "/autoload.txt")
		if ok and n and n ~= "" then return (n:gsub("%s+$", "")) end
	end
	return nil
end
-- Language and theme are stored apart from the feature configs (they belong to the player, not to a farm preset)
local LANG_CODES = {"TR", "EN", "ES", "AR", "FR", "HI", "PT", "RU", "DE", "ID", "JA", "KO", "VI", "ZH", "IT", "PL", "TH", "FIL", "MS"}
function V.loadSettings()
	if not hasFS then return false end
	local path = FOLDER .. "/settings.json"
	if not isfile(path) then return false end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not ok or type(data) ~= "table" then return false end
	if table.find(LANG_CODES, data.language) then V.lang = data.language end
	if V.Themes[data.theme] then V.applyTheme(data.theme) end
	return true
end
function V.saveSettings()
	if not hasFS then return end
	ensureFolder()
	pcall(writefile, FOLDER .. "/settings.json", HttpService:JSONEncode({language = V.lang, theme = V.theme}))
end
function V.changed()
	if V.loading or not V.Flags.autoSave then return end
	V.saveVersion = (V.saveVersion or 0) + 1
	local v = V.saveVersion
	task.delay(1, function() if V.alive and V.saveVersion == v then V.saveConfig(V.cfgName) end end)
end

-- ===============================================================
-- ICONS (Fluent UI System Icons, converted to white PNGs and hosted on a6hub.com.tr)
-- Downloaded once, cached in the executor workspace and shown through getcustomasset.
-- If the site is unreachable or the executor lacks the file APIs, the UI simply shows no icons.
-- ===============================================================
local ICON_BASE = "https://a6hub.example/assets/icons/"
local ICON_VERSION = 5   -- bump this when the hosted PNGs change so the cache is refreshed
local ICON_NAMES = {
	"autofarm", "throwing", "training", "thanksgiving", "index", "shop", "animals", "rewards", "teleports",
	"movement", "qol", "stats", "settings", "minimize", "close", "info", "search", "people", "play", "stop", "chat", "open", "check",
}
V.iconAssets, V.iconWaiters = {}, {}

-- Creates an ImageLabel that fills itself in as soon as the icon is available (tintable via ImageColor3)
function V.icon(parent, name, size, color, onLoad)
	local img = make("ImageLabel", {
		Name = "Icon", BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size),
		ImageColor3 = color or T.dim, ScaleType = Enum.ScaleType.Fit, Image = "",
	}, parent)
	local function apply(asset)
		if img.Parent then
			img.Image = asset
			if onLoad then pcall(onLoad, img) end
		end
	end
	if V.iconAssets[name] then apply(V.iconAssets[name])
	else
		V.iconWaiters[name] = V.iconWaiters[name] or {}
		table.insert(V.iconWaiters[name], apply)
	end
	return img
end
function V.fetchIcons()
	task.spawn(function()
		setId()
		local getAsset = getcustomasset or getsynasset
		if not (hasFS and type(getAsset) == "function" and type(makefolder) == "function") then return end
		ensureFolder()
		local dir = FOLDER .. "/icons"
		if not isfolder(dir) then pcall(makefolder, dir) end
		for _, name in ipairs(ICON_NAMES) do
			if not V.alive then return end
			local path = dir .. "/" .. name .. "_v" .. ICON_VERSION .. ".png"
			if not isfile(path) then
				for attempt = 1, 2 do
					local body = httpGet(ICON_BASE .. name .. ".png?v=" .. ICON_VERSION)
					if type(body) == "string" and body:sub(2, 4) == "PNG" then pcall(writefile, path, body) break end
					task.wait(2)
				end
			end
			if isfile(path) then
				local ok, asset = pcall(getAsset, path)
				if ok and asset then
					V.iconAssets[name] = asset
					for _, fn in ipairs(V.iconWaiters[name] or {}) do pcall(fn, asset) end
					V.iconWaiters[name] = nil
				end
			end
		end
	end)
end


-- Maple-leaf style particle burst for Thanksgiving tab (Canada maple colors)
function V.playMapleFX(parent)
	if not parent then return end
	local holder = parent:FindFirstChild("MapleFX")
	if holder then holder:Destroy() end
	holder = make("Frame", {Name = "MapleFX", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, ClipsDescendants = true}, parent)
	local colors = {
		Color3.fromRGB(200, 40, 40), Color3.fromRGB(220, 90, 30), Color3.fromRGB(230, 150, 40),
		Color3.fromRGB(180, 50, 20), Color3.fromRGB(240, 180, 60), Color3.fromRGB(160, 30, 30),
	}
	for i = 1, 18 do
		local leaf = make("TextLabel", {
			BackgroundTransparency = 1, Text = "🍁", TextSize = math.random(14, 22),
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(math.random(), 0, -0.05, 0),
			TextColor3 = colors[math.random(1, #colors)], ZIndex = 6, Rotation = math.random(-30, 30),
		}, holder)
		local delay = math.random() * 0.8
		task.delay(delay, function()
			if not leaf.Parent then return end
			local dur = 2.2 + math.random() * 1.4
			tween(leaf, {
				Position = UDim2.new(leaf.Position.X.Scale + (math.random() - 0.5) * 0.25, 0, 1.05, 0),
				Rotation = leaf.Rotation + math.random(-90, 90),
				TextTransparency = 0.15,
			}, dur, Enum.EasingStyle.Quad)
			task.delay(dur + 0.05, function() if leaf.Parent then leaf:Destroy() end end)
		end)
	end
	task.delay(4.5, function() if holder.Parent then holder:Destroy() end end)
end

-- ===============================================================
-- UI: WINDOW (A6 Hub layout)
-- ===============================================================
local Page = {}
Page.__index = Page

function Page:row(h)
	local r = make("Frame", {BackgroundColor3 = T.panel, BorderSizePixel = 0, Size = UDim2.new(1, -2, 0, h or 54), LayoutOrder = self.order}, self.frame)
	self.order = self.order + 1
	round(r, 10); stroke(r)
	return r
end
function Page:Section(text)
	local l = label(self.frame, V.upper(L(text)), 11, true)
	l.Size = UDim2.new(1, 0, 0, 26); l.LayoutOrder = self.order; self.order = self.order + 1
	return l
end
function Page:Info(text)
	local l = label(self.frame, text, 12, true)
	l.Size = UDim2.new(1, -2, 0, 34); l.TextWrapped = true; l.TextTruncate = Enum.TextTruncate.None
	l.LayoutOrder = self.order; self.order = self.order + 1
	return l
end
-- The same key can appear on several tabs ("mirror"): the first control created decides the default and the callback,
-- the others only share the display and are repainted together on every change.
V.Callbacks = {}
V.Paints = {}
function V.addPaint(key, fn)
	V.Paints[key] = V.Paints[key] or {}
	table.insert(V.Paints[key], fn)
end
function V.syncPaint(key)
	for _, fn in ipairs(V.Paints[key] or {}) do pcall(fn) end
end

function Page:Toggle(key, text, default, cb)
	local first = V.Defaults[key] == nil
	if first then
		V.Defaults[key] = default and true or false
		if V.Flags[key] == nil then V.Flags[key] = V.Defaults[key] end   -- keep the value when the UI is rebuilt
		V.Callbacks[key] = cb
	end
	local row = self:row(54)
	local t = label(row, text, 14); t.Position = UDim2.fromOffset(14, 15); t.Size = UDim2.new(1, -120, 0, 24)
	local b
	local function paint()
		local v = V.Flags[key] == true
		b.Text = L(v and "On" or "Off")
		b.BackgroundColor3 = v and T.accent or T.raised
		b.TextColor3 = v and T.onAccent or T.text
	end
	local function set(v, silent)
		V.Flags[key] = v and true or false
		V.syncPaint(key)
		if not silent then
			local fn = V.Callbacks[key]
			if fn then task.spawn(fn, V.Flags[key]) end
			V.changed()
		end
	end
	b = button(row, "Off", function() set(not V.Flags[key]) end, 82)
	b.AnchorPoint = Vector2.new(1, 0.5); b.Position = UDim2.new(1, -12, 0.5, 0)
	if first then
		V.Setters[key] = function(v) set(v) end
		V.SilentSetters = V.SilentSetters or {}
		V.SilentSetters[key] = function(v) set(v, true); V.changed() end
	end
	V.addPaint(key, paint)
	paint()
	return row
end

function Page:Slider(key, text, min, max, default, step, suffix, cb)
	step = step or 1
	local first = V.Defaults[key] == nil
	if first then
		V.Defaults[key] = default
		if V.Flags[key] == nil then V.Flags[key] = default end
		V.Callbacks[key] = cb
	end
	local row = self:row(66)
	local t = label(row, text, 14); t.Position = UDim2.fromOffset(14, 8); t.Size = UDim2.new(1, -150, 0, 24)
	local val = label(row, "", 13, true); val.AnchorPoint = Vector2.new(1, 0); val.Position = UDim2.new(1, -14, 0, 8)
	val.Size = UDim2.fromOffset(120, 24); val.TextXAlignment = Enum.TextXAlignment.Right
	local bar = make("Frame", {Position = UDim2.new(0, 14, 0, 44), Size = UDim2.new(1, -28, 0, 6), BackgroundColor3 = T.raised, BorderSizePixel = 0}, row)
	round(bar, 3)
	local fill = make("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.accent, BorderSizePixel = 0}, bar); round(fill, 3)
	local knob = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = T.accent, BorderSizePixel = 0, ZIndex = 3}, bar)
	round(knob, 7)
	local hit = make("TextButton", {Text = "", BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 34), Size = UDim2.new(1, -28, 0, 26), ZIndex = 4}, row)
	local function paint()
		local v = tonumber(V.Flags[key]) or default
		local a = (v - min) / math.max(max - min, 1e-9)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		val.Text = (step < 1 and string.format("%.1f", v) or tostring(v)) .. LS(suffix)
	end
	local function set(v, silent)
		v = tonumber(v) or default
		v = math.clamp(math.floor((v - min) / step + 0.5) * step + min, min, max)
		V.Flags[key] = v
		V.syncPaint(key)
		if not silent then
			local fn = V.Callbacks[key]
			if fn then task.spawn(fn, v) end
			V.changed()
		end
	end
	local dragging
	local function fromX(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		set(min + a * (max - min))
	end
	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = i; fromX(i.Position.X)
		end
	end)
	uiTrack(UIS.InputChanged:Connect(function(i)
		if dragging and (i == dragging or i.UserInputType == Enum.UserInputType.MouseMovement) then fromX(i.Position.X) end
	end))
	uiTrack(UIS.InputEnded:Connect(function(i) if i == dragging then dragging = nil end end))
	if first then
		V.Setters[key] = function(v) set(v) end
		V.SilentSetters = V.SilentSetters or {}
		V.SilentSetters[key] = function(v) set(v, true) end
	end
	V.addPaint(key, paint)
	paint()
	return row
end

function Page:Dropdown(key, text, options, default, cb)
	-- options: { {v=, label=}, ... }
	local first = V.Defaults[key] == nil
	if first then
		V.Defaults[key] = default
		if V.Flags[key] == nil then V.Flags[key] = default end
		V.Callbacks[key] = cb
	end
	local row = self:row(54)
	local t = label(row, text, 14); t.Position = UDim2.fromOffset(14, 15); t.Size = UDim2.new(1, -240, 0, 24)
	local function labelOf(v)
		for _, o in ipairs(options) do if o.v == v then return o.label end end
		return tostring(v)
	end
	local b
	local function paint() b.Text = L(labelOf(V.Flags[key])) end
	local function set(v, silent)
		V.Flags[key] = v
		V.syncPaint(key)
		if not silent then
			local fn = V.Callbacks[key]
			if fn then task.spawn(fn, v) end
			V.changed()
		end
	end
	b = button(row, labelOf(default), function()
		V.modal(text, function(list, close)
			for _, o in ipairs(options) do
				local ob = button(list, o.label, function() set(o.v); close() end, 354)
				ob.Size = UDim2.new(1, -8, 0, 36)
				if V.Flags[key] == o.v then ob.BackgroundColor3 = T.accent; ob.TextColor3 = T.onAccent end
			end
		end, 390, 460)
	end, 200)
	b.AnchorPoint = Vector2.new(1, 0.5); b.Position = UDim2.new(1, -12, 0.5, 0)
	if first then
		V.Setters[key] = function(v) set(v) end
		V.SilentSetters = V.SilentSetters or {}
		V.SilentSetters[key] = function(v) set(v, true) end
	end
	V.addPaint(key, paint)
	paint()
	return row
end

function Page:Multi(key, text, options, defaults)
	local first = V.Defaults[key] == nil
	local function sanitize(tbl)
		local clean = {}
		for _, o in ipairs(options) do if type(tbl) == "table" and tbl[o] then clean[o] = true end end
		return clean
	end
	if first then
		V.Defaults[key] = defaults
		V.Flags[key] = sanitize(V.Flags[key] ~= nil and V.Flags[key] or defaults)
	end
	local row = self:row(54)
	local t = label(row, text, 14); t.Position = UDim2.fromOffset(14, 15); t.Size = UDim2.new(1, -200, 0, 24)
	local b
	local function paint()
		local n = 0
		for _, o in ipairs(options) do if V.Flags[key][o] then n = n + 1 end end
		b.Text = LF("%d / %d selected", n, #options)
	end
	local function set(tbl, silent)
		V.Flags[key] = sanitize(tbl)
		V.syncPaint(key)
		if not silent then V.changed() end
	end
	b = button(row, "", function()
		V.modal(text, function(list, close)
			for _, o in ipairs(options) do
				local r = make("Frame", {BackgroundColor3 = T.panel, BorderSizePixel = 0, Size = UDim2.new(1, -8, 0, 40)}, list)
				round(r, 8); stroke(r)
				local l = label(r, o, 14); l.Position = UDim2.fromOffset(12, 8); l.Size = UDim2.new(1, -110, 0, 24)
				local tb
				local function paintOpt()
					local on = V.Flags[key][o] == true
					tb.Text = L(on and "On" or "Off"); tb.BackgroundColor3 = on and T.accent or T.raised; tb.TextColor3 = on and T.onAccent or T.text
				end
				tb = button(r, "Off", function()
					local nt = table.clone(V.Flags[key]); nt[o] = (not nt[o]) or nil
					set(nt); paintOpt()
				end, 70)
				tb.AnchorPoint = Vector2.new(1, 0.5); tb.Position = UDim2.new(1, -8, 0.5, 0); tb.Size = UDim2.fromOffset(70, 28)
				paintOpt()
			end
		end, 390, 480)
	end, 160)
	b.AnchorPoint = Vector2.new(1, 0.5); b.Position = UDim2.new(1, -12, 0.5, 0)
	if first then V.Setters[key] = function(v) set(v) end end
	V.addPaint(key, paint)
	paint()
	return row
end
function Page:Button(text, btnText, cb, width)
	local row = self:row(54)
	local t = label(row, text, 14); t.Position = UDim2.fromOffset(14, 15); t.Size = UDim2.new(1, -(width or 140) - 40, 0, 24)
	local b = button(row, btnText, cb, width or 130)
	b.AnchorPoint = Vector2.new(1, 0.5); b.Position = UDim2.new(1, -12, 0.5, 0)
	return row, b
end
function Page:Stat(text, getter)
	local row = self:row(54)
	local t = label(row, text, 14); t.Position = UDim2.fromOffset(14, 15); t.Size = UDim2.new(0.5, -14, 0, 24)
	local v = label(row, "-", 14); v.AnchorPoint = Vector2.new(1, 0); v.Position = UDim2.new(1, -14, 0, 15)
	v.Size = UDim2.new(0.5, -14, 0, 24); v.TextXAlignment = Enum.TextXAlignment.Right; v.Font = Enum.Font.GothamMedium
	V.Tickers[#V.Tickers + 1] = function()
		local ok, s = pcall(getter)
		v.Text = L(ok and tostring(s) or "-")
	end
	return row
end
function Page:Input(text, placeholder, default)
	local row = self:row(54)
	local t = label(row, text, 14); t.Position = UDim2.fromOffset(14, 15); t.Size = UDim2.new(1, -250, 0, 24)
	local box = make("TextBox", {
		PlaceholderText = placeholder, Text = default or "", TextSize = 13, Font = Enum.Font.Gotham, ClearTextOnFocus = false,
		TextColor3 = T.text, PlaceholderColor3 = T.dim, BackgroundColor3 = T.raised, BorderSizePixel = 0,
		Size = UDim2.fromOffset(220, 34), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	round(box, 8)
	make("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, box)
	return box
end
function Page:Keybind(key, text, default)
	local row = self:row(54)
	local t = label(row, text, 14); t.Position = UDim2.fromOffset(14, 15); t.Size = UDim2.new(1, -200, 0, 24)
	local b
	local function set(v, silent)
		V.Flags[key] = v
		b.Text = tostring(v)
		if not silent then V.changed() end
	end
	b = button(row, default, function()
		b.Text = L("Press a key...")
		V.capturing = true
		local conn
		conn = UIS.InputBegan:Connect(function(i, gp)
			if i.UserInputType == Enum.UserInputType.Keyboard then
				conn:Disconnect()
				V.capturing = false
				if i.KeyCode == Enum.KeyCode.Escape then b.Text = tostring(V.Flags[key]) else set(i.KeyCode.Name) end
			end
		end)
	end, 150)
	b.AnchorPoint = Vector2.new(1, 0.5); b.Position = UDim2.new(1, -12, 0.5, 0)
	V.Defaults[key] = default
	V.Setters[key] = function(v) if Enum.KeyCode[tostring(v)] then set(v) end end
	set(V.Flags[key] ~= nil and V.Flags[key] or default, true)   -- keep the chosen key when the UI is rebuilt
	return row
end

local TABS = {
	{"autofarm", "Auto Farm", "One switch for the whole farming loop"},
	{"throwing", "Throwing", "Target area, accuracy and auto throw"},
	{"training", "Training", "Auto training and spot teleport"},
	{"thanksgiving", "Auto ThanksGiving Event", "Feast throws, cook sandwiches, maple leaf FX"},
	{"index", "Index", "Fill the missing animals in your index"},
	{"shop", "Shop", "Food, bar and fence upgrades"},
	{"animals", "Animals", "Equip best and rarity based selling"},
	{"rewards", "Rewards", "Gifts, offline cash and admin events"},
	{"teleports", "Teleports", "Throw line, plots and stands"},
	{"movement", "Movement", "Speed, jump, infinite jump and noclip"},
	{"qol", "Quality of Life", "Anti AFK, rejoin and server hop"},
	{"stats", "Stats", "Live values from your data"},
	{"settings", "Settings", "Configs, toggle key and auto save"},
}

function V.selectTab(id)
	V.state.tab = id
	for tid, page in pairs(V.pages) do page.frame.Visible = (tid == id) end
	if id == "thanksgiving" and V.pages.thanksgiving then
		task.defer(function() V.playMapleFX(V.pages.thanksgiving.frame) end)
	end
	if V.search then V.search.Text = "" end
	if V.applySearch then V.applySearch("") end
	for tid, b in pairs(V.tabButtons) do
		local sel = tid == id
		tween(b, {BackgroundTransparency = sel and 0 or 1}, 0.16)
		b.TextColor3 = sel and T.text or T.dim
		b.Marker.Visible = sel
		local tabIcon = b:FindFirstChild("Icon")
		if tabIcon then tween(tabIcon, {ImageColor3 = sel and T.accent or T.dim}, 0.16) end
	end
	for _, t in ipairs(TABS) do
		if t[1] == id then
			V.heading.Text = L(t[2]); V.headingSub.Text = L(t[3])
			V.route.Text = L("WORKSPACE") .. "  /  " .. V.upper(L(t[2]))
		end
	end
end

function V.updateScale()
	local cam = workspace.CurrentCamera
	if not (cam and V.scale) then return end
	local vx, vy = cam.ViewportSize.X, cam.ViewportSize.Y
	V.panelsEnabled = vx >= 1100   -- the side panels need a wide viewport
	local totalW = V.panelsEnabled and (980 + 16 + 280) or 980
	local fit = math.clamp(math.min((vx - 24) / totalW, (vy - 28) / 740, 1), 0.25, 1)
	V.scale.Scale = fit * V.zoom.Value
	-- keep the window + side panels centred as one group until the user drags the window
	if not V.userMoved and V.window then
		V.window.Position = UDim2.new(0.5, -math.floor(V.panelsEnabled and 148 * fit or 0), 0.5, 0)
	end
end
function V.setVisible(visible)
	V.visible = visible
	V.visVersion = (V.visVersion or 0) + 1
	local ver = V.visVersion
	V.window.Visible = true
	tween(V.zoom, {Value = visible and 1 or 0.96}, visible and 0.25 or 0.16)
	if not visible then
		task.delay(0.18, function() if V.visVersion == ver and V.window then V.window.Visible = false end end)
	end
end

function V.buildUI()
	V.gui = make("ScreenGui", {Name = "A6HubAnimalThrow", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 10000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, guiParent())
	pcall(function() if type(protect_gui) == "function" then protect_gui(V.gui) elseif syn and syn.protect_gui then syn.protect_gui(V.gui) end end)
	-- During cutscenes the game turns off every ScreenGui (HUDController.SetGameplayVisible); keep the menu enabled
	uiTrack(V.gui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if V.alive and V.gui and V.gui.Parent and not V.gui.Enabled then V.gui.Enabled = true end
	end))
	uiTrack(RunService.Heartbeat:Connect(function()
		if V.alive and V.gui and V.gui.Parent and not V.gui.Enabled then V.gui.Enabled = true end
	end))
	local window = make("Frame", {
		ClipsDescendants = true, Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(980, 740), BackgroundColor3 = T.bg, BorderSizePixel = 0,
	}, V.gui)
	round(window, 18); stroke(window)
	V.window = window
	V.scale = make("UIScale", {}, window)
	V.zoom = make("NumberValue", {Name = "Zoom", Value = 0.96}, window)
	uiTrack(V.zoom.Changed:Connect(V.updateScale))
	V.updateScale()
	if workspace.CurrentCamera then uiTrack(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(V.updateScale)) end

	-- Sidebar
	local sidebar = make("Frame", {Name = "Sidebar", Size = UDim2.new(0, 184, 1, 0), BackgroundColor3 = T.panel, BorderSizePixel = 0}, window)
	round(sidebar, 18)
	make("Frame", {Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -16, 0, 0), BackgroundColor3 = T.panel, BorderSizePixel = 0}, sidebar)
	make("Frame", {Name = "SidebarRule", Position = UDim2.new(0, 183, 0, 18), Size = UDim2.new(0, 1, 1, -36), BackgroundColor3 = T.rule, BorderSizePixel = 0}, window)
	local logo = make("Frame", {Name = "BrandLogo", Position = UDim2.fromOffset(20, 24), Size = UDim2.fromOffset(40, 40), BackgroundColor3 = T.accent, BorderSizePixel = 0}, sidebar)
	round(logo, 12)
	-- A6 custom logo (Roblox asset)
	local logoIcon = make("ImageLabel", {
		Name = "Logo", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Image = "rbxthumb://type=Asset&id=123931707434013&w=420&h=420", ScaleType = Enum.ScaleType.Fit, BorderSizePixel = 0,
	}, logo)
	local brand = label(sidebar, "A6", 22); brand.Font = Enum.Font.GothamBold; brand.Position = UDim2.fromOffset(70, 22); brand.Size = UDim2.fromOffset(104, 28)
	local ver = label(sidebar, "A6 HUB  /  TFFA", 10, true); ver.Position = UDim2.fromOffset(71, 51); ver.Size = UDim2.fromOffset(106, 18)
	local cap = label(sidebar, "WORKSPACE", 9, true); cap.Position = UDim2.fromOffset(20, 100)

	local nav = make("ScrollingFrame", {
		Name = "Nav", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 124),
		Size = UDim2.new(1, 0, 1, -290), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0,
	}, sidebar)
	make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center}, nav)
	make("UIPadding", {PaddingTop = UDim.new(0, 2)}, nav)

	-- Header area
	local drag = make("Frame", {Name = "TitleBar", BackgroundTransparency = 1, Position = UDim2.fromOffset(184, 0), Size = UDim2.new(1, -280, 0, 112), Active = true}, window)
	V.route = label(window, "", 10, true); V.route.Position = UDim2.fromOffset(208, 18); V.route.Size = UDim2.new(1, -420, 0, 18)
	V.heading = label(window, "", 29); V.heading.Font = Enum.Font.GothamBold; V.heading.Position = UDim2.fromOffset(208, 42); V.heading.Size = UDim2.new(1, -330, 0, 38)
	V.headingSub = label(window, "", 12, true); V.headingSub.Position = UDim2.fromOffset(209, 87); V.headingSub.Size = UDim2.new(1, -330, 0, 20)
	-- big metric on the right of the header (header metric)
	local metric = make("Frame", {Name = "HeaderMetric", Position = UDim2.new(1, -190, 0, 47), Size = UDim2.fromOffset(164, 53), BackgroundTransparency = 1}, window)
	V.metricValue = label(metric, "—", 22); V.metricValue.Font = Enum.Font.GothamMedium; V.metricValue.TextXAlignment = Enum.TextXAlignment.Right; V.metricValue.Size = UDim2.new(1, 0, 0, 28)
	local metricCaption = label(metric, "MONEY", 9, true); metricCaption.Position = UDim2.fromOffset(0, 29); metricCaption.TextXAlignment = Enum.TextXAlignment.Right; metricCaption.Size = UDim2.new(1, 0, 0, 18)
	V.Tickers[#V.Tickers + 1] = function()
		if V.metricValue and V.metricValue.Parent then V.metricValue.Text = "$" .. fmtNum(D("Money") or 0) end
	end

	local hide = button(window, "", function() V.setVisible(false) end, 40)
	hide.Name = "MinimizeMenu"; hide.Position = UDim2.new(1, -108, 0, 8); hide.BackgroundTransparency = 1
	local bar = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(18, 3), BackgroundColor3 = T.text, BorderSizePixel = 0, ZIndex = 3}, hide)
	round(bar, 2)   -- drawn bar instead of the thin Fluent glyph, which rendered pale at this size
	local close = button(window, "", function()
		V.confirm("Close A6 Hub?", function() if _g.A6HubCleanup then _g.A6HubCleanup() end end)
	end, 40)
	close.Name = "CloseMenu"; close.Position = UDim2.new(1, -60, 0, 8); close.BackgroundTransparency = 1
	local crossBars = {}
	for _, rot in ipairs({45, -45}) do
		local x = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 3), Rotation = rot, BackgroundColor3 = T.text, BorderSizePixel = 0, ZIndex = 3}, close)
		round(x, 2)
	end

	-- Content
	local surface = make("Frame", {Name = "ContentSurface", ClipsDescendants = true, BackgroundTransparency = 1, Position = UDim2.fromOffset(208, 182), Size = UDim2.new(1, -232, 1, -182 - 100)}, window)
	for i, t in ipairs(TABS) do
		local id = t[1]
		local frame = make("ScrollingFrame", {
			Name = id, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false,
		}, surface)
		make("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, frame)
		make("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, frame)
		V.pages[id] = setmetatable({frame = frame, order = 0}, Page)

		local b = button(nav, t[2], function() V.selectTab(id) end, 160)
		b.Name = id; b.LayoutOrder = i; b.Size = UDim2.fromOffset(160, 34); b.TextXAlignment = Enum.TextXAlignment.Left; b.TextSize = 14
		b.BackgroundColor3 = T.selection; b.BackgroundTransparency = 1; b.TextColor3 = T.dim
		make("UIPadding", {PaddingLeft = UDim.new(0, 44)}, b)   -- room for the icon (children are offset by this padding)
		local marker = make("Frame", {Name = "Marker", Position = UDim2.fromOffset(-44, 8), Size = UDim2.fromOffset(3, 18), BackgroundColor3 = T.text, BorderSizePixel = 0, Visible = false}, b)
		round(marker, 3)
		local tabIcon = V.icon(b, id, 18, T.dim)
		tabIcon.Position = UDim2.fromOffset(-28, 8); tabIcon.ZIndex = 3
		V.tabButtons[id] = b
	end

	-- Active users (A6 users), shown above the profile
	local usage = make("Frame", {Name = "ActiveUsage", BackgroundTransparency = 1, Position = UDim2.new(0, 20, 1, -150), Size = UDim2.fromOffset(150, 28)}, sidebar)
	local usageIcon = V.icon(usage, "people", 18, T.dim)
	usageIcon.Position = UDim2.fromOffset(0, 5)
	V.activeCount = label(usage, "—", 15); V.activeCount.Name = "Count"; V.activeCount.Font = Enum.Font.GothamBold
	V.activeCount.Position = UDim2.fromOffset(26, 0); V.activeCount.Size = UDim2.fromOffset(150 - 26, 28)
	V.activeCount.RichText = true
	V.Tickers[#V.Tickers + 1] = function()
		if V.activeCount and V.activeCount.Parent then
			local function rgb(c) return string.format("rgb(%d,%d,%d)", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)) end
			V.activeCount.Text = '<font color="' .. rgb(T.text) .. '">' .. (V.activeUsers and tostring(V.activeUsers) or "—")
				.. '</font>  <font color="' .. rgb(T.dim) .. '" size="11"><b>' .. L("Using A6 Hub") .. '</b></font>'
		end
	end

	-- Profile
	local avatar = make("ImageLabel", {
		Name = "ProfileAvatar", Position = UDim2.new(0, 16, 1, -82), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = T.raised,
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150", BorderSizePixel = 0,
	}, sidebar)
	round(avatar, 22)
	local uname = label(sidebar, player.DisplayName, 14); uname.Position = UDim2.new(0, 70, 1, -82); uname.Size = UDim2.fromOffset(106, 24)
	local sub = label(sidebar, "@" .. player.Name, 11, true); sub.Position = UDim2.new(0, 70, 1, -56); sub.Size = UDim2.fromOffset(106, 20)
	-- connection status to the A6 API (green when the last heartbeat was accepted), connection status
	V.apiStatus = label(sidebar, "", 10); V.apiStatus.Position = UDim2.new(0, 20, 1, -28); V.apiStatus.Size = UDim2.fromOffset(152, 18)
	V.Tickers[#V.Tickers + 1] = function()
		if not (V.apiStatus and V.apiStatus.Parent) then return end
		if V.apiOk then V.apiStatus.Text = L("Connected to A6 Hub"); V.apiStatus.TextColor3 = T.good
		else V.apiStatus.Text = L("Connecting to A6 Hub..."); V.apiStatus.TextColor3 = T.dim end
	end

	-- Window dragging
	local dragging, origin, startPos
	drag.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = i; origin = i.Position; startPos = window.Position; V.userMoved = true end
	end)
	uiTrack(UIS.InputChanged:Connect(function(i)
		if dragging and (i == dragging or i.UserInputType == Enum.UserInputType.MouseMovement) then
			local d = i.Position - origin
			window.Position = startPos + UDim2.fromOffset(d.X, d.Y)
			origin = i.Position; startPos = window.Position
		end
	end))
	uiTrack(UIS.InputEnded:Connect(function(i) if i == dragging then dragging = nil end end))

	-- Open button (draggable)
	local open = button(V.gui, "", function()
		if os.clock() < (V.openBlock or 0) then return end
		V.setVisible(not V.visible)
	end, 60)
	open.Name = "OpenMenu"; open.Size = UDim2.fromOffset(60, 60); open.Position = UDim2.new(0, 14, 0.5, -30); open.BackgroundColor3 = T.bg
	round(open, 16); stroke(open)
	-- A6 custom logo (Roblox asset)
	local openIcon = make("ImageLabel", {
		Name = "Logo", BackgroundTransparency = 1, Size = UDim2.fromScale(0.78, 0.78),
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Image = "rbxthumb://type=Asset&id=123931707434013&w=420&h=420", ScaleType = Enum.ScaleType.Fit, BorderSizePixel = 0, ZIndex = 3,
	}, open)
	local oi, oo, os0, moved
	open.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then oi = i; oo = i.Position; os0 = open.Position; moved = false end
	end)
	uiTrack(UIS.InputChanged:Connect(function(i)
		if oi and (i == oi or i.UserInputType == Enum.UserInputType.MouseMovement) then
			local d = i.Position - oo
			if moved or d.Magnitude > 5 then
				moved = true; V.openBlock = os.clock() + 0.3
				open.Position = os0 + UDim2.fromOffset(d.X, d.Y); oo = i.Position; os0 = open.Position
			end
		end
	end))
	uiTrack(UIS.InputEnded:Connect(function(i) if i == oi then if moved then V.openBlock = os.clock() + 0.3 end oi = nil end end))

	-- Toggle key
	uiTrack(UIS.InputBegan:Connect(function(i, gp)
		if gp or V.capturing or UIS:GetFocusedTextBox() then return end
		if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == V.Flags.toggleKey then V.setVisible(not V.visible) end
	end))
end

-- ===============================================================
-- EXTRAS (A6 layout): search row, farm dock and side panels
-- ===============================================================
-- Filters the rows of the current tab by their title; sections and info texts hide while searching
function V.applySearch(q)
	q = (q or ""):lower()
	local page = V.pages[V.state.tab]
	if not page then return end
	for _, o in ipairs(page.frame:GetChildren()) do
		if o:IsA("Frame") then
			local title
			for _, c in ipairs(o:GetChildren()) do
				if c:IsA("TextLabel") and c.Text ~= "" then title = c.Text break end
			end
			o.Visible = q == "" or (title ~= nil and title:lower():find(q, 1, true) ~= nil)
		elseif o:IsA("TextLabel") then
			o.Visible = q == ""
		end
	end
end

function V.buildExtras()
	local window = V.window
	local PHASES = {throw = "Throwing", train = "Training", none = "Idle"}
	local MODES = {"throw", "train", "cycle"}
	local MODE_LABEL = {throw = "Throw Only", train = "Train Only", cycle = "Cycle"}
	local function clock(sec)
		sec = math.floor(sec)
		return string.format("%d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
	end

	-- search row: input + accent button (like "Emote ara" + "Rastgele emote")
	local row = make("Frame", {Name = "SearchRow", BackgroundTransparency = 1, Position = UDim2.fromOffset(208, 126), Size = UDim2.new(1, -232, 0, 44)}, window)
	local search = make("TextBox", {
		Name = "Search", PlaceholderText = "Search settings...", Text = "", TextSize = 14, Font = Enum.Font.Gotham, ClearTextOnFocus = false,
		TextColor3 = T.text, PlaceholderColor3 = T.dim, BackgroundColor3 = T.input, BorderSizePixel = 0,
		Size = UDim2.new(1, -160, 0, 44), TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	round(search, 8); stroke(search)
	make("UIPadding", {PaddingLeft = UDim.new(0, 44), PaddingRight = UDim.new(0, 12)}, search)
	local searchIcon = V.icon(search, "search", 20, T.dim)
	searchIcon.Position = UDim2.fromOffset(-32, 12)   -- children are offset by the padding above
	V.search = search
	uiTrack(search:GetPropertyChangedSignal("Text"):Connect(function() V.applySearch(search.Text) end))

	local farmBtn = button(row, "Start Farm", function() V.Setters.autoFarm(not V.Flags.autoFarm) end, 148)
	farmBtn.Name = "FarmAction"; farmBtn.AnchorPoint = Vector2.new(1, 0); farmBtn.Position = UDim2.new(1, 0, 0, 0); farmBtn.Size = UDim2.fromOffset(148, 44)
	farmBtn.BackgroundColor3 = T.accent; farmBtn.TextColor3 = T.onAccent; farmBtn.TextSize = 12
	make("UIPadding", {PaddingLeft = UDim.new(0, 22)}, farmBtn)
	local farmIcon = V.icon(farmBtn, "play", 16, T.onAccent)
	farmIcon.Position = UDim2.new(0, -20, 0.5, -8)

	-- dock at the bottom: what the farm is doing right now (farm dock)
	local dock = make("Frame", {Name = "FarmDock", BackgroundColor3 = T.dock, BorderSizePixel = 0, Position = UDim2.new(0, 208, 1, -82), Size = UDim2.new(1, -232, 0, 64)}, window)
	round(dock, 13); stroke(dock)
	local box = make("Frame", {BackgroundColor3 = T.raised, BorderSizePixel = 0, Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(44, 44)}, dock)
	round(box, 9)
	local boxIcon = V.icon(box, "autofarm", 24, T.text)
	boxIcon.AnchorPoint = Vector2.new(0.5, 0.5); boxIcon.Position = UDim2.fromScale(0.5, 0.5)
	local dockTitle = label(dock, "Auto Farm", 14); dockTitle.Font = Enum.Font.GothamMedium; dockTitle.Position = UDim2.fromOffset(66, 11); dockTitle.Size = UDim2.new(1, -300, 0, 23)
	local dockSub = label(dock, "", 10, true); dockSub.Position = UDim2.fromOffset(66, 35); dockSub.Size = UDim2.new(1, -300, 0, 18)
	local modeBtn = button(dock, MODE_LABEL.throw, function()
		local cur = V.Flags.farmMode or "throw"
		local nextMode = MODES[(table.find(MODES, cur) or 0) % #MODES + 1]
		V.Setters.farmMode(nextMode)
	end, 112)
	modeBtn.Name = "FarmMode"; modeBtn.AnchorPoint = Vector2.new(1, 0.5); modeBtn.Position = UDim2.new(1, -72, 0.5, 0)
	modeBtn.Size = UDim2.fromOffset(112, 36); modeBtn.BackgroundTransparency = 1; modeBtn.TextSize = 12
	local playBtn = button(dock, "", function() V.Setters.autoFarm(not V.Flags.autoFarm) end, 44)
	playBtn.Name = "FarmPlay"; playBtn.AnchorPoint = Vector2.new(1, 0.5); playBtn.Position = UDim2.new(1, -12, 0.5, 0)
	playBtn.Size = UDim2.fromOffset(44, 44); playBtn.BackgroundColor3 = T.accent
	local playIcon = V.icon(playBtn, "play", 22, T.onAccent)
	playIcon.AnchorPoint = Vector2.new(0.5, 0.5); playIcon.Position = UDim2.fromScale(0.5, 0.5)
	local progress = make("Frame", {Name = "Progress", Position = UDim2.new(0, 12, 1, -3), Size = UDim2.new(1, -24, 0, 2), BackgroundColor3 = T.progress, BorderSizePixel = 0, ClipsDescendants = true}, dock)
	local fill = make("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.text, BorderSizePixel = 0}, progress)

	V.Tickers[#V.Tickers + 1] = function()
		local on = V.Flags.autoFarm == true
		local s = F.farmStats()
		-- buttons
		farmBtn.Text = L(on and "Stop Farm" or "Start Farm")
		local a1 = V.iconAssets[on and "stop" or "play"]
		if a1 then farmIcon.Image = a1; playIcon.Image = a1; playBtn.Text = "" else playBtn.Text = L(on and "Stop" or "Start") end
		modeBtn.Text = L(MODE_LABEL[V.Flags.farmMode or "throw"] or "Throw Only")
		-- texts
		dockTitle.Text = on and (L("Auto Farm") .. "  -  " .. L(PHASES[s and s.phase] or "Starting")) or L("Auto Farm")
		if on and s then
			dockSub.Text = clock(s.elapsed) .. "  •  " .. s.throws .. " " .. L("throws") .. "  •  " .. (s.gained >= 0 and "+$" or "-$") .. fmtNum(math.abs(s.gained))
		else
			dockSub.Text = L("Press play to run the selected modules")
		end
		-- progress: cycle phase, stop-after-throws or stop-after-minutes
		local p = 0
		local f = V.farm
		if on and s then
			if f and f.cyc and (V.Flags.farmMode == "cycle") and V.Flags.farmThrow and V.Flags.farmTrain then
				local c = f.cyc
				if c.phase == "throw" then p = ((V.throwCount or 0) - c.c) / math.max(V.Flags.farmCycleThrows or 5, 1)
				else p = (os.clock() - c.t) / math.max(V.Flags.farmCycleTrain or 60, 1) end
			elseif (V.Flags.farmStopThrows or 0) > 0 then p = s.throws / V.Flags.farmStopThrows
			elseif (V.Flags.farmStopMinutes or 0) > 0 then p = s.elapsed / 60 / V.Flags.farmStopMinutes end
		end
		fill.Size = UDim2.fromScale(math.clamp(p, 0, 1), 1)
	end

	-- side panels to the right of the window (side panels)
	V.panels = {}
	local function newPanel(h, yOff)
		local f = make("Frame", {Name = "SidePanel", BackgroundColor3 = T.bg, BorderSizePixel = 0, Size = UDim2.fromOffset(280, h), Visible = false}, V.gui)
		round(f, 18); stroke(f)
		local sc = make("UIScale", {}, f)
		V.panels[#V.panels + 1] = {frame = f, scale = sc, yOff = yOff}
		return f
	end
	local live = newPanel(590, 0)
	local liveTitle = label(live, "Live Stats", 16); liveTitle.Font = Enum.Font.GothamMedium; liveTitle.Position = UDim2.fromOffset(18, 16); liveTitle.Size = UDim2.new(1, -36, 0, 24)
	local liveSub = label(live, player.DisplayName .. "  @" .. player.Name, 11, true); liveSub.Position = UDim2.fromOffset(18, 42); liveSub.Size = UDim2.new(1, -36, 0, 18)
	local function statRow(y, text, getter)
		local l = label(live, text, 12, true); l.Position = UDim2.fromOffset(18, y); l.Size = UDim2.fromOffset(120, 22)
		local v = label(live, "-", 13); v.Font = Enum.Font.GothamMedium; v.AnchorPoint = Vector2.new(1, 0); v.Position = UDim2.new(1, -18, 0, y)
		v.Size = UDim2.fromOffset(130, 22); v.TextXAlignment = Enum.TextXAlignment.Right
		make("Frame", {BackgroundColor3 = T.rule, BorderSizePixel = 0, Position = UDim2.fromOffset(18, y + 27), Size = UDim2.new(1, -36, 0, 1)}, live)
		V.Tickers[#V.Tickers + 1] = function()
			local ok, s = pcall(getter)
			v.Text = L(ok and tostring(s) or "-")
		end
	end
	local y = 80
	for _, item in ipairs({
		{"Money", function() return "$" .. fmtNum(D("Money") or 0) end},
		{"Level", function() return tostring(D("Level") or 0) end},
		{"Throw Power", function() return fmtNum(F.effPower()) .. " / " .. fmtNum(F.maxPower()) end},
		{"Throws", function() return fmtNum(D("Throws") or 0) end},
		{"Equipped Food", function()
			local i = D("EquippedFood"); local fd = i and G.Foods and G.Foods.List and G.Foods.List[i]
			return fd and fd.Name or "None"
		end},
		{"Fence Level", function() return tostring(D("FenceLevel") or 0) end},
		{"Stand Level", function() return tostring(D("Stand") or 0) end},
	}) do statRow(y, item[1], item[2]); y = y + 32 end
	local sess = label(live, "AUTO FARM SESSION", 9, true); sess.Position = UDim2.fromOffset(18, y + 8); sess.Size = UDim2.new(1, -36, 0, 16)
	y = y + 32
	for _, item in ipairs({
		{"Phase", function() local s = F.farmStats(); return s and (PHASES[s.phase] or "-") or (V.Flags.autoFarm and "Starting" or "Off") end},
		{"Time", function() local s = F.farmStats(); return s and clock(s.elapsed) or "-" end},
		{"Throws", function() local s = F.farmStats(); return s and tostring(s.throws) or "-" end},
		{"Money Gained", function() local s = F.farmStats(); return s and ((s.gained >= 0 and "+$" or "-$") .. fmtNum(math.abs(s.gained))) or "-" end},
		{"Money / Hour", function() local s = F.farmStats(); return s and ("$" .. fmtNum(s.perHour)) or "-" end},
		{"Bonus Taps", function() return tostring(V.bonusCount or 0) end},
	}) do statRow(y, item[1], item[2]); y = y + 32 end

	-- Chat launcher
	local chatCard = newPanel(134, 606)
	local chatIcon = V.icon(chatCard, "chat", 32, T.text)
	chatIcon.Position = UDim2.fromOffset(16, 18)
	local chatTitle = label(chatCard, "A6 Chat", 17); chatTitle.Font = Enum.Font.GothamMedium; chatTitle.Position = UDim2.fromOffset(60, 13); chatTitle.Size = UDim2.fromOffset(204, 26)
	local chatDesc = label(chatCard, "Open chat with Discord-style channels.", 11, true)
	chatDesc.Position = UDim2.fromOffset(60, 41); chatDesc.Size = UDim2.fromOffset(204, 34); chatDesc.TextWrapped = true; chatDesc.TextTruncate = Enum.TextTruncate.None
	chatDesc.TextYAlignment = Enum.TextYAlignment.Top
	local execute
	execute = button(chatCard, "Execute", function()
		local loader = loadstring or load
		if type(loader) ~= "function" then V.notify("A6 Chat", "This executor cannot launch scripts.") return end
		execute.Text = L("Loading...")
		local function fail()
			if execute.Parent then execute.Text = L("Execute") end
			V.notify("A6 Chat", "Couldn't launch chat. Check your connection and try again.")
		end
		local source = httpGet("https://a6hub.example/chat.lua")
		if type(source) ~= "string" or #source < 100 then fail() return end
		local compiled, chunk = pcall(loader, source, "A6Chat")
		if not compiled or type(chunk) ~= "function" then fail() return end
		if not pcall(chunk) then fail() return end
		if execute.Parent then execute.Text = L("Execute") end
	end, 248)
	execute.Name = "ExecuteChat"; execute.Position = UDim2.fromOffset(16, 88); execute.Size = UDim2.fromOffset(248, 32)
	execute.BackgroundColor3 = T.accent; execute.TextColor3 = T.onAccent

	uiTrack(RunService.RenderStepped:Connect(function()
		if not (V.window and V.window.Parent and V.scale) then return end
		local sc = V.scale.Scale
		local show = V.panelsEnabled == true and V.window.Visible
		-- work in the ScreenGui's own coordinate space (AbsolutePosition can be shifted by the topbar inset)
		local gs, wp, ws = V.gui.AbsoluteSize, V.window.Position, V.window.AbsoluteSize
		local left = gs.X * wp.X.Scale + wp.X.Offset - ws.X * 0.5
		local top = gs.Y * wp.Y.Scale + wp.Y.Offset - ws.Y * 0.5
		for _, p in ipairs(V.panels) do
			p.frame.Visible = show
			if show then p.scale.Scale = sc; p.frame.Position = UDim2.fromOffset(left + ws.X + 16 * sc, top + p.yOff * sc) end
		end
	end))
	V.updateScale()
end

-- ===============================================================
-- DARK GLASS (translucent surfaces + depth-of-field blur behind the panels, DarkGlass theme)
-- ===============================================================
function V.cleanupGlass()
	local g = V.glass
	if g then
		if g.connection then g.connection:Disconnect() end
		if g.effect then g.effect:Destroy() end
		if g.folder then g.folder:Destroy() end
	end
	V.glass = nil
end
function V.applyGlass()
	V.cleanupGlass()
	if V.theme ~= "DarkGlass" or not V.window then return end
	V.window.BackgroundTransparency = 0.42
	local sidebar = V.window:FindFirstChild("Sidebar")
	if sidebar then
		sidebar.BackgroundTransparency = 0.5
		for _, c in ipairs(sidebar:GetChildren()) do
			if c:IsA("Frame") and c.Size == UDim2.new(0, 16, 1, 0) then c.BackgroundTransparency = 1 end
		end
	end
	local dock = V.window:FindFirstChild("FarmDock")
	if dock then dock.BackgroundTransparency = 0.3 end
	if V.search then V.search.BackgroundTransparency = 0.3 end
	for _, page in pairs(V.pages) do
		for _, o in ipairs(page.frame:GetChildren()) do if o:IsA("Frame") then o.BackgroundTransparency = 0.3 end end
	end
	for _, p in ipairs(V.panels or {}) do p.frame.BackgroundTransparency = 0.42 end
	local g = {}
	V.glass = g
	g.folder = Instance.new("Folder"); g.folder.Name = "A6PanelGlass"
	g.effect = Instance.new("DepthOfFieldEffect"); g.effect.Name = "A6PanelDepthBlur"
	g.effect.FarIntensity = 0; g.effect.NearIntensity = 1; g.effect.FocusDistance = 1; g.effect.InFocusRadius = 0.1; g.effect.Enabled = false
	g.panels = {}
	local frames = {V.window}
	for _, p in ipairs(V.panels or {}) do frames[#frames + 1] = p.frame end
	for _, panel in ipairs(frames) do
		local part = Instance.new("Part"); part.Name = "PanelGlass"
		part.Material = Enum.Material.Glass; part.Color = Color3.new(0, 0, 0); part.Transparency = 0.99
		part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false; part.CastShadow = false; part.Locked = true
		part.Size = Vector3.new(1, 1, 0.001); part.Parent = g.folder
		local mesh = Instance.new("SpecialMesh"); mesh.MeshType = Enum.MeshType.Brick; mesh.Scale = Vector3.new(1, 1, 0); mesh.Offset = Vector3.new(0, 0, -0.000001); mesh.Parent = part
		g.panels[#g.panels + 1] = {panel = panel, part = part, mesh = mesh}
	end
	local function update()
		if V.glass ~= g then return end
		if not V.alive then V.cleanupGlass() return end
		local camera = workspace.CurrentCamera
		if not camera then g.effect.Enabled = false return end
		local attached = pcall(function()
			if g.folder.Parent ~= camera then g.folder.Parent = camera end
			if g.effect.Parent ~= camera then g.effect.Parent = camera end
		end)
		if not attached then return end
		local inset = Vector2.zero
		if V.gui and V.gui.IgnoreGuiInset then inset = game:GetService("GuiService"):GetGuiInset() end
		local any = false
		for _, entry in ipairs(g.panels) do
			local panel, part = entry.panel, entry.part
			local visible = V.gui and V.gui.Enabled and panel.Parent and panel.Visible and panel.AbsoluteSize.X > 2
			part.Transparency = visible and 0.99 or 1
			if visible then
				any = true
				local pad = math.min(12, math.min(panel.AbsoluteSize.X, panel.AbsoluteSize.Y) * 0.025)
				local pos = panel.AbsolutePosition + inset + Vector2.new(pad, pad)
				local size = panel.AbsoluteSize - Vector2.new(pad * 2, pad * 2)
				local a = camera:ViewportPointToRay(pos.X, pos.Y, 0.002).Origin
				local b = camera:ViewportPointToRay(pos.X + size.X, pos.Y, 0.002).Origin
				local c = camera:ViewportPointToRay(pos.X + size.X, pos.Y + size.Y, 0.002).Origin
				part.CFrame = CFrame.fromMatrix((a + c) * 0.5, camera.CFrame.XVector, camera.CFrame.YVector, camera.CFrame.ZVector)
				entry.mesh.Scale = Vector3.new((b - a).Magnitude, (b - c).Magnitude, 0)
			end
		end
		g.effect.Enabled = any
	end
	g.connection = RunService.RenderStepped:Connect(update)
	update()
end

-- ===============================================================
-- REBUILD + PICKERS (language / theme)
-- ===============================================================
V.LanguageOptions = {
	{"TR", "Türkçe", "Turkish", "🇹🇷"}, {"EN", "English", "English", "🇺🇸"}, {"ES", "Español", "Spanish", "🇪🇸"}, {"AR", "العربية", "Arabic", "🇸🇦"},
	{"FR", "Français", "French", "🇫🇷"}, {"HI", "हिन्दी", "Hindi", "🇮🇳"}, {"PT", "Português", "Portuguese", "🇧🇷"}, {"RU", "Русский", "Russian", "🇷🇺"},
	{"DE", "Deutsch", "German", "🇩🇪"}, {"ID", "Bahasa Indonesia", "Indonesian", "🇮🇩"}, {"JA", "日本語", "Japanese", "🇯🇵"}, {"KO", "한국어", "Korean", "🇰🇷"},
	{"VI", "Tiếng Việt", "Vietnamese", "🇻🇳"}, {"ZH", "中文", "Chinese", "🇨🇳"}, {"IT", "Italiano", "Italian", "🇮🇹"},
	{"PL", "Polski", "Polish", "🇵🇱"}, {"TH", "ไทย", "Thai", "🇹🇭"}, {"FIL", "Filipino", "Filipino", "🇵🇭"}, {"MS", "Bahasa Melayu", "Malay", "🇲🇾"},
}
V.LanguageCopy = {
	TR = {title = "Kendi dilinde başla", body = "A6 Hub için kullanmak istediğin dili seç. Daha sonra Ayarlar'dan değiştirebilirsin.", next = "Devam et"},
	EN = {title = "Make yourself at home", body = "Choose your language for A6 Hub. You can change it later in Settings.", next = "Continue"},
	ES = {title = "Empieza en tu idioma", body = "Elige tu idioma para A6 Hub. Puedes cambiarlo después en Ajustes.", next = "Continuar"},
	AR = {title = "ابدأ بلغتك", body = "اختر لغتك في A6 Hub. يمكنك تغييرها لاحقًا من الإعدادات.", next = "متابعة"},
	FR = {title = "Commence dans ta langue", body = "Choisis ta langue pour A6 Hub. Tu pourras la changer dans les paramètres.", next = "Continuer"},
	HI = {title = "अपनी भाषा में शुरू करें", body = "A6 Hub के लिए अपनी भाषा चुनें। इसे बाद में सेटिंग्स में बदल सकते हैं।", next = "जारी रखें"},
	PT = {title = "Comece no seu idioma", body = "Escolha seu idioma para o A6 Hub. Você pode alterá-lo depois nas configurações.", next = "Continuar"},
	RU = {title = "Начните на своём языке", body = "Выберите язык A6 Hub. Его можно изменить позже в настройках.", next = "Продолжить"},
	DE = {title = "Fühl dich wie zu Hause", body = "Wähle deine Sprache für A6 Hub. Du kannst sie später in den Einstellungen ändern.", next = "Weiter"},
	ID = {title = "Mulai dengan bahasamu", body = "Pilih bahasa untuk A6 Hub. Kamu bisa mengubahnya nanti di Pengaturan.", next = "Lanjutkan"},
	JA = {title = "あなたの言語で始めよう", body = "A6 Hub の言語を選択してください。後で設定から変更できます。", next = "続ける"},
	KO = {title = "내 언어로 시작하세요", body = "A6 Hub에서 사용할 언어를 선택하세요. 나중에 설정에서 변경할 수 있습니다.", next = "계속"},
	VI = {title = "Bắt đầu bằng ngôn ngữ của bạn", body = "Chọn ngôn ngữ cho A6 Hub. Bạn có thể đổi sau trong Cài đặt.", next = "Tiếp tục"},
	ZH = {title = "用你的语言开始", body = "为 A6 Hub 选择语言。之后可在设置中更改。", next = "继续"},
	IT = {title = "Inizia nella tua lingua", body = "Scegli la lingua per A6 Hub. Puoi cambiarla dopo nelle Impostazioni.", next = "Continua"},
	PL = {title = "Zacznij w swoim języku", body = "Wybierz język A6 Hub. Możesz zmienić go później w Ustawieniach.", next = "Dalej"},
	TH = {title = "เริ่มต้นด้วยภาษาของคุณ", body = "เลือกภาษาสำหรับ A6 Hub เปลี่ยนได้ทีหลังในการตั้งค่า", next = "ต่อไป"},
	FIL = {title = "Magsimula sa iyong wika", body = "Piliin ang wika para sa A6 Hub. Maaari mong baguhin mamaya sa Settings.", next = "Magpatuloy"},
	MS = {title = "Mula dengan bahasa anda", body = "Pilih bahasa untuk A6 Hub. Anda boleh tukar kemudian dalam Tetapan.", next = "Teruskan"},
}

-- Rebuilds the whole UI from scratch (needed for a new language or theme). Feature flags are kept.
function V.rebuildUI(showWindow)
	local wasVisible = V.visible
	local tab = V.state.tab
	local windowPos = V.window and V.window.Parent and V.window.Position
	local openButton = V.gui and V.gui:FindFirstChild("OpenMenu")
	local openPos = openButton and openButton.Position
	for _, c in ipairs(V.uiConns) do pcall(function() c:Disconnect() end) end
	V.uiConns = {}
	V.cleanupGlass()
	if V.gui then pcall(function() V.gui:Destroy() end) end
	V.gui, V.window, V.scale, V.zoom, V.search, V.panels = nil, nil, nil, nil, nil, nil
	V.pages, V.tabButtons, V.Tickers = {}, {}, {}
	V.Paints, V.Callbacks, V.Defaults, V.Setters, V.SilentSetters = {}, {}, {}, {}, {}
	V.modalShade, V.toast = nil, nil
	V.buildUI()
	V.buildPages()
	V.buildExtras()
	if V.userMoved and windowPos then V.window.Position = windowPos end
	if openPos then local ob = V.gui:FindFirstChild("OpenMenu"); if ob then ob.Position = openPos end end
	V.selectTab(tab or "autofarm")
	V.applyGlass()
	V.visible = false
	V.setVisible(showWindow ~= nil and showWindow or wasVisible ~= false)
end

function V.openLanguagePicker(onboarding, after)
	local selected = V.lang
	V.pendingLanguage = selected
	V.modal("A6  /  " .. L("Language"), function(list, close)
		local title = label(list, "", 22); title.Font = Enum.Font.GothamBold; title.Size = UDim2.new(1, -8, 0, 34); title.LayoutOrder = 1
		local body = label(list, "", 12, true); body.Size = UDim2.new(1, -8, 0, 40); body.TextWrapped = true; body.TextTruncate = Enum.TextTruncate.None; body.LayoutOrder = 2
		-- Let the language grid grow to fit every language. The modal's ScrollingFrame
		-- then scrolls the full list, with Continue placed after the final language.
		local grid = make("Frame", {Name = "LanguageGrid", BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3}, list)
		local gridLayout = make("UIGridLayout", {SortOrder = Enum.SortOrder.LayoutOrder, FillDirectionMaxCells = 3, CellSize = UDim2.new(1 / 3, -7, 0, 64), CellPadding = UDim2.fromOffset(10, 10)}, grid)
		local confirm
		local buttons = {}
		local function refresh()
			local copy = V.LanguageCopy[selected] or V.LanguageCopy.EN
			title.Text = copy.title; body.Text = copy.body; confirm.Text = copy.next
			local align = selected == "AR" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
			title.TextXAlignment = align; body.TextXAlignment = align
			for code, b in pairs(buttons) do
				local active = code == selected
				b.BackgroundColor3 = active and T.selection or T.raised
				b.NativeName.TextColor3 = active and T.text or T.dim
				b.SelectedCheck.Visible = active
			end
		end
		for i, entry in ipairs(V.LanguageOptions) do
			local code = entry[1]
			local b = button(grid, "", function()
					-- Keep the pending choice on V as well as in this picker closure.
					-- This avoids stale selection state if the modal is rebuilt/reopened.
					selected = code
					V.pendingLanguage = code
					refresh()
				end, 100)
			b.Name = "Language_" .. code; b.LayoutOrder = i
			local flag = label(b, entry[4], 24); flag.Position = UDim2.fromOffset(10, 16); flag.Size = UDim2.fromOffset(32, 32)
			flag.TextXAlignment = Enum.TextXAlignment.Center; flag.TextColor3 = Color3.new(1, 1, 1)
			local native = label(b, entry[2], 14); native.Name = "NativeName"; native.Position = UDim2.fromOffset(49, 8); native.Size = UDim2.new(1, -77, 0, 24)
			local english = label(b, entry[3], 10, true); english.Position = UDim2.fromOffset(49, 33); english.Size = UDim2.new(1, -65, 0, 19)
			local check = V.icon(b, "check", 16, T.text); check.Name = "SelectedCheck"; check.Position = UDim2.new(1, -26, 0.5, -8)
			buttons[code] = b
		end
		confirm = button(list, "", function()
			local chosen = V.pendingLanguage or selected or V.lang
			if not table.find(LANG_CODES, chosen) then chosen = "EN" end
			-- Commit before closing so the saved value and the rebuilt UI always agree.
			V.lang = chosen
			V.pendingLanguage = nil
			V.saveSettings()
			close()
			-- Do not destroy/rebuild the GUI inside the Activated callback. Deferring
			-- prevents the old modal's input handler from racing the newly built UI.
			task.delay(0.18, function()
				if not V.alive then return end
				if onboarding then
					if after then after() end
				else
					V.rebuildUI()
				end
			end)
		end, 100)
		confirm.Size = UDim2.new(1, -8, 0, 46); confirm.BackgroundColor3 = T.accent; confirm.TextColor3 = T.onAccent; confirm.LayoutOrder = 4
		refresh()
	end, 720, 570, onboarding)
end

function V.openThemePicker(onboarding)
	V.modal(L("Theme"), function(list, close)
		for i, name in ipairs(V.ThemeOrder) do
			local theme = V.Themes[name]
			local b = button(list, "", function()
				close()
				V.applyTheme(name)
				V.saveSettings()
				V.rebuildUI(onboarding and true or nil)
			end, 100)
			b.Name = "Theme_" .. name; b.LayoutOrder = i; b.Size = UDim2.new(1, -8, 0, 68); b.BackgroundColor3 = theme.bg
			stroke(b, name == V.theme and theme.accent or theme.stroke)
			local title = label(b, name == "Dark" and "AMOLED" or name, 15); title.TextColor3 = theme.text
			title.Position = UDim2.fromOffset(14, 8); title.Size = UDim2.new(1, -44, 0, 24)
			if name == V.theme then
				local check = V.icon(b, "check", 18, theme.accent); check.Position = UDim2.new(1, -32, 0, 12)
			end
			local colors = V.ThemePalettes[name]
			for k = 1, 4 do
				local color = colors and hexColor(colors[k]) or ({theme.bg, theme.raised, theme.dim, theme.accent})[k]
				local swatch = make("Frame", {Name = "Swatch" .. k, Position = UDim2.new((k - 1) / 4, 14, 0, 40), Size = UDim2.new(0.25, -18, 0, 14), BackgroundColor3 = color, BorderSizePixel = 0}, b)
				round(swatch, 4)
			end
		end
	end, 430, 500, onboarding)
end

-- First launch: language, then theme  ; afterwards both live in Settings.
function V.runOnboarding()
	V.window.Visible = false
	V.visible = false
	V.openLanguagePicker(true, function() V.openThemePicker(true) end)
end

-- ===============================================================
-- TAB CONTENTS
-- ===============================================================
function V.buildPages()
	local P = V.pages

	-- Throwing
	local p = P.throwing
	local areaOpts = {{v = "Best", label = "Best Area (Auto-Detect)"}}
	if G.AreasCfg and G.AreasCfg.List then
		for i, a in ipairs(G.AreasCfg.List) do areaOpts[#areaOpts + 1] = {v = a.Key, label = i .. " · " .. a.Name} end
	end
	p:Section("Target")
	p:Dropdown("targetArea", "Target Area", areaOpts, "Best")
	p:Stat("Selected Area", function()
		local k, why = F.desiredArea()
		if k == "Best" then
			local a = G.AreasCfg and G.AreasCfg.List and G.AreasCfg.List[F.bestArea()]
			return L("Best") .. " → " .. (a and a.Name or "?")
		end
		return (why and (why .. " → ") or "") .. tostring(k)
	end)
	p:Section("Accuracy and timing")
	p:Slider("accuracy", "Throw Accuracy", 0, 100, 90, 1, "%")
	p:Slider("meterWait", "Max Meter Wait", 0.5, 8, 2, 0.1, "s")
	p:Stat("Planned Tap", function()
		local t, pos = F.meterPlan()
		local bonus = (G.GameCfg and G.GameCfg.Throw and G.GameCfg.Throw.MeterBonusStuds or 20) * (pos or 0)
		return LF("%.1fs  →  %d%%  (+%d stud)", t, math.floor((pos or 0) * 100 + 0.5), math.floor(bonus + 0.5))
	end)
	p:Slider("throwDelay", "Throw Delay", 1.5, 10, 1.7, 0.1, "s")
	p:Section("Automation")
	p:Toggle("autoThrow", "Auto Throw", false, function(on)
		if on then
			V.autoSkipSet = false
			if V.SilentSetters.skipCutscene then V.SilentSetters.skipCutscene(true) end
			if V.SilentSetters.skipCard then V.SilentSetters.skipCard(true) end
			V.notify("Auto Throw on", "Teleports to the line and throws automatically; cutscene and result card are skipped")
		else V.notify("Auto Throw off", "") end
	end)
	p:Toggle("skipCutscene", "Skip Cutscene", false)
	p:Toggle("skipCard", "Skip Result Card (tap to continue)", false)
	p:Toggle("useSuper", "Use Super Throws", false)
	p:Info("If you have a saved Super Throw, the meter locks and the throw is perfect. Without one it keeps doing normal throws.")

	-- Training
	p = P.training
	p:Section("Training")
	p:Toggle("autoTrain", "Auto Training", false, function(on)
		if on and V.Flags.autoThrow then V.notify("Auto Throw is on", "Throwing has priority; training starts once throwing is off") end
	end)
	p:Toggle("autoTapBonus", "Auto Tap x2 Bonus", true)
	p:Stat("Bonus Taps (this session)", function() return tostring(V.bonusCount or 0) end)
	p:Button("Teleport to Training Spot", "Teleport", function()
		if busy() then V.notify("Not possible right now", "Wait for the throw/training to finish") return end
		if not F.tpTraining() then V.notify("Training Spot not found", "") end
	end)
	p:Stat("Training", function() return (G.Training and G.Training.IsRunning and G.Training.IsRunning()) and "Running" or "Idle" end)

	-- Thanksgiving Event (controls first, guide last)
	p = P.thanksgiving
	p:Section("Auto Throw Event")
	p:Toggle("autoTgThrow", "Auto Throw Event", false, function(on)
		if on then
			V.notify("Auto Throw Event", "Waits for Feast (~30 min). Throws only during the 5-min window, then stops.")
		else
			if V.tg and V.tg.active then F.tgStop() end
			V.notify("Auto Throw Event", "Off")
		end
	end)
	p:Stat("Event Status", function()
		if V.tg and V.tg.active then
			local left = math.max(0, math.floor((V.tg.endsAt or 0) - os.clock()))
			return "ACTIVE  ·  " .. left .. "s left"
		end
		return F.tgDetectActive() and "Theme live" or "Waiting for next Feast"
	end)
	p:Info("Does NOT throw outside the event. When Feast starts: pause train, +20 power, auto throw. When it ends: restore previous mode.")
	p:Section("Auto Cook")
	p:Dropdown("tgSandwich", "Sandwich Size", {
		{v = "Regular", label = "Regular  (3 ingredients)"},
		{v = "Big", label = "Big  (6 ingredients)"},
		{v = "Mega", label = "Mega  (9 ingredients)"},
	}, "Regular")
	p:Info("Only one size at a time — change the dropdown to switch.")
	p:Toggle("autoTgCook", "Auto Cook while Event", false, function(on)
		if on then V.notify("Auto Cook", "Will TP to Feast hub and cook the selected size only") end
	end)
	p:Button("Cook Now", "Cook", function()
		F.tgCook(V.Flags.tgSandwich or "Regular")
	end, 130)
	p:Info("TP to Turkey Chef / picnic table (left of safe zone) → cook selected sandwich only.")
	p:Section("How to play")
	p:Info("Event every ~30 min · lasts 5 min. Throw to collect Sweet Potato, Cranberry Sauce, Cornbread. Cook at Feast hub. Regular/Big/Mega need 3/6/9 ingredients. Event animals spawn outside Forest/Savanna/Desert.")

	-- Index
	p = P.index
	p:Section("Index")
	p:Toggle("autoIndex", "Auto Index (Fill Missing Animals)", false, function(on)
		if on then
			local k, n = F.nextMissingArea()
			V.notify(k and LF("Target area: %s", k) or "Index complete", k and tostring(n) or "No missing animals in reachable areas")
		end
	end)
	p:Stat("Next Missing Animal", function()
		local k, n = F.nextMissingArea()
		return k and (tostring(n) .. " (" .. k .. ")") or "None"
	end)
	p:Stat("Index Progress", function()
		local idx, have, total = D("Index") or {}, 0, 0
		if G.AnimalsData then
			for _, list in pairs(G.AnimalsData) do
				if type(list) == "table" then for _, a in pairs(list) do if type(a) == "table" and a.ModelName then total = total + 1; if idx[a.ModelName] then have = have + 1 end end end end
			end
		end
		return have .. " / " .. total
	end)
	p:Info("The lowest reachable area that has a missing animal is targeted automatically; Auto Throw throws at that area.")

	-- Shop
	p = P.shop
	p:Section("Automation")
	p:Toggle("autoBuyFood", "Auto Buy Best Food (Smart Check)", false)
	p:Toggle("autoEquipFood", "Auto Equip Best Food", false)
	p:Toggle("autoUpBar", "Auto Upgrade Bar (Smart Check)", false)
	p:Toggle("autoUpFence", "Auto Upgrade Fence (Smart Check)", false)
	p:Section("Manual")
	p:Button("Buy Best Food", "Buy", function()
		local ok = F.buyBestFood(false)
		if not ok then V.notify("Could not buy", "Not enough money or you already own the best food") end
	end)
	p:Button("Equip Best Food", "Equip", function()
		if not F.equipBestFood(false) then V.notify("No change", "The best food is already equipped") end
	end)
	p:Button("Upgrade Bar", "Upgrade", function()
		local ok, why = F.upgrade("Stand_Upgrade", false)
		if not ok then V.notify("Could not upgrade", tostring(why)) end
	end)
	p:Button("Upgrade Fence", "Upgrade", function()
		local ok, why = F.upgrade("Plot_UpgradeFence", false)
		if not ok then V.notify("Could not upgrade", tostring(why)) end
	end)

	-- Animals
	p = P.animals
	local rarities = {}
	if G.Rarity and G.Rarity.List then for _, r in ipairs(G.Rarity.List) do rarities[#rarities + 1] = r.Name end end
	local muts = {"Gold", "Diamond", "Emerald", "Ruby", "Rainbow", "Champion", "Lucid"}
	local keepDefault = {}
	for _, m in ipairs(muts) do keepDefault[m] = true end
	p:Section("Equip")
	p:Toggle("autoEquipAnimals", "Auto Equip Best Animals", false)
	p:Button("Equip Best", "Equip Best", function()
		local r = inv("Plot_EquipBest")
		V.notify(r.Ok and "Best animals equipped" or "Could not equip", r.Ok and "" or tostring(r.Reason))
	end)
	p:Section("Auto Place (plot)")
	p:Toggle("autoPlace", "Auto Place Animals", false, function(on)
		if on then V.notify("Auto Place on", "Empty slots get filled; a full plot is swapped according to your rules") end
	end)
	p:Dropdown("placeOrder", "Place Order", {
		{v = "income", label = "Highest Income"},
		{v = "rarity", label = "Highest Rarity"},
		{v = "mutation", label = "Mutations First"},
		{v = "size", label = "Largest Size First"},
	}, "income")
	local rarityOpts = {}
	for _, n in ipairs(rarities) do rarityOpts[#rarityOpts + 1] = {v = n, label = n} end
	p:Dropdown("placeMinRarity", "Only Place From Rarity", rarityOpts, "Common")
	p:Toggle("replaceWorst", "Replace Worst When Plot Is Full", true)
	p:Slider("replaceMargin", "Replace Only If Better By", 0, 200, 10, 5, "%")
	p:Toggle("protectMutations", "Never Remove Placed Mutations", false)
	p:Stat("Plot Slots", function()
		local placed = F.plotState()
		return #placed .. " / " .. F.plotSlots()
	end)
	p:Stat("Best Unplaced", function()
		local _, un = F.plotState()
		table.sort(un, function(x, y) return x.v > y.v end)
		local b = un[1]
		return b and (F.animalName(b.a) .. "  ($" .. fmtNum(b.v) .. "/s)") or "None"
	end)
	p:Stat("Worst Placed", function()
		local placed = F.plotState()
		local w = placed[1]
		return w and (F.animalName(w.a) .. "  ($" .. fmtNum(w.v) .. "/s)") or "None"
	end)
	p:Button("Place Now", "Run", function()
		local a, s = F.placeTick(false)
		V.notify(a + s > 0 and "Plot updated" or "No changes", LF("Placed: %d  •  Swapped: %d", a, s))
	end)
	p:Info("Candidates are sorted by the chosen order. When the plot is full, the lowest-income placed animal is swapped if the candidate earns more than your margin. While Auto Place is on, animals that would be placed are not sold by Auto Sell.")
	p:Section("Selling")
	p:Toggle("autoSell", "Auto Sell with Rarity Filter", false)
	p:Multi("sellRarities", "Sell Rarities", rarities, {Common = true, Uncommon = true})
	p:Multi("keepMutations", "Keep Special Mutations", muts, keepDefault)
	p:Toggle("keepLarge", "Keep Large Sizes", true)
	p:Info("Only animals that are not placed on the plot (in your inventory) are sold. The selected rarity filter and kept mutations are applied.")
	p:Button("Sell Filtered Now", "Sell", function()
		local n = F.sellFiltered(false)
		if n == 0 then V.notify("Nothing to sell", "No inventory animal matches the filter") end
	end)
	p:Button("Sell All", "Sell All", function()
		V.confirm("ALL animals in your inventory will be sold with the game's Sell All. The mutation and rarity filters are not applied.", function()
			local r = inv("Plot_SellAll")
			V.notify(r.Ok and "Everything sold" or "Could not sell", r.Ok and ("+$" .. fmtNum(r.Money or 0)) or tostring(r.Reason))
		end)
	end)

	-- Rewards
	p = P.rewards
	p:Section("Automation")
	p:Toggle("autoGifts", "Auto Claim Free Gifts", false)
	p:Toggle("autoOffline", "Auto Claim Offline Cash", false)
	p:Toggle("autoVote", "Auto Vote Admin Events", false)
	p:Info("In admin event rounds, the option with the most votes gets a vote after a short random delay.")

	-- Teleports
	p = P.teleports
	p:Section("Locations")
	p:Button("Throw Line", "Teleport", F.tpLine)
	p:Button("My Plot", "Teleport", F.tpMyPlot)
	p:Button("Food Shop", "Teleport", F.tpShop)
	p:Button("Animal Stand", "Teleport", F.tpStand)
	p:Button("Sell Stand", "Teleport", F.tpSell)
	p:Section("Plots")
	for i = 1, 5 do p:Button(LF("Plot %d", i), "Teleport", function() F.tpPlot(i) end) end

	-- Movement
	p = P.movement
	p:Section("Character")
	p:Slider("walkSpeed", "WalkSpeed", 16, 250, V.defaultWS or 16, 1, "", function() V.wsTouched = true end)
	p:Slider("jumpPower", "JumpPower", 50, 300, V.defaultJP or 50, 1, "", function() V.jpTouched = true end)
	p:Toggle("infJump", "Infinite Jump", false)
	p:Toggle("noclip", "Noclip", false)
	p:Button("Reset Speed and Jump", "Reset", function()
		V.wsTouched, V.jpTouched = nil, nil
		V.SilentSetters.walkSpeed(V.defaultWS or 16); V.SilentSetters.jumpPower(V.defaultJP or 50)
		local h = hum()
		if h then h.WalkSpeed = V.defaultWS or 16; h.JumpPower = V.defaultJP or 50 end
	end)

	-- QoL
	p = P.qol
	p:Section("Utility")
	p:Toggle("antiAfk", "Anti AFK", true)
	p:Button("Rejoin Server", "Rejoin", function() V.confirm("Rejoin the same server?", F.rejoin) end)
	p:Button("Server Hop", "Hop", function() V.confirm("Hop to another server?", F.serverHop) end)

	-- Stats
	p = P.stats
	p:Section("Live")
	p:Stat("Money", function() return "$" .. fmtNum(D("Money") or 0) end)
	p:Stat("Level", function() return tostring(D("Level") or 0) end)
	p:Stat("Power", function() return fmtNum(F.effPower()) .. " / " .. fmtNum(F.maxPower()) end)
	p:Stat("Throws", function() return fmtNum(D("Throws") or 0) .. (V.throwCount and ("  (+" .. V.throwCount .. " this session)") or "") end)
	p:Stat("Equipped Food", function()
		local i = D("EquippedFood")
		local f = i and G.Foods and G.Foods.List and G.Foods.List[i]
		return f and (f.Name .. " (#" .. i .. ")") or "None"
	end)
	p:Stat("Fence Level", function() return tostring(D("FenceLevel") or 0) end)
	p:Stat("Stand Level", function() return tostring(D("Stand") or 0) end)

	-- Settings
	p = P.settings
	p:Section("Appearance")
	local nativeName = V.lang
	for _, o in ipairs(V.LanguageOptions) do if o[1] == V.lang then nativeName = o[4] .. "  " .. o[2] end end
	p:Button("Language", nativeName, function() V.openLanguagePicker(false) end, 200)
	p:Button("Theme", V.theme == "Dark" and "AMOLED" or V.theme, function() V.openThemePicker(false) end, 200)
	p:Section("Configs")
	local nameBox = p:Input("Config Name", "default", V.cfgName)
	local function pickConfig()
		local names = V.configList()
		if #names == 0 then V.notify("No saved configs", "") return end
		V.modal("Existing Configs", function(list, close)
			for _, n in ipairs(names) do
				button(list, n, function() nameBox.Text = n; close() end, 354).Size = UDim2.new(1, -8, 0, 36)
			end
		end, 390, 460)
	end
	p:Button("Existing Configs", "Choose", pickConfig)
	p:Button("Save Config", "Save", function()
		if V.saveConfig(nameBox.Text) then V.notify("Config saved", V.cfgName) end
	end)
	p:Button("Load Config", "Load", function()
		local n = nameBox.Text ~= "" and nameBox.Text or V.cfgName
		if V.loadConfig(n) then V.notify("Config loaded", n) end
	end)
	p:Button("Delete Config", "Delete", function()
		local n = nameBox.Text
		if n == "" then V.notify("Config name is empty", "") return end
		V.confirm(LF("Delete config '%s'?", n), function()
			if V.deleteConfig(n) then V.notify("Config deleted", n) else V.notify("Could not delete", "File missing or the executor does not support it") end
		end)
	end)
	p:Section("Behaviour")
	p:Toggle("autoLoadCfg", "Auto Load Config", V.getAutoLoad() ~= nil, function(on)
		if on then
			local n = nameBox.Text ~= "" and nameBox.Text or V.cfgName
			V.saveConfig(n); V.setAutoLoad(n)
			V.notify("Auto Load on", n)
		else V.setAutoLoad(nil) end
	end)
	p:Toggle("autoSave", "Auto Save", false)
	p:Keybind("toggleKey", "Toggle Key", "RightControl")
	p:Info("Open or close the menu with the selected key. With Auto Save on, every change is written to the selected config.")

	-- Auto Farm (mirror of the settings on the other tabs + orchestrator settings)
	p = P.autofarm
	p:Section("Auto Farm")
	p:Toggle("autoFarm", "Auto Farm", false, function(on)
		if on then V.farm = nil end
		F.applyFarm()
		V.notify(on and "Auto Farm on" or "Auto Farm off", on and "Running the selected modules" or "Features it started were turned off")
	end)
	p:Dropdown("farmMode", "Throw / Train Mode", {
		{v = "throw", label = "Throw Only"},
		{v = "train", label = "Train Only"},
		{v = "cycle", label = "Cycle (Throw then Train)"},
	}, "throw", function() if V.farm then V.farm.phase = nil; V.farm.cyc = nil end end)
	p:Slider("farmCycleThrows", "Cycle: Throws Before Training", 1, 30, 5, 1, " throws")
	p:Slider("farmCycleTrain", "Cycle: Training Duration", 10, 300, 60, 5, "s")
	p:Slider("farmStopThrows", "Stop After Throws (0 = never)", 0, 500, 0, 5, "")
	p:Slider("farmStopMinutes", "Stop After Minutes (0 = never)", 0, 600, 0, 5, " min")
	p:Section("Modules")
	local function modChanged() F.applyFarm() end
	p:Toggle("farmThrow", "Throw", true, modChanged)
	p:Toggle("farmTrain", "Training", false, modChanged)
	p:Toggle("farmPlace", "Place Animals", true, modChanged)
	p:Toggle("farmFood", "Buy and Equip Best Food", true, modChanged)
	p:Toggle("farmUpgrades", "Upgrade Bar and Fence", true, modChanged)
	p:Toggle("farmSell", "Sell Filtered Animals", false, modChanged)
	p:Toggle("farmRewards", "Claim Rewards and Vote", true, modChanged)
	p:Toggle("farmIndex", "Fill Missing Index Animals", false, modChanged)
	p:Section("Throw settings")
	p:Dropdown("targetArea", "Target Area", areaOpts, "Best")
	p:Slider("accuracy", "Throw Accuracy", 0, 100, 90, 1, "%")
	p:Slider("meterWait", "Max Meter Wait", 0.5, 8, 2, 0.1, "s")
	p:Slider("throwDelay", "Throw Delay", 1.5, 10, 1.7, 0.1, "s")
	p:Toggle("skipCutscene", "Skip Cutscene", false)
	p:Toggle("skipCard", "Skip Result Card (tap to continue)", false)
	p:Toggle("useSuper", "Use Super Throws", false)
	p:Section("Place settings")
	p:Dropdown("placeOrder", "Place Order", {
		{v = "income", label = "Highest Income"},
		{v = "rarity", label = "Highest Rarity"},
		{v = "mutation", label = "Mutations First"},
		{v = "size", label = "Largest Size First"},
	}, "income")
	p:Dropdown("placeMinRarity", "Only Place From Rarity", rarityOpts, "Common")
	p:Toggle("replaceWorst", "Replace Worst When Plot Is Full", true)
	p:Slider("replaceMargin", "Replace Only If Better By", 0, 200, 10, 5, "%")
	p:Toggle("protectMutations", "Never Remove Placed Mutations", false)
	p:Section("Sell settings")
	p:Multi("sellRarities", "Sell Rarities", rarities, {Common = true, Uncommon = true})
	p:Multi("keepMutations", "Keep Special Mutations", muts, keepDefault)
	p:Toggle("keepLarge", "Keep Large Sizes", true)
	p:Section("Session")
	p:Stat("Phase", function()
		local s = F.farmStats()
		if not s then return V.Flags.autoFarm and "Starting..." or "Off" end
		local names = {throw = "Throwing", train = "Training", none = "Idle"}
		return names[s.phase] or "-"
	end)
	p:Stat("Session Time", function()
		local s = F.farmStats()
		if not s then return "-" end
		local e = math.floor(s.elapsed)
		return string.format("%d:%02d:%02d", e // 3600, (e % 3600) // 60, e % 60)
	end)
	p:Stat("Throws (this farm)", function() local s = F.farmStats(); return s and tostring(s.throws) or "-" end)
	p:Stat("Money Gained", function() local s = F.farmStats(); return s and ((s.gained >= 0 and "+$" or "-$") .. fmtNum(math.abs(s.gained))) or "-" end)
	p:Stat("Money per Hour", function() local s = F.farmStats(); return s and ("$" .. fmtNum(s.perHour)) or "-" end)
	p:Info("While Auto Farm is on, the selected modules turn on the matching settings from the other tabs; when it stops, it only turns off what it enabled itself. The same settings are visible on the other tabs and stay in sync.")
end

-- ===============================================================
-- START / STOP
-- ===============================================================
function V.cleanup()
	V.stopThemeFx()
	if V.alive then task.spawn(V.sendDisconnect) end   -- leave the active user count immediately
	V.alive = false
	pcall(function() if G.Meter then G.Meter.TestAutoTap = nil end end)
	pcall(function() if G.Super and V.origBegin then G.Super.Begin = V.origBegin end end)
	pcall(function() if G.Reveal and V.origRun then G.Reveal.Run = V.origRun end end)
	pcall(function() if G.Input and V.origBind then G.Input.BindPressed = V.origBind end end)
	pcall(function()
		if G.Training and G.Training.IsRunning and G.Training.IsRunning() and V.trainStarted then G.Training.Stop() end
	end)
	for _, c in ipairs(V.conns) do pcall(function() c:Disconnect() end) end
	V.conns = {}
	for _, c in ipairs(V.uiConns) do pcall(function() c:Disconnect() end) end
	V.uiConns = {}
	pcall(V.cleanupGlass)
	if V.gui then pcall(function() V.gui:Destroy() end) end
	_g.A6Hub = nil
	_g.A6HubCleanup = nil
end
_g.A6HubCleanup = V.cleanup

function V.start()
	local loaded = G.load()
	if not loaded then
		warn("[A6Hub] Game modules failed to load, script stopped")
		V.alive = false
		return
	end
	-- Capture the Super Throw instance
	if G.Super and G.Super.Begin and not V.origBegin then
		V.origBegin = G.Super.Begin
		G.Super.Begin = function(...)
			local o = V.origBegin(...)
			V.curSuper = o
			return o
		end
	end
	F.hookReveal()
	F.moveStart()
	V.fetchIcons()
	local hasSavedSettings = V.loadSettings()   -- saved language and theme (first launch: none, so the pickers are shown)
	V.buildUI()
	V.buildPages()
	V.buildExtras()
	V.applyGlass()
	F.antiAfk()
	V.selectTab("autofarm")

	-- Stats ticker
	task.spawn(function()
		setId()
		while V.alive do
			for _, t in ipairs(V.Tickers) do pcall(t) end
			task.wait(0.5)
		end
	end)
	for _, fn in ipairs({F.throwLoop, F.superLoop, F.trainLoop, F.tgLoop, F.shopLoop, F.animalsLoop, F.rewardsLoop, F.farmLoop, F.presenceLoop}) do
		task.spawn(function()
			setId()
			local ok, err = pcall(fn)
			if not ok then warn("[A6Hub] loop: " .. tostring(err)) end
		end)
	end

	-- Auto Load
	local al = V.getAutoLoad()
	if al then
		task.delay(0.5, function()
			if V.alive and V.loadConfig(al) then V.notify("Config loaded", al) end
		end)
	end

	_g.A6Hub = {V = V, G = G, F = F}
	if hasSavedSettings then
		V.visible = false
		V.setVisible(true)
		V.notify("A6 Hub", LF("Menu: press %s to open/close", tostring(V.Flags.toggleKey)))
	else
		V.runOnboarding()
	end
end

-- ===============================================================
-- TRANSLATION TABLE  (EN|TR|ES|AR|FR|HI|PT|RU|DE|ID|JA|KO, one UI text per line)
-- ===============================================================
do
	local CODES = {"EN", "TR", "ES", "AR", "FR", "HI", "PT", "RU", "DE", "ID", "JA", "KO", "VI", "ZH", "IT", "PL", "TH", "FIL", "MS"}
	local RAW = [==[
Action failed|İşlem başarısız|Acción fallida|فشل الإجراء|Action échouée|कार्रवाई विफल रही|Ação falhou|Действие не удалось|Aktion fehlgeschlagen|Tindakan gagal|操作に失敗しました|작업 실패|Thao tác thất bại|操作失败|Azione non riuscita|Akcja nie powiodła się|การดำเนินการล้มเหลว|Nabigo ang aksyon|Tindakan gagal
Are you sure?|Emin misin?|¿Seguro?|هل أنت متأكد؟|Es-tu sûr ?|क्या आप निश्चित हैं?|Tem certeza?|Вы уверены?|Bist du sicher?|Apakah kamu yakin?|よろしいですか？|확실한가요?|Bạn chắc chứ?|确定吗？|Sei sicuro?|Na pewno?|แน่ใจหรือไม่?|Sigurado ka ba?|Adakah anda pasti?
Confirm|Onayla|Confirmar|تأكيد|Confirmer|पुष्टि करें|Confirmar|Подтвердить|Bestätigen|Konfirmasi|確認|확인|Xác nhận|确认|Conferma|Potwierdź|ยืนยัน|Kumpirmahin|Sahkan
Close|Kapat|Cerrar|إغلاق|Fermer|बंद करें|Fechar|Закрыть|Schließen|Tutup|閉じる|닫기|Đóng|关闭|Chiudi|Zamknij|ปิด|Isara|Tutup
On|Açık|Activo|مفعل|Activé|चालू|Ligado|Вкл|An|Aktif|オン|켜짐|Bật|开|Attivo|Wł.|เปิด|Naka-on|Hidup
Off|Kapalı|Inactivo|متوقف|Désactivé|बंद|Desligado|Выкл|Aus|Nonaktif|オフ|꺼짐|Tắt|关|Disattivo|Wył.|ปิด|Naka-off|Mati
Press a key...|Bir tuşa bas...|Pulsa una tecla...|اضغط على مفتاح...|Appuie sur une touche...|कोई कुंजी दबाएँ...|Pressione uma tecla...|Нажмите клавишу...|Drücke eine Taste...|Tekan sebuah tombol...|キーを押してください...|키를 누르세요...|Nhấn một phím...|按下按键...|Premi un tasto...|Naciśnij klawisz...|กดปุ่ม...|Pindutin ang key...|Tekan kekunci...
%d / %d selected|%d / %d seçili|%d / %d seleccionados|%d / %d محدد|%d / %d sélectionnés|%d / %d चयनित|%d / %d selecionados|%d / %d выбрано|%d / %d ausgewählt|%d / %d dipilih|%d / %d 選択中|%d / %d 선택됨|%d / %d đã chọn|%d / %d 已选|%d / %d selezionati|%d / %d wybrano|%d / %d ที่เลือก|%d / %d napili|%d / %d dipilih
Index: %s|Dizin: %s|Índice: %s|الفهرس: %s|Index : %s|इंडेक्स: %s|Índice: %s|Индекс: %s|Index: %s|Indeks: %s|図鑑: %s|도감: %s|Sổ: %s|图鉴：%s|Indice: %s|Indeks: %s|ดัชนี: %s|Index: %s|Indeks: %s
Best|En iyi|Mejor|الأفضل|Meilleur|सर्वश्रेष्ठ|Melhor|Лучшая|Beste|Terbaik|最適|최적|Tốt nhất|最佳|Migliore|Najlepsza|ดีที่สุด|Pinakamahusay|Terbaik
Best Area (Auto-Detect)|En İyi Alan (Otomatik)|Mejor zona (automático)|أفضل منطقة (تلقائي)|Meilleure zone (auto)|सर्वश्रेष्ठ क्षेत्र (स्वचालित)|Melhor área (automático)|Лучшая зона (авто)|Beste Zone (automatisch)|Area terbaik (otomatis)|最適エリア（自動検出）|최적 구역 (자동 감지)|Khu vực tốt nhất (Tự động)|最佳区域（自动）|Zona migliore (auto)|Najlepsza strefa (auto)|พื้นที่ดีที่สุด (อัตโนมัติ)|Pinakamagandang area (auto)|Kawasan terbaik (auto)
Food purchased|Yemek satın alındı|Comida comprada|تم شراء الطعام|Nourriture achetée|खाना खरीदा गया|Comida comprada|Еда куплена|Futter gekauft|Makanan dibeli|フードを購入しました|먹이 구매 완료|Đã mua thức ăn|已购买食物|Cibo acquistato|Jedzenie kupione|ซื้ออาหารแล้ว|Nabili ang pagkain|Makanan dibeli
Food equipped|Yemek kuşanıldı|Comida equipada|تم تجهيز الطعام|Nourriture équipée|खाना सुसज्जित|Comida equipada|Еда экипирована|Futter ausgerüstet|Makanan dipakai|フードを装備しました|먹이 장착 완료|Đã trang bị thức ăn|已装备食物|Cibo equipaggiato|Jedzenie założone|สวมอาหารแล้ว|Na-equip ang pagkain|Makanan dilengkapi
Upgrade successful|Yükseltme başarılı|Mejora completada|تمت الترقية بنجاح|Amélioration réussie|अपग्रेड सफल|Melhoria concluída|Улучшение выполнено|Upgrade erfolgreich|Peningkatan berhasil|アップグレード成功|업그레이드 성공|Nâng cấp thành công|升级成功|Upgrade riuscito|Ulepszenie udane|อัปเกรดสำเร็จ|Matagumpay ang upgrade|Naik taraf berjaya
Bar|Bar|Barra|الشريط|Barre|बार|Barra|Шкала|Balken|Bar|バー|바|Thanh|进度条|Barra|Pasek|แถบ|Bar|Bar
Fence|Çit|Valla|السياج|Clôture|बाड़|Cerca|Забор|Zaun|Pagar|フェンス|울타리|Hàng rào|围栏|Recinzione|Płot|รั้ว|Bakod|Pagar
Plot updated|Arazi güncellendi|Parcela actualizada|تم تحديث الأرض|Terrain mis à jour|प्लॉट अपडेट हुआ|Terreno atualizado|Участок обновлён|Grundstück aktualisiert|Lahan diperbarui|区画を更新しました|부지 업데이트됨|Đã cập nhật plot|地块已更新|Terreno aggiornato|Działka zaktualizowana|อัปเดตแปลงแล้ว|Na-update ang plot|Plot dikemas kini
Placed: %d  •  Swapped: %d|Yerleştirilen: %d  •  Değiştirilen: %d|Colocados: %d  •  Cambiados: %d|تم وضع: %d  •  تم استبدال: %d|Placés : %d  •  Remplacés : %d|रखे गए: %d  •  बदले गए: %d|Colocados: %d  •  Trocados: %d|Размещено: %d  •  Заменено: %d|Platziert: %d  •  Getauscht: %d|Ditempatkan: %d  •  Ditukar: %d|配置: %d  •  入れ替え: %d|배치: %d  •  교체: %d|Đặt: %d  •  Đổi: %d|放置：%d  •  替换：%d|Piazzati: %d  •  Scambiati: %d|Umieszczono: %d  •  Zamieniono: %d|วาง: %d  •  สลับ: %d|Nailagay: %d  •  Pinalitan: %d|Diletak: %d  •  Ditukar: %d
Sold: %d animals|Satıldı: %d hayvan|Vendidos: %d animales|تم بيع %d حيوان|Vendus : %d animaux|%d जानवर बेचे गए|Vendidos: %d animais|Продано: %d животных|Verkauft: %d Tiere|Terjual: %d hewan|%d 匹を売却|%d마리 판매됨|Đã bán: %d thú|已售出：%d 只动物|Venduti: %d animali|Sprzedano: %d zwierząt|ขายแล้ว: %d ตัว|Nabenta: %d hayop|Dijual: %d haiwan
Auto Farm stopped|Oto Farm durdu|Auto Farm detenido|توقفت المزرعة التلقائية|Auto Farm arrêté|ऑटो फ़ार्म रुक गया|Auto Farm parado|Авто-фарм остановлен|Auto-Farm gestoppt|Auto Farm berhenti|オートファーム停止|자동 파밍 중지됨|Auto Farm đã dừng|自动挂机已停止|Auto Farm interrotto|Auto Farm zatrzymany|หยุด Auto Farm แล้ว|Tumigil ang Auto Farm|Auto Farm dihentikan
Throw target reached|Atış hedefine ulaşıldı|Objetivo de lanzamientos alcanzado|تم الوصول إلى هدف الرميات|Objectif de lancers atteint|फेंकने का लक्ष्य पूरा हुआ|Meta de arremessos atingida|Цель по броскам достигнута|Wurfziel erreicht|Target lemparan tercapai|投擲目標に到達|던지기 목표 달성|Đã đạt mục tiêu ném|已达到投掷目标|Obiettivo lanci raggiunto|Cel rzutów osiągnięty|ถึงเป้าหมายขว้างแล้ว|Naabot ang target ng throw|Sasaran lemparan dicapai
Time limit reached|Süre doldu|Límite de tiempo alcanzado|انتهى الوقت المحدد|Limite de temps atteinte|समय सीमा पूरी हुई|Limite de tempo atingido|Лимит времени достигнут|Zeitlimit erreicht|Batas waktu tercapai|制限時間に到達|시간 제한 도달|Hết thời gian|已到时间限制|Limite di tempo raggiunto|Limit czasu osiągnięty|ถึงเวลาจำกัดแล้ว|Naabot ang limit ng oras|Had masa dicapai
Not possible right now|Şu an yapılamaz|No es posible ahora|غير ممكن الآن|Impossible pour le moment|अभी संभव नहीं|Não é possível agora|Сейчас невозможно|Gerade nicht möglich|Tidak bisa saat ini|今はできません|지금은 불가능합니다|Hiện không thể|现在无法进行|Non possibile ora|Teraz niemożliwe|ตอนนี้ทำไม่ได้|Hindi posible ngayon|Tidak boleh buat sekarang
Wait for the throw/training to finish|Atışın/antrenmanın bitmesini bekle|Espera a que termine el lanzamiento/entrenamiento|انتظر انتهاء الرمي/التدريب|Attends la fin du lancer/de l'entraînement|फेंकना/प्रशिक्षण खत्म होने का इंतज़ार करें|Aguarde o arremesso/treino terminar|Дождитесь окончания броска/тренировки|Warte, bis Wurf/Training fertig ist|Tunggu lemparan/latihan selesai|投擲/トレーニングが終わるまでお待ちください|던지기/훈련이 끝날 때까지 기다리세요|Chờ ném/luyện xong|请等待投掷/训练结束|Attendi fine lancio/allenamento|Poczekaj na koniec rzutu/treningu|รอขว้าง/ฝึกให้จบ|Hintayin matapos ang throw/training|Tunggu lemparan/latihan selesai
Plot not found|Arazi bulunamadı|Parcela no encontrada|لم يتم العثور على الأرض|Terrain introuvable|प्लॉट नहीं मिला|Terreno não encontrado|Участок не найден|Grundstück nicht gefunden|Lahan tidak ditemukan|区画が見つかりません|부지를 찾을 수 없음|Không tìm thấy plot|未找到地块|Terreno non trovato|Nie znaleziono działki|ไม่พบแปลง|Hindi nahanap ang plot|Plot tidak dijumpai
No plot|Arazi yok|Sin parcela|لا توجد أرض|Pas de terrain|कोई प्लॉट नहीं|Sem terreno|Нет участка|Kein Grundstück|Tidak ada lahan|区画なし|부지 없음|Không có plot|无地块|Nessun terreno|Brak działki|ไม่มีแปลง|Walang plot|Tiada plot
PlotIndex is not assigned|PlotIndex atanmamış|PlotIndex no asignado|لم يتم تعيين PlotIndex|PlotIndex non attribué|PlotIndex असाइन नहीं है|PlotIndex não atribuído|PlotIndex не назначен|PlotIndex nicht zugewiesen|PlotIndex belum ditetapkan|PlotIndex が未割り当てです|PlotIndex가 할당되지 않음|PlotIndex chưa được gán|未分配 PlotIndex|PlotIndex non assegnato|PlotIndex nieprzypisany|ยังไม่กำหนด PlotIndex|Hindi naka-assign ang PlotIndex|PlotIndex belum ditetapkan
Stand not found|Stand bulunamadı|Puesto no encontrado|لم يتم العثور على الكشك|Stand introuvable|स्टैंड नहीं मिला|Estande não encontrado|Стенд не найден|Stand nicht gefunden|Stan tidak ditemukan|スタンドが見つかりません|스탠드를 찾을 수 없음|Không tìm thấy stand|未找到摊位|Stand non trovato|Nie znaleziono stoiska|ไม่พบสแตนด์|Hindi nahanap ang stand|Stand tidak dijumpai
Sell Stand not found|Satış standı bulunamadı|Puesto de venta no encontrado|لم يتم العثور على كشك البيع|Stand de vente introuvable|बिक्री स्टैंड नहीं मिला|Estande de venda não encontrado|Стенд продажи не найден|Verkaufsstand nicht gefunden|Stan jual tidak ditemukan|販売スタンドが見つかりません|판매 스탠드를 찾을 수 없음|Không tìm thấy quầy bán|未找到出售摊位|Banco vendita non trovato|Stoisko sprzedaży nie znalezione|ไม่พบจุดขาย|Hindi nahanap ang sell stand|Gerai jual tidak dijumpai
Rejoining|Yeniden bağlanılıyor|Reconectando|جارٍ إعادة الاتصال|Reconnexion|दोबारा जुड़ रहे हैं|Reconectando|Переподключение|Verbinde erneut|Bergabung ulang|再参加中|재접속 중|Đang vào lại|正在重新加入|Rientro in corso|Ponowne dołączanie|กำลังเข้าใหม่|Muling sumasali|Menyertai semula
Returning to the same server|Aynı sunucuya dönülüyor|Volviendo al mismo servidor|العودة إلى نفس الخادم|Retour sur le même serveur|उसी सर्वर पर लौट रहे हैं|Voltando ao mesmo servidor|Возврат на тот же сервер|Kehre zum selben Server zurück|Kembali ke server yang sama|同じサーバーに戻ります|같은 서버로 돌아갑니다|Quay lại server hiện tại|返回同一服务器|Tornando allo stesso server|Powrót na ten sam serwer|กลับเซิร์ฟเวอร์เดิม|Babalik sa parehong server|Kembali ke pelayan sama
Searching for a server|Sunucu aranıyor|Buscando servidor|جارٍ البحث عن خادم|Recherche d'un serveur|सर्वर खोजा जा रहा है|Procurando servidor|Поиск сервера|Suche Server|Mencari server|サーバーを検索中|서버 검색 중|Đang tìm server|正在搜索服务器|Ricerca server|Szukanie serwera|กำลังหาเซิร์ฟเวอร์|Naghahanap ng server|Mencari pelayan
Picking an emptier server|Daha boş bir sunucu seçiliyor|Eligiendo un servidor más vacío|اختيار خادم أقل ازدحامًا|Choix d'un serveur moins plein|कम भीड़ वाला सर्वर चुना जा रहा है|Escolhendo um servidor mais vazio|Выбор менее заполненного сервера|Wähle einen leereren Server|Memilih server yang lebih sepi|空いているサーバーを選択中|더 한가한 서버 선택 중|Chọn server trống hơn|选择更空的服务器|Scelta server più vuoto|Wybór pustszego serwera|เลือกเซิร์ฟว่างกว่า|Pumipili ng mas walang tao|Pilih pelayan lebih kosong
Could not fetch the server list|Sunucu listesi alınamadı|No se pudo obtener la lista de servidores|تعذر جلب قائمة الخوادم|Impossible de récupérer la liste des serveurs|सर्वर सूची नहीं मिल सकी|Não foi possível obter a lista de servidores|Не удалось получить список серверов|Serverliste konnte nicht geladen werden|Gagal mengambil daftar server|サーバー一覧を取得できませんでした|서버 목록을 가져올 수 없음|Không lấy được danh sách server|无法获取服务器列表|Impossibile ottenere lista server|Nie pobrano listy serwerów|ดึงรายชื่อเซิร์ฟไม่ได้|Hindi makuha ang listahan ng server|Gagal dapat senarai pelayan
Try again later|Daha sonra tekrar dene|Inténtalo de nuevo más tarde|حاول مرة أخرى لاحقًا|Réessaie plus tard|बाद में फिर कोशिश करें|Tente novamente mais tarde|Повторите позже|Versuche es später erneut|Coba lagi nanti|後でもう一度お試しください|나중에 다시 시도하세요|Thử lại sau|请稍后再试|Riprova più tardi|Spróbuj później|ลองใหม่ภายหลัง|Subukan ulit mamaya|Cuba lagi kemudian
No suitable server|Uygun sunucu yok|Ningún servidor adecuado|لا يوجد خادم مناسب|Aucun serveur adapté|कोई उपयुक्त सर्वर नहीं|Nenhum servidor adequado|Нет подходящего сервера|Kein passender Server|Tidak ada server yang cocok|適したサーバーがありません|적합한 서버 없음|Không có server phù hợp|没有合适的服务器|Nessun server adatto|Brak odpowiedniego serwera|ไม่มีเซิร์ฟที่เหมาะสม|Walang angkop na server|Tiada pelayan sesuai
Could not save config|Config kaydedilemedi|No se pudo guardar la configuración|تعذر حفظ الإعدادات|Impossible d'enregistrer la config|कॉन्फ़िग सहेजा नहीं जा सका|Não foi possível salvar a configuração|Не удалось сохранить конфиг|Config konnte nicht gespeichert werden|Gagal menyimpan konfigurasi|設定を保存できませんでした|설정을 저장할 수 없음|Không lưu được config|无法保存配置|Impossibile salvare config|Nie zapisano konfiguracji|บันทึกคอนฟิกไม่ได้|Hindi ma-save ang config|Gagal simpan konfigurasi
Your executor does not support the file system|Executor'ın dosya sistemini desteklemiyor|Tu ejecutor no admite el sistema de archivos|المنفّذ لا يدعم نظام الملفات|Ton exécuteur ne gère pas le système de fichiers|आपका एक्ज़ीक्यूटर फ़ाइल सिस्टम का समर्थन नहीं करता|Seu executor não suporta o sistema de arquivos|Ваш исполнитель не поддерживает файловую систему|Dein Executor unterstützt kein Dateisystem|Executor-mu tidak mendukung sistem file|お使いのエグゼキューターはファイルシステムに対応していません|사용 중인 실행기가 파일 시스템을 지원하지 않음|Executor không hỗ trợ hệ thống file|你的执行器不支持文件系统|L'executor non supporta il file system|Twój executor nie obsługuje systemu plików|เอ็กซีคิวเตอร์ไม่รองรับระบบไฟล์|Hindi support ng executor ang file system|Executor tidak menyokong sistem fail
Could not load config|Config yüklenemedi|No se pudo cargar la configuración|تعذر تحميل الإعدادات|Impossible de charger la config|कॉन्फ़िग लोड नहीं हो सका|Não foi possível carregar a configuração|Не удалось загрузить конфиг|Config konnte nicht geladen werden|Gagal memuat konfigurasi|設定を読み込めませんでした|설정을 불러올 수 없음|Không tải được config|无法加载配置|Impossibile caricare config|Nie wczytano konfiguracji|โหลดคอนฟิกไม่ได้|Hindi ma-load ang config|Gagal muat konfigurasi
Config not found|Config bulunamadı|Configuración no encontrada|لم يتم العثور على الإعدادات|Config introuvable|कॉन्फ़िग नहीं मिला|Configuração não encontrada|Конфиг не найден|Config nicht gefunden|Konfigurasi tidak ditemukan|設定が見つかりません|설정을 찾을 수 없음|Không tìm thấy config|未找到配置|Config non trovata|Nie znaleziono konfiguracji|ไม่พบคอนฟิก|Hindi nahanap ang config|Konfigurasi tidak dijumpai
Config is corrupted|Config bozuk|La configuración está dañada|الإعدادات تالفة|La config est corrompue|कॉन्फ़िग दूषित है|A configuração está corrompida|Конфиг повреждён|Config ist beschädigt|Konfigurasi rusak|設定が破損しています|설정이 손상됨|Config bị hỏng|配置已损坏|Config corrotta|Konfiguracja uszkodzona|คอนฟิกเสีย|Sira ang config|Konfigurasi rosak
Auto Farm|Oto Farm|Auto Farm|المزرعة التلقائية|Auto Farm|ऑटो फ़ार्म|Auto Farm|Авто-фарм|Auto-Farm|Auto Farm|オートファーム|자동 파밍|Auto Farm|自动挂机|Auto Farm|Auto Farm|ออโต้ฟาร์ม|Auto Farm|Auto Farm
One switch for the whole farming loop|Tüm farm döngüsü için tek anahtar|Un interruptor para todo el ciclo de farmeo|مفتاح واحد لكل دورة الزراعة|Un seul interrupteur pour toute la boucle de farm|पूरे फ़ार्मिंग लूप के लिए एक स्विच|Um interruptor para todo o ciclo de farm|Один переключатель для всего цикла фарма|Ein Schalter für die ganze Farm-Schleife|Satu tombol untuk seluruh siklus farming|ファーム全体を1つのスイッチで操作|파밍 전체를 하나의 스위치로|Một nút cho toàn bộ vòng farm|一个开关控制整套挂机|Un interruttore per tutto il farm|Jeden przełącznik na cały farm|สวิตช์เดียวทั้งลูปฟาร์ม|Isang switch para sa buong farm loop|Satu suis untuk seluruh gelung farm
Throwing|Fırlatma|Lanzamiento|الرمي|Lancer|फेंकना|Arremesso|Бросок|Werfen|Lemparan|投擲|던지기|Ném|投掷|Lancio|Rzut|การขว้าง|Paghahagis|Lemparan
Target area, accuracy and auto throw|Hedef alan, isabet ve otomatik atış|Zona objetivo, precisión y lanzamiento automático|المنطقة المستهدفة والدقة والرمي التلقائي|Zone cible, précision et lancer auto|लक्ष्य क्षेत्र, सटीकता और ऑटो थ्रो|Área alvo, precisão e arremesso automático|Целевая зона, точность и автобросок|Zielzone, Genauigkeit und Auto-Wurf|Area target, akurasi, dan lempar otomatis|ターゲットエリア・精度・自動投擲|목표 구역, 정확도, 자동 던지기|Khu vực đích, độ chính xác và tự động ném|目标区域、精度与自动投掷|Zona, precisione e auto lancio|Strefa, celność i auto rzut|พื้นที่เป้า ความแม่น ออโต้ขว้าง|Target area, accuracy at auto throw|Kawasan sasaran, ketepatan dan auto lempar
Training|Antrenman|Entrenamiento|التدريب|Entraînement|प्रशिक्षण|Treino|Тренировка|Training|Latihan|トレーニング|훈련|Luyện tập|训练|Allenamento|Trening|การฝึก|Pagsasanay|Latihan
Auto training and spot teleport|Otomatik antrenman ve noktaya ışınlanma|Entrenamiento automático y teletransporte al punto|تدريب تلقائي والانتقال إلى النقطة|Entraînement auto et téléportation au point|ऑटो प्रशिक्षण और स्थान पर टेलीपोर्ट|Treino automático e teletransporte ao ponto|Автотренировка и телепорт к месту|Auto-Training und Teleport zum Punkt|Latihan otomatis dan teleport ke lokasi|自動トレーニングと地点へのテレポート|자동 훈련 및 훈련 지점 텔레포트|Tự luyện và dịch chuyển tới chỗ luyện|自动训练与传送到训练点|Auto allenamento e TP al punto|Auto trening i TP do punktu|ออโต้ฝึกและวาปจุดฝึก|Auto training at teleport sa spot|Auto latihan dan teleport ke tempat
Index|Dizin|Índice|الفهرس|Index|इंडेक्स|Índice|Индекс|Index|Indeks|図鑑|도감|Sổ thú|图鉴|Indice|Indeks|ดัชนี|Index|Indeks
Fill the missing animals in your index|Dizinindeki eksik hayvanları tamamla|Completa los animales que faltan en tu índice|أكمل الحيوانات الناقصة في فهرسك|Complète les animaux manquants de ton index|अपने इंडेक्स के गायब जानवर पूरे करें|Complete os animais que faltam no índice|Заполните недостающих животных в индексе|Fehlende Tiere im Index auffüllen|Lengkapi hewan yang belum ada di indeks|図鑑に足りない動物を埋める|도감에서 빠진 동물 채우기|Điền thú còn thiếu trong sổ|补全图鉴缺失动物|Completa animali mancanti nell'indice|Uzupełnij brakujące zwierzęta w indeksie|เติมสัตว์ที่ขาดในดัชนี|Punan ang kulang sa index|Isikan haiwan yang kurang dalam indeks
Shop|Mağaza|Tienda|المتجر|Boutique|दुकान|Loja|Магазин|Shop|Toko|ショップ|상점|Cửa hàng|商店|Negozio|Sklep|ร้านค้า|Tindahan|Kedai
Food, bar and fence upgrades|Yemek, bar ve çit yükseltmeleri|Mejoras de comida, barra y valla|ترقيات الطعام والشريط والسياج|Améliorations nourriture, barre et clôture|खाना, बार और बाड़ अपग्रेड|Melhorias de comida, barra e cerca|Улучшения еды, шкалы и забора|Upgrades für Futter, Balken und Zaun|Peningkatan makanan, bar, dan pagar|フード・バー・フェンスの強化|먹이, 바, 울타리 업그레이드|Thức ăn, nâng cấp thanh và hàng rào|食物、进度条与围栏升级|Cibo, barra e upgrade recinzione|Jedzenie, pasek i ulepszenia płotu|อาหาร แถบ และอัปเกรดรั้ว|Pagkain, bar at upgrade ng bakod|Makanan, bar dan naik taraf pagar
Animals|Hayvanlar|Animales|الحيوانات|Animaux|जानवर|Animais|Животные|Tiere|Hewan|動物|동물|Thú|动物|Animali|Zwierzęta|สัตว์|Mga hayop|Haiwan
Equip best and rarity based selling|En iyiyi kuşan ve nadirliğe göre sat|Equipa lo mejor y vende según rareza|جهّز الأفضل وبع حسب الندرة|Équipe le meilleur et vends selon la rareté|सर्वश्रेष्ठ सुसज्जित करें और दुर्लभता के अनुसार बेचें|Equipe o melhor e venda por raridade|Экипировка лучших и продажа по редкости|Beste ausrüsten und nach Seltenheit verkaufen|Pakai yang terbaik dan jual berdasarkan kelangkaan|最強を装備しレア度で売却|최고 장착 및 희귀도별 판매|Trang bị tốt nhất và bán theo độ hiếm|装备最佳并按稀有度出售|Equipaggia i migliori e vendi per rarità|Załóż najlepsze i sprzedawaj wg rzadkości|สวมตัวดีที่สุดและขายตามความหายาก|I-equip ang pinakamahusay at magbenta ayon sa rarity|Lengkapi terbaik dan jual ikut kelangkaan
Rewards|Ödüller|Recompensas|المكافآت|Récompenses|पुरस्कार|Recompensas|Награды|Belohnungen|Hadiah|報酬|보상|Phần thưởng|奖励|Ricompense|Nagrody|รางวัล|Mga gantimpala|Ganjaran
Gifts, offline cash and admin events|Hediyeler, çevrimdışı para ve yönetici etkinlikleri|Regalos, dinero offline y eventos de admin|الهدايا والمال أثناء الغياب وفعاليات الإدارة|Cadeaux, argent hors ligne et événements admin|उपहार, ऑफ़लाइन कमाई और एडमिन इवेंट|Presentes, dinheiro offline e eventos de admin|Подарки, оффлайн-доход и события админов|Geschenke, Offline-Geld und Admin-Events|Hadiah, uang offline, dan event admin|ギフト・オフライン収入・管理者イベント|선물, 오프라인 수익, 관리자 이벤트|Quà, tiền offline và sự kiện admin|礼物、离线金币与管理员活动|Regali, soldi offline ed eventi admin|Prezenty, offline cash i eventy admin|ของขวัญ เงินออฟไลน์ และอีเวนต์แอดมิน|Regalo, offline cash at admin events|Hadiah, wang luar talian dan acara admin
Teleports|Işınlanma|Teletransportes|الانتقال الفوري|Téléportations|टेलीपोर्ट|Teletransportes|Телепорты|Teleports|Teleportasi|テレポート|텔레포트|Dịch chuyển|传送|Teleport|Teleporty|วาป|Mga teleport|Teleport
Throw line, plots and stands|Atış çizgisi, araziler ve standlar|Línea de lanzamiento, parcelas y puestos|خط الرمي والأراضي والأكشاك|Ligne de lancer, terrains et stands|थ्रो लाइन, प्लॉट और स्टैंड|Linha de arremesso, terrenos e estandes|Линия броска, участки и стенды|Wurflinie, Grundstücke und Stände|Garis lempar, lahan, dan stan|投擲ライン・区画・スタンド|던지기 선, 부지, 스탠드|Vạch ném, plot và stand|投掷线、地块与摊位|Linea lancio, terreni e stand|Linia rzutu, działki i stoiska|เส้นขว้าง แปลง และสแตนด์|Throw line, mga plot at stand|Garis lempar, plot dan stand
Movement|Hareket|Movimiento|الحركة|Mouvement|गति|Movimento|Движение|Bewegung|Gerakan|移動|이동|Di chuyển|移动|Movimento|Ruch|การเคลื่อนที่|Paggalaw|Pergerakan
Speed, jump, infinite jump and noclip|Hız, zıplama, sonsuz zıplama ve noclip|Velocidad, salto, salto infinito y noclip|السرعة والقفز والقفز اللانهائي وتجاوز الجدران|Vitesse, saut, saut infini et noclip|गति, कूद, अनंत कूद और नोक्लिप|Velocidade, pulo, pulo infinito e noclip|Скорость, прыжок, бесконечный прыжок и ноклип|Tempo, Sprung, unendlicher Sprung und Noclip|Kecepatan, lompat, lompat tanpa batas, dan noclip|速度・ジャンプ・無限ジャンプ・ノークリップ|속도, 점프, 무한 점프, 노클립|Tốc độ, nhảy, nhảy vô hạn và noclip|速度、跳跃、无限跳与穿墙|Velocità, salto, salto infinito e noclip|Prędkość, skok, nieskończony skok i noclip|ความเร็ว กระโดด กระโดดไม่จำกัด และ noclip|Bilis, talon, infinite jump at noclip|Kelajuan, lompat, lompat tak terhingga dan noclip
Quality of Life|Kullanım Kolaylığı|Calidad de vida|تحسينات الاستخدام|Confort|सुविधाएँ|Qualidade de vida|Удобства|Komfort|Kemudahan|便利機能|편의 기능|Tiện ích|生活质量|Qualità della vita|Wygoda|คุณภาพชีวิต|Kaginhawaan|Kualiti hidup
Anti AFK, rejoin and server hop|Anti AFK, yeniden bağlan ve sunucu değiştir|Anti AFK, reconectar y cambiar de servidor|مكافحة الخمول وإعادة الاتصال وتبديل الخادم|Anti-AFK, reconnexion et changement de serveur|एंटी AFK, दोबारा जुड़ें और सर्वर बदलें|Anti AFK, reconectar e trocar de servidor|Анти-АФК, переподключение и смена сервера|Anti-AFK, erneut beitreten und Serverwechsel|Anti AFK, gabung ulang, dan pindah server|アンチAFK・再参加・サーバー移動|안티 AFK, 재접속, 서버 이동|Chống AFK, vào lại và chuyển server|防挂机、重进与换服|Anti AFK, rientro e server hop|Anti AFK, rejoin i hop serwera|กัน AFK เข้าใหม่ และย้ายเซิร์ฟ|Anti AFK, rejoin at server hop|Anti AFK, sertai semula dan lompat pelayan
Stats|İstatistikler|Estadísticas|الإحصائيات|Statistiques|आँकड़े|Estatísticas|Статистика|Statistiken|Statistik|統計|통계|Thống kê|统计|Statistiche|Statystyki|สถิติ|Stats|Statistik
Live values from your data|Verilerinden canlı değerler|Valores en vivo de tus datos|قيم مباشرة من بياناتك|Valeurs en direct de tes données|आपके डेटा के लाइव मान|Valores ao vivo dos seus dados|Актуальные значения ваших данных|Live-Werte aus deinen Daten|Nilai langsung dari datamu|データのリアルタイム値|내 데이터의 실시간 값|Giá trị realtime từ dữ liệu của bạn|来自你数据的实时数值|Valori live dai tuoi dati|Wartości na żywo z danych|ค่าสดจากข้อมูลของคุณ|Live values mula sa data mo|Nilai langsung dari data anda
Settings|Ayarlar|Ajustes|الإعدادات|Paramètres|सेटिंग्स|Configurações|Настройки|Einstellungen|Pengaturan|設定|설정|Cài đặt|设置|Impostazioni|Ustawienia|การตั้งค่า|Mga setting|Tetapan
Configs, toggle key and auto save|Configler, aç/kapat tuşu ve otomatik kayıt|Configuraciones, tecla de alternar y guardado automático|الإعدادات ومفتاح التبديل والحفظ التلقائي|Configs, touche d'affichage et sauvegarde auto|कॉन्फ़िग, टॉगल कुंजी और ऑटो सेव|Configurações, tecla de alternar e salvamento automático|Конфиги, клавиша меню и автосохранение|Configs, Umschalttaste und Auto-Speichern|Konfigurasi, tombol buka/tutup, dan simpan otomatis|設定ファイル・切替キー・自動保存|설정 파일, 토글 키, 자동 저장|Config, phím bật/tắt và tự lưu|配置、开关键与自动保存|Config, tasto toggle e auto salvataggio|Konfigi, klawisz i auto zapis|คอนฟิก ปุ่มสลับ และบันทึกอัตโนมัติ|Configs, toggle key at auto save|Konfigurasi, kekunci togol dan auto simpan
WORKSPACE|ÇALIŞMA ALANI|ESPACIO DE TRABAJO|مساحة العمل|ESPACE DE TRAVAIL|कार्यक्षेत्र|ÁREA DE TRABALHO|РАБОЧЕЕ МЕСТО|ARBEITSBEREICH|RUANG KERJA|ワークスペース|작업 공간|KHÔNG GIAN LÀM VIỆC|工作区|AREA DI LAVORO|PRZESTRZEŃ ROBOCZA|พื้นที่ทำงาน|WORKSPACE|RUANG KERJA
MONEY|PARA|DINERO|المال|ARGENT|पैसा|DINHEIRO|ДЕНЬГИ|GELD|UANG|お金|돈|TIỀN|金钱|DENARO|PIENIĄDZE|เงิน|PERA|WANG
Close A6 Hub?|A6 Hub kapatılsın mı?|¿Cerrar A6 Hub?|هل تريد إغلاق A6 Hub؟|Fermer A6 Hub ?|A6 Hub बंद करें?|Fechar A6 Hub?|Закрыть A6 Hub?|A6 Hub schließen?|Tutup A6 Hub?|A6 Hub を閉じますか？|A6 Hub를 닫을까요?|Đóng A6 Hub?|关闭 A6 Hub？|Chiudere A6 Hub?|Zamknąć A6 Hub?|ปิด A6 Hub?|Isara ang A6 Hub?|Tutup A6 Hub?
Using A6 Hub|A6 kullanıyor|usando A6|يستخدمون A6|utilisent A6|A6 उपयोग में|usando A6|используют A6|nutzen A6|memakai A6|A6 利用中|A6 사용 중|đang dùng A6 Hub|正在使用 A6 Hub|usando A6 Hub|używa A6 Hub|กำลังใช้ A6 Hub|gumagamit ng A6 Hub|menggunakan A6 Hub
Connected to A6 Hub|A6'ya bağlanıldı|Conectado a A6|متصل بـ A6|Connecté à A6|A6 से जुड़ा है|Conectado ao A6|Подключено к A6|Mit A6 verbunden|Terhubung ke A6|A6 に接続済み|A6에 연결됨|Đã kết nối A6 Hub|已连接到 A6 Hub|Connesso ad A6 Hub|Połączono z A6 Hub|เชื่อมต่อ A6 Hub แล้ว|Nakakonekta sa A6 Hub|Disambungkan ke A6 Hub
Connecting to A6 Hub...|A6'ya bağlanılıyor...|Conectando a A6...|جارٍ الاتصال بـ A6...|Connexion à A6...|A6 से जुड़ रहे हैं...|Conectando ao A6...|Подключение к A6...|Verbinde mit A6...|Menghubungkan ke A6...|A6 に接続中...|A6에 연결 중...|Đang kết nối A6 Hub...|正在连接 A6 Hub...|Connessione ad A6 Hub...|Łączenie z A6 Hub...|กำลังเชื่อมต่อ A6 Hub...|Kumokonekta sa A6 Hub...|Menyambung ke A6 Hub...
Idle|Boşta|Inactivo|خامل|Inactif|निष्क्रिय|Ocioso|Простой|Leerlauf|Menganggur|待機中|대기 중|Chờ|空闲|Inattivo|Bezczynny|ว่าง|Idle|Melahu
Throw Only|Sadece Atış|Solo lanzar|الرمي فقط|Lancer seulement|सिर्फ़ थ्रो|Só arremessar|Только броски|Nur Werfen|Lempar Saja|投擲のみ|던지기만|Chỉ ném|仅投掷|Solo lancio|Tylko rzut|ขว้างอย่างเดียว|Throw lang|Lempar sahaja
Train Only|Sadece Antrenman|Solo entrenar|التدريب فقط|Entraîner seulement|सिर्फ़ प्रशिक्षण|Só treinar|Только тренировка|Nur Training|Latihan Saja|トレーニングのみ|훈련만|Chỉ luyện|仅训练|Solo allenamento|Tylko trening|ฝึกอย่างเดียว|Training lang|Latihan sahaja
Cycle|Döngü|Ciclo|دورة|Cycle|चक्र|Ciclo|Цикл|Zyklus|Siklus|サイクル|사이클|Chu kỳ|循环|Ciclo|Cykl|วนรอบ|Cycle|Kitaran
Cycle (Throw then Train)|Döngü (Atış sonra Antrenman)|Ciclo (lanzar y luego entrenar)|دورة (رمي ثم تدريب)|Cycle (lancer puis entraîner)|चक्र (थ्रो फिर प्रशिक्षण)|Ciclo (arremessar e depois treinar)|Цикл (бросок, затем тренировка)|Zyklus (Werfen, dann Training)|Siklus (lempar lalu latihan)|サイクル（投擲→トレーニング）|사이클 (던지기 후 훈련)|Chu kỳ (Ném rồi Luyện)|循环（先投再练）|Ciclo (lancio poi allenamento)|Cykl (rzut potem trening)|วน (ขว้างแล้วฝึก)|Cycle (Throw tapos Train)|Kitaran (Lempar kemudian Latihan)
Search settings...|Ayarlarda ara...|Buscar ajustes...|ابحث في الإعدادات...|Rechercher dans les paramètres...|सेटिंग्स खोजें...|Buscar configurações...|Поиск настроек...|Einstellungen suchen...|Cari pengaturan...|設定を検索...|설정 검색...|Tìm cài đặt...|搜索设置...|Cerca impostazioni...|Szukaj ustawień...|ค้นหาการตั้งค่า...|Maghanap ng settings...|Cari tetapan...
Start Farm|Farmı Başlat|Iniciar farm|بدء الزراعة|Lancer le farm|फ़ार्म शुरू करें|Iniciar farm|Запустить фарм|Farm starten|Mulai Farm|ファーム開始|파밍 시작|Bắt đầu Farm|开始挂机|Avvia Farm|Start Farm|เริ่มฟาร์ม|Simulan ang Farm|Mula Farm
Stop Farm|Farmı Durdur|Detener farm|إيقاف الزراعة|Arrêter le farm|फ़ार्म रोकें|Parar farm|Остановить фарм|Farm stoppen|Hentikan Farm|ファーム停止|파밍 중지|Dừng Farm|停止挂机|Ferma Farm|Stop Farm|หยุดฟาร์ม|Itigil ang Farm|Henti Farm
Stop|Durdur|Detener|إيقاف|Arrêter|रोकें|Parar|Стоп|Stopp|Berhenti|停止|중지|Dừng|停止|Stop|Stop|หยุด|Stop|Henti
Start|Başlat|Iniciar|ابدأ|Démarrer|शुरू करें|Iniciar|Старт|Start|Mulai|開始|시작|Bắt đầu|开始|Avvia|Start|เริ่ม|Start|Mula
Starting|Başlıyor|Iniciando|جارٍ البدء|Démarrage|शुरू हो रहा है|Iniciando|Запуск|Startet|Memulai|開始中|시작 중|Đang bắt đầu|正在启动|Avvio|Uruchamianie|กำลังเริ่ม|Nagsisimula|Memulakan
Starting...|Başlıyor...|Iniciando...|جارٍ البدء...|Démarrage...|शुरू हो रहा है...|Iniciando...|Запуск...|Startet...|Memulai...|開始中...|시작 중...|Đang bắt đầu...|正在启动...|Avvio...|Uruchamianie...|กำลังเริ่ม...|Nagsisimula...|Memulakan...
throws|atış|lanzamientos|رميات|lancers|थ्रो|arremessos|бросков|Würfe|lemparan|回|회|ném|次投掷|lanci|rzuty|ครั้ง|throws|lemparan
Press play to run the selected modules|Seçili modülleri çalıştırmak için oynat'a bas|Pulsa reproducir para ejecutar los módulos seleccionados|اضغط تشغيل لتشغيل الوحدات المحددة|Appuie sur lecture pour lancer les modules choisis|चयनित मॉड्यूल चलाने के लिए प्ले दबाएँ|Pressione play para executar os módulos selecionados|Нажмите «играть», чтобы запустить выбранные модули|Drücke Play, um die gewählten Module zu starten|Tekan putar untuk menjalankan modul terpilih|再生を押して選択したモジュールを実行|재생을 눌러 선택한 모듈을 실행하세요|Nhấn play để chạy module đã chọn|按播放以运行所选模块|Premi play per i moduli selezionati|Naciśnij play by uruchomić wybrane|กดเล่นเพื่อรันโมดูลที่เลือก|Pindutin ang play para sa napiling modules|Tekan main untuk jalankan modul dipilih
Live Stats|Canlı İstatistikler|Estadísticas en vivo|إحصائيات مباشرة|Stats en direct|लाइव आँकड़े|Estatísticas ao vivo|Статистика онлайн|Live-Statistiken|Statistik Langsung|ライブ統計|실시간 통계|Thống kê realtime|实时统计|Statistiche live|Statystyki na żywo|สถิติสด|Live Stats|Statistik langsung
Money|Para|Dinero|المال|Argent|पैसा|Dinheiro|Деньги|Geld|Uang|お金|돈|Tiền|金钱|Denaro|Pieniądze|เงิน|Pera|Wang
Level|Seviye|Nivel|المستوى|Niveau|स्तर|Nível|Уровень|Level|Level|レベル|레벨|Cấp|等级|Livello|Poziom|เลเวล|Level|Tahap
Throw Power|Atış Gücü|Fuerza de lanzamiento|قوة الرمي|Puissance de lancer|थ्रो शक्ति|Força de arremesso|Сила броска|Wurfkraft|Kekuatan Lempar|投擲パワー|던지기 힘|Sức ném|投掷力|Potenza lancio|Siła rzutu|พลังขว้าง|Throw Power|Kuasa lempar
Throws|Atışlar|Lanzamientos|الرميات|Lancers|थ्रो|Arremessos|Броски|Würfe|Lemparan|投擲回数|던지기|Số lần ném|投掷次数|Lanci|Rzuty|จำนวนขว้าง|Throws|Lemparan
Equipped Food|Kuşanılan Yemek|Comida equipada|الطعام المجهز|Nourriture équipée|सुसज्जित खाना|Comida equipada|Экипированная еда|Ausgerüstetes Futter|Makanan Dipakai|装備中のフード|장착한 먹이|Thức ăn đang trang bị|已装备食物|Cibo equipaggiato|Założone jedzenie|อาหารที่สวม|Naka-equip na pagkain|Makanan dilengkapi
None|Yok|Ninguno|لا شيء|Aucun|कोई नहीं|Nenhum|Нет|Keine|Tidak ada|なし|없음|Không|无|Nessuno|Brak|ไม่มี|Wala|Tiada
Fence Level|Çit Seviyesi|Nivel de valla|مستوى السياج|Niveau de clôture|बाड़ स्तर|Nível da cerca|Уровень забора|Zaunlevel|Level Pagar|フェンスレベル|울타리 레벨|Cấp hàng rào|围栏等级|Livello recinzione|Poziom płotu|เลเวลรั้ว|Level ng bakod|Tahap pagar
Stand Level|Stand Seviyesi|Nivel del puesto|مستوى الكشك|Niveau du stand|स्टैंड स्तर|Nível do estande|Уровень стенда|Standlevel|Level Stan|スタンドレベル|스탠드 레벨|Cấp stand|摊位等级|Livello stand|Poziom stoiska|เลเวลสแตนด์|Level ng stand|Tahap stand
AUTO FARM SESSION|OTO FARM OTURUMU|SESIÓN DE AUTO FARM|جلسة المزرعة التلقائية|SESSION AUTO FARM|ऑटो फ़ार्म सत्र|SESSÃO DE AUTO FARM|СЕССИЯ АВТО-ФАРМА|AUTO-FARM-SITZUNG|SESI AUTO FARM|オートファームセッション|자동 파밍 세션|PHIÊN AUTO FARM|自动挂机会话|SESSIONE AUTO FARM|SESJA AUTO FARM|เซสชันออโต้ฟาร์ม|AUTO FARM SESSION|SESI AUTO FARM
Phase|Aşama|Fase|المرحلة|Phase|चरण|Fase|Этап|Phase|Fase|フェーズ|단계|Giai đoạn|阶段|Fase|Faza|เฟส|Phase|Fasa
Time|Süre|Tiempo|الوقت|Temps|समय|Tempo|Время|Zeit|Waktu|時間|시간|Thời gian|时间|Tempo|Czas|เวลา|Oras|Masa
Money Gained|Kazanılan Para|Dinero ganado|المال المكتسب|Argent gagné|कमाया गया पैसा|Dinheiro ganho|Заработано|Gewonnenes Geld|Uang Didapat|獲得したお金|획득한 돈|Tiền kiếm được|获得金钱|Denaro guadagnato|Zarobione pieniądze|เงินที่ได้|Nakuhang pera|Wang diperolehi
Money / Hour|Para / Saat|Dinero / hora|المال / ساعة|Argent / heure|पैसा / घंटा|Dinheiro / hora|Деньги / час|Geld / Stunde|Uang / Jam|お金 / 時間|돈 / 시간|Tiền / giờ|金钱/小时|Denaro / ora|Pieniądze / godz.|เงิน / ชม.|Pera / oras|Wang / jam
Bonus Taps|Bonus Dokunuşları|Toques de bonus|نقرات المكافأة|Taps bonus|बोनस टैप|Toques de bônus|Бонус-нажатия|Bonus-Taps|Ketukan Bonus|ボーナスタップ|보너스 탭|Nhấn bonus|奖励点击|Tap bonus|Tap bonusów|แตะโบนัส|Bonus taps|Ketik bonus
Open chat with Discord-style channels.|Discord tarzı kanallarla sohbet et.|Abre el chat con canales al estilo Discord.|افتح دردشة بقنوات على نمط Discord.|Un chat avec des salons de type Discord.|Discord जैसे चैनलों वाली चैट खोलें।|Abra o chat com canais no estilo Discord.|Откройте чат с каналами в стиле Discord.|Öffne den Chat mit Kanälen im Discord-Stil.|Buka chat dengan kanal bergaya Discord.|Discord風のチャンネルでチャットを開きます。|Discord 스타일 채널로 채팅을 여세요.|Mở chat kênh kiểu Discord.|打开类 Discord 频道聊天。|Apri chat con canali stile Discord.|Otwórz czat z kanałami jak Discord.|เปิดแชทช่องแบบ Discord|Buksan ang chat na may Discord-style channels.|Buka sembang saluran gaya Discord.
Execute|Çalıştır|Ejecutar|تشغيل|Exécuter|चलाएँ|Executar|Запустить|Ausführen|Jalankan|実行|실행|Chạy|执行|Esegui|Uruchom|รัน|Ipatupad|Laksana
This executor cannot launch scripts.|Bu executor script başlatmayı desteklemiyor.|Este ejecutor no puede iniciar scripts.|هذا المنفّذ لا يستطيع تشغيل السكربتات.|Cet exécuteur ne peut pas lancer de scripts.|यह एक्ज़ीक्यूटर स्क्रिप्ट नहीं चला सकता।|Este executor não pode iniciar scripts.|Этот исполнитель не может запускать скрипты.|Dieser Executor kann keine Skripte starten.|Executor ini tidak bisa menjalankan skrip.|このエグゼキューターはスクリプトを起動できません。|이 실행기는 스크립트를 실행할 수 없습니다.|Executor này không chạy được script.|此执行器无法启动脚本。|Questo executor non avvia script.|Ten executor nie uruchamia skryptów.|เอ็กซีคิวเตอร์นี้รันสคริปต์ไม่ได้|Hindi makapagpatakbo ng script ang executor na ito.|Executor ini tidak boleh lancarkan skrip.
Loading...|Yükleniyor...|Cargando...|جارٍ التحميل...|Chargement...|लोड हो रहा है...|Carregando...|Загрузка...|Lädt...|Memuat...|読み込み中...|불러오는 중...|Đang tải...|加载中...|Caricamento...|Ładowanie...|กำลังโหลด...|Naglo-load...|Memuatkan...
Couldn't launch chat. Check your connection and try again.|Sohbet başlatılamadı. Bağlantını kontrol edip tekrar dene.|No se pudo abrir el chat. Comprueba tu conexión e inténtalo de nuevo.|تعذر فتح الدردشة. تحقق من اتصالك وحاول مجددًا.|Impossible d'ouvrir le chat. Vérifie ta connexion et réessaie.|चैट शुरू नहीं हो सका। कनेक्शन जाँचकर फिर कोशिश करें।|Não foi possível abrir o chat. Verifique a conexão e tente novamente.|Не удалось открыть чат. Проверьте подключение и повторите попытку.|Chat konnte nicht gestartet werden. Prüfe deine Verbindung und versuche es erneut.|Tidak dapat membuka chat. Periksa koneksi dan coba lagi.|チャットを起動できませんでした。接続を確認して再試行してください。|채팅을 실행할 수 없습니다. 연결을 확인하고 다시 시도하세요.|Không mở được chat. Kiểm tra kết nối rồi thử lại.|无法启动聊天。请检查网络后重试。|Impossibile aprire la chat. Controlla la connessione.|Nie uruchomiono czatu. Sprawdź połączenie.|เปิดแชทไม่ได้ ตรวจเน็ตแล้วลองใหม่|Hindi mabuksan ang chat. Tingnan ang koneksyon.|Gagal buka sembang. Semak sambungan dan cuba lagi.
Target|Hedef|Objetivo|الهدف|Cible|लक्ष्य|Alvo|Цель|Ziel|Target|ターゲット|목표|Mục tiêu|目标|Obiettivo|Cel|เป้าหมาย|Target|Sasaran
Target Area|Hedef Alan|Zona objetivo|المنطقة المستهدفة|Zone cible|लक्ष्य क्षेत्र|Área alvo|Целевая зона|Zielzone|Area Target|ターゲットエリア|목표 구역|Khu vực đích|目标区域|Zona obiettivo|Strefa docelowa|พื้นที่เป้า|Target Area|Kawasan sasaran
Selected Area|Seçili Alan|Zona seleccionada|المنطقة المحددة|Zone sélectionnée|चयनित क्षेत्र|Área selecionada|Выбранная зона|Gewählte Zone|Area Terpilih|選択中のエリア|선택된 구역|Khu vực đã chọn|已选区域|Zona selezionata|Wybrana strefa|พื้นที่ที่เลือก|Napiling Area|Kawasan dipilih
Accuracy and timing|İsabet ve zamanlama|Precisión y tiempo|الدقة والتوقيت|Précision et timing|सटीकता और समय|Precisão e tempo|Точность и тайминг|Genauigkeit und Timing|Akurasi dan waktu|精度とタイミング|정확도 및 타이밍|Độ chính xác và thời gian|精度与时机|Precisione e timing|Celność i timing|ความแม่นและจังหวะ|Accuracy at timing|Ketepatan dan masa
Throw Accuracy|Atış İsabeti|Precisión de lanzamiento|دقة الرمي|Précision du lancer|थ्रो सटीकता|Precisão do arremesso|Точность броска|Wurfgenauigkeit|Akurasi Lempar|投擲精度|던지기 정확도|Độ chính xác ném|投掷精度|Precisione lancio|Celność rzutu|ความแม่นขว้าง|Throw Accuracy|Ketepatan lempar
Max Meter Wait|Maks. Metre Bekleme|Espera máx. del medidor|أقصى انتظار للمقياس|Attente max. de la jauge|मीटर की अधिकतम प्रतीक्षा|Espera máx. do medidor|Макс. ожидание шкалы|Max. Messwartezeit|Maks. Tunggu Meter|メーター最大待機|미터 최대 대기|Chờ meter tối đa|最大计量等待|Attesa max meter|Max czas licznika|รอมิเตอร์สูงสุด|Max Meter Wait|Tunggu meter maks
Planned Tap|Planlanan Dokunuş|Toque planificado|النقرة المخططة|Tap prévu|नियोजित टैप|Toque planejado|Запланированный тап|Geplanter Tap|Ketukan Terencana|予定タップ|예정된 탭|Nhấn dự kiến|计划点击|Tap pianificato|Planowany tap|แตะที่วางแผน|Planned Tap|Ketik dirancang
Throw Delay|Atış Gecikmesi|Retraso de lanzamiento|تأخير الرمي|Délai de lancer|थ्रो विलंब|Atraso do arremesso|Задержка броска|Wurfverzögerung|Jeda Lempar|投擲ディレイ|던지기 지연|Độ trễ ném|投掷延迟|Ritardo lancio|Opóźnienie rzutu|ดีเลย์ขว้าง|Throw Delay|Lengah lempar
Automation|Otomasyon|Automatización|الأتمتة|Automatisation|स्वचालन|Automação|Автоматизация|Automatisierung|Otomatisasi|自動化|자동화|Tự động|自动化|Automazione|Automatyzacja|อัตโนมัติ|Automation|Automasi
Auto Throw|Otomatik Atış|Lanzamiento automático|رمي تلقائي|Lancer auto|ऑटो थ्रो|Arremesso automático|Автобросок|Auto-Wurf|Lempar Otomatis|自動投擲|자동 던지기|Tự động ném|自动投掷|Auto lancio|Auto rzut|ออโต้ขว้าง|Auto Throw|Auto lempar
Auto Throw on|Otomatik Atış açık|Lanzamiento automático activado|الرمي التلقائي مفعل|Lancer auto activé|ऑटो थ्रो चालू|Arremesso automático ativado|Автобросок включён|Auto-Wurf an|Lempar Otomatis aktif|自動投擲オン|자동 던지기 켜짐|Tự động ném bật|自动投掷已开启|Auto lancio attivo|Auto rzut włączony|ออโต้ขว้างเปิด|Naka-on ang Auto Throw|Auto lempar dihidupkan
Teleports to the line and throws automatically; cutscene and result card are skipped|Çizgiye ışınlanıp otomatik atar; ara sahne ve sonuç kartı atlanır|Se teletransporta a la línea y lanza automáticamente; se omiten la cinemática y la tarjeta de resultado|ينتقل إلى الخط ويرمي تلقائيًا؛ يتم تخطي المشهد وبطاقة النتيجة|Se téléporte à la ligne et lance automatiquement ; cinématique et carte de résultat ignorées|लाइन पर टेलीपोर्ट होकर अपने आप फेंकता है; कटसीन और रिज़ल्ट कार्ड छोड़े जाते हैं|Teletransporta para a linha e arremessa automaticamente; a cena e o cartão de resultado são pulados|Телепорт к линии и автоматический бросок; заставка и карточка результата пропускаются|Teleportiert zur Linie und wirft automatisch; Zwischensequenz und Ergebniskarte werden übersprungen|Teleport ke garis dan lempar otomatis; cutscene dan kartu hasil dilewati|ラインにテレポートして自動で投げます。カットシーンと結果カードはスキップされます|라인으로 텔레포트해 자동으로 던집니다. 컷신과 결과 카드는 건너뜁니다|Dịch tới vạch và tự ném; bỏ qua cutscene và thẻ kết quả|传送到线并自动投掷；跳过过场与结果卡|Si teletrasporta alla linea e lancia; cutscene e carta risultato saltate|TP do linii i auto rzut; pomija cutscenę i kartę wyniku|วาปไปเส้นแล้วขว้างอัตโนมัติ ข้ามคัทซีนกับการ์ดผล|Teleport sa line at auto throw; skip cutscene at result card|Teleport ke garisan dan lempar auto; cutscene dan kad keputusan dilangkau
Auto Throw off|Otomatik Atış kapalı|Lanzamiento automático desactivado|الرمي التلقائي متوقف|Lancer auto désactivé|ऑटो थ्रो बंद|Arremesso automático desativado|Автобросок выключен|Auto-Wurf aus|Lempar Otomatis nonaktif|自動投擲オフ|자동 던지기 꺼짐|Tự động ném tắt|自动投掷已关闭|Auto lancio disattivo|Auto rzut wyłączony|ออโต้ขว้างปิด|Naka-off ang Auto Throw|Auto lempar dimatikan
Skip Cutscene|Ara Sahneyi Atla|Omitir cinemática|تخطي المشهد|Passer la cinématique|कटसीन छोड़ें|Pular cena|Пропуск заставки|Zwischensequenz überspringen|Lewati Cutscene|カットシーンをスキップ|컷신 건너뛰기|Bỏ cutscene|跳过过场|Salta cutscene|Pomiń cutscenę|ข้ามคัทซีน|Skip Cutscene|Langkau cutscene
Skip Result Card (tap to continue)|Sonuç Kartını Atla (devam için dokun)|Omitir tarjeta de resultado (toca para continuar)|تخطي بطاقة النتيجة (انقر للمتابعة)|Passer la carte de résultat (toucher pour continuer)|रिज़ल्ट कार्ड छोड़ें (जारी रखने के लिए टैप)|Pular cartão de resultado (toque para continuar)|Пропуск карточки результата (нажмите, чтобы продолжить)|Ergebniskarte überspringen (tippen zum Fortfahren)|Lewati Kartu Hasil (ketuk untuk lanjut)|結果カードをスキップ（タップで続行）|결과 카드 건너뛰기 (탭하여 계속)|Bỏ thẻ kết quả (nhấn để tiếp)|跳过结果卡（点击继续）|Salta carta risultato (tocca per continuare)|Pomiń kartę wyniku (dotknij by kontynuować)|ข้ามการ์ดผล (แตะเพื่อต่อ)|Skip Result Card (tap to continue)|Langkau kad keputusan (ketik untuk terus)
Use Super Throws|Süper Atışları Kullan|Usar superlanzamientos|استخدام الرميات الخارقة|Utiliser les super lancers|सुपर थ्रो इस्तेमाल करें|Usar superarremessos|Использовать суперброски|Superwürfe nutzen|Gunakan Super Lempar|スーパー投擲を使う|슈퍼 던지기 사용|Dùng Super Throw|使用超级投掷|Usa Super Throw|Użyj Super Rzutów|ใช้ซูเปอร์ขว้าง|Gamitin ang Super Throws|Guna Super Lempar
If you have a saved Super Throw, the meter locks and the throw is perfect. Without one it keeps doing normal throws.|Kayıtlı bir Süper Atışın varsa metre kilitlenir ve atış mükemmel olur. Yoksa normal atışa devam eder.|Si tienes un superlanzamiento guardado, el medidor se bloquea y el lanzamiento es perfecto. Sin él, sigue con lanzamientos normales.|إذا كان لديك رمية خارقة محفوظة يتوقف المقياس وتكون الرمية مثالية. بدونها يستمر الرمي العادي.|Si tu as un super lancer en réserve, la jauge se bloque et le lancer est parfait. Sinon, il continue en lancers normaux.|यदि आपके पास सेव किया हुआ सुपर थ्रो है तो मीटर लॉक हो जाता है और थ्रो परफेक्ट होता है। न होने पर सामान्य थ्रो चलते रहते हैं।|Se você tiver um superarremesso guardado, o medidor trava e o arremesso é perfeito. Sem ele, continua com arremessos normais.|Если у вас есть сохранённый суперброс, шкала фиксируется и бросок идеален. Без него продолжаются обычные броски.|Mit einem gespeicherten Superwurf rastet die Anzeige ein und der Wurf ist perfekt. Ohne ihn wirft er normal weiter.|Jika kamu punya Super Lempar tersimpan, meter terkunci dan lemparan sempurna. Tanpa itu, tetap lempar biasa.|保存済みのスーパー投擲があるとメーターが固定され完璧な投擲になります。なければ通常投擲を続けます。|저장된 슈퍼 던지기가 있으면 미터가 고정되어 완벽한 던지기가 됩니다. 없으면 일반 던지기를 계속합니다.|Nếu còn Super Throw đã lưu, meter khóa và ném hoàn hảo. Không có thì ném thường.|若有已存超级投掷，计量锁定且投掷完美；否则继续普通投掷。|Con Super Throw salvato il meter si blocca e il lancio è perfetto. Altrimenti lanci normali.|Z zapisanym Super Rzutem licznik się blokuje i rzut jest idealny. Bez niego normalne rzuty.|ถ้ามีซูเปอร์ขว้างที่เซฟไว้ มิเตอร์ล็อกและขว้างสมบูรณ์ ไม่มีก็ขว้างปกติ|Kung may naka-save na Super Throw, maglo-lock ang meter at perfect ang throw. Kung wala, normal throws.|Jika ada Super Lempar disimpan, meter dikunci dan lemparan sempurna. Tanpa itu, lemparan biasa.
Auto Training|Otomatik Antrenman|Entrenamiento automático|تدريب تلقائي|Entraînement auto|ऑटो प्रशिक्षण|Treino automático|Автотренировка|Auto-Training|Latihan Otomatis|自動トレーニング|자동 훈련|Tự luyện|自动训练|Auto allenamento|Auto trening|ออโต้ฝึก|Auto Training|Auto latihan
Auto Throw is on|Otomatik Atış açık|El lanzamiento automático está activado|الرمي التلقائي مفعل|Le lancer auto est activé|ऑटो थ्रो चालू है|O arremesso automático está ativado|Автобросок включён|Auto-Wurf ist an|Lempar Otomatis aktif|自動投擲がオンです|자동 던지기가 켜져 있음|Tự động ném đang bật|自动投掷已开启|Auto lancio è attivo|Auto rzut jest włączony|ออโต้ขว้างเปิดอยู่|Naka-on ang Auto Throw|Auto lempar dihidupkan
Throwing has priority; training starts once throwing is off|Atış önceliklidir; atış kapanınca antrenman başlar|El lanzamiento tiene prioridad; el entrenamiento empieza al apagarlo|للرمي الأولوية؛ يبدأ التدريب عند إيقافه|Le lancer est prioritaire ; l'entraînement démarre quand il est coupé|थ्रो को प्राथमिकता है; थ्रो बंद होने पर प्रशिक्षण शुरू होगा|O arremesso tem prioridade; o treino começa quando ele for desligado|Броски в приоритете; тренировка начнётся после их отключения|Werfen hat Vorrang; Training startet, sobald es aus ist|Lempar diprioritaskan; latihan mulai setelah lempar dimatikan|投擲が優先され、投擲がオフになるとトレーニングが始まります|던지기가 우선이며, 던지기가 꺼지면 훈련이 시작됩니다|Ném ưu tiên; luyện bắt đầu khi tắt ném|投掷优先；关闭投掷后才开始训练|Il lancio ha priorità; l'allenamento parte quando è spento|Rzut ma priorytet; trening startuje po wyłączeniu|ขว้างมาก่อน ฝึกเริ่มเมื่อปิดขว้าง|Mas priority ang throwing; magsisimula ang training kapag off|Lemparan diutamakan; latihan mula bila dimatikan
Auto Tap x2 Bonus|Otomatik x2 Bonus Dokunuşu|Toque automático de bonus x2|نقر تلقائي لمكافأة x2|Tap auto bonus x2|ऑटो x2 बोनस टैप|Toque automático de bônus x2|Автонажатие бонуса x2|Auto-Tap x2-Bonus|Ketuk Otomatis Bonus x2|x2ボーナス自動タップ|x2 보너스 자동 탭|Tự nhấn bonus x2|自动点击 x2 奖励|Auto tap bonus x2|Auto tap bonus x2|แตะโบนัส x2 อัตโนมัติ|Auto Tap x2 Bonus|Auto ketik bonus x2
Bonus Taps (this session)|Bonus Dokunuşları (bu oturum)|Toques de bonus (esta sesión)|نقرات المكافأة (هذه الجلسة)|Taps bonus (cette session)|बोनस टैप (इस सत्र में)|Toques de bônus (esta sessão)|Бонус-нажатия (эта сессия)|Bonus-Taps (diese Sitzung)|Ketukan Bonus (sesi ini)|ボーナスタップ（今回）|보너스 탭 (이번 세션)|Nhấn bonus (phiên này)|奖励点击（本次会话）|Tap bonus (questa sessione)|Tap bonusów (ta sesja)|แตะโบนัส (เซสชันนี้)|Bonus taps (session na ito)|Ketik bonus (sesi ini)
Teleport to Training Spot|Antrenman Noktasına Işınlan|Teletransportar al punto de entrenamiento|الانتقال إلى نقطة التدريب|Téléportation au point d'entraînement|प्रशिक्षण स्थल पर टेलीपोर्ट|Teletransportar ao ponto de treino|Телепорт к месту тренировки|Zum Trainingspunkt teleportieren|Teleport ke Lokasi Latihan|トレーニング地点へテレポート|훈련 지점으로 텔레포트|Dịch tới chỗ luyện|传送到训练点|TP al punto allenamento|TP do punktu treningu|วาปไปจุดฝึก|Teleport sa Training Spot|Teleport ke tempat latihan
Teleport|Işınlan|Teletransportar|انتقال|Téléporter|टेलीपोर्ट|Teletransportar|Телепорт|Teleport|Teleport|テレポート|텔레포트|Dịch chuyển|传送|Teleport|Teleport|วาป|Teleport|Teleport
Training Spot not found|Antrenman noktası bulunamadı|Punto de entrenamiento no encontrado|لم يتم العثور على نقطة التدريب|Point d'entraînement introuvable|प्रशिक्षण स्थल नहीं मिला|Ponto de treino não encontrado|Место тренировки не найдено|Trainingspunkt nicht gefunden|Lokasi latihan tidak ditemukan|トレーニング地点が見つかりません|훈련 지점을 찾을 수 없음|Không tìm thấy chỗ luyện|未找到训练点|Punto allenamento non trovato|Nie znaleziono punktu treningu|ไม่พบจุดฝึก|Hindi nahanap ang training spot|Tempat latihan tidak dijumpai
Running|Çalışıyor|En marcha|يعمل|En cours|चल रहा है|Em execução|Работает|Läuft|Berjalan|実行中|실행 중|Đang chạy|运行中|In esecuzione|Działa|กำลังทำงาน|Tumatakbo|Berjalan
Auto Index (Fill Missing Animals)|Otomatik Dizin (Eksik Hayvanları Tamamla)|Índice automático (completar animales faltantes)|فهرس تلقائي (إكمال الحيوانات الناقصة)|Index auto (compléter les animaux manquants)|ऑटो इंडेक्स (गायब जानवर पूरे करें)|Índice automático (completar animais faltantes)|Автоиндекс (заполнить недостающих)|Auto-Index (fehlende Tiere auffüllen)|Indeks Otomatis (lengkapi hewan yang kurang)|自動図鑑（足りない動物を埋める）|자동 도감 (빠진 동물 채우기)|Tự điền sổ (thú còn thiếu)|自动图鉴（补全缺失）|Auto indice (completa mancanti)|Auto indeks (uzupełnij brakujące)|ออโต้ดัชนี (เติมที่ขาด)|Auto Index (Punan ang kulang)|Auto indeks (isi yang kurang)
Target area: %s|Hedef alan: %s|Zona objetivo: %s|المنطقة المستهدفة: %s|Zone cible : %s|लक्ष्य क्षेत्र: %s|Área alvo: %s|Целевая зона: %s|Zielzone: %s|Area target: %s|ターゲットエリア: %s|목표 구역: %s|Khu vực đích: %s|目标区域：%s|Zona obiettivo: %s|Strefa docelowa: %s|พื้นที่เป้า: %s|Target area: %s|Kawasan sasaran: %s
Index complete|Dizin tamamlandı|Índice completo|اكتمل الفهرس|Index complet|इंडेक्स पूरा हुआ|Índice completo|Индекс заполнен|Index vollständig|Indeks lengkap|図鑑コンプリート|도감 완성|Sổ đã đủ|图鉴已完成|Indice completo|Indeks kompletny|ดัชนีครบ|Kumpleto ang index|Indeks lengkap
No missing animals in reachable areas|Ulaşılabilir alanlarda eksik hayvan yok|No faltan animales en las zonas alcanzables|لا توجد حيوانات ناقصة في المناطق المتاحة|Aucun animal manquant dans les zones accessibles|पहुँच वाले क्षेत्रों में कोई जानवर गायब नहीं|Nenhum animal faltando nas áreas alcançáveis|В доступных зонах нет недостающих животных|Keine fehlenden Tiere in erreichbaren Zonen|Tidak ada hewan yang kurang di area terjangkau|到達可能なエリアに不足している動物はいません|도달 가능한 구역에 빠진 동물이 없음|Không còn thú thiếu trong khu vực tới được|可达区域内无缺失动物|Nessun animale mancante nelle zone raggiungibili|Brak brakujących w dostępnych strefach|ไม่มีสัตว์ขาดในพื้นที่ถึงได้|Walang kulang sa reachable areas|Tiada haiwan kurang di kawasan boleh dicapai
Next Missing Animal|Sıradaki Eksik Hayvan|Próximo animal faltante|الحيوان الناقص التالي|Prochain animal manquant|अगला गायब जानवर|Próximo animal faltante|Следующее недостающее животное|Nächstes fehlendes Tier|Hewan Kurang Berikutnya|次の不足動物|다음 빠진 동물|Thú thiếu tiếp theo|下一个缺失动物|Prossimo animale mancante|Następne brakujące zwierzę|สัตว์ที่ขาดถัดไป|Susunod na kulang|Haiwan kurang seterusnya
Index Progress|Dizin İlerlemesi|Progreso del índice|تقدم الفهرس|Progression de l'index|इंडेक्स प्रगति|Progresso do índice|Прогресс индекса|Index-Fortschritt|Progres Indeks|図鑑の進捗|도감 진행도|Tiến độ sổ|图鉴进度|Progresso indice|Postęp indeksu|ความคืบหน้าดัชนี|Progreso ng index|Kemajuan indeks
The lowest reachable area that has a missing animal is targeted automatically; Auto Throw throws at that area.|Eksik hayvanı olan ulaşılabilir en düşük alan otomatik hedeflenir; Otomatik Atış o alana atar.|Se apunta automáticamente a la zona alcanzable más baja con un animal faltante; el lanzamiento automático lanza allí.|يتم استهداف أدنى منطقة متاحة تحتوي على حيوان ناقص تلقائيًا؛ ويرمي الرمي التلقائي نحوها.|La zone accessible la plus basse avec un animal manquant est ciblée automatiquement ; le lancer auto y lance.|गायब जानवर वाला सबसे निचला पहुँच योग्य क्षेत्र अपने आप चुना जाता है; ऑटो थ्रो वहीं फेंकता है।|A menor área alcançável com um animal faltando é alvo automático; o arremesso automático lança lá.|Автоматически выбирается самая низкая доступная зона с недостающим животным; автобросок бьёт туда.|Die niedrigste erreichbare Zone mit einem fehlenden Tier wird automatisch angepeilt; der Auto-Wurf wirft dorthin.|Area terendah yang terjangkau dengan hewan kurang dibidik otomatis; Lempar Otomatis melempar ke sana.|不足している動物がいる到達可能な最も低いエリアを自動で狙い、自動投擲がそこへ投げます。|빠진 동물이 있는 도달 가능한 가장 낮은 구역을 자동으로 노리며, 자동 던지기가 그곳으로 던집니다.|Tự nhắm khu vực thấp nhất còn thú thiếu; Auto Throw ném vào đó.|自动瞄准有缺失动物的最低可达区域；自动投掷投向该区。|La zona raggiungibile più bassa con animale mancante è mirata; Auto lancio lancia lì.|Najniższa dostępna strefa z brakującym jest celowana; Auto rzut rzuca tam.|เล็งพื้นที่ต่ำสุดที่มีสัตว์ขาดอัตโนมัติ ออโต้ขว้างไปที่นั่น|Automatic na target ang pinakamababang reachable area na may kulang; Auto Throw doon.|Kawasan terendah boleh dicapai dengan haiwan kurang disasarkan; Auto lempar ke situ.
Auto Buy Best Food (Smart Check)|En İyi Yemeği Otomatik Al (Akıllı Kontrol)|Comprar mejor comida automáticamente (comprobación inteligente)|شراء أفضل طعام تلقائيًا (فحص ذكي)|Achat auto du meilleur aliment (vérification intelligente)|सर्वश्रेष्ठ खाना ऑटो खरीदें (स्मार्ट जाँच)|Comprar melhor comida automaticamente (verificação inteligente)|Автопокупка лучшей еды (умная проверка)|Bestes Futter automatisch kaufen (Smart-Check)|Beli Makanan Terbaik Otomatis (Cek Cerdas)|最高のフードを自動購入（スマートチェック）|최고의 먹이 자동 구매 (스마트 체크)|Tự mua thức ăn tốt nhất (kiểm thông minh)|自动购买最佳食物（智能检查）|Auto compra miglior cibo (check smart)|Auto kup najlepsze jedzenie (smart)|ซื้ออาหารดีสุดอัตโนมัติ (ตรวจอัจฉริยะ)|Auto Buy Best Food (Smart Check)|Auto beli makanan terbaik (semakan pintar)
Auto Equip Best Food|En İyi Yemeği Otomatik Kuşan|Equipar mejor comida automáticamente|تجهيز أفضل طعام تلقائيًا|Équiper auto le meilleur aliment|सर्वश्रेष्ठ खाना ऑटो सुसज्जित करें|Equipar melhor comida automaticamente|Автоэкипировка лучшей еды|Bestes Futter automatisch ausrüsten|Pakai Makanan Terbaik Otomatis|最高のフードを自動装備|최고의 먹이 자동 장착|Tự trang bị thức ăn tốt nhất|自动装备最佳食物|Auto equipaggia miglior cibo|Auto załóż najlepsze jedzenie|สวมอาหารดีสุดอัตโนมัติ|Auto Equip Best Food|Auto lengkapi makanan terbaik
Auto Upgrade Bar (Smart Check)|Barı Otomatik Yükselt (Akıllı Kontrol)|Mejorar barra automáticamente (comprobación inteligente)|ترقية الشريط تلقائيًا (فحص ذكي)|Amélioration auto de la barre (vérification intelligente)|बार ऑटो अपग्रेड (स्मार्ट जाँच)|Melhorar barra automaticamente (verificação inteligente)|Автоулучшение шкалы (умная проверка)|Balken automatisch verbessern (Smart-Check)|Tingkatkan Bar Otomatis (Cek Cerdas)|バーを自動強化（スマートチェック）|바 자동 업그레이드 (스마트 체크)|Tự nâng cấp thanh (kiểm thông minh)|自动升级进度条（智能检查）|Auto upgrade barra (check smart)|Auto ulepsz pasek (smart)|อัปเกรดแถบอัตโนมัติ (ตรวจอัจฉริยะ)|Auto Upgrade Bar (Smart Check)|Auto naik taraf bar (semakan pintar)
Auto Upgrade Fence (Smart Check)|Çiti Otomatik Yükselt (Akıllı Kontrol)|Mejorar valla automáticamente (comprobación inteligente)|ترقية السياج تلقائيًا (فحص ذكي)|Amélioration auto de la clôture (vérification intelligente)|बाड़ ऑटो अपग्रेड (स्मार्ट जाँच)|Melhorar cerca automaticamente (verificação inteligente)|Автоулучшение забора (умная проверка)|Zaun automatisch verbessern (Smart-Check)|Tingkatkan Pagar Otomatis (Cek Cerdas)|フェンスを自動強化（スマートチェック）|울타리 자동 업그레이드 (스마트 체크)|Tự nâng cấp hàng rào (kiểm thông minh)|自动升级围栏（智能检查）|Auto upgrade recinzione (check smart)|Auto ulepsz płot (smart)|อัปเกรดรั้วอัตโนมัติ (ตรวจอัจฉริยะ)|Auto Upgrade Fence (Smart Check)|Auto naik taraf pagar (semakan pintar)
Manual|Manuel|Manual|يدوي|Manuel|मैनुअल|Manual|Вручную|Manuell|Manual|手動|수동|Thủ công|手动|Manuale|Ręcznie|มือ|Manual|Manual
Buy Best Food|En İyi Yemeği Al|Comprar mejor comida|شراء أفضل طعام|Acheter le meilleur aliment|सर्वश्रेष्ठ खाना खरीदें|Comprar melhor comida|Купить лучшую еду|Bestes Futter kaufen|Beli Makanan Terbaik|最高のフードを購入|최고의 먹이 구매|Mua thức ăn tốt nhất|购买最佳食物|Compra miglior cibo|Kup najlepsze jedzenie|ซื้ออาหารดีสุด|Bumili ng Best Food|Beli makanan terbaik
Buy|Al|Comprar|شراء|Acheter|खरीदें|Comprar|Купить|Kaufen|Beli|購入|구매|Mua|购买|Compra|Kup|ซื้อ|Bumili|Beli
Could not buy|Satın alınamadı|No se pudo comprar|تعذر الشراء|Achat impossible|खरीद नहीं हो सकी|Não foi possível comprar|Не удалось купить|Kauf nicht möglich|Gagal membeli|購入できませんでした|구매할 수 없음|Không mua được|无法购买|Impossibile acquistare|Nie udało się kupić|ซื้อไม่ได้|Hindi makabili|Gagal beli
Not enough money or you already own the best food|Yeterli para yok ya da en iyi yemek zaten sende|No tienes suficiente dinero o ya tienes la mejor comida|لا يوجد مال كافٍ أو تملك أفضل طعام بالفعل|Pas assez d'argent ou tu as déjà le meilleur aliment|पर्याप्त पैसा नहीं या आपके पास सर्वश्रेष्ठ खाना पहले से है|Dinheiro insuficiente ou você já tem a melhor comida|Недостаточно денег или лучшая еда уже есть|Nicht genug Geld oder du besitzt das beste Futter schon|Uang tidak cukup atau kamu sudah punya makanan terbaik|お金が足りないか、すでに最高のフードを持っています|돈이 부족하거나 이미 최고의 먹이를 가지고 있음|Không đủ tiền hoặc đã có thức ăn tốt nhất|金钱不足或已拥有最佳食物|Soldi insufficienti o hai già il miglior cibo|Za mało pieniędzy lub masz już najlepsze|เงินไม่พอหรือมีอาหารดีสุดแล้ว|Kulang ang pera o may best food ka na|Wang tidak cukup atau sudah ada makanan terbaik
Equip Best Food|En İyi Yemeği Kuşan|Equipar mejor comida|تجهيز أفضل طعام|Équiper le meilleur aliment|सर्वश्रेष्ठ खाना सुसज्जित करें|Equipar melhor comida|Экипировать лучшую еду|Bestes Futter ausrüsten|Pakai Makanan Terbaik|最高のフードを装備|최고의 먹이 장착|Trang bị thức ăn tốt nhất|装备最佳食物|Equipaggia miglior cibo|Załóż najlepsze jedzenie|สวมอาหารดีสุด|I-equip ang Best Food|Lengkapi makanan terbaik
Equip|Kuşan|Equipar|تجهيز|Équiper|सुसज्जित करें|Equipar|Надеть|Ausrüsten|Pakai|装備|장착|Trang bị|装备|Equipaggia|Załóż|สวม|I-equip|Lengkapi
No change|Değişiklik yok|Sin cambios|لا تغيير|Aucun changement|कोई बदलाव नहीं|Sem alterações|Без изменений|Keine Änderung|Tidak ada perubahan|変更なし|변경 없음|Không đổi|无变化|Nessuna modifica|Bez zmian|ไม่เปลี่ยน|Walang pagbabago|Tiada perubahan
The best food is already equipped|En iyi yemek zaten kuşanılı|La mejor comida ya está equipada|أفضل طعام مجهز بالفعل|Le meilleur aliment est déjà équipé|सर्वश्रेष्ठ खाना पहले से सुसज्जित है|A melhor comida já está equipada|Лучшая еда уже экипирована|Das beste Futter ist bereits ausgerüstet|Makanan terbaik sudah dipakai|最高のフードはすでに装備済みです|최고의 먹이가 이미 장착되어 있음|Thức ăn tốt nhất đã được trang bị|最佳食物已装备|Il miglior cibo è già equipaggiato|Najlepsze jedzenie już założone|สวมอาหารดีสุดอยู่แล้ว|Naka-equip na ang best food|Makanan terbaik sudah dilengkapi
Upgrade Bar|Barı Yükselt|Mejorar barra|ترقية الشريط|Améliorer la barre|बार अपग्रेड करें|Melhorar barra|Улучшить шкалу|Balken verbessern|Tingkatkan Bar|バーを強化|바 업그레이드|Nâng cấp thanh|升级进度条|Upgrade barra|Ulepsz pasek|อัปเกรดแถบ|I-upgrade ang Bar|Naik taraf bar
Upgrade|Yükselt|Mejorar|ترقية|Améliorer|अपग्रेड|Melhorar|Улучшить|Verbessern|Tingkatkan|強化|업그레이드|Nâng cấp|升级|Upgrade|Ulepsz|อัปเกรด|I-upgrade|Naik taraf
Could not upgrade|Yükseltilemedi|No se pudo mejorar|تعذرت الترقية|Amélioration impossible|अपग्रेड नहीं हो सका|Não foi possível melhorar|Не удалось улучшить|Verbesserung nicht möglich|Gagal meningkatkan|強化できませんでした|업그레이드할 수 없음|Không nâng cấp được|无法升级|Impossibile potenziare|Nie udało się ulepszyć|อัปเกรดไม่ได้|Hindi ma-upgrade|Gagal naik taraf
Upgrade Fence|Çiti Yükselt|Mejorar valla|ترقية السياج|Améliorer la clôture|बाड़ अपग्रेड करें|Melhorar cerca|Улучшить забор|Zaun verbessern|Tingkatkan Pagar|フェンスを強化|울타리 업그레이드|Nâng cấp hàng rào|升级围栏|Upgrade recinzione|Ulepsz płot|อัปเกรดรั้ว|I-upgrade ang Fence|Naik taraf pagar
Gold|Altın|Oro|ذهبي|Or|सोना|Ouro|Золото|Gold|Emas|ゴールド|골드|Vàng|金色|Oro|Złoto|ทอง|Ginto|Emas
Diamond|Elmas|Diamante|ألماس|Diamant|हीरा|Diamante|Алмаз|Diamant|Berlian|ダイヤモンド|다이아몬드|Kim cương|钻石|Diamante|Diament|เพชร|Diamante|Berlian
Emerald|Zümrüt|Esmeralda|زمرد|Émeraude|पन्ना|Esmeralda|Изумруд|Smaragd|Zamrud|エメラルド|에메랄드|Ngọc lục bảo|翡翠|Smeraldo|Szmaragd|มรกต|Esmeralda|Zamrud
Ruby|Yakut|Rubí|ياقوت|Rubis|माणिक|Rubi|Рубин|Rubin|Rubi|ルビー|루비|Hồng ngọc|红宝石|Rubino|Rubin|ทับทิม|Ruby|Delima
Rainbow|Gökkuşağı|Arcoíris|قوس قزح|Arc-en-ciel|इंद्रधनुष|Arco-íris|Радуга|Regenbogen|Pelangi|レインボー|무지개|Cầu vồng|彩虹|Arcobaleno|Tęcza|รุ้ง|Bahaghari|Pelangi
Champion|Şampiyon|Campeón|بطل|Champion|चैंपियन|Campeão|Чемпион|Champion|Juara|チャンピオン|챔피언|Nhà vô địch|冠军|Campione|Mistrz|แชมป์|Kampeon|Juara
Lucid|Berrak|Lúcido|صافٍ|Lucide|स्पष्ट|Lúcido|Ясный|Klar|Jernih|ルシッド|루시드|Trong suốt|清醒|Lucido|Przejrzysty|ใส|Lucid|Jernih
Auto Equip Best Animals|En İyi Hayvanları Otomatik Kuşan|Equipar mejores animales automáticamente|تجهيز أفضل الحيوانات تلقائيًا|Équiper auto les meilleurs animaux|सर्वश्रेष्ठ जानवर ऑटो सुसज्जित करें|Equipar melhores animais automaticamente|Автоэкипировка лучших животных|Beste Tiere automatisch ausrüsten|Pakai Hewan Terbaik Otomatis|最強の動物を自動装備|최고의 동물 자동 장착|Tự trang bị thú tốt nhất|自动装备最佳动物|Auto equipaggia migliori animali|Auto załóż najlepsze zwierzęta|สวมสัตว์ดีสุดอัตโนมัติ|Auto Equip Best Animals|Auto lengkapi haiwan terbaik
Equip Best|En İyiyi Kuşan|Equipar lo mejor|تجهيز الأفضل|Équiper le meilleur|सर्वश्रेष्ठ सुसज्जित करें|Equipar o melhor|Экипировать лучших|Beste ausrüsten|Pakai Terbaik|最強を装備|최고 장착|Trang bị tốt nhất|装备最佳|Equipaggia i migliori|Załóż najlepsze|สวมตัวดีสุด|I-equip ang Best|Lengkapi terbaik
Best animals equipped|En iyi hayvanlar kuşanıldı|Mejores animales equipados|تم تجهيز أفضل الحيوانات|Meilleurs animaux équipés|सर्वश्रेष्ठ जानवर सुसज्जित|Melhores animais equipados|Лучшие животные экипированы|Beste Tiere ausgerüstet|Hewan terbaik dipakai|最強の動物を装備しました|최고의 동물 장착 완료|Đã trang bị thú tốt nhất|已装备最佳动物|Migliori animali equipaggiati|Najlepsze zwierzęta założone|สวมสัตว์ดีสุดแล้ว|Na-equip ang best animals|Haiwan terbaik dilengkapi
Could not equip|Kuşanılamadı|No se pudo equipar|تعذر التجهيز|Équipement impossible|सुसज्जित नहीं हो सका|Não foi possível equipar|Не удалось экипировать|Ausrüsten nicht möglich|Gagal memakai|装備できませんでした|장착할 수 없음|Không trang bị được|无法装备|Impossibile equipaggiare|Nie udało się założyć|สวมไม่ได้|Hindi ma-equip|Gagal lengkapi
Auto Place (plot)|Otomatik Yerleştirme (arazi)|Colocación automática (parcela)|وضع تلقائي (الأرض)|Placement auto (terrain)|ऑटो प्लेस (प्लॉट)|Posicionamento automático (terreno)|Авторазмещение (участок)|Auto-Platzierung (Grundstück)|Tempatkan Otomatis (lahan)|自動配置（区画）|자동 배치 (부지)|Tự đặt (plot)|自动放置（地块）|Auto piazza (terreno)|Auto umieść (działka)|วางอัตโนมัติ (แปลง)|Auto Place (plot)|Auto letak (plot)
Auto Place Animals|Hayvanları Otomatik Yerleştir|Colocar animales automáticamente|وضع الحيوانات تلقائيًا|Placer les animaux automatiquement|जानवर ऑटो प्लेस करें|Posicionar animais automaticamente|Авторазмещение животных|Tiere automatisch platzieren|Tempatkan Hewan Otomatis|動物を自動配置|동물 자동 배치|Tự đặt thú|自动放置动物|Auto piazza animali|Auto umieść zwierzęta|วางสัตว์อัตโนมัติ|Auto Place Animals|Auto letak haiwan
Auto Place on|Otomatik Yerleştirme açık|Colocación automática activada|الوضع التلقائي مفعل|Placement auto activé|ऑटो प्लेस चालू|Posicionamento automático ativado|Авторазмещение включено|Auto-Platzierung an|Tempatkan Otomatis aktif|自動配置オン|자동 배치 켜짐|Tự đặt bật|自动放置已开启|Auto piazza attivo|Auto umieszczanie włączone|วางอัตโนมัติเปิด|Naka-on ang Auto Place|Auto letak dihidupkan
Empty slots get filled; a full plot is swapped according to your rules|Boş slotlar doldurulur; arazi doluysa kurallarına göre değiştirilir|Se llenan los espacios vacíos; una parcela llena se intercambia según tus reglas|تُملأ الخانات الفارغة؛ وتُستبدل الأرض الممتلئة وفق قواعدك|Les emplacements vides sont remplis ; un terrain plein est échangé selon tes règles|खाली स्लॉट भरे जाते हैं; भरा प्लॉट आपके नियमों के अनुसार बदला जाता है|Espaços vazios são preenchidos; um terreno cheio é trocado conforme suas regras|Пустые слоты заполняются; полный участок меняется по вашим правилам|Leere Plätze werden gefüllt; ein volles Grundstück wird nach deinen Regeln getauscht|Slot kosong diisi; lahan penuh ditukar sesuai aturanmu|空きスロットを埋め、満杯の区画はルールに従って入れ替えます|빈 슬롯을 채우고, 가득 찬 부지는 규칙에 따라 교체합니다|Ô trống được lấp; plot đầy thì đổi theo quy tắc của bạn|填充空位；满地块按你的规则替换|Gli slot vuoti si riempiono; terreno pieno si scambia secondo le regole|Puste sloty się wypełniają; pełna działka wymienia wg reguł|เติมช่องว่าง แปลงเต็มสลับตามกฎคุณ|Napupuno ang empty slots; full plot ay nagsi-swap ayon sa rules mo|Slot kosong diisi; plot penuh ditukar ikut peraturan anda
Place Order|Yerleştirme Sırası|Orden de colocación|ترتيب الوضع|Ordre de placement|प्लेस क्रम|Ordem de posicionamento|Порядок размещения|Platzierungsreihenfolge|Urutan Penempatan|配置順|배치 순서|Thứ tự đặt|放置顺序|Ordine piazzamento|Kolejność umieszczania|ลำดับการวาง|Place Order|Susunan letak
Highest Income|En Yüksek Gelir|Mayor ingreso|أعلى دخل|Revenu le plus élevé|सबसे अधिक आय|Maior renda|Наибольший доход|Höchstes Einkommen|Pendapatan Tertinggi|最高収入|최고 수입|Thu nhập cao nhất|最高收入|Reddito più alto|Najwyższy dochód|รายได้สูงสุด|Pinakamataas na kita|Pendapatan tertinggi
Highest Rarity|En Yüksek Nadirlik|Mayor rareza|أعلى ندرة|Rareté la plus élevée|सर्वोच्च दुर्लभता|Maior raridade|Наивысшая редкость|Höchste Seltenheit|Kelangkaan Tertinggi|最高レア度|최고 희귀도|Độ hiếm cao nhất|最高稀有度|Rarità più alta|Najwyższa rzadkość|ความหายากสูงสุด|Pinakamataas na rarity|Kelangkaan tertinggi
Mutations First|Önce Mutasyonlular|Mutaciones primero|الطفرات أولًا|Mutations d'abord|पहले म्यूटेशन|Mutações primeiro|Сначала мутации|Mutationen zuerst|Mutasi Dulu|ミューテーション優先|돌연변이 우선|Ưu tiên đột biến|突变优先|Mutazioni prima|Mutacje najpierw|มิวเทชันก่อน|Mutations muna|Mutasi dahulu
Largest Size First|Önce En Büyük Boy|Mayor tamaño primero|الأكبر حجمًا أولًا|Plus grande taille d'abord|पहले सबसे बड़ा आकार|Maior tamanho primeiro|Сначала самый большой размер|Größte Größe zuerst|Ukuran Terbesar Dulu|最大サイズ優先|가장 큰 크기 우선|Ưu tiên kích thước lớn|最大体型优先|Taglia più grande prima|Największy rozmiar najpierw|ขนาดใหญ่ก่อน|Pinakamalaking size muna|Saiz terbesar dahulu
Only Place From Rarity|Sadece Şu Nadirlikten İtibaren Yerleştir|Colocar solo desde la rareza|وضع من هذه الندرة فصاعدًا فقط|Placer seulement à partir de la rareté|केवल इस दुर्लभता से प्लेस करें|Posicionar apenas a partir da raridade|Размещать только от редкости|Nur ab Seltenheit platzieren|Tempatkan Hanya dari Kelangkaan|このレア度以上のみ配置|이 희귀도 이상만 배치|Chỉ đặt từ độ hiếm|仅从此稀有度起放置|Piazza solo da questa rarità|Umieszczaj tylko od tej rzadkości|วางตั้งแต่ความหายากนี้|Maglagay lang mula sa rarity na ito|Letak hanya dari kelangkaan ini
Replace Worst When Plot Is Full|Arazi Doluyken En Kötüyü Değiştir|Reemplazar al peor cuando la parcela esté llena|استبدال الأسوأ عند امتلاء الأرض|Remplacer le pire quand le terrain est plein|प्लॉट भरा होने पर सबसे खराब बदलें|Substituir o pior quando o terreno estiver cheio|Заменять худшего при полном участке|Schlechtestes ersetzen, wenn das Grundstück voll ist|Ganti yang Terburuk Saat Lahan Penuh|区画が満杯のとき最弱を入れ替え|부지가 가득 차면 최악 교체|Đổi thú kém nhất khi plot đầy|地块满时替换最差|Sostituisci il peggiore a terreno pieno|Zamień najgorsze gdy działka pełna|สลับตัวแย่สุดเมื่อแปลงเต็ม|Palitan ang pinakamasama kapag puno ang plot|Ganti terburuk bila plot penuh
Replace Only If Better By|Sadece Şu Kadar Daha İyiyse Değiştir|Reemplazar solo si es mejor en|استبدل فقط إذا كان أفضل بنسبة|Remplacer seulement si meilleur de|केवल इतना बेहतर होने पर बदलें|Substituir apenas se for melhor em|Заменять, только если лучше на|Nur ersetzen, wenn besser um|Ganti Hanya Jika Lebih Baik Sebesar|これ以上優れている場合のみ入れ替え|이만큼 더 좋을 때만 교체|Chỉ đổi nếu tốt hơn|仅当更好时才替换|Sostituisci solo se migliore di|Zamień tylko jeśli lepsze o|สลับเมื่อดีกว่า|Palitan lang kung mas maganda ng|Ganti hanya jika lebih baik sebanyak
Never Remove Placed Mutations|Yerleşik Mutasyonluları Asla Çıkarma|No quitar nunca mutaciones colocadas|لا تزل الطفرات الموضوعة أبدًا|Ne jamais retirer les mutations placées|रखे गए म्यूटेशन कभी न हटाएँ|Nunca remover mutações posicionadas|Никогда не убирать размещённые мутации|Platzierte Mutationen nie entfernen|Jangan Pernah Lepas Mutasi yang Ditempatkan|配置済みミューテーションは外さない|배치된 돌연변이는 절대 제거 안 함|Không bao giờ gỡ đột biến đã đặt|从不移除已放突变|Non rimuovere mai mutazioni piazzate|Nigdy nie usuwaj umieszczonych mutacji|ไม่ถอดมิวเทชันที่วางแล้ว|Huwag kailanman tanggalin ang naka-place na mutations|Jangan buang mutasi yang diletak
Plot Slots|Arazi Slotları|Espacios de parcela|خانات الأرض|Emplacements du terrain|प्लॉट स्लॉट|Espaços do terreno|Слоты участка|Grundstücksplätze|Slot Lahan|区画スロット|부지 슬롯|Ô plot|地块槽位|Slot terreno|Sloty działki|ช่องแปลง|Plot slots|Slot plot
Best Unplaced|En İyi Yerleşmemiş|Mejor sin colocar|أفضل غير موضوع|Meilleur non placé|सर्वश्रेष्ठ अनरखा|Melhor não posicionado|Лучший неразмещённый|Bester nicht platzierter|Terbaik yang Belum Ditempatkan|未配置の最強|배치 안 된 최고|Tốt nhất chưa đặt|最佳未放置|Migliore non piazzato|Najlepsze nieumieszczone|ดีสุดที่ยังไม่วาง|Best hindi naka-place|Terbaik belum diletak
Worst Placed|En Kötü Yerleşik|Peor colocado|أسوأ موضوع|Pire placé|सबसे खराब रखा हुआ|Pior posicionado|Худший размещённый|Schlechtester platzierter|Terburuk yang Ditempatkan|配置済みの最弱|배치된 최악|Kém nhất đang đặt|最差已放置|Peggiore piazzato|Najgorsze umieszczone|แย่สุดที่วางแล้ว|Pinakamasamang naka-place|Terburuk diletak
Place Now|Şimdi Yerleştir|Colocar ahora|ضع الآن|Placer maintenant|अभी प्लेस करें|Posicionar agora|Разместить сейчас|Jetzt platzieren|Tempatkan Sekarang|今すぐ配置|지금 배치|Đặt ngay|立即放置|Piazza ora|Umieść teraz|วางตอนนี้|Ilagay ngayon|Letak sekarang
Run|Çalıştır|Ejecutar|تشغيل|Lancer|चलाएँ|Executar|Запуск|Ausführen|Jalankan|実行|실행|Chạy|运行|Esegui|Uruchom|รัน|Patakbuhin|Jalankan
No changes|Değişiklik yok|Sin cambios|لا تغييرات|Aucun changement|कोई बदलाव नहीं|Sem alterações|Изменений нет|Keine Änderungen|Tidak ada perubahan|変更なし|변경 없음|Không thay đổi|无更改|Nessuna modifica|Bez zmian|ไม่มีการเปลี่ยนแปลง|Walang pagbabago|Tiada perubahan
Candidates are sorted by the chosen order. When the plot is full, the lowest-income placed animal is swapped if the candidate earns more than your margin. While Auto Place is on, animals that would be placed are not sold by Auto Sell.|Adaylar seçilen sıraya göre dizilir. Arazi doluysa en düşük gelirli yerleşik hayvan, adayın geliri senin payından fazlaysa değiştirilir. Otomatik Yerleştirme açıkken yerleşecek hayvanlar Otomatik Satış tarafından satılmaz.|Los candidatos se ordenan según el orden elegido. Con la parcela llena, se cambia el animal colocado de menor ingreso si el candidato gana más que tu margen. Con la colocación automática activa, la venta automática no vende animales que se colocarían.|يتم ترتيب المرشحين حسب الترتيب المختار. عند امتلاء الأرض يُستبدل الحيوان الموضوع الأقل دخلًا إذا كان المرشح يربح أكثر من هامشك. أثناء الوضع التلقائي لا يبيع البيع التلقائي الحيوانات التي سيتم وضعها.|Les candidats sont triés selon l'ordre choisi. Quand le terrain est plein, l'animal placé au plus faible revenu est remplacé si le candidat rapporte plus que ta marge. Avec le placement auto, la vente auto ne vend pas les animaux qui seraient placés.|उम्मीदवार चुने गए क्रम में सजाए जाते हैं। प्लॉट भरा होने पर सबसे कम आय वाला रखा जानवर तब बदला जाता है जब उम्मीदवार आपके मार्जिन से अधिक कमाता है। ऑटो प्लेस चालू होने पर जिन जानवरों को रखा जाएगा उन्हें ऑटो सेल नहीं बेचता।|Os candidatos são ordenados na ordem escolhida. Com o terreno cheio, o animal posicionado de menor renda é trocado se o candidato render mais que sua margem. Com o posicionamento automático ativo, a venda automática não vende animais que seriam posicionados.|Кандидаты сортируются по выбранному порядку. Когда участок полон, размещённое животное с наименьшим доходом заменяется, если кандидат приносит больше вашего порога. Пока авторазмещение включено, автопродажа не продаёт животных, которые были бы размещены.|Kandidaten werden nach der gewählten Reihenfolge sortiert. Ist das Grundstück voll, wird das platzierte Tier mit dem geringsten Einkommen getauscht, wenn der Kandidat mehr als deine Marge einbringt. Bei aktiver Auto-Platzierung verkauft Auto-Verkauf keine Tiere, die platziert würden.|Kandidat diurutkan sesuai urutan yang dipilih. Saat lahan penuh, hewan dengan pendapatan terendah ditukar jika kandidat menghasilkan lebih dari margin-mu. Saat Tempatkan Otomatis aktif, hewan yang akan ditempatkan tidak dijual oleh Jual Otomatis.|候補は選択した順に並びます。区画が満杯のとき、候補の収入が設定した差を上回れば、配置済みで最も収入の低い動物と入れ替えます。自動配置がオンの間、配置される動物は自動売却されません。|후보는 선택한 순서로 정렬됩니다. 부지가 가득 차면 후보가 설정한 기준보다 더 벌 때 수입이 가장 낮은 배치 동물과 교체합니다. 자동 배치가 켜져 있는 동안 배치될 동물은 자동 판매되지 않습니다.|Ứng viên xếp theo thứ tự đã chọn. Khi plot đầy, thú thu nhập thấp nhất bị đổi nếu ứng viên kiếm hơn biên độ của bạn. Khi Tự đặt bật, thú sẽ được đặt không bị Auto Sell bán.|候选按所选顺序排序。地块满时，若候选收入超过你的边际则替换最低收入已放动物。自动放置开启时，将被放置的动物不会被自动出售卖掉。|I candidati sono ordinati per l'ordine scelto. A terreno pieno, l'animale piazzato a reddito più basso è scambiato se il candidato guadagna più del margine. Con Auto piazza attivo, Auto Sell non vende gli animali da piazzare.|Kandydaci sortowani wg wybranej kolejności. Przy pełnej działce najniższy dochód jest wymieniany, jeśli kandydat zarabia więcej niż marża. Przy włączonym Auto Place Auto Sell nie sprzedaje zwierząt do umieszczenia.|เรียงผู้สมัครตามลำดับที่เลือก เมื่อแปลงเต็มจะสลับตัวรายได้ต่ำสุดถ้าผู้สมัครทำเงินเกินมาร์จิน เมื่อวางอัตโนมัติเปิด สัตว์ที่จะวางจะไม่ถูกขายอัตโนมัติ|Naka-sort ang candidates sa napiling order. Kapag puno ang plot, pinapalitan ang lowest-income kung mas mataas ang kita ng candidate sa margin mo. Habang naka-on ang Auto Place, hindi binebenta ng Auto Sell ang ilalagay.|Calon disusun ikut susunan dipilih. Bila plot penuh, haiwan pendapatan terendah ditukar jika calon menjana lebih daripada margin. Bila Auto Letak hidup, Auto Jual tidak jual haiwan yang akan diletak.
Selling|Satış|Venta|البيع|Vente|बिक्री|Venda|Продажа|Verkauf|Penjualan|売却|판매|Bán|出售|Vendita|Sprzedaż|การขาย|Pagbebenta|Jualan
Auto Sell with Rarity Filter|Nadirlik Filtreli Otomatik Satış|Venta automática con filtro de rareza|بيع تلقائي بفلتر الندرة|Vente auto avec filtre de rareté|दुर्लभता फ़िल्टर के साथ ऑटो सेल|Venda automática com filtro de raridade|Автопродажа с фильтром редкости|Auto-Verkauf mit Seltenheitsfilter|Jual Otomatis dengan Filter Kelangkaan|レア度フィルター付き自動売却|희귀도 필터 자동 판매|Tự bán theo độ hiếm|按稀有度过滤自动出售|Auto vendita con filtro rarità|Auto sprzedaż z filtrem rzadkości|ขายอัตโนมัติกรองความหายาก|Auto Sell with Rarity Filter|Auto jual dengan penapis kelangkaan
Sell Rarities|Satılacak Nadirlikler|Rarezas a vender|الندرات المراد بيعها|Raretés à vendre|बेचने की दुर्लभताएँ|Raridades a vender|Редкости для продажи|Zu verkaufende Seltenheiten|Kelangkaan yang Dijual|売却するレア度|판매할 희귀도|Độ hiếm sẽ bán|出售稀有度|Rarità da vendere|Rzadkości do sprzedaży|ความหายากที่จะขาย|Mga rarity na ibebenta|Kelangkaan untuk dijual
Keep Special Mutations|Özel Mutasyonları Koru|Conservar mutaciones especiales|الاحتفاظ بالطفرات الخاصة|Garder les mutations spéciales|विशेष म्यूटेशन रखें|Manter mutações especiais|Сохранять особые мутации|Besondere Mutationen behalten|Simpan Mutasi Spesial|特別なミューテーションを保持|특별 돌연변이 유지|Giữ đột biến đặc biệt|保留特殊突变|Mantieni mutazioni speciali|Zachowaj specjalne mutacje|เก็บมิวเทชันพิเศษ|Panatilihin ang special mutations|Kekalkan mutasi khas
Keep Large Sizes|Büyük Boyları Koru|Conservar tamaños grandes|الاحتفاظ بالأحجام الكبيرة|Garder les grandes tailles|बड़े आकार रखें|Manter tamanhos grandes|Сохранять крупные размеры|Große Größen behalten|Simpan Ukuran Besar|大きいサイズを保持|큰 크기 유지|Giữ kích thước lớn|保留大体型|Mantieni taglie grandi|Zachowaj duże rozmiary|เก็บขนาดใหญ่|Panatilihin ang malalaking size|Kekalkan saiz besar
Only animals that are not placed on the plot (in your inventory) are sold. The selected rarity filter and kept mutations are applied.|Sadece arazide olmayan (envanterdeki) hayvanlar satılır. Seçili nadirlik filtresi ve korunan mutasyonlar uygulanır.|Solo se venden los animales que no están en la parcela (en tu inventario). Se aplican el filtro de rareza y las mutaciones conservadas.|تُباع فقط الحيوانات غير الموضوعة على الأرض (في مخزونك). يتم تطبيق فلتر الندرة والطفرات المحتفظ بها.|Seuls les animaux non placés sur le terrain (dans ton inventaire) sont vendus. Le filtre de rareté et les mutations gardées s'appliquent.|केवल वे जानवर बेचे जाते हैं जो प्लॉट पर नहीं रखे हैं (इन्वेंटरी में)। चुना हुआ दुर्लभता फ़िल्टर और रखे गए म्यूटेशन लागू होते हैं।|Apenas animais não posicionados no terreno (no inventário) são vendidos. O filtro de raridade e as mutações mantidas são aplicados.|Продаются только животные, не размещённые на участке (в инвентаре). Применяются выбранный фильтр редкости и сохранённые мутации.|Nur Tiere, die nicht auf dem Grundstück stehen (im Inventar), werden verkauft. Der Seltenheitsfilter und behaltene Mutationen gelten.|Hanya hewan yang tidak ditempatkan di lahan (di inventaris) yang dijual. Filter kelangkaan dan mutasi yang disimpan diterapkan.|区画に配置されていない（インベントリの）動物のみ売却されます。選択したレア度フィルターと保持するミューテーションが適用されます。|부지에 배치되지 않은(인벤토리의) 동물만 판매됩니다. 선택한 희귀도 필터와 유지할 돌연변이가 적용됩니다.|Chỉ bán thú chưa đặt trên plot (trong túi). Áp dụng bộ lọc độ hiếm và đột biến giữ lại.|仅出售未放在地块上（在背包中）的动物。应用所选稀有度过滤与保留的突变。|Solo animali non piazzati (in inventario) vengono venduti. Si applicano filtro rarità e mutazioni tenute.|Sprzedawane tylko nieumieszczone (w ekwipunku). Stosowany filtr rzadkości i zachowane mutacje.|ขายเฉพาะที่ไม่อยู่บนแปลง (ในกระเป๋า) ใช้ตัวกรองความหายากและมิวเทชันที่เก็บ|Tanging hayop na hindi naka-place (sa inventory) ang binebenta. Applied ang rarity filter at kept mutations.|Hanya haiwan tidak diletak (dalam inventori) dijual. Penapis kelangkaan dan mutasi dikekalkan digunakan.
Sell Filtered Now|Filtrelileri Şimdi Sat|Vender filtrados ahora|بيع المفلترة الآن|Vendre les filtrés maintenant|फ़िल्टर किए गए अभी बेचें|Vender filtrados agora|Продать отфильтрованных сейчас|Gefilterte jetzt verkaufen|Jual yang Difilter Sekarang|フィルター対象を今すぐ売却|필터된 동물 지금 판매|Bán đã lọc ngay|立即出售已过滤|Vendi filtrati ora|Sprzedaj odfiltrowane teraz|ขายที่กรองแล้วตอนนี้|Ibenta ang naka-filter ngayon|Jual ditapis sekarang
Sell|Sat|Vender|بيع|Vendre|बेचें|Vender|Продать|Verkaufen|Jual|売却|판매|Bán|出售|Vendi|Sprzedaj|ขาย|Ibenta|Jual
Nothing to sell|Satılacak bir şey yok|Nada que vender|لا شيء للبيع|Rien à vendre|बेचने के लिए कुछ नहीं|Nada para vender|Нечего продавать|Nichts zu verkaufen|Tidak ada yang dijual|売却するものがありません|판매할 것이 없음|Không có gì để bán|没有可售|Niente da vendere|Nic do sprzedania|ไม่มีอะไรขาย|Walang ibebenta|Tiada untuk dijual
No inventory animal matches the filter|Filtreye uyan envanter hayvanı yok|Ningún animal del inventario coincide con el filtro|لا يوجد حيوان في المخزون يطابق الفلتر|Aucun animal de l'inventaire ne correspond au filtre|इन्वेंटरी का कोई जानवर फ़िल्टर से मेल नहीं खाता|Nenhum animal do inventário corresponde ao filtro|Нет животных в инвентаре, подходящих под фильтр|Kein Inventartier passt zum Filter|Tidak ada hewan di inventaris yang cocok dengan filter|フィルターに一致するインベントリの動物はいません|필터와 일치하는 인벤토리 동물이 없음|Không thú trong túi khớp bộ lọc|背包中无动物匹配过滤|Nessun animale in inventario corrisponde al filtro|Żadne zwierzę w ekwipunku nie pasuje|ไม่มีสัตว์ในกระเป๋าตรงตัวกรอง|Walang hayop sa inventory na tugma sa filter|Tiada haiwan inventori sepadan penapis
Sell All|Hepsini Sat|Vender todo|بيع الكل|Tout vendre|सब बेचें|Vender tudo|Продать всё|Alle verkaufen|Jual Semua|すべて売却|모두 판매|Bán hết|全部出售|Vendi tutto|Sprzedaj wszystko|ขายทั้งหมด|Ibenta lahat|Jual semua
ALL animals in your inventory will be sold with the game's Sell All. The mutation and rarity filters are not applied.|Envanterindeki TÜM hayvanlar oyunun Hepsini Sat özelliğiyle satılacak. Mutasyon ve nadirlik filtreleri uygulanmaz.|TODOS los animales de tu inventario se venderán con el Vender todo del juego. No se aplican los filtros de mutación y rareza.|سيتم بيع كل الحيوانات في مخزونك عبر "بيع الكل" في اللعبة. لا يتم تطبيق فلاتر الطفرة والندرة.|TOUS les animaux de ton inventaire seront vendus avec le Tout vendre du jeu. Les filtres de mutation et de rareté ne s'appliquent pas.|आपकी इन्वेंटरी के सभी जानवर गेम के सब बेचें से बेचे जाएँगे। म्यूटेशन और दुर्लभता फ़िल्टर लागू नहीं होते।|TODOS os animais do inventário serão vendidos com o Vender tudo do jogo. Os filtros de mutação e raridade não são aplicados.|ВСЕ животные в инвентаре будут проданы игровой кнопкой «Продать всё». Фильтры мутаций и редкости не применяются.|ALLE Tiere in deinem Inventar werden mit dem Alle-verkaufen des Spiels verkauft. Mutations- und Seltenheitsfilter gelten nicht.|SEMUA hewan di inventarismu akan dijual dengan Jual Semua milik game. Filter mutasi dan kelangkaan tidak diterapkan.|インベントリの動物がすべて、ゲームの「すべて売却」で売却されます。ミューテーションとレア度のフィルターは適用されません。|인벤토리의 모든 동물이 게임의 모두 판매로 판매됩니다. 돌연변이 및 희귀도 필터는 적용되지 않습니다.|TẤT CẢ thú trong túi sẽ bán bằng Sell All của game. Không áp dụng lọc đột biến/độ hiếm.|背包中全部动物将用游戏的“全部出售”卖掉。不应用突变与稀有度过滤。|TUTTI gli animali in inventario saranno venduti con Vendi tutto del gioco. Filtri non applicati.|WSZYSTKIE zwierzęta w ekwipunku zostaną sprzedane przez Sell All gry. Filtry nie obowiązują.|สัตว์ในกระเป๋าทั้งหมดจะถูกขายด้วย Sell All ของเกม ไม่ใช้ตัวกรอง|LAHAT ng hayop sa inventory ay ibebenta gamit ang Sell All ng game. Hindi applied ang filters.|SEMUA haiwan dalam inventori akan dijual dengan Sell All permainan. Penapis tidak digunakan.
Everything sold|Hepsi satıldı|Todo vendido|تم بيع كل شيء|Tout est vendu|सब बिक गया|Tudo vendido|Всё продано|Alles verkauft|Semua terjual|すべて売却しました|모두 판매됨|Đã bán hết|已全部售出|Tutto venduto|Wszystko sprzedane|ขายหมดแล้ว|Nabenta lahat|Semua dijual
Could not sell|Satılamadı|No se pudo vender|تعذر البيع|Vente impossible|बेचा नहीं जा सका|Não foi possível vender|Не удалось продать|Verkauf nicht möglich|Gagal menjual|売却できませんでした|판매할 수 없음|Không bán được|无法出售|Impossibile vendere|Nie udało się sprzedać|ขายไม่ได้|Hindi mabenta|Gagal jual
Common|Yaygın|Común|شائع|Commun|सामान्य|Comum|Обычный|Gewöhnlich|Umum|コモン|일반|Thường|普通|Comune|Zwykły|ธรรมดา|Common|Biasa
Uncommon|Yaygın Değil|Poco común|غير شائع|Peu commun|असामान्य|Incomum|Необычный|Ungewöhnlich|Tidak Umum|アンコモン|고급|Không phổ biến|优秀|Non comune|Niepospolity|ไม่ธรรมดา|Uncommon|Luar biasa
Rare|Nadir|Raro|نادر|Rare|दुर्लभ|Raro|Редкий|Selten|Langka|レア|희귀|Hiếm|稀有|Raro|Rzadki|หายาก|Rare|Rare
Epic|Destansı|Épico|ملحمي|Épique|महाकाव्य|Épico|Эпический|Episch|Epik|エピック|영웅|Sử thi|史诗|Epico|Epicki|มหากาพย์|Epic|Epik
Legendary|Efsanevi|Legendario|أسطوري|Légendaire|पौराणिक|Lendário|Легендарный|Legendär|Legendaris|レジェンダリー|전설|Huyền thoại|传说|Leggendario|Legendarny|ตำนาน|Legendary|Lagenda
Mythic|Mitik|Mítico|أسطوري خارق|Mythique|पौराणिक कथा|Mítico|Мифический|Mythisch|Mitos|ミシック|신화|Thần thoại|神话|Mitico|Mityczny|เทพนิยาย|Mythic|Mitos
Secret|Gizli|Secreto|سري|Secret|गुप्त|Secreto|Секретный|Geheim|Rahasia|シークレット|비밀|Bí mật|秘密|Segreto|Sekretny|ลับ|Secret|Rahsia
Divine|İlahi|Divino|إلهي|Divin|दिव्य|Divino|Божественный|Göttlich|Ilahi|ディヴァイン|신성|Thần thánh|神圣|Divino|Boski|ศักดิ์สิทธิ์|Divine|Ilahi
Celestial|Göksel|Celestial|سماوي|Céleste|दिव्य लोक|Celestial|Небесный|Himmlisch|Surgawi|セレスティアル|천상|Thiên thể|天体|Celestiale|Niebiański|สวรรค์|Celestial|Samawi
Eternal|Ebedi|Eterno|أبدي|Éternel|शाश्वत|Eterno|Вечный|Ewig|Abadi|エターナル|영원|Vĩnh cửu|永恒|Eterno|Wieczny|นิรันดร์|Eternal|Abadi
Cosmic|Kozmik|Cósmico|كوني|Cosmique|ब्रह्मांडीय|Cósmico|Космический|Kosmisch|Kosmik|コズミック|우주|Vũ trụ|宇宙|Cosmico|Kosmiczny|จักรวาล|Cosmic|Kosmik
Supreme|Yüce|Supremo|أعلى|Suprême|सर्वोच्च|Supremo|Верховный|Höchste|Agung|スプリーム|지고|Tối cao|至高|Supremo|Najwyższy|สูงสุด|Supreme|Tertinggi
Sovereign|Hükümdar|Soberano|سيادي|Souverain|संप्रभु|Soberano|Суверенный|Souverän|Berdaulat|ソブリン|주권|Chủ quyền|主权|Sovrano|Suwerenny|อธิปไตย|Sovereign|Berdaulat
Auto Claim Free Gifts|Ücretsiz Hediyeleri Otomatik Al|Reclamar regalos gratis automáticamente|المطالبة التلقائية بالهدايا المجانية|Récupérer auto les cadeaux gratuits|मुफ़्त उपहार ऑटो क्लेम करें|Resgatar presentes grátis automaticamente|Автосбор бесплатных подарков|Gratis-Geschenke automatisch abholen|Klaim Hadiah Gratis Otomatis|無料ギフトを自動受取|무료 선물 자동 수령|Tự nhận quà miễn phí|自动领取免费礼物|Auto riscatta regali gratis|Auto odbierz darmowe prezenty|รับของฟรีอัตโนมัติ|Auto Claim Free Gifts|Auto tuntut hadiah percuma
Auto Claim Offline Cash|Çevrimdışı Parayı Otomatik Al|Reclamar dinero offline automáticamente|المطالبة التلقائية بالمال أثناء الغياب|Récupérer auto l'argent hors ligne|ऑफ़लाइन कैश ऑटो क्लेम करें|Resgatar dinheiro offline automaticamente|Автосбор оффлайн-дохода|Offline-Geld automatisch abholen|Klaim Uang Offline Otomatis|オフライン収入を自動受取|오프라인 수익 자동 수령|Tự nhận tiền offline|自动领取离线金币|Auto riscatta soldi offline|Auto odbierz offline cash|รับเงินออฟไลน์อัตโนมัติ|Auto Claim Offline Cash|Auto tuntut wang luar talian
Auto Vote Admin Events|Yönetici Etkinliklerinde Otomatik Oy Ver|Votar automáticamente en eventos de admin|التصويت التلقائي في فعاليات الإدارة|Voter auto aux événements admin|एडमिन इवेंट में ऑटो वोट|Votar automaticamente em eventos de admin|Автоголосование в событиях админов|Bei Admin-Events automatisch abstimmen|Vote Otomatis di Event Admin|管理者イベントで自動投票|관리자 이벤트 자동 투표|Tự vote sự kiện admin|自动投票管理员活动|Auto vota eventi admin|Auto głosuj w eventach admin|โหวตอีเวนต์แอดมินอัตโนมัติ|Auto Vote Admin Events|Auto undi acara admin
In admin event rounds, the option with the most votes gets a vote after a short random delay.|Yönetici etkinlik turlarında en çok oyu alan seçeneğe kısa rastgele bir gecikmeyle oy verilir.|En las rondas de eventos de admin, la opción con más votos recibe un voto tras un breve retraso aleatorio.|في جولات فعاليات الإدارة يُصوَّت للخيار الأكثر أصواتًا بعد تأخير عشوائي قصير.|Lors des événements admin, l'option la plus votée reçoit un vote après un court délai aléatoire.|एडमिन इवेंट राउंड में सबसे अधिक वोट वाले विकल्प को थोड़ी रैंडम देरी के बाद वोट दिया जाता है।|Nas rodadas de eventos de admin, a opção mais votada recebe um voto após um curto atraso aleatório.|В раундах событий админов за самый популярный вариант голосуют после короткой случайной задержки.|In Admin-Event-Runden stimmt er nach kurzer zufälliger Verzögerung für die Option mit den meisten Stimmen.|Di ronde event admin, opsi dengan suara terbanyak diberi suara setelah jeda acak singkat.|管理者イベントのラウンドでは、最も票の多い選択肢に短いランダム遅延の後で投票します。|관리자 이벤트 라운드에서는 가장 많은 표를 받은 선택지에 짧은 무작위 지연 후 투표합니다.|Trong vòng sự kiện admin, lựa chọn nhiều vote nhất được vote sau độ trễ ngẫu nhiên ngắn.|管理员活动回合中，票数最多的选项在短随机延迟后获得一票。|Nei round admin, l'opzione con più voti riceve un voto dopo breve ritardo casuale.|W rundach admin opcja z największą liczbą głosów dostaje głos po krótkim losowym opóźnieniu.|ในรอบอีเวนต์แอดมิน ตัวเลือกที่ได้โหวตมากสุดจะได้โหวตหลังดีเลย์สุ่มสั้นๆ|Sa admin event rounds, ang option na may pinakamaraming boto ay makakakuha ng boto pagkatapos ng maikling random delay.|Dalam pusingan acara admin, pilihan dengan undi terbanyak mendapat undi selepas lengah rawak singkat.
Locations|Konumlar|Ubicaciones|المواقع|Lieux|स्थान|Locais|Места|Orte|Lokasi|場所|위치|Vị trí|地点|Luoghi|Lokalizacje|ตำแหน่ง|Mga lokasyon|Lokasi
Throw Line|Atış Çizgisi|Línea de lanzamiento|خط الرمي|Ligne de lancer|थ्रो लाइन|Linha de arremesso|Линия броска|Wurflinie|Garis Lempar|投擲ライン|던지기 선|Vạch ném|投掷线|Linea di lancio|Linia rzutu|เส้นขว้าง|Throw Line|Garis lempar
My Plot|Arazim|Mi parcela|أرضي|Mon terrain|मेरा प्लॉट|Meu terreno|Мой участок|Mein Grundstück|Lahanku|自分の区画|내 부지|Plot của tôi|我的地块|Il mio terreno|Moja działka|แปลงของฉัน|Aking Plot|Plot saya
Food Shop|Yemek Mağazası|Tienda de comida|متجر الطعام|Boutique de nourriture|खाने की दुकान|Loja de comida|Магазин еды|Futterladen|Toko Makanan|フードショップ|먹이 상점|Cửa hàng thức ăn|食物店|Negozio cibo|Sklep z jedzeniem|ร้านอาหาร|Food Shop|Kedai makanan
Animal Stand|Hayvan Standı|Puesto de animales|كشك الحيوانات|Stand d'animaux|जानवर स्टैंड|Estande de animais|Стенд животных|Tierstand|Stan Hewan|動物スタンド|동물 스탠드|Stand thú|动物摊|Stand animali|Stoisko zwierząt|สแตนด์สัตว์|Animal Stand|Stand haiwan
Sell Stand|Satış Standı|Puesto de venta|كشك البيع|Stand de vente|बिक्री स्टैंड|Estande de venda|Стенд продажи|Verkaufsstand|Stan Jual|販売スタンド|판매 스탠드|Quầy bán|出售摊|Banco vendita|Stoisko sprzedaży|จุดขาย|Sell Stand|Gerai jual
Plots|Araziler|Parcelas|الأراضي|Terrains|प्लॉट|Terrenos|Участки|Grundstücke|Lahan|区画|부지|Các plot|地块|Terreni|Działki|แปลง|Mga plot|Plot
Plot %d|Arazi %d|Parcela %d|الأرض %d|Terrain %d|प्लॉट %d|Terreno %d|Участок %d|Grundstück %d|Lahan %d|区画 %d|부지 %d|Plot %d|地块 %d|Terreno %d|Działka %d|แปลง %d|Plot %d|Plot %d
Character|Karakter|Personaje|الشخصية|Personnage|किरदार|Personagem|Персонаж|Charakter|Karakter|キャラクター|캐릭터|Nhân vật|角色|Personaggio|Postać|ตัวละคร|Character|Watak
WalkSpeed|Yürüme Hızı|Velocidad de caminar|سرعة المشي|Vitesse de marche|चलने की गति|Velocidade de caminhada|Скорость ходьбы|Gehgeschwindigkeit|Kecepatan Jalan|歩行速度|걷기 속도|Tốc độ đi|行走速度|Velocità camminata|Prędkość chodzenia|ความเร็วเดิน|WalkSpeed|Kelajuan jalan
JumpPower|Zıplama Gücü|Fuerza de salto|قوة القفز|Puissance de saut|कूद शक्ति|Força do pulo|Сила прыжка|Sprungkraft|Kekuatan Lompat|ジャンプ力|점프력|Lực nhảy|跳跃力|Potenza salto|Siła skoku|พลังกระโดด|JumpPower|Kuasa lompat
Infinite Jump|Sonsuz Zıplama|Salto infinito|قفز لا نهائي|Saut infini|अनंत कूद|Pulo infinito|Бесконечный прыжок|Unendlicher Sprung|Lompat Tanpa Batas|無限ジャンプ|무한 점프|Nhảy vô hạn|无限跳跃|Salto infinito|Nieskończony skok|กระโดดไม่จำกัด|Infinite Jump|Lompat tak terhingga
Reset Speed and Jump|Hızı ve Zıplamayı Sıfırla|Restablecer velocidad y salto|إعادة ضبط السرعة والقفز|Réinitialiser vitesse et saut|गति और कूद रीसेट करें|Redefinir velocidade e pulo|Сбросить скорость и прыжок|Tempo und Sprung zurücksetzen|Atur Ulang Kecepatan dan Lompat|速度とジャンプをリセット|속도와 점프 초기화|Reset tốc độ và nhảy|重置速度与跳跃|Reset velocità e salto|Reset prędkości i skoku|รีเซ็ตความเร็วและกระโดด|I-reset ang Speed at Jump|Set semula kelajuan dan lompat
Reset|Sıfırla|Restablecer|إعادة ضبط|Réinitialiser|रीसेट|Redefinir|Сброс|Zurücksetzen|Atur Ulang|リセット|초기화|Reset|重置|Reset|Reset|รีเซ็ต|I-reset|Set semula
Utility|Araçlar|Utilidades|أدوات|Utilitaires|उपयोगिताएँ|Utilidades|Утилиты|Hilfsmittel|Utilitas|ユーティリティ|유틸리티|Tiện ích|实用|Utilità|Narzędzia|ยูทิลิตี้|Utility|Utiliti
Rejoin Server|Sunucuya Yeniden Bağlan|Volver a unirse al servidor|إعادة الانضمام للخادم|Rejoindre le serveur|सर्वर में दोबारा जुड़ें|Reentrar no servidor|Перезайти на сервер|Server erneut beitreten|Gabung Ulang Server|サーバーに再参加|서버 재접속|Vào lại server|重新加入服务器|Rientra nel server|Dołącz ponownie|เข้าเซิร์ฟใหม่|Muling sumali sa Server|Sertai semula pelayan
Rejoin|Yeniden Bağlan|Reunirse|إعادة الانضمام|Rejoindre|दोबारा जुड़ें|Reentrar|Перезайти|Erneut beitreten|Gabung Ulang|再参加|재접속|Vào lại|重新加入|Rientra|Dołącz ponownie|เข้าใหม่|Muling sumali|Sertai semula
Rejoin the same server?|Aynı sunucuya yeniden bağlanılsın mı?|¿Volver a unirse al mismo servidor?|هل تريد إعادة الانضمام لنفس الخادم؟|Rejoindre le même serveur ?|क्या उसी सर्वर में दोबारा जुड़ें?|Reentrar no mesmo servidor?|Перезайти на тот же сервер?|Demselben Server erneut beitreten?|Gabung ulang ke server yang sama?|同じサーバーに再参加しますか？|같은 서버에 다시 접속할까요?|Vào lại cùng server?|重新加入同一服务器？|Rientrare nello stesso server?|Dołączyć do tego samego serwera?|เข้าเซิร์ฟเดิมใหม่?|Muling sumali sa parehong server?|Sertai semula pelayan sama?
Server Hop|Sunucu Değiştir|Cambiar de servidor|تبديل الخادم|Changer de serveur|सर्वर बदलें|Trocar de servidor|Смена сервера|Serverwechsel|Pindah Server|サーバー移動|서버 이동|Chuyển server|换服|Cambia server|Hop serwera|ย้ายเซิร์ฟ|Server Hop|Lompat pelayan
Hop|Geç|Cambiar|تبديل|Changer|बदलें|Trocar|Сменить|Wechseln|Pindah|移動|이동|Chuyển|换服|Cambia|Hop|ย้าย|Hop|Lompat
Hop to another server?|Başka bir sunucuya geçilsin mi?|¿Cambiar a otro servidor?|هل تريد الانتقال إلى خادم آخر؟|Changer de serveur ?|क्या दूसरे सर्वर पर जाएँ?|Trocar para outro servidor?|Перейти на другой сервер?|Zu einem anderen Server wechseln?|Pindah ke server lain?|別のサーバーに移動しますか？|다른 서버로 이동할까요?|Chuyển sang server khác?|换到其他服务器？|Passare a un altro server?|Przejść na inny serwer?|ย้ายไปเซิร์ฟอื่น?|Lumipat sa ibang server?|Lompat ke pelayan lain?
Live|Canlı|En vivo|مباشر|En direct|लाइव|Ao vivo|Онлайн|Live|Langsung|ライブ|실시간|Realtime|实时|Live|Na żywo|สด|Live|Langsung
Power|Güç|Fuerza|القوة|Puissance|शक्ति|Força|Сила|Kraft|Kekuatan|パワー|힘|Sức mạnh|力量|Potenza|Moc|พลัง|Power|Kuasa
Appearance|Görünüm|Apariencia|المظهر|Apparence|दिखावट|Aparência|Внешний вид|Darstellung|Tampilan|外観|외관|Giao diện|外观|Aspetto|Wygląd|รูปลักษณ์|Hitsura|Penampilan
Language|Dil|Idioma|اللغة|Langue|भाषा|Idioma|Язык|Sprache|Bahasa|言語|언어|Ngôn ngữ|语言|Lingua|Język|ภาษา|Wika|Bahasa
Theme|Tema|Tema|السمة|Thème|थीम|Tema|Тема|Design|Tema|テーマ|테마|Chủ đề|主题|Tema|Motyw|ธีม|Theme|Tema
Configs|Configler|Configuraciones|الإعدادات المحفوظة|Configs|कॉन्फ़िग|Configurações|Конфиги|Configs|Konfigurasi|設定ファイル|설정 파일|Config|配置|Config|Konfigi|คอนฟิก|Configs|Konfigurasi
Config Name|Config Adı|Nombre de la configuración|اسم الإعداد|Nom de la config|कॉन्फ़िग नाम|Nome da configuração|Имя конфига|Config-Name|Nama Konfigurasi|設定名|설정 이름|Tên config|配置名称|Nome config|Nazwa konfiguracji|ชื่อคอนฟิก|Pangalan ng Config|Nama konfigurasi
No saved configs|Kayıtlı config yok|No hay configuraciones guardadas|لا توجد إعدادات محفوظة|Aucune config enregistrée|कोई सहेजा कॉन्फ़िग नहीं|Nenhuma configuração salva|Нет сохранённых конфигов|Keine gespeicherten Configs|Tidak ada konfigurasi tersimpan|保存済みの設定がありません|저장된 설정 없음|Chưa có config lưu|无已保存配置|Nessuna config salvata|Brak zapisanych konfiguracji|ไม่มีคอนฟิกที่เซฟ|Walang naka-save na configs|Tiada konfigurasi disimpan
Existing Configs|Mevcut Configler|Configuraciones existentes|الإعدادات الموجودة|Configs existantes|मौजूदा कॉन्फ़िग|Configurações existentes|Существующие конфиги|Vorhandene Configs|Konfigurasi yang Ada|既存の設定|기존 설정|Config hiện có|现有配置|Config esistenti|Istniejące konfiguracje|คอนฟิกที่มี|Mga existing configs|Konfigurasi sedia ada
Choose|Seç|Elegir|اختر|Choisir|चुनें|Escolher|Выбрать|Wählen|Pilih|選択|선택|Chọn|选择|Scegli|Wybierz|เลือก|Pumili|Pilih
Save Config|Configi Kaydet|Guardar configuración|حفظ الإعدادات|Enregistrer la config|कॉन्फ़िग सहेजें|Salvar configuração|Сохранить конфиг|Config speichern|Simpan Konfigurasi|設定を保存|설정 저장|Lưu config|保存配置|Salva config|Zapisz konfigurację|บันทึกคอนฟิก|I-save ang Config|Simpan konfigurasi
Save|Kaydet|Guardar|حفظ|Enregistrer|सहेजें|Salvar|Сохранить|Speichern|Simpan|保存|저장|Lưu|保存|Salva|Zapisz|บันทึก|I-save|Simpan
Config saved|Config kaydedildi|Configuración guardada|تم حفظ الإعدادات|Config enregistrée|कॉन्फ़िग सहेजा गया|Configuração salva|Конфиг сохранён|Config gespeichert|Konfigurasi disimpan|設定を保存しました|설정 저장됨|Đã lưu config|配置已保存|Config salvata|Konfiguracja zapisana|บันทึกคอนฟิกแล้ว|Na-save ang config|Konfigurasi disimpan
Load Config|Configi Yükle|Cargar configuración|تحميل الإعدادات|Charger la config|कॉन्फ़िग लोड करें|Carregar configuração|Загрузить конфиг|Config laden|Muat Konfigurasi|設定を読み込む|설정 불러오기|Tải config|加载配置|Carica config|Wczytaj konfigurację|โหลดคอนฟิก|I-load ang Config|Muat konfigurasi
Load|Yükle|Cargar|تحميل|Charger|लोड करें|Carregar|Загрузить|Laden|Muat|読み込み|불러오기|Tải|加载|Carica|Wczytaj|โหลด|I-load|Muat
Config loaded|Config yüklendi|Configuración cargada|تم تحميل الإعدادات|Config chargée|कॉन्फ़िग लोड हुआ|Configuração carregada|Конфиг загружен|Config geladen|Konfigurasi dimuat|設定を読み込みました|설정 불러옴|Đã tải config|配置已加载|Config caricata|Konfiguracja wczytana|โหลดคอนฟิกแล้ว|Na-load ang config|Konfigurasi dimuatkan
Delete Config|Configi Sil|Eliminar configuración|حذف الإعدادات|Supprimer la config|कॉन्फ़िग हटाएँ|Excluir configuração|Удалить конфиг|Config löschen|Hapus Konfigurasi|設定を削除|설정 삭제|Xóa config|删除配置|Elimina config|Usuń konfigurację|ลบคอนฟิก|I-delete ang Config|Padam konfigurasi
Delete|Sil|Eliminar|حذف|Supprimer|हटाएँ|Excluir|Удалить|Löschen|Hapus|削除|삭제|Xóa|删除|Elimina|Usuń|ลบ|I-delete|Padam
Config name is empty|Config adı boş|El nombre de la configuración está vacío|اسم الإعداد فارغ|Le nom de la config est vide|कॉन्फ़िग नाम खाली है|O nome da configuração está vazio|Имя конфига пусто|Config-Name ist leer|Nama konfigurasi kosong|設定名が空です|설정 이름이 비어 있음|Tên config trống|配置名称为空|Nome config vuoto|Nazwa konfiguracji pusta|ชื่อคอนฟิกว่าง|Walang pangalan ang config|Nama konfigurasi kosong
Delete config '%s'?|'%s' configi silinsin mi?|¿Eliminar la configuración '%s'?|هل تريد حذف الإعداد '%s'؟|Supprimer la config '%s' ?|कॉन्फ़िग '%s' हटाएँ?|Excluir a configuração '%s'?|Удалить конфиг '%s'?|Config '%s' löschen?|Hapus konfigurasi '%s'?|設定 '%s' を削除しますか？|설정 '%s'을(를) 삭제할까요?|Xóa config '%s'?|删除配置“%s”？|Eliminare config '%s'?|Usunąć konfigurację '%s'?|ลบคอนฟิก '%s'?|I-delete ang config '%s'?|Padam konfigurasi '%s'?
Config deleted|Config silindi|Configuración eliminada|تم حذف الإعدادات|Config supprimée|कॉन्फ़िग हटाया गया|Configuração excluída|Конфиг удалён|Config gelöscht|Konfigurasi dihapus|設定を削除しました|설정 삭제됨|Đã xóa config|配置已删除|Config eliminata|Konfiguracja usunięta|ลบคอนฟิกแล้ว|Na-delete ang config|Konfigurasi dipadam
Could not delete|Silinemedi|No se pudo eliminar|تعذر الحذف|Suppression impossible|हटाया नहीं जा सका|Não foi possível excluir|Не удалось удалить|Löschen nicht möglich|Gagal menghapus|削除できませんでした|삭제할 수 없음|Không xóa được|无法删除|Impossibile eliminare|Nie udało się usunąć|ลบไม่ได้|Hindi ma-delete|Gagal padam
File missing or the executor does not support it|Dosya yok ya da executor desteklemiyor|Falta el archivo o el ejecutor no lo admite|الملف مفقود أو المنفّذ لا يدعمه|Fichier absent ou non pris en charge par l'exécuteur|फ़ाइल गायब है या एक्ज़ीक्यूटर समर्थन नहीं करता|Arquivo ausente ou o executor não suporta|Файл отсутствует или не поддерживается исполнителем|Datei fehlt oder der Executor unterstützt es nicht|File hilang atau executor tidak mendukung|ファイルがないか、エグゼキューターが非対応です|파일이 없거나 실행기가 지원하지 않음|Thiếu file hoặc executor không hỗ trợ|文件缺失或执行器不支持|File mancante o non supportato dall'executor|Brak pliku lub executor nie obsługuje|ไฟล์หายหรือเอ็กซีคิวเตอร์ไม่รองรับ|Missing ang file o hindi support ng executor|Fail tiada atau executor tidak menyokong
Behaviour|Davranış|Comportamiento|السلوك|Comportement|व्यवहार|Comportamento|Поведение|Verhalten|Perilaku|動作|동작|Hành vi|行为|Comportamento|Zachowanie|พฤติกรรม|Ugali|Tingkah laku
Auto Load Config|Configi Otomatik Yükle|Cargar configuración automáticamente|تحميل الإعدادات تلقائيًا|Charger la config automatiquement|कॉन्फ़िग ऑटो लोड करें|Carregar configuração automaticamente|Автозагрузка конфига|Config automatisch laden|Muat Konfigurasi Otomatis|設定を自動読み込み|설정 자동 불러오기|Tự tải config|自动加载配置|Auto carica config|Auto wczytaj konfigurację|โหลดคอนฟิกอัตโนมัติ|Auto Load Config|Auto muat konfigurasi
Auto Load on|Otomatik Yükleme açık|Carga automática activada|التحميل التلقائي مفعل|Chargement auto activé|ऑटो लोड चालू|Carregamento automático ativado|Автозагрузка включена|Auto-Laden an|Muat Otomatis aktif|自動読み込みオン|자동 불러오기 켜짐|Tự tải bật|自动加载已开启|Auto carica attivo|Auto wczytywanie włączone|โหลดอัตโนมัติเปิด|Naka-on ang Auto Load|Auto muat dihidupkan
Auto Save|Otomatik Kayıt|Guardado automático|حفظ تلقائي|Sauvegarde auto|ऑटो सेव|Salvamento automático|Автосохранение|Auto-Speichern|Simpan Otomatis|自動保存|자동 저장|Tự lưu|自动保存|Auto salvataggio|Auto zapis|บันทึกอัตโนมัติ|Auto Save|Auto simpan
Toggle Key|Aç/Kapat Tuşu|Tecla de alternar|مفتاح التبديل|Touche d'affichage|टॉगल कुंजी|Tecla de alternar|Клавиша меню|Umschalttaste|Tombol Buka/Tutup|切替キー|토글 키|Phím bật/tắt|开关键|Tasto toggle|Klawisz przełączania|ปุ่มสลับ|Toggle Key|Kekunci togol
Open or close the menu with the selected key. With Auto Save on, every change is written to the selected config.|Menüyü seçili tuşla aç/kapat. Otomatik Kayıt açıkken her değişiklik seçili config'e yazılır.|Abre o cierra el menú con la tecla elegida. Con el guardado automático, cada cambio se escribe en la configuración elegida.|افتح القائمة أو أغلقها بالمفتاح المحدد. مع الحفظ التلقائي تُكتب كل تغييرات في الإعداد المحدد.|Ouvre ou ferme le menu avec la touche choisie. Avec la sauvegarde auto, chaque changement est écrit dans la config choisie.|चुनी हुई कुंजी से मेनू खोलें या बंद करें। ऑटो सेव चालू होने पर हर बदलाव चुने हुए कॉन्फ़िग में लिखा जाता है।|Abra ou feche o menu com a tecla escolhida. Com o salvamento automático, cada mudança é gravada na configuração escolhida.|Открывайте и закрывайте меню выбранной клавишей. При автосохранении каждое изменение записывается в выбранный конфиг.|Öffne oder schließe das Menü mit der gewählten Taste. Bei Auto-Speichern wird jede Änderung in die gewählte Config geschrieben.|Buka atau tutup menu dengan tombol terpilih. Dengan Simpan Otomatis, setiap perubahan ditulis ke konfigurasi terpilih.|選択したキーでメニューを開閉します。自動保存がオンのとき、変更はすべて選択中の設定に書き込まれます。|선택한 키로 메뉴를 열고 닫습니다. 자동 저장이 켜져 있으면 모든 변경이 선택한 설정에 기록됩니다.|Mở/đóng menu bằng phím đã chọn. Khi Tự lưu bật, mọi thay đổi ghi vào config đang chọn.|用所选键打开或关闭菜单。开启自动保存时，每次更改写入所选配置。|Apri/chiudi menu con il tasto scelto. Con Auto salvataggio, ogni modifica va nella config scelta.|Otwórz/zamknij menu wybranym klawiszem. Przy Auto zapisie każda zmiana idzie do wybranej konfiguracji.|เปิด/ปิดเมนูด้วยปุ่มที่เลือก เมื่อบันทึกอัตโนมัติเปิด ทุกการเปลี่ยนจะเขียนลงคอนฟิกที่เลือก|Buksan o isara ang menu gamit ang napiling key. Kapag naka-on ang Auto Save, bawat change ay naisusulat sa napiling config.|Buka/tutup menu dengan kekunci dipilih. Bila Auto simpan hidup, setiap perubahan ditulis ke konfigurasi dipilih.
Auto Farm on|Oto Farm açık|Auto Farm activado|المزرعة التلقائية مفعلة|Auto Farm activé|ऑटो फ़ार्म चालू|Auto Farm ativado|Авто-фарм включён|Auto-Farm an|Auto Farm aktif|オートファームオン|자동 파밍 켜짐|Auto Farm bật|自动挂机已开启|Auto Farm attivo|Auto Farm włączony|ออโต้ฟาร์มเปิด|Naka-on ang Auto Farm|Auto Farm dihidupkan
Auto Farm off|Oto Farm kapalı|Auto Farm desactivado|المزرعة التلقائية متوقفة|Auto Farm désactivé|ऑटो फ़ार्म बंद|Auto Farm desativado|Авто-фарм выключен|Auto-Farm aus|Auto Farm nonaktif|オートファームオフ|자동 파밍 꺼짐|Auto Farm tắt|自动挂机已关闭|Auto Farm disattivo|Auto Farm wyłączony|ออโต้ฟาร์มปิด|Naka-off ang Auto Farm|Auto Farm dimatikan
Running the selected modules|Seçili modüller çalıştırılıyor|Ejecutando los módulos seleccionados|تشغيل الوحدات المحددة|Exécution des modules sélectionnés|चयनित मॉड्यूल चल रहे हैं|Executando os módulos selecionados|Запуск выбранных модулей|Gewählte Module laufen|Menjalankan modul terpilih|選択したモジュールを実行中|선택한 모듈 실행 중|Đang chạy module đã chọn|正在运行所选模块|Esecuzione moduli selezionati|Uruchamianie wybranych modułów|กำลังรันโมดูลที่เลือก|Tumatakbo ang napiling modules|Menjalankan modul dipilih
Features it started were turned off|Başlattığı özellikler kapatıldı|Se desactivaron las funciones que inició|تم إيقاف الميزات التي بدأها|Les fonctions qu'il a lancées ont été désactivées|इसके शुरू किए फ़ीचर बंद कर दिए गए|Os recursos que ele iniciou foram desligados|Запущенные им функции отключены|Von ihm gestartete Funktionen wurden ausgeschaltet|Fitur yang dimulainya dimatikan|開始した機能をオフにしました|시작한 기능을 껐습니다|Các tính năng do nó bật đã được tắt|它启动的功能已关闭|Le funzioni avviate sono state disattivate|Funkcje, które włączył, zostały wyłączone|ฟีเจอร์ที่มันเปิดถูกปิดแล้ว|Ang features na sinimulan nito ay na-off|Ciri yang dimulakannya dimatikan
Throw / Train Mode|Atış / Antrenman Modu|Modo lanzar / entrenar|وضع الرمي / التدريب|Mode lancer / entraîner|थ्रो / प्रशिक्षण मोड|Modo arremessar / treinar|Режим броски / тренировка|Wurf-/Trainingsmodus|Mode Lempar / Latihan|投擲/トレーニングモード|던지기/훈련 모드|Chế độ Ném / Luyện|投掷/训练模式|Modalità lancio / allenamento|Tryb rzut / trening|โหมดขว้าง / ฝึก|Throw / Train Mode|Mod lempar / latihan
Cycle: Throws Before Training|Döngü: Antrenmandan Önce Atışlar|Ciclo: lanzamientos antes de entrenar|الدورة: رميات قبل التدريب|Cycle : lancers avant l'entraînement|चक्र: प्रशिक्षण से पहले थ्रो|Ciclo: arremessos antes do treino|Цикл: броски перед тренировкой|Zyklus: Würfe vor dem Training|Siklus: Lemparan Sebelum Latihan|サイクル: トレーニング前の投擲数|사이클: 훈련 전 던지기 횟수|Chu kỳ: Số ném trước khi luyện|循环：训练前投掷次数|Ciclo: lanci prima dell'allenamento|Cykl: rzuty przed treningiem|วน: จำนวนขว้างก่อนฝึก|Cycle: Throws bago ang Training|Kitaran: Lemparan sebelum latihan
Cycle: Training Duration|Döngü: Antrenman Süresi|Ciclo: duración del entrenamiento|الدورة: مدة التدريب|Cycle : durée d'entraînement|चक्र: प्रशिक्षण अवधि|Ciclo: duração do treino|Цикл: длительность тренировки|Zyklus: Trainingsdauer|Siklus: Durasi Latihan|サイクル: トレーニング時間|사이클: 훈련 시간|Chu kỳ: Thời gian luyện|循环：训练时长|Ciclo: durata allenamento|Cykl: czas treningu|วน: ระยะเวลาฝึก|Cycle: Tagal ng Training|Kitaran: Tempoh latihan
Stop After Throws (0 = never)|Şu Kadar Atıştan Sonra Dur (0 = asla)|Detener tras X lanzamientos (0 = nunca)|التوقف بعد عدد رميات (0 = أبدًا)|Arrêter après X lancers (0 = jamais)|इतने थ्रो के बाद रुकें (0 = कभी नहीं)|Parar após X arremessos (0 = nunca)|Остановка после бросков (0 = никогда)|Nach Würfen stoppen (0 = nie)|Berhenti Setelah Lemparan (0 = tidak pernah)|投擲数で停止（0 = 無制限）|던지기 횟수 후 중지 (0 = 안 함)|Dừng sau số ném (0 = không)|投掷次数后停止（0=永不）|Ferma dopo X lanci (0 = mai)|Stop po X rzutach (0 = nigdy)|หยุดหลังขว้างกี่ครั้ง (0 = ไม่)|Tumigil pagkatapos ng X throws (0 = never)|Henti selepas X lemparan (0 = tidak pernah)
Stop After Minutes (0 = never)|Şu Kadar Dakikadan Sonra Dur (0 = asla)|Detener tras X minutos (0 = nunca)|التوقف بعد دقائق (0 = أبدًا)|Arrêter après X minutes (0 = jamais)|इतने मिनट बाद रुकें (0 = कभी नहीं)|Parar após X minutos (0 = nunca)|Остановка через минуты (0 = никогда)|Nach Minuten stoppen (0 = nie)|Berhenti Setelah Menit (0 = tidak pernah)|分数で停止（0 = 無制限）|분 후 중지 (0 = 안 함)|Dừng sau số phút (0 = không)|分钟后停止（0=永不）|Ferma dopo X minuti (0 = mai)|Stop po X minutach (0 = nigdy)|หยุดหลังกี่นาที (0 = ไม่)|Tumigil pagkatapos ng X minutes (0 = never)|Henti selepas X minit (0 = tidak pernah)
min|dk|min|د|min|मिनट|min|мин|Min.|mnt|分|분|phút|分钟|min|min|นาที|min|min
Modules|Modüller|Módulos|الوحدات|Modules|मॉड्यूल|Módulos|Модули|Module|Modul|モジュール|모듈|Module|模块|Moduli|Moduły|โมดูล|Modules|Modul
Throw|Atış|Lanzar|رمي|Lancer|थ्रो|Arremessar|Бросок|Werfen|Lempar|投擲|던지기|Ném|投掷|Lancio|Rzut|ขว้าง|Throw|Lempar
Place Animals|Hayvanları Yerleştir|Colocar animales|وضع الحيوانات|Placer les animaux|जानवर प्लेस करें|Posicionar animais|Размещать животных|Tiere platzieren|Tempatkan Hewan|動物を配置|동물 배치|Đặt thú|放置动物|Piazza animali|Umieść zwierzęta|วางสัตว์|Maglagay ng hayop|Letak haiwan
Buy and Equip Best Food|En İyi Yemeği Al ve Kuşan|Comprar y equipar la mejor comida|شراء وتجهيز أفضل طعام|Acheter et équiper le meilleur aliment|सर्वश्रेष्ठ खाना खरीदें और सुसज्जित करें|Comprar e equipar a melhor comida|Покупать и экипировать лучшую еду|Bestes Futter kaufen und ausrüsten|Beli dan Pakai Makanan Terbaik|最高のフードを購入して装備|최고의 먹이 구매 및 장착|Mua và trang bị thức ăn tốt nhất|购买并装备最佳食物|Compra e equipaggia miglior cibo|Kup i załóż najlepsze jedzenie|ซื้อและสวมอาหารดีสุด|Bumili at i-equip ang Best Food|Beli dan lengkapi makanan terbaik
Upgrade Bar and Fence|Barı ve Çiti Yükselt|Mejorar barra y valla|ترقية الشريط والسياج|Améliorer barre et clôture|बार और बाड़ अपग्रेड करें|Melhorar barra e cerca|Улучшать шкалу и забор|Balken und Zaun verbessern|Tingkatkan Bar dan Pagar|バーとフェンスを強化|바와 울타리 업그레이드|Nâng cấp thanh và hàng rào|升级进度条与围栏|Upgrade barra e recinzione|Ulepsz pasek i płot|อัปเกรดแถบและรั้ว|I-upgrade ang Bar at Fence|Naik taraf bar dan pagar
Sell Filtered Animals|Filtrelenmiş Hayvanları Sat|Vender animales filtrados|بيع الحيوانات المفلترة|Vendre les animaux filtrés|फ़िल्टर किए जानवर बेचें|Vender animais filtrados|Продавать отфильтрованных животных|Gefilterte Tiere verkaufen|Jual Hewan yang Difilter|フィルター対象の動物を売却|필터된 동물 판매|Bán thú đã lọc|出售已过滤动物|Vendi animali filtrati|Sprzedaj odfiltrowane zwierzęta|ขายสัตว์ที่กรอง|Ibenta ang naka-filter na hayop|Jual haiwan ditapis
Claim Rewards and Vote|Ödülleri Al ve Oy Ver|Reclamar recompensas y votar|المطالبة بالمكافآت والتصويت|Récupérer les récompenses et voter|पुरस्कार क्लेम करें और वोट दें|Resgatar recompensas e votar|Забирать награды и голосовать|Belohnungen abholen und abstimmen|Klaim Hadiah dan Vote|報酬を受け取り投票|보상 수령 및 투표|Nhận thưởng và vote|领取奖励并投票|Riscatta ricompense e vota|Odbierz nagrody i głosuj|รับรางวัลและโหวต|Kunin ang rewards at bumoto|Tuntut ganjaran dan undi
Fill Missing Index Animals|Eksik Dizin Hayvanlarını Tamamla|Completar animales faltantes del índice|إكمال حيوانات الفهرس الناقصة|Compléter les animaux manquants de l'index|गायब इंडेक्स जानवर पूरे करें|Completar animais faltantes do índice|Заполнять недостающих в индексе|Fehlende Index-Tiere auffüllen|Lengkapi Hewan Indeks yang Kurang|不足している図鑑の動物を埋める|도감의 빠진 동물 채우기|Điền thú sổ còn thiếu|补全图鉴缺失动物|Completa animali mancanti indice|Uzupełnij brakujące w indeksie|เติมสัตว์ดัชนีที่ขาด|Punan ang kulang sa index|Isikan haiwan indeks yang kurang
Throw settings|Atış ayarları|Ajustes de lanzamiento|إعدادات الرمي|Réglages de lancer|थ्रो सेटिंग्स|Configurações de arremesso|Настройки бросков|Wurfeinstellungen|Pengaturan lempar|投擲設定|던지기 설정|Cài đặt ném|投掷设置|Impostazioni lancio|Ustawienia rzutu|ตั้งค่าขว้าง|Throw settings|Tetapan lempar
Place settings|Yerleştirme ayarları|Ajustes de colocación|إعدادات الوضع|Réglages de placement|प्लेस सेटिंग्स|Configurações de posicionamento|Настройки размещения|Platzierungseinstellungen|Pengaturan penempatan|配置設定|배치 설정|Cài đặt đặt thú|放置设置|Impostazioni piazzamento|Ustawienia umieszczania|ตั้งค่าการวาง|Place settings|Tetapan letak
Sell settings|Satış ayarları|Ajustes de venta|إعدادات البيع|Réglages de vente|बिक्री सेटिंग्स|Configurações de venda|Настройки продажи|Verkaufseinstellungen|Pengaturan penjualan|売却設定|판매 설정|Cài đặt bán|出售设置|Impostazioni vendita|Ustawienia sprzedaży|ตั้งค่าการขาย|Sell settings|Tetapan jual
Session|Oturum|Sesión|الجلسة|Session|सत्र|Sessão|Сессия|Sitzung|Sesi|セッション|세션|Phiên|会话|Sessione|Sesja|เซสชัน|Session|Sesi
Session Time|Oturum Süresi|Tiempo de sesión|مدة الجلسة|Durée de session|सत्र समय|Tempo de sessão|Время сессии|Sitzungsdauer|Waktu Sesi|セッション時間|세션 시간|Thời gian phiên|会话时间|Tempo sessione|Czas sesji|เวลาเซสชัน|Oras ng session|Masa sesi
Throws (this farm)|Atışlar (bu farm)|Lanzamientos (este farm)|الرميات (هذا الفارم)|Lancers (ce farm)|थ्रो (यह फ़ार्म)|Arremessos (este farm)|Броски (этот фарм)|Würfe (dieser Farm)|Lemparan (farm ini)|投擲回数（このファーム）|던지기 (이번 파밍)|Ném (farm này)|投掷（本次挂机）|Lanci (questo farm)|Rzuty (ten farm)|ขว้าง (ฟาร์มนี้)|Throws (farm na ito)|Lemparan (farm ini)
Money per Hour|Saatlik Para|Dinero por hora|المال في الساعة|Argent par heure|प्रति घंटा पैसा|Dinheiro por hora|Деньги в час|Geld pro Stunde|Uang per Jam|時間あたりのお金|시간당 돈|Tiền mỗi giờ|每小时金钱|Denaro all'ora|Pieniądze na godzinę|เงินต่อชั่วโมง|Pera kada oras|Wang sejam
While Auto Farm is on, the selected modules turn on the matching settings from the other tabs; when it stops, it only turns off what it enabled itself. The same settings are visible on the other tabs and stay in sync.|Oto Farm açıkken seçili modüller diğer sekmelerdeki ilgili ayarları açar; durunca yalnızca kendi açtıklarını kapatır. Aynı ayarlar diğer sekmelerde de görünür ve senkron kalır.|Con Auto Farm activo, los módulos seleccionados activan los ajustes correspondientes de otras pestañas; al detenerse, solo apaga lo que activó. Los mismos ajustes se ven en otras pestañas y se mantienen sincronizados.|أثناء تشغيل المزرعة التلقائية تفعّل الوحدات المحددة الإعدادات المطابقة من علامات التبويب الأخرى؛ وعند التوقف تُطفئ فقط ما فعّلته. تظهر الإعدادات نفسها في علامات التبويب الأخرى وتبقى متزامنة.|Quand Auto Farm est actif, les modules choisis activent les réglages correspondants des autres onglets ; à l'arrêt, il ne coupe que ce qu'il a activé. Les mêmes réglages apparaissent dans les autres onglets et restent synchronisés.|ऑटो फ़ार्म चालू होने पर चयनित मॉड्यूल अन्य टैब की संबंधित सेटिंग्स चालू करते हैं; रुकने पर वह केवल अपनी चालू की हुई चीज़ें बंद करता है। वही सेटिंग्स अन्य टैब में भी दिखती हैं और सिंक में रहती हैं।|Com o Auto Farm ativo, os módulos selecionados ligam as configurações correspondentes das outras abas; ao parar, ele só desliga o que ele mesmo ativou. As mesmas configurações aparecem nas outras abas e ficam sincronizadas.|Пока Авто-фарм включён, выбранные модули включают соответствующие настройки на других вкладках; при остановке он выключает только то, что включил сам. Те же настройки видны на других вкладках и остаются синхронизированными.|Solange Auto-Farm läuft, schalten die gewählten Module die passenden Einstellungen der anderen Tabs ein; beim Stoppen schaltet es nur aus, was es selbst aktiviert hat. Dieselben Einstellungen sind auch in den anderen Tabs sichtbar und bleiben synchron.|Saat Auto Farm aktif, modul terpilih menyalakan pengaturan terkait dari tab lain; saat berhenti, hanya mematikan yang dinyalakannya sendiri. Pengaturan yang sama terlihat di tab lain dan tetap sinkron.|オートファームがオンの間、選択したモジュールが他のタブの対応する設定をオンにし、停止時は自分でオンにしたものだけをオフにします。同じ設定は他のタブにも表示され、同期されます。|자동 파밍이 켜져 있는 동안 선택한 모듈이 다른 탭의 해당 설정을 켜고, 멈추면 자신이 켠 것만 끕니다. 같은 설정은 다른 탭에도 표시되며 동기화됩니다.|Khi Auto Farm bật, module đã chọn bật cài đặt tương ứng ở tab khác; khi dừng chỉ tắt những gì chính nó đã bật. Cùng cài đặt hiện ở tab khác và đồng bộ.|自动挂机开启时，所选模块会打开其他页对应设置；停止时只关闭自己启用的项。相同设置在其他页可见并保持同步。|Con Auto Farm attivo i moduli selezionati accendono le impostazioni corrispondenti delle altre schede; all'arresto spegne solo ciò che ha attivato. Le stesse impostazioni restano visibili e sincronizzate.|Gdy Auto Farm jest włączony, wybrane moduły włączają ustawienia z innych kart; przy zatrzymaniu wyłącza tylko to, co sam włączył. Te same ustawienia widać na innych kartach i są zsynchronizowane.|เมื่อออโต้ฟาร์มเปิด โมดูลที่เลือกจะเปิดการตั้งค่าที่ตรงกันในแท็บอื่น เมื่อหยุดจะปิดเฉพาะที่มันเปิดเอง การตั้งค่าเดียวกันเห็นในแท็บอื่นและซิงก์กัน|Habang naka-on ang Auto Farm, ang napiling modules ay nag-o-on ng matching settings sa ibang tabs; kapag tumigil, ini-off lang ang sinimulan nito. Parehong settings sa ibang tabs at naka-sync.|Bila Auto Farm hidup, modul dipilih menghidupkan tetapan sepadan tab lain; bila berhenti, hanya matikan yang dihidupkannya. Tetapan sama kelihatan di tab lain dan kekal segerak.
Menu: press %s to open/close|Menü: açmak/kapatmak için %s tuşuna bas|Menú: pulsa %s para abrir/cerrar|القائمة: اضغط %s للفتح/الإغلاق|Menu : appuie sur %s pour ouvrir/fermer|मेनू: खोलने/बंद करने के लिए %s दबाएँ|Menu: pressione %s para abrir/fechar|Меню: нажмите %s, чтобы открыть/закрыть|Menü: %s drücken zum Öffnen/Schließen|Menu: tekan %s untuk buka/tutup|メニュー: %s キーで開閉|메뉴: %s 키로 열기/닫기|Menu: nhấn %s để mở/đóng|菜单：按 %s 打开/关闭|Menu: premi %s per aprire/chiudere|Menu: naciśnij %s by otworzyć/zamknąć|เมนู: กด %s เพื่อเปิด/ปิด|Menu: pindutin ang %s para buksan/isara|Menu: tekan %s untuk buka/tutup
%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %%%d  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d %%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)|%.1fs  →  %d%%  (+%d stud)
Noclip|Noclip|Noclip|اختراق الجدران|Noclip|नोक्लिप|Noclip|Ноклип|Noclip|Noclip|ノークリップ|노클립|Noclip|穿墙|Noclip|Noclip|Noclip|Noclip|Noclip
Anti AFK|Anti AFK|Anti AFK|مكافحة الخمول|Anti-AFK|एंटी AFK|Anti AFK|Анти-АФК|Anti-AFK|Anti AFK|アンチAFK|안티 AFK|Chống AFK|防挂机|Anti AFK|Anti AFK|กัน AFK|Anti AFK|Anti AFK
Auto ThanksGiving Event|Oto Şükran Günü Etkinliği|Auto Evento Acción de Gracias|حدث الشكر التلقائي|Auto Événement Thanksgiving|ऑटो थैंक्सगिविंग इवेंट|Auto Evento de Ação de Graças|Авто День Благодарения|Auto Thanksgiving-Event|Auto Event Thanksgiving|自動サンクスギビング|자동 추수감사절 이벤트|Auto Sự kiện Lễ Tạ Ơn|自动感恩节活动|Auto Evento Thanksgiving|Auto wydarzenie Thanksgiving|ออโต้กิจกรรมขอบคุณพระเจ้า|Auto Thanksgiving Event|Auto Acara Thanksgiving
Feast throws, cook sandwiches, maple leaf FX|Şölen atışları, sandviç pişir, akçaağaç efekti|Lanzamientos del festín, cocinar sándwiches, FX de hojas|رميات العيد وطهي الساندويتش وتأثير أوراق القيقب|Lancers du festin, cuisiner des sandwichs, FX feuilles|फीस्ट थ्रो, सैंडविच पकाएँ, मेपल लीफ FX|Arremessos do festim, cozinhar sanduíches, FX de folhas|Броски пира, готовка сэндвичей, эффект кленовых листьев|Festmahl-Würfe, Sandwiches kochen, Ahornblatt-FX|Lemparan pesta, masak sandwich, FX daun maple|フィースト投擲・サンドイッチ調理・カエデFX|축제 던지기, 샌드위치 요리, 단풍 FX|Ném tiệc, nấu sandwich, hiệu ứng lá phong|盛宴投掷、烹饪三明治、枫叶特效|Lanci del banchetto, cucina panini, FX foglie d'acero|Rzuty uczty, gotowanie kanapek, FX liści klonu|ขว้างงานเลี้ยง ทำแซนด์วิช เอฟเฟกต์ใบเมเปิล|Feast throws, magluto ng sandwich, maple leaf FX|Lemparan pesta, masak sandwich, FX daun maple
Event every ~30 min · lasts 5 min. Collect Sweet Potato, Cranberry Sauce, Cornbread while throwing. Cook at the Feast hub (left of safe zone).|~30 dk'da bir, 5 dk sürer. Atarken Tatlı Patates, Kızılcık Sosu, Mısır Ekmeği topla. Güvenli alanın solundaki Şölen merkezinde pişir.|Cada ~30 min, dura 5 min. Recoge Batata, Salsa de arándano y Pan de maíz al lanzar. Cocina en el hub del Festín (izquierda de la zona segura).|كل ~30 دقيقة لمدة 5 دقائق. اجمع البطاطا الحلوة وصلصة التوت وخبز الذرة أثناء الرمي. اطبخ في مركز العيد يسار المنطقة الآمنة.|Toutes les ~30 min, dure 5 min. Collecte Patate douce, Sauce aux canneberges, Pain de maïs en lançant. Cuisine au hub du Festin (gauche de la zone sûre).|~30 मिनट पर, 5 मिनट। फेंकते समय स्वीट पोटैटो, क्रैनबेरी सॉस, कॉर्नब्रेड इकट्ठा करें। सेफ ज़ोन के बाएँ Feast हब पर पकाएँ।|A cada ~30 min, dura 5 min. Colete Batata-doce, Molho de cranberry e Pão de milho ao arremessar. Cozinhe no hub do Festim (esquerda da zona segura).|Каждые ~30 мин, 5 мин. Собирайте батат, клюквенный соус и кукурузный хлеб при бросках. Готовьте в центре Пира слева от безопасной зоны.|Alle ~30 Min., 5 Min. lang. Sammle Süßkartoffel, Preiselbeersauce, Maisbrot beim Werfen. Koche am Fest-Hub (links der Safe Zone).|Setiap ~30 mnt, 5 mnt. Kumpulkan Ubi manis, Saus cranberry, Roti jagung saat melempar. Masak di hub Pesta (kiri zona aman).|約30分ごと・5分間。投げながらスイートポテト・クランベリーソース・コーンブレッドを集める。安全地帯左のフィーストハブで調理。|약 30분마다 5분. 던지며 고구마, 크랜베리 소스, 콘브레드 수집. 안전 구역 왼쪽 축제 허브에서 요리.|Mỗi ~30 phút, kéo dài 5 phút. Ném để lấy Khoai ngọt, Sốt nam việt quất, Bánh bắp. Nấu tại hub Tiệc (trái safe zone).|约每30分钟一次，持续5分钟。投掷时收集红薯、蔓越莓酱、玉米面包。在安全区左侧盛宴中心烹饪。|Ogni ~30 min, dura 5 min. Raccogli Patata dolce, Salsa di mirtilli, Pane di mais lanciando. Cucina all'hub del Banchetto (sinistra zona sicura).|Co ~30 min, trwa 5 min. Zbieraj Bataty, Sos żurawinowy, Chleb kukurydziany rzucając. Gotuj w hubie Uczty (lewo safe zone).|ทุก ~30 นาที นาน 5 นาที เก็บมันหวาน ซอสแครนเบอร์รี ขนมปังข้าวโพดตอนขว้าง ทำอาหารที่ฮับงานเลี้ยง (ซ้ายเซฟโซน)|Bawat ~30 min, 5 min. Mangolekta ng Sweet Potato, Cranberry Sauce, Cornbread habang naghahagis. Magluto sa Feast hub (kaliwa ng safe zone).|Setiap ~30 min, 5 min. Kumpul Ubi keledek, Sos kranberi, Roti jagung semasa lempar. Masak di hab Pesta (kiri zon selamat).
Auto Throw Event|Oto Etkinlik Atışı|Auto Lanzamiento de Evento|رمي الحدث التلقائي|Auto Lancer d'événement|ऑटो इवेंट थ्रो|Auto Arremesso de Evento|Авто бросок события|Auto Event-Wurf|Auto Lempar Event|自動イベント投擲|자동 이벤트 던지기|Tự động ném sự kiện|自动活动投掷|Auto Lancio Evento|Auto rzut wydarzenia|ออโต้ขว้างอีเวนต์|Auto Throw Event|Auto Lempar Acara
Will pause train/throw and farm ingredients when Feast starts|Şölen başlayınca antrenman/atışı durdurup malzeme farmlar|Al empezar el Festín pausa train/throw y farmea ingredientes|عند بدء العيد يوقف التدريب/الرمي ويزرع المكونات|Au début du Festin, pause train/throw et farm d'ingrédients|फीस्ट शुरू होने पर ट्रेन/थ्रो रोककर सामग्री फार्म करेगा|Ao iniciar o Festim, pausa treino/arremesso e farma ingredientes|При старте Пира остановит тренировку/броски и фармит ингредиенты|Beim Fest-Start: Training/Wurf pausieren und Zutaten farmen|Saat Pesta mulai, jeda train/throw dan farm bahan|フィースト開始時に訓練/投擲を止め材料を集める|축제 시작 시 훈련/던지기를 멈추고 재료 파밍|Khi Tiệc bắt đầu sẽ dừng luyện/ném và farm nguyên liệu|盛宴开始时暂停训练/投掷并刷材料|All'inizio del Banchetto mette in pausa train/throw e farma ingredienti|Na start Uczty pauzuje trening/rzut i farmi składniki|เมื่องานเลี้ยงเริ่ม จะหยุดฝึก/ขว้างและฟาร์มวัตถุดิบ|Kapag nagsimula ang Feast, i-pause ang train/throw at magfa-farm ng ingredients|Bila Pesta mula, jeda train/throw dan farm bahan
Event Status|Etkinlik Durumu|Estado del evento|حالة الحدث|État de l'événement|इवेंट स्थिति|Status do evento|Статус события|Event-Status|Status Event|イベント状態|이벤트 상태|Trạng thái sự kiện|活动状态|Stato evento|Status wydarzenia|สถานะอีเวนต์|Status ng Event|Status Acara
ACTIVE  ·  |AKTİF  ·  |ACTIVO  ·  |نشط  ·  |ACTIF  ·  |सक्रिय  ·  |ATIVO  ·  |АКТИВНО  ·  |AKTIV  ·  |AKTIF  ·  |進行中  ·  |진행 중  ·  |ĐANG DIỄN RA  ·  |进行中  ·  |ATTIVO  ·  |AKTYWNE  ·  |กำลังดำเนิน  ·  |AKTIBO  ·  |AKTIF  ·  
s left|sn kaldı|s restantes|ث متبقية|s restantes|से बचे|s restantes|с осталось|s übrig|d tersisa|秒残り|초 남음|s còn lại|秒剩余|s rimasti|s pozostało|วิที่เหลือ|s natitira|s tinggal
Theme live|Tema canlı|Tema en vivo|السمة مباشرة|Thème en direct|थीम लाइव|Tema ao vivo|Тема активна|Theme live|Tema aktif|テーマ発動中|테마 진행|Theme đang chạy|主题进行中|Tema attivo|Motyw aktywny|ธีมสด|Theme live|Tema langsung
Waiting|Bekleniyor|Esperando|انتظار|En attente|प्रतीक्षा|Aguardando|Ожидание|Warten|Menunggu|待機中|대기 중|Đang chờ|等待中|In attesa|Oczekiwanie|กำลังรอ|Naghihintay|Menunggu
Auto Cook|Oto Pişir|Auto Cocinar|طهي تلقائي|Auto Cuisson|ऑटो कुक|Auto Cozinhar|Авто готовка|Auto Kochen|Auto Masak|自動調理|자동 요리|Tự nấu|自动烹饪|Auto Cucina|Auto gotowanie|ออโต้ทำอาหาร|Auto Cook|Auto Masak
Sandwich Size|Sandviç Boyutu|Tamaño del sándwich|حجم الساندويتش|Taille du sandwich|सैंडविच आकार|Tamanho do sanduíche|Размер сэндвича|Sandwich-Größe|Ukuran Sandwich|サンドイッチサイズ|샌드위치 크기|Cỡ sandwich|三明治尺寸|Dimensione panino|Rozmiar kanapki|ขนาดแซนด์วิช|Laki ng Sandwich|Saiz sandwich
Regular  (3 ingredients)|Normal  (3 malzeme)|Normal  (3 ingredientes)|عادي  (3 مكونات)|Normal  (3 ingrédients)|रेगुलर  (3 सामग्री)|Normal  (3 ingredientes)|Обычный  (3 ингредиента)|Normal  (3 Zutaten)|Regular  (3 bahan)|レギュラー  (材料3)|레귤러  (재료 3)|Thường  (3 nguyên liệu)|普通  (3材料)|Normale  (3 ingredienti)|Zwykła  (3 składniki)|ธรรมดา  (3 วัตถุดิบ)|Regular  (3 ingredients)|Biasa  (3 bahan)
Big  (6 ingredients)|Büyük  (6 malzeme)|Grande  (6 ingredientes)|كبير  (6 مكونات)|Grand  (6 ingrédients)|बिग  (6 सामग्री)|Grande  (6 ingredientes)|Большой  (6 ингредиентов)|Groß  (6 Zutaten)|Big  (6 bahan)|ビッグ  (材料6)|빅  (재료 6)|Lớn  (6 nguyên liệu)|大  (6材料)|Grande  (6 ingredienti)|Duża  (6 składników)|ใหญ่  (6 วัตถุดิบ)|Big  (6 ingredients)|Besar  (6 bahan)
Mega  (9 ingredients)|Mega  (9 malzeme)|Mega  (9 ingredientes)|ميجا  (9 مكونات)|Méga  (9 ingrédients)|मेगा  (9 सामग्री)|Mega  (9 ingredientes)|Мега  (9 ингредиентов)|Mega  (9 Zutaten)|Mega  (9 bahan)|メガ  (材料9)|메가  (재료 9)|Siêu  (9 nguyên liệu)|巨型  (9材料)|Mega  (9 ingredienti)|Mega  (9 składników)|เมกะ  (9 วัตถุดิบ)|Mega  (9 ingredients)|Mega  (9 bahan)
Auto Cook while Event|Etkinlikte Oto Pişir|Auto cocinar durante el evento|طهي تلقائي أثناء الحدث|Auto cuisson pendant l'événement|इवेंट के दौरान ऑटो कुक|Auto cozinhar durante o evento|Авто готовка во время события|Auto kochen während Event|Auto masak saat Event|イベント中に自動調理|이벤트 중 자동 요리|Tự nấu khi sự kiện|活动期间自动烹饪|Auto cucina durante evento|Auto gotuj podczas wydarzenia|ออโต้ทำอาหารระหว่างอีเวนต์|Auto Cook habang Event|Auto masak semasa Acara
Cook Now|Şimdi Pişir|Cocinar ahora|اطبخ الآن|Cuisiner maintenant|अभी पकाएँ|Cozinhar agora|Приготовить сейчас|Jetzt kochen|Masak Sekarang|今すぐ調理|지금 요리|Nấu ngay|立即烹饪|Cucina ora|Gotuj teraz|ทำอาหารตอนนี้|Magluto Ngayon|Masak sekarang
Cook|Pişir|Cocinar|طهي|Cuisiner|पकाएँ|Cozinhar|Готовить|Kochen|Masak|調理|요리|Nấu|烹饪|Cucina|Gotuj|ทำอาหาร|Magluto|Masak
Cooked|Pişirildi|Cocinado|تم الطهي|Cuit|पकाया गया|Cozinhado|Приготовлено|Gekocht|Dimasak|調理完了|요리됨|Đã nấu|已烹饪|Cotto|Ugotowano|ทำแล้ว|Naluto|Dimasak
Cook failed|Pişirme başarısız|Cocción fallida|فشل الطهي|Cuisson échouée|पकाना विफल|Falha ao cozinhar|Готовка не удалась|Kochen fehlgeschlagen|Gagal masak|調理失敗|요리 실패|Nấu thất bại|烹饪失败|Cottura fallita|Gotowanie nieudane|ทำอาหารล้มเหลว|Nabigo ang pagluto|Gagal masak
Remote not found — open Feast menu once|Remote bulunamadı — Şölen menüsünü bir kez aç|Remote no encontrado — abre el menú del Festín una vez|لم يُعثر على الريموت — افتح قائمة العيد مرة|Remote introuvable — ouvre le menu du Festin une fois|रिमोट नहीं मिला — Feast मेनू एक बार खोलें|Remote não encontrado — abra o menu do Festim uma vez|Remote не найден — откройте меню Пира один раз|Remote nicht gefunden — öffne Fest-Menü einmal|Remote tidak ditemukan — buka menu Pesta sekali|Remote未検出 — フィーストメニューを一度開く|리모트 없음 — 축제 메뉴를 한 번 여세요|Không thấy remote — mở menu Tiệc một lần|未找到远程 — 请先打开一次盛宴菜单|Remote non trovato — apri il menu Banchetto una volta|Nie znaleziono remote — otwórz menu Uczty raz|ไม่พบรีโมต — เปิดเมนูงานเลี้ยงสักครั้ง|Hindi nahanap ang remote — buksan ang Feast menu isang beses|Remote tidak dijumpai — buka menu Pesta sekali
Regular attracts base size · Big attracts big · Mega attracts large Thanksgiving animals. Forest / Savanna / Desert do not spawn event animals.|Normal temel boyut, Büyük büyük, Mega büyük Şükran hayvanlarını çeker. Orman/Savana/Çöl event hayvanı doğurmaz.|Normal atrae tamaño base · Grande atrae grandes · Mega atrae grandes de Acción de Gracias. Bosque/Sabana/Desierto no generan animales de evento.|العادي يجذب الحجم الأساسي · الكبير يجذب الكبير · الميجا يجذب حيوانات الشكر الكبيرة. الغابة/السافانا/الصحراء لا تظهر حيوانات الحدث.|Normal attire taille de base · Grand attire grands · Méga attire grands animaux Thanksgiving. Forêt/Savane/Désert ne spawn pas d'animaux d'événement.|रेगुलर बेस साइज़ · बिग बड़े · मेगा बड़े थैंक्सगिविंग जानवर खींचता है। जंगल/सवाना/रेगिस्तान में इवेंट जानवर नहीं।|Normal atrai tamanho base · Grande atrai grandes · Mega atrai animais grandes de Ação de Graças. Floresta/Savana/Deserto não geram animais de evento.|Обычный — базовый размер · Большой — крупных · Мега — крупных животных Дня благодарения. Лес/Саванна/Пустыня не спавнят ивент-животных.|Normal zieht Basisgröße · Groß zieht große · Mega zieht große Thanksgiving-Tiere. Wald/Savanne/Wüste spawnen keine Event-Tiere.|Regular tarik ukuran dasar · Big tarik besar · Mega tarik hewan Thanksgiving besar. Hutan/Savana/Gurun tidak spawn hewan event.|レギュラーは基本サイズ・ビッグは大型・メガは大型サンクスギビング動物を誘引。森/サバンナ/砂漠はイベント動物を出さない。|레귤러는 기본 크기 · 빅은 큰 것 · 메가는 큰 추수감사절 동물을 유인. 숲/사바나/사막은 이벤트 동물 스폰 안 함.|Thường hút size gốc · Lớn hút size lớn · Siêu hút thú Tạ Ơn lớn. Rừng / Savanna / Sa mạc không spawn thú event.|普通吸引基础体型 · 大吸引大型 · 巨型吸引大型感恩节动物。森林/草原/沙漠不刷活动动物。|Normale attira taglia base · Grande attira grandi · Mega attira grandi animali Thanksgiving. Foresta/Savana/Deserto non spawnano animali evento.|Zwykła przyciąga bazowy rozmiar · Duża duże · Mega duże zwierzęta Thanksgiving. Las/Sawanna/Pustynia nie spawnują zwierząt eventu.|ธรรมดาดึงขนาดพื้นฐาน · ใหญดึงตัวใหญ่ · เมกะดึงสัตว์ขอบคุณพระเจ้าขนาดใหญ่ ป่า/สะวันนา/ทะเลทรายไม่เกิดสัตว์อีเวนต์|Regular umaakit ng base size · Big sa malalaki · Mega sa malalaking Thanksgiving animals. Forest / Savanna / Desert hindi nag-s-spawn ng event animals.|Biasa tarik saiz asas · Besar tarik besar · Mega tarik haiwan Thanksgiving besar. Hutan/Savana/Gurun tidak spawn haiwan acara.
How to play|Nasıl oynanır|Cómo jugar|طريقة اللعب|Comment jouer|कैसे खेलें|Como jogar|Как играть|So spielt man|Cara main|遊び方|플레이 방법|Cách chơi|玩法|Come si gioca|Jak grać|วิธีเล่น|Paano maglaro|Cara main
1) Throw food during the 5-minute Feast window to farm ingredients (RNG). 2) Go to the event hub left of the safe zone. 3) Press E → Thanksgiving Feast. 4) Cook Regular / Big / Mega. 5) Throw the sandwich to pull event animals (Starfall+ biomes).|1) 5 dk'lık Şölen penceresinde malzeme farmlamak için yiyecek at (RNG). 2) Güvenli alanın solundaki etkinlik merkezine git. 3) E → Şükran Günü Şöleni. 4) Normal / Büyük / Mega pişir. 5) Sandvici atarak etkinlik hayvanlarını çek (Starfall+ biyomlar).|1) Lanza comida en la ventana de 5 min del Festín para farmear ingredientes (RNG). 2) Ve al hub del evento a la izquierda de la zona segura. 3) E → Festín de Acción de Gracias. 4) Cocina Normal / Grande / Mega. 5) Lanza el sándwich para atraer animales de evento (biomas Starfall+).|1) ارْمِ الطعام خلال نافذة العيد 5 دقائق لجمع المكونات (عشوائي). 2) اذهب لمركز الحدث يسار المنطقة الآمنة. 3) E → وليمة الشكر. 4) اطبخ عادي / كبير / ميجا. 5) ارمِ الساندويتش لجذب حيوانات الحدث (مناطق Starfall+).|1) Lance de la nourriture pendant les 5 min du Festin pour farmer les ingrédients (RNG). 2) Va au hub d'événement à gauche de la zone sûre. 3) E → Festin Thanksgiving. 4) Cuisine Normal / Grand / Méga. 5) Lance le sandwich pour attirer les animaux d'événement (biomes Starfall+).|1) 5 मिनट की फीस्ट विंडो में सामग्री फार्म करने के लिए खाना फेंको (RNG)। 2) सेफ ज़ोन के बाएँ इवेंट हब पर जाओ। 3) E → थैंक्सगिविंग फीस्ट। 4) रेगुलर / बिग / मेगा पकाओ। 5) सैंडविच फेंककर इवेंट जानवर खींचो (Starfall+ बायोम)।|1) Arremesse comida na janela de 5 min do Festim para farmear ingredientes (RNG). 2) Vá ao hub do evento à esquerda da zona segura. 3) E → Festim de Ação de Graças. 4) Cozinhe Normal / Grande / Mega. 5) Arremesse o sanduíche para atrair animais de evento (biomas Starfall+).|1) Бросайте еду в 5-минутное окно Пира, чтобы фармить ингредиенты (RNG). 2) Идите в хаб события слева от безопасной зоны. 3) E → Пир Дня благодарения. 4) Готовьте Обычный / Большой / Мега. 5) Бросайте сэндвич, чтобы привлечь ивент-животных (биомы Starfall+).|1) Wirf Essen im 5-Minuten-Festfenster, um Zutaten zu farmen (RNG). 2) Geh zum Event-Hub links der Safe Zone. 3) E → Thanksgiving-Fest. 4) Koche Normal / Groß / Mega. 5) Wirf das Sandwich, um Event-Tiere anzulocken (Starfall+-Biome).|1) Lempar makanan selama jendela Pesta 5 menit untuk farm bahan (RNG). 2) Pergi ke hub event di kiri zona aman. 3) E → Pesta Thanksgiving. 4) Masak Regular / Big / Mega. 5) Lempar sandwich untuk tarik hewan event (biome Starfall+).|1) 5分間のフィースト中に食べ物を投げて材料を集める（RNG）。2) 安全地帯左のイベントハブへ。3) E → サンクスギビングフィースト。4) レギュラー/ビッグ/メガを調理。5) サンドイッチを投げてイベント動物を誘引（Starfall+バイオーム）。|1) 5분 축제 동안 음식을 던져 재료 파밍(RNG). 2) 안전 구역 왼쪽 이벤트 허브로. 3) E → 추수감사절 축제. 4) 레귤러/빅/메가 요리. 5) 샌드위치를 던져 이벤트 동물 유인(Starfall+ 바이옴).|1) Ném thức ăn trong 5 phút Tiệc để farm nguyên liệu (RNG). 2) Đến hub sự kiện bên trái safe zone. 3) E → Tiệc Tạ Ơn. 4) Nấu Thường / Lớn / Siêu. 5) Ném sandwich để hút thú event (biome Starfall+).|1) 在5分钟盛宴窗口投掷食物刷材料（随机）。2) 前往安全区左侧活动中心。3) E → 感恩节盛宴。4) 烹饪普通/大/巨型。5) 投掷三明治吸引活动动物（Starfall+生态区）。|1) Lancia cibo nella finestra di 5 min del Banchetto per farmare ingredienti (RNG). 2) Vai all'hub evento a sinistra della zona sicura. 3) E → Banchetto Thanksgiving. 4) Cucina Normale / Grande / Mega. 5) Lancia il panino per attirare animali evento (biomi Starfall+).|1) Rzucaj jedzenie w 5-minutowym oknie Uczty, by farmić składniki (RNG). 2) Idź do huba wydarzenia na lewo od safe zone. 3) E → Uczta Thanksgiving. 4) Gotuj Zwykłą / Dużą / Mega. 5) Rzuć kanapkę, by przyciągnąć zwierzęta eventu (biomy Starfall+).|1) ขว้างอาหารในช่วง 5 นาทีของงานเลี้ยงเพื่อฟาร์มวัตถุดิบ (RNG) 2) ไปฮับอีเวนต์ซ้ายเซฟโซน 3) E → งานเลี้ยงขอบคุณพระเจ้า 4) ทำ ธรรมดา / ใหญ่ / เมกะ 5) ขว้างแซนด์วิชเพื่อดึงสัตว์อีเวนต์ (ไบโอม Starfall+)|1) Maghagis ng pagkain sa 5-minutong Feast window para mag-farm ng ingredients (RNG). 2) Pumunta sa event hub sa kaliwa ng safe zone. 3) E → Thanksgiving Feast. 4) Magluto ng Regular / Big / Mega. 5) Ihagis ang sandwich para humila ng event animals (Starfall+ biomes).|1) Lempar makanan semasa tetingkap Pesta 5 min untuk farm bahan (RNG). 2) Pergi ke hab acara di kiri zon selamat. 3) E → Pesta Thanksgiving. 4) Masak Biasa / Besar / Mega. 5) Lempar sandwich untuk tarik haiwan acara (biome Starfall+).
Thanksgiving Event|Şükran Günü Etkinliği|Evento de Acción de Gracias|حدث الشكر|Événement Thanksgiving|थैंक्सगिविंग इवेंट|Evento de Ação de Graças|Событие Дня благодарения|Thanksgiving-Event|Event Thanksgiving|サンクスギビングイベント|추수감사절 이벤트|Sự kiện Lễ Tạ Ơn|感恩节活动|Evento Thanksgiving|Wydarzenie Thanksgiving|อีเวนต์ขอบคุณพระเจ้า|Thanksgiving Event|Acara Thanksgiving
Auto Throw Event started (+20 power)|Oto Etkinlik Atışı başladı (+20 güç)|Auto Lanzamiento de Evento iniciado (+20 poder)|بدأ رمي الحدث التلقائي (+20 قوة)|Auto Lancer d'événement démarré (+20 puissance)|ऑटो इवेंट थ्रो शुरू (+20 पावर)|Auto Arremesso de Evento iniciado (+20 poder)|Авто бросок события начат (+20 силы)|Auto Event-Wurf gestartet (+20 Power)|Auto Lempar Event dimulai (+20 power)|自動イベント投擲開始（+20パワー）|자동 이벤트 던지기 시작 (+20 파워)|Tự ném sự kiện bắt đầu (+20 sức)|自动活动投掷已开始（+20力量）|Auto Lancio Evento avviato (+20 potenza)|Auto rzut wydarzenia rozpoczęty (+20 mocy)|เริ่มออโต้ขว้างอีเวนต์ (+20 พลัง)|Nagsimula ang Auto Throw Event (+20 power)|Auto Lempar Acara dimulakan (+20 kuasa)
Event ended — resumed previous mode|Etkinlik bitti — önceki moda dönüldü|Evento terminado — se reanudó el modo anterior|انتهى الحدث — استُؤنف الوضع السابق|Événement terminé — mode précédent repris|इवेंट समाप्त — पिछला मोड फिर से|Evento encerrado — modo anterior retomado|Событие закончилось — прежний режим возобновлён|Event beendet — vorheriger Modus fortgesetzt|Event selesai — mode sebelumnya dilanjutkan|イベント終了 — 前のモードに復帰|이벤트 종료 — 이전 모드 재개|Hết sự kiện — đã quay lại chế độ trước|活动结束 — 已恢复先前模式|Evento terminato — ripreso modalità precedente|Wydarzenie zakończone — wznowiono poprzedni tryb|อีเวนต์จบ — กลับโหมดก่อนหน้า|Tapos na ang event — ibinalik ang dating mode|Acara tamat — mode sebelumnya disambung
Off|Kapalı|Inactivo|متوقف|Désactivé|बंद|Desligado|Выкл|Aus|Nonaktif|オフ|꺼짐|Tắt|关|Disattivo|Wył.|ปิด|Naka-off|Mati
Only one size at a time — change the dropdown to switch.|Aynı anda yalnızca bir boyut — değiştirmek için menüyü kullan.|Solo un tamaño a la vez — cambia el desplegable.|حجم واحد فقط في كل مرة — غيّر القائمة.|Une seule taille à la fois — change le menu.|एक समय में केवल एक आकार — ड्रॉपडाउन बदलें।|Apenas um tamanho por vez — mude o menu.|Только один размер за раз — смените в списке.|Nur eine Größe gleichzeitig — Dropdown wechseln.|Hanya satu ukuran sekaligus — ganti dropdown.|一度に1サイズのみ — ドロップダウンで切替。|한 번에 하나의 크기만 — 드롭다운 변경.|Chỉ chọn một cỡ mỗi lần — đổi ở dropdown.|一次仅一种尺寸 — 用下拉切换。|Una sola misura alla volta — cambia il menu.|Tylko jeden rozmiar naraz — zmień listę.|เลือกได้ทีละขนาด — เปลี่ยนที่เมนู|Isang size lang sa isang pagkakataon — palitan sa dropdown.|Hanya satu saiz pada satu masa — tukar dropdown.
Will TP to Feast hub and cook the selected size only|Şölen merkezine ışınlanıp yalnızca seçilen boyutu pişirir|TP al hub del Festín y cocina solo el tamaño elegido|ينتقل لمركز العيد ويطبخ الحجم المحدد فقط|TP au hub du Festin et cuisine uniquement la taille choisie|Feast हब पर TP करके केवल चुना आकार पकाएगा|TP ao hub do Festim e cozinha só o tamanho escolhido|ТП к хабу Пира и готовит только выбранный размер|TP zum Fest-Hub und kocht nur die gewählte Größe|TP ke hub Pesta dan masak hanya ukuran dipilih|フィーストハブにTPし選択サイズのみ調理|축제 허브로 TP 후 선택한 크기만 요리|TP tới hub Tiệc và chỉ nấu cỡ đã chọn|传送到盛宴中心并仅烹饪所选尺寸|TP all'hub Banchetto e cucina solo la misura scelta|TP do huba Uczty i gotuje tylko wybrany rozmiar|วาปไปฮับงานเลี้ยงแล้วทำเฉพาะขนาดที่เลือก|TP sa Feast hub at magluluto lang ng napiling size|TP ke hab Pesta dan masak saiz dipilih sahaja
Feast hub not found|Şölen merkezi bulunamadı|Hub del Festín no encontrado|لم يُعثر على مركز العيد|Hub du Festin introuvable|Feast हब नहीं मिला|Hub do Festim não encontrado|Хаб Пира не найден|Fest-Hub nicht gefunden|Hub Pesta tidak ditemukan|フィーストハブ未検出|축제 허브를 찾을 수 없음|Không tìm thấy hub Tiệc|未找到盛宴中心|Hub Banchetto non trovato|Nie znaleziono huba Uczty|ไม่พบฮับงานเลี้ยง|Hindi nahanap ang Feast hub|Hab Pesta tidak dijumpai
Waits for Feast (~30 min). Throws only during the 5-min window, then stops.|Şöleni bekler (~30 dk). Yalnızca 5 dk pencerede atar, sonra durur.|Espera el Festín (~30 min). Lanza solo en la ventana de 5 min y para.|ينتظر العيد (~30 د). يرمي فقط خلال 5 د ثم يتوقف.|Attend le Festin (~30 min). Lance seulement pendant 5 min puis s'arrête.|फीस्ट का इंतज़ार (~30 मिनट)। केवल 5 मिनट विंडो में थ्रो, फिर रुकता है।|Espera o Festim (~30 min). Arremessa só na janela de 5 min e para.|Ждёт Пир (~30 мин). Бросает только в 5-мин окне, затем стоп.|Wartet auf Fest (~30 Min). Wirft nur im 5-Min-Fenster, dann Stopp.|Menunggu Pesta (~30 mnt). Lempar hanya di jendela 5 mnt lalu berhenti.|フィースト待ち（約30分）。5分窓のみ投擲し停止。|축제 대기(~30분). 5분 창에서만 던지고 멈춤.|Chờ Tiệc (~30 phút). Chỉ ném trong 5 phút rồi dừng.|等待盛宴（约30分钟）。仅在5分钟窗口投掷后停止。|Attende il Banchetto (~30 min). Lancia solo nei 5 min poi ferma.|Czeka na Ucztę (~30 min). Rzuca tylko w oknie 5 min, potem stop.|รองานเลี้ยง (~30 นาที) ขว้างเฉพาะหน้าต่าง 5 นาทีแล้วหยุด|Naghihintay ng Feast (~30 min). Naghahagis lang sa 5-min window tapos titigil.|Menunggu Pesta (~30 min). Lempar hanya dalam tetingkap 5 min lalu berhenti.
Does NOT throw outside the event. When Feast starts: pause train, +20 power, auto throw. When it ends: restore previous mode.|Etkinlik dışında ATMAZ. Şölen başlayınca: antrenmanı durdur, +20 güç, oto atış. Bitince önceki moda dön.|NO lanza fuera del evento. Al empezar el Festín: pausa train, +20 poder, auto throw. Al terminar: restaura el modo previo.|لا يرمي خارج الحدث. عند بدء العيد: إيقاف التدريب، +20 قوة، رمي تلقائي. عند الانتهاء: استعادة الوضع السابق.|Ne lance PAS hors événement. Au Festin: pause train, +20 puissance, auto throw. À la fin: mode précédent.|इवेंट के बाहर थ्रो नहीं। फीस्ट शुरू: ट्रेन रोकें, +20 पावर, ऑटो थ्रो। खत्म: पिछला मोड।|NÃO arremessa fora do evento. No Festim: pausa treino, +20 poder, auto throw. Ao fim: modo anterior.|НЕ бросает вне события. На Пире: пауза тренировки, +20 силы, авто-бросок. После: прежний режим.|Wirft NICHT außerhalb. Beim Fest: Training pausieren, +20 Power, Auto-Wurf. Danach: vorheriger Modus.|TIDAK melempar di luar event. Saat Pesta: jeda train, +20 power, auto throw. Selesai: mode sebelumnya.|イベント外では投げない。フィースト開始で訓練停止・+20パワー・自動投擲。終了で元のモード。|이벤트 밖에서는 던지지 않음. 축제 시작: 훈련 중지, +20 파워, 자동 던지기. 종료 시 이전 모드.|KHÔNG ném ngoài event. Khi Tiệc: dừng luyện, +20 sức, auto throw. Hết: khôi phục chế độ trước.|活动外不投掷。盛宴开始：暂停训练、+20力量、自动投。结束：恢复先前模式。|NON lancia fuori evento. Al Banchetto: pausa train, +20 potenza, auto throw. Fine: modalità precedente.|NIE rzuca poza eventem. Na Uczcie: pauza treningu, +20 mocy, auto rzut. Po: poprzedni tryb.|ไม่ขว้างนอกอีเวนต์ เมื่องานเลี้ยง: หยุดฝึก +20 พลัง ออโต้ขว้าง จบ: คืนโหมดก่อน|HINDI nagtatapon sa labas ng event. Sa Feast: i-pause ang train, +20 power, auto throw. Tapos: ibalik ang dating mode.|TIDAK lempar di luar acara. Bila Pesta: jeda train, +20 kuasa, auto lempar. Tamat: mode sebelumnya.
Waiting for next Feast|Sonraki Şölen bekleniyor|Esperando el próximo Festín|انتظار العيد التالي|En attente du prochain Festin|अगले फीस्ट की प्रतीक्षा|Aguardando o próximo Festim|Ожидание следующего Пира|Warte auf nächstes Fest|Menunggu Pesta berikutnya|次のフィースト待ち|다음 축제 대기|Đang chờ Tiệc tiếp theo|等待下一场盛宴|In attesa del prossimo Banchetto|Oczekiwanie na kolejną Ucztę|รองานเลี้ยงครั้งถัดไป|Naghihintay ng susunod na Feast|Menunggu Pesta seterusnya
TP to Turkey Chef / picnic table (left of safe zone) → cook selected sandwich only.|Turkey Chef / piknik masasına TP (güvenli alanın solu) → yalnızca seçili sandvici pişir.|TP a Turkey Chef / mesa de picnic (izq. zona segura) → cocina solo el sándwich elegido.|انتقال إلى طاهي الديك الرومي / طاولة النزهة (يسار المنطقة الآمنة) → اطبخ الساندويتش المحدد فقط.|TP vers Turkey Chef / table de pique-nique (gauche zone sûre) → cuisine uniquement le sandwich choisi.|Turkey Chef / पिकनिक टेबल पर TP (सेफ ज़ोन बाएँ) → केवल चुना सैंडविच पकाएँ।|TP ao Turkey Chef / mesa de piquenique (esq. zona segura) → cozinha só o sanduíche escolhido.|ТП к Turkey Chef / столу пикника (слева от сейф-зоны) → готовит только выбранный сэндвич.|TP zu Turkey Chef / Picknicktisch (links Safe Zone) → kocht nur gewähltes Sandwich.|TP ke Turkey Chef / meja piknik (kiri zona aman) → masak sandwich dipilih saja.|Turkey Chef／ピクニックテーブルへTP（安全地帯左）→選択サンドイッチのみ調理。|Turkey Chef / 피크닉 테이블로 TP(안전 구역 왼쪽) → 선택한 샌드위치만 요리.|TP tới Turkey Chef / bàn picnic (trái safe zone) → chỉ nấu sandwich đã chọn.|传送到Turkey Chef/野餐桌（安全区左侧）→仅烹饪所选三明治。|TP a Turkey Chef / tavolo picnic (sinistra zona sicura) → cucina solo il panino scelto.|TP do Turkey Chef / stołu piknikowego (lewo safe zone) → gotuje tylko wybraną kanapkę.|วาปไป Turkey Chef / โต๊ะปิกนิก (ซ้ายเซฟโซน) → ทำแซนด์วิชที่เลือกเท่านั้น|TP sa Turkey Chef / picnic table (kaliwa ng safe zone) → lutuin lang ang napiling sandwich.|TP ke Turkey Chef / meja picnik (kiri zon selamat) → masak sandwich dipilih sahaja.
]==]
	for line in RAW:gmatch("[^\n]+") do
		local f = {}
		for part in (line .. "|"):gmatch("(.-)|") do f[#f + 1] = part end
		if #f >= #CODES then
			local e = {}
			for i = 2, #CODES do e[CODES[i]] = f[i] end
			V.Translations[f[1]] = e
		end
	end
end
local ok, err = pcall(V.start)
if not ok then
	warn("[A6Hub] failed to start: " .. tostring(err))
	pcall(V.cleanup)
end
