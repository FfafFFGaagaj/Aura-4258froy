local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local OLD_ROOT = CoreGui:FindFirstChild("FOTO_System_Root") or PlayerGui:FindFirstChild("FOTO_System_Root")
if OLD_ROOT then
	OLD_ROOT:Destroy()
end

local function getGuiParent()
	local ok, res = pcall(function()
		return CoreGui
	end)
	if ok and res then
		local canWrite = pcall(function()
			local f = Instance.new("Folder")
			f.Parent = CoreGui
			f:Destroy()
		end)
		if canWrite then
			return CoreGui
		end
	end
	return PlayerGui
end

local GuiParent = getGuiParent()

local OriginalLighting = {
	Brightness = Lighting.Brightness,
	ExposureCompensation = Lighting.ExposureCompensation,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ColorShift_Top = Lighting.ColorShift_Top,
	ColorShift_Bottom = Lighting.ColorShift_Bottom,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
}

local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Name = "FOTO_ColorCorrection"
ColorCorrection.Enabled = false
ColorCorrection.Parent = Lighting

local Bloom = Instance.new("BloomEffect")
Bloom.Name = "FOTO_Bloom"
Bloom.Enabled = false
Bloom.Intensity = 0.35
Bloom.Size = 24
Bloom.Threshold = 1
Bloom.Parent = Lighting

local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local CreatedAtmosphere = false
if not Atmosphere then
	Atmosphere = Instance.new("Atmosphere")
	Atmosphere.Name = "FOTO_Atmosphere"
	Atmosphere.Parent = Lighting
	CreatedAtmosphere = true
end

local OriginalAtmos = {
	Density = Atmosphere.Density,
	Offset = Atmosphere.Offset,
	Color = Atmosphere.Color,
	Decay = Atmosphere.Decay,
	Glare = Atmosphere.Glare,
	Haze = Atmosphere.Haze,
}

local PresetOrder = {
	"1. Ultra Realistic / RTX Style",
	"2. Cyberpunk / Night Neon",
	"3. Anime / Vibrant Pastel",
	"4. Golden Sunset / Aesthetic",
	"5. Fullbright / Clear Vision",
	"6. Sakura Pink / Dreamy",
	"7. Retro Film / Moody",
}

