// SCP-173 - The Sculpture
// A concrete statue that moves when not observed

/mob/living/carbon/scp/scp173
	name = "SCP-173"
	desc = "A concrete statue of a humanoid figure. It seems to be watching you."
	icon = 'icons/scp/scp-173.dmi'
	icon_state = "scp173"
	real_name = "SCP-173"
	use_custom_sprite = TRUE

	// SCP-173 specific variables
	var/move_cooldown = 0
	var/move_cooldown_time = 2 SECONDS
	var/containment_area = null

	// Persistence tracking
	var/kills_count = 0

/mob/living/carbon/scp/scp173/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-173",
		SCP_KETER,
		"173",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 20
	SCP_datum.min_time = 30 MINUTES

	containment_area = get_area(src)

	// Set up SCP-specific properties
	max_scp_health = 300
	scp_health = max_scp_health
	max_scp_armor = 100
	scp_armor = max_scp_armor

	// Add SCP abilities
	add_ability("snap_neck", "snap_neck_ability")

	// Add passive effects
	add_passive_effect("motion_detection")
	add_passive_effect("concrete_durability")

	// Initialize SCP-173 specific skills with cooldowns and requirements
	initialize_skill("motion_manipulation", 45 SECONDS, list("base_cooldown" = 45 SECONDS, "requires_breach" = TRUE))
	initialize_skill("concrete_weakening", 90 SECONDS, list("base_cooldown" = 90 SECONDS, "requires_level_10" = TRUE))
	initialize_skill("neck_snapping", 15 SECONDS, list("base_cooldown" = 15 SECONDS))
	initialize_skill("stealth_movement", 30 SECONDS, list("base_cooldown" = 30 SECONDS, "requires_level_25" = TRUE))
	initialize_skill("mass_terror", 120 SECONDS, list("base_cooldown" = 120 SECONDS, "requires_level_50" = TRUE, "requires_breach" = TRUE))

	// Add SCP-173 specific containment protocols
	add_containment_protocol("Motion Detection", "SCP-173 must be observed at all times to prevent movement")
	add_containment_protocol("Blink Protocol", "Personnel must coordinate blinking to maintain constant observation")
	add_containment_protocol("Concrete Reinforcement", "Containment area reinforced with concrete to prevent structural damage")

	// Add SCP-173 specific security measures
	add_security_measure("Observation Teams", "Multiple personnel assigned to maintain constant visual contact")
	add_security_measure("Emergency Lighting", "Backup lighting systems to prevent darkness")
	add_security_measure("Motion Sensors", "Advanced motion detection systems")

	// Add SCP-173 specific containment abilities
	add_containment_ability("motion_manipulation", "motion_manipulation_ability")
	add_containment_ability("concrete_weakening", "concrete_weakening_ability")

	// Add SCP-173 specific containment effects
	add_containment_effect("motion_detection_bypass")
	add_containment_effect("concrete_corrosion")

	// Set up default containment protocols and security measures
	setup_default_containment()

/mob/living/carbon/scp/scp173/Destroy()
	containment_area = null
	return ..()

// Override core mechanics
/mob/living/carbon/scp/scp173/process_scp_effects()
	. = ..()

	// Check if anyone can see us
	var/can_move = TRUE
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP)
			continue
		if(can_see(H, src))
			can_move = FALSE
			break

	// Move if no one is watching
	if(can_move && world.time >= move_cooldown)
		move_cooldown = world.time + move_cooldown_time

		// Find nearest target
		var/mob/living/target = null
		var/shortest_distance = 999
		for(var/mob/living/L in view(7, src))
			if(L == src || L.SCP)
				continue
			var/distance = get_dist(src, L)
			if(distance < shortest_distance)
				shortest_distance = distance
				target = L

		if(target)
			step_towards(src, target)

// Override containment check
/mob/living/carbon/scp/scp173/check_containment()
	if(containment_status == "breached")
		return

	// Check if we're still in containment area
	if(get_area(src) == containment_area)
		return

	// Breach containment if we're outside containment area
	breach_containment()

// Override specific containment check for SCP-173
/mob/living/carbon/scp/scp173/check_specific_containment()
	// Check if anyone is observing us
	var/being_observed = FALSE
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP)
			continue
		if(can_see(H, src))
			being_observed = TRUE
			break

	// If not being observed, reduce containment integrity
	if(!being_observed)
		reduce_containment_integrity(1)
		// Chance to breach if integrity is very low
		if(containment_integrity < 20 && prob(5))
			attempt_containment_breach()

// SCP-173 specific containment abilities
/mob/living/carbon/scp/scp173/proc/motion_manipulation_ability()
	if(!use_skill("motion_manipulation", 2, 1.0))
		return

	to_chat(src, "<span class='notice'>You manipulate the motion detection systems.</span>")
	// Temporarily disable motion sensors
	remove_security_measure("Motion Sensors")
	spawn(30 SECONDS)
		add_security_measure("Motion Sensors", "Advanced motion detection systems")

/mob/living/carbon/scp/scp173/proc/concrete_weakening_ability()
	if(!use_skill("concrete_weakening", 3, 1.5))
		return

	to_chat(src, "<span class='notice'>You begin weakening the concrete reinforcements.</span>")
	reduce_containment_integrity(15)
	remove_containment_protocol("Concrete Reinforcement")
	spawn(60 SECONDS)
		add_containment_protocol("Concrete Reinforcement", "Containment area reinforced with concrete to prevent structural damage")

