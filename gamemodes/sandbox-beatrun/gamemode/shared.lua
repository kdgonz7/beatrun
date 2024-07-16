VERSIONGLOBAL = "v1.0.2-kai"

DeriveGamemode("sandbox")

GM.Name = "Kai's BeatRun"
GM.Author = "Kai D."
GM.Email = "<gkai70263@gmail.com>"
GM.Website = ""

include("player_class/player_beatrun.lua")

for _, v in ipairs(file.Find("gamemodes/sandbox-beatrun/gamemode/sh/*.lua", "GAME", "nameasc")) do
	AddCSLuaFile("sh/" .. v)
	include("sh/" .. v)
end