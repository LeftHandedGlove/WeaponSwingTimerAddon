local addon_name, addon_data = ...

addon_data.config = {}

addon_data.config.OnDefault = function()
    addon_data.core.RestoreAllDefaults()
    addon_data.config.UpdateConfigValues()
end

addon_data.config.InitializeVisuals = function()

    -- Add the parent panel
    addon_data.config.config_parent_panel = CreateFrame("Frame", "MyFrame", UIParent)
    local panel = addon_data.config.config_parent_panel
    panel:SetSize(1, 1)
    panel.global_panel = addon_data.config.CreateConfigPanel(panel)
    panel.global_panel:SetPoint('TOPLEFT', 10, -10)
    panel.global_panel:SetSize(1, 1)
    
    panel.logo = panel:CreateTexture(nil, 'ARTWORK')
    panel.logo:SetTexture('Interface/AddOns/WeaponSwingTimer/Images/LandingPage')
    panel.logo:SetSize(1024, 1024)
    panel.logo:SetPoint('TOPLEFT', 5, -10)

    panel.name = "WeaponSwingTimer"
    panel.default = addon_data.config.OnDefault
    InterfaceOptions_AddCategory(panel)
    
    -- Add the melee panel
    panel.config_melee_panel = CreateFrame("Frame", nil, panel)
    panel.config_melee_panel:SetSize(1, 1)
    panel.config_melee_panel.player_panel = addon_data.player.CreateConfigPanel(panel.config_melee_panel)
    panel.config_melee_panel.player_panel:SetPoint('TOPLEFT', 0, 0)
    panel.config_melee_panel.player_panel:SetSize(1, 1)
    panel.config_melee_panel.target_panel = addon_data.target.CreateConfigPanel(panel.config_melee_panel)
    panel.config_melee_panel.target_panel:SetPoint('TOPLEFT', 0, -275)
    panel.config_melee_panel.target_panel:SetSize(1, 1)
    panel.config_melee_panel.name = 'Melee Settings'
    panel.config_melee_panel.parent = panel.name
    panel.config_melee_panel.default = addon_data.config.OnDefault
    InterfaceOptions_AddCategory(panel.config_melee_panel)
    
    -- Add the hunter panel
    panel.config_hunter_panel = CreateFrame("Frame", nil, panel)
    panel.config_hunter_panel:SetSize(1, 1)
    panel.config_hunter_panel.hunter_panel = addon_data.hunter.CreateConfigPanel(panel.config_hunter_panel)
    panel.config_hunter_panel.hunter_panel:SetPoint('TOPLEFT', 0, 0)
    panel.config_hunter_panel.hunter_panel:SetSize(1, 1)
    panel.config_hunter_panel.name = 'Hunter & Wand Settings'
    panel.config_hunter_panel.parent = panel.name
    panel.config_hunter_panel.default = addon_data.config.OnDefault
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
    local edit_box_obj = CreateFrame("EditBox", addon_name .. g_name, parent, BackdropTemplateMixin and "BackdropTemplate")
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
    edit_box_obj:SetScript("OnTextChanged", function(self)
        if self:GetText() ~= "" then
            enter_func(self)
        end
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
    color_picker:SetNormalTexture(color_picker.foreground)
    color_picker:SetScript('OnClick', on_click_func)
    color_picker.text = addon_data.config.TextFactory(color_picker, text, 12)
    color_picker.text:SetPoint('LEFT', 25, 0)
    return color_picker
end

addon_data.config.UpdateConfigValues = function()
    local panel = addon_data.config.config_frame
    local settings = character_player_settings
    panel.is_locked_checkbox:SetChecked(settings.is_locked)
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

addon_data.config.CreateConfigPanel = function(parent_panel)
    addon_data.config.config_frame = CreateFrame("Frame", addon_name .. "GlobalConfigPanel", parent_panel)
    local panel = addon_data.config.config_frame
    local settings = character_player_settings
    -- Title Text
    panel.title_text = addon_data.config.TextFactory(panel, "Global Bar Settings", 20)
    panel.title_text:SetPoint("TOPLEFT", 0, 0)
    panel.title_text:SetTextColor(1, 0.9, 0, 1)
    
    -- Is Locked Checkbox
    panel.is_locked_checkbox = addon_data.config.CheckBoxFactory(
        "IsLockedCheckBox",
        panel,
        " Lock All Bars",
        "Locks all of the swing bar frames, preventing them from being dragged.",
        addon_data.config.IsLockedCheckBoxOnClick)
    panel.is_locked_checkbox:SetPoint("TOPLEFT", 0, -30)
    
    -- Guidance Text
    panel.guidance_text = addon_data.config.TextFactory(panel, "<- Click the '+' on the left\nfor more options", 16)
    panel.guidance_text:SetPoint("TOPLEFT", 0, -100)
    panel.guidance_text:SetTextColor(1, 1, 1, 1)
    
    -- Return the final panel
    addon_data.config.UpdateConfigValues()
    return panel
end

