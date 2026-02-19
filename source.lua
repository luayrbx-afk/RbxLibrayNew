z--[[
    CRATE UI LIBRARY v2 - 2026
    SISTEMA MODULAR DE UI PARA ROBLOX
]]

local Crate = {}
Crate.__index = Crate

--// SERVIÇOS DO ROBLOX
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

--// TABELAS DE DADOS INTERNOS
Crate.Elements = {
    Toggles = {},
    TextBoxes = {},
    Dropdowns = {},
    Sliders = {},
    ColorPickers = {},
    CodeBoxes = {}
}

--// FUNÇÃO DE ARRASTAR (DRAGGABLE)
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// CONSTRUTOR DA JANELA PRINCIPAL
function Crate:windows(name)
    local WindowObj = {
        Name = name,
        MainColor = Color3.fromRGB(20, 20, 20),
        AccentColor = Color3.fromRGB(110, 50, 250),
        Keybind = Enum.KeyCode.P,
        MinKey = Enum.KeyCode.Z,
        Minimized = false,
        Visible = true
    }

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Crate_" .. name
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WindowObj.Gui = ScreenGui

    -- Frame Principal (Design conforme imagem)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = WindowObj.MainColor
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = MainFrame

    -- Barra Lateral (Abas)
    local SideBar = Instance.new("Frame")
    SideBar.Name = "SideBar"
    SideBar.Parent = MainFrame
    SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SideBar.Size = UDim2.new(0, 130, 1, 0)
    
    local SideBarCorner = Instance.new("UICorner")
    SideBarCorner.CornerRadius = UDim.new(0, 15)
    SideBarCorner.Parent = SideBar
    
    -- Separador Vertical
    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(0, 2, 1, -40)
    Separator.Position = UDim2.new(1, -2, 0, 20)
    Separator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Separator.BorderSizePixel = 0
    Separator.Parent = SideBar

    -- Container de Conteúdo (Áreas)
    local ContentHolder = Instance.new("ScrollingFrame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Parent = MainFrame
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Position = UDim2.new(0, 140, 0, 50)
    ContentHolder.Size = UDim2.new(1, -150, 1, -60)
    ContentHolder.ScrollBarThickness = 2
    ContentHolder.CanvasSize = UDim2.new(0, 0, 0, 0)

    -- Bolinha de Minimizar (M)
    local MiniBall = Instance.new("ImageButton")
    MiniBall.Name = "MiniBall"
    MiniBall.Parent = ScreenGui
    MiniBall.Visible = false
    MiniBall.Size = UDim2.new(0, 50, 0, 50)
    MiniBall.BackgroundColor3 = WindowObj.MainColor
    MiniBall.Position = UDim2.new(0.1, 0, 0.1, 0)
    
    local MBCorner = Instance.new("UICorner")
    MBCorner.CornerRadius = UDim.new(1, 0)
    MBCorner.Parent = MiniBall
    
    MakeDraggable(MainFrame)
    MakeDraggable(MiniBall)

    --// FUNÇÕES DA WINDOW
    function WindowObj:GuiSize(udim) MainFrame.Size = udim end
    function WindowObj:GuiColor(color) MainFrame.BackgroundColor3 = color end
    function WindowObj:Keyboard(key) WindowObj.Keybind = key end
    function WindowObj:MinimizeKey(key) WindowObj.MinKey = key end
    function WindowObj:M(id, size) 
        MiniBall.Image = "rbxassetid://" .. tostring(id)
        -- Ajuste de tamanho se necessário baseado na string "23x23"
    end

    -- Toggle de Visibilidade/Minimização
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == WindowObj.Keybind then
            WindowObj.Visible = not WindowObj.Visible
            MainFrame.Visible = WindowObj.Visible
        elseif input.KeyCode == WindowObj.MinKey then
            WindowObj.Minimized = not WindowObj.Minimized
            MainFrame.Visible = not WindowObj.Minimized
            MiniBall.Visible = WindowObj.Minimized
        end
    end)

    WindowObj.MainFrame = MainFrame
    WindowObj.SideBar = SideBar
    WindowObj.ContentHolder = ContentHolder
    setmetatable(WindowObj, {__index = Crate})
    return WindowObj
