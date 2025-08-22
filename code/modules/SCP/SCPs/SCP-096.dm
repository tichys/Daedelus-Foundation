// SCP-096 - The Shy Guy
// Becomes aggressive when its face is seen

/mob/living/carbon/human/scp096
	name = "SCP-096"
	desc = "A tall, thin humanoid figure with pale skin and long arms. It appears to be covering its face."
	icon = 'icons/scp/scp-096.dmi'
	icon_state = "scp096"
	real_name = "SCP-096"
	// use_custom_sprite = TRUE // This will be handled by the component system

	// SCP-096 specific variables
	var/state = "idle" // idle, screaming, chasing, slaughter
	var/mob/living/current_target = null
	var/scream_cooldown = 0
	var/scream_cooldown_time = 30 SECONDS
	var/rage_duration = 0
	var/rage_duration_time = 5 MINUTES
	var/rage_level = 0
	var/max_rage_level = 100

	// Enhanced rage system
	var/rage_multiplier = 1.0
	var/rage_decay_rate = 0.1
	var/rage_escalation_bonus = 0
	var/face_revelation_cooldown = 0
	var/face_revelation_cooldown_time = 60 SECONDS

	// Advanced abilities
	var/scream_range = 5
	var/scream_damage = 15
	var/rage_boost_duration = 0
	var/rage_boost_duration_time = 2 MINUTES
	var/hysteria_radius = 7
	var/hysteria_duration = 0
	var/hysteria_duration_time = 3 MINUTES

	// Announcement system
	var/announcement_cooldown = 0
	var/announcement_cooldown_time = 120 SECONDS
	var/last_announcement = 0
	var/list/announcement_messages = list(
		"*whimpers softly*",
		"*covers face with hands*",
		"*shakes violently*",
		"*mumbles incoherently*",
		"*tries to hide in shadows*"
	)

	// Persistence tracking
	var/kills_count = 0
	var/rage_activations = 0
	var/last_rage_time = 0
	var/face_revelations = 0
	var/scream_attacks = 0
	var/hysteria_events = 0
	var/total_damage_dealt = 0
	var/targets_eliminated = 0
	var/rage_escalations = 0

/mob/living/carbon/human/scp096/Initialize()
	. = ..()
	
	// Set species properly
	set_species(/datum/species/scp096)

	// Create SCP datum and enable advanced component system
	SCP = new /datum/scp(src, "Shy Guy", SCP_KETER, "096", SCP_SENTIENT)
	SCP.uses_advanced_components = TRUE
	SCP.compInit_advanced() // Use the extended initialization

	// Initialize SCP-096 specific skills through component system
	initialize_scp_096_skills()

	// Enable vision cone for SCP-096
	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()

	// Load persistence data
	load_persistence_data()

/mob/living/carbon/human/scp096/proc/initialize_scp_096_skills()
	// Get the skill system component
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(skill_system)
		skill_system.add_skill("Face Revelation", 120 SECONDS, list("requires_breach"))
		skill_system.add_skill("Rage Manipulation", 90 SECONDS, list("requires_rage"))
		skill_system.add_skill("Scream Attack", 60 SECONDS, list("requires_target"))
		skill_system.add_skill("Rage Escalation", 180 SECONDS, list("requires_power"))
		skill_system.add_skill("Mass Hysteria", 360 SECONDS, list("requires_breach"))
		skill_system.add_skill("Rage Boost", 240 SECONDS, list("requires_rage"))
		skill_system.add_skill("Terrifying Presence", 300 SECONDS, list("requires_power"))

