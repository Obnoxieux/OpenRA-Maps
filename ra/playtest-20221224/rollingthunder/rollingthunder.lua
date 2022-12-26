SovietInfantryTypes = { "e1", "e1", "e1", "e2", "e2", "e4", "e4", "shok" }
SovietArmorTypes = { "3tnk", "3tnk", "3tnk", "3tnk", "v2rl", "4tnk", "ttnk" }
SovietAircraftType = { "yak", "yak", "mig", "hind" }
--SovietHeliType = {  }

SubPens = { SubPen1, SubPen2, SubPen3, SubPen4 }
AirFacilities = { Airfield1, Airfield2, Airfield3, Helipad1, Helipad2, Helipad3 }

IdlingUnits = { }
--AttackGroupSize = 3

SovietAttackPathGround = { { Rallypoint, AttackMoveSouth1, AlliedBaseEast, AlliedBaseWest }, { Rallypoint, AttackMoveNorth1, AlliedBaseWest, AlliedBaseEast } }
SovietAttackAir = { { AlliedBaseWest, AlliedBaseEast }, { AlliedBaseEast, AlliedBaseWest } }

InfAttack = { }
TankAttack = { }
AirAttack = { }
HeliAttack = { }

MCVReinforcement = { "mcv", "2tnk", "2tnk", "1tnk", "jeep" }
TransportBoatReinforcement = { "lst", "lst", "lst" }

Rallypoints = { Rallypoint }
Barracks = { Rax }
Warfactory = { Wafa }

BuildVehicles = true
TrainInfantry = true
Attacking = true


IdleHunt = function(unit) if not unit.IsDead then Trigger.OnIdle(unit, unit.Hunt) end end


ProduceInfantry = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9))
	local toBuild = { Utils.Random(SovietInfantryTypes) }
	local Path = Utils.Random(SovietAttackPathGround)
	ussr.Build(toBuild, function(unit)
		InfAttack[#InfAttack + 1] = unit[1]

		if #InfAttack >= 9 then
			SendUnits(InfAttack, Path)
			InfAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(2), ProduceInfantry)
		else
			Trigger.AfterDelay(delay, ProduceInfantry)
		end
	end)
end

ProduceTanks = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(15))
	local toBuild = { Utils.Random(SovietArmorTypes) }
	local Path = Utils.Random(SovietAttackPathGround)
	ussr.Build(toBuild, function(unit)
		TankAttack[#TankAttack + 1] = unit[1]

		if #TankAttack >= 3 then
			SendUnits(TankAttack, Path)
			TankAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(2), ProduceTanks)
		else
			Trigger.AfterDelay(delay, ProduceTanks)
		end
	end)
end

ProducePlanes = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(15))
	local toBuild = { Utils.Random(SovietAircraftType) }
	local Path = Utils.Random(SovietAttackAir)
	ussr.Build(toBuild, function(unit)
		AirAttack[#AirAttack + 1] = unit[1]

		if #AirAttack >= 1 then
			SendUnits(AirAttack, Path)
			AirAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(2), ProducePlanes)
		else
			Trigger.AfterDelay(delay, ProducePlanes)
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

	Trigger.AfterDelay(DateTime.Seconds(10), function()
		ProduceInfantry()
		ProduceTanks()
		ProducePlanes()
	end)
end


SetupTriggers = function()

	Trigger.OnKilled(RadarDome, function()
		allies1.MarkCompletedObjective(objDestroyRadar)
		allies2.MarkCompletedObjective(objDestroyRadar2)
		Media.PlaySpeechNotification(allies2, "AlliedReinforcementsArrived")
		Media.PlaySpeechNotification(allies1, "AlliedReinforcementsArrived")
		Reinforcements.Reinforce(allies1, TransportBoatReinforcement, { TransportBoatSpawn.Location, TransportBoatMove.Location })
		Reinforcements.Reinforce(allies2, TransportBoatReinforcement, { TransportBoatSpawn.Location, TransportBoatMove.Location })
		Reinforcements.Reinforce(allies1, MCVReinforcement, { MCVSpawn.Location, MCVMove.Location })
		Reinforcements.Reinforce(allies2, MCVReinforcement, { MCVSpawn.Location, MCVMove.Location })

		Trigger.AfterDelay(DateTime.Minutes(12), ActivateAI)
	end)

	Trigger.OnAllKilledOrCaptured(SubPens, function()
		allies1.MarkCompletedObjective(objSubPens)
		allies2.MarkCompletedObjective(objSubPens2)
	end)

	Trigger.OnAllKilledOrCaptured(AirFacilities, function()
		allies1.MarkCompletedObjective(objAirpower)
		allies2.MarkCompletedObjective(objAirpower2)
	end)

	Trigger.OnCapture(SovietForwardCommand, function()
		allies1.MarkCompletedObjective(objCaptureFC)
		allies2.MarkCompletedObjective(objCaptureFC2)
	end)

	Trigger.OnKilled(SovietForwardCommand, function()
		allies1.MarkFailedObjective(objCaptureFC)
		allies2.MarkFailedObjective(objCaptureFC2)
	end)
end


InitObjectives = function()

	ussrObj = ussr.AddPrimaryObjective("Deny the Allies.")
	objCaptureFC = allies1.AddPrimaryObjective("Capture the Soviet Forward Command.")
	objCaptureFC2 = allies2.AddPrimaryObjective("Capture the Soviet Forward Command.")
	objDestroyRadar = allies1.AddPrimaryObjective("Destroy the Soviet radar station.")
	objDestroyRadar2 = allies2.AddPrimaryObjective("Destroy the Soviet radar station.")
	objAirpower = allies1.AddSecondaryObjective("Destroy all of the Soviets' air capabilities.")
	objAirpower2 = allies2.AddSecondaryObjective("Destroy all of the Soviets' air capabilities.")
	objSubPens = allies1.AddSecondaryObjective("Destroy all of the Soviets' submarine production facilities.")
	objSubPens2 = allies2.AddSecondaryObjective("Destroy all of the Soviets' submarine production facilities.")
end

WorldLoaded = function()
	allies1 = Player.GetPlayer("Allies1")
	allies2 = Player.GetPlayer("Allies2")
	ussr = Player.GetPlayer("USSR")

  Trigger.OnObjectiveAdded(allies1, function(p, id)
      Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
  end)
    
  Trigger.OnObjectiveAdded(allies2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
  end)

  Trigger.OnObjectiveCompleted(allies1, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
  end)
    
  Trigger.OnObjectiveCompleted(allies2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
  end)

  Trigger.OnObjectiveFailed(allies1, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
  end)
    
  Trigger.OnObjectiveFailed(allies2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
  end)

  Trigger.OnPlayerWon(allies1, function()
    Media.PlaySpeechNotification(allies1, "MissionAccomplished")
  end)
    
  Trigger.OnPlayerWon(allies2, function()
    Media.PlaySpeechNotification(allies2, "MissionAccomplished")
  end)

  Trigger.OnPlayerLost(allies1, function()
    Media.PlaySpeechNotification(allies1, "MissionFailed")
  end)
    
  Trigger.OnPlayerLost(allies2, function()
    Media.PlaySpeechNotification(allies2, "MissionFailed")
  end)

	InitObjectives()
	SetupTriggers()
end
