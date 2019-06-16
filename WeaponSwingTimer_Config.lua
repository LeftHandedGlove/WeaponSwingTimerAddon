local addon_name, addon_data = ...

addon_data.config = {}

addon_data.config.OnDefault = function()
    addon_data.core.RestoreAllDefaults()
    addon_data.config.UpdateConfigValues()
end

addon_data.config.InitializeVisuals = function()
    --parent frame, this gets added to the interface options
    addon_data.config.panel = CreateFrame("Frame", "MyFrame", UIParent)
    local panel = addon_data.config.panel
    panel.name = "WeaponSwingTimer"
    panel.default = addon_data.config.OnDefault
    InterfaceOptions_AddCategory(panel)

    --scrollframe, this holds the scroll child, think of it like the window that holds the current content.
    scrollframe = CreateFrame("ScrollFrame", nil, panel) 
    scrollframe:SetPoint('TOPLEFT', 5, -5)
    scrollframe:SetPoint('BOTTOMRIGHT', -5, 5)
    scrollframe:EnableMouseWheel(true)
    scrollframe:SetScript('OnMouseWheel', function(self, direction)
        if direction == 1 then
            scroll_value = math.max(self:GetVerticalScroll() - 50, 1)
            self:SetVerticalScroll(scroll_value)
            self:GetParent().scrollbar:SetValue(scroll_value) 
        elseif direction == -1 then
            scroll_value = math.min(self:GetVerticalScroll() + 50, 250)
            self:SetVerticalScroll(scroll_value)
            self:GetParent().scrollbar:SetValue(scroll_value)
        end
    end)
    panel.scrollframe = scrollframe 

    --scrollbar, the scroll bar on the side
    scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
    scrollbar:SetPoint("TOPLEFT", panel, "TOPRIGHT", -20, -20) 
    scrollbar:SetPoint("BOTTOMLEFT", panel, "BOTTOMRIGHT", -20, 20) 
    scrollbar:SetMinMaxValues(1, 250) 
    scrollbar:SetValueStep(1) 
    scrollbar.scrollStep = 1 
    scrollbar:SetValue(0) 
    scrollbar:SetWidth(16) 
    scrollbar:SetScript("OnValueChanged", 
    function (self, value) 
    self:GetParent():SetVerticalScroll(value) 
    end) 
    local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
    scrollbg:SetAllPoints(scrollbar) 
    scrollbg:SetColorTexture(0, 0, 0, 0.6) 
    panel.scrollbar = scrollbar
    
    --content frame, this holds all of the titles and settings. 
    local content = CreateFrame("Frame", nil, scrollframe) 
    content:SetSize(1, 1) 
    scrollframe.content = content 
    scrollframe:SetScrollChild(content)
    -- Add the global panel
    content.global_panel = addon_data.config.CreateConfigPanel(content)
    content.global_panel:SetPoint('TOPLEFT', 10, -10)
    content.global_panel:SetSize(1, 1)
    -- Add the player panel
    content.player_panel = addon_data.player.CreateConfigPanel(content)
    content.player_panel:SetPoint('TOPLEFT', 10, -220)
    content.player_panel:SetSize(1, 1)
    -- Add the target panel
    content.target_panel = addon_data.target.CreateConfigPanel(content)
    content.target_panel:SetPoint('TOPLEFT', 10, -395)
    content.target_panel:SetSize(1, 1)
    
    -- Add the hunter panel
    panel.config_hunter_panel = CreateFrame("Frame", "MyFrame", panel)
    panel.config_hunter_panel:SetSize(1, 1)
    panel.config_hunter_panel.hunter_panel = addon_data.hunter.CreateConfigPanel(panel.config_hunter_panel)
    panel.config_hunter_panel.hunter_panel:SetPoint('TOPLEFT', 10, -10)
    panel.config_hunter_panel.hunter_panel:SetSize(1, 1)
    panel.config_hunter_panel.name = 'Hunter'
    panel.config_hunter_panel.parent = panel.name
    InterfaceOptions_AddCategory(panel.config_hunter_panel)
    

end

addon_data.config.TextFactory = function(parent, text, size)
    local text_obj = parent:CreateFontString(nil, "ARTWORK")
    text_obj:SetFont("Fonts/FRIZQT__.ttf", size)
    text_obj:SetJustifyV("CENTER")
    text_obj:SetJustifyH("CENTER")
    text_obj:SetText(text)
    return text_obj
end

