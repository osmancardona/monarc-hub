--======================================================--
--  MONARC UI  |  v0.1 - Interfaz (todavía sin funciones)
--======================================================--
-- Este script SOLO dibuja la interfaz: ventana, menú lateral,
-- toggles y dropdowns. Los botones se pueden tocar y cambian
-- de estado visualmente, pero no hacen nada "real" en el juego
-- todavía. Eso lo conectaremos en una siguiente etapa.
--======================================================--

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--========== TEMA (colores que se usan en toda la UI) ==========--
local THEME = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar    = Color3.fromRGB(13, 13, 16),
    Card       = Color3.fromRGB(27, 27, 32),
    Text       = Color3.fromRGB(235, 235, 240),
    SubText    = Color3.fromRGB(150, 150, 158),
    AccentFrom = Color3.fromRGB(167, 139, 250), -- morado
    AccentTo   = Color3.fromRGB(96, 165, 250),  -- azul
    ToggleOff  = Color3.fromRGB(46, 46, 53),
}

--========== Si vuelves a correr el script, borra la UI anterior ==========--
do
    local coreOk, core = pcall(function() return game:GetService("CoreGui") end)
    if coreOk and core:FindFirstChild("MonarcUI") then
        core.MonarcUI:Destroy()
    end
    if player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("MonarcUI") then
        player.PlayerGui.MonarcUI:Destroy()
    end
end

--========== ScreenGui (el contenedor de todo) ==========--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MonarcUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Intentamos meterlo en CoreGui (sobrevive mejor a cambios de pantalla).
-- Si no se puede, lo metemos en el PlayerGui normal.
local parentedOk = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not parentedOk then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

--========== Ventana principal ==========--
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(900, 540)
main.Position = UDim2.new(0.5, -450, 0.5, -270)
main.BackgroundColor3 = THEME.Background
main.BorderSizePixel = 0
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

--========== Barra superior (sirve para arrastrar la ventana) ==========--
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundTransparency = 1
topBar.Active = true
topBar.Parent = main

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -260, 1, 0)
title.Position = UDim2.fromOffset(240, 0)
title.BackgroundTransparency = 1
title.Text = "v0.1 - Mi Juego"
title.TextColor3 = THEME.SubText
title.Font = Enum.Font.Gotham
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Lógica para poder arrastrar la ventana tomándola de la barra superior
do
    local dragging, dragStart, startPos, dragInput

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--========== Sidebar (menú lateral izquierdo) ==========--
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 210, 1, 0)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)

-- Logo (un cuadrito rotado con degradado morado->azul + texto "MONARC")
local logoIcon = Instance.new("Frame")
logoIcon.Size = UDim2.fromOffset(26, 26)
logoIcon.Position = UDim2.fromOffset(20, 23)
logoIcon.Rotation = 45
logoIcon.BackgroundColor3 = THEME.AccentFrom
logoIcon.Parent = sidebar
Instance.new("UICorner", logoIcon).CornerRadius = UDim.new(0, 6)

local logoGradient = Instance.new("UIGradient")
logoGradient.Color = ColorSequence.new(THEME.AccentFrom, THEME.AccentTo)
logoGradient.Rotation = 45
logoGradient.Parent = logoIcon

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, -70, 0, 26)
logoText.Position = UDim2.fromOffset(58, 23)
logoText.BackgroundTransparency = 1
logoText.Text = "MONARC"
logoText.Font = Enum.Font.GothamBold
logoText.TextSize = 18
logoText.TextColor3 = THEME.Text
logoText.TextXAlignment = Enum.TextXAlignment.Left
logoText.Parent = sidebar

-- Botón de navegación "Main" (resaltado, como en tu captura)
local navButton = Instance.new("Frame")
navButton.Size = UDim2.new(1, -24, 0, 40)
navButton.Position = UDim2.fromOffset(12, 80)
navButton.BackgroundColor3 = THEME.Card
navButton.Parent = sidebar
Instance.new("UICorner", navButton).CornerRadius = UDim.new(0, 8)

local navIcon = Instance.new("Frame")
navIcon.Size = UDim2.fromOffset(10, 10)
navIcon.Position = UDim2.fromOffset(16, 15)
navIcon.BackgroundColor3 = THEME.AccentFrom
navIcon.Parent = navButton
Instance.new("UICorner", navIcon).CornerRadius = UDim.new(1, 0)

local navText = Instance.new("TextLabel")
navText.Size = UDim2.new(1, -50, 1, 0)
navText.Position = UDim2.fromOffset(38, 0)
navText.BackgroundTransparency = 1
navText.Text = "Main"
navText.Font = Enum.Font.Gotham
navText.TextSize = 14
navText.TextColor3 = THEME.Text
navText.TextXAlignment = Enum.TextXAlignment.Left
navText.Parent = navButton

--========== Área de contenido (a la derecha del sidebar) ==========--
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -226, 1, -66)
content.Position = UDim2.fromOffset(218, 58)
content.BackgroundTransparency = 1
content.Parent = main

local cardsLayout = Instance.new("UIListLayout")
cardsLayout.FillDirection = Enum.FillDirection.Horizontal
cardsLayout.Padding = UDim.new(0, 16)
cardsLayout.Parent = content