local Presets = {
	["1. Ultra Realistic / RTX Style"] = {
		Brightness = 2.6,
		Exposure = 0.2,
		ClockTime = 14.5,
		Ambient = Color3.fromRGB(70, 75, 85),
		OutdoorAmbient = Color3.fromRGB(115, 120, 130),
		Tint = Color3.fromRGB(255, 250, 245),
		BaseContrast = 0.24,
		BaseSaturation = 0.16,
		BaseBrightness = 0.02,
		BloomIntensity = 0.45,
		BloomThreshold = 0.95,
		AtmosDensity = 0.28,
		AtmosColor = Color3.fromRGB(199, 215, 235),
	},
	["2. Cyberpunk / Night Neon"] = {
		Brightness = 1.4,
		Exposure = 0.1,
		ClockTime = 23.5,
		Ambient = Color3.fromRGB(65, 35, 95),
		OutdoorAmbient = Color3.fromRGB(45, 75, 125),
		Tint = Color3.fromRGB(225, 205, 255),
		BaseContrast = 0.30,
		BaseSaturation = 0.35,
		BaseBrightness = -0.02,
		BloomIntensity = 0.85,
		BloomThreshold = 0.7,
		AtmosDensity = 0.35,
		AtmosColor = Color3.fromRGB(140, 90, 210),
	},
	["3. Anime / Vibrant Pastel"] = {
		Brightness = 2.5,
		Exposure = 0.25,
		ClockTime = 10.5,
		Ambient = Color3.fromRGB(125, 115, 140),
		OutdoorAmbient = Color3.fromRGB(155, 145, 170),
		Tint = Color3.fromRGB(255, 238, 248),
		BaseContrast = 0.14,
		BaseSaturation = 0.42,
		BaseBrightness = 0.05,
		BloomIntensity = 0.55,
		BloomThreshold = 0.85,
		AtmosDensity = 0.20,
		AtmosColor = Color3.fromRGB(255, 225, 240),
	},
	["4. Golden Sunset / Aesthetic"] = {
		Brightness = 2.1,
		Exposure = 0.15,
		ClockTime = 17.6,
		Ambient = Color3.fromRGB(130, 85, 65),
		OutdoorAmbient = Color3.fromRGB(185, 115, 75),
		Tint = Color3.fromRGB(255, 214, 170),
		BaseContrast = 0.20,
		BaseSaturation = 0.28,
		BaseBrightness = 0.02,
		BloomIntensity = 0.65,
		BloomThreshold = 0.8,
		AtmosDensity = 0.32,
		AtmosColor = Color3.fromRGB(255, 175, 115),
	},
	["5. Fullbright / Clear Vision"] = {
		Brightness = 3.0,
		Exposure = 0.1,
		ClockTime = 12.0,
		Ambient = Color3.fromRGB(210, 210, 210),
		OutdoorAmbient = Color3.fromRGB(220, 220, 220),
		Tint = Color3.fromRGB(255, 255, 255),
		BaseContrast = 0.05,
		BaseSaturation = 0.05,
		BaseBrightness = 0.06,
		BloomIntensity = 0.10,
		BloomThreshold = 1.5,
		AtmosDensity = 0.05,
		AtmosColor = Color3.fromRGB(220, 235, 255),
	},
	["6. Sakura Pink / Dreamy"] = {
		Brightness = 2.3,
		Exposure = 0.2,
		ClockTime = 16.5,
		Ambient = Color3.fromRGB(145, 100, 125),
		OutdoorAmbient = Color3.fromRGB(180, 130, 155),
		Tint = Color3.fromRGB(255, 212, 230),
		BaseContrast = 0.12,
		BaseSaturation = 0.26,
		BaseBrightness = 0.04,
		BloomIntensity = 0.70,
		BloomThreshold = 0.75,
		AtmosDensity = 0.30,
		AtmosColor = Color3.fromRGB(255, 195, 220),
	},
	["7. Retro Film / Moody"] = {
		Brightness = 1.7,
		Exposure = -0.05,
		ClockTime = 15.5,
		Ambient = Color3.fromRGB(85, 82, 78),
		OutdoorAmbient = Color3.fromRGB(120, 112, 100),
		Tint = Color3.fromRGB(235, 222, 198),
		BaseContrast = 0.26,
		BaseSaturation = -0.15,
		BaseBrightness = -0.02,
		BloomIntensity = 0.25,
		BloomThreshold = 1.1,
		AtmosDensity = 0.25,
		AtmosColor = Color3.fromRGB(185, 175, 155),
	},
}

local State = {
	PresetName = PresetOrder[1],
	Intensity = 10,
	Softness = 10,
	Active = false,
	HasEnabled = false,
	LogoHidden = false,
}

local function applyColorSettings()
	if not State.Active then return end
	local p = Presets[State.PresetName]
	if not p then return end

	local intFactor = (State.Intensity - 1) / 19
	local softFactor = (State.Softness - 1) / 19

	local finalContrast = math.clamp(
		p.BaseContrast + (intFactor * 0.35) - (softFactor * 0.22),
		-0.8,
		1.0
	)
	local finalSaturation = math.clamp(
		p.BaseSaturation + (intFactor * 0.40) - (softFactor * 0.25),
		-0.9,
		1.0
	)
	local finalBrightness = math.clamp(
		p.BaseBrightness + (softFactor * 0.08) - (intFactor * 0.03),
		-0.5,
		0.5
	)

	Lighting.Brightness = p.Brightness
	Lighting.ExposureCompensation = p.Exposure + (softFactor * 0.12)
	Lighting.ClockTime = p.ClockTime
	Lighting.Ambient = p.Ambient
	Lighting.OutdoorAmbient = p.OutdoorAmbient

	ColorCorrection.Enabled = true
	ColorCorrection.TintColor = p.Tint
	ColorCorrection.Contrast = finalContrast
	ColorCorrection.Saturation = finalSaturation
	ColorCorrection.Brightness = finalBrightness

	Bloom.Enabled = true
	Bloom.Intensity = math.clamp(p.BloomIntensity + (softFactor * 0.25), 0, 2)
	Bloom.Threshold = p.BloomThreshold

	Atmosphere.Density = p.AtmosDensity
	Atmosphere.Color = p.AtmosColor