addon_data.config.CheckBoxFactory = function(g_name, parent, checkbtn_text, tooltip_text, on_click_func)
    local checkbox = CreateFrame("CheckButton", addon_name .. g_name, parent, "ChatConfigCheckButtonTemplate")
    getglobal(checkbox:GetName() .. 'Text'):SetText(checkbtn_text)
    checkbox.tooltip = tooltip_text
    checkbox:SetScript("OnClick", function(self)
        on_click_func(self)
    end)
    checkbox:SetScale(1.1)
    return checkbox
end

addon_data.config.EditBoxFactory = function(g_name, parent, title, w, h, enter_func)
    local edit_box_obj = CreateFrame("EditBox", addon_name .. g_name, parent)
    edit_box_obj.title_text = addon_data.config.TextFactory(edit_box_obj, title, 12)
    edit_box_obj.title_text:SetPoint("TOP", 0, 12)
    edit_box_obj:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 26,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    edit_box_obj:SetBackdropColor(0,0,0,1)
    edit_box_obj:SetSize(w, h)
    edit_box_obj:SetMultiLine(false)
    edit_box_obj:SetAutoFocus(false)
    edit_box_obj:SetMaxLetters(4)
    edit_box_obj:SetJustifyH("CENTER")
	edit_box_obj:SetJustifyV("CENTER")
    edit_box_obj:SetFontObject(GameFontNormal)
    edit_box_obj:SetScript("OnEnterPressed", function(self)
        enter_func(self)
        self:ClearFocus()
    end)
    edit_box_obj:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    return edit_box_obj
end

addon_data.config.SliderFactory = function(g_name, parent, title, min_val, max_val, val_step, func)
    local slider = CreateFrame("Slider", addon_name .. g_name, parent, "OptionsSliderTemplate")
    local editbox = CreateFrame("EditBox", "$parentEditBox", slider, "InputBoxTemplate")
    slider:SetMinMaxValues(min_val, max_val)
    slider:SetValueStep(val_step)
    slider.text = _G[addon_name .. g_name .. "Text"]
    slider.text:SetText(title)
    slider.textLow = _G[addon_name .. g_name .. "Low"]
    slider.textHigh = _G[addon_name .. g_name .. "High"]
    slider.textLow:SetText(floor(min_val))
    slider.textHigh:SetText(floor(max_val))
    slider.textLow:SetTextColor(0.8,0.8,0.8)
    slider.textHigh:SetTextColor(0.8,0.8,0.8)
    slider:SetObeyStepOnDrag(true)
    editbox:SetSize(45,30)
    editbox:ClearAllPoints()
    editbox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    editbox:SetText(slider:GetValue())
    editbox:SetAutoFocus(false)
    slider:SetScript("OnValueChanged", function(self)
        editbox:SetText(tostring(addon_data.utils.SimpleRound(self:GetValue(), val_step)))
        func(self)
    end)
    editbox:SetScript("OnTextChanged", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
        end
    end)
    editbox:SetScript("OnEnterPressed", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
            self:ClearFocus()
        end
    end)
    slider.editbox = editbox
    return slider
end

addon_data.config.color_picker_factory = function(g_name, parent, r, g, b, a, text, on_click_func)
    local color_picker = CreateFrame('Button', addon_name .. g_name, parent)
    color_picker:SetSize(15, 15)
    color_picker.normal = color_picker:CreateTexture(nil, 'BACKGROUND')
    color_picker.normal:SetColorTexture(1, 1, 1, 1)
    color_picker.normal:SetPoint('TOPLEFT', -1, 1)
    color_picker.normal:SetPoint('BOTTOMRIGHT', 1, -1)
    color_picker.foreground = color_picker:CreateTexture(nil, 'ARTWORK')
    color_picker.foreground:SetColorTexture(r, g, b, a)
    color_picker.foreground:SetAllPoints()
    color_picker:SetNormalTexture(color_picker.normal)
    color_picker:SetScript('OnClick', on_click_func)
    color_picker.text = addon_data.config.TextFactory(color_picker, text, 12)
    color_picker.text:SetPoint('LEFT', 25, 0)
    return color_picker
end

