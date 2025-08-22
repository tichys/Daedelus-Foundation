// SCP-966 - Sleep Killer
// An invisible creature that causes sleep deprivation

/mob/living/carbon/human/scp966
	name = "SCP-966"
	desc = "An invisible creature that causes sleep deprivation."
	icon = 'icons/scp/scp-966.dmi'
	icon_state = "scp966"
	real_name = "SCP-966"
	// use_custom_sprite = TRUE // This will be handled by the component system

	// Maximum Enhanced SCP-966 variables
	var/list/sleep_affected_targets = list()
	var/sleep_drain_cooldown = 0
	var/sleep_drain_cooldown_time = 10 SECONDS
	var/invisibility_level = 0
	var/max_invisibility = 100
	var/stealth_mode = FALSE
	var/stealth_cooldown = 0
	var/stealth_cooldown_time = 20 SECONDS
	var/sleep_deprivation_intensity = 1
	var/max_sleep_deprivation = 5
	var/list/stalked_targets = list()
	var/nightmare_manipulation = 0
	var/max_nightmare_manipulation = 100
	var/sleep_paralysis_skill = 0
	var/max_sleep_paralysis_skill = 100
	var/dream_invasion_level = 0
	var/max_dream_invasion_level = 5
	var/reality_distortion = 0
	var/max_reality_distortion = 100
	var/psychological_horror = 0
	var/max_psychological_horror = 100
	var/invisibility_evolution = 1
	var/max_invisibility_evolution = 5
	var/nightmare_cooldown = 0
	var/nightmare_cooldown_time = 15 SECONDS
	var/dream_invasion_cooldown = 0
	var/dream_invasion_cooldown_time = 25 SECONDS

	// Persistence tracking
	var/sleep_drain_sessions = 0
	var/stealth_activations = 0
	var/targets_stalked = 0
	var/nightmares_created = 0
	var/sleep_paralysis_events = 0
	var/dream_invasions = 0
	var/reality_distortions = 0
	var/psychological_horrors = 0
	var/invisibility_evolutions = 0

/mob/living/carbon/human/scp966/Initialize()
	. = ..()

	// Create SCP datum and enable advanced component system
	SCP = new /datum/scp(src, "Sleep Killer", SCP_EUCLID, "966", SCP_SENTIENT)
	SCP.uses_advanced_components = TRUE
	SCP.compInit_advanced() // Use the extended initialization

	// Initialize SCP-966 specific skills through component system
	initialize_scp_966_skills()

/mob/living/carbon/human/scp966/proc/initialize_scp_966_skills()
	// Get the skill system component
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(skill_system)
		skill_system.add_skill("Drain Sleep", 30 SECONDS, list("requires_target"))
		skill_system.add_skill("Toggle Stealth", 60 SECONDS, list("requires_stealth"))
		skill_system.add_skill("Stalk Target", 90 SECONDS, list("requires_target"))
		skill_system.add_skill("Intensify Deprivation", 120 SECONDS, list("requires_intensity"))
		skill_system.add_skill("View Stalked Targets", 45 SECONDS, list("requires_stalked"))
		skill_system.add_skill("Create Nightmare", 180 SECONDS, list("requires_nightmare"))
		skill_system.add_skill("Sleep Paralysis", 150 SECONDS, list("requires_paralysis"))
		skill_system.add_skill("Invade Dreams", 240 SECONDS, list("requires_dreams"))
		skill_system.add_skill("Distort Reality", 300 SECONDS, list("requires_reality"))
		skill_system.add_skill("Psychological Horror", 200 SECONDS, list("requires_horror"))
		skill_system.add_skill("Evolve Invisibility", 360 SECONDS, list("requires_evolution"))
		skill_system.add_skill("Nightmare Mastery", 270 SECONDS, list("requires_mastery"))

