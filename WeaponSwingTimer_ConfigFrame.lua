LHGWSTConfig = {}
local config_frame

LHGWSTConfig.CreateLHGWSTConfigFrame = function()
    -- Setup the config frame
    config_frame = CreateFrame("Frame", "WSTConfigFrame", UIParent)
    config_frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 100,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    config_frame:SetBackdropColor(0,0,0,1)
    config_frame:SetWidth(100)
    config_frame:SetHeight(100)
    config_frame:SetPoint("CENTER", 0, 0)
    config_frame:Show()
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
    config_frame.title_frame:SetWidth(100)
    config_frame.title_frame:SetHeight(30)
    config_frame.title_frame:SetPoint("TOP", 0, 0)
end

