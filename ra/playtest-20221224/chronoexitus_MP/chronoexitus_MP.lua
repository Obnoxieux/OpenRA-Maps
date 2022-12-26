BrickWall = { Wall1, Wall2, Wall, Wall3, Wall4, Wall5, Wall6 }
DefenceTurrets = { Turret1, Turret2, Turret3, Turret4, Turret5, Turret6, Turret7, Turret8, Turret9, Turret10, Turret11, Turret12 }
Minefield = { Mine1, Mine2, Mine3, Mine4, Mine5, Mine6, Mine7, Mine7, Mine8, Mine9, Mine10, Mine11, Mine12, Mine13, Mine14, Mine15, Mine16, Mine17, Mine18, Mine19, Mine20, Mine21, Mine22, Mine23, Mine24, Mine25, Mine26, Mine27, Mine28 }
ExitPillboxes = { ExitBox1, ExitBox2, ExitBox3, ExitBox4, ExitBox5, ExitBox6, ExitBox7 }

EinsteinGuards = { Guard1, Guard2, Guard3, Guard4, Guard5, Guard6, Guard7, Guard8, Guard9, Guard10 }

GasKillArea = { CPos.New(80, 21), CPos.New(80, 22), CPos.New(80, 23), CPos.New(80, 24),CPos.New(80, 25), CPos.New(80, 26), CPos.New(81, 21), CPos.New(81, 22), CPos.New(81, 23), CPos.New(81, 24), CPos.New(81, 25), CPos.New(81, 26), CPos.New(82, 21), CPos.New(82, 22), CPos.New(82, 23), CPos.New(82, 23), CPos.New(82, 24), CPos.New(82, 25), CPos.New(82, 26) }

SovietPOWs = { POW1, POW2, POW3, POW4, POW5, POW6, POW7, POW8, POW9, POW10, POW11, POW12, POW13 }

AlliedVehiclePatrols = { { "1tnk", "1tnk", "jeep" }, { "1tnk", "2tnk" }, { "apc", "1tnk" }, { "ctnk", "jeep" } }
AlliedInfantryPatrols = { { "e1", "e1", "e1", "e1", "e3", "e3" }, { "e1", "e1", "e1", "e1", "e1", "e3" }, { "e1", "e1", "e1", "dog", "e3", "e3" } }


AlliedPatrolPath = { Patrol1.Location, Patrol2.Location, Patrol3.Location, Patrol4.Location, Patrol5.Location, Patrol6.Location, Patrol7.Location, Patrol8.Location, Patrol9.Location, Patrol10.Location, Patrol11.Location, Patrol12.Location, Patrol13.Location, Patrol14.Location }

GasActive = true
SecurityObjectiveShown = false
EndingSequence = false
ChronosphereAlive = true


Tick = function()
	if ussr1.HasNoRequiredUnits() or ussr2.HasNoRequiredUnits() then
		allies.MarkCompletedObjective(enemyobj)
	end
end

SendInfantryPatrols = function()
	local units = Utils.Random(AlliedInfantryPatrols)
	Reinforcements.Reinforce(allies, units, { AlliedInfantrySpawn.Location, AlliedInfantryMove.Location }, 7, function(infpatrol)
    infpatrol.Patrol(AlliedPatrolPath, true, 11)
		Trigger.OnDamaged(infpatrol, function()
			infpatrol.Hunt()
		end)
	end)
--test
	Trigger.AfterDelay(DateTime.Seconds(120), SendInfantryPatrols)
end

SendVehiclePatrols = function()
	local units = Utils.Random(AlliedVehiclePatrols)
	Reinforcements.Reinforce(allies, units, { AlliedVehicleSpawn.Location, AlliedVehicleMove.Location }, 7, function(vehiclepatrol)
    vehiclepatrol.Patrol(AlliedPatrolPath, true, 11)
		Trigger.OnDamaged(vehiclepatrol, function()
			vehiclepatrol.Hunt()
		end)
	end)

	Trigger.AfterDelay(DateTime.Seconds(280), SendVehiclePatrols)
end

