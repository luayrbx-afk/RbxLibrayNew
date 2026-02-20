--[[ 
    LUAY UI LIBRARY - MODULAR & PROFESSIONAL
    Foco: Mobile/PC, Performance, Feedback Visual, Auto-Save
]]

local LUAY = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Configurações de Tema (Dark Moderno)
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Secondary = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(230, 230, 230),
    DarkText = Color3.fromRGB(150, 150, 150),
    Border = Color3.fromRGB(40, 40, 40),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- Funções Utilitárias
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Sistema de Salvamento (Pasta "sabes")
local function EnsureFolder(path)
    if isfolder and not isfolder(path) then
        makefolder(path)
    end
end

local function SaveToFile(scriptName, type, id, value)
    if not writefile then return end
    local root = "sabes"
    local scriptFolder = root .. "/Saves" .. scriptName
    EnsureFolder(root)
    EnsureFolder(scriptFolder)
    EnsureFolder(scriptFolder .. "/UIsaves")
    EnsureFolder(scriptFolder .. "/ScriptSaves")
    
    local path = scriptFolder .. (type == "UI" and "/UIsaves/" or "/ScriptSaves/") .. id .. ".json"
    writefile(path, HttpService:JSONEncode({val = value}))
end

local function LoadFromFile(scriptName, type, id)
    if not readfile then return nil end
    local path = "sabes/Saves" .. scriptName .. (type == "UI" and "/UIsaves/" or "/ScriptSaves/") .. id .. ".json"
    if isfile and isfile(path) then
        local data = HttpService:JSONDecode(readfile(path))
        return data.val
    end
    return nil
end

