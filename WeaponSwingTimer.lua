local player_weapon_speed = 0
local target_weapon_speed = 0
local in_combat = false
local class = "Undefined"

local wst_frame = WSTConfigButtonFrame

-- Registering the events
wst_frame:RegisterEvent("ADDON_LOADED")
wst_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
wst_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
wst_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
wst_frame:RegisterEvent("UNIT_COMBAT")

local function AddonLoaded()
    class = UnitClass("player")
end

local function PlayerRegenEnabled()
    wst_frame:Show()
    player_weapon_speed, _ = UnitAttackSpeed("player")
    target_weapon_speed, _ = UnitAttackSpeed("target")
end

local function PlayerRegenDisabled()
    wst_frame:Hide()
end

local function PlayerTargetChanged()
    print("PlayerTargetChanged")
end

local function UnitCombat()
    print("UnitCombat")
end

local function WST_EventHandler(self, event, ...)
    print(event)
--[[
    if (event == "ADDON_LOADED") then
        AddonLoaded()
    elseif (event == "PLAYER_REGEN_ENABLED") then
        PlayerRegenEnabled()
    elseif (event == "PLAYER_REGEN_DISABLED") then
        PlayerRegenDisabled()
    elseif (event == "PLAYER_TARGET_CHANGED") then
        PlayerTargetChanged()
    elseif (event == "UNIT_COMBAT") then
        UnitCombat()
    end
]]--
end

local function UpdateHandler(self, elapsed)
    -- print(elapsed)
end

--wst_frame:SetScript("OnEvent", EventHandler)
--wst_frame:SetScript("OnUpdate", UpdateHandler)


local function toggle_config_menu()
    print("Toggling Weapon Swing Timer Config Menu.")
    local mainHandSpeed, offhandSpeed = UnitAttackSpeed("player")
    local targetMainHandSpeed, targetOffHandSpeed = UnitAttackSpeed("target")
    print(mainHandSpeed)
    print(offhandSpeed)
    print(targetMainHandSpeed)
    print(targetOffHandSpeed)
end

SLASH_WEAPONSWINGTIMER_CONFIG1 = "/wst"
SlashCmdList["WEAPONSWINGTIMER_CONFIG"] = toggle_config_menu
    
