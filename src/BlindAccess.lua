local _ENV = rom and rom.game or _ENV
local mod = ... or BlindAccess
if not mod.Config.Enabled then return end

--[[
Mod: DoorMenu
Author: hllf & JLove
Version: 29

Intended as an accessibility mod. Places all doors in a menu, allowing the player to select a door and be teleported to it.
Use the mod importer to import this mod.
--]]

local function setupData()
	ModUtil.Table.Merge(ScreenData, {
		BlindAccessibilityRewardMenu = {
			Components = {},
			Name = "BlindAccessibilityRewardMenu"
		},
		BlindAccesibilityDoorMenu = {
			Components = {},
			Name = "BlindAccesibilityDoorMenu"
		},
		BlindAccesibilityStoreMenu = {
			Components = {},
			Name = "BlindAccesibilityStoreMenu"
		},
		BlindAccesibilityInventoryMenu = {
			Components = {},
			Name = "BlindAccesibilityInventoryMenu"
		}
	})
end

OnControlPressed { "Inventory", function(triggerArgs)
	if TableLength(MapState.OfferedExitDoors) == 0 and mod.GetMapName() ~= "Hub_Main" then
		return
	elseif TableLength(MapState.OfferedExitDoors) == 1 and string.find(mod.GetMapName(), "D_Hub") then
		finalBossDoor = CollapseTable(MapState.OfferedExitDoors)[1]
		if finalBossDoor.Room.Name:find("D_Boss", 1, true) == 1 and GetDistance({ Id = 547487, DestinationId = 551569 }) ~= 0 then
			return
		end
	end
	if CurrentRun.CurrentRoom.ExitsUnlocked and IsScreenOpen("TraitTrayScreen") then
		thread(TraitTrayScreenClose, ActiveScreens.TraitTrayScreen)
		OpenAssesDoorShowerMenu(CollapseTable(MapState.OfferedExitDoors))
	end
end }

function OpenAssesDoorShowerMenu(doors)
	local curMap = mod.GetMapName()
	local screen = DeepCopyTable(ScreenData.BlindAccesibilityDoorMenu)

	if IsScreenOpen(screen.Name) then
		return
	end
	OnScreenOpened(screen)
	if ShowingCombatUI then
		HideCombatUI(screen.Name)
	end
	-- FreezePlayerUnit()
	SetConfigOption({ Name = "FreeFormSelectWrapY", Value = false })
	SetConfigOption({ Name = "FreeFormSelectStepDistance", Value = 8 })
	SetConfigOption({ Name = "FreeFormSelectSuccessDistanceStep", Value = 8 })
	SetConfigOption({ Name = "FreeFormSelectRepeatDelay", Value = 0.6 })
	SetConfigOption({ Name = "FreeFormSelectRepeatInterval", Value = 0.1 })
	SetConfigOption({ Name = "FreeFormSelecSearchFromId", Value = 0 })

	PlaySound({ Name = "/SFX/Menu Sounds/ContractorMenuOpen" })
	local components = screen.Components

	components.ShopBackgroundDim = CreateScreenComponent({ Name = "rectangle01", Group = "Asses_UI" })

	components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Group = "Asses_UI_Backing", Scale = 0.7 })
	Attach({ Id = components.CloseButton.Id, DestinationId = components.ShopBackgroundDim.Id, OffsetX = 0, OffsetY = 440 })
	components.CloseButton.OnPressedFunctionName = "BlindAccess.CloseAssesDoorShowerScreen"
	components.CloseButton.ControlHotkey = "Cancel"

	SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4 })
	SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0, 0, 0, 1 } })


	mod.CreateAssesDoorButtons(screen, doors)
	screen.KeepOpen = true
	-- thread( HandleWASDInput, screen )
	HandleScreenInput(screen)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Asses_UI" })
end

local nameToPreviewName = {
	["HermesUpgrade"] = "Hermes",
	["HermesUpgrade (Infernal Gate)"] = "Hermes (Infernal Gate)",
	["RoomRewardMetaPoint"] = "Darkness",
	["Gem"] = "Gemstones",
	["LockKey"] = "Chthonic Key",
	["Gift"] = "Nectar",
	["RoomRewardMaxHealth"] = "Centaur Heart",
	["RoomRewardMaxHealth (Infernal Gate)"] = "Centaur Heart (Infernal Gate)",
	["StackUpgrade"] = "Pom of Power",
	["StackUpgrade (Infernal Gate)"] = "pom of Power (Infernal Gate)",
	["WeaponUpgrade"] = "Daedalus Hammer",
	["RoomRewardMoney"] = "Gold",
	["RoomRewardMoney (Infernal Gate)"] = "Gold (Infernal Gate)",
	["SuperLockKey"] = "Titan Blood",
	["Shop"] = "Charon's Shop",
	["SuperGem"] = "Diamond",
	["SuperGift"] = "Ambrosia",
	["Story"] = "NPC Room",
}

function mod.GetMapName()
	if CurrentRun.Hero.IsDead then
		return CurrentHubRoom.Name
	else
		return CurrentRun.CurrentRoom.Name
	end
end

function mod.CreateAssesDoorButtons(screen, doors)
	local xPos = 960
	local startY = 180
	local yIncrement = 75
	local curY = startY
	local components = screen.Components
	local isFirstButton = true
	components.statsTextBacking = CreateScreenComponent({
		Name = "BlankObstacle",
		Group = "Asses_UI",
		Scale = 1,
		X = xPos,
		Y = curY
	})
	CreateTextBox({
		Id = components.statsTextBacking.Id,
		Text = "Health: " .. (CurrentRun.Hero.Health or 0) .. "/" .. (CurrentRun.Hero.MaxHealth or 0),
		FontSize = 24,
		OffsetX = 0,
		OffsetY = 0,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		Group = "Asses_UI",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Left",
	})
	curY = curY + yIncrement
	CreateTextBox({
		Id = components.statsTextBacking.Id,
		Text = "Armor: " .. (CurrentRun.Hero.HealthBuffer or 0),
		FontSize = 24,
		OffsetX = 0,
		OffsetY = yIncrement,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		Group = "Asses_UI",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Left",
	})
	curY = curY + yIncrement
	CreateTextBox({
		Id = components.statsTextBacking.Id,
		Text = "Gold: " .. (GameState.Resources["Money"] or 0),
		FontSize = 24,
		OffsetX = 0,
		OffsetY = yIncrement * 2,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		Group = "Asses_UI",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Left",
	})
	curY = curY + yIncrement
	for k, door in pairs(doors) do
		local showDoor = true
		if string.find(mod.GetMapName(), "D_Hub") then
			if door.Room.Name:find("D_Boss", 1, true) == 1 and GetDistance({ Id = 547487, DestinationId = 551569 }) ~= 0 then
				showDoor = false
			end
		end
		if showDoor then
			local displayText = ""
			if door.Room.ChosenRewardType == "Devotion" then
				displayText = displayText .. mod.getDoorSound(door, false) .. " "
				displayText = displayText .. mod.getDoorSound(door, true)
			else
				displayText = displayText .. mod.getDoorSound(door, false)
			end
			displayText = displayText:gsub("Room", "")

			local args = { RoomData = door.Room }
			local rewardOverrides = args.RoomData.RewardOverrides or {}
			local encounterData = args.RoomData.Encounter or {}
			local previewIcon = rewardOverrides.RewardPreviewIcon or encounterData.RewardPreviewIcon or
				args.RoomData.RewardPreviewIcon
			if previewIcon ~= nil and string.find(previewIcon, "Elite") then
				if previewIcon == "RoomElitePreview4" then
					displayText = displayText .. " (Boss)"
				elseif previewIcon == "RoomElitePreview2" then
					displayText = displayText .. " (Mini-Boss)"
				elseif previewIcon == "RoomElitePreview3" then
					if not string.find(displayText, "(Infernal Gate)") then
						displayText = displayText .. " (Infernal Gate)"
					end
				else
					displayText = displayText .. " (Elite)"
				end
			end
			local buttonKey = "AssesResourceMenuButton" .. k .. displayText

			components[buttonKey] =
				CreateScreenComponent({
					Name = "ButtonDefault",
					Group = "Asses_UI",
					Scale = 0.8,
					X = xPos,
					Y = curY
				})
			components[buttonKey].OnPressedFunctionName = "BlindAccess.AssesDoorMenuSoundSet"
			components[buttonKey].door = door
			--Attach({ Id = components[buttonKey].Id, DestinationId = components.ShopBackgroundDim.Id, OffsetX = xPos, OffsetY = curY })

			CreateTextBox({
				Id = components[buttonKey].Id,
				Text = displayText,
				FontSize = 24,
				OffsetX = -90,
				OffsetY = 0,
				Color = Color.White,
				Font = "P22UndergroundSCMedium",
				Group = "Asses_UI",
				ShadowBlur = 0,
				ShadowColor = { 0, 0, 0, 1 },
				ShadowOffset = { 0, 2 },
				Justification = "Left",
			})
			if isFirstButton then
				TeleportCursor({ OffsetX = xPos, OffsetY = curY })
				isFirstButton = false
			end
			curY = curY + yIncrement
		end
	end