end

local function makeDraggable(dragHandle, targetFrame, onMovedCallback)
	local dragging = false
	local dragStart, startPos, moved

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = targetFrame.Position
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > 6 then
				moved = true
				if onMovedCallback then
					onMovedCallback(true)
				end
			end
			if moved then
				targetFrame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local RootGui = Instance.new("ScreenGui")
RootGui.Name = "FOTO_System_Root"
RootGui.ResetOnSpawn = false
RootGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
RootGui.Parent = GuiParent

local PresetPickerFrame
local MainWindow
local LogoButton
local CurrentPresetLabel
local HideLogoBtn
local syncIntensityUI
local syncSoftnessUI

local function setLogoInvisibleOnly(hidden)
	State.LogoHidden = hidden
	if LogoButton then
		-- คงตำแหน่งและตัวตนไว้ แค่ซ่อน/แสดงการมองเห็น
		LogoButton.Visible = not hidden
	end
	if HideLogoBtn then
		HideLogoBtn.Text = hidden and "แสดงโลโก้" or "ซ่อนโลโก้"
	end
end

local function hidePresetPicker()
	if PresetPickerFrame then
		PresetPickerFrame.Visible = false
	end
end

local function showPresetPicker()
	if not PresetPickerFrame then return end
	PresetPickerFrame.Visible = true
	PresetPickerFrame.Size = UDim2.fromOffset(230, 140)
	TweenService:Create(
		PresetPickerFrame,
		TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = UDim2.fromOffset(310, 365) }
	):Play()
end

local function cleanupAndDestroy()
	State.Active = false

	Lighting.Brightness = OriginalLighting.Brightness
	Lighting.ExposureCompensation = OriginalLighting.ExposureCompensation
	Lighting.Ambient = OriginalLighting.Ambient
	Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
	Lighting.ColorShift_Top = OriginalLighting.ColorShift_Top
	Lighting.ColorShift_Bottom = OriginalLighting.ColorShift_Bottom
	Lighting.ClockTime = OriginalLighting.ClockTime
	Lighting.FogEnd = OriginalLighting.FogEnd
	Lighting.GlobalShadows = OriginalLighting.GlobalShadows

	if ColorCorrection then ColorCorrection:Destroy() end
	if Bloom then Bloom:Destroy() end

	if CreatedAtmosphere and Atmosphere then
		Atmosphere:Destroy()
	elseif Atmosphere then
		Atmosphere.Density = OriginalAtmos.Density
		Atmosphere.Offset = OriginalAtmos.Offset
		Atmosphere.Color = OriginalAtmos.Color
		Atmosphere.Decay = OriginalAtmos.Decay
		Atmosphere.Glare = OriginalAtmos.Glare
		Atmosphere.Haze = OriginalAtmos.Haze
	end

	if RootGui then
		RootGui:Destroy()
	end
end

local function createRangeControl(parent, sectionTitle, initialValue, accentColor, onChange)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 88)
	card.BackgroundColor3 = Color3.fromRGB(28, 31, 43)
	card.BorderSizePixel = 0
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -90, 0, 24)
	lbl.Position = UDim2.fromOffset(12, 8)
	lbl.BackgroundTransparency = 1
	lbl.Text = sectionTitle
	lbl.TextColor3 = Color3.fromRGB(240, 242, 250)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 13
	lbl.Parent = card

	local box = Instance.new("TextBox")
	box.Size = UDim2.fromOffset(64, 26)
	box.Position = UDim2.new(1, -76, 0, 7)
	box.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	box.Text = tostring(initialValue)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.GothamBold
	box.TextSize = 13
	box.ClearTextOnFocus = false
	box.Parent = card
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 10)
	track.Position = UDim2.fromOffset(12, 52)
	track.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
	track.BorderSizePixel = 0
	track.Parent = card
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((initialValue - 1) / 19, 0, 1, 0)
	fill.BackgroundColor3 = accentColor
	fill.BorderSizePixel = 0
	fill.Parent = track
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.fromOffset(22, 22)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new((initialValue - 1) / 19, 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(1, -24, 0, 16)
	valueLbl.Position = UDim2.fromOffset(12, 66)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = "ระดับ: " .. tostring(initialValue) .. " / 20"
	valueLbl.TextColor3 = Color3.fromRGB(175, 182, 205)
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.Font = Enum.Font.Gotham
	valueLbl.TextSize = 11
	valueLbl.Parent = card

	local currentVal = initialValue
	local sliding = false

	local function setVal(newVal, updateBox)
		newVal = math.clamp(math.floor(newVal), 1, 20)
		currentVal = newVal
		local ratio = (newVal - 1) / 19
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		knob.Position = UDim2.new(ratio, 0, 0.5, 0)
		valueLbl.Text = "ระดับ: " .. tostring(newVal) .. " / 20"
		if updateBox ~= false then
			box.Text = tostring(newVal)
		end
		onChange(newVal)
	end

	local function updateFromX(posX)
		local absPos = track.AbsolutePosition.X
		local absSize = track.AbsoluteSize.X
		if absSize <= 0 then return end
		local ratio = math.clamp((posX - absPos) / absSize, 0, 1)
		local val = 1 + math.floor((ratio * 19) + 0.5)
		setVal(val, true)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			updateFromX(input.Position.X)
		end
	end)

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)

	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		if num then
			setVal(num, true)
		else
			box.Text = tostring(currentVal)
		end
	end)

	return function(v)
		setVal(v, true)
	end
