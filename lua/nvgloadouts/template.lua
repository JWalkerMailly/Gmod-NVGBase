
local TEMPLATE = {};
TEMPLATE.Goggles = {};

-- Base settings.
TEMPLATE.Settings = {

	-- Animation gesture to use if your playermodels support it.
	Gestures = {
		On = nil,
		Off = nil
	},

	-- Bodygroup to set if your playermodels have special bodygroups for goggles on/off.
	BodyGroups = {
		Group = nil,
		Values = {
			On = nil,
			Off = nil
		}
	},

	-- Goggle overlays.
	-- Goggle is a static fullscreen texture.
	-- Transition is the texture used when animating the transition in and out.
	Overlays = {
		Goggle = nil,
		Transition = nil
	},

	-- Transition timings for transition overlay.
	Transition = {
		Rate = 5,
		Delay = 0.225,
		Switch = 0.5,
		Sound = nil
	},

	-- True to remove on death, false otherwise.
	RemoveOnDeath = true
};

-- First goggle settings.
TEMPLATE.Goggles[1] = {

	Name = "first_goggle_name",

	-- Whitelist should be a table of playermodels.
	Whitelist = nil,

	-- Full screen material overlay.
	MaterialOverlay   = nil,
	OverlayFirst      = false,

	-- Full screen material overlay.
	MaterialInterlace = nil,
	InterlaceColor    = Color(255, 255, 255, 255),

	-- Material to apply to every entity that passes the filter function.
	MaterialOverride  = nil,
	Filter = function(ent)
		return;
	end,

	-- Goggle sounds table.
	Sounds = {
		Loop      = nil, -- Plays continuously, must be a looping sound.
		ToggleOn  = nil, -- Played once when toggling on.
		ToggleOff = nil, -- Played once when toggling off.
		Activate  = nil  -- Played once then toggling on, used for special effects.
	},

	-- Lighting example. Dynamic lights are expensive and should be small.
	-- This is better suited for illuminating your viewmodel rather than the world itself.
	Lighting = {
		Color      = Color(25, 25, 25),
		Min        = 0,
		Style      = 0,
		Brightness = 1,
		Size       = 200,
		Decay      = 200,
		DieTime    = 0.05
	},

	-- Projected texture example. Use this to illuminate the world rather
	-- than the lighting table as it yields better results.
	ProjectedTexture = {
		FOV        = 140,
		VFOV       = 100,
		Brightness = 2,
		Distance   = 2500
	},

	-- Photosensitive influences the goggles light sensitivity.
	PhotoSensitive = 0.9,

	-- Color correction example.
	ColorCorrection = {
		ColorAdd   = Color(0.2, 0.4, 0.05),
		ColorMul   = Color(0, 0, 0),
		ColorMod   = 0.25,
		Contrast   = 1,
		Brightness = 0.05
	},

	PostProcess = function(self)
		-- * self refers this goggle table.
	end,

	OffscreenRendering = function(self, texture)
		-- * self refers this goggle table.
		-- * texture is a full screen material of the player's view before any processing. Useful for UV effects.
	end
};

-- Register the loadout. Line is commented to avoid adding it to the real loadout cache.
-- NVGBASE_LOADOUTS.Register("loadout_name", TEMPLATE);