--========== Función reutilizable: crear una "tarjeta" (card) ==========--
local function createCard(name, widthOffset, titleText)
    local card = Instance.new("Frame")
    card.Name = name
    card.Size = UDim2.new(0, widthOffset, 1, 0)
    card.BackgroundColor3 = THEME.Card
    card.BorderSizePixel = 0
    card.Parent = content
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 16)
    pad.PaddingLeft = UDim.new(0, 18)
    pad.PaddingRight = UDim.new(0, 18)
    pad.Parent = card

    local cardTitle = Instance.new("TextLabel")
    cardTitle.Text = titleText
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextSize = 14
    cardTitle.TextColor3 = THEME.SubText
    cardTitle.BackgroundTransparency = 1
    cardTitle.Size = UDim2.new(1, 0, 0, 24)
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.LayoutOrder = 0
    cardTitle.Parent = card

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 18)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = card

    return card
end

local autoFarmCard = createCard("AutoFarm", 470, "Auto Farm")
local featuresCard = createCard("Features", 360, "Features")

--========== Funciones reutilizables: filas, toggles y dropdowns ==========--

local function createRow(parent, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, height or 36)
    row.BackgroundTransparency = 1
    row.Parent = parent
    return row
end

local function createLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.TextColor3 = THEME.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

-- Guardamos cada toggle/dropdown en estas tablas con su nombre como clave.
-- Esto es a propósito: cuando conectemos las funciones reales, será tan
-- fácil como escribir, por ejemplo: Toggles["Auto Click"]:Get()
local Toggles = {}
local Dropdowns = {}

local function createToggle(parent, key, default)
    local row = createRow(parent, 30)
    createLabel(row, key)

    local switch = Instance.new("Frame")
    switch.Size = UDim2.fromOffset(40, 24)
    switch.Position = UDim2.new(1, -40, 0.5, -12)
    switch.BackgroundColor3 = default and THEME.AccentFrom or THEME.ToggleOff
    switch.Parent = row
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = switch

    local state = default
    local toggleObj = {}

    function toggleObj:Set(value)
        state = value
        local knobPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        TweenService:Create(switch, TweenInfo.new(0.15), {
            BackgroundColor3 = state and THEME.AccentFrom or THEME.ToggleOff
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), { Position = knobPos }):Play()
    end

    function toggleObj:Get()
        return state
    end

    button.MouseButton1Click:Connect(function()
        toggleObj:Set(not state)
        -- TODO (siguiente etapa): aquí llamaremos a la función real,
        -- por ejemplo: if state then StartAutoClick() else StopAutoClick() end
    end)

    Toggles[key] = toggleObj
    return toggleObj
end

local function createDropdown(parent, key, options)
    options = options or { "Opción 1", "Opción 2" }

    local row = createRow(parent, 56)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = key
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.TextColor3 = THEME.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(1, 0, 0, 30)
    box.Position = UDim2.fromOffset(0, 24)
    box.BackgroundColor3 = THEME.ToggleOff
    box.AutoButtonColor = false
    box.Text = ""
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local boxLabel = Instance.new("TextLabel")
    boxLabel.Size = UDim2.new(1, -30, 1, 0)
    boxLabel.Position = UDim2.fromOffset(10, 0)
    boxLabel.BackgroundTransparency = 1
    boxLabel.Text = options[1] or "Selecciona..."
    boxLabel.Font = Enum.Font.Gotham
    boxLabel.TextSize = 13
    boxLabel.TextColor3 = THEME.SubText
    boxLabel.TextXAlignment = Enum.TextXAlignment.Left
    boxLabel.Parent = box

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(20, 30)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = THEME.SubText
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 12
    arrow.Parent = box

    -- Lista de opciones, oculta hasta que se hace click en la caja
    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 0, math.min(#options, 4) * 28)
    list.Position = UDim2.fromOffset(0, 58)
    list.BackgroundColor3 = THEME.ToggleOff
    list.Visible = false
    list.ZIndex = 5
    list.Parent = row
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = list

    local selected = options[1]
    local dropdownObj = {}

    function dropdownObj:Get()
        return selected
    end

    for _, optionText in ipairs(options) do
        local optButton = Instance.new("TextButton")
        optButton.Size = UDim2.new(1, 0, 0, 28)
        optButton.BackgroundTransparency = 1
        optButton.Text = optionText
        optButton.TextColor3 = THEME.Text
        optButton.Font = Enum.Font.Gotham
        optButton.TextSize = 13
        optButton.ZIndex = 6
        optButton.Parent = list

        optButton.MouseButton1Click:Connect(function()
            selected = optionText
            boxLabel.Text = optionText
            list.Visible = false
        end)
    end

    box.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
    end)

    Dropdowns[key] = dropdownObj
    return dropdownObj
end

--========== Contenido de la tarjeta "Auto Farm" ==========--
createDropdown(autoFarmCard, "Select World", { "Mundo 1", "Mundo 2", "Mundo 3" })
createDropdown(autoFarmCard, "Select Mobs", { "Mob 1", "Mob 2" })
createToggle(autoFarmCard, "Teleport To World Before Farm", true)
createToggle(autoFarmCard, "Auto Farm Mobs", false)

--========== Contenido de la tarjeta "Features" ==========--
createToggle(featuresCard, "Auto Redeem Codes", true)
createToggle(featuresCard, "Auto Click", true)

print("[MonarcUI] Interfaz cargada correctamente ✔")
