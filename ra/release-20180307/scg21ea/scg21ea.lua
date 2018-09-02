--Down Under

SarinDispensed = false
SovietImportantGuys = { Officer3, Officer2, Officer1, Scientist1, Scientist2, Scientist3 }
WinTriggerArea = { CPos.New(112, 59), CPos.New(112, 60), CPos.New(112, 61), CPos.New(112, 62), CPos.New(112, 63), CPos.New(112, 64), CPos.New(112, 65), CPos.New(111, 59), CPos.New(111, 60), CPos.New(111, 61), CPos.New(111, 62), CPos.New(111, 63), CPos.New(111, 64), CPos.New(111, 65) }

Trigger.OnEnteredFootprint(WinTriggerArea, function(a, id)
	if not EscapeGoalTrigger and a.Owner == allies then
		EscapeGoalTrigger = true
		allies.MarkCompletedObjective(objGetOut)
	end
end)

Tick = function() 
	if allies.HasNoRequiredUnits() then 
		allies.MarkFailedObjective(objGetOut)
	end
end

SetupTriggers = function()
  
  -- 8 triggers for flame turrets, tesla coils and sarin dispensers
  
  Trigger.OnEnteredProximityTrigger(Terminal1.CenterPosition, WDist.FromCells(1), function(actor, trigger1)
		if actor.Type == "spy" then
			Trigger.RemoveProximityTrigger(trigger1)
      Media.DisplayMessage("Flame Turret deactivated")
      if not FlameTower1.IsDead then
				FlameTower1.Kill()
			end
		end
	end)

  Trigger.OnEnteredProximityTrigger(Terminal2.CenterPosition, WDist.FromCells(1), function(actor, trigger2)
		if actor.Type == "spy" then
			Trigger.RemoveProximityTrigger(trigger2)
      Media.DisplayMessage("Flame Turret deactivated")
			if not FlameTower2.IsDead then
				FlameTower2.Kill()
			end
		end
	end)

  Trigger.OnEnteredProximityTrigger(Terminal3.CenterPosition, WDist.FromCells(1), function(actor, trigger3)
		if actor.Type == "spy" then
			Trigger.RemoveProximityTrigger(trigger3)
      Media.DisplayMessage("Flame Turret deactivated")
			if not FlameTower3.IsDead then
				FlameTower3.Kill()
			end
		end
	end)

  Trigger.OnEnteredProximityTrigger(Terminal4.CenterPosition, WDist.FromCells(1), function(actor, trigger4)
		if actor.Type == "spy" then
      SarinDispensed = true
			Trigger.RemoveProximityTrigger(trigger4)
      Media.DisplayMessage("Sarin Nerve Gas dispensers activated")
      Actor.Create("camera", true, { Owner = allies, Location = Sarin2.Location })
      flare1 = Actor.Create("flare", true, { Owner = england, Location = Sarin1.Location })
      flare2 = Actor.Create("flare", true, { Owner = england, Location = Sarin2.Location })
      flare3 = Actor.Create("flare", true, { Owner = england, Location = Sarin3.Location })
      flare4 = Actor.Create("flare", true, { Owner = england, Location = Sarin4.Location })
      Trigger.AfterDelay(DateTime.Seconds(3), function()
				if not SarinVictim1.IsDead then
					SarinVictim1.Kill()
				end
				if not SarinVictim2.IsDead then
					SarinVictim2.Kill()
				end
				if not SarinVictim3.IsDead then
					SarinVictim3.Kill()
				end
				if not SarinVictim4.IsDead then
					SarinVictim4.Kill()
				end
				if not SarinVictim5.IsDead then
					SarinVictim5.Kill()
				end
				if not SarinVictim6.IsDead then
					SarinVictim6.Kill()
				end
				if not SarinVictim7.IsDead then
					SarinVictim7.Kill()
				end
				if not SarinVictim8.IsDead then
					SarinVictim8.Kill()
				end
				if not SarinVictim9.IsDead then
					SarinVictim9.Kill()
				end
				if not SarinVictim10.IsDead then
					SarinVictim10.Kill()
				end
				if not SarinVictim11.IsDead then
					SarinVictim11.Kill()
				end
				if not SarinVictim12.IsDead then
					SarinVictim12.Kill()
				end
				if not SarinVictimX.IsDead then
					SarinVictimX.Kill()
				end
      end)
      Trigger.AfterDelay(DateTime.Seconds(9), function()
        flare1.Destroy()
        flare2.Destroy()
        flare3.Destroy()
        flare4.Destroy()
      end)
		end
	end)

  Trigger.OnEnteredProximityTrigger(Terminal5.CenterPosition, WDist.FromCells(1), function(actor, trigger5)
		if actor.Type == "spy" then
			Trigger.RemoveProximityTrigger(trigger5)
      Media.DisplayMessage("Tesla Coil deactivated")
      BadCoil.Kill()
		end
	end)

  Trigger.OnEnteredProximityTrigger(Terminal6.CenterPosition, WDist.FromCells(1), function(actor, trigger6)
		if actor.Type == "spy" then
			Trigger.RemoveProximityTrigger(trigger6)
      Media.DisplayMessage("Initialising Tesla Coil defence")
      Actor.Create("tsla", true, { Owner = turkey, Location = TurkeyCoil1.Location })
      Actor.Create("tsla", true, { Owner = turkey, Location = TurkeyCoil2.Location })
		end
	end)

  Trigger.OnEnteredProximityTrigger(Terminal7.CenterPosition, WDist.FromCells(1), function(actor, trigger7)
		if actor.Type == "spy" then
			Trigger.RemoveProximityTrigger(trigger7)
      Media.DisplayMessage("Flame Turrets deactivated")
			if not FlameTowerTanya1.IsDead then
				FlameTowerTanya1.Kill()
			end
			if not FlameTowerTanya2.IsDead then
				FlameTowerTanya2.Kill()
			end
		end
	end)

  Trigger.OnEnteredProximityTrigger(Terminal8.CenterPosition, WDist.FromCells(1), function(actor, trigger8)
		if actor.Type == "spy" then
			Trigger.RemoveProximityTrigger(trigger8)
      Media.DisplayMessage("Flame Turrets deactivated")
			if not FlameTowerExit1.IsDead then
				FlameTowerExit1.Kill()
			end
			if not FlameTowerExit2.IsDead then
				FlameTowerExit2.Kill()
			end
			if not FlameTowerExit3.IsDead then
				FlameTowerExit3.Kill()
			end
		end
	end)