addon_data.config.UpdateConfigValues = function()
    local panel = addon_data.config.config_frame
    local settings = character_player_settings
    panel.show_text_checkbox:SetChecked(settings.show_text)
    panel.is_locked_checkbox:SetChecked(settings.is_locked)
    panel.in_combat_alpha_slider:SetValue(settings.in_combat_alpha)
    panel.in_combat_alpha_slider.editbox:SetCursorPosition(0)
    panel.ooc_alpha_slider:SetValue(settings.ooc_alpha)
    panel.ooc_alpha_slider.editbox:SetCursorPosition(0)
    panel.backplane_alpha_slider:SetValue(settings.backplane_alpha)
    panel.backplane_alpha_slider.editbox:SetCursorPosition(0)
end

addon_data.config.ShowTextCheckBoxOnClick = function(self)
    character_player_settings.show_text = self:GetChecked()
    character_target_settings.show_text = self:GetChecked()
    character_hunter_settings.show_text = self:GetChecked()
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

addon_data.config.IsLockedCheckBoxOnClick = function(self)
    character_player_settings.is_locked = self:GetChecked()
    character_target_settings.is_locked = self:GetChecked()
    character_hunter_settings.is_locked = self:GetChecked()
    addon_data.player.frame:EnableMouse(not character_target_settings.is_locked)
    addon_data.target.frame:EnableMouse(not character_target_settings.is_locked)
    addon_data.hunter.frame:EnableMouse(not character_target_settings.is_locked)
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

addon_data.config.CombatAlphaOnValChange = function(self)
    character_player_settings.in_combat_alpha = tonumber(self:GetValue())
    character_target_settings.in_combat_alpha = tonumber(self:GetValue())
    character_hunter_settings.in_combat_alpha = tonumber(self:GetValue())
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

addon_data.config.OOCAlphaOnValChange = function(self)
    character_player_settings.ooc_alpha = tonumber(self:GetValue())
    character_target_settings.ooc_alpha = tonumber(self:GetValue())
    character_hunter_settings.ooc_alpha = tonumber(self:GetValue())
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

addon_data.config.BackplaneAlphaOnValChange = function(self)
    character_player_settings.backplane_alpha = tonumber(self:GetValue())
    character_target_settings.backplane_alpha = tonumber(self:GetValue())
    character_hunter_settings.backplane_alpha = tonumber(self:GetValue())
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

addon_data.config.CreateConfigPanel = function(parent_panel)
    addon_data.config.config_frame = CreateFrame("Frame", addon_name .. "GlobalConfigPanel", parent_panel)
    local panel = addon_data.config.config_frame
    local settings = character_player_settings
    -- Title Text
    panel.title_text = addon_data.config.TextFactory(panel, "Global Bar Settings", 20)
    panel.title_text:SetPoint("TOPLEFT", 0, 0)
    panel.title_text:SetTextColor(1, 0.9, 0, 1)
    -- Show Text Checkbox
    panel.show_text_checkbox = addon_data.config.CheckBoxFactory(
        "ShowTextCheckBox",
        panel,
        " Show Text",
        "Enables the text on the swing bars.",
        addon_data.config.ShowTextCheckBoxOnClick)
    panel.show_text_checkbox:SetPoint("TOPLEFT", 10, -55)
    -- Is Locked Checkbox
    panel.is_locked_checkbox = addon_data.config.CheckBoxFactory(
        "IsLockedCheckBox",
        panel,
        " Lock All Bars",
        "Locks all of the swing bar frames, preventing them from being dragged.",
        addon_data.config.IsLockedCheckBoxOnClick)
    panel.is_locked_checkbox:SetPoint("TOPLEFT", 10, -35)
    -- In Combat Alpha Slider
    panel.in_combat_alpha_slider = addon_data.config.SliderFactory(
        "InCombatAlphaSlider",
        panel,
        "In Combat Alpha",
        0,
        1,
        0.05,
        addon_data.config.CombatAlphaOnValChange)
    panel.in_combat_alpha_slider:SetPoint("TOPLEFT", 200, -55)
    -- Out Of Combat Alpha Slider
    panel.ooc_alpha_slider = addon_data.config.SliderFactory(
        "OOCAlphaSlider",
        panel,
        "Out of Combat Alpha",
        0,
        1,
        0.05,
        addon_data.config.OOCAlphaOnValChange)
    panel.ooc_alpha_slider:SetPoint("TOPLEFT", 200, -105)
    -- Backplane Alpha Slider
    panel.backplane_alpha_slider = addon_data.config.SliderFactory(
        "BackplaneAlphaSlider",
        panel,
        "Backplane Alpha",
        0,
        1,
        0.05,
        addon_data.config.BackplaneAlphaOnValChange)
    panel.backplane_alpha_slider:SetPoint("TOPLEFT", 200, -155)
    
    -- Extra Classic Button
    panel.extra_classic_button = CreateFrame("Button", nil, panel)
    panel.extra_classic_button:SetPoint('TOPLEFT', 475, 0)
    panel.extra_classic_button:SetSize(150, 35)
    panel.extra_classic_button:SetNormalTexture('Interface/Buttons/UI-Panel-Button-Up')
    panel.extra_classic_button:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
    panel.extra_classic_button:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
    local fo = panel.extra_classic_button:CreateFontString()
	fo:SetFont("Fonts/FRIZQT__.TTF",12)
	fo:SetPoint("TOPLEFT", panel.extra_classic_button, "TOPLEFT", 10, -6)
	fo:SetText("True Classic")
	panel.extra_classic_button:SetFontString(fo)
    panel.extra_classic_button:SetScript("OnClick", function(self)
        if panel.extra_classic_frame:IsVisible() then
            panel.extra_classic_frame:EnableKeyboard(false)
            panel.extra_classic_frame:Hide()
        else
            panel.extra_classic_frame:EnableKeyboard(true)
            panel.extra_classic_frame:Show()
        end
        
    end)
    -- Extra Classic Frame
    panel.extra_classic_frame = CreateFrame("Frame", addon_name .. "ExtraClassicPanel", UIParent)
    panel.extra_classic_frame:SetPoint('CENTER', 0, 10)
    panel.extra_classic_frame:SetSize(GetScreenWidth(), GetScreenWidth() * 0.75)
    panel.extra_classic_frame.texture = panel.extra_classic_frame:CreateTexture(nil, "ARTWORK")
    panel.extra_classic_frame.texture:SetTexture('Interface/AddOns/WeaponSwingTimer/Images/crazyui')
    panel.extra_classic_frame.texture:SetAllPoints(panel.extra_classic_frame)
    panel.extra_classic_frame:SetScript('OnKeyDown', function()
        panel.extra_classic_frame:EnableKeyboard(false)
        panel.extra_classic_frame:Hide()
    end)
    panel.extra_classic_frame:Hide()
    -- Return the final panel
    addon_data.config.UpdateConfigValues()
    return panel
