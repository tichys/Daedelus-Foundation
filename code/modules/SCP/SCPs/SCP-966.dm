// SCP-966 - Sleep Killer
// An invisible creature that causes sleep deprivation

/mob/living/carbon/human/scp966
	name = "SCP-966"
	desc = "An invisible creature that causes sleep deprivation."
	icon = 'icons/scp/scp-966.dmi'
	icon_state = "scp966"
	real_name = "SCP-966"

	var/datum/scp966_sleep_system/sleep_system
	var/datum/scp966_stealth_system/stealth_system
	var/datum/scp966_stalk_system/stalk_system
	var/datum/scp966_nightmare_system/nightmare_system
	var/datum/scp966_research_system/research_system

/mob/living/carbon/human/scp966/Initialize()
	. = ..()
	set_species(/datum/species/scp939) // reuse similar resist profile if 966 species absent
	SCP = new /datum/scp(src, "Sleep Killer", SCP_EUCLID, "966", SCP_SENTIENT)
	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

/mob/living/carbon/human/scp966/proc/initialize_systems()
	sleep_system = new /datum/scp966_sleep_system(src)
	stealth_system = new /datum/scp966_stealth_system(src)
	stalk_system = new /datum/scp966_stalk_system(src)
	nightmare_system = new /datum/scp966_nightmare_system(src)
	research_system = new /datum/scp966_research_system(src)

/mob/living/carbon/human/scp966/Life()
	. = ..()
	if(stat == DEAD)
		return
	sleep_system?.process_sleep()
	stealth_system?.process_stealth()
	stalk_system?.process_stalk()
	nightmare_system?.process_nightmares()
	research_system?.process_research()

/mob/living/carbon/human/scp966/proc/get_scp_status()
	var/list/status = list()
	status += "=== SCP-966 Status ==="
	status += "Sleep aura active"
	status += "Stalked: [stalk_system?.stalked?.len || 0]"
	return status
