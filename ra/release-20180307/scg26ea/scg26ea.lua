-- Fresh Tracks

SovietAttackerWays = { { EntryNorthEdgeLeft.Location, EntryNorthEdgeLeftMove.Location },	{ EntryNorthEdgeMiddle.Location, EntryNorthEdgeMiddleMove.Location }, { EntryNorthEdgeRight.Location, EntryNorthEdgeRightMove.Location }, { EntrySouthEdgeLeft.Location, EntrySouthEdgeLeftMove.Location }, { EntryLeftEdgeNorth.Location, EntryLeftEdgeNorthMove.Location } }

SovietAttackTeams = { { "3tnk", "3tnk", "e1", "e1", "e2" }, { "3tnk", "e1", "e4", "e1", "e1" }, { "3tnk", "e1", "e4", "e1", "e1" }, { "e2", "e1", "e4", "e1", "e1" }, { "3tnk", "4tnk", "e1", "e1", "e1" }, { "ttnk", "e1", "e4", "shok", "e1" } }

Convoy1 = { "3tnk", "e1", "e1", "e1" }
Convoy2 = { "3tnk", "3tnk", "e1", "e1", "e1", "e2" }
Convoy3 = { "3tnk", "ttnk", "e1", "e1", "e1", "e2" }
Convoy4 = { "3tnk", "3tnk", "ttnk", "e1", "e1", "e1", "e2" }
Convoy5 = { "4tnk", "3tnk", "e1", "e1", "e4", "e2" }
Convoy6 = { "4tnk", "4tnk", "e1", "e1", "e4", "e2" }
Convoy7 = { "4tnk", "4tnk", "ttnk", "ttnk", "3tnk" }

ConvoyActualTrucks = { "truk", "truk", "truk" }

--ConvoyRoute1 = { }

IdleHunt = function(unit) if not unit.IsDead then Trigger.OnIdle(unit, unit.Hunt) end end

SendConvoy1 = function()
  Actor.Create("flare", true, { Owner = england, Location = ExitRight.Location })
  Media.PlaySpeechNotification(allies, "ConvoyApproaching")
	Reinforcements.Reinforce(ussr, Convoy1, { EntrySouthEdgeLeft.Location, EntrySouthEdgeLeftMove.Location }, 5, function(convoyescort)
    convoyescort.AttackMove(WP5.Location)
    convoyescort.AttackMove(WP4.Location)
    convoyescort.AttackMove(WP14.Location)
    convoyescort.AttackMove(WP15.Location)
	end)
  Trigger.AfterDelay(DateTime.Seconds(4), function()
    Reinforcements.Reinforce(ussr, ConvoyActualTrucks, { EntrySouthEdgeLeft.Location, EntrySouthEdgeLeftMove.Location }, 5, function(convoy)
      convoy.Move(WP5.Location)
      convoy.Move(WP4.Location)
      convoy.Move(WP14.Location)
      convoy.Move(WP15.Location)
      convoy.Move(ExitRight.Location)
    end)
  end)
end

SendConvoy2 = function()
  Actor.Create("flare", true, { Owner = england, Location = ExitNorth.Location })
  Media.PlaySpeechNotification(allies, "ConvoyApproaching")
	Reinforcements.Reinforce(ussr, Convoy2, { EntryLeftEdgeNorth.Location, EntryLeftEdgeNorthMove.Location }, 5, function(convoyescort)
    convoyescort.AttackMove(WP1.Location)
    convoyescort.AttackMove(WP3.Location)
    convoyescort.AttackMove(WP2.Location)
    convoyescort.AttackMove(WP6.Location)
    convoyescort.AttackMove(EntryNorthEdgeRightMove.Location)
    convoyescort.AttackMove(WP10.Location)
	end)
  Trigger.AfterDelay(DateTime.Seconds(4), function()
    Reinforcements.Reinforce(ussr, ConvoyActualTrucks, { EntryLeftEdgeNorth.Location, EntryLeftEdgeNorthMove.Location }, 5, function(convoy)
      convoy.Move(WP1.Location)
      convoy.Move(WP3.Location)
      convoy.Move(WP2.Location)
      convoy.Move(WP6.Location)
      convoy.Move(EntryNorthEdgeRightMove.Location)
      convoy.Move(WP10.Location)
      convoy.Move(ExitNorth.Location)
    end)
  end)
end

