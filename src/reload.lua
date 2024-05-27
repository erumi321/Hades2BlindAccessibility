---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.

function OnInventoryPress()
	if not IsScreenOpen("TraitTrayScreen") then
		return
	end
	if TableLength(MapState.OfferedExitDoors) == 0 and GetMapName() ~= "Hub_Main" then
		return
	elseif TableLength(MapState.OfferedExitDoors) == 1 and string.find(GetMapName(), "D_Hub") then
		finalBossDoor = CollapseTable(MapState.OfferedExitDoors)[1]
		if finalBossDoor.Room.Name:find("D_Boss", 1, true) == 1 and GetDistance({ Id = 547487, DestinationId = 551569 }) ~= 0 then
			return
		end
	end
	if CurrentRun.CurrentRoom.ExitsUnlocked and IsScreenOpen("TraitTrayScreen") then
		TraitTrayScreenClose(ActiveScreens.TraitTrayScreen)
		OpenAssesDoorShowerMenu(CollapseTable(MapState.OfferedExitDoors))
	end
end

function OpenAssesDoorShowerMenu(doors)
	local curMap = GetMapName()
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
	components.CloseButton.OnPressedFunctionName = "BlindAccessCloseAssesDoorShowerScreen"
	components.CloseButton.ControlHotkeys = { "Cancel", }
	components.CloseButton.MouseControlHotkeys  = { "Cancel" }

	SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4 })
	SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0, 0, 0, 1 } })


	CreateAssesDoorButtons(screen, doors)
	screen.KeepOpen = true
	-- thread( HandleWASDInput, screen )
	HandleScreenInput(screen)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Asses_UI" })
end

function GetMapName()
	if CurrentRun.Hero.IsDead then
		return CurrentHubRoom.Name
	else
		return CurrentRun.CurrentRoom.Name
	end
end