end

function mod.CloseAssesDoorShowerScreen(screen, button)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters(screen.Name)
	ShowCombatUI(screen.Name)
end

function mod.AssesDoorMenuSoundSet(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/ContractorItemPurchase" })
	mod.CloseAssesDoorShowerScreen(screen, button)
	mod.doDefaultSound(button.door)
end

function mod.doDefaultSound(door)
	Teleport({ Id = CurrentRun.Hero.ObjectId, DestinationId = door.ObjectId })
end

function mod.getDoorSound(door, devotionSlot)
	local room = door.Room
	if door.Room.Name == "FinalBossExitDoor" or door.Room.Name == "E_Intro" then
		return "Greece"
	elseif room.NextRoomSet and room.Name:find("D_Boss", 1, true) ~= 1 then
		return "Stairway"
	elseif room.Name:find("_Intro", 1, true) ~= nil then
		return "Next Biome"
	elseif HasHeroTraitValue("HiddenRoomReward") then
		return "Enshrouded"
	elseif room.ChosenRewardType == nil then
		return "Enshrouded"
	elseif room.ChosenRewardType == "Boon" and room.ForceLootName then
		if LootData[room.ForceLootName].DoorIcon ~= nil then
			local godName = LootData[room.ForceLootName].DoorIcon
			godName = godName:gsub("BoonDrop", "")
			godName = godName:gsub("Preview", "Upgrade")
			if door.Name == "ShrinePointDoor" then
				godName = godName .. " (Infernal Gate)"
			end
			return godName
		end
	elseif room.ChosenRewardType == "Devotion" then
		local devotionLootName = room.Encounter.LootAName
		if devotionSlot == true then
			devotionLootName = room.Encounter.LootBName
		end
		devotionLootName = devotionLootName:gsub("Progress", ""):gsub("Drop", ""):gsub("Run", ""):gsub("Upgrade", "")
		return devotionLootName
	else
		local resourceName = room.ChosenRewardType:gsub("Progress", ""):gsub("Drop", ""):gsub("Run", "")
		if door.Name == "ShrinePointDoor" then
			resourceName = resourceName .. " (Infernal Gate)"
		end
		return resourceName
	end
end

ModUtil.Path.Wrap("ExitDoorUnlockedPresentation", function(baseFunc, exitDoor)
	local ret = baseFunc(exitDoor)
	if TableLength(MapState.OfferedExitDoors) == 1 then
		if GetDistance({ Id = 547487, DestinationId = 551569 }) == 0 then
			return ret
		elseif GetDistance({ Id = 547487, DestinationId = 551569 }) ~= 0 and GetDistance({ Id = CurrentRun.Hero.ObjectId, DestinationId = 547487 }) < 1000 then
			return ret
		end
	end
	local rewardsTable = mod.ProcessTable(LootObjects)
	if TableLength(rewardsTable) > 0 then
		PlaySound({ Name = "/Leftovers/SFX/AnnouncementPing" })
		return ret
	end
	local curMap = mod.GetMapName()
	if curMap == nil or string.find(curMap, "PostBoss") or string.find(curMap, "Hub_Main") or string.find(curMap, "Shop") or string.find(curMap, "D_Hub") or (string.find(curMap, "PreBoss") and CurrentRun.CurrentRoom.Store ~= nil and CurrentRun.CurrentRoom.Store.SpawnedStoreItems ~= nil) then
		return ret
	end
	OpenAssesDoorShowerMenu(CollapseTable(MapState.OfferedExitDoors))
	return ret
end)

OnControlPressed { "Codex", function(triggerArgs)
	if IsScreenOpen("TraitTrayScreen") then
		local rewardsTable = {}
		local curMap = mod.GetMapName()

		--shop menu
		if string.find(curMap, "Shop") or string.find(curMap, "PreBoss") or string.find(curMap, "D_Hub") then
			if CurrentRun.CurrentRoom.Store == nil then
				return
			elseif mod.NumUseableObjects(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems) == 0 then
				return
			end
			thread(TraitTrayScreenClose, ActiveScreens.TraitTrayScreen)
			mod.OpenStoreMenu(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems)
			return
		end

		if string.find(curMap, "Hub_PreRun") then
			rewardsTable = mod.ProcessTable(MapState.WeaponKits)
		else
			rewardsTable = mod.ProcessTable(ModUtil.Table.Merge(LootObjects, MapState.RoomRequiredObjects))
			local currentRoom = CurrentRun.CurrentRoom
			if currentRoom.HarvestPointIds ~= nil and #currentRoom.HarvestPointIds > 0 then
				for k, point in pairs(currentRoom.HarvestPointIds) do
					if IsUseable({Id = point.Id}) then
						table.insert(rewardsTable, {IsResourceHarvest=true, Type="Herb", Id=point.Id})
					end
				end
			end
			if currentRoom.ShovelPointId ~= nil and IsUseable({Id = currentRoom.ShovelPointId}) then
				table.insert(rewardsTable, {IsResourceHarvest=true, Type="Shovel", Id=currentRoom.ShovelPointId})
			end
			if currentRoom.PickaxePointId ~= nil and IsUseable({Id = currentRoom.PickaxePointId}) then
				table.insert(rewardsTable, {IsResourceHarvest=true, Type="Pickaxe", Id=currentRoom.PickaxePointId})
			end
			if currentRoom.ExorcismPointId ~= nil and IsUseable({Id = currentRoom.ExorcismPointId}) then
				table.insert(rewardsTable, {IsResourceHarvest=true, Type="Tablet", Id=currentRoom.ExorcismPointId})
			end 
			if currentRoom.FishingPointId ~= nil and IsUseable({Id = currentRoom.FishingPointId}) then
				table.insert(rewardsTable, {IsResourceHarvest=true, Type="Fish", Id=currentRoom.FishingPointId})
			end 
		end

		local tempTable = {}
		for k,v in pairs(rewardsTable) do
			if v.ObjectId == nil or IsUseable({ Id = v.ObjectId }) then
				tempTable[k] = v
			end
		end

		rewardsTable = tempTable

		if TableLength(rewardsTable) > 0 then
			thread(TraitTrayScreenClose, ActiveScreens.TraitTrayScreen)
			mod.OpenRewardMenu(rewardsTable)
		else
			return
		end
	-- elseif IsScreenOpen("BlindAccessibilityRewardMenu") then
	-- 	local curMap = mod.GetMapName()
	-- 	if not string.find(curMap, "Shop") and not string.find(curMap, "PreBoss") and not string.find(curMap, "D_Hub") then
	-- 		return
	-- 	end
	-- 	if CurrentRun.CurrentRoom.Store == nil then
	-- 		return
	-- 	elseif mod.NumUseableObjects(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems) == 0 then
	-- 		return
	-- 	end
	-- 	thread(mod.CloseRewardMenu, ActiveScreens.BlindAccessibilityRewardMenu)
	-- 	mod.OpenStoreMenu(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems)
	end
end }

OnControlPressed { "AdvancedTooltip", function(triggerArgs)
	local rewardsTable = {}
	if IsScreenOpen("InventoryScreen") then
		local currentResources = {}
		local screen = ActiveScreens.InventoryScreen
		for k,resourceName in pairs(screen.ItemCategories[screen.ActiveCategoryIndex]) do
			local amount = GameState.Resources[resourceName]
			if amount ~= nil and GetDisplayName({Text = resourceName}) ~= nil then
				table.insert(currentResources, {Resource = resourceName, Name = GetDisplayName({Text = resourceName}), Amount = amount})
			end
		end

		table.sort(currentResources, function(a,b) return a.Name < b.Name end)

		-- CloseInventoryScreen(ActiveScreens.InventoryScreen, nil)

		mod.OpenSimplifiedInventory(currentResources)
		
	elseif CurrentRun.Hero.IsDead then
		rewardsTable = mod.ProcessTable(ModUtil.Table.Merge(LootObjects, MapState.RoomRequiredObjects))
		if TableLength(rewardsTable) > 0 then
			if not IsEmpty(ActiveScreens.TraitTrayScreen) then
				thread(TraitTrayScreenClose, ActiveScreens.TraitTrayScreen)
			end
			mod.OpenRewardMenu(rewardsTable)
		end
	end
end }

function mod.OpenSimplifiedInventory(resources) 
	local screen = DeepCopyTable(ScreenData.BlindAccesibilityInventoryMenu)

	if IsScreenOpen(screen.Name) then
		return
	end
	OnScreenOpened(screen)
	HideCombatUI(screen.Name)

	PlaySound({ Name = "/SFX/Menu Sounds/ContractorMenuOpen" })
	local components = screen.Components

	components.ShopBackgroundDim = CreateScreenComponent({ Name = "rectangle01", Group = "Menu_UI" })
	components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Group = "Menu_UI_Backing", Scale = 0.7 })
	Attach({ Id = components.CloseButton.Id, DestinationId = components.ShopBackgroundDim.Id, OffsetX = 0, OffsetY = 440 })
	components.CloseButton.OnPressedFunctionName = "BlindAccess.CloseInventoryMenu"
	components.CloseButton.ControlHotkey = "Cancel"

	SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4 })
	SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0, 0, 0, 1 } })

	mod.CreateInventoryButtons(screen, resources)
	screen.KeepOpen = true
	-- thread(HandleWASDInput, screen)
	HandleScreenInput(screen)
	-- SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Menu_UI" })
