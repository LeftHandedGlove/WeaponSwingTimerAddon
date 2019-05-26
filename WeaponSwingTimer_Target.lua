local addon_name, addon_data = ...

addon_data.target = {}

addon_data.target.default_settings = {
	enabled = true,
	width = 300,
	height = 10,
    point = "CENTER",
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -150,
	in_combat_alpha = 1.0,
	ooc_alpha = 0.25,
	backplane_alpha = 0.25,
	is_locked = false,
    show_text = true,
	show_offhand = true
}

addon_data.target.main_swing_timer = 0
addon_data.target.main_weapon_speed = 0
addon_data.target.main_weapon_id = 0
addon_data.target.off_swing_timer = 0
addon_data.target.off_weapon_speed = 0
addon_data.target.off_weapon_id = 0
addon_data.target.has_offhand = false
addon_data.target.class = 0
addon_data.target.guid = 0

addon_data.target.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_target_settings then
        character_target_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.target.default_settings) do
        if character_target_settings[setting] == nil then
            character_target_settings[setting] = value
        end
    end
end

addon_data.target.RestoreDefaults = function()
    for setting, value in pairs(addon_data.target.default_settings) do
        character_target_settings[setting] = value
    end
    addon_data.target.UpdateFramePointAndSize()
end

addon_data.target.UpdateInfo = function()
    if UnitExists("target") then
        addon_data.target.class = UnitClass("target")[2]
        addon_data.target.main_weapon_id = GetInventoryItemID("target", 16)
        addon_data.target.off_weapon_id = GetInventoryItemID("target", 17)
        addon_data.target.main_weapon_speed, addon_data.target.off_weapon_speed = UnitAttackSpeed("target")
        if not addon_data.target.off_weapon_speed then
            addon_data.target.has_offhand = false
        else
            addon_data.target.has_offhand = true
        end
        addon_data.target.guid = UnitGUID("target")
    end
end

addon_data.target.ResetMainSwingTimer = function()
    addon_data.target.main_swing_timer = addon_data.target.main_weapon_speed
end

addon_data.target.ResetOffSwingTimer = function()
    addon_data.target.off_swing_timer = addon_data.target.off_weapon_speed
end

addon_data.target.ZeroizeSwingTimer = function()
    addon_data.target.main_swing_timer = 0.0001
    addon_data.target.off_swing_timer = 0.0001
end

addon_data.target.UpdateSwingTimer = function(elapsed)
    if character_target_settings.enabled then
        if addon_data.target.main_swing_timer > 0 then
            addon_data.target.main_swing_timer = addon_data.target.main_swing_timer - elapsed
            if addon_data.target.main_swing_timer < 0 then
                addon_data.target.main_swing_timer = 0
            end
        end
        if addon_data.target.off_swing_timer > 0 then
            addon_data.target.off_swing_timer = addon_data.target.off_swing_timer - elapsed
            if addon_data.target.off_swing_timer < 0 then
                addon_data.target.off_swing_timer = 0
            end
        end
    end
end

addon_data.target.UpdateVisuals = function()
    local settings = character_target_settings
    local frame = addon_data.target.frame
	if (settings.enabled) and (UnitExists("target")) and (not UnitIsDeadOrGhost("target")) then
        frame:Show()
        -- Update the main-hand bar
        local main_speed = addon_data.target.main_weapon_speed
        local main_timer = addon_data.target.main_swing_timer
        if main_speed == 0 then
            main_speed = 2
        end
        -- Update the main-hand bar's width
        main_width = settings.width - (settings.width * (main_timer / main_speed))
        frame.main_hand_bar:SetWidth(main_width)
        frame.main_hand_bar:SetHeight(settings.height)
        -- Update the main-hand bar's text
        if settings.show_text then
            frame.main_hand_bar.text.left:SetText("Main-Hand")
            frame.main_hand_bar.text.right:SetText(tostring(addon_data.utils.SimpleRound(main_timer, 0.1)))
        end
        -- Update the off-hand bar
        if addon_data.target.has_offhand and character_target_settings.show_offhand then
            frame.off_hand_bar:Show()
            local off_speed = addon_data.target.off_weapon_speed
            local off_timer = addon_data.target.off_swing_timer
            if off_speed == 0 then
                off_speed = 2
            end
            -- Update the off-hand bar's width
            off_width = settings.width - (settings.width * (off_timer / off_speed))
            frame.off_hand_bar:SetWidth(off_width)
            frame.off_hand_bar:SetHeight(settings.height)
            -- Update the off-hand bar's text
            if settings.show_text then
                frame.off_hand_bar.text.left:SetText("Off-Hand")
                frame.off_hand_bar.text.right:SetText(tostring(addon_data.utils.SimpleRound(off_timer, 0.1)))
            end
        else
            frame.off_hand_bar:Hide()
        end
        -- Update the frame's appearance based on settings
        frame:SetWidth(settings.width + 2)
        if addon_data.target.has_offhand and character_target_settings.show_offhand then
            frame:SetHeight((settings.height * 2) + 4)
        else
            frame:SetHeight(settings.height + 2)
        end
        -- Update the alpha
        if addon_data.core.in_combat then
            frame:SetAlpha(settings.in_combat_alpha)
        else
            frame:SetAlpha(settings.ooc_alpha)
        end
	else
        frame:Hide()
    end
