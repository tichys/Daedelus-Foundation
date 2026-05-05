// SCP-294 - The Coffee Machine
// A vending machine that dispenses any liquid

/obj/machinery/scp294
	name = "coffee machine"
	desc = "A standard-looking coffee vending machine. The keypad seems to accept any input."
	icon = 'icons/scp/scp294.dmi'
	icon_state = "scp294"
	density = TRUE
	anchored = TRUE

	var/dispense_cooldown = 0
	var/drinks_dispensed = 0
	var/last_liquid

	var/datum/scp294_liquid_system/liquid_system
	var/datum/scp294_effect_system/effect_system
	var/datum/scp294_research_system/research_system

/obj/machinery/scp294/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "The Coffee Machine", SCP_SAFE, "294")

	liquid_system = new /datum/scp294_liquid_system(src)
	effect_system = new /datum/scp294_effect_system(src)
	research_system = new /datum/scp294_research_system(src)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-294"] = new /datum/scp_instance("SCP-294", src)

/obj/machinery/scp294/attack_hand(mob/living/carbon/human/user)
	..()

	if(!istype(user))
		return

	if(dispense_cooldown > world.time)
		to_chat(user, "<span class='warning'>The machine is cooling down. Please wait.</span>")
		return

	var/liquid = input(user, "Enter liquid name:", "SCP-294") as null|text
	if(!liquid)
		return

	hook_scp_interaction(user, "SCP-294", INTERACTION_TYPE_CONTAINMENT)

	dispense_liquid(user, liquid)

/obj/machinery/scp294/proc/dispense_liquid(mob/living/carbon/human/user, liquid_name)
	if(!user || !liquid_name)
		return

	last_liquid = liquid_name
	drinks_dispensed++
	dispense_cooldown = world.time + 30 SECONDS

	var/obj/item/reagent_containers/drinks/drinkingglass/G = new(get_turf(src))

	if(liquid_system)
		liquid_system.analyze_and_fill(G, liquid_name)

	visible_message("<span class='notice'>[src] whirs and dispenses a cup of [liquid_name].</span>")

	if(effect_system)
		effect_system.apply_effects(user, liquid_name)

/obj/machinery/scp294/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A coffee machine that can dispense any liquid. Enter what you desire.</span>")
	to_chat(user, "<span class='notice'>Drinks dispensed: [drinks_dispensed]</span>")

/datum/scp294_liquid_system
	var/obj/machinery/parent
	var/list/known_liquids = list()
	var/analysis_accuracy = 75

/datum/scp294_liquid_system/New(obj/machinery/P)
	parent = P

/datum/scp294_liquid_system/proc/analyze_and_fill(obj/item/reagent_containers/container, liquid_name)
	if(!container || !liquid_name)
		return

	var/lower_liquid = lowertext(liquid_name)

	var/datum/reagents/R = container.reagents
	if(!R)
		R = new/datum/reagents(100)
		R.my_atom = container
		container.reagents = R

	R.maximum_volume = 100

	if(findtext(lower_liquid, "coffee"))
		R.add_reagent("coffee", 50)
	else if(findtext(lower_liquid, "tea"))
		R.add_reagent("tea", 50)
	else if(findtext(lower_liquid, "water"))
		R.add_reagent("water", 50)
	else if(findtext(lower_liquid, "blood"))
		R.add_reagent("blood", 50)
	else if(findtext(lower_liquid, "acid"))
		R.add_reagent("acid", 50)
	else if(findtext(lower_liquid, "poison") || findtext(lower_liquid, "toxin"))
		R.add_reagent("toxin", 50)
	else if(findtext(lower_liquid, "healing") || findtext(lower_liquid, "cure"))
		R.add_reagent("tricordrazine", 50)
	else
		R.add_reagent("water", 30)
		if(prob(30))
			R.add_reagent("toxin", 10)
			if(parent)
				var/mob/living/carbon/human/nearby = locate() in range(2, parent)
				if(nearby)
					to_chat(nearby, "<span class='warning'>The machine makes an unsettling gurgle.</span>")

	known_liquids[liquid_name] = world.time

/datum/scp294_effect_system
	var/obj/machinery/parent
	var/effect_intensity = 1

/datum/scp294_effect_system/New(obj/machinery/P)
	parent = P

/datum/scp294_effect_system/proc/apply_effects(mob/living/carbon/human/drinker, liquid_name)
	if(!drinker || !liquid_name)
		return

	var/lower_liquid = lowertext(liquid_name)

	if(findtext(lower_liquid, "hot") || findtext(lower_liquid, "burning"))
		drinker.adjustFireLoss(10)
		to_chat(drinker, "<span class='danger'>The liquid burns your throat!</span>")
		hook_scp_combat(drinker, "SCP-294", 0, 10)

	if(findtext(lower_liquid, "cold") || findtext(lower_liquid, "freezing"))
		drinker.adjustFireLoss(5)
		drinker.bodytemperature -= 50
		to_chat(drinker, "<span class='warning'>The liquid is freezing cold!</span>")

	if(findtext(lower_liquid, "perfect") || findtext(lower_liquid, "best"))
		drinker.reagents?.add_reagent("tricordrazine", 15)
		drinker.reagents?.add_reagent("hyperzine", 5)
		to_chat(drinker, "<span class='notice'>The liquid tastes absolutely perfect.</span>")

/datum/scp294_research_system
	var/obj/machinery/parent
	var/list/research_data = list()
	var/dispense_events = 0

/datum/scp294_research_system/New(obj/machinery/P)
	parent = P

/datum/scp294_research_system/proc/record_dispense(mob/living/carbon/human/user, liquid_name)
	dispense_events++
	research_data["[world.time]"] = list("user" = user.ckey, "liquid" = liquid_name)
