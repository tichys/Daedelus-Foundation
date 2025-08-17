/obj/machinery/scp914
	name = "SCP-914"
	desc = "A massive clockwork device with various settings for refining objects. It seems to be constantly ticking and whirring."
	icon = 'icons/scp/SCP-914-64x64.dmi'
	icon_state = "scp914"
	density = TRUE
	anchored = TRUE

	// Maximum Enhanced SCP-914 variables
	var/refinement_setting = "ROUGH" // ROUGH, COARSE, 1:1, FINE, VERY_FINE
	var/list/refinement_settings = list("ROUGH", "COARSE", "1:1", "FINE", "VERY_FINE")
	var/refinement_cooldown = 0
	var/refinement_cooldown_time = 60 SECONDS
	var/list/input_objects = list()
	var/list/output_objects = list()
	var/list/refinement_history = list()
	var/refinement_radius = 2
	var/active = FALSE
	var/refinement_progress = 0
	var/max_refinement_progress = 100
	var/list/refined_materials = list()
	var/list/failed_refinements = list()
	var/refinement_quality = 1.0
	var/max_quality = 5.0
	var/refinement_mastery = 0
	var/max_refinement_mastery = 100
	var/material_synthesis = 0
	var/max_material_synthesis = 100
	var/reality_manipulation = 0
	var/max_reality_manipulation = 100
	var/temporal_effects = 0
	var/max_temporal_effects = 100
	var/refinement_evolution = 1
	var/max_refinement_evolution = 5
	var/breakthrough_chance = 5
	var/max_breakthrough_chance = 25
	var/catastrophe_chance = 2
	var/max_catastrophe_chance = 10
	var/refinement_efficiency = 1.0
	var/max_refinement_efficiency = 3.0
	var/refinement_cooldown_reduction = 0
	var/max_cooldown_reduction = 50
	var/refinement_radius_expansion = 0
	var/max_radius_expansion = 5
	var/refinement_cooldown_enhancement = 0
	var/refinement_cooldown_enhancement_time = 20 SECONDS
	var/material_synthesis_cooldown = 0
	var/material_synthesis_cooldown_time = 30 SECONDS
	var/reality_manipulation_cooldown = 0
	var/reality_manipulation_cooldown_time = 45 SECONDS

	// Persistence tracking
	var/refinements_performed = 0
	var/objects_destroyed = 0
	var/objects_enhanced = 0
	var/containment_status = "contained"
	var/total_materials_processed = 0
	var/refinement_breakthroughs = 0
	var/refinement_catastrophes = 0
	var/refinement_masteries = 0
	var/material_syntheses = 0
	var/reality_manipulations = 0
	var/temporal_events = 0
	var/evolution_events = 0
	var/efficiency_improvements = 0

/obj/machinery/scp914/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-914",
		SCP_EUCLID,
		"914",

	)

	SCP.min_playercount = 10
	SCP.min_time = 15 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-914"] = new /datum/scp_instance("SCP-914", src)

/obj/machinery/scp914/Destroy()
	input_objects = list()
	output_objects = list()
	refinement_history = list()
	refined_materials = list()
	failed_refinements = list()
	return ..()

// Core mechanics
/obj/machinery/scp914/process()
	. = ..()

	// Process refinement if active
	if(active)
		process_refinement()

	// Process refinement mastery
	process_refinement_mastery()

	// Process material synthesis
	process_material_synthesis()

	// Process reality manipulation
	process_reality_manipulation()

	// Process temporal effects
	process_temporal_effects()

	// Process refinement evolution
	process_refinement_evolution()

	// Award research points to nearby researchers
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP) // Skip SCPs
			continue

		// Award research points for observing SCP-914
		award_research_points("914", "behavior", 1, H.ckey)

// Enhanced refinement processing
/obj/machinery/scp914/proc/process_refinement()
	if(refinement_progress < max_refinement_progress)
		var/progress_increase = 5 * refinement_efficiency
		refinement_progress += progress_increase

		// Visual and audio effects
		playsound(src, 'sound/weapons/punch1.ogg', 30, TRUE)

		// Update quality based on setting and mastery
		update_refinement_quality()

		// Chance for breakthrough or catastrophe
		if(prob(breakthrough_chance))
			create_breakthrough()
		else if(prob(catastrophe_chance))
			create_catastrophe()

		if(refinement_progress >= max_refinement_progress)
			complete_refinement()

