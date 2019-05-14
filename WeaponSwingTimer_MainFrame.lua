LHGWSTMain = {}
local main_frame

LHGWSTMain.CreateLHGWSTMainFrame = function()
    -- Setup the main frame appearance
    main_frame = CreateFrame("Frame", "WSTMainFrame", UIParent)
    main_frame:SetWidth(300)
    main_frame:SetHeight(14)
    main_frame:SetPoint("CENTER", 200, 200)
    local main_texture = main_frame:CreateTexture(nil,"ARTWORK")
    main_texture:SetColorTexture(0,0,0,0.9)
    main_texture:SetAllPoints(main_frame)
    main_frame.texture = main_texture
    main_frame:Show()
    -- Setup the player's swing image appearance
    main_frame.player_swing_frame = CreateFrame("Frame", "WSTPlayerSwingFrame", main_frame)
    main_frame.player_swing_frame:SetWidth(main_frame:GetWidth() - 2)
    main_frame.player_swing_frame:SetHeight((main_frame:GetHeight() / 2) - 2)
    main_frame.player_swing_frame:SetPoint("TOP", 0, -1)
    local player_texture = main_frame.player_swing_frame:CreateTexture(nil,"ARTWORK")
    player_texture:SetColorTexture(0.8,1,0.8,1)
    player_texture:SetAllPoints(main_frame.player_swing_frame)
    main_frame.player_swing_frame.texture = player_texture
    -- Setup the target's swing image appearance
    main_frame.target_swing_frame = CreateFrame("Frame", "WSTTargetSwingFrame", main_frame)
    main_frame.target_swing_frame:SetWidth(main_frame:GetWidth() - 2)
    main_frame.target_swing_frame:SetHeight((main_frame:GetHeight() / 2) - 2)
    main_frame.target_swing_frame:SetPoint("BOTTOM", 0, 1)
    local target_texture = main_frame.target_swing_frame:CreateTexture(nil,"ARTWORK")
    target_texture:SetColorTexture(1,0.8,0.8,1)
    target_texture:SetAllPoints(main_frame.target_swing_frame)
    main_frame.target_swing_frame.texture = target_texture
    -- Register the main_frame for events
    main_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    main_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    main_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    main_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    main_frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    -- Set the scripts that control the main_frame
    
end
