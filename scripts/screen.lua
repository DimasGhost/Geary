local Screen = {}

function Screen.init()
    local Utils = require('scripts.utils')
    Utils.load_sound('woosh.wav', 'woosh')
end

function Screen:create_button(name, x, y, func)
    local Utils = require("scripts.utils")

    but = Utils.create_button(name, x, y, 192, 192, 'blood', func, self)
    table.push(self.buttons, but)
    return but
end

function Screen:create_sound_button()
    local Utils = require('scripts.utils')
    local function turn_sound()
        self:turn_sound()
    end
    self.sound_on_but = self:create_button('sound_on', Utils.cx + 200, Utils.cy + 50, turn_sound)
    self.sound_off_but = self:create_button('sound_off', Utils.cx + 200, Utils.cy + 50, turn_sound)
    self.sound_on_but.isVisible = Utils.data_table.sound
    self.sound_off_but.isVisible = not Utils.data_table.sound
end

function Screen:turn_sound()
    local Utils = require('scripts.utils')
    if audio.getVolume() == 0 then
        audio.setVolume(1)
        Utils.change_data_table({sound = true})
        self.sound_on_but.isVisible = true
        self.sound_off_but.isVisible = false
    else
        audio.setVolume(0)
        Utils.change_data_table({sound = false})
        self.sound_on_but.isVisible = false
        self.sound_off_but.isVisible = true
    end
end

function Screen:show()
    local Game = require("scripts.game")
    local Utils = require('scripts.utils')

    transition.cancel(self)
    self.isVisible = true
    for i = 1, #self.buttons do
    	self.buttons[i]:setEnabled(true)
    end
    self.sound_on_but.isVisible = Utils.data_table.sound
    self.sound_off_but.isVisible = not Utils.data_table.sound
    timer.perform_with_params(400, Runtime.addEventListener, {Runtime, 'tap', self.on_tap})
    self.rotation = 180 * Game.dir * -1
    transition.to(self, {rotation = 0, time = 1300, transition = easing.outCubic})

    if self.on_call ~= nil then
        self.on_call()
    end
    Utils.play_sound('woosh', 400)
end

function Screen:hide(no_sound)
    local Game = require("scripts.game")
    local Utils = require('scripts.utils')

    transition.cancel(self)
    for i = 1, #self.buttons do
    	self.buttons[i]:setEnabled(false)
    end
    Runtime:removeEventListener('tap', self.on_tap)
    local function on_hide() 
        self.isVisible = false
    end
    timer.performWithDelay(1000, on_hide)
    transition.to(self, {rotation = 180 * Game.dir, time = 1300, transition = easing.outCubic})
    if not no_sound then
        Utils.play_sound('woosh', 200)
    end
end

Screen.init()

return Screen