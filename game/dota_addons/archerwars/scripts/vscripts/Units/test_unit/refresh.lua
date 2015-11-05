function Activate( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local heal_amount = caster:GetMaxHealth() - caster:GetHealth() 
	local mana_amount = caster:GetMaxMana() - caster:GetMaxMana() 

	if (heal_amount > 0) then print("Health for: " .. heal_amount) end
	if (mana_amount > 0) then print("Mana for: " .. mana_amount) end
	
	caster:SetHealth(caster:GetMaxHealth())
	caster:SetMana(caster:GetMaxMana())
end