-- Engine Principal da UI
function LUAY:windows(title, subtitle)
    local scriptName = title or "LUAY_Script"
    local GUI = Instance.new("ScreenGui")
    GUI.Name = "LUAY_" .. HttpService:GenerateGUID(false)
    GUI.Parent = CoreGui
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Frame Principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = GUI

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Thickness = 1.2
    Stroke.Parent = MainFrame

    -- Sidebar (Menu lateral)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Secondary
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar

    -- Header Info
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundTransparency = 1
    Header.Parent = Sidebar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = "." .. (title or "exemple")
    TitleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 10)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = Theme.Accent
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Text = subtitle or "exemple2"
    SubLabel.Size = UDim2.new(1, 0, 0.5, 0)
    SubLabel.Position = UDim2.new(0, 15, 0.5, 0)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 14
    SubLabel.TextColor3 = Theme.DarkText
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = Header

    -- Container de Abas
    local TabButtonList = Instance.new("ScrollingFrame")
    TabButtonList.Size = UDim2.new(1, 0, 1, -120)
    TabButtonList.Position = UDim2.new(0, 0, 0, 70)
    TabButtonList.BackgroundTransparency = 1
    TabButtonList.ScrollBarThickness = 0
    TabButtonList.Parent = Sidebar

    local TabUIList = Instance.new("UIListLayout")
    TabUIList.Padding = UDim.new(0, 5)
    TabUIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabUIList.Parent = TabButtonList

    -- Área de Conteúdo
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -160, 1, -20)
    Container.Position = UDim2.new(0, 155, 0, 10)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local Pages = Instance.new("Folder")
    Pages.Name = "Pages"
    Pages.Parent = Container

    -- Botão Fechar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "X"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Theme.DarkText
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = MainFrame
    CloseBtn.MouseButton1Click:Connect(function()
        GUI:Destroy()
    end)

    MakeDraggable(MainFrame)

    local Window = {
        CurrentPage = nil,
        ScriptID = scriptName
    }

    -- Métodos da Janela
    function Window:MobileSize(x, y)
        if UserInputService.TouchEnabled then
            MainFrame.Size = UDim2.new(0, x, 0, y)
        end
    end

    function Window:PcSize(x, y)
        if not UserInputService.TouchEnabled then
            MainFrame.Size = UDim2.new(0, x, 0, y)
        end
    end

    function Window:BgTs(ts)
        MainFrame.BackgroundTransparency = ts
        Sidebar.BackgroundTransparency = ts
    end

    function Window:Aarea(id, name, image)
        local Page = Instance.new("ScrollingFrame")
        Page.Name = id
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Parent = Pages

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 8)
        PageList.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingLeft = UDim.new(0, 5)
        PagePadding.PaddingRight = UDim.new(0, 5)
        PagePadding.Parent = Page

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        TabBtn.BackgroundColor3 = Theme.Background
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = Theme.DarkText
        TabBtn.Parent = TabButtonList

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages:GetChildren()) do p.Visible = false end
            for _, b in pairs(TabButtonList:GetChildren()) do 
                if b:IsA("TextButton") then
                    TweenService:Create(b, TweenInfo.new(0.3), {TextColor3 = Theme.DarkText}):Play()
                end
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Theme.Accent}):Play()
        end)

        if not Window.CurrentPage then
            Page.Visible = true
            Window.CurrentPage = Page
            TabBtn.TextColor3 = Theme.Accent
        end

        local Elements = {}

        -- Componentes Dinâmicos
        function Elements:button(name, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundColor3 = Theme.Secondary
            Btn.Text = name
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 14
            Btn.Parent = Page

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Btn

            Btn.MouseButton1Click:Connect(function()
                callback()
                local originalSize = Btn.Size
                Btn.Size = UDim2.new(1, -4, 0, 31)
                task.wait(0.05)
                Btn.Size = originalSize
            end)
        end

        function Elements:toggle(id, name, callback)
            local TglFrame = Instance.new("Frame")
            TglFrame.Size = UDim2.new(1, 0, 0, 35)
            TglFrame.BackgroundColor3 = Theme.Secondary
            TglFrame.Parent = Page

            Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
            TglFrame.UICorner.Parent = TglFrame

            local TglLabel = Instance.new("TextLabel")
            TglLabel.Text = name
            TglLabel.Size = UDim2.new(1, -50, 1, 0)
            TglLabel.Position = UDim2.new(0, 10, 0, 0)
            TglLabel.BackgroundTransparency = 1
            TglLabel.TextColor3 = Theme.Text
            TglLabel.Font = Enum.Font.Gotham
            TglLabel.TextSize = 14
            TglLabel.TextXAlignment = Enum.TextXAlignment.Left
            TglLabel.Parent = TglFrame

            local TglBtn = Instance.new("TextButton")
            TglBtn.Size = UDim2.new(0, 40, 0, 20)
            TglBtn.Position = UDim2.new(1, -50, 0.5, -10)
            TglBtn.BackgroundColor3 = Theme.Background
            TglBtn.Text = ""
            TglBtn.Parent = TglFrame

            Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
            TglBtn.UICorner.Parent = TglBtn

            local TglCircle = Instance.new("Frame")
            TglCircle.Size = UDim2.new(0, 16, 0, 16)
            TglCircle.Position = UDim2.new(0, 2, 0.5, -8)
            TglCircle.BackgroundColor3 = Theme.DarkText
            TglCircle.Parent = TglBtn

            Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
            TglCircle.UICorner.Parent = TglCircle

            local Toggled = LoadFromFile(Window.ScriptID, "UI", id) or false
            local function Update()
                if Toggled then
                    TweenService:Create(TglCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Accent}):Play()
                else
                    TweenService:Create(TglCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.DarkText}):Play()
                end
                SaveToFile(Window.ScriptID, "UI", id, Toggled)
                callback(Toggled)
            end

            TglBtn.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Update()
            end)
            task.spawn(Update)
        end

        function Elements:textbox(id, name, text, placeholder, callback)
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Size = UDim2.new(1, 0, 0, 55)
            BoxFrame.BackgroundColor3 = Theme.Secondary
            BoxFrame.Parent = Page

            Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
            BoxFrame.UICorner.Parent = BoxFrame

            local Label = Instance.new("TextLabel")
            Label.Text = name
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Theme.DarkText
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BoxFrame

            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(1, -20, 0, 25)
            Input.Position = UDim2.new(0, 10, 0, 25)
            Input.BackgroundColor3 = Theme.Background
            Input.Text = LoadFromFile(Window.ScriptID, "UI", id) or text
            Input.PlaceholderText = placeholder
            Input.TextColor3 = Theme.Text
            Input.Font = Enum.Font.Gotham
            Input.TextSize = 13
            Input.Parent = BoxFrame

            Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
            Input.UICorner.Parent = Input

            Input.FocusLost:Connect(function()
                SaveToFile(Window.ScriptID, "UI", id, Input.Text)
                callback(Input.Text)
            end)
        end

        function Elements:slider(id, name, min, max, default, callback)
            local SldFrame = Instance.new("Frame")
            SldFrame.Size = UDim2.new(1, 0, 0, 45)
            SldFrame.BackgroundColor3 = Theme.Secondary
            SldFrame.Parent = Page

            Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
            SldFrame.UICorner.Parent = SldFrame

            local Label = Instance.new("TextLabel")
            Label.Text = name
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SldFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextColor3 = Theme.Accent
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SldFrame

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -20, 0, 4)
            Bar.Position = UDim2.new(0, 10, 0, 32)
            Bar.BackgroundColor3 = Theme.Background
            Bar.Parent = SldFrame

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = Theme.Accent
            Fill.Parent = Bar

            local function Move(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                ValueLabel.Text = tostring(val)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                callback(val)
                SaveToFile(Window.ScriptID, "UI", id, val)
            end

            local dragging = false
            SldFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Move(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Move(input)
                end
            end)

            local saved = LoadFromFile(Window.ScriptID, "UI", id) or default
            local startPos = (saved - min) / (max - min)
            Fill.Size = UDim2.new(startPos, 0, 1, 0)
            ValueLabel.Text = tostring(saved)
        end

        function Elements:logBox(id, name)
            local LgFrame = Instance.new("Frame")
            LgFrame.Size = UDim2.new(1, 0, 0, 150)
            LgFrame.BackgroundColor3 = Theme.Secondary
            LgFrame.Parent = Page

            Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
            LgFrame.UICorner.Parent = LgFrame

            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Size = UDim2.new(1, -10, 1, -40)
            Scroll.Position = UDim2.new(0, 5, 0, 10)
            Scroll.BackgroundColor3 = Theme.Background
            Scroll.ScrollBarThickness = 1
            Scroll.Parent = LgFrame

            local LgList = Instance.new("UIListLayout")
            LgList.Parent = Scroll

            local function addLog(txt, color)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, 0, 0, 18)
                l.BackgroundTransparency = 1
                l.Text = "$> " .. txt
                l.TextColor3 = color or Theme.Text
                l.Font = Enum.Font.Code
                l.TextSize = 11
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.Parent = Scroll
                Scroll.CanvasPosition = Vector2.new(0, 9999)
            end

            addLog("LUAY Loaded successfully", Color3.fromRGB(0, 255, 0))
            return {log = addLog}
        end

        function Elements:infoBox(id)
            local Info = Instance.new("Frame")
            Info.Size = UDim2.new(1, 0, 0, 80)
            Info.BackgroundColor3 = Theme.Secondary
            Info.Parent = Page

            Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
            Info.UICorner.Parent = Info

            local Content = Instance.new("TextLabel")
            Content.Size = UDim2.new(1, -20, 1, -20)
            Content.Position = UDim2.new(0, 10, 0, 10)
            Content.BackgroundTransparency = 1
            Content.TextColor3 = Theme.Text
            Content.Font = Enum.Font.Code
            Content.TextSize = 12
            Content.TextXAlignment = Enum.TextXAlignment.Left
            Content.Parent = Info

            RunService.RenderStepped:Connect(function()
                local fps = math.floor(1 / RunService.RenderStepped:Wait())
                local device = UserInputService.TouchEnabled and "mobile" or "pc"
                Content.Text = string.format("info\n\nFps: %dMs\nType: %s\nUiSaves: %d", fps, device, 0)
            end)
        end

        return Elements
    end

    function Window:Credits(image, discord, desc)
    local CreditsPage = Window:Area("credits", "Credits", "")

    local Img = Instance.new("ImageLabel")
    Img.Size = UDim2.new(0, 60, 0, 60)
    Img.BackgroundColor3 = Theme.Secondary
    Img.Image = image or ""
    Img.Parent = Pages.credits
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
    Img.UICorner.Parent = Img

    local D = Instance.new("TextLabel")
    D.Text = "Discord: " .. discord
    D.Size = UDim2.new(1, 0, 0, 20)
    D.BackgroundTransparency = 1
    D.TextColor3 = Theme.Accent
    D.Font = Enum.Font.GothamBold
    D.Parent = Pages.credits

    local Desc = Instance.new("TextLabel")
    Desc.Text = desc
    Desc.Size = UDim2.new(1, 0, 0, 60)
    Desc.BackgroundTransparency = 1
    Desc.TextColor3 = Theme.DarkText
    Desc.TextWrapped = true
    Desc.Parent = Pages.credits
  end

  return Window
end

return LUAY
