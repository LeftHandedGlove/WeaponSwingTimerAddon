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
	backplane_alpha = 0.5,
	is_locked = false,
    show_text = true,
	show_offhand = true,
    crp_ping_enabled = false,
    crp_fixed_enabled = false,
    crp_fixed_delay = 0.25
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
        if addon_data.target.has_offhand and character_target_settings.show_offhand then
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
        --[[
        -- Update the CRP lines
        local main_ping_offset = 0
        local off_ping_offset = 0
        if settings.crp_ping_enabled then
            frame.crp_main_ping_line:Show()
            local down, up, lagHome, lagWorld = GetNetStats()
            main_ping_offset = (settings.width * (lagHome / 1000)) / addon_data.target.main_weapon_speed
            frame.crp_main_ping_line:SetWidth(2)
            frame.crp_main_ping_line:SetHeight(settings.height)
            frame.crp_main_ping_line:SetPoint("TOPRIGHT", -main_ping_offset, -1)
            if addon_data.target.has_offhand then
                frame.crp_off_ping_line:Show()
                off_ping_offset = (settings.width * (lagHome / 1000)) / addon_data.target.off_weapon_speed
                frame.crp_off_ping_line:SetWidth(2)
                frame.crp_off_ping_line:SetHeight(settings.height)
                frame.crp_off_ping_line:SetPoint("BOTTOMRIGHT", -off_ping_offset, 1)
            else
                frame.crp_off_ping_line:Hide()
            end
        else
            frame.crp_main_ping_line:Hide()
            frame.crp_off_ping_line:Hide()
        end
        if settings.crp_fixed_enabled then
            frame.crp_main_fixed_line:Show()
            main_fixed_offset = ((settings.width * settings.crp_fixed_delay) / 
                                addon_data.target.main_weapon_speed) + main_ping_offset
            frame.crp_main_fixed_line:SetWidth(2)
            frame.crp_main_fixed_line:SetHeight(settings.height)
            frame.crp_main_fixed_line:SetPoint("TOPRIGHT", -main_fixed_offset, -1)
            if addon_data.target.has_offhand then
                frame.crp_off_fixed_line:Show()
                off_fixed_offset = ((settings.width * settings.crp_fixed_delay) / 
                                   addon_data.target.off_weapon_speed) + off_ping_offset
                frame.crp_off_fixed_line:SetWidth(2)
                frame.crp_off_fixed_line:SetHeight(settings.height)
                frame.crp_off_fixed_line:SetPoint("BOTTOMRIGHT", -off_fixed_offset, 1)
            else
                frame.crp_off_fixed_line:Hide()
            end
        else
            frame.crp_main_fixed_line:Hide()
            frame.crp_off_fixed_line:Hide()
        end
        ]]--
	else
        frame:Hide()
    end
end

