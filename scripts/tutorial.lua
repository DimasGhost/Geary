local Tutorial = {}

function Tutorial.init()
	local Utils = require('scripts.utils')

	Tutorial.timer = nil
	Tutorial.page_timing = 3000
	Tutorial.page_show_time = nil
	Tutorial.page_rest = Tutorial.page_timing

	Tutorial.group = display.newGroup()
	Tutorial.group:scale(0.85, 0.85)
	Tutorial.group.x, Tutorial.group.y = Utils.cx, -70
	Tutorial.group.alpha = 0.8
	Tutorial.pages = {}
	for i = 1, 3 do
		Tutorial.pages[i] = display.newGroup()
		Tutorial.pages[i].alpha = 0
		Tutorial.group:insert(Tutorial.pages[i])
	end
	Tutorial.cur_page = 1

	local text, image

	text = Utils.create_text('TOUCH TO CONNECT GEARS', 50, 'blood', -30, 0, Tutorial.pages[1], nil, false)
	image = Utils.create_image('touch', 290, 0, 0.8, Tutorial.pages[1], false, 'blood')
	
	text = Utils.create_text('AVOID COLLISIONS', 50, 'blood', -100, 0, Tutorial.pages[2], nil, false)
	image = Utils.create_image('tutorial_bad', 200, 0, 0.8, Tutorial.pages[2], false, 'blood')

	text = Utils.create_text('YES, YOU CAN', 50, 'blood', -110, 0, Tutorial.pages[3], nil, false)
	image = Utils.create_image('tutorial_good', 150, 0, 0.8, Tutorial.pages[3], false, 'blood')
end

function Tutorial.show_page(page)
	Tutorial.page_show_time = system.getTimer()
	transition.cancel(page)
	page.alpha = 1
	page.y = 0
	transition.to(page, {y = 160, time = 700, transition = easing.outExpo})
end

function Tutorial.hide_page(page)
	transition.to(page, {alpha = 0, time = 800, transition = easing.outExpo})
end

function Tutorial.set_timer()
	Tutorial.timer = timer.performWithDelay(Tutorial.page_rest, Tutorial.next_page)
end

function Tutorial.next_page()
	Tutorial.hide_page(Tutorial.pages[Tutorial.cur_page])
	Tutorial.cur_page = Tutorial.cur_page + 1
	if Tutorial.cur_page > #Tutorial.pages then
		return
	end
	Tutorial.show_page(Tutorial.pages[Tutorial.cur_page])
	Tutorial.page_rest = Tutorial.page_timing
	Tutorial.set_timer()
end

function Tutorial.show()
	if Tutorial.cur_page > #Tutorial.pages then
		return
	end
	Tutorial.show_page(Tutorial.pages[Tutorial.cur_page])
	Tutorial.set_timer()
end

function Tutorial.hide()
	if Tutorial.cur_page > #Tutorial.pages then
		return
	end
	timer.cancel(Tutorial.timer)
	Tutorial.page_rest = math.max(0, Tutorial.page_rest - (system.getTimer() - Tutorial.page_show_time))
	Tutorial.hide_page(Tutorial.pages[Tutorial.cur_page])
end

Tutorial.init()

return Tutorial