// SCP-966 specific ability procs (updated to use component system)
/mob/living/carbon/human/scp966/proc/drain_sleep(mob/target)
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Drain Sleep"))
		return FALSE

	if(!target)
		to_chat(src, "<span class='warning'>You need a target to drain sleep from.</span>")
		return FALSE

	sleep_drain_sessions++
	sleep_deprivation_intensity = min(max_sleep_deprivation, sleep_deprivation_intensity + 1)

	to_chat(src, "<span class='notice'>You drain sleep from [target]. Sleep Drain Sessions: [sleep_drain_sessions]</span>")
	to_chat(target, "<span class='danger'>You feel your energy being drained...</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/toggle_stealth()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Toggle Stealth"))
		return FALSE

	stealth_mode = !stealth_mode
	stealth_activations++

	to_chat(src, "<span class='notice'>You [stealth_mode ? "activate" : "deactivate"] stealth mode. Stealth Activations: [stealth_activations]</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/stalk_target(mob/target)
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Stalk Target"))
		return FALSE

	if(!target)
		to_chat(src, "<span class='warning'>You need a target to stalk.</span>")
		return FALSE

	targets_stalked++
	stalked_targets += target

	to_chat(src, "<span class='notice'>You begin stalking [target]. Targets Stalked: [targets_stalked]</span>")
	to_chat(target, "<span class='danger'>You feel like you're being watched...</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/intensify_deprivation()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Intensify Deprivation"))
		return FALSE

	sleep_deprivation_intensity = min(max_sleep_deprivation, sleep_deprivation_intensity + 1)

	to_chat(src, "<span class='notice'>You intensify sleep deprivation. Intensity: [sleep_deprivation_intensity]/[max_sleep_deprivation]</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/view_stalked_targets()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("View Stalked Targets"))
		return FALSE

	to_chat(src, "<span class='notice'>You view your stalked targets. Targets: [stalked_targets.len]</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/create_nightmare()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Create Nightmare"))
		return FALSE

	nightmare_manipulation = min(max_nightmare_manipulation, nightmare_manipulation + 10)
	nightmares_created++

	to_chat(src, "<span class='notice'>You create a nightmare. Nightmare Manipulation: [nightmare_manipulation]/[max_nightmare_manipulation]</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/sleep_paralysis()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Sleep Paralysis"))
		return FALSE

	sleep_paralysis_skill = min(max_sleep_paralysis_skill, sleep_paralysis_skill + 10)
	sleep_paralysis_events++

	to_chat(src, "<span class='notice'>You induce sleep paralysis. Sleep Paralysis Skill: [sleep_paralysis_skill]/[max_sleep_paralysis_skill]</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/invade_dreams()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Invade Dreams"))
		return FALSE

	dream_invasion_level = min(max_dream_invasion_level, dream_invasion_level + 1)
	dream_invasions++

	to_chat(src, "<span class='notice'>You invade dreams. Dream Invasion Level: [dream_invasion_level]/[max_dream_invasion_level]</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/distort_reality()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Distort Reality"))
		return FALSE

	reality_distortion = min(max_reality_distortion, reality_distortion + 10)
	reality_distortions++

	to_chat(src, "<span class='notice'>You distort reality. Reality Distortion: [reality_distortion]/[max_reality_distortion]</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/psychological_horror()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Psychological Horror"))
		return FALSE

	psychological_horror = min(max_psychological_horror, psychological_horror + 10)
	psychological_horrors++

	to_chat(src, "<span class='notice'>You create psychological horror. Psychological Horror: [psychological_horror]/[max_psychological_horror]</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/evolve_invisibility()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Evolve Invisibility"))
		return FALSE

	invisibility_evolution = min(max_invisibility_evolution, invisibility_evolution + 1)
	invisibility_evolutions++

	to_chat(src, "<span class='notice'>Your invisibility evolves! Invisibility Evolution: [invisibility_evolution]/[max_invisibility_evolution]</span>")
	return TRUE

/mob/living/carbon/human/scp966/proc/nightmare_mastery()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(!skill_system || !skill_system.use_skill("Nightmare Mastery"))
		return FALSE

	nightmare_manipulation = min(max_nightmare_manipulation, nightmare_manipulation + 15)

	to_chat(src, "<span class='notice'>You master nightmare creation. Nightmare Manipulation: [nightmare_manipulation]/[max_nightmare_manipulation]</span>")
	return TRUE

// Life cycle integration
/mob/living/carbon/human/scp966/Life()
	. = ..()

	// Update component system
	if(SCP && SCP.uses_advanced_components)
		SCP.update_components()

	// Legacy sleep deprivation effects
	if(sleep_deprivation_intensity > 0)
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD)
				H.adjustBruteLoss(sleep_deprivation_intensity * 0.1)

// Verb definitions for SCP-966 abilities
/mob/living/carbon/human/scp966/verb/drain_sleep_verb()
	set name = "Drain Sleep"
	set category = "SCP-966"
	set desc = "Drain sleep from a target"

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		targets += H

	if(targets.len == 0)
		to_chat(src, "<span class='warning'>No targets in range.</span>")
		return

	var/mob/target = input(src, "Select target to drain sleep from:", "Drain Sleep") as null|anything in targets
	if(target)
		drain_sleep(target)

