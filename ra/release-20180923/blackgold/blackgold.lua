ParadropWaypoints = { Paradrop1, Paradrop2, Paradrop3 }
ParadropUnitTypes = { "e1", "e1", "e1", "e3", "e1", "e3", "e3" }

AlliedInfantryTypes = { "e1", "e1", "e1", "e1", "e3", "e3",}
AlliedArmorTypes = { "1tnk", "1tnk", "1tnk", "2tnk", "2tnk", "2tnk", "2tnk", "2tnk", "2tnk", "2tnk", "jeep", "jeep", "apc", "ctnk", "arty" }
AlliedAircraftTypes = { "heli" }
AlliedNavalTypes = { "pt", "pt", "pt", "dd", "dd", "dd", "dd", "dd", "ca" }

InvasionTeams = { { "1tnk", "1tnk", "e3", "e3", "e1" }, { "1tnk", "2tnk", "e1", "e1", "e3" }, { "1tnk", "2tnk", "2tnk", "arty", "apc" }, { "jeep", "1tnk", "2tnk", "2tnk", "ctnk" } }
InvasionWays = { { AlliedInvSp2.Location, MainBeach.Location }, { AlliedInvSp1.Location, MainBeach.Location } }

InfAttack = { }
TankAttack = { }
AirAttack = { }
NavalAttack = { }

AlliedAttackPath = { { wp2, wp3, wp4, wp5, wp1, wp6, wp7 }, { wp2, wp8, wp9, wp4, wp5, wp17, wp7 }, { wp10, wp11, wp12, wp13, wp14, wp15, wp16, wp1, wp6, wp7 } }
AlliedNavyPath = { { wp18, wp19, wp20, wp21 }, { wp18, wp22, wp23, wp20, wp21 } }

OrangeMCVTeam = { "3tnk", "3tnk", "mcv", "shok", "shok" }


ProduceInfantry = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(1), DateTime.Seconds(3))
	local toBuild = { Utils.Random(AlliedInfantryTypes) }
  local Path = Utils.Random(AlliedAttackPath)
	allies.Build(toBuild, function(unit)
		InfAttack[#InfAttack + 1] = unit[1]

		if #InfAttack >= 6 then
			SendUnits(InfAttack, Path)
			InfAttack = { }
			Trigger.AfterDelay(DateTime.Seconds(30), ProduceInfantry)
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
			Trigger.AfterDelay(DateTime.Seconds(20), ProduceTanks)
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
  local Path = Utils.Random(AlliedNavyPath)
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

SendAlliedInvasion = function()
  local units = Utils.Random(InvasionTeams)
	local way = Utils.Random(InvasionWays)
  local invasionteam = Reinforcements.ReinforceWithTransport (allies, "lst", units, way, { AlliedInvSp2.Location})[2]
  Utils.Do(invasionteam, function(a)
    Trigger.OnAddedToWorld(a, function()
      a.AttackMove(wp7.Location)
      a.Hunt()
    end)
  end)

  Trigger.AfterDelay(DateTime.Minutes(6), SendAlliedInvasion)
end

--[[ParadropAlliedUnits = function()
	local lz = Utils.Random(ParadropWaypoints).Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = allies, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = allies })
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	Trigger.AfterDelay(DateTime.Seconds(160), ParadropAlliedUnits)
end]]


SendSovietReinforcements = function()

end

SetupTriggers = function()

	Trigger.OnKilled(SovietSpy, function()
		ussr1.MarkFailedObjective(objSpyTech)
	end)

  Trigger.OnKilled(RealDome, function()
		ussr1.MarkFailedObjective(objFindEinstein)
	end)

	Trigger.OnInfiltrated(StolenTechCentre, function()
		ussr1.MarkCompletedObjective(objSpyTech)
		
		SendSovietReinforcements()
		ParadropVolkov()
		
		objDestroyBase = ussr1.AddPrimaryObjective("Destroy or capture the rest of the Allied base")
		objFindEinstein = ussr1.AddPrimaryObjective("Find the location of Einstein's lab\nby capturing the Allied radar dome.")
		
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

end

InitObjectives = function()

	enemyobj = allies.AddPrimaryObjective("Deny the Soviets.")
	
  objSpyTech = ussr1.AddPrimaryObjective("Get our spy into our captured tech centre.")
	--objKillAll = ussr1.AddPrimaryObjective("Eliminate all Allied presence in the sector.")
	
end


StartDogPatrol = function()
	
end

WorldLoaded = function()
	allies = Player.GetPlayer("Allies")
	greece = Player.GetPlayer("Greece")
  einstein = Player.GetPlayer("Germany")
	ussr1 = Player.GetPlayer("USSR")
  --ussr2 = Player.GetPlayer("USSR2")

	InitObjectives()
	--ActivateAI()
  SetupTriggers()
	
	SovietSpy.DisguiseAsType("e1", greece)
  
  Trigger.OnObjectiveAdded(ussr1, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
  end)
    
  --[[Trigger.OnObjectiveAdded(ussr2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
  end)]]

  Trigger.OnObjectiveCompleted(ussr1, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
  end)
    
  --[[Trigger.OnObjectiveCompleted(ussr2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
  end)]]

  Trigger.OnObjectiveFailed(ussr1, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
  end)
    
  --[[Trigger.OnObjectiveFailed(ussr2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
  end)]]

  Trigger.OnPlayerWon(ussr1, function()
    Media.PlaySpeechNotification(ussr1, "MissionAccomplished")
  end)
    
  --[[Trigger.OnPlayerWon(ussr2, function()
    Media.PlaySpeechNotification(ussr2, "MissionAccomplished")
  end)]]

  Trigger.OnPlayerLost(ussr1, function()
    Media.PlaySpeechNotification(ussr1, "MissionFailed")
  end)
    
  --[[Trigger.OnPlayerLost(ussr2, function()
    Media.PlaySpeechNotification(ussr2, "MissionFailed")
  end)]]

  Trigger.AfterDelay(DateTime.Seconds(5), function()
		StartDogPatrol()
	end)
end