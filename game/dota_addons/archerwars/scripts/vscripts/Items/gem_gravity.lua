function Activate( keys )
	local caster = keys.caster
	local target = keys.target
	local cPos = caster:GetCenter()
	local tPos = target:GetCenter()
	local distance = keys.distance
	local duration = keys.duration
	local loops = 60
	local power = (distance / loops) * -1

	for l=0, loops do
		local Rotation = math.atan2(tPos.y - cPos.y, tPos.x - cPos.x)
		local VectorTowards = Vector(math.cos( Rotation ) * power, math.sin( Rotation ) * power, target:GetCenter().z)
		Timers:CreateTimer((duration / loops) * l, function() FindClearSpaceForUnit(target, target:GetCenter() + VectorTowards, false) end)
	end
end