// Enhanced SCP-096 specific ability procs
/mob/living/carbon/human/scp096/proc/face_revelation()
	if(world.time < face_revelation_cooldown)
		to_chat(src, "<span class='warning'>You need time to recover from the last revelation...</span>")
		return FALSE

	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Face Revelation"))
		return FALSE

	face_revelation_cooldown = world.time + face_revelation_cooldown_time
	face_revelations++
	rage_level = min(max_rage_level, rage_level + 20 + rage_escalation_bonus)
	rage_escalation_bonus += 5

	// Enhanced visual and audio effects
	playsound(src, 'sound/effects/ghost.ogg', 50, 0)
	visible_message("<span class='danger'>[src] reveals their face in a moment of pure terror!</span>")

	// Announce to nearby players
	for(var/mob/living/carbon/human/H in range(7, src))
		if(H != src)
			to_chat(H, "<span class='danger'>You catch a glimpse of something that fills you with primal fear...</span>")

	to_chat(src, "<span class='danger'>Your face has been revealed! Rage Level: [rage_level]/[max_rage_level]</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp096/proc/rage_manipulation()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Rage Manipulation"))
		return FALSE

	rage_level = min(max_rage_level, rage_level + 10)
	rage_activations++
	rage_multiplier += 0.1

	// Enhanced rage effects
	if(rage_level > 50)
		rage_boost_duration = world.time + rage_boost_duration_time

	to_chat(src, "<span class='danger'>You manipulate your rage! Rage Level: [rage_level]/[max_rage_level], Multiplier: [round(rage_multiplier, 0.1)]x</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp096/proc/scream_attack(mob/target)
	if(world.time < scream_cooldown)
		to_chat(src, "<span class='warning'>Your vocal cords need time to recover...</span>")
		return FALSE

	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Scream Attack"))
		return FALSE

	if(!target)
		to_chat(src, "<span class='warning'>You need a target to scream at.</span>")
		return FALSE

	scream_cooldown = world.time + scream_cooldown_time
	scream_attacks++
	rage_level = min(max_rage_level, rage_level + 15)

	// Enhanced scream mechanics
	var/damage = scream_damage * rage_multiplier
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustBruteLoss(damage)
		H.stamina.adjust(-damage * 2)
		total_damage_dealt += damage

		// Chance to cause fear effects
		if(prob(30))
			H.stamina.adjust(-20)
			to_chat(H, "<span class='danger'>The scream fills you with overwhelming terror!</span>")

	// Audio and visual effects
	playsound(src, 'sound/effects/ghost2.ogg', 70, 0)
	visible_message("<span class='danger'>[src] lets out a blood-curdling scream at [target]!</span>")

	to_chat(src, "<span class='danger'>You scream at [target]! Scream Attacks: [scream_attacks], Damage Dealt: [total_damage_dealt]</span>")
	to_chat(target, "<span class='danger'>You hear a terrifying scream that shakes your very soul!</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp096/proc/rage_escalation()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Rage Escalation"))
		return FALSE

	rage_level = min(max_rage_level, rage_level + 25)
	rage_activations++
	rage_escalations++
	rage_multiplier += 0.2
	rage_escalation_bonus += 10

	// Enhanced escalation effects
	rage_boost_duration = world.time + rage_boost_duration_time
	scream_damage += 5
	scream_range += 1

	to_chat(src, "<span class='danger'>Your rage escalates to new heights! Rage Level: [rage_level]/[max_rage_level], Multiplier: [round(rage_multiplier, 0.1)]x</span>")

	// Announce to nearby players
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H != src)
			to_chat(H, "<span class='danger'>You feel an overwhelming sense of dread as something nearby becomes enraged...</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp096/proc/mass_hysteria()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Mass Hysteria"))
		return FALSE

	hysteria_events++
	hysteria_duration = world.time + hysteria_duration_time

	// Enhanced hysteria effects
	for(var/mob/living/carbon/human/H in range(hysteria_radius, src))
		if(H != src)
			H.stamina.adjust(-30)
			H.adjustBruteLoss(10)
			to_chat(H, "<span class='danger'>Mass hysteria grips the area! You feel overwhelming fear!</span>")

			// Chance to cause panic
			if(prob(40))
				H.stamina.adjust(-20)
				to_chat(H, "<span class='danger'>You panic and lose control!</span>")

	playsound(src, 'sound/effects/ghost.ogg', 80, 0)
	visible_message("<span class='danger'>[src] causes mass hysteria in the area!</span>")
	to_chat(src, "<span class='danger'>You cause mass hysteria! Hysteria Events: [hysteria_events]</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp096/proc/rage_boost()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Rage Boost"))
		return FALSE

	rage_boost_duration = world.time + rage_boost_duration_time
	rage_multiplier += 0.3
	scream_damage += 10
	rage_level = min(max_rage_level, rage_level + 30)

	to_chat(src, "<span class='danger'>You enter a rage boost! Multiplier: [round(rage_multiplier, 0.1)]x, Duration: [rage_boost_duration_time/600] minutes</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp096/proc/terrifying_presence()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Terrifying Presence"))
		return FALSE

	// Enhanced presence effects
	for(var/mob/living/carbon/human/H in range(8, src))
		if(H != src)
			H.stamina.adjust(-25)
			to_chat(H, "<span class='danger'>You feel an overwhelming sense of dread and terror!</span>")

			// Chance to cause fear-based effects
			if(prob(25))
				H.stamina.adjust(-15)
				to_chat(H, "<span class='danger'>The presence is so terrifying you can barely move!</span>")

	to_chat(src, "<span class='danger'>You project a terrifying presence!</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp096/proc/announce_presence()
	if(world.time < last_announcement + announcement_cooldown)
		return

	last_announcement = world.time
	var/announcement = pick(announcement_messages)

	// Play audio
	playsound(src, 'sound/effects/ghost.ogg', 30, 0)

	// Send announcement
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.z == z)
			to_chat(H, "<span class='danger'>[announcement]</span>")