SendConvoy3 = function()
  Actor.Create("flare", true, { Owner = england, Location = ExitSouth.Location })
  Media.PlaySpeechNotification(allies, "ConvoyApproaching")
	Reinforcements.Reinforce(ussr, Convoy3, { EntryNorthEdgeLeft.Location, EntryNorthEdgeLeftMove.Location }, 5, function(convoyescort)
    convoyescort.AttackMove(EntryNorthEdgeMiddleMove.Location)
    convoyescort.AttackMove(WP2.Location)
    convoyescort.AttackMove(WP6.Location)
    convoyescort.AttackMove(WP7.Location)
    convoyescort.AttackMove(WP11.Location)
    convoyescort.AttackMove(WP14.Location)
	end)
  Trigger.AfterDelay(DateTime.Seconds(4), function()
    Reinforcements.Reinforce(ussr, ConvoyActualTrucks, { EntryNorthEdgeLeft.Location, EntryNorthEdgeLeftMove.Location }, 5, function(convoy)
      convoy.Move(EntryNorthEdgeMiddleMove.Location)
      convoy.Move(WP2.Location)
      convoy.Move(WP6.Location)
      convoy.Move(WP7.Location)
      convoy.Move(WP11.Location)
      convoy.Move(WP14.Location)
      convoy.Move(ExitSouth.Location)
    end)
  end)
end

SendConvoy4 = function()
  Media.PlaySpeechNotification(allies, "ConvoyApproaching")
	Reinforcements.Reinforce(ussr, Convoy4, { EntryNorthEdgeLeft.Location, EntryNorthEdgeLeftMove.Location }, 5, function(convoyescort)
    convoyescort.AttackMove(EntryLeftEdgeNorthMove.Location)
    convoyescort.AttackMove(WP1.Location)
    convoyescort.AttackMove(WP3.Location)
    convoyescort.AttackMove(WP2.Location)
    convoyescort.AttackMove(WP6.Location)
    convoyescort.AttackMove(WP7.Location)
    convoyescort.AttackMove(WP11.Location)
    convoyescort.AttackMove(WP13.Location)
    convoyescort.AttackMove(WP15.Location)
	end)
  Trigger.AfterDelay(DateTime.Seconds(4), function()
    Reinforcements.Reinforce(ussr, ConvoyActualTrucks, { EntryNorthEdgeLeft.Location, EntryNorthEdgeLeftMove.Location }, 5, function(convoy)
      convoy.Move(EntryLeftEdgeNorthMove.Location)
      convoy.Move(WP1.Location)
      convoy.Move(WP3.Location)
      convoy.Move(WP2.Location)
      convoy.Move(WP6.Location)
      convoy.Move(WP7.Location)
      convoy.Move(WP11.Location)
      convoy.Move(WP13.Location)
      convoy.Move(WP15.Location)
      convoy.Move(ExitRight.Location)
    end)
  end)
end

SendConvoy5 = function()
  Media.PlaySpeechNotification(allies, "ConvoyApproaching")
	Reinforcements.Reinforce(ussr, Convoy5, { EntryNorthEdgeMiddle.Location, EntryNorthEdgeMiddleMove.Location }, 5, function(convoyescort)
    convoyescort.AttackMove(WP2.Location)
    convoyescort.AttackMove(WP6.Location)
    convoyescort.AttackMove(WP7.Location)
    convoyescort.AttackMove(WP8.Location)
    convoyescort.AttackMove(WP14.Location)
	end)
  Trigger.AfterDelay(DateTime.Seconds(4), function()
    Reinforcements.Reinforce(ussr, ConvoyActualTrucks, { EntryNorthEdgeMiddle.Location, EntryNorthEdgeMiddleMove.Location }, 5, function(convoy)
      convoy.Move(WP2.Location)
      convoy.Move(WP6.Location)
      convoy.Move(WP7.Location)
      convoy.Move(WP8.Location)
      convoy.Move(WP14.Location)
      convoy.Move(ExitSouth.Location)
    end)
  end)
end

SendConvoy6 = function()
  Media.PlaySpeechNotification(allies, "ConvoyApproaching")
	Reinforcements.Reinforce(ussr, Convoy6, { EntryLeftEdgeSouth.Location, EntryLeftEdgeSouthMove.Location }, 5, function(convoyescort)
    convoyescort.AttackMove(WP1.Location)
    convoyescort.AttackMove(WP3.Location)
    convoyescort.AttackMove(WP9.Location)
    convoyescort.AttackMove(WP14.Location)
	end)
  Trigger.AfterDelay(DateTime.Seconds(4), function()
    Reinforcements.Reinforce(ussr, ConvoyActualTrucks, { EntryLeftEdgeSouth.Location, EntryLeftEdgeSouthMove.Location }, 5, function(convoy)
      convoy.Move(WP1.Location)
      convoy.Move(WP3.Location)
      convoy.Move(WP9.Location)
      convoy.Move(WP14.Location)
      convoy.Move(ExitSouth.Location)
    end)
  end)
end

