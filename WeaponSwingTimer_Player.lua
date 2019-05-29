local addon_name, addon_data = ...

addon_data.player = {}

addon_data.player.default_settings = {
	enabled = true,
	width = 300,
	height = 10,
    point = "CENTER",
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

addon_data.player.main_swing_timer = 0
addon_data.player.main_weapon_speed = 0
addon_data.player.main_weapon_id = 0
addon_data.player.off_swing_timer = 0
addon_data.player.off_weapon_speed = 0
addon_data.player.off_weapon_id = 0
addon_data.player.has_offhand = false
addon_data.player.class = 0
addon_data.player.guid = 0

addon_data.player.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_player_settings then
        character_player_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.player.default_settings) do
        if character_player_settings[setting] == nil then
            character_player_settings[setting] = value
        end
    end
end

addon_data.player.RestoreDefaults = function()
    for setting, value in pairs(addon_data.player.default_settings) do
        character_player_settings[setting] = value
    end
    addon_data.player.UpdateFramePointAndSize()
end

addon_data.player.UpdateInfo = function()
    addon_data.player.class = UnitClass("player")[2]
    addon_data.player.main_weapon_id = GetInventoryItemID("player", 16)
    addon_data.player.off_weapon_id = GetInventoryItemID("player", 17)
    addon_data.player.main_weapon_speed, addon_data.player.off_weapon_speed = UnitAttackSpeed("player")
    if not addon_data.player.off_weapon_speed then
        addon_data.player.has_offhand = false
    else
        addon_data.player.has_offhand = true
    end
    addon_data.player.guid = UnitGUID("player")
end

addon_data.player.ResetMainSwingTimer = function()
    addon_data.player.main_swing_timer = addon_data.player.main_weapon_speed
end

addon_data.player.ResetOffSwingTimer = function()
    addon_data.player.off_swing_timer = addon_data.player.off_weapon_speed
end

addon_data.player.ZeroizeSwingTimer = function()
    addon_data.player.main_swing_timer = 0.0001
    addon_data.player.off_swing_timer = 0.0001
end

addon_data.player.UpdateSwingTimer = function(elapsed)
    if character_target_settings.enabled then 
        if addon_data.player.main_swing_timer > 0 then
            addon_data.player.main_swing_timer = addon_data.player.main_swing_timer - elapsed
            if addon_data.player.main_swing_timer < 0 then
                addon_data.player.main_swing_timer = 0
            end
        end
        if addon_data.player.off_swing_timer > 0 then
            addon_data.player.off_swing_timer = addon_data.player.off_swing_timer - elapsed
            if addon_data.player.off_swing_timer < 0 then
                addon_data.player.off_swing_timer = 0
            end
        end
    end
end

addon_data.player.UpdateVisuals = function()
    local settings = character_player_settings
    local frame = addon_data.player.frame
	if settings.enabled then
        frame:Show()
        -- Update the main-hand bar
        local main_speed = addon_data.player.main_weapon_speed
        local main_timer = addon_data.player.main_swing_timer
        if main_speed == 0 then
            main_speed = 2
        end
        -- Update the main-hand bar's width
        main_width = settings.width - (settings.width * (main_timer / main_speed))
        frame.main_hand_bar:SetWidth(main_width)
        frame.main_hand_bar:SetHeight(settings.height)
        -- Update the main-hand bar's text
        frame.main_hand_bar.text.left:SetPoint("LEFT", 5, 0)
        frame.main_hand_bar.text.right:SetPoint("LEFT", settings.width - 20, 0)
        if settings.show_text then
            frame.main_hand_bar.text.left:SetText("Main-Hand")
            frame.main_hand_bar.text.right:SetText(tostring(addon_data.utils.SimpleRound(main_timer, 0.1)))
        else
            frame.main_hand_bar.text.left:SetText("")
            frame.main_hand_bar.text.right:SetText("")
        end
        -- Update the off-hand bar
        if addon_data.player.has_offhand and character_player_settings.show_offhand then
            frame.off_hand_bar:Show()
            local off_speed = addon_data.player.off_weapon_speed
            local off_timer = addon_data.player.off_swing_timer
            if off_speed == 0 then
                off_speed = 2
            end
            -- Update the off-hand bar's width
            off_width = settings.width - (settings.width * (off_timer / off_speed))
            frame.off_hand_bar:SetWidth(off_width)
            frame.off_hand_bar:SetHeight(settings.height)
            -- Update the off-hand bar's text
            frame.off_hand_bar.text.left:SetPoint("LEFT", 5, 0)
            frame.off_hand_bar.text.right:SetPoint("LEFT", settings.width - 20, 0)
            if settings.show_text then
                frame.off_hand_bar.text.left:SetText("Off-Hand")
                frame.off_hand_bar.text.right:SetText(tostring(addon_data.utils.SimpleRound(off_timer, 0.1)))
            else
                frame.off_hand_bar.text.left:SetText("")
                frame.off_hand_bar.text.right:SetText("")
            end
        else
            frame.off_hand_bar:Hide()
        end
        -- Update the frame's appearance based on settings
        frame:SetWidth(settings.width + 2)
        if addon_data.player.has_offhand and character_player_settings.show_offhand then
            frame:SetHeight((settings.height * 2) + 4)
        else
            frame:SetHeight(settings.height + 2)
        end
        -- Update the alpha
        frame.texture:SetColorTexture(0, 0, 0, settings.backplane_alpha)
        if addon_data.core.in_combat then
            frame:SetAlpha(settings.in_combat_alpha)
        else
            frame:SetAlpha(settings.ooc_alpha)
        end
	else
        frame:Hide()
    end
