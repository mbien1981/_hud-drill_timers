CustomTimerGUI = CustomTimerGUI or class()

function CustomTimerGUI:create_box(panel, params, config)
	local box_panel = panel:panel(params)
	local color = config and config.color or Color(1, 0, 0, 0)
	local bg_color = config and config.bg_color or Color(1, 0, 0, 0)
	local blend_mode = config and config.blend_mode

	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = bg_color,
	})

	local left_top = box_panel:panel({ h = box_panel:h() / 3, w = box_panel:h() / 3 })
	left_top:gradient({
		blend_mode = blend_mode,
		orientation = "vertical",
		gradient_points = { 0, color, 0.65, color, 1, Color(0, 0, 0, 0) },
		w = 2,
	})
	left_top:gradient({
		blend_mode = blend_mode,
		orientation = "horizontal",
		gradient_points = { 0, color, 0.65, color, 1, Color(0, 0, 0, 0) },
		h = 2,
	})

	local left_bottom = box_panel:panel({ h = box_panel:h() / 3, w = box_panel:h() / 3 })
	left_bottom:gradient({
		blend_mode = blend_mode,
		orientation = "vertical",
		gradient_points = { 1, color, 0.65, color, 0, Color(0, 0, 0, 0) },
		w = 2,
	})
	left_bottom:gradient({
		blend_mode = blend_mode,
		orientation = "horizontal",
		gradient_points = { 0, color, 0.65, color, 1, Color(0, 0, 0, 0) },
		h = 2,
		y = left_bottom:h() - 2,
	})
	left_bottom:set_bottom(box_panel:h())

	local right_top = box_panel:panel({ h = box_panel:h() / 3, w = box_panel:h() / 3 })
	right_top:gradient({
		blend_mode = blend_mode,
		orientation = "vertical",
		gradient_points = { 0, color, 0.65, color, 1, Color(0, 0, 0, 0) },
		x = right_top:w() - 2,
		w = 2,
	})
	right_top:gradient({
		blend_mode = blend_mode,
		orientation = "horizontal",
		gradient_points = { 1, color, 0.65, color, 0, Color(0, 0, 0, 0) },
		h = 2,
	})

	right_top:set_right(box_panel:w())

	local right_bottom = box_panel:panel({ h = box_panel:h() / 3, w = box_panel:h() / 3 })
	right_bottom:gradient({
		blend_mode = blend_mode,
		orientation = "vertical",
		gradient_points = { 1, color, 0.65, color, 0, Color(0, 0, 0, 0) },
		x = right_bottom:w() - 2,
		w = 2,
	})
	right_bottom:gradient({
		blend_mode = blend_mode,
		orientation = "horizontal",
		gradient_points = { 1, color, 0.65, color, 0, Color(0, 0, 0, 0) },
		y = right_bottom:h() - 2,
		h = 2,
	})

	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())

	return box_panel
end

function CustomTimerGUI:init(super)
	self.super = super

	self._hud = self.super:script(PlayerBase.PLAYER_INFO_HUD)
	self._panel = self._hud.panel:panel({ layer = -100 })

	self.font = { path = "fonts/font_univers_530_bold", size = 24 }

	self.items = {}

	self._toolbox = _M._hudToolBox
	self._updator = _M._hudUpdator

	self:setup_panels()

	self._updator:remove("timer_gui_update")
	self._updator:add(callback(self, self, "update"), "timer_gui_update")
end

function CustomTimerGUI:setup_panels()
	self.main_panel = self._panel:panel()

	self.item_container = self.main_panel:panel({ w = 200 })

	local y = 122
	local custom_control_panel = self.super._hud.custom_control_panel
	if custom_control_panel then
		y = custom_control_panel.main_panel:child("hostages_panel"):world_bottom() + 4
	end

	self.item_container:set_y(y)
	self.item_container:set_right(self.main_panel:right())
end

function CustomTimerGUI:exists(unit)
	if not next(self.items) then
		return false
	end

	for _, item in pairs(self.items) do
		if item.unit == unit then
			return true
		end
	end

	return false
end

function CustomTimerGUI:get_icon(timer_gui)
	local icon = "wp_drill"

	local unit = timer_gui._unit
	if alive(unit) then
		if (unit:base() and unit:base().is_hacking_device) or timer_gui._current_bar then
			icon = "wp_hack"
		elseif (unit:base() and unit:base().is_saw) or (unit:key() == "974ec006f0c9e852") then
			icon = "wp_saw"
		end
	end

	return icon
end

function CustomTimerGUI:add(timer_gui)
	if self:exists(timer_gui._unit) then
		return
	end

	local texture, texture_rect = tweak_data.hud_icons:get_icon_data(self:get_icon(timer_gui))

	local panel = self.item_container:panel({ h = 38 })

	local timer_container = panel:panel({
		name = "timer_container",
		w = (tonumber(timer_gui._current_timer) >= 3600 and 80) or 50,
	})
	self:create_box(timer_container, nil, { color = Color.white })

	local stage_container
	if timer_gui._current_bar then
		stage_container = panel:panel({ name = "stage_container", w = 50 })
		self:create_box(stage_container, nil, { color = Color.white })

		local stage_counter = stage_container:text({
			name = "stage_counter",
			text = string.format("%s/3", tostring(timer_gui._current_timer)),
			font = self.font.path,
			font_size = self.font.size,
			layer = 1,
			color = Color.white,
		})
		self._toolbox:make_pretty_text(stage_counter)
	end

	local timer = timer_container:text({
		name = "timer",
		text = tostring(timer_gui._current_timer),
		font = self.font.path,
		font_size = self.font.size,
		layer = 1,
		color = Color.white,
	})
	self._toolbox:make_pretty_text(timer)

	local icon = panel:bitmap({
		name = "icon",
		texture = texture,
		texture_rect = texture_rect,
		layer = 1,
		w = 30,
		h = 30,
	})

	timer:set_center(timer_container:center())
	timer_container:set_right(panel:right())

	if alive(stage_container) then
		stage_container:child("stage_counter"):set_center(timer_container:center())
		stage_container:set_right(timer_container:left() - 4)
	end

	icon:set_right((stage_container or timer_container):left() - 4)
	icon:set_center_y(timer_container:center_y())

	table.insert(self.items, {
		unit = timer_gui._unit,
		data = {
			time = tonumber(timer_gui._current_timer),
			stage = timer_gui._current_bar,
			animating = false,
			paused = false,
		},
		panel = panel,
	})
