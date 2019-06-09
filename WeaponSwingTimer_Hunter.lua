local addon_name, addon_data = ...

addon_data.hunter = {}

addon_data.hunter.shot_spell_ids = {
    [75] = {spell_name = 'Auto Shot', rank = nil, cooldown = nil},
    [2643] = {spell_name = 'Multi-Shot', rank = 1, cooldown = 10},
    [14288] = {spell_name = 'Multi-Shot', rank = 2, cooldown = 10},
    [14289] = {spell_name = 'Multi-Shot', rank = 3, cooldown = 10},
    [14290] = {spell_name = 'Multi-Shot', rank = 4, cooldown = 10},
    [25294] = {spell_name = 'Multi-Shot', rank = 5, cooldown = 10},
    [19434] = {spell_name = 'Aimed Shot', rank = 1, cooldown = 6},
    [20900] = {spell_name = 'Aimed Shot', rank = 2, cooldown = 6},
    [20901] = {spell_name = 'Aimed Shot', rank = 3, cooldown = 6},
    [20902] = {spell_name = 'Aimed Shot', rank = 4, cooldown = 6},
    [20903] = {spell_name = 'Aimed Shot', rank = 5, cooldown = 6},
    [20904] = {spell_name = 'Aimed Shot', rank = 6, cooldown = 6}
}


addon_data.hunter.default_settings = {
	enabled = true,
	width = 300,
	height = 12,
    point = "CENTER",
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -200,
	in_combat_alpha = 1.0,
	ooc_alpha = 0.25,
	backplane_alpha = 0.5,
	is_locked = false,
    show_text = true,
    show_aimedshot_cast_bar = true,
    show_multishot_cast_bar = true,
    show_latency_bars = true,
    show_multishot_clip_bar = true,
    show_border = false,
    classic_bars = false
}

addon_data.hunter.shooting = false
addon_data.hunter.range_speed = 3.0
addon_data.hunter.auto_cast_time = 0.65
addon_data.hunter.shot_timer = 0.65
addon_data.hunter.last_shot_time = 0
addon_data.hunter.auto_shot_ready = true

addon_data.hunter.casting = false
addon_data.hunter.casting_shot = false
addon_data.hunter.cast_timer = 0.1
addon_data.hunter.cast_time = 0.1

addon_data.hunter.range_weapon_id = 0
addon_data.hunter.has_moved = false
addon_data.hunter.berserk_haste = 0
addon_data.hunter.class = 0
addon_data.hunter.guid = 0

addon_data.hunter.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_hunter_settings then
        character_hunter_settings = {}
        _, class, _ = UnitClass("player")
        character_hunter_settings.enabled = (class == "HUNTER")
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
    _, class, _ = UnitClass("player")
    character_hunter_settings.enabled = (class == "HUNTER")
    addon_data.hunter.UpdateVisualsOnSettingsChange()
    addon_data.hunter.UpdateConfigPanelValues()
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
    if addon_data.hunter.has_moved or addon_data.hunter.casting then
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

addon_data.hunter.UpdateCastTimer = function(elapsed)
    addon_data.hunter.cast_timer = addon_data.hunter.cast_timer + elapsed
end

addon_data.hunter.OnUpdate = function(elapsed)
    -- Update the ranged attack speed
    new_range_speed, _, _, _, _, _ = UnitRangedDamage("player")
    -- FIXME: Temp fix until I can nail down the divide by zero error
    if addon_data.hunter.range_speed == 0 then
        addon_data.hunter.range_speed = 3
    end
    -- Handling for getting haste buffs in combat
    if new_range_speed ~= addon_data.hunter.range_speed then
        if not addon_data.hunter.auto_shot_ready then
            addon_data.hunter.shot_timer = addon_data.hunter.shot_timer * 
                                           (new_range_speed / addon_data.hunter.range_speed)
        end
        addon_data.hunter.range_speed = new_range_speed
    end
    addon_data.hunter.UpdateRangeCastSpeedModifier()
    -- Check to see if we have moved
    addon_data.hunter.has_moved = (GetUnitSpeed("player") > 0)
    -- Update the Auto Shot timer based on the updated settings
    addon_data.hunter.UpdateAutoShotTimer(elapsed)
    -- Update the cast bar timers
    if addon_data.hunter.casting_shot then
        addon_data.hunter.UpdateCastTimer(elapsed)
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