addon_data.target.UpdateFramePointAndSize = function()
    local frame = addon_data.target.frame
    local settings = character_target_settings
    frame:ClearAllPoints()
    frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
    addon_data.target.UpdateConfigValues()
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
    settings.x_offset = addon_data.utils.SimpleRound(x_offset, 1)
    settings.y_offset = addon_data.utils.SimpleRound(y_offset, 1)
    addon_data.target.UpdateConfigValues()
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
    main_hand_texture:SetColorTexture(0.7, 0.2, 0.2, 1)
    main_hand_texture:SetAllPoints(frame.main_hand_bar)
    frame.main_hand_bar.texture = main_hand_texture
    -- Create the main-hand bar's text
    frame.main_hand_bar.text = CreateFrame("Frame", addon_name .. "TargetMainHandBarText", frame.main_hand_bar)
    frame.main_hand_bar.text:SetFrameStrata("DIALOG")
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
    frame.off_hand_bar = CreateFrame("Frame", addon_name .. "TargetOffHandBar", frame)
    frame.off_hand_bar:SetPoint("BOTTOMLEFT", 1, 1)
    local off_hand_texture = frame.off_hand_bar:CreateTexture(nil,"ARTWORK")
    off_hand_texture:SetColorTexture(0.7, 0.2, 0.2, 1)
    off_hand_texture:SetAllPoints(frame.off_hand_bar)
    frame.off_hand_bar.texture = off_hand_texture
    -- Create the off-hand bar's text
    frame.off_hand_bar.text = CreateFrame("Frame", addon_name .. "TargetOffHandBarText", frame.off_hand_bar)
    frame.off_hand_bar.text:SetFrameStrata("DIALOG")
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
    --[[
    -- Create the main-hand CRP ping delay line
    frame.crp_main_ping_line = CreateFrame("Frame", addon_name .. "CRPMainPingDelayLine", frame)
    frame.crp_main_ping_line:SetFrameStrata("HIGH")
    local ping_texture = frame.crp_main_ping_line:CreateTexture(nil, "ARTWORK")
    ping_texture:SetColorTexture(1, 0, 0, 1)
    ping_texture:SetAllPoints(frame.crp_main_ping_line)
    frame.crp_main_ping_line.texture = ping_texture
    -- Create the off-hand CRP ping delay line
    frame.crp_off_ping_line = CreateFrame("Frame", addon_name .. "CRPOffPingDelayLine", frame)
    frame.crp_off_ping_line:SetFrameStrata("HIGH")
    local ping_texture = frame.crp_off_ping_line:CreateTexture(nil, "ARTWORK")
    ping_texture:SetColorTexture(1, 0, 0, 1)
    ping_texture:SetAllPoints(frame.crp_off_ping_line)
    -- Create the main-hand CRP fixed delay line
    frame.crp_main_fixed_line = CreateFrame("Frame", addon_name .. "CRPMainFixedDelayLine", frame)
    frame.crp_main_fixed_line:SetFrameStrata("HIGH")
    local fixed_texture = frame.crp_main_fixed_line:CreateTexture(nil, "ARTWORK")
    fixed_texture:SetColorTexture(1, 1, 0, 1)
    fixed_texture:SetAllPoints(frame.crp_main_fixed_line)
    frame.crp_main_fixed_line.texture = fixed_texture
    -- Create the off-hand CRP fixed delay line
    frame.crp_off_fixed_line = CreateFrame("Frame", addon_name .. "CRPOffFixedDelayLine", frame)
    frame.crp_off_fixed_line:SetFrameStrata("HIGH")
    local fixed_texture = frame.crp_off_fixed_line:CreateTexture(nil, "ARTWORK")
    fixed_texture:SetColorTexture(1, 1, 0, 1)
    fixed_texture:SetAllPoints(frame.crp_off_fixed_line)
    frame.crp_off_fixed_line.texture = fixed_texture
    ]]--
    -- Show it off
    addon_data.target.UpdateVisuals()
    frame:Hide()
end

addon_data.target.UpdateConfigValues = function()
    local panel = addon_data.target.config_frame
    local settings = character_target_settings
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

addon_data.target.EnabledCheckBoxOnClick = function(self)
    character_target_settings.enabled = self:GetChecked()
end

addon_data.target.ShowOffHandCheckBoxOnClick = function(self)
    character_target_settings.show_offhand = self:GetChecked()
end

addon_data.target.WidthEditBoxOnEnter = function(self)
    character_target_settings.width = tonumber(self:GetText())
    addon_data.target.UpdateFramePointAndSize()
end

addon_data.target.HeightEditBoxOnEnter = function(self)
    character_target_settings.height = tonumber(self:GetText())
    addon_data.target.UpdateFramePointAndSize()
end

addon_data.target.XOffsetEditBoxOnEnter = function(self)
    character_target_settings.x_offset = tonumber(self:GetText())
    addon_data.target.UpdateFramePointAndSize()
end

addon_data.target.YOffsetEditBoxOnEnter = function(self)
    character_target_settings.y_offset = tonumber(self:GetText())
    addon_data.target.UpdateFramePointAndSize()
end

--[[
addon_data.target.CRPPingEnabledCheckBoxOnClick = function(self)
    character_target_settings.crp_ping_enabled = self:GetChecked()
end

addon_data.target.CRPFixedEnabledCheckBoxOnClick = function(self)
    character_target_settings.crp_fixed_enabled = self:GetChecked()
end

addon_data.target.CRPFixedDelayEditBoxOnEnter = function(self)
    character_target_settings.crp_fixed_delay = tonumber(self:GetText())
end
]]--

