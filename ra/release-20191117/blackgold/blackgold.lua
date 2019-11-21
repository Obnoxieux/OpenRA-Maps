ParadropWaypoints = { wp8, SovBaseCam, Actor543 }
ParadropUnitTypes = { "e1", "e1", "e1", "e3", "e1", "e3", "e3" }

DogPatrolPath = { Patrol1.Location, Patrol2.Location, Patrol3.Location, Patrol4.Location, Patrol5.Location }
DogPatrolTeam = { PatrolRifle, PatrolDog1, PatrolDog2 }

GreeceBaseBuidings = { GreeceKenn, GreeceProc, GreeceWaFa, GreeceDome, GreeceRax, GreeceFix, GreeceHpad1, GreeceHpad2, GreecePP1, GreecePP2, GreecePP3, GreecePP4, GreecePP5, GreecePP6, GreecePP7, GreeceCyard, GreeceSyard }

AlliedInfantryTypes = { "e1", "e1", "e1", "e1", "e3", "e3" }
AlliedArmorTypes = { "1tnk", "1tnk", "1tnk", "2tnk", "2tnk", "2tnk", "2tnk", "2tnk", "2tnk", "2tnk", "jeep", "jeep", "apc", "ctnk", "arty" }
AlliedAircraftTypes = { "mh60", "mh60", "heli" }
AlliedNavalTypes = { "pt", "pt", "pt", "dd", "dd", "dd", "dd", "dd", "ca" }

EinsteinLabDefenders = { "ctnk", "ctnk", "ctnk", "ctnk" }

InvasionTeams = { { "1tnk", "jeep", "e3", "e3", "e1" }, { "1tnk", "2tnk", "e1", "e1", "e3" }, { "1tnk", "2tnk", "2tnk", "arty", "apc" }, { "jeep", "1tnk", "2tnk", "2tnk", "ctnk" } }
InvasionWays = { { AlliesBoatSpawn.Location, AlliesBoatUnload1.Location }, { AlliesBoatSpawn.Location, AlliesBoatUnload2.Location } }

InfAttack = { }
TankAttack = { }
AirAttack = { }
NavalAttack = { }

AlliedAttackPath = { { wp1, wp2, wp3, wp4, wp5, wp6, wp7, wp8 }, { wp9, wp10, wp11, wp12, wp13, wp14, wp8 } }
AlliedNavyPath = { wp16, wp17, wp18 }

VolkovTeam = { "gnrl" }

SovietReinforcementsSea = { "3tnk", "3tnk", "4tnk", "4tnk", "v2rl" }
SovietReinforcementsMCV = { "3tnk", "3tnk", "4tnk", "4tnk", "mcv" }
SovietReinforcementsLand = { "qtnk", "qtnk", "dtrk", "dtrk", "shok", "mnly", "shok", "e1", "e1", "e1", "e1", "e4", "e4", "e6", "e6", "e6", "e6" }

Domf1Kill = { CPos.New(110, 103), CPos.New(110, 104), CPos.New(110, 105), CPos.New(110, 106), CPos.New(111, 104), CPos.New(111, 105), CPos.New(111, 106) }
Domf2Kill = { CPos.New(108, 63), CPos.New(109, 63), CPos.New(110, 63), CPos.New(108, 62), CPos.New(109, 62), CPos.New(110, 62) }


Tick = function()
	if allies.HasNoRequiredUnits() and greece.HasNoRequiredUnits() then
		ussr1.MarkCompletedObjective(objKillAll)
		--ussr2.MarkCompletedObjective(objKillAll2)
	end
end

--lab last line of defence

