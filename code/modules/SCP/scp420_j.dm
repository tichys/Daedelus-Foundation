// SCP-420-J: The Best Joke
// An item that causes uncontrollable laughter and can spread to nearby humans

/obj/item/scp420_j
	name = "SCP-420-J"
	desc = "A small piece of paper with what appears to be a joke written on it. It seems to be the best joke ever."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "scp420_j"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	var/list/affected_humans = list()
	var/laughter_intensity = 1
	var/max_intensity = 5
	var/laughter_cooldown = 0
	var/LAUGHTER_COOLDOWN = 15 SECONDS
	var/spread_cooldown = 0
	var/SPREAD_COOLDOWN = 30 SECONDS
	var/list/joke_variations = list(
		"Why did the SCP cross the road? To get to the other containment chamber!",
		"What do you call a D-Class who survives? A miracle!",
		"Why don't scientists trust atoms? Because they make up everything!",
		"What's the difference between a Foundation researcher and a pizza? A pizza can feed a family of four!",
		"Why did the MTF agent go to the doctor? Because he was feeling a bit... contained!"
	)

/obj/item/scp420_j/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"best joke",
		SCP_SAFE,
		"420-J",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL | MAUDIBLE | MPERSISTENT
	SCP.memetic_proc = TYPE_PROC_REF(/obj/item/scp420_j, laughter_effect)
	SCP.compInit()

	add_verb(src, list(
		/obj/item/scp420_j/proc/TellJoke,
		/obj/item/scp420_j/proc/IncreaseIntensity,
		/obj/item/scp420_j/proc/SpreadLaughter,
		/obj/item/scp420_j/proc/InteractWithSCP,
	))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

/obj/item/scp420_j/Destroy()
	QDEL_NULL(SCP)
	return ..()

/obj/item/scp420_j/proc/laughter_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply laughter effects
	H.adjustSanity(10, "scp420_j_laughter")
	H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
	H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
	H.add_sanity_effect(SANITY_EFFECT_CALM, 180 SECONDS, laughter_intensity)

	// Apply vision effects
	// Vision effects removed (Foundation-19 style)

	// Make the human laugh
	H.emote("laugh")
	to_chat(H, span_notice("You can't help but laugh at the joke! It's the best joke ever!"))

	// Add to affected list
	if(!(H in affected_humans))
		affected_humans += H

// SCP-420-J abilities
/obj/item/scp420_j/proc/TellJoke()
	set category = "SCP-420-J"
	set name = "Tell Joke"

	if(world.time < laughter_cooldown)
		to_chat(usr, span_warning("You need time to recover from the last joke."))
		return

	// Tell a joke
	var/joke = pick(joke_variations)
	to_chat(usr, span_notice("You tell the joke: [joke]"))
	usr.say(joke, forced = "SCP-420-J")

	// Apply effects to nearby humans
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat == DEAD)
			continue

		to_chat(H, span_notice("You hear the joke and can't help but laugh!"))
		H.adjustSanity(15, "scp420_j_joke")
		H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
		H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		H.add_sanity_effect(SANITY_EFFECT_CALM, 240 SECONDS, laughter_intensity)
		H.emote("laugh")

		// Add to affected list
		if(!(H in affected_humans))
			affected_humans += H

	laughter_cooldown = world.time + LAUGHTER_COOLDOWN
	playsound(src, 'sound/scp/scp420_j/laugh.ogg', 50, TRUE)

	to_chat(usr, span_notice("The joke spreads joy to everyone who hears it!"))
	SEND_SIGNAL(src, COMSIG_SCP420_J_JOKE_TOLD, joke)

