local Gear = {}

function Gear.init()
	Gear.colors = {'red', 'orange', 'green', 'blue', 'purple'}
	Gear.block_dist = 89
	Gear.shadow_dist = 15
	Gear.group = nil
	Gear.pool = require('scripts.pool')
end

function Gear.preload(num)
	for i = 1, num do
		Gear.pool.insert_object('gear', Gear.create())
	end
end

function Gear.get_gear()
	return Gear.pool.get_object('gear')
end

function Gear:free()
	self:hide()
	Gear.pool.insert_object('gear', self)
end

function Gear.create_shape()
	local shape = display.newGroup()
	Gear.group:insert(shape)
	shape.blocks = {}
	for i = 0, 15 do
		local block = display.newImage(shape, 'images/block_normal.png')
		block.rotation = 45 * math.floor((i + 1) / 2)
		block:scale(1 - (i % 2) * 2, 1)
		block.anchorX = -1
		block.x = math.sin(math.rad(block.rotation)) * 127
		block.y = -math.cos(math.rad(block.rotation)) * 127
		shape.blocks[i + 1] = block
	end
	return shape
end

function Gear.create()
	local Utils = require('scripts.utils')

	local cur_gear = {}
	setmetatable(cur_gear, {__index = Gear})
	cur_gear.body = Gear.create_shape()
	cur_gear.shadow = Gear.create_shape()
	Gear.colorize_shape(cur_gear.shadow, 'black')
	cur_gear.shadow.x, cur_gear.shadow.y = Gear.shadow_dist, Gear.shadow_dist
	cur_gear.shadow:toBack()
	cur_gear:hide()

	return cur_gear
end

function Gear.colorize_shape(shape, color)
	local Utils = require('scripts.utils')

	for i = 1, 16 do
		shape.blocks[i]:setFillColor(Utils.color(color))
	end
end

function Gear:show()
	self.body.isVisible = true
	self.shadow.isVisible = true
end

function Gear:hide()
	self.body.isVisible = false
	self.shadow.isVisible = false
	self:cancel_transitions()
end

function Gear:set_pos(x, y)
	self.body.x, self.body.y = x, y
	self.shadow.x, self.shadow.y = x + Gear.shadow_dist, y + Gear.shadow_dist
end

function Gear:set_rot(rot)
	self.body.rotation, self.shadow.rotation = rot, rot
end

function Gear:colorize()
	local Utils = require('scripts.utils')

	local i = math.random(2, #Gear.colors)
	Gear.colorize_shape(self.body, Gear.colors[i])
	Gear.colors[i], Gear.colors[#Gear.colors] = Gear.colors[#Gear.colors], Gear.colors[i]
end

function Gear.apply_color()
	Gear.colors[1], Gear.colors[#Gear.colors] = Gear.colors[#Gear.colors], Gear.colors[1]
end

function Gear:cancel_transitions()
	transition.cancel(self.body)
	transition.cancel(self.shadow)
end

function Gear:make_transition(t)
	transition.to(self.body, t)
	if t.x ~= nil then
		t.x = t.x + Gear.shadow_dist
	end
	if t.y ~= nil then
		t.y = t.y + Gear.shadow_dist
	end
	t.onStart = nil
	t.onComplete = nil
	t.onPause = nil
	t.onResume = nil
	t.onCancel = nil
	t.onRepeat = nil
	transition.to(self.shadow, t)
end

Gear.init()

return Gear