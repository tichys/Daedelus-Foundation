// SCP-3008 - The Infinite IKEA
// An infinite IKEA store with hostile staff entities and survival mechanics

/obj/structure/scp3008
	name = "SCP-3008"
	desc = "An entrance to an infinite IKEA store. The interior seems to stretch on forever."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "scp113"
	density = TRUE
	anchored = TRUE

	// Entry mechanics
	var/obj/effect/landmark/ikea_entrance/entrance_landmark
	var/list/ikea_interiors = list()
	var/max_interiors = 10
	var/current_interior_id = 0

	// Maximum Enhanced SCP-3008 variables
	var/expansion_level = 0
	var/max_expansion_level = 1000
	var/staff_entities = 0
	var/max_staff_entities = 100
	var/survival_difficulty = 1
	var/max_survival_difficulty = 10
	var/dimensional_instability = 0
	var/max_dimensional_instability = 100
	var/resource_abundance = 1
	var/max_resource_abundance = 10
	var/expansion_mastery = 0
	var/max_expansion_mastery = 100
	var/staff_mastery = 0
	var/max_staff_mastery = 100
	var/survival_mastery = 0
	var/max_survival_mastery = 100
	var/dimensional_mastery = 0
	var/max_dimensional_mastery = 100
	var/ikea_evolution = 1
	var/max_ikea_evolution = 5
	var/expansion_cooldown = 0
	var/expansion_cooldown_time = 30 SECONDS
	var/staff_cooldown = 0
	var/staff_cooldown_time = 20 SECONDS
	var/survival_cooldown = 0
	var/survival_cooldown_time = 25 SECONDS

	// Persistence tracking
	var/expansions_performed = 0
	var/staff_events = 0
	var/survival_events = 0
	var/dimensional_events = 0
	var/resource_events = 0
	var/expansion_masteries = 0
	var/staff_masteries = 0
	var/survival_masteries = 0
	var/dimensional_masteries = 0
	var/evolution_events = 0

/obj/structure/scp3008/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-3008",
		SCP_EUCLID,
		"3008",

	)

	SCP.min_playercount = 25
	SCP.min_time = 45 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-3008"] = new /datum/scp_instance("SCP-3008", src)

	// Create entrance landmark if it doesn't exist
	if(!entrance_landmark)
		entrance_landmark = new /obj/effect/landmark/ikea_entrance(get_turf(src))

	// Create initial IKEA interior
	create_ikea_interior()

/obj/structure/scp3008/Destroy()
	// Clean up entrance landmark
	if(entrance_landmark)
		qdel(entrance_landmark)

	// Clean up IKEA interiors
	for(var/datum/ikea_interior/interior in ikea_interiors)
		qdel(interior)
	ikea_interiors = list()

	return ..()

// Entry mechanics
/obj/structure/scp3008/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return

	to_chat(user, "<span class='notice'>You approach the entrance to the infinite IKEA...</span>")
	if(alert(user, "Enter SCP-3008 - The Infinite IKEA? You may become lost inside.", "Enter IKEA", "Yes", "No") == "Yes")
		enter_ikea(user)

/obj/structure/scp3008/proc/enter_ikea(mob/living/carbon/human/user)
	if(!user || !istype(user))
		return

	// Find or create an IKEA interior
	var/datum/ikea_interior/interior = get_available_interior()
	if(!interior)
		to_chat(user, "<span class='warning'>The IKEA is currently full. Please try again later.</span>")
		return

		// Teleport user to IKEA interior
	var/turf/entry_point = interior.get_entry_point()

	// Debug the entry point
	if(!entry_point)
		to_chat(user, "<span class='warning'>Entry point is null. Interior ID: [interior.id]</span>")
		world.log << "IKEA entry failed: entry_point is null for interior [interior.id]"
		return

	if(istype(entry_point, /turf/open/space))
		to_chat(user, "<span class='warning'>Entry point is space. Interior ID: [interior.id]</span>")
		world.log << "IKEA entry failed: entry_point is space for interior [interior.id]"
		return

	// Debug info
	to_chat(user, "<span class='notice'>Teleporting to IKEA interior at [entry_point.x], [entry_point.y], [entry_point.z]</span>")
	world.log << "IKEA entry: teleporting user [user.ckey] to [entry_point.x], [entry_point.y], [entry_point.z]"

	user.forceMove(entry_point)
	to_chat(user, "<span class='danger'>You enter the infinite IKEA. The store stretches on forever in all directions...</span>")
	to_chat(user, "<span class='warning'>You hear the sound of IKEA staff approaching. They are not friendly.</span>")

	// Add user to interior's occupant list
	interior.add_occupant(user)

	// Award research points for entering
	if(SSscp_research && SSscp_research.manager)
		award_research_points("SCP-3008", "entry", 5, user.ckey)

	hook_scp_exploration(user, "SCP-3008", 0)

/obj/structure/scp3008/proc/get_available_interior()
	// Find an interior with space
	for(var/datum/ikea_interior/interior in ikea_interiors)
		if(length(interior.occupants) < interior.max_occupants)
			return interior

	// Create new interior if needed
	if(length(ikea_interiors) < max_interiors)
		return create_ikea_interior()

	return null

/obj/structure/scp3008/proc/create_ikea_interior()
	current_interior_id++
	var/datum/ikea_interior/interior = new /datum/ikea_interior(current_interior_id, src)
	ikea_interiors += interior
	return interior

// Core mechanics
/obj/structure/scp3008/process()
	. = ..()

	// Process expansion effects
	process_expansion_effects()

	// Process staff entities
	process_staff_entities()

	// Process survival mechanics
	process_survival_mechanics()

	// Process dimensional instability
	process_dimensional_instability()

	// Process IKEA evolution
	process_ikea_evolution()

// Process expansion effects
/obj/structure/scp3008/proc/process_expansion_effects()
	if(expansion_level > 0 && prob(1))
		expansion_level = min(max_expansion_level, expansion_level + 1)

