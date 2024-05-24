---@meta _
---@diagnostic disable

local sjson = rom.mods['SGG_Modding-SJSON']
local projectilePath = rom.path.combine(rom.paths.Content, 'Game/Projectiles/EnemyProjectiles.sjson')

sjson.hook(guiPath, function(data)
	for _,v in pairs(data) do
		print(v)
	end
end)
