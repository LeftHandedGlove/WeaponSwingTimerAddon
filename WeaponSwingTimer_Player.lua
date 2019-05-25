local addon_name, addon_data = ...

addon_data.player = {}

addon_data.player.default_settings = {
	enabled = true,
	width = 300,
	height = 10,
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -100,
	in_combat_alpha = 1.0,
	ooc_alpha = 0.25,
	backplane_alpha = 0.5,
	is_locked = false,
    show_text = true,
	show_offhand = true
}
addon_data.player.settings = character_player_settings

addon_data.player.swing_timer = 0
addon_data.player.weapon_speed = 0
addon_data.player.class = 0
addon_data.player.weapon_id = 0
addon_data.player.guid = 0

addon_data.player.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not addon_data.player.settings then
        addon_data.player.settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.player.default_settings) do
        if addon_data.player.settings[setting] == nil then
            addon_data.player.settings[setting] = value
        end
    end
end

addon_data.player.RestoreDefaults = function()
    for setting, value in pairs(addon_data.player.default_settings) do
        addon_data.player.settings[setting] = value
    end
end

addon_data.player.UpdateInfo = function()
    addon_data.player.class = UnitClass("player")[2]
    addon_data.player.weapon_id = GetInventoryItemID("player", 16)
    addon_data.player.weapon_speed, _ = UnitAttackSpeed("player")
    addon_data.player.guid = UnitGUID("player")
end

addon_data.player.ResetSwingTimer = function()
    addon_data.player.swing_timer = addon_data.player.weapon_speed
end

addon_data.player.ZeroizeSwingTimer = function()
    addon_data.player.swing_timer = 0.0001
end

addon_data.player.UpdateSwingTimer = function(elapsed)
    if addon_data.player.swing_timer > 0 then
        addon_data.player.swing_timer = addon_data.player.swing_timer - elapsed
        if addon_data.player.swing_timer < 0 then
            addon_data.player.swing_timer = 0
        end
    end
    addon_data.player.swing_timer = 0.0001
end

addon_data.player.UpdateVisuals = function()
    local settings = addon_data.player.settings
	if settings.enabled then
        -- Update the main-hand bar's width
        
        -- Update the main-hand bar's text
        if settings.show_text then
        else
        end
        -- Update the off-hand bar's width
        -- Update the off-hand bar's text
        if settings.show_text then
        else
        end
        -- Update the frame's appearance based on settings
	end
end

addon_data.player.InitializeVisuals = function()
    local settings = addon_data.player.settings
    -- Create the frame that holds everything, this is also the backplane
    addon_data.player.frame = CreateFrame("Frame", addon_name .. "PlayerFrame", UIParent)
    local frame = addon_data.player.frame
    local frame_texture = frame:CreateTexture(nil,"ARTWORK")
    frame_texture:SetColorTexture(0, 0, 0, settings.backplane_alpha)
    frame_texture:SetAllPoints(frame)
    frame.texture = frame_texture
    frame:Show()
    -- Create the main-hand bar
    frame.main_hand_bar = CreateFrame("Frame", addon_name .. "PlayerMainHandBar", frame)
    local main_hand_texture = frame.main_hand_bar:CreateTexture(nil,"ARTWORK")
    main_hand_texture:SetColorTexture(0.8, 1, 0.8, 1)
    main_hand_texture:SetAllPoints(frame.main_hand_bar)
    frame.main_hand_bar.texture = main_hand_texture
    -- Create the main-hand bar's text
    frame.main_hand_text = frame:CreateFontString(nil, "ARTWORK")
    frame.main_hand_text:SetFont("Fonts/FRIZQT__.ttf", 11)
    frame.main_hand_text:SetJustifyV("CENTER")
    frame.main_hand_text:SetJustifyH("CENTER")
    -- Create the off-hand bar
    -- Create the off-hand bar's texture
    -- Create the off-hand bar's text
end
