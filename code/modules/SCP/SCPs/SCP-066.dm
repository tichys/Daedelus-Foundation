// SCP-066 - Eric's Toy
// Musical Anomaly and Emotional Resonance System

/mob/living/simple_animal/hostile/retaliate/scp066
	name = "SCP-066"
	desc = "An amorphous red mass of braided yarn and ribbon. It seems to be listening intently for something."
	icon = 'icons/SCP/nonhumanoidscps(32x32).dmi'
	icon_state = "066"
	icon_living = "066"
	icon_dead = "dead"

	real_name = "SCP-066"

	// Basic stats
	maxHealth = 500
	health = 500
	see_in_dark = 3

	// Core system datums - to be implemented later when compilation issues are resolved

	// Basic musical system
	var/musical_energy_level = 100
	var/max_musical_energy = 100
	var/eric_connection_strength = 50
	var/evolution_stage = 1

	// Persistence tracking
	var/total_performances_given = 0
	var/total_healings_performed = 0
	var/total_eric_attempts = 0
	var/total_facility_integrations = 0
	var/total_evolution_stages = 0
	var/total_containment_encounters = 0
	var/total_eric_detections = 0
	var/session_start_time = 0
	var/containment_status = "contained"

	// Audio configuration
	var/movement_sound = 'sound/scp/scp066/Roll.ogg'
	speak_chance = 2

	speak = list("Eric?", "Are you Eric?", "Eric, is that you?", "Have you seen Eric?")
	speak_emote = list("makes a melodic sound.", "hums a gentle tune.", "plays a curious melody.")
	emote_hear = list(
		'sound/scp/scp066/Notes1.ogg' = 16,
		'sound/scp/scp066/Notes2.ogg' = 16,
		'sound/scp/scp066/Notes3.ogg' = 16,
		'sound/scp/scp066/Notes4.ogg' = 16,
		'sound/scp/scp066/Notes5.ogg' = 16,
		'sound/scp/scp066/Notes6.ogg' = 16,
		'sound/scp/scp066/Eric1.ogg' = 33,
		'sound/scp/scp066/Eric2.ogg' = 33,
		'sound/scp/scp066/Eric3.ogg' = 33
		)

/mob/living/simple_animal/hostile/retaliate/scp066/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"ball of yarn",
		SCP_EUCLID,
		"066",
		SCP_SENTIENT
	)

	// Set session start time
	session_start_time = world.time

	// Initialize core systems after a short delay
	addtimer(CALLBACK(src, PROC_REF(initialize_scp066_systems)), 1)

	// Grant language and register for SCP persistence
	grant_language(/datum/language/common, TRUE, TRUE)

	// Start processing
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/retaliate/scp066/proc/initialize_scp066_systems()
	// Initialize core systems - simplified for now
	// Will be enhanced with full system datums later
	musical_energy_level = 100
	max_musical_energy = 100
	eric_connection_strength = 50
	evolution_stage = 1

/mob/living/simple_animal/hostile/retaliate/scp066/Destroy()
	// Clean up systems - simplified for now
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/simple_animal/hostile/retaliate/scp066/process()
	. = ..()

	// Process SCP-066 specific effects - simplified for now
	process_scp066_effects()

/mob/living/simple_animal/hostile/retaliate/scp066/proc/process_scp066_effects()
	// Update appearance based on current state
	update_scp066_appearance()

	// Process automatic musical responses
	process_automatic_responses()

	// Process Eric-seeking behavior
	process_eric_seeking()

/mob/living/simple_animal/hostile/retaliate/scp066/proc/update_scp066_appearance()
	// Update description based on current evolution stage
	switch(evolution_stage)
		if(1)
			desc = "An amorphous red mass of braided yarn and ribbon. It seems to be listening intently for something."
		if(2)
			desc = "An amorphous red mass of braided yarn and ribbon. It pulses gently with musical energy and seems more aware of its surroundings."
		if(3)
			desc = "An amorphous red mass of braided yarn and ribbon. It radiates musical harmony and appears deeply connected to the facility's acoustic environment."
		if(4)
			desc = "An amorphous red mass of braided yarn and ribbon. It seems to resonate with the emotions of nearby personnel and pulses with empathic energy."
		if(5)
			desc = "An amorphous red mass of braided yarn and ribbon. It appears transcendent, as if existing partially in multiple dimensions while searching eternally for Eric."

