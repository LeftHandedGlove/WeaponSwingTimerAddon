local addon_name, addon_data = ...

addon_data.hunter = {}

addon_data.hunter.default_settings = {
	enabled = true,
	width = 300,
	height = 10,
    point = "CENTER",
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -200,
	in_combat_alpha = 1.0,
	ooc_alpha = 0.25,
	backplane_alpha = 0.5,
	is_locked = false,
    show_text = true
}

addon_data.hunter.shooting = false
addon_data.hunter.range_speed = 0
addon_data.hunter.auto_cast_time = 0.5
addon_data.hunter.shot_timer = 0
addon_data.hunter.last_shot_time = GetTime()
addon_data.hunter.auto_shot_ready = false

addon_data.hunter.casting = false
addon_data.hunter.cast_timer = 0
addon_data.hunter.cast_time = 0

addon_data.hunter.range_weapon_id = 0
addon_data.hunter.last_pos = {x = 0, y = 0}
addon_data.hunter.has_moved = false
addon_data.hunter.berserk_haste = 0
addon_data.hunter.class = 0
addon_data.hunter.guid = 0

addon_data.hunter.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_hunter_settings then
        character_hunter_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.hunter.default_settings) do
        if character_hunter_settings[setting] == nil then
            character_hunter_settings[setting] = value
        end
    end
end

addon_data.hunter.RestoreDefaults = function()
    for setting, value in pairs(addon_data.hunter.default_settings) do
        character_hunter_settings[setting] = value
    end
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.UpdateInfo = function()
    addon_data.hunter.range_weapon_id = GetInventoryItemID("player", 18)
    addon_data.hunter.class = UnitClass("player")[2]
    addon_data.hunter.guid = UnitGUID("player")
end

addon_data.hunter.UpdateRangeCastSpeedModifier = function()
    local speed = 1.0
    for i=1, 40 do
        name, _ = UnitAura("player", i)
        if name == "Quick Shots" then
            speed = speed/1.3
        end
        if name == "Rapid Shot" then
            speed = speed/1.4
        end
        if name == "Berserking" then
            addon_data.hunter.UpdateBerserkHaste()
            speed = speed/ (1 + addon_data.hunter.berserk_haste)
        end
        if name == "Kiss of the Spider" then
            speed = speed/1.2
        end
        if name == "Curse of Tongues" then
            speed = speed/0.5
        end
    end
    addon_data.hunter.range_cast_speed_modifer = speed
end

addon_data.hunter.UpdateBerserkHaste = function()
    if((UnitHealth("player")/UnitHealthMax("player")) >= 0.40) then
        addon_data.hunter.berserk_haste = (1.30 - (UnitHealth("player")/UnitHealthMax("player")))/3
    else
        addon_data.hunter.berserk_haste = 0.3
    end
end

addon_data.hunter.ResetShotTimer = function()
    -- The timer is reset to either the auto cast time or the difference between the time since the last shot and the current time depending on which is larger
    local curr_time = GetTime()
    local range_speed = addon_data.hunter.range_speed
    if (curr_time - addon_data.hunter.last_shot_time) > (range_speed - addon_data.hunter.auto_cast_time) then
        addon_data.hunter.shot_timer = addon_data.hunter.auto_cast_time
        addon_data.hunter.auto_shot_ready = true
    elseif curr_time ~= addon_data.hunter.last_shot_time then
        addon_data.hunter.shot_timer = curr_time - addon_data.hunter.last_shot_time
        addon_data.hunter.auto_shot_ready = false
    else
        addon_data.hunter.shot_timer = range_speed
        addon_data.hunter.auto_shot_ready = false
    end
end

addon_data.hunter.ZeroizeShotTimer = function()
    addon_data.hunter.shot_timer = addon_data.hunter.auto_cast_time
end

addon_data.hunter.UpdateAutoShotTimer = function(elapsed)
    local curr_time = GetTime()
    addon_data.hunter.shot_timer = addon_data.hunter.shot_timer - elapsed
    -- If the player moved then the timer resets
    if addon_data.hunter.has_moved then
        if addon_data.hunter.shot_timer <= addon_data.hunter.auto_cast_time then
            addon_data.hunter.ResetShotTimer()
        end
    end
    -- If the shot timer is less than zero then a shot occured and the last shot should be update and the timer should be reset
    if addon_data.hunter.shot_timer < 0 then
        addon_data.hunter.last_shot_time = curr_time
        addon_data.hunter.ResetShotTimer()
    -- If the shot timer is less than the auto cast time then the auto shot is ready
    elseif addon_data.hunter.shot_timer <= addon_data.hunter.auto_cast_time then
        addon_data.hunter.auto_shot_ready = true
        -- If we are not shooting then the timer should be reset
        if not addon_data.hunter.shooting then
            addon_data.hunter.ResetShotTimer()
        end
    else
        addon_data.hunter.auto_shot_ready = false
    end
