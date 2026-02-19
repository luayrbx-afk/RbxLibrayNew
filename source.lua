local Crate = {}
Crate.__index = Crate

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- armazenamento global
Crate.Elements = {}
Crate.CurrentColor = Color3.fromRGB(25,25,25)

-- =========================
-- WINDOW
-- =========================

function Crate.windows(name)
    local self = setmetatable({}, Crate)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "$classicle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0,500,0,400)
    Main.Position = UDim2.new(0.5,-250,0.5,-200)
    Main.BackgroundColor3 = Crate.CurrentColor
    Main.BackgroundTransparency = 0.25
    Main.Parent = ScreenGui
    Main.Name = "Main"

    local UICorner = Instance.new("UICorner", Main)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1,0,0,40)
    TopBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    TopBar.BackgroundTransparency = 0.5
    TopBar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,1,0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Parent = TopBar

    -- Minimizar bolinha
    local Bubble = Instance.new("ImageButton")
    Bubble.Size = UDim2.new(0,40,0,40)
    Bubble.Position = UDim2.new(0,10,1,10)
    Bubble.Visible = false
    Bubble.BackgroundColor3 = Crate.CurrentColor
    Bubble.Parent = ScreenGui
    Instance.new("UICorner", Bubble)

    Bubble.MouseButton1Click:Connect(function()
        Main.Visible = true
        Bubble.Visible = false
    end)

    -- arrastar
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragStart = input.Position
            local startPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then return end
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end)
        end
    end)

    self.Gui = ScreenGui
    self.Main = Main
    self.Bubble = Bubble

    return self
end

-- =========================
-- CONFIG
-- =========================

function Crate:GuiSize(size)
    self.Main.Size = size
end

function Crate:GuiColor(rgb)
    Crate.CurrentColor = rgb
    self.Main.BackgroundColor3 = rgb
    if self.Bubble then
        self.Bubble.BackgroundColor3 = rgb
    end
end

function Crate:Keyboard(key)
    UIS.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode == key then
            self.Main.Visible = not self.Main.Visible
        end
    end)
end

function Crate:MinimizeKey(key)
    UIS.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode == key then
            self.Main.Visible = false
            self.Bubble.Visible = true
        end
    end)
end

function Crate:M(image,size)
    self.Bubble.Image = "rbxassetid://"..image
end

-- =========================
-- AREA
-- =========================

function Crate:Create()
    local Area = {}

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1,0,1,-40)
    Container.Position = UDim2.new(0,0,0,40)
    Container.BackgroundTransparency = 1
    Container.Parent = self.Main

    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0,6)

    -- =========================
    -- COMPONENTES
    -- =========================

    function Area:Button(title,callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1,-20,0,35)
        Btn.Text = title
        Btn.Parent = Container
        Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        Btn.TextColor3 = Color3.new(1,1,1)

        Btn.MouseButton1Click:Connect(function()
            callback()
        end)
    end

    function Area:Toggle(title,default,callback)
        local state = default

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1,-20,0,35)
        Btn.Text = title.." : "..(state and "ON" or "OFF")
        Btn.Parent = Container
        Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        Btn.TextColor3 = Color3.new(1,1,1)

        Crate.Elements[title] = Btn

        Btn.MouseButton1Click:Connect(function()
            state = not state
            Btn.Text = title.." : "..(state and "ON" or "OFF")
            callback(state)
        end)
    end

    function Area:Textbox(title,placeholder,text,callback)
        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1,-20,0,35)
        Box.PlaceholderText = placeholder
        Box.Text = text or ""
        Box.Parent = Container
        Box.BackgroundColor3 = Color3.fromRGB(35,35,35)
        Box.TextColor3 = Color3.new(1,1,1)

        Crate.Elements[title] = Box

        Box.FocusLost:Connect(function()
            callback(Box.Text)
        end)
    end

    function Area:Slider(title,min,max,default,callback)
        local value = default

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1,-20,0,35)
        Btn.Text = title.." : "..value
        Btn.Parent = Container
        Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        Btn.TextColor3 = Color3.new(1,1,1)

        Crate.Elements[title] = Btn

        Btn.MouseButton1Click:Connect(function()
            value = math.clamp(value + 1, min, max)
            Btn.Text = title.." : "..value
            callback(value)
        end)
    end

    function Area:Discord(link)
        self:Button("Join Discord", function()
            if setclipboard then
                setclipboard(link)
            end
        end)
    end

    function Area:Feedback(webhook)
        self:Textbox("Feedback","Digite aqui","",function(text)
            local name = LocalPlayer.Name
            local censored = string.sub(name,1,2).."***"

            local data = {
                embeds = {{
                    title = "Feedback de "..censored,
                    description = "```"..text.."```"
                }}
            }

            local json = HttpService:JSONEncode(data)

            if syn and syn.request then
                syn.request({
                    Url = webhook,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = json
                })
            end
        end)
    end

    return Area
end

-- =========================
-- FUNÇÕES GLOBAIS
-- =========================

function Crate:TurnToggle(name,state)
    local el = Crate.Elements[name]
    if el then
        el.Text = name.." : "..(state=="on" and "ON" or "OFF")
    end
end

function Crate:TurnTextBox(name,text)
    local el = Crate.Elements[name]
    if el then
        el.Text = text
    end
end

function Crate:SliderSetValue(name,value)
    local el = Crate.Elements[name]
    if el then
        el.Text = name.." : "..value
    end
end

return Crate