addon_data.target.CreateConfigPanel = function(parent_panel)
    addon_data.target.config_frame = CreateFrame("Frame", addon_name .. "TargetConfigPanel", parent_panel)
    local panel = addon_data.target.config_frame
    local settings = character_target_settings
    -- Title Text
    panel.title_text = addon_data.config.TextFactory(panel, "Target Swing Bar Settings", 20)
    panel.title_text:SetPoint("TOPLEFT", 15, 0)
    panel.title_text:SetTextColor(1, 0.9, 0, 1)
    -- Enabled Checkbox
    panel.enabled_checkbox = addon_data.config.CheckBoxFactory(
        "TargetEnabledCheckBox",
        panel,
        " Enable",
        "Enables the target's swing bars.",
        addon_data.target.EnabledCheckBoxOnClick)
    panel.enabled_checkbox:SetPoint("TOPLEFT", 10, -30)
    -- Show Off-Hand Checkbox
    panel.show_offhand_checkbox = addon_data.config.CheckBoxFactory(
        "TargetShowOffHandCheckBox",
        panel,
        " Show Off-Hand",
        "Enables the target's off-hand swing bar.",
        addon_data.target.ShowOffHandCheckBoxOnClick)
    panel.show_offhand_checkbox:SetPoint("TOPLEFT", 10, -50)
    -- Width EditBox
    panel.width_editbox = addon_data.config.EditBoxFactory(
        "TargetWidthEditBox",
        panel,
        "Bar Width",
        100,
        25,
        addon_data.target.WidthEditBoxOnEnter)
    panel.width_editbox:SetPoint("TOPLEFT", 15, -100, "BOTTOMRIGHT", 115, -125)
    -- Height EditBox
    panel.height_editbox = addon_data.config.EditBoxFactory(
        "TargetHeightEditBox",
        panel,
        "Bar Height",
        100,
        25,
        addon_data.target.HeightEditBoxOnEnter)
    panel.height_editbox:SetPoint("TOPLEFT", 125, -100, "BOTTOMRIGHT", 225, -125)
    -- X Offset EditBox
    panel.x_offset_editbox = addon_data.config.EditBoxFactory(
        "TargetXOffsetEditBox",
        panel,
        "X Offset",
        100,
        25,
        addon_data.target.XOffsetEditBoxOnEnter)
    panel.x_offset_editbox:SetPoint("TOPLEFT", 15, -150, "BOTTOMRIGHT", 115, -175)
    -- Y Offset EditBox
    panel.y_offset_editbox = addon_data.config.EditBoxFactory(
        "TargetYOffsetEditBox",
        panel,
        "Y Offset",
        100,
        25,
        addon_data.target.YOffsetEditBoxOnEnter)
    panel.y_offset_editbox:SetPoint("TOPLEFT", 125, -150, "BOTTOMRIGHT", 225, -175)
    --[[
    -- CRP Title
    panel.crp_title_text = addon_data.config.TextFactory(panel, "Crit Reactive Proc Settings", 20)
    panel.crp_title_text:SetPoint("TOPLEFT", 350, -15)
    panel.crp_title_text:SetTextColor(1, 0.9, 0, 1)
    -- CRP Ping Enabled Checkbox
    panel.crp_ping_enabled_checkbox = addon_data.config.CheckBoxFactory(
        "TargetCRPPingEnableCheckBox",
        panel,
        " CRP Ping Line Enable",
        "Enables the CRP ping delay line over the target's swing bars.",
        addon_data.target.CRPPingEnabledCheckBoxOnClick)
    panel.crp_ping_enabled_checkbox:SetPoint("TOPLEFT", 310, -50)
    panel.crp_ping_enabled_checkbox:SetChecked(character_target_settings.crp_ping_enabled)
    -- CRP Fixed Enabled Checkbox
    panel.crp_fixed_enabled_checkbox = addon_data.config.CheckBoxFactory(
        "TargetCRPFixedEnableCheckBox",
        panel,
        " CRP Fixed Line Enable",
        "Enables the CRP fixed delay line over the target's swing bars.",
        addon_data.target.CRPFixedEnabledCheckBoxOnClick)
    panel.crp_fixed_enabled_checkbox:SetPoint("TOPLEFT", 310, -70)
    panel.crp_fixed_enabled_checkbox:SetChecked(character_target_settings.enabled)
    -- CRP Fixed Delay Editbox
    panel.crp_fixed_delay_editbox = addon_data.config.EditBoxFactory(
        "TargetCRPFixedDelayEditBox",
        panel,
        "CRP Fixed Delay (secs)",
        150,
        25,
        addon_data.target.CRPFixedDelayEditBoxOnEnter)
    panel.crp_fixed_delay_editbox:SetPoint("TOPLEFT", 345, -125, "BOTTOMRIGHT", 495, -150)
    panel.crp_fixed_delay_editbox:SetText(tostring(settings.crp_fixed_delay))
    panel.crp_fixed_delay_editbox:SetCursorPosition(0)
    ]]--
    -- Return the final panel
    addon_data.target.UpdateConfigValues()
    return panel
end

