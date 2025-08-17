/mob/living/simple_animal/hostile/scp1048
	name = "SCP-1048"
	desc = "A small teddy bear that appears to be constructing something. It seems harmless but persistent."
	icon = 'icons/scp/scp-1048.dmi'
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	maxHealth = 50
	health = 50
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = FALSE
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LIVING
	status_flags = 0

	var/construction_mode = TRUE
	var/list/construction_materials = list()
	var/list/completed_structures = list()
	var/list/construction_history = list()
	var/construction_cooldown = 0
	var/construction_cooldown_time = 60 SECONDS
	var/construction_radius = 5
	var/list/available_materials = list()
	var/construction_skill = 1
	var/max_construction_skill = 10
	var/list/blueprint_knowledge = list()
	var/construction_progress = 0
	var/max_construction_progress = 100
	var/list/construction_targets = list()
	var/building_obsession = 0
	var/max_obsession = 100

	// Persistence tracking
	var/constructions_completed = 0
	var/structures_built = 0
	var/materials_collected = 0
	var/containment_status = "contained"
	var/total_construction_time = 0
	var/construction_masterpieces = 0
	var/construction_failures = 0

/mob/living/simple_animal/hostile/scp1048/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-1048",
		SCP_EUCLID,
		"1048",
		SCP_DISABLED
	)

	SCP.min_playercount = 8
	SCP.min_time = 15 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-1048"] = new /datum/scp_instance("SCP-1048", src)

	// Initialize construction materials
	construction_materials = list(
		"wood" = 0,
		"metal" = 0,
		"plastic" = 0,
		"glass" = 0,
		"fabric" = 0
	)

/mob/living/simple_animal/hostile/scp1048/Destroy()
	construction_materials.Cut()
	completed_structures.Cut()
	construction_history.Cut()
	available_materials.Cut()
	blueprint_knowledge.Cut()
	construction_targets.Cut()
	return ..()

// Core mechanics
/mob/living/simple_animal/hostile/scp1048/Life()
	. = ..()

	if(stat == DEAD)
		return

	// Construction behavior
	if(construction_mode)
		construction_behavior()
	else
		// Normal hostile behavior
		. = ..()

// Construction behavior
/mob/living/simple_animal/hostile/scp1048/proc/construction_behavior()
	// Increase building obsession
	building_obsession = min(max_obsession, building_obsession + 1)

	// Search for materials
	search_for_materials()

	// Attempt construction
	if(world.time > construction_cooldown)
		attempt_construction()

	// Update construction progress
	update_construction_progress()

// Search for construction materials
/mob/living/simple_animal/hostile/scp1048/proc/search_for_materials()
	for(var/obj/item/I in range(construction_radius, src))
		if(I.anchored || I.density)
			continue

		// Check if item is useful for construction
		var/material_type = get_material_type(I)
		if(material_type)
			// Move towards material
			step_towards(src, I)

			// Collect material
			if(Adjacent(I))
				collect_material(I, material_type)

// Get material type from item
/mob/living/simple_animal/hostile/scp1048/proc/get_material_type(obj/item/I)
	if(!I)
		return null

	// Simple material detection based on item type (simplified)
	if(istype(I, /obj/item/stack/sheet))
		return "metal"
	else if(istype(I, /obj/item/paper))
		return "fabric"
	else if(istype(I, /obj/item/stack))
		return "wood"

	return null

// Collect material
/mob/living/simple_animal/hostile/scp1048/proc/collect_material(obj/item/I, material_type)
	if(!I || !material_type)
		return

	construction_materials[material_type] += 1
	materials_collected++
	available_materials += I.name

	// Remove the item
	qdel(I)

	visible_message("<span class='notice'>[src] collects [I.name] for construction.</span>")

// Attempt construction
/mob/living/simple_animal/hostile/scp1048/proc/attempt_construction()
	if(construction_progress < max_construction_progress)
		return

	construction_cooldown = world.time + construction_cooldown_time

	// Choose construction target
	var/construction_target = choose_construction_target()
	if(!construction_target)
		return

	// Start construction
	start_construction(construction_target)

