AlliedInfantryTypes = { "e1", "e1", "e1", "e3", "e3"}
AlliedArmorTypes = { "1tnk", "2tnk" }
Helis = { "heli"}
ReinforcementTypes = { "4tnk", "4tnk", "v2rl", "3tnk"}
ParadropUnitTypes = { "e1", "e1", "e1", "e3", "e3" }
ParadropWaypoints = { Drop1, Drop2 }

IdlingUnits = { }
AttackGroupSize = 3

AlliedAttackPath = { Attack1, Attack2, SovBase }
HeliAttackPath = { SovBase }
AlliedAttackPathSouth = { Attack1, Attack2south, SovBase }
TruckEscapePath = { Truck1, Truck2, Truck3, Truck4 }

InfAttack = { }
TankAttack = { }
HeliAttack = { }

--Boat = { "lst" }

Rallypoints = { Rallypoint }
Barracks = { Rax }
Warfactory = { Wafa }

--TheTruck = { TheTruck }

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

------------------------------------------------------build stuff------------------------------------------------------------------------------

ProduceInfantry = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9))
	local toBuild = { Utils.Random(AlliedInfantryTypes) }
	allies.Build(toBuild, function(unit)
		InfAttack[#InfAttack + 1] = unit[1]

		if #InfAttack >= 8 then
			SendUnits(InfAttack, AlliedAttackPath)
			InfAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceInfantry)
		else
			Trigger.AfterDelay(delay, ProduceInfantry)
		end
	end)
end

ProduceTanks = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(AlliedArmorTypes) }
	allies.Build(toBuild, function(unit)
		TankAttack[#TankAttack + 1] = unit[1]

		if #TankAttack >= 5 then
			SendUnits(TankAttack, AlliedAttackPath)
			TankAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceTanks)
		else
			Trigger.AfterDelay(delay, ProduceTanks)
		end
	end)
end

ProduceHelis = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(Helis) }
	allies.Build(toBuild, function(unit)
		HeliAttack[#HeliAttack + 1] = unit[1]

		if #HeliAttack >= 1 then
			SendUnits(HeliAttack, HeliAttackPath)
			HeliAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceHelis)
		else
			Trigger.AfterDelay(delay, ProduceHelis)
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


--note: es wird immer nur eine davon aktiviert - offenbar gehen keine zwei loopenden Aufträge bei einem Gebäude

ActivateAI = function(cyard)

	Utils.Do(Map.NamedActors, function(actor)
		if actor.Owner == allies and actor.HasProperty("StartBuildingRepairs") then
			Trigger.OnDamaged(actor, function(building)
				if building.Owner == allies and building.Health < 3/4 * building.MaxHealth then
					building.StartBuildingRepairs()
				end
			end)
		end
	end)

	allies.Cash = 999999

	InitProductionBuildings()
	BuildBase(cyard)

	Trigger.AfterDelay(DateTime.Seconds(2), function()
		ProduceInfantry()
		ProduceTanks()
		ProduceHelis()
	end)
end

--------------------------------------------------------------------base stuff-------------------------------------------------------------------------------------------

InfantryProduction = { type = "tent", pos = CPos.New(17, 2), cost = 500, exists = true }
VehicleProduction = { type = "weap", pos = CPos.New(22, 2), cost = 2000, exists = true }

BaseBuildings = { InfantryProduction, VehicleProduction }

Trigger.OnKilled(Rax, function(building)
	InfantryProduction.exists = false
end)

Trigger.OnKilled(Wafa, function(building)
	VehicleProduction.exists = false
end)

BuildBase = function(cyard)
	Utils.Do(BaseBuildings, function(building)
		if not building.exists and not cyardIsBuilding then
			BuildBuilding(building, cyard)
			return
		end
	end)
	Trigger.AfterDelay(DateTime.Seconds(10), function() BuildBase(cyard) end)
end

BuildBuilding = function(building, cyard)
	cyardIsBuilding = true

	Trigger.AfterDelay(Actor.BuildTime(building.type), function()
		cyardIsBuilding = false

		if cyard.IsDead or cyard.Owner ~= allies then
			return
		end

		local actor = Actor.Create(building.type, true, { Owner = allies, Location = building.pos })
		allies.Cash = allies.Cash - building.cost

		building.exists = true

		if actor.Type == 'tent' or actor.Type == 'barr' then
			Trigger.AfterDelay(DateTime.Seconds(1), function() ProduceInfantry() end)
		if actor.Type == 'weap' then
			Trigger.AfterDelay(DateTime.Seconds(1), function() ProduceTanks() end)
		end

		Trigger.OnKilled(actor, function() building.exists = false end)

		Trigger.OnDamaged(actor, function(building)
			if building.Owner == allies and building.Health < building.MaxHealth * 3/4 then
				building.StartBuildingRepairs()
			end
		end)

		Trigger.AfterDelay(DateTime.Seconds(10), function() BuildBase(cyard) end)
		
end end)
end

--------------------------------------------------------------------------------------------------------------------------------------------------

InitObjectives = function()
	Trigger.OnObjectiveAdded(ussr, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	alliesObj = allies.AddPrimaryObjective("Deny the Soviets.")
	KillAll = ussr.AddPrimaryObjective("Eliminate all Allied units in this area.")

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

MoveTruck = function(truck)
  truck.Move(Truck1.Location)
  truck.Move(Truck2.Location)
  truck.Move(Truck3.Location)
  truck.Move(Truck4.Location)
end

SendReinforcements = function()
  Reinforcements.ReinforceWithTransport (ussr, "lst", ReinforcementTypes, { LSTSpawn.Location, LSTUnload.Location}, { LSTSpawn.Location})
end

ParadropAlliedUnits = function()
	local lz = Utils.Random(ParadropWaypoints).Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = allies, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = allies })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	Trigger.AfterDelay(DateTime.Seconds(30), ParadropAlliedUnits)
end

  
WorldLoaded = function()
	allies = Player.GetPlayer("Allies")
	ussr = Player.GetPlayer("USSR")
	greece = Player.GetPlayer("Greece")

	InitObjectives()
	ActivateAI(AlliesCYard)

  Trigger.AfterDelay(DateTime.Seconds(3), function()
    Actor.Create("tsla", true, { Owner = ussr, Location = TeslaSpawn.Location })
  end)
	Trigger.AfterDelay(DateTime.Seconds(4), function()
		if not TheTruck.IsDead then
			--MoveTruck(TheTruck) --finished testing this
			TheTruck.Destroy()
		end
	end)
  --Trigger.AfterDelay(DateTime.Seconds(7), function() SendReinforcements() end)
  --Trigger.AfterDelay(DateTime.Seconds(10), function() ParadropAlliedUnits() end)

end==