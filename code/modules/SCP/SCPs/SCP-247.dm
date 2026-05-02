// SCP-247 - A Creature of Habit
// An animal mask that causes viewers to perceive friendly animals as dangerous

/obj/item/clothing/mask/scp247
	name = "animal mask"
	desc = "A realistic-looking animal mask. It seems to have a subtle pattern on it."
	icon = 'icons/scp/scp-247.dmi'
	icon_state = "scp247"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES

	var/mask_type = "lion"
	var/perception_strength = 100
	var/viewer_count = 0

	var/datum/scp247_perception_system/perception_system
	var/datum/scp247_effect_system/effect_system
	var/datum/scp247_research_system/research_system

	var/activation_count = 0
	var	affected_viewers = list()

/obj/item/clothing/mask/scp247/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "animal mask", SCP_EUCLID, "247")

	perception_system = new /datum/scp247_perception_system(src)
	effect_system = new /datum/scp247_effect_system(src)
	research_system = new /datum/scp247_research_system(src)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-247"] = new /datum/scp_instance("SCP-247", src)

/obj/item/clothing/mask/scp247/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == ITEM_SLOT_MASK)
		activation_count++
		hook_scp_interaction(user, "SCP-247", INTERACTION_TYPE_OBSERVATION)
		START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/scp247/unequipped(mob/living/carbon/human/user)
	STOP_PROCESSING(SSobj, src)
	affected_viewers = list()
	..()

/obj/item/clothing/mask/scp247/process()
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || !wearer.wear_mask == src)
		return

	for(var/mob/living/carbon/human/H in view(7, wearer))
		if(H.stat != DEAD && !(H.ckey in affected_viewers))
			affected_viewers += H.ckey
			viewer_count++
			if(perception_system)
				perception_system.apply_perception_effect(H, wearer)
			hook_scp_interaction(H, "SCP-247", INTERACTION_TYPE_OBSERVATION)

/obj/item/clothing/mask/scp247/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A mask that affects how others perceive animals.</span>")

/datum/scp247_perception_system
	var/obj/item/parent
	var/list/affected_mobs = list()
	var/perception_duration = 300
	var/hallucination_types = list("hostile", "friendly_inverted", "monster")

/datum/scp247_perception_system/New(obj/item/P)
	parent = P

/datum/scp247_perception_system/proc/apply_perception_effect(mob/living/carbon/human/viewer, mob/living/carbon/human/wearer)
	if(!viewer || !wearer)
		return

	affected_mobs[viewer.ckey] = world.time + perception_duration

	for(var/mob/living/simple_animal/pet/P in view(10, viewer))
		if(prob(50))
			make_animal_appear_hostile(viewer, P)

	to_chat(viewer, "<span class='warning'>Your perception of animals seems... distorted.</span>")

/datum/scp247_perception_system/proc/make_animal_appear_hostile(mob/living/carbon/human/viewer, mob/living/simple_animal/pet/target)
	if(!viewer || !target)
		return

	var/image/hostile_image = image('icons/mob/animal.dmi', target.loc, "hostile_[pick("wolf", "bear", "spider")]", target.dir)
	hostile_image.name = "[target.name] - HOSTILE"
	hostile_image.color = "#ff0000"

	viewer << hostile_image

/datum/scp247_effect_system
	var/obj/item/parent
	var/effect_radius = 7
	var/effect_duration = 60 SECONDS

/datum/scp247_effect_system/New(obj/item/P)
	parent = P

/datum/scp247_effect_system/proc/trigger_fear_response(mob/living/carbon/human/viewer, mob/living/simple_animal/pet/animal)
	if(!viewer || !animal)
		return

	if(prob(30))
		viewer.adjust_drowsyness(2)
		to_chat(viewer, "<span class='danger'>[animal] looks terrifying!</span>")
		hook_scp_combat(viewer, "SCP-247", 0, 2)

/datum/scp247_research_system
	var/obj/item/parent
	var/list/perception_log = list()
	var	viewer_events = 0

/datum/scp247_research_system/New(obj/item/P)
	parent = P

/datum/scp247_research_system/proc/log_perception_event(mob/viewer, effect_type)
	viewer_events++
	perception_log["[world.time]"] = list("viewer" = viewer?.ckey, "effect" = effect_type)