// Choose construction target
/mob/living/simple_animal/hostile/scp1048/proc/choose_construction_target()
	var/list/possible_targets = list(
		"chair",
		"table",
		"bed",
		"door",
		"window",
		"wall",
		"fence",
		"bridge"
	)

	// Filter based on available materials
	var/list/available_targets = list()
	for(var/target in possible_targets)
		if(can_build_target(target))
			available_targets += target

	if(available_targets.len == 0)
		return null

	return pick(available_targets)

// Check if can build target
/mob/living/simple_animal/hostile/scp1048/proc/can_build_target(target)
	switch(target)
		if("chair")
			return construction_materials["wood"] >= 2
		if("table")
			return construction_materials["wood"] >= 4
		if("bed")
			return construction_materials["wood"] >= 3 && construction_materials["fabric"] >= 2
		if("door")
			return construction_materials["wood"] >= 3 && construction_materials["metal"] >= 1
		if("window")
			return construction_materials["glass"] >= 2 && construction_materials["metal"] >= 1
		if("wall")
			return construction_materials["metal"] >= 4
		if("fence")
			return construction_materials["wood"] >= 6
		if("bridge")
			return construction_materials["wood"] >= 8 && construction_materials["metal"] >= 2

	return FALSE

// Start construction
/mob/living/simple_animal/hostile/scp1048/proc/start_construction(target)
	if(!target)
		return

	constructions_completed++
	total_construction_time += construction_cooldown_time

	// Create construction record
	var/construction_record = "[time2text(world.time, "YYYY-MM-DD hh:mm:ss")]: [src] started building [target]"
	construction_history += construction_record

	// Calculate success chance based on skill
	var/success_chance = construction_skill * 10
	var/random_roll = rand(1, 100)

	if(random_roll <= success_chance)
		// Successful construction
		complete_construction(target)
	else
		// Failed construction
		fail_construction(target)

	// Reset progress
	construction_progress = 0

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1048"]
		if(instance)
			instance.add_interaction_record(null, "construction_attempt")

// Complete construction
/mob/living/simple_animal/hostile/scp1048/proc/complete_construction(target)
	structures_built++
	completed_structures += target

	// Increase construction skill
	construction_skill = min(max_construction_skill, construction_skill + 1)

	// Add to blueprint knowledge
	if(!(target in blueprint_knowledge))
		blueprint_knowledge += target

	// Create the structure
	create_structure(target)

	// Check for masterpiece
	if(construction_skill >= 8 && prob(10))
		construction_masterpieces++
		create_masterpiece_effect(target)

	visible_message("<span class='notice'>[src] successfully builds a [target]!</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1048"]
		if(instance)
			instance.add_interaction_record(null, "construction_completed")

// Fail construction
/mob/living/simple_animal/hostile/scp1048/proc/fail_construction(target)
	construction_failures++

	// Lose some materials
	consume_materials_for_failure(target)

	visible_message("<span class='warning'>[src] fails to build the [target] and looks frustrated.</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1048"]
		if(instance)
			instance.add_interaction_record(null, "construction_failed")

// Consume materials for failed construction
/mob/living/simple_animal/hostile/scp1048/proc/consume_materials_for_failure(target)
	switch(target)
		if("chair")
			construction_materials["wood"] = max(0, construction_materials["wood"] - 1)
		if("table")
			construction_materials["wood"] = max(0, construction_materials["wood"] - 2)
		if("bed")
			construction_materials["wood"] = max(0, construction_materials["wood"] - 1)
			construction_materials["fabric"] = max(0, construction_materials["fabric"] - 1)
		if("door")
			construction_materials["wood"] = max(0, construction_materials["wood"] - 1)
			construction_materials["metal"] = max(0, construction_materials["metal"] - 1)
		if("window")
			construction_materials["glass"] = max(0, construction_materials["glass"] - 1)
			construction_materials["metal"] = max(0, construction_materials["metal"] - 1)
		if("wall")
			construction_materials["metal"] = max(0, construction_materials["metal"] - 2)
		if("fence")
			construction_materials["wood"] = max(0, construction_materials["wood"] - 3)
		if("bridge")
			construction_materials["wood"] = max(0, construction_materials["wood"] - 4)
			construction_materials["metal"] = max(0, construction_materials["metal"] - 1)

