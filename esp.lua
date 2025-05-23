loadstring([[
-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Configuração do ESP
local Config = {
    Ativado = true,
    Caixa = true,
    Nome = true,
    Distancia = true,
    TeamCheck = true
}

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ESP_GUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.02, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ESP Controller"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local container = Instance.new("Frame", frame)
container.Position = UDim2.new(0, 0, 0, 35)
container.Size = UDim2.new(1, 0, 1, -35)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function createToggle(name, var)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.Text = name .. ": " .. (Config[var] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        Config[var] = not Config[var]
        btn.Text = name .. ": " .. (Config[var] and "ON" or "OFF")
    end)
end

createToggle("ESP", "Ativado")
createToggle("Caixa", "Caixa")
createToggle("Nome", "Nome")
createToggle("Distância", "Distancia")
createToggle("TeamCheck", "TeamCheck")

-- Função para criar a BillboardGui para cada jogador
local function criarBillboard(plr)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPBillboard"
    billboard.Adornee = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 120, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.ZIndex = 2
    Instance.new("UICorner", frame)

    local box = Instance.new("Frame", frame)
    box.Size = UDim2.new(1, -10, 1, -10)
    box.Position = UDim2.new(0, 5, 0, 5)
    box.BorderColor3 = Color3.fromRGB(255, 255, 255)
    box.BackgroundTransparency = 1
    box.ZIndex = 3
    box.BorderMode = Enum.BorderMode.Outline

    local nameLabel = Instance.new("TextLabel", frame)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.ZIndex = 3
    nameLabel.Text = plr.Name

    local distLabel = Instance.new("TextLabel", frame)
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.ZIndex = 3
    distLabel.Text = ""

    return billboard, nameLabel, distLabel, box
end

-- Tabela para armazenar as Billboards de cada jogador
local billboards = {}

-- Atualização do ESP
RunService.Heartbeat:Connect(function()
    if not Config.Ativado then
        for plr,billboardData in pairs(billboards) do
            if billboardData.Billboard then
                billboardData.Billboard.Enabled = false
            end
        end
        return
    end

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if Config.TeamCheck and plr.Team == LP.Team then
                -- Esconde ESP para aliados
                if billboards[plr] and billboards[plr].Billboard then
                    billboards[plr].Billboard.Enabled = false
                end
            else
                if not billboards[plr] then
                    local b, nameLbl, distLbl, box = criarBillboard(plr)
                    b.Parent = plr.Character.HumanoidRootPart
                    billboards[plr] = {
                        Billboard = b,
                        NameLabel = nameLbl,
                        DistLabel = distLbl,
                        Box = box
                    }
                end

                local data = billboards[plr]
                data.Billboard.Enabled = Config.Ativado
                data.NameLabel.Visible = Config.Nome
                data.DistLabel.Visible = Config.Distancia
                data.Box.BorderColor3 = Color3.fromRGB(255,255,255)
                data.Box.Visible = Config.Caixa

                -- Atualizar nome e distância
                data.NameLabel.Text = plr.Name
                local dist = math.floor((LP.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
                data.DistLabel.Text = dist .. "m"
            end
        else
            if billboards[plr] and billboards[plr].Billboard then
                billboards[plr].Billboard.Enabled = false
            end
        end
    end
end)
]])()