end

addon_data.target.UpdateFramePointAndSize = function()
    local frame = addon_data.target.frame
    local settings = character_target_settings
    frame:ClearAllPoints()
    frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
end

addon_data.target.OnFrameDragStart = function()
    if not character_target_settings.is_locked then
        addon_data.target.frame:StartMoving()
    end
end

addon_data.target.OnFrameDragStop = function()
    local frame = addon_data.target.frame
    local settings = character_target_settings
    frame:StopMovingOrSizing()
    point, _, rel_point, x_offset, y_offset = frame:GetPoint()
    settings.point = point
    settings.rel_point = rel_point
    settings.x_offset = x_offset
    settings.y_offset = y_offset
    -- addon_data.config.UpdateConfigFrameValues()
end

addon_data.target.InitializeVisuals = function()
    local settings = character_target_settings
    -- Create the frame that holds everything, this is also the backplane
    addon_data.target.frame = CreateFrame("Frame", addon_name .. "TargetFrame", UIParent)
    local frame = addon_data.target.frame
    frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
    local frame_texture = frame:CreateTexture(nil,"ARTWORK")
    frame_texture:SetColorTexture(0, 0, 0, settings.backplane_alpha)
    frame_texture:SetAllPoints(frame)
    frame.texture = frame_texture
    -- Set the scripts for the target's frame
    frame:SetMovable(true)
    frame:EnableMouse(not settings.is_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", addon_data.target.OnFrameDragStart)
    frame:SetScript("OnDragStop", addon_data.target.OnFrameDragStop)
    -- Create the main-hand bar
    frame.main_hand_bar = CreateFrame("Frame", addon_name .. "TargetMainHandBar", frame)
    frame.main_hand_bar:SetPoint("TOPLEFT", 1, -1)
    local main_hand_texture = frame.main_hand_bar:CreateTexture(nil, "ARTWORK")
    main_hand_texture:SetColorTexture(1, 0.5, 0.5, 1)
    main_hand_texture:SetAllPoints(frame.main_hand_bar)
    frame.main_hand_bar.texture = main_hand_texture
    -- Create the main-hand bar's text
    frame.main_hand_bar.text = CreateFrame("Frame", addon_name .. "TargetMainHandBarText", frame.main_hand_bar)
    local main_text = frame.main_hand_bar.text
    main_text:SetAllPoints(frame.main_hand_bar)
    main_text.left = main_text:CreateFontString(nil, "ARTWORK")
    main_text.left:SetFont("Fonts/FRIZQT__.ttf", 10)
    main_text.left:SetJustifyV("CENTER")
    main_text.left:SetJustifyH("LEFT")
    main_text.left:SetPoint("LEFT", 5, 0)
    main_text.right = main_text:CreateFontString(nil, "ARTWORK")
    main_text.right:SetFont("Fonts/FRIZQT__.ttf", 10)
    main_text.right:SetJustifyV("CENTER")
    main_text.right:SetJustifyH("RIGHT")
    main_text.right:SetPoint("LEFT", settings.width - 20, 0)
    -- Create the off-hand bar
    frame.off_hand_bar = CreateFrame("Frame", addon_name .. "TargetOffHandBar", frame)
    frame.off_hand_bar:SetPoint("BOTTOMLEFT", 1, 1)
    local off_hand_texture = frame.off_hand_bar:CreateTexture(nil,"ARTWORK")
    off_hand_texture:SetColorTexture(1, 0.5, 0.5, 1)
    off_hand_texture:SetAllPoints(frame.off_hand_bar)
    frame.off_hand_bar.texture = off_hand_texture
    -- Create the off-hand bar's text
    frame.off_hand_bar.text = CreateFrame("Frame", addon_name .. "TargetOffHandBarText", frame.off_hand_bar)
    local off_text = frame.off_hand_bar.text
    off_text:SetAllPoints(frame.off_hand_bar)
    off_text.left = off_text:CreateFontString(nil, "ARTWORK")
    off_text.left:SetFont("Fonts/FRIZQT__.ttf", 10)
    off_text.left:SetJustifyV("CENTER")
    off_text.left:SetJustifyH("LEFT")
    off_text.left:SetPoint("LEFT", 5, 0)
    off_text.right = off_text:CreateFontString(nil, "ARTWORK")
    off_text.right:SetFont("Fonts/FRIZQT__.ttf", 10)
    off_text.right:SetJustifyV("CENTER")
    off_text.right:SetJustifyH("RIGHT")
    off_text.right:SetPoint("LEFT", settings.width - 20, 0)
    -- Show it off
    addon_data.target.UpdateVisuals()
    frame:Hide()
end
















































--[[
local addon_name, addon_data = ...

addon_data.target = {}

addon_data.target.default_settings = {
	enabled = true,
	width = 300,
	height = 10,
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -150,
	in_combat_alpha = 1.0,
	ooc_alpha = 0.25,
	backplane_alpha = 0.5,
	is_locked = false,
    show_text = true,
	crp_ping_enabled = false,
	crp_fixed_enabled = false,
	crp_fixed_delay = 0.25
}
character_target_settings = character_target_settings

addon_data.target.swing_timer = 0
addon_data.target.weapon_speed = 0
addon_data.target.class = 0
addon_data.target.weapon_id = 0
addon_data.target.guid = 0

addon_data.target.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_target_settings then
        character_target_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.target.default_settings) do
        if character_target_settings[setting] == nil then
            character_target_settings[setting] = value
        end
    end
end

addon_data.target.RestoreDefaults = function()
    for setting, value in pairs(addon_data.target.default_settings) do
        character_target_settings[setting] = value
    end
end

addon_data.target.UpdateInfo = function()
    if UnitExists("target") then
        addon_data.target.class = UnitClass("target")[2]
        addon_data.target.weapon_id = GetInventoryItemID("target", 16)
        addon_data.target.weapon_speed, _ = UnitAttackSpeed("target")
        addon_data.target.guid = UnitGUID("target")
    end
end

addon_data.target.ResetSwingTimer = function()
    addon_data.target.swing_timer = addon_data.target.weapon_speed
end

addon_data.target.ZeroizeSwingTimer = function()
    addon_data.target.swing_timer = 0.0001
end

addon_data.target.UpdateSwingTimer = function(elapsed)
    if addon_data.target.swing_timer > 0 then
        addon_data.target.swing_timer = addon_data.target.swing_timer - elapsed
        if addon_data.target.swing_timer < 0 then
            addon_data.target.swing_timer = 0
        end
    end
end


addon_data.target.UpdateVisuals = function()
	if character_target_settings.enabled then
	end
end

addon_data.target.InitializeVisuals = function()
    local settings = character_target_settings
    -- Create the frame that holds everything, this is also the backplane
    addon_data.target.frame = CreateFrame("Frame", addon_name .. "TargetFrame", UIParent)
    local frame = addon_data.target.frame
    local frame_texture = frame:CreateTexture(nil,"ARTWORK")
    frame_texture:SetColorTexture(0, 0, 0, settings.backplane_alpha)
    frame_texture:SetAllPoints(frame)
    frame.texture = frame_texture
    frame:SetWidth(100)
    frame:SetHeight(100)
    frame:SetPoint(settings.rel_point, settings.x_offset, settings.y_offset)
    frame:Show()
    return nil
end










    -- Set the scripts for the target's frame
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", addon_data.target.OnFrameDragStart)
    frame:SetScript("OnDragStop", addon_data.target.OnFrameDragStop)
    -- Create the main-hand bar
    frame.main_hand_bar = CreateFrame("Frame", addon_name .. "targetMainHandBar", frame)
    local main_hand_texture = frame.main_hand_bar:CreateTexture(nil,"ARTWORK")
    main_hand_texture:SetColorTexture(0.5, 0.5, 1, 1)
    main_hand_texture:SetAllPoints(frame.main_hand_bar)
    frame.main_hand_bar.texture = main_hand_texture
    -- Create the main-hand bar's text
    frame.main_hand_text = frame:CreateFontString(nil, "ARTWORK")
    frame.main_hand_text:SetFont("Fonts/FRIZQT__.ttf", 11)
    frame.main_hand_text:SetJustifyV("CENTER")
    frame.main_hand_text:SetJustifyH("CENTER")
    -- Create the off-hand bar
    frame.off_hand_bar = CreateFrame("Frame", addon_name .. "targetOffHandBar", frame)
    local off_hand_texture = frame.off_hand_bar:CreateTexture(nil,"ARTWORK")
    off_hand_texture:SetColorTexture(0.5, 0.5, 1, 1)
    off_hand_texture:SetAllPoints(frame.off_hand_bar)
    frame.off_hand_bar.texture = off_hand_texture
    -- Create the off-hand bar's text
    frame.off_hand_text = frame:CreateFontString(nil, "ARTWORK")
    frame.off_hand_text:SetFont("Fonts/FRIZQT__.ttf", 11)
    frame.off_hand_text:SetJustifyV("CENTER")
    frame.off_hand_text:SetJustifyH("CENTER")
    -- Show it off
    -- addon_data.target.UpdateVisuals()
    -- frame:Show()
end
]]--