AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

for _, v in ipairs(file.Find("gamemodes/sandbox-beatrun/gamemode/cl/*.lua", "GAME")) do
	AddCSLuaFile("cl/" .. v)
end

for _, v in ipairs(file.Find("gamemodes/sandbox-beatrun/gamemode/sh/*.lua", "GAME")) do
	AddCSLuaFile("sh/" .. v)
	include("sh/" .. v)
end

for _, v in ipairs(file.Find("gamemodes/sandbox-beatrun/gamemode/sv/*.lua", "GAME")) do
	include("sv/" .. v)
end

print("BTR v1.0.3-kai")