addon_data.hunter.OnUnitSpellCastStart = function(unit, spell_id)
    if unit == 'player' then
        addon_data.hunter.casting = true
        local spell_name
        local settings = character_hunter_settings
        for id, spell_table in pairs(addon_data.hunter.shot_spell_ids) do
            if spell_id == id then
                spell_name = addon_data.hunter.shot_spell_ids[spell_id].spell_name
                if ((spell_name == 'Aimed Shot') and settings.show_aimedshot_cast_bar) or
                   ((spell_name == 'Multi-Shot') and settings.show_multishot_cast_bar) then
                        addon_data.hunter.casting_shot = true
                        addon_data.hunter.cast_timer = 0
                        addon_data.hunter.frame.spell_bar:SetVertexColor(0.7, 0.4, 0, 1)
                        local name, text, _, start_time, end_time, _, _, _ = UnitCastingInfo("player")
                        addon_data.hunter.cast_time = (end_time - start_time) / 1000
                        if character_hunter_settings.show_text then
                            addon_data.hunter.frame.spell_text_center:SetText(text)
                        end
                end
                break
            end
        end
    end
end

addon_data.hunter.OnUnitSpellCastSucceeded = function(unit, spell_id)
    if addon_data.hunter.shot_spell_ids[spell_id] then
        if addon_data.hunter.shot_spell_ids[spell_id].spell_name == 'Auto Shot' then
            addon_data.hunter.shot_timer = UnitRangedDamage("player")
        end
    end
    if unit == 'player' then
        addon_data.hunter.casting = false
        if addon_data.hunter.shot_spell_ids[spell_id] then
            if addon_data.hunter.shot_spell_ids[spell_id].spell_name ~= 'Auto Shot' then
                addon_data.hunter.casting_shot = false
                addon_data.hunter.frame.spell_bar:SetVertexColor(0, 0.5, 0, 1)
                addon_data.hunter.frame.spell_bar:SetWidth(character_hunter_settings.width)
            end
        end
    end
end

addon_data.hunter.OnUnitSpellCastDelayed = function(unit, spell_id)
    if unit == 'player' then
        for id, spell_table in pairs(addon_data.hunter.shot_spell_ids) do
            if spell_id == id then
                local name, text, _, start_time, end_time, _, _, _ = UnitCastingInfo("player")
                local current_timer = (GetTime() - (start_time / 1000))
                if current_timer < 0 then
                    current_timer = 0
                end
                addon_data.hunter.cast_timer = current_timer
            end
        end
    end
end

addon_data.hunter.OnUnitSpellCastInterrupted = function(unit, spell_id)
    if unit == 'player' then
        if addon_data.hunter.shot_spell_ids[spell_id] then
            if addon_data.hunter.shot_spell_ids[spell_id].spell_name ~= 'Auto Shot' then
                addon_data.hunter.casting = false
            end
        end
        for id, spell_table in pairs(addon_data.hunter.shot_spell_ids) do
            if spell_id == id then
                addon_data.hunter.casting_shot = false
                addon_data.hunter.frame.spell_bar:SetVertexColor(0.7, 0, 0, 1)
                if character_hunter_settings.show_text then
                    addon_data.hunter.frame.spell_text_center:SetText("Interrupted")
                end
                addon_data.hunter.frame.spell_bar:SetWidth(character_hunter_settings.width)
            end
        end
    end
end

