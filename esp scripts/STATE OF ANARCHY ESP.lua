-- I publish the esp scripts I made for specific games in roblox for free, you can use the scripts in your own projects, but I would be very happy if you give credit.
-- i made this script is specially made for state of anarchy game, finding the humanoidrootpart in players folder in workspace and drawing 2d esp on it,
-- i would not recommend you to use it in other games, it probably won't work, but you can use the esp i wrote for deadzone its work almost all games and available on my github page
-- github = @canbuba https://github.com/canbuba/Lua-ESP

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local maxDistance = 3000 -- if you change this your max distance will change
local espObjects = {} -- for storing esp drawings

-- 2d esp fonction create
local function createESP(modelName, part)
	local box = Drawing.new("Square")
	box.Color = Color3.fromRGB(255, 0, 0)
	box.Thickness = 1
	box.Transparency = 1
	box.Filled = false

	local text = Drawing.new("Text")
	text.Size = 14
	text.Center = true
	text.Outline = true
	text.Color = Color3.fromRGB(255, 0, 0)

	espObjects[part] = {Box = box, Text = text, ModelName = modelName}
end

-- update esp
local function updateESP()
	for part, drawings in pairs(espObjects) do
		if part.Parent == nil or not part:IsDescendantOf(workspace) then
			drawings.Box:Remove()
			drawings.Text:Remove()
			espObjects[part] = nil
		else
			local rootPos, onScreen = camera:WorldToViewportPoint(part.Position)
			local distance = (camera.CFrame.Position - part.Position).Magnitude

			if onScreen and distance < maxDistance then
				local size = math.clamp(2000 / distance, 2, 25)

				drawings.Box.Visible = true
				drawings.Box.Size = Vector2.new(size, size)
				drawings.Box.Position = Vector2.new(rootPos.X - size / 2, rootPos.Y - size / 2)

				drawings.Text.Visible = true
				drawings.Text.Text = drawings.ModelName .. " (" .. math.floor(distance) .. " studs)"
				drawings.Text.Position = Vector2.new(rootPos.X, rootPos.Y - size / 2 - 14)
			else
				drawings.Box.Visible = false
				drawings.Text.Visible = false
			end
		end
	end
end

-- humanoidrootpart scan in workspace (this players some part)
local function scanWorkspacePlayers()
	local playersFolder = workspace:FindFirstChild("Players")
	if not playersFolder then return end

	for _, model in ipairs(playersFolder:GetChildren()) do
		if model:IsA("Model") then
			local hrp = model:FindFirstChild("HumanoidRootPart")
			if hrp and not espObjects[hrp] then
				createESP(model.Name, hrp)
			end
		end
	end
end

-- update esp every frame
RunService.RenderStepped:Connect(updateESP)

-- scan at startup
scanWorkspacePlayers()

-- rescan every update in workspace
local playersFolder = workspace:FindFirstChild("Players")
if playersFolder then
	playersFolder.ChildAdded:Connect(function()
		task.wait(1)
		scanWorkspacePlayers()
	end)
end
