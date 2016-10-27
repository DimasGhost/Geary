local Game = display.newGroup()

function Game.init()
	local Utils = require("scripts.utils")
	local Gear = require('scripts.gear')

	Game.session_number = 0
	Game.start_time = 0
	Game.session_start_time = system.getTimer()

	Game.score = Utils.create_text('0', 120, 'blood', Utils.cx, Utils.cy - 450)
	Game.score.alpha = 0

	Game.lx, Game.ly = 0, 0
	Game.angle, Game.shift_x, Game.shift_y = 0, 0, 0
	Game.dir = 1 - (math.random(2) - 1) * 2
	Game.period = 2300
	Game.controls_active = false

	Gear.group = Game
	Gear.preload(4)

	Game.gears = {Gear.get_gear()}
	Game.gears[1]:show()
	Game.gears[1]:set_pos(Utils.cx, Utils.cy + 1000)
	Game.gears[1]:colorize()
	Gear.apply_color()
	Game.rotate_gear(Game.gears[1])

	Utils.load_sound_row('gear_connection')
	Utils.load_sound_row('gear_bump')
end

function Game.start()
	local Utils = require('scripts.utils')
	local Tutorial = require('scripts.tutorial')
	Tutorial.show()

	Game.start_time = system.getTimer()

	Game.score.text = 0
	Game.lx, Game.ly = Game.gears[1].body.x, Game.gears[1].body.y
	transition.cancel(Game.score)
	transition.to(Game.score, {alpha = 1, time = 800})
	Game.push_gear()
	Runtime:addEventListener('touch', Game.touch_listener)
end

function Game.touch_listener(event)
	if event.phase == 'ended' then
		Game.interact()
	end
end

function Game.push_gear()
	local Gear = require('scripts.gear')
	
	if #Game.gears == 4 then
		Game.remove_gear(4)
	end
	table.insert(Game.gears, 1, Gear.get_gear())
	
	Game.angle = math.random(-30, 30)
	Game.shift_x = math.sin(math.rad(Game.angle))
	Game.shift_y = -math.cos(math.rad(Game.angle))

	local tx, ty = Game.get_angle_shift(190)
	Game.focus_camera_at(tx, ty - 200)
	Game.appear_gear(Game.get_angle_shift(410))
	Game.lx, Game.ly = Game.get_angle_shift(360)

	local function activate_control()
		Game.controls_active = true
	end

	timer.performWithDelay(210, activate_control)
end

function Game.get_angle_shift(len)
	local x = Game.lx + Game.shift_x * len
	local y = Game.ly + Game.shift_y * len
	return x, y
end

function Game.focus_camera_at(x, y, time)
	local Utils = require("scripts.utils")

	time = time or 1000
	local cur_cam_x, cur_cam_y = Game:localToContent(x, y)
	local cam_add_x, cam_add_y = Utils.cx - cur_cam_x, Utils.cy - cur_cam_y
	local fx, fy = Game.x + cam_add_x, Game.y + cam_add_y
	transition.cancel(Game)
	transition.to(Game, {x = fx, y = fy, time = time, transition = easing.outExpo})
end

function Game.appear_gear(x, y)
	local gear = Game.gears[1]
	local side = Game.angle < 0 and -1 or 1
	gear:colorize()
	gear:show()
	gear:set_rot(math.random(45))
	gear:set_pos(x + 900 * side, y)
	gear:cancel_transitions()
	gear:make_transition({x = x, time = 600, transition = easing.outExpo})
end

function Game.interact()
	if not Game.controls_active then
		return
	end
	Game.controls_active = false

	local Utils = require('scripts.utils')

	local ang1 = Game.gears[1].body.rotation
	local ang2 = Game.gears[2].body.rotation
	local dif = (ang1 + ang2 - Game.angle * 2) % 45
	if math.abs(dif - 22.5) < 13 then
		local Gear = require('scripts.gear')
		Game.connect_gear(dif)
		Game.score.text = Game.score.text + 1
		Gear.apply_color()
		Game.push_gear()
		Utils.play_sound('gear_connection')
	else
		Game.throw_gear(Game.gears[1])
		table.remove(Game.gears, 1)
		timer.performWithDelay(450, Game.finish)
		Utils.play_sound('gear_bump', 100)
	end
