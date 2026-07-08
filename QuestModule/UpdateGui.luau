local RS = game:GetService("ReplicatedStorage")
local questGuiEvent = RS:WaitForChild("Remotes"):WaitForChild("UpdateQuestGui")
local questDataFunction = RS:WaitForChild("Remotes"):WaitForChild("questDataFunction")
local player = game.Players.LocalPlayer

--\\ Gui Variables // --
local gui = player.PlayerGui:WaitForChild("QuestGui")
local questsFrame = gui:WaitForChild("QuestsFrame")
local questTemplate = gui:WaitForChild("QuestTemplate"):WaitForChild("QuestTemplate")
local scrollingFrame = questsFrame:WaitForChild("ScrollingFrame")

local function drawPlayerGui(packet)
	for _, frame in pairs(scrollingFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	if packet.Status == "Completed" then return end

	local newQuestFrame = questTemplate:Clone()
	newQuestFrame.Name = packet.Name
	newQuestFrame.Parent = scrollingFrame
	newQuestFrame.Description.Text = packet.Description
	newQuestFrame.Completion.Text = tostring(packet.CurrentProgress .. "/" .. packet.CompletionAmount)
	if packet.Status == "Ready" then
		newQuestFrame.Completion.Text = "Completed"
		newQuestFrame.Completion.TextColor3 = Color3.new(0.32929, 1, 0.18909)
	end
	newQuestFrame.Visible = true
end


local initialPacket = questDataFunction:InvokeServer()

if initialPacket then
	drawPlayerGui(initialPacket)
end

questGuiEvent.OnClientEvent:Connect(function(packet)
	drawPlayerGui(packet)
end)