end
do
	PresetPickerFrame = Instance.new("Frame")
	PresetPickerFrame.Name = "FOTO_PresetPicker"
	PresetPickerFrame.Size = UDim2.fromOffset(310, 365)
	PresetPickerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	PresetPickerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	PresetPickerFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 33)
	PresetPickerFrame.Visible = false
	PresetPickerFrame.ZIndex = 30
	PresetPickerFrame.Parent = RootGui
	Instance.new("UICorner", PresetPickerFrame).CornerRadius = UDim.new(0, 14)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(115, 130, 255)
	stroke.Thickness = 1.6
	stroke.Parent = PresetPickerFrame

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -20, 0, 38)
	header.Position = UDim2.fromOffset(10, 8)
	header.BackgroundTransparency = 1
	header.Text = "เลือกโทนสีภาพ (7 โทน)"
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.Font = Enum.Font.GothamBold
	header.TextSize = 15
	header.ZIndex = 31
	header.Parent = PresetPickerFrame

	local listHolder = Instance.new("Frame")
	listHolder.Size = UDim2.new(1, -24, 1, -56)
	listHolder.Position = UDim2.fromOffset(12, 48)
	listHolder.BackgroundTransparency = 1
	listHolder.ZIndex = 31
	listHolder.Parent = PresetPickerFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = listHolder

	for _, presetName in ipairs(PresetOrder) do
		local btn = Instance.new("TextButton")
		btn.Name = presetName
		btn.Size = UDim2.new(1, 0, 0, 37)
		btn.BackgroundColor3 = Color3.fromRGB(34, 38, 52)
		btn.Text = presetName
		btn.TextColor3 = Color3.fromRGB(235, 238, 248)
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 12
		btn.ZIndex = 32
		btn.Parent = listHolder
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

		btn.MouseButton1Click:Connect(function()
			State.PresetName = presetName
			if CurrentPresetLabel then
				CurrentPresetLabel.Text = "โทนสีปัจจุบัน: " .. presetName
			end
			applyColorSettings()
			hidePresetPicker()
		end)
	end
end

