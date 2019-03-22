--Siberian Conflict 2: Trapped

PlayerStartUnits = { "1tnk", "1tnk", "e1", "e1", "e1", "e3", "e3", "e3", "arty", "arty", "2tnk", "2tnk", "mcv" }
InvasionTeams = { { "3tnk", "e1", "e1", "e1", "e2" }, { "3tnk", "e1", "e4", "e1", "e1" }, { "3tnk", "e1", "e4", "e1", "e1" }, { "e2", "e1", "e4", "e1", "e1" }, { "e4", "4tnk", "e1", "e1", "e1" }, { "ttnk", "e1", "e4", "shok", "e1" } }

SovietAttackPath = { { wp6, wp5, wp9, wp29, AlliedBase }, { wp35, wp18, wp32, wp16, wp15, wp7, wp2, AlliedBase }, { wp6, wp5, wp21, wp19, AlliedBase } }
BadGuyPath = { wp23, wp22, wp21, wp8, wp9, AlliedBase }
AirAttackPath = { AlliedBase }
SubPath = { Sub1, Sub2, Sub3, Sub4, MSUB }

ConvoyTrucks = { CinematicTruck, Truck1, Truck2, Truck3, Truck4 }

ParadropWaypoints = { AlliedBase, wp19, wp11 }
ParadropUnitTypes = { "e1", "e1", "e1", "e2", "e4", "shok" }

SovietInfantryTypes = { "e1", "e1", "e1", "e1", "e1", "e1", "e2", "e2", "e4", "e4", "shok" }
SovietArmorTypes = { "3tnk", "3tnk", "3tnk", "3tnk", "v2rl", "4tnk", "ttnk" }
SovietAircraftTypes = { "hind", "yak", "mig" }
SovietSubType = { "ss", "ss", "msub" }

InfAttack = { }
InfAttackBadGuy = { }
TankAttack = { }
AirAttack = { }
SubAttack = { }

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
	Trigger.AfterDelay(DateTime.Seconds(300), ParadropSovietUnits)
end

SendParabombsOnBridges = function()
  local bombproxy = Actor.Create("powerproxy.parabombs", false, { Owner = ussr })
  bombproxy.SendAirstrike(BridgeLeft.CenterPosition, false, Facing.NorthWest)
  bombproxy.Destroy()
  local bombproxy2 = Actor.Create("powerproxy.parabombs", false, { Owner = ussr })
  bombproxy2.SendAirstrike(BridgeMiddle.CenterPosition, false, Facing.NorthWest)
  bombproxy2.Destroy()
end

SendSovietInvasion = function()
  local units = Utils.Random(InvasionTeams)
  local invasionteam = Reinforcements.ReinforceWithTransport (ussr, "lst", units, { SovietBoatEntry.Location, SovietBoatUnload.Location}, { SovietBoatEntry.Location})[2]
  Utils.Do(invasionteam, function(a)
    Trigger.OnAddedToWorld(a, function()
      a.AttackMove(AlliedBase.Location)
      a.Hunt()
    end)
  end)

  Trigger.AfterDelay(DateTime.Minutes(6), SendSovietInvasion)
end

MoveTruck1and2 = function(truck)
  Media.DisplayMessage("Convoy truck attempting to escape!")
  truck.Move(wp6.Location)
  truck.Move(wp5.Location)
  truck.Move(wp27.Location)
  truck.Move(wp28.Location)
  truck.Move(wp7.Location)
  truck.Move(wp4.Location)
  truck.Move(wp3.Location)
  truck.Move(wp1.Location)
  truck.Move(ExitLeft.Location)
end

MoveTruck3 = function(truck)
  Media.DisplayMessage("Convoy truck attempting to escape!")
  truck.Move(wp18.Location)
  truck.Move(wp17.Location)
  truck.Move(wp15.Location)
  truck.Move(wp7.Location)
  truck.Move(wp28.Location)
  truck.Move(wp27.Location)
  truck.Move(wp8.Location)
  truck.Move(ExitNortheast.Location)
end

MoveTruck4and5 = function(truck)
  Media.DisplayMessage("Convoy truck attempting to escape!")
  truck.Move(wp6.Location)
  truck.Move(wp5.Location)
  truck.Move(wp30.Location)
  truck.Move(wp21.Location)
  truck.Move(wp22.Location)
  truck.Move(wp23.Location)
  truck.Move(wp26.Location)
  truck.Move(ExitEast.Location)
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

