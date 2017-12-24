SovietInfantryTypes = { "e1", "e1", "e1", "e2", "e2", "e4" } --this defines which types of infantry units the Soviet player will be using for attacks. You will have to know the internal engine names, they're used in the editor.
SovietArmorTypes = { "3tnk", "3tnk"} --the same as the above for tanks. As they're chosen at random, I could have also used "3tnk" once with the same effect. However, you can make the AI prefer a certain type by including it more than the other types. (Ex. types = { "3tnk, "3tnk", "v2rl" } will return 66,6% Heavy Tanks and 33,3% V2 Rocket Launchers.
SovietAircraftType = { "yak" } --not used here. If you want a challenge, complete the script and make the Soviets use aircraft!

SovietAttackPath = { AttackPoint } --this defines the waypath the Soviets will use to attack the player. Here, just the middle of the Allied base is used. If you include more than one waypoint, the units will move along them in order.

InfAttack = { } --these are necessary to define a variable for the attacking teams (see below) before they are created. You must use one of those for each team.
TankAttack = { } --same as above

BuildVehicles = true
TrainInfantry = true
Attacking = true

Tick = function() --this lets you win the mission! Tick means the function conditions are checked at every game tick - so effectively constantly
	if ussr.HasNoRequiredUnits() then --meaning all units with the "MustBeDestroyed" trait belonging to player "ussr" have been destroyed
		allies.MarkCompletedObjective(KillAll) --the primary objective with the name "KillAll" belonging to player "allies" is marked as completed. Since it is the only primary objective, the mission ends in victory immediately.
	end
end

IdleHunt = function(unit) if not unit.IsDead then Trigger.OnIdle(unit, unit.Hunt) end end --I have no clue about this tbh - copied it from a campaign mission


