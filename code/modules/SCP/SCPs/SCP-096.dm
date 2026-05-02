// SCP-096 - The Shy Guy
// Becomes aggressive when its face is seen

/mob/living/carbon/human/scp096
	name = "SCP-096"
	desc = "A tall, thin humanoid figure with pale skin and long arms. It appears to be covering its face."
	icon = 'icons/scp/scp-096.dmi'
	icon_state = "scp096"
	real_name = "SCP-096"

	// SCP-096 specific variables
	var/state = "idle" // idle, screaming, chasing, slaughter
	var/mob/living/current_target = null
	var/kills_count = 0
	var/targets_eliminated = 0
	var/total_damage_dealt = 0

	// Modular systems
	var/datum/scp096_rage_system/rage_system
	var/datum/scp096_face_system/face_system
	var/datum/scp096_scream_system/scream_system
	var/datum/scp096_hysteria_system/hysteria_system
	var/datum/scp096_research_system/research_system

	// Progression integration tracking
	var/rage_activations = 0
	var/victims_hunted = 0
	var/containment_escapes = 0

/mob/living/carbon/human/scp096/Initialize()
	. = ..()

	// Set species properly
	set_species(/datum/species/scp096)

	// Initialize modular systems
	rage_system = new /datum/scp096_rage_system(src)
	face_system = new /datum/scp096_face_system(src)
	scream_system = new /datum/scp096_scream_system(src)
	hysteria_system = new /datum/scp096_hysteria_system(src)
	research_system = new /datum/scp096_research_system(src)

	// Create SCP datum
	SCP = new /datum/scp(src, "Shy Guy", SCP_KETER, "096", SCP_SENTIENT)

	// Enable vision cone for SCP-096
	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()

	// Load persistence data
	load_persistence_data()

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

// Enhanced life cycle integration
/mob/living/carbon/human/scp096/Life()
	. = ..()

	// Process all modular systems
	if(rage_system)
		rage_system.process_rage()
	if(face_system)
		face_system.process_face_revelation()
	if(scream_system)
		scream_system.process_scream()
	if(hysteria_system)
		hysteria_system.process_hysteria()
	if(research_system)
		research_system.process_research()

	// Update state based on rage level
	if(rage_system)
		if(rage_system.rage_level > 70)
			state = "slaughter"
		else if(rage_system.rage_level > 50)
			state = "chasing"
		else if(rage_system.rage_level > 20)
			state = "screaming"
		else
			state = "idle"

	// Automatic face revelation when threatened
	if(prob(1) && rage_system && rage_system.rage_level < 20)
		var/list/threats = list()
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD && H != src)
				threats += H

		if(threats.len > 0)
			face_system.reveal_face()
			rage_system.trigger_rage(15)

	// Automatic rage escalation when in combat
	if(rage_system && rage_system.rage_level > 60 && prob(5))
		rage_system.escalate_rage()

	// Automatic rage boost when heavily damaged
	if(health < maxHealth * 0.3 && rage_system && rage_system.rage_level > 40)
		rage_system.activate_rage_boost()

// Persistence system
/mob/living/carbon/human/scp096/proc/save_persistence_data()
	if(!SCP)
		return

	var/list/data = list(
		"kills_count" = kills_count,
		"targets_eliminated" = targets_eliminated,
		"total_damage_dealt" = total_damage_dealt,
		"rage_level" = rage_system ? rage_system.rage_level : 0,
		"rage_multiplier" = rage_system ? rage_system.rage_multiplier : 1.0,
		"face_revelations" = face_system ? face_system.face_revelations : 0,
		"scream_attacks" = scream_system ? scream_system.scream_attacks : 0,
		"hysteria_events" = hysteria_system ? hysteria_system.hysteria_events : 0,
		"rage_activations" = rage_system ? rage_system.rage_activations : 0,
		"rage_escalations" = rage_system ? rage_system.rage_escalations : 0
	)

	// Store data for research integration
	if(research_system)
		research_system.research_data = data

