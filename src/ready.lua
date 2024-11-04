---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

--[[
Mod: DoorMenu
Author: hllf & JLove
Version: 29

Intended as an accessibility mod. Places all doors in a menu, allowing the player to select a door and be teleported to it.
--]]

local function setupData()
	ModUtil.Table.Merge(ScreenData, {
		BlindAccessibilityRewardMenu = {
			Components = {},
			BlockPause=true,
			Name = "BlindAccessibilityRewardMenu"
		},
		BlindAccesibilityDoorMenu = {
			Components = {},
			BlockPause=true,
			Name = "BlindAccesibilityDoorMenu"
		},
		BlindAccesibilityStoreMenu = {
			Components = {},
			BlockPause=true,
			Name = "BlindAccesibilityStoreMenu"
		},
	})
end

OnControlPressed { "Inventory", function(triggerArgs)
	OnInventoryPress()
end }

modutil.mod.Path.Wrap("InventoryScreenDisplayCategory", function(baseFunc, screen, categoryIndex, args)
	local ret = baseFunc(screen, categoryIndex, args)
	wrap_InventoryScreenDisplayCategory(screen, categoryIndex, args)
	return ret
end)

modutil.mod.Path.Wrap("ExitDoorUnlockedPresentation", function(baseFunc, exitDoor)
	local ret = baseFunc(exitDoor)
	OnExitDoorUnlocked()
	return ret
end)

OnControlPressed { "Codex", function(triggerArgs)
	OnCodexPress()

end }

OnControlPressed { "AdvancedTooltip", function(triggerArgs)
	OnAdvancedTooltipPress()
end }

modutil.mod.Path.Wrap("TraitTrayScreenShowCategory", function(baseFunc, screen, categoryIndex, args)
	return wrap_TraitTrayScreenShowCategory(baseFunc, screen, categoryIndex, args)
end)

modutil.mod.Path.Wrap("GetDisplayName", function(baseFunc, args)
	return wrap_GetDisplayName(baseFunc, args)
end)

modutil.mod.Path.Override("SpawnStoreItemInWorld", function(itemData, kitId)
	return override_SpawnStoreItemInWorld(itemData, kitId)
end)

--arcana menu button speaking

modutil.mod.Path.Wrap("MetaUpgradeCardAction", function(baseFunc, screen, button)
	local rV = baseFunc(screen, button)
	wrap_MetaUpgradeCardAction(screen, button)
	return rV
end)

modutil.mod.Path.Context.Wrap("UpdateMetaUpgradeCard", function(screen, row, column)
	modutil.mod.Path.Wrap("CreateTextBox", function(baseFunc, args, ...)
		return wrap_UpdateMetaUpgradeCardCreateTextBox(baseFunc, screen, row, column, args)
	end)
end)

modutil.mod.Path.Wrap("UpdateMetaUpgradeCard", function(baseFunc, screen, row, column)
	wrap_UpdateMetaUpgradeCard(screen, row, column)
	return baseFunc(screen, row, column)
end)

modutil.mod.Path.Wrap("IncreaseMetaUpgradeCardLimit", function(baseFunc, screen, ...)
	local ret = baseFunc(screen, ...)
	wrap_UpdateMetaUpgradeCard(screen)
	return ret
end)

modutil.mod.Path.Context.Wrap("OpenGraspLimitScreen", function(parentScreen)
	modutil.mod.Path.Wrap("HandleScreenInput", function(baseFunc, ...)
		wrap_OpenGraspLimitAcreen()

		return baseFunc(...)
	end)
end)

modutil.mod.Path.Wrap("ShipsSteeringWheelChoicePresentation", function(baseFunc, ...)
	thread(function()
		wait(0.1)
		OpenAssesDoorShowerMenu(CollapseTable(MapState.ShipWheels))
	end)
	return baseFunc(...)
end)

modutil.mod.Path.Wrap("GhostAdminDisplayCategory", function(baseFunc, screen, button)
	local ret = baseFunc(screen, button)
	
	wrap_GhostAdminDisplayCategory(screen, button)

	return ret
end)

modutil.mod.Path.Override("GhostAdminScreenRevealNewItemsPresentation", function(screen, button)
	return override_GhostAdminScreenRevealNewItemsPresentation( screen, button )
end)

modutil.mod.Path.Wrap("MarketScreenDisplayCategory", function(baseFunc, screen, categoryIndex)
	local ret = baseFunc(screen, categoryIndex)
	wrap_MarketScreenDisplayCategory(screen, categoryIndex)
	return ret
end)

modutil.mod.Path.Override("CreateSurfaceShopButtons", function(screen)
	return override_CreateSurfaceShopButtons(screen)
end)

modutil.mod.Path.Context.Wrap("HandleSurfaceShopAction", function(screen, button)
	modutil.mod.Path.Wrap("SwitchToSpeedupPresentation", function(baseFunc, ...) --we do this so that the wrap only happens if all of the inbuilt logic passes to purchase the item
		wrap_HandleSurfaceShopAction(screen, button)
		return baseFunc(...)
	end)

end)

modutil.mod.Path.Context.Wrap("CreateKeepsakeIcon", function(screen, components, keepsakeArgs)
	modutil.mod.Path.Wrap("CreateTextBox", function(baseFunc, args)
		if args.ignoreWrap == true then
			return baseFunc(args)
		end
		 wrap_CreateKeepsakeIconText(args, keepsakeArgs)
		 return baseFunc(args)
	end)

end)

modutil.mod.Path.Context.Wrap("CreateStoreButtons", function(screen)
	modutil.mod.Path.Wrap("CreateTextBox", function(baseFunc, args)
		return wrap_CreateStoreButtons(baseFunc, args)
	end)
end)

modutil.mod.Path.Context.Wrap("CreateSpellButtons", function(screen)
	modutil.mod.Path.Wrap("CreateTextBox", function(baseFunc, args)
		return wrap_CreateSpellButtons(baseFunc, args)
	end)
end)

modutil.mod.Path.Wrap("CreateTalentTreeIcons", function(baseFunc, screen, args)
	local ret = baseFunc(screen, args)
	wrap_CreateTalentTreeIcons(screen, args)
	return ret
end)

modutil.mod.Path.Wrap("UpdateTalentButtons", function(baseFunc, screen, skipUsableCheck )
	local ret = baseFunc(screen, skipUsableCheck)
	wrap_UpdateTalentButtons(screen, skipUsableCheck)
	return ret
end)

modutil.mod.Path.Context.Wrap("HighlightTalentButton", function( button )
	modutil.mod.Path.Wrap("ModifyTextBox", function(baseFunc, args)
		return nil
	end)
end)

modutil.mod.Path.Override("HecateHideAndSeekExit", function(source, args)
	override_HecateHideAndSeekExit(source, args)
end)

modutil.mod.Path.Wrap("UseableOff", function(baseFunc, args)
	return wrap_UseableOff(baseFunc, args)
end)

modutil.mod.Path.Override("ExorcismSequence", function(source, exorcismData, args, user )
	return override_ExorcismSequence(source, exorcismData, args, user)
end)

local projectilePath = rom.path.combine(rom.paths.Content, 'Game/Projectiles/EnemyProjectiles.sjson')

sjson.hook(projectilePath, function(data)
	return sjson_Chronos(data)
end)

setupData()