// Process refinement mastery
/obj/machinery/scp914/proc/process_refinement_mastery()
	if(refinements_performed > 0 && refinement_mastery < max_refinement_mastery)
		if(prob(2))
			refinement_mastery = min(max_refinement_mastery, refinement_mastery + 1)

// Process material synthesis
/obj/machinery/scp914/proc/process_material_synthesis()
	if(material_synthesis > 0 && prob(1)):
		// Synthesize new materials
		var/list/new_materials = list("reality_fabric", "temporal_essence", "dimensional_crystal", "existence_particle")
		var/new_material = pick(new_materials)

		if(!(new_material in refined_materials))
			refined_materials += new_material
			material_syntheses++

// Process reality manipulation
/obj/machinery/scp914/proc/process_reality_manipulation()
	if(reality_manipulation > 0 && prob(1)):
		// Create reality distortions
		for(var/mob/living/carbon/human/H in range(refinement_radius + refinement_radius_expansion, src))
			if(H != src)
				to_chat(H, "<span class='notice'>You feel reality shifting around SCP-914...</span>")

// Process temporal effects
/obj/machinery/scp914/proc/process_temporal_effects()
	if(temporal_effects > 0 && prob(1)):
		// Create temporal distortions
		for(var/mob/living/carbon/human/H in range(refinement_radius + refinement_radius_expansion, src))
			if(H != src)
				to_chat(H, "<span class='notice'>You feel time warping around SCP-914...</span>")
				temporal_events++

// Process refinement evolution
/obj/machinery/scp914/proc/process_refinement_evolution()
	if(refinement_mastery >= max_refinement_mastery && refinement_evolution < max_refinement_evolution)
		if(prob(1))
			evolve_refinement_stage()

// Evolve refinement stage
/obj/machinery/scp914/proc/evolve_refinement_stage()
	refinement_evolution = min(max_refinement_evolution, refinement_evolution + 1)
	evolution_events++

	var/evolution_message = ""
	switch(refinement_evolution)
		if(2)
			evolution_message = "SCP-914 evolves enhanced refinement capabilities!"
		if(3)
			evolution_message = "SCP-914 evolves material synthesis abilities!"
		if(4)
			evolution_message = "SCP-914 evolves reality manipulation powers!"
		if(5)
			evolution_message = "SCP-914 achieves ultimate refinement evolution!"

	visible_message("<span class='notice'>[evolution_message]</span>")

// Enhanced refinement quality update
/obj/machinery/scp914/proc/update_refinement_quality()
	var/base_quality = 1.0
	switch(refinement_setting)
		if("ROUGH")
			base_quality = 0.5
		if("COARSE")
			base_quality = 1.0
		if("1:1")
			base_quality = 2.0
		if("FINE")
			base_quality = 3.5
		if("VERY_FINE")
			base_quality = 5.0

	refinement_quality = base_quality * (1 + (refinement_mastery / 100))

// Create breakthrough refinement
/obj/machinery/scp914/proc/create_breakthrough()
	refinement_breakthroughs++
	breakthrough_chance = min(max_breakthrough_chance, breakthrough_chance + 1)

	visible_message("<span class='notice'>SCP-914 creates a breakthrough refinement!</span>")

	// Enhance nearby objects
	for(var/obj/O in range(refinement_radius + refinement_radius_expansion, src))
		if(O != src)
			// Repair objects by creating a visual effect
			visible_message("<span class='notice'>[O] is enhanced by SCP-914's breakthrough!</span>")

// Create refinement catastrophe
/obj/machinery/scp914/proc/create_catastrophe()
	refinement_catastrophes++
	catastrophe_chance = min(max_catastrophe_chance, catastrophe_chance + 1)

	visible_message("<span class='danger'>SCP-914 experiences a refinement catastrophe!</span>")

	// Damage nearby objects
	for(var/obj/O in range(refinement_radius + refinement_radius_expansion, src))
		if(O != src)
			// Damage objects by creating a visual effect
			visible_message("<span class='danger'>[O] is damaged by SCP-914's catastrophe!</span>")

