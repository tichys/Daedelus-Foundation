/obj/item/clothing/ring/scp399
	name = "metallic ring"
	desc = "A ring consisting of two metallic bands with six purple glass segments set between them. It hums faintly when held."
	icon = 'icons/scp/scp-399.dmi'
	icon_state = "scp399"
	w_class = WEIGHT_CLASS_SMALL

	var/active = FALSE
	var/manipulation_range = 5
	var/energy_drain_radius = 3
	var/cooldown_time = 30 SECONDS
	var/next_activation = 0
	var/drain_timer = 0

	var/manipulations_performed = 0

/obj/item/clothing/ring/scp399/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Atomic Manipulation Ring", SCP_EUCLID, "399")
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-399"] = new /datum/scp_instance("SCP-399", src)

/obj/item/clothing/ring/scp399/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == ITEM_SLOT_GLOVES)
		active = TRUE
		to_chat(user, span_warning("The ring tightens on your finger. You feel a faint drain on your vitality as objects around you seem... mutable."))
		hook_scp_interaction(user, "SCP-399", INTERACTION_TYPE_OBSERVATION)
		START_PROCESSING(SSobj, src)

/obj/item/clothing/ring/scp399/dropped(mob/living/carbon/human/user)
	..()
	active = FALSE
	drain_timer = 0
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/ring/scp399/process()
	if(!active)
		return

	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || wearer.gloves != src)
		active = FALSE
		return

	drain_timer++

	if(drain_timer % 10 == 0)
		wearer.adjustStaminaLoss(2)
		for(var/mob/living/carbon/human/H in range(energy_drain_radius, wearer))
			if(H == wearer)
				continue
			H.adjustStaminaLoss(1)

		if(prob(10))
			var/list/drained_things = list()
			for(var/obj/machinery/M in range(energy_drain_radius, wearer))
				if(M.use_power && M.powernet)
					drained_things += M.name
			if(length(drained_things))
				to_chat(wearer, span_notice("You sense energy being drawn from [pick(drained_things)]."))

/obj/item/clothing/ring/scp399/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !active)
		return

	if(world.time < next_activation)
		to_chat(user, span_warning("The ring's segments are dark. It needs time to recharge."))
		return

	var/list/nearby_objects = list()
	for(var/obj/O in range(manipulation_range, user))
		if(O == src || O == user || istype(O, /obj/effect) || O.anchored)
			continue
		if(isitem(O) || isstructure(O))
			nearby_objects[O.name] = O

	if(!length(nearby_objects))
		to_chat(user, span_notice("There are no suitable objects nearby to manipulate."))
		return

	var/choice = input(user, "Select an object to reshape:", "SCP-399 Manipulation") as null|anything in nearby_objects
	if(!choice || !(choice in nearby_objects))
		return

	var/obj/target = nearby_objects[choice]
	if(!target || get_dist(user, target) > manipulation_range)
		return

	next_activation = world.time + cooldown_time
	manipulations_performed++

	hook_scp_interaction(user, "SCP-399", INTERACTION_TYPE_RESEARCH)

	user.visible_message(span_danger("[user]'s ring flares with purple light as [target] begins to warp and reshape!"), span_notice("The ring's segments glow as you manipulate the atomic structure of [target]."))

	var/effect = rand(1, 5)
	switch(effect)
		if(1)
			target.color = pick("#ff0000", "#00ff00", "#0000ff", "#ff00ff", "#ffff00")
			target.visible_message(span_warning("[target] shifts in color!"))
		if(2)
			var/matrix/M = target.transform
			target.transform = M.Scale(rand(5, 15) / 10, rand(5, 15) / 10)
			target.visible_message(span_warning("[target] stretches and warps!"))
		if(3)
			var/matrix/M = target.transform
			target.transform = M.Turn(rand(45, 315))
			target.visible_message(span_warning("[target] rotates unnaturally!"))
		if(4)
			target.alpha = rand(50, 200)
			target.visible_message(span_warning("[target] becomes partially transparent!"))
		if(5)
			if(isitem(target))
				var/obj/item/I = target
				I.force = rand(0, I.force + 10)
				I.throwforce = rand(0, I.throwforce + 5)
			target.visible_message(span_warning("[target]'s material composition seems to shift!"))

	apply_energy_drain(user)

/obj/item/clothing/ring/scp399/proc/apply_energy_drain(mob/living/carbon/human/wearer)
	if(!wearer)
		return

	wearer.adjustStaminaLoss(15)

	for(var/mob/living/carbon/human/H in range(energy_drain_radius, wearer))
		if(H == wearer)
			continue
		H.adjustStaminaLoss(5)

	for(var/obj/machinery/M in range(energy_drain_radius, wearer))
		if(M.use_power)
			M.use_power(500)

/obj/item/clothing/ring/scp399/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A ring with two metallic bands and six purple glass segments. When worn, it allows manipulation of nearby inanimate objects."))
	to_chat(user, span_notice("Manipulations performed: [manipulations_performed]"))
	if(active)
		to_chat(user, span_warning("The ring hums on your finger, drawing energy from the environment."))
