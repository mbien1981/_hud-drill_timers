if rawget(_M, "_hudToolBox") then
	return
end

rawset(_M, "_hudToolBox", {})

local _hudToolBox = _M._hudToolBox

function _hudToolBox:make_pretty_text(text_obj)
	local _, _, w, h = text_obj:text_rect()
	w, h = w + 2, h + 2

	text_obj:set_size(w, h)
	text_obj:set_position(math.round(text_obj:x()), math.round(text_obj:y()))

	return w, h
end