--secondary objectives

  Trigger.OnAllKilled(SovietImportantGuys, function()
		allies.MarkCompletedObjective(objKillOffSci)
	end)

  Trigger.OnInfiltrated(Wafa, function()
    allies.MarkCompletedObjective(objSteal)
		if not StealMammoth.IsDead then
			StealMammoth.Owner = allies
		end
  end)

--miscellaneous: dog attack, demo truck

  Trigger.OnKilled(Scientist2, function()
		if not DemoTruck.IsDead then
			DemoTruck.Owner = allies
			Media.DisplayMessage("This scientist had the engine codes for a demolition truck parked in this facility")
		end
	end)

  Trigger.OnEnteredProximityTrigger(DoggyMove.CenterPosition, WDist.FromCells(5), function(actor, triggerdog)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(triggerdog)
			if not SnoopDogg1.IsDead then
				SnoopDogg1.AttackMove(DoggyMove.Location)
			end
			if not SnoopDoggBackgroundMC.IsDead then
				SnoopDoggBackgroundMC.AttackMove(DoggyMove.Location)
			end
			if not SnoopDoggBackgroundBreakdancer.IsDead then
				SnoopDoggBackgroundBreakdancer.AttackMove(DoggyMove.Location)
			end
		end
	end)

--camera celltriggers

  Trigger.OnEnteredProximityTrigger(CameraTrigger1.CenterPosition, WDist.FromCells(8), function(actor, triggercam1)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(triggercam1)
      Actor.Create("camera", true, { Owner = allies, Location = CameraTrigger1.Location })
		end
	end)

  Trigger.OnEnteredProximityTrigger(CameraTrigger2.CenterPosition, WDist.FromCells(8), function(actor, triggercam2)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(triggercam2)
      Actor.Create("camera", true, { Owner = allies, Location = CameraTrigger2.Location })
		end
	end)

  Trigger.OnEnteredProximityTrigger(CameraTrigger3.CenterPosition, WDist.FromCells(8), function(actor, triggercam3)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(triggercam3)
      Actor.Create("camera", true, { Owner = allies, Location = CameraTrigger3.Location })
      Actor.Create("apwr", true, { Owner = france, Location = PowerPlantSpawn1.Location })
      Actor.Create("apwr", true, { Owner = germany, Location = PowerPlantSpawn2.Location })
      Mammoth1.AttackMove(MammothGo.Location)
		end
	end)

  Trigger.OnEnteredProximityTrigger(CameraTrigger4.CenterPosition, WDist.FromCells(8), function(actor, triggercam4)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(triggercam4)
      Actor.Create("camera", true, { Owner = allies, Location = CameraTrigger4.Location })
		end
	end)

  Trigger.OnEnteredProximityTrigger(CameraTrigger5.CenterPosition, WDist.FromCells(8), function(actor, triggercam5)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(triggercam5)
      Actor.Create("camera", true, { Owner = allies, Location = CameraTrigger5.Location })
		end
	end)

  Trigger.OnEnteredProximityTrigger(CameraTrigger6.CenterPosition, WDist.FromCells(8), function(actor, triggercam6)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(triggercam6)
      Actor.Create("camera", true, { Owner = allies, Location = CameraTrigger6.Location })
		end
	end)

  Trigger.OnEnteredProximityTrigger(CameraTrigger7.CenterPosition, WDist.FromCells(8), function(actor, triggercam7)
		if actor.Owner == allies then
			Trigger.RemoveProximityTrigger(triggercam7)
      Actor.Create("camera", true, { Owner = allies, Location = CameraTrigger7.Location })
		end
	end)

end

InitObjectives = function()
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	ussrObj = ussr.AddPrimaryObjective("Become a Pokemon Master and catch em all.")
	objGetOut = allies.AddPrimaryObjective("Reach the eastern exit of the facility.")
  objKillOffSci = allies.AddSecondaryObjective("Kill all Soviet officers and scientists.")
  objSteal = allies.AddSecondaryObjective("Steal a Soviet vehicle\nby infiltrating a weapons factory.")

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
  turkey = Player.GetPlayer("Turkey")
	ussr = Player.GetPlayer("USSR")
  badguy = Player.GetPlayer("BadGuy")
  france = Player.GetPlayer("France")
  germany = Player.GetPlayer("Germany")
  
  StartSpy.DisguiseAsType("e1", badguy) --it is "badguy" to prevent the spy from getting killed by the turkey owned tesla coils
  StartAttacker1.AttackMove(start.Location)
  StartAttacker2.AttackMove(start.Location)
  
  Camera.Position = start.CenterPosition

	InitObjectives()
  SetupTriggers()
end