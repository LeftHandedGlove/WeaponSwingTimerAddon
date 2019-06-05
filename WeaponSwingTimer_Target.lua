local addon_name, addon_data = ...

addon_data.target = {}

--[[============================================================================================]]--
--[[===================================== SETTINGS RELATED =====================================]]--
--[[============================================================================================]]--

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
	show_offhand = true
}

addon_data.target.class = 'WARRIOR'
addon_data.target.guid = 0

addon_data.target.main_swing_timer = 0.00001
addon_data.target.prev_main_weapon_speed = 2
addon_data.target.main_weapon_speed = 2
addon_data.target.main_weapon_id = GetInventoryItemID("target", 16)
addon_data.target.main_speed_changed = false

addon_data.target.off_swing_timer = 0.00001
addon_data.target.prev_off_weapon_speed = 2
addon_data.target.off_weapon_speed = 2
addon_data.target.off_weapon_id = GetInventoryItemID("target", 17)
addon_data.target.has_offhand = false
addon_data.target.off_speed_changed = false

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
    addon_data.target.UpdateVisualsOnSettingsChange()
end

--[[============================================================================================]]--
--[[====================================== LOGIC RELATED =======================================]]--
--[[============================================================================================]]--
addon_data.target.OnPlayerTargetChanged = function()
    if UnitExists("target") then
        addon_data.target.class = UnitClass("target")[2]
        addon_data.target.guid = UnitGUID("target")
        addon_data.target.ZeroizeSwingTimers()
    end
end

addon_data.target.OnInventoryChange = function()
    local new_main_guid = GetInventoryItemID("target", 16)
    local new_off_guid = GetInventoryItemID("target", 17)
    -- Check for a main hand weapon change
    if addon_data.target.main_weapon_id ~= new_main_guid then
        addon_data.target.UpdateMainWeaponSpeed()
        addon_data.target.ResetMainSwingTimer()
    end
    addon_data.target.main_weapon_id = new_main_guid
    -- Check for an off hand weapon change
    if addon_data.target.off_weapon_id ~= new_off_guid then
        addon_data.target.UpdateOffWeaponSpeed()
        addon_data.target.ResetOffSwingTimer()
    end
    addon_data.target.off_weapon_id = new_off_guid
end

addon_data.target.OnUpdate = function(elapsed)
    if character_target_settings.enabled and UnitExists("target") then
        -- Update the weapon speed
        addon_data.target.UpdateMainWeaponSpeed()
        addon_data.target.UpdateOffWeaponSpeed()
        -- FIXME: Temp fix until I can nail down the divide by zero error
        if addon_data.target.main_weapon_speed == 0 then
            addon_data.target.main_weapon_speed = 2
        end
        if addon_data.target.off_weapon_speed == 0 then
            addon_data.target.off_weapon_speed = 2
        end
        -- If the weapon speed changed for either hand then a buff occured and we need to modify the timers
        if addon_data.target.main_speed_changed or addon_data.target.off_speed_changed then
            local main_multiplier = addon_data.target.main_weapon_speed / addon_data.target.prev_main_weapon_speed
            addon_data.target.main_swing_timer = addon_data.target.main_swing_timer * main_multiplier
            if addon_data.target.has_offhand then
                local off_multiplier = (addon_data.target.off_weapon_speed / addon_data.target.prev_off_weapon_speed)
                addon_data.target.off_swing_timer = addon_data.target.off_swing_timer * off_multiplier
            end
        end
        -- Update the main hand swing timer
        addon_data.target.UpdateMainSwingTimer(elapsed)
        -- Update the off hand swing timer
        addon_data.target.UpdateOffSwingTimer(elapsed)
    end
    -- Update the visuals
        addon_data.target.UpdateVisualsOnUpdate()
end

