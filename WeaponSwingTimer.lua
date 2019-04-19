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
    target_swing_timer = target_weapon_speed_weapon_speed
end

local function UpdatePlayerWeaponSpeed()
    player_weapon_speed, _ = UnitAttackSpeed("player")
end

local function UpdateTargetWeaponSpeed()
    target_weapon_speed, _ = UnitAttackSpeed("target")
end

local function UpdateSwingFrame()
    if (in_combat) then
        WSTSwingFrame:Show()
        width = 200 * (player_swing_timer / player_weapon_speed)
        WSTSwingFrame:SetWidth(width)
    else
        WSTSwingFrame:Hide()
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
        UpdateSwingFrame()
    elseif (event == "PLAYER_REGEN_DISABLED") then
        in_combat = true
        UpdateSwingFrame()
    elseif (event == "PLAYER_TARGET_CHANGED") then
        print("Player Target Changed: TODO")
        UpdateTargetWeaponSpeed()
        target_guid = UnitGUID("target")
    elseif (event  == "COMBAT_LOG_EVENT_UNFILTERED") then
        _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _, miss_type = 
            CombatLogGetCurrentEventInfo()
        if (source_guid == player_guid) then
            if (event == "SWING_DAMAGE") then
                print("Player Swing Hit")
                ResetPlayerSwingTimer()
            elseif (event == "SWING_MISSED") then
                print("Player Swing Missed")
            elseif (event == "SPELL_DAMAGE") then
                print("Player Spell Hit")
            elseif (event == "SPELL_MISSED") then
                print("Player Spell Missed")
            end
        elseif (source_guid == target_guid) then
            print (event .. "   target hit")
        end
        
    elseif (event == "UNIT_INVENTORY_CHANGED") then
        if (GetInventoryItemID("player", 16) ~= weapon_id) then
            weapon_id = GetInventoryItemID("player", 16)
            print(weapon_id)
        end
    end
end

function LeftHandedGlove_WST_OnLoad()
    WSTSwingFrame:RegisterEvent("ADDON_LOADED")
    WSTSwingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	WSTSwingFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    WSTSwingFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    WSTSwingFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    WSTSwingFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    DEFAULT_CHAT_FRAME:AddMessage("WeaponSwingTimer by LeftHandedGlove Loaded.")
end

function LeftHandedGlove_WST_OnUpdate(elapsed)
    if (player_swing_timer > 0) then
        player_swing_timer = player_swing_timer - elapsed
        if (player_swing_timer < 0) then
            player_swing_timer = 0
        end
    end
    UpdateSwingFrame()
end

--[[ ===================================== Slash Commands ===================================== ]]--

SLASH_WEAPONSWINGTIMER_CONFIG1 = "/wst"
SlashCmdList["WEAPONSWINGTIMER_CONFIG"] = function()
    print("Howdy!")
end
    