SendConvoy7 = function()
  Media.PlaySpeechNotification(allies, "ConvoyApproaching")
	Reinforcements.Reinforce(ussr, Convoy7, { EntryNorthEdgeRight.Location, EntryNorthEdgeRightMove.Location }, 5, function(convoyescort)
    convoyescort.AttackMove(WP10.Location)
    convoyescort.AttackMove(ExitNorth.Location)
	end)
  Trigger.AfterDelay(DateTime.Seconds(4), function()
    lastconvoy = Reinforcements.Reinforce(ussr, ConvoyActualTrucks, { EntryNorthEdgeRight.Location, EntryNorthEdgeRightMove.Location }, 5, function(convoy)
      convoy.Move(WP10.Location)
      convoy.Move(ExitNorth.Location)
    end)
		Trigger.OnAllKilled(lastconvoy, function()
			allies.MarkCompletedObjective(objKillConvoys)
		end)
  end)
end

--[[old workaround to complete mission

WinMission = function()
  allies.MarkCompletedObjective(objKillConvoys)
end]]

SendSovietAttacks = function()
	local way = Utils.Random(SovietAttackerWays)
	local units = Utils.Random(SovietAttackTeams)
	Reinforcements.Reinforce(ussr, units , way, 7, function(sovietattackers)
    sovietattackers.AttackMove(AlliedBase.Location)
    sovietattackers.Hunt()
	end)

	Trigger.AfterDelay(DateTime.Seconds(170), SendSovietAttacks)
end

SetupTriggers = function()
  Trigger.OnEnteredProximityTrigger(ExitRight.CenterPosition, WDist.FromCells(1), function(actor, triggerlose1)
    if actor.Owner == ussr and actor.Type == "truk" then
      Trigger.RemoveProximityTrigger(triggerlose1)
      actor.Destroy()
      allies.MarkFailedObjective(objKillConvoys)
    end
  end)

  Trigger.OnEnteredProximityTrigger(ExitSouth.CenterPosition, WDist.FromCells(1), function(actor, triggerlose2)
    if actor.Owner == ussr and actor.Type == "truk" then
      Trigger.RemoveProximityTrigger(triggerlose2)
      actor.Destroy()
      allies.MarkFailedObjective(objKillConvoys)
    end
  end)

  Trigger.OnEnteredProximityTrigger(ExitNorth.CenterPosition, WDist.FromCells(1), function(actor, triggerlose3)
    if actor.Owner == ussr and actor.Type == "truk" then
      Trigger.RemoveProximityTrigger(triggerlose3)
      actor.Destroy()
      allies.MarkFailedObjective(objKillConvoys)
    end
  end)
end

--[[SetupBridgeStates = function()
  
  Trigger.OnKilled(BridgeBarrel1, function()
    local bridge1 = Map.ActorsInCircle(BridgePoint1.Location, 4, function(self) return self.Type == "bridge1" end)[1]
    
    if not bridge1.IsDead then
      bridge1.Kill()
    end
  end)

  Trigger.OnKilled(BridgeBarrel2, function()
    local bridge2 = Map.ActorsInCircle(BridgePoint2.Location, 4, function(self) return self.Type == "bridge1" end)[1]
    
    if not bridge2.IsDead then
      bridge2.Kill()
    end
  end)

  Trigger.OnKilled(BridgeBarrel3, function()
    local bridge3 = Map.ActorsInCircle(BridgePoint3.Location, 4, function(self) return self.Type == "bridge1" end)[1]
    
    if not bridge3.IsDead then
      bridge3.Kill()
    end
  end)

  --Trigger.OnAllKilled(
end]]

InitObjectives = function()
	Trigger.OnObjectiveAdded(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	ussrObj = ussr.AddPrimaryObjective("Make a Hoola-Hoop.")
	objKillConvoys = allies.AddPrimaryObjective("Destroy all trucks from all seven Soviet convoys.")
  --objKillBridges = allies.AddSecondaryObjective("Destroy all bridges to block convoy routes.")

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
	allies = Player.GetPlayer("Allies")
	ussr = Player.GetPlayer("USSR")
  england = Player.GetPlayer("England")
  
  PatrolMammoth.Patrol({ WP2.Location, WP6.Location, WP7.Location, WP8.Location, WP3.Location }, true, 15)
  
  Camera.Position = DefaultCameraPosition.CenterPosition

	InitObjectives()
  SetupTriggers()
  --SetupBridgeStates()
  
  Trigger.AfterDelay(DateTime.Seconds(3), SendSovietAttacks)
  Trigger.AfterDelay(DateTime.Minutes(11), SendConvoy1)
  Trigger.AfterDelay(DateTime.Minutes(15), SendConvoy2)
  Trigger.AfterDelay(DateTime.Minutes(19), SendConvoy3)
  Trigger.AfterDelay(DateTime.Minutes(23), SendConvoy4)
  Trigger.AfterDelay(DateTime.Minutes(27), SendConvoy5)
  Trigger.AfterDelay(DateTime.Minutes(31), SendConvoy6)
  Trigger.AfterDelay(DateTime.Minutes(35), SendConvoy7) --was 44
  --Trigger.AfterDelay(DateTime.Minutes(38), WinMission) --this is temporary until I can find a better solution
end