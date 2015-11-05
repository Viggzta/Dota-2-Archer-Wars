function Activate( keys )
	local caster = keys.caster
	local distance = keys.distance
	local duration = keys.duration
	local loops = 60
	local power = (distance / loops)

	for l=0, loops do
		Timers:CreateTimer((duration / loops) * l, function() 
			FindClearSpaceForUnit(caster, caster:GetCenter() + caster:GetForwardVector() * power, false) 
		end)
	end
end