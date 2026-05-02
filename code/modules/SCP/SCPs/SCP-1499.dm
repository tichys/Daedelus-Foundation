// SCP-1499 - The Gas Mask
// A gas mask that transports the wearer to an alien dimension when worn

/obj/item/clothing/mask/gas/scp1499
	name = "strange gas mask"
	desc = "A Soviet GP-5 gas mask with unusual modifications. Looking through the lenses reveals a strange landscape."
	icon = 'icons/scp/scp-1499.dmi'
	icon_state = "scp1499"
	w_class = WEIGHT_CLASS_NORMAL
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH

	var/dimension_active = FALSE
	var/trip_duration = 0
	var/entities_encountered = 0

	var/datum/scp1499_dimension_system/dimension_system
	var/datum/scp1499_entity_system/entity_system
	var/datum/scp1499_research_system/research_system

	var/trips_taken = 0
	var	safe_returns = 0
	var	original_location

/obj/item/clothing/mask/gas/scp1499/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "gas mask", SCP_SAFE, "1499")

	dimension_system = new /datum/scp1499_dimension_system(src)
	entity_system = new /datum/scp1499_entity_system(src)
	research_system = new /datum/scp1499_research_system(src)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-1499"] = new /datum/scp_instance("SCP-1499", src)

/obj/item/clothing/mask/gas/scp1499/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == ITEM_SLOT_MASK)
		enter_dimension(user)

/obj/item/clothing/mask/gas/scp1499/unequipped(mob/living/carbon/human/user)
	if(dimension_active)
		exit_dimension(user)
	..()

/obj/item/clothing/mask/gas/scp1499/proc/enter_dimension(mob/living/carbon/human/wearer)
	if(!wearer || dimension_active)
		return

	dimension_active = TRUE
	original_location = get_turf(wearer)
	trips_taken++
	trip_duration = 0

	hook_scp_interaction(wearer, "SCP-1499", INTERACTION_TYPE_EXPLORATION)

	if(dimension_system)
		dimension_system.transport_to_dimension(wearer)

	to_chat(wearer, "<span class='warning'>Reality shifts around you. You find yourself in an alien landscape!</span>")
	START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/gas/scp1499/proc/exit_dimension(mob/living/carbon/human/wearer)
	if(!wearer)
		return

	dimension_active = FALSE
	trip_duration = 0

	if(dimension_system)
		dimension_system.return_from_dimension(wearer, original_location)

	to_chat(wearer, "<span class='notice'>The alien landscape fades as reality returns to normal.</span>")
	hook_scp_interaction(wearer, "SCP-1499", INTERACTION_TYPE_SURVIVAL)
	safe_returns++

	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/gas/scp1499/process()
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || wearer.wear_mask != src)
		if(dimension_active)
			exit_dimension(wearer)
		return

	trip_duration++

	if(dimension_system)
		dimension_system.process_dimension(wearer, trip_duration)

	if(entity_system)
		entity_system.process_entities(wearer, trip_duration)

	if(trip_duration > 600 && prob(5))
		to_chat(wearer, "<span class='warning'>You feel like you should remove the mask soon...</span>")

/obj/item/clothing/mask/gas/scp1499/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A gas mask that transports the wearer to an alien dimension.</span>")

/datum/scp1499_dimension_system
	var/obj/item/parent
	var/list/dimension_turfs = list()
	var/dimension_size = 50
	var/alien_architecture = TRUE

/datum/scp1499_dimension_system/New(obj/item/P)
	parent = P

/datum/scp1499_dimension_system/proc/transport_to_dimension(mob/living/carbon/human/wearer)
	if(!wearer)
		return

	wearer.forceMove(locate(wearer.x, wearer.y, 2))

/datum/scp1499_dimension_system/proc/return_from_dimension(mob/living/carbon/human/wearer, original_turf)
	if(!wearer)
		return

	if(original_turf)
		wearer.forceMove(original_turf)

/datum/scp1499_dimension_system/proc/process_dimension(mob/living/carbon/human/wearer, duration)
	if(!wearer)
		return

	if(prob(5))
		wearer.visible_message("<span class='notice'>[wearer] stares blankly into nothing.</span>")

	if(duration > 1800)
		wearer.adjust_drowsyness(1)
		hook_scp_combat(wearer, "SCP-1499", 0, 1)

/datum/scp1499_entity_system
	var/obj/item/parent
	var/list/spawned_entities = list()
	var/entity_types = list("scout", "soldier", "giant")
	var/max_entities = 5
	var/aggression_level = 0

/datum/scp1499_entity_system/New(obj/item/P)
	parent = P

/datum/scp1499_entity_system/proc/process_entities(mob/living/carbon/human/wearer, duration)
	if(!wearer)
		return

	aggression_level = min(100, aggression_level + 0.1)

	if(spawned_entities.len < max_entities && prob(5))
		spawn_entity(wearer)

	for(var/obj/effect/scp1499_entity/E in spawned_entities)
		if(get_dist(E, wearer) <= 3 && aggression_level > 50)
			if(prob(10))
				attack_wearer(wearer, E)

/datum/scp1499_entity_system/proc/spawn_entity(mob/living/carbon/human/wearer)
	if(!wearer)
		return

	var/turf/spawn_turf = get_step(wearer, pick(NORTH, SOUTH, EAST, WEST))
	var/obj/effect/scp1499_entity/E = new(spawn_turf)
	E.target = wearer
	spawned_entities += E

	wearer.visible_message("<span class='danger'>A strange entity manifests nearby!</span>", "<span class='danger'>One of the dimension's inhabitants approaches!</span>")
	hook_scp_combat(wearer, "SCP-1499", 0, 5)

/datum/scp1499_entity_system/proc/attack_wearer(mob/living/carbon/human/wearer, obj/effect/scp1499_entity/entity)
	if(!wearer || !entity)
		return

	var/damage = rand(5, 15)
	wearer.adjustBruteLoss(damage)
	to_chat(wearer, "<span class='danger'>[entity] attacks you!</span>")
	hook_scp_combat(wearer, "SCP-1499", 0, damage)

/obj/effect/scp1499_entity
	name = "alien entity"
	desc = "A tall, thin humanoid with no visible facial features. Its skin is pale and leathery."
	icon = 'icons/mob/cult.dmi'
	icon_state = "shade"
	density = TRUE
	anchored = FALSE

	var/mob/living/carbon/human/target
	var/health = 50

/obj/effect/scp1499_entity/proc/die()
	qdel(src)

/datum/scp1499_research_system
	var/obj/item/parent
	var/list/trip_log = list()
	var	total_trip_time = 0

/datum/scp1499_research_system/New(obj/item/P)
	parent = P

/datum/scp1499_research_system/proc/log_trip(mob/wearer, duration, entities_seen)
	total_trip_time += duration
	trip_log["[world.time]"] = list("wearer" = wearer?.ckey, "duration" = duration, "entities" = entities_seen)