addon_data.target.OnCombatLogUnfiltered = function(combat_info)
    local _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _ = unpack(combat_info)
    if (source_guid == addon_data.target.guid) then
        if (event == "SWING_DAMAGE") then
            local _, _, _, _, _, _, _, _, _, is_offhand = select(12, unpack(combat_info))
            if is_offhand then
                addon_data.target.ResetOffSwingTimer()
            else
                addon_data.target.ResetMainSwingTimer()
            end
        elseif (event == "SWING_MISSED") then
            local miss_type, is_offhand = select(12, unpack(combat_info))
            addon_data.core.MissHandler("target", miss_type, is_offhand)
        elseif (event == "SPELL_DAMAGE") or (event == "SPELL_MISSED") then
            addon_data.core.SpellHandler("target", spell_name)
        end
    end
    
end

addon_data.target.ResetMainSwingTimer = function()
    if UnitExists("target") then
        addon_data.target.main_swing_timer = addon_data.target.main_weapon_speed
    end
end

addon_data.target.ResetOffSwingTimer = function()
    if addon_data.target.has_offhand and UnitExists("target") then
        addon_data.target.off_swing_timer = addon_data.target.off_weapon_speed
    end
end

addon_data.target.ZeroizeSwingTimers = function()
    addon_data.target.main_swing_timer = 0.0001
    addon_data.target.off_swing_timer = 0.0001
end

addon_data.target.UpdateMainSwingTimer = function(elapsed)
    if character_target_settings.enabled and UnitExists("target") then
        if addon_data.target.main_swing_timer > 0 then
            addon_data.target.main_swing_timer = addon_data.target.main_swing_timer - elapsed
            if addon_data.target.main_swing_timer < 0 then
                addon_data.target.main_swing_timer = 0
            end
        end
    end
end

addon_data.target.UpdateOffSwingTimer = function(elapsed)
    if character_target_settings.enabled and UnitExists("target") then
        if addon_data.target.has_offhand then
            if addon_data.target.off_swing_timer > 0 then
                addon_data.target.off_swing_timer = addon_data.target.off_swing_timer - elapsed
                if addon_data.target.off_swing_timer < 0 then
                    addon_data.target.off_swing_timer = 0
                end
            end
        end
    end
end

addon_data.target.UpdateMainWeaponSpeed = function()
    if UnitExists("target") then
        -- Handle the nil when first selecting target
        if addon_data.target.main_weapon_speed then
            addon_data.target.prev_main_weapon_speed = addon_data.target.main_weapon_speed
        else
            addon_data.target.prev_main_weapon_speed, _ = UnitAttackSpeed("target")
        end
        -- Update the weapon speed
        addon_data.target.main_weapon_speed, _ = UnitAttackSpeed("target")
        if addon_data.target.main_weapon_speed ~= addon_data.target.prev_main_weapon_speed then
            addon_data.target.main_speed_changed = true
        else
            addon_data.target.main_speed_changed = false
        end
    end
end

addon_data.target.UpdateOffWeaponSpeed = function()
    if UnitExists("target") then
        -- Handle the nil when first selecting target
        if addon_data.target.off_weapon_speed then
            addon_data.target.prev_off_weapon_speed = addon_data.target.off_weapon_speed
        else
            _, addon_data.target.prev_off_weapon_speed = UnitAttackSpeed("target")
        end
        -- Update the weapon speed
        _, addon_data.target.off_weapon_speed = UnitAttackSpeed("target")
        -- Check to see if we have an off-hand
        if (not addon_data.target.off_weapon_speed) or (addon_data.target.off_weapon_speed == 0) then
            addon_data.target.has_offhand = false
        else
            addon_data.target.has_offhand = true
        end
        if addon_data.target.off_weapon_speed ~= addon_data.target.prev_off_weapon_speed then
            addon_data.target.off_speed_changed = true
        else
            addon_data.target.off_speed_changed = false
        end
    end
end