ProduceInfantryBadGuy = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(6))
	local toBuild = { Utils.Random(SovietInfantryTypes) }
	badguy.Build(toBuild, function(unit)
		InfAttackBadGuy[#InfAttackBadGuy + 1] = unit[1]

		if #InfAttackBadGuy >= 5 then
			SendUnits(InfAttackBadGuy, BadGuyPath)
			InfAttackBadGuy = { }
			Trigger.AfterDelay(DateTime.Seconds(38), ProduceInfantryBadGuy)
		else
			Trigger.AfterDelay(delay, ProduceInfantryBadGuy)
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


SendAircraft = function(units)
	Utils.Do(units, function(unit)
		if not unit.IsDead then
			unit.Hunt()
		end
	end)
end

ActivateAI = function()

  ussr.Cash = 100000
	Trigger.AfterDelay(DateTime.Seconds(350), function()
		ProduceAircraft()
		ProduceTanks()
    ProduceInfantry()
    ProduceSubs()
    ParadropSovietUnits()
	end)
end

InitObjectives = function()
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	ussrObj = ussr.AddPrimaryObjective("Make a Hoola-Hoop.")
	objKillTrucks = allies.AddPrimaryObjective("Destroy all Soviet convoy trucks\nbefore they can escape the area.")
  objKillAll = allies.AddPrimaryObjective("Clear the sector of all Soviet presence.")

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

SetupTriggers = function()
  
	Trigger.OnAllKilled(ConvoyTrucks, function()
		allies.MarkCompletedObjective(objKillTrucks)
	end)
	
  Trigger.OnEnteredProximityTrigger(BridgeRight.CenterPosition, WDist.FromCells(4), function(actor, triggerbombs)
    if actor.Owner == allies then
      Trigger.RemoveProximityTrigger(triggerbombs)
      local bombproxy = Actor.Create("powerproxy.parabombs", false, { Owner = ussr })
      bombproxy.SendAirstrike(BridgeRight.CenterPosition, false, Facing.NorthEast)
      bombproxy.Destroy()
    end
  end)

	Trigger.OnEnteredProximityTrigger(ExitLeft.CenterPosition, WDist.FromCells(1), function(actor, triggerlose1)
    if actor.Owner == ussr and actor.Type == "truk" then
      Trigger.RemoveProximityTrigger(triggerlose1)
      actor.Destroy()
      allies.MarkFailedObjective(objKillTrucks)
    end
  end)

  Trigger.OnEnteredProximityTrigger(ExitEast.CenterPosition, WDist.FromCells(1), function(actor, triggerlose2)
    if actor.Owner == ussr and actor.Type == "truk" then
      Trigger.RemoveProximityTrigger(triggerlose2)
      actor.Destroy()
      allies.MarkFailedObjective(objKillTrucks)
    end
  end)

  Trigger.OnEnteredProximityTrigger(ExitNortheast.CenterPosition, WDist.FromCells(1), function(actor, triggerlose3)
    if actor.Owner == ussr and actor.Type == "truk" then
      Trigger.RemoveProximityTrigger(triggerlose3)
      actor.Destroy()
      allies.MarkFailedObjective(objKillTrucks)
    end
  end)

end

WorldLoaded = function()
	allies = Player.GetPlayer("Allies")
	ussr = Player.GetPlayer("USSR")
  badguy = Player.GetPlayer("BadGuy")
  
  Camera.Position = wp1.CenterPosition
  CinematicTruck.Move(wplast.Location)

	InitObjectives()
  SetupTriggers()
  
  Reinforcements.Reinforce(allies, PlayerStartUnits, { ExitLeft.Location, wp1.Location })
  
  ActivateAI()
	
	badguy.Cash = 100000
	ProduceInfantryBadGuy()
	
  Trigger.AfterDelay(DateTime.Minutes(9), SendParabombsOnBridges)
  Trigger.AfterDelay(DateTime.Seconds(30), SendSovietInvasion)
	
	Trigger.AfterDelay(DateTime.Minutes(8), function()
		if not CinematicTruck.IsDead then
			MoveTruck1and2(CinematicTruck)
		end
	end)
  Trigger.AfterDelay(DateTime.Minutes(12), function() 
		if not Truck1.IsDead then
			MoveTruck1and2(Truck1)
		end
	end)
  Trigger.AfterDelay(DateTime.Minutes(15), function()
		if not Truck2.IsDead then
			MoveTruck3(Truck2)
		end
	end)
  Trigger.AfterDelay(DateTime.Minutes(28), function()
		if not Truck3.IsDead then
			MoveTruck4and5(Truck3)
		end
	end)
  Trigger.AfterDelay(DateTime.Minutes(31), function()
		if not Truck4.IsDead then
			MoveTruck4and5(Truck4)
		end
	end)
  
  Trigger.AfterDelay(DateTime.Seconds(6), function()
    start1.AttackMove(wp1.Location)
    start2.AttackMove(wp1.Location)
    start3.AttackMove(wp1.Location)
    start4.AttackMove(wp1.Location)
    start5.AttackMove(wp1.Location)
    start6.AttackMove(wp1.Location)
    start7.AttackMove(wp1.Location)
    start8.AttackMove(wp1.Location)
  end)
end