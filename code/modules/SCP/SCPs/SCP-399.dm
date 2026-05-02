// SCP-399 - The Wish Granter
// An entity that grants wishes with unpredictable consequences

/obj/structure/scp399
	name = "wish granter"
	desc = "A crystalline structure that pulses with an otherworldly light. It seems to respond to desire."
	icon = 'icons/scp/scp-399.dmi'
	icon_state = "scp399"
	density = TRUE
	anchored = TRUE

	var/wishes_granted = 0
	var/max_wishes_per_round = 5
	var/wish_cooldown = 0
	var/last_wisher

	var/datum/scp399_wish_system/wish_system
	var/datum/scp399_consequence_system/consequence_system
	var/datum/scp399_research_system/research_system

/obj/structure/scp399/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "wish granter", SCP_KETER, "399")

	wish_system = new /datum/scp399_wish_system(src)
	consequence_system = new /datum/scp399_consequence_system(src)
	research_system = new /datum/scp399_research_system(src)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-399"] = new /datum/scp_instance("SCP-399", src)

/obj/structure/scp399/attack_hand(mob/living/carbon/human/user)
	..()

	if(!istype(user))
		return

	if(wish_cooldown > world.time)
		to_chat(user, "<span class='warning'>The crystal dims momentarily - it needs time to recharge.</span>")
		return

	if(wishes_granted >= max_wishes_per_round)
		to_chat(user, "<span class='warning'>The crystal's light has faded. It cannot grant more wishes today.</span>")
		return

	var/wish = input(user, "What do you wish for?", "SCP-399") as null|text
	if(!wish)
		return

	hook_scp_interaction(user, "SCP-399", INTERACTION_TYPE_COMMUNICATION)

	if(wish_system)
		var/result = wish_system.process_wish(user, wish)
		wishes_granted++
		last_wisher = user.ckey
		wish_cooldown = world.time + 5 MINUTES

		if(result)
			hook_scp_breach("SCP-399", src)
			visible_message("<span class='danger'>The crystal flares brilliantly as [user]'s wish is granted!</span>")

/obj/structure/scp399/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A crystalline entity that grants wishes. Be careful what you wish for.</span>")
	to_chat(user, "<span class='notice'>Wishes granted today: [wishes_granted]/[max_wishes_per_round]</span>")

/datum/scp399_wish_system
	var/obj/structure/parent
	var/list/granted_wishes = list()
	var/list/wish_types = list("material", "power", "knowledge", "protection", "destruction")

/datum/scp399_wish_system/New(obj/structure/P)
	parent = P

/datum/scp399_wish_system/proc/process_wish(mob/living/carbon/human/wisher, wish_text)
	if(!wisher || !wish_text)
		return FALSE

	var/wish_type = analyze_wish(wish_text)
	var/consequence = determine_consequence(wish_type)

	granted_wishes += list(list(
		"wisher" = wisher.ckey,
		"wish" = wish_text,
		"type" = wish_type,
		"consequence" = consequence,
		"time" = world.time
	))

	grant_wish_effect(wisher, wish_type, consequence)

	return TRUE

/datum/scp399_wish_system/proc/analyze_wish(wish_text)
	var/lower_wish = lowertext(wish_text)

	if(findtext(lower_wish, "power") || findtext(lower_wish, "strong"))
		return "power"
	if(findtext(lower_wish, "money") || findtext(lower_wish, "wealth") || findtext(lower_wish, "item"))
		return "material"
	if(findtext(lower_wish, "know") || findtext(lower_wish, "learn") || findtext(lower_wish, "secret"))
		return "knowledge"
	if(findtext(lower_wish, "protect") || findtext(lower_wish, "safe") || findtext(lower_wish, "heal"))
		return "protection"
	if(findtext(lower_wish, "kill") || findtext(lower_wish, "destroy") || findtext(lower_wish, "hurt"))
		return "destruction"

	return pick(wish_types)

/datum/scp399_wish_system/proc/determine_consequence(wish_type)
	return pick(1, 2, 3)

/datum/scp399_wish_system/proc/grant_wish_effect(mob/living/carbon/human/wisher, wish_type, consequence_level)
	switch(wish_type)
		if("power")
			wisher.adjustBruteLoss(-50 * consequence_level)
			if(consequence_level > 1)
				wisher.adjustBrainLoss(10 * consequence_level)
				to_chat(wisher, "<span class='danger'>Power flows through you, but at what cost?</span>")
		if("material")
			var/obj/item/stack/money/M = new(get_turf(wisher))
			M.amount = 100 * consequence_level
			if(consequence_level > 1)
				wisher.adjustFireLoss(5 * consequence_level)
				to_chat(wisher, "<span class='danger'>Wealth appears, but you feel the price.</span>")
		if("knowledge")
			wisher.mind?.adjust_experience("research", 100 * consequence_level)
			if(consequence_level > 1)
				wisher.adjustBrainLoss(5 * consequence_level)
				to_chat(wisher, "<span class='danger'>Forbidden knowledge fills your mind.</span>")
		if("protection")
			wisher.reagents?.add_reagent("tricordrazine", 10 * consequence_level)
			if(consequence_level > 1)
				wisher.stamina.adjust(-20 * consequence_level)
				to_chat(wisher, "<span class='danger'>Protection wraps around you, draining your vitality.</span>")
		if("destruction")
			var/mob/living/target = locate() in range(5, wisher)
			if(target && target != wisher)
				target.adjustBruteLoss(50 * consequence_level)
			if(consequence_level > 1)
				wisher.adjustBruteLoss(10 * consequence_level)
				to_chat(wisher, "<span class='danger'>Destruction is wrought, but you are not immune.</span>")

/datum/scp399_consequence_system
	var/obj/structure/parent
	var/consequence_intensity = 1

/datum/scp399_consequence_system/New(obj/structure/P)
	parent = P

/datum/scp399_research_system
	var/obj/structure/parent
	var/list/research_data = list()
	var/wish_events = 0

/datum/scp399_research_system/New(obj/structure/P)
	parent = P
