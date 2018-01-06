MCVReinforcements = { "htnk", "htnk", "mcv" }
NodLateReinforcements = { "e5", "e5", "e5", "e5", "ftnk", "ftnk", "stnk", "stnk", "stnk", "arty", "arty" }

NodEarlyBase = { EarlyConyard, EarlyHand, EarlyAFLD, EarlyCommCentre, EarlyHelipad }

AttackPaths = { { wp1, wp2, GDIBase }, { wp3, wp4, wp5, wp6, wp2, GDIBase }, { wp1, wp7, wp8, wp9, GDIBase } }
	
InfantryProductionTypes = { "e1", "e1", "e1", "e1", "e1", "e3", "e3", "e3", "e3", "e4", "e4", "e5" }
InfantryAttackGroup = { }
VehicleProductionTypes = { "ltnk", "ltnk", "ltnk", "ltnk", "ltnk", "bike", "bike", "bggy", "bggy", "stnk", "ftnk", "arty" }
VehicleAttackGroup = { }
HeliAttackGroup = { }



SendNodLateReinforcements = function()
	local chemtroops = Reinforcements.Reinforce(nod, NodLateReinforcements, { NodIN.Location, NodINGo.Location })
	Utils.Do(chemtroops, function(a)
    Trigger.OnAddedToWorld(a, function()
      a.AttackMove(LabPoint.Location)
      a.Hunt()
    end)
  end)
end


ProduceInfantry = function(building)
	if building.IsDead or building.Owner ~= nod then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9))
	local toBuild = { Utils.Random(InfantryProductionTypes) }
	local Path = Utils.Random(AttackPaths)
	building.Build(toBuild, function(unit)
		InfantryAttackGroup[#InfantryAttackGroup + 1] = unit[1]

		if #InfantryAttackGroup >= 5 then
			SendUnits(InfantryAttackGroup, Path)
			InfantryAttackGroup = { }
			Trigger.AfterDelay(DateTime.Minutes(1), function() ProduceInfantry(building) end)
		else
			Trigger.AfterDelay(delay, function() ProduceInfantry(building) end)
		end
	end)
	
end

ProduceVehicle = function(building)
	if building.IsDead or building.Owner ~= nod then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(10), DateTime.Seconds(14))
	local toBuild = { Utils.Random(VehicleProductionTypes) }
	local Path = Utils.Random(AttackPaths)
	building.Build(toBuild, function(unit)
		VehicleAttackGroup[#VehicleAttackGroup + 1] = unit[1]

		if #VehicleAttackGroup >= 4 then
			SendUnits(VehicleAttackGroup, Path)
			VehicleAttackGroup = { }
			Trigger.AfterDelay(DateTime.Seconds(100), function() ProduceVehicle(building) end)
		else
			Trigger.AfterDelay(delay, function() ProduceVehicle(building) end)
		end
	end)
end

ProduceAircraft = function(building)
	if building.IsDead or building.Owner ~= nod then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(10), DateTime.Seconds(14))
	local toBuild = { "heli" }
	building.Build(toBuild, function(unit)
		HeliAttackGroup[#HeliAttackGroup + 1] = unit[1]

		if #HeliAttackGroup >= 1 then
			SendAircraft(HeliAttackGroup)
			HeliAttackGroup = { }
			Trigger.AfterDelay(DateTime.Minutes(5), function() ProduceAircraft(building) end)
		else
			Trigger.AfterDelay(delay, function() ProduceAircraft(building) end)
		end
	end)
end

IdleHunt = function(unit)
	if not unit.IsDead then 
		Trigger.OnIdle(unit, unit.Hunt) 
	end 
end

SendAircraft = function(units)
	Utils.Do(units, function(unit)
		if not unit.IsDead then
			unit.Hunt()
		end
	end)
end

SendUnits = function(units, waypoints)
	Utils.Do(units, function(unit)
		if not unit.IsDead then
			Utils.Do(waypoints, function(waypoint)
				unit.AttackMove(waypoint.Location)
			end)
			IdleHunt(unit)
		end
	end)
end


ActivateAI = function()
	Utils.Do(Map.NamedActors, function(actor)
		if actor.Owner == nod and actor.HasProperty("StartBuildingRepairs") then
			Trigger.OnDamaged(actor, function(building)
				if building.Owner == nod and building.Health < 3/4 * building.MaxHealth then
					building.StartBuildingRepairs()
				end
			end)
		end
	end)
	nod.Cash = 999999
	
	Trigger.AfterDelay(DateTime.Minutes(2), function() ProduceInfantry(NodHand) end)
	Trigger.AfterDelay(DateTime.Minutes(3), function() ProduceVehicle(NodAirfield) end)
	Trigger.AfterDelay(DateTime.Minutes(5), function() ProduceAircraft(NodHelipad) end)
	
end

SetupTriggers = function()

	Trigger.OnAllKilled(NodEarlyBase, function()
		Reinforcements.Reinforce(gdi, MCVReinforcements, { GDIReinforce.Location, GDIReinforceGo.Location })
		ActivateAI()
		gdi.MarkCompletedObjective(objEast)
	end)

	Trigger.OnEnteredProximityTrigger(LabPoint.CenterPosition, WDist.FromCells(2), function(actor, trigger)
		if actor.Owner == gdi then
			Trigger.RemoveProximityTrigger(trigger)
			SendNodLateReinforcements()
			Media.DisplayMessage("Nod has received heavy reinforcements from the east!")
		end
	end)

	Trigger.OnKilled(TheLab, function()
		gdi.MarkFailedObjective(objLab)
	end)

	Trigger.OnCapture(TheLab, function()
		gdi.MarkCompletedObjective(objLab)
	end)
end

WorldLoaded = function()
	gdi = Player.GetPlayer("GDI")
	nod = Player.GetPlayer("Nod")
	
	SetupTriggers()
	
	Camera.Position = camstart.CenterPosition
	
	Trigger.OnObjectiveAdded(gdi, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	objEast = gdi.AddPrimaryObjective("Destroy the Nod base to the east\nto make room for our forward base.")
	objLab = gdi.AddPrimaryObjective("Capture the Nod Research Lab.")

	Trigger.OnObjectiveCompleted(gdi, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(gdi, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerLost(gdi, function()
		Media.PlaySpeechNotification(gdi, "Lose")
	end)
	Trigger.OnPlayerWon(gdi, function()
		Media.PlaySpeechNotification(gdi, "Win")
	end)

end