/obj/item/scp420_j/proc/IncreaseIntensity()
	set category = "SCP-420-J"
	set name = "Increase Intensity"

	if(laughter_intensity >= max_intensity)
		to_chat(usr, span_warning("The laughter intensity is already at maximum."))
		return

	laughter_intensity++
	to_chat(usr, span_notice("You increase the laughter intensity to [laughter_intensity]."))

	// Apply increased effects to affected humans
	for(var/mob/living/carbon/human/H in affected_humans)
		if(H.stat == DEAD)
			continue

		H.adjustSanity(5, "scp420_j_intensity_increase")
		H.add_sanity_effect(SANITY_EFFECT_CALM, 120 SECONDS, laughter_intensity)

	SEND_SIGNAL(src, COMSIG_SCP420_J_INTENSITY_INCREASED, laughter_intensity)

/obj/item/scp420_j/proc/SpreadLaughter()
	set category = "SCP-420-J"
	set name = "Spread Laughter"

	if(world.time < spread_cooldown)
		to_chat(usr, span_warning("You need time to recharge the laughter spread ability."))
		return

	// Spread laughter to a wider area
	for(var/mob/living/carbon/human/H in range(8, src))
		if(H.stat == DEAD)
			continue

		to_chat(H, span_notice("You feel an overwhelming urge to laugh!"))
		H.adjustSanity(20, "scp420_j_spread")
		H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
		H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
		H.add_sanity_effect(SANITY_EFFECT_CALM, 300 SECONDS, laughter_intensity)
		H.emote("laugh")

		// Add to affected list
		if(!(H in affected_humans))
			affected_humans += H

	spread_cooldown = world.time + SPREAD_COOLDOWN
	playsound(src, 'sound/scp/scp420_j/spread.ogg', 50, TRUE)

	to_chat(usr, span_notice("You spread contagious laughter throughout the area!"))
	SEND_SIGNAL(src, COMSIG_SCP420_J_LAUGHTER_SPREAD)

/obj/item/scp420_j/proc/InteractWithSCP()
	set category = "SCP-420-J"
	set name = "Interact with SCP"

	var/list/nearby_scps = list()
	for(var/atom/A in range(3, src))
		if(A.SCP && A != src)
			nearby_scps += A

	if(!nearby_scps.len)
		to_chat(usr, span_warning("No SCPs nearby to interact with."))
		return

	var/atom/selected_scp = input(usr, "Select SCP to interact with:", "SCP Interaction") as null|anything in nearby_scps
	if(!selected_scp)
		return

	// SCP-specific interactions
	var/scp_id = selected_scp.SCP.designation
	switch(scp_id)
		if("049")
			interact_with_049(selected_scp)
		if("096")
			interact_with_096(selected_scp)
		if("173")
			interact_with_173(selected_scp)
		if("106")
			interact_with_106(selected_scp)
		else
			generic_scp_interaction(selected_scp)

/obj/item/scp420_j/proc/interact_with_049(atom/scp049)
	to_chat(usr, span_notice("You tell a joke to SCP-049."))
	SEND_SIGNAL(scp049, COMSIG_SCP049_JOKE_TOLD, src)

/obj/item/scp420_j/proc/interact_with_096(atom/scp096)
	to_chat(usr, span_notice("You attempt to make SCP-096 laugh."))
	if(prob(40))
		to_chat(usr, span_green("You successfully make SCP-096 laugh!"))
		SEND_SIGNAL(scp096, COMSIG_SCP096_LAUGHED, src)
	else
		to_chat(usr, span_warning("SCP-096 doesn't find the joke funny."))

/obj/item/scp420_j/proc/interact_with_173(atom/scp173)
	to_chat(usr, span_notice("You tell a joke to SCP-173."))
	to_chat(usr, span_warning("SCP-173 doesn't seem to respond to jokes."))

/obj/item/scp420_j/proc/interact_with_106(atom/scp106)
	to_chat(usr, span_notice("You attempt to make SCP-106 laugh."))
	to_chat(usr, span_warning("SCP-106 doesn't seem amused."))

/obj/item/scp420_j/proc/generic_scp_interaction(atom/scp)
	to_chat(usr, span_notice("You tell a joke to [scp.name]."))

