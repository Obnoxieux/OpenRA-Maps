PlayerStartUnits = { "1tnk", "1tnk", "2tnk", "arty" }
MCVTeam = { "2tnk", "2tnk", "2tnk", "2tnk", "mcv" }

BarricadePatrol = { barrpatrol1, barrpatrol2, barrpatrol3 }
VillagePatrol = { villpatrol1, villpatrol2, villpatrol3, villpatrol4, villpatrol5, villpatrol6 }
SovietBarricade = { barrtank1, barrtank2, barrtank3, barrtank4, barrflame1, barrflame2, barrrax, barrpp1, barrpp2, barrpp3, barrsam }
EnglandOutpost = { engpostrax, engpostgun, engpostpbox, engpostpp, engpostflak }

BarricadePatrolPath = { patrol1.Location, att5.Location, att6.Location }
VillagePatrolPath = { att3.Location, patrol3.Location, patrol4.Location, att2.Location }

Tick = function()
	if ussr.HasNoRequiredUnits() and badguy.HasNoRequiredUnits() then
		allies.MarkCompletedObjective(objKillAll)
	end
end

SendPatrols = function()
	Utils.Do(BarricadePatrol, function(patrolguys)
    patrolguys.Patrol(BarricadePatrolPath, true, 20)
  end)

	Utils.Do(VillagePatrol, function(patrolguys)
    patrolguys.Patrol(VillagePatrolPath, true, 20)
  end)
end

SetupTriggers = function()
  
	Trigger.OnAllKilledOrCaptured(SovietBarricade, function()
		allies.MarkCompletedObjective(objClearWay)
		Reinforcements.ReinforceWithTransport (allies, "lst", MCVTeam, { boatspawn.Location, boatunload.Location}, { boatspawn.Location})
		Media.DisplayMessage("Commander, MCV reinforcements have arrived in the south now that the way is free.")
	end)

	Trigger.OnAllKilled(EnglandOutpost, function()
		allies.MarkFailedObjective(objSaveEngland)
	end)

end

InitObjectives = function()
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	ussrObj = ussr.AddPrimaryObjective("Make a Hoola-Hoop.")
	objClearWay = allies.AddPrimaryObjective("Destroy the Soviet barricade on the eastern river bank.")
  objKillAll = allies.AddPrimaryObjective("Take the western river bank and\nclear the sector of all Soviet presence.")
	objSaveEngland = allies.AddSecondaryObjective("Prevent the destruction of our southern outpost.")

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
	ussr = Player.GetPlayer("USSR")
  badguy = Player.GetPlayer("BadGuy")
  

	InitObjectives()
  SetupTriggers()
	SendPatrols()
  
  Reinforcements.Reinforce(allies, PlayerStartUnits, { alliesspawn.Location, alliesmove.Location })
  
  ActivateAI()
	
  Trigger.AfterDelay(DateTime.Seconds(30), SendSovietInvasion)
  
	start1.AttackMove(att9.Location)
	start2.AttackMove(att9.Location)
	start3.AttackMove(att9.Location)
	start4.AttackMove(att9.Location)
  end)
end