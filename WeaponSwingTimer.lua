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

--[[ ======================================= Utilities ======================================== ]]--
local function ResetPlayerSwingTimer()
    player_swing_timer = player_weapon_speed
end

local function ResetTargetSwingTimer()
    target_swing_timer = target_weapon_speed
end

local function UpdatePlayerWeaponSpeed()
    player_weapon_speed, _ = UnitAttackSpeed("player")
end

local function UpdateTargetWeaponSpeed()
    target_weapon_speed, _ = UnitAttackSpeed("target")
end

local function UpdatePlayerSwingFrame()
    if (in_combat) then
        WSTPlayerSwingFrame:Show()
        WSTTargetSwingFrame:Show()
        width = 200 * (player_swing_timer / player_weapon_speed)
        WSTPlayerSwingTimerTexture:SetWidth(width)
    else
        WSTPlayerSwingFrame:Hide()
        WSTTargetSwingFrame:Hide()
    end
end

local function UpdateTargetSwingFrame()
    if (in_combat) then
        WSTTargetSwingFrame:Show()
        width = 200 * (target_swing_timer / target_weapon_speed)
        WSTTargetSwingTimerTexture:SetWidth(width)
    else
        WSTTargetSwingFrame:Hide()
    end
end


--[[ ================================= WoW trigger functions ================================== ]]--

function LeftHandedGlove_WST_OnEvent(event, ...)
    if (event == "ADDON_LOADED") then
        _, _, class_id = UnitClass("player")
        weapon_id = GetInventoryItemID("player", 16)
        UpdatePlayerWeaponSpeed()
        player_guid = UnitGUID("player")
        print("Addon Loaded: TODO")
    elseif (event == "PLAYER_REGEN_ENABLED") then
        in_combat = false
        UpdatePlayerSwingFrame()
        UpdateTargetSwingFrame()
    elseif (event == "PLAYER_REGEN_DISABLED") then
        in_combat = true
        UpdatePlayerSwingFrame()
        UpdateTargetSwingFrame()
    elseif (event == "PLAYER_TARGET_CHANGED") then
        print("Player Target Changed: TODO")
        UpdateTargetWeaponSpeed()
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
            print(weapon_id)
        end
    end
end

function LeftHandedGlove_WST_OnLoad()
    WSTPlayerSwingFrame:RegisterEvent("ADDON_LOADED")
    WSTPlayerSwingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	WSTPlayerSwingFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    WSTPlayerSwingFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    WSTPlayerSwingFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    WSTPlayerSwingFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    DEFAULT_CHAT_FRAME:AddMessage("WeaponSwingTimer by LeftHandedGlove Loaded.")
end

function LeftHandedGlove_WST_TargetOnUpdate(elapsed)
    if (target_swing_timer > 0) then
        target_swing_timer = target_swing_timer - elapsed
        if (target_swing_timer < 0) then
            target_swing_timer = 0
        end
    end
    UpdateTargetSwingFrame()
end

function LeftHandedGlove_WST_PlayerOnUpdate(elapsed)
    if (player_swing_timer > 0) then
        player_swing_timer = player_swing_timer - elapsed
        if (player_swing_timer < 0) then
            player_swing_timer = 0
        end
    end
    UpdatePlayerSwingFrame()
end

--[[ ===================================== Slash Commands ===================================== ]]--

SLASH_WEAPONSWINGTIMER_CONFIG1 = "/wst"
SlashCmdList["WEAPONSWINGTIMER_CONFIG"] = function()
    print("Howdy!")
end
    
