// SCP-106 - The Old Man
// An elderly humanoid that can phase through walls and create pocket dimensions

/mob/living/scp/scp106
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

/mob/living/scp/scp106/Initialize()
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
	maxHealth = SCP106_MAX_HEALTH
	health = maxHealth

	// Initialize vision cone
	fovangle = 90
	update_fov_angles()
	update_cone_show()

	// Start processing
	START_PROCESSING(SSobj, src)

	// Remove bodypart overlays to prevent covering the SCP icon

/mob/living/scp/scp106/process(delta_time)
	// Don't call parent - we're implementing our own process logic

	// Update all systems
	phasing_system?.process_phasing()
	pocket_dimension_system?.process_dimensions()
	corrosion_system?.process_corrosion()
	hunting_system?.process_hunting()
	containment_system?.process_containment()
	research_integration?.process_research()

/mob/living/scp/scp106/Destroy()
	QDEL_NULL(phasing_system)
	QDEL_NULL(pocket_dimension_system)
	QDEL_NULL(corrosion_system)
	QDEL_NULL(hunting_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(research_integration)
	STOP_PROCESSING(SSobj, src)
	return ..()

// SCP-106 Status Display
/mob/living/scp/scp106/proc/get_scp106_status_items()
	var/list/status_items = list()

	if(phasing_system)
		status_items += "Dimensional Energy: [phasing_system.dimensional_energy]/[phasing_system.max_dimensional_energy]"
		status_items += "Phase Range: [phasing_system.phase_range]"

	if(pocket_dimension_system)
		status_items += "Active Dimensions: [length(pocket_dimension_system.active_dimensions)]/[pocket_dimension_system.dimension_capacity]"

	if(corrosion_system)
		status_items += "Corrosion Spread: [corrosion_system.corrosion_spread]"

	if(hunting_system)
		status_items += "Hunt Mode: [hunting_system.hunt_mode ? "ACTIVE" : "INACTIVE"]"
		if(hunting_system.current_target)
			status_items += "Current Target: [hunting_system.current_target]"

	if(containment_system)
		status_items += "Containment Status: [containment_system.containment_status]"

	return status_items

// Override get_status_tab_items to include SCP-106 specific information
/mob/living/scp/scp106/get_status_tab_items()
	var/list/status_items = ..()
	status_items += get_scp106_status_items()
	return status_items

// Enhanced examine for SCP-106
/mob/living/scp/scp106/examine(mob/user)
	. = ..()

	if(phasing_system)
		. += "<span class='notice'>Dimensional Energy: [phasing_system.dimensional_energy]/[phasing_system.max_dimensional_energy]</span>"

	if(pocket_dimension_system)
		. += "<span class='notice'>Active Dimensions: [length(pocket_dimension_system.active_dimensions)]</span>"

	if(containment_system && containment_system.containment_status == "breached")
		. += "<span class='danger'>This SCP-106 has breached containment!</span>"

// Research contribution
/mob/living/scp/scp106/proc/contribute_research_data()
	var/research_data = list(
		"scp_type" = "SCP-106",
		"dimensional_energy" = phasing_system?.dimensional_energy || 0,
		"active_dimensions" = length(pocket_dimension_system?.active_dimensions) || 0,
		"corrosion_potency" = corrosion_system?.corrosion_potency || 0,
		"containment_status" = containment_system?.containment_status || "unknown",
		"timestamp" = world.time
	)

	research_integration?.research_data["last_update"] = research_data

// Progression Integration Hooks
/mob/living/scp/scp106/proc/on_breach()
	hook_scp_breach("SCP-106", src)

/mob/living/scp/scp106/proc/on_pocket_capture(mob/living/carbon/human/victim)
	if(victim && victim.ckey)
		hook_scp_interaction(victim, "SCP-106", INTERACTION_TYPE_CONTAINMENT, list("captured" = TRUE))
		start_scp_survival_tracking(victim, "SCP-106", INTERACTION_RISK_CRITICAL)

/mob/living/scp/scp106/proc/on_pocket_escape(mob/living/carbon/human/escapee)
	if(escapee && escapee.ckey)
		stop_scp_survival_tracking(escapee, "SCP-106")
		hook_scp_interaction(escapee, "SCP-106", INTERACTION_TYPE_SURVIVAL, list("escaped" = TRUE))

/mob/living/scp/scp106/proc/on_corrosion_use(mob/living/carbon/human/target)
	if(target && target.ckey)
		hook_scp_combat(target, "SCP-106", corrosion_system?.corrosion_potency || 0, 0)