/mob/living/simple_animal/hostile/retaliate/scp066/proc/process_automatic_responses()
	// Check for nearby humans in distress - simplified for now
	if(musical_energy_level < 5)
		return

	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat == DEAD)
			continue

		// Check if human needs help
		if(H.sanity && H.sanity.sanity_level < 30)
			// Automatic soothing melody
			if(prob(20))
				perform_simple_melody("soothing", H)
				break

		if(H.health < H.maxHealth * 0.5)
			// Automatic healing melody
			if(prob(15))
				perform_simple_melody("healing", H)
				break

/mob/living/simple_animal/hostile/retaliate/scp066/proc/process_eric_seeking()
	// Passive Eric detection - simplified for now
	if(prob(1)) // 1% chance per process cycle
		for(var/mob/living/carbon/human/H in range(10, src))
			if(H.stat == DEAD)
				continue

			// Check if this could be Eric (placeholder logic)
			if(H.real_name && findtext(H.real_name, "Eric"))
				face_atom(H)
				say("Eric? Is that really you?")
				return

	// Occasional Eric calling
	if(prob(2) && musical_energy_level >= 15)
		say(pick("Eric?", "Are you Eric?", "Eric, is that you?", "Have you seen Eric?"))
		musical_energy_level -= 5

// Simple melody performance function
/mob/living/simple_animal/hostile/retaliate/scp066/proc/perform_simple_melody(melody_type, mob/living/carbon/human/target)
	if(!target || musical_energy_level < 5)
		return FALSE

	musical_energy_level -= 5
	total_performances_given++

	switch(melody_type)
		if("soothing")
			// Heal sanity and minor health
			if(target.sanity)
				target.sanity.adjust_sanity(10)
			target.adjustBruteLoss(-5)
			to_chat(target, "<span class='notice'>SCP-066's soothing melody fills you with peace.</span>")
			to_chat(src, "<span class='notice'>You sense [target]'s distress and play a soothing melody.</span>")
			total_healings_performed++
		if("healing")
			// Focus on health restoration
			target.adjustBruteLoss(-10)
			target.adjustFireLoss(-5)
			target.adjustToxLoss(-5)
			to_chat(target, "<span class='notice'>SCP-066's healing melody mends your wounds.</span>")
			to_chat(src, "<span class='notice'>You sense [target]'s pain and play a healing melody.</span>")
			total_healings_performed++
		if("energizing")
			// Boost stamina and remove fatigue
			if(target.stamina)
				target.stamina.adjust(30)
			to_chat(target, "<span class='notice'>SCP-066's energizing rhythm fills you with vigor!</span>")
			to_chat(src, "<span class='notice'>You play an energizing melody for [target].</span>")

	// Play sound effect
	var/sound_file = pick('sound/scp/scp066/Notes1.ogg', 'sound/scp/scp066/Notes2.ogg', 'sound/scp/scp066/Notes3.ogg', 'sound/scp/scp066/Notes4.ogg', 'sound/scp/scp066/Notes5.ogg', 'sound/scp/scp066/Notes6.ogg')
	playsound(src, sound_file, 50)

	return TRUE

// Musical Abilities (Automatic - no verb commands as per user request)
/mob/living/simple_animal/hostile/retaliate/scp066/proc/perform_musical_ability(ability_type)
	// Simplified musical abilities
	switch(ability_type)
		if("soothing_melody")
			return perform_simple_melody("soothing", null)
		if("energizing_rhythm")
			return perform_simple_melody("energizing", null)
		if("eric_song")
			say(pick("Eric?", "Are you Eric?", "Eric, is that you?", "Have you seen Eric?"))
			total_eric_attempts++
			return TRUE

	return FALSE