--[[============================================================================================]]--
--[[===================================== VISUALS RELATED ======================================]]--
--[[============================================================================================]]--
addon_data.target.UpdateVisualsOnUpdate = function()
    local settings = character_target_settings
    local frame = addon_data.target.frame
    if settings.enabled and UnitExists("target") then
        frame:Show()
        local main_speed = addon_data.target.main_weapon_speed
        local main_timer = addon_data.target.main_swing_timer
        -- FIXME: Handle divide by 0 error
        if main_speed == 0 then
            main_speed = 2
        end
        -- Update the main bars width
        main_width = settings.width - (settings.width * (main_timer / main_speed))
        frame.main_bar:SetWidth(main_width)
        -- Update the main bars text
        frame.main_left_text:SetText("Main-Hand")
        frame.main_right_text:SetText(tostring(addon_data.utils.SimpleRound(main_timer, 0.1)))
        -- Update the off hand bar
        if addon_data.target.has_offhand and settings.show_offhand then
            frame.off_bar:Show()
            if settings.show_text then
                frame.off_left_text:Show()
                frame.off_right_text:Show()
            end
            local off_speed = addon_data.target.off_weapon_speed
            local off_timer = addon_data.target.off_swing_timer
            -- FIXME: Handle divide by 0 error
            if off_speed == 0 then
                off_speed = 2
            end
            -- Update the off-hand bar's width
            off_width = settings.width - (settings.width * (off_timer / off_speed))
            frame.off_bar:SetWidth(off_width)
            -- Update the off-hand bar's text
            frame.off_left_text:SetText("Off-Hand")
            frame.off_right_text:SetText(tostring(addon_data.utils.SimpleRound(off_timer, 0.1)))
        else
            frame.off_bar:Hide()
            frame.off_left_text:Hide()
            frame.off_right_text:Hide()
        end
        -- Update the frame's appearance based on settings
        if addon_data.target.has_offhand and character_target_settings.show_offhand then
            frame:SetHeight((settings.height * 2) + 2)
        else
            frame:SetHeight(settings.height)
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

addon_data.target.UpdateVisualsOnSettingsChange = function()
    local frame = addon_data.target.frame
    local settings = character_target_settings
    if settings.enabled then
        frame:Show()
        frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
        frame:SetWidth(settings.width)
        frame.backdrop:SetColorTexture(0, 0, 0, settings.backplane_alpha)
        frame.backdrop:SetPoint("TOPLEFT", -1, 1)
        frame.backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
        frame.main_bar:SetPoint("TOPLEFT", 0, 0)
        frame.main_bar:SetHeight(settings.height)
        frame.main_left_text:SetPoint("TOPLEFT", 2, 1)
        frame.main_right_text:SetPoint("TOPRIGHT", -5, 0)
        frame.off_bar:SetPoint("BOTTOMLEFT", 0, 0)
        frame.off_bar:SetHeight(settings.height)
        frame.off_left_text:SetPoint("BOTTOMLEFT", 2, 0)
        frame.off_right_text:SetPoint("BOTTOMRIGHT", -5, 0)
        if settings.show_text then
            frame.main_left_text:Show()
            frame.main_right_text:Show()
            frame.off_left_text:Show()
            frame.off_right_text:Show()
        else
            frame.main_left_text:Hide()
            frame.main_right_text:Hide()
            frame.off_left_text:Hide()
            frame.off_right_text:Hide()
        end
        if settings.show_offhand then
            frame.off_bar:Show()
            if settings.show_text then
                frame.off_left_text:Show()
                frame.off_right_text:Show()
            else
                frame.off_left_text:Hide()
                frame.off_right_text:Hide()
            end
        else
            frame.off_bar:Hide()
            frame.off_left_text:Hide()
            frame.off_right_text:Hide()
        end
    else
        frame:Hide()
    end
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
    addon_data.target.UpdateConfigPanelValues()
end

