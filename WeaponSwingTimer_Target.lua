local addon_name, addon_data = ...

addon_data.target = {}

addon_data.target.default_settings = {
	enabled = true,
	width = 300,
	height = 10,
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -150,
	in_combat_alpha = 1.0,
	ooc_alpha = 0.25,
	backplane_alpha = 0.5,
	is_locked = false,
    show_text = true,
	crp_ping_enabled = false,
	crp_fixed_enabled = false,
	crp_fixed_delay = 0.25
}
addon_data.target.settings = character_target_settings

addon_data.target.swing_timer = 0
addon_data.target.weapon_speed = 0
addon_data.target.class = 0
addon_data.target.weapon_id = 0
addon_data.target.guid = 0

addon_data.target.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not addon_data.target.settings then
        addon_data.target.settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.target.default_settings) do
        if addon_data.target.settings[setting] == nil then
            addon_data.target.settings[setting] = value
        end
    end
end

addon_data.target.RestoreDefaults = function()
    for setting, value in pairs(addon_data.target.default_settings) do
        addon_data.target.settings[setting] = value
    end
end

addon_data.target.UpdateInfo = function()
    if UnitExists("target") then
        addon_data.target.class = UnitClass("target")[2]
        addon_data.target.weapon_id = GetInventoryItemID("target", 16)
        addon_data.target.weapon_speed, _ = UnitAttackSpeed("target")
        addon_data.target.guid = UnitGUID("target")
    end
end

addon_data.target.ResetSwingTimer = function()
    addon_data.target.swing_timer = addon_data.target.weapon_speed
end

addon_data.target.ZeroizeSwingTimer = function()
    addon_data.target.swing_timer = 0.0001
end

addon_data.target.UpdateVisuals = function()
	if LHGWST_Settings.target_settings.enabled then
	end
end