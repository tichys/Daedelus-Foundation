/obj/machinery/scp914
	name = "SCP-914"
	desc = "A massive clockwork device with various settings for refining objects. It seems to be constantly ticking and whirring."
	icon = 'icons/scp/SCP-914-64x64.dmi'
	icon_state = "scp914"
	density = TRUE
	anchored = TRUE

	// Modular system datums
	var/datum/scp914_refinement_system/refinement_system
	var/datum/scp914_reality_system/reality_system
	var/datum/scp914_temporal_system/temporal_system
	var/datum/scp914_material_system/material_system
	var/datum/scp914_containment_system/containment_system
	var/datum/scp914_environmental_system/environmental_system
	var/datum/scp914_research_integration/research_integration

/obj/machinery/scp914/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-914",
		SCP_EUCLID,
		"914"
	)

	SCP.min_playercount = 10
	SCP.min_time = 15 MINUTES

	// Initialize modular systems
	refinement_system = new /datum/scp914_refinement_system(src)
	reality_system = new /datum/scp914_reality_system(src)
	temporal_system = new /datum/scp914_temporal_system(src)
	material_system = new /datum/scp914_material_system(src)
	containment_system = new /datum/scp914_containment_system(src)
	environmental_system = new /datum/scp914_environmental_system(src)
	research_integration = new /datum/scp914_research_integration(src)

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-914"] = new /datum/scp_instance("SCP-914", src)

/obj/machinery/scp914/Destroy()
	// Clean up system datums
	if(refinement_system)
		refinement_system.input_objects.Cut()
		refinement_system.output_objects.Cut()
	if(material_system)
		material_system.refined_materials.Cut()
	if(research_integration)
		research_integration.research_data.Cut()
	return ..()

// Core processing
/obj/machinery/scp914/process()
	. = ..()

	// Process all systems
	if(refinement_system)
		refinement_system.process_refinement()
		refinement_system.process_refinement_mastery()

	if(reality_system)
		reality_system.process_reality_manipulation()

	if(temporal_system)
		temporal_system.process_temporal_effects()

	if(material_system)
		material_system.process_material_synthesis()

	if(containment_system)
		containment_system.check_containment()

	if(environmental_system)
		environmental_system.process_environmental_effects()

	if(research_integration)
		research_integration.update_research_data()

	// Award research points to nearby researchers
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP) // Skip SCPs
			continue

			// Award research points for observing SCP-914
	// Research data will be collected by the research integration system

// ===== USER INTERFACE VERBS =====

/obj/machinery/scp914/verb/change_setting()
	set name = "Change Setting"
	set category = "SCP-914"
	set desc = "Change the refinement setting of SCP-914."

	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	var/new_setting = input(usr, "Choose refinement setting:", "SCP-914 Setting") as null|anything in refinement_system.refinement_settings
	if(new_setting)
		refinement_system.refinement_setting = new_setting
		to_chat(usr, "<span class='notice'>SCP-914 setting changed to [refinement_system.refinement_setting].</span>")

/obj/machinery/scp914/verb/start_refinement()
	set name = "Start Refinement"
	set category = "SCP-914"
	set desc = "Start the refinement process."

	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(refinement_system.active)
		to_chat(usr, "<span class='warning'>SCP-914 is already active.</span>")
		return

	if(!refinement_system.input_objects.len)
		to_chat(usr, "<span class='warning'>No objects in input to refine.</span>")
		return

	refinement_system.active = TRUE
	refinement_system.refinement_progress = 0
	visible_message("<span class='notice'>SCP-914 begins refining [refinement_system.input_objects.len] objects on [refinement_system.refinement_setting] setting.</span>")

	// Progression integration - log experiment start
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		hook_scp_experiment(H, "SCP-914", EXPERIMENT_TYPE_TECHNICAL)
		hook_scp_interaction(H, "SCP-914", INTERACTION_TYPE_EXPERIMENT, list("type" = "refinement", "setting" = refinement_system.refinement_setting))