// Enhanced refinement completion
/obj/machinery/scp914/proc/complete_refinement()
	active = FALSE

	// Award research points to nearby researchers for observing refinement
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H.SCP) // Skip SCPs
			continue

		// Award research points for observing SCP-914 refinement
		award_research_points("914", "refinement", 20, H.ckey)
	refinements_performed++

	// Process input objects
	for(var/obj/item/item in input_objects)
		if(item)
			process_refinement_item(item)

	input_objects.Cut()

	// Update persistence
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-914"]
		if(instance)
			instance.add_interaction_record(null, "refinement_completed")

// Process individual refinement item
/obj/machinery/scp914/proc/process_refinement_item(obj/item/item)
	if(!item)
		return

	var/refinement_result = calculate_refinement_result(item)

	if(refinement_result == "destroyed")
		objects_destroyed++
		qdel(item)
		visible_message("<span class='danger'>[item] is destroyed by SCP-914!</span>")
	else if(refinement_result == "enhanced")
		objects_enhanced++
		enhance_item(item)
		output_objects += item
		visible_message("<span class='notice'>[item] is enhanced by SCP-914!</span>")
	else
		output_objects += item
		visible_message("<span class='notice'>[item] is refined by SCP-914.</span>")

	total_materials_processed++

// Calculate refinement result
/obj/machinery/scp914/proc/calculate_refinement_result(obj/item/item)
	var/destruction_chance = 0
	var/enhancement_chance = 0

	switch(refinement_setting)
		if("ROUGH")
			destruction_chance = 30
			enhancement_chance = 10
		if("COARSE")
			destruction_chance = 20
			enhancement_chance = 20
		if("1:1")
			destruction_chance = 10
			enhancement_chance = 30
		if("FINE")
			destruction_chance = 5
			enhancement_chance = 50
		if("VERY_FINE")
			destruction_chance = 2
			enhancement_chance = 80

	// Apply mastery bonuses
	enhancement_chance += refinement_mastery / 10
	destruction_chance -= refinement_mastery / 20

	if(prob(destruction_chance))
		return "destroyed"
	else if(prob(enhancement_chance))
		return "enhanced"
	else
		return "normal"

// Enhance item
/obj/machinery/scp914/proc/enhance_item(obj/item/item)
	if(!item)
		return

	// Apply various enhancements based on refinement quality
	if(refinement_quality >= 3.0)
		item.name = "Enhanced [item.name]"
		item.desc = "[item.desc] This item has been enhanced by SCP-914."

// Maximum enhanced abilities
/obj/machinery/scp914/proc/refinement_mastery_ability()
	if(refinement_mastery >= max_refinement_mastery)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum refinement mastery.</span>")
		return

	refinement_mastery = min(max_refinement_mastery, refinement_mastery + 10)
	refinement_masteries++

	to_chat(usr, "<span class='notice'>SCP-914's refinement mastery is enhanced. Mastery: [refinement_mastery]/[max_refinement_mastery]</span>")

/obj/machinery/scp914/proc/material_synthesis_ability()
	if(world.time < material_synthesis_cooldown)
		to_chat(usr, "<span class='warning'>SCP-914 needs time to synthesize materials.</span>")
		return

	material_synthesis_cooldown = world.time + material_synthesis_cooldown_time
	material_synthesis = min(max_material_synthesis, material_synthesis + 20)
	material_syntheses++

	to_chat(usr, "<span class='notice'>SCP-914 begins material synthesis. Synthesis: [material_synthesis]/[max_material_synthesis]</span>")

/obj/machinery/scp914/proc/reality_manipulation_ability()
	if(world.time < reality_manipulation_cooldown)
		to_chat(usr, "<span class='warning'>SCP-914 needs time to manipulate reality.</span>")
		return

	reality_manipulation_cooldown = world.time + reality_manipulation_cooldown_time
	reality_manipulation = min(max_reality_manipulation, reality_manipulation + 20)
	reality_manipulations++

	to_chat(usr, "<span class='notice'>SCP-914 begins reality manipulation. Manipulation: [reality_manipulation]/[max_reality_manipulation]</span>")

