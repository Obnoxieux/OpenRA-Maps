--Evacuation

AlliedMCVTeam = { "mcv", "jeep", "jeep", "e1", "e1", "e1", "e1", "e3", "e3", "e3" }
CivsSouthWest = { "c1", "c1", "c1" }
CivsWest = { "c2", "c2", "c2" }
CivsMiddle = { "c3", "c3", "c3" }
CivsEast = { "c4", "c4", "c4" }
SovietVillageAttackers = { "3tnk", "3tnk", "e4", "e4", "e4", "e4", "e4" }
ParadropUnitTypes = { "e1", "e1", "e1", "e2", "e4", "e4" }
SubPens = { SubPen1, SubPen2 }
ParadropWaypoints = { AlliedBase, AttackRight2, AttackWest6 }

SovietInfantryTypes = { "e1", "e1", "e1", "e2", "e2", "e4", "e4"}
SovietArmorTypes = { "3tnk", "3tnk", "3tnk", "3tnk", "3tnk", "3tnk", "3tnk", "v2rl", "v2rl", "v2rl", "4tnk" }
SovietHeliType = { "hind" }
SovietSubType = { "ss" }

TownEastCheck = false
TownWestCheck = false
TownMiddleCheck = false
TownSouthWestCheck = false

InfAttack = { }
TankAttack = { }
HeliAttack = { }
SubAttack = { }

SovietAttackPath = { { AttackCentre1, AttackCentre2, AttackCentre3, AlliedBase }, { AttackCentre1, AttackRight1, AttackCentre3, AttackRight2, AlliedBase }, { AttackWest1, AttackWest2, AttackWest3, AttackWest4, AttackWest5, AttackWest6, AttackWest7, AlliedBase } }
AirAttack = { AlliedBase }
SubPath = { SubAttack1, SubAttack2, SubAttack3, SubAttack4, SubAttack5 }

------------------------------------------------------------------------------------------------------------------------------------------------

SendExtractionHelicopter = function()
	heli = Reinforcements.ReinforceWithTransport(england, "tran", nil, { InsertionEntry.Location, waypoint1.Location })[1]
  heli2 = Reinforcements.ReinforceWithTransport(england, "tran", nil, { InsertionEntry.Location, waypoint55.Location })[1]
  heli3 = Reinforcements.ReinforceWithTransport(england, "tran", nil, { InsertionEntry.Location, waypoint0.Location })[1]
  Trigger.AfterDelay(DateTime.Seconds(18), function()
    allies.MarkCompletedObjective(objEvacCivs)
  end)
end

ParadropSovietUnits = function()
	local lz = Utils.Random(ParadropWaypoints).Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = ussr })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	Trigger.AfterDelay(DateTime.Seconds(228), ParadropSovietUnits)
end

ProduceInfantry = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(6))
	local toBuild = { Utils.Random(SovietInfantryTypes) }
  local Path = Utils.Random(SovietAttackPath)
	ussr.Build(toBuild, function(unit)
		InfAttack[#InfAttack + 1] = unit[1]

		if #InfAttack >= 6 then
			SendUnits(InfAttack, Path)
			InfAttack = { }
			Trigger.AfterDelay(DateTime.Seconds(38), ProduceInfantry)
		else
			Trigger.AfterDelay(delay, ProduceInfantry)
		end
	end)
end

ProduceTanks = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(6))
	local toBuild = { Utils.Random(SovietArmorTypes) }
  local Path = Utils.Random(SovietAttackPath)
	ussr.Build(toBuild, function(unit)
		TankAttack[#TankAttack + 1] = unit[1]

		if #TankAttack >= 3 then
			SendUnits(TankAttack, Path)
			TankAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(1), ProduceTanks)
		else
			Trigger.AfterDelay(delay, ProduceTanks)
		end
	end)
end

ProduceAircraft = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(6))
	local toBuild = { Utils.Random(SovietHeliType) }
	ussr.Build(toBuild, function(unit)
		HeliAttack[#HeliAttack + 1] = unit[1]

		if #HeliAttack >= 1 then
			SendUnits(HeliAttack, AirAttack)
			HeliAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(2), ProduceAircraft)
		else
			Trigger.AfterDelay(delay, ProduceAircraft)
		end
	end)
end

ProduceSubs = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(6))
	local toBuild = { Utils.Random(SovietSubType) }
	ussr.Build(toBuild, function(unit)
		SubAttack[#SubAttack + 1] = unit[1]

		if #SubAttack >= 1 then
			SendUnits(SubAttack, SubPath)
			SubAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(9), ProduceSubs)
		else
			Trigger.AfterDelay(delay, ProduceSubs)
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

ActivateAI = function()

  ussr.Cash = 100000
	Trigger.AfterDelay(DateTime.Seconds(200), function()
		ProduceAircraft()
		ProduceTanks()
    ProduceInfantry()
    ProduceSubs()
    ParadropSovietUnits()
	end)
end

SendSovietParatroopersVillage = function()
	local lz = VillageEast.Location
	local start = Map.CenterOfCell(waypoint34.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = ussr })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

