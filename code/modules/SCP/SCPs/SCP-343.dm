// SCP-343 - God
// Divine Intervention and Reality Manipulation System

/mob/living/carbon/human/scp343
	name = "SCP-343"
	desc = "An elderly man who claims to be God. He radiates an aura of divine power and benevolence."
	icon = 'icons/scp/scp-343.dmi'
	icon_state = "scp343"
	real_name = "SCP-343"

	// Core system datums
	var/datum/scp343_divine_power/divine_power
	var/datum/scp343_intervention/intervention_system
	var/datum/scp343_evolution/evolution_system
	var/datum/scp343_containment/containment_system
	var/datum/scp343_environmental/environmental_system
	var/datum/scp343_research_integration/research_integration

	// Persistence tracking
	var/total_protections_given = 0
	var/total_healings_performed = 0
	var/total_guidance_provided = 0
	var/total_reality_manipulations = 0
	var/total_evolution_stages = 0
	var/total_containment_encounters = 0
	var/total_divine_zones_created = 0
	var/session_start_time = 0
	var/containment_status = "contained"

/mob/living/carbon/human/scp343/Initialize()
	. = ..()

	// Set species properly
	set_species(/datum/species/scp343)

	// Initialize SCP datum
	SCP = new /datum/scp(src, "God", SCP_SAFE, "343", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	// Initialize core systems after a short delay to ensure proper initialization
	addtimer(CALLBACK(src, PROC_REF(initialize_scp343_systems)), 1)

	// Start processing
	START_PROCESSING(SSobj, src)

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

/mob/living/carbon/human/scp343/proc/initialize_scp343_systems()
	// Initialize core systems
	divine_power = new /datum/scp343_divine_power(src)
	intervention_system = new /datum/scp343_intervention(src)
	evolution_system = new /datum/scp343_evolution(src)
	containment_system = new /datum/scp343_containment(src)
	environmental_system = new /datum/scp343_environmental(src)
	research_integration = new /datum/scp343_research_integration(src)

/mob/living/carbon/human/scp343/Destroy()
	// Clean up systems
	QDEL_NULL(divine_power)
	QDEL_NULL(intervention_system)
	QDEL_NULL(evolution_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(environmental_system)
	QDEL_NULL(research_integration)

	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/carbon/human/scp343/process()
	. = ..()

	// Process all systems
	divine_power?.process()
	intervention_system?.process()
	containment_system?.process()
	research_integration?.contribute_research_data()

	// Process SCP-343 specific effects
	process_scp343_effects()

/mob/living/carbon/human/scp343/proc/process_scp343_effects()
	// Update divine presence
	update_divine_presence()

	// Process automatic protection aura
	if(divine_power && divine_power.divine_energy > 10)
		divine_power.protection_aura_active = TRUE

	// Process evolution benefits
	if(evolution_system && evolution_system.current_stage > 1)
		apply_evolution_benefits()

/mob/living/carbon/human/scp343/proc/update_divine_presence()
	// Create subtle divine effects
	if(prob(5)) // 5% chance per process cycle
		var/obj/effect/temp_visual/divine_presence/presence = new(loc)
		presence.color = "#FFD700"

/mob/living/carbon/human/scp343/proc/apply_evolution_benefits()
	// Apply passive benefits based on evolution stage
	var/stage = evolution_system.current_stage

	// Enhanced protection aura
	if(stage >= 2)
		divine_power.protection_aura_range = 3 + (stage - 1) * 2

	// Enhanced energy regeneration
	if(stage >= 3)
		divine_power.energy_regeneration_rate = 1 + (stage - 2) * 0.5

// Persistence tracking methods
/mob/living/carbon/human/scp343/proc/add_protection_record(mob/living/carbon/human/H)
	total_protections_given++
	evolution_system.add_protection_points(5)
	containment_system.add_activity()

	// Add to persistence if available
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-343"]
		if(instance)
			instance.add_interaction_record(H, "divine_protection")

/mob/living/carbon/human/scp343/proc/add_healing_record(mob/living/carbon/human/H)
	total_healings_performed++
	evolution_system.add_healing_points(10)
	containment_system.add_activity()

	// Add to persistence if available
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-343"]
		if(instance)
			instance.add_interaction_record(H, "divine_healing")

/mob/living/carbon/human/scp343/proc/add_guidance_record(mob/living/carbon/human/H)
	total_guidance_provided++
	evolution_system.add_guidance_points(3)
	containment_system.add_activity()

	// Add to persistence if available
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-343"]
		if(instance)
			instance.add_interaction_record(H, "divine_guidance")

/mob/living/carbon/human/scp343/proc/add_reality_manipulation_record(turf/T)
	total_reality_manipulations++
	evolution_system.add_authority_points(15)
	containment_system.add_activity()

	// Add to persistence if available
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-343"]
		if(instance)
			instance.add_interaction_record(null, "reality_manipulation")

/mob/living/carbon/human/scp343/proc/add_evolution_record(stage)
	total_evolution_stages++
	containment_system.add_activity()

	// Add to persistence if available
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-343"]
		if(instance)
			instance.add_interaction_record(null, "evolution_stage_[stage]")

// Legacy compatibility methods
/mob/living/carbon/human/scp343/proc/divine_intervention()
	// Legacy method - now handled by automatic intervention system
	if(intervention_system && intervention_system.can_protect())
		intervention_system.perform_protection_intervention(src)
		return TRUE
	return FALSE

/mob/living/carbon/human/scp343/proc/reality_manipulation_ability()
	// Legacy method - now handled by automatic reality manipulation
	if(intervention_system && intervention_system.can_manipulate_reality())
		intervention_system.perform_reality_manipulation(loc)
		return TRUE
	return FALSE

/mob/living/carbon/human/scp343/proc/miracle_creation()
	// Legacy method - now handled by healing intervention
	if(intervention_system && intervention_system.can_heal())
		intervention_system.perform_healing_intervention(src)
		return TRUE
	return FALSE

// Status display
/mob/living/carbon/human/scp343/proc/get_scp343_status_items()
	var/list/status_items = list()

	status_items += "=== SCP-343 Divine Status ==="
	status_items += "Divine Energy: [divine_power?.divine_energy || 0]/[divine_power?.max_divine_energy || 100] ([divine_power?.get_energy_percentage() || 0]%)"
	status_items += "Divine Authority: [divine_power?.divine_authority || 1]/[divine_power?.max_divine_authority || 5]"
	status_items += "Evolution Stage: [evolution_system?.current_stage || 1]/[evolution_system?.max_stage || 5]"
	status_items += "Containment Level: [containment_system?.containment_level || 1]/[containment_system?.max_containment_level || 4]"
	status_items += "Protection Aura: [divine_power?.protection_aura_active ? "ACTIVE" : "INACTIVE"]"
	status_items += "Divine Zones: [environmental_system?.divine_zones?.len || 0]/[environmental_system?.max_zones || 5]"

	status_items += "=== Evolution Progress ==="
	status_items += "Protection Points: [evolution_system?.protection_points || 0]"
	status_items += "Healing Points: [evolution_system?.healing_points || 0]"
	status_items += "Guidance Points: [evolution_system?.guidance_points || 0]"
	status_items += "Authority Points: [evolution_system?.authority_points || 0]"

	status_items += "=== Session Statistics ==="
	status_items += "Protections Given: [total_protections_given]"
	status_items += "Healings Performed: [total_healings_performed]"
	status_items += "Guidance Provided: [total_guidance_provided]"
	status_items += "Reality Manipulations: [total_reality_manipulations]"
	status_items += "Evolution Stages: [total_evolution_stages]"
	status_items += "Divine Activities: [containment_system?.divine_activities || 0]"

	return status_items

/mob/living/carbon/human/scp343/examine(mob/user)
	. = ..()

	if(user == src)
		. += "<span class='notice'>You radiate divine power and benevolence.</span>"
		. += "<span class='notice'>Divine Energy: [divine_power?.divine_energy || 0]/[divine_power?.max_divine_energy || 100]</span>"
		. += "<span class='notice'>Evolution Stage: [evolution_system?.current_stage || 1]</span>"
	else
		. += "<span class='notice'>This elderly man radiates an aura of divine power and benevolence.</span>"
		. += "<span class='notice'>You feel a sense of peace and protection in his presence.</span>"

		// Apply sanity effects to humans examining SCP-343
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.sanity)
				H.sanity.adjust_sanity(5)
				. += "<span class='notice'>His presence soothes your mind.</span>"

// Persistence data methods
/mob/living/carbon/human/scp343/proc/get_persistence_data()
	var/list/data = list()

	data["total_protections_given"] = total_protections_given
	data["total_healings_performed"] = total_healings_performed
	data["total_guidance_provided"] = total_guidance_provided
	data["total_reality_manipulations"] = total_reality_manipulations
	data["total_evolution_stages"] = total_evolution_stages
	data["total_containment_encounters"] = total_containment_encounters
	data["total_divine_zones_created"] = total_divine_zones_created
	data["session_start_time"] = session_start_time
	data["containment_status"] = containment_status

	// Add system data
	if(divine_power)
		data["divine_energy"] = divine_power.divine_energy
		data["divine_authority"] = divine_power.divine_authority

	if(evolution_system)
		data["evolution_stage"] = evolution_system.current_stage
		data["protection_points"] = evolution_system.protection_points
		data["healing_points"] = evolution_system.healing_points
		data["guidance_points"] = evolution_system.guidance_points
		data["authority_points"] = evolution_system.authority_points

	if(containment_system)
		data["containment_level"] = containment_system.containment_level
		data["divine_activities"] = containment_system.divine_activities

	return data

/mob/living/carbon/human/scp343/proc/load_persistence_data(list/data)
	if(!data)
		return

	total_protections_given = data["total_protections_given"] || 0
	total_healings_performed = data["total_healings_performed"] || 0
	total_guidance_provided = data["total_guidance_provided"] || 0
	total_reality_manipulations = data["total_reality_manipulations"] || 0
	total_evolution_stages = data["total_evolution_stages"] || 0
	total_containment_encounters = data["total_containment_encounters"] || 0
	total_divine_zones_created = data["total_divine_zones_created"] || 0
	session_start_time = data["session_start_time"] || world.time
	containment_status = data["containment_status"] || "contained"

	// Load system data
	if(divine_power)
		divine_power.divine_energy = data["divine_energy"] || 100
		divine_power.divine_authority = data["divine_authority"] || 1

	if(evolution_system)
		evolution_system.current_stage = data["evolution_stage"] || 1
		evolution_system.protection_points = data["protection_points"] || 0
		evolution_system.healing_points = data["healing_points"] || 0
		evolution_system.guidance_points = data["guidance_points"] || 0
		evolution_system.authority_points = data["authority_points"] || 0

	if(containment_system)
		containment_system.containment_level = data["containment_level"] || 1
		containment_system.divine_activities = data["divine_activities"] || 0

// Research contribution
/mob/living/carbon/human/scp343/proc/contribute_research_data()
	if(!research_integration)
		return

	research_integration.contribute_research_data()

// Visual Effects
/obj/effect/temp_visual/divine_presence
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparkles"
	duration = 20
	color = "#FFD700"

// END OF SCP-343 IMPLEMENTATION
// ============================================================================

/mob/living/carbon/human/scp343/proc/on_divine_protection(mob/living/carbon/human/protected)
	if(!protected)
		return
	hook_scp_care(protected, "SCP-343", "protection")

/mob/living/carbon/human/scp343/proc/on_divine_healing(mob/living/carbon/human/healed)
	if(!healed)
		return
	hook_scp_care(healed, "SCP-343", "healing")

/mob/living/carbon/human/scp343/proc/on_divine_guidance(mob/living/carbon/human/guided)
	if(!guided)
		return
	hook_scp_interaction(guided, "SCP-343", INTERACTION_TYPE_COMMUNICATION)

