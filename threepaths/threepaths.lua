ParadropUnitTypes = { "e1", "e1", "e1", "e3", "e1", "e3", "e3" }
SovietParadropUnitTypes = { "e1", "e1", "e1", "e1", "e2", "e2", "e4", "e4", "e4" }
ParadropWaypoints = { AlliedParatroopersAttack1, AlliedParatroopersAttack2, AlliedParatroopersAttack3 }
NuclearTrucks = { Truck1, Truck2, Truck3 }
MCVReinforcement = { "mcv", "3tnk", "3tnk", "4tnk", "ttnk", "v2rl" }

AlliedInfantryTypes = { "e1", "e1", "e1", "e3", "e3"}
AlliedArmorTypes = { "1tnk", "1tnk", "2tnk", "2tnk", "apc", "jeep", "arty" }
AlliedHeliType = { "heli"}

InfAttackSouth = { }
TankAttackSouth = { }
HeliAttackSouth = { }
InfAttackWest = { }
HeliAttackWest = { }
TankAttackWest = { }

WestAttackPathGround = { { AttackWest1, AttackWest2, AttackWest3, AttackWestDirect4, AttackWestDirect5, RedBaseCentralPoint }, { AttackWest1, AttackWest2, AttackWest3, AttackWestSneaky4, AttackWestSneaky5, RedBaseCentralPoint } }
AirAttackPath = { RedBaseCentralPoint }
SouthAttackPathGround = { { AttackSouthLeft1, AttackSouthLeft2, AttackSouth3, OrangeBaseCentralPoint }, { AttackSouthRight1, AttackSouthRight2, AttackSouthRight3, AttackSouth3, OrangeBaseCentralPoint } }

BuildVehicles = true
TrainInfantry = true
Attacking = true

TruckGoalTrigger = { CPos.New(33, 118), CPos.New(32, 118), CPos.New(31, 118), CPos.New(30, 118), CPos.New(29, 118), CPos.New(28, 118), CPos.New(27, 118), CPos.New(26, 118), CPos.New(33, 119), CPos.New(32, 119), CPos.New(31, 119), CPos.New(30, 119), CPos.New(29, 119), CPos.New(28, 119), CPos.New(27, 119), CPos.New(26, 119), CPos.New(33, 120), CPos.New(32, 120), CPos.New(31, 120), CPos.New(30, 120), CPos.New(29, 120), CPos.New(28, 120), CPos.New(27, 120), CPos.New(26, 120) }

ReinforcementsDelay = DateTime.Minutes(16)

Tick = function()

	if not ussr1.IsObjectiveCompleted(objPowerGrid) and allies1.PowerState ~= "Normal" then
		ussr1.MarkCompletedObjective(objPowerGrid)
    ussr2.MarkCompletedObjective(objPowerGrid2)
	end
end

IdleHunt = function(unit) if not unit.IsDead then Trigger.OnIdle(unit, unit.Hunt) end end

Trigger.OnEnteredFootprint(TruckGoalTrigger, function(a, id)
	if not truckGoalTrigger and a.Owner == ussr1 and a.Type == "truk" then
		truckGoalTrigger = true
		ussr1.MarkCompletedObjective(objEvacuateTrucks)
		ussr2.MarkCompletedObjective(objEvacuateTrucks2)
	end
end)

ParadropAlliedUnits = function()
	local lz = Utils.Random(ParadropWaypoints).Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = allies1, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = allies1 })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	Trigger.AfterDelay(DateTime.Seconds(150), ParadropAlliedUnits)
end

AlliedTownParatroopers = function()
	local lz = VillageCentre.Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = allies1, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = allies1 })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

SovietOutpostParatroopersRed = function()
	local lz = SovietParatroopers1.Location
	local start = Map.CenterOfCell(RedReinforcementsSpawn.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr1, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(SovietParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = ussr1 })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

SovietOutpostParatroopersOrange = function()
	local lz = SovietParatroopers2.Location
	local start = Map.CenterOfCell(OrangeReinforcementsSpawn.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr2, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(SovietParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = ussr2 })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

