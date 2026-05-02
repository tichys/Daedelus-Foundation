// SCP-457 - The Living Flame
// Complete Redesign Implementation

/mob/living/carbon/human/scp457
	name = "SCP-457"
	desc = "A living flame that moves with purpose and spreads with intent."
	icon = 'icons/scp/scp-457.dmi'
	icon_state = "fireguy"


	// Core system datums
	var/datum/scp457_heat_system/heat_system
	var/datum/scp457_fire_system/fire_system
	var/datum/scp457_evolution_system/evolution_system
	var/datum/scp457_containment_system/containment_system
	var/datum/scp457_environmental_system/environmental_system
	var/datum/scp457_research_integration/research_integration

	// Persistence tracking
	var/list/consumed_targets = list()
	var/total_targets_consumed = 0
	var/total_fires_created = 0
	var/total_evolution_stages = 0
	var/total_containment_encounters = 0
	var/total_environmental_control = 0
	var/session_start_time = 0

	// Progression integration tracking
	var/fires_created = 0
	var/damage_dealt = 0
	var/victims_consumed = 0

/mob/living/carbon/human/scp457/Initialize()
	. = ..()

	// Set species properly
	set_species(/datum/species/scp457)

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-457",
		SCP_KETER,
		"457",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	// Set up human-specific properties for SCP-457
	maxHealth = 150
	health = maxHealth
	// Set up physiology for fire resistance
	if(!physiology)
		physiology = new /datum/physiology(src)
	physiology.burn_mod = 0.1 // Highly resistant to fire
	physiology.brute_mod = 0.8 // Slightly resistant to brute damage

	// Initialize core systems
	heat_system = new /datum/scp457_heat_system(src)
	fire_system = new /datum/scp457_fire_system(src)
	evolution_system = new /datum/scp457_evolution_system(src)
	containment_system = new /datum/scp457_containment_system(src)
	environmental_system = new /datum/scp457_environmental_system(src)
	research_integration = new /datum/scp457_research_integration(src)

	// Enable vision cone for SCP-457
	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()

	// Set session start time
	session_start_time = world.time
		// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

	// Start processing
	START_PROCESSING(SSobj, src)

	// Create initial fires immediately
	addtimer(CALLBACK(fire_system, TYPE_PROC_REF(/datum/scp457_fire_system, create_initial_fires)), 1)