end

function mod.CreateInventoryButtons(screen, resources)
	local startX = 360
	local startY = 135
	local endY = 635
	local xIncrement = 300
	local yIncrement = 55

	local curY = startY
	local curX = startX

	local components = screen.Components
	local isFirstButton = true

	for resource, resourceData in pairs(resources) do
		local buttonKey = "InventoryMenuText" .. resourceData.Resource
		components[buttonKey] =
			CreateScreenComponent({
				Name = "BlankObstacle",
				Group = "Menu_UI_Inventory",
				Scale = 0.8,
				X = curX,
				Y = curY
			})
		CreateTextBox({
			Id = components[buttonKey].Id,
			Text = resourceData.Name .. " : " .. resourceData.Amount,
			FontSize = 24,
			OffsetX = -320,
			OffsetY = 0,
			Color = Color.White,
			Font = "P22UndergroundSCMedium",
			Group = "Menu_UI_Inventory",
			ShadowBlur = 0,
			ShadowColor = { 0, 0, 0, 1 },
			ShadowOffset = { 0, 2 },
			Justification = "Left",
		})
		if isFirstButton then
			TeleportCursor({ OffsetX = curX, OffsetY = curY })
			isFirstButton = false
		end
		curY = curY + yIncrement
		if curY >= endY then
			curY = startY
			curX = curX + xIncrement 
		end
	end
end

function mod.CloseInventoryMenu(screen, button)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters(screen.Name)
	ShowCombatUI(screen.Name)
end


--DEBUG STUFF
ScreenData.InventoryScreen.FreezePlayerArgs = {
	DisableTray = false
}

local nameToPreviewName = {
	["RoomRewardMetaPoint"] = "Darkness",
	["RoomRewardMetaPointRunProgress"] = "Darkness (Pitch-Black)",
	["MetaPoints"] = "Darkness",
	["Gem"] = "Gemstones",
	["GemRunProgress"] = "Gemstones (Brilliant)",
	["Gems"] = "Gemstones",
	["LockKey"] = "Chthonic Key",
	["LockKeyRunProgress"] = "Chthonic Key (Fated)",
	["Gift"] = "Nectar",
	["GiftRunProgress"] = "Nectar (Vintage)",
	["RoomRewardMaxHealth"] = "Centaur Heart",
	["StackUpgrade"] = "Pom of Power",
	["WeaponUpgrade"] = "Daedalus Hammer",
	["RoomRewardMoney"] = "Gold",
	["Money"] = "Gold",
	["SuperLockKey"] = "Titan Blood",
	["SuperGem"] = "Diamond",
	["SuperGift"] = "Ambrosia",
	["HermesUpgrade"] = "Hermes",
	["AthenaUpgrade"] = "Athena",
	["CerberusKey"] = "Satyr Sack",
	["HealthFountain"] = "Fountain",
	["HealthFountainAsphodel"] = "Fountain",
	["HealthFountainElysium"] = "Fountain",
	["HealthFountainStyx"] = "Fountain",
	["SwordWeapon"] = "Stygian Blade",
	["BowWeapon"] = "Heart-Seeking Bow",
	["SpearWeapon"] = "Eternal Spear",
	["GunWeapon"] = "Adamant Rail",
	["FistWeapon"] = "Twin Fists",
	["ShieldWeapon"] = "Shield of Chaos",
	["NPC_Cerberus_Field_01"] = "Cerberus",
}

