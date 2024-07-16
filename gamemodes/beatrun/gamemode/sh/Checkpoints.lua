Checkpoints = Checkpoints or {}
CheckpointNumber = CheckpointNumber or 1

Course_StartTime = 0
Course_GoTime = 0
Course_EndTime = 0

Course_ID = Course_ID or ""
Course_Name = Course_Name or ""

local cptimes = {}

if CLIENT then
	CreateClientConVar("Beatrun_ShowSpeedometer", 1, true, true, language.GetPhrase("#beatrun.convars.showspeedometer"), 0, 1)
end

if CLIENT then
	CreateClientConVar("Beatrun_FastStart", "0", true, true, language.GetPhrase("beatrun.convars.faststart"), 0, 1)
end

function StartCourse(spawntime)
	table.Empty(cptimes)

	CheckpointNumber = 1
	countdown = 0
	countdownalpha = 255
	lastcptime = Course_StartTime

	hook.Remove("Think", "StartCountdown")
	hook.Remove("HUDPaint", "StartCountdownHUD")
	hook.Remove("StartCommand", "StartFreeze")
end

net.Receive("BeatrunSpawn", function()
	hook.Run("BeatrunSpawn")
end)