do
	MainWindow = Instance.new("Frame")
	MainWindow.Name = "FOTO_MainWindow"
	MainWindow.Size = UDim2.fromOffset(360, 440)
	MainWindow.Position = UDim2.new(0.5, 0, -0.65, 0)
	MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
	MainWindow.BackgroundColor3 = Color3.fromRGB(19, 21, 29)
	MainWindow.Visible = false
	MainWindow.ZIndex = 20
	MainWindow.Parent = RootGui
	Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 14)

	local winStroke = Instance.new("UIStroke")
	winStroke.Color = Color3.fromRGB(95, 110, 225)
	winStroke.Thickness = 1.6
	winStroke.Parent = MainWindow

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 44)
	topBar.BackgroundColor3 = Color3.fromRGB(26, 29, 40)
	topBar.BorderSizePixel = 0
	topBar.ZIndex = 21
	topBar.Parent = MainWindow
	Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 14)

	local winTitle = Instance.new("TextLabel")
	winTitle.Size = UDim2.new(1, -90, 1, 0)
	winTitle.Position = UDim2.fromOffset(14, 0)
	winTitle.BackgroundTransparency = 1
	winTitle.Text = "FOTO | Color & Graphics"
	winTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	winTitle.TextXAlignment = Enum.TextXAlignment.Left
	winTitle.Font = Enum.Font.GothamBold
	winTitle.TextSize = 14
	winTitle.ZIndex = 22
	winTitle.Parent = topBar

	local closeWinBtn = Instance.new("TextButton")
	closeWinBtn.Size = UDim2.fromOffset(30, 30)
	closeWinBtn.Position = UDim2.new(1, -38, 0.5, -15)
	closeWinBtn.BackgroundColor3 = Color3.fromRGB(45, 49, 66)
	closeWinBtn.Text = "X"
	closeWinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeWinBtn.Font = Enum.Font.GothamBold
	closeWinBtn.TextSize = 13
	closeWinBtn.ZIndex = 22
	closeWinBtn.Parent = topBar
	Instance.new("UICorner", closeWinBtn).CornerRadius = UDim.new(0, 8)

	closeWinBtn.MouseButton1Click:Connect(function()
		hidePresetPicker()
		MainWindow.Visible = false
	end)

	makeDraggable(topBar, MainWindow)

	local body = Instance.new("ScrollingFrame")
	body.Size = UDim2.new(1, -24, 1, -56)
	body.Position = UDim2.fromOffset(12, 50)
	body.BackgroundTransparency = 1
	body.ScrollBarThickness = 4
	body.CanvasSize = UDim2.new(0, 0, 0, 365)
	body.ZIndex = 21
	body.Parent = MainWindow

	local bodyLayout = Instance.new("UIListLayout")
	bodyLayout.Padding = UDim.new(0, 10)
	bodyLayout.FillDirection = Enum.FillDirection.Vertical
	bodyLayout.Parent = body

	local presetCard = Instance.new("Frame")
	presetCard.Size = UDim2.new(1, 0, 0, 82)
	presetCard.BackgroundColor3 = Color3.fromRGB(28, 31, 43)
	presetCard.BorderSizePixel = 0
	presetCard.Parent = body
	Instance.new("UICorner", presetCard).CornerRadius = UDim.new(0, 10)

	local section1Lbl = Instance.new("TextLabel")
	section1Lbl.Size = UDim2.new(1, -20, 0, 22)
	section1Lbl.Position = UDim2.fromOffset(12, 8)
	section1Lbl.BackgroundTransparency = 1
	section1Lbl.Text = "1. โทนสีภาพ"
	section1Lbl.TextColor3 = Color3.fromRGB(240, 242, 250)
	section1Lbl.TextXAlignment = Enum.TextXAlignment.Left
	section1Lbl.Font = Enum.Font.GothamBold
	section1Lbl.TextSize = 13
	section1Lbl.Parent = presetCard

	CurrentPresetLabel = Instance.new("TextLabel")
	CurrentPresetLabel.Size = UDim2.new(1, -92, 0, 32)
	CurrentPresetLabel.Position = UDim2.fromOffset(12, 36)
	CurrentPresetLabel.BackgroundTransparency = 1
	CurrentPresetLabel.Text = "โทนสีปัจจุบัน: " .. State.PresetName
	CurrentPresetLabel.TextColor3 = Color3.fromRGB(185, 195, 225)
	CurrentPresetLabel.TextXAlignment = Enum.TextXAlignment.Left
	CurrentPresetLabel.TextWrapped = true
	CurrentPresetLabel.Font = Enum.Font.Gotham
	CurrentPresetLabel.TextSize = 12
	CurrentPresetLabel.Parent = presetCard

	local openPickerBtn = Instance.new("TextButton")
	openPickerBtn.Size = UDim2.fromOffset(68, 34)
	openPickerBtn.Position = UDim2.new(1, -80, 0, 35)
	openPickerBtn.BackgroundColor3 = Color3.fromRGB(105, 120, 245)
	openPickerBtn.Text = "เปิด"
	openPickerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	openPickerBtn.Font = Enum.Font.GothamBold
	openPickerBtn.TextSize = 13
	openPickerBtn.Parent = presetCard
	Instance.new("UICorner", openPickerBtn).CornerRadius = UDim.new(0, 8)

	openPickerBtn.MouseButton1Click:Connect(function()
		showPresetPicker()
	end)

	syncIntensityUI = createRangeControl(
		body,
		"2. ความเข้ม (1 - 20)",
		State.Intensity,
		Color3.fromRGB(115, 130, 255),
		function(val)
			State.Intensity = val
			applyColorSettings()
		end
	)

	syncSoftnessUI = createRangeControl(
		body,
		"3. ความอ่อน (1 - 20)",
		State.Softness,
		Color3.fromRGB(120, 215, 180),
		function(val)
			State.Softness = val
			applyColorSettings()
		end
	)

	-- การ์ดซ่อนโลโก้ (มองไม่เห็นแต่อยู่ตำแหน่งเดิม)
	local logoCard = Instance.new("Frame")
	logoCard.Size = UDim2.new(1, 0, 0, 48)
	logoCard.BackgroundColor3 = Color3.fromRGB(28, 31, 43)
	logoCard.BorderSizePixel = 0
	logoCard.Parent = body
	Instance.new("UICorner", logoCard).CornerRadius = UDim.new(0, 10)

	local logoCardLbl = Instance.new("TextLabel")
	logoCardLbl.Size = UDim2.new(1, -125, 1, 0)
	logoCardLbl.Position = UDim2.fromOffset(12, 0)
	logoCardLbl.BackgroundTransparency = 1
	logoCardLbl.Text = "โลโก้ FOTO (คงตำแหน่งเดิม)"
	logoCardLbl.TextColor3 = Color3.fromRGB(240, 242, 250)
	logoCardLbl.TextXAlignment = Enum.TextXAlignment.Left
	logoCardLbl.Font = Enum.Font.GothamBold
	logoCardLbl.TextSize = 12
	logoCardLbl.Parent = logoCard

	HideLogoBtn = Instance.new("TextButton")
	HideLogoBtn.Size = UDim2.fromOffset(102, 32)
	HideLogoBtn.Position = UDim2.new(1, -112, 0.5, -16)
	HideLogoBtn.BackgroundColor3 = Color3.fromRGB(68, 74, 98)
	HideLogoBtn.Text = "ซ่อนโลโก้"
	HideLogoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	HideLogoBtn.Font = Enum.Font.GothamBold
	HideLogoBtn.TextSize = 12
	HideLogoBtn.Parent = logoCard
	Instance.new("UICorner", HideLogoBtn).CornerRadius = UDim.new(0, 8)

	HideLogoBtn.MouseButton1Click:Connect(function()
		setLogoInvisibleOnly(not State.LogoHidden)
	end)
