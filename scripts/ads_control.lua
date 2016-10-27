local ads_control = {
	show_interval = 3,
	reload_interval = 2
}

function ads_control.init(app_id)
	local Utils = require('scripts.utils')
	if system.getInfo('environment') == 'simulator' then
		ads_control.show = function() end
		return
	end
	if Utils.data_table.last_ad > os.time() then
		Utils.change_data_table({last_ad = 0})
	end
	ads_control.ads = require('ads')
	ads_control.ads.init('admob', app_id, ads_control.ad_listener)
	ads_control.load()
end

function ads_control.load()
	ads_control.ads.load('interstitial')
end

function ads_control.show()
	local Utils = require('scripts.utils')
	local delta_time = os.time() - Utils.data_table.last_ad 
	local is_loaded = ads_control.ads.isLoaded('interstitial')
	if not is_loaded or delta_time < ads_control.show_interval * 60 then
		return false
	end
	Utils.change_data_table({last_ad = os.time()})
	ads_control.ads.show('interstitial')
	ads_control.load()
	return true
end

function ads_control.ad_listener(event)
	if event.isError then
		timer.performWithDelay(ads_control.reload_interval * 60000, ads_control.load)
	elseif event.phase == 'shown' then
		ads_control.load()
	end
end

ads_control.init('ca-app-pub-8603012012285695/5704073365')

return ads_control