// Eric Detection and Response
/mob/living/simple_animal/hostile/retaliate/scp066/proc/attempt_eric_detection()
	// Enhanced Eric detection attempt - simplified
	var/detection_range = 15 + (evolution_stage * 5)

	for(var/mob/living/carbon/human/H in range(detection_range, src))
		if(H.stat == DEAD)
			continue

		// Check if this could be Eric (placeholder logic)
		if(H.real_name && findtext(H.real_name, "Eric"))
			face_atom(H)
			say("Eric? Is that really you?")

			// Play joyful Eric sounds
			var/sound_file = pick('sound/scp/scp066/Eric1.ogg', 'sound/scp/scp066/Eric2.ogg', 'sound/scp/scp066/Eric3.ogg')
			playsound(src, sound_file, 50)

			// Update tracking
			total_eric_attempts++
			if(evolution_stage < 5)
				evolution_stage++
				update_scp066_appearance()

			return TRUE

	return FALSE

// Imitation ability (modified from original)
/mob/living/simple_animal/hostile/retaliate/scp066/proc/imitate_object(atom/movable/target)
	if(!target)
		return FALSE

	// Check size restrictions
	if(isitem(target))
		var/obj/item/item_target = target
		if(item_target.w_class > MOB_SIZE_HUMAN)
			to_chat(src, "<span class='warning'>That is too big for you to imitate!</span>")
			return FALSE

	if(ismob(target))
		var/mob/living/mob_target = target
		if(mob_target.mob_size > MOB_SIZE_SMALL)
			to_chat(src, "<span class='warning'>That is too big for you to imitate!</span>")
			return FALSE

	// Perform imitation
	var/icon/I = new /icon(target.icon, target.icon_state)
	I.ColorTone("#891313") // Red tint
	icon = I
	name = target.name
	desc = "It appears to be \a [target] made out of yarn..."

	// Add to evolution points
	if(evolution_system)
		evolution_system.add_musical_points(2)

	return TRUE

/mob/living/simple_animal/hostile/retaliate/scp066/proc/reset_appearance()
		icon = new /icon(initial(icon), initial(icon_state))
		desc = initial(desc)
		name = SCP.name

	// Update description based on evolution
	update_scp066_appearance()

// Interaction overrides
/mob/living/simple_animal/hostile/retaliate/scp066/UnarmedAttack(atom/A, proximity)
	// Imitation behavior
	if(A == src)
		reset_appearance()
			return

	if(isitem(A) || (ismob(A) && !ishuman(A) && isliving(A)))
		imitate_object(A)
			return

	// Normal attack for other targets
	return ..()

