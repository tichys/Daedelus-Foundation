// SCP-966 - Sleep Killer
// An invisible creature that causes sleep deprivation and hunts sleeping prey

/mob/living/carbon/human/scp966
	name = "SCP-966"
	desc = "An invisible creature that causes sleep deprivation. You can barely make out its shimmering outline."
	icon = 'icons/scp/scp-966.dmi'
	icon_state = "scp966"
	real_name = "SCP-966"
	status_flags = 0

	var/datum/scp966_sleep_system/sleep_system
	var/datum/scp966_stealth_system/stealth_system
	var/datum/scp966_stalk_system/stalk_system
	var/datum/scp966_nightmare_system/nightmare_system
	var/datum/scp966_research_system/research_system

	var/victims_sleep_deprived = 0
	var	stalk_targets = 0
	var	nightmares_caused = 0

/mob/living/carbon/human/scp966/Initialize()
	. = ..()
	set_species(/datum/species/scp966)
	SCP = new /datum/scp(src, "Sleep Killer", SCP_EUCLID, "966", SCP_PLAYABLE)
	SCP.min_playercount = 25
	SCP.min_time = 10 MINUTES

	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

	grant_language(/datum/language/common, TRUE, TRUE)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-966"] = new /datum/scp_instance("SCP-966", src)

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

/mob/living/carbon/human/scp966/UnarmedAttack(atom/A)
	if(!ishuman(A))
		return ..()

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD)
		return ..()

	if(sleep_system && H.drowsyness > 50)
		H.adjustBruteLoss(sleep_system.intensity * 3)
		H.visible_message("<span class='danger'>Something invisible slashes at [H]!</span>", "<span class='danger'>You feel claws tear into you!</span>")
		return

	to_chat(src, "<span class='warning'>[H] is too alert to attack effectively.</span>")

/mob/living/carbon/human/scp966/verb/toggle_invisibility()
	set name = "Toggle Invisibility"
	set desc = "Become visible or invisible"
	set category = "SCP-966"

	if(stealth_system?.active)
		stealth_system.active = FALSE
		to_chat(src, "<span class='notice'>You become more visible.</span>")
	else if(stealth_system)
		stealth_system.active = TRUE
		to_chat(src, "<span class='notice'>You fade into the shadows.</span>")

/mob/living/carbon/human/scp966/verb/induce_insomnia()
	set name = "Induce Insomnia"
	set desc = "Cause sleep deprivation in a nearby target"
	set category = "SCP-966"

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(7, src))
		if(H.stat != DEAD && H != src)
			targets += H

	if(!length(targets))
		to_chat(src, "<span class='warning'>No valid targets nearby.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose target:", "Induce Insomnia") as null|anything in targets
	if(!target)
		return

	if(sleep_system)
		sleep_system.intensity = min(sleep_system.max_intensity, sleep_system.intensity + 1)
		target.drowsyness = max(0, target.drowsyness - 20)
		victims_sleep_deprived++
		hook_scp_interaction(target, "SCP-966", INTERACTION_TYPE_COMBAT)
		to_chat(target, "<span class='danger'>A wave of wakefulness crashes over you!</span>")

/mob/living/carbon/human/scp966/verb/stalk_target()
	set name = "Stalk Target"
	set desc = "Begin stalking a target for later attack"
	set category = "SCP-966"

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(15, src))
		if(H.stat != DEAD && H != src)
			targets += H

	if(!length(targets))
		to_chat(src, "<span class='warning'>No valid targets nearby.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose target to stalk:", "Stalk") as null|anything in targets
	if(!target)
		return

	if(stalk_system && !(target in stalk_system.stalked))
		stalk_system.stalked += target
		stalk_targets++
		hook_scp_interaction(target, "SCP-966", INTERACTION_TYPE_OBSERVATION)
		to_chat(target, "<span class='danger'>You feel an unseen gaze upon you...</span>")

/mob/living/carbon/human/scp966/proc/get_scp_status()
	var/list/status = list()
	status += "=== SCP-966 Status ==="
	status += "Sleep aura active"
	status += "Stalked: [stalk_system?.stalked?.len || 0]"
	status += "Victims deprived: [victims_sleep_deprived]"
	status += "Nightmares caused: [nightmares_caused]"
	return status

/mob/living/carbon/human/scp966/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(H, "<span class='warning'>SCP-966: A sleep-inducing predator. Victims suffer extreme sleep deprivation.</span>")
		else
			to_chat(H, "<span class='warning'>You can barely see something shimmering in the air...</span>")
