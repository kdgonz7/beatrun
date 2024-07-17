# Sandboxified Beatrun

A personal version of beatrun, a fork of the one by Jony Bro, which removes any sort of net-related features, as well as any unused features.

As somebody who is experienced in compiler design, and also Garry's Mod, I felt taking this addon and modifying it to run faster and more optimized was a good way to take it.

This version of beatrun, albeit much smaller, also yields better FPS in certain instances.

## What is REMOVED?

* All of the telemetry and network sharing related modules
    * (any malice code, Discord RPC, Steam RPC, )
* All entities related to map making (the map making system is disabled)
    * Swingbar, RabbitBunny (Whatever that was), and more 
      level-based objects are deleted.
* The Map Database (This gamemode now sends absolutely **0** http requests)
* Nasty bugs (This addon fixes particular bugs, this makes the game feel and play much better)
* Any gamemode-related lua files (minimizes size)
* The beatrun UI is removed, as well as the XP system
* The checkpoint system was also removed
* The disarm system is removed, which maintains certain compatibility with [BSMod](https://steamcommunity.com/sharedfiles/filedetails/?id=2106330193)
* The focus on trying to mimic Mirror's Edge, and a realigned vision to be a realism/gameplay enhancing addon.
* Any Beatrun fonts that are created, utilizing the default GMod fonts can yield for a more lightweight experience.

## What is CHANGED?

* Beatrun now has Vector optimizations, making the expensive calls much smoother and improves FPS
* The format of certain lua files has been updated, and a lot of messy code areas are relieved
* The name and icon have also been changed
* Weapons are now switched when wallrunning, rolling, and hitting the ground.
* When jumping, the animation no longer plays the weird leg skipping animation (**This is a preference, and will be changed in a later update rollout**)

## WHY?

Because this mod serves more as a realism enhancement for the sandbox gamemode, rather than a beatrun replacement, as the views and motives do not align well. The Sandboxified Beatrun gamemode is based off of the true Sandbox gamemode, and removes a majority of the "competitive" style checks that don't make sense. This improves performance, as there is less modules, and less state changes throughout the entirety of the addon. 

This addon is much more of an enhancement, removing a majority of the bloat which is unneeded, if your main goal for this addon is movement, and there's a checkpoint system, and a bunch of keybinds which are unneeded and clunk up your gameplay & addon compatibility.