/mob/living/carbon/human/scp966/verb/toggle_stealth_verb()
	set name = "Toggle Stealth"
	set category = "SCP-966"
	set desc = "Toggle stealth mode"

	toggle_stealth()

/mob/living/carbon/human/scp966/verb/stalk_target_verb()
	set name = "Stalk Target"
	set category = "SCP-966"
	set desc = "Stalk a target"

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(5, src))
		targets += H

	if(targets.len == 0)
		to_chat(src, "<span class='warning'>No targets in range.</span>")
		return

	var/mob/target = input(src, "Select target to stalk:", "Stalk Target") as null|anything in targets
	if(target)
		stalk_target(target)

/mob/living/carbon/human/scp966/verb/intensify_deprivation_verb()
	set name = "Intensify Deprivation"
	set category = "SCP-966"
	set desc = "Intensify sleep deprivation"

	intensify_deprivation()

/mob/living/carbon/human/scp966/verb/view_stalked_targets_verb()
	set name = "View Stalked Targets"
	set category = "SCP-966"
	set desc = "View your stalked targets"

	view_stalked_targets()

/mob/living/carbon/human/scp966/verb/create_nightmare_verb()
	set name = "Create Nightmare"
	set category = "SCP-966"
	set desc = "Create a nightmare"

	create_nightmare()

/mob/living/carbon/human/scp966/verb/sleep_paralysis_verb()
	set name = "Sleep Paralysis"
	set category = "SCP-966"
	set desc = "Induce sleep paralysis"

	sleep_paralysis()

/mob/living/carbon/human/scp966/verb/invade_dreams_verb()
	set name = "Invade Dreams"
	set category = "SCP-966"
	set desc = "Invade dreams"

	invade_dreams()

/mob/living/carbon/human/scp966/verb/distort_reality_verb()
	set name = "Distort Reality"
	set category = "SCP-966"
	set desc = "Distort reality"

	distort_reality()

/mob/living/carbon/human/scp966/verb/psychological_horror_verb()
	set name = "Psychological Horror"
	set category = "SCP-966"
	set desc = "Create psychological horror"

	psychological_horror()

/mob/living/carbon/human/scp966/verb/evolve_invisibility_verb()
	set name = "Evolve Invisibility"
	set category = "SCP-966"
	set desc = "Evolve your invisibility"

	evolve_invisibility()

/mob/living/carbon/human/scp966/verb/nightmare_mastery_verb()
	set name = "Nightmare Mastery"
	set category = "SCP-966"
	set desc = "Master nightmare creation"

	nightmare_mastery()

// Status display
/mob/living/carbon/human/scp966/proc/get_scp_status()
	var/list/status = list()
	status += "=== SCP-966 Status ==="
	status += "Stealth Mode: [stealth_mode ? "ACTIVE" : "Inactive"]"
	status += "Invisibility Level: [invisibility_level]/[max_invisibility]"
	status += "Sleep Deprivation Intensity: [sleep_deprivation_intensity]/[max_sleep_deprivation]"
	status += "Nightmare Manipulation: [nightmare_manipulation]/[max_nightmare_manipulation]"
	status += "Sleep Paralysis Skill: [sleep_paralysis_skill]/[max_sleep_paralysis_skill]"
	status += "Dream Invasion Level: [dream_invasion_level]/[max_dream_invasion_level]"
	status += "Reality Distortion: [reality_distortion]/[max_reality_distortion]"
	status += "Psychological Horror: [psychological_horror]/[max_psychological_horror]"
	status += "Invisibility Evolution: [invisibility_evolution]/[max_invisibility_evolution]"
	status += "=== Statistics ==="
	status += "Sleep Drain Sessions: [sleep_drain_sessions]"
	status += "Stealth Activations: [stealth_activations]"
	status += "Targets Stalked: [targets_stalked]"
	status += "Nightmares Created: [nightmares_created]"
	status += "Sleep Paralysis Events: [sleep_paralysis_events]"
	status += "Dream Invasions: [dream_invasions]"
	status += "Reality Distortions: [reality_distortions]"
	status += "Psychological Horrors: [psychological_horrors]"
	status += "Invisibility Evolutions: [invisibility_evolutions]"

	// Add component status if using advanced system
	if(SCP && SCP.uses_advanced_components)
		var/list/component_status = SCP.get_component_status()
		status += "=== Component Status ==="
		status += component_status

	return status

/mob/living/carbon/human/scp966/verb/show_status_verb()
	set name = "Show SCP Status"
	set category = "SCP-966"
	set desc = "Display your SCP-966 status"

	var/list/status = get_scp_status()
	for(var/line in status)
		to_chat(src, "<span class='notice'>[line]</span>")
