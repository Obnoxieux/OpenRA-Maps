MCVReinforcements = { "ltnk", "ltnk", "ftnk", "ftnk", "ftnk", "e3", "e3", "e3", "e3", "e3", "e3", "arty", "arty", "mcv" }

AttackPaths = { { wp2, wp1, LabPoint }, { wp2, wp6, wp5, wp4, wp3, LabPoint }, { wp9, wp8, wp7, wp1, LabPoint } }

InfantryProductionTypes = { "e1", "e1", "e1", "e1", "e1", "e2", "e2", "e2", "e3", "e3" }
InfantryAttackGroup = { }
VehicleProductionTypes = { "mtnk", "mtnk", "mtnk", "mtnk", "mtnk", "apc", "apc", "jeep", "jeep", "htnk", "msam" }
VehicleAttackGroup = { }
HeliAttackGroup = { }

InitialAttackers = { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14 ,a15, a16 ,a17, a18, a19, a20 }

Tick = function()
	if gdi.HasNoRequiredUnits() then
		nod.MarkCompletedObjective(objkillGDI)
		nod.MarkCompletedObjective(objdefend)
	end
end

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

	Trigger.OnKilledOrCaptured(TheLab, function()
		nod.MarkFailedObjective(objdefend)
	end)

end

SendInitialAttackers = function()
	a1.AttackMove(LabPoint.Location)
	a2.AttackMove(LabPoint.Location)
	a3.AttackMove(LabPoint.Location)
	a4.AttackMove(LabPoint.Location)
	a5.AttackMove(LabPoint.Location)
	a6.AttackMove(LabPoint.Location)
	a7.AttackMove(LabPoint.Location)
	a8.AttackMove(LabPoint.Location)
	a9.AttackMove(LabPoint.Location)
	a10.AttackMove(LabPoint.Location)
	a11.AttackMove(LabPoint.Location)
	a12.AttackMove(LabPoint.Location)
	a13.AttackMove(LabPoint.Location)
	a14.AttackMove(LabPoint.Location)
	a15.AttackMove(LabPoint.Location)
	a16.AttackMove(LabPoint.Location)
	a17.AttackMove(LabPoint.Location)
	a18.AttackMove(LabPoint.Location)
	a19.AttackMove(LabPoint.Location)
	a20.AttackMove(LabPoint.Location)
end

WorldLoaded = function()
	gdi = Player.GetPlayer("GDI")
	nod = Player.GetPlayer("Nod")
	
	SetupTriggers()
	ActivateAI()
	
	SendInitialAttackers()
	
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