/mob/living/carbon/human/scp096/proc/load_persistence_data()
	// Load data from research system if available
	if(research_system && research_system.research_data && research_system.research_data.len > 0)
		var/list/data = research_system.research_data
		kills_count = data["kills_count"] || 0
		targets_eliminated = data["targets_eliminated"] || 0
		total_damage_dealt = data["total_damage_dealt"] || 0

		if(rage_system)
			rage_system.rage_level = data["rage_level"] || 0
			rage_system.rage_multiplier = data["rage_multiplier"] || 1.0
			rage_system.rage_activations = data["rage_activations"] || 0
			rage_system.rage_escalations = data["rage_escalations"] || 0

		if(face_system)
			face_system.face_revelations = data["face_revelations"] || 0

		if(scream_system)
			scream_system.scream_attacks = data["scream_attacks"] || 0

		if(hysteria_system)
			hysteria_system.hysteria_events = data["hysteria_events"] || 0

// Enhanced status display
/mob/living/carbon/human/scp096/proc/get_scp_status()
	var/list/status = list()
	status += "=== SCP-096 Status ==="
	status += "State: [state]"

	if(rage_system)
		status += "Rage Level: [rage_system.rage_level]/[rage_system.max_rage_level]"
		status += "Rage Multiplier: [round(rage_system.rage_multiplier, 0.1)]x"
		status += "Rage Activations: [rage_system.rage_activations]"
		status += "Rage Escalations: [rage_system.rage_escalations]"

	status += "Current Target: [current_target ? current_target.name : "None"]"

	if(face_system)
		status += "Face Revelations: [face_system.face_revelations]"

	if(scream_system)
		status += "Scream Damage: [scream_system.scream_damage]"
		status += "Scream Range: [scream_system.scream_range]"
		status += "Scream Attacks: [scream_system.scream_attacks]"

	if(hysteria_system)
		status += "Hysteria Events: [hysteria_system.hysteria_events]"

	status += "=== Statistics ==="
	status += "Kills Count: [kills_count]"
	status += "Total Damage Dealt: [total_damage_dealt]"
	status += "Targets Eliminated: [targets_eliminated]"

	return status

/mob/living/carbon/human/scp096/verb/show_status_verb()
	set name = "Show SCP Status"
	set category = "SCP-096"
	set desc = "Display your SCP-096 status"

	var/list/status = get_scp_status()
	for(var/line in status)
		to_chat(src, "<span class='notice'>[line]</span>")

// Override death to save persistence data
/mob/living/carbon/human/scp096/death(gibbed)
	save_persistence_data()
	hook_scp_recontainment("SCP-096", list())
	. = ..()

/mob/living/carbon/human/scp096/proc/on_rage_trigger(trigger_source)
	rage_activations++
	hook_scp_breach("SCP-096", src)
	if(current_target && ishuman(current_target))
		var/mob/living/carbon/human/H = current_target
		hook_scp_combat(H, "SCP-096", 0, 0)

/mob/living/carbon/human/scp096/proc/on_face_view(mob/living/carbon/human/viewer)
	if(!viewer || viewer == src)
		return
	hook_scp_interaction(viewer, "SCP-096", INTERACTION_TYPE_OBSERVATION)
	hook_scp_observation(viewer, "SCP-096")

/mob/living/carbon/human/scp096/proc/on_target_kill(mob/living/carbon/human/victim)
	if(!victim)
		return
	kills_count++
	victims_hunted++
	hook_scp_combat(victim, "SCP-096", 100, 0)
	hook_player_death_near_scp(victim, "SCP-096")

/mob/living/carbon/human/scp096/proc/on_containment_escape()
	containment_escapes++
	hook_scp_breach("SCP-096", src)

// Override logout to save persistence data
/mob/living/carbon/human/scp096/Logout()
	save_persistence_data()
	. = ..()
