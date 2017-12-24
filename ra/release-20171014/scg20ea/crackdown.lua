MammothPath = { Patrol1.Location, Patrol2.Location, Patrol3.Location, Patrol4.Location }
SovietInfantryTypes = { "e1", "e1", "e1", "e2", "e2", "e4", "e4"}
SovietArmorTypes = { "3tnk", "3tnk", "3tnk", "3tnk", "v2rl" }
IdlingUnits = { }

ConvoyTrucks = { Truck1, Truck2, Truck3, Truck4, Truck5, TruckIntro1, TruckIntro2 }

InfAttack = { }
TankAttack = { }

SovietAttackPath = { { AlliedBase }, { AttackSouth1, EscapeSouth3, AlliedBase }, { EscapeNorth2, EscapeNorth5, EscapeNorth7, AlliedBase } }

Barracks = { Rax }
Warfactory = { Wafa }

BuildVehicles = true
TrainInfantry = true
Attacking = true

Tick = function()
	if ussr.HasNoRequiredUnits() and ussr2.HasNoRequiredUnits() then
		allies.MarkCompletedObjective(objKillAll)
	end
end

ProduceInfantry = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9))
	local toBuild = { Utils.Random(SovietInfantryTypes) }
  local Path = Utils.Random(SovietAttackPath)
	ussr.Build(toBuild, function(unit)
		InfAttack[#InfAttack + 1] = unit[1]

		if #InfAttack >= 6 then
			SendUnits(InfAttack, Path)
			InfAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(3), ProduceInfantry)
		else
			Trigger.AfterDelay(delay, ProduceInfantry)
		end
	end)
end

ProduceTanks = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(SovietArmorTypes) }
  local Path = Utils.Random(SovietAttackPath)
	ussr.Build(toBuild, function(unit)
		TankAttack[#TankAttack + 1] = unit[1]

		if #TankAttack >= 2 then
			SendUnits(TankAttack, Path)
			TankAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(3), ProduceTanks)
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

SetupTriggers = function()

	Trigger.OnInfiltrated(RadarDome, function()
      allies.MarkCompletedObjective(objRadarSpy)
      Actor.Create("camera", true, { Owner = allies, Location = Cam1.Location })
      Actor.Create("camera", true, { Owner = allies, Location = Cam2.Location })
      Actor.Create("camera", true, { Owner = allies, Location = Cam3.Location })
      Actor.Create("camera", true, { Owner = allies, Location = Cam4.Location })
  end)

  Trigger.OnAllKilled(ConvoyTrucks, function()
      allies.MarkCompletedObjective(objDestroyAllTrucks)
  end)

  Trigger.OnEnteredProximityTrigger(EscapeNorth11.CenterPosition, WDist.FromCells(1), function(actor, triggerlose1)
    if actor.Owner == ussr and actor.Type == "truk" then
      Trigger.RemoveProximityTrigger(triggerlose1)
      actor.Destroy()
      allies.MarkFailedObjective(objDestroyAllTrucks)
    end
  end)

  Trigger.OnEnteredProximityTrigger(EscapeSouth6.CenterPosition, WDist.FromCells(1), function(actor, triggerlose2)
    if actor.Owner == ussr and actor.Type == "truk" then
      Trigger.RemoveProximityTrigger(triggerlose2)
      actor.Destroy()
      allies.MarkFailedObjective(objDestroyAllTrucks)
    end
  end)
end

InitObjectives = function()

	ussrObj = ussr.AddPrimaryObjective("Deny the Allies.")
	objDestroyAllTrucks = allies.AddPrimaryObjective("Destroy all Soviet Convoy Trucks.")
  objKillAll = allies.AddPrimaryObjective("Clear the sector of all Soviet presence.")
  objRadarSpy = allies.AddSecondaryObjective("Infiltrate the Soviet Radar Dome.")
	
end

SendPatrol = function(mammoth)
  mammoth.Patrol(MammothPath, true, 20)
end

MoveTruckNorth = function(truck)
  Media.DisplayMessage("Convoy truck attempting to escape!")
  truck.Move(EscapeNorth1.Location)
  truck.Move(EscapeNorth2.Location)
  truck.Move(EscapeNorth3.Location)
  truck.Move(EscapeNorth4.Location)
  truck.Move(EscapeNorth5.Location)
  truck.Move(EscapeNorth6.Location)
  truck.Move(EscapeNorth7.Location)
  truck.Move(EscapeNorth8.Location)
  truck.Move(EscapeNorth9.Location)
  truck.Move(EscapeNorth10.Location)
  truck.Move(EscapeNorth11.Location)
end

MoveTruckSouth = function(truck)
  Media.DisplayMessage("Convoy truck attempting to escape!")
  truck.Move(EscapeSouth1.Location)
  truck.Move(EscapeSouth2.Location)
  truck.Move(EscapeSouth3.Location)
  truck.Move(EscapeSouth4.Location)
  truck.Move(EscapeSouth5.Location)
  truck.Move(EscapeSouth6.Location)
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
  ussr.Cash = 999999

	Trigger.AfterDelay(DateTime.Seconds(30), function()
		ProduceInfantry()
		ProduceTanks()
	end)
end

WorldLoaded = function()
	allies = Player.GetPlayer("Greece")
	ussr = Player.GetPlayer("USSR")
  ussr2 = Player.GetPlayer("BadGuy")
	
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	Trigger.OnObjectiveCompleted(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerLost(allies, function()
		Media.PlaySpeechNotification(player, "Lose")
	end)
	Trigger.OnPlayerWon(allies, function()
		Media.PlaySpeechNotification(player, "Win")
	end)

  ActivateAI()

	SetupTriggers()
  SendPatrol(PatrolMammoth)
  
  Camera.Position = DefaultCameraPosition.CenterPosition
  
	InitObjectives()
  
  Trigger.AfterDelay(DateTime.Minutes(8), function() MoveTruckNorth(Truck1) end)
  Trigger.AfterDelay(DateTime.Minutes(14), function() MoveTruckNorth(Truck2) end)
  Trigger.AfterDelay(DateTime.Minutes(17), function() MoveTruckSouth(Truck3) end)
  Trigger.AfterDelay(DateTime.Minutes(20), function() MoveTruckNorth(Truck4) end)
  Trigger.AfterDelay(DateTime.Minutes(22), function() MoveTruckSouth(Truck5) end)
end