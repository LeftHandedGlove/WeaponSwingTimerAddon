LHGWSTCore = {}
LHGWSTCore.core_frame = CreateFrame("Frame", "MainFrame", UIParent)
LHGWSTCore.core_frame:RegisterEvent("ADDON_LOADED")
LHGWSTCore.core_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
LHGWSTCore.core_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
LHGWSTCore.core_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
LHGWSTCore.core_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
LHGWSTCore.core_frame:RegisterEvent("UNIT_INVENTORY_CHANGED")

local addon_name_message = "|cFF00FFB0WeaponSwingTimer: |r"
local load_message = "Thank you for installing WeaponSwingTimer by LeftHandedGlove! " .. 
                     "Use |cFFFFC300/weaponswingtimer|r or |cFFFFC300/wst|r for more options."

local default_settings = {
    width = 300,
    height = 10,
    rel_point = "CENTER",
    x_pos = 0,
    y_pos = -100,
    scale = 1,
    in_combat_alpha = 1.0,
    ooc_alpha = 0.25,
    backplane_alpha = 0.5,
	is_locked = false,
    in_combat = false,
	crp_ping_enabled = false,
	crp_fixed_enabled = false,
	crp_fixed_delay = 0.1
}

local swing_spells = {
    "Heroic Strike",
    "Slam",
	"Cleave",
	"Raptor Strike",
	"Maul"
}

LHGWSTCore.player_swing_timer = 0.0
LHGWSTCore.player_weapon_speed = 0.0
LHGWSTCore.player_class = "MAGE"
LHGWSTCore.player_weapon_id = 0
LHGWSTCore.player_guid = 0

LHGWSTCore.target_swing_timer = 0.0
LHGWSTCore.target_weapon_speed = 0.0
LHGWSTCore.target_class = "MAGE"
LHGWSTCore.target_weapon_id = 0
LHGWSTCore.target_guid = 0

local function PrintMsg(msg)
	DEFAULT_CHAT_FRAME:AddMessage(addon_name_message .. msg)
end

local function LoadSettings()
    if not LHG_WST_Settings then
        LHG_WST_Settings = {}
    end
    for setting, value in pairs(default_settings) do
        if LHG_WST_Settings[setting] == nil then
            LHG_WST_Settings[setting] = value
        end
    end
	PrintMsg(load_message)
end

LHGWSTCore.RestoreDefaults = function()
    for setting, value in pairs(default_settings) do
        LHG_WST_Settings[setting] = value
    end
    LHGWSTConfig.UpdateConfigFrameValues()
    LHGWSTMain.UpdateVisuals()
end

local function UpdatePlayerInfo()
    LHGWSTCore.player_class = UnitClass("player")[2]
    LHGWSTCore.player_weapon_id = GetInventoryItemID("player", 16)
    LHGWSTCore.player_weapon_speed, _ = UnitAttackSpeed("player")
    LHGWSTCore.player_guid = UnitGUID("player")
end

local function UpdateTargetInfo()
    if UnitExists("target") then
        LHGWSTCore.target_class = UnitClass("target")[2]
        LHGWSTCore.target_weapon_id = GetInventoryItemID("target", 16)
        LHGWSTCore.target_weapon_speed, _ = UnitAttackSpeed("target")
        LHGWSTCore.target_guid = UnitGUID("target")
    end
end

local function ResetPlayerSwingTimer()
    LHGWSTCore.player_swing_timer = LHGWSTCore.player_weapon_speed
end

local function ResetTargetSwingTimer()
    LHGWSTCore.target_swing_timer = LHGWSTCore.target_weapon_speed
end

local function MaximizePlayerSwingTimer()
    LHGWSTCore.player_swing_timer = 0.0001
end

local function MaximizeTargetSwingTimer()
    LHGWSTCore.target_swing_timer = 0.0001
end

