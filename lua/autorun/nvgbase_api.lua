
local _player = FindMetaTable("Player");
local entity = FindMetaTable("Entity");
local color  = FindMetaTable("Color");

-- Server side whitelist convar.
if (SERVER) then

	CreateConVar("NVGBASE_WHITELIST", "0", { FCVAR_ARCHIVE, FCVAR_CHEAT });
	CreateConVar("NVGBASE_ALLOWPLAYERLOADOUT", "0", { FCVAR_ARCHIVE, FCVAR_CHEAT });

	-- Admin console command to define the gamemode loadout on the fly.
	CreateConVar("NVGBASE_DEFAULTLOADOUT", "", { FCVAR_ARCHIVE, FCVAR_CHEAT });
	concommand.Add("NVGBASE_GAMEMODELOADOUT", function(ply, cmd, args)

		if (args[1] == nil) then return; end

		GetConVar("NVGBASE_DEFAULTLOADOUT"):SetString(args[1]);
		for k,v in pairs(player.GetAll()) do
			v:NVGBASE_SetLoadout(args[1]);
		end
	end, nil, nil, FCVAR_CHEAT);
end

-- Show all available NVG loadouts.
concommand.Add("NVGBASE_SHOWLOADOUTS", function(ply, cmd, args)

	for k,v in pairs(NVGBASE.Loadouts) do
		print(k);
	end
end, nil, nil, 0);

-- Player console command to define the loadout on the fly.
concommand.Add("NVGBASE_PLAYERLOADOUT", function(ply, cmd, args)

	if (args[1] == nil || ply == NULL || !GetConVar("NVGBASE_ALLOWPLAYERLOADOUT"):GetBool()) then return; end
	ply:NVGBASE_SetLoadout(args[1]);
end, nil, nil, 0);

--!
--! @brief      Utility function to determine if player model whitelisting is on.
--!
--! @return     True if it is, False otherwise.
--!
function _G:NVGBASE_IsWhitelistOn()
	return GetConVar("NVGBASE_WHITELIST"):GetBool();
end

-- Setup convars to determine which key to use for the goggles. By default:
-- * KEY_N (24): Toggle goggle.
-- * KEY_M (23): Cycle goggle.
CreateClientConVar("NVGBASE_INPUT", "24", true, true, "Which key to toggle goggle. Must be a number, refer to: https://wiki.facepunch.com/gmod/Enums/KEY.", 1, 159);
CreateClientConVar("NVGBASE_CYCLE", "23", true, true, "Which key to cycle goggle. Must be a number, refer to: https://wiki.facepunch.com/gmod/Enums/KEY.", 1, 159);

-- Setup toggle and cycle commands for goggles.
CreateClientConVar("NVGBASE_TOGGLE", "0", false, true);

--!
--! @brief      Utility function to lerp a color towards another color table.
--!
--! @param      t     Delta
--! @param      to    Target color
--!
--! @return     Interpolated result.
--!
function color:NVGBASE_LerpColor(t, to)
	return Color(
		Lerp(t, self.r, to.r),
		Lerp(t, self.g, to.g),
		Lerp(t, self.b, to.b),
		Lerp(t, self.a, to.a)
	);
end

--!
--! @brief      Trace test to determine if an entity is visible.
--!
--! @param      target       The target
--! @param      maxDistance  The maximum distance to test against
--!
--! @return     If entity is visible.
--!
function _player:NVGBASE_IsBoundingBoxVisible(target, maxDistance)

	local trace = util.TraceHull({
		start = self:EyePos(),
		endpos = target:NVGBASE_GetCenterPos(),
		mins = Vector(1, 1, 1) * -1,
		maxs = Vector(1, 1, 1) * 1,
		filter = self
	});

	return trace.Hit && target == trace.Entity;
end

--!
--! @brief      Return the center position of an entity.
--!
--! @return     Position + OBBCenter.
--!
function entity:NVGBASE_GetCenterPos()
	return self:GetPos() + self:OBBCenter();
end

--!
--! @brief      Utility function to save entity rendering settings for cleanup later.
--!
function entity:NVGBASE_SaveRenderingSettings()

	-- Save rendering options for later.
	if (self.NVGBASE_RENDEROVERRIDE == nil) then
		self.NVGBASE_RENDEROVERRIDE = true;
		self.NVGBASE_OldColor = self:GetColor();
		self.NVGBASE_OldRenderMode = self:GetRenderMode();
	end
end

--!
--! @brief      Utility function to reset the entity's rendering settings to defaults.
--!
function entity:NVGBASE_ResetRenderingSettings()
	self:SetColor(self.NVGBASE_OldColor);
	self:SetRenderMode(self.NVGBASE_OldRenderMode);
end