addon_data.target.InitializeVisuals = function()
    local settings = character_target_settings
    -- Create the frame
    addon_data.target.frame = CreateFrame("Frame", addon_name .. "TargetFrame", UIParent)
    local frame = addon_data.target.frame
    frame:SetMovable(true)
    frame:EnableMouse(not settings.is_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", addon_data.target.OnFrameDragStart)
    frame:SetScript("OnDragStop", addon_data.target.OnFrameDragStop)
    -- Create the backplane
    frame.backdrop = frame:CreateTexture(nil,"BACKGROUND")
    -- Create the main hand bar
    frame.main_bar = frame:CreateTexture(nil,"ARTWORK")
    frame.main_bar:SetColorTexture(0.7, 0.2, 0.2, 1)
    -- Create the main hand bar left text
    frame.main_left_text = frame:CreateFontString(nil, "OVERLAY")
    frame.main_left_text:SetFont("Fonts/FRIZQT__.ttf", 11)
    frame.main_left_text:SetTextColor(1, 1, 1, 1)
    frame.main_left_text:SetJustifyV("CENTER")
    frame.main_left_text:SetJustifyH("LEFT")
    -- Create the main hand bar right text
    frame.main_right_text = frame:CreateFontString(nil, "OVERLAY")
    frame.main_right_text:SetFont("Fonts/FRIZQT__.ttf", 11)
    frame.main_right_text:SetTextColor(1, 1, 1, 1)
    frame.main_right_text:SetJustifyV("CENTER")
    frame.main_right_text:SetJustifyH("RIGHT")
    -- Create the off hand bar
    frame.off_bar = frame:CreateTexture(nil,"ARTWORK")
    frame.off_bar:SetColorTexture(0.7, 0.2, 0.2, 1)
    -- Create the off hand bar left text
    frame.off_left_text = frame:CreateFontString(nil, "OVERLAY")
    frame.off_left_text:SetFont("Fonts/FRIZQT__.ttf", 11)
    frame.off_left_text:SetTextColor(1, 1, 1, 1)
    frame.off_left_text:SetJustifyV("CENTER")
    frame.off_left_text:SetJustifyH("LEFT")
    -- Create the off hand bar right text
    frame.off_right_text = frame:CreateFontString(nil, "OVERLAY")
    frame.off_right_text:SetFont("Fonts/FRIZQT__.ttf", 11)
    frame.off_right_text:SetTextColor(1, 1, 1, 1)
    frame.off_right_text:SetJustifyV("CENTER")
    frame.off_right_text:SetJustifyH("RIGHT")
    -- Show it off
    addon_data.target.UpdateVisualsOnSettingsChange()
    addon_data.target.UpdateVisualsOnUpdate()
    frame:Show()
end

--[[============================================================================================]]--
--[[================================== CONFIG WINDOW RELATED ===================================]]--
--[[============================================================================================]]--

addon_data.target.UpdateConfigPanelValues = function()
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
    addon_data.target.UpdateVisualsOnSettingsChange()
end

addon_data.target.ShowOffHandCheckBoxOnClick = function(self)
    character_target_settings.show_offhand = self:GetChecked()
    addon_data.target.UpdateVisualsOnSettingsChange()
end

addon_data.target.WidthEditBoxOnEnter = function(self)
    character_target_settings.width = tonumber(self:GetText())
    addon_data.target.UpdateVisualsOnSettingsChange()
end

addon_data.target.HeightEditBoxOnEnter = function(self)
    character_target_settings.height = tonumber(self:GetText())
    addon_data.target.UpdateVisualsOnSettingsChange()
end

addon_data.target.XOffsetEditBoxOnEnter = function(self)
    character_target_settings.x_offset = tonumber(self:GetText())
    addon_data.target.UpdateVisualsOnSettingsChange()
end

addon_data.target.YOffsetEditBoxOnEnter = function(self)
    character_target_settings.y_offset = tonumber(self:GetText())
    addon_data.target.UpdateVisualsOnSettingsChange()
end

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
    -- Return the final panel
    addon_data.target.UpdateConfigPanelValues()
    return panel
end