addon_data.hunter.UpdateVisualsOnUpdate = function()
    local settings = character_hunter_settings
    local frame = addon_data.hunter.frame
    local range_speed = addon_data.hunter.range_speed
    local shot_timer = addon_data.hunter.shot_timer
    local auto_cast_time = addon_data.hunter.auto_cast_time
	if settings.enabled then
        if addon_data.core.in_combat or addon_data.hunter.shooting or addon_data.hunter.casting_shot then
            frame:SetAlpha(settings.in_combat_alpha)
        else
            frame:SetAlpha(settings.ooc_alpha)
        end
        if addon_data.hunter.auto_shot_ready then
            frame.shot_bar:SetVertexColor(1, 0, 0, 1)
            new_width = settings.width * (auto_cast_time - shot_timer) / auto_cast_time
            frame.multishot_clip_bar:Hide()
        else
            frame.shot_bar:SetVertexColor(1, 1, 1, 1)
            new_width = settings.width * ((shot_timer - auto_cast_time) / (range_speed - auto_cast_time))
            if settings.show_multishot_clip_bar then
                frame.multishot_clip_bar:Show()
                multishot_clip_width = math.min((settings.width * 2) * (0.5 / (addon_data.hunter.range_speed - 0.5)), settings.width)
                frame.multishot_clip_bar:SetWidth(multishot_clip_width)
            end
        end
        if new_width < 2 then
            new_width = 2
        end
        frame.shot_bar:SetWidth(new_width)
        if addon_data.hunter.casting_shot then
            frame:SetSize(settings.width, (settings.height * 2) + 2)
            frame.spell_bar:SetAlpha(1)
            new_width = settings.width * (addon_data.hunter.cast_timer / addon_data.hunter.cast_time)
            new_width = math.min(new_width, settings.width)
            frame.spell_bar:SetWidth(new_width)
            frame.spell_spark:SetPoint('BOTTOMLEFT', new_width - 8, 0)
            if new_width == settings.width or not settings.classic_bars then
                frame.spell_spark:Hide()
            else
                frame.spell_spark:Show()
            end
        else
            new_alpha = frame.spell_bar:GetAlpha() - 0.005
            if new_alpha <= 0 then
                new_alpha = 0
                frame:SetSize(settings.width, settings.height)
                frame.spell_text_center:SetText("")
            end
            frame.spell_bar:SetAlpha(new_alpha)
            frame.spell_spark:Hide()
        end
        if settings.show_latency_bars then
            if addon_data.hunter.casting_shot then
                frame.cast_latency:Show()
                _, _, _, latency = GetNetStats()
                lag_width = settings.width * ((latency / 1000) / addon_data.hunter.cast_time)
                frame.cast_latency:SetWidth(lag_width)
            else
                frame.cast_latency:Hide()
            end
        end
    end
end

