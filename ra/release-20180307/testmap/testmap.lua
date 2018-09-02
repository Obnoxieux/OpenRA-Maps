SovietAircraftType = { "yak", "mig", "hind" }
Yaks = { }

ConvoyActualTrucks = { "truk", "truk", "truk" }

SovietAirAttack = { MainAttack3 }

AirAttack = { }

BuildVehicles = true
TrainInfantry = true
Attacking = true

Tick = function()
	if ussr.HasNoRequiredUnits() then
		allies.MarkCompletedObjective(KillAll)
	end
end

IdleHunt = function(unit) if not unit.IsDead then Trigger.OnIdle(unit, unit.Hunt) end end

--[[ProducePlanes = function()

	local delay = Utils.RandomInteger(DateTime.Seconds(2), DateTime.Seconds(3))
	local toBuild = { Utils.Random(SovietAircraftType) }
	ussr.Build(toBuild, function(unit)
		AirAttack[#AirAttack + 1] = unit[1]

		if #AirAttack >= 1 then
			TargetAndAttack(AirAttack)
			AirAttack = { }
			Trigger.AfterDelay(DateTime.Seconds(40), ProducePlanes)
		else
			Trigger.AfterDelay(delay, ProducePlanes)
		end
	end)
end]]

ProducePlanes = function()
  local toBuild = { Utils.Random(SovietAircraftType) }
	ussr.Build(toBuild, function(units)
		local yak = units[1]
		Yaks[#Yaks + 1] = yak

		Trigger.OnKilled(yak, ProducePlanes)
		if #Yaks == 1 then
			Trigger.AfterDelay(DateTime.Seconds(30), ProducePlanes)
		end

		TargetAndAttack(yak)
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

--testen ob das mit Flugzeugen so funktioniert --> tut es, aber noch kein zweiter Anflug

SendAircraft = function(units)
	Utils.Do(units, function(unit)
		if not unit.IsDead then
			unit.Hunt()
		end
    if unit.IsIdle then
			unit.Hunt()
		end
	end)
end

TargetAndAttack = function(yak, target)
	if not target or target.IsDead or (not target.IsInWorld) then
		local enemies = Utils.Where(Map.ActorsInWorld, function(self) return self.Owner == allies and self.HasProperty("Health") and yak.CanTarget(self) end)
		if #enemies > 0 then
			target = Utils.Random(enemies)
		end
	end

	if target and yak.AmmoCount() > 0 and yak.CanTarget(target) then
		yak.Attack(target)
	else
		yak.ReturnToBase()
	end

	yak.CallFunc(function()
		TargetAndAttack(yak, target)
	end)
end

SendConvoy7 = function()
  Media.PlaySpeechNotification(allies, "ConvoyApproaching")
	--[[Reinforcements.Reinforce(ussr, Convoy7, { EntryNorthEdgeRight.Location, EntryNorthEdgeRightMove.Location }, 5, function(convoyescort)
    convoyescort.AttackMove(WP10.Location)
    convoyescort.AttackMove(ExitNorth.Location)
	end)]]
  Trigger.AfterDelay(DateTime.Seconds(4), function()
    lastconvoy = Reinforcements.Reinforce(ussr, ConvoyActualTrucks, { TruckEscape.Location, ConvoyMove.Location }, 5, function(convoy)
      convoy.Move(ConvoyGoal.Location)
    end)
		Trigger.OnAllKilled(lastconvoy, function()
			allies.MarkCompletedObjective(convoyobj)
		end)
  end)

	
end

InitObjectives = function()
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	ussrObj = ussr.AddPrimaryObjective("Deny the Allies.")
	KillAll = allies.AddPrimaryObjective("Eliminate all Soviet units in this area.")
  Dumbass = allies.AddSecondaryObjective("Let the Soviet truck escape\nbecause we're dumb")
	convoyobj = allies.AddSecondaryObjective("Kill the Soviet convoy.")

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

InitProductionBuildings = function()
	if not Wafa.IsDead then
		Wafa.IsPrimaryBuilding = true
		Trigger.OnKilled(Wafa, function() BuildVehicles = false end)
	else
		BuildVehicles = false
	end

	if not Rax.IsDead then
		Rax.IsPrimaryBuilding = true
		Trigger.OnKilled(Rax, function() TrainInfantry = false end)
	else
		TrainInfantry = false
	end
end

ActivateAI = function()

	InitProductionBuildings()

	Trigger.AfterDelay(DateTime.Seconds(5), function()
		ProducePlanes()
		--ProduceTanks()
	end)
end

Trigger.OnEnteredProximityTrigger(TruckEscape.CenterPosition, WDist.FromCells(1), function(actor, trigger)
  if actor.Owner == ussr and actor.Type == "truk" then
    Trigger.RemoveProximityTrigger(trigger)
    actor.Destroy()
    allies.MarkCompletedObjective(Dumbass)
  end
end)

WorldLoaded = function()
	allies = Player.GetPlayer("Greece")
	ussr = Player.GetPlayer("USSR")
  
  TheTruck.Move(TruckEscape.Location)
	
	Trigger.AfterDelay(DateTime.Seconds(5), function()
		SendConvoy7()
	end)
	
	InitObjectives()
	ActivateAI()
end