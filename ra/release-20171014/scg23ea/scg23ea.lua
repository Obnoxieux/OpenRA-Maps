--Personal War

ParadropUnitTypes = { "e1", "e1", "e1", "e2", "e2", "e4", "e4" }
SovietPatrolPath = { Patrol1.Location, Patrol2.Location, Patrol3.Location, Patrol4.Location }
SovietPatrolTeam = { PatrolMammoth, gren1, gren2, gren3, gren4, gren5 }
OutpostAttackers = { "3tnk", "3tnk", "3tnk", "3tnk", "4tnk", "4tnk", "v2rl", "v2rl", "e4", "e1", "e1", "e2", "e2", "e4" }
SecondWaveTeam = { "3tnk", "3tnk", "e1", "e1", "e1", "e2", "e2", "e4" }
AlliedTankReinforcements = { "1tnk", "1tnk", "2tnk", "2tnk", "2tnk" }
LastReinforcements = { "1tnk", "arty", "2tnk", "2tnk", "2tnk" }
AlliedParadropUnitTypes = { "e1", "e1", "e1", "e1", "e1", "e1", "e3", "e3" }
ExtractionPath = { InsertionEntry.Location, ExtractionPoint.Location }

SendExtractionHelicopter = function()
	heli = Reinforcements.ReinforceWithTransport(allies, "tran", nil, ExtractionPath)[1]
	if not Stavros.IsDead then
		Trigger.OnRemovedFromWorld(Stavros, EvacuateHelicopter)
	end
	--Trigger.OnKilled(heli, RescueFailed)
	Trigger.OnRemovedFromWorld(heli, HelicopterGone)
end

EvacuateHelicopter = function()
	if heli.HasPassengers then
		heli.Move(InsertionEntry.Location)
		Trigger.OnIdle(heli, heli.Destroy)
	end
end

HelicopterGone = function()
	if not heli.IsDead then
		Media.PlaySpeechNotification(allies, "TargetRescued")
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			allies.MarkCompletedObjective(objEvacStavros)
		end)
	end
end

SendPatrol = function()
  Utils.Do(SovietPatrolTeam, function(patrolguys)
    patrolguys.Patrol(SovietPatrolPath, true, 20)
  end)
end

MoveTruck = function(truck)
  truck.Move(TruckGo.Location)
end

MoveMammoths = function(mammy)
  mammy.Move(MammysGo.Location)
end

SendAlliedReinforcements1 = function()
  Reinforcements.ReinforceWithTransport (allies, "lst", AlliedTankReinforcements, { BoatSpawn.Location, BoatUnload.Location}, { BoatSpawn.Location})
end

SendSovietParatroopers1 = function()
	local lz = SovParadropBase1.Location
	local start = Map.CenterOfCell(SovietReinforcementsSpawn.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = ussr })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

SendSovietParatroopers2 = function()
	local lz = SovParadropBase2.Location
	local start = Map.CenterOfCell(SovietReinforcementsSpawn.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = ussr })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

SendSovietParatroopersVillage = function()
	local lz = SovParadropVillage.Location
	local start = Map.CenterOfCell(SovietReinforcementsSpawn.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = ussr })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

SendAlliedParatroopersTesla = function()
	local lz = ParadropPoint.Location
	local start = Map.CenterOfCell(ParadropSpawn.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = allies, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(AlliedParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = allies })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

OutpostAttack = function()
  Reinforcements.Reinforce(ussr, OutpostAttackers, { SovietReinforcementsSpawn.Location, SovietsMove.Location })
  Trigger.AfterDelay(DateTime.Seconds(100), function()
    Reinforcements.Reinforce(ussr, SecondWaveTeam, { SovietReinforcementsSpawn.Location, SecondWaveMove.Location })
  end)
end

SetupTriggers = function()
  
  Trigger.OnKilled(Stavros, function()
      allies.MarkFailedObjective(objEvacStavros)
  end)
  
  Trigger.OnEnteredProximityTrigger(SovietAttackTrigger.CenterPosition, WDist.FromCells(4), function(actor, trigger)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(trigger)
			OutpostAttack()
      SendSovietParatroopers1()
      SendSovietParatroopers2()
		end
	end)

  Trigger.OnEnteredProximityTrigger(SecondWaveMove.CenterPosition, WDist.FromCells(7), function(actor, trigger2)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(trigger2)
      SendAlliedReinforcements1()
      Media.PlaySpeechNotification(allies, "AlliedReinforcementsArrived")
      Actor.Create("flare", true, { Owner = allies, Location = Flare2.Location })
      Actor.Create("camera", true, { Owner = allies, Location = Flare2.Location })
      SendExtractionHelicopter()
		end
	end)

  Trigger.OnEnteredProximityTrigger(SovParadropVillage.CenterPosition, WDist.FromCells(3), function(actor, trigger3)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(trigger3)
      SendSovietParatroopersVillage()
		end
	end)

  Trigger.OnEnteredProximityTrigger(ParadropPoint.CenterPosition, WDist.FromCells(3), function(actor, trigger4)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(trigger4)
      SendAlliedParatroopersTesla()
		end
	end)

  Trigger.OnEnteredProximityTrigger(MammysGo.CenterPosition, WDist.FromCells(3), function(actor, trigger5)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(trigger5)
      MoveTruck(CowardTruck)
      MoveMammoths(BridgeMammoth1)
      MoveMammoths(BridgeMammoth2)
		end
	end)

  Trigger.OnEnteredProximityTrigger(LastReinfTrigger.CenterPosition, WDist.FromCells(9), function(actor, trigger6)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(trigger6)
      Reinforcements.ReinforceWithTransport (allies, "lst", LastReinforcements, { BoatSpawn.Location, LastReinforcementsUnload.Location}, { BoatSpawn.Location})
      Media.PlaySpeechNotification(allies, "AlliedReinforcementsArrived")
		end
	end)

end

InitObjectives = function()
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	ussrObj = ussr.AddPrimaryObjective("Kill Stavros.")
	objEvacStavros = allies.AddPrimaryObjective("Evacuate Stavros from the sector.")

	Trigger.OnObjectiveCompleted(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerLost(allies, function()
		Media.PlaySpeechNotification(allies, "Lose")
	end)
	Trigger.OnPlayerWon(allies, function()
		Media.PlaySpeechNotification(allies, "Win")
	end)
end

WorldLoaded = function()
	allies = Player.GetPlayer("Allies")
	ussr = Player.GetPlayer("USSR")
  badguy = Player.GetPlayer("BadGuy")

  SendPatrol()
	InitObjectives()
  SetupTriggers()
end