local function UpdateSwingTimers(elapsed)
    if (LHGWSTCore.player_swing_timer > 0) then
        LHGWSTCore.player_swing_timer = LHGWSTCore.player_swing_timer - elapsed
        if (LHGWSTCore.player_swing_timer < 0) then
            LHGWSTCore.player_swing_timer = 0
        end
    end
    if (LHGWSTCore.target_swing_timer > 0) then
        LHGWSTCore.target_swing_timer = LHGWSTCore.target_swing_timer - elapsed
        if (LHGWSTCore.target_swing_timer < 0) then
            LHGWSTCore.target_swing_timer = 0
        end
    end
end

local function CoreFrame_OnUpdate(self, elapsed)
    UpdateSwingTimers(elapsed)
    LHGWSTMain.UpdateSwingFrames()
end

local function MissHandler(unit, miss_type)
    if miss_type == "PARRY" then
        if unit == "player" then
            min_swing_time = LHGWSTCore.player_weapon_speed * 0.2
            if LHGWSTCore.player_swing_timer > min_swing_time then
                LHGWSTCore.player_swing_timer = min_swing_time
            end
        elseif unit == "target" then
            min_swing_time = LHGWSTCore.target_weapon_speed * 0.2
            if LHGWSTCore.target_swing_timer > min_swing_time then
                LHGWSTCore.target_swing_timer = min_swing_time
            end
        else
            PrintMsg("Unexpected Unit Type in MissHandler().")
        end
    else
        if unit == "player" then
            ResetPlayerSwingTimer()
        elseif unit == "target" then
            ResetTargetSwingTimer()
        else
            PrintMsg("Unexpected Unit Type in MissHandler().")
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
                PrintMsg("Unexpected Unit Type in SpellHandler().")
            end
        end
    end
end

local function CoreFrame_OnEvent(self, event, ...)
    local args = {...}
    if event == "ADDON_LOADED" then
        if args[1] == "WeaponSwingTimer" then
            LoadSettings()
            UpdatePlayerInfo()
            LHGWSTCore.main_frame = LHGWSTMain.CreateLHGWSTMainFrame()
            LHGWSTCore.config_frame = LHGWSTConfig.CreateLHGWSTConfigFrame()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        LHG_WST_Settings.in_combat = false
        LHGWSTMain.UpdateSwingFrames()
    elseif event == "PLAYER_REGEN_DISABLED" then
        LHG_WST_Settings.in_combat = true
        LHGWSTMain.UpdateSwingFrames()
    elseif event == "PLAYER_TARGET_CHANGED" then
        UpdateTargetInfo()
        MaximizeTargetSwingTimer()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _, miss_type = CombatLogGetCurrentEventInfo()
        if (source_guid == LHGWSTCore.player_guid) then
            if (event == "SWING_DAMAGE") then
                ResetPlayerSwingTimer()
            elseif (event == "SWING_MISSED") then
                MissHandler("player", miss_type)
            elseif (event == "SPELL_DAMAGE") then
                SpellHandler("player", spell_name)
            elseif (event == "SPELL_MISSED") then
                SpellHandler("player", spell_name)
            end
        elseif (source_guid == LHGWSTCore.target_guid) then
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

LHGWSTCore.core_frame:SetScript("OnEvent", CoreFrame_OnEvent)
LHGWSTCore.core_frame:SetScript("OnUpdate", CoreFrame_OnUpdate)

-- Add a slash command to bring up the config window and reset to the defaults.
SLASH_WEAPONSWINGTIMER_CONFIG1 = "/WeaponSwingTimer"
SLASH_WEAPONSWINGTIMER_CONFIG2 = "/weaponswingtimer"
SLASH_WEAPONSWINGTIMER_CONFIG3 = "/wst"
SlashCmdList["WEAPONSWINGTIMER_CONFIG"] = function(option)
	PrintMsg("Configuration window opened.")
    LHGWSTCore.config_frame:Show()
end