ProduceInfantry = function() --this is the main looping function telling the AI to produce infantry and what to do with it.

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9)) --this is just a minor randomiser to make the unit production seem less streamlined
	local toBuild = { Utils.Random(SovietInfantryTypes) } --this defines a local variable to tell the Soviets which types of infantry to use. Here, a random unit is built from the entry "SovietInfantryTypes" above.
	ussr.Build(toBuild, function(unit) --this initiates the actual building process: player "ussr" starts to build a unit of type "toBuild" that is defined in the preceding line, the built unit is afterwards referred to as "unit"
		InfAttack[#InfAttack + 1] = unit[1] --I don't fully get this line, but I infer that if a unit is built, 1 is added to the unit counter

		if #InfAttack >= 6 then --this number is crucial: it defines the amount of infantry the Soviets are going to throw at you in one wave. In this case, it is 6. You can freely adjust this number.
			SendUnits(InfAttack, SovietAttackPath) --this tells the AI what to do with the units after building them - it is defined in the function below, but means: the team "InfAttack" is sent along the way "SovietAttackPath"
			InfAttack = { } -- this is necessary to reset the unit count to zero after the attack
			Trigger.AfterDelay(DateTime.Minutes(3), ProduceInfantry) --this tells the game when to start producing the same team again after successfully completing it and having sent it to attack. You can again use any number or change the minutes amount to seconds.
		else
			Trigger.AfterDelay(delay, ProduceInfantry) --you can see in the "if"-structure that this just means "if I have built a unit, but still have not reached the goal of having at least 6, I continue building"
		end
	end)
end

ProduceTanks = function() --this is the same as above but with tanks. You can see that it is functionally identical, but all instances of "InfAttack" have been replaced with "TankAttack" and the time variables differ a bit. You can of course use a different attack path if you want.

--------------some more general remarks about unit production:
--If you order an AI player to produce a unit he is incapable of producing due to its prerequisites (e.g. telling the Soviets to build Heavy Tanks without having a Service Depot), he will simply not do anything if this unit is called during the random selection process, stopping the loop of the attack function as well. You therefore should always make sure that the AI is actually able to build that specific unit, or alternatively remove the prerequisites in rules.yaml.
--so far I have not been able to make an AI player use more than one function in the same production queue. So you can only use infantry in one function, vehicles in another and aircraft in a third, but not two different functions for vehicles for example (may be different in TD, not tested) or mix infantry and tanks in the same attack team. (?) You can circumvent this by creating a second AI player though.
--it does not seem that the AI cheats money on its own. So if it is not building, it might simply have run out of cash.

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17)) --a bit more delay between building tanks
	local toBuild = { Utils.Random(SovietArmorTypes) }
	ussr.Build(toBuild, function(unit)
		TankAttack[#TankAttack + 1] = unit[1]

		if #TankAttack >= 2 then --two tanks are enough here
			SendUnits(TankAttack, SovietAttackPath)
			TankAttack = { }
			Trigger.AfterDelay(DateTime.Minutes(3), ProduceTanks) --same delay
		else
			Trigger.AfterDelay(delay, ProduceTanks)
		end
	end)
end

SendUnits = function(units, waypoints) --this is the function that actually sends the units on the attack. You may note that we can use just (units, waypoints) because we have defined the units earlier in "SendUnits(InfAttack, SovietAttackPath)"
	Utils.Do(units, function(unit)
		if not unit.IsDead then
			Utils.Do(waypoints, function(waypoint)
				unit.AttackMove(waypoint.Location) --this means attack move follow the waypoint path defined at the start
			end)
			unit.Hunt() --start hunting if finished (?)
		end
	end)
end

InitProductionBuildings = function()
	if not Wafa.IsDead then
		Wafa.IsPrimaryBuilding = true --this marks the building named "Wafa" in map.yaml as the primary building - not necessary, but useful for determining the direction of the enemy if he has more than one Warfactory
		Trigger.OnKilled(Wafa, function() BuildVehicles = false end) --probably deprecated
	else
		BuildVehicles = false
	end

	if not Rax.IsDead then
		Rax.IsPrimaryBuilding = true --the same as above, but for a barracks called "Rax"
		Trigger.OnKilled(Rax, function() TrainInfantry = false end)
	else
		TrainInfantry = false
	end
end

ActivateAI = function() --this function tells the AI to start production

	InitProductionBuildings() --as below: calls the function with this name, directly above this one

	Trigger.AfterDelay(DateTime.Seconds(10), function() --this calls the two attack functions below, but with a 10 second delay. You can adjust this delay if you want the enemy attacks to start later to give the human player some time to build up.
		ProduceInfantry()
		ProduceTanks()
	end)
end

InitObjectives = function()
	
	ussrObj = ussr.AddPrimaryObjective("Deny the Allies.") --this adds an objective for the AI. One way to make the human player lose the game is to mark this as completed - which I have not done in this script.
	KillAll = allies.AddPrimaryObjective("Eliminate all Soviet units in this area.") --this adds an objective for the human player, which is much more important because it is visible in the game. The first part in front of the "=" is the internal name of the objective that can be referred to later. You can use Primary and Secondary, depending on the objective. I would advise not to use a very long description string because it needs to fit in the UI - long descriptions belong into the "Briefing" entry in map.yaml or rules.yaml.

	Trigger.OnObjectiveAdded(allies, function(p, id) --the next five basically can be copied in every mission (of course adjusted for player designations) as they just tell the game to play sounds and display texts for the objectives.
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)
	
	Trigger.OnObjectiveCompleted(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(allies, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerLost(allies, function()
		Media.PlaySpeechNotification(player, "Lose")
	end)
	Trigger.OnPlayerWon(allies, function()
		Media.PlaySpeechNotification(player, "Win")
	end)
end

WorldLoaded = function() --the most important function - it gets the game started! This function is called immediately when the game starts.
	allies = Player.GetPlayer("Allies") --tell the game which player is afterwards defined as "allies". The second part after "Player.GetPlayer" needs to be filled with a player designation from map.yaml. To avoid confusion between the two, I did not use a capitalised a for the Lua definition.
	ussr = Player.GetPlayer("USSR") --the same as above for the Soviets

	InitObjectives() --this immediately calls the function with this name without any conditions
	ActivateAI() --same
end
