--Controlled Burn

PowerPlantsBadGuy = { PowerPlant1, PowerPlant2, PowerPlant3, PowerPlant4, PowerPlant5 }
MCVReinforcements = { "1tnk", "1tnk", "mcv", "e1", "e1", "e1", "e3", "e3", "e3" }
SarinPlants = { SarinLab1, SarinLab2, SarinLab3, SarinLab4, SarinLab5 }

ParadropWaypoints = { AlliedBase, AttackSneakOre, waypoint53 }
ParadropUnitTypes = { "e1", "e1", "e1", "e2", "e4", "shok" }

SovietInfantryTypes = { "e1", "e1", "e1", "e1", "e1", "e1", "e2", "e2", "e4", "e4", "shok" }
SovietArmorTypes = { "3tnk", "3tnk", "3tnk", "3tnk", "v2rl", "4tnk", "ttnk" }
SovietAircraftTypes = { "hind", "hind", "yak", "yak", "mig" }

InfAttack = { }
TankAttack = { }
AirAttack = { }

SovietAttackPath = { { AttackCentre1, AttackCentre2, AttackCentre3, AlliedBase }, { AttackSouth1, AttackSouth2, AttackSouth3, AttackSouth4, AlliedBase }, { AttackNorth1, AttackNorth2, AttackNorth3, AttackNorth4, AttackNorth5, AlliedBase }, { AttackNorth1, AttackNorth2, AttackNorth3, AttackSneakOre, AttackNorth5, AlliedBase } }
AirAttackPath = { AlliedBase }

Tick = function()
	if ussr.HasNoRequiredUnits() and badguy.HasNoRequiredUnits() then
		allies.MarkCompletedObjective(objKillAll)
	end
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
	Trigger.AfterDelay(DateTime.Seconds(268), ParadropSovietUnits)
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

ActivateAI = function()

  ussr.Cash = 100000

	Trigger.AfterDelay(DateTime.Seconds(250), function()
		ProduceInfantry()
    ProduceAircraft()
    ParadropSovietUnits()
	end)
  Trigger.AfterDelay(DateTime.Seconds(400), function()
		ProduceTanks()
	end)
end

SetupTriggers = function()
  
  Trigger.OnEnteredProximityTrigger(waypoint23.CenterPosition, WDist.FromCells(9), function(actor, trigger1)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(trigger1)
      Actor.Create("camera", true, { Owner = allies, Location = waypoint23.Location })
		end
	end)

  --a case for Utils.Do???
  
  Trigger.OnKilled(VeryImportantBarrel, function()
		if not Alert1.IsDead then
      Alert1.AttackMove(AlertGo.Location)
    end
    if not Alert2.IsDead then
      Alert2.AttackMove(AlertGo.Location)
    end
    if not Alert3.IsDead then
      Alert3.AttackMove(AlertGo.Location)
    end
    if not Alert4.IsDead then
      Alert4.AttackMove(AlertGo.Location)
    end
    if not Alert5.IsDead then
      Alert5.AttackMove(AlertGo.Location)
    end
	end)

  Trigger.OnAllKilled(PowerPlantsBadGuy, function()
		allies.MarkCompletedObjective(objPowerPlants)
    Media.PlaySpeechNotification(allies, "ReinforcementsArrived")
    Reinforcements.Reinforce(allies, MCVReinforcements, { AlliesSpawn.Location, AlliesMove.Location })
    Actor.Create("flare", true, { Owner = allies, Location = AlliedBase.Location })
    Actor.Create("proc", true, { Owner = ussr, Location = Proc1.Location })
    Actor.Create("proc", true, { Owner = ussr, Location = Proc2.Location })
    ActivateAI()
	end)

  Trigger.OnAnyKilled(SarinPlants, function()
    allies.MarkFailedObjective(objSarinPlants)
  end)

end

CaptureSarinPlants = function()
	Utils.Do(SarinPlants, function(a)
		Trigger.OnCapture(a, function()
			allies.MarkCompletedObjective(objSarinPlants)
		end)
	end)
end

InitObjectives = function()
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	ussrObj = ussr.AddPrimaryObjective("Become a Pokemon Master and catch 'em all.")
  objPowerPlants = allies.AddPrimaryObjective("Destroy the eastern Power Plants.")
	objKillAll = allies.AddPrimaryObjective("Destroy all Soviet presence in the sector.")
  objSarinPlants = allies.AddPrimaryObjective("Capture all Sarin processing plants intact.")

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
	ussr = Player.GetPlayer("USSR")
  badguy = Player.GetPlayer("BadGuy")
  
  StartSpy.DisguiseAsType("e1", badguy)
  
  CaptureSarinPlants()
  
  PatrolMammoth.Patrol({ Patrol1.Location, Patrol2.Location, Patrol3.Location, Patrol4.Location, Patrol5.Location }, true, 20)
  
  Camera.Position = DefaultCameraPosition.CenterPosition

	InitObjectives()
  SetupTriggers()
end