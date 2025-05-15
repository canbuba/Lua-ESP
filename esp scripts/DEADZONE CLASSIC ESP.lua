-- I publish the esp scripts I made for specific games in roblox for free, you can use the scripts in your own projects, but I would be very happy if you give credit.
-- i made this script is specially made for deadzone classic game, i tried this script in other games and it works, you can use it in games other than deadzone.
-- github = @canbuba https://github.com/canbuba/Lua-ESP / discord = Brombeere8355

setfflag("AbuseReportScreenshot", "False") -- this bypass for roblox's player report
setfflag("AbuseReportScreenshotPercentage", "0")

local Players = game:GetService("Players") 
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local zombiesFolder = workspace:FindFirstChild("__zombies") -- i define the zombie folder that will not be checked
local maxDistance = 3000 -- if you change this your max distance will change

-- for storing esp drawings
local espObjects = {}

-- 2d esp fonction create
local function createESP(playerName, part)
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

	espObjects[part] = {Box = box, Text = text, PlayerName = playerName}
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
				drawings.Text.Text = math.floor(distance) .. " studs"
				drawings.Text.Position = Vector2.new(rootPos.X, rootPos.Y - size / 2 - 14)
			else
				drawings.Box.Visible = false
				drawings.Text.Visible = false
			end
		end
	end
end

-- humanoidrootpart scan in workspace (this players some part)
local function scanForHumanoidParts()
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and not (zombiesFolder and zombiesFolder:FindFirstChild(obj.Name)) then
			local function tryRegister(model)
				local hrp = model:FindFirstChild("HumanoidRootPart")
				if hrp and not espObjects[hrp] then
					createESP(model.Name, hrp)
				end
			end

			tryRegister(obj)

			if obj.Name == "Model" then
				for _, sub in ipairs(obj:GetChildren()) do
					if sub:IsA("Model") then
						tryRegister(sub)
					end
				end
			end
		end
	end
end

-- update esp every frame
RunService.RenderStepped:Connect(function()
	updateESP()
end)

-- scan at startup
scanForHumanoidParts()

-- rescan every update in workspace
workspace.ChildAdded:Connect(function(child)
	task.wait(1)
	scanForHumanoidParts()
end)

if workspace:FindFirstChild("Model") then
	workspace.Model.ChildAdded:Connect(function(child)
		task.wait(1)
		scanForHumanoidParts()
	end)
end
