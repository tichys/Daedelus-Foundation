// SCP-096 - The Shy Guy
// Becomes aggressive when its face is seen

/mob/living/carbon/scp/scp096
	name = "SCP-096"
	desc = "A tall, thin humanoid figure with pale skin and long arms. It appears to be covering its face."
	icon = 'icons/scp/scp-096.dmi'
	icon_state = "scp096"
	real_name = "SCP-096"

	// SCP-096 specific variables
	var/state = "idle" // idle, screaming, chasing, slaughter
	var/mob/living/current_target = null
	var/scream_cooldown = 0
	var/scream_cooldown_time = 30 SECONDS
	var/rage_duration = 0
	var/rage_duration_time = 5 MINUTES

	// Persistence tracking
	var/kills_count = 0
	var/rage_activations = 0
	var/last_rage_time = 0

/mob/living/carbon/scp/scp096/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-096",
		SCP_KETER,
		"096",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 25
	SCP_datum.min_time = 45 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 500
	scp_health = max_scp_health
	max_scp_armor = 200
	scp_armor = max_scp_armor

	// Add SCP abilities
	add_ability("scream", "scream_ability")
	add_ability("rage_mode", "rage_mode_ability")

	// Add passive effects
	add_passive_effect("face_obsession")
	add_passive_effect("rage_escalation")

/mob/living/carbon/scp/scp096/Destroy()
	current_target = null
	return ..()

// Override core mechanics
/mob/living/carbon/scp/scp096/process_scp_effects()
	. = ..()

	switch(state)
		if("idle")
			// Check if anyone has seen our face
			for(var/mob/living/carbon/human/H in view(7, src))
				if(H.SCP)
					continue
				if(can_see(H, src) && world.time >= scream_cooldown)
					trigger_rage(H)
					break

		if("screaming")
			// Scream for a moment, then start chasing
			if(world.time >= rage_duration)
				start_chasing()

		if("chasing")
			// Chase the target
			if(current_target && current_target.stat != DEAD)
				if(get_dist(src, current_target) <= 1)
					start_slaughter()
				else
					step_towards(src, current_target)
			else
				// Target is dead or gone, find new target
				find_new_target()

		if("slaughter")
			// Kill everything in sight
			for(var/mob/living/L in view(3, src))
				if(L == src || L.SCP)
					continue
				UnarmedAttack(L)

// Trigger rage when face is seen
/mob/living/carbon/scp/scp096/proc/trigger_rage(mob/living/carbon/human/viewer)
	state = "screaming"
	current_target = viewer
	scream_cooldown = world.time + scream_cooldown_time
	rage_duration = world.time + 3 SECONDS

	// Track rage activation for persistence
	rage_activations++
	last_rage_time = world.time
	breach_containment()

	// Update persistence system
	add_interaction_record(viewer, "rage_triggered")

	// Scream animation and sound
	icon_state = "scp096-screaming"
	visible_message("<span class='danger'>[src] lets out a blood-curdling scream!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 100, TRUE)

	// Stun nearby targets
	for(var/mob/living/carbon/L in view(5, src))
		if(L == src || L.SCP)
			continue
		L.stamina.adjust(-25)

// Start chasing the target
/mob/living/carbon/scp/scp096/proc/start_chasing()
	state = "chasing"
	icon_state = "scp096-chasing"
	visible_message("<span class='danger'>[src] begins chasing [current_target]!</span>")

// Start slaughter mode
/mob/living/carbon/scp/scp096/proc/start_slaughter()
	state = "slaughter"
	icon_state = "scp096-slaughter"
	visible_message("<span class='danger'>[src] enters a murderous rage!</span>")

// Find a new target
/mob/living/carbon/scp/scp096/proc/find_new_target()
	var/mob/living/new_target = null
	var/shortest_distance = 999

	for(var/mob/living/L in view(7, src))
		if(L == src || L.SCP)
			continue
		var/distance = get_dist(src, L)
		if(distance < shortest_distance)
			shortest_distance = distance
			new_target = L

	if(new_target)
		current_target = new_target
	else
		// No targets, return to idle
		return_to_idle()

// Return to idle state
/mob/living/carbon/scp/scp096/proc/return_to_idle()
	state = "idle"
	current_target = null
	icon_state = "scp096"
	return_to_containment()
	visible_message("<span class='notice'>[src] calms down and returns to covering its face.</span>")

// Attack behavior
/mob/living/carbon/scp/scp096/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		visible_message("<span class='danger'>[src] tears [H] apart!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
		H.adjustBruteLoss(150)

		// Track kill for persistence
		if(H.stat == DEAD)
			kills_count++
			add_interaction_record(H, "kill")

		return

	return ..()

// SCP-096 specific abilities
/mob/living/carbon/scp/scp096/proc/scream_ability()
	if(state == "idle" && world.time >= scream_cooldown)
		var/list/targets = list()
		for(var/mob/living/carbon/human/H in view(7, src))
			if(H != src)
				targets += H

		if(targets.len)
			var/mob/living/carbon/human/chosen_target = pick(targets)
			trigger_rage(chosen_target)
		else
			to_chat(src, "<span class='warning'>No targets in range to scream at.</span>")
	else
		to_chat(src, "<span class='warning'>You cannot scream right now.</span>")

/mob/living/carbon/scp/scp096/proc/rage_mode_ability()
	if(state == "idle")
		to_chat(src, "<span class='notice'>You enter a controlled rage mode.</span>")
		state = "screaming"
		rage_duration = world.time + 10 SECONDS
		icon_state = "scp096-screaming"
	else
		to_chat(src, "<span class='warning'>You are already in rage mode.</span>")

// Override status display
/mob/living/carbon/scp/scp096/get_status_tab_items()
	. = ..()
	. += "State: [state]"
	. += "Kills: [kills_count]"
	. += "Rage Activations: [rage_activations]"
	if(current_target)
		. += "Target: [current_target.name]"

// Override examine behavior
/mob/living/carbon/scp/scp096/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-096, a humanoid that becomes aggressive when its face is seen.</span>")
		else
			to_chat(user, "<span class='danger'>A tall, thin figure covering its face. Something about it feels wrong.</span>")

// Override SCP death
/mob/living/carbon/scp/scp096/scp_death()
	visible_message("<span class='danger'>[src] collapses to the ground!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Verb commands
/mob/living/carbon/scp/scp096/verb/scream()
	set name = "Scream"
	set category = "SCP"
	set desc = "Let out a blood-curdling scream."

	scream_ability()

/mob/living/carbon/scp/scp096/verb/rage_mode()
	set name = "Rage Mode"
	set category = "SCP"
	set desc = "Enter a controlled rage mode."

	rage_mode_ability()

// Override persistence data view
/mob/living/carbon/scp/scp096/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-096 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-096 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Kills Count:</b> [kills_count]<br>"
	message += "<b>Rage Activations:</b> [rage_activations]<br>"
	message += "<b>Last Rage Time:</b> [last_rage_time ? time2text(last_rage_time, "YYYY-MM-DD hh:mm:ss") : "Never"]<br>"
	message += "<b>Current State:</b> [state]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")
