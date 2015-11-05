function Activate( keys )
	local caster = keys.caster
	local cPos = caster:GetCenter()
	local tPos = caster:GetCenter()
	local distance = keys.distance
	local radius = keys.radius
	local duration = keys.duration
	local loops = 60
	local power = (distance / loops) * -1

	local units = FindUnitsInRadius( 
			caster:GetTeamNumber(), 
			cPos, 
			caster, 
			radius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
			0, 
			false
			)
	for _, unit in pairs( units ) do
		-- Not hitting invisible units
		tPos = unit:GetCenter()
		for l=0, loops do
			local Rotation = math.atan2(tPos.y - cPos.y, tPos.x - cPos.x)
			local VectorTowards = Vector(math.cos( Rotation ) * power, math.sin( Rotation ) * power, unit:GetCenter().z)
			Timers:CreateTimer((duration / loops) * l, function() FindClearSpaceForUnit(unit, unit:GetCenter() + VectorTowards, false) end)
		end
		StartSoundEventFromPosition("DOTA_Item.ForceStaff.Activate", tPos)
	end
end