/obj/machinery/scp914/verb/add_to_input(obj/item/item in range(1, src))
	set name = "Add to Input"
	set category = "SCP-914"
	set desc = "Add an item to SCP-914's input."

	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(!item)
		to_chat(usr, "<span class='warning'>No item selected.</span>")
		return

	if(refinement_system.active)
		to_chat(usr, "<span class='warning'>Cannot add items while SCP-914 is active.</span>")
		return

	refinement_system.input_objects += item
	item.forceMove(src)
	to_chat(usr, "<span class='notice'>Added [item.name] to SCP-914 input.</span>")

/obj/machinery/scp914/verb/remove_from_output(obj/item/item in refinement_system.output_objects)
	set name = "Remove from Output"
	set category = "SCP-914"
	set desc = "Remove an item from SCP-914's output."

	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(!item)
		to_chat(usr, "<span class='warning'>No item selected.</span>")
		return

	refinement_system.output_objects -= item
	item.forceMove(get_turf(src))
	to_chat(usr, "<span class='notice'>Removed [item.name] from SCP-914 output.</span>")

// ===== ADVANCED ABILITY VERBS =====

/obj/machinery/scp914/verb/refinement_mastery()
	set name = "Refinement Mastery"
	set category = "SCP-914"
	set desc = "Enhance SCP-914's refinement mastery."

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(refinement_system.refinement_mastery >= refinement_system.max_refinement_mastery)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum refinement mastery.</span>")
		return

	refinement_system.refinement_mastery = min(refinement_system.max_refinement_mastery, refinement_system.refinement_mastery + 10)
	to_chat(usr, "<span class='notice'>SCP-914's refinement mastery is enhanced. Mastery: [refinement_system.refinement_mastery]/[refinement_system.max_refinement_mastery]</span>")

/obj/machinery/scp914/verb/material_synthesis()
	set name = "Material Synthesis"
	set category = "SCP-914"
	set desc = "Begin material synthesis."

	if(!material_system)
		to_chat(usr, "<span class='warning'>SCP-914 material system not available.</span>")
		return

	if(material_system.activate_material_synthesis())
		to_chat(usr, "<span class='notice'>SCP-914 begins material synthesis. Synthesis: [material_system.material_synthesis]/[material_system.max_material_synthesis]</span>")
	else
		to_chat(usr, "<span class='warning'>SCP-914 needs time to synthesize materials.</span>")

/obj/machinery/scp914/verb/reality_manipulation()
	set name = "Reality Manipulation"
	set category = "SCP-914"
	set desc = "Begin reality manipulation."

	if(!reality_system)
		to_chat(usr, "<span class='warning'>SCP-914 reality system not available.</span>")
		return

	if(reality_system.activate_reality_manipulation())
		to_chat(usr, "<span class='notice'>SCP-914 begins reality manipulation. Manipulation: [reality_system.reality_manipulation]/[reality_system.max_reality_manipulation]</span>")
	else
		to_chat(usr, "<span class='warning'>SCP-914 needs time to manipulate reality.</span>")

/obj/machinery/scp914/verb/temporal_effects()
	set name = "Temporal Effects"
	set category = "SCP-914"
	set desc = "Create temporal effects."

	if(!temporal_system)
		to_chat(usr, "<span class='warning'>SCP-914 temporal system not available.</span>")
		return

	if(temporal_system.activate_temporal_effects())
		to_chat(usr, "<span class='notice'>SCP-914 creates temporal effects. Effects: [temporal_system.temporal_effects]/[temporal_system.max_temporal_effects]</span>")

/obj/machinery/scp914/verb/efficiency_improvement()
	set name = "Efficiency Improvement"
	set category = "SCP-914"
	set desc = "Improve SCP-914's efficiency."

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(refinement_system.refinement_efficiency >= refinement_system.max_refinement_efficiency)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum efficiency.</span>")
		return

	refinement_system.refinement_efficiency = min(refinement_system.max_refinement_efficiency, refinement_system.refinement_efficiency + 0.2)
	to_chat(usr, "<span class='notice'>SCP-914's efficiency is improved. Efficiency: [refinement_system.refinement_efficiency]/[refinement_system.max_refinement_efficiency]</span>")