/mob/living/carbon/human/scp457/Destroy()
	QDEL_NULL(heat_system)
	QDEL_NULL(fire_system)
	QDEL_NULL(evolution_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(environmental_system)
	QDEL_NULL(research_integration)
	consumed_targets.Cut()
	return ..()

/mob/living/carbon/human/scp457/process(delta_time)
	// Don't call parent - we're implementing our own process logic

	// Update all systems
	heat_system?.process()
	fire_system?.process()
	evolution_system?.process()
	containment_system?.process()
	environmental_system?.process()
	research_integration?.process()

	// Process SCP-457 specific effects
	process_scp457_effects()

	// Return nothing to continue processing (not PROCESS_KILL)

/mob/living/carbon/human/scp457/proc/process_scp457_effects()
	// Update icon based on heat level
	update_scp457_appearance()

	// Process movement effects
	process_movement_effects()

	// Process interaction with nearby targets
	process_target_interaction()

/mob/living/carbon/human/scp457/proc/update_scp457_appearance()
	var/fire_type = heat_system.get_fire_type()

	switch(fire_type)
		if("basic")
			icon_state = "fireguy"
		if("intense")
			icon_state = "fireguy"
		if("blue")
			icon_state = "fireguy"
		if("white")
			icon_state = "fireguy"

/mob/living/carbon/human/scp457/proc/process_movement_effects()
	// Create fire trail when moving
	if(heat_system.current_heat > 25)
		var/turf/current_turf = get_turf(src)
		if(current_turf && !locate(/obj/effect/scp457_fire) in current_turf)
			fire_system.create_fire_at_turf(current_turf)

/mob/living/carbon/human/scp457/proc/process_target_interaction()
	// Check for nearby targets to consume
	for(var/mob/living/carbon/human/H in range(2, src))
		if(H != src && !H.SCP && H.stat != DEAD && !QDELETED(H))
			// Only interact with targets in vision cone
			if(fovangle && can_see_cone(H))
				attempt_target_consumption(H)

/mob/living/carbon/human/scp457/proc/attempt_target_consumption(mob/living/carbon/human/target)
	// Check if target is vulnerable
	if(target.stat == DEAD || QDELETED(target))
		return

	// Apply fire damage
	var/damage = heat_system.get_fire_type() == "white" ? 25 : 15

	// Additional safety check before applying damage
	if(!QDELETED(target) && target.stat != DEAD)
		target.adjustFireLoss(damage)
		target.adjustBruteLoss(damage / 2)

	// Add heat when consuming targets
	heat_system.add_heat(5)

	// Check if target died
	if(target.stat == DEAD)
		add_consumed_target(target)

		// Add to evolution progress
		evolution_system.add_target_consumed()

		// Notify owner
		to_chat(src, "<span class='notice'>You consume [target] with your flames. Heat: [heat_system.current_heat]/[heat_system.max_heat]</span>")

/mob/living/carbon/human/scp457/proc/add_consumed_target(mob/living/carbon/human/target)
	if(!(target in consumed_targets))
		consumed_targets += target
	total_targets_consumed++

/mob/living/carbon/human/scp457/proc/is_spreading_fires()
	return fire_system.active_fires.len > 0

/mob/living/carbon/human/scp457/proc/add_evolution_record(stage)
	total_evolution_stages = max(total_evolution_stages, stage)

/mob/living/carbon/human/scp457/proc/add_containment_record()
	total_containment_encounters++

/mob/living/carbon/human/scp457/proc/add_environmental_record()
	total_environmental_control++

// Enhanced attack behavior
/mob/living/carbon/human/scp457/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A

		// Check if target is being deleted
		if(QDELETED(L))
			return

		var/damage = 20 + (heat_system.current_heat / 10)

		// Additional safety check before applying damage
		if(!QDELETED(L) && L.stat != DEAD)
			visible_message("<span class='danger'>[src] engulfs [L] in intense flames!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

		L.adjustBruteLoss(damage)
		L.adjustFireLoss(damage)

		// Add heat from attack
		heat_system.add_heat(3)

		// Add to consumed targets if they die
		if(L.stat == DEAD && istype(L, /mob/living/carbon/human))
			add_consumed_target(L)
			evolution_system.add_target_consumed()

			// Add interaction record removed - not needed
		return

	return ..()

// Manual fire creation verb for testing
/mob/living/carbon/human/scp457/verb/create_fire()
	set name = "Create Fire"
	set category = "SCP-457"
	set desc = "Manually create a fire at your location"

	if(fire_system)
		fire_system.create_initial_fires()

// Status display
/mob/living/carbon/human/scp457/get_status_tab_items()
	. = ..()
	. += "Heat Level: [heat_system.current_heat]/[heat_system.max_heat]"
	. += "Fire Type: [heat_system.get_fire_type()]"
	. += "Active Fires: [fire_system.active_fires.len]"
	. += "Evolution Stage: [evolution_system.current_stage]/[evolution_system.max_stage]"
	. += "Containment Level: [containment_system.containment_level]"
	. += "Targets Consumed: [total_targets_consumed]"
	. += "Environmental Control: [environmental_system.controlled_room_types.len]"

// Examine behavior
/mob/living/carbon/human/scp457/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-457, a living flame that spreads and consumes. Current evolution stage: [evolution_system.current_stage]</span>")
		else
			to_chat(user, "<span class='danger'>A living flame that moves with purpose. The heat radiating from it is intense and unnatural.</span>")

			// Apply fear effect to non-SCP humans
			if(H.sanity)
				H.sanity.adjust_sanity(-2)
				H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 3)

// Persistence integration
/mob/living/carbon/human/scp457/proc/get_persistence_data()
	var/list/data = list()
	data["total_targets_consumed"] = total_targets_consumed
	data["total_fires_created"] = total_fires_created
	data["total_evolution_stages"] = total_evolution_stages
	data["total_containment_encounters"] = total_containment_encounters
	data["total_environmental_control"] = total_environmental_control
	data["session_duration"] = world.time - session_start_time
	data["current_heat"] = heat_system.current_heat
	data["current_evolution_stage"] = evolution_system.current_stage
	data["current_containment_level"] = containment_system.containment_level
	return data

/mob/living/carbon/human/scp457/proc/load_persistence_data(list/data)
	if(!data)
		return

	total_targets_consumed = data["total_targets_consumed"] || 0
	total_fires_created = data["total_fires_created"] || 0
	total_evolution_stages = data["total_evolution_stages"] || 0
	total_containment_encounters = data["total_containment_encounters"] || 0
	total_environmental_control = data["total_environmental_control"] || 0

// Research integration
/mob/living/carbon/human/scp457/proc/contribute_research_data()
	if(!SSresearch_persistence || !SSresearch_persistence.manager)
		return

	// Create research project if it doesn't exist
	var/project_name = "SCP-457 Behavioral Analysis"
	var/project_description = "Analysis of SCP-457's fire spreading and evolution patterns"
	var/research_field = "SCP-457_BEHAVIORAL"
	var/lead_researcher = "System"

	var/datum/research_persistence_project/project = SSresearch_persistence.manager.add_research_project(
		project_name,
		project_description,
		research_field,
		lead_researcher,
		1000,
		1
	)

	if(project)
		// Update project with current data
		project.progress = min(100, (total_targets_consumed * 2) + (total_fires_created / 10) + (total_evolution_stages * 10))

		// Mark as completed if enough data
		if(project.progress >= 100)
			project.status = "COMPLETED"

			// Add scientific discovery
			SSresearch_persistence.manager.add_scientific_discovery(
				"SCP-457 Behavior Patterns",
				"Comprehensive analysis of SCP-457's fire spreading and evolution mechanics",
				"SCP_RESEARCH",
				"SCP-457",
				"System",
				3 // High significance
			)

/mob/living/carbon/human/scp457/proc/on_fire_spread(turf/location)
	if(!location)
		return
	fires_created++
	total_fires_created++
	hook_facility_damage_near_scp("SCP-457", 1)

/mob/living/carbon/human/scp457/proc/on_target_consumption(mob/living/carbon/human/victim)
	if(!victim)
		return
	victims_consumed++
	hook_scp_combat(victim, "SCP-457", 100, 0)
	hook_player_death_near_scp(victim, "SCP-457")

/mob/living/carbon/human/scp457/proc/on_evolution(new_stage)
	total_evolution_stages = max(total_evolution_stages, new_stage)
	hook_scp_breach("SCP-457", src)

/mob/living/carbon/human/scp457/proc/on_containment_encounter()
	total_containment_encounters++
	return

// Legacy compatibility - removed undefined procs

// ============================================================================
// END OF SCP-457 REDESIGN
// ============================================================================
