---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

if not config.enabled then return end

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
		BlindAccesibilityInventoryMenu = {
			Components = {},
			BlockPause=true,
			Name = "BlindAccesibilityInventoryMenu"
		}
	})
	ScreenData.InventoryScreen.ComponentData.ActionBar.Children.CloseButton.Data.MouseControlHotkeys = {"Cancel"}
	ScreenData.InventoryScreen.ComponentData.ActionBar.Children.OpenAccessibleInventory = {
		Graphic = "ContextualActionButton",
		GroupName = "Combat_Menu_Overlay",
		BottomOffset = UIData.ContextualButtonBottomOffset,
		Data =
		{
			OnMouseOverFunctionName = "MouseOverContextualAction",
			OnMouseOffFunctionName = "MouseOffContextualAction",
			OnPressedFunctionName = "BlindAccessTryOpenSimplifiedInventory",
			ControlHotkeys = { "Inventory", },
			MouseControlHotkeys  = { "Inventory" },
		},
		Text = "",
		TextArgs = UIData.ContextualButtonFormatRight,
	}
end

OnControlPressed { "Inventory", function(triggerArgs)
	OnInventoryPress()
end }

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

local projectilePath = rom.path.combine(rom.paths.Content, 'Game/Projectiles/EnemyProjectiles.sjson')

sjson.hook(projectilePath, function(data)
	return sjson_Chronos(data)
end)

setupData()
