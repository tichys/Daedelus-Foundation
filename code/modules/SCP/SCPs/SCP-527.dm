// SCP-527 - Mr. Fish
// A fish-man from the SCP-005 "Mr." series

/mob/living/carbon/human/scp527
	name = "Mr. Fish"
	desc = "A humanoid male with a fish head. He appears to be a specimen from the 'Mr.' series of SCPs."
	icon = 'icons/scp/scp-527.dmi'
	icon_state = "scp527"
	status_flags = 0

	var/datum/scp527_aquatic_system/aquatic_system
	var/datum/scp527_ability_system/ability_system
	var/datum/scp527_research_system/research_system

	var/swim_time = 0
	var	conversations_held = 0

/mob/living/carbon/human/scp527/Initialize(mapload)
	. = ..()
	set_species(/datum/species/scp527)
	SCP = new /datum/scp(src, "Mr. Fish", SCP_SAFE, "527", SCP_PLAYABLE|SCP_ROLEPLAY)
	SCP.min_playercount = 15
	SCP.min_time = 5 MINUTES

	aquatic_system = new /datum/scp527_aquatic_system(src)
	ability_system = new /datum/scp527_ability_system(src)
	research_system = new /datum/scp527_research_system(src)

	grant_language(/datum/language/common, TRUE, TRUE)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-527"] = new /datum/scp_instance("SCP-527", src)

	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

/mob/living/carbon/human/scp527/Life()
	. = ..()
	if(stat == DEAD)
		return

	if(aquatic_system)
		aquatic_system.process_aquatic()

/mob/living/carbon/human/scp527/say(message)
	. = ..()
	if(.)
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD && H != src)
				hook_scp_interaction(H, "SCP-527", INTERACTION_TYPE_COMMUNICATION)
				conversations_held++

/mob/living/carbon/human/scp527/UnarmedAttack(atom/A)
	. = ..()
	if(istype(A, /obj/structure/sink) || istype(A, /turf/open/water))
		if(aquatic_system)
			aquatic_system.enter_water()
			swim_time++
			hook_scp_interaction(src, "SCP-527", INTERACTION_TYPE_EXPLORATION)

/mob/living/carbon/human/scp527/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A fish-headed humanoid from Dr. Wondertainment's 'Mr.' series.</span>")
	to_chat(user, "<span class='notice'>He seems comfortable in and out of water.</span>")

/mob/living/carbon/human/scp527/verb/dive()
	set name = "Dive"
	set desc = "Dive into nearby water"
	set category = "SCP-527"

	var/turf/open/water/W = locate() in range(1, src)
	if(W)
		forceMove(W)
		visible_message("<span class='notice'>[src] dives into the water!</span>")
		if(aquatic_system)
			aquatic_system.enter_water()
	else
		to_chat(src, "<span class='warning'>No water nearby to dive into!</span>")

/mob/living/carbon/human/scp527/verb/breathe_underwater()
	set name = "Underwater Breathing"
	set desc = "Toggle underwater breathing mode"
	set category = "SCP-527"

	if(aquatic_system)
		aquatic_system.toggle_underwater_mode()
		to_chat(src, "<span class='notice'>You [aquatic_system.underwater_mode ? "begin" : "stop"] breathing underwater.</span>")

/datum/scp527_aquatic_system
	var/mob/living/carbon/human/parent
	var/underwater_mode = FALSE
	var/swim_speed_bonus = 2
	var/water_healing_rate = 1
	var/max_breath_hold = 300

/datum/scp527_aquatic_system/New(mob/living/carbon/human/P)
	parent = P

/datum/scp527_aquatic_system/proc/process_aquatic()
	if(!parent)
		return

	var/turf/T = get_turf(parent)
	if(istype(T, /turf/open/water))
		if(parent.health < parent.maxHealth)
			parent.adjustBruteLoss(-water_healing_rate)

/datum/scp527_aquatic_system/proc/enter_water()
	underwater_mode = TRUE

/datum/scp527_aquatic_system/proc/exit_water()
	underwater_mode = FALSE

/datum/scp527_aquatic_system/proc/toggle_underwater_mode()
	underwater_mode = !underwater_mode

/datum/scp527_ability_system
	var/mob/living/carbon/human/parent
	var/fish_communication_range = 10
	var/speed_in_water = 2

/datum/scp527_ability_system/New(mob/living/carbon/human/P)
	parent = P

/datum/scp527_ability_system/proc/communicate_with_fish()
	if(!parent)
		return

	var/list/nearby_fish = list()
	for(var/mob/living/simple_animal/A in range(fish_communication_range, parent))
		if(findtext(lowertext(A.name), "fish"))
			nearby_fish += A

	if(nearby_fish.len > 0)
		to_chat(parent, "<span class='notice'>You sense [nearby_fish.len] fish nearby.</span>")
		return nearby_fish

/datum/scp527_research_system
	var/mob/living/carbon/human/parent
	var/list/research_data = list()
	var	water_time = 0

/datum/scp527_research_system/New(mob/living/carbon/human/P)
	parent = P