/obj/machinery/scp914/proc/temporal_effects_ability()
	temporal_effects = min(max_temporal_effects, temporal_effects + 20)
	temporal_events++

	to_chat(usr, "<span class='notice'>SCP-914 creates temporal effects. Effects: [temporal_effects]/[max_temporal_effects]</span>")

/obj/machinery/scp914/proc/evolve_refinement_ability()
	if(refinement_evolution >= max_refinement_evolution)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum evolution.</span>")
		return

	if(refinement_mastery < max_refinement_mastery)
		to_chat(usr, "<span class='warning'>SCP-914 needs more refinement mastery to evolve.</span>")
		return

	evolve_refinement_stage()

/obj/machinery/scp914/proc/efficiency_improvement_ability()
	if(refinement_efficiency >= max_refinement_efficiency)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum efficiency.</span>")
		return

	refinement_efficiency = min(max_refinement_efficiency, refinement_efficiency + 0.2)
	efficiency_improvements++

	to_chat(usr, "<span class='notice'>SCP-914's efficiency is improved. Efficiency: [refinement_efficiency]/[max_refinement_efficiency]</span>")

/obj/machinery/scp914/proc/cooldown_reduction_ability()
	if(refinement_cooldown_reduction >= max_cooldown_reduction)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum cooldown reduction.</span>")
		return

	refinement_cooldown_reduction = min(max_cooldown_reduction, refinement_cooldown_reduction + 10)

	to_chat(usr, "<span class='notice'>SCP-914's cooldown is reduced. Reduction: [refinement_cooldown_reduction]/[max_cooldown_reduction]</span>")

/obj/machinery/scp914/proc/radius_expansion_ability()
	if(refinement_radius_expansion >= max_radius_expansion)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum radius expansion.</span>")
		return

	refinement_radius_expansion = min(max_radius_expansion, refinement_radius_expansion + 1)

	to_chat(usr, "<span class='notice'>SCP-914's refinement radius is expanded. Radius: [refinement_radius + refinement_radius_expansion]</span>")

/obj/machinery/scp914/proc/breakthrough_enhancement_ability()
	if(breakthrough_chance >= max_breakthrough_chance)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum breakthrough chance.</span>")
		return

	breakthrough_chance = min(max_breakthrough_chance, breakthrough_chance + 5)

	to_chat(usr, "<span class='notice'>SCP-914's breakthrough chance is enhanced. Chance: [breakthrough_chance]/[max_breakthrough_chance]</span>")

/obj/machinery/scp914/proc/ultimate_refinement_ability()
	if(refinement_evolution < max_refinement_evolution)
		to_chat(usr, "<span class='warning'>SCP-914 needs maximum evolution for ultimate refinement.</span>")
		return

	// Ultimate refinement affects all nearby objects
	for(var/obj/O in range(refinement_radius + refinement_radius_expansion, src))
		if(O != src)
			enhance_item(O)

	to_chat(usr, "<span class='notice'>SCP-914 performs ultimate refinement on all nearby objects.</span>")

// Enhanced status display
/obj/machinery/scp914/proc/get_refinement_status()
	var/message = "<h2>SCP-914 Refinement Status</h2>"
	message += "<b>Current Setting:</b> [refinement_setting]<br>"
	message += "<b>Refinement Quality:</b> [refinement_quality]/[max_quality]<br>"
	message += "<b>Refinement Mastery:</b> [refinement_mastery]/[max_refinement_mastery]<br>"
	message += "<b>Material Synthesis:</b> [material_synthesis]/[max_material_synthesis]<br>"
	message += "<b>Reality Manipulation:</b> [reality_manipulation]/[max_reality_manipulation]<br>"
	message += "<b>Temporal Effects:</b> [temporal_effects]/[max_temporal_effects]<br>"
	message += "<b>Refinement Evolution:</b> [refinement_evolution]/[max_refinement_evolution]<br>"
	message += "<b>Refinement Efficiency:</b> [refinement_efficiency]/[max_refinement_efficiency]<br>"
	message += "<b>Cooldown Reduction:</b> [refinement_cooldown_reduction]/[max_cooldown_reduction]<br>"
	message += "<b>Radius Expansion:</b> [refinement_radius_expansion]/[max_radius_expansion]<br>"
	message += "<b>Breakthrough Chance:</b> [breakthrough_chance]/[max_breakthrough_chance]<br>"
	message += "<b>Active:</b> [active ? "Yes" : "No"]<br>"
	message += "<b>Progress:</b> [refinement_progress]/[max_refinement_progress]<br>"

	return message

