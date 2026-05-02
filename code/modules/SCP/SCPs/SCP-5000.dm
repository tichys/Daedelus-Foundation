// SCP-5000: Probability Manipulation Suit
// A suit that grants its wearer the ability to manipulate probability and create chaos

/obj/item/clothing/suit/scp5000
	name = "probability manipulation suit"
	desc = "A mysterious suit that seems to bend probability to its wearer's will. Strange events occur around it."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "scp5000"
	w_class = 4
	body_parts_covered = 15
	flags_inv = 256
	allowed = list()
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 10, bomb = 10, bio = 100, rad = 100)

	// Probability manipulation abilities
	var/probability_shift_cooldown = 0
	var/probability_shift_cooldown_time = 20 SECONDS
	var/chaos_field_cooldown = 0
	var/chaos_field_cooldown_time = 45 SECONDS
	var/chaos_radius = 6
	var/probability_shift_strength = 0.8
	var/wearer = null

/obj/item/clothing/suit/scp5000/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "probability manipulation suit", SCP_KETER, "5000")
	// Auto-registered via datum/scp

/obj/item/clothing/suit/scp5000/equipped(mob/user, slot)
	. = ..()
	if(slot == 13) // SLOT_WEAR_SUIT
		wearer = user
		to_chat(user, "<span class='notice'>You feel the power of probability manipulation flowing through you!</span>")
		// Add abilities to wearer
		user.verbs += /mob/living/proc/shift_probability_ability
		user.verbs += /mob/living/proc/create_chaos_ability

/obj/item/clothing/suit/scp5000/unequipped(mob/user)
	. = ..()
	if(wearer == user)
		wearer = null
		to_chat(user, "<span class='notice'>The probability manipulation powers fade away.</span>")
		// Remove abilities from wearer
		user.verbs -= /mob/living/proc/shift_probability_ability
		user.verbs -= /mob/living/proc/create_chaos_ability

/obj/item/clothing/suit/scp5000/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This suit grants its wearer the ability to manipulate probability and create chaos.</span>"
	. += "<span class='warning'>Strange events seem to occur around it.</span>"

// Probability manipulation abilities for wearer
/mob/living/proc/shift_probability_ability()
	set name = "Shift Probability"
	set desc = "Manipulate probability in your favor"
	set category = "SCP"

	var/obj/item/clothing/suit/scp5000/suit = locate(/obj/item/clothing/suit/scp5000) in src
	if(!suit)
		to_chat(src, "<span class='warning'>You need to wear the probability manipulation suit!</span>")
		return

	if(suit.probability_shift_cooldown > world.time)
		to_chat(src, "<span class='warning'>Probability shift is still recharging...</span>")
		return

	to_chat(src, "<span class='notice'>You shift probability in your favor.</span>")
	visible_message("<span class='danger'>[src] manipulates the fabric of probability!</span>")

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Random beneficial effects
	var/effect_roll = rand(1, 4)
	switch(effect_roll)
		if(1)
			adjustBruteLoss(-50)
			to_chat(src, "<span class='notice'>Probability shifts heal your wounds!</span>")
		if(2)
			to_chat(src, "<span class='notice'>Probability shifts enhance your defenses!</span>")
		if(3)
			to_chat(src, "<span class='notice'>Probability shifts make you more resilient!</span>")
		if(4)
			adjustBruteLoss(-75)
			to_chat(src, "<span class='notice'>Probability shifts provide incredible healing!</span>")

	suit.probability_shift_cooldown = world.time + suit.probability_shift_cooldown_time

/mob/living/proc/create_chaos_ability()
	set name = "Create Chaos"
	set desc = "Create a field of probability chaos"
	set category = "SCP"

	var/obj/item/clothing/suit/scp5000/suit = locate(/obj/item/clothing/suit/scp5000) in src
	if(!suit)
		to_chat(src, "<span class='warning'>You need to wear the probability manipulation suit!</span>")
		return

	if(suit.chaos_field_cooldown > world.time)
		to_chat(src, "<span class='warning'>Chaos field is still recharging...</span>")
		return

	to_chat(src, "<span class='notice'>You create a field of probability chaos.</span>")
	visible_message("<span class='danger'>[src] creates a field of probability chaos!</span>")

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Affect all living beings in range
	for(var/mob/living/L in range(suit.chaos_radius, src))
		if(L == src)
			continue
		if(L.stat == DEAD)
			continue

		// Random chaotic effects
		var/chaos_effect = rand(1, 5)
		switch(chaos_effect)
			if(1)
				L.adjustBruteLoss(15)
				to_chat(L, "<span class='danger'>Probability chaos causes you harm!</span>")
			if(2)
				L.adjustBruteLoss(20)
				to_chat(L, "<span class='danger'>Reality bends against you!</span>")
			if(3)
				L.adjustBruteLoss(25)
				to_chat(L, "<span class='danger'>Impossible events occur!</span>")
			if(4)
				L.adjustBruteLoss(30)
				to_chat(L, "<span class='danger'>The laws of physics are violated!</span>")
			if(5)
				L.adjustBruteLoss(35)
				to_chat(L, "<span class='danger'>Probability itself attacks you!</span>")

		suit.SCP.log_interaction(L, "probability_chaos_field")
		suit.SCP.award_research(L, "anomaly", 20)

	suit.chaos_field_cooldown = world.time + suit.chaos_field_cooldown_time

/obj/item/clothing/suit/scp5000/proc/on_probability_shift(mob/living/carbon/human/wearer)
	if(!wearer)
		return
	hook_scp_interaction(wearer, "SCP-5000", INTERACTION_TYPE_CONTAINMENT)

/obj/item/clothing/suit/scp5000/proc/on_chaos_field(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-5000", 25, 0)


