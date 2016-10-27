local Pool = {}

function Pool.init()
	Pool.container = {}
	Pool.creator = {}
end

function Pool.check_container(key)
	if Pool.container[key] == nil then
		Pool.container[key] = {}
	end
end

function Pool.check_preload(key, num)
	Pool.check_container(key)
	while #Pool.container[key] < num do
		table.push(Pool.container[key], Pool.creator[key]())
	end
end

function Pool.get_object(key)
	Pool.check_preload(key, 1)
	local obj = Pool.container[key][#Pool.container[key]]
	table.remove(Pool.container[key], #Pool.container[key])
	return obj
end

function Pool.insert_object(key, obj)
	Pool.check_container(key)
	table.push(Pool.container[key], obj)
end

Pool.init()

return Pool