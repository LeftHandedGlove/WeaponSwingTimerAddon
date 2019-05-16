LHGWSTConfig = {}
local config_frame

local function HideConfigFrame()
    LHGWSTConfig.config_frame:Hide()
end

local function ConfigFrame_OnDragStart()
    LHGWSTConfig.config_frame:StartMoving()
end

local function ConfigFrame_OnDragStop()
    LHGWSTConfig.config_frame:StopMovingOrSizing()
end

LHGWSTConfig.CreateLHGWSTConfigFrame = function()
    -- Setup the config frame
    LHGWSTConfig.config_frame = CreateFrame("Frame", "WSTConfigFrame", UIParent)
    local config_frame = LHGWSTConfig.config_frame
    config_frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 100,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    config_frame:SetBackdropColor(0,0,0,1)
    config_frame:SetWidth(350)
    config_frame:SetHeight(100)
    config_frame:SetPoint("CENTER", 0, 0)
    config_frame:Hide()
    -- Setup the config frame's title
    config_frame.title_frame = CreateFrame("Frame", "WSTConfigFrameTitle", config_frame)
    config_frame.title_frame:SetBackdrop({
        bgFile = "Interface/FrameGeneral/UI-Background-Rock",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 100,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    config_frame.title_frame:SetBackdropColor(1,1,1,1)
    config_frame.title_frame:SetWidth(config_frame:GetWidth())
    config_frame.title_frame:SetHeight(30)
    config_frame.title_frame:SetPoint("TOP", 0, 0)
    -- Add the title's name
    config_frame.title_frame.text = config_frame.title_frame:CreateFontString(nil, "ARTWORK")
    config_frame.title_frame.text:SetFont("Fonts/FRIZQT__.ttf", 16)
    config_frame.title_frame.text:SetJustifyH("LEFT")
	config_frame.title_frame.text:SetJustifyV("CENTER")
    config_frame.title_frame.text:SetText("WeaponSwingTimer Configuration")
    config_frame.title_frame.text:SetPoint("LEFT",10, 0)
    -- Add the close button
    config_frame.title_frame.close_btn = CreateFrame("Button", "WSTCloseButton", config_frame.title_frame)
    config_frame.title_frame.close_btn:SetWidth(20)
    config_frame.title_frame.close_btn:SetHeight(20)
    config_frame.title_frame.close_btn:SetNormalTexture("Interface/Addons/WeaponSwingTimer/Images/CloseUp")
    config_frame.title_frame.close_btn:SetPushedTexture("Interface/Addons/WeaponSwingTimer/Images/CloseDown")
    config_frame.title_frame.close_btn:SetPoint("RIGHT", -5, 0)
    config_frame.title_frame.close_btn:SetScript("OnClick", HideConfigFrame)
    -- Add the lock checkbox
    config_frame.lock_checkbtn = CreateFrame("CheckButton", "WSTLockCheckbtn", config_frame, "ChatConfigCheckButtonTemplate")
    config_frame.lock_checkbtn:SetPoint("TOPLEFT", 10, -35)
    getglobal(config_frame.lock_checkbtn:GetName() .. 'Text'):SetText("Lock")
    config_frame.lock_checkbtn.tooltip = "Locks the swing timer bars."
    config_frame.lock_checkbtn:SetScript("OnClick", function(self)
        LHG_WeapSwingTimer_Settings.is_locked = self:GetChecked()
    end)
    -- Add the width control
    config_frame.width_editbox = CreateFrame("EditBox", nil, config_frame)
    config_frame.width_editbox:SetWidth(60)
    config_frame.width_editbox:SetHeight(25)
    config_frame.width_editbox:SetPoint("TOPLEFT", 10, -60)
    config_frame.width_editbox:SetMultiLine(false)
    config_frame.width_editbox:SetAutoFocus(false)
    config_frame.width_editbox:SetMaxLetters(4)
    config_frame.width_editbox:SetNumeric(true)
    config_frame.width_editbox:SetJustifyH("CENTER")
	config_frame.width_editbox:SetJustifyV("CENTER")
    config_frame.width_editbox:SetFontObject(GameFontNormal)
    config_frame.width_editbox:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    config_frame.width_editbox:SetTextInsets(8, 4, 4, 4)
    config_frame.width_editbox:SetScript("OnEnterPressed", function(self)
        LHG_WeapSwingTimer_Settings.width = self:GetNumber()
        self:ClearFocus()
        print("Howdy!")
    end)
    -- Add the height control
    -- Add the x offset control
    -- Add the y offset control
    -- Set the scripts that control the config_frame
    config_frame:SetMovable(true)
    config_frame.title_frame:EnableMouse(true)
    config_frame.title_frame:RegisterForDrag("LeftButton")
    config_frame.title_frame:SetScript("OnDragStart", ConfigFrame_OnDragStart)
    config_frame.title_frame:SetScript("OnDragStop", ConfigFrame_OnDragStop)
    -- return the config frame
    return config_frame
end