SetupTriggers = function()

  Trigger.OnKilled(Volkov, function()
		ussr1.MarkFailedObjective(objVolkovSurvival)
		ussr2.MarkFailedObjective(objVolkovSurvival)
	end)

	Trigger.OnKilled(Einstein, function()
		ussr1.MarkCompletedObjective(objHitman)
		ussr2.MarkCompletedObjective(objHitman)
		ussr1.MarkCompletedObjective(objVolkovSurvival)
		ussr2.MarkCompletedObjective(objVolkovSurvival)
	end)

	Trigger.OnKilled(Chronosphere, function()
		ussr1.MarkCompletedObjective(objchrono)
		ussr2.MarkCompletedObjective(objchrono)
		ChronosphereAlive = false
	end)

	Trigger.OnKilled(POWGuardPillbox, function()
		ussr1.MarkCompletedObjective(objPOWs)
		ussr2.MarkCompletedObjective(objPOWs)
		
		Utils.Do(SovietPOWs, function(pows)
			if not pows.IsDead then
				pows.Owner = ussr2
			end
		end)
	end)

	
	--show defence objectives
	
  Trigger.OnEnteredProximityTrigger(RevealDefence.CenterPosition, WDist.FromCells(3), function(actor, trigger)
		if actor.Owner == ussr1 or actor.Owner == ussr2 then
			Trigger.RemoveProximityTrigger(trigger)
			Actor.Create("camera", true, { Owner = ussr1, Location = DefenceCam.Location })
			
			Media.DisplayMessage("The facility is on lockdown to protect Einstein.\nYou must find a way to deactivate the defence systems.")
			
			SecurityObjectiveShown = true
			
			objTurrets = ussr1.AddPrimaryObjective("Deactivate the turret defence.")
			objTurrets2 = ussr2.AddPrimaryObjective("Deactivate the turret defence.")
			objGas = ussr1.AddPrimaryObjective("Deactivate the poison gas dispensers.")
			objGas2 = ussr2.AddPrimaryObjective("Deactivate the poison gas dispensers.")
			objMines = ussr1.AddPrimaryObjective("Deactivate the minefield.")
			objMines2 = ussr2.AddPrimaryObjective("Deactivate the minefield.")
		end
	end)

	Trigger.OnEnteredProximityTrigger(TerminalTurrets.CenterPosition, WDist.FromCells(1), function(actor, trigger)
		if actor.Owner == ussr2 and actor.Type == "e6" and SecurityObjectiveShown == true then
			Trigger.RemoveProximityTrigger(trigger)
			
			ussr1.MarkCompletedObjective(objTurrets)
			ussr2.MarkCompletedObjective(objTurrets)
			
			Utils.Do(DefenceTurrets, function(turrets)
				if not turrets.IsDead then
					turrets.Kill()
				end
			end)
		end
	end)

	Trigger.OnEnteredProximityTrigger(TerminalMines.CenterPosition, WDist.FromCells(1), function(actor, trigger)
		if actor.Owner == ussr2 and actor.Type == "e6" and SecurityObjectiveShown == true then
			Trigger.RemoveProximityTrigger(trigger)
			
			ussr1.MarkCompletedObjective(objMines)
			ussr2.MarkCompletedObjective(objMines)
			
			Utils.Do(Minefield, function(mines)
				if not mines.IsDead then
					mines.Kill()
				end
			end)
		end
	end)

	Trigger.OnEnteredProximityTrigger(TerminalGas.CenterPosition, WDist.FromCells(1), function(actor, trigger)
		if actor.Owner == ussr2 and actor.Type == "e6" and SecurityObjectiveShown == true then
			Trigger.RemoveProximityTrigger(trigger)
			
			ussr1.MarkCompletedObjective(objGas)
			ussr2.MarkCompletedObjective(objGas)
			
			GasActive = false
			
			Flare1.Destroy()
			Flare2.Destroy()
			Flare3.Destroy()
			Flare4.Destroy()
		end
	end)

	Trigger.OnEnteredProximityTrigger(TerminalWall.CenterPosition, WDist.FromCells(1), function(actor, trigger)
		if actor.Owner == ussr2 and actor.Type == "e6" and EndingSequence == true then
			Trigger.RemoveProximityTrigger(trigger)
			
			Utils.Do(BrickWall, function(wall)
				if not wall.IsDead then
					wall.Kill()
				end
			end)
		end
	end)

	Trigger.OnEnteredProximityTrigger(TerminalExitPillboxes.CenterPosition, WDist.FromCells(1), function(actor, trigger)
		if actor.Owner == ussr2 and actor.Type == "e6" then
			Trigger.RemoveProximityTrigger(trigger)
			
			Utils.Do(ExitPillboxes, function(boxes)
				if not boxes.IsDead then
					boxes.Kill()
				end
			end)
		end
	end)