// Enhanced input objects display
/obj/machinery/scp914/proc/get_input_objects()
	var/message = "<h2>SCP-914 Input Objects</h2>"

	if(input_objects.len)
		message += "<b>Objects in Input:</b><br>"
		for(var/obj/item/item in input_objects)
			if(item)
				message += "- [item.name]<br>"
	else
		message += "<i>No objects in input.</i>"

	return message

// Enhanced output objects display
/obj/machinery/scp914/proc/get_output_objects()
	var/message = "<h2>SCP-914 Output Objects</h2>"

	if(output_objects.len)
		message += "<b>Objects in Output:</b><br>"
		for(var/obj/item/item in output_objects)
			if(item)
				message += "- [item.name]<br>"
	else
		message += "<i>No objects in output.</i>"

	return message

// Enhanced verbs
/obj/machinery/scp914/verb/change_setting()
	set name = "Change Setting"
	set category = "SCP-914"
	set desc = "Change the refinement setting of SCP-914."

	if(!usr || !usr.client)
		return

	var/new_setting = input(usr, "Choose refinement setting:", "SCP-914 Setting") as null|anything in refinement_settings
	if(new_setting)
		refinement_setting = new_setting
		to_chat(usr, "<span class='notice'>SCP-914 setting changed to [refinement_setting].</span>")

/obj/machinery/scp914/verb/start_refinement()
	set name = "Start Refinement"
	set category = "SCP-914"
	set desc = "Start the refinement process."

	if(!usr || !usr.client)
		return

	if(active)
		to_chat(usr, "<span class='warning'>SCP-914 is already active.</span>")
		return

	if(!input_objects.len)
		to_chat(usr, "<span class='warning'>No objects in input to refine.</span>")
		return

	active = TRUE
	refinement_progress = 0
	visible_message("<span class='notice'>SCP-914 begins refining [input_objects.len] objects on [refinement_setting] setting.</span>")

/obj/machinery/scp914/verb/add_to_input(obj/item/item in range(1, src))
	set name = "Add to Input"
	set category = "SCP-914"
	set desc = "Add an item to SCP-914's input."

	if(!usr || !usr.client)
		return

	if(!item)
		to_chat(usr, "<span class='warning'>No item selected.</span>")
		return

	if(active)
		to_chat(usr, "<span class='warning'>Cannot add items while SCP-914 is active.</span>")
		return

	input_objects += item
	item.forceMove(src)
	to_chat(usr, "<span class='notice'>Added [item.name] to SCP-914 input.</span>")

/obj/machinery/scp914/verb/remove_from_output(obj/item/item in output_objects)
	set name = "Remove from Output"
	set category = "SCP-914"
	set desc = "Remove an item from SCP-914's output."

	if(!usr || !usr.client)
		return

	if(!item)
		to_chat(usr, "<span class='warning'>No item selected.</span>")
		return

	output_objects -= item
	item.forceMove(get_turf(src))
	to_chat(usr, "<span class='notice'>Removed [item.name] from SCP-914 output.</span>")

/obj/machinery/scp914/verb/refinement_mastery()
	set name = "Refinement Mastery"
	set category = "SCP-914"
	set desc = "Enhance SCP-914's refinement mastery."

	refinement_mastery_ability()

/obj/machinery/scp914/verb/material_synthesis()
	set name = "Material Synthesis"
	set category = "SCP-914"
	set desc = "Begin material synthesis."

	material_synthesis_ability()