addon_data.hunter.UpdateVisualsOnSettingsChange = function()
    local settings = character_hunter_settings
    local frame = addon_data.hunter.frame
	if settings.enabled then
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
        if settings.show_border then
            frame.backplane:SetBackdrop({
                bgFile = "Interface/AddOns/WeaponSwingTimer/Images/Background", 
                edgeFile = "Interface/AddOns/WeaponSwingTimer/Images/Border", 
                tile = true, tileSize = 16, edgeSize = 16, 
                insets = { left = 8, right = 8, top = 8, bottom = 8}})
        else
            frame.backplane:SetBackdrop({
                bgFile = "Interface/AddOns/WeaponSwingTimer/Images/Background", 
                edgeFile = nil, 
                tile = true, tileSize = 16, edgeSize = 16, 
                insets = { left = 11, right = 11, top = 11, bottom = 11}})
        end
        frame.backplane:SetBackdropColor(0,0,0,settings.backplane_alpha)
        frame.shot_bar:SetPoint("TOP", 0, 0)
        frame.shot_bar:SetHeight(settings.height)
        if settings.classic_bars then
            frame.shot_bar:SetTexture('Interface/AddOns/WeaponSwingTimer/Images/Bar')
        else
            frame.shot_bar:SetTexture('Interface/AddOns/WeaponSwingTimer/Images/Background')
        end
        frame.multishot_clip_bar:SetPoint("TOP", 0, 0)
        frame.multishot_clip_bar:SetHeight(settings.height)
        frame.multishot_clip_bar:SetColorTexture(1, 0, 0, 0.7)
        frame.spell_bar:SetPoint("BOTTOMLEFT", 0, 0)
        frame.spell_bar:SetHeight(settings.height)
        if settings.classic_bars then
            frame.spell_bar:SetTexture('Interface/AddOns/WeaponSwingTimer/Images/Bar')
        else
            frame.spell_bar:SetTexture('Interface/AddOns/WeaponSwingTimer/Images/Background')
        end
        frame.spell_spark:SetSize(16, settings.height)
        frame.spell_text_center:SetPoint("CENTER", 2, -(settings.height / 2))
        frame.cast_latency:SetHeight(settings.height)
        frame.cast_latency:SetPoint("BOTTOMRIGHT", 0, 0)
        frame.cast_latency:SetColorTexture(1, 0, 0, 0.75)
        if settings.show_latency_bars then
            frame.cast_latency:Show()
        else
            frame.cast_latency:Hide()
        end
        if settings.show_multishot_clip_bar then
            frame.multishot_clip_bar:Show()
        else
            frame.multishot_clip_bar:Hide()
        end
        if not settings.show_text then
            frame.spell_text_center:SetText("")
        end
    else
        frame:Hide()
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
    addon_data.hunter.UpdateVisualsOnSettingsChange()
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
    frame.backplane = CreateFrame("Frame", addon_name .. "HunterBackdropFrame", frame)
    frame.backplane:SetPoint('TOPLEFT', -12, 12)
    frame.backplane:SetPoint('BOTTOMRIGHT', 12, -12)
    frame.backplane:SetFrameStrata('BACKGROUND')
    -- Create the shot bar
    frame.shot_bar = frame:CreateTexture(nil, "ARTWORK")
    -- Create the multishot clip bar
    frame.multishot_clip_bar = frame:CreateTexture(nil, "OVERLAY")
    -- Create the range spell shot bar
    frame.spell_bar = frame:CreateTexture(nil, "ARTWORK")
    -- Create the spell spark
    frame.spell_spark = frame:CreateTexture(nil,"OVERLAY")
    frame.spell_spark:SetTexture('Interface/AddOns/WeaponSwingTimer/Images/Spark')
    -- Create the range spell shot bar center text
    frame.spell_text_center = frame:CreateFontString(nil, "OVERLAY")
    frame.spell_text_center:SetFont("Fonts/FRIZQT__.ttf", 11)
    frame.spell_text_center:SetTextColor(1, 1, 1, 1)
    frame.spell_text_center:SetJustifyV("CENTER")
    frame.spell_text_center:SetJustifyH("LEFT")
    -- Create the latency bar
    frame.cast_latency = frame:CreateTexture(nil,"OVERLAY")
    -- Show it off
    addon_data.hunter.UpdateVisualsOnSettingsChange()
    addon_data.hunter.UpdateVisualsOnUpdate()
    frame:Show()
end