end

function Game.connect_gear(dif)
	Game.dir = Game.dir * -1
	local t = 200
	local gear = Game.gears[1]
	local rot = gear.body.rotation + (22.5 - dif) + t / Game.period * 360 * Game.dir
	gear:cancel_transitions()
	gear:make_transition({x = Game.lx, y = Game.ly, time = t, rotation = rot})

	timer.perform_with_params(t, Game.rotate_gear, {Game.gears[1]})
	timer.perform_with_params(t, Game.correct_angles, {Game.gears[1], Game.gears[2], Game.angle})
end

function Game.correct_angles(gear1, gear2, angle)
	local ang1 = gear1.body.rotation
	local ang2 = gear2.body.rotation
	local dif = (ang1 + ang2 - angle * 2) % 45
	local dir = Game.dir * -1
	local t = 200
	local rot = gear2.body.rotation + (22.5 - dif) + t / Game.period * 360 * dir
	gear2:cancel_transitions()
	gear2:make_transition({rotation = rot, time = t})
	timer.perform_with_params(t, Game.rotate_gear, {gear2, dir})
end

function Game.rotate_gear(gear, dir)
	gear = gear or Game.gears[1]
	dir = dir or Game.dir
	gear.body.rotation = gear.body.rotation % 45
	gear.shadow.rotation = gear.body.rotation
	gear:make_transition({rotation = gear.body.rotation + 360 * dir, time = Game.period, iterations = -1})
end

function Game.throw_gear(gear)
	local fx = gear.body.x - (gear.body.x - Game.lx) / 2
	local fy = gear.body.y - (gear.body.y - Game.ly) / 2
	local t = 50
	gear:cancel_transitions()
	gear:make_transition({x = fx, y = fy, time = t})

	local function throw_away_gear(gear)
		local fx = gear.body.x + (gear.body.x - Game.lx) * 60
		local fy = gear.body.y + (gear.body.y - Game.ly) * 60
		local t = 400
		gear:cancel_transitions()
		gear:make_transition({x = fx, y = fy, time = t})

		timer.perform_with_params(t, gear.free, {gear})
	end

	timer.perform_with_params(t, throw_away_gear, {gear})
end

function Game.finish()
	local Utils = require('scripts.utils')
	local Replay = require('scripts.replay')
	local ads_control = require('scripts.ads_control')
	local analytics = require('analytics')
	local Tutorial = require('scripts.tutorial')
	Tutorial.hide()

	Runtime:removeEventListener('touch', Game.touch_listener)

	local session_time = (system.getTimer() - Game.session_start_time) / 1000
	local game_time = (system.getTimer() - Game.start_time) / 1000
	local prev_highscore = Utils.data_table.score
	local score = tonumber(Game.score.text)
    Game.new_best_score = prev_highscore < score
	if Game.new_best_score then
        Utils.change_data_table({score = score})
    end
	Game.session_number = Game.session_number + 1
	Utils.change_data_table({game_cnt = Utils.data_table.game_cnt + 1})

	analytics.logEvent('GameEnd', {
			mode = 'normal',
			number = Utils.data_table.game_cnt,
			session_number = Game.session_number,
			session_time = session_time,
			game_time = game_time,
			score = score,
			is_highscore = Game.new_best_score,
			prev_highscore = prev_highscore
		})

	Game.hide()
	Replay:show()
	
	if not ads_control.show() then
		Utils.change_data_table({rate_cnt = Utils.data_table.rate_cnt + 1})
		if Utils.data_table.rate_cnt % 50 == 49 then
			Utils.ask_for_rate()
		end
	end
end

function Game.hide()
	transition.cancel(Game.score)
	transition.to(Game.score, {alpha = 0, time = 800})

	Game.focus_camera_at(Game.gears[1].body.x, Game.gears[1].body.y - 700)
	timer.performWithDelay(300, Game.hide_gears)
end

function Game.hide_gears()
	while #Game.gears > 1 do
		Game.remove_gear(2)
	end
end

function Game.free_gear(gear)
	gear:hide()
	Game.pool.insert_object('gear', gear)
end

function Game.remove_gear(ind)
	Game.gears[ind]:free()
	table.remove(Game.gears, ind)
end

Game.init()

return Game