// SCP-096 - The Shy Guy
// Becomes aggressive when its face is seen

/mob/living/carbon/scp/scp096
	name = "SCP-096"
	desc = "A tall, thin humanoid figure with pale skin and long arms. It appears to be covering its face."
	icon = 'icons/scp/scp-096.dmi'
	icon_state = "scp096"
	real_name = "SCP-096"
	use_custom_sprite = TRUE

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

	// Initialize SCP-096 specific skills with cooldowns and requirements
	initialize_skill("face_revelation", 60 SECONDS, list("base_cooldown" = 60 SECONDS, "requires_breach" = TRUE))
	initialize_skill("rage_manipulation", 45 SECONDS, list("base_cooldown" = 45 SECONDS))
	initialize_skill("scream_attack", 30 SECONDS, list("base_cooldown" = 30 SECONDS))
	initialize_skill("rage_escalation", 90 SECONDS, list("base_cooldown" = 90 SECONDS, "requires_level_20" = TRUE))
	initialize_skill("mass_hysteria", 180 SECONDS, list("base_cooldown" = 180 SECONDS, "requires_level_60" = TRUE, "requires_breach" = TRUE))

	// Add SCP-096 specific containment protocols
	add_containment_protocol("Face Concealment", "SCP-096's face must never be viewed by personnel")
	add_containment_protocol("Blindfold Protocol", "Personnel must wear blindfolds when entering containment area")
	add_containment_protocol("Rage Management", "Procedures for calming SCP-096 after rage activation")

	// Add SCP-096 specific security measures
	add_security_measure("Facial Recognition Blocking", "AI systems programmed to blur SCP-096's face")
	add_security_measure("Emergency Containment", "Rapid containment procedures for rage events")
	add_security_measure("Psychological Monitoring", "Monitoring of personnel mental state around SCP-096")

	// Add SCP-096 specific containment abilities
	add_containment_ability("face_revelation", "face_revelation_ability")
	add_containment_ability("rage_manipulation", "rage_manipulation_ability")

	// Add SCP-096 specific containment effects
	add_containment_effect("face_obsession_escalation")
	add_containment_effect("rage_amplification")

	// Set up default containment protocols and security measures
	setup_default_containment()

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

// Override specific containment check for SCP-096
/mob/living/carbon/scp/scp096/check_specific_containment()
	// Check if anyone can see our face
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP)
			continue
		if(can_see(H, src))
			// Someone can see our face - this is a containment failure
			reduce_containment_integrity(10)
			if(prob(20))
				trigger_rage(H)
			break

// SCP-096 specific containment abilities
/mob/living/carbon/scp/scp096/proc/face_revelation_ability()
	if(!use_skill("face_revelation", 3, 1.5))
		return

	to_chat(src, "<span class='notice'>You reveal your face to nearby personnel.</span>")
	// Force face revelation to nearby personnel
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && !H.SCP)
			trigger_rage(H)
			break

/mob/living/carbon/scp/scp096/proc/rage_manipulation_ability()
	if(!use_skill("rage_manipulation", 2, 1.0))
		return

	to_chat(src, "<span class='notice'>You manipulate your rage state.</span>")
	if(state == "idle")
		state = "screaming"
		rage_duration = world.time + 10 SECONDS
		icon_state = "scp096-screaming"
		breach_containment()
	else
		state = "idle"
		icon_state = "scp096"
		return_to_containment()

// Enhanced skill-based abilities
/mob/living/carbon/scp/scp096/proc/scream_attack_ability()
	if(!use_skill("scream_attack", 1, 0.8))
		return

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

/mob/living/carbon/scp/scp096/proc/rage_escalation_ability()
	if(!use_skill("rage_escalation", 4, 1.8))
		return

	to_chat(src, "<span class='notice'>You escalate your rage to new heights!</span>")
	// Enhanced rage effects
	enhance_containment_resistance(10)
	reduce_containment_integrity(10)
	spawn(30 SECONDS)
		enhance_containment_resistance(-10)

/mob/living/carbon/scp/scp096/proc/mass_hysteria_ability()
	if(!use_skill("mass_hysteria", 6, 2.5))
		return

	to_chat(src, "<span class='notice'>You cause mass hysteria!</span>")
	// Affect all nearby humans with panic
	for(var/mob/living/carbon/human/H in view(15, src))
		if(H != src && !H.SCP)
			H.adjustBruteLoss(30)
			H.stamina.adjust(-50)
			to_chat(H, "<span class='danger'>You are overcome with hysteria!</span>")

// SCP-096 specific skill requirement checks
/mob/living/carbon/scp/scp096/check_skill_requirement(requirement, current_level)
	switch(requirement)
		if("requires_breach")
			return containment_status == "breached"
		if("requires_level_20")
			return current_level >= 20
		if("requires_level_60")
			return current_level >= 60
		else
			return ..()

// Apply skill level effects for SCP-096
/mob/living/carbon/scp/scp096/apply_skill_level_effects(skill_name, new_level)
	switch(skill_name)
		if("face_revelation")
			if(new_level >= 20)
				to_chat(src, "<span class='notice'>Your face revelation affects a larger area.</span>")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your face revelation can now affect multiple targets.</span>")
		if("rage_manipulation")
			if(new_level >= 15)
				to_chat(src, "<span class='notice'>Your rage manipulation is more effective.</span>")
			if(new_level >= 30)
				to_chat(src, "<span class='notice'>Your rage manipulation can now control others.</span>")
		if("scream_attack")
			if(new_level >= 10)
				to_chat(src, "<span class='notice'>Your scream attack is more powerful.</span>")
			if(new_level >= 25)
				to_chat(src, "<span class='notice'>Your scream attack can now stun targets.</span>")
		if("rage_escalation")
			if(new_level >= 25)
				to_chat(src, "<span class='notice'>Your rage escalation affects a larger area.</span>")
			if(new_level >= 50)
				to_chat(src, "<span class='notice'>Your rage escalation can now cause environmental damage.</span>")
		if("mass_hysteria")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your mass hysteria affects a larger area.</span>")
			if(new_level >= 80)
				to_chat(src, "<span class='notice'>Your mass hysteria can now cause permanent psychological damage.</span>")

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
	set desc = "Let out a blood-curling scream."

	scream_attack_ability()

/mob/living/carbon/scp/scp096/verb/rage_mode()
	set name = "Rage Mode"
	set category = "SCP"
	set desc = "Enter a controlled rage mode."

	rage_manipulation_ability()

// SCP-096 specific containment verbs
/mob/living/carbon/scp/scp096/verb/face_revelation()
	set name = "Reveal Face"
	set category = "SCP"
	set desc = "Reveal your face to nearby personnel."

	face_revelation_ability()

/mob/living/carbon/scp/scp096/verb/rage_manipulation()
	set name = "Manipulate Rage"
	set category = "SCP"
	set desc = "Manipulate your rage state."

	rage_manipulation_ability()

// New skill-based verbs
/mob/living/carbon/scp/scp096/verb/rage_escalation()
	set name = "Rage Escalation"
	set category = "SCP"
	set desc = "Escalate your rage to new heights (requires level 20)."

	rage_escalation_ability()

/mob/living/carbon/scp/scp096/verb/mass_hysteria()
	set name = "Mass Hysteria"
	set category = "SCP"
	set desc = "Cause mass hysteria (requires level 60 and breach)."

	mass_hysteria_ability()

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