// Cross-SCP interaction methods
/obj/item/scp420_j/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-420-J can help resist SCP-106's corrosion
	if(victim in range(5, src))
		to_chat(victim, span_notice("The joke helps you resist the corrosive effect!"))
		victim.adjustSanity(10, "joke_corrosion_resistance")

/obj/item/scp420_j/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-420-J can enhance SCP-049's cure
	if(patient in range(5, src))
		to_chat(patient, span_notice("The joke enhances the cure's effectiveness!"))
		patient.adjustSanity(15, "enhanced_cure_joke")

/obj/item/scp420_j/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-420-J can calm SCP-096's rage
	if(target in range(5, src))
		to_chat(target, span_notice("The joke helps calm your rage!"))
		target.adjustSanity(20, "joke_rage_calm")
		target.remove_sanity_effect(SANITY_EFFECT_AGGRESSION)

/obj/item/scp420_j/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-420-J can help resist SCP-173's effects
	if(viewer in range(5, src))
		to_chat(viewer, span_notice("The joke helps you resist the statue's gaze!"))
		viewer.adjustSanity(12, "joke_statue_resistance")

/obj/item/scp420_j/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-420-J can enhance SCP-682's adaptation
	if(adaptor in range(5, src))
		to_chat(adaptor, span_notice("The joke enhances your adaptation process!"))
		adaptor.adjustSanity(10, "joke_adaptation_enhancement")

/obj/item/scp420_j/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-420-J can interact with SCP-035's possession
	if(host in range(5, src))
		to_chat(host, span_notice("The mask's personality finds the joke hilarious!"))
		host.adjustSanity(15, "mask_joke_amusement")

/obj/item/scp420_j/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-420-J can help resist SCP-087's effects
	if(explorer in range(5, src))
		to_chat(explorer, span_notice("The joke helps you resist the stairwell's psychological pressure!"))
		explorer.adjustSanity(18, "joke_stairwell_resistance")

// Research system integration
/obj/item/scp420_j/proc/get_research_data()
	var/list/data = list()
	data["affected_humans"] = length(affected_humans)
	data["laughter_intensity"] = laughter_intensity
	data["max_intensity"] = max_intensity
	data["laughter_cooldown_remaining"] = max(0, laughter_cooldown - world.time)
	data["spread_cooldown_remaining"] = max(0, spread_cooldown - world.time)
	data["joke_variations"] = length(joke_variations)
	return data

// SCP-420-J Laughter Aura
/obj/effect/scp420_j_aura
	name = "Laughter Aura"
	desc = "An area filled with contagious laughter."
	icon = 'icons/effects/effects.dmi'
	icon_state = "scp420_j_aura"
	layer = ABOVE_MOB_LAYER
	invisibility = INVISIBILITY_ABSTRACT
	var/aura_range = 4
	var/list/affected_humans = list()
	var/aura_duration = 0
	var/AURA_DURATION = 3 MINUTES

/obj/effect/scp420_j_aura/Initialize()
	. = ..()
	aura_duration = world.time + AURA_DURATION
	START_PROCESSING(SSobj, src)

/obj/effect/scp420_j_aura/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/scp420_j_aura/process()
	. = ..()
	if(world.time >= aura_duration)
		qdel(src)
		return

	// Apply laughter aura effects
	for(var/mob/living/carbon/human/H in range(aura_range, src))
		if(H.stat == DEAD)
			continue

		// Apply continuous laughter effects
		H.adjustSanity(1, "scp420_j_aura")
		H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
		H.add_sanity_effect(SANITY_EFFECT_CALM, 60 SECONDS, 1)

		// Chance to laugh
		if(prob(10))
			H.emote("laugh")

		// Add to affected list
		if(!(H in affected_humans))
			affected_humans += H

	// Clean up affected list
	for(var/mob/living/carbon/human/H in affected_humans)
		if(!(H in range(aura_range, src)))
			affected_humans -= H






