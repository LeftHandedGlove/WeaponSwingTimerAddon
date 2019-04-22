--[[ ===================================== File Variables ===================================== ]]--
local player_weapon_speed = 0
local player_swing_timer = 0
local target_weapon_speed = 0
local target_swing_timer = 0
local in_combat = false
local class_id = 0
local weapon_id = 0
local player_guid = 0
local target_guid = 0
local main_frame
local player_frame
local player_texture
local target_frame
local target_texture
local addon_name_message = "|cFF16A085WeaponSwingTimer: |r"
local help_message = 
[[Options...
    |cFFFFC300loc <x> <y>:|r Moves the center of the frame to the given (x, y) coords.
    |cFFFFC300scale <factor>:|r Scales the frame based on the given scale factor.
    |cFFFFC300combat_alpha <0.0-1.0>:|r Sets the in combat alpha to the given value.
    |cFFFFC300ooc_alpha <0.0-1.0>:|r Sets the out of combat alpha to the given value.
    |cFFFFC300restore_defaults:|r Restore the addon to its default settings.]]
local load_message = [[WeaponSwingTimer by LeftHandedGlove Loaded. Use "/wst" for options.]]
local restore_defaults_message = [[Default location and size restored.]]
local set_location_message = [[Location set to ]]
local set_scale_message = [[Scale set to ]]
local set_combat_alpha_message = [[In combat alpha set to ]]
local set_ooc_alpha_message = [[Out of combat alpha set to ]]

local defaults = {
    width=200,
    height=20,
    x_offset=0,
    y_offset=-150,
    scale=1,
    combat_alpha=1.0,
    ooc_alpha=0.25
}

--[[ ======================================= Utilities ======================================== ]]--

local function ResetPlayerSwingTimer()
    player_swing_timer = player_weapon_speed
end

local function ResetTargetSwingTimer()
    target_swing_timer = target_weapon_speed
end

local function MaximizeTargetSwingTimer()
    target_swing_timer = 0.0001
end

local function UpdatePlayerWeaponSpeed()
    player_weapon_speed, _ = UnitAttackSpeed("player")
end

local function UpdateTargetWeaponSpeed()
    target_weapon_speed, _ = UnitAttackSpeed("target")
end

local function PrintMsg(msg)
    DEFAULT_CHAT_FRAME:AddMessage(addon_name_message .. msg)
end

--[[ ================================= Upper Level Functions ================================== ]]--

local function RestoreDefaults()
    for setting, value in pairs(defaults) do
        LeftHandedGlove_WST_Settings[setting] = value
    end
end

local function UpdateSwingFrames()
    if (in_combat) then
        main_frame:SetAlpha(LeftHandedGlove_WST_Settings.combat_alpha)
    else
        main_frame:SetAlpha(LeftHandedGlove_WST_Settings.ooc_alpha)
    end
    texture_width = LeftHandedGlove_WST_Settings.width - 8
    player_width = texture_width - (texture_width * (player_swing_timer / player_weapon_speed))
    target_width = texture_width - (texture_width * (target_swing_timer / target_weapon_speed))
    player_frame:SetWidth(player_width)
    target_frame:SetWidth(target_width)
end

local function UpdateVisuals()
    local settings = LeftHandedGlove_WST_Settings
    main_frame:ClearAllPoints()
    main_frame:SetPoint("CENTER", settings.x_offset, settings.y_offset)
    main_frame:SetWidth(settings.width)
    main_frame:SetScale(settings.scale)
    main_frame:SetHeight(settings.height)
    UpdateSwingFrames()
end  

local function InitializeAddon()
    main_frame = LeftHandedGlove_WST_main_frame
    player_frame = LeftHandedGlove_WST_player_frame
    player_texture = LeftHandedGlove_WST_player_frame_texture
    target_frame = LeftHandedGlove_WST_target_frame
    target_texture = LeftHandedGlove_WST_target_frame_texture
    class_id = UnitClass("player")[3]
    weapon_id = GetInventoryItemID("player", 16)
    UpdatePlayerWeaponSpeed()
    player_guid = UnitGUID("player")
    if not LeftHandedGlove_WST_Settings then
        LeftHandedGlove_WST_Settings = {}
    end
    for setting, value in pairs(defaults) do
        if LeftHandedGlove_WST_Settings[setting] == nil then
            LeftHandedGlove_WST_Settings[setting] = value
        end
    end
    UpdateVisuals()
    PrintMsg(load_message)