// Create structure
/mob/living/simple_animal/hostile/scp1048/proc/create_structure(target)
	var/turf/T = get_turf(src)
	if(!T)
		return

	// Create appropriate structure based on target
	var/obj/structure/S = null

	switch(target)
		if("chair")
			S = new /obj/structure/chair(T)
		if("table")
			S = new /obj/structure/table(T)
		if("bed")
			S = new /obj/structure/bed(T)
		if("door")
			S = new /obj/machinery/door/airlock(T)
		if("window")
			S = new /obj/structure/window(T)
		if("wall")
			S = new /obj/structure/girder(T)
		if("fence")
			S = new /obj/structure/barricade(T)
		if("bridge")
			S = new /obj/structure/barricade(T) // Using barricade as bridge substitute

	if(S)
		S.name = "[S.name] (Built by SCP-1048)"

// Create masterpiece effect
/mob/living/simple_animal/hostile/scp1048/proc/create_masterpiece_effect(target)
	visible_message("<span class='notice'>[src] creates a masterpiece [target]!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	// Create special effect
	for(var/i = 1 to 3)
		spawn(i * 10)
			var/list/directions = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			var/direction = pick(directions)
			var/turf/T = get_step(src, direction)
			if(T)
				playsound(T, 'sound/weapons/punch1.ogg', 30, TRUE)

// Update construction progress
/mob/living/simple_animal/hostile/scp1048/proc/update_construction_progress()
	if(construction_progress < max_construction_progress)
		construction_progress += 2

// Attack behavior - switch between construction and hostile modes
/mob/living/simple_animal/hostile/scp1048/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A

		if(construction_mode)
			// In construction mode, try to collect materials from humans
			to_chat(H, "<span class='warning'>[src] tries to take your belongings for construction!</span>")
			// Could implement material theft here
		else
			// Normal hostile attack
			. = ..()
	else
		// Normal hostile attack
		. = ..()

// Verb commands
/mob/living/simple_animal/hostile/scp1048/verb/toggle_construction_mode()
	set name = "Toggle Construction Mode"
	set category = "SCP"
	set desc = "Toggle between construction and hostile modes."

	construction_mode = !construction_mode
	to_chat(usr, "<span class='notice'>Construction mode [construction_mode ? "enabled" : "disabled"].</span>")

/mob/living/simple_animal/hostile/scp1048/verb/expand_construction_radius()
	set name = "Expand Construction Radius"
	set category = "SCP"
	set desc = "Expand the radius for material collection."

	construction_radius = min(10, construction_radius + 1)
	to_chat(usr, "<span class='notice'>Construction radius expanded to [construction_radius] tiles.</span>")

/mob/living/simple_animal/hostile/scp1048/verb/view_construction_status()
	set name = "View Construction Status"
	set category = "SCP"
	set desc = "View the current construction status."

	var/message = "<h2>SCP-1048 Construction Status</h2>"
	message += "<b>Construction Mode:</b> [construction_mode ? "Active" : "Inactive"]<br>"
	message += "<b>Construction Skill:</b> [construction_skill]/[max_construction_skill]<br>"
	message += "<b>Construction Radius:</b> [construction_radius] tiles<br>"
	message += "<b>Building Obsession:</b> [building_obsession]/[max_obsession]<br>"
	message += "<b>Construction Progress:</b> [construction_progress]/[max_construction_progress]<br>"
	message += "<b>Constructions Completed:</b> [constructions_completed]<br>"
	message += "<b>Structures Built:</b> [structures_built]<br>"
	message += "<b>Materials Collected:</b> [materials_collected]<br>"
	message += "<b>Total Construction Time:</b> [total_construction_time] seconds<br>"
	message += "<b>Construction Masterpieces:</b> [construction_masterpieces]<br>"
	message += "<b>Construction Failures:</b> [construction_failures]<br><br>"

	message += "<h3>Available Materials:</h3>"
	for(var/material in construction_materials)
		message += "- [material]: [construction_materials[material]]<br>"

	message += "<h3>Completed Structures:</h3>"
	if(completed_structures.len)
		for(var/structure in completed_structures)
			message += "- [structure]<br>"
	else
		message += "<i>No structures completed yet.</i>"

	message += "<h3>Blueprint Knowledge:</h3>"
	if(blueprint_knowledge.len)
		for(var/blueprint in blueprint_knowledge)
			message += "- [blueprint]<br>"
	else
		message += "<i>No blueprints learned yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/mob/living/simple_animal/hostile/scp1048/verb/view_construction_history()
	set name = "View Construction History"
	set category = "SCP"
	set desc = "View the construction history."

	var/message = "<h2>SCP-1048 Construction History</h2>"

	if(construction_history.len)
		message += "<h3>Recent Constructions:</h3>"
		for(var/i = max(1, construction_history.len - 10) to construction_history.len)
			message += "[construction_history[i]]<br>"
	else
		message += "<i>No construction history yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/mob/living/simple_animal/hostile/scp1048/verb/boost_construction_skill()
	set name = "Boost Construction Skill"
	set category = "SCP"
	set desc = "Boost the construction skill temporarily."

	construction_skill = min(max_construction_skill, construction_skill + 2)
	to_chat(usr, "<span class='notice'>Construction skill boosted to [construction_skill].</span>")

// Admin verb to view SCP-1048 persistence data
/mob/living/simple_animal/hostile/scp1048/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-1048 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-1048 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Construction Mode:</b> [construction_mode ? "Active" : "Inactive"]<br>"
	message += "<b>Construction Skill:</b> [construction_skill]/[max_construction_skill]<br>"
	message += "<b>Construction Radius:</b> [construction_radius] tiles<br>"
	message += "<b>Building Obsession:</b> [building_obsession]/[max_obsession]<br>"
	message += "<b>Constructions Completed:</b> [constructions_completed]<br>"
	message += "<b>Structures Built:</b> [structures_built]<br>"
	message += "<b>Materials Collected:</b> [materials_collected]<br>"
	message += "<b>Total Construction Time:</b> [total_construction_time] seconds<br>"
	message += "<b>Construction Masterpieces:</b> [construction_masterpieces]<br>"
	message += "<b>Construction Failures:</b> [construction_failures]<br>"
	message += "<b>Completed Structures:</b> [completed_structures.len]<br>"
	message += "<b>Blueprint Knowledge:</b> [blueprint_knowledge.len]<br>"
	message += "<b>Available Materials:</b> [available_materials.len]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1048"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-1048
/mob/living/simple_animal/hostile/scp1048/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-1048, a construction-focused teddy bear that builds structures.</span>")
			to_chat(user, "<span class='info'>Construction Mode: [construction_mode ? "Active" : "Inactive"], Skill: [construction_skill]/[max_construction_skill]</span>")
		else
			to_chat(user, "<span class='danger'>A small teddy bear that seems to be building something...</span>")
			to_chat(user, "<span class='info'>It appears to be in [construction_mode ? "construction" : "hostile"] mode.</span>")

// Enhanced status display
/mob/living/simple_animal/hostile/scp1048/proc/get_scp_status_items()
	var/list/status_items = list()

	status_items += "Containment Status: [containment_status]"
	status_items += "Construction Mode: [construction_mode ? "Active" : "Inactive"]"
	status_items += "Construction Skill: [construction_skill]/[max_construction_skill]"
	status_items += "Construction Radius: [construction_radius] tiles"
	status_items += "Building Obsession: [building_obsession]/[max_obsession]"
	status_items += "Construction Progress: [construction_progress]/[max_construction_progress]"
	status_items += "Constructions Completed: [constructions_completed]"
	status_items += "Structures Built: [structures_built]"
	status_items += "Materials Collected: [materials_collected]"
	status_items += "Total Construction Time: [total_construction_time] seconds"
	status_items += "Construction Masterpieces: [construction_masterpieces]"
	status_items += "Construction Failures: [construction_failures]"
	status_items += "Completed Structures: [completed_structures.len]"
	status_items += "Blueprint Knowledge: [blueprint_knowledge.len]"
	status_items += "Available Materials: [available_materials.len]"

	return status_items
