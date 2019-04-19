player_weapon_speed = 0
target_weapon_speed = 0
in_combat = false
class = "Undefined"

local function OnPlayerRegenDisabled()
    WSTSwingFrame:Show()
end

local function OnPlayerRegenEnabled()
    WSTSwingFrame:Hide()
end

function LeftHandedGlove_WST_OnEvent(event, ...)
    if (event == "PLAYER_REGEN_DISABLED") then
        OnPlayerRegenDisabled()
    elseif (event == "PLAYER_REGEN_ENABLED") then
        OnPlayerRegenEnabled()
    end
end

function LeftHandedGlove_WST_OnLoad()
    
    WSTSwingFrame:RegisterEvent("ADDON_LOADED")
    WSTSwingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	WSTSwingFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    WSTSwingFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    WSTSwingFrame:RegisterEvent("UNIT_COMBAT")
    DEFAULT_CHAT_FRAME:AddMessage("WeaponSwingTimer by LeftHandedGlove Loaded.")
end

function LeftHandedGlove_WST_OnUpdate(duration)
    -- print("Update")
end

SLASH_WEAPONSWINGTIMER_CONFIG1 = "/wst"
SlashCmdList["WEAPONSWINGTIMER_CONFIG"] = function()
    print("Howdy!")
end
    