// Process staff entities
/obj/structure/scp3008/proc/process_staff_entities()
	if(staff_entities > 0 && prob(2))
		// Create staff entity effects
		for(var/mob/living/carbon/human/H in range(8, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>You hear the sound of IKEA staff approaching...</span>")
				H.adjustBruteLoss(10)
				staff_events++

// Process survival mechanics
/obj/structure/scp3008/proc/process_survival_mechanics()
	if(survival_difficulty > 1 && prob(1))
		// Create survival challenges
		for(var/mob/living/carbon/human/H in range(6, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='warning'>The IKEA becomes more hostile and difficult to navigate...</span>")
				survival_events++

// Process dimensional instability
/obj/structure/scp3008/proc/process_dimensional_instability()
	if(dimensional_instability > 0 && prob(1))
		// Create dimensional effects
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>The IKEA's dimensions begin to shift and change...</span>")
				dimensional_events++

// Process IKEA evolution
/obj/structure/scp3008/proc/process_ikea_evolution()
	if(expansion_level >= max_expansion_level && ikea_evolution < max_ikea_evolution)
		if(prob(1))
			evolve_ikea_stage()

// Evolve IKEA stage
/obj/structure/scp3008/proc/evolve_ikea_stage()
	ikea_evolution = min(max_ikea_evolution, ikea_evolution + 1)
	evolution_events++

	var/evolution_message = ""
	switch(ikea_evolution)
		if(2)
			evolution_message = "SCP-3008 evolves enhanced staff entities!"
		if(3)
			evolution_message = "SCP-3008 evolves survival mechanics!"
		if(4)
			evolution_message = "SCP-3008 evolves dimensional manipulation!"
		if(5)
			evolution_message = "SCP-3008 achieves ultimate IKEA evolution!"

	visible_message("<span class='danger'>[evolution_message]</span>")

// Maximum enhanced abilities
/obj/structure/scp3008/proc/expansion_mastery_ability()
	if(expansion_mastery >= max_expansion_mastery)
		to_chat(usr, "<span class='warning'>SCP-3008 has reached maximum expansion mastery.</span>")
		return

	expansion_mastery = min(max_expansion_mastery, expansion_mastery + 10)
	expansion_masteries++

	to_chat(usr, "<span class='notice'>SCP-3008's expansion mastery is enhanced. Mastery: [expansion_mastery]/[max_expansion_mastery]</span>")

/obj/structure/scp3008/proc/staff_mastery_ability()
	if(world.time < staff_cooldown)
		to_chat(usr, "<span class='warning'>SCP-3008 needs time to master staff entities again.</span>")
		return

	staff_cooldown = world.time + staff_cooldown_time
	staff_mastery = min(max_staff_mastery, staff_mastery + 10)
	staff_masteries++

	to_chat(usr, "<span class='notice'>SCP-3008's staff mastery is enhanced. Mastery: [staff_mastery]/[max_staff_mastery]</span>")

/obj/structure/scp3008/proc/survival_mastery_ability()
	if(world.time < survival_cooldown)
		to_chat(usr, "<span class='warning'>SCP-3008 needs time to master survival mechanics again.</span>")
		return

	survival_cooldown = world.time + survival_cooldown_time
	survival_mastery = min(max_survival_mastery, survival_mastery + 10)
	survival_masteries++

	to_chat(usr, "<span class='notice'>SCP-3008's survival mastery is enhanced. Mastery: [survival_mastery]/[max_survival_mastery]</span>")

/obj/structure/scp3008/proc/dimensional_mastery_ability()
	dimensional_mastery = min(max_dimensional_mastery, dimensional_mastery + 10)
	dimensional_masteries++

	to_chat(usr, "<span class='notice'>SCP-3008's dimensional mastery is enhanced. Mastery: [dimensional_mastery]/[max_dimensional_mastery]</span>")

/obj/structure/scp3008/proc/evolve_ikea_ability()
	if(ikea_evolution >= max_ikea_evolution)
		to_chat(usr, "<span class='warning'>SCP-3008 has reached maximum evolution.</span>")
		return

	if(expansion_level < max_expansion_level)
		to_chat(usr, "<span class='warning'>SCP-3008 needs more expansion levels to evolve.</span>")
		return

	evolve_ikea_stage()

/obj/structure/scp3008/proc/resource_abundance_ability()
	if(resource_abundance >= max_resource_abundance)
		to_chat(usr, "<span class='warning'>SCP-3008 has reached maximum resource abundance.</span>")
		return

	resource_abundance = min(max_resource_abundance, resource_abundance + 1)
	resource_events++

	to_chat(usr, "<span class='notice'>SCP-3008's resource abundance is enhanced. Abundance: [resource_abundance]/[max_resource_abundance]</span>")

/obj/structure/scp3008/proc/staff_entity_ability()
	staff_entities = min(max_staff_entities, staff_entities + 10)
	staff_events++

	to_chat(usr, "<span class='notice'>SCP-3008 creates staff entities. Entities: [staff_entities]/[max_staff_entities]</span>")

/obj/structure/scp3008/proc/survival_difficulty_ability()
	survival_difficulty = min(max_survival_difficulty, survival_difficulty + 1)
	survival_events++

	to_chat(usr, "<span class='notice'>SCP-3008 increases survival difficulty. Difficulty: [survival_difficulty]/[max_survival_difficulty]</span>")

/obj/structure/scp3008/proc/dimensional_instability_ability()
	dimensional_instability = min(max_dimensional_instability, dimensional_instability + 20)
	dimensional_events++

	to_chat(usr, "<span class='notice'>SCP-3008 creates dimensional instability. Instability: [dimensional_instability]/[max_dimensional_instability]</span>")

/obj/structure/scp3008/proc/ultimate_ikea_ability()
	if(ikea_evolution < max_ikea_evolution)
		to_chat(usr, "<span class='warning'>SCP-3008 needs maximum evolution for ultimate IKEA.</span>")
		return

	// Ultimate IKEA affects all nearby targets
	for(var/mob/living/carbon/human/H in range(12, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='danger'>You experience SCP-3008's ultimate infinite IKEA!</span>")
			H.adjustBruteLoss(75)

	to_chat(usr, "<span class='notice'>SCP-3008 performs ultimate IKEA on all nearby targets.</span>")

/obj/structure/scp3008/proc/ikea_synthesis_ability()
	if(expansion_level < max_expansion_level)
		to_chat(usr, "<span class='warning'>SCP-3008 needs more expansion levels to synthesize.</span>")
		return

	// Create a powerful IKEA effect
	for(var/mob/living/carbon/human/H in range(10, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='danger'>You feel yourself being pulled into an infinite IKEA dimension...</span>")

	to_chat(usr, "<span class='notice'>SCP-3008 synthesizes IKEA and affects all nearby targets.</span>")

// Enhanced status display
/obj/structure/scp3008/proc/get_ikea_status()
	var/message = "<h2>SCP-3008 IKEA Status</h2>"
	message += "<b>Expansion Level:</b> [expansion_level]/[max_expansion_level]<br>"
	message += "<b>Staff Entities:</b> [staff_entities]/[max_staff_entities]<br>"
	message += "<b>Survival Difficulty:</b> [survival_difficulty]/[max_survival_difficulty]<br>"
	message += "<b>Dimensional Instability:</b> [dimensional_instability]/[max_dimensional_instability]<br>"
	message += "<b>Resource Abundance:</b> [resource_abundance]/[max_resource_abundance]<br>"
	message += "<b>Expansion Mastery:</b> [expansion_mastery]/[max_expansion_mastery]<br>"
	message += "<b>Staff Mastery:</b> [staff_mastery]/[max_staff_mastery]<br>"
	message += "<b>Survival Mastery:</b> [survival_mastery]/[max_survival_mastery]<br>"
	message += "<b>Dimensional Mastery:</b> [dimensional_mastery]/[max_dimensional_mastery]<br>"
	message += "<b>IKEA Evolution:</b> [ikea_evolution]/[max_ikea_evolution]<br>"

	return message

// Enhanced verbs
/obj/structure/scp3008/verb/expansion_mastery()
	set name = "Expansion Mastery"
	set category = "SCP-3008"
	set desc = "Enhance SCP-3008's expansion mastery."

	expansion_mastery_ability()

/obj/structure/scp3008/verb/staff_mastery()
	set name = "Staff Mastery"
	set category = "SCP-3008"
	set desc = "Enhance SCP-3008's staff mastery."

	staff_mastery_ability()

/obj/structure/scp3008/verb/survival_mastery()
	set name = "Survival Mastery"
	set category = "SCP-3008"
	set desc = "Enhance SCP-3008's survival mastery."

	survival_mastery_ability()

/obj/structure/scp3008/verb/dimensional_mastery()
	set name = "Dimensional Mastery"
	set category = "SCP-3008"
	set desc = "Enhance SCP-3008's dimensional mastery."

	dimensional_mastery_ability()

/obj/structure/scp3008/verb/evolve_ikea()
	set name = "Evolve IKEA"
	set category = "SCP-3008"
	set desc = "Evolve SCP-3008's IKEA capabilities."

	evolve_ikea_ability()

/obj/structure/scp3008/verb/resource_abundance()
	set name = "Resource Abundance"
	set category = "SCP-3008"
	set desc = "Enhance SCP-3008's resource abundance."

	resource_abundance_ability()

/obj/structure/scp3008/verb/staff_entity()
	set name = "Staff Entity"
	set category = "SCP-3008"
	set desc = "Create staff entities."

	staff_entity_ability()

/obj/structure/scp3008/verb/survival_difficulty()
	set name = "Survival Difficulty"
	set category = "SCP-3008"
	set desc = "Increase survival difficulty."

	survival_difficulty_ability()

/obj/structure/scp3008/verb/dimensional_instability()
	set name = "Dimensional Instability"
	set category = "SCP-3008"
	set desc = "Create dimensional instability effects."

	dimensional_instability_ability()

/obj/structure/scp3008/verb/ultimate_ikea()
	set name = "Ultimate IKEA"
	set category = "SCP-3008"
	set desc = "Perform ultimate IKEA on all nearby targets."

	ultimate_ikea_ability()

/obj/structure/scp3008/verb/ikea_synthesis()
	set name = "IKEA Synthesis"
	set category = "SCP-3008"
	set desc = "Synthesize IKEA and affect all nearby targets."

	ikea_synthesis_ability()

// Admin verb to view SCP-3008 persistence data
/obj/structure/scp3008/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP-3008"
	set desc = "View SCP-3008 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-3008 Persistence Data</h2>"
	message += "<b>Expansions Performed:</b> [expansions_performed]<br>"
	message += "<b>Staff Events:</b> [staff_events]<br>"
	message += "<b>Survival Events:</b> [survival_events]<br>"
	message += "<b>Dimensional Events:</b> [dimensional_events]<br>"
	message += "<b>Resource Events:</b> [resource_events]<br>"
	message += "<b>Expansion Masteries:</b> [expansion_masteries]<br>"
	message += "<b>Staff Masteries:</b> [staff_masteries]<br>"
	message += "<b>Survival Masteries:</b> [survival_masteries]<br>"
	message += "<b>Dimensional Masteries:</b> [dimensional_masteries]<br>"
	message += "<b>Evolution Events:</b> [evolution_events]<br>"
	message += "<b>Expansion Level:</b> [expansion_level]/[max_expansion_level]<br>"
	message += "<b>Staff Entities:</b> [staff_entities]/[max_staff_entities]<br>"
	message += "<b>Survival Difficulty:</b> [survival_difficulty]/[max_survival_difficulty]<br>"
	message += "<b>Dimensional Instability:</b> [dimensional_instability]/[max_dimensional_instability]<br>"
	message += "<b>Resource Abundance:</b> [resource_abundance]/[max_resource_abundance]<br>"
	message += "<b>Expansion Mastery:</b> [expansion_mastery]/[max_expansion_mastery]<br>"
	message += "<b>Staff Mastery:</b> [staff_mastery]/[max_staff_mastery]<br>"
	message += "<b>Survival Mastery:</b> [survival_mastery]/[max_survival_mastery]<br>"
	message += "<b>Dimensional Mastery:</b> [dimensional_mastery]/[max_dimensional_mastery]<br>"
	message += "<b>IKEA Evolution:</b> [ikea_evolution]/[max_ikea_evolution]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-3008"]
		if(instance)
			message += "<b>Interaction History:</b> [length(instance.interaction_history)] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-3008
/obj/structure/scp3008/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-3008, an infinite IKEA store with hostile staff entities.</span>")
		else
			to_chat(user, "<span class='danger'>An entrance to an IKEA store that seems to stretch on infinitely into the distance.</span>")
			to_chat(user, "<span class='notice'>You can click on this to enter the IKEA.</span>")

// IKEA Interior Datum
/datum/ikea_interior
	var/id
	var/obj/structure/scp3008/parent_entrance
	var/list/occupants = list()
	var/max_occupants = 20
	var/turf/entry_point
	var/list/ikea_turfs = list()
	var/staff_entities = list()
	var/resource_spawns = list()

/datum/ikea_interior/New(interior_id, obj/structure/scp3008/entrance)
	id = interior_id
	parent_entrance = entrance
	generate_interior()

/datum/ikea_interior/Destroy()
	// Clean up occupants
	for(var/mob/living/carbon/human/occupant in occupants)
		if(occupant && occupant.loc)
			// Try to return them to the entrance
			if(parent_entrance && parent_entrance.loc)
				occupant.forceMove(get_turf(parent_entrance))
				to_chat(occupant, "<span class='notice'>You are ejected from the IKEA.</span>")
			else
				// Emergency teleport to a safe location
				var/turf/safe_turf = pick(GLOB.station_turfs)
				if(safe_turf)
					occupant.forceMove(safe_turf)
					to_chat(occupant, "<span class='notice'>You are teleported to safety.</span>")

	// Clean up staff entities
	for(var/mob/living/simple_animal/hostile/ikea_staff/staff in staff_entities)
		qdel(staff)

	// Clean up resource spawns
	for(var/obj/item/resource in resource_spawns)
		qdel(resource)

	occupants = list()
	staff_entities = list()
	resource_spawns = list()

	return ..()

/datum/ikea_interior/proc/generate_interior()
	// Create a new z-level for this IKEA interior with proper gravity
	var/datum/space_level/new_level = SSmapping.add_new_zlevel("IKEA Interior [id]", list(ZTRAIT_STATION = TRUE, ZTRAIT_GRAVITY = TRUE))
	if(!new_level)
		world.log << "Failed to create IKEA interior z-level for interior [id]"
		return

	world.log << "Created IKEA interior z-level [new_level.z_value] for interior [id]"

	// Generate IKEA labyrinth environment
	generate_ikea_labyrinth(new_level.z_value)

	// Set entry point - ensure it's a valid floor tile
	entry_point = locate(50, 50, new_level.z_value)
	world.log << "IKEA interior [id]: Initial entry point at 50,50 is [entry_point ? "valid" : "null"]"

	if(!entry_point)
		world.log << "IKEA interior [id]: Entry point is null, trying to create one"
		var/turf/center_turf = locate(50, 50, new_level.z_value)
		if(center_turf)
			center_turf.ChangeTurf(/turf/open/floor/wood)
			entry_point = center_turf
			world.log << "IKEA interior [id]: Created entry point at 50,50"
		else
			world.log << "IKEA interior [id]: Failed to create entry point at 50,50"
			// Emergency fallback - use a station turf
			entry_point = pick(GLOB.station_turfs)
			world.log << "IKEA interior [id] using fallback entry point at [entry_point.x], [entry_point.y], [entry_point.z]"
	else
		// Force the entry point to be a floor tile
		if(!istype(entry_point, /turf/open/floor))
			world.log << "IKEA interior [id]: Converting entry point to floor tile"
			entry_point.ChangeTurf(/turf/open/floor/wood)

		// Double-check it's now a floor tile
		if(!istype(entry_point, /turf/open/floor))
			world.log << "IKEA interior [id]: Entry point conversion failed, searching for valid floor"
			// Find a valid floor tile in the IKEA
			for(var/x in 45 to 55)
				for(var/y in 45 to 55)
					var/turf/T = locate(x, y, new_level.z_value)
					if(T && istype(T, /turf/open/floor))
						entry_point = T
						world.log << "IKEA interior [id]: Found valid entry point at [x],[y]"
						break
				if(entry_point)
					break

			if(!entry_point)
				world.log << "IKEA interior [id]: No valid floor found, using fallback"
				entry_point = pick(GLOB.station_turfs)

	world.log << "IKEA interior [id]: Final entry point is [entry_point ? "valid" : "null"] at [entry_point ? "[entry_point.x],[entry_point.y],[entry_point.z]" : "N/A"]"

/datum/ikea_interior/proc/generate_ikea_labyrinth(z_level)
	world.log << "IKEA interior: Starting labyrinth generation for z-level [z_level]"

	// Create perimeter walls first
	world.log << "IKEA interior: Creating perimeter walls"
	for(var/x in 1 to 100)
		for(var/y in 1 to 100)
			var/turf/T = locate(x, y, z_level)
			if(T)
				if(x == 1 || x == 100 || y == 1 || y == 100)
					T.ChangeTurf(/turf/closed/wall/mineral/wood)
				else
					T.ChangeTurf(/turf/open/floor/wood)
				ikea_turfs += T

	// Generate labyrinth structure
	world.log << "IKEA interior: Generating labyrinth structure"
	generate_labyrinth_structure(z_level)

	// Create random rooms
	world.log << "IKEA interior: Creating random rooms"
	create_random_rooms(z_level)

	// Create corridors and paths
	world.log << "IKEA interior: Creating corridors"
	create_corridors(z_level)

	// Add loot and resources
	world.log << "IKEA interior: Adding loot and resources"
	add_labyrinth_loot(z_level)

	// Create IKEA sections
	create_ikea_sections(z_level)

	// Spawn IKEA staff entities
	spawn_ikea_staff(z_level)

	// Spawn additional resources
	spawn_resources(z_level)

	world.log << "IKEA interior: Labyrinth generation completed for z-level [z_level]"

/datum/ikea_interior/proc/generate_labyrinth_structure(z_level)
	// Create a basic labyrinth structure with walls and paths
	world.log << "IKEA interior: Creating labyrinth walls and paths"

	// Create main corridors
	for(var/x in 10 to 90 step 20)
		for(var/y in 10 to 90)
			var/turf/T = locate(x, y, z_level)
			if(T && istype(T, /turf/open/floor/wood))
				T.ChangeTurf(/turf/closed/wall/mineral/wood)

	for(var/y in 10 to 90 step 20)
		for(var/x in 10 to 90)
			var/turf/T = locate(x, y, z_level)
			if(T && istype(T, /turf/open/floor/wood))
				T.ChangeTurf(/turf/closed/wall/mineral/wood)

	// Create some random internal walls
	for(var/i in 1 to 15)
		var/start_x = rand(15, 85)
		var/start_y = rand(15, 85)
		var/length = rand(5, 15)
		var/direction = pick(NORTH, SOUTH, EAST, WEST)

		for(var/j in 1 to length)
			var/turf/T
			switch(direction)
				if(NORTH)
					T = locate(start_x, start_y + j, z_level)
				if(SOUTH)
					T = locate(start_x, start_y - j, z_level)
				if(EAST)
					T = locate(start_x + j, start_y, z_level)
				if(WEST)
					T = locate(start_x - j, start_y, z_level)

			if(T && istype(T, /turf/open/floor/wood))
				T.ChangeTurf(/turf/closed/wall/mineral/wood)

/datum/ikea_interior/proc/create_proper_room(z_level, room_x, room_y, room_width, room_height, room_type, room_num)
	// Create a proper room with walls, doors, and themed furniture
	world.log << "IKEA interior: Creating [room_type] room [room_num] at [room_x],[room_y]"

	// Create room walls
	for(var/x in room_x to room_x + room_width)
		for(var/y in room_y to room_y + room_height)
			var/turf/T = locate(x, y, z_level)
			if(T)
				// Create walls around the perimeter
				if(x == room_x || x == room_x + room_width || y == room_y || y == room_y + room_height)
					if(istype(T, /turf/open/floor/wood))
						T.ChangeTurf(/turf/closed/wall/mineral/wood)
				else
					// Ensure floor inside room
					if(istype(T, /turf/closed/wall/mineral/wood))
						T.ChangeTurf(/turf/open/floor/wood)

	// Add door to the room
	add_room_door(z_level, room_x, room_y, room_width, room_height)

	// Add room-specific furniture and decorations
	furnish_room(z_level, room_x, room_y, room_width, room_height, room_type)

/datum/ikea_interior/proc/add_room_door(z_level, room_x, room_y, room_width, room_height)
	// Add a door to the room (randomly on one of the walls)
	var/door_side = pick("north", "south", "east", "west")
	var/door_x = room_x
	var/door_y = room_y

	switch(door_side)
		if("north")
			door_x = rand(room_x + 2, room_x + room_width - 2)
			door_y = room_y + room_height
		if("south")
			door_x = rand(room_x + 2, room_x + room_width - 2)
			door_y = room_y
		if("east")
			door_x = room_x + room_width
			door_y = rand(room_y + 2, room_y + room_height - 2)
		if("west")
			door_x = room_x
			door_y = rand(room_y + 2, room_y + room_height - 2)

	var/turf/door_turf = locate(door_x, door_y, z_level)
	if(door_turf && istype(door_turf, /turf/closed/wall/mineral/wood))
		door_turf.ChangeTurf(/turf/open/floor/wood)
		new /obj/structure/mineral_door/wood(door_turf)

/datum/ikea_interior/proc/furnish_room(z_level, room_x, room_y, room_width, room_height, room_type)
	// Furnish the room based on its type
	switch(room_type)
		if("bedroom")
			furnish_bedroom(z_level, room_x, room_y, room_width, room_height)
		if("kitchen")
			furnish_kitchen(z_level, room_x, room_y, room_width, room_height)
		if("living_room")
			furnish_living_room(z_level, room_x, room_y, room_width, room_height)
		if("bathroom")
			furnish_bathroom(z_level, room_x, room_y, room_width, room_height)
		if("office")
			furnish_office(z_level, room_x, room_y, room_width, room_height)
		if("storage")
			furnish_storage_room(z_level, room_x, room_y, room_width, room_height)
		if("dining_room")
			furnish_dining_room(z_level, room_x, room_y, room_width, room_height)
		if("study")
			furnish_study(z_level, room_x, room_y, room_width, room_height)

/datum/ikea_interior/proc/furnish_bedroom(z_level, room_x, room_y, room_width, room_height)
	// Furnish a bedroom with beds, wardrobes, and bedside tables
	var/bed_x = room_x + 2
	var/bed_y = room_y + 2
	var/turf/bed_turf = locate(bed_x, bed_y, z_level)
	if(bed_turf && istype(bed_turf, /turf/open/floor/wood))
		new /obj/structure/bed(bed_turf)

	// Add wardrobe
	var/wardrobe_x = room_x + room_width - 2
	var/wardrobe_y = room_y + 2
	var/turf/wardrobe_turf = locate(wardrobe_x, wardrobe_y, z_level)
	if(wardrobe_turf && istype(wardrobe_turf, /turf/open/floor/wood))
		new /obj/structure/closet/wardrobe(wardrobe_turf)

	// Add bedside table
	var/table_x = room_x + 2
	var/table_y = room_y + 3
	var/turf/table_turf = locate(table_x, table_y, z_level)
	if(table_turf && istype(table_turf, /turf/open/floor/wood))
		new /obj/structure/table/wood(table_turf)

	// Add lighting
	var/light_x = room_x + (room_width / 2)
	var/light_y = room_y + (room_height / 2)
	var/turf/light_turf = locate(light_x, light_y, z_level)
	if(light_turf && istype(light_turf, /turf/open/floor/wood))
		new /obj/machinery/light/small(light_turf)

/datum/ikea_interior/proc/furnish_kitchen(z_level, room_x, room_y, room_width, room_height)
	// Furnish a kitchen with appliances and counters
	// Add kitchen table
	var/table_x = room_x + (room_width / 2) - 1
	var/table_y = room_y + (room_height / 2) - 1
	for(var/x in table_x to table_x + 2)
		for(var/y in table_y to table_y + 2)
			var/turf/T = locate(x, y, z_level)
			if(T && istype(T, /turf/open/floor/wood))
				new /obj/structure/table/wood(T)

	// Add sink
	var/sink_x = room_x + 2
	var/sink_y = room_y + 2
	var/turf/sink_turf = locate(sink_x, sink_y, z_level)
	if(sink_turf && istype(sink_turf, /turf/open/floor/wood))
		new /obj/structure/sink(sink_turf)

	// Add refrigerator
	var/fridge_x = room_x + room_width - 2
	var/fridge_y = room_y + 2
	var/turf/fridge_turf = locate(fridge_x, fridge_y, z_level)
	if(fridge_turf && istype(fridge_turf, /turf/open/floor/wood))
		new /obj/structure/closet(fridge_turf)
		var/obj/structure/closet/fridge = locate(/obj/structure/closet) in fridge_turf
		if(fridge)
			fridge.name = "Refrigerator"

	// Add lighting
	var/light_x = room_x + (room_width / 2)
	var/light_y = room_y + (room_height / 2)
	var/turf/light_turf = locate(light_x, light_y, z_level)
	if(light_turf && istype(light_turf, /turf/open/floor/wood))
		new /obj/machinery/light/small(light_turf)

/datum/ikea_interior/proc/furnish_living_room(z_level, room_x, room_y, room_width, room_height)
	// Furnish a living room with sofas, tables, and entertainment
	// Add sofa (multiple chairs in a row)
	for(var/i in 0 to 2)
		var/sofa_x = room_x + 2 + i
		var/sofa_y = room_y + 2
		var/turf/sofa_turf = locate(sofa_x, sofa_y, z_level)
		if(sofa_turf && istype(sofa_turf, /turf/open/floor/wood))
			new /obj/structure/chair(sofa_turf)

	// Add coffee table
	var/table_x = room_x + (room_width / 2)
	var/table_y = room_y + 4
	var/turf/table_turf = locate(table_x, table_y, z_level)
	if(table_turf && istype(table_turf, /turf/open/floor/wood))
		new /obj/structure/table/wood(table_turf)

	// Add TV stand
	var/tv_x = room_x + room_width - 2
	var/tv_y = room_y + (room_height / 2)
	var/turf/tv_turf = locate(tv_x, tv_y, z_level)
	if(tv_turf && istype(tv_turf, /turf/open/floor/wood))
		new /obj/structure/table/wood(tv_turf)

	// Add lighting
	var/light_x = room_x + (room_width / 2)
	var/light_y = room_y + (room_height / 2)
	var/turf/light_turf = locate(light_x, light_y, z_level)
	if(light_turf && istype(light_turf, /turf/open/floor/wood))
		new /obj/machinery/light/small(light_turf)

/datum/ikea_interior/proc/furnish_bathroom(z_level, room_x, room_y, room_width, room_height)
	// Furnish a bathroom with toilet, sink, and shower
	// Add toilet
	var/toilet_x = room_x + 2
	var/toilet_y = room_y + 2
	var/turf/toilet_turf = locate(toilet_x, toilet_y, z_level)
	if(toilet_turf && istype(toilet_turf, /turf/open/floor/wood))
		new /obj/structure/toilet(toilet_turf)

	// Add sink
	var/sink_x = room_x + room_width - 2
	var/sink_y = room_y + 2
	var/turf/sink_turf = locate(sink_x, sink_y, z_level)
	if(sink_turf && istype(sink_turf, /turf/open/floor/wood))
		new /obj/structure/sink(sink_turf)

	// Add shower (using sink as placeholder)
	var/shower_x = room_x + 2
	var/shower_y = room_y + room_height - 2
	var/turf/shower_turf = locate(shower_x, shower_y, z_level)
	if(shower_turf && istype(shower_turf, /turf/open/floor/wood))
		new /obj/structure/sink(shower_turf)
		var/obj/structure/sink/shower = locate(/obj/structure/sink) in shower_turf
		if(shower)
			shower.name = "Shower"

	// Add lighting
	var/light_x = room_x + (room_width / 2)
	var/light_y = room_y + (room_height / 2)
	var/turf/light_turf = locate(light_x, light_y, z_level)
	if(light_turf && istype(light_turf, /turf/open/floor/wood))
		new /obj/machinery/light/small(light_turf)

/datum/ikea_interior/proc/furnish_office(z_level, room_x, room_y, room_width, room_height)
	// Furnish an office with desk, chair, and filing cabinet
	// Add desk
	var/desk_x = room_x + (room_width / 2) - 1
	var/desk_y = room_y + (room_height / 2) - 1
	for(var/x in desk_x to desk_x + 2)
		var/turf/T = locate(x, desk_y, z_level)
		if(T && istype(T, /turf/open/floor/wood))
			new /obj/structure/table/wood(T)

	// Add office chair
	var/chair_x = room_x + (room_width / 2)
	var/chair_y = room_y + (room_height / 2) - 2
	var/turf/chair_turf = locate(chair_x, chair_y, z_level)
	if(chair_turf && istype(chair_turf, /turf/open/floor/wood))
		new /obj/structure/chair(chair_turf)

	// Add filing cabinet
	var/cabinet_x = room_x + room_width - 2
	var/cabinet_y = room_y + 2
	var/turf/cabinet_turf = locate(cabinet_x, cabinet_y, z_level)
	if(cabinet_turf && istype(cabinet_turf, /turf/open/floor/wood))
		new /obj/structure/closet(cabinet_turf)

	// Add lighting
	var/light_x = room_x + (room_width / 2)
	var/light_y = room_y + (room_height / 2)
	var/turf/light_turf = locate(light_x, light_y, z_level)
	if(light_turf && istype(light_turf, /turf/open/floor/wood))
		new /obj/machinery/light/small(light_turf)

/datum/ikea_interior/proc/furnish_storage_room(z_level, room_x, room_y, room_width, room_height)
	// Furnish a storage room with shelves and boxes
	// Add shelves along walls
	for(var/i in 1 to room_width - 2)
		var/shelf_x = room_x + i
		var/shelf_y = room_y + 2
		var/turf/shelf_turf = locate(shelf_x, shelf_y, z_level)
		if(shelf_turf && istype(shelf_turf, /turf/open/floor/wood) && prob(30))
			new /obj/structure/rack(shelf_turf)

	// Add storage boxes
	for(var/i in 1 to 3)
		var/box_x = rand(room_x + 2, room_x + room_width - 2)
		var/box_y = rand(room_y + 2, room_y + room_height - 2)
		var/turf/box_turf = locate(box_x, box_y, z_level)
		if(box_turf && istype(box_turf, /turf/open/floor/wood))
			new /obj/structure/closet(box_turf)

	// Add lighting
	var/light_x = room_x + (room_width / 2)
	var/light_y = room_y + (room_height / 2)
	var/turf/light_turf = locate(light_x, light_y, z_level)
	if(light_turf && istype(light_turf, /turf/open/floor/wood))
		new /obj/machinery/light/small(light_turf)

/datum/ikea_interior/proc/furnish_dining_room(z_level, room_x, room_y, room_width, room_height)
	// Furnish a dining room with table and chairs
	// Add dining table
	var/table_x = room_x + (room_width / 2) - 2
	var/table_y = room_y + (room_height / 2) - 2
	for(var/x in table_x to table_x + 4)
		for(var/y in table_y to table_y + 2)
			var/turf/T = locate(x, y, z_level)
			if(T && istype(T, /turf/open/floor/wood))
				new /obj/structure/table/wood(T)

	// Add chairs around the table
	for(var/i in 0 to 3)
		var/chair_x = table_x + (i * 2)
		var/chair_y = table_y - 1
		var/turf/chair_turf = locate(chair_x, chair_y, z_level)
		if(chair_turf && istype(chair_turf, /turf/open/floor/wood))
			new /obj/structure/chair(chair_turf)

	// Add lighting
	var/light_x = room_x + (room_width / 2)
	var/light_y = room_y + (room_height / 2)
	var/turf/light_turf = locate(light_x, light_y, z_level)
	if(light_turf && istype(light_turf, /turf/open/floor/wood))
		new /obj/machinery/light/small(light_turf)

/datum/ikea_interior/proc/furnish_study(z_level, room_x, room_y, room_width, room_height)
	// Furnish a study with desk, bookshelves, and comfortable chair
	// Add desk
	var/desk_x = room_x + 2
	var/desk_y = room_y + 2
	for(var/x in desk_x to desk_x + 2)
		var/turf/T = locate(x, desk_y, z_level)
		if(T && istype(T, /turf/open/floor/wood))
			new /obj/structure/table/wood(T)

	// Add comfortable chair
	var/chair_x = room_x + 3
	var/chair_y = room_y + 1
	var/turf/chair_turf = locate(chair_x, chair_y, z_level)
	if(chair_turf && istype(chair_turf, /turf/open/floor/wood))
		new /obj/structure/chair(chair_turf)

	// Add bookshelves
	for(var/i in 1 to 2)
		var/shelf_x = room_x + room_width - 2
		var/shelf_y = room_y + 2 + i
		var/turf/shelf_turf = locate(shelf_x, shelf_y, z_level)
		if(shelf_turf && istype(shelf_turf, /turf/open/floor/wood))
			new /obj/structure/rack(shelf_turf)

	// Add lighting
	var/light_x = room_x + (room_width / 2)
	var/light_y = room_y + (room_height / 2)
	var/turf/light_turf = locate(light_x, light_y, z_level)
	if(light_turf && istype(light_turf, /turf/open/floor/wood))
		new /obj/machinery/light/small(light_turf)

/datum/ikea_interior/proc/create_random_rooms(z_level)
	// Create random rooms throughout the labyrinth
	world.log << "IKEA interior: Creating enhanced rooms"

	// Create more rooms with better variety
	for(var/room_num in 1 to 15)
		var/room_x = rand(15, 75)
		var/room_y = rand(15, 75)
		var/room_width = rand(8, 16)
		var/room_height = rand(8, 16)
		var/room_type = pick("bedroom", "kitchen", "living_room", "bathroom", "office", "storage", "dining_room", "study")

		// Create proper room with walls
		create_proper_room(z_level, room_x, room_y, room_width, room_height, room_type, room_num)

	world.log << "IKEA interior: Created 15 enhanced rooms"

/datum/ikea_interior/proc/create_corridors(z_level)
	// Create connecting corridors between areas
	world.log << "IKEA interior: Creating connecting corridors"

	// Create some diagonal paths
	for(var/i in 1 to 5)
		var/start_x = rand(20, 80)
		var/start_y = rand(20, 80)
		var/end_x = rand(20, 80)
		var/end_y = rand(20, 80)

		// Create path between points
		var/current_x = start_x
		var/current_y = start_y

		while(current_x != end_x || current_y != end_y)
			var/turf/T = locate(current_x, current_y, z_level)
			if(T && istype(T, /turf/closed/wall/mineral/wood))
				T.ChangeTurf(/turf/open/floor/wood)

			// Move towards end point
			if(current_x < end_x)
				current_x++
			else if(current_x > end_x)
				current_x--
			if(current_y < end_y)
				current_y++
			else if(current_y > end_y)
				current_y--

/datum/ikea_interior/proc/add_labyrinth_loot(z_level)
	// Add various loot and resources throughout the labyrinth
	world.log << "IKEA interior: Adding loot and resources"

	// Add food and water caches
	for(var/i in 1 to 6)
		var/loot_x = rand(20, 80)
		var/loot_y = rand(20, 80)
		var/turf/T = locate(loot_x, loot_y, z_level)
		if(T && istype(T, /turf/open/floor/wood))
			spawn_loot_cache(T)

	// Add tool caches
	for(var/i in 1 to 4)
		var/loot_x = rand(20, 80)
		var/loot_y = rand(20, 80)
		var/turf/T = locate(loot_x, loot_y, z_level)
		if(T && istype(T, /turf/open/floor/wood))
			spawn_tool_cache(T)

	// Add medical supplies
	for(var/i in 1 to 3)
		var/loot_x = rand(20, 80)
		var/loot_y = rand(20, 80)
		var/turf/T = locate(loot_x, loot_y, z_level)
		if(T && istype(T, /turf/open/floor/wood))
			spawn_medical_cache(T)

/datum/ikea_interior/proc/add_room_furniture(turf/T, room_num)
	// Add furniture specific to room types
	switch(room_num)
		if(1 to 2) // Bedroom
			if(prob(30))
				new /obj/structure/bed(T)
			if(prob(25))
				new /obj/structure/closet/wardrobe(T)
		if(3 to 4) // Kitchen
			if(prob(30))
				new /obj/structure/table(T)
			if(prob(20))
				new /obj/structure/sink(T)
		if(5 to 6) // Living room
			if(prob(35))
				new /obj/structure/chair(T)
			if(prob(25))
				new /obj/structure/table(T)
		if(7 to 8) // Storage
			if(prob(40))
				new /obj/structure/closet(T)
			if(prob(30))
				new /obj/structure/rack(T)

/datum/ikea_interior/proc/spawn_loot_cache(turf/T)
	// Spawn food and water cache
	var/obj/structure/closet/crate = new /obj/structure/closet(T)
	crate.name = "IKEA Supply Crate"

	// Add random food items
	for(var/i in 1 to rand(2, 4))
		var/food_choice = pick(1, 2, 3, 4, 5)
		switch(food_choice)
			if(1)
				new /obj/item/food/bread(crate)
			if(2)
				new /obj/item/food/cheese(crate)
			if(3)
				new /obj/item/food/meat(crate)
			if(4)
				new /obj/item/food/candy(crate)
			if(5)
				new /obj/item/food/chips(crate)

	// Add water bottles
	for(var/i in 1 to rand(1, 3))
		new /obj/item/reagent_containers/food/drinks/waterbottle(crate)

/datum/ikea_interior/proc/spawn_tool_cache(turf/T)
	// Spawn tool cache
	var/obj/structure/closet/crate = new /obj/structure/closet(T)
	crate.name = "IKEA Tool Crate"

	// Add random tools
	for(var/i in 1 to rand(2, 4))
		var/tool_choice = pick(1, 2, 3, 4, 5)
		switch(tool_choice)
			if(1)
				new /obj/item/crowbar(crate)
			if(2)
				new /obj/item/wrench(crate)
			if(3)
				new /obj/item/screwdriver(crate)
			if(4)
				new /obj/item/wirecutters(crate)
			if(5)
				new /obj/item/multitool(crate)

/datum/ikea_interior/proc/spawn_medical_cache(turf/T)
	// Spawn medical supplies cache
	var/obj/structure/closet/crate = new /obj/structure/closet(T)
	crate.name = "IKEA Medical Crate"

	// Add medical supplies
	for(var/i in 1 to rand(2, 4))
		var/medical_choice = pick(1, 2, 3, 4)
		switch(medical_choice)
			if(1)
				new /obj/item/stack/medical/bruise_pack(crate)
			if(2)
				new /obj/item/stack/medical/ointment(crate)
			if(3)
				new /obj/item/reagent_containers/hypospray/medipen(crate)
			if(4)
				new /obj/item/healthanalyzer(crate)

/datum/ikea_interior/proc/create_ikea_sections(z_level)
	// Create different IKEA sections with open areas
	var/list/sections = list(
		list(10, 10, 30, 30, "Furniture Display"),
		list(40, 10, 60, 30, "Kitchen Section"),
		list(70, 10, 90, 30, "Bedroom Section"),
		list(10, 40, 30, 60, "Living Room Section"),
		list(40, 40, 60, 60, "Dining Area"),
		list(70, 40, 90, 60, "Bathroom Section"),
		list(10, 70, 30, 90, "Storage Section"),
		list(40, 70, 60, 90, "Office Section"),
		list(70, 70, 90, 90, "Children's Section")
	)

	for(var/list/section in sections)
		create_section_area(z_level, section[1], section[2], section[3], section[4], section[5])

/datum/ikea_interior/proc/create_section_area(z_level, start_x, start_y, end_x, end_y, section_name)
	// Create open area for IKEA section
	for(var/x in start_x to end_x)
		for(var/y in start_y to end_y)
			var/turf/T = locate(x, y, z_level)
			if(T)
				// Clear walls in section area
				if(istype(T, /turf/closed/wall))
					T.ChangeTurf(/turf/open/floor/wood)

				// Add section-specific furniture
				if(prob(20))
					add_section_furniture(T, section_name)

				// Add section signs
				if(x == start_x && y == start_y)
					new /obj/structure/sign/ikea(T, section_name)

/datum/ikea_interior/proc/add_section_furniture(turf/T, section_name)
	switch(section_name)
		if("Furniture Display")
			var/choice = pick(1, 2, 3, 4)
			switch(choice)
				if(1) new /obj/structure/chair(T)
				if(2) new /obj/structure/table(T)
				if(3) new /obj/structure/bed/ikea(T)
				if(4) new /obj/structure/closet(T)
		if("Kitchen Section")
			var/choice = pick(1, 2, 3)
			switch(choice)
				if(1) new /obj/structure/table(T)
				if(2) new /obj/structure/sink(T)
				if(3) new /obj/structure/rack(T)
		if("Bedroom Section")
			var/choice = pick(1, 2, 3, 4)
			switch(choice)
				if(1) new /obj/structure/bed/ikea(T)
				if(2) new /obj/structure/closet(T)
				if(3) new /obj/structure/table(T)
				if(4) new /obj/structure/chair(T)
		if("Living Room Section")
			var/choice = pick(1, 2, 3)
			switch(choice)
				if(1) new /obj/structure/chair(T)
				if(2) new /obj/structure/table(T)
				if(3) new /obj/structure/display_case(T)
		if("Dining Area")
			var/choice = pick(1, 2)
			switch(choice)
				if(1) new /obj/structure/table(T)
				if(2) new /obj/structure/chair(T)
		if("Bathroom Section")
			var/choice = pick(1, 2)
			switch(choice)
				if(1) new /obj/structure/sink(T)
				if(2) new /obj/structure/toilet(T)
		if("Storage Section")
			var/choice = pick(1, 2)
			switch(choice)
				if(1) new /obj/structure/closet(T)
				if(2) new /obj/structure/rack(T)
		if("Office Section")
			var/choice = pick(1, 2, 3)
			switch(choice)
				if(1) new /obj/structure/table(T)
				if(2) new /obj/structure/chair(T)
				if(3) new /obj/structure/display_case(T)
		if("Children's Section")
			var/choice = pick(1, 2, 3)
			switch(choice)
				if(1) new /obj/structure/chair(T)
				if(2) new /obj/structure/table(T)
				if(3) new /obj/structure/bed/ikea(T)

/datum/ikea_interior/proc/spawn_ikea_staff(z_level)
	world.log << "IKEA interior: Spawning IKEA staff variations"

	// Spawn different types of IKEA staff
	for(var/i in 1 to 3)
		var/turf/spawn_turf = locate(rand(10, 90), rand(10, 90), z_level)
		if(spawn_turf)
			var/mob/living/simple_animal/hostile/ikea_staff/staff = new /mob/living/simple_animal/hostile/ikea_staff(spawn_turf)
			staff_entities += staff

	// Spawn security staff
	for(var/i in 1 to 2)
		var/turf/spawn_turf = locate(rand(10, 90), rand(10, 90), z_level)
		if(spawn_turf)
			var/mob/living/simple_animal/hostile/ikea_security/security = new /mob/living/simple_animal/hostile/ikea_security(spawn_turf)
			staff_entities += security

	// Spawn manager
	var/turf/manager_turf = locate(rand(10, 90), rand(10, 90), z_level)
	if(manager_turf)
		var/mob/living/simple_animal/hostile/ikea_manager/manager = new /mob/living/simple_animal/hostile/ikea_manager(manager_turf)
		staff_entities += manager

/datum/ikea_interior/proc/spawn_resources(z_level)
	for(var/i in 1 to 10)
		var/turf/spawn_turf = locate(rand(10, 90), rand(10, 90), z_level)
		if(spawn_turf)
			new /obj/item/food/bread(spawn_turf)
			resource_spawns += locate(/obj/item/food/bread) in spawn_turf

/datum/ikea_interior/proc/get_entry_point()
	return entry_point



// IKEA Staff Entity
/mob/living/simple_animal/hostile/ikea_staff
	name = "IKEA Staff"
	desc = "A hostile IKEA staff member. They don't seem friendly."
	icon = 'icons/scp/ikea.dmi'
	icon_state = "staff"
	icon_living = "staff"
	icon_dead = "staff_dead"
	health = 100
	maxHealth = 100
	melee_damage_lower = 15
	melee_damage_upper = 25
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("ikea_staff")

/mob/living/simple_animal/hostile/ikea_staff/Initialize()
	. = ..()
	// Randomize appearance with custom sprites
	icon_state = pick("staff", "staff_heavy")

/mob/living/simple_animal/hostile/ikea_staff/Found(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.faction == faction)
			return FALSE
		return TRUE
	return FALSE

// IKEA Security Staff
/mob/living/simple_animal/hostile/ikea_security
	name = "IKEA Security"
	desc = "A hostile IKEA security guard. They're armed and dangerous."
	icon = 'icons/scp/ikea.dmi'
	icon_state = "security"
	icon_living = "security"
	icon_dead = "security_dead"
	health = 150
	maxHealth = 150
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("ikea_staff")

/mob/living/simple_animal/hostile/ikea_security/Initialize()
	. = ..()
	// Randomize security appearance
	icon_state = pick("security", "security2", "security_armed")

// IKEA Manager
/mob/living/simple_animal/hostile/ikea_manager
	name = "IKEA Manager"
	desc = "A hostile IKEA manager. They seem to be in charge and very aggressive."
	icon = 'icons/scp/ikea.dmi'
	icon_state = "manager"
	icon_living = "manager"
	icon_dead = "manager_dead"
	health = 200
	maxHealth = 200
	melee_damage_lower = 25
	melee_damage_upper = 35
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("ikea_staff")

/mob/living/simple_animal/hostile/ikea_manager/Initialize()
	. = ..()
	// Manager has unique appearance
	icon_state = "manager"

// IKEA Entrance Landmark
/obj/effect/landmark/ikea_entrance
	name = "IKEA Entrance"
	desc = "A landmark marking the entrance to SCP-3008."
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"

// IKEA-specific furniture
/obj/structure/bed/ikea
	name = "IKEA Bed"
	desc = "A comfortable IKEA bed. It looks well-made."
	icon = 'icons/obj/structures.dmi'
	icon_state = "bed"

/obj/structure/closet/wardrobe/ikea
	name = "IKEA Wardrobe"
	desc = "A stylish IKEA wardrobe."
	icon = 'icons/obj/closet.dmi'
	icon_state = "wardrobe"

/obj/structure/table/wood
	name = "Wooden Table"
	desc = "A sturdy wooden table."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"

// IKEA Sign
/obj/structure/sign/ikea
	name = "IKEA Section Sign"
	desc = "A sign indicating the IKEA section."
	icon = 'icons/obj/decals.dmi'
	icon_state = "sign"
	var/section_name = "IKEA Section"

/obj/structure/sign/ikea/New(loc, new_section_name)
	. = ..()
	if(new_section_name)
		section_name = new_section_name
		name = "[section_name] Sign"
		desc = "A sign indicating the [section_name]."

// Display Case
/obj/structure/display_case
	name = "Display Case"
	desc = "A glass display case for showcasing products."
	icon = 'icons/obj/structures.dmi'
	icon_state = "display_case"

// Plant Pot
/obj/structure/plant_pot
	name = "Plant Pot"
	desc = "A decorative plant pot with artificial plants."
	icon = 'icons/obj/structures.dmi'
	icon_state = "plant_pot"

// Verbs for players inside IKEA
/mob/living/carbon/human/proc/escape_ikea()
	set name = "Try to Escape IKEA"
	set category = "IKEA"
	set desc = "Attempt to escape from the infinite IKEA."

	var/datum/ikea_interior/current_interior = get_ikea_interior()
	if(!current_interior)
		to_chat(src, "<span class='warning'>You are not in an IKEA interior.</span>")
		return

	// Check if player is near an exit point
	var/turf/current_turf = get_turf(src)
	if(current_turf && current_interior.entry_point && get_dist(current_turf, current_interior.entry_point) <= 5)
		// Successfully escape
		if(current_interior.parent_entrance && current_interior.parent_entrance.loc)
			forceMove(get_turf(current_interior.parent_entrance))
			to_chat(src, "<span class='notice'>You successfully escape from the infinite IKEA!</span>")
			current_interior.remove_occupant(src)

			// Award research points for escaping
			if(SSscp_research && SSscp_research.manager)
				award_research_points("SCP-3008", "escape", 10, ckey)
		else
			// Emergency escape
			var/turf/safe_turf = pick(GLOB.station_turfs)
			if(safe_turf)
				forceMove(safe_turf)
				to_chat(src, "<span class='notice'>You are teleported to safety.</span>")
				current_interior.remove_occupant(src)
	else
		to_chat(src, "<span class='warning'>You need to be closer to the entrance to escape. The IKEA seems to be shifting around you...</span>")

/mob/living/carbon/human/proc/get_ikea_interior()
	// Find which IKEA interior this player is in
	for(var/obj/structure/scp3008/entrance in world)
		if(entrance.ikea_interiors)
			for(var/datum/ikea_interior/interior in entrance.ikea_interiors)
				if(src in interior.occupants)
					return interior
	return null

/mob/living/carbon/human/proc/ikea_survival_tips()
	set name = "IKEA Survival Tips"
	set category = "IKEA"
	set desc = "Get tips for surviving in the infinite IKEA."

	to_chat(src, "<span class='notice'><b>IKEA Survival Tips:</b></span>")
	to_chat(src, "<span class='notice'>• Avoid IKEA staff - they are hostile and will attack you</span>")
	to_chat(src, "<span class='notice'>• Look for resources like food, water, and tools</span>")
	to_chat(src, "<span class='notice'>• The labyrinth layout constantly shifts - don't rely on landmarks</span>")
	to_chat(src, "<span class='notice'>• Find the entrance area to escape (near coordinates 50,50)</span>")
	to_chat(src, "<span class='notice'>• Work with other survivors to increase your chances</span>")
	to_chat(src, "<span class='notice'>• Look for section signs to navigate the maze</span>")
	to_chat(src, "<span class='notice'>• The maze has open areas for different IKEA sections</span>")
	to_chat(src, "<span class='notice'>• Use furniture and objects as cover from staff</span>")

// Add verbs when entering IKEA
/datum/ikea_interior/proc/add_occupant(mob/living/carbon/human/occupant)
	if(occupant && !(occupant in occupants))
		occupants += occupant
		// Add IKEA-specific verbs
		occupant.verbs += /mob/living/carbon/human/proc/escape_ikea
		occupant.verbs += /mob/living/carbon/human/proc/ikea_survival_tips
		occupant.verbs += /mob/living/carbon/human/proc/debug_ikea_interior
		hook_scp_interaction(occupant, "SCP-3008", INTERACTION_TYPE_EXPLORATION)

/obj/structure/scp3008/proc/on_ikea_entry(mob/living/carbon/human/entrant)
	if(!entrant)
		return
	hook_scp_breach("SCP-3008", src)

/obj/structure/scp3008/proc/on_staff_attack(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-3008", 20, 0)

/datum/ikea_interior/proc/remove_occupant(mob/living/carbon/human/occupant)
	if(occupant in occupants)
		occupants -= occupant
		// Remove IKEA-specific verbs
		occupant.verbs -= /mob/living/carbon/human/proc/escape_ikea
		occupant.verbs -= /mob/living/carbon/human/proc/ikea_survival_tips
		occupant.verbs -= /mob/living/carbon/human/proc/debug_ikea_interior

// Debug verb for IKEA interior
/mob/living/carbon/human/proc/debug_ikea_interior()
	set name = "Debug IKEA Interior"
	set category = "IKEA"
	set desc = "Debug information about current IKEA interior."

	var/datum/ikea_interior/current_interior = get_ikea_interior()
	if(!current_interior)
		to_chat(src, "<span class='warning'>You are not in an IKEA interior.</span>")
		return

	var/turf/current_turf = get_turf(src)
	to_chat(src, "<span class='notice'><b>IKEA Interior Debug Info:</b></span>")
	to_chat(src, "<span class='notice'>Interior ID: [current_interior.id]</span>")
	to_chat(src, "<span class='notice'>Current Position: [current_turf.x], [current_turf.y], [current_turf.z]</span>")
	to_chat(src, "<span class='notice'>Entry Point: [current_interior.entry_point ? "[current_interior.entry_point.x], [current_interior.entry_point.y], [current_interior.entry_point.z]" : "NULL"]</span>")
	to_chat(src, "<span class='notice'>Occupants: [length(current_interior.occupants)]</span>")
	to_chat(src, "<span class='notice'>IKEA Turfs: [length(current_interior.ikea_turfs)]</span>")