function CreateAssesDoorButtons(screen, doors)
	local xPos = 960
	local startY = 180
	local yIncrement = 75
	local curY = startY
	local components = screen.Components
	local isFirstButton = true
	
	local healthKey = "AssesResourceMenuInformationHealth"
	components[healthKey] =
	CreateScreenComponent({
		Name = "ButtonDefault",
		Group = "Asses_UI",
		Scale = 0.8,
		X = 960,
		Y = curY
	})
	AttachLua({ Id = components[healthKey].Id, Table =components[healthKey] })

	CreateTextBox({
		Id = components[healthKey].Id,
		Text = "Health: " .. (CurrentRun.Hero.Health or 0) .. "/" .. (CurrentRun.Hero.MaxHealth or 0),
		FontSize = 24,
		OffsetX = -100,
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

	local armorKey = "AssesResourceMenuInformationArmor"
	components[armorKey] =
	CreateScreenComponent({
		Name = "ButtonDefault",
		Group = "Asses_UI",
		Scale = 0.8,
		X = 960,
		Y = curY
	})
	AttachLua({ Id = components[armorKey].Id, Table =components[armorKey] })
	CreateTextBox({
		Id = components[armorKey].Id,
		Text = "Armor: " .. (CurrentRun.Hero.HealthBuffer or 0),
		FontSize = 24,
		OffsetX = -100,
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

	local goldKey = "AssesResourceMenuInformationGold"
	components[goldKey] =
	CreateScreenComponent({
		Name = "ButtonDefault",
		Group = "Asses_UI",
		Scale = 0.8,
		X = 960,
		Y = curY
	})
	AttachLua({ Id = components[goldKey].Id, Table =components[goldKey] })
	CreateTextBox({
		Id = components[goldKey].Id,
		Text = "Gold: " .. (GameState.Resources["Money"] or 0),
		FontSize = 24,
		OffsetX = -100,
		-- OffsetY = yIncrement * 2,
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
		if string.find(GetMapName(), "D_Hub") then
			if door.Room.Name:find("D_Boss", 1, true) == 1 and GetDistance({ Id = 547487, DestinationId = 551569 }) ~= 0 then
				showDoor = false
			end
		end
		if showDoor then
			local displayText = ""
			if door.Room.ChosenRewardType == "Devotion" then
				displayText = displayText .. getDoorSound(door, false) .. " "
				displayText = displayText .. getDoorSound(door, true)
			else
				displayText = displayText .. getDoorSound(door, false)
			end
			displayText = GetDisplayName({Text=displayText:gsub("Room", ""), IgnoreSpecialFormatting=true})

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
				SetScaleX({Id = components[buttonKey].Id, Fraction=2})
			components[buttonKey].OnPressedFunctionName = "BlindAccessAssesDoorMenuSoundSet"
			AttachLua({ Id = components[buttonKey].Id, Table =components[buttonKey] })
			-- components[buttonKey].OnMouseOverFunctionName = "MouseOver"
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
				TeleportCursor({ OffsetX = xPos + 300, OffsetY = curY })
				wait(0.02)
				TeleportCursor({ OffsetX = xPos, OffsetY = curY })
				isFirstButton = false
			end
			curY = curY + yIncrement
		end
	end
end

function rom.game.BlindAccessCloseAssesDoorShowerScreen(screen, button)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters(screen.Name)
	ShowCombatUI(screen.Name)
end

function rom.game.BlindAccessAssesDoorMenuSoundSet(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/ContractorItemPurchase" })
	rom.game.BlindAccessCloseAssesDoorShowerScreen(screen, button)
	doDefaultSound(button.door)
end

function doDefaultSound(door)
	Teleport({ Id = CurrentRun.Hero.ObjectId, DestinationId = door.ObjectId })
end

function getDoorSound(door, devotionSlot)
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
		local resourceName = room.ChosenRewardType--:gsub("Progress", ""):gsub("Drop", ""):gsub("Run", "")
		if door.Name == "ShrinePointDoor" then
			resourceName = resourceName .. " (Infernal Gate)"
		end
		return resourceName
	end
end

function rom.game.BlindAccessTryOpenSimplifiedInventory(screen, button) 
	if not IsScreenOpen("BlindAccesibilityInventoryMenu") then
		local currentResources = {}
		for k,resourceName in pairs(screen.ItemCategories[screen.ActiveCategoryIndex]) do
			local amount = GameState.Resources[resourceName]
			if amount ~= nil and GetDisplayName({Text = resourceName, IgnoreSpecialFormatting=true}) ~= resourceName then
				table.insert(currentResources, {Resource = resourceName, Name = GetDisplayName({Text = resourceName, IgnoreSpecialFormatting=true}), Amount = amount})
			end
		end

		table.sort(currentResources, function(a,b) return a.Name < b.Name end)

	 	thread(CloseInventoryScreen, screen, button)
		-- thread(TraitTrayScreenClose, ActiveScreens.TraitTrayScreen)

		OpenSimplifiedInventory(currentResources)
	end
end

function OpenSimplifiedInventory(resources) 
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
	components.CloseButton.OnPressedFunctionName = "BlindAccessCloseInventoryMenu"
	components.CloseButton.ControlHotkeys = { "Cancel", }
	components.CloseButton.MouseControlHotkeys  = { "Cancel", "Inventory", }

	SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4 })
	SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0, 0, 0, 1 } })

	CreateInventoryButtons(screen, resources)
	screen.KeepOpen = true
	-- thread(HandleWASDInput, screen)
	HandleScreenInput(screen)
	-- SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Menu_UI" })

	return screen
end

function CreateInventoryButtons(screen, resources)
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
				Name = "ButtonDefault",
				Group = "Menu_UI_Inventory",
				Scale = 0.8,
				X = curX,
				Y = curY
			})
		AttachLua({ Id = components[buttonKey].Id, Table =components[buttonKey] })
		-- components[buttonKey].OnMouseOverFunctionName = "MouseOver"
		CreateTextBox({
			Id = components[buttonKey].Id,
			Text = resourceData.Name .. " : " .. resourceData.Amount,
			FontSize = 24,
			OffsetX = -100,
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
			TeleportCursor({ OffsetX = startX + 300, OffsetY = curY })
			wait(0.02)
			TeleportCursor({ OffsetX = startX, OffsetY = curY })
			isFirstButton = false
		end
		curY = curY + yIncrement
		if curY >= endY then
			curY = startY
			curX = curX + xIncrement 
		end
	end
end

function rom.game.BlindAccessCloseInventoryMenu(screen, button)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters(screen.Name)
	ShowCombatUI(screen.Name)
end

local mapPointsOfInterest = {
	Hub_Main = {
		AddNPCs = true,
		SetupFunction = function(t)
			local copy = ShallowCopyTable(t)
			local name = ""
			local objectId = nil
			for k,plot in pairs(GameState.GardenPlots) do
				if plot.GrowTimeRemaining == 0 then
					objectId = plot.ObjectId
					if plot.StoredGrows > 0 then
						name = GetDisplayName({Text = "GardenPlots", IgnoreSpecialFormatting=true}) .. " - Harvestable"
						break
					else
						name = GetDisplayName({Text = "GardenPlots", IgnoreSpecialFormatting=true}) .. " - Plantable"
					end
				end
			end
			if name ~= "" then
				table.insert(copy, {Name = name, ObjectId = objectId, DestinationOffsetX=100})
			end
			return copy
		end,
		Objects = {
			{Name = "QuestLog_Unlocked_Subtitle", ObjectId=589991},
			{Name = "GhostAdminScreen_Title", ObjectId=567390, DestinationOffsetY = 137, RequireUseable=false},
			{Name = "Broker", ObjectId=558096, DestinationOffsetX = 140, DestinationOffsetY = 35},
			{Name = "Supply Drop", ObjectId=583652, DestinationOffsetX=117, DestinationOffsetY=-64}, --No direct translation in sjson
			{Name = "Training Ground", ObjectId=587947, RequireUseable=false} --No direct translation in sjson 
			--we're cheating a little here as this is the telport to the stair object in the loading zone, as every once in a while the actual loading zone has not been found
		}
	},
	Hub_PreRun = {
		AddNPCs = true,
		SetupFunction = function(t)
			local copy = ShallowCopyTable(t)
			for index, weaponName in ipairs( WeaponSets.HeroPrimaryWeapons ) do
				local suffix = ""
				if IsBonusUnusedWeapon( weaponName ) then
					suffix = " - " .. GetDisplayName({Text = "UnusedWeaponBonusTrait", IgnoreSpecialFormatting=true})
				end
				if IsUseable({Id = MapState.WeaponKitIds[index]}) then
					table.insert(copy, {Name = GetDisplayName({Text="WeaponSet"}) .. " " .. GetDisplayName({Text=weaponName}) .. suffix, ObjectId =MapState.WeaponKitIds[index] })
				end
			end

			for index, toolName in ipairs( ToolOrderData ) do
				local kitId = MapState.ToolKitIds[index]
				if IsUseable({Id = kitId}) then
					table.insert(copy, {Name = GetDisplayName({Text = "Tool", IgnoreSpecialFormatting=true}) .. " " .. GetDisplayName({Text=toolName, IgnoreSpecialFormatting=true}), ObjectId = kitId })
				end
			end
			return copy
		end,
		Objects = {
			{Name = "TraitTray_Category_MetaUpgrades", ObjectId=587228, RequireUseable=false},
			{Name = "WeaponShop", ObjectId=558210, RequireUseable=false},
			{Name = "BountyBoard", ObjectId=561146, DestinationOffsetX=-17, DestinationOffsetY=82},
			{Name = "Keepsakes", ObjectId=421320, DestinationOffsetX=119, DestinationOffsetY=30},
			{Name = "BiomeF", ObjectId=587938, DestinationOffsetX=263, DestinationOffsetY=-293, RequireUseable=false},
			{Name = "RunHistoryScreen_RouteN", ObjectId=587935, DestinationOffsetX=-162, DestinationOffsetY=194, RequireUseable=false},
			{Name = "ShrineMenu", ObjectId=589694, DestinationOffsetY=90},
			{Name = "Hub", ObjectId=588689, RequireUseable=false},
		}
	}
}

function ProcessTable(objects)
	local t = InitializeObjectList(objects)

	local map = GetMapName()
	for map_name, map_data in pairs(mapPointsOfInterest) do
		if map_name == map or map_name == "*" then
			for _, object in pairs(map_data.Objects) do
				if object.RequireUseable == false or IsUseable({Id = object.ObjectId}) then
					local o = ShallowCopyTable(object)
					o.Name = GetDisplayName({Text=o.Name, IgnoreSpecialFormatting=true})
					table.insert(t, o)
				end
			end
			if map_data.AddNPCs and GameState and GameState.Flags and not GameState.Flags.InFlashback then
				t = AddNPCs(t)
			end
	
			if map_data.SetupFunction ~= nil then
				t = map_data.SetupFunction(t)
			end
		end
	end

	table.sort(t, function(a,b) return a.Name < b.Name end)

	if CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.ExitsUnlocked then
		t = AddTrove(t)
		t = AddWell(t)
		t = AddPool(t)
	end

	return t
end

function InitializeObjectList(objects)
	local initTable = CollapseTableOrderedByKeys(objects) or {}
	local copy = {}
	for i, v in ipairs(initTable) do
		table.insert(copy, { ["ObjectId"] = v.ObjectId, ["Name"] = v.Name })
	end
	return copy
end

function AddTrove(objects)
	if not (CurrentRun.CurrentRoom.ChallengeSwitch and IsUseable({ Id = CurrentRun.CurrentRoom.ChallengeSwitch.ObjectId })) then
		return objects
	end
	local NV = CurrentRun.CurrentRoom.ChallengeSwitch.ObjectId
	local copy = ShallowCopyTable(objects)
	local switch = {
		["ObjectId"] = CurrentRun.CurrentRoom.ChallengeSwitch.ObjectId,
		["Name"] = "Infernal Trove (" ..
			(GetDisplayName({Text = CurrentRun.CurrentRoom.ChallengeSwitch.RewardType or CurrentRun.CurrentRoom.ChallengeSwitch.RewardType, IgnoreSpecialFormatting=true})) ..
			")",
	}
	if not ObjectAlreadyPresent(switch, copy) then
		table.insert(copy, switch)
	end
	return copy
end

function AddWell(objects)
	if not (CurrentRun.CurrentRoom.WellShop and IsUseable({ Id = CurrentRun.CurrentRoom.WellShop.ObjectId })) then
		return objects
	end
	local NV = CurrentRun.CurrentRoom.WellShop.ObjectId
	local copy = ShallowCopyTable(objects)
	local well = {
		["ObjectId"] = CurrentRun.CurrentRoom.WellShop.ObjectId,
		["Name"] = "Well of Charon",
	}
	if not ObjectAlreadyPresent(well, copy) then
		table.insert(copy, well)
	end
	return copy
end

function AddPool(objects)
	if not (CurrentRun.CurrentRoom.SellTraitShop and IsUseable({ Id = CurrentRun.CurrentRoom.SellTraitShop.ObjectId })) then
		return objects
	end
	local NV = CurrentRun.CurrentRoom.SellTraitShop.ObjectId
	local copy = ShallowCopyTable(objects)
	local pool = {
		["ObjectId"] = CurrentRun.CurrentRoom.SellTraitShop.ObjectId,
		["Name"] = "Pool of Purging",
	}
	if not ObjectAlreadyPresent(pool, copy) then
		table.insert(copy, pool)
	end
	return copy
end


function AddNPCs(objects)
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
				["Name"] = GetDisplayName({Text=npcs[i].Name, IgnoreSpecialFormatting=true}),
			}
			if npcs[i].Name == "NPC_Hades_01" and GetMapName() == "Hub_Main" then --Hades in house
				if ActiveEnemies[555686] then                                       --Hades is in garden
					npc["ObjectId"] = 555686
				elseif GetDistance({ Id = npc["ObjectId"], DestinationId = 422028 }) < 100 then --Hades on his throne
					npc["DestinationOffsetY"] = 150
				end
			elseif npcs[i].Name == "NPC_Cerberus_01" and GetMapName() == "Hub_Main" and GetDistance({ Id = npc["ObjectId"], DestinationId = 422028 }) > 500 then                                                                                                 --Cerberus not present in house
				skip = true
			elseif npcs[i].Name == "NPC_Cerberus_Field_01" and TableLength(MapState.OfferedExitDoors) == 1 and CollapseTable(MapState.OfferedExitDoors)[1].Room.Name:find("D_Boss", 1, true) == 1 and GetDistance({ Id = npc["ObjectId"], DestinationId = 551569 }) == 0 then --Cerberus in Styx after having been given satyr sack
				skip = true
			end
			if not ObjectAlreadyPresent(npc, copy) and not skip then
				table.insert(copy, npc)
			end
		end
	end
	return copy
end

function ObjectAlreadyPresent(object, objects)
	found = false
	for k, v in ipairs(objects) do
		if object.ObjectId == v.ObjectId then
			found = true
		end
	end
	if CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.Store and NumUseableObjects(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems) > 0 then
		for k, v in pairs(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems) do
			if object.ObjectId == v.ObjectId and v.Name ~= "ForbiddenShopItem" then
				found = true
			end
		end
	end
	return found
end

function TableInsertAtBeginning(baseTable, insertValue)
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

function OpenRewardMenu(rewards)
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
	components.CloseButton.OnPressedFunctionName = "BlindAccessCloseRewardMenu"
	components.CloseButton.ControlHotkeys = { "Cancel", }
	components.CloseButton.MouseControlHotkeys  = { "Cancel", }

	SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4 })
	SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0, 0, 0, 1 } })

	CreateRewardButtons(screen, rewards)
	screen.KeepOpen = true
	-- thread(HandleWASDInput, screen)
	HandleScreenInput(screen)
	-- SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Menu_UI" })