/obj/machinery/scp914/verb/reality_manipulation()
	set name = "Reality Manipulation"
	set category = "SCP-914"
	set desc = "Begin reality manipulation."

	reality_manipulation_ability()

/obj/machinery/scp914/verb/temporal_effects()
	set name = "Temporal Effects"
	set category = "SCP-914"
	set desc = "Create temporal effects."

	temporal_effects_ability()

/obj/machinery/scp914/verb/evolve_refinement()
	set name = "Evolve Refinement"
	set category = "SCP-914"
	set desc = "Evolve SCP-914's refinement capabilities."

	evolve_refinement_ability()

/obj/machinery/scp914/verb/efficiency_improvement()
	set name = "Efficiency Improvement"
	set category = "SCP-914"
	set desc = "Improve SCP-914's efficiency."

	efficiency_improvement_ability()

/obj/machinery/scp914/verb/cooldown_reduction()
	set name = "Cooldown Reduction"
	set category = "SCP-914"
	set desc = "Reduce SCP-914's cooldown."

	cooldown_reduction_ability()

/obj/machinery/scp914/verb/radius_expansion()
	set name = "Radius Expansion"
	set category = "SCP-914"
	set desc = "Expand SCP-914's refinement radius."

	radius_expansion_ability()

/obj/machinery/scp914/verb/breakthrough_enhancement()
	set name = "Breakthrough Enhancement"
	set category = "SCP-914"
	set desc = "Enhance SCP-914's breakthrough chance."

	breakthrough_enhancement_ability()

/obj/machinery/scp914/verb/ultimate_refinement()
	set name = "Ultimate Refinement"
	set category = "SCP-914"
	set desc = "Perform ultimate refinement on all nearby objects."

	ultimate_refinement_ability()

// Admin verb to view SCP-914 persistence data
/obj/machinery/scp914/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP-914"
	set desc = "View SCP-914 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-914 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Refinements Performed:</b> [refinements_performed]<br>"
	message += "<b>Objects Destroyed:</b> [objects_destroyed]<br>"
	message += "<b>Objects Enhanced:</b> [objects_enhanced]<br>"
	message += "<b>Total Materials Processed:</b> [total_materials_processed]<br>"
	message += "<b>Refinement Breakthroughs:</b> [refinement_breakthroughs]<br>"
	message += "<b>Refinement Catastrophes:</b> [refinement_catastrophes]<br>"
	message += "<b>Refinement Masteries:</b> [refinement_masteries]<br>"
	message += "<b>Material Syntheses:</b> [material_syntheses]<br>"
	message += "<b>Reality Manipulations:</b> [reality_manipulations]<br>"
	message += "<b>Temporal Events:</b> [temporal_events]<br>"
	message += "<b>Evolution Events:</b> [evolution_events]<br>"
	message += "<b>Efficiency Improvements:</b> [efficiency_improvements]<br>"
	message += "<b>Refinement Mastery:</b> [refinement_mastery]/[max_refinement_mastery]<br>"
	message += "<b>Material Synthesis:</b> [material_synthesis]/[max_material_synthesis]<br>"
	message += "<b>Reality Manipulation:</b> [reality_manipulation]/[max_reality_manipulation]<br>"
	message += "<b>Temporal Effects:</b> [temporal_effects]/[max_temporal_effects]<br>"
	message += "<b>Refinement Evolution:</b> [refinement_evolution]/[max_refinement_evolution]<br>"
	message += "<b>Refinement Efficiency:</b> [refinement_efficiency]/[max_refinement_efficiency]<br>"
	message += "<b>Cooldown Reduction:</b> [refinement_cooldown_reduction]/[max_cooldown_reduction]<br>"
	message += "<b>Radius Expansion:</b> [refinement_radius_expansion]/[max_radius_expansion]<br>"
	message += "<b>Breakthrough Chance:</b> [breakthrough_chance]/[max_breakthrough_chance]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-914"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-914
/obj/machinery/scp914/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-914, a clockwork refinement device with multiple settings.</span>")
		else
			to_chat(user, "<span class='notice'>A massive clockwork device that seems to refine objects placed within it.</span>")
