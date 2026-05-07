// SCP-427: Healing Locket
// A small, ornately carved locket that provides healing but can transform the user if overused

/obj/item/clothing/accessory/scp427
	name = "ornate locket"
	desc = "A small, ornately carved locket made out of polished silver material."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "locket"
	w_class = 2
	slot_flags = 256 | 512 // SLOT_MASK | SLOT_TIE
	var/locket_open = FALSE

	// Transformation tracking
	var/list/time_used = list()
	var/transformation_time_min = 90 // Time before transformation becomes possible
	var/transformation_time_max = 900 // Time when transformation probability is maximum
	var/transformation_max_prob = 4 // Maximum probability per tick

/obj/item/clothing/accessory/scp427/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Ornate Locket", SCP_SAFE, "427")
	// Auto-registered via datum/scp

/obj/item/clothing/accessory/scp427/process()
	var/mob/living/carbon/human/user = loc
	if(!istype(user))
		return

	if(!locket_open)
		return

	var/user_key = user.ckey || "\ref[user]"
	if(!(user_key in time_used))
		time_used[user_key] = 0

	time_used[user_key] += 1

	user.adjustBruteLoss(-10)
	user.adjustFireLoss(-10)
	user.adjustToxLoss(-5)
	user.adjustOxyLoss(-5)

	SCP.log_interaction(user, "healing")
	SCP.award_research(user, "anomaly", 5)

	if(time_used[user_key] < transformation_time_min)
		return

	var/transform_prob = transformation_max_prob * min(1, time_used[user_key] / transformation_time_max)
	if(prob(transform_prob))
		transform_user(user)

/obj/item/clothing/accessory/scp427/proc/transform_user(mob/living/carbon/human/user)
	var/turf/user_turf = get_turf(user)
	forceMove(user_turf)

	playsound(user_turf, 'sound/effects/explosion1.ogg', 75, TRUE, 12)
	user.visible_message(
		"<span class='danger'>[user] turns into an unknown monstrosity as [src] falls to the ground!</span>",
		"<span class='userdanger'>Your body turns into something unrecognizable! It's over!</span>"
	)

	// Log the transformation
	SCP.log_interaction(user, "transformation")
	SCP.award_research(user, "anomaly", 50)

	user.ghostize(TRUE)
	user.dust()
	// Create a simple hostile mob instead of the undefined abomination
	var/mob/living/simple_animal/hostile/monster = new /mob/living/simple_animal/hostile(user_turf)
	monster.name = "unknown monstrosity"
	monster.desc = "A horrifying creature that was once human."

/obj/item/clothing/accessory/scp427/attack_self(mob/user)
	locket_open = !locket_open
	to_chat(user, "You flip \the [src] [locket_open ? "open" : "closed"].")

	if(locket_open)
		icon_state = "locket_open"
		START_PROCESSING(SSobj, src)
		to_chat(user, "<span class='notice'>You feel a warm, healing energy emanating from the locket.</span>")
	else
		icon_state = "locket"
		STOP_PROCESSING(SSobj, src)
		to_chat(user, "<span class='notice'>The healing energy fades as you close the locket.</span>")

/obj/item/clothing/accessory/scp427/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This ornate locket seems to have healing properties when opened.</span>"
	if(locket_open)
		. += "<span class='warning'>The locket is open and emanating healing energy.</span>"
		if(user in time_used)
			var/usage_time = time_used[user]
			if(usage_time > transformation_time_min)
				. += "<span class='danger'>You have used the locket extensively. Continued use may be dangerous.</span>"
			else
				. += "<span class='notice'>You have used the locket for [usage_time] seconds.</span>"

/obj/item/clothing/accessory/scp427/equipped(mob/user, slot)
	. = ..()
	if(locket_open)
		to_chat(user, "<span class='notice'>The locket's healing energy flows through you.</span>")

/obj/item/clothing/accessory/scp427/unequipped(mob/user)
	. = ..()
	if(user in time_used)
		to_chat(user, "<span class='notice'>The locket's effects fade as you remove it.</span>")

/obj/item/clothing/accessory/scp427/proc/on_healing_applied(mob/living/carbon/human/patient, amount)
	if(!patient)
		return
	hook_scp_care(patient, "SCP-427", "healing")

/obj/item/clothing/accessory/scp427/proc/on_transformation(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_breach("SCP-427", src)
	hook_player_death_near_scp(victim, "SCP-427")