/obj/machinery/scp914/verb/cooldown_reduction()
	set name = "Cooldown Reduction"
	set category = "SCP-914"
	set desc = "Reduce SCP-914's cooldown."

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(refinement_system.refinement_cooldown_reduction >= refinement_system.max_cooldown_reduction)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum cooldown reduction.</span>")
		return

	refinement_system.refinement_cooldown_reduction = min(refinement_system.max_cooldown_reduction, refinement_system.refinement_cooldown_reduction + 10)
	to_chat(usr, "<span class='notice'>SCP-914's cooldown is reduced. Reduction: [refinement_system.refinement_cooldown_reduction]/[refinement_system.max_cooldown_reduction]</span>")

/obj/machinery/scp914/verb/radius_expansion()
	set name = "Radius Expansion"
	set category = "SCP-914"
	set desc = "Expand SCP-914's refinement radius."

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(refinement_system.refinement_radius_expansion >= refinement_system.max_radius_expansion)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum radius expansion.</span>")
		return

	refinement_system.refinement_radius_expansion = min(refinement_system.max_radius_expansion, refinement_system.refinement_radius_expansion + 1)
	to_chat(usr, "<span class='notice'>SCP-914's refinement radius is expanded. Radius: [refinement_system.refinement_radius + refinement_system.refinement_radius_expansion]</span>")

/obj/machinery/scp914/verb/breakthrough_enhancement()
	set name = "Breakthrough Enhancement"
	set category = "SCP-914"
	set desc = "Enhance SCP-914's breakthrough chance."

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(refinement_system.breakthrough_chance >= refinement_system.max_breakthrough_chance)
		to_chat(usr, "<span class='warning'>SCP-914 has reached maximum breakthrough chance.</span>")
		return

	refinement_system.breakthrough_chance = min(refinement_system.max_breakthrough_chance, refinement_system.breakthrough_chance + 5)
	to_chat(usr, "<span class='notice'>SCP-914's breakthrough chance is enhanced. Chance: [refinement_system.breakthrough_chance]/[refinement_system.max_breakthrough_chance]</span>")

/obj/machinery/scp914/verb/emergency_shutdown()
	set name = "Emergency Shutdown"
	set category = "SCP-914"
	set desc = "Activate emergency shutdown procedure."

	if(!containment_system)
		to_chat(usr, "<span class='warning'>SCP-914 containment system not available.</span>")
		return

	containment_system.emergency_shutdown_procedure()
	to_chat(usr, "<span class='notice'>SCP-914 emergency shutdown activated.</span>")

// ===== STATUS DISPLAY VERBS =====

/obj/machinery/scp914/verb/view_status()
	set name = "View Status"
	set category = "SCP-914"
	set desc = "View SCP-914's current status."

	if(!usr || !usr.client)
		return

	var/message = "<h2>SCP-914 Status</h2>"

	if(refinement_system)
		message += "<b>Current Setting:</b> [refinement_system.refinement_setting]<br>"
		message += "<b>Refinement Quality:</b> [refinement_system.refinement_quality]/[refinement_system.max_quality]<br>"
		message += "<b>Refinement Mastery:</b> [refinement_system.refinement_mastery]/[refinement_system.max_refinement_mastery]<br>"
		message += "<b>Refinement Efficiency:</b> [refinement_system.refinement_efficiency]/[refinement_system.max_refinement_efficiency]<br>"
		message += "<b>Breakthrough Chance:</b> [refinement_system.breakthrough_chance]/[refinement_system.max_breakthrough_chance]<br>"
		message += "<b>Active:</b> [refinement_system.active ? "Yes" : "No"]<br>"
		message += "<b>Progress:</b> [refinement_system.refinement_progress]/[refinement_system.max_refinement_progress]<br>"

	if(material_system)
		message += "<b>Material Synthesis:</b> [material_system.material_synthesis]/[material_system.max_material_synthesis]<br>"

	if(reality_system)
		message += "<b>Reality Manipulation:</b> [reality_system.reality_manipulation]/[reality_system.max_reality_manipulation]<br>"

	if(temporal_system)
		message += "<b>Temporal Effects:</b> [temporal_system.temporal_effects]/[temporal_system.max_temporal_effects]<br>"

	if(containment_system)
		message += "<b>Containment Status:</b> [containment_system.containment_status]<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/machinery/scp914/verb/view_input_objects()
	set name = "View Input Objects"
	set category = "SCP-914"
	set desc = "View objects in SCP-914's input."

	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	var/message = "<h2>SCP-914 Input Objects</h2>"

	if(refinement_system.input_objects.len)
		message += "<b>Objects in Input:</b><br>"
		for(var/obj/item/item in refinement_system.input_objects)
			if(item)
				message += "- [item.name]<br>"
	else
		message += "<i>No objects in input.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/machinery/scp914/verb/view_output_objects()
	set name = "View Output Objects"
	set category = "SCP-914"
	set desc = "View objects in SCP-914's output."

	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	var/message = "<h2>SCP-914 Output Objects</h2>"

	if(refinement_system.output_objects.len)
		message += "<b>Objects in Output:</b><br>"
		for(var/obj/item/item in refinement_system.output_objects)
			if(item)
				message += "- [item.name]<br>"
	else
		message += "<i>No objects in output.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/machinery/scp914/verb/view_research_summary()
	set name = "View Research Summary"
	set category = "SCP-914"
	set desc = "View SCP-914's research summary."

	if(!usr || !usr.client)
		return

	if(!research_integration)
		to_chat(usr, "<span class='warning'>SCP-914 research integration not available.</span>")
		return

	var/summary = research_integration.get_research_summary()
	to_chat(usr, "<span class='notice'>[summary]</span>")

