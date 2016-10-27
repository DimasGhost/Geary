local Utils = {
	white = 'F0F1EE',
	blood = 'D94E67',
	brown = 'D79C8C',
	yellow = 'FFDC84',
	red = 'F97B76',
	orange = 'FFAA66',
	green = 'ABD294',
	blue = '86CBF0',
	purple = 'C6ACC4',
	black = '808080',
	cx = display.contentCenterX,
	cy = display.contentCenterY,
	game_market_link = 'market://details?id=com.maunt.geary',
	game_http_link = 'https://play.google.com/store/apps/details?id=com.maunt.geary'
}

function Utils.init()
	Utils.init_data_table()
	Utils.sounds = {}
	Utils.table_patch()
	Utils.timer_patch()
	Utils.load_sound('click.wav', 'click')
end

function Utils.ask_for_rate()
	local analytics = require('analytics')
	local title = 'Like this game?'
	local text = 'Please rate it!'
	local function onComplete(event)
	    if event.action == 'clicked' then
	    	if event.index == 1 then
	        	system.openURL(Utils.game_market_link)
	        	analytics.logEvent('RateAccept')
	        else
	        	analytics.logEvent('RateRefuse')
	        end
	    end
	end
	native.showAlert(title, text, {'OK', 'No, thanks'}, onComplete)
end

function Utils.color(col)
	local r, g, b = Utils[col]:sub(1, 2), Utils[col]:sub(3, 4), Utils[col]:sub(5, 6)
	return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255
end

function Utils.create_text(text, size, color, x, y, group, font, absolute_xy)
	if absolute_xy == nil then
		absolute_xy = true
	end
	font = font or 'Clarke'
	local label = display.newText(text, 0, 0, font, size)
	if color ~= nil then
    	label:setFillColor(Utils.color(color))
    end
    if group ~= nil then
    	group:insert(label)
    end
    if absolute_xy then
    	label.x, label.y = label:contentToLocal(x, y)
    else
    	label.x, label.y = x, y
    end
    return label
end

function Utils.create_image(name, x, y, scale, group, absolute_xy, color)
    local image = display.newImage('images/' .. name .. '.png')
    image:scale(scale, scale)
    if group then
        group:insert(image)
    end
    if absolute_xy then
        image.x, image.y = image:contentToLocal(x, y)
    else
        image.x, image.y = x, y
    end
    if color then
        image:setFillColor(Utils.color(color))
    end
    return image
end

function Utils.create_button(name, x, y, width, height, color, func, group, absolute_xy)
	if absolute_xy == nil then
		absolute_xy = true
	end
    local widget = require("widget")

    local but = widget.newButton {
        width = width, height = height,
        defaultFile = "buttons/" .. name .. ".png",
        overFile = "buttons/" .. name .. "_pressed.png",
        onRelease = function(event)
        	Utils.play_sound('click')
        	func()
    	end
    }
    if group ~= nil then
    	group:insert(but)
    end
    but:setFillColor(Utils.color(color))
    if absolute_xy then
    	but.x, but.y = but:contentToLocal(x, y)
    else
    	but.x, but.y = x, y
    end

    return but
end

function Utils.shake_button(button)
	Utils.shake(button, true, 30, 4, 500)
end

function Utils.loading_button(button)
	Utils.shake(button, false, 40, 800, 200000)
end

function Utils.stop_button(button)
	transition.cancel(button)
end

function Utils.reset_place()
	object.std_place = nil
	object.to_place = nil
end

function Utils.save_place(object)
	if object.std_place == nil then
		object.std_place = {}
		object.std_place.x, object.std_place.y = object.x, object.y
	end
	function object.to_place()
		object.x, object.y = object.std_place.x, object.std_place.y
	end
end

function Utils.shake(object, calming, offset, amount, time)
    Utils.save_place(object)
    local function eas(t, tmax, start, delta)
        return start + offset * math.sin(t / tmax * math.pi * amount) * (calming and (1 - t / tmax) or 1)
    end
    object.to_place()
    transition.cancel(object)
    params = {
        x = object.std_place.x,
        time = time,
        transition = eas,
        onCancel = object.to_place,
        onComplete = object.to_place
    }
    transition.to(object, params)
end

function Utils.inherit(child, parent)
	for key, value in pairs(parent) do
		child[key] = value
	end
end

function Utils.init_data_table()
	local LoadSave = require('scripts.external.loadsave')

	local source_table = LoadSave.loadTable("data_table.json") or {}
	Utils.data_table = {}
	local table_preset = {
		score = 0,
		sound = true,
		last_ad = 0,
		rate_cnt = 0,
		game_cnt = 0
	}
	for key, value in pairs(table_preset) do
		if type(source_table[key]) ~= type(value) then
			Utils.data_table[key] = value
		else
			Utils.data_table[key] = source_table[key]
		end
	end
	LoadSave.saveTable(Utils.data_table, "data_table.json")
end

function Utils.change_data_table(data_changes)
	local LoadSave = require('scripts.external.loadsave')

	for key, value in pairs(data_changes) do
		Utils.data_table[key] = value
	end
	LoadSave.saveTable(Utils.data_table, "data_table.json")
end

function Utils.load_sound(path, name)
	name = name or path
	local sound = audio.loadSound('sounds/' .. path)
	if sound == nil then
		return false
	end
	if Utils.sounds[name] == nil then
		Utils.sounds[name] = {}
	end
	Utils.sounds[name][#Utils.sounds[name] + 1] = sound
	return true
end

function Utils.load_sound_row(path, name)
	name = name or path
	i = 1
	while Utils.load_sound(path .. '/' .. i .. '.wav', name) do
		i = i + 1
	end
end

function Utils.play_sound(sound_name, delay)
	local function play_now(sound_name)
		local sounds = Utils.sounds[sound_name]
		local sound = sounds[math.random(#sounds)]
		audio.play(sound)
	end
	if delay then
		timer.perform_with_params(delay, play_now, {sound_name})
	else
		play_now(sound_name)
	end
end

function Utils.table_patch()
	function table.push(t, val)
		t[#t + 1] = val
	end
end

function Utils.timer_patch()
	local function call_with_args(event)
		event.source.params.func(unpack(event.source.params.args))
	end
	function timer.perform_with_params(delay, func, args, iterations)
		timer.performWithDelay(delay, call_with_args, iterations).params = {func = func, args = args}
	end
end

Utils.init()

return Utils