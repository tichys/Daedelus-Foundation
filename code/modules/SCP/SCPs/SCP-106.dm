// SCP-106 - The Old Man
// An elderly humanoid that can phase through walls and create pocket dimensions

/mob/living/carbon/human/scp106
	name = "SCP-106"
	desc = "An elderly humanoid figure with dark, wrinkled skin. It appears to be hunched over."
	icon = 'icons/scp/scp-106.dmi'
	icon_state = "scp106"
	real_name = "SCP-106"

	// Core system datums
	var/datum/scp106_phasing_system/phasing_system
	var/datum/scp106_pocket_dimension_system/pocket_dimension_system
	var/datum/scp106_corrosion_system/corrosion_system
	var/datum/scp106_hunting_system/hunting_system
	var/datum/scp106_containment_system/containment_system
	var/datum/scp106_research_integration/research_integration

	// Core stats (now human-based)
	var/dimensional_energy = 100
	var/phase_mastery = 1.0
	var/corrosion_potency = 50
	var/hunt_experience = 0

	// Persistence tracking
	var/phase_count = 0
	var/pocket_dimensions_created = 0
	var/victims_dragged = 0
	var/corrosion_events = 0
	var/total_damage_dealt = 0
	var/dimensional_manipulations = 0
	var/containment_breaches = 0
	var/escape_attempts = 0

/mob/living/carbon/human/scp106/Initialize()
	. = ..()

	// Set species properly
	set_species(/datum/species/scp106)

	// Initialize core systems
	phasing_system = new /datum/scp106_phasing_system(src)
	pocket_dimension_system = new /datum/scp106_pocket_dimension_system(src)
	corrosion_system = new /datum/scp106_corrosion_system(src)
	hunting_system = new /datum/scp106_hunting_system(src)
	containment_system = new /datum/scp106_containment_system(src)
	research_integration = new /datum/scp106_research_integration(src)

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-106",
		SCP_KETER,
		"106",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	// Set up human-specific properties for SCP-106
	maxHealth = 300 // Base health as per design
	health = maxHealth

	// Initialize vision cone
	fovangle = 90
	update_fov_angles()
	update_cone_show()

	// Start processing
	START_PROCESSING(SSobj, src)

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

/mob/living/carbon/human/scp106/process(delta_time)
	// Don't call parent - we're implementing our own process logic

	// Update all systems
	phasing_system?.process_phasing()
	pocket_dimension_system?.process_dimensions()
	corrosion_system?.process_corrosion()
	hunting_system?.process_hunting()
	containment_system?.process_containment()
	research_integration?.process_research()

	// Return nothing to continue processing (not PROCESS_KILL)

// SCP-106 Status Display
/mob/living/carbon/human/scp106/proc/get_scp106_status_items()
	var/list/status_items = list()

	// Phasing system status
	if(phasing_system)
		status_items += "Dimensional Energy: [phasing_system.dimensional_energy]/[phasing_system.max_dimensional_energy]"
		status_items += "Phase Mastery: [phasing_system.phase_mastery]/[phasing_system.max_phase_mastery]"
		status_items += "Phase Range: [phasing_system.phase_range]/[phasing_system.max_phase_range]"

	// Pocket dimension system status
	if(pocket_dimension_system)
		status_items += "Active Dimensions: [pocket_dimension_system.active_dimensions.len]/[pocket_dimension_system.dimension_capacity]"
		status_items += "Torture Efficiency: [pocket_dimension_system.torture_efficiency]/[pocket_dimension_system.max_torture_efficiency]"
		status_items += "Extraction Difficulty: [pocket_dimension_system.extraction_difficulty]/[pocket_dimension_system.max_extraction_difficulty]"

	// Corrosion system status
	if(corrosion_system)
		status_items += "Corrosion Potency: [corrosion_system.corrosion_potency]/[corrosion_system.max_corrosion_potency]"
		status_items += "Corrosion Spread: [corrosion_system.corrosion_spread]/[corrosion_system.max_corrosion_spread]"
		status_items += "Environmental Impact: [corrosion_system.environmental_impact]/[corrosion_system.max_environmental_impact]"

	// Hunting system status
	if(hunting_system)
		status_items += "Hunt Experience: [hunting_system.hunt_experience]/[hunting_system.max_hunt_experience]"
		status_items += "Stalking Patience: [hunting_system.stalking_patience]/[hunting_system.max_stalking_patience]"
		status_items += "Hunt Mode: [hunting_system.hunt_mode ? "ACTIVE" : "INACTIVE"]"
		if(hunting_system.current_target)
			status_items += "Current Target: [hunting_system.current_target]"

	// Containment system status
	if(containment_system)
		status_items += "Containment Status: [containment_system.containment_status]"
		status_items += "Breach Capability: [containment_system.breach_capability]/[containment_system.max_breach_capability]"
		status_items += "Escape Motivation: [containment_system.escape_motivation]/[containment_system.max_escape_motivation]"

	return status_items

