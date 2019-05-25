local addon_name, addon_data = ...

addon_data.core = {}

addon_data.core.core_frame = CreateFrame("Frame", addon_name .. "CoreFrame", UIParent)
addon_data.core.core_frame:RegisterEvent("ADDON_LOADED")

addon_data.core.all_timers = {
    addon_data.player, addon_data.target
}

local load_message = "Thank you for installing WeaponSwingTimer by LeftHandedGlove! " .. 
                     "Use |cFFFFC300/weaponswingtimer|r or |cFFFFC300/wst|r for more options."
					 
addon_data.core.default_settings = {
	one_frame = false
}
addon_data.core.settings = character_core_settings

addon_data.core.in_combat = false

local swing_spells = {
    "Heroic Strike",
    "Slam",
	"Cleave",
	"Raptor Strike",
	"Maul"
}

local function LoadAllSettings()
    -- Load the core settings
    addon_data.core.LoadSettings()
    -- Load all of the timer's settings
    for timer_index = 1, #addon_data.core.all_timers do
        addon_data.core.all_timers[timer_index].LoadSettings()
    end
end

addon_data.core.RestoreAllDefaults = function()
    -- Restore the core settings
    addon_data.core.RestoreDefaults()
    -- Restore all of the timer's settings
    for timer_index = 1, #addon_data.core.all_timers do
        addon_data.core.all_timers[timer_index].RestoreDefaults()
    end
end

local function InitializeAllVisuals()
    -- Go through all of the timers
    for timer_index = 1, #addon_data.core.all_timers do
        addon_data.core.all_timers[timer_index].InitializeVisuals()
    end
end

local function UpdateAllVisuals()
    -- Go through all of the timers
    for timer_index = 1, #addon_data.core.all_timers do
        -- Get the current timer
        local current_timer = addon_data.core.all_timers[timer_index]
        -- If the timer is enabled then update the visuals
        if current_timer.enabled then
            current_timer.UpdateVisuals()
        end
    end
end

local function UpdateAllSwingTimers(elapsed)
    -- Go through all of the timers
    for timer_index = 1, #addon_data.core.all_timers do
        -- Get the current timer
        local current_timer = addon_data.core.all_timers[timer_index]
        -- If the timer is enabled then update the swing timers and visuals
        if current_timer.enabled then
            current_timer.UpdateSwingTimer(elapsed)
            current_timer.UpdateVisuals()
        end
    end
end

addon_data.core.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not addon_data.core.settings then
        addon_data.core.settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.core.default_settings) do
        if addon_data.core.settings[setting] == nil then
            addon_data.core.settings[setting] = value
        end
    end
end

addon_data.core.RestoreDefaults = function()
    for setting, value in pairs(addon_data.core.default_settings) do
        addon_data.core.settings[setting] = value
    end
end

local function CoreFrame_OnUpdate(self, elapsed)
    UpdateAllSwingTimers(elapsed)
end

local function MissHandler(unit, miss_type)
    if miss_type == "PARRY" then
        if unit == "player" then
            min_swing_time = addon_data.player.weapon_speed * 0.2
            if addon_data.player.swing_timer > min_swing_time then
                addon_data.player.swing_timer = min_swing_time
            end
        elseif unit == "target" then
            min_swing_time = addon_data.target.weapon_speed * 0.2
            if addon_data.target.swing_timer > min_swing_time then
                addon_data.target.swing_timer = min_swing_time
            end
        else
            addon_data.utils.PrintMsg("Unexpected Unit Type in MissHandler().")
        end
    else
        if unit == "player" then
            addon_data.player.ResetSwingTimer()
        elseif unit == "target" then
            addon_data.target.ResetSwingTimer()
        else
            addon_data.utils.PrintMsg("Unexpected Unit Type in MissHandler().")
        end
    end
end

local function SpellHandler(unit, spell_name)
    for _, swing_spell in ipairs(swing_spells) do
        if spell_name == swing_spell then
            if unit == "player" then
                addon_data.player.ResetSwingTimer()
            elseif unit == "target" then
                addon_data.target.ResetSwingTimer()
            else
                addon_data.utils.PrintMsg("Unexpected Unit Type in SpellHandler().")
            end
        end
    end
end

local function OnAddonLoaded(self)
    -- Attach the rest of the events and scripts to the core frame
	addon_data.core.core_frame:SetScript("OnUpdate", CoreFrame_OnUpdate)
	addon_data.core.core_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	addon_data.core.core_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	addon_data.core.core_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	addon_data.core.core_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	addon_data.core.core_frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	-- Load the settings for the core and all timers
    LoadAllSettings()
    -- Any other misc operations that happen at the start
	addon_data.player.UpdateInfo()
    addon_data.target.UpdateInfo()
    addon_data.player.ZeroizeSwingTimer()
	addon_data.target.ZeroizeSwingTimer()
    addon_data.utils.PrintMsg(load_message)
end

local function CoreFrame_OnEvent(self, event, ...)
    local args = {...}
    if event == "ADDON_LOADED" then
        if args[1] == "WeaponSwingTimer" then
            OnAddonLoaded()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        addon_data.core.in_combat = false
        UpdateAllVisuals()
    elseif event == "PLAYER_REGEN_DISABLED" then
        addon_data.core.in_combat = true
        UpdateAllVisuals()
    elseif event == "PLAYER_TARGET_CHANGED" then
        addon_data.target.UpdateInfo()
        addon_data.target.ZeroizeSwingTimer()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _, miss_type = 
			CombatLogGetCurrentEventInfo()
        if (source_guid == addon_data.player.guid) then
            if (event == "SWING_DAMAGE") then
                addon_data.player.ResetSwingTimer()
            elseif (event == "SWING_MISSED") then
                MissHandler("player", miss_type)
            elseif (event == "SPELL_DAMAGE") or (event == "SPELL_MISSED") then
                SpellHandler("player", spell_name)
            end
        elseif (source_guid == addon_data.core.target_guid) then
            if (event == "SWING_DAMAGE") then
                addon_data.target.ResetSwingTimer()
            elseif (event == "SWING_MISSED") then
                MissHandler("target", miss_type)
            elseif (event == "SPELL_DAMAGE") or (event == "SPELL_MISSED") then
                SpellHandler("target", spell_name)
            end
        end
    elseif event == "UNIT_INVENTORY_CHANGED" then
        addon_data.player.UpdateInfo()
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

-- Setup the core of the addon (This is like calling main in C)
addon_data.core.core_frame:SetScript("OnEvent", CoreFrame_OnEvent)
