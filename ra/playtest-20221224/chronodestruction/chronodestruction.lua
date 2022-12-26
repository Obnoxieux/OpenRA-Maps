Tick = function()

	if greece.HasNoRequiredUnits() and goodguy.HasNoRequiredUnits() then
		ussr1.MarkCompletedObjective(goodguy)
	end

	if ussr1.HasNoRequiredUnits() then
		greece.MarkCompletedObjective(BeatUSSR)
	end
end

WorldLoaded = function()
	ussr1 = Player.GetPlayer("USSR")
	goodguy = Player.GetPlayer("GoodGuy")
	greece = Player.GetPlayer("Greece")
	
	Trigger.OnObjectiveAdded(ussr1, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)
	
	objChrono = ussr1.AddPrimaryObjective("Destroy the Allied Chronosphere.")
	objMiss = ussr1.AddPrimaryObjective("Capture the Allied Research Lab.")
	objBio = ussr1.AddPrimaryObjective("Capture the Allied Biochemical Facility.")
	objWipeOut = ussr1.AddSecondaryObjective("Annihilate all Allied presence.")

	BeatCommies = greece.AddPrimaryObjective("Defeat the Soviet forces.")
	
	Trigger.OnObjectiveCompleted(ussr1, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(ussr1, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerLost(ussr1, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(ussr1, "MissionFailed")
		end)
	end)
	Trigger.OnPlayerWon(ussr1, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(ussr1, "MissionAccomplished")
		end)
	end)
	
	Camera.Position = camstart.CenterPosition
	
	--Trigger.AfterDelay(ActivateAIDelay, ActivateAI)
end