// Enhanced life cycle integration
/mob/living/carbon/human/scp096/Life()
	. = ..()

	// Update component system
	if(SCP && SCP.uses_advanced_components)
		SCP.update_components()

	// Enhanced rage effects with decay
	if(rage_level > 0)
		rage_level = max(0, rage_level - rage_decay_rate) // Gradual rage decay

		if(rage_level > 70)
			state = "slaughter"
		else if(rage_level > 50)
			state = "chasing"
		else if(rage_level > 20)
			state = "screaming"
		else
			state = "idle"

	// Enhanced abilities in rage state
	if(state == "chasing" || state == "slaughter")
		for(var/mob/living/carbon/human/H in range(3, src))
			if(H.stat != DEAD)
				var/damage = rage_level * 0.1 * rage_multiplier
				H.adjustBruteLoss(damage)
				total_damage_dealt += damage

	// Rage boost effects
	if(world.time < rage_boost_duration)
		rage_multiplier = min(3.0, rage_multiplier) // Cap at 3x
	else
		rage_multiplier = max(1.0, rage_multiplier - 0.01) // Gradual decay

	// Random announcements
	if(prob(2) && world.time > last_announcement + announcement_cooldown)
		announce_presence()

// Persistence system
/mob/living/carbon/human/scp096/proc/save_persistence_data()
	var/datum/scp_advanced_component/advanced_persistence_system/persistence = SCP.get_component("persistence_system")
	if(persistence)
		var/list/data = list(
			"kills_count" = kills_count,
			"rage_activations" = rage_activations,
			"last_rage_time" = last_rage_time,
			"face_revelations" = face_revelations,
			"scream_attacks" = scream_attacks,
			"hysteria_events" = hysteria_events,
			"total_damage_dealt" = total_damage_dealt,
			"targets_eliminated" = targets_eliminated,
			"rage_escalations" = rage_escalations,
			"rage_multiplier" = rage_multiplier,
			"rage_escalation_bonus" = rage_escalation_bonus,
			"scream_damage" = scream_damage,
			"scream_range" = scream_range
		)
		persistence.save_data("scp096_stats", data)

