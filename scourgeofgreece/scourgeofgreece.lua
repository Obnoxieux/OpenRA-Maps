AlliedInfantryTypes = { "e1", "e1", "e1", "e3", "e3",}
AlliedArmorTypes = { "1tnk", "2tnk", "jeep", "apc" }
ParadropUnitTypes = { "e1", "e1", "e1", "e3", "e1", "e3", "e3" }

IdlingUnits = { }
AttackGroupSize = 3

AlliedAttackPath = { { Attack1, Attack2, SovBase }, { Attack1, Attack2south, SovBase } }
GreekAttackPath = { AttackGreece, Attack2, SovBase }

InfAttack = { }
InfAttackGreece = { }
TankAttack = { }

Rallypoints = { Rallypoint }
Barracks = { Rax }
Warfactory = { Wafa }

BuildVehicles = true
TrainInfantry = true
Attacking = true

Tick = function()
	if allies.HasNoRequiredUnits() 
	and greece.HasNoRequiredUnits() then
		ussr.MarkCompletedObjective(KillAll)
	end
end

IdleHunt = function(unit) if not unit.IsDead then Trigger.OnIdle(unit, unit.Hunt) end end


ProduceInfantry = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9))
	local toBuild = { Utils.Random(AlliedInfantryTypes) }
  local Path = Utils.Random(AlliedAttackPath)
	allies.Build(toBuild, function(unit)
		InfAttack[#InfAttack + 1] = unit[1]

		if #InfAttack >= 6 then
			SendUnits(InfAttack, Path)
			InfAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceInfantry)
		else
			Trigger.AfterDelay(delay, ProduceInfantry)
		end
	end)
end

ProduceInfantryGreece = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9))
	local toBuild = { Utils.Random(AlliedInfantryTypes) }
	greece.Build(toBuild, function(unit)
		InfAttackGreece[#InfAttackGreece + 1] = unit[1]

		if #InfAttackGreece >= 4 then
			SendUnits(InfAttackGreece, GreekAttackPath)
			InfAttackGreece = { }
			Trigger.AfterDelay(DateTime.Minutes(2), ProduceInfantryGreece)
		else
			Trigger.AfterDelay(delay, ProduceInfantryGreece)
		end
	end)
end

ProduceTanks = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(AlliedArmorTypes) }
  local Path = Utils.Random(AlliedAttackPath)
	allies.Build(toBuild, function(unit)
		TankAttack[#TankAttack + 1] = unit[1]

		if #TankAttack >= 4 then
			SendUnits(TankAttack, Path)
			TankAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceTanks)
		else
			Trigger.AfterDelay(delay, ProduceTanks)
		end
	end)
end

SendUnits = function(units, waypoints)
	Utils.Do(units, function(unit)
		if not unit.IsDead then
			Utils.Do(waypoints, function(waypoint)
				unit.AttackMove(waypoint.Location)
			end)
			unit.Hunt()
		end
	end)
end

InitProductionBuildings = function()
	if not Wafa.IsDead then
		Wafa.IsPrimaryBuilding = true
		Trigger.OnKilled(Wafa, function() BuildVehicles = false end)
	else
		BuildVehicles = false
	end

	if not Rax.IsDead then
		Rax.IsPrimaryBuilding = true
		Trigger.OnKilled(Rax, function() TrainInfantry = false end)
	else
		TrainInfantry = false
	end
end

ActivateAI = function()

	InitProductionBuildings()
  allies.Cash = 50000
  greece.Cash = 100000
	Trigger.AfterDelay(DateTime.Seconds(10), function()
		ProduceInfantry()
		ProduceTanks()
    ProduceInfantryGreece()
	end)
end

SendAlliedParatroopersDome = function()
	local lz = paradome.Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = allies, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = allies })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

SendAlliedParatroopersRax = function()
	local lz = pararax.Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = allies, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = allies })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

SetupTriggers = function()
  
  Trigger.OnKilledOrCaptured(alliesdome, function()
    ussr.MarkCompletedObjective(desRadar)
  end)

  Trigger.OnEnteredProximityTrigger(paradome.CenterPosition, WDist.FromCells(4), function(actor, trigger2)
		if actor.Owner == ussr then
			Trigger.RemoveProximityTrigger(trigger2)
      SendAlliedParatroopersDome()
		end
	end)

  Trigger.OnEnteredProximityTrigger(pararax.CenterPosition, WDist.FromCells(4), function(actor, trigger3)
		if actor.Owner == ussr then
			Trigger.RemoveProximityTrigger(trigger3)
      SendAlliedParatroopersRax()
		end
	end)

end

InitObjectives = function()
	Trigger.OnObjectiveAdded(ussr, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	alliesObj = allies.AddPrimaryObjective("Deny the Soviets.")
	KillAll = ussr.AddPrimaryObjective("Eliminate all Allied and Greek local units in this area.")
  desRadar = ussr.AddSecondaryObjective("Destroy the Allied Radar Dome.")

	Trigger.OnObjectiveCompleted(ussr, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(ussr, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerLost(ussr, function()
		Media.PlaySpeechNotification(ussr, "Lose")
	end)
	Trigger.OnPlayerWon(ussr, function()
		Media.PlaySpeechNotification(ussr, "Win")
	end)
end

WorldLoaded = function()
	allies = Player.GetPlayer("Allies")
	ussr = Player.GetPlayer("USSR")
	greece = Player.GetPlayer("Greece")

	InitObjectives()
	ActivateAI()
  SetupTriggers()
end