addon_data.hunter.UpdateConfigPanelValues = function()
    local panel = addon_data.hunter.config_frame
    local settings = character_hunter_settings
    panel.enabled_checkbox:SetChecked(settings.enabled)
    panel.show_aimedshot_cast_bar_checkbox:SetChecked(settings.show_aimedshot_cast_bar)
    panel.show_multishot_cast_bar_checkbox:SetChecked(settings.show_multishot_cast_bar)
    panel.show_latency_bar_checkbox:SetChecked(settings.show_latency_bars)
    panel.show_multishot_clip_bar_checkbox:SetChecked(settings.show_multishot_clip_bar)
    panel.show_border_checkbox:SetChecked(settings.show_border)
    panel.classic_bars_checkbox:SetChecked(settings.classic_bars)
    panel.width_editbox:SetText(tostring(settings.width))
    panel.width_editbox:SetCursorPosition(0)
    panel.height_editbox:SetText(tostring(settings.height))
    panel.height_editbox:SetCursorPosition(0)
    panel.x_offset_editbox:SetText(tostring(settings.x_offset))
    panel.x_offset_editbox:SetCursorPosition(0)
    panel.y_offset_editbox:SetText(tostring(settings.y_offset))
    panel.y_offset_editbox:SetCursorPosition(0)
end

addon_data.hunter.EnabledCheckBoxOnClick = function(self)
    character_hunter_settings.enabled = self:GetChecked()
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.ShowAimedShotCastBarCheckBoxOnClick = function(self)
    character_hunter_settings.show_aimedshot_cast_bar = self:GetChecked()
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.ShowMultiShotCastBarCheckBoxOnClick = function(self)
    character_hunter_settings.show_multishot_cast_bar = self:GetChecked()
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.ShowLatencyBarsCheckBoxOnClick = function(self)
    character_hunter_settings.show_latency_bars = self:GetChecked()
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.ShowMultiShotClipBarCheckBoxOnClick = function(self)
   character_hunter_settings.show_multishot_clip_bar = self:GetChecked()
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.ShowBorderCheckBoxOnClick = function(self)
    character_hunter_settings.show_border = self:GetChecked()
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.ClassicBarsCheckBoxOnClick = function(self)
    character_hunter_settings.classic_bars = self:GetChecked()
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.WidthEditBoxOnEnter = function(self)
    character_hunter_settings.width = tonumber(self:GetText())
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.HeightEditBoxOnEnter = function(self)
    character_hunter_settings.height = tonumber(self:GetText())
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.XOffsetEditBoxOnEnter = function(self)
    character_hunter_settings.x_offset = tonumber(self:GetText())
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end

addon_data.hunter.YOffsetEditBoxOnEnter = function(self)
    character_hunter_settings.y_offset = tonumber(self:GetText())
    addon_data.hunter.UpdateVisualsOnSettingsChange()
end