end

function CustomTimerGUI:remove(unit)
	if not next(self.items) then
		return
	end

	for i, item in pairs(self.items) do
		if item.unit == unit then
			item.panel:clear()
			item.panel:parent():remove(item.panel)

			table.remove(self.items, i)
		end
	end
end

function CustomTimerGUI:get_item_index(unit)
	if not next(self.items) then
		return false
	end

	for index, item in pairs(self.items) do
		if item.unit == unit then
			return index, item
		end
	end

	return nil
end

function CustomTimerGUI:get_timer_string(data)
	local timer = math.floor(data.time)
	local seconds = math.mod(timer, 60)
	local minutes = math.mod(math.floor(timer / 60), 60)
	local hours = math.floor(timer / 3600)

	local text = ((hours > 0) and string.format("%02d:%02d:%02d", hours, minutes, seconds))
		or string.format("%02d:%02d", minutes, seconds)

	return text
end

function CustomTimerGUI:update_item(timer_gui)
	if not self:exists(timer_gui._unit) then
		self:add(timer_gui)
		return
	end

	if not next(self.items) then
		return
	end

	local index = self:get_item_index(timer_gui._unit)
	local item = self.items[index]

	item.data.time = timer_gui._current_timer or 240
	item.data.stage = timer_gui._current_bar
	item.data.paused = timer_gui._jammed or not timer_gui._powered

	local timer = item.panel:child("timer_container"):child("timer")

	if item.data.paused and not item.data.animating then
		item.data.animating = true
		timer:stop()
		timer:set_color(Color("FF7A7A"))
		timer:animate(self._hud.flash_assault_title)
	end

	if item.data.animating and not item.data.paused then
		item.data.animating = false
		timer:stop()
		timer:set_color(Color.white)
	end

	timer:set_text(self:get_timer_string(item.data))
	self._toolbox:make_pretty_text(timer)

	if not item.data.stage then
		return
	end

	local stage_container = item.panel:child("stage_container")
	if alive(stage_container) then
		stage_container:child("stage_counter"):set_text(string.format("%s/3", tostring(item.data.stage)))
		self._toolbox:make_pretty_text(stage_container:child("stage_counter"))
	end
end

function CustomTimerGUI:update_gui()
	local i = 0
	for _, item in pairs(self.items) do
		local panel = item.panel
		local data = item.data
		if (data.stage and data.stage <= 3 or not data.stage) and math.floor(data.time) >= 0 and alive(panel) then
			panel:set_y((panel:h() * i) + ((i > 0 and (4 * i)) or 0))

			local timer_container = panel:child("timer_container")

			timer_container:child("timer"):set_world_center(timer_container:world_center())

			local stage_container = panel:child("stage_container")
			if alive(stage_container) then
				stage_container:child("stage_counter"):set_world_center(stage_container:world_center())
			end

			i = i + 1
		else
			self:remove(item.unit)
		end
	end
end

function CustomTimerGUI:update()
	if not next(self.items) then
		return
	end

	self:update_gui()
end

local module = ... or D:module("_hud-drill_timers")

if RequiredScript == "lib/units/beings/player/playerbase" then
	local PlayerBase = module:hook_class("PlayerBase")
	module:post_hook(50, PlayerBase, "_setup_hud", function(...)
		if not managers.hud._hud.custom_drill_timer then
			managers.hud._hud.custom_drill_timer = CustomTimerGUI:new(managers.hud)
		end
	end, false)
end

if RequiredScript == "lib/units/props/timergui" then
	local TimerGui = module:hook_class("TimerGui")
	module:post_hook(50, TimerGui, "_start", function(self)
		local custom_drill_timer = managers.hud._hud.custom_drill_timer
		if not custom_drill_timer then
			return
		end

		custom_drill_timer:add(self)
	end)

	module:post_hook(50, TimerGui, "update", function(self)
		local custom_drill_timer = managers.hud._hud.custom_drill_timer
		if not custom_drill_timer then
			return
		end

		if not alive(self._unit) then
			custom_drill_timer:remove(self._unit)
			return
		end

		custom_drill_timer:update_item(self)
	end)
end

if RequiredScript == "lib/units/props/securitylockgui" then
	local SecurityLockGui = module:hook_class("SecurityLockGui")
	module:post_hook(50, SecurityLockGui, "_start", function(self, ...)
		local custom_drill_timer = managers.hud._hud.custom_drill_timer
		if not custom_drill_timer then
			return
		end

		custom_drill_timer:add(self)
	end)

	module:post_hook(50, SecurityLockGui, "update", function(self, ...)
		local custom_drill_timer = managers.hud._hud.custom_drill_timer
		if not custom_drill_timer then
			return
		end

		if not alive(self._unit) then
			custom_drill_timer:remove(self._unit)
			return
		end

		custom_drill_timer:update_item(self)
	end)
end
