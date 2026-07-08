local RS = game:GetService("ReplicatedStorage")
local DS = game:GetService("DataStoreService")
local questGuiEvent = RS:WaitForChild("Remotes"):WaitForChild("UpdateQuestGui")
local questDataFunction = RS:WaitForChild("Remotes"):WaitForChild("questDataFunction")


local QuestDataStore = DS:GetDataStore("QuestDataStore")


local QuestModule = {}

local QuestStatus = {
	Active = "Active",
	Ready = "Ready",
	Completed = "Completed"
}

QuestModule.Quests = {
	[1] = {
		Name = "Collect Apples I",
		Description = "Collect 5 Apples",
		CompletionAmount = 5,
		RequiredQuest = 0
	},
	[2] = {
		Name = "Collect Apples II",
		Description = "Collect 10 Apples",
		CompletionAmount = 10,
		RequiredQuest = 1 
	}
}

QuestModule.PlayerData = {}

function QuestModule.InitializePlayer(player : Player)
	local key = "Player_"..player.UserId
	local packet
	
	local success, err = pcall(function()
		packet = QuestDataStore:GetAsync(key)
	end)
	
	if not success then
		local tries = 0
		while not success do
			if tries < 3 then
				success, err = pcall(function()
					packet = QuestDataStore:GetAsync(key)
				end)
				tries += 1
			else
				warn("Couldn't fetch player data after 3 attempts: " .. tostring(err))
				break
			end	
		end
	end
	
	
	if not packet then
		QuestModule.PlayerData[player.UserId] = {
			CurrentQuest = 0,
			CurrentProgress = 0,
			CompletedQuests = {},
			Status = QuestStatus.Completed
		}
	else
		local status
		local currentQuestId = packet.CurrentQuest
		
		if currentQuestId == 0 then
			packet.Status = QuestStatus.Completed
		else
			local questConfig = QuestModule.Quests[currentQuestId]
			
			if packet.CurrentProgress >= questConfig.CompletionAmount then
				packet.Status = QuestStatus.Ready
			else
				packet.Status = QuestStatus.Active
			end
		end	
		QuestModule.PlayerData[player.UserId] = packet
	end
end

function QuestModule.RemovePlayer(player : Player)
	local plrData = QuestModule.PrepareData(player)
	
	local key = "Player_"..player.UserId
	
	local success, err = pcall(function()
		QuestDataStore:SetAsync(key, plrData)
	end)
	
	if not success then
		local tries = 0
		
		while not success do
			if tries < 3 then
				success, err = pcall(function()
					QuestDataStore:SetAsync(key, plrData)
				end)
				tries += 1
			else
				warn("Failed to save data after 3 attempts: " .. tostring(err))
				break
			end
		end
	end
	
	
	QuestModule.PlayerData[player.UserId] = nil
end

function QuestModule.AssignQuest(player : Player, questId : number)
	local plrData = QuestModule.PlayerData[player.UserId]
	local reqQuest = QuestModule.Quests[questId].RequiredQuest
	local currQuest = plrData.CurrentQuest
	local completedQuests = plrData.CompletedQuests
	if currQuest == 0 and (completedQuests[reqQuest] == true or reqQuest == 0) and not completedQuests[questId] then
		plrData.CurrentQuest = questId
		plrData.Status = QuestStatus.Active

		local packet = {
			Name = QuestModule.Quests[questId].Name,
			Description = QuestModule.Quests[questId].Description,
			CurrentProgress = 0,
			CompletionAmount = QuestModule.Quests[questId].CompletionAmount,
			Status = QuestStatus.Active
		}

		questGuiEvent:FireClient(player, packet)
	end
end

function QuestModule.UpdateProgress(player : Player, amount : number)
	local plrData = QuestModule.PlayerData[player.UserId]
	
	if not plrData or plrData.CurrentQuest <= 0 then return end
	
	local currQuest = plrData.CurrentQuest
	
	plrData.CurrentProgress += amount
	
	if plrData.CurrentProgress > QuestModule.Quests[currQuest].CompletionAmount then
		plrData.CurrentProgress = QuestModule.Quests[currQuest].CompletionAmount
	end
	
	
	if plrData.CurrentProgress >= QuestModule.Quests[currQuest].CompletionAmount then
		plrData.Status = QuestStatus.Ready
	end
	
	local packet = {
		Name = QuestModule.Quests[currQuest].Name,
		Description = QuestModule.Quests[currQuest].Description,
		CurrentProgress = plrData.CurrentProgress,
		CompletionAmount = QuestModule.Quests[currQuest].CompletionAmount,
		Status = plrData.Status
	}
	
	print(plrData.Status)
	
	questGuiEvent:FireClient(player, packet)
end

function QuestModule.CompleteQuest(player : Player)
	local plrData = QuestModule.PlayerData[player.UserId]
	if not plrData then return end
	
	local currQuest = plrData.CurrentQuest
	
	if currQuest == 0 then return end
	
	plrData.CompletedQuests[currQuest] = true
	plrData.CurrentQuest = 0
	plrData.CurrentProgress = 0
	plrData.Status = QuestStatus.Completed
	
	print("Status")
	print(plrData.Status)	
	
	local packet = {
		Name = QuestModule.Quests[currQuest].Name,
		Description = QuestModule.Quests[currQuest].Description,
		CurrentProgress = 0,
		CompletionAmount = QuestModule.Quests[currQuest].CompletionAmount,
		Status = plrData.Status
	}
	
	questGuiEvent:FireClient(player, packet)
end

function QuestModule.PrepareData(player : Player)
	local plrData = QuestModule.PlayerData[player.UserId]
	local packet = {
		CurrentQuest = plrData.CurrentQuest,
		CurrentProgress = plrData.CurrentProgress,
		CompletedQuests = plrData.CompletedQuests
	}
	
	return packet
end

function QuestModule.WipeData(player : Player)
	if player.UserId ~= 110929109 then return end
	QuestModule.PlayerData[player.UserId] = nil
	local packet = {
		CurrentQuest = 0,
		CurrentProgress = 0,
		CompletedQuests = {},
		Status = QuestStatus.Completed
	}
	QuestDataStore:SetAsync("Player_"..player.UserId, packet)
	print("Wiped data")
end

questDataFunction.OnServerInvoke = function(player : Player)
	local plrData = QuestModule.PlayerData[player.UserId]
	local currQuest = QuestModule.Quests[plrData.CurrentQuest]
	
	if currQuest == 0 then return nil end
	
	if plrData then
		local packet = {
			Name = currQuest.Name,
			Description = currQuest.Description,
			CurrentProgress = plrData.CurrentProgress,
			CompletionAmount = currQuest.CompletionAmount
		}
		
		if plrData.CurrentProgress >= currQuest.CompletionAmount then
			packet.Status = QuestStatus.Ready
		else
			packet.Status = QuestStatus.Active
		end
		
		return packet
	else
		return nil
	end
end

return QuestModule