function mod.ProcessTable(objects)
	local table = mod.InitializeObjectList(objects)
	if CurrentRun and CurrentRun.CurrentRoom and not CurrentRun.CurrentRoom.ExitsUnlocked and not (TableLength(LootObjects) > 0) then
		table = mod.AddCure(table)
	end
	table = mod.AddCrossRoadExits(objects)
	table = mod.AddFood(table)
	table = mod.AddGold(table)
	table = mod.AddDarkness(table)
	table = mod.AddGemstones(table)
	table = mod.AddNectar(table)
	table = mod.AddDiamonds(table)
	table = mod.AddUrns(table)
	table = mod.AddFishingPoint(table)
	table = mod.AddGiftRack(table)
	if CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.ExitsUnlocked then
		table = mod.AddTrove(table)
		table = mod.AddWell(table)
		table = mod.AddPool(table)
	end
	table = mod.AddSkelly(table)
	table = mod.AddEscapeDoor(table)
	if GameState and GameState.Flags and not GameState.Flags.InFlashback then
		table = mod.AddNPCs(table)
	end
	table = mod.AddHouseContractor(table)
	table = mod.AddWretchedBroker(table)
	table = mod.AddHeadChef(table)
	table = mod.AddSackOfObols(table)
	return table
end

function mod.InitializeObjectList(objects)
	local initTable = CollapseTableOrderedByKeys(objects) or {}
	local copy = {}
	for i, v in ipairs(initTable) do
		table.insert(copy, { ["ObjectId"] = v.ObjectId, ["Name"] = v.Name })
	end
	return copy
end

function mod.AddCrossRoadExits(objects)
	local map = mod.GetMapName()
	if map == "Hub_Main" then
		local door = MapState.ActiveObstacles[391697]
		door.Name = "Training room"
		if not mod.ObjectAlreadyPresent(door, objects) then
			table.insert(objects, door)
		end
	elseif map == "Hub_PreRun" then
		local door = MapState.ActiveObstacles[421119]
		door.Name = "Crossroads"
		if not mod.ObjectAlreadyPresent(door, objects) then
			table.insert(objects, door)
		end
	end
	return objects
end

function mod.AddCure(objects)
	local NV = GetIdsByType({ Name = "PoisonCureFountainStyx" })
	if TableLength(NV) == 0 then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	for ID = #NV, 1, -1 do
		if IsUseable({ Id = NV[ID] }) then
			local cure = {
				["ObjectId"] = NV[ID],
				["Name"] = "Mandragora Curing Pool",
			}
			if not mod.ObjectAlreadyPresent(cure, copy) then
				copy = mod.TableInsertAtBeginning(copy, cure)
			end
		end
	end
	return copy
end

function mod.AddFood(objects)
	local NV = CombineTablesIPairs(GetIdsByType({ Name = "HealDropMinor" }),
		GetIdsByType({ Name = "RoomRewardHealDrop" }))
	if TableLength(NV) == 0 then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	NV = GetIdsByType({ Name = "HealDropMinor" })
	if TableLength(NV) > 0 then
		for ID = 1, #NV do
			if IsUseable({ Id = NV[ID] }) then
				local food = {
					["ObjectId"] = NV[ID],
					["Name"] = "Food (Dropped)",
				}
				if not mod.ObjectAlreadyPresent(food, copy) then
					table.insert(copy, food)
				end
			end
		end
	end
	NV = GetIdsByType({ Name = "RoomRewardHealDrop" })
	if TableLength(NV) > 0 then
		for ID = 1, #NV do
			if IsUseable({ Id = NV[ID] }) then
				local food = {
					["ObjectId"] = NV[ID],
					["Name"] = "Food",
				}
				if not mod.ObjectAlreadyPresent(food, copy) then
					table.insert(copy, food)
				end
			end
		end
	end
	return copy
end

function mod.AddGold(objects)
	local NV = CombineTablesIPairs(GetIdsByType({ Name = "RoomRewardMoneyDrop" }),
		GetIdsByType({ Name = "MinorMoneyDrop" }))
	if TableLength(NV) == 0 then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	for ID = 1, #NV do
		if IsUseable({ Id = NV[ID] }) then
			local obols = {
				["ObjectId"] = NV[ID],
				["Name"] = "Gold",
			}
			if not mod.ObjectAlreadyPresent(obols, copy) then
				table.insert(copy, obols)
			end
		end
	end
	return copy
end

function mod.AddDarkness(objects)
	local NV = CombineTablesIPairs(GetIdsByType({ Name = "RoomRewardMetaPointDrop" }),
		GetIdsByType({ Name = "RoomRewardMetaPointDropRunProgress" }))
	if TableLength(NV) == 0 then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	for ID = 1, #NV do
		if IsUseable({ Id = NV[ID] }) then
			local darkness = {
				["ObjectId"] = NV[ID],
				["Name"] = "Darkness",
			}
			if not mod.ObjectAlreadyPresent(darkness, copy) then
				table.insert(copy, darkness)
			end
		end
	end
	return copy
end

function mod.AddGemstones(objects)
	local NV = CombineTablesIPairs(GetIdsByType({ Name = "GemDrop" }), GetIdsByType({ Name = "GemDropRunProgress" }))
	if TableLength(NV) == 0 then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	for ID = 1, #NV do
		if IsUseable({ Id = NV[ID] }) then
			local gem = {
				["ObjectId"] = NV[ID],
				["Name"] = "Gemstones",
			}
			if not mod.ObjectAlreadyPresent(gem, copy) then
				table.insert(copy, gem)
			end
		end
	end
	return copy
end

function mod.AddNectar(objects)
	local NV = CombineTablesIPairs(GetIdsByType({ Name = "GiftDrop" }), GetIdsByType({ Name = "GiftDropRunProgress" }))
	if TableLength(NV) == 0 then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	for ID = 1, #NV do
		if IsUseable({ Id = NV[ID] }) then
			local nectar = {
				["ObjectId"] = NV[ID],
				["Name"] = "Nectar",
			}
			if not mod.ObjectAlreadyPresent(nectar, copy) then
				table.insert(copy, nectar)
			end
		end
	end
	return copy
end

function mod.AddDiamonds(objects)
	local NV = GetIdsByType({ Name = "SuperGemDrop" })
	if TableLength(NV) == 0 then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	for ID = 1, #NV do
		if IsUseable({ Id = NV[ID] }) then
			local diamond = {
				["ObjectId"] = NV[ID],
				["Name"] = "Diamond",
			}
			if not mod.ObjectAlreadyPresent(diamond, copy) then
				table.insert(copy, diamond)
			end
		end
	end
	return copy
end

function mod.AddUrns(objects)
	if CurrentRun and IsCombatEncounterActive(CurrentRun) then
		return objects
	end
	local urns = CollapseTableOrderedByKeys(ActiveEnemies)
	if TableLength(urns) == 0 then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	for i = 1, #urns do
		if urns[i].Name == "Breakable" and urns[i].MoneyDropOnDeath and urns[i].MoneyDropOnDeath.Chance > 0 then
			local urn = {
				["ObjectId"] = urns[i].ObjectId,
				["Name"] = "Breakable Urn (Obols)",
			}
			if not mod.ObjectAlreadyPresent(urn, copy) then
				table.insert(copy, urn)
			end
		end
	end
	return copy