--TODO: system uses destroy instead of kill, also dirty hack for second player
	Trigger.OnEnteredFootprint(GasKillArea, function(actor, trigger)
		if GasActive == true and actor.Owner == ussr1 and actor.IsMobile then
			--Trigger.RemoveProximityTrigger(trigger)
			actor.Kill()
		end
		if GasActive == true and actor.Owner == ussr2 and actor.IsMobile then
			--Trigger.RemoveProximityTrigger(trigger)
			actor.Kill()
		end
	end)

	Trigger.OnEnteredProximityTrigger(EinsteinDestination.CenterPosition, WDist.FromCells(1), function(actor, trigger)
		if actor.Type == "einstein" and ChronosphereAlive == true then
			Trigger.RemoveProximityTrigger(trigger)
			actor.Destroy()
			ussr1.MarkFailedObjective(objHitman)
		end
	end)

	Trigger.OnEnteredProximityTrigger(TankCam.CenterPosition, WDist.FromCells(9), function(actor, trigger)
		if actor.Owner == ussr1 or actor.Owner == ussr2 then 
			Trigger.RemoveProximityTrigger(trigger)
			Actor.Create("camera", true, { Owner = ussr1, Location = TankCam.Location })
		end
	end)

	--trigger ending sequence, Einstein tries to flee to the chronosphere
	Trigger.OnEnteredProximityTrigger(FleeTrigger.CenterPosition, WDist.FromCells(4), function(actor, trigger)
		if actor.Owner == ussr1 or actor.Owner == ussr2 then 
			Trigger.RemoveProximityTrigger(trigger)
			
			EndingSequence = true
			
			Einstein.Move(EinsteinDestination.Location)
			
			Utils.Do(EinsteinGuards, function(guards)
				if not guards.IsDead then
					guards.AttackMove(FleeTrigger.Location)
				end
			end)
		
			Reinforcements.Reinforce(allies, { "e1", "e1", "e1", "e1", "e1", "e3", "e3", "e3" } , { LateReinIN.Location, LateReinfMove.Location }, 7, function(latereinf)
				latereinf.AttackMove(EinsteinCam.Location)
			end)
			
			Actor.Create("camera", true, { Owner = ussr1, Location = EinsteinCam.Location })
			Actor.Create("camera", true, { Owner = ussr1, Location = ChronoCam.Location })
			Media.DisplayMessage("Einstein tries to escape! You must stop him!")
			objchrono = ussr1.AddSecondaryObjective("Destroy the Chronosphere\nto prevent Einstein from escaping")
			objchrono2 = ussr2.AddSecondaryObjective("Destroy the Chronosphere\nto prevent Einstein from escaping")
		end
	end)


end

InitObjectives = function()

	enemyobj = allies.AddPrimaryObjective("Deny the Soviets.")
  objHitman = ussr1.AddPrimaryObjective("Eliminate Einstein.")
	objHitman2 = ussr2.AddPrimaryObjective("Eliminate Einstein.")
	objVolkovSurvival = ussr1.AddPrimaryObjective("Volkov must survive.")
	objVolkovSurvival2 = ussr2.AddPrimaryObjective("Volkov must survive.")
	objPOWs = ussr1.AddSecondaryObjective("Free our captured comrades.")
	objPOWs2 = ussr2.AddSecondaryObjective("Free our captured comrades.")
	
end

WorldLoaded = function()
	allies = Player.GetPlayer("GoodGuy")
	england = Player.GetPlayer("England")
	turkey = Player.GetPlayer("Turkey")
  einstein = Player.GetPlayer("France")
	ussr1 = Player.GetPlayer("USSR")
  ussr2 = Player.GetPlayer("Ukraine")

	InitObjectives()
  SetupTriggers()
	
	Camera.Position = Camstart.CenterPosition
	
  
  Trigger.OnObjectiveAdded(ussr1, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
  end)
    
  Trigger.OnObjectiveAdded(ussr2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
  end)

  Trigger.OnObjectiveCompleted(ussr1, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
  end)
    
  Trigger.OnObjectiveCompleted(ussr2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
  end)

  Trigger.OnObjectiveFailed(ussr1, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
  end)
    
  Trigger.OnObjectiveFailed(ussr2, function(p, id)
    Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
  end)

  Trigger.OnPlayerWon(ussr1, function()
    Media.PlaySpeechNotification(ussr1, "MissionAccomplished")
  end)
    
  Trigger.OnPlayerWon(ussr2, function()
    Media.PlaySpeechNotification(ussr2, "MissionAccomplished")
  end)

  Trigger.OnPlayerLost(ussr1, function()
    Media.PlaySpeechNotification(ussr1, "MissionFailed")
  end)
    
  Trigger.OnPlayerLost(ussr2, function()
    Media.PlaySpeechNotification(ussr2, "MissionFailed")
  end)

  Trigger.AfterDelay(DateTime.Seconds(240), function()
		SendVehiclePatrols()
	end)

	Trigger.AfterDelay(DateTime.Seconds(120), function()
		SendInfantryPatrols()
	end)
end