SpawnSovietReinforcements = function()
  Reinforcements.Reinforce(ussr1, MCVReinforcement, { RedReinforcementsSpawn.Location, RedBaseCentralPoint.Location })
  Reinforcements.Reinforce(ussr2, MCVReinforcement, { OrangeReinforcementsSpawn.Location, OrangeBaseCentralPoint.Location })
end

SetupTriggers = function()

  Trigger.OnAnyKilled(NuclearTrucks, function()
		ussr1.MarkFailedObjective(objStreber)
		ussr2.MarkFailedObjective(objStreber2)
	end)

	Trigger.OnAllKilled(NuclearTrucks, function()
		ussr1.MarkFailedObjective(objEvacuateTrucks)
		ussr2.MarkFailedObjective(objEvacuateTrucks2)
	end)

  Trigger.OnEnteredProximityTrigger(VillageCentre.CenterPosition, WDist.FromCells(4), function(actor, trigger)
		if actor.Owner == ussr1 then
			Trigger.RemoveProximityTrigger(trigger)
			AlliedTownParatroopers()
		end
	end)

  Trigger.OnEnteredProximityTrigger(SovietParatroopers1.CenterPosition, WDist.FromCells(8), function(actor, trigger2)
		if actor.Owner == ussr1 then
			Trigger.RemoveProximityTrigger(trigger2)
			SovietOutpostParatroopersRed()
      SovietOutpostParatroopersOrange()
		end
	end)

  Trigger.OnCapture(SubPen, function()
		ussr1.MarkCompletedObjective(objOutpost)
		ussr2.MarkCompletedObjective(objOutpost2)
	end)

  Trigger.AfterDelay(ReinforcementsDelay, SpawnSovietReinforcements)

end

ProduceInfantryWest = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(6))
	local toBuild = { Utils.Random(AlliedInfantryTypes) }
  local Path = Utils.Random(WestAttackPathGround)
	allies1.Build(toBuild, function(unit)
		InfAttackWest[#InfAttackWest + 1] = unit[1]

		if #InfAttackWest >= 8 then
			SendUnits(InfAttackWest, Path)
			InfAttackWest = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceInfantryWest)
		else
			Trigger.AfterDelay(delay, ProduceInfantryWest)
		end
	end)
end

ProduceInfantrySouth = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(6))
	local toBuild = { Utils.Random(AlliedInfantryTypes) }
  local Path = Utils.Random(SouthAttackPathGround)
	allies2.Build(toBuild, function(unit)
		InfAttackSouth[#InfAttackSouth + 1] = unit[1]

		if #InfAttackSouth >= 8 then
			SendUnits(InfAttackSouth, Path)
			InfAttackSouth = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceInfantrySouth)
		else
			Trigger.AfterDelay(delay, ProduceInfantrySouth)
		end
	end)
end

ProduceTanksWest = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(9), DateTime.Seconds(10))
	local toBuild = { Utils.Random(AlliedArmorTypes) }
  local Path = Utils.Random(WestAttackPathGround)
	allies1.Build(toBuild, function(unit)
		TankAttackWest[#TankAttackWest + 1] = unit[1]

		if #TankAttackWest >= 6 then
			SendUnits(TankAttackWest, Path)
			TankAttackWest = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceTanksWest)
		else
			Trigger.AfterDelay(delay, ProduceTanksWest)
		end
	end)
end

ProduceTanksSouth = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(9), DateTime.Seconds(10))
	local toBuild = { Utils.Random(AlliedArmorTypes) }
  local Path = Utils.Random(SouthAttackPathGround)
	allies2.Build(toBuild, function(unit)
		TankAttackSouth[#TankAttackSouth + 1] = unit[1]

		if #TankAttackSouth >= 6 then
			SendUnits(TankAttackSouth, Path)
			TankAttackSouth = { }
			Trigger.AfterDelay(DateTime.Minutes(2), ProduceTanksSouth)
		else
			Trigger.AfterDelay(delay, ProduceTanksSouth)
		end
	end)
end

ProduceHelisWest = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(13))
	local toBuild = { Utils.Random(AlliedHeliType) }
	allies1.Build(toBuild, function(unit)
		HeliAttackWest[#HeliAttackWest + 1] = unit[1]

		if #HeliAttackWest >= 1 then
			SendUnits(HeliAttackWest, AirAttackPath)
			HeliAttackWest = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceHelisWest)
		else
			Trigger.AfterDelay(delay, ProduceHelisWest)
		end
	end)