end

function mod.AddFishingPoint(objects)
	if not (CurrentRun.CurrentRoom.ForceFishing and CurrentRun.CurrentRoom.FishingPointId and IsUseable({ Id = CurrentRun.CurrentRoom.FishingPointId })) then
		return objects
	end
	local canFishInEncounter = true
	if CurrentRun.CurrentRoom.Encounter and CurrentRun.CurrentRoom.Encounter.BlockFishingBeforeStart and not CurrentRun.CurrentRoom.Encounter.Completed then
		canFishInEncounter = false
	end
	if (CurrentRun and IsCombatEncounterActive(CurrentRun)) or not canFishInEncounter then
		return objects
	end
	local NV = CurrentRun.CurrentRoom.FishingPointId
	local copy = ShallowCopyTable(objects)
	local fish = {
		["ObjectId"] = CurrentRun.CurrentRoom.FishingPointId,
		["Name"] = "Fishing Point",
	}
	if not mod.ObjectAlreadyPresent(fish, copy) then
		table.insert(copy, fish)
	end
	return copy
end

function mod.AddGiftRack(objects)
	local NV = GetIdsByType({ Name = "GiftRack" })
	if TableLength(NV) == 0 then
		return objects
	end
	local ID = NV[1]
	if not IsUseable({ Id = NV[1] }) then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	local rack = {
		["ObjectId"] = NV[1],
		["Name"] = "Keepsake Display Case",
	}
	if not mod.ObjectAlreadyPresent(rack, copy) then
		table.insert(copy, rack)
	end
	return copy
end

function mod.AddTrove(objects)
	if not (CurrentRun.CurrentRoom.ChallengeSwitch and IsUseable({ Id = CurrentRun.CurrentRoom.ChallengeSwitch.ObjectId })) then
		return objects
	end
	local NV = CurrentRun.CurrentRoom.ChallengeSwitch.ObjectId
	local copy = ShallowCopyTable(objects)
	local switch = {
		["ObjectId"] = CurrentRun.CurrentRoom.ChallengeSwitch.ObjectId,
		["Name"] = "Infernal Trove (" ..
			(nameToPreviewName[CurrentRun.CurrentRoom.ChallengeSwitch.RewardType] or CurrentRun.CurrentRoom.ChallengeSwitch.RewardType) ..
			")",
	}
	if not mod.ObjectAlreadyPresent(switch, copy) then
		table.insert(copy, switch)
	end
	return copy
end

function mod.AddWell(objects)
	if not (CurrentRun.CurrentRoom.WellShop and IsUseable({ Id = CurrentRun.CurrentRoom.WellShop.ObjectId })) then
		return objects
	end
	local NV = CurrentRun.CurrentRoom.WellShop.ObjectId
	local copy = ShallowCopyTable(objects)
	local well = {
		["ObjectId"] = CurrentRun.CurrentRoom.WellShop.ObjectId,
		["Name"] = "Well of Charon",
	}
	if not mod.ObjectAlreadyPresent(well, copy) then
		table.insert(copy, well)
	end
	return copy
end

function mod.AddPool(objects)
	if not (CurrentRun.CurrentRoom.SellTraitShop and IsUseable({ Id = CurrentRun.CurrentRoom.SellTraitShop.ObjectId })) then
		return objects
	end
	local NV = CurrentRun.CurrentRoom.SellTraitShop.ObjectId
	local copy = ShallowCopyTable(objects)
	local pool = {
		["ObjectId"] = CurrentRun.CurrentRoom.SellTraitShop.ObjectId,
		["Name"] = "Pool of Purging",
	}
	if not mod.ObjectAlreadyPresent(pool, copy) then
		table.insert(copy, pool)
	end
	return copy
end

function mod.AddSkelly(objects)
	if not string.find(mod.GetMapName(), "Hub_PreRun") then
		return objects
	end
	local NV = GetIdsByType({ Name = "NPC_Skelly_01" })
	if TableLength(NV) == 0 then
		return objects
	end
	local ID = NV[1]
	if not (ActiveEnemies[NV[1]] and not ActiveEnemies[NV[1]].IsDead) then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	local skelly = {
		["ObjectId"] = NV[1],
		["Name"] = "Schelemeus",
	}
	if not mod.ObjectAlreadyPresent(skelly, copy) then
		copy = mod.TableInsertAtBeginning(copy, skelly)
	end
	return copy
end

function mod.AddEscapeDoor(objects)
	if not string.find(mod.GetMapName(), "Hub_PreRun") then
		return objects
	end
	local NV = GetIdsByType({ Name = "NewRunDoor" })
	if TableLength(NV) == 0 then
		return objects
	end
	local ID = NV[1]
	if not IsUseable({ Id = NV[1] }) then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	local window = {
		["ObjectId"] = NV[1],
		["Name"] = "Escape Window",
	}
	if not mod.ObjectAlreadyPresent(window, copy) then
		table.insert(copy, window)
	end
	return copy
end

function mod.AddNPCs(objects)
	if CurrentRun and IsCombatEncounterActive(CurrentRun) then
		return objects
	end
	local npcs = CollapseTableOrderedByKeys(ActiveEnemies)
	if TableLength(npcs) == 0 then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	for i = 1, #npcs do
		local skip = false
		if IsUseable({ Id = npcs[i].ObjectId }) then
			local npc = {
				["ObjectId"] = npcs[i].ObjectId,
				["Name"] = nameToPreviewName[npcs[i].Name] or npcs[i].Name,
			}
			if npcs[i].Name == "NPC_Hades_01" and mod.GetMapName() == "Hub_Main" then --Hades in house
				if ActiveEnemies[555686] then                                       --Hades is in garden
					npc["ObjectId"] = 555686
				elseif GetDistance({ Id = npc["ObjectId"], DestinationId = 422028 }) < 100 then --Hades on his throne
					npc["DestinationOffsetY"] = 150
				end
			elseif npcs[i].Name == "NPC_Cerberus_01" and mod.GetMapName() == "Hub_Main" and GetDistance({ Id = npc["ObjectId"], DestinationId = 422028 }) > 500 then                                                                                                 --Cerberus not present in house
				skip = true
			elseif npcs[i].Name == "NPC_Cerberus_Field_01" and TableLength(MapState.OfferedExitDoors) == 1 and CollapseTable(MapState.OfferedExitDoors)[1].Room.Name:find("D_Boss", 1, true) == 1 and GetDistance({ Id = npc["ObjectId"], DestinationId = 551569 }) == 0 then --Cerberus in Styx after having been given satyr sack
				skip = true
			end
			if not mod.ObjectAlreadyPresent(npc, copy) and not skip then
				table.insert(copy, npc)
			end
		end
	end
	return copy
end

function mod.AddHouseContractor(objects)
	if mod.GetMapName() ~= "Hub_Main" or (GameState and GameState.Flags and GameState.Flags.InFlashback) then
		return objects
	end
	local NV = { 210158 }
	if TableLength(NV) == 0 then
		return objects
	end
	local ID = NV[1]
	if not IsUseable({ Id = NV[1] }) then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	local contractor = {
		["ObjectId"] = NV[1],
		["Name"] = "House Contractor",
		["DestinationOffsetY"] = 25,
	}
	if not mod.ObjectAlreadyPresent(contractor, copy) then
		table.insert(copy, contractor)
	end
	return copy