end
--// SISTEMA DE CRIAÇÃO DE ÁREA (TAB)
function Crate:CreateArea(name)
    local AreaObj = {
        Name = name,
        Elements = {}
    }
    
    -- Botão na Sidebar
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "_Tab"
    TabBtn.Parent = self.SideBar:FindFirstChild("TabContainer") or self.SideBar -- Fallback se não houver container
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBtn.Size = UDim2.new(1, -10, 0, 30)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 14
    
    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(0, 6)
    TBCorner.Parent = TabBtn

    -- Container de itens da Área
    local ItemList = Instance.new("ScrollingFrame")
    ItemList.Name = name .. "_Items"
    ItemList.Parent = self.ContentHolder
    ItemList.Size = UDim2.new(1, 0, 1, 0)
    ItemList.BackgroundTransparency = 1
    ItemList.Visible = false
    ItemList.ScrollBarThickness = 0
    ItemList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local UIList = Instance.new("UIListLayout")
    UIList.Parent = ItemList
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Alternar Abas
    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.ContentHolder:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        ItemList.Visible = true
    end)

    --// BANNER (DESIGN 404)
    function AreaObj:banner(data)
        local BannerFrame = Instance.new("Frame")
        BannerFrame.Size = UDim2.new(1, -10, 0, 110)
        BannerFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        BannerFrame.Parent = ItemList
        
        local BICorner = Instance.new("UICorner")
        BICorner.CornerRadius = UDim.new(0, 10)
        BICorner.Parent = BannerFrame

        local Img = Instance.new("ImageLabel")
        Img.Size = UDim2.new(0, 267, 0, 107) -- Tamanho exato da imagem
        Img.Position = UDim2.new(0.5, -133, 0.5, -53)
        Img.Image = "rbxassetid://" .. tostring(data.id)
        Img.BackgroundTransparency = 1
        Img.Parent = BannerFrame

        local Info = Instance.new("TextLabel")
        Info.Size = UDim2.new(1, 0, 1, 0)
        Info.Text = data.text
        Info.TextColor3 = Color3.fromRGB(200, 200, 200)
        Info.BackgroundTransparency = 1
        Info.Font = Enum.Font.Gotham
        Info.TextSize = 14
        Info.Parent = BannerFrame
    end

    --// DISCORD (JOIN & COPY)
    function AreaObj:Discord(inviteLink)
        local DiscFrame = Instance.new("Frame")
        DiscFrame.Size = UDim2.new(1, -10, 0, 80)
        DiscFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DiscFrame.Parent = ItemList
        
        local DCorner = Instance.new("UICorner")
        DCorner.CornerRadius = UDim.new(0, 10)
        DCorner.Parent = DiscFrame

        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 40, 0, 40)
        Icon.Position = UDim2.new(0, 10, 0, 10)
        Icon.Image = "rbxassetid://6034537559" -- Ícone Discord
        Icon.BackgroundTransparency = 1
        Icon.Parent = DiscFrame

        local Title = Instance.new("TextLabel")
        Title.Text = "Join discord"
        Title.Position = UDim2.new(0, 60, 0, 10)
        Title.Size = UDim2.new(0, 100, 0, 20)
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 16
        Title.BackgroundTransparency = 1
        Title.Parent = DiscFrame

        local CopyBtn = Instance.new("TextButton")
        CopyBtn.Size = UDim2.new(0, 100, 0, 25)
        CopyBtn.Position = UDim2.new(0, 60, 0, 40)
        CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        CopyBtn.Text = "Copy link"
        CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CopyBtn.Parent = DiscFrame
        
        local CBCorner = Instance.new("UICorner")
        CBCorner.CornerRadius = UDim.new(0, 6)
        CBCorner.Parent = CopyBtn

        CopyBtn.MouseButton1Click:Connect(function()
            setclipboard(inviteLink)
            CopyBtn.Text = "Copied!"
            task.wait(2)
            CopyBtn.Text = "Copy link"
        end)
    end

    --// FEEDBACK (WEBHOOK + CENSURA)
    function AreaObj:Feedback(webhookUrl)
        local FeedFrame = Instance.new("Frame")
        FeedFrame.Size = UDim2.new(1, -10, 0, 120)
        FeedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        FeedFrame.Parent = ItemList
        
        local Input = Instance.new("TextBox")
        Input.Size = UDim2.new(1, -20, 0, 60)
        Input.Position = UDim2.new(0, 10, 0, 10)
        Input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Input.PlaceholderText = "Entrer tour text"
        Input.Text = ""
        Input.TextColor3 = Color3.fromRGB(255, 255, 255)
        Input.ClearTextOnFocus = false
        Input.MultiLine = true
        Input.Parent = FeedFrame
        
        local SendBtn = Instance.new("TextButton")
        SendBtn.Size = UDim2.new(0, 150, 0, 30)
        SendBtn.Position = UDim2.new(0, 10, 0, 80)
        SendBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        SendBtn.Text = "Send feedback"
        SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SendBtn.Parent = FeedFrame

        SendBtn.MouseButton1Click:Connect(function()
            local rawName = LocalPlayer.Name
            local censoredName = string.sub(rawName, 1, 2) .. string.rep("*", 3)
            
            local data = {
                ["embeds"] = {{
                    ["title"] = "Feedback de " .. censoredName,
                    ["description"] = "```\n" .. Input.Text .. "\n```",
                    ["color"] = 65280
                }}
            }
            
            local finalData = HttpService:JSONEncode(data)
            request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = finalData
            })
            Input.Text = ""
            SendBtn.Text = "Sent!"
            task.wait(2)
            SendBtn.Text = "Send feedback"
        end)
    end

    
