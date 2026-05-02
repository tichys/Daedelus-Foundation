/mob/living/carbon/human/scp2343
	name = "strange american man"
	desc = "A brusk and wiley man of american decent."
	icon = 'icons/scp/scp_2343.dmi'
	icon_state = "americangod"
	status_flags = 0
	var/datum/scp2343_benevolence_system/benevolence_system
	var/datum/scp2343_research_system/research_system

/mob/living/carbon/human/scp2343/Initialize(mapload)
	. = ..()
	set_species(/datum/species/scp2343)
	SCP = new /datum/scp(src, "benevolent entity", SCP_SAFE, "2343", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-2343"] = new /datum/scp_instance("SCP-2343", src)
	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

/mob/living/carbon/human/scp2343/proc/initialize_systems()
	benevolence_system = new /datum/scp2343_benevolence_system(src)
	research_system = new /datum/scp2343_research_system(src)

/mob/living/carbon/human/scp2343/Life(datum/controller/process/mobs/parent)
	. = ..()
	if(stat == DEAD)
		return
	benevolence_system?.process_benevolence()
	research_system?.process_research()

/mob/living/carbon/human/scp2343/say(message)
	. = ..()
	if(.)
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD && H != src)
				hook_scp_interaction(H, "SCP-2343", INTERACTION_TYPE_COMMUNICATION)

/mob/living/carbon/human/scp2343/proc/on_benevolent_act(mob/living/carbon/human/beneficiary)
	if(!beneficiary)
		return
	hook_scp_care(beneficiary, "SCP-2343", "benevolence")

/mob/living/carbon/human/scp2343/examine(mob/living/user)
	. = ..()
	to_chat(user, "<span class='notice'>This being seems to have reality-bending powers.</span>")
