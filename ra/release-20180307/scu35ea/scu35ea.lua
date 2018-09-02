--Soviet Soldier Volkov

VolkovTeam = { "gnrl" }
AlliedArmorTypes = { "1tnk", "2tnk", "jeep" }
ParadropUnitTypes = { "e1", "e1", "e1", "e1", "e1", "e1", "e1" }
--TruckEscapePath = { Truck1 }
AlliedAttackPath = { AttackPoint }

TankAttack = { }

IdleHunt = function(unit) if not unit.IsDead then Trigger.OnIdle(unit, unit.Hunt) end end

ParadropAlliedUnits = function()
	local lz = AlliedParadrop.Location
	local start = Map.CenterOfCell(AlliedParadropSpawn.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = allies, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = allies })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

ProduceTanks = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(AlliedArmorTypes) }
	allies.Build(toBuild, function(unit)
		TankAttack[#TankAttack + 1] = unit[1]

		if #TankAttack >= 4 then
			SendUnits(TankAttack, AlliedAttackPath)
			TankAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(2), ProduceTanks)
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

ActivateAI = function()

	--InitProductionBuildings()
  allies.Cash = 60000
  france.Cash = 60000
  goodguy.Cash = 60000

	Trigger.AfterDelay(DateTime.Seconds(60), function()
		ProduceTanks()
	end)
end

MoveTruck = function(truck)
  truck.Move(Truck1.Location)
end

SetupTriggers = function()
  
  Trigger.OnKilled(AlliedTechCentre, function()
    ussr.MarkCompletedObjective(objSabotageControlCentre)
    InvulnerableTurret1.Kill()
    InvulnerableTurret2.Kill()
    InvulnerableTurret3.Kill()
  end)

  Trigger.OnKilled(AlloyFacility, function()
    ussr.MarkCompletedObjective(objKillFacility)
  end)
    
  
  Trigger.OnEnteredProximityTrigger(AlliedParadrop.CenterPosition, WDist.FromCells(6), function(actor, trigger)
		if actor.Owner == ussr then
			Trigger.RemoveProximityTrigger(trigger)
			ParadropAlliedUnits()
		end
	end)

  Trigger.OnEnteredProximityTrigger(TruckProximityTrigger.CenterPosition, WDist.FromCells(6), function(actor, trigger2)
		if actor.Owner == ussr then
			Trigger.RemoveProximityTrigger(trigger2)
			MoveTruck(CowardTruck)
		end
	end)

end

InitObjectives = function()

	enemyobj = allies.AddPrimaryObjective("Deny the Soviets.")
	objSabotageControlCentre = ussr.AddPrimaryObjective("Destroy the Allied Tech Control Centre.")
  objKillFacility = ussr.AddPrimaryObjective("Destroy the Alloy Facility.")
	
end

ParadropVolkov = function()
	local lz = VolkovDropoff.Location
	local start = Map.CenterOfCell(SpawnVolkovPlane.Location) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = ussr, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(VolkovTeam, function(type)
		local a = Actor.Create(type, false, { Owner = ussr })
		--BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
end

WorldLoaded = function()
	allies = Player.GetPlayer("Greece")
  france = Player.GetPlayer("France")
  goodguy = Player.GetPlayer("GoodGuy")
	ussr = Player.GetPlayer("USSR")

	InitObjectives()
	ActivateAI()
  SetupTriggers()
  
  Camera.Position = DefaultCameraPosition.CenterPosition
  
  Trigger.OnObjectiveAdded(ussr, function(p, id)
      Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
  end)

  Trigger.OnObjectiveCompleted(ussr, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
  end)
  
  Trigger.OnObjectiveFailed(ussr, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
  end)

  Trigger.OnPlayerWon(ussr, function()
    Media.PlaySpeechNotification(ussr, "MissionAccomplished")
  end)

  Trigger.OnPlayerLost(ussr, function()
    Media.PlaySpeechNotification(ussr, "MissionFailed")
  end)

  Trigger.AfterDelay(DateTime.Seconds(5), function() 
      ParadropVolkov() 
  end)

end