end

function mod.AddWretchedBroker(objects)
	if mod.GetMapName() ~= "Hub_Main" or (GameState and GameState.Flags and GameState.Flags.InFlashback) then
		return objects
	end
	local NV = { 423390 }
	if TableLength(NV) == 0 then
		return objects
	end
	local ID = NV[1]
	if not IsUseable({ Id = NV[1] }) then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	local broker = {
		["ObjectId"] = NV[1],
		["Name"] = "Wretched Broker",
		["DestinationOffsetX"] = -225,
		["DestinationOffsetY"] = -100
	}
	if not mod.ObjectAlreadyPresent(broker, copy) then
		table.insert(copy, broker)
	end
	return copy
end

function mod.AddHeadChef(objects)
	if mod.GetMapName() ~= "Hub_Main" or (GameState and GameState.Flags and GameState.Flags.InFlashback) then
		return objects
	end
	local NV = { 423399 }
	if TableLength(NV) == 0 then
		return objects
	end
	local ID = NV[1]
	if not IsUseable({ Id = NV[1] }) then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	local chef = {
		["ObjectId"] = NV[1],
		["Name"] = "Head Chef",
	}
	if not mod.ObjectAlreadyPresent(chef, copy) then
		table.insert(copy, chef)
	end
	return copy
end

function mod.AddSackOfObols(objects)
	local curMap = mod.GetMapName()
	if not string.find(curMap, "Shop") and not string.find(curMap, "PreBoss") and not string.find(curMap, "D_Hub") then
		return objects
	end
	if not (CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.Store and CurrentRun.CurrentRoom.Store.SpawnedStoreItems) then
		return objects
	end
	local NV = {}
	for k, v in pairs(CurrentRun.CurrentRoom.Store.SpawnedStoreItems) do
		if v.Name == "ForbiddenShopItem" then
			table.insert(NV, v.ObjectId)
		end
	end
	if TableLength(NV) == 0 then
		return objects
	end
	local ID = NV[1]
	if not IsUseable({ Id = NV[1] }) then
		return objects
	end
	local copy = ShallowCopyTable(objects)
	local sack = {
		["ObjectId"] = NV[1],
		["Name"] = "Sack of Obols (Elite)",
	}
	if not mod.ObjectAlreadyPresent(sack, copy) then
		table.insert(copy, sack)
	end
	return copy
end

function mod.ObjectAlreadyPresent(object, objects)
	found = false
	for k, v in ipairs(objects) do
		if object.ObjectId == v.ObjectId then
			found = true
		end
	end
	if CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.Store and mod.NumUseableObjects(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems) > 0 then
		for k, v in pairs(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems) do
			if object.ObjectId == v.ObjectId and v.Name ~= "ForbiddenShopItem" then
				found = true
			end
		end
	end
	return found
end

function mod.TableInsertAtBeginning(baseTable, insertValue)
	if baseTable == nil or insertValue == nil then
		return
	end
	local returnTable = {}
	table.insert(returnTable, insertValue)
	for k, v in ipairs(baseTable) do
		table.insert(returnTable, v)
	end
	return returnTable
end

function mod.GetWeaponDisplayConditions(name)
	found = false
	for k, weaponName in ipairs(WeaponSets.HeroPrimaryWeapons) do
		if name == weaponName then
			found = true
		end
	end
	if not found then
		return ""
	end
	if CurrentRun.Hero.Weapons[name] ~= nil then
		if IsWeaponUnused(name) then
			return " (Equipped, Dark Thirst)"
		else
			return " (Equipped)"
		end
	else
		if IsWeaponUnused(name) then
			return " (Dark Thirst)"
		else
			return ""
		end
	end
end

function mod.OpenRewardMenu(rewards)
	local screen = DeepCopyTable(ScreenData.BlindAccessibilityRewardMenu)

	if IsScreenOpen(screen.Name) then
		return
	end
	OnScreenOpened(screen)
	HideCombatUI(screen.Name)

	PlaySound({ Name = "/SFX/Menu Sounds/ContractorMenuOpen" })
	local components = screen.Components

	components.ShopBackgroundDim = CreateScreenComponent({ Name = "rectangle01", Group = "Menu_UI" })
	components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Group = "Menu_UI_Backing", Scale = 0.7 })
	Attach({ Id = components.CloseButton.Id, DestinationId = components.ShopBackgroundDim.Id, OffsetX = 0, OffsetY = 440 })
	components.CloseButton.OnPressedFunctionName = "BlindAccess.CloseRewardMenu"
	components.CloseButton.ControlHotkey = "Cancel"

	SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4 })
	SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0, 0, 0, 1 } })

	mod.CreateRewardButtons(screen, rewards)
	screen.KeepOpen = true
	-- thread(HandleWASDInput, screen)
	HandleScreenInput(screen)
	-- SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Menu_UI" })
end

