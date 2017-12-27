NuclearPlants = { Bio1, Bio2 }

ParadropWaypoints = { Paradrop1, Paradrop2, Paradrop3 }
ParadropUnitTypes = { "e1", "e1", "e1", "e3", "e1", "e3", "e3" }

AlliedInfantryTypes = { "e1", "e1", "e1", "e1", "e3", "e3",}
AlliedArmorTypes = { "1tnk", "1tnk", "1tnk", "2tnk", "2tnk", "2tnk", "2tnk", "2tnk", "2tnk", "2tnk", "jeep", "jeep", "apc" }
AlliedAircraftTypes = { "heli" }
AlliedNavalTypes = { "pt", "dd", "dd", "dd", "dd", "ca" }

InfAttack = { }
TankAttack = { }
AirAttack = { }
NavalAttack = { }

AlliedAttackPath = XXXXXXXXXXXXXXXXXXXXX
AlliedNavyPath = XXXXXXXXXXXXXXXXXXXXX

OrangeMCVTeam = { "3tnk", "3tnk", "mcv", "shok", "shok" }

Tick = function()
	if allies.HasNoRequiredUnits() and england.HasNoRequiredUnits() then
		ussr1.MarkCompletedObjective(objKillAll)
		ussr2.MarkCompletedObjective(objKillAll)
		ussr1.MarkCompletedObjective(objDefendBase)
	end
end

ProduceInfantry = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(1), DateTime.Seconds(2))
	local toBuild = { Utils.Random(AlliedInfantryTypes) }
  local Path = Utils.Random(AlliedAttackPath)
	allies.Build(toBuild, function(unit)
		InfAttack[#InfAttack + 1] = unit[1]

		if #InfAttack >= 6 then
			SendUnits(InfAttack, Path)
			InfAttack = { }
			Trigger.AfterDelay(DateTime.Seconds(10), ProduceInfantry)
		else
			Trigger.AfterDelay(delay, ProduceInfantry)
		end
	end)
end

ProduceTanks = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(1), DateTime.Seconds(2))
	local toBuild = { Utils.Random(AlliedArmorTypes) }
  local Path = Utils.Random(AlliedAttackPath)
	allies.Build(toBuild, function(unit)
		TankAttack[#TankAttack + 1] = unit[1]

		if #TankAttack >= 4 then
			SendUnits(TankAttack, Path)
			TankAttack = { }
			Trigger.AfterDelay(DateTime.Seconds(10), ProduceTanks)
		else
			Trigger.AfterDelay(delay, ProduceTanks)
		end
	end)
end

ProduceAircraft = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(1), DateTime.Seconds(2))
	local toBuild = { Utils.Random(AlliedAircraftTypes) }
	allies.Build(toBuild, function(unit)
		AirAttack[#AirAttack + 1] = unit[1]

		if #AirAttack >= 1 then
			SendAircraft(AirAttack)
			AirAttack = { }
			Trigger.AfterDelay(DateTime.Seconds(120), ProduceAircraft)
		else
			Trigger.AfterDelay(delay, ProduceAircraft)
		end
	end)
end

ProduceNavy = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(1), DateTime.Seconds(2))
	local toBuild = { Utils.Random(AlliedNavalTypes) }
  local Path = Utils.Random(XXXXXXXXX)
	allies.Build(toBuild, function(unit)
		NavalAttack[#NavalAttack + 1] = unit[1]

		if #NavalAttack >= 2 then
			SendUnits(NavalAttack, Path)
			NavalAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(5), ProduceNavy)
		else
			Trigger.AfterDelay(delay, ProduceNavy)
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

SendAircraft = function(units)
	Utils.Do(units, function(unit)
		if not unit.IsDead then
			unit.Hunt()
		end
	end)
end

ActivateAI = function()

  allies.Cash = 100000

	Trigger.AfterDelay(DateTime.Seconds(25), function()
		ProduceInfantry()
		ProduceTanks()
		ProduceAircraft()
		ProduceNavy()
	end)
end

ParadropAlliedUnits = function()
	local lz = Utils.Random(ParadropWaypoints).Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = allies, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = allies })
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	Trigger.AfterDelay(DateTime.Seconds(160), ParadropAlliedUnits)
end

SpiesGo = function()
	if not spy1.IsDead or SovWafa.IsDead then
		spy1.Infiltrate(SovWafa)
	end
	if not spy2.IsDead or SovRax.IsDead then
		spy2.Infiltrate(SovRax)
	end
	if not spy3.IsDead or SovDome.IsDead then
		spy3.Infiltrate(SovDome)
	end
end

SetupTriggers = function()

  Trigger.OnKilled(NukeTruck, function()
		ussr2.MarkFailedObjective(objEscortTruck)
	end)

  Trigger.OnEnteredProximityTrigger(TruckGoal.CenterPosition, WDist.FromCells(2), function(actor, trigger)
		if actor.Type == "truk" and actor.Owner == ussr2 then
			Trigger.RemoveProximityTrigger(trigger)
			actor.Destroy()
			ussr2.MarkCompletedObjective(objEscortTruck)
			if not ussr2.IsObjectiveFailed(objperfect) then
				ussr2.MarkCompletedObjective(objperfect)
			end
			Actor.Create("mslo", true, { Owner = ussr1, Location = NukeSpawn.Location })
			Reinforcements.Reinforce(ussr2, OrangeMCVTeam, { ReinfSpawn.Location, ReinfMove.Location })
		end
	end)

	Trigger.OnDamaged(NukeTruck, function()
		ussr2.MarkFailedObjective(objperfect)
	end)

	Trigger.OnAnyKilled(NuclearPlants, function()
		ussr1.MarkFailedObjective(objDefendBase)
	end)

end

InitObjectives = function()

	enemyobj = allies.AddPrimaryObjective("Deny the Soviets.")
	objEscortTruck = ussr2.AddPrimaryObjective("Escort the Truck with nuclear material to our facility.")
	objperfect = ussr2.AddSecondaryObjective("Prevent the Truck from getting damaged at all.")
  objDefendBase = ussr1.AddPrimaryObjective("Defend the nuclear processing plants.")
	objKillAll = ussr1.AddPrimaryObjective("Eliminate all Allied presence in the sector")
	objKillAll = ussr2.AddPrimaryObjective("Eliminate all Allied presence in the sector")
	
end

WorldLoaded = function()
	allies = Player.GetPlayer("Allies")
  england = Player.GetPlayer("England")
	ussr1 = Player.GetPlayer("USSR1")
  ussr2 = Player.GetPlayer("USSR2")

	InitObjectives()
	ActivateAI()
  SetupTriggers()
	
	spy1.DisguiseAsType("e1", ussr1)
	spy2.DisguiseAsType("e1", ussr1)
	spy3.DisguiseAsType("e1", ussr1)
  
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

  Trigger.AfterDelay(DateTime.Seconds(5), function()
		ParadropAlliedUnits()
		StartShip1.AttackMove(wp23.Location)
		StartShip2.AttackMove(wp23.Location)
		StartShip3.AttackMove(wp23.Location)
	end)

	Trigger.AfterDelay(DateTime.Seconds(6), function() --set to 120
		SpiesGo()
	end)
end