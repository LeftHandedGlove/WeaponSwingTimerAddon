LHGWSTMain = {}

local function MainFrame_OnDragStart()
    if not LHG_WST_Settings.is_locked then
        LHGWSTMain.main_frame:StartMoving()
    end
end

local function MainFrame_OnDragStop()
    LHGWSTMain.main_frame:StopMovingOrSizing()
    _, _, rel_point, x_pos, y_pos = LHGWSTMain.main_frame:GetPoint()
    LHG_WST_Settings.rel_point = rel_point
    LHG_WST_Settings.x_pos = x_pos
    LHG_WST_Settings.y_pos = y_pos
    LHGWSTConfig.UpdateConfigFrameValues()
end

LHGWSTMain.UpdateSwingFrames = function()
	-- Get the swing speeds and timers
	local play_weap_speed = LHGWSTCore.player_weapon_speed
	local play_swing_time = LHGWSTCore.player_swing_timer
	local tar_weap_speed = LHGWSTCore.target_weapon_speed
	local tar_swing_time = LHGWSTCore.target_swing_timer
	-- Deal with divide by zero error
    if play_weap_speed == 0 then
        play_weap_speed = 2
    end
	-- Deal with divide by zero error
    if tar_weap_speed == 0 then
        tar_weap_speed = 2
    end
    -- Update the alpha
    local main_frame = LHGWSTMain.main_frame
    if LHG_WST_Settings.in_combat then
        main_frame:SetAlpha(LHG_WST_Settings.in_combat_alpha)
    else
        main_frame:SetAlpha(LHG_WST_Settings.ooc_alpha)
    end
    -- Update the player swing frame
    local player_swing_frame = LHGWSTMain.main_frame.player_swing_frame
	local player_percent = 1 - (play_swing_time / play_weap_speed)
	local player_width = (main_frame:GetWidth() - 2) * player_percent
    player_swing_frame:SetWidth(player_width)
    -- Update the target swing frame
    local target_swing_frame = LHGWSTMain.main_frame.target_swing_frame
	local target_percent = 1 - (tar_swing_time / tar_weap_speed)
	local target_width = (main_frame:GetWidth() - 2) * target_percent
    target_swing_frame:SetWidth(target_width)
	
	main_frame.target_swing_frame.crp_ping_frame:SetHeight(main_frame.target_swing_frame:GetHeight())
	local down, up, lagHome, lagWorld = GetNetStats()
	local ping_width = 0
	if (LHG_WST_Settings.crp_ping_enabled) then
		ping_width = (LHG_WST_Settings.width * (lagHome / 1000)) / tar_weap_speed
	end
	ping_offset = (main_frame:GetWidth() - 2) - target_width - ping_width
	main_frame.target_swing_frame.crp_ping_frame:SetWidth(ping_width)
	main_frame.target_swing_frame.crp_ping_frame:SetPoint("RIGHT", ping_offset, 0)
	
	main_frame.target_swing_frame.crp_fixed_frame:SetHeight(main_frame.target_swing_frame:GetHeight())
	local fixed_width = 0
	if (LHG_WST_Settings.crp_fixed_enabled) then
		fixed_width = (LHG_WST_Settings.width * (LHG_WST_Settings.crp_fixed_delay / 1000)) / tar_weap_speed
	end
	main_frame.target_swing_frame.crp_fixed_frame:SetWidth(fixed_width)
	main_frame.target_swing_frame.crp_fixed_frame:SetPoint("LEFT", main_frame.target_swing_frame.crp_ping_frame, 0, 0)
	
end