SetupTriggers = function()
  
  --triggers for civilian towns
  
  Trigger.OnEnteredProximityTrigger(ChurchEast.CenterPosition, WDist.FromCells(2), function(actor, trigger)
		if actor.Owner == allies then
			TownEastCheck = true
			Trigger.RemoveProximityTrigger(trigger)
      easterncivs = Reinforcements.Reinforce(allies, CivsEast, { ChurchEast.Location, VillageEast.Location })
      Actor.Create("flare", true, { Owner = england, Location = VillageEast.Location })
			Trigger.OnAllKilled(easterncivs, function()
				allies.MarkFailedObjective(objEvacCivs)
			end)
      Trigger.AfterDelay(DateTime.Seconds(75), function()
        SendSovietParatroopersVillage()
      end)
		end
	end)

  Trigger.OnEnteredProximityTrigger(ChurchMiddle.CenterPosition, WDist.FromCells(2), function(actor, trigger2)
		if actor.Owner == allies then
			TownMiddleCheck = true
			Trigger.RemoveProximityTrigger(trigger2)
      middlecivs = Reinforcements.Reinforce(allies, CivsMiddle, { ChurchMiddle.Location, VillageMiddle.Location })
      Actor.Create("flare", true, { Owner = england, Location = VillageMiddle.Location })
			Trigger.OnAllKilled(middlecivs, function()
				allies.MarkFailedObjective(objEvacCivs)
			end)
		end
	end)

  Trigger.OnEnteredProximityTrigger(ChurchSouthwest.CenterPosition, WDist.FromCells(2), function(actor, trigger3)
		if actor.Owner == allies then
			TownSouthWestCheck = true
			Trigger.RemoveProximityTrigger(trigger3)
      southwestcivs = Reinforcements.Reinforce(allies, CivsSouthWest, { ChurchSouthwest.Location, VillageSouthwest.Location })
      Actor.Create("flare", true, { Owner = england, Location = VillageSouthwest.Location })
			Trigger.OnAllKilled(southwestcivs, function()
				allies.MarkFailedObjective(objEvacCivs)
			end)
      Trigger.AfterDelay(DateTime.Seconds(70), function()
        Reinforcements.Reinforce(ussr, SovietVillageAttackers, { SovietReinforcementsSpawn.Location, VillageSouthwest.Location })
      end)
		end
	end)

  Trigger.OnEnteredProximityTrigger(ChurchNorthwest.CenterPosition, WDist.FromCells(2), function(actor, trigger4)
		if actor.Owner == allies then
			TownWestCheck = true
			Trigger.RemoveProximityTrigger(trigger4)
      westcivs = Reinforcements.Reinforce(allies, CivsWest, { ChurchNorthwest.Location, VillageNorthwest.Location })
      Actor.Create("flare", true, { Owner = england, Location = VillageNorthwest.Location })
			Trigger.OnAllKilled(westcivs, function()
				allies.MarkFailedObjective(objEvacCivs)
			end)
      Trigger.AfterDelay(DateTime.Seconds(80), function()
        Reinforcements.Reinforce(ussr, SovietVillageAttackers, { SovietReinforcementsSpawnNorth.Location, VillageNorthwest.Location })
      end)
		end
	end)

--secondary objective

  Trigger.OnAllKilledOrCaptured(SubPens, function()
      allies.MarkCompletedObjective(objKillNavy)
  end)

--send the extraction helicopters and start winning sequence

  Trigger.OnEnteredProximityTrigger(waypoint52.CenterPosition, WDist.FromCells(7), function(actor, trigger5)
		if actor.Type == "c1" or actor.Type == "c2" or actor.Type == "c3" or actor.Type == "c4" then
			Trigger.RemoveProximityTrigger(trigger5)
      Actor.Create("flare", true, { Owner = england, Location = waypoint5.Location })
      Actor.Create("flare", true, { Owner = england, Location = waypoint53.Location })
      SendExtractionHelicopter()
		end
	end)

end

InitObjectives = function()
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	ussrObj = ussr.AddPrimaryObjective("Make a Hoola-Hoop.")
	objEvacCivs = allies.AddPrimaryObjective("Evacuate civilians from all four villages.")
  objKillNavy = allies.AddSecondaryObjective("Destroy the Soviet naval capabilities.")

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
  england = Player.GetPlayer("England")
	ussr = Player.GetPlayer("USSR")
  
  Camera.Position = DefaultCameraPosition.CenterPosition

  Reinforcements.Reinforce(allies, AlliedMCVTeam, { AlliedReinfSpawn.Location, AlliedBase.Location })
  ActivateAI()
	InitObjectives()
  SetupTriggers()
end