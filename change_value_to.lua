return function (max_delta, current, target)
	return current < target and math.min(target, current + max_delta)
		or math.max(target, current - max_delta)
end