end

local function openElasticMainWindow(forceElastic)
	State.Active = true
	if forceElastic or not MainWindow.Visible then
		MainWindow.Visible = true
		MainWindow.Position = UDim2.new(0.5, 0, -0.65, 0)
		TweenService:Create(
			MainWindow,
			TweenInfo.new(0.65, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, 0, 0.5, 0) }
		):Play()
	end
	applyColorSettings()
end

do
	LogoButton = Instance.new("TextButton")
	LogoButton.Name = "FOTO_LogoButton"
	LogoButton.Size = UDim2.fromOffset(78, 78)
	LogoButton.Position = UDim2.new(0.05, 0, 0.35, 0)
	LogoButton.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
	LogoButton.Text = "FOTO"
	LogoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	LogoButton.Font = Enum.Font.GothamBlack
	LogoButton.TextSize = 20
	LogoButton.AutoButtonColor = false
	LogoButton.ZIndex = 10
	LogoButton.Parent = RootGui
	Instance.new("UICorner", LogoButton).CornerRadius = UDim.new(1, 0)

	local LogoStroke = Instance.new("UIStroke")
	LogoStroke.Color = Color3.fromRGB(115, 130, 255)
	LogoStroke.Thickness = 2.5
	LogoStroke.Parent = LogoButton

	local LogoGradient = Instance.new("UIGradient")
	LogoGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 36, 52)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 20, 28)),
	})
	LogoGradient.Rotation = 45
	LogoGradient.Parent = LogoButton

	local movedFlag = false
	makeDraggable(LogoButton, LogoButton, function(isMoved)
		movedFlag = isMoved
	end)

	local ConfirmFrame = Instance.new("Frame")
	ConfirmFrame.Name = "FOTO_ConfirmModal"
	ConfirmFrame.Size = UDim2.fromOffset(270, 145)
	ConfirmFrame.Position = UDim2.fromScale(0.5, 0.5)
	ConfirmFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	ConfirmFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
	ConfirmFrame.Visible = false
	ConfirmFrame.ZIndex = 25
	ConfirmFrame.Parent = RootGui
	Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 14)

	local ConfirmStroke = Instance.new("UIStroke")
	ConfirmStroke.Color = Color3.fromRGB(80, 90, 125)
	ConfirmStroke.Thickness = 1.5
	ConfirmStroke.Parent = ConfirmFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -24, 0, 46)
	TitleLabel.Position = UDim2.fromOffset(12, 10)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "FOTO - เลือกสถานะสคริปต์"
	TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 15
	TitleLabel.ZIndex = 26
	TitleLabel.Parent = ConfirmFrame

	local EnableBtn = Instance.new("TextButton")
	EnableBtn.Name = "EnableButton"
	EnableBtn.Size = UDim2.new(0.46, -6, 0, 42)
	EnableBtn.Position = UDim2.new(0.04, 0, 1, -56)
	EnableBtn.BackgroundColor3 = Color3.fromRGB(64, 158, 105)
	EnableBtn.Text = "ใช้งาน"
	EnableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	EnableBtn.Font = Enum.Font.GothamBold
	EnableBtn.TextSize = 14
	EnableBtn.ZIndex = 26
	EnableBtn.Parent = ConfirmFrame
	Instance.new("UICorner", EnableBtn).CornerRadius = UDim.new(0, 10)

	local DisableBtn = Instance.new("TextButton")
	DisableBtn.Name = "DisableButton"
	DisableBtn.Size = UDim2.new(0.46, -6, 0, 42)
	DisableBtn.Position = UDim2.new(0.5, 6, 1, -56)
	DisableBtn.BackgroundColor3 = Color3.fromRGB(205, 68, 76)
	DisableBtn.Text = "ปิดใช้งาน"
	DisableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	DisableBtn.Font = Enum.Font.GothamBold
	DisableBtn.TextSize = 14
	DisableBtn.ZIndex = 26
	DisableBtn.Parent = ConfirmFrame
	Instance.new("UICorner", DisableBtn).CornerRadius = UDim.new(0, 10)

	LogoButton.MouseButton1Click:Connect(function()
		if movedFlag then
			movedFlag = false
			return
		end

		LogoButton.Size = UDim2.fromOffset(66, 66)
		TweenService:Create(
			LogoButton,
			TweenInfo.new(0.28, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
			{ Size = UDim2.fromOffset(78, 78) }
		):Play()

		-- หากกด "ใช้งาน" ไปแล้วครั้งเดียว การกดโลโก้ FOTO จะเปิด/ซ่อนหน้าต่างหลักได้โดยตรง ไม่ต้องกด "ใช้งาน" ซ้ำ
		if State.HasEnabled then
			if MainWindow.Visible then
				hidePresetPicker()
				MainWindow.Visible = false
			else
				openElasticMainWindow(true)
			end
			return
		end

		if ConfirmFrame.Visible then
			ConfirmFrame.Visible = false
		else
			ConfirmFrame.Visible = true
			ConfirmFrame.Size = UDim2.fromOffset(180, 95)
			TweenService:Create(
				ConfirmFrame,
				TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Size = UDim2.fromOffset(270, 145) }
			):Play()
		end
	end)

	EnableBtn.MouseButton1Click:Connect(function()
		if State.HasEnabled then return end
		State.HasEnabled = true
		EnableBtn.Visible = false
		DisableBtn.Size = UDim2.new(0.92, 0, 0, 42)
		DisableBtn.Position = UDim2.new(0.04, 0, 1, -56)
		ConfirmFrame.Visible = false
		openElasticMainWindow(true)
	end)

	DisableBtn.MouseButton1Click:Connect(function()
		cleanupAndDestroy()
	end)
end
