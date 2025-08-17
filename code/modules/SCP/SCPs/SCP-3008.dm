// SCP-3008 - The Infinite IKEA
// An infinite IKEA store with hostile staff entities and survival mechanics

/obj/structure/scp3008
	name = "SCP-3008"
	desc = "An entrance to an infinite IKEA store. The interior seems to stretch on forever."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "door"
	density = TRUE
	anchored = TRUE

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
		SCP_DISABLED
	)

	SCP.min_playercount = 25
	SCP.min_time = 45 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-3008"] = new /datum/scp_instance("SCP-3008", src)

/obj/structure/scp3008/Destroy()
	return ..()

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
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

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