end

addon_data.config.CreateMeleeConfigPanel = function(parent_panel)
    
end

addon_data.config.CreateHunterConfigPanel = function(parent_panel)
    parent_panel.hunter_panel = addon_data.hunter.CreateConfigPanel(parent_panel)
    parent_panel.hunter_panel.name = 'Hunter Shot Bars'
    parent_panel.hunter_panel.parent = parent_panel.name
    InterfaceOptions_AddCategory(parent_panel.hunter_panel)
    
    
    
    --parent frame 
    local frame = CreateFrame("Frame", "MyFrame", UIParent) 
    frame:SetSize(150, 200) 
    frame:SetPoint("CENTER") 
    local texture = frame:CreateTexture() 
    texture:SetAllPoints() 
    texture:SetColorTexture(1,1,1,1) 
    frame.background = texture 

    --scrollframe 
    scrollframe = CreateFrame("ScrollFrame", nil, frame) 
    scrollframe:SetPoint("TOPLEFT", 10, -10) 
    scrollframe:SetPoint("BOTTOMRIGHT", -10, 10) 
    local texture = scrollframe:CreateTexture() 
    texture:SetAllPoints() 
    texture:SetColorTexture(.5,.5,.5,1) 
    frame.scrollframe = scrollframe 

    --scrollbar 
    scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
    scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -16) 
    scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 16) 
    scrollbar:SetMinMaxValues(1, 200) 
    scrollbar:SetValueStep(1) 
    scrollbar.scrollStep = 1 
    scrollbar:SetValue(0) 
    scrollbar:SetWidth(16) 
    scrollbar:SetScript("OnValueChanged", 
    function (self, value) 
    self:GetParent():SetVerticalScroll(value) 
    end) 
    local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
    scrollbg:SetAllPoints(scrollbar) 
    scrollbg:SetColorTexture(0, 0, 0, 0.4) 
    frame.scrollbar = scrollbar 

    --content frame 
    local content = CreateFrame("Frame", nil, scrollframe) 
    content:SetSize(128, 128) 
    local texture = content:CreateTexture() 
    texture:SetAllPoints() 
    texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo") 
    content.texture = texture 
    scrollframe.content = content 

    scrollframe:SetScrollChild(content)
    
    
    
    
    
end





