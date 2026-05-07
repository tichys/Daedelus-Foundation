/mob/living/simple_animal/hostile/zombie/scp049_1
	var/mob/living/scp/scp049/master
	var/obedience_level = 50
	var/decay_timer
	var/decay_interval = 60 SECONDS
	var/last_decay_check = 0
	var/decay_health_loss = 5
	var/current_command = "guard"
	AIStatus = AI_ON

/mob/living/simple_animal/hostile/zombie/scp049_1/proc/setup_servant(mob/living/scp/scp049/creator)
	master = creator
	obedience_level = 80
	decay_timer = world.time
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/zombie/scp049_1/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(master && master.command_system)
		master.command_system.on_servant_death(src)
	return ..()

/mob/living/simple_animal/hostile/zombie/scp049_1/process()
	if(world.time >= last_decay_check + decay_interval)
		process_decay()
		last_decay_check = world.time

/mob/living/simple_animal/hostile/zombie/scp049_1/proc/process_decay()
	maxHealth = max(30, maxHealth - decay_health_loss)
	if(health > maxHealth)
		health = maxHealth
	if(master)
		var/distance = get_dist(src, master)
		if(distance > 10)
			obedience_level = max(0, obedience_level - 2)
		else
			obedience_level = min(100, obedience_level + 1)

/mob/living/simple_animal/hostile/zombie/scp049_1/Found(atom/A)
	if(istype(A, /mob/living/carbon/human) && HAS_TRAIT(A, TRAIT_PESTILENCE))
		return A
	return ..()

/mob/living/simple_animal/hostile/zombie/scp049_1/CanAttack(atom/the_target)
	if(!the_target)
		return FALSE
	if(istype(the_target, /mob/living/simple_animal/hostile/zombie/scp049_1))
		return FALSE
	if(istype(the_target, /mob/living/scp/scp049))
		return FALSE
	if(faction_check_mob(the_target, TRUE))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/zombie/scp049_1/LoseTarget()
	. = ..()
	if(current_command == "attack" && master)
		FindTarget()

/mob/living/simple_animal/hostile/zombie/scp049_1/proc/set_command(command)
	current_command = command
	switch(command)
		if("follow")
			if(master)
				Goto(master, move_to_delay, 2)
		if("guard")
			stop_automated_movement = 0
			LoseTarget()
		if("attack")
			FindTarget()
		if("spread")
			var/turf/random_turf = get_step(src, pick(GLOB.cardinals))
			if(random_turf)
				Goto(random_turf, move_to_delay, 1)

/mob/living/simple_animal/hostile/zombie/scp049_1/death(gibbed)
	if(master && master.command_system)
		master.command_system.on_servant_death(src)
	return ..()

/datum/scp049_command_system
	var/mob/living/scp/scp049/owner
	var/list/servants = list()
	var/process_interval = 30 SECONDS
	var/last_process = 0
	var/obedience_decay_distance = 10
	var/obedience_decay_amount = 2
	var/obedience_regen_amount = 1

/datum/scp049_command_system/New(mob/living/scp/scp049/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/scp049_command_system/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/simple_animal/hostile/zombie/scp049_1/servant in servants)
		servant.master = null
	servants.Cut()
	return ..()

/datum/scp049_command_system/process()
	if(world.time >= last_process + process_interval)
		process_servants()
		last_process = world.time

/datum/scp049_command_system/proc/process_servants()
	var/list/to_remove = list()
	for(var/mob/living/simple_animal/hostile/zombie/scp049_1/servant in servants)
		if(QDELETED(servant) || servant.stat == DEAD)
			to_remove += servant
			continue
		if(!owner || QDELETED(owner))
			continue
		var/distance = get_dist(servant, owner)
		if(distance > obedience_decay_distance)
			servant.obedience_level = max(0, servant.obedience_level - obedience_decay_amount)
		else
			servant.obedience_level = min(100, servant.obedience_level + obedience_regen_amount)
	for(var/mob/living/simple_animal/hostile/zombie/scp049_1/servant in to_remove)
		servants -= servant

/datum/scp049_command_system/proc/command_servants(command)
	if(!owner)
		return
	var/commanded = 0
	for(var/mob/living/simple_animal/hostile/zombie/scp049_1/servant in servants)
		if(QDELETED(servant) || servant.stat == DEAD)
			continue
		if(servant.obedience_level < rand(1, 100))
			continue
		servant.set_command(command)
		commanded++
	if(commanded > 0)
		to_chat(owner, span_notice("[commanded] servant\s heeds your command: [command]."))
	else
		to_chat(owner, span_warning("No servants obeyed your command."))

/datum/scp049_command_system/proc/register_servant(mob/living/simple_animal/hostile/zombie/scp049_1/servant)
	if(!servant || QDELETED(servant))
		return
	servant.master = owner
	servant.obedience_level = 80
	servants += servant

/datum/scp049_command_system/proc/on_servant_death(mob/living/simple_animal/hostile/zombie/scp049_1/servant)
	if(!servant)
		return
	servants -= servant
	servant.master = null

/datum/action/innate/scp_ability/scp049_command
	name = "Command Servants"
	desc = "Issue a command to your SCP-049-1 servants."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "command"
	background_icon_state = "bg_default"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/scp049_command/Activate()
	var/mob/living/scp/scp049/scp_mob = owner
	if(!istype(scp_mob))
		return
	if(!scp_mob.command_system)
		to_chat(scp_mob, span_warning("You have no command system initialized."))
		return
	if(!length(scp_mob.command_system.servants))
		to_chat(scp_mob, span_warning("You have no servants to command."))
		return
	var/command = input(scp_mob, "Choose a command for your servants:", "Command Servants") as null|anything in list("follow", "guard", "attack", "spread")
	if(!command)
		return
	start_cooldown()
	scp_mob.command_system.command_servants(command)
