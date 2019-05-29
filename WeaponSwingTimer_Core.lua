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

addon_data.core.in_combat = false

local swing_spells = {
    "Heroic Strike",
    "Slam",
	"Cleave",
	"Raptor Strike",
	"Maul"
}

local function LoadAllSettings()
    addon_data.core.LoadSettings()
    addon_data.player.LoadSettings()
    addon_data.target.LoadSettings()
end

addon_data.core.RestoreAllDefaults = function()
    addon_data.core.RestoreDefaults()
    addon_data.player.RestoreDefaults()
    addon_data.target.RestoreDefaults()
    addon_data.player.UpdateVisuals()
    addon_data.target.UpdateVisuals()
end

local function InitializeAllVisuals()
    addon_data.player.InitializeVisuals()
    addon_data.target.InitializeVisuals()
    addon_data.config.InitializeVisuals()
end

local function UpdateAllVisuals()
    addon_data.player.UpdateVisuals()
    addon_data.target.UpdateVisuals()
end

local function UpdateAllSwingTimers(elapsed)
    addon_data.player.UpdateSwingTimer(elapsed)
    addon_data.target.UpdateSwingTimer(elapsed)
    addon_data.player.UpdateVisuals()
    addon_data.target.UpdateVisuals()
end

addon_data.core.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_core_settings then
        character_core_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.core.default_settings) do
        if character_core_settings[setting] == nil then
            character_core_settings[setting] = value
        end
    end
end

addon_data.core.RestoreDefaults = function()
    for setting, value in pairs(addon_data.core.default_settings) do
        character_core_settings[setting] = value
    end
end

local function CoreFrame_OnUpdate(self, elapsed)
    UpdateAllSwingTimers(elapsed)
    addon_data.target.UpdateInfo()
end

local function MissHandler(unit, miss_type, is_offhand)
    if miss_type == "PARRY" then
        if unit == "player" then
            if not is_offhand then
                min_swing_time = addon_data.player.main_weapon_speed * 0.2
                if addon_data.player.main_swing_timer > min_swing_time then
                    addon_data.player.main_swing_timer = min_swing_time
                end
            else
                min_swing_time = addon_data.player.off_weapon_speed * 0.2
                if addon_data.player.off_swing_timer > min_swing_time then
                    addon_data.player.off_swing_timer = min_swing_time
                end
            end
        elseif unit == "target" then
            if not is_offhand then
                min_swing_time = addon_data.target.main_weapon_speed * 0.2
                if addon_data.target.main_swing_timer > min_swing_time then
                    addon_data.target.main_swing_timer = min_swing_time
                end
            else
                min_swing_time = addon_data.target.off_weapon_speed * 0.2
                if addon_data.target.off_swing_timer > min_swing_time then
                    addon_data.target.off_swing_timer = min_swing_time
                end
            end
        else
            addon_data.utils.PrintMsg("Unexpected Unit Type in MissHandler().")
        end
    else
        if unit == "player" then
            if not is_offhand then
                addon_data.player.ResetMainSwingTimer()
            else
                addon_data.player.ResetOffSwingTimer()
            end 
        elseif unit == "target" then
            if not is_offhand then
                addon_data.target.ResetMainSwingTimer()
            else
                addon_data.target.ResetOffSwingTimer()
            end 
        else
            addon_data.utils.PrintMsg("Unexpected Unit Type in MissHandler().")
        end
    end
end

local function SpellHandler(unit, spell_name)
    for _, swing_spell in ipairs(swing_spells) do
        if spell_name == swing_spell then
            if unit == "player" then
                addon_data.player.ResetMainSwingTimer()
            elseif unit == "target" then
                addon_data.target.ResetMainSwingTimer()
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
    InitializeAllVisuals()
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
        local _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _ = CombatLogGetCurrentEventInfo()
        if (source_guid == addon_data.player.guid) then
            if (event == "SWING_DAMAGE") then
                local _, _, _, _, _, _, _, _, _, is_offhand = select(12, CombatLogGetCurrentEventInfo())
                if is_offhand then
                    addon_data.player.ResetOffSwingTimer()
                else
                    addon_data.player.ResetMainSwingTimer()
                end
            elseif (event == "SWING_MISSED") then
                local miss_type, is_offhand = select(12, CombatLogGetCurrentEventInfo())
                MissHandler("player", miss_type, is_offhand)
            elseif (event == "SPELL_DAMAGE") or (event == "SPELL_MISSED") then
                SpellHandler("player", spell_name)
            end
        elseif (source_guid == addon_data.target.guid) then
            if (event == "SWING_DAMAGE") then
                local _, _, _, _, _, _, _, _, _, is_offhand = select(12, CombatLogGetCurrentEventInfo())
                if is_offhand then
                    addon_data.target.ResetOffSwingTimer()
                else
                    addon_data.target.ResetMainSwingTimer()
                end
            elseif (event == "SWING_MISSED") then
                local miss_type, is_offhand = select(12, CombatLogGetCurrentEventInfo())
                MissHandler("target", miss_type, is_offhand)
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
    InterfaceOptionsFrame_OpenToCategory("WeaponSwingTimer")
    InterfaceOptionsFrame_OpenToCategory("WeaponSwingTimer")
end

-- Setup the core of the addon (This is like calling main in C)
addon_data.core.core_frame:SetScript("OnEvent", CoreFrame_OnEvent)
