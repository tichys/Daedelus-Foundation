

/mob/living/carbon/human/scp2020
	name = "Green humanoid"
	desc = "A strange Green humanoid with an otherworldly presence."
	status_flags = 0

	// Modular systems
	var/datum/scp2020_teleportation_system/teleportation_system
	var/datum/scp2020_phasing_system/phasing_system
	var/datum/scp2020_stealth_system/stealth_system
	var/datum/scp2020_hunting_system/hunting_system
	var/datum/scp2020_research_system/research_system

	// Basic tracking variables
	var/total_encounters = 0
	var/people_observed = 0
	var/activation_events = 0

/mob/living/carbon/human/scp2020/Initialize(mapload, new_species = "SCP-2020")
	. = ..()
	set_species(/datum/species/scp2020)
	SCP = new /datum/scp(src, "dimensional entity", SCP_KETER, "2020", SCP_PLAYABLE|SCP_ROLEPLAY)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	// Initialize core systems
	teleportation_system = new /datum/scp2020_teleportation_system(src)
	phasing_system = new /datum/scp2020_phasing_system(src)
	stealth_system = new /datum/scp2020_stealth_system(src)
	hunting_system = new /datum/scp2020_hunting_system(src)
	research_system = new /datum/scp2020_research_system(src)

	// Grant language and register for SCP persistence
	grant_language(/datum/language/common, TRUE, TRUE)

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-2020"] = new /datum/scp_instance("SCP-2020", src)

	// Start processing
	START_PROCESSING(SSobj, src)

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

	// Load persistence data
	load_persistence_data()

// Player-controlled abilities
/mob/living/carbon/human/scp2020/verb/teleport_to_target()
	set name = "Teleport to Target"
	set desc = "Teleport to a visible target"
	set category = "SCP-2020"

	if(!teleportation_system)
		to_chat(src, "<span class='warning'>Teleportation system not available.</span>")
		return

	if(teleportation_system.teleport_cooldown > world.time)
		to_chat(src, "<span class='warning'>Teleportation is still recharging...</span>")
		return

	var/list/targets = list()
	for(var/mob/living/L in view(teleportation_system.teleport_range, src))
		if(L != src && L.stat != DEAD)
			targets += L

	if(!targets.len)
		to_chat(src, "<span class='warning'>No valid targets in range.</span>")
		return

	var/mob/living/target = input(src, "Choose target to teleport to:", "Teleport") as null|anything in targets
	if(!target || target.stat == DEAD)
		return

	teleportation_system.perform_teleport(get_turf(target), "player_controlled")
	to_chat(src, "<span class='notice'>You teleport to [target].</span>")

/mob/living/carbon/human/scp2020/verb/phase_through_walls()
	set name = "Phase Through Walls"
	set desc = "Phase through walls in the direction you're facing"
	set category = "SCP-2020"

	if(!phasing_system)
		to_chat(src, "<span class='warning'>Phasing system not available.</span>")
		return

	if(phasing_system.phasing_cooldown > world.time)
		to_chat(src, "<span class='warning'>Phasing is still recharging...</span>")
		return

	var/turf/T = get_step(src, dir)
	if(!T)
		to_chat(src, "<span class='warning'>Cannot phase in that direction.</span>")
		return

	if(T.density)
		phasing_system.perform_phase(T)
		to_chat(src, "<span class='notice'>You phase through the wall.</span>")
	else
		to_chat(src, "<span class='warning'>There's no wall to phase through.</span>")

/mob/living/carbon/human/scp2020/verb/activate_stealth()
	set name = "Activate Stealth"
	set desc = "Activate stealth mode to become harder to detect"
	set category = "SCP-2020"

	if(!stealth_system)
		to_chat(src, "<span class='warning'>Stealth system not available.</span>")
		return

	if(stealth_system.stealth_cooldown > world.time)
		to_chat(src, "<span class='warning'>Stealth is still recharging...</span>")
		return

	stealth_system.activate_stealth()
	to_chat(src, "<span class='notice'>You activate stealth mode.</span>")