// Admin verb to view SCP-914 persistence data
/obj/machinery/scp914/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP-914"
	set desc = "View SCP-914 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-914 Persistence Data</h2>"

	if(containment_system)
		message += "<b>Containment Status:</b> [containment_system.containment_status]<br>"

	if(refinement_system)
		message += "<b>Refinements Performed:</b> [refinement_system.refinements_performed]<br>"
		message += "<b>Objects Destroyed:</b> [refinement_system.objects_destroyed]<br>"
		message += "<b>Objects Enhanced:</b> [refinement_system.objects_enhanced]<br>"
		message += "<b>Total Materials Processed:</b> [refinement_system.total_materials_processed]<br>"
		message += "<b>Refinement Breakthroughs:</b> [refinement_system.refinement_breakthroughs]<br>"
		message += "<b>Refinement Catastrophes:</b> [refinement_system.refinement_catastrophes]<br>"
		message += "<b>Refinement Mastery:</b> [refinement_system.refinement_mastery]/[refinement_system.max_refinement_mastery]<br>"
		message += "<b>Refinement Efficiency:</b> [refinement_system.refinement_efficiency]/[refinement_system.max_refinement_efficiency]<br>"
		message += "<b>Cooldown Reduction:</b> [refinement_system.refinement_cooldown_reduction]/[refinement_system.max_cooldown_reduction]<br>"
		message += "<b>Radius Expansion:</b> [refinement_system.refinement_radius_expansion]/[refinement_system.max_radius_expansion]<br>"
		message += "<b>Breakthrough Chance:</b> [refinement_system.breakthrough_chance]/[refinement_system.max_breakthrough_chance]<br>"

	if(material_system)
		message += "<b>Material Syntheses:</b> [material_system.material_syntheses]<br>"
		message += "<b>Material Synthesis:</b> [material_system.material_synthesis]/[material_system.max_material_synthesis]<br>"

	if(reality_system)
		message += "<b>Reality Manipulations:</b> [reality_system.reality_manipulations]<br>"
		message += "<b>Reality Manipulation:</b> [reality_system.reality_manipulation]/[reality_system.max_reality_manipulation]<br>"

	if(temporal_system)
		message += "<b>Temporal Events:</b> [temporal_system.temporal_events]<br>"
		message += "<b>Temporal Effects:</b> [temporal_system.temporal_effects]/[temporal_system.max_temporal_effects]<br>"

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

		// Show current status to users
		if(refinement_system)
			to_chat(user, "<span class='notice'>Current setting: [refinement_system.refinement_setting]</span>")
			to_chat(user, "<span class='notice'>Status: [refinement_system.active ? "Active" : "Inactive"]</span>")
