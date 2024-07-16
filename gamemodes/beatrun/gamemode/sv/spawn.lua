DEFINE_BASECLASS("gamemode_base")

// yonked from dark rp

// fp is a function wrapper that automatically unpacks arguments into a table,
// this is useful for situations where you want to pass an argument list to
// another function in the same way as lua tables are unpacked, but don't want
// to have to check for the number of arguments each time. This is especially
// useful for defining functions in tables.
//
// tbl is a table where the first element is the function to be called, and the
// rest are the arguments to be unpacked onto the front of the arguments passed
// to the function.
//
// ... is the arguments passed to the function
//
// The return value is the function itself, which unpacks its arguments into
// fnArgs before calling the function with tbl as the first argument.
//
function fp(tbl)
	local func = tbl[1]

	return function(...)
		local fnArgs = {}
		local arg = {...}
		local tblN = table.maxn(tbl)

		for i = 2, tblN do fnArgs[i - 1] = tbl[i] end
		for i = 1, table.maxn(arg) do fnArgs[tblN + i - 1] = arg[i] end

		return func(unpack(fnArgs, 1, table.maxn(fnArgs)))
	end
end

function GM:PlayerSpawn(ply, transition)
	player_manager.SetPlayerClass(ply, "player_beatrun")

	ply:StripAmmo()

	BaseClass.PlayerSpawn(self, ply, transition)
end