/mob/living/carbon/human/scp2020/verb/select_hunting_target()
	set name = "Select Hunting Target"
	set desc = "Choose a target to focus your attention on"
	set category = "SCP-2020"

	if(!hunting_system)
		to_chat(src, "<span class='warning'>Hunting system not available.</span>")
		return

	var/list/potential_targets = list()
	for(var/mob/living/carbon/human/H in range(10, src))
		if(H.stat != DEAD && H != src)
			potential_targets += H

	if(!potential_targets.len)
		to_chat(src, "<span class='warning'>No valid targets in range.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose target to hunt:", "Hunting") as null|anything in potential_targets
	if(!target || target.stat == DEAD)
		return

	hunting_system.current_target = target
	hunting_system.hunting_intensity = min(hunting_system.max_hunting_intensity, hunting_system.hunting_intensity + 10)
	to_chat(src, "<span class='notice'>You focus your attention on [target].</span>")
	to_chat(target, "<span class='danger'>The green humanoid seems to focus its attention on you...</span>")

/mob/living/carbon/human/scp2020/verb/check_abilities_status()
	set name = "Check Abilities Status"
	set desc = "Check the status of your supernatural abilities"
	set category = "SCP-2020"

	var/list/status = list()
	status += "=== SCP-2020 Abilities Status ==="

	if(teleportation_system)
		var/cooldown_remaining = max(0, (teleportation_system.teleport_cooldown - world.time) / 10)
		status += "Teleportation: [cooldown_remaining > 0 ? "Recharging ([cooldown_remaining]s)" : "Ready"]"
		status += "Range: [teleportation_system.teleport_range] tiles"
		status += "Mastery: [teleportation_system.teleport_mastery]/[teleportation_system.max_teleport_mastery]"

	if(phasing_system)
		var/cooldown_remaining = max(0, (phasing_system.phasing_cooldown - world.time) / 10)
		status += "Phasing: [cooldown_remaining > 0 ? "Recharging ([cooldown_remaining]s)" : "Ready"]"
		status += "Mastery: [phasing_system.phasing_mastery]/[phasing_system.max_phasing_mastery]"

	if(stealth_system)
		var/cooldown_remaining = max(0, (stealth_system.stealth_cooldown - world.time) / 10)
		status += "Stealth: [cooldown_remaining > 0 ? "Recharging ([cooldown_remaining]s)" : "Ready"]"
		status += "Level: [stealth_system.stealth_level]/[stealth_system.max_stealth_level]"

	if(hunting_system)
		status += "Hunting Target: [hunting_system.current_target ? "[hunting_system.current_target]" : "None"]"
		status += "Intensity: [hunting_system.hunting_intensity]/[hunting_system.max_hunting_intensity]"

	for(var/line in status)
		to_chat(src, "<span class='notice'>[line]</span>")

// Core automated processing - minimal for player control
/mob/living/carbon/human/scp2020/Life()
	. = ..()

	// Only process research system automatically
	if(research_system)
		research_system.process_research()

	// Update tracking data
	update_tracking_data()

	// Apply passive effects from active systems
	apply_passive_effects()

/mob/living/carbon/human/scp2020/proc/update_tracking_data()
	// Count current nearby people
	var/current_people = 0
	for(var/mob/living/carbon/human/H in range(8, src))
		if(H.stat != DEAD && H != src)
			current_people++

	if(current_people > 0)
		activation_events++
		people_observed += current_people

/mob/living/carbon/human/scp2020/proc/apply_passive_effects()
	// Apply passive effects from active systems
	if(stealth_system && stealth_system.stealth_level > 10)
		stealth_system.apply_stealth_effects()

	// Apply hunting system effects if target is set
	if(hunting_system && hunting_system.current_target)
		var/mob/living/carbon/human/target = hunting_system.current_target
		if(target.stat == DEAD || get_dist(src, target) > 15)
			hunting_system.current_target = null
			to_chat(src, "<span class='notice'>You lose focus on your target.</span>")
		else if(get_dist(src, target) <= 3)
			// Close enough to interact
			to_chat(target, "<span class='danger'>The green humanoid studies you intently...</span>")