// Speech processing for Eric detection
/mob/living/simple_animal/hostile/retaliate/scp066/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	. = ..()

	// Check for Eric mentions
	if(environmental_system && speaker && ismob(speaker))
		var/mob/speaking_mob = speaker
		if(istype(speaking_mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/human_speaker = speaking_mob

			// Check for Eric in the message
			if(findtext(message, "Eric") || findtext(message, "eric") || findtext(message, "ERIC"))
				environmental_system.trigger_eric_detection(human_speaker, "eric")

// Status and examination
/mob/living/simple_animal/hostile/retaliate/scp066/examine(mob/user)
	. = ..()

	// Simplified display
	. += "<span class='notice'>Musical Energy: [round((musical_energy_level / max_musical_energy) * 100)]%</span>"
	. += "<span class='notice'>Evolution Stage: [evolution_stage]</span>"
	. += "<span class='notice'>Eric Connection: [eric_connection_strength]%</span>"

	// Sanity effects
	if(user && istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.sanity)
			H.sanity.adjust_sanity(2) // Viewing SCP-066 is slightly calming
			to_chat(H, "<span class='notice'>SCP-066's presence feels oddly comforting.</span>")

/mob/living/simple_animal/hostile/retaliate/scp066/get_status_tab_items()
	. = ..()

	// Simplified status display
	. += "Musical Energy: [musical_energy_level]/[max_musical_energy]"
	. += "Evolution Stage: [evolution_stage]"
	. += "Eric Connection: [eric_connection_strength]%"
	. += "Total Performances: [total_performances_given]"
	. += "Successful Healings: [total_healings_performed]"
	. += "Eric Attempts: [total_eric_attempts]"

// Persistence tracking methods
/mob/living/simple_animal/hostile/retaliate/scp066/proc/add_performance_record(performance_type)
	total_performances_given++

	// Add to tracking (simplified)
	total_performances_given++

/mob/living/simple_animal/hostile/retaliate/scp066/proc/add_healing_record(mob/living/carbon/human/healed_human)
	total_healings_performed++

	// Add to tracking (simplified)
	total_healings_performed++

/mob/living/simple_animal/hostile/retaliate/scp066/proc/add_eric_record(composition_type)
	total_eric_attempts++

	// Add to tracking (simplified)
	total_eric_attempts++

/mob/living/simple_animal/hostile/retaliate/scp066/proc/add_facility_integration_record(integration_type)
	total_facility_integrations++

	// Add to tracking
	total_facility_integrations++

/mob/living/simple_animal/hostile/retaliate/scp066/proc/add_evolution_record(new_stage)
	total_evolution_stages++

	// Update containment status based on evolution
	if(new_stage >= 3)
		containment_status = "enhanced_observation"
	if(new_stage >= 5)
		containment_status = "transcendent"

/mob/living/simple_animal/hostile/retaliate/scp066/proc/add_eric_detection_record(mob/living/carbon/human/detector, trigger_word)
	total_eric_detections++

	// Add to tracking (simplified)
	total_eric_detections++

// Legacy compatibility methods for research integration
/mob/living/simple_animal/hostile/retaliate/scp066/proc/get_persistence_data()
	var/list/data = list()

	data["total_performances"] = total_performances_given
	data["total_healings"] = total_healings_performed
	data["total_eric_attempts"] = total_eric_attempts
	data["total_facility_integrations"] = total_facility_integrations
	data["total_evolution_stages"] = total_evolution_stages
	data["total_eric_detections"] = total_eric_detections
	data["session_duration"] = world.time - session_start_time
	data["containment_status"] = containment_status

	// Simplified persistence data
	data["evolution_stage"] = evolution_stage
	data["musical_energy"] = musical_energy_level
	data["eric_connection"] = eric_connection_strength

	return data

/mob/living/simple_animal/hostile/retaliate/scp066/proc/load_persistence_data(list/data)
	if(!data || !islist(data))
		return

	// Load basic tracking data
	total_performances_given = data["total_performances"] || 0
	total_healings_performed = data["total_healings"] || 0
	total_eric_attempts = data["total_eric_attempts"] || 0
	total_facility_integrations = data["total_facility_integrations"] || 0
	total_evolution_stages = data["total_evolution_stages"] || 0
	total_eric_detections = data["total_eric_detections"] || 0
	containment_status = data["containment_status"] || "contained"

	// Load simplified system data
	evolution_stage = data["evolution_stage"] || 1
	musical_energy_level = data["musical_energy"] || 100
	eric_connection_strength = data["eric_connection"] || 50

/mob/living/simple_animal/hostile/retaliate/scp066/proc/contribute_research_data()
	// Simplified research contribution - can be enhanced later
	if(!SSresearch_persistence || !SSresearch_persistence.manager)
		return

	// Basic research data contribution
	var/project_name = "SCP-066 Musical Anomaly Analysis"
	var/project_description = "Analysis of SCP-066's musical abilities and Eric-seeking behavior"
	var/research_field = "SCP-066_MUSICAL"
	var/lead_researcher = "System"

	var/datum/research_persistence_project/project = SSresearch_persistence.manager.add_research_project(
		project_name,
		project_description,
		research_field,
		lead_researcher,
		10080, // 1 week
		1
	)

	if(project)
		var/progress = (total_performances_given / 5) + (total_eric_attempts / 3) + (total_healings_performed / 4)
		project.progress = min(100, progress)

// END OF SCP-066 IMPLEMENTATION
