MammothReinforcements = { "htnk", "htnk", "htnk", "msam", "msam", "msam" }
ChemicalReinforcements = { "e5", "e5", "e5", "e5", "ftnk", "ftnk" }
ExtractionHelicopterType = "tran"
EvilGuysTeam = { Sam, Will, Mike }
ExtractionPath = { HeliSpawn.Location, ExtractionLZ.Location }

SendExtractionHelicopter = function()
	heli = Reinforcements.ReinforceWithTransport(player, "tran", nil, ExtractionPath)[1]
	if not Rambo.IsDead then
		Trigger.OnRemovedFromWorld(Rambo, EvacuateHelicopter)
	end
	Trigger.OnRemovedFromWorld(heli, HelicopterGone)
end

EvacuateHelicopter = function()
	if heli.HasPassengers then
		heli.Move(HeliSpawn.Location)
		Trigger.OnIdle(heli, heli.Destroy)
	end
end

HelicopterGone = function()
	if not heli.IsDead then
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			player.MarkCompletedObjective(objEvac)
		end)
	end
end

SendMammothReinforcements = function()
	Reinforcements.Reinforce(player, MammothReinforcements, { mammothOUT.Location, mammothIN.Location })
end

SendChemicalReinforcements = function()
	local chemtroops = Reinforcements.Reinforce(enemy, ChemicalReinforcements, { chemOUT.Location, chemIN.Location })
	Utils.Do(chemtroops, function(a)
    Trigger.OnAddedToWorld(a, function()
      a.AttackMove(ExtractionLZ.Location)
      a.Hunt()
    end)
  end)
end


SetupTriggers = function()

	Trigger.OnAllKilled(EvilGuysTeam, function()
		SendMammothReinforcements()
	end)

	Trigger.OnKilled(Rambo, function()
		player.MarkFailedObjective(objEvac)
	end)

	Trigger.OnKilled(prison, function()
		player.MarkCompletedObjective(objPrison)
		SendExtractionHelicopter()
		SendChemicalReinforcements()
	end)
end

WorldLoaded = function()
	player = Player.GetPlayer("GDI")
	enemy = Player.GetPlayer("Nod")
	
	SetupTriggers()
	
	Camera.Position = camstart.CenterPosition
	
	Trigger.OnObjectiveAdded(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	objPrison = player.AddPrimaryObjective("Destroy the Nod Communications Centre.")
	objEvac = player.AddPrimaryObjective("Evacuate the Commando from the sector.")

	Trigger.OnObjectiveCompleted(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerLost(player, function()
		Media.PlaySpeechNotification(player, "Lose")
	end)
	Trigger.OnPlayerWon(player, function()
		Media.PlaySpeechNotification(player, "Win")
	end)

end
