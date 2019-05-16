local core = {}
core.core_frame = CreateFrame("Frame", "MainFrame", UIParent)
core.core_frame:RegisterEvent("ADDON_LOADED")
core.core_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
core.core_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
core.core_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
core.core_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
core.core_frame:RegisterEvent("UNIT_INVENTORY_CHANGED")

local addon_name_message = "|cFF00FFB0QualityTime: |r"
local first_load_message = [[Thank you for installing WeaponSwingTimer by LeftHandedGlove!]]
local load_message = [[Addon Loaded. Use /weaponswingtimer for more options.]]

default_settings = {
    width = 200,
    height = 20,
    x_pos = 0,
    y_pos = 0,
    scale = 1,
    in_combat_alpha = 1.0,
    ooc_alpha = 0.25,
    backplane_alpha = 0.75,
	is_locked = false
}

core.in_combat = false

core.player_swing_timer = 0.0
core.player_weapon_speed = 0.0
core.player_class = "MAGE"
core.player_weapon_id = 0
core.player_guid = 0

core.target_swing_timer = 0.0
core.target_weapon_speed = 0.0
core.target_class = "MAGE"
core.target_weapon_id = 0
core.target_guid = 0

local function PrintMsg(msg)
	DEFAULT_CHAT_FRAME:AddMessage(addon_name_message .. msg)
end

local function LoadSettings()
    if not LHG_WeapSwingTimer_Settings then
        LHG_WeapSwingTimer_Settings = {}
    end
    for setting, value in pairs(default_settings) do
        if LHG_WeapSwingTimer_Settings[setting] == nil then
            LHG_WeapSwingTimer_Settings[setting] = value
        end
    end
	PrintMsg(first_load_message)
	PrintMsg(load_message)
end

local function UpdatePlayerInfo()
    core.player_class = UnitClass("player")[2]
    core.player_weapon_id = GetInventoryItemID("player", 16)
    core.player_weapon_speed, _ = UnitAttackSpeed("player")
    core.player_guid = UnitGUID("player")
end

local function UpdateTargetInfo()
    if UnitExists("target") then
        core.target_class = UnitClass("target")[2]
        core.target_weapon_id = GetInventoryItemID("target", 16)
        core.target_weapon_speed, _ = UnitAttackSpeed("target")
        core.target_guid = UnitGUID("target")
    end
end

local function ResetPlayerSwingTimer()
    core.player_swing_timer = core.player_weapon_speed
end

local function ResetTargetSwingTimer()
    core.target_swing_timer = core.target_weapon_speed
end

local function MaximizePlayerSwingTimer()
    core.player_swing_timer = 0.0001
end

local function MaximizeTargetSwingTimer()
    core.target_swing_timer = 0.0001
end

local function UpdateSwingTimers(elapsed)
    if (core.player_swing_timer > 0) then
        core.player_swing_timer = core.player_swing_timer - elapsed
        if (core.player_swing_timer < 0) then
            core.player_swing_timer = 0
        end
    end
    if (core.target_swing_timer > 0) then
        core.target_swing_timer = core.target_swing_timer - elapsed
        if (core.target_swing_timer < 0) then
            core.target_swing_timer = 0
        end
    end
end

local function UpdateSwingFrames()
    LHGWSTMain.UpdateSwingFrames(
        core.player_weapon_speed, core.player_swing_timer, 
        core.target_weapon_speed, core.target_swing_timer,
        core.in_combat)
end

local function CoreFrame_OnUpdate(self, elapsed)
    UpdateSwingTimers(elapsed)
    UpdateSwingFrames()
end

local function CoreFrame_OnEvent(self, event, ...)
    local args = {...}
    if event == "ADDON_LOADED" then
        if args[1] == "WeaponSwingTimer" then
            LoadSettings()
            UpdatePlayerInfo()
            core.main_frame = LHGWSTMain.CreateLHGWSTMainFrame()
            core.config_frame = LHGWSTConfig.CreateLHGWSTConfigFrame()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        core.in_combat = false
        UpdateSwingFrames()
    elseif event == "PLAYER_REGEN_DISABLED" then
        core.in_combat = true
        UpdateSwingFrames()
    elseif event == "PLAYER_TARGET_CHANGED" then
        UpdateTargetInfo()
        MaximizeTargetSwingTimer()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _, miss_type = CombatLogGetCurrentEventInfo()
        if (source_guid == core.player_guid) then
            if (event == "SWING_DAMAGE") then
                ResetPlayerSwingTimer()
            elseif (event == "SWING_MISSED") then
                ResetPlayerSwingTimer()
            elseif (event == "SPELL_DAMAGE") then
                print("Player Spell Hit: TODO")
            elseif (event == "SPELL_MISSED") then
                print("Player Spell Missed: TODO")
            end
        elseif (source_guid == core.target_guid) then
            if (event == "SWING_DAMAGE") then
                ResetTargetSwingTimer()
            elseif (event == "SWING_MISSED") then
                ResetTargetSwingTimer()
            elseif (event == "SPELL_DAMAGE") then
                print("Target Spell Hit: TODO")
            elseif (event == "SPELL_MISSED") then
                print("Target Spell Missed: TODO")
            end
        end
    elseif event == "UNIT_INVENTORY_CHANGED" then
        UpdatePlayerInfo()
    end
end

core.core_frame:SetScript("OnEvent", CoreFrame_OnEvent)
core.core_frame:SetScript("OnUpdate", CoreFrame_OnUpdate)

-- Add a slash command to bring up the config window and reset to the defaults.
SLASH_WEAPONSWINGTIMER_CONFIG1 = "/WeaponSwingTimer"
SLASH_WEAPONSWINGTIMER_CONFIG2 = "/weaponswingtimer"
SLASH_WEAPONSWINGTIMER_CONFIG3 = "/wst"
SlashCmdList["QUALITYTIME_CONFIG"] = function(option)
	PrintMsg("Configuration window opened.")
    core.config_frame:Show()
end