end

addon_data.player.UpdateFramePointAndSize = function()
    local frame = addon_data.player.frame
    local settings = character_player_settings
    frame:ClearAllPoints()
    frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
    frame:SetSize(settings.width, settings.height)
    addon_data.player.UpdateConfigValues()
end

addon_data.player.OnFrameDragStart = function()
    if not character_player_settings.is_locked then
        addon_data.player.frame:StartMoving()
    end
end

addon_data.player.OnFrameDragStop = function()
    local frame = addon_data.player.frame
    local settings = character_player_settings
    frame:StopMovingOrSizing()
    point, _, rel_point, x_offset, y_offset = frame:GetPoint()
    settings.point = point
    settings.rel_point = rel_point
    settings.x_offset = addon_data.utils.SimpleRound(x_offset, 1)
    settings.y_offset = addon_data.utils.SimpleRound(y_offset, 1)
    addon_data.player.UpdateConfigValues()
end

addon_data.player.InitializeVisuals = function()
    local settings = character_player_settings
    -- Create the frame that holds everything, this is also the backplane
    addon_data.player.frame = CreateFrame("Frame", addon_name .. "PlayerFrame", UIParent)
    local frame = addon_data.player.frame
    frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
    local frame_texture = frame:CreateTexture(nil,"ARTWORK")
    frame_texture:SetColorTexture(0, 0, 0, settings.backplane_alpha)
    frame_texture:SetAllPoints(frame)
    frame.texture = frame_texture
    -- Set the scripts for the player's frame
    frame:SetMovable(true)
    frame:EnableMouse(not settings.is_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", addon_data.player.OnFrameDragStart)
    frame:SetScript("OnDragStop", addon_data.player.OnFrameDragStop)
    -- Create the main-hand bar
    frame.main_hand_bar = CreateFrame("Frame", addon_name .. "PlayerMainHandBar", frame)
    frame.main_hand_bar:SetPoint("TOPLEFT", 1, -1)
    local main_hand_texture = frame.main_hand_bar:CreateTexture(nil, "ARTWORK")
    main_hand_texture:SetColorTexture(0.3, 0.3, 0.6, 1)
    main_hand_texture:SetAllPoints(frame.main_hand_bar)
    frame.main_hand_bar.texture = main_hand_texture
    -- Create the main-hand bar's text
    frame.main_hand_bar.text = CreateFrame("Frame", addon_name .. "PlayerMainHandBarText", frame.main_hand_bar)
    local main_text = frame.main_hand_bar.text
    main_text:SetAllPoints(frame.main_hand_bar)
    main_text.left = main_text:CreateFontString(nil, "ARTWORK")
    main_text.left:SetFont("Fonts/FRIZQT__.ttf", 10)
    main_text.left:SetTextColor(1, 1, 1, 1)
    main_text.left:SetJustifyV("CENTER")
    main_text.left:SetJustifyH("LEFT")
    main_text.right = main_text:CreateFontString(nil, "ARTWORK")
    main_text.right:SetFont("Fonts/FRIZQT__.ttf", 10)
    main_text.right:SetTextColor(1, 1, 1, 1)
    main_text.right:SetJustifyV("CENTER")
    main_text.right:SetJustifyH("RIGHT")
    -- Create the off-hand bar
    frame.off_hand_bar = CreateFrame("Frame", addon_name .. "PlayerOffHandBar", frame)
    frame.off_hand_bar:SetPoint("BOTTOMLEFT", 1, 1)
    local off_hand_texture = frame.off_hand_bar:CreateTexture(nil,"ARTWORK")
    off_hand_texture:SetColorTexture(0.3, 0.3, 0.6, 1)
    off_hand_texture:SetAllPoints(frame.off_hand_bar)
    frame.off_hand_bar.texture = off_hand_texture
    -- Create the off-hand bar's text
    frame.off_hand_bar.text = CreateFrame("Frame", addon_name .. "PlayerOffHandBarText", frame.off_hand_bar)
    local off_text = frame.off_hand_bar.text
    off_text:SetAllPoints(frame.off_hand_bar)
    off_text.left = off_text:CreateFontString(nil, "ARTWORK")
    off_text.left:SetFont("Fonts/FRIZQT__.ttf", 10)
    off_text.left:SetTextColor(1, 1, 1, 1)
    off_text.left:SetJustifyV("CENTER")
    off_text.left:SetJustifyH("LEFT")
    off_text.right = off_text:CreateFontString(nil, "ARTWORK")
    off_text.right:SetFont("Fonts/FRIZQT__.ttf", 10)
    off_text.right:SetTextColor(1, 1, 1, 1)
    off_text.right:SetJustifyV("CENTER")
    off_text.right:SetJustifyH("RIGHT")
    -- Show it off
    addon_data.player.UpdateVisuals()
    frame:Show()
end

addon_data.player.UpdateConfigValues = function()
    local panel = addon_data.player.config_frame
    local settings = character_player_settings
    panel.enabled_checkbox:SetChecked(settings.enabled)
    panel.show_offhand_checkbox:SetChecked(settings.show_offhand)
    panel.width_editbox:SetText(tostring(settings.width))
    panel.width_editbox:SetCursorPosition(0)
    panel.height_editbox:SetText(tostring(settings.height))
    panel.height_editbox:SetCursorPosition(0)
    panel.x_offset_editbox:SetText(tostring(settings.x_offset))
    panel.x_offset_editbox:SetCursorPosition(0)
    panel.y_offset_editbox:SetText(tostring(settings.y_offset))
    panel.y_offset_editbox:SetCursorPosition(0)
end

addon_data.player.EnabledCheckBoxOnClick = function(self)
    character_player_settings.enabled = self:GetChecked()
end

addon_data.player.ShowOffHandCheckBoxOnClick = function(self)
    character_player_settings.show_offhand = self:GetChecked()
end

addon_data.player.WidthEditBoxOnEnter = function(self)
    character_player_settings.width = tonumber(self:GetText())
    addon_data.player.UpdateFramePointAndSize()
end

addon_data.player.HeightEditBoxOnEnter = function(self)
    character_player_settings.height = tonumber(self:GetText())
    addon_data.player.UpdateFramePointAndSize()
end

addon_data.player.XOffsetEditBoxOnEnter = function(self)
    character_player_settings.x_offset = tonumber(self:GetText())
    addon_data.player.UpdateFramePointAndSize()
end

addon_data.player.YOffsetEditBoxOnEnter = function(self)
    character_player_settings.y_offset = tonumber(self:GetText())
    addon_data.player.UpdateFramePointAndSize()
end

addon_data.player.CreateConfigPanel = function(parent_panel)
    addon_data.player.config_frame = CreateFrame("Frame", addon_name .. "PlayerConfigPanel", parent_panel)
    local panel = addon_data.player.config_frame
    local settings = character_player_settings
    -- Title Text
    panel.title_text = addon_data.config.TextFactory(panel, "Player Swing Bar Settings", 20)
    panel.title_text:SetPoint("TOPLEFT", 15, 0)
    panel.title_text:SetTextColor(1, 0.9, 0, 1)
    -- Enabled Checkbox
    panel.enabled_checkbox = addon_data.config.CheckBoxFactory(
        "PlayerEnabledCheckBox",
        panel,
        " Enable",
        "Enables the player's swing bars.",
        addon_data.player.EnabledCheckBoxOnClick)
    panel.enabled_checkbox:SetPoint("TOPLEFT", 10, -30)
    -- Show Off-Hand Checkbox
    panel.show_offhand_checkbox = addon_data.config.CheckBoxFactory(
        "PlayerShowOffHandCheckBox",
        panel,
        " Show Off-Hand",
        "Enables the player's off-hand swing bar.",
        addon_data.player.ShowOffHandCheckBoxOnClick)
    panel.show_offhand_checkbox:SetPoint("TOPLEFT", 10, -50)
    -- Width EditBox
    panel.width_editbox = addon_data.config.EditBoxFactory(
        "PlayerWidthEditBox",
        panel,
        "Bar Width",
        100,
        25,
        addon_data.player.WidthEditBoxOnEnter)
    panel.width_editbox:SetPoint("TOPLEFT", 15, -100, "BOTTOMRIGHT", 115, -125)
    -- Height EditBox
    panel.height_editbox = addon_data.config.EditBoxFactory(
        "PlayerHeightEditBox",
        panel,
        "Bar Height",
        100,
        25,
        addon_data.player.HeightEditBoxOnEnter)
    panel.height_editbox:SetPoint("TOPLEFT", 125, -100, "BOTTOMRIGHT", 225, -125)
    -- X Offset EditBox
    panel.x_offset_editbox = addon_data.config.EditBoxFactory(
        "PlayerXOffsetEditBox",
        panel,
        "X Offset",
        100,
        25,
        addon_data.player.XOffsetEditBoxOnEnter)
    panel.x_offset_editbox:SetPoint("TOPLEFT", 15, -150, "BOTTOMRIGHT", 115, -175)
    -- Y Offset EditBox
    panel.y_offset_editbox = addon_data.config.EditBoxFactory(
        "PlayerYOffsetEditBox",
        panel,
        "Y Offset",
        100,
        25,
        addon_data.player.YOffsetEditBoxOnEnter)
    panel.y_offset_editbox:SetPoint("TOPLEFT", 125, -150, "BOTTOMRIGHT", 225, -175)
    -- Return the final panel
    addon_data.player.UpdateConfigValues()
    return panel
end

