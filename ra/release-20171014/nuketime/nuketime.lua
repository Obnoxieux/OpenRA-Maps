ActivateAI = function()

  allies.Cash = 100000

	Trigger.AfterDelay(DateTime.Seconds(2), function()
		ProduceInfantry()
		ProduceTanks()
		ProduceAircraft()
		ProduceNavy()
	end)
end

SetupTriggers = function()

  Trigger.OnKilled(NukeTruck, function()
		ussr1.MarkFailedObjective(objStreber)
		ussr2.MarkFailedObjective(objStreber2)
	end)

  Trigger.OnEnteredProximityTrigger(VillageCentre.CenterPosition, WDist.FromCells(4), function(actor, trigger)
		if actor.Owner == ussr1 then
			Trigger.RemoveProximityTrigger(trigger)
			AlliedTownParatroopers()
		end
	end)

  Trigger.OnEnteredProximityTrigger(SovietParatroopers1.CenterPosition, WDist.FromCells(8), function(actor, trigger2)
		if actor.Owner == ussr1 then
			Trigger.RemoveProximityTrigger(trigger2)
			SovietOutpostParatroopersRed()
      SovietOutpostParatroopersOrange()
		end
	end)

  Trigger.OnCapture(SubPen, function()
		ussr1.MarkCompletedObjective(objOutpost)
		ussr2.MarkCompletedObjective(objOutpost2)
	end)

  Trigger.AfterDelay(ReinforcementsDelay, SpawnSovietReinforcements)

end

InitObjectives = function()

	enemyobj = allies.AddPrimaryObjective("Deny the Soviets.")
	objEscortTruck = ussr2.AddPrimaryObjective("Escort the Truck with nuclear material to our facility.")
	objperfect = ussr2.AddSecondaryObjective("Prevent the Tuck from getting damaged at all.")
  objDefendBase = ussr1.AddPrimaryObjective("Defend the nuclear processing plants.")
	objKillAll = ussr1.AddPrimaryObjective("Eliminate all Allied presence in the sector")
	objKillAll = ussr2.AddPrimaryObjective("Eliminate all Allied presence in the sector")
	
end

WorldLoaded = function()
	allies = Player.GetPlayer("Allies")
  england = Player.GetPlayer("England")
	ussr1 = Player.GetPlayer("USSR1")
  ussr2 = Player.GetPlayer("USSR2")

	InitObjectives()
	ActivateAI()
  SetupTriggers()
	
	spy1.DisguiseAsType("e1", ussr1)
	spy2.DisguiseAsType("e1", ussr1)
	spy3.DisguiseAsType("e1", ussr1)
  
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
    Media.PlaySpeechNotification(player, "MissionAccomplished")
  end)
    
  Trigger.OnPlayerWon(ussr2, function()
    Media.PlaySpeechNotification(player, "MissionAccomplished")
  end)

  Trigger.OnPlayerLost(ussr1, function()
    Media.PlaySpeechNotification(player, "MissionFailed")
  end)
    
  Trigger.OnPlayerLost(ussr2, function()
    Media.PlaySpeechNotification(player, "MissionFailed")
  end)

  Trigger.AfterDelay(DateTime.Seconds(5), function()
		ParadropAlliedUnits()
	end)

end