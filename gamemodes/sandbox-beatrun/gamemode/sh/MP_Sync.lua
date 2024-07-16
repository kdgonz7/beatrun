if CLIENT then
  hook.Add("InitPostEntity", "JoinSync", function()
    net.Start("JoinSync")
    net.SendToServer()
  end)
end

if SERVER then
  util.AddNetworkString("JoinSync")
  net.Receive("JoinSync", function(len, ply) if not ply.Synced then ply.Synced = true end end)
end