function mod.CreateRewardButtons(screen, rewards)
	local xPos = 960
	local startY = 235
	local yIncrement = 55
	local curY = startY
	local components = screen.Components
	local isFirstButton = true
	if not string.find(mod.GetMapName(), "Hub_PreRun") and mod.GetMapName():find("Hub_Main", 1, true) ~= 1 and mod.GetMapName():find("E_", 1, true) ~= 1 then
		components.statsTextBacking = CreateScreenComponent({
			Name = "BlankObstacle",
			Group = "Menu_UI_Rewards",
			Scale = 1,
			X = xPos,
			Y = curY
		})
		CreateTextBox({
			Id = components.statsTextBacking.Id,
			Text = "Health: " .. (CurrentRun.Hero.Health or 0) .. "/" .. (CurrentRun.Hero.MaxHealth or 0),
			FontSize = 24,
			OffsetX = 0,
			OffsetY = 0,
			Color = Color.White,
			Font = "P22UndergroundSCMedium",
			Group = "Menu_UI_Rewards",
			ShadowBlur = 0,
			ShadowColor = { 0, 0, 0, 1 },
			ShadowOffset = { 0, 2 },
			Justification = "Left",
		})
		curY = curY + yIncrement
		CreateTextBox({
			Id = components.statsTextBacking.Id,
			Text = "Armor: " .. (CurrentRun.Hero.HealthBuffer or 0),
			FontSize = 24,
			OffsetX = 0,
			OffsetY = yIncrement,
			Color = Color.White,
			Font = "P22UndergroundSCMedium",
			Group = "Menu_UI_Rewards",
			ShadowBlur = 0,
			ShadowColor = { 0, 0, 0, 1 },
			ShadowOffset = { 0, 2 },
			Justification = "Left",
		})
		curY = curY + yIncrement
		CreateTextBox({
			Id = components.statsTextBacking.Id,
			Text = "Gold: " .. (GameState.Resources["Money"] or 0),
			FontSize = 24,
			OffsetX = 0,
			OffsetY = yIncrement * 2,
			Color = Color.White,
			Font = "P22UndergroundSCMedium",
			Group = "Menu_UI_Rewards",
			ShadowBlur = 0,
			ShadowColor = { 0, 0, 0, 1 },
			ShadowOffset = { 0, 2 },
			Justification = "Left",
		})
		curY = curY + yIncrement
	end
	for k, reward in pairs(rewards) do
		if reward.IsResourceHarvest then
			local displayText = reward.Type
			local buttonKey = "RewardMenuButton" .. k .. displayText
			components[buttonKey] =
				CreateScreenComponent({
					Name = "ButtonDefault",
					Group = "Menu_UI_Rewards",
					Scale = 0.8,
					X = xPos,
					Y = curY
				})
			components[buttonKey].index = k
			components[buttonKey].reward = {ObjectId = reward.Id}
			components[buttonKey].OnPressedFunctionName = "BlindAccess.GoToReward"
			if reward.Args ~= nil and reward.Args.ForceLootName then
				displayText = reward.Args.ForceLootName:gsub("Upgrade", ""):gsub("Drop", "")
			end
			displayText = displayText:gsub("Drop", ""):gsub("StoreReward", "") or displayText
			displayText = (displayText .. mod.GetWeaponDisplayConditions(reward.Name)) or displayText
			CreateTextBox({
				Id = components[buttonKey].Id,
				Text = displayText,
				FontSize = 24,
				OffsetX = -320,
				OffsetY = 0,
				Color = Color.White,
				Font = "P22UndergroundSCMedium",
				Group = "Menu_UI_Rewards",
				ShadowBlur = 0,
				ShadowColor = { 0, 0, 0, 1 },
				ShadowOffset = { 0, 2 },
				Justification = "Left",
			})
			if isFirstButton then
				TeleportCursor({ OffsetX = xPos, OffsetY = curY })
				isFirstButton = false
			end
			curY = curY + yIncrement
		else
			local displayText = reward.Name
			local buttonKey = "RewardMenuButton" .. k .. displayText
			components[buttonKey] =
				CreateScreenComponent({
					Name = "ButtonDefault",
					Group = "Menu_UI_Rewards",
					Scale = 0.8,
					X = xPos,
					Y = curY
				})
			components[buttonKey].index = k
			components[buttonKey].reward = reward
			components[buttonKey].OnPressedFunctionName = "BlindAccess.GoToReward"
			if reward.Args ~= nil and reward.Args.ForceLootName then
				displayText = reward.Args.ForceLootName:gsub("Upgrade", ""):gsub("Drop", "")
			end
			displayText = displayText:gsub("Drop", ""):gsub("StoreReward", "") or displayText
			displayText = (displayText .. mod.GetWeaponDisplayConditions(reward.Name)) or displayText
			CreateTextBox({
				Id = components[buttonKey].Id,
				Text = displayText,
				FontSize = 24,
				OffsetX = -320,
				OffsetY = 0,
				Color = Color.White,
				Font = "P22UndergroundSCMedium",
				Group = "Menu_UI_Rewards",
				ShadowBlur = 0,
				ShadowColor = { 0, 0, 0, 1 },
				ShadowOffset = { 0, 2 },
				Justification = "Left",
			})
			if isFirstButton then
				TeleportCursor({ OffsetX = xPos, OffsetY = curY })
				isFirstButton = false
			end
			curY = curY + yIncrement
		end
	end
end

function mod.GoToReward(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/ContractorItemPurchase" })
	mod.CloseRewardMenu(screen, button)
	local RewardID = nil
	RewardID = button.reward.ObjectId
	destinationOffsetX = button.reward.DestinationOffsetX or 0
	destinationOffsetY = button.reward.DestinationOffsetY or 0
	if RewardID ~= nil then
		Teleport({
			Id = CurrentRun.Hero.ObjectId,
			DestinationId = RewardID,
			OffsetX = destinationOffsetX,
			OffsetY =
				destinationOffsetY
		})
	end
end

function mod.CloseRewardMenu(screen, button)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters(screen.Name)
	ShowCombatUI(screen.Name)
end

-- OnControlPressed { "ScrollDown", function(triggerArgs)
-- 	local curMap = GetMapName({})
-- 	if not string.find(curMap, "Shop") and not string.find(curMap, "PreBoss") and not string.find(curMap, "D_Hub") then
-- 		return
-- 	end
-- 	if CurrentRun.CurrentRoom.Store == nil then
-- 		return
-- 	elseif mod.NumUseableObjects(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems) == 0 then
-- 		return
-- 	end
-- 	if IsScreenOpen("TraitTrayScreen") then
-- 		thread(TraitTrayScreenClose, ActiveScreens.TraitTrayScreen)
-- 		mod.OpenStoreMenu(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems)
-- 	end
-- end }

function mod.NumUseableObjects(objects)
	local count = 0
	if objects ~= nil then
		for k, object in pairs(objects) do
			if object.ObjectId ~= nil and IsUseable({ Id = object.ObjectId }) and object.Name ~= "ForbiddenShopItem" then
				count = count + 1
			end
		end
	end
	return count
end

function mod.OpenStoreMenu(items)
	local screen = DeepCopyTable(ScreenData.BlindAccesibilityStoreMenu)

	if IsScreenOpen(screen.Name) then
		return
	end
	OnScreenOpened(screen)
	HideCombatUI(screen.Name)

	PlaySound({ Name = "/SFX/Menu Sounds/ContractorMenuOpen" })
	local components = screen.Components

	components.ShopBackgroundDim = CreateScreenComponent({ Name = "rectangle01", Group = "Asses_UI_Store" })

	components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Group = "Asses_UI_Store_Backing", Scale = 0.7 })
	Attach({ Id = components.CloseButton.Id, DestinationId = components.ShopBackgroundDim.Id, OffsetX = 0, OffsetY = 440 })
	components.CloseButton.OnPressedFunctionName = "BlindAccess.CloseItemScreen"
	components.CloseButton.ControlHotkey = "Cancel"

	SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4 })
	SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0, 0, 0, 1 } })

	mod.CreateItemButtons(screen, items)
	screen.KeepOpen = true
	HandleScreenInput(screen)
	-- SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Asses_UI_Store" })
end

local nameToPreviewName = {
	["HermesUpgrade"] = "Hermes",
	["MetaPoint"] = "25 Darkness",
	["Gem"] = "20 Gemstones",
	["LockKey"] = "Chthonic Key",
	["Gift"] = "Nectar",
	["RoomRewardMaxHealth"] = "Centaur Heart",
	["StackUpgrade"] = "Pom of Power",
	["StackUpgradeRare"] = "Double Pom of Power",
	["WeaponUpgrade"] = "Daedalus Hammer",
	["ChaosWeaponUpgrade"] = "Anvil of Fates",
	["RoomRewardMoney"] = "Obols",
	["SuperLockKey"] = "Titan Blood",
	["SuperGem"] = "Diamond",
	["SuperGift"] = "Ambrosia",
	["BlindBoxLoot"] = "Random God Boon",
	["RoomRewardHeal"] = "Food",
	["RandomStack"] = "Pom Slice",
}

