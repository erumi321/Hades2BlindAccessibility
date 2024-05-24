---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

if not config.Enabled then return end

--[[
Mod: DoorMenu
Author: hllf & JLove
Version: 29

Intended as an accessibility mod. Places all doors in a menu, allowing the player to select a door and be teleported to it.
--]]

local function setupData()
	modutil.Table.Merge(ScreenData, {
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
			OnPressedFunctionName = "BlindAccess.TryOpenSimplifiedInventory",
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

modutil.mod.Path.Wrap("TraitTrayScreenShowCategory", function(baseFunc, ...)
	wrap_TraitTrayScreenShowCategory(baseFunc, ...)
end)

modutil.mod.Path.Wrap("GetDisplayName", function(baseFunc, args)
	wrap_GetDisplayName(baseFunc, args)
end)

modutil.mod.Path.Override("SpawnStoreItemInWorld", function(itemData, kitId)
	override_SpawnSotreItemInWorld(itemData, kitId)
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

modutil.mod.Path.Context.Wrap("OpenGraspLimitScreen", function(parentScreen)
	modutil.mod.Path.Wrap("HandleScreenInput", function(baseFunc, ...)
		wrap_OpenGraspLimitAcreen()

		return baseFunc(...)
	end)
end)

setupData()