LHGWSTMain.UpdateVisuals = function()
    local main_frame = LHGWSTMain.main_frame
    main_frame:SetWidth(LHG_WST_Settings.width)
    main_frame:SetHeight(LHG_WST_Settings.height)
    main_frame:SetPoint(LHG_WST_Settings.rel_point, LHG_WST_Settings.x_pos, LHG_WST_Settings.y_pos)
    main_frame:SetScale(LHG_WST_Settings.scale)
    main_frame.main_texture:SetColorTexture(0,0,0,LHG_WST_Settings.backplane_alpha)
	
    main_frame.player_swing_frame:SetWidth(main_frame:GetWidth() - 2)
    main_frame.player_swing_frame:SetHeight((main_frame:GetHeight() / 2) - 2)
    main_frame.player_swing_frame:SetPoint("TOPLEFT", 1, -1)
	
    main_frame.target_swing_frame:SetWidth(main_frame:GetWidth() - 2)
    main_frame.target_swing_frame:SetHeight((main_frame:GetHeight() / 2) - 2)
    main_frame.target_swing_frame:SetPoint("BOTTOMLEFT", 1, 1)
	
    LHGWSTMain.UpdateSwingFrames()
end

LHGWSTMain.CreateLHGWSTMainFrame = function()
    -- Setup the main frame appearance
    LHGWSTMain.main_frame = CreateFrame("Frame", "WSTMainFrame", UIParent)
    local main_frame = LHGWSTMain.main_frame
    main_frame.main_texture = main_frame:CreateTexture(nil,"ARTWORK")
    main_frame.main_texture:SetColorTexture(0,0,0,LHG_WST_Settings.backplane_alpha)
    main_frame.main_texture:SetAllPoints(main_frame)
    main_frame.texture = main_frame.main_texture
    main_frame:Show()
    -- Setup the player's swing image appearance
    main_frame.player_swing_frame = CreateFrame("Frame", "WSTPlayerSwingFrame", main_frame)
    local player_texture = main_frame.player_swing_frame:CreateTexture(nil,"ARTWORK")
    player_texture:SetColorTexture(0.8,1,0.8,1)
    player_texture:SetAllPoints(main_frame.player_swing_frame)
    main_frame.player_swing_frame.texture = player_texture
    -- Setup the target's swing image appearance
    main_frame.target_swing_frame = CreateFrame("Frame", "WSTTargetSwingFrame", main_frame)
    local target_texture = main_frame.target_swing_frame:CreateTexture(nil,"ARTWORK")
    target_texture:SetColorTexture(1,0.8,0.8,1)
    target_texture:SetAllPoints(main_frame.target_swing_frame)
    main_frame.target_swing_frame.texture = target_texture
	-- Setup the Crit Reactive Procs Ping Delay Frame
	main_frame.target_swing_frame.crp_ping_frame = CreateFrame("Frame", "WSTCRPPingFrame", main_frame.target_swing_frame)
	local crp_ping_texture = main_frame.target_swing_frame.crp_ping_frame:CreateTexture(nil,"ARTWORK")
	crp_ping_texture:SetColorTexture(1,0,0,1)
    crp_ping_texture:SetAllPoints(main_frame.target_swing_frame.crp_ping_frame)
    main_frame.target_swing_frame.crp_ping_frame.texture = crp_ping_texture
	-- Setup the Crit Reactive Procs Fixed Delay Frame
	main_frame.target_swing_frame.crp_fixed_frame = CreateFrame("Frame", "WSTCRPFixedFrame", main_frame.target_swing_frame)
	local crp_fixed_texture = main_frame.target_swing_frame.crp_fixed_frame:CreateTexture(nil,"ARTWORK")
	crp_fixed_texture:SetColorTexture(1,0,0,1)
    crp_fixed_texture:SetAllPoints(main_frame.target_swing_frame.crp_fixed_frame)
    main_frame.target_swing_frame.crp_fixed_frame.texture = crp_fixed_texture
    -- Set the scripts that control the main_frame
    main_frame:SetMovable(true)
    main_frame:EnableMouse(true)
    main_frame:RegisterForDrag("LeftButton")
    main_frame:SetScript("OnDragStart", MainFrame_OnDragStart)
    main_frame:SetScript("OnDragStop", MainFrame_OnDragStop)
    -- Update the visuals
    LHGWSTMain.UpdateVisuals()
    -- return the main_frame
    return main_frame
end
