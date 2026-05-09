// SCP-066 - Eric's Toy
// A small metal sphere that produces random sounds with escalating intensity when interacted with.
// Can imitate the appearance of nearby objects.

/obj/item/scp066
	name = "Eric's Toy"
	desc = "A small metal sphere, about the size of a tennis ball. It occasionally produces faint tones."
	icon = 'icons/scp/nonhumanoidscps(32x32).dmi'
	icon_state = "066"
	w_class = WEIGHT_CLASS_SMALL

	force = 0
	throwforce = 0
	throw_range = 7
	throw_speed = 2

	var/interaction_count = 0
	var/cooldown_time = 0
	var/imitating = FALSE
	var/original_icon
	var/original_icon_state
	var/original_name
	var/original_desc

	var/static/list/gentle_sounds = list(
		'sound/scp/scp066/Notes1.ogg',
		'sound/scp/scp066/Notes2.ogg',
		'sound/scp/scp066/Notes3.ogg',
		'sound/scp/scp066/Notes4.ogg',
		'sound/scp/scp066/Notes5.ogg',
		'sound/scp/scp066/Notes6.ogg'
	)

	var/static/list/eric_sounds = list(
		'sound/scp/scp066/Eric1.ogg',
		'sound/scp/scp066/Eric2.ogg',
		'sound/scp/scp066/Eric3.ogg'
	)

/obj/item/scp066/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Eric's Toy", SCP_SAFE, "066")
	original_icon = icon
	original_icon_state = icon_state
	original_name = name
	original_desc = desc

/obj/item/scp066/attack_self(mob/user)
	if(world.time < cooldown_time)
		return

	interaction_count++
	cooldown_time = world.time + 20

	trigger_response(user)

	if(prob(15))
		attempt_imitation()

	hook_scp_interaction(user, "SCP-066", INTERACTION_TYPE_OBSERVATION)

/obj/item/scp066/attack_hand(mob/user)
	if(istype(loc, /mob))
		trigger_response(user)
	return ..()

/obj/item/scp066/pickup(mob/user)
	. = ..()
	if(world.time < cooldown_time)
		return

	interaction_count++
	cooldown_time = world.time + 20

	if(prob(30))
		trigger_response(user)

	if(prob(10))
		attempt_imitation()

	hook_scp_interaction(user, "SCP-066", INTERACTION_TYPE_OBSERVATION)

/obj/item/scp066/proc/trigger_response(mob/user)
	var/severity = get_response_severity()

	switch(severity)
		if(1)
			playsound(src, pick(gentle_sounds), 30, FALSE)
			user.visible_message(
				"<span class='notice'>[src] produces a gentle chime.</span>",
				"<span class='notice'>[src] plays a soft tone in your hands.</span>"
			)
		if(2)
			playsound(src, pick(gentle_sounds), 60, FALSE)
			user.visible_message(
				"<span class='notice'>[src] emits a pleasant melody.</span>",
				"<span class='notice'>[src] plays a pleasant tune.</span>"
			)
		if(3)
			if(prob(50))
				playsound(src, pick(eric_sounds), 70, FALSE)
				user.visible_message(
					"<span class='warning'>[src] says something indistinct.</span>",
					"<span class='warning'>[src] murmurs something you can't quite make out.</span>"
				)
			else
				playsound(src, 'sound/scp/scp066/BeethovenLOUD.ogg', 80, FALSE)
				user.visible_message(
					"<span class='warning'>[src] produces a loud, jarring note!</span>",
					"<span class='warning'>[src] blasts a loud sound, making you wince!</span>"
				)
		if(4)
			playsound(src, 'sound/scp/scp066/BeethovenLOUD.ogg', 100, FALSE)
			user.visible_message(
				"<span class='danger'>[src] blasts a deafening crash of sound!</span>",
				"<span class='danger'>[src] unleashes a deafening crash of sound that rattles your bones!</span>"
			)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.adjustEarDamage(0, 8)
				var/throwdir = pick(GLOB.alldirs)
				var/turf/target_turf = get_ranged_target_turf(H, throwdir, 2)
				if(target_turf)
					H.throw_at(target_turf, 2, 2)
				hook_scp_combat(H, "SCP-066", 0, 15)
		if(5)
			playsound(src, 'sound/scp/scp066/BeethovenLOUD.ogg', 120, FALSE)
			user.visible_message(
				"<span class='bolddanger'>[src] erupts with a catastrophic burst of sound!</span>",
				"<span class='bolddanger'>[src] erupts with an earth-shaking blast of sound!</span>"
			)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.adjustEarDamage(0, 20)
				H.apply_damage(25, BRUTE)
				var/throwdir = pick(GLOB.alldirs)
				var/turf/target_turf = get_ranged_target_turf(H, throwdir, 4)
				if(target_turf)
					H.throw_at(target_turf, 4, 3)
				hook_scp_combat(H, "SCP-066", 25, 30)
				SCP.log_interaction(H, "severe_response")

/obj/item/scp066/proc/get_response_severity()
	var/base_chance = min(interaction_count * 10, 80)

	if(prob(100 - base_chance))
		return 1

	if(interaction_count <= 3)
		return pick(1, 1, 2, 2, 3)

	if(interaction_count <= 7)
		return pick(2, 3, 3, 4)

	if(interaction_count <= 12)
		return pick(3, 4, 4, 5)

	return pick(4, 5, 5)

/obj/item/scp066/proc/attempt_imitation()
	var/list/nearby_items = list()
	for(var/obj/item/I in range(3, src))
		if(I == src)
			continue
		if(I.w_class > WEIGHT_CLASS_NORMAL)
			continue
		nearby_items += I

	if(!length(nearby_items))
		return

	var/obj/item/target = pick(nearby_items)

	imitating = TRUE
	icon = target.icon
	icon_state = target.icon_state
	name = target.name
	desc = "It looks like \a [target.name], but something seems off about it..."

	addtimer(CALLBACK(src, PROC_REF(reset_appearance)), rand(200, 600))

/obj/item/scp066/proc/reset_appearance()
	if(!imitating)
		return
	imitating = FALSE
	icon = original_icon
	icon_state = original_icon_state
	name = original_name
	desc = original_desc

/obj/item/scp066/examine(mob/user)
	. = ..()
	if(imitating)
		. += "<span class='warning'>Something about this [name] seems wrong...</span>"
	else
		. += "<span class='notice'>A small metal sphere. It occasionally produces faint sounds.</span>"

	if(interaction_count > 0 && ishuman(user))
		if(interaction_count >= 10)
			. += "<span class='danger'>It has been handled many times. Further interaction may be extremely dangerous.</span>"
		else if(interaction_count >= 5)
			. += "<span class='warning'>It has been handled several times. It seems to be getting more reactive.</span>"
		else
			. += "<span class='notice'>It has been handled a few times.</span>"

/obj/item/scp066/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		interaction_count++
		trigger_response(H)
		hook_scp_combat(H, "SCP-066", 5, 5)

/obj/item/scp066/proc/on_severe_response(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-066", 25, 30)