// Status display for admin/research purposes
/mob/living/carbon/human/scp2020/proc/get_scp_status()
	var/list/status = list()
	status += "=== SCP-2020 Status ==="

	if(teleportation_system)
		status += "Teleport Range: [teleportation_system.teleport_range]/[teleportation_system.max_teleport_range]"
		status += "Teleport Mastery: [teleportation_system.teleport_mastery]/[teleportation_system.max_teleport_mastery]"
		status += "Teleport Events: [teleportation_system.teleport_events]"

	if(phasing_system)
		status += "Phasing Mastery: [phasing_system.phasing_mastery]/[phasing_system.max_phasing_mastery]"
		status += "Phasing Events: [phasing_system.phasing_events]"

	if(stealth_system)
		status += "Stealth Level: [stealth_system.stealth_level]/[stealth_system.max_stealth_level]"
		status += "Stealth Events: [stealth_system.stealth_events]"

	if(hunting_system)
		status += "Hunting Intensity: [hunting_system.hunting_intensity]/[hunting_system.max_hunting_intensity]"
		status += "Current Target: [hunting_system.current_target ? hunting_system.current_target : "None"]"
		status += "Hunting Events: [hunting_system.hunting_events]"

	status += "=== Statistics ==="
	status += "Total Encounters: [total_encounters]"
	status += "People Observed: [people_observed]"
	status += "Activation Events: [activation_events]"

	return status

// Persistence system
/mob/living/carbon/human/scp2020/proc/save_persistence_data()
	if(!SCP)
		return

	var/list/data = list(
		"total_encounters" = total_encounters,
		"people_observed" = people_observed,
		"activation_events" = activation_events,
		"teleport_range" = teleportation_system ? teleportation_system.teleport_range : 7,
		"teleport_mastery" = teleportation_system ? teleportation_system.teleport_mastery : 0,
		"phasing_mastery" = phasing_system ? phasing_system.phasing_mastery : 0,
		"stealth_level" = stealth_system ? stealth_system.stealth_level : 0,
		"hunting_intensity" = hunting_system ? hunting_system.hunting_intensity : 0,
		"teleport_events" = teleportation_system ? teleportation_system.teleport_events : 0,
		"phasing_events" = phasing_system ? phasing_system.phasing_events : 0,
		"stealth_events" = stealth_system ? stealth_system.stealth_events : 0,
		"hunting_events" = hunting_system ? hunting_system.hunting_events : 0
	)

	// Store data for research integration
	if(research_system)
		research_system.research_data = data

/mob/living/carbon/human/scp2020/proc/load_persistence_data()
	// Load data from research system if available
	if(research_system && research_system.research_data && research_system.research_data.len > 0)
		var/list/data = research_system.research_data
		total_encounters = data["total_encounters"] || 0
		people_observed = data["people_observed"] || 0
		activation_events = data["activation_events"] || 0

		if(teleportation_system)
			teleportation_system.teleport_range = data["teleport_range"] || 7
			teleportation_system.teleport_mastery = data["teleport_mastery"] || 0
			teleportation_system.teleport_events = data["teleport_events"] || 0

		if(phasing_system)
			phasing_system.phasing_mastery = data["phasing_mastery"] || 0
			phasing_system.phasing_events = data["phasing_events"] || 0

		if(stealth_system)
			stealth_system.stealth_level = data["stealth_level"] || 0
			stealth_system.stealth_events = data["stealth_events"] || 0

		if(hunting_system)
			hunting_system.hunting_intensity = data["hunting_intensity"] || 0
			hunting_system.hunting_events = data["hunting_events"] || 0

/mob/living/carbon/human/scp2020/death()
	save_persistence_data()
	return ..()

/mob/living/carbon/human/scp2020/Logout()
	save_persistence_data()
	return ..()

/mob/living/carbon/human/scp2020/examine(mob/living/user)
	. = ..()
	to_chat(user, "<span class='notice'>This being seems to have supernatural abilities and an otherworldly intelligence.</span>")