end

addon_data.hunter.UpdatingCastingBar = function(elapsed)
    addon_data.hunter.cast_timer = addon_data.hunter.cast_timer + elapsed
end

addon_data.hunter.OnUpdate = function(elapsed)
    -- Update the ranged attack speed
    addon_data.hunter.range_speed, _, _, _, _, _ = UnitRangedDamage("player")
    addon_data.hunter.UpdateRangeCastSpeedModifier()
    -- Check to see if we have moved
    local new_x, new_y, _, _ = UnitPosition("player")
    local x_changed = addon_data.hunter.last_pos.x ~= new_x
    local y_changed = addon_data.hunter.last_pos.y ~= new_y
    addon_data.hunter.has_moved = x_changed or y_changed
    addon_data.hunter.last_pos.x = new_x
    addon_data.hunter.last_pos.y = new_y
    -- Update the Auto Shot timer based on the updated settings
    addon_data.hunter.UpdateAutoShotTimer(elapsed)
    -- Update the cast bar timers
    if addon_data.hunter.casting then
        addon_data.hunter.UpdatingCastingBar(elapsed)
    end
    -- Update the visuals
    addon_data.hunter.UpdateVisualsOnUpdate()
end

addon_data.hunter.OnStartAutorepeatSpell = function()
    addon_data.hunter.shooting = true
    addon_data.hunter.UpdateInfo()
    addon_data.hunter.ResetShotTimer()
end

addon_data.hunter.OnStopAutorepeatSpell = function()
    addon_data.hunter.shooting = false
    addon_data.hunter.UpdateInfo()
end

addon_data.hunter.OnUnitSpellCastStart = function(spell_name, rank, cast_time)
    if spell_name == "Aimed Shot" or spell_name == "Multi-Shot" then
        addon_data.hunter.casting = true
        addon_data.hunter.cast_timer = 0
        addon_data.hunter.frame.spell_bar:SetColorTexture(0.7, 0.4, 0, 1)
        local name, text, _, start_time, end_time, _, _, _ = UnitCastingInfo("player")
        addon_data.hunter.cast_time = (end_time / 1000) - (start_time / 1000)
        addon_data.hunter.frame.spell_text_center:SetText(name .. " [Rank " .. tostring(rank) .. "]")
    end
end

addon_data.hunter.OnUnitSpellCastSucceeded = function(spell_name, rank, cast_time)
    if spell_name == "Aimed Shot" or spell_name == "Multi-Shot" then
        addon_data.hunter.casting = false
        addon_data.hunter.frame.spell_bar:SetColorTexture(0, 0.5, 0, 1)
    end
end

addon_data.hunter.OnUnitSpellCastDelayed = function(spell_name, rank, cast_time)
    if spell_name == "Aimed Shot" or spell_name == "Multi-Shot" then
        local name, text, _, start_time, end_time, _, _, _ = UnitCastingInfo("player")
        local current_timer = (GetTime() - (startTime / 1000))
        if current_timer < 0 then
            current_timer = 0
        end
        addon_data.hunter.cast_timer = current_timer
    end
end

addon_data.hunter.OnUnitSpellCastInterrupted = function(spell_name, rank, cast_time)
    if spell_name == "Aimed Shot" or spell_name == "Multi-Shot" then
        addon_data.hunter.casting = false
        addon_data.hunter.frame.spell_bar:SetColorTexture(0.7, 0, 0, 1)
        addon_data.hunter.frame.spell_text_center:SetText("Interrupted")
    end
end