function mod.CreateItemButtons(screen, items)
	local xPos = 960
	local startY = 235
	local yIncrement = 75
	local curY = startY
	local components = screen.Components
	local isFirstButton = true
	components.statsTextBacking = CreateScreenComponent({
		Name = "BlankObstacle",
		Group = "Asses_UI_Store",
		Scale = 1,
		X = xPos,
		Y = curY
	})
	CreateTextBox({
		Id = components.statsTextBacking.Id,
		Text = "Health: " .. (CurrentRun.Hero.Health or 0) .. "/" .. (CurrentRun.Hero.MaxHealth or 0),
		FontSize = 24,
		Width = 360,
		OffsetX = 0,
		OffsetY = 0,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		Group = "Asses_UI_Store",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Left",
	})
	curY = curY + yIncrement
	CreateTextBox({
		Id = components.statsTextBacking.Id,
		Text = "Gold: " .. (GameState.Resources["Money"] or 0),
		FontSize = 24,
		Width = 360,
		OffsetX = 0,
		OffsetY = yIncrement,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		Group = "Asses_UI_Store",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Left",
	})
	curY = curY + yIncrement
	for k, item in pairs(items) do
		if IsUseable({ Id = item.ObjectId }) and item.Name ~= "ForbiddenShopItem" then
			local displayText = item.Name
			local buttonKey = "AssesShopMenuButton" .. k .. displayText
			components[buttonKey] =
				CreateScreenComponent({
					Name = "ButtonDefault",
					Group = "Asses_UI_Store",
					Scale = 0.8,
					X = xPos,
					Y = curY
				})
			components[buttonKey].index = k
			components[buttonKey].item = item
			components[buttonKey].OnPressedFunctionName = "BlindAccess.MoveToItem"

			if displayText == "RandomLoot" then
				if LootObjects[item.ObjectId] ~= nil then
					displayText = LootObjects[item.ObjectId].Name
				end
			end
			displayText = displayText:gsub("RoomReward", ""):gsub("StoreReward", "") or displayText
			CreateTextBox({
				Id = components[buttonKey].Id,
				Text = GetDisplayName({Text=displayText}),
				UseDescription = false,
				FontSize = 24,
				OffsetX = -520,
				OffsetY = 0,
				Color = Color.White,
				Font = "P22UndergroundSCMedium",
				Group = "Asses_UI_Store",
				ShadowBlur = 0,
				ShadowColor = { 0, 0, 0, 1 },
				ShadowOffset = { 0, 2 },
				Justification = "Left",
			})
			CreateTextBox({
				Id = components[buttonKey].Id,
				Text = item.ResourceCosts.Money .. " Gold",
				FontSize = 24,
				OffsetX = -520,
				OffsetY = 30,
				Color = Color.White,
				Font = "P22UndergroundSCMedium",
				Group = "Asses_UI_Store",
				ShadowBlur = 0,
				ShadowColor = { 0, 0, 0, 1 },
				ShadowOffset = { 0, 2 },
				Justification = "Left",
			})
			if isFirstButton then
				TeleportCursor({ OffsetX = xPos, OffsetY = curY })
				isFirstButton = false
			end
			curY = curY + yIncrement
		end
	end
end

function mod.MoveToItem(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/ContractorItemPurchase" })
	mod.CloseItemScreen(screen, button)
	local ItemID = button.item.ObjectId
	if ItemID ~= nil then
		Teleport({ Id = CurrentRun.Hero.ObjectId, DestinationId = ItemID })
	end
end

function mod.CloseItemScreen(screen, button)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters(screen.Name)
	ShowCombatUI(screen.Name)
end

ModUtil.Path.Override("SpawnStoreItemInWorld", function(itemData, kitId)
	local spawnedItem = nil
	if itemData.Name == "WeaponUpgradeDrop" then
		spawnedItem = CreateWeaponLoot({
			SpawnPoint = kitId,
			ResourceCosts = itemData.ResourceCosts or
				GetProcessedValue(ConsumableData.WeaponUpgradeDrop.ResourceCosts),
			DoesNotBlockExit = true,
			SuppressSpawnSounds = true,
		})
	elseif itemData.Name == "ShopHermesUpgrade" then
		spawnedItem = CreateHermesLoot({
			SpawnPoint = kitId,
			ResourceCosts = itemData.ResourceCosts or
				GetProcessedValue(ConsumableData.ShopHermesUpgrade.ResourceCosts),
			DoesNotBlockExit = true,
			SuppressSpawnSounds = true,
			BoughtFromShop = true,
			AddBoostedAnimation =
				itemData.AddBoostedAnimation,
			BoonRaritiesOverride = itemData.BoonRaritiesOverride
		})
		spawnedItem.CanReceiveGift = false
		SetThingProperty({ Property = "SortBoundsScale", Value = 1.0, DestinationId = spawnedItem.ObjectId })
	elseif itemData.Name == "ShopManaUpgrade" then
		spawnedItem = CreateManaLoot({
			SpawnPoint = kitId,
			ResourceCosts = itemData.ResourceCosts or
				GetProcessedValue(ConsumableData.ShopManaUpgrade.ResourceCosts),
			DoesNotBlockExit = true,
			SuppressSpawnSounds = true,
			BoughtFromShop = true,
			AddBoostedAnimation =
				itemData.AddBoostedAnimation,
			BoonRaritiesOverride = itemData.BoonRaritiesOverride
		})
		spawnedItem.CanReceiveGift = false
		SetThingProperty({ Property = "SortBoundsScale", Value = 1.0, DestinationId = spawnedItem.ObjectId })
	elseif itemData.Type == "Consumable" then
		local consumablePoint = SpawnObstacle({ Name = itemData.Name, DestinationId = kitId, Group = "Standing" })
		local upgradeData = GetRampedConsumableData(ConsumableData[itemData.Name] or LootData[itemData.Name])
		spawnedItem = CreateConsumableItemFromData(consumablePoint, upgradeData, itemData.CostOverride)
		spawnedItem.CanDuplicate = false
		spawnedItem.CanReceiveGift = false
		ApplyConsumableItemResourceMultiplier(CurrentRun.CurrentRoom, spawnedItem)
		ExtractValues(CurrentRun.Hero, spawnedItem, spawnedItem)
	elseif itemData.Type == "Boon" then
		itemData.Args.SpawnPoint = kitId
		itemData.Args.DoesNotBlockExit = true
		itemData.Args.SuppressSpawnSounds = true
		itemData.Args.SuppressFlares = true
		spawnedItem = GiveLoot(itemData.Args)
		spawnedItem.CanReceiveGift = false
		SetThingProperty({ Property = "SortBoundsScale", Value = 1.0, DestinationId = spawnedItem.ObjectId })
	end
	if spawnedItem ~= nil then
		spawnedItem.SpawnPointId = kitId
		if not itemData.PendingShopItem then
			SetObstacleProperty({ Property = "MagnetismWhileBlocked", Value = 0, DestinationId = spawnedItem.ObjectId })
			spawnedItem.UseText = spawnedItem.PurchaseText or "Shop_UseText"
			spawnedItem.IconPath = spawnedItem.TextIconPath or spawnedItem.IconPath
			table.insert(CurrentRun.CurrentRoom.Store.SpawnedStoreItems,
				--MOD START
				{ KitId = kitId, ObjectId = spawnedItem.ObjectId, ResourceCosts = spawnedItem.ResourceCosts, Name = itemData.Name })
			--MOD END
		else
			MapState.SurfaceShopItems = MapState.SurfaceShopItems or {}
			table.insert(MapState.SurfaceShopItems, spawnedItem.Name)
		end
		return spawnedItem
	else
		DebugPrint({ Text = " Not spawned?!" .. itemData.Name })
	end
end, mod)

mod.Internal = ModUtil.UpValues(function()
	return setupData
end)

setupData()
