util.AddNetworkString("DisarmStart")

local function Disarm(ply, ent)
end

hook.Add("PlayerUse", "Disarm", Disarm)

hook.Add("CreateEntityRagdoll", "Disarm_Ragdoll", function(ent, rag)
	if ent.InDisarm then
		rag:Remove()
	end
end)