end

ProduceHelisSouth = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(13))
	local toBuild = { Utils.Random(AlliedHeliType) }
	allies2.Build(toBuild, function(unit)
		HeliAttackSouth[#HeliAttackSouth + 1] = unit[1]

		if #HeliAttackSouth >= 1 then
			SendUnits(HeliAttackSouth, AirAttackPath)
			HeliAttackSouth = { }
			Trigger.AfterDelay(DateTime.Minutes(2), ProduceHelisSouth)
		else
			Trigger.AfterDelay(delay, ProduceHelisSouth)
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
  if not Wafa2.IsDead then
		Wafa2.IsPrimaryBuilding = true
		Trigger.OnKilled(Wafa, function() BuildVehicles = false end)
	else
		BuildVehicles = false
	end

	if not Rax2.IsDead then
		Rax2.IsPrimaryBuilding = true
		Trigger.OnKilled(Rax, function() TrainInfantry = false end)
	else
		TrainInfantry = false
	end
end

ActivateAI = function()

	InitProductionBuildings()
  allies1.Cash = 60000
  allies2.Cash = 60000

	Trigger.AfterDelay(DateTime.Seconds(2), function()
		ProduceInfantryWest()
		ProduceTanksWest()
		ProduceHelisWest()
    ProduceTanksSouth()
    ProduceInfantrySouth()
    ProduceHelisSouth()
	end)
end

InitObjectives = function()

	enemyobj = allies1.AddPrimaryObjective("Deny the Soviets.")
	objEvacuateTrucks = ussr1.AddPrimaryObjective("Evacuate at least one Truck from the sector.")
  objEvacuateTrucks2 = ussr2.AddPrimaryObjective("Evacuate at least one Truck from the sector.")
  objStreber = ussr1.AddSecondaryObjective("Protect ALL Trucks from destruction.")
  objStreber2 = ussr2.AddSecondaryObjective("Protect ALL Trucks from destruction.")
  objPowerGrid = ussr1.AddSecondaryObjective("Cut the Allied power grid to facilitate evacuation.")
  objPowerGrid2 = ussr2.AddSecondaryObjective("Cut the Allied power grid to facilitate evacuation.")
  objOutpost = ussr1.AddSecondaryObjective("Recapture our riverside outpost.")
  objOutpost2 = ussr2.AddSecondaryObjective("Recapture our riverside outpost.")
	
end

WorldLoaded = function()
	allies1 = Player.GetPlayer("Allies1")
  allies2 = Player.GetPlayer("Allies2")
	ussr1 = Player.GetPlayer("USSR1")
  ussr2 = Player.GetPlayer("USSR2")

	InitObjectives()
	ActivateAI()
  SetupTriggers()
  
  Trigger.OnObjectiveAdded(ussr1, function(p, id)
      Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
  end)
    
  Trigger.OnObjectiveAdded(ussr2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
  end)

  Trigger.OnObjectiveCompleted(ussr1, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
  end)
    
  Trigger.OnObjectiveCompleted(ussr2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
  end)

  Trigger.OnObjectiveFailed(ussr1, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
  end)
    
  Trigger.OnObjectiveFailed(ussr2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
  end)

  Trigger.OnPlayerWon(ussr1, function()
    Media.PlaySpeechNotification(player, "MissionAccomplished")
  end)
    
  Trigger.OnPlayerWon(ussr2, function()
    Media.PlaySpeechNotification(player, "MissionAccomplished")
  end)

  Trigger.OnPlayerLost(ussr1, function()
    Media.PlaySpeechNotification(player, "MissionFailed")
  end)
    
  Trigger.OnPlayerLost(ussr2, function()
    Media.PlaySpeechNotification(player, "MissionFailed")
  end)

  Trigger.AfterDelay(DateTime.Seconds(5), function() ParadropAlliedUnits() end)

end