--// COMPONENTE: BUTTON
function AreaObj:Button(name, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -10, 0, 40)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ButtonFrame.Parent = ItemList
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 8)
    BCorner.Parent = ButtonFrame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = "• " .. name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 16
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = ButtonFrame
    
    -- Padding para o texto não colar na borda
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 15)
    UIPadding.Parent = ButtonFrame

    Btn.MouseButton1Click:Connect(function()
        callback()
        -- Efeito visual rápido
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        task.wait(0.1)
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
end

--// COMPONENTE: TOGGLE
function AreaObj:Toggle(name, default, callback)
    local state = default or false
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleFrame.Parent = ItemList
    
    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = ToggleFrame

    local SwitchBg = Instance.new("Frame")
    SwitchBg.Size = UDim2.new(0, 45, 0, 22)
    SwitchBg.Position = UDim2.new(1, -55, 0.5, -11)
    SwitchBg.BackgroundColor3 = state and Color3.fromRGB(80, 40, 200) or Color3.fromRGB(60, 60, 60)
    SwitchBg.Parent = ToggleFrame
    
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(1, 0)
    SCorner.Parent = SwitchBg

    local Ball = Instance.new("Frame")
    Ball.Size = UDim2.new(0, 18, 0, 18)
    Ball.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Ball.BackgroundColor3 = Color3.fromRGB(160, 100, 255)
    Ball.Parent = SwitchBg
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(1, 0)
    BCorner.Parent = Ball

    local Clicker = Instance.new("TextButton")
    Clicker.Size = UDim2.new(1, 0, 1, 0)
    Clicker.Transparency = 1
    Clicker.Text = ""
    Clicker.Parent = ToggleFrame

    local function update()
        local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = state and Color3.fromRGB(80, 40, 200) or Color3.fromRGB(60, 60, 60)
        
        TweenService:Create(Ball, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        callback(state)
    end

    Clicker.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)
    
    Crate.Elements.Toggles[name] = function(val)
        state = (val == "on" or val == true)
        update()
    end
end
--// COMPONENTE: DROPDOWN
function AreaObj:Dropdown(name, list, callback)
    local expanded = false
    
    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1, -10, 0, 70)
    DropFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropFrame.ClipsDescendants = true
    DropFrame.Parent = ItemList
    
    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(0, 10)
    DCorner.Parent = DropFrame

    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = DropFrame

    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Text = name .. "2 (escolhido)"
    SelectedLabel.Size = UDim2.new(1, -20, 0, 30)
    SelectedLabel.Position = UDim2.new(0, 10, 0, 35)
    SelectedLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SelectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SelectedLabel.Font = Enum.Font.Gotham
    SelectedLabel.TextSize = 14
    SelectedLabel.Parent = DropFrame
    
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 6)
    SCorner.Parent = SelectedLabel

    local Arrow = Instance.new("TextLabel")
    Arrow.Text = ">"
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.Parent = SelectedLabel

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.Transparency = 1
    Btn.Text = ""
    Btn.Parent = SelectedLabel

    local OptionContainer = Instance.new("Frame")
    OptionContainer.Size = UDim2.new(1, -20, 0, 0)
    OptionContainer.Position = UDim2.new(0, 10, 0, 70)
    OptionContainer.BackgroundTransparency = 1
    OptionContainer.Parent = DropFrame
    
    local UIList = Instance.new("UIListLayout")
    UIList.Parent = OptionContainer
    UIList.Padding = UDim.new(0, 5)

    local function Refresh()
        for _, v in pairs(OptionContainer:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        
        for _, opt in pairs(list) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 30)
            OptBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            OptBtn.Text = opt
            OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.Parent = OptionContainer
            
            local OCorner = Instance.new("UICorner")
            OCorner.CornerRadius = UDim.new(0, 6)
            OCorner.Parent = OptBtn

            OptBtn.MouseButton1Click:Connect(function()
                SelectedLabel.Text = opt
                callback(opt)
                expanded = false
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 70)}):Play()
                Arrow.Text = ">"
            end)
        end
    end

    Btn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetSize = expanded and UDim2.new(1, -10, 0, 75 + UIList.AbsoluteContentSize.Y) or UDim2.new(1, -10, 0, 70)
        Arrow.Text = expanded and "^" or ">"
        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    end)

    Refresh()
    
    -- Funções globais de Dropdown
    Crate.Elements.Dropdowns[name] = {
        Add = function(val) table.insert(list, val); Refresh() end,
        Remove = function(val) 
            for i, v in pairs(list) do 
                if v == val then table.remove(list, i) end 
            end; Refresh() 
        end
    }
