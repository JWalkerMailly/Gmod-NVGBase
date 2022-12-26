
if (SERVER) then
	util.AddNetworkString("NVGBASE_TOGGLE_ANIM");
end

--! 
--! Used to handle animations clientside since the input handler will only be serverside.
--!
net.Receive("NVGBASE_TOGGLE_ANIM", function()

	-- Simple conversion function for nil (-1) int on network thread.
	local function cast(int)
		if (int == -1) then return nil; end
		return int;
	end

	local player = net.ReadEntity();
	local gogglesActive = net.ReadBool();
	local anim = cast(net.ReadInt(14));
	local bodygroup = cast(net.ReadInt(14));
	local bodygroupOn = cast(net.ReadInt(14));
	local bodygroupOff = cast(net.ReadInt(14));

	player:NVGBASE_AnimGoggle(gogglesActive, anim, bodygroup, bodygroupOn, bodygroupOff);
end);

--! 
--! Main input entry point for the goggles. Will process the toggle and cycle key.
--!
hook.Add("PlayerButtonDown", "NVGBASE_INPUT", function(player, button)

	-- Server only code. PlayerButtonDown is not called clientside in singleplayer. It is
	-- simpler and cleaner to handle everything server-side and do network calls ourselves
	-- to the client realm for animations. This will ensure compatibility in singleplayer and multiplayer.
	if (!SERVER) then return; end

	-- Do nothing if the player is not using a loadout at the moment.
	local loadout = player:NVGBASE_GetLoadout();
	if (loadout == nil) then return; end

	local whitelist = _G:NVGBASE_IsWhitelistOn();
	local playerWhitelisted = player:NVGBASE_IsWhitelisted(loadout);
	local gogglesActive = player:NVGBASE_IsGoggleActive();

	-- If whitelist system is on, make sure the player is whitelisted before.
	-- The only way to bypass the whitelist if it is on, is if the player already has his
	-- goggles active while his allowed goggles list changed, in that case, we allow to run
	-- to prevent him getting stuck in his active goggles.
	if (whitelist && !playerWhitelisted && !gogglesActive) then return; end

	-- Toggle goggle on/off.
	if (player:NVGBASE_CanToggleGoggle(button)) then

		-- Play toggle animation. Playermodel must be whitelisted even if whitelist is off.
		if (loadout.Settings.Gestures != nil && playerWhitelisted) then

			local anim = loadout.Settings.Gestures;
			local bodygroup = loadout.Settings.BodyGroups;
			local bodygroupOn = nil;
			local bodygroupOff = nil;

			-- Loadout uses animations.
			if (anim != nil) then
				if (!gogglesActive) then anim = anim.On;
				else anim = anim.Off; end
			end

			-- Loadout uses bodygroups.
			if (bodygroup != nil) then
				bodygroupOn = bodygroup.Values.On;
				bodygroupOff = bodygroup.Values.Off;
				bodygroup = bodygroup.Group;
			end

			-- Will only play server side.
			player:NVGBASE_AnimGoggle(gogglesActive, anim, bodygroup, bodygroupOn, bodygroupOff);

			-- Send out net message to play animation on client.
			net.Start("NVGBASE_TOGGLE_ANIM");
				net.WriteEntity(player);
				net.WriteBool(gogglesActive);
				net.WriteInt(anim || -1, 14);
				net.WriteInt(bodygroup || -1, 14);
				net.WriteInt(bodygroupOn || -1, 14);
				net.WriteInt(bodygroupOff || -1, 14);
			net.Broadcast();
		end

		player:NVGBASE_ToggleGoggle(loadout);
	end

	-- Cycle between different goggle modes.
	if (player:NVGBASE_CanSwitchGoggle(button)) then
		player:NVGBASE_SwitchToNextGoggle(loadout);
	end
end);

--! 
--! Simple hook to remove goggle on death.
--!
hook.Add("PlayerDeath", "NVGBASE_DEATH", function(victim, inflictor, attacker)

	-- Do nothing if the player is not using a loadout at the moment.
	local loadout = victim:NVGBASE_GetLoadout();
	if (loadout == nil) then return; end

	if (loadout.Settings.RemoveOnDeath) then
		victim:NVGBASE_ToggleGoggle(loadout, true, 0);
	end
end);