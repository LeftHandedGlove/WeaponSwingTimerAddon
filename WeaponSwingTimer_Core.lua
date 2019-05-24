LHGWST_core = {}

LHGWST_core.addon_name = "WeaponSwingTimer"
LHGWST_core.addon_name_message = "|cFF00FFB0WeaponSwingTimer: |r"
LHGWST_core.load_message = "Thank you for installing WeaponSwingTimer by LeftHandedGlove! " .. 
                     "Use |cFFFFC300/weaponswingtimer|r or |cFFFFC300/wst|r for more options."
					 
LHGWST_core.default_settings = {
    player_settings = LHGWST_player_frame.default_settings,
	target_settings = LHGWST_player_frame.default_settings,
	one_frame = false
}

LHGWST_core.swing_spells = {
    "Heroic Strike",
    "Slam",
	"Cleave",
	"Raptor Strike",
	"Maul"
}

LHGWST_core.player_swing_timer = 0.0
LHGWST_core.player_weapon_speed = 0.0
LHGWST_core.player_class = "MAGE"
LHGWST_core.player_weapon_id = 0
LHGWST_core.player_guid = 0

LHGWST_core.target_swing_timer = 0.0
LHGWST_core.target_weapon_speed = 0.0
LHGWST_core.target_class = "MAGE"
LHGWST_core.target_weapon_id = 0
LHGWST_core.target_guid = 0

LHGWST_core.in_combat = false

local function LoadSettings()
	-- If the addon hasn't been loaded before then declare the per character settings
    if not LHGWST_Settings then
        LHGWST_Settings = {}
    end
    for setting, value in pairs(default_settings) do
        if LHGWST_Settings[setting] == nil then
            LHGWST_Settings[setting] = value
        end
    end
end

LHGWST_core.RestoreDefaults = function()
    for setting, value in pairs(default_settings) do
        LHGWST_Settings[setting] = value
    end
    LHGWST_config_frame.UpdateConfigFrameValues()
    LHGWST_main.UpdateVisuals()
end

local function UpdatePlayerInfo()
    LHGWST_core.player_class = UnitClass("player")[2]
    LHGWST_core.player_weapon_id = GetInventoryItemID("player", 16)
    LHGWST_core.player_weapon_speed, _ = UnitAttackSpeed("player")
    LHGWST_core.player_guid = UnitGUID("player")
end

local function UpdateTargetInfo()
    if UnitExists("target") then
        LHGWST_core.target_class = UnitClass("target")[2]
        LHGWST_core.target_weapon_id = GetInventoryItemID("target", 16)
        LHGWST_core.target_weapon_speed, _ = UnitAttackSpeed("target")
        LHGWST_core.target_guid = UnitGUID("target")
    end
end

local function ResetPlayerSwingTimer()
    LHGWST_core.player_swing_timer = LHGWST_core.player_weapon_speed
end

local function ResetTargetSwingTimer()
    LHGWST_core.target_swing_timer = LHGWST_core.target_weapon_speed
end

local function MaximizePlayerSwingTimer()
    LHGWST_core.player_swing_timer = 0.0001
end

local function MaximizeTargetSwingTimer()
    LHGWST_core.target_swing_timer = 0.0001
end

local function UpdateSwingTimers(elapsed)
    if (LHGWST_core.player_swing_timer > 0) then
        LHGWST_core.player_swing_timer = LHGWST_core.player_swing_timer - elapsed
        if (LHGWST_core.player_swing_timer < 0) then
            LHGWST_core.player_swing_timer = 0
        end
    end
    if (LHGWST_core.target_swing_timer > 0) then
        LHGWST_core.target_swing_timer = LHGWST_core.target_swing_timer - elapsed
        if (LHGWST_core.target_swing_timer < 0) then
            LHGWST_core.target_swing_timer = 0
        end
    end
end

local function CoreFrame_OnUpdate(self, elapsed)
    UpdateSwingTimers(elapsed)
    
end