end

--[[ ================================= WoW trigger functions ================================== ]]--

function LeftHandedGlove_WST_OnLoad()
    LeftHandedGlove_WST_main_frame:RegisterEvent("ADDON_LOADED")
    LeftHandedGlove_WST_main_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	LeftHandedGlove_WST_main_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    LeftHandedGlove_WST_main_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    LeftHandedGlove_WST_main_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    LeftHandedGlove_WST_main_frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function LeftHandedGlove_WST_OnUpdate(elapsed)
    if (player_swing_timer > 0) then
        player_swing_timer = player_swing_timer - elapsed
        if (player_swing_timer < 0) then
            player_swing_timer = 0
        end
    end
    if (target_swing_timer > 0) then
        target_swing_timer = target_swing_timer - elapsed
        if (target_swing_timer < 0) then
            target_swing_timer = 0
        end
    end
    UpdateSwingFrames()
end

function LeftHandedGlove_WST_OnEvent(event, ...)
    local args = {...}
    if (event == "ADDON_LOADED") then
        if (args[1] == "WeaponSwingTimer") then
            InitializeAddon()
        end
    elseif (event == "PLAYER_REGEN_ENABLED") then
        in_combat = false
        UpdateSwingFrames()
    elseif (event == "PLAYER_REGEN_DISABLED") then
        in_combat = true
        UpdateSwingFrames()
    elseif (event == "PLAYER_TARGET_CHANGED") then
        UpdateTargetWeaponSpeed()
        MaximizeTargetSwingTimer()
        target_guid = UnitGUID("target")
    elseif (event  == "COMBAT_LOG_EVENT_UNFILTERED") then
        _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _, miss_type = 
            CombatLogGetCurrentEventInfo()
        if (source_guid == player_guid) then
            if (event == "SWING_DAMAGE") then
                ResetPlayerSwingTimer()
            elseif (event == "SWING_MISSED") then
                ResetPlayerSwingTimer()
            elseif (event == "SPELL_DAMAGE") then
                print("Player Spell Hit: TODO")
            elseif (event == "SPELL_MISSED") then
                print("Player Spell Missed: TODO")
            end
        elseif (source_guid == target_guid) then
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
    elseif (event == "UNIT_INVENTORY_CHANGED") then
        if (GetInventoryItemID("player", 16) ~= weapon_id) then
            weapon_id = GetInventoryItemID("player", 16)
        end
    end
end

--[[ ===================================== Slash Commands ===================================== ]]--

SLASH_WEAPONSWINGTIMER_CONFIG1 = "/wst"
SlashCmdList["WEAPONSWINGTIMER_CONFIG"] = function(option)
    local args = {strsplit(" ", option)}
    local cmd = args[1]
    print(cmd)
    if (cmd == "") then
        PrintMsg(help_message)
    elseif (cmd == "loc") then
        local x_loc = tonumber(args[2])
        local y_loc = tonumber(args[3])
        LeftHandedGlove_WST_Settings.x_offset = x_loc
        LeftHandedGlove_WST_Settings.y_offset = y_loc
        UpdateVisuals()
        PrintMsg(set_location_message .. x_loc .. ", " .. y_loc)
    elseif (cmd == "scale") then
        local scale = tonumber(args[2])
        LeftHandedGlove_WST_Settings.scale = scale
        UpdateVisuals()
        PrintMsg(set_scale_message .. scale)
    elseif (cmd == "combat_alpha") then
        local combat_alpha = args[2]
        LeftHandedGlove_WST_Settings.combat_alpha = combat_alpha
        UpdateVisuals()
        PrintMsg(set_combat_alpha_message .. combat_alpha)
    elseif (cmd == "ooc_alpha") then
        local ooc_alpha = args[2]
        LeftHandedGlove_WST_Settings.ooc_alpha = ooc_alpha
        UpdateVisuals()
        PrintMsg(set_ooc_alpha_message .. ooc_alpha)
    elseif (cmd == "lock") then
        PrintMsg("Howdy")
        if (main_frame.is_locked) then
            main_frame.is_locked = false
        else
            main_frame.is_locked = true
        end
        PrintMsg("Is the frame locked? " .. tostring(main_frame.is_locked))
    elseif (cmd == "restore_defaults") then
        RestoreDefaults()
        UpdateVisuals()
        PrintMsg(restore_defaults_message)
    end
end
