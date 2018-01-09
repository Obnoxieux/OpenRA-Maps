MCVReinforcements = { "ltnk", "ltnk", "ftnk", "ftnk", "ftnk", "e3", "e3", "e3", "e3", "e3", "e3", "arty", "arty", "mcv" }

AttackPaths = { { wp1, wp2, GDIBase }, { wp3, wp4, wp5, wp6, wp2, GDIBase }, { wp1, wp7, wp8, wp9, GDIBase } }

InfantryProductionTypes = { "e1", "e1", "e1", "e1", "e1", "e2", "e2", "e2", "e3", "e3" }
InfantryAttackGroup = { }
VehicleProductionTypes = { "mtnk", "mtnk", "mtnk", "mtnk", "mtnk", "apc", "apc", "jeep", "jeep", "htnk", "msam" }
VehicleAttackGroup = { }
HeliAttackGroup = { }


ProduceInfantry = function(building)
	if building.IsDead or building.Owner ~= gdi then
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
	if building.IsDead or building.Owner ~= gdi then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(10), DateTime.Seconds(14))
	local toBuild = { Utils.Random(VehicleProductionTypes) }
	local Path = Utils.Random(AttackPaths)
	building.Build(toBuild, function(unit)
		VehicleAttackGroup[#VehicleAttackGroup + 1] = unit[1]

		if #VehicleAttackGroup >= 3 then
			SendUnits(VehicleAttackGroup, Path)
			VehicleAttackGroup = { }
			Trigger.AfterDelay(DateTime.Seconds(100), function() ProduceVehicle(building) end)
		else
			Trigger.AfterDelay(delay, function() ProduceVehicle(building) end)
		end
	end)
end

ProduceAircraft = function(building)
	if building.IsDead or building.Owner ~= gdi then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(10), DateTime.Seconds(14))
	local toBuild = { "orca" }
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
		if actor.Owner == gdi and actor.HasProperty("StartBuildingRepairs") then
			Trigger.OnDamaged(actor, function(building)
				if building.Owner == gdi and building.Health < 3/4 * building.MaxHealth then
					building.StartBuildingRepairs()
				end
			end)
		end
	end)
	gdi.Cash = 999999
	
	Trigger.AfterDelay(DateTime.Minutes(2), function() ProduceInfantry(GDIPyle) end)
	Trigger.AfterDelay(DateTime.Minutes(4), function() ProduceVehicle(GDIWaFa) end)
	Trigger.AfterDelay(DateTime.Minutes(6), function() ProduceAircraft(GDIHPad) end)
	
end

SetupTriggers = function()

	--[[Trigger.OnEnteredProximityTrigger(LabPoint.CenterPosition, WDist.FromCells(2), function(actor, trigger)
		if actor.Owner == gdi then
			Trigger.RemoveProximityTrigger(trigger)
			SendNodLateReinforcements()
			Media.DisplayMessage("Nod has received heavy reinforcements from the east!")
		end
	end)]]

	Trigger.OnKilledOrCaptured(TheLab, function()
		nod.MarkFailedObjective(objdefend)
	end)

end

WorldLoaded = function()
	gdi = Player.GetPlayer("GDI")
	nod = Player.GetPlayer("Nod")
	
	SetupTriggers()
	ActivateAI()
	
	Reinforcements.Reinforce(nod, MCVReinforcements, { NodIN.Location, NodINGo.Location })

	Camera.Position = camstart.CenterPosition
	
	Trigger.OnObjectiveAdded(nod, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	objenemy = gdi.AddPrimaryObjective("Capture the Nod Research Lab.")
	objdefend = nod.AddPrimaryObjective("Defend the Nod Research Lab at all costs.")
	objkillGDI = nod.AddPrimaryObjective("Remove any GDI presence in the sector.")

	Trigger.OnObjectiveCompleted(nod, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(nod, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerLost(nod, function()
		Media.PlaySpeechNotification(nod, "Lose")
	end)
	Trigger.OnPlayerWon(nod, function()
		Media.PlaySpeechNotification(nod, "Win")
	end)

end
