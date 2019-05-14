local core_frame = CreateFrame("Frame", "MainFrame", UIParent)
core_frame:RegisterEvent("ADDON_LOADED")

local function CoreFrame_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        LHGWSTMain.CreateLHGWSTMainFrame()
        LHGWSTConfig.CreateLHGWSTConfigFrame()
    end
end

core_frame:SetScript("OnEvent", CoreFrame_OnEvent)