addon_data.hunter.CreateConfigPanel = function(parent_panel)
    addon_data.hunter.config_frame = CreateFrame("Frame", addon_name .. "HunterConfigPanel", parent_panel)
    local panel = addon_data.hunter.config_frame
    local settings = character_hunter_settings
    -- Title Text
    panel.title_text = addon_data.config.TextFactory(panel, "Hunter Shot Bar Settings", 20)
    panel.title_text:SetPoint("TOPLEFT", 15 , -15)
    panel.title_text:SetTextColor(1, 0.9, 0, 1)
    -- Enabled Checkbox
    panel.enabled_checkbox = addon_data.config.CheckBoxFactory(
        "HunterEnabledCheckBox",
        panel,
        " Enable",
        "Enables the hunter's Auto Shot and casting bars.",
        addon_data.hunter.EnabledCheckBoxOnClick)
    panel.enabled_checkbox:SetPoint("TOPLEFT", 10, -45)
    -- Show Aimed Shot Cast Bar Checkbox
    panel.show_aimedshot_cast_bar_checkbox = addon_data.config.CheckBoxFactory(
        "HunterShowAimedShotCastBarCheckBox",
        panel,
        " Show Aimed Shot cast bar",
        "Allows the cast bar to show Aimed Shot casts.",
        addon_data.hunter.ShowAimedShotCastBarCheckBoxOnClick)
    panel.show_aimedshot_cast_bar_checkbox:SetPoint("TOPLEFT", 10, -65)
    -- Show Multi Shot Cast Bar Checkbox
    panel.show_multishot_cast_bar_checkbox = addon_data.config.CheckBoxFactory(
        "HunterShowMultiShotCastBarCheckBox",
        panel,
        " Show Multi-Shot cast bar",
        "Allows the cast bar to show Multi-Shot casts.",
        addon_data.hunter.ShowMultiShotCastBarCheckBoxOnClick)
    panel.show_multishot_cast_bar_checkbox:SetPoint("TOPLEFT", 10, -85)
    -- Show Latency Bar Checkbox
    panel.show_latency_bar_checkbox = addon_data.config.CheckBoxFactory(
        "HunterShowLatencyBarCheckBox",
        panel,
        " Show latency bar",
        "Shows a bar that represents latency on cast bar.",
        addon_data.hunter.ShowLatencyBarsCheckBoxOnClick)
    panel.show_latency_bar_checkbox:SetPoint("TOPLEFT", 10, -105)
    -- Show Multi-Shot Clip Bar Checkbox
    panel.show_multishot_clip_bar_checkbox = addon_data.config.CheckBoxFactory(
        "HunterShowMultiShotClipBarCheckBox",
        panel,
        " Show Multi-Shot clip bar",
        "Shows a bar that represents when a Multi-Shot would clip an Auto Shot.",
        addon_data.hunter.ShowMultiShotClipBarCheckBoxOnClick)
    panel.show_multishot_clip_bar_checkbox:SetPoint("TOPLEFT", 10, -125)
    -- Show Border Checkbox
    panel.show_border_checkbox = addon_data.config.CheckBoxFactory(
        "HunterShowBorderCheckBox",
        panel,
        " Show border",
        "Enables the hunter bar's border.",
        addon_data.hunter.ShowBorderCheckBoxOnClick)
    panel.show_border_checkbox:SetPoint("TOPLEFT", 10, -145)
    -- Show Classic Bars Checkbox
    panel.classic_bars_checkbox = addon_data.config.CheckBoxFactory(
        "HunterClassicBarsCheckBox",
        panel,
        " Classic bars",
        "Enables the classic texture for the hunter bars.",
        addon_data.hunter.ClassicBarsCheckBoxOnClick)
    panel.classic_bars_checkbox:SetPoint("TOPLEFT", 10, -165)
    -- Width EditBox
    panel.width_editbox = addon_data.config.EditBoxFactory(
        "HunterWidthEditBox",
        panel,
        "Bar Width",
        100,
        25,
        addon_data.hunter.WidthEditBoxOnEnter)
    panel.width_editbox:SetPoint("TOPLEFT", 15, -220, "BOTTOMRIGHT", 115, -245)
    -- Height EditBox
    panel.height_editbox = addon_data.config.EditBoxFactory(
        "HunterHeightEditBox",
        panel,
        "Bar Height",
        100,
        25,
        addon_data.hunter.HeightEditBoxOnEnter)
    panel.height_editbox:SetPoint("TOPLEFT", 125, -220, "BOTTOMRIGHT", 225, -245)
    -- X Offset EditBox
    panel.x_offset_editbox = addon_data.config.EditBoxFactory(
        "HunterXOffsetEditBox",
        panel,
        "X Offset",
        100,
        25,
        addon_data.hunter.XOffsetEditBoxOnEnter)
    panel.x_offset_editbox:SetPoint("TOPLEFT", 15, -270, "BOTTOMRIGHT", 115, -295)
    -- Y Offset EditBox
    panel.y_offset_editbox = addon_data.config.EditBoxFactory(
        "HunterYOffsetEditBox",
        panel,
        "Y Offset",
        100,
        25,
        addon_data.hunter.YOffsetEditBoxOnEnter)
    panel.y_offset_editbox:SetPoint("TOPLEFT", 125, -270, "BOTTOMRIGHT", 225, -295)
    -- Return the final panel
    addon_data.hunter.UpdateConfigPanelValues()
    return panel
end