--!
--! @brief      Utility function for animating and bodygroup.
--!
--! @param      gogglesActive  Flag
--! @param      anim           The animation to play
--! @param      bodygroup      Playermodel bodygroup to modify
--! @param      on             Bodygroup value for on
--! @param      off            Bodygroup value for off
--!
function _player:NVGBASE_AnimGoggle(gogglesActive, anim, bodygroup, on, off)

	if (IsValid(self)) then
		if (bodygroup != nil) then self:SetBodygroup(bodygroup, !gogglesActive && on || off); end
		if (anim != nil) then self:AnimRestartGesture(GESTURE_SLOT_CUSTOM, anim, true); end
	end
end

--!
--! @return     Returns the player's toggle key.
--!
function _player:NVGBASE_GetGoggleToggleKey()
	return self:GetInfoNum("NVGBASE_INPUT", 24);
end

--!
--! @return     Returns the player's cycle mode key.
--!
function _player:NVGBASE_GetGoggleSwitchKey()
	return self:GetInfoNum("NVGBASE_CYCLE", 23);
end

--!
--! @return     Returns the next time the goggle and be toggled. If you are comparing against
--!             this value, simply check that CurTime() is greater for "can toggle".
--!
function _player:NVGBASE_GetNextToggleTime()
	return self:GetNWFloat("NVGBASE_NEXT_TOGGLE", 0);
end

--!
--! @return     Returns the next time the goggle and be switched. If you are comparing against
--!             this value, simply check that CurTime() is greater for "can switch".
--!
function _player:NVGBASE_GetNextSwitchTime()
	return self:GetNWFloat("NVGBASE_NEXT_SWITCH", 0);
end

--!
--! @brief      Utility function to retreive the current NVG loadout of a player. 
--!             The loadout should be applied onto the player through a gamemode or
--!             autorun script.
--!
--! @return     The name (key) of the current loadout.
--!
function _player:NVGBASE_GetLoadout()
	local loadout = self:GetNWString("NVGBASE_LOADOUT", GetConVar("NVGBASE_DEFAULTLOADOUT"):GetString());
	if (loadout == "") then return nil; end
	return NVGBASE.Loadouts[loadout];
end

--!
--! @brief      Utility function to apply loadout to a player.
--!
--! @param      loadoutName  The loadout name to apply. Must match
--!             the name of the loadout registered in the cache. 
--!
function _player:NVGBASE_SetLoadout(loadoutName)
	self:SetNWString("NVGBASE_LOADOUT", loadoutName);
end

--!
--! @return     True if the goggles are currently toggled on, False otherwise.
--!
function _player:NVGBASE_IsGoggleActive()
	return self:GetInfoNum("NVGBASE_TOGGLE", 0) == 1;
end

--!
--! @brief      Utility function to toggle a player's goggles.
--!
--! @param      loadout Current loadout being used.
--! @param      silent  Optional, if set to true, will not emit a sound to other players.
--! @param      force   Optional, used to override the state to on (1) or off (0).
--!
function _player:NVGBASE_ToggleGoggle(loadout, silent, force)

	local toggled = self:NVGBASE_IsGoggleActive();

	-- Failsafe if the goggle has changed to one that we don't have access to. A good example
	-- of this would be a gamemode where player model whitelisting is on and the player has
	-- switched teams mid game. The new model or team might not have access to the last goggle he used.
	if (_G:NVGBASE_IsWhitelistOn() && !toggled && !self:NVGBASE_IsWhitelisted(loadout, self:GetNWInt("NVGBASE_CURRENT_GOGGLE", 1))) then
		self:NVGBASE_SwitchToNextGoggle(loadout);
	end

	if (force != nil) then
		self:ConCommand("NVGBASE_TOGGLE " .. force);
		self:SetNWFloat("NVGBASE_NEXT_TOGGLE", CurTime() + loadout.Settings.Transition.Switch);
	else
		self:ConCommand("NVGBASE_TOGGLE " .. (!toggled && 1 || 0));
		self:SetNWFloat("NVGBASE_NEXT_TOGGLE", CurTime() + loadout.Settings.Transition.Switch);
	end

	local goggle = self:NVGBASE_GetGoggle();
	if (!silent && goggle.Sounds != nil) then
		if (!toggled) then if (goggle.Sounds.ToggleOn != nil) then self:EmitSound(goggle.Sounds.ToggleOn, 75, 100, 1, CHAN_ITEM); end
		else if (goggle.Sounds.ToggleOff != nil) then self:EmitSound(goggle.Sounds.ToggleOff, 75, 100, 1, CHAN_ITEM); end end
	end
end