// Override get_status_tab_items to include SCP-106 specific information
/mob/living/carbon/human/scp106/get_status_tab_items()
	var/list/status_items = ..()
	status_items += get_scp106_status_items()
	return status_items

// Enhanced examine for SCP-106
/mob/living/carbon/human/scp106/examine(mob/user)
	. = ..()

	if(phasing_system)
		. += "<span class='notice'>Dimensional Energy: [phasing_system.dimensional_energy]/[phasing_system.max_dimensional_energy]</span>"
		. += "<span class='notice'>Phase Mastery: [phasing_system.phase_mastery]/[phasing_system.max_phase_mastery]</span>"

	if(pocket_dimension_system)
		. += "<span class='notice'>Active Dimensions: [pocket_dimension_system.active_dimensions.len]</span>"
		. += "<span class='notice'>Torture Efficiency: [pocket_dimension_system.torture_efficiency]%</span>"

	if(corrosion_system)
		. += "<span class='notice'>Corrosion Potency: [corrosion_system.corrosion_potency]%</span>"

	if(containment_system && containment_system.containment_status == "breached")
		. += "<span class='danger'>This SCP-106 has breached containment!</span>"

// Research contribution
/mob/living/carbon/human/scp106/proc/contribute_research_data()
	var/research_data = list(
		"scp_type" = "SCP-106",
		"dimensional_energy" = phasing_system?.dimensional_energy || 0,
		"phase_mastery" = phasing_system?.phase_mastery || 1.0,
		"active_dimensions" = pocket_dimension_system?.active_dimensions?.len || 0,
		"torture_efficiency" = pocket_dimension_system?.torture_efficiency || 0,
		"corrosion_potency" = corrosion_system?.corrosion_potency || 0,
		"hunt_experience" = hunting_system?.hunt_experience || 0,
		"containment_status" = containment_system?.containment_status || "unknown",
		"breach_capability" = containment_system?.breach_capability || 0,
		"escape_motivation" = containment_system?.escape_motivation || 0,
		"timestamp" = world.time
	)

	research_integration?.research_data["last_update"] = research_data

// Progression Integration Hooks
/mob/living/carbon/human/scp106/proc/on_breach()
	containment_breaches++
	hook_scp_breach("SCP-106", src)

/mob/living/carbon/human/scp106/proc/on_pocket_capture(mob/living/carbon/human/victim)
	if(victim && victim.ckey)
		hook_scp_interaction(victim, "SCP-106", INTERACTION_TYPE_CONTAINMENT, list("captured" = TRUE))
		start_scp_survival_tracking(victim, "SCP-106", INTERACTION_RISK_CRITICAL)
		victims_dragged++

/mob/living/carbon/human/scp106/proc/on_pocket_escape(mob/living/carbon/human/escapee)
	if(escapee && escapee.ckey)
		stop_scp_survival_tracking(escapee, "SCP-106")
		hook_scp_interaction(escapee, "SCP-106", INTERACTION_TYPE_SURVIVAL, list("escaped" = TRUE))
		escape_attempts++

/mob/living/carbon/human/scp106/proc/on_corrosion_use(mob/living/carbon/human/target)
	if(target && target.ckey)
		hook_scp_combat(target, "SCP-106", corrosion_potency, 0)
		corrosion_events++
