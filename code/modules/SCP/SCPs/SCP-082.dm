// SCP-082 - Fernand the Cannibal
// A massive, aggressive humanoid with enhanced strength, regeneration, and cannibalistic tendencies

/mob/living/carbon/human/scp082
	name = "SCP-082"
	desc = "A massive, muscular humanoid with aggressive tendencies and cannibalistic behavior. It towers over most beings."
	icon = 'icons/scp/scp-082.dmi'
	icon_state = "humanoid"
	real_name = "SCP-082"
	status_flags = 0

	// Core system datums
	var/datum/scp082_rage_system/rage_system
	var/datum/scp082_consumption_system/consumption_system
	var/datum/scp082_strength_system/strength_system
	var/datum/scp082_terror_system/terror_system
	var/datum/scp082_enhancement_system/enhancement_system
	var/datum/scp082_research_integration/research_integration

	// Persistence tracking
	var/rage_activations = 0
	var/regenerations = 0
	var/meals_consumed = 0
	var/strength_uses = 0
	var/total_damage_dealt = 0
	var/targets_consumed = 0
	var/rage_escalations = 0
	var/strength_boosts = 0

/mob/living/carbon/human/scp082/Initialize()
	. = ..()
	set_species(/datum/species/scp082)
	SCP = new /datum/scp(src, "cannibalistic humanoid", SCP_KETER, "082", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	// Initialize core systems after a short delay to ensure proper initialization
	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

	// Grant language and register for SCP persistence
	grant_language(/datum/language/common, TRUE, TRUE)

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-082"] = new /datum/scp_instance("SCP-082", src)

	// Start processing
	START_PROCESSING(SSobj, src)

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

/mob/living/carbon/human/scp082/proc/initialize_systems()
	rage_system = new /datum/scp082_rage_system(src)
	consumption_system = new /datum/scp082_consumption_system(src)
	strength_system = new /datum/scp082_strength_system(src)
	terror_system = new /datum/scp082_terror_system(src)
	enhancement_system = new /datum/scp082_enhancement_system(src)
	research_integration = new /datum/scp082_research_integration(src)

	// Set up human-specific properties for SCP-082
	maxHealth = 400 // Enhanced health for SCP-082
	health = maxHealth

	// Initialize vision cone
	fovangle = 120 // Wider vision than normal
	update_fov_angles()
	update_cone_show()

/mob/living/carbon/human/scp082/process()
	. = ..()

	// Update all systems
	rage_system?.process_rage()
	consumption_system?.process_consumption()
	strength_system?.process_strength()
	terror_system?.process_terror()
	enhancement_system?.process_enhancement()
	research_integration?.process_research()

// SCP-082 Status Display
/mob/living/carbon/human/scp082/proc/get_scp082_status_items()
	var/list/status_items = list()

	// Rage system status
	if(rage_system)
		status_items += "Rage Level: [rage_system.rage_level]/[rage_system.max_rage_level]"
		status_items += "Combat Efficiency: [rage_system.combat_efficiency]x"
		status_items += "Berserk Mode: [rage_system.berserk_mode ? "ACTIVE" : "INACTIVE"]"
		status_items += "Intimidation Radius: [rage_system.intimidation_radius]"

	// Consumption system status
	if(consumption_system)
		status_items += "Hunger Level: [consumption_system.hunger_level]/[consumption_system.max_hunger_level]"
		status_items += "Satiation Level: [consumption_system.satiation_level]/[consumption_system.max_satiation_level]"
		status_items += "Consumption Efficiency: [consumption_system.consumption_efficiency]x"
		if(consumption_system.feeding_in_progress)
			status_items += "Currently Feeding: [consumption_system.feeding_target]"

	// Strength system status
	if(strength_system)
		status_items += "Current Strength: [strength_system.current_strength]/[strength_system.max_strength]"
		status_items += "Lifting Capacity: [strength_system.lifting_capacity] kg"
		status_items += "Destructive Force: [strength_system.destructive_force]"
		status_items += "Grappling Power: [strength_system.grappling_power]"

	// Terror system status
	if(terror_system)
		status_items += "Intimidation Level: [terror_system.intimidation_level]/[terror_system.max_intimidation_level]"
		status_items += "Terror Intensity: [terror_system.terror_intensity]/[terror_system.max_terror_intensity]"
		status_items += "Presence Radius: [terror_system.presence_radius]"

	// Enhancement system status
	if(enhancement_system)
		status_items += "Regeneration Rate: [enhancement_system.regeneration_rate]/[enhancement_system.max_regeneration_rate]"
		status_items += "Adaptation Level: [enhancement_system.adaptation_level]/[enhancement_system.max_adaptation_level]"
		status_items += "Physical Growth: [enhancement_system.physical_growth]/[enhancement_system.max_physical_growth]"
		status_items += "Metabolic Efficiency: [enhancement_system.metabolic_efficiency]x"

	return status_items

// Override get_status_tab_items to include SCP-082 specific information
/mob/living/carbon/human/scp082/get_status_tab_items()
	var/list/status_items = ..()
	status_items += get_scp082_status_items()
	return status_items

// Enhanced examine for SCP-082
/mob/living/carbon/human/scp082/examine(mob/user)
	. = ..()

	if(rage_system)
		. += "<span class='notice'>Rage Level: [rage_system.rage_level]/[rage_system.max_rage_level]</span>"
		if(rage_system.berserk_mode)
			. += "<span class='danger'>This entity is in a berserk rage!</span>"

	if(consumption_system)
		. += "<span class='notice'>Hunger Level: [consumption_system.hunger_level]/[consumption_system.max_hunger_level]</span>"
		if(consumption_system.hunger_level > 70)
			. += "<span class='warning'>This entity appears extremely hungry!</span>"

	if(strength_system)
		. += "<span class='notice'>Physical Strength: [strength_system.current_strength]</span>"

	if(enhancement_system && enhancement_system.physical_growth > 0)
		. += "<span class='notice'>This entity appears larger than normal humans.</span>"

// Research contribution
/mob/living/carbon/human/scp082/proc/contribute_research_data()
	var/research_data = list(
		"scp_type" = "SCP-082",
		"rage_level" = rage_system?.rage_level || 0,
		"berserk_mode" = rage_system?.berserk_mode || FALSE,
		"hunger_level" = consumption_system?.hunger_level || 0,
		"satiation_level" = consumption_system?.satiation_level || 0,
		"current_strength" = strength_system?.current_strength || 0,
		"intimidation_level" = terror_system?.intimidation_level || 0,
		"adaptation_level" = enhancement_system?.adaptation_level || 0,
		"physical_growth" = enhancement_system?.physical_growth || 0,
		"regeneration_rate" = enhancement_system?.regeneration_rate || 0,
		"timestamp" = world.time
	)

	research_integration?.research_data["last_update"] = research_data

// Enhanced attack for SCP-082
/mob/living/carbon/human/scp082/attack_hand(mob/living/carbon/human/target)
	// Check if this is a consumption attempt
	if(consumption_system && consumption_system.attempt_consumption(target))
		meals_consumed++
		targets_consumed++
		return

	// Check if this is a strength-enhanced attack
	if(strength_system && rage_system)
		var/damage_multiplier = rage_system.channel_rage_for_attack()
		if(damage_multiplier > 1.0)
			var/enhanced_damage = 20 * damage_multiplier
			target.adjustBruteLoss(enhanced_damage)
			total_damage_dealt += enhanced_damage

			target.visible_message("<span class='danger'>[src] strikes [target] with enhanced strength!</span>")
			playsound(src, 'sound/effects/phasein.ogg', 50, 0)

			// Apply fear to target
			if(terror_system && target.sanity)
				target.sanity.adjust_sanity(-10, "scp082_attack")

			return

	// Default attack
	. = ..()

/mob/living/carbon/human/scp082/proc/on_rage_activation()
	rage_activations++
	hook_scp_breach("SCP-082", src)

/mob/living/carbon/human/scp082/proc/on_consumption(mob/living/carbon/human/victim)
	if(!victim)
		return
	meals_consumed++
	targets_consumed++
	hook_scp_combat(victim, "SCP-082", 100, 0)
	hook_player_death_near_scp(victim, "SCP-082")

/mob/living/carbon/human/scp082/proc/on_regeneration()
	regenerations++
	hook_scp_damage("SCP-082", (health / maxHealth) * 100)