/mob/living/carbon/human/scp096/proc/load_persistence_data()
	var/datum/scp_advanced_component/advanced_persistence_system/persistence = SCP.get_component("persistence_system")
	if(persistence)
		var/list/data = persistence.load_data("scp096_stats")
		if(data)
			kills_count = data["kills_count"] || 0
			rage_activations = data["rage_activations"] || 0
			last_rage_time = data["last_rage_time"] || 0
			face_revelations = data["face_revelations"] || 0
			scream_attacks = data["scream_attacks"] || 0
			hysteria_events = data["hysteria_events"] || 0
			total_damage_dealt = data["total_damage_dealt"] || 0
			targets_eliminated = data["targets_eliminated"] || 0
			rage_escalations = data["rage_escalations"] || 0
			rage_multiplier = data["rage_multiplier"] || 1.0
			rage_escalation_bonus = data["rage_escalation_bonus"] || 0
			scream_damage = data["scream_damage"] || 15
			scream_range = data["scream_range"] || 5

// Enhanced verb definitions for SCP-096 abilities
/mob/living/carbon/human/scp096/verb/face_revelation_verb()
	set name = "Face Revelation"
	set category = "SCP-096"
	set desc = "Reveal your face to trigger rage"

	face_revelation()

/mob/living/carbon/human/scp096/verb/rage_manipulation_verb()
	set name = "Rage Manipulation"
	set category = "SCP-096"
	set desc = "Manipulate your rage"

	rage_manipulation()

/mob/living/carbon/human/scp096/verb/scream_attack_verb()
	set name = "Scream Attack"
	set category = "SCP-096"
	set desc = "Scream at a target"

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(scream_range, src))
		targets += H

	if(targets.len == 0)
		to_chat(src, "<span class='warning'>No targets in range.</span>")
		return

	var/mob/target = input(src, "Select target to scream at:", "Scream Attack") as null|anything in targets
	if(target)
		scream_attack(target)

/mob/living/carbon/human/scp096/verb/rage_escalation_verb()
	set name = "Rage Escalation"
	set category = "SCP-096"
	set desc = "Escalate your rage"

	rage_escalation()

/mob/living/carbon/human/scp096/verb/mass_hysteria_verb()
	set name = "Mass Hysteria"
	set category = "SCP-096"
	set desc = "Cause mass hysteria"

	mass_hysteria()

/mob/living/carbon/human/scp096/verb/rage_boost_verb()
	set name = "Rage Boost"
	set category = "SCP-096"
	set desc = "Activate rage boost"

	rage_boost()

/mob/living/carbon/human/scp096/verb/terrifying_presence_verb()
	set name = "Terrifying Presence"
	set category = "SCP-096"
	set desc = "Project terrifying presence"

	terrifying_presence()

// Enhanced status display
/mob/living/carbon/human/scp096/proc/get_scp_status()
	var/list/status = list()
	status += "=== SCP-096 Status ==="
	status += "State: [state]"
	status += "Rage Level: [rage_level]/[max_rage_level]"
	status += "Rage Multiplier: [round(rage_multiplier, 0.1)]x"
	status += "Current Target: [current_target ? current_target.name : "None"]"
	status += "Scream Damage: [scream_damage]"
	status += "Scream Range: [scream_range]"
	status += "=== Statistics ==="
	status += "Kills Count: [kills_count]"
	status += "Rage Activations: [rage_activations]"
	status += "Face Revelations: [face_revelations]"
	status += "Scream Attacks: [scream_attacks]"
	status += "Hysteria Events: [hysteria_events]"
	status += "Total Damage Dealt: [total_damage_dealt]"
	status += "Targets Eliminated: [targets_eliminated]"
	status += "Rage Escalations: [rage_escalations]"

	// Add component status if using advanced system
	if(SCP && SCP.uses_advanced_components)
		var/list/component_status = SCP.get_component_status()
		status += "=== Component Status ==="
		status += component_status

	return status

/mob/living/carbon/human/scp096/verb/show_status_verb()
	set name = "Show SCP Status"
	set category = "SCP-096"
	set desc = "Display your SCP-096 status"

	var/list/status = get_scp_status()
	for(var/line in status)
		to_chat(src, "<span class='notice'>[line]</span>")
