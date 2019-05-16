LHGWSTConfig = {}
local config_frame

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
    --[[
    main_frame.title_frame.reset_btn = CreateFrame("Button", "ResetButton", main_frame)
    main_frame.title_frame.reset_btn:SetWidth(20)
    main_frame.title_frame.reset_btn:SetHeight(20)
    main_frame.title_frame.reset_btn:SetNormalTexture("Interface/Addons/QualityTime/Images/ResetTimerUp")
    main_frame.title_frame.reset_btn:SetPushedTexture("Interface/Addons/QualityTime/Images/ResetTimerDown")
    main_frame.title_frame.reset_btn:SetPoint("RIGHT", -4, 0)
    main_frame.title_frame.reset_btn:SetScript("OnClick", ResetTimes)
    ]]--
    -- Add the width control
    config_frame.width_editbox = CreateFrame("EditBox", nil, config_frame)
    config_frame.width_editbox:SetPoint("TOPRIGHT", -10, -50)
    config_frame.width_editbox:SetPoint("BOTTOMLEFT", 10, 10)
    config_frame.width_editbox:SetMultiLine(false)
    config_frame.width_editbox:SetMaxLetters(99999)
    config_frame.width_editbox:SetFontObject(GameFontNormal)
    -- Add the height control
    -- Add the x offset control
    -- Add the y offset control
    -- return the config frame
    return config_frame
end