end

function CreateRewardButtons(screen, rewards)
	local xPos = 960
	local startY = 235
	local yIncrement = 55
	local curY = startY
	local components = screen.Components
	local isFirstButton = true
	if not string.find(GetMapName(), "Hub_PreRun") and GetMapName():find("Hub_Main", 1, true) ~= 1 and GetMapName():find("E_", 1, true) ~= 1 then
		local healthKey = "AssesResourceMenuInformationHealth"
		components[healthKey] =
		CreateScreenComponent({
			Name = "ButtonDefault",
			Group = "Asses_UI",
			Scale = 0.8,
			X = 960,
			Y = curY
		})
		AttachLua({ Id = components[healthKey].Id, Table =components[healthKey] })
	
		CreateTextBox({
			Id = components[healthKey].Id,
			Text = "Health: " .. (CurrentRun.Hero.Health or 0) .. "/" .. (CurrentRun.Hero.MaxHealth or 0),
			FontSize = 24,
			OffsetX = -100,
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
	
		local armorKey = "AssesResourceMenuInformationArmor"
		components[armorKey] =
		CreateScreenComponent({
			Name = "ButtonDefault",
			Group = "Asses_UI",
			Scale = 0.8,
			X = 960,
			Y = curY
		})
		AttachLua({ Id = components[armorKey].Id, Table =components[armorKey] })
		CreateTextBox({
			Id = components[armorKey].Id,
			Text = "Armor: " .. (CurrentRun.Hero.HealthBuffer or 0),
			FontSize = 24,
			OffsetX = -100,
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
	
		local goldKey = "AssesResourceMenuInformationGold"
		components[goldKey] =
		CreateScreenComponent({
			Name = "ButtonDefault",
			Group = "Asses_UI",
			Scale = 0.8,
			X = 960,
			Y = curY
		})
		AttachLua({ Id = components[goldKey].Id, Table =components[goldKey] })
		CreateTextBox({
			Id = components[goldKey].Id,
			Text = "Gold: " .. (GameState.Resources["Money"] or 0),
			FontSize = 24,
			OffsetX = -100,
			-- OffsetY = yIncrement * 2,
			Color = Color.White,
			Font = "P22UndergroundSCMedium",
			Group = "Asses_UI",
			ShadowBlur = 0,
			ShadowColor = { 0, 0, 0, 1 },
			ShadowOffset = { 0, 2 },
			Justification = "Left",
		})
		curY = curY + yIncrement
	else
		startY = 110
		curY = startY
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
				SetScaleX({Id = components[buttonKey].Id, Fraction=4})
			
			AttachLua({ Id = components[buttonKey].Id, Table =components[buttonKey] })
			-- components[buttonKey].OnMouseOverFunctionName = "MouseOver"

			components[buttonKey].index = k
			components[buttonKey].reward = {ObjectId = reward.Id}
			components[buttonKey].OnPressedFunctionName = "BlindAccessGoToReward"
			if reward.Args ~= nil and reward.Args.ForceLootName then
				displayText = reward.Args.ForceLootName--:gsub("Upgrade", ""):gsub("Drop", "")
			end
			-- displayText = displayText:gsub("Drop", ""):gsub("StoreReward", "") or displayText
			--displayText = (displayText .. GetWeaponDisplayConditions(reward.Name)) or displayText
			CreateTextBox({
				Id = components[buttonKey].Id,
				Text = displayText,
				FontSize = 24,
				OffsetX = -100,
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
				TeleportCursor({ OffsetX = xPos + 300, OffsetY = curY })
				wait(0.02)
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
				SetScaleX({Id = components[buttonKey].Id, Fraction=4})
			AttachLua({ Id = components[buttonKey].Id, Table =components[buttonKey] })
			-- components[buttonKey].OnMouseOverFunctionName = "MouseOver"
			components[buttonKey].index = k
			components[buttonKey].reward = reward
			components[buttonKey].OnPressedFunctionName = "BlindAccessGoToReward"
			if reward.Args ~= nil and reward.Args.ForceLootName then
				displayText = reward.Args.ForceLootName--:gsub("Upgrade", ""):gsub("Drop", "")
			end
			-- displayText = displayText:gsub("Drop", ""):gsub("StoreReward", "") or displayText
			--displayText = (displayText .. GetWeaponDisplayConditions(reward.Name)) or displayText
			CreateTextBox({
				Id = components[buttonKey].Id,
				Text = GetDisplayName({Text=displayText, IgnoreSpecialFormatting=true}),
				FontSize = 24,
				OffsetX = -200,
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
				TeleportCursor({ OffsetX = xPos + 300, OffsetY = curY })
				wait(0.02)
				TeleportCursor({ OffsetX = xPos, OffsetY = curY })
				isFirstButton = false
			end
			curY = curY + yIncrement
		end
	end
end

-- function MouseOver(screen, button)
-- 	--Does nothing just exists so that the OnMouseOver functionality of the modified UI script using TOLk interacts with the button
-- 	--without setting this the OnMouseover trigger is returned out of before TOLk is called
-- 	--Not needed if using the thunderstore version of TOLk compatability
-- end

function rom.game.BlindAccessGoToReward(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/ContractorItemPurchase" })
	rom.game.BlindAccessCloseRewardMenu(screen, button)
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

function rom.game.BlindAccessCloseRewardMenu(screen, button)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters(screen.Name)
	ShowCombatUI(screen.Name)
end


function NumUseableObjects(objects)
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

function OpenStoreMenu(items)
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
	components.CloseButton.OnPressedFunctionName = "BlindAccessCloseItemScreen"
	components.CloseButton.ControlHotkeys = { "Cancel", }
	components.CloseButton.MouseControlHotkeys  = { "Cancel", }

	SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4 })
	SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0, 0, 0, 1 } })

	CreateItemButtons(screen, items)
	screen.KeepOpen = true
	HandleScreenInput(screen)
	-- SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Asses_UI_Store" })
end

function CreateItemButtons(screen, items)
	local xPos = 960
	local startY = 235
	local yIncrement = 75
	local curY = startY
	local components = screen.Components
	local isFirstButton = true
	local healthKey = "AssesResourceMenuInformationHealth"
	components[healthKey] =
	CreateScreenComponent({
		Name = "ButtonDefault",
		Group = "Asses_UI_Store",
		Scale = 0.8,
		X = 960,
		Y = curY
	})
	AttachLua({ Id = components[healthKey].Id, Table =components[healthKey] })

	CreateTextBox({
		Id = components[healthKey].Id,
		Text = "Health: " .. (CurrentRun.Hero.Health or 0) .. "/" .. (CurrentRun.Hero.MaxHealth or 0),
		FontSize = 24,
		OffsetX = -100,
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

	local armorKey = "AssesResourceMenuInformationArmor"
	components[armorKey] =
	CreateScreenComponent({
		Name = "ButtonDefault",
		Group = "Asses_UI_Store",
		Scale = 0.8,
		X = 960,
		Y = curY
	})
	AttachLua({ Id = components[armorKey].Id, Table =components[armorKey] })
	CreateTextBox({
		Id = components[armorKey].Id,
		Text = "Armor: " .. (CurrentRun.Hero.HealthBuffer or 0),
		FontSize = 24,
		OffsetX = -100,
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

	local goldKey = "AssesResourceMenuInformationGold"
	components[goldKey] =
	CreateScreenComponent({
		Name = "ButtonDefault",
		Group = "Asses_UI_Store",
		Scale = 0.8,
		X = 960,
		Y = curY
	})
	AttachLua({ Id = components[goldKey].Id, Table =components[goldKey] })
	CreateTextBox({
		Id = components[goldKey].Id,
		Text = "Gold: " .. (GameState.Resources["Money"] or 0),
		FontSize = 24,
		OffsetX = -100,
		-- OffsetY = yIncrement * 2,
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
			components[buttonKey].OnPressedFunctionName = "BlindAccessMoveToItem"
			AttachLua({ Id = components[buttonKey].Id, Table =components[buttonKey] })
			-- components[buttonKey].OnMouseOverFunctionName = "MouseOver"

			if displayText == "RandomLoot" then
				if LootObjects[item.ObjectId] ~= nil then
					displayText = LootObjects[item.ObjectId].Name
				end
			end
			displayText = displayText:gsub("RoomReward", ""):gsub("StoreReward", "") or displayText
			CreateTextBox({
				Id = components[buttonKey].Id,
				Text = GetDisplayName({Text=displayText, IgnoreSpecialFormatting=true}),
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
				TeleportCursor({ OffsetX = xPos + 300, OffsetY = curY })
				wait(0.02)
				TeleportCursor({ OffsetX = xPos, OffsetY = curY })
				isFirstButton = false
			end
			curY = curY + yIncrement
		end
	end
end

function rom.game.BlindAccessMoveToItem(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/ContractorItemPurchase" })
	rom.game.BlindAccessCloseItemScreen(screen, button)
	local ItemID = button.item.ObjectId
	if ItemID ~= nil then
		Teleport({ Id = CurrentRun.Hero.ObjectId, DestinationId = ItemID })
	end
end

function rom.game.BlindAccessCloseItemScreen(screen, button)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters(screen.Name)
	ShowCombatUI(screen.Name)
end

function CreateArcanaSpeechText(button, args, buttonArgs)
	local c = DeepCopyTable(args)
	c.SkipWrap = true
	if button.OnMouseOverFunctionName == "MouseOverMetaUpgrade" then
		DestroyTextBox({ Id = button.Id })
		local cardName = button.CardName
		local metaUpgradeData = MetaUpgradeCardData[cardName]
		
		c.UseDescription = false

		local state = "HIDDEN"
		if buttonArgs.CardState then
			state = buttonArgs.CardState
		else
			if GameState.MetaUpgradeState[cardName].Unlocked then
				state = "UNLOCKED"
			elseif HasNeighboringUnlockedCards( buttonArgs.Row, buttonArgs.Column ) or (buttonArgs.Row == 1 and buttonArgs.Column == 1) then
				state = "LOCKED"
			end
		end
		
		local stateText = GetDisplayName({Text="AwardMenuLocked", IgnoreSpecialFormatting=true})
		if state == "UNLOCKED" then
			stateText = GetDisplayName({Text = "Off", IgnoreSpecialFormatting=true})
			if GameState.MetaUpgradeState[cardName].Equipped then
				stateText = GetDisplayName({Text = "On", IgnoreSpecialFormatting=true})
			end
		end


		c.Text = GetDisplayName({Text = c.Text, IgnoreSpecialFormatting=true}) .. ", State: " .. stateText .. ", "
		c.Text = c.Text .. GetDisplayName({Text = "CannotUseChaosWeaponUpgrade", IgnoreSpecialFormatting=true}) .. metaUpgradeData.Cost .. GetDisplayName({Text="IncreaseMetaUpgradeCard", IgnoreSpecialFormatting=true}) .. ", "
		if state == "LOCKED" then
			local costText = GetDisplayName({Text = "CannotUseChaosWeaponUpgrade", IgnoreSpecialFormatting=true}) --cheating here, this is just "Requires: {Hammer Icon}" and we just remove the Hammer Icon

			local totalResourceCosts = MetaUpgradeCardData[button.CardName].ResourceCost
			for resource, cost in pairs(totalResourceCosts) do
				costText = costText .. " " .. cost .. " " .. GetDisplayName({Text = resource, IgnoreSpecialFormatting=true})
			end
			c.Text = c.Text .. costText
		end
		
		CreateTextBox(c)
		CreateTextBox({
			Id = c.Id,
			Text = args.Text,
			UseDescription = true,
			LuaKey = c.LuaKey,
			LuaValue = c.LuaValue,
			SkipDraw = true,
			SkipWrap = true,
			Color = Color.Transparent
		})
		CreateTextBox({
			Id = c.Id,
			Text = metaUpgradeData.AutoEquipText,
			SkipDraw = true,
			SkipWrap = true,
			Color = Color.Transparent
		})

		return nil
	else
		local cardTitle = button.CardName
		local cardMultiplier = 1
		if GameState.MetaUpgradeState[ cardTitle ].AdjacencyBonuses and GameState.MetaUpgradeState[ cardTitle ].AdjacencyBonuses.CustomMultiplier then
			cardMultiplier = cardMultiplier + GameState.MetaUpgradeState[ cardTitle ].AdjacencyBonuses.CustomMultiplier
		end
		local cardData = {}
		if MetaUpgradeCardData[cardTitle].TraitName then
			cardData = GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = MetaUpgradeCardData[cardTitle].TraitName , Rarity = TraitRarityData.RarityUpgradeOrder[ GetMetaUpgradeLevel( cardTitle )], CustomMultiplier = cardMultiplier })
			local nextLevelCardData = GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = MetaUpgradeCardData[cardTitle].TraitName , Rarity = TraitRarityData.RarityUpgradeOrder[ GetMetaUpgradeLevel( cardTitle ) + 1], CustomMultiplier = cardMultiplier })
			SetTraitTextData( cardData, { ReplacementTraitData = nextLevelCardData })
		end
		if TraitData[MetaUpgradeCardData[cardTitle].TraitName].CustomUpgradeText then
			cardTitle = TraitData[MetaUpgradeCardData[cardTitle].TraitName].CustomUpgradeText
		end
		
			local costText = ""
			if CanUpgradeMetaUpgrade( button.CardName ) then 
			local state = "HIDDEN"
			if buttonArgs.CardState then
				state = buttonArgs.CardState
			else
				if GameState.MetaUpgradeState[button.CardName].Unlocked then
					state = "UNLOCKED"
				elseif HasNeighboringUnlockedCards( buttonArgs.Row, buttonArgs.Column ) or (buttonArgs.Row == 1 and buttonArgs.Column == 1) then
					state = "LOCKED"
				end
			end

			if state == "UNLOCKED" then
				costText = GetDisplayName({Text = "CannotUseChaosWeaponUpgrade", IgnoreSpecialFormatting=true}) --cheating here, this is just "Requires: {Hammer Icon}" and we just remove the Hammer Icon

				local totalResourceCosts = MetaUpgradeCardData[button.CardName].UpgradeResourceCost[GetMetaUpgradeLevel( button.CardName )]
				for resource, cost in pairs(totalResourceCosts) do
					costText = costText .. " " .. cost .. " " .. GetDisplayName({Text = resource, IgnoreSpecialFormatting=true})
				end
			end
		end

		c.Id = button.Id
		c.Text = cardTitle
		c.UseDescription = true
		c.LuaKey = "TooltipData"
		c.LuaValue = cardData
		CreateTextBox({
			Id = c.Id,
			Text = GetDisplayName({Text = args.Text, IgnoreSpecialFormatting=true}) .. ", " .. costText,
			SkipDraw = true,
			SkipWrap = true,
			Color = Color.Transparent
		})
		CreateTextBox(c)
	end
end

function OnExitDoorUnlocked()
	if TableLength(MapState.OfferedExitDoors) == 1 then
		if GetDistance({ Id = 547487, DestinationId = 551569 }) == 0 then
			return
		elseif GetDistance({ Id = 547487, DestinationId = 551569 }) ~= 0 and GetDistance({ Id = CurrentRun.Hero.ObjectId, DestinationId = 547487 }) < 1000 then
			return
		end
	end
	local rewardsTable = ProcessTable(LootObjects)
	if TableLength(rewardsTable) > 0 then
		PlaySound({ Name = "/Leftovers/SFX/AnnouncementPing" })
		return
	end
	local curMap = GetMapName()
	if curMap == nil or string.find(curMap, "PostBoss") or string.find(curMap, "Hub_Main") or string.find(curMap, "Shop") or string.find(curMap, "D_Hub") or (string.find(curMap, "PreBoss") and CurrentRun.CurrentRoom.Store ~= nil and CurrentRun.CurrentRoom.Store.SpawnedStoreItems ~= nil) then
		return
	end
	OpenAssesDoorShowerMenu(CollapseTable(MapState.OfferedExitDoors))
end

function OnCodexPress()
	if IsScreenOpen("TraitTrayScreen") then
		local rewardsTable = {}
		local curMap = GetMapName()

		--shop menu
		if string.find(curMap, "Shop") or string.find(curMap, "PreBoss") or string.find(curMap, "D_Hub") then
			if CurrentRun.CurrentRoom.Store == nil then
				return
			elseif NumUseableObjects(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems) == 0 then
				return
			end
			thread(TraitTrayScreenClose, ActiveScreens.TraitTrayScreen)
			OpenStoreMenu(CurrentRun.CurrentRoom.Store.SpawnedStoreItems or MapState.SurfaceShopItems)
			return
		end

		if string.find(curMap, "Hub_PreRun") then
			rewardsTable = ProcessTable(MapState.WeaponKits)
		else
			rewardsTable = ProcessTable(ModUtil.Table.Merge(LootObjects, MapState.RoomRequiredObjects))
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
			OpenRewardMenu(rewardsTable)
		else
			return
		end
	end
end

function OnAdvancedTooltipPress()
	if IsEmpty( ActiveScreens ) then
		if not IsEmpty( MapState.CombatUIHide ) or not IsInputAllowed({}) then
			-- If no screen is open, controlled entirely by input status
			return
		end
	end

	local rewardsTable = {}
	if CurrentRun.Hero.IsDead and not IsScreenOpen("InventoryScreen") and not IsScreenOpen("BlindAccesibilityInventoryMenu") then
		rewardsTable = ProcessTable(ModUtil.Table.Merge(LootObjects, MapState.RoomRequiredObjects))
		if TableLength(rewardsTable) > 0 then
			if not IsEmpty(ActiveScreens.TraitTrayScreen) then
					thread(TraitTrayScreenClose, ActiveScreens.TraitTrayScreen)
			end
			OpenRewardMenu(rewardsTable)
		end
	end
end

function wrap_GetDisplayName(baseFunc, args)
	v = baseFunc(args)
	if args.IgnoreSpecialFormatting then
		return v:gsub("{[#!][^}]+}", "")
	end
	return v
end

function wrap_TraitTrayScreenShowCategory(baseFunc, screen, categoryIndex, args)
	if not screen.Closing then
		return baseFunc(screen, categoryIndex, args)
	end
end

function override_SpawnStoreItemInWorld(itemData, kitId)
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
end

function wrap_MetaUpgradeCardAction(screen, button)
	local selectedButton = button
	local cardName = selectedButton.CardName
	local metaUpgradeData = MetaUpgradeCardData[cardName]

	CreateArcanaSpeechText(selectedButton, { Id = selectedButton.Id,
		Text = metaUpgradeData.Name,
		SkipDraw = true,
		Color = Color.Transparent,
		UseDescription = true,
		LuaKey = "TooltipData",
		LuaValue = selectedButton.TraitData or {},
	}, {CardState = selectedButton.CardState})

end

function wrap_UpdateMetaUpgradeCardCreateTextBox(baseFunc, screen, row, column, args)
    if args.SkipDraw and not args.SkipWrap then
        if args.LuaKey == nil then
            return
        end
        local button = screen.Components[GetMetaUpgradeKey( row, column )]

        CreateArcanaSpeechText(button, args, {Row=row, Column=column})
        return nil
    else
        return baseFunc(args, screen, row, column, args)
    end
end

function wrap_UpdateMetaUpgradeCard(screen, row, column)
	local components = screen.Components
	local button = components.MemCostModule
	if button.Id then
		local nextCostData = MetaUpgradeCostData.MetaUpgradeLevelData[GetCurrentMetaUpgradeLimitLevel() + 1 ].ResourceCost
		local nextMetaUpgradeLevel = MetaUpgradeCostData.MetaUpgradeLevelData[GetCurrentMetaUpgradeLimitLevel() + 1 ]

		local costText = GetDisplayName({Text = "CannotUseChaosWeaponUpgrade", IgnoreSpecialFormatting=true}) --cheating here, this is just "Requires: {Hammer Icon}" and we just remove the Hammer Icon

		for resource, cost in pairs(nextCostData) do
			costText = costText .. " " .. cost .. " " .. GetDisplayName({Text = resource, IgnoreSpecialFormatting=true})
		end

		DestroyTextBox({Id = button.Id})
		CreateTextBox({
			Id = button.Id,
			Text = GetDisplayName({Text="IncreaseMetaUpgradeCard", IgnoreSpecialFormatting=true}) .. ", " .. costText,
			SkipDraw = true,
			Color = Color.Transparent
		})
		CreateTextBox({
			Id = button.Id,
			Text = "IncreaseMetaUpgradeCard",
			SkipDraw = true,
			Color = Color.Transparent,
			UseDescription = true, LuaKey = "TempTextData", LuaValue = { Amount = nextMetaUpgradeLevel.CostIncrease}
		})
	end
end

function wrap_OpenGraspLimitAcreen()
    local components = ActiveScreens.GraspLimitLayout.Components

    local buttonKey = "GraspReadUIButton"
    components[buttonKey] = CreateScreenComponent({
        Name="ButtonDefault",
        Group="Combat_Menu_TraitTray",
        X = 600,
        Y = 100
    })
    -- components[buttonKey].OnMouseOverFunctionName = "MouseOver"
    AttachLua({ Id = components[buttonKey].Id, Table =components[buttonKey] })

    CreateTextBox({
        Id = components[buttonKey].Id,
        Text = "MetaUpgradeTable_UnableToEquip",
        UseDescription = true,
    })

    thread(function()
        wait(0.02)
        TeleportCursor({DestinationId=components[buttonKey].Id})
    end)
end



function sjson_Chronos(data) 
	for k,v in ipairs(data.Projectiles) do
			if v.Name == "ChronosCircle" or v.Name == "ChronosCircleInverted" then
				v.Damage = 50
			end
	end
end