end
--// COMPONENTE: SLIDER
function AreaObj:Slider(name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 65)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SliderFrame.Parent = ItemList
    
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 10)
    SCorner.Parent = SliderFrame

    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Size = UDim2.new(1, -60, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Text = "{" .. tostring(default) .. "}"
    ValueLabel.Size = UDim2.new(0, 50, 0, 30)
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 45)
    SliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SliderBar.Parent = SliderFrame
    
    local SBCorner = Instance.new("UICorner")
    SBCorner.CornerRadius = UDim.new(1, 0)
    SBCorner.Parent = SliderBar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    Fill.Parent = SliderBar
    
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(1, 0)
    FCorner.Parent = Fill

    local Circle = Instance.new("ImageButton")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(110, 50, 250)
    Circle.Parent = SliderBar
    
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = Circle

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        ValueLabel.Text = "{" .. tostring(val) .. "}"
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Circle.Position = UDim2.new(pos, -8, 0.5, -8)
        callback(val)
    end

    Circle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)

    Crate.Elements.Sliders[name] = function(val)
        local pos = math.clamp((val - min) / (max - min), 0, 1)
        ValueLabel.Text = "{" .. tostring(val) .. "}"
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Circle.Position = UDim2.new(pos, -8, 0.5, -8)
        callback(val)
    end
end
--// COMPONENTE: TEXTBOX
function AreaObj:Textbox(name, placeholder, default, callback)
    local TextFrame = Instance.new("Frame")
    TextFrame.Size = UDim2.new(1, -10, 0, 45)
    TextFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TextFrame.Parent = ItemList
    
    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Size = UDim2.new(0.4, 0, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TextFrame

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(0.5, 0, 0, 25)
    Input.Position = UDim2.new(0.45, 0, 0.5, -12)
    Input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.PlaceholderText = "{" .. placeholder .. "}"
    Input.Text = default
    Input.Font = Enum.Font.Gotham
    Input.TextSize = 12
    Input.Parent = TextFrame
    
    local ICorner = Instance.new("UICorner")
    ICorner.CornerRadius = UDim.new(0, 6)
    ICorner.Parent = Input

    Input.FocusLost:Connect(function()
        callback(Input.Text)
    end)

    Crate.Elements.TextBoxes[name] = function(val)
        Input.Text = val
        callback(val)
    end
end
--// COMPONENTE: CODEBOX (WINDOW STYLE)
function AreaObj:CodeBox(name, default, placeholder, callback)
    local CodeFrame = Instance.new("Frame")
    CodeFrame.Size = UDim2.new(1, -10, 0, 180)
    CodeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CodeFrame.Parent = ItemList
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = CodeFrame

    -- Barra superior do CodeBox (igual a imagem da direita)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TopBar.Parent = CodeFrame
    
    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(0, 12)
    TBCorner.Parent = TopBar

    local DotContainer = Instance.new("Frame")
    DotContainer.Size = UDim2.new(0, 50, 1, 0)
    DotContainer.BackgroundTransparency = 1
    DotContainer.Parent = TopBar
    
    local DotList = Instance.new("UIListLayout")
    DotList.FillDirection = Enum.FillDirection.Horizontal
    DotList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    DotList.VerticalAlignment = Enum.VerticalAlignment.Center
    DotList.Padding = UDim.new(0, 5)
    DotList.Parent = DotContainer

    for _, color in pairs({Color3.fromRGB(255, 85, 85), Color3.fromRGB(255, 185, 85), Color3.fromRGB(85, 255, 85)}) do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.BackgroundColor3 = color
        dot.Parent = DotContainer
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    end

    local Label = Instance.new("TextLabel")
    Label.Text = name
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 60, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TopBar

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 1, -45)
    Box.Position = UDim2.new(0, 10, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Text = default
    Box.PlaceholderText = "{" .. placeholder .. "}"
    Box.MultiLine = true
    Box.ClearTextOnFocus = false
    Box.TextYAlignment = Enum.TextYAlignment.Top
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.Font = Enum.Font.Code
    Box.TextSize = 13
    Box.Parent = CodeFrame
    
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
    Instance.new("UIPadding", Box).PaddingLeft = UDim.new(0, 10)

    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)

    Crate.Elements.CodeBoxes[name] = function(val)
        Box.Text = val
        callback(val)
    end