--!
--! @brief      Utility function to switch to the next goggle. If whitelisting is on,
--!             will switch to the next goggle the user has access to. If whitelisting
--!             is off, will cycle through all the goggles.
--!
function _player:NVGBASE_SwitchToNextGoggle(loadout)

	local function loop(current)
		current = current + 1;
		if (current > #loadout.Goggles) then current = 1; end
		return current;
	end

	local current = self:GetNWInt("NVGBASE_CURRENT_GOGGLE", 1);
	self:SetNWInt("NVGBASE_LAST_GOGGLE", current);

	if (!_G:NVGBASE_IsWhitelistOn()) then

		-- Whitelist mode is not on, cycle through all the goggles normally.
		current = loop(current);
		self:SetNWInt("NVGBASE_CURRENT_GOGGLE", current);
		self:SetNWFloat("NVGBASE_NEXT_SWITCH", CurTime() + loadout.Settings.Transition.Switch);
	else

		-- Find next valid goggle.
		current = loop(current);
		while (current != self:GetNWInt("NVGBASE_CURRENT_GOGGLE", 1)) do

			-- Fetch the next goggle according to the whitelist.
			if (self:NVGBASE_IsWhitelisted(loadout, current)) then
				self:SetNWInt("NVGBASE_CURRENT_GOGGLE", current);
				self:SetNWFloat("NVGBASE_NEXT_SWITCH", CurTime() + loadout.Settings.Transition.Switch);
				return;
			end

			-- Loop back around if we have gone past the last goggle.
			current = loop(current);
		end
	end
end

--!
--! @brief      Utility function to determine if the player can toggle their goggles. If no
--!             key is provided, will only take into account timing since last toggle.
--!
--! @param      key   Optional, the key code used to toggle the goggles.
--!
--! @return     True if can be toggled, False otherwise.
--!
function _player:NVGBASE_CanToggleGoggle(key)
	if (key == nil) then return CurTime() > self:NVGBASE_GetNextToggleTime(); end
	return key == self:NVGBASE_GetGoggleToggleKey() && CurTime() > self:NVGBASE_GetNextToggleTime();
end

--!
--! @brief      Utility function to determine if the player can switch their goggles. If no
--!             key is provided, will only take into account timing since last switch.
--!
--! @param      key   Optional, the key code used to switch the goggles.
--!
--! @return     True if can be switched, False otherwise.
--!
function _player:NVGBASE_CanSwitchGoggle(key)
	local toggled = self:NVGBASE_IsGoggleActive();
	if (key == nil) then return toggled && CurTime() > self:NVGBASE_GetNextSwitchTime(); end
	return toggled && key == self:NVGBASE_GetGoggleSwitchKey() && CurTime() > self:NVGBASE_GetNextSwitchTime();
end

--!
--! @brief      Return the table config of the player's current goggle.
--!
--! @return     NVG Table.
--! @debug      lua_run PrintTable(Entity(1):NVGBASE_GetGoggle())
--!
function _player:NVGBASE_GetGoggle()
	local goggle = self:GetNWInt("NVGBASE_CURRENT_GOGGLE", 1);
	if (goggle == 0) then return nil; end
	return self:NVGBASE_GetLoadout().Goggles[goggle];
end

--!
--! @brief      Utility function to set a goggle on the player. Does not toggle the
--!             goggle, will simply set the reference for the next toggle.
--!
--! @param 		loadoutName The loadout to use.
--! @param      name  The name of the goggle to use when toggling.
--!
--! @return     True on success, False otherwise.
--! @debug      lua_run print(Entity(1):NVGBASE_SetGoggle("Thermal"))
--!
function _player:NVGBASE_SetGoggle(loadoutName, name)

	local goggle = nil
	for k,v in pairs(NVGBASE.Loadouts[loadoutName].Goggles) do if (v.Name == name) then goggle = k; end end
	if (goggle == nil) then return false; end

	self:SetNWInt("NVGBASE_CURRENT_GOGGLE", goggle);
	return true;
end

--!
--! @brief      Return the table config of the player's last goggle.
--!
--! @return     NVG Table.
--! @debug      lua_run PrintTable(Entity(1):NVGBASE_GetPreviousGoggle())
--!
function _player:NVGBASE_GetPreviousGoggle()
	local goggle = self:GetNWInt("NVGBASE_LAST_GOGGLE", 0);
	if (goggle == 0) then return nil; end
	return self:NVGBASE_GetLoadout().Goggles[goggle];
end

--!
--! @brief      Determines if the player is whitelisted for a goggle according to his playermodel.
--!             If no goggle is supplied, will do a general check to see if he can use the goggle feature.
--!
--! @param      loadout Current loadout to test against.
--! @param      goggle  The goggle to test against (key, or nil for a general check. 
--!
--! @return     True if whitelisted, False otherwise.
--! @debug 		lua_run print(Entity(1):NVGBASE_IsWhitelisted())
--! @debug 		lua_run print(Entity(1):NVGBASE_IsWhitelisted(1))
--!
function _player:NVGBASE_IsWhitelisted(loadout, goggle)

	local model = self:GetModel();
	if (goggle == nil || goggle == 0) then
		for k,v in ipairs(loadout.Goggles) do
			for x,y in pairs(v.Whitelist) do
				if (model == y) then return true; end
			end
		end
	else
		for k,v in pairs(loadout.Goggles[goggle].Whitelist) do
			if (model == v) then return true; end
		end
	end

	return false;
end