PlayerStartUnits = { "1tnk", "1tnk", "2tnk", "arty" }
MCVTeam = { "2tnk", "2tnk", "2tnk", "2tnk", "mcv" }

ParadropUnitTypes = { "e1", "e1", "e1", "e1", "e2", "e4" }
ParadropWaypoints = { att9, att7 }

SovietInfantryTypes = { "e1", "e1", "e1", "e1", "e1", "e1", "e1", "e1", "e1", "e2", "e2", "e4", "e4" }
SovietArmorTypes = { "ftrk", "3tnk", "3tnk", "3tnk", "3tnk", "3tnk", "3tnk", "3tnk", "3tnk", "3tnk", "v2rl", "ttnk" }
SovietAircraftTypes = { "hind", "hind", "hind", "yak", "yak", "yak", "mig" }

InvasionTeams = { { "3tnk", "e1", "e1", "e1", "e2" }, { "3tnk", "e1", "e4", "e1", "e1" }, { "3tnk", "e1", "e4", "e1", "e1" }, { "e2", "e1", "e4", "e1", "e1" }, { "e4", "3tnk", "e1", "e1", "e1" }, { "ttnk", "e1", "e4", "ftrk", "e1" } }

SovietAttackPath = { { att1, att2, att3, att4, att5, att6, att7, att8, att9 }, { att1, att2, patrol4, patrol3, att3, att4, att5, att6, att7, att8, att9 } }

BarricadePatrol = { barrpatrol1, barrpatrol2, barrpatrol3 }
VillagePatrol = { villpatrol1, villpatrol2, villpatrol3, villpatrol4, villpatrol5, villpatrol6 }
SovietBarricade = { barrtank1, barrtank2, barrtank3, barrtank4, barrflame1, barrflame2, barrrax, barrpp1, barrpp2, barrpp3, barrsam }
EnglandOutpost = { engpostrax, engpostgun, engpostpbox, engpostpp, engpostflak }

BarricadePatrolPath = { patrol1.Location, att5.Location, att6.Location }
VillagePatrolPath = { att3.Location, patrol3.Location, patrol4.Location, att2.Location }

InfAttack = { }
TankAttack = { }
AirAttack = { }


Tick = function()
	if ussr.HasNoRequiredUnits() and badguy.HasNoRequiredUnits() then
		if not allies.IsObjectiveFailed(objSaveEngland) then
			allies.MarkCompletedObjective(objSaveEngland)
		end
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			allies.MarkCompletedObjective(objKillAll)
		end)
	end
end

SendPatrols = function()
	Utils.Do(BarricadePatrol, function(patrolguys)
    patrolguys.Patrol(BarricadePatrolPath, true, 20)
  end)

	Utils.Do(VillagePatrol, function(patrolguys)
    patrolguys.Patrol(VillagePatrolPath, true, 20)
  end)
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
			Trigger.AfterDelay(DateTime.Seconds(60), ProduceInfantry)
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

		if #TankAttack >= 2 then
			SendUnits(TankAttack, Path)
			TankAttack = { }
			Trigger.AfterDelay(DateTime.Seconds(140), ProduceTanks)
		else
			Trigger.AfterDelay(delay, ProduceTanks)
		end
	end)
end

ProduceAircraft = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(6))
	local toBuild = { Utils.Random(SovietAircraftTypes) }
	ussr.Build(toBuild, function(unit)
		AirAttack[#AirAttack + 1] = unit[1]

		if #AirAttack >= 1 then
			SendAircraft(AirAttack)
			AirAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(3), ProduceAircraft)
		else
			Trigger.AfterDelay(delay, ProduceAircraft)
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

ParadropSovietUnits = function()
	local lz = Utils.Random(ParadropWaypoints).Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = ussr })
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	Trigger.AfterDelay(DateTime.Seconds(300), ParadropSovietUnits)
end

SendSovietInvasion = function()
  local units = Utils.Random(InvasionTeams)
  local invasionteam = Reinforcements.ReinforceWithTransport (ussr, "lst", units, { sovboatspawn.Location, sovboatunload.Location}, { sovboatspawn.Location})[2]
  Utils.Do(invasionteam, function(a)
    Trigger.OnAddedToWorld(a, function()
      a.AttackMove(att9.Location)
      a.Hunt()
    end)
  end)

  Trigger.AfterDelay(DateTime.Minutes(7), SendSovietInvasion)
end

ActivateAI = function()

  ussr.Cash = 100000
	
	ProduceInfantry()
	
	Trigger.AfterDelay(DateTime.Seconds(200), function()
    ParadropSovietUnits()
		SendSovietInvasion()
	end)
end

SetupTriggers = function()
  
	Trigger.OnAllKilledOrCaptured(SovietBarricade, function()
		allies.MarkCompletedObjective(objClearWay)
		Reinforcements.ReinforceWithTransport (allies, "lst", MCVTeam, { boatspawn.Location, boatunload.Location}, { boatspawn.Location})
		Media.DisplayMessage("Commander, MCV reinforcements have arrived in the south now that the way is free.")
		ProduceAircraft()
		ProduceTanks()
	end)

	Trigger.OnAllKilled(EnglandOutpost, function()
		allies.MarkFailedObjective(objSaveEngland)
	end)

end

InitObjectives = function()
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	ussrObj = ussr.AddPrimaryObjective("Make a Hoola-Hoop.")
	objClearWay = allies.AddPrimaryObjective("Destroy the Soviet barricade\non the eastern river bank.")
  objKillAll = allies.AddPrimaryObjective("Take the western river bank and\nclear the sector of all Soviet presence.")
	objSaveEngland = allies.AddSecondaryObjective("Prevent the destruction of our southern outpost.")

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
	allies = Player.GetPlayer("Greece")
	england = Player.GetPlayer("England")
	ussr = Player.GetPlayer("USSR")
  badguy = Player.GetPlayer("BadGuy")
  

	InitObjectives()
  SetupTriggers()
	SendPatrols()
  
  Reinforcements.Reinforce(allies, PlayerStartUnits, { alliesspawn.Location, alliesmove.Location })
  
  ActivateAI()
	
  Trigger.AfterDelay(DateTime.Minutes(10), SendSovietInvasion)
  
	start1.AttackMove(att9.Location)
	start2.AttackMove(att9.Location)
	start3.AttackMove(att9.Location)
	start4.AttackMove(att9.Location)
end