end
--// COMPONENTE: COLORPICKER
function AreaObj:ColorPicker(name, callback)
    local PickerFrame = Instance.new("Frame")
    PickerFrame.Size = UDim2.new(1, -10, 0, 180)
    PickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    PickerFrame.Parent = ItemList
    
    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Size = UDim2.new(0, 100, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = PickerFrame

    -- Roda de Cores (Representação visual)
    local Wheel = Instance.new("ImageLabel")
    Wheel.Size = UDim2.new(0, 120, 0, 120)
    Wheel.Position = UDim2.new(0, 10, 0, 40)
    Wheel.Image = "rbxassetid://6020299385" -- Roda de cores padrão
    Wheel.BackgroundTransparency = 1
    Wheel.Parent = PickerFrame
    
    local PickerDot = Instance.new("Frame")
    PickerDot.Size = UDim2.new(0, 6, 0, 6)
    PickerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PickerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    PickerDot.Parent = Wheel
    Instance.new("UICorner", PickerDot).CornerRadius = UDim.new(1, 0)

    -- Display de Cor Atual
    local CurrColor = Instance.new("Frame")
    CurrColor.Size = UDim2.new(0, 60, 0, 15)
    CurrColor.Position = UDim2.new(1, -70, 0, 10)
    CurrColor.BackgroundColor3 = Color3.fromRGB(14, 255, 213)
    CurrColor.Parent = PickerFrame
    Instance.new("UICorner", CurrColor).CornerRadius = UDim.new(0, 4)

    -- Grid de Presets (Quadrados de cores à direita)
    local PresetGrid = Instance.new("Frame")
    PresetGrid.Size = UDim2.new(0, 60, 0, 120)
    PresetGrid.Position = UDim2.new(1, -70, 0, 40)
    PresetGrid.BackgroundTransparency = 1
    PresetGrid.Parent = PickerFrame
    
    local UIGrid = Instance.new("UIGridLayout")
    UIGrid.CellSize = UDim2.new(0, 25, 0, 25)
    UIGrid.Padding = UDim2.new(0, 5, 0, 5)
    UIGrid.Parent = PresetGrid

    local colors = {
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 150),
        Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 200, 100),
        Color3.fromRGB(100, 50, 255), Color3.fromRGB(255, 50, 50),
        Color3.fromRGB(80, 200, 255), Color3.fromRGB(150, 255, 50)
    }

    for _, color in pairs(colors) do
        local p = Instance.new("TextButton")
        p.Text = ""
        p.BackgroundColor3 = color
        p.Parent = PresetGrid
        Instance.new("UICorner", p).CornerRadius = UDim.new(0, 4)
        p.MouseButton1Click:Connect(function()
            CurrColor.BackgroundColor3 = color
            callback(color)
        end)
    end

    Crate.Elements.ColorPickers[name] = function(color)
        CurrColor.BackgroundColor3 = color
        callback(color)
    end
end


return AreaObj
end
-- Aliases para bater com o seu exemplo
Crate.area = Crate.CreateArea


--// FUNÇÕES GLOBAIS DE CONTROLO (MODIFICAR ELEMENTOS PELO NOME)
function Crate:TurnToggle(name, state)
    if Crate.Elements.Toggles[name] then Crate.Elements.Toggles[name](state) end
end

function Crate:TurnTextBox(name, text)
    if Crate.Elements.TextBoxes[name] then Crate.Elements.TextBoxes[name](text) end
end

function Crate:AddDropDown(name, option)
    if Crate.Elements.Dropdowns[name] then Crate.Elements.Dropdowns[name].Add(option) end
end

function Crate:RemoveDropDown(name, option)
    if Crate.Elements.Dropdowns[name] then Crate.Elements.Dropdowns[name].Remove(option) end
end

function Crate:SliderSetValue(name, val)
    if Crate.Elements.Sliders[name] then Crate.Elements.Sliders[name](val) end
end

function Crate:PikerSetColor(name, color)
    if Crate.Elements.ColorPickers[name] then Crate.Elements.ColorPickers[name](color) end
end

function Crate:TurnCodeBox(name, text)
    if Crate.Elements.CodeBoxes[name] then Crate.Elements.CodeBoxes[name](text) end
end

--// ENCERRAMENTO DA LIB
return Crate