local function MissHandler(unit, miss_type)
    if miss_type == "PARRY" then
        if unit == "player" then
            min_swing_time = LHGWST_core.player_weapon_speed * 0.2
            if LHGWST_core.player_swing_timer > min_swing_time then
                LHGWST_core.player_swing_timer = min_swing_time
            end
        elseif unit == "target" then
            min_swing_time = LHGWST_core.target_weapon_speed * 0.2
            if LHGWST_core.target_swing_timer > min_swing_time then
                LHGWST_core.target_swing_timer = min_swing_time
            end
        else
            LHGWST_utils.PrintMsg("Unexpected Unit Type in MissHandler().")
        end
    else
        if unit == "player" then
            ResetPlayerSwingTimer()
        elseif unit == "target" then
            ResetTargetSwingTimer()
        else
            LHGWST_utils.PrintMsg("Unexpected Unit Type in MissHandler().")
        end
    end
end

local function SpellHandler(unit, spell_name)
    for _, swing_spell in ipairs(swing_spells) do
        if spell_name == swing_spell then
            if unit == "player" then
                ResetPlayerSwingTimer()
            elseif unit == "target" then
                ResetTargetSwingTimer()
            else
                LHGWST_utils.PrintMsg("Unexpected Unit Type in SpellHandler().")
            end
        end
    end
end

local function OnAddonLoaded(self)
	LHGWST_core.core_frame:SetScript("OnUpdate", CoreFrame_OnUpdate)
	LHGWST_core.core_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	LHGWST_core.core_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	LHGWST_core.core_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	LHGWST_core.core_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	LHGWST_core.core_frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	LoadSettings()
	UpdatePlayerInfo()
	MaximizePlayerSwingTimer()
	MaximizeTargetSwingTimer()
end

local function CoreFrame_OnEvent(self, event, ...)
    local args = {...}
    if event == "ADDON_LOADED" then
        if args[1] == "WeaponSwingTimer" then
            OnAddonLoaded()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        LHGWST_core.in_combat = false
        LHGWST_main.UpdateVisuals()
    elseif event == "PLAYER_REGEN_DISABLED" then
        LHGWST_core.in_combat = true
        LHGWST_main.UpdateVisuals()
    elseif event == "PLAYER_TARGET_CHANGED" then
        UpdateTargetInfo()
        MaximizeTargetSwingTimer()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _, miss_type = 
			CombatLogGetCurrentEventInfo()
        if (source_guid == LHGWST_core.player_guid) then
            if (event == "SWING_DAMAGE") then
                ResetPlayerSwingTimer()
            elseif (event == "SWING_MISSED") then
                MissHandler("player", miss_type)
            elseif (event == "SPELL_DAMAGE") then
                SpellHandler("player", spell_name)
            elseif (event == "SPELL_MISSED") then
                SpellHandler("player", spell_name)
            end
        elseif (source_guid == LHGWST_core.target_guid) then
            if (event == "SWING_DAMAGE") then
                ResetTargetSwingTimer()
            elseif (event == "SWING_MISSED") then
                MissHandler("target", miss_type)
            elseif (event == "SPELL_DAMAGE") then
                SpellHandler("target", spell_name)
            elseif (event == "SPELL_MISSED") then
                SpellHandler("target", spell_name)
            end
        end
    elseif event == "UNIT_INVENTORY_CHANGED" then
        UpdatePlayerInfo()
    end
end

-- Add a slash command to bring up the config window
SLASH_WEAPONSWINGTIMER_CONFIG1 = "/WeaponSwingTimer"
SLASH_WEAPONSWINGTIMER_CONFIG2 = "/weaponswingtimer"
SLASH_WEAPONSWINGTIMER_CONFIG3 = "/wst"
SlashCmdList["WEAPONSWINGTIMER_CONFIG"] = function(option)
	LHGWST_utils.LHGWST_utils.PrintMsg("Configuration window opened.")
    LHGWST_config.config_frame:Show()
end

-- Setup the core of the addon (This is like main in C)
LHGWST_core.core_frame = CreateFrame("Frame", LHGWST_core.addon_name .. "CoreFrame", UIParent)
LHGWST_core.core_frame:RegisterEvent("ADDON_LOADED")
LHGWST_core.core_frame:SetScript("OnEvent", CoreFrame_OnEvent)