addon_data.hunter.UpdateVisualsOnUpdate = function()
    local settings = character_hunter_settings
    local frame = addon_data.hunter.frame
    local range_speed = addon_data.hunter.range_speed
    local shot_timer = addon_data.hunter.shot_timer
    local auto_cast_time = addon_data.hunter.auto_cast_time
	if settings.enabled then
        if addon_data.hunter.auto_shot_ready then
            frame.shot_bar:SetColorTexture(1, 0, 0, 1)
            new_width = settings.width * (auto_cast_time - shot_timer) / auto_cast_time
        else
            frame.shot_bar:SetColorTexture(1, 1, 1, 1)
            new_width = settings.width * ((shot_timer - auto_cast_time) / (range_speed - auto_cast_time))
        end
        if new_width < 10 then
            frame.shot_bar:Hide()
            new_width = 1
        else
            frame.shot_bar:Show()
        end
        frame.shot_bar:SetWidth(new_width)
        if addon_data.hunter.casting then
            frame:SetSize(settings.width, (settings.height * 2) + 2)
            frame.spell_bar:SetAlpha(1)
            new_width = settings.width * (addon_data.hunter.cast_timer / addon_data.hunter.cast_time)
            if new_width > settings.width then
                new_width = settings.width
            end
            frame.spell_bar:SetWidth(new_width)
            
        else
            new_alpha = frame.spell_bar:GetAlpha() - 0.001
            if new_alpha <= 0 then
                new_alpha = 0
                frame:SetSize(settings.width, settings.height)
                frame.spell_text_center:SetText("")
            end
            frame.spell_bar:SetAlpha(new_alpha)
        end
    end
end

addon_data.hunter.UpdateVisualsOnSettingsChange = function()
    local settings = character_hunter_settings
    local frame = addon_data.hunter.frame
	if settings.enabled then
        
        frame.backdrop:SetColorTexture(0, 0, 0, settings.backplane_alpha)
        
        frame:SetPoint("TOP", 0, -600)
        frame.backdrop:SetPoint("TOPLEFT", -1, 1)
        frame.backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
        frame.shot_bar:SetPoint("TOP", 0, 0)
        frame.spell_bar:SetPoint("BOTTOMLEFT", 0, 0)
        
        frame:SetSize(settings.width, settings.height)
        frame.shot_bar:SetHeight(settings.height)
        frame.spell_bar:SetHeight(settings.height)
    end
end

addon_data.hunter.OnFrameDragStart = function()
    if not character_hunter_settings.is_locked then
        addon_data.hunter.frame:StartMoving()
    end
end

addon_data.hunter.OnFrameDragStop = function()
    local frame = addon_data.hunter.frame
    local settings = character_hunter_settings
    frame:StopMovingOrSizing()
    point, _, rel_point, x_offset, y_offset = frame:GetPoint()
    settings.point = point
    settings.rel_point = rel_point
    settings.x_offset = addon_data.utils.SimpleRound(x_offset, 1)
    settings.y_offset = addon_data.utils.SimpleRound(y_offset, 1)
    addon_data.hunter.UpdateConfigPanelValues()
end

addon_data.hunter.InitializeVisuals = function()
    local settings = character_hunter_settings
    -- Create the frame
    addon_data.hunter.frame = CreateFrame("Frame", addon_name .. "HunterAutoshotFrame", UIParent)
    local frame = addon_data.hunter.frame
    frame:SetMovable(true)
    frame:EnableMouse(not settings.is_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", addon_data.hunter.OnFrameDragStart)
    frame:SetScript("OnDragStop", addon_data.hunter.OnFrameDragStop)
    -- Create the backplane
    frame.backdrop = frame:CreateTexture(nil,"BACKGROUND")
    -- Create the shot bar
    frame.shot_bar = frame:CreateTexture(nil, "ARTWORK")
    -- Create the range spell shot bar
    frame.spell_bar = frame:CreateTexture(nil, "ARTWORK")
    -- Create the range spell shot bar center text
    frame.spell_text_center = frame:CreateFontString(nil, "OVERLAY")
    frame.spell_text_center:SetFont("Fonts/FRIZQT__.ttf", 12)
    frame.spell_text_center:SetTextColor(1, 1, 1, 1)
    frame.spell_text_center:SetJustifyV("CENTER")
    frame.spell_text_center:SetJustifyH("LEFT")
    frame.spell_text_center:SetPoint("BOTTOM", 2, 0)
    
    -- Show it off
    addon_data.hunter.UpdateVisualsOnSettingsChange()
    addon_data.hunter.UpdateVisualsOnUpdate()
    frame:Show()
end

addon_data.hunter.UpdateConfigPanelValues = function()
end

addon_data.hunter.CreateConfigPanel = function(parent_panel)
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