Trigger.OnEnteredProximityTrigger(LabAlertSpawnMove.CenterPosition, WDist.FromCells(3), function(actor, triggerlab)
	if actor.Owner == ussr1 and actor.Type == "gnrl" then
		Trigger.RemoveProximityTrigger(triggerlab)
		local lastline1 = Reinforcements.Reinforce(einstein, EinsteinLabDefenders, { LabAlertSpawnN.Location, LabAlertSpawnMove.Location } )
		Utils.Do(lastline1, function(a)
			Trigger.OnAddedToWorld(a, function()
				a.Hunt()
			end)
		end)
		local lastline2 = Reinforcements.Reinforce(einstein, EinsteinLabDefenders, { LabAlertSpawnW.Location, LabAlertSpawnMove.Location } )
		Utils.Do(lastline2, function(a)
			Trigger.OnAddedToWorld(a, function()
				a.Hunt()
			end)
		end)
	end
end)


ProduceInfantry = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(1), DateTime.Seconds(3))
	local toBuild = { Utils.Random(AlliedInfantryTypes) }
  local Path = Utils.Random(AlliedAttackPath)
	allies.Build(toBuild, function(unit)
		InfAttack[#InfAttack + 1] = unit[1]

		if #InfAttack >= 6 then
			SendUnits(InfAttack, Path)
			InfAttack = { }
			Trigger.AfterDelay(DateTime.Seconds(75), ProduceInfantry)
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
			Trigger.AfterDelay(DateTime.Seconds(80), ProduceTanks)
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
	allies.Build(toBuild, function(unit)
		NavalAttack[#NavalAttack + 1] = unit[1]

		if #NavalAttack >= 2 then
			SendUnits(NavalAttack, AlliedNavyPath)
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

	Utils.Do(Map.NamedActors, function(actor)
		if actor.Owner == allies and actor.HasProperty("StartBuildingRepairs") then
			Trigger.OnDamaged(actor, function(building)
				if building.Owner == allies and building.Health < 3/4 * building.MaxHealth then
					building.StartBuildingRepairs()
				end
			end)
		end
	end)

  allies.Cash = 100000

	Trigger.AfterDelay(DateTime.Seconds(25), function()
		ProduceInfantry()
		ProduceTanks()
		ProduceAircraft()
		ProduceNavy()
	end)

	Trigger.AfterDelay(DateTime.Minutes(4), function()
		SendAlliedInvasion()
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
	Trigger.AfterDelay(DateTime.Seconds(240), ParadropAlliedUnits)
end


ParadropVolkov = function()
	local lz = VolkovLZ.Location
	local start = Map.CenterOfCell(SovietReinfSeaSpawn.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr1, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(VolkovTeam, function(type)
		local a = Actor.Create(type, false, { Owner = ussr1 })
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	--todo: loss script when killed
end

SendAlliedInvasion = function()
  local units = Utils.Random(InvasionTeams)
	local way = Utils.Random(InvasionWays)
  local invasionteam = Reinforcements.ReinforceWithTransport (allies, "lst", units, way, { AlliesBoatSpawn.Location})[2]
  Utils.Do(invasionteam, function(a)
    Trigger.OnAddedToWorld(a, function()
      a.Hunt()
    end)
  end)
  Trigger.AfterDelay(DateTime.Minutes(7), SendAlliedInvasion)
end


SendSovietReinforcements = function()
	Reinforcements.ReinforceWithTransport (ussr1, "lst", SovietReinforcementsSea, { SovietReinfSeaSpawn.Location, SovietReinfSeaUnload.Location})
	
	--das hier wird Spieler 2
	Reinforcements.Reinforce(ussr1, SovietReinforcementsLand, { SovietReinfLandSpawn.Location, SovietReinfLandMove.Location })
end

SetupTriggers = function()

	--[[Trigger.OnKilled(SovietSpy, function()
		ussr1.MarkFailedObjective(objSpyTech)
	end)]]

	Trigger.OnKilled(StolenTechCentre, function()
		if not ussr1.IsObjectiveCompleted(objSpyTech) then
			ussr1.MarkFailedObjective(objSpyTech)
		end
	end)

	Trigger.OnAllKilledOrCaptured(GreeceBaseBuidings, function()
		ussr1.MarkCompletedObjective(objDestroyBase)
		Reinforcements.ReinforceWithTransport (ussr1, "lst", SovietReinforcementsMCV, { SovietReinfSeaSpawn.Location, SovietReinfSeaUnload.Location})
		Media.DisplayMessage("Comrade General, advise to build our base to the West as there is more ore to be found there.")
		Actor.Create("camera", true, { Owner = ussr1, Location = SovBaseCam.Location })
		
		Trigger.AfterDelay(DateTime.Minutes(7), function()
			ActivateAI()
			ParadropAlliedUnits()
		end)

	end)

  Trigger.OnKilled(RealDome, function()
		ussr1.MarkFailedObjective(objFindEinstein)
	end)

	Trigger.OnCapture(RealDome, function()
		ussr1.MarkCompletedObjective(objFindEinstein)
		Actor.Create("camera", true, { Owner = ussr1, Location = LabCam.Location })
		
		if not LabGap1.IsDead then 
			LabGap1.Kill()
		end
		if not LabGap2.IsDead then 
			LabGap2.Kill()
		end
	end)

	Trigger.OnKilled(EinsteinLab, function()
		ussr1.MarkFailedObjective(objInfiltrateLab)
	end)

	Trigger.OnInfiltrated(StolenTechCentre, function()
		ussr1.MarkCompletedObjective(objSpyTech)
		
		Trigger.AfterDelay(DateTime.Seconds(2), function()
			SendSovietReinforcements()
			ParadropVolkov()
		end)
		
		--Actor.Create("camera", true, { Owner = ussr1, Location = CamDomf1.Location })
	end)
	
	--kill off the fake domes
	
  Trigger.OnEnteredFootprint(Domf1Kill, function(actor, trigger)
		if actor.Owner == ussr1 then
			Trigger.RemoveFootprintTrigger(trigger)
			Media.DisplayMessage("This Radar Dome was just a decoy.")
			if not FakeDome1.IsDead then
				FakeDome1.Kill()
			end
		end
	end)

	Trigger.OnEnteredFootprint(Domf2Kill, function(actor, trigger2)
		if actor.Owner == ussr1 then
			Trigger.RemoveFootprintTrigger(trigger2)
			Media.DisplayMessage("This Radar Dome was just a decoy.")
			if not FakeDome2.IsDead then
				FakeDome2.Kill()
			end
		end
	end)

	--ending the mission
	Trigger.OnEnteredProximityTrigger(LabCam.CenterPosition, WDist.FromCells(1), function(actor, trigger3)
		if actor.Owner == ussr1 and actor.Type == "gnrl" then
			Trigger.RemoveProximityTrigger(trigger3)
			ussr1.MarkCompletedObjective(objInfiltrateLab)
			ussr1.MarkCompletedObjective(objVolkovSurvival)
			actor.Destroy()
		end
	end)

end

InitObjectives = function()

	enemyobj = allies.AddPrimaryObjective("Deny the Soviets.")
  objSpyTech = ussr1.AddPrimaryObjective("Get our spy into our captured tech centre.")
	objDestroyBase = ussr1.AddPrimaryObjective("Destroy or capture the rest of our former tech base.")
	objVolkovSurvival = ussr1.AddPrimaryObjective("Volkov must survive.")
	objFindEinstein = ussr1.AddPrimaryObjective("Find the location of Einstein's lab\nby capturing the Allied radar dome.")
	objInfiltrateLab = ussr1.AddPrimaryObjective("Get Volkov into Einstein's lab to eliminate him.")
	objKillAll = ussr1.AddSecondaryObjective("Finish off the Allied forces.")
	
end


StartDogPatrol = function()
	Utils.Do(DogPatrolTeam, function(patrolguys)
    patrolguys.Patrol(DogPatrolPath, true, 20)
  end)
end

WorldLoaded = function()
	allies = Player.GetPlayer("GoodGuy")
	greece = Player.GetPlayer("Greece")
  einstein = Player.GetPlayer("France")
	ussr1 = Player.GetPlayer("USSR")
  --ussr2 = Player.GetPlayer("USSR2")

	InitObjectives()
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