// Enhanced skill-based abilities
/mob/living/carbon/scp/scp173/proc/neck_snapping_ability()
	if(!use_skill("neck_snapping", 1, 0.8))
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(1, src))
		if(H != src)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets in range.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to snap the neck of:", "Snap Neck") as null|anything in targets
	if(target)
		UnarmedAttack(target)

/mob/living/carbon/scp/scp173/proc/stealth_movement_ability()
	if(!use_skill("stealth_movement", 2, 1.2))
		return

	to_chat(src, "<span class='notice'>You move with enhanced stealth.</span>")
	// Enhanced movement for a short time
	enhance_containment_resistance(5)
	spawn(20 SECONDS)
		enhance_containment_resistance(-5)

/mob/living/carbon/scp/scp173/proc/mass_terror_ability()
	if(!use_skill("mass_terror", 5, 2.0))
		return

	to_chat(src, "<span class='notice'>You unleash mass terror!</span>")
	// Affect all nearby humans
	for(var/mob/living/carbon/human/H in view(10, src))
		if(H != src && !H.SCP)
			H.adjustBruteLoss(20)
			to_chat(H, "<span class='danger'>You feel overwhelming terror!</span>")

// SCP-173 specific skill requirement checks
/mob/living/carbon/scp/scp173/check_skill_requirement(requirement, current_level)
	switch(requirement)
		if("requires_breach")
			return containment_status == "breached"
		if("requires_level_10")
			return current_level >= 10
		if("requires_level_25")
			return current_level >= 25
		if("requires_level_50")
			return current_level >= 50
		else
			return ..()

// Apply skill level effects for SCP-173
/mob/living/carbon/scp/scp173/apply_skill_level_effects(skill_name, new_level)
	switch(skill_name)
		if("motion_manipulation")
			if(new_level >= 25)
				to_chat(src, "<span class='notice'>Your motion manipulation now affects a larger area.</span>")
			if(new_level >= 50)
				to_chat(src, "<span class='notice'>Your motion manipulation can now disable multiple systems.</span>")
		if("concrete_weakening")
			if(new_level >= 20)
				to_chat(src, "<span class='notice'>Your concrete weakening is now more effective.</span>")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your concrete weakening affects a larger area.</span>")
		if("neck_snapping")
			if(new_level >= 15)
				to_chat(src, "<span class='notice'>Your neck snapping is now more precise.</span>")
			if(new_level >= 30)
				to_chat(src, "<span class='notice'>Your neck snapping can now affect multiple targets.</span>")
		if("stealth_movement")
			if(new_level >= 20)
				to_chat(src, "<span class='notice'>Your stealth movement is now more effective.</span>")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your stealth movement can now bypass some detection.</span>")
		if("mass_terror")
			if(new_level >= 30)
				to_chat(src, "<span class='notice'>Your mass terror affects a larger area.</span>")
			if(new_level >= 60)
				to_chat(src, "<span class='notice'>Your mass terror can now cause panic effects.</span>")

// Attack behavior
/mob/living/carbon/scp/scp173/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		visible_message("<span class='danger'>[src] snaps [H]'s neck!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
		H.adjustBruteLoss(100)

		// Track kill for persistence
		if(H.stat == DEAD)
			kills_count++
			add_interaction_record(H, "kill")

		return

	return ..()

// SCP-173 specific abilities
/mob/living/carbon/scp/scp173/proc/snap_neck_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(1, src))
		if(H != src)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets in range.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to snap the neck of:", "Snap Neck") as null|anything in targets
	if(target)
		UnarmedAttack(target)

// Override status display
/mob/living/carbon/scp/scp173/get_status_tab_items()
	. = ..()
	. += "Move Cooldown: [move_cooldown_time/10] seconds"
	. += "Kills: [kills_count]"

// Override examine behavior
/mob/living/carbon/scp/scp173/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-173, a concrete statue that moves when not observed.</span>")
		else
			to_chat(user, "<span class='danger'>A concrete statue. It seems to be watching you intently.</span>")

// Override SCP death
/mob/living/carbon/scp/scp173/scp_death()
	visible_message("<span class='danger'>[src] crumbles to pieces!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Verb commands
/mob/living/carbon/scp/scp173/verb/snap_neck()
	set name = "Snap Neck"
	set category = "SCP"
	set desc = "Snap the neck of a nearby target."

	neck_snapping_ability()

// SCP-173 specific containment verbs
/mob/living/carbon/scp/scp173/verb/motion_manipulation()
	set name = "Manipulate Motion Sensors"
	set category = "SCP"
	set desc = "Temporarily disable motion detection systems."

	motion_manipulation_ability()

/mob/living/carbon/scp/scp173/verb/concrete_weakening()
	set name = "Weaken Concrete"
	set category = "SCP"
	set desc = "Begin weakening concrete reinforcements."

	concrete_weakening_ability()

// New skill-based verbs
/mob/living/carbon/scp/scp173/verb/stealth_movement()
	set name = "Stealth Movement"
	set category = "SCP"
	set desc = "Move with enhanced stealth (requires level 25)."

	stealth_movement_ability()

/mob/living/carbon/scp/scp173/verb/mass_terror()
	set name = "Mass Terror"
	set category = "SCP"
	set desc = "Unleash mass terror on nearby targets (requires level 50 and breach)."

	mass_terror_ability()

// Override persistence data view
/mob/living/carbon/scp/scp173/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-173 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-173 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Kills Count:</b> [kills_count]<br>"
	message += "<b>Breach Count:</b> [breach_count]<br>"
	message += "<b>Last Breach Time:</b> [last_breach_time ? time2text(last_breach_time, "YYYY-MM-DD hh:mm:ss") : "Never"]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"
			message += "<b>Breach History:</b> [instance.breach_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")
