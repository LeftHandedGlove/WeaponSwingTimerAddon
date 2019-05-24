LHGWST_target_frame  = {}

LHGWST_target_frame.default_settings = {
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
	crp_ping_enabled = false,
	crp_fixed_enabled = false,
	crp_fixed_delay = 0.25
}

LHGWST_target_frame.UpdateVisuals = function()
	if LHGWST_Settings.target_settings.enabled then
	end
end