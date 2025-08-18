// SCP-106 - The Old Man
// An elderly humanoid that can phase through walls and create pocket dimensions

/mob/living/carbon/scp/scp106
	name = "SCP-106"
	desc = "An elderly humanoid figure with dark, wrinkled skin. It appears to be hunched over."
	icon = 'icons/scp/scp-106.dmi'
	icon_state = "scp106"
	real_name = "SCP-106"
	use_custom_sprite = TRUE
	use_custom_sprite = TRUE

	// SCP-106 specific variables
	var/phase_cooldown = 0
	var/phase_cooldown_time = 10 SECONDS
	var/pocket_dimension_cooldown = 0
	var/pocket_dimension_cooldown_time = 30 SECONDS
	var/list/pocket_dimensions = list()

	// Persistence tracking
	var/phase_count = 0
	var/pocket_dimensions_created = 0
	var/victims_dragged = 0

/mob/living/carbon/scp/scp106/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-106",
		SCP_KETER,
		"106",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 30
	SCP_datum.min_time = 60 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 400
	scp_health = max_scp_health
	max_scp_armor = 150
	scp_armor = max_scp_armor

	// Add SCP abilities
	add_ability("phase_through_wall", "phase_through_wall_ability")
	add_ability("create_pocket_dimension", "create_pocket_dimension_ability")
	add_ability("drag_victim", "drag_victim_ability")

	// Add passive effects
	add_passive_effect("wall_phasing")
	add_passive_effect("pocket_dimension_mastery")

	// Add SCP-106 specific containment protocols
	add_containment_protocol("Dimensional Anchoring", "SCP-106 must be anchored to prevent dimensional travel")
	add_containment_protocol("Wall Reinforcement", "Containment walls reinforced to prevent phasing")
	add_containment_protocol("Pocket Dimension Monitoring", "Monitoring systems for pocket dimension creation")

	// Add SCP-106 specific security measures
	add_security_measure("Dimensional Sensors", "Sensors to detect dimensional anomalies")
	add_security_measure("Phase Detection", "Systems to detect wall phasing attempts")
	add_security_measure("Victim Tracking", "Tracking systems for personnel dragged to pocket dimensions")

	// Add SCP-106 specific containment abilities
	add_containment_ability("dimensional_manipulation", "dimensional_manipulation_ability")
	add_containment_ability("wall_corrosion", "wall_corrosion_ability")

	// Add SCP-106 specific containment effects
	add_containment_effect("dimensional_instability")
	add_containment_effect("wall_weakening")

	// Set up default containment protocols and security measures
	setup_default_containment()

/mob/living/carbon/scp/scp106/Destroy()
	pocket_dimensions = list()
	return ..()

// Override core mechanics
/mob/living/carbon/scp/scp106/process_scp_effects()
	. = ..()

	// Look for targets to phase towards
	if(world.time >= phase_cooldown)
		var/mob/living/target = find_target()
		if(target)
			phase_towards(target)

// Find a target to chase
/mob/living/carbon/scp/scp106/proc/find_target()
	var/mob/living/target = null
	var/shortest_distance = 999

	for(var/mob/living/L in view(10, src))
		if(L == src || L.SCP)
			continue
		var/distance = get_dist(src, L)
		if(distance < shortest_distance)
			shortest_distance = distance
			target = L

	return target

// Phase through walls towards target
/mob/living/carbon/scp/scp106/proc/phase_towards(mob/living/target)
	if(!target || world.time < phase_cooldown)
		return

	phase_cooldown = world.time + phase_cooldown_time

	// Calculate direction to target
	var/direction = get_dir(src, target)
	var/turf/target_turf = get_step(src, direction)

	// Check if we can move normally
	if(target_turf && !target_turf.density)
		step_towards(src, target)
		return

	// Phase through walls
	visible_message("<span class='danger'>[src] phases through the wall!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	// Track phase for persistence
	phase_count++
	breach_containment()

	// Update persistence system
	add_interaction_record(target, "phase_through_wall")

	// Find a valid turf on the other side
	var/turf/phase_turf = find_phase_turf(target_turf, direction)
	if(phase_turf)
		forceMove(phase_turf)
		visible_message("<span class='danger'>[src] emerges from the wall!</span>")

// Find a valid turf to phase to
/mob/living/carbon/scp/scp106/proc/find_phase_turf(turf/start_turf, direction)
	if(!start_turf)
		return null

	var/turf/current = start_turf
	var/max_distance = 5

	for(var/i = 1 to max_distance)
		current = get_step(current, direction)
		if(!current || current.density)
			continue
		if(!current.contents.len) // Simple check for empty turf
			return current

	return null

// Create pocket dimension
/mob/living/carbon/scp/scp106/proc/create_pocket_dimension_internal()
	if(world.time < pocket_dimension_cooldown)
		return

	pocket_dimension_cooldown = world.time + pocket_dimension_cooldown_time

	// Create a pocket dimension area
	var/area/pocket_dimension/pocket = new /area/pocket_dimension()
	pocket_dimensions += pocket

	visible_message("<span class='danger'>[src] creates a pocket dimension!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	// Track pocket dimension creation for persistence
	pocket_dimensions_created++

	// Update persistence system
	add_interaction_record(null, "create_pocket_dimension")

	return pocket

// Override specific containment check for SCP-106
/mob/living/carbon/scp/scp106/check_specific_containment()
	// Check if we're near walls that we could phase through
	for(var/turf/T in range(1, src))
		if(T.density)
			// We're near a wall - chance to reduce containment integrity
			if(prob(5))
				reduce_containment_integrity(2)
				to_chat(src, "<span class='notice'>You sense a weak point in the containment.</span>")

// SCP-106 specific containment abilities
/mob/living/carbon/scp/scp106/proc/dimensional_manipulation_ability()
	to_chat(src, "<span class='notice'>You manipulate the dimensional anchoring.</span>")
	// Temporarily disable dimensional anchoring
	remove_containment_protocol("Dimensional Anchoring")
	spawn(45 SECONDS)
		add_containment_protocol("Dimensional Anchoring", "SCP-106 must be anchored to prevent dimensional travel")

/mob/living/carbon/scp/scp106/proc/wall_corrosion_ability()
	to_chat(src, "<span class='notice'>You begin corroding the containment walls.</span>")
	reduce_containment_integrity(20)
	remove_containment_protocol("Wall Reinforcement")
	spawn(90 SECONDS)
		add_containment_protocol("Wall Reinforcement", "Containment walls reinforced to prevent phasing")

// Process SCP-106 specific containment effects
/mob/living/carbon/scp/scp106/process_containment_effect(effect)
	switch(effect)
		if("dimensional_instability")
			// SCP-106 creates dimensional instability
			if(prob(1))
				to_chat(src, "<span class='notice'>You create dimensional instability.</span>")
				reduce_containment_integrity(3)
		if("wall_weakening")
			// SCP-106 slowly weakens walls
			if(prob(2))
				reduce_containment_integrity(1)

// Attack behavior
/mob/living/carbon/scp/scp106/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		visible_message("<span class='danger'>[src] grabs [H] and begins dragging them!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

		// Try to drag them to pocket dimension
		var/area/pocket_dimension/pocket = create_pocket_dimension_internal()
		if(pocket)
			H.forceMove(pocket)
			to_chat(H, "<span class='danger'>You are dragged into a pocket dimension!</span>")

			// Track victim drag for persistence
			victims_dragged++

			// Update persistence system
			add_interaction_record(H, "drag_to_pocket_dimension")

		return

	return ..()

// SCP-106 specific abilities
/mob/living/carbon/scp/scp106/proc/phase_through_wall_ability()
	if(world.time < phase_cooldown)
		to_chat(src, "<span class='warning'>You cannot phase right now.</span>")
		return

	var/list/directions = list("North", "South", "East", "West")
	var/chosen_direction = input(src, "Choose a direction to phase:", "Phase Through Wall") as null|anything in directions

	if(!chosen_direction)
		return

	var/direction
	switch(chosen_direction)
		if("North")
			direction = NORTH
		if("South")
			direction = SOUTH
		if("East")
			direction = EAST
		if("West")
			direction = WEST

	var/turf/target_turf = get_step(src, direction)
	if(target_turf && target_turf.density)
		var/turf/phase_turf = find_phase_turf(target_turf, direction)
		if(phase_turf)
			forceMove(phase_turf)
			visible_message("<span class='danger'>[src] phases through the wall!</span>")
			playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
		else
			to_chat(src, "<span class='warning'>No valid location to phase to.</span>")
	else
		to_chat(src, "<span class='warning'>No wall to phase through in that direction.</span>")

/mob/living/carbon/scp/scp106/proc/create_pocket_dimension_ability()
	var/area/pocket_dimension/pocket = create_pocket_dimension_internal()
	if(pocket)
		to_chat(src, "<span class='notice'>Pocket dimension created successfully.</span>")
	else
		to_chat(src, "<span class='warning'>Cannot create pocket dimension right now.</span>")

/mob/living/carbon/scp/scp106/proc/drag_victim_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(2, src))
		if(H != src)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No victims in range to drag.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a victim to drag:", "Drag Victim") as null|anything in targets
	if(target)
		UnarmedAttack(target)

// Override status display
/mob/living/carbon/scp/scp106/get_status_tab_items()
	. = ..()
	. += "Phase Cooldown: [phase_cooldown_time/10] seconds"
	. += "Pocket Dimension Cooldown: [pocket_dimension_cooldown_time/10] seconds"
	. += "Active Pocket Dimensions: [pocket_dimensions.len]"
	. += "Phases: [phase_count]"
	. += "Pocket Dimensions Created: [pocket_dimensions_created]"
	. += "Victims Dragged: [victims_dragged]"

// Override examine behavior
/mob/living/carbon/scp/scp106/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-106, an elderly humanoid that can phase through walls and create pocket dimensions.</span>")
		else
			to_chat(user, "<span class='danger'>An elderly figure with dark, wrinkled skin. It seems to be watching you intently.</span>")

// Override SCP death
/mob/living/carbon/scp/scp106/scp_death()
	visible_message("<span class='danger'>[src] collapses and begins to decay!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Verb commands
/mob/living/carbon/scp/scp106/verb/phase_through_wall()
	set name = "Phase Through Wall"
	set category = "SCP"
	set desc = "Phase through a nearby wall."

	phase_through_wall_ability()

/mob/living/carbon/scp/scp106/verb/create_pocket_dimension()
	set name = "Create Pocket Dimension"
	set category = "SCP"
	set desc = "Create a pocket dimension."

	create_pocket_dimension_ability()

/mob/living/carbon/scp/scp106/verb/drag_victim()
	set name = "Drag Victim"
	set category = "SCP"
	set desc = "Drag a victim to your pocket dimension."

	drag_victim_ability()

// SCP-106 specific containment verbs
/mob/living/carbon/scp/scp106/verb/dimensional_manipulation()
	set name = "Manipulate Dimensions"
	set category = "SCP"
	set desc = "Manipulate the dimensional anchoring."

	dimensional_manipulation_ability()

/mob/living/carbon/scp/scp106/verb/wall_corrosion()
	set name = "Corrode Walls"
	set category = "SCP"
	set desc = "Begin corroding the containment walls."

	wall_corrosion_ability()

// Override persistence data view
/mob/living/carbon/scp/scp106/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-106 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-106 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Phase Count:</b> [phase_count]<br>"
	message += "<b>Pocket Dimensions Created:</b> [pocket_dimensions_created]<br>"
	message += "<b>Victims Dragged:</b> [victims_dragged]<br>"
	message += "<b>Active Pocket Dimensions:</b> [pocket_dimensions.len]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

// Pocket Dimension Area
/area/pocket_dimension
	name = "Pocket Dimension"
	icon_state = "pocket_dimension"
	requires_power = FALSE
	has_gravity = TRUE
	ambientsounds = list('sound/ambience/ambimine.ogg')
