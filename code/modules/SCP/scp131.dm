// SCP-131: The Eye Pods
// Two friendly, curious creatures that follow humans and provide comfort

/mob/living/simple_animal/hostile/scp131_a
	name = "SCP-131-A"
	desc = "A small, teardrop-shaped creature with a single large eye. It appears to be friendly and curious."
	icon = 'icons/mob/animal.dmi'
	icon_state = "scp131_a"
	icon_living = "scp131_a"
	icon_dead = "scp131_a_dead"
	maxHealth = 150
	health = 150
	see_in_dark = 8
	move_to_delay = 2
	response_help_continuous = "pets"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "hits"
	friendly_verb_continuous = "nuzzles"
	friendly_verb_simple = "nuzzle"
	harm_intent_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = 'sound/effects/slime_squish.ogg'
	environment_smash = ENVIRONMENT_SMASH_NONE
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE
	// Make it non-aggressive
	AIStatus = AI_OFF

	// SCP-131 specific variables
	var/mob/living/carbon/human/following_human
	var/comfort_range = 3
	var/list/comforted_humans = list()
	var/comfort_cooldown = 0
	var/COMFORT_COOLDOWN = 30 SECONDS
	var/curiosity_level = 1
	var/max_curiosity = 5

/mob/living/simple_animal/hostile/scp131_a/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"eye pod",
		SCP_SAFE,
		"131-A",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/simple_animal/hostile/scp131_a, comfort_effect)
	SCP.compInit()

	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp131_a/proc/FollowHuman,
		/mob/living/simple_animal/hostile/scp131_a/proc/ProvideComfort,
		/mob/living/simple_animal/hostile/scp131_a/proc/ShowCuriosity,
		/mob/living/simple_animal/hostile/scp131_a/proc/InteractWithSCP,
	))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, .proc/on_corrosion_applied)
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, .proc/on_cure_started)
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, .proc/on_rage_triggered)
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, .proc/on_eye_contact)
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, .proc/on_adaptation)
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, .proc/on_possession_started)
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, .proc/on_exploration_started)

	// Start comfort aura
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/scp131_a/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

/mob/living/simple_animal/hostile/scp131_a/process()
	. = ..()
	apply_comfort_aura()
	follow_human()

/mob/living/simple_animal/hostile/scp131_a/proc/comfort_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply comfort effects
	H.adjustSanity(8, "scp131_comfort")
	H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
	H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
	H.add_sanity_effect(SANITY_EFFECT_CALM, 120 SECONDS, 1)

	// Apply vision effects
	// Vision effects removed (Foundation-19 style)

	to_chat(H, span_notice("SCP-131-A's presence makes you feel calmer and more at ease."))

/mob/living/simple_animal/hostile/scp131_a/proc/apply_comfort_aura()
	for(var/mob/living/carbon/human/H in range(comfort_range, src))
		if(H.stat == DEAD)
			continue

		// Apply continuous comfort effects
		H.adjustSanity(1, "scp131_aura")

		// Chance to provide stronger comfort
		if(prob(15))
			H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
			H.add_sanity_effect(SANITY_EFFECT_CALM, 90 SECONDS, 1)

		// Add to comforted list
		if(!(H in comforted_humans))
			comforted_humans += H

	// Clean up comforted list
	for(var/mob/living/carbon/human/H in comforted_humans)
		if(!(H in range(comfort_range, src)))
			comforted_humans -= H

/mob/living/simple_animal/hostile/scp131_a/proc/follow_human()
	if(!following_human || following_human.stat == DEAD || !(following_human in range(10, src)))
		// Find new human to follow
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD)
				following_human = H
				to_chat(src, span_notice("You decide to follow [H.name]."))
				break
		return

	// Follow the human
	if(get_dist(src, following_human) > 2)
		step_towards(src, following_human)

// SCP-131 abilities
/mob/living/simple_animal/hostile/scp131_a/proc/FollowHuman()
	set category = "SCP-131-A"
	set name = "Follow Human"

	var/list/nearby_humans = list()
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat != DEAD)
			nearby_humans += H

	if(length(nearby_humans) == 0)
		to_chat(src, span_warning("No humans nearby to follow."))
		return

	var/mob/living/carbon/human/target = input(src, "Choose a human to follow:", "Follow Human") as null|mob in nearby_humans
	if(!target)
		return

	following_human = target
	to_chat(src, span_notice("You start following [target.name]."))
	to_chat(target, span_notice("SCP-131-A starts following you curiously."))

/mob/living/simple_animal/hostile/scp131_a/proc/ProvideComfort()
	set category = "SCP-131-A"
	set name = "Provide Comfort"

	if(world.time < comfort_cooldown)
		to_chat(src, span_warning("You need time to recharge your comfort ability."))
		return

	// Provide comfort to nearby humans
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat == DEAD)
			continue

		to_chat(H, span_notice("SCP-131-A nuzzles you gently, providing comfort."))
		H.adjustSanity(15, "scp131_comfort_ability")
		H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
		H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
		H.add_sanity_effect(SANITY_EFFECT_CALM, 180 SECONDS, 2)

	comfort_cooldown = world.time + COMFORT_COOLDOWN
	playsound(src, 'sound/scp/scp131/comfort.ogg', 50, TRUE)

	to_chat(src, span_notice("You provide comfort to nearby humans."))
	SEND_SIGNAL(src, COMSIG_SCP131_COMFORT_PROVIDED)

/mob/living/simple_animal/hostile/scp131_a/proc/ShowCuriosity()
	set category = "SCP-131-A"
	set name = "Show Curiosity"

	// Show curiosity about nearby objects
	var/list/nearby_objects = list()
	for(var/obj/O in range(2, src))
		if(O != src)
			nearby_objects += O

	if(length(nearby_objects) == 0)
		to_chat(src, span_warning("Nothing interesting nearby."))
		return

	var/obj/target = pick(nearby_objects)
	to_chat(src, span_notice("You examine [target.name] with great curiosity."))

	// Apply curiosity effects to nearby humans
	for(var/mob/living/carbon/human/H in range(3, src))
		to_chat(H, span_notice("SCP-131-A seems very interested in [target.name]."))
		H.adjustSanity(3, "scp131_curiosity")

	curiosity_level = min(curiosity_level + 1, max_curiosity)
	playsound(src, 'sound/scp/scp131/curious.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP131_CURIOSITY_SHOWN, target)

/mob/living/simple_animal/hostile/scp131_a/proc/InteractWithSCP()
	set category = "SCP-131-A"
	set name = "Interact with SCP"

	var/list/nearby_scps = list()
	for(var/atom/A in range(3, src))
		if(A.SCP && A != src)
			nearby_scps += A

	if(!nearby_scps.len)
		to_chat(src, span_warning("No SCPs nearby to interact with."))
		return

	var/atom/selected_scp = input(src, "Select SCP to interact with:", "SCP Interaction") as null|anything in nearby_scps
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

/mob/living/simple_animal/hostile/scp131_a/proc/interact_with_049(atom/scp049)
	to_chat(src, span_notice("You provide comfort to SCP-049."))
	SEND_SIGNAL(scp049, COMSIG_SCP049_COMFORTED, src)

/mob/living/simple_animal/hostile/scp131_a/proc/interact_with_096(atom/scp096)
	to_chat(src, span_notice("You attempt to calm SCP-096."))
	if(prob(60))
		to_chat(src, span_green("You successfully calm SCP-096."))
		SEND_SIGNAL(scp096, COMSIG_SCP096_CALMED, src)
	else
		to_chat(src, span_warning("SCP-096 is too enraged to calm."))

/mob/living/simple_animal/hostile/scp131_a/proc/interact_with_173(atom/scp173)
	to_chat(src, span_notice("You attempt to comfort SCP-173."))
	to_chat(src, span_warning("SCP-173 doesn't seem to respond to comfort."))

/mob/living/simple_animal/hostile/scp131_a/proc/interact_with_106(atom/scp106)
	to_chat(src, span_notice("You attempt to comfort SCP-106."))
	to_chat(src, span_warning("SCP-106 seems unaffected by your comfort."))

/mob/living/simple_animal/hostile/scp131_a/proc/generic_scp_interaction(atom/scp)
	to_chat(src, span_notice("You provide comfort to [scp.name]."))

// Cross-SCP interaction methods
/mob/living/simple_animal/hostile/scp131_a/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can distress SCP-131
	if(victim in range(5, src))
		to_chat(src, span_warning("The corrosive effect distresses you!"))
		// Simple animals don't have sanity, just show distress

/mob/living/simple_animal/hostile/scp131_a/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can be comforting to SCP-131
	if(patient in range(5, src))
		to_chat(src, span_notice("The cure's power feels comforting to you."))
		// Simple animals don't have sanity, just show comfort

/mob/living/simple_animal/hostile/scp131_a/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can frighten SCP-131
	if(target in range(5, src))
		to_chat(src, span_warning("The rage frightens you!"))
		// Simple animals don't have sanity, just show fear

/mob/living/simple_animal/hostile/scp131_a/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-131
	if(viewer in range(5, src))
		to_chat(viewer, span_danger("You see a statue near the eye pod!"))
		viewer.adjustSanity(-10, "scp173_near_131")

/mob/living/simple_animal/hostile/scp131_a/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can interest SCP-131
	if(adaptor in range(5, src))
		to_chat(src, span_notice("The adaptation process fascinates you."))
		curiosity_level = min(curiosity_level + 1, max_curiosity)

/mob/living/simple_animal/hostile/scp131_a/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-131
	if(host in range(5, src))
		to_chat(host, span_notice("The mask's personality finds the eye pod adorable."))
		host.adjustSanity(8, "mask_131_interest")

/mob/living/simple_animal/hostile/scp131_a/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can distress SCP-131
	if(explorer in range(5, src))
		to_chat(src, span_warning("The stairwell's presence distresses you!"))
		// Simple animals don't have sanity, just show distress

// Research system integration
/mob/living/simple_animal/hostile/scp131_a/proc/get_research_data()
	var/list/data = list()
	data["health"] = health
	data["max_health"] = maxHealth
	data["comforted_humans"] = length(comforted_humans)
	data["comfort_range"] = comfort_range
	data["curiosity_level"] = curiosity_level
	data["max_curiosity"] = max_curiosity
	data["following_human"] = following_human ? following_human.name : "None"
	data["comfort_cooldown_remaining"] = max(0, comfort_cooldown - world.time)
	return data

// SCP-131-B (Second Eye Pod)
/mob/living/simple_animal/hostile/scp131_b
	name = "SCP-131-B"
	desc = "A small, teardrop-shaped creature with a single large eye. It appears to be friendly and curious."
	icon = 'icons/mob/animal.dmi'
	icon_state = "scp131_b"
	icon_living = "scp131_b"
	icon_dead = "scp131_b_dead"
	maxHealth = 150
	health = 150
	see_in_dark = 8
	move_to_delay = 2
	response_help_continuous = "pets"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "hits"
	friendly_verb_continuous = "nuzzles"
	friendly_verb_simple = "nuzzle"
	harm_intent_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = 'sound/effects/slime_squish.ogg'
	environment_smash = ENVIRONMENT_SMASH_NONE
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE
	// Make it non-aggressive
	AIStatus = AI_OFF

	// SCP-131-B specific variables
	var/mob/living/carbon/human/following_human
	var/comfort_range = 3
	var/list/comforted_humans = list()
	var/comfort_cooldown = 0
	var/COMFORT_COOLDOWN = 30 SECONDS
	var/curiosity_level = 1
	var/max_curiosity = 5

/mob/living/simple_animal/hostile/scp131_b/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"eye pod",
		SCP_SAFE,
		"131-B",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/simple_animal/hostile/scp131_b, comfort_effect)
	SCP.compInit()

	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp131_b/proc/FollowHuman,
		/mob/living/simple_animal/hostile/scp131_b/proc/ProvideComfort,
		/mob/living/simple_animal/hostile/scp131_b/proc/ShowCuriosity,
		/mob/living/simple_animal/hostile/scp131_b/proc/InteractWithSCP,
	))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, .proc/on_corrosion_applied)
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, .proc/on_cure_started)
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, .proc/on_rage_triggered)
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, .proc/on_eye_contact)
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, .proc/on_adaptation)
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, .proc/on_possession_started)
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, .proc/on_exploration_started)

	// Start comfort aura
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/scp131_b/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

/mob/living/simple_animal/hostile/scp131_b/process()
	. = ..()
	apply_comfort_aura()
	follow_human()

/mob/living/simple_animal/hostile/scp131_b/proc/comfort_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply comfort effects
	H.adjustSanity(8, "scp131_comfort")
	H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
	H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
	H.add_sanity_effect(SANITY_EFFECT_CALM, 120 SECONDS, 1)

	// Apply vision effects
	// Vision effects removed (Foundation-19 style)

	to_chat(H, span_notice("SCP-131-B's presence makes you feel calmer and more at ease."))

/mob/living/simple_animal/hostile/scp131_b/proc/apply_comfort_aura()
	for(var/mob/living/carbon/human/H in range(comfort_range, src))
		if(H.stat == DEAD)
			continue

		// Apply continuous comfort effects
		H.adjustSanity(1, "scp131_aura")

		// Chance to provide stronger comfort
		if(prob(15))
			H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
			H.add_sanity_effect(SANITY_EFFECT_CALM, 90 SECONDS, 1)

		// Add to comforted list
		if(!(H in comforted_humans))
			comforted_humans += H

	// Clean up comforted list
	for(var/mob/living/carbon/human/H in comforted_humans)
		if(!(H in range(comfort_range, src)))
			comforted_humans -= H

/mob/living/simple_animal/hostile/scp131_b/proc/follow_human()
	if(!following_human || following_human.stat == DEAD || !(following_human in range(10, src)))
		// Find new human to follow
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD)
				following_human = H
				to_chat(src, span_notice("You decide to follow [H.name]."))
				break
		return

	// Follow the human
	if(get_dist(src, following_human) > 2)
		step_towards(src, following_human)

// SCP-131-B abilities (same as A but with different names)
/mob/living/simple_animal/hostile/scp131_b/proc/FollowHuman()
	set category = "SCP-131-B"
	set name = "Follow Human"

	var/list/nearby_humans = list()
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat != DEAD)
			nearby_humans += H

	if(length(nearby_humans) == 0)
		to_chat(src, span_warning("No humans nearby to follow."))
		return

	var/mob/living/carbon/human/target = input(src, "Choose a human to follow:", "Follow Human") as null|mob in nearby_humans
	if(!target)
		return

	following_human = target
	to_chat(src, span_notice("You start following [target.name]."))
	to_chat(target, span_notice("SCP-131-B starts following you curiously."))

/mob/living/simple_animal/hostile/scp131_b/proc/ProvideComfort()
	set category = "SCP-131-B"
	set name = "Provide Comfort"

	if(world.time < comfort_cooldown)
		to_chat(src, span_warning("You need time to recharge your comfort ability."))
		return

	// Provide comfort to nearby humans
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat == DEAD)
			continue

		to_chat(H, span_notice("SCP-131-B nuzzles you gently, providing comfort."))
		H.adjustSanity(15, "scp131_comfort_ability")
		H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
		H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
		H.add_sanity_effect(SANITY_EFFECT_CALM, 180 SECONDS, 2)

	comfort_cooldown = world.time + COMFORT_COOLDOWN
	playsound(src, 'sound/scp/scp131/comfort.ogg', 50, TRUE)

	to_chat(src, span_notice("You provide comfort to nearby humans."))
	SEND_SIGNAL(src, COMSIG_SCP131_COMFORT_PROVIDED)

/mob/living/simple_animal/hostile/scp131_b/proc/ShowCuriosity()
	set category = "SCP-131-B"
	set name = "Show Curiosity"

	// Show curiosity about nearby objects
	var/list/nearby_objects = list()
	for(var/obj/O in range(2, src))
		if(O != src)
			nearby_objects += O

	if(length(nearby_objects) == 0)
		to_chat(src, span_warning("Nothing interesting nearby."))
		return

	var/obj/target = pick(nearby_objects)
	to_chat(src, span_notice("You examine [target.name] with great curiosity."))

	// Apply curiosity effects to nearby humans
	for(var/mob/living/carbon/human/H in range(3, src))
		to_chat(H, span_notice("SCP-131-B seems very interested in [target.name]."))
		H.adjustSanity(3, "scp131_curiosity")

	curiosity_level = min(curiosity_level + 1, max_curiosity)
	playsound(src, 'sound/scp/scp131/curious.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP131_CURIOSITY_SHOWN, target)

/mob/living/simple_animal/hostile/scp131_b/proc/InteractWithSCP()
	set category = "SCP-131-B"
	set name = "Interact with SCP"

	var/list/nearby_scps = list()
	for(var/atom/A in range(3, src))
		if(A.SCP && A != src)
			nearby_scps += A

	if(!nearby_scps.len)
		to_chat(src, span_warning("No SCPs nearby to interact with."))
		return

	var/atom/selected_scp = input(src, "Select SCP to interact with:", "SCP Interaction") as null|anything in nearby_scps
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

/mob/living/simple_animal/hostile/scp131_b/proc/interact_with_049(atom/scp049)
	to_chat(src, span_notice("You provide comfort to SCP-049."))
	SEND_SIGNAL(scp049, COMSIG_SCP049_COMFORTED, src)

/mob/living/simple_animal/hostile/scp131_b/proc/interact_with_096(atom/scp096)
	to_chat(src, span_notice("You attempt to calm SCP-096."))
	if(prob(60))
		to_chat(src, span_green("You successfully calm SCP-096."))
		SEND_SIGNAL(scp096, COMSIG_SCP096_CALMED, src)
	else
		to_chat(src, span_warning("SCP-096 is too enraged to calm."))

/mob/living/simple_animal/hostile/scp131_b/proc/interact_with_173(atom/scp173)
	to_chat(src, span_notice("You attempt to comfort SCP-173."))
	to_chat(src, span_warning("SCP-173 doesn't seem to respond to comfort."))

/mob/living/simple_animal/hostile/scp131_b/proc/interact_with_106(atom/scp106)
	to_chat(src, span_notice("You attempt to comfort SCP-106."))
	to_chat(src, span_warning("SCP-106 seems unaffected by your comfort."))

/mob/living/simple_animal/hostile/scp131_b/proc/generic_scp_interaction(atom/scp)
	to_chat(src, span_notice("You provide comfort to [scp.name]."))

// Cross-SCP interaction methods (same as A)
/mob/living/simple_animal/hostile/scp131_b/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	if(victim in range(5, src))
		to_chat(src, span_warning("The corrosive effect distresses you!"))
		// Simple animals don't have sanity, just show distress

/mob/living/simple_animal/hostile/scp131_b/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	if(patient in range(5, src))
		to_chat(src, span_notice("The cure's power feels comforting to you."))
		// Simple animals don't have sanity, just show comfort

/mob/living/simple_animal/hostile/scp131_b/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	if(target in range(5, src))
		to_chat(src, span_warning("The rage frightens you!"))
		// Simple animals don't have sanity, just show fear

/mob/living/simple_animal/hostile/scp131_b/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	if(viewer in range(5, src))
		to_chat(viewer, span_danger("You see a statue near the eye pod!"))
		viewer.adjustSanity(-10, "scp173_near_131")

/mob/living/simple_animal/hostile/scp131_b/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	if(adaptor in range(5, src))
		to_chat(src, span_notice("The adaptation process fascinates you."))
		curiosity_level = min(curiosity_level + 1, max_curiosity)

/mob/living/simple_animal/hostile/scp131_b/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	if(host in range(5, src))
		to_chat(host, span_notice("The mask's personality finds the eye pod adorable."))
		host.adjustSanity(8, "mask_131_interest")

/mob/living/simple_animal/hostile/scp131_b/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	if(explorer in range(5, src))
		to_chat(src, span_warning("The stairwell's presence distresses you!"))
		// Simple animals don't have sanity, just show distress

// Research system integration
/mob/living/simple_animal/hostile/scp131_b/proc/get_research_data()
	var/list/data = list()
	data["health"] = health
	data["max_health"] = maxHealth
	data["comforted_humans"] = length(comforted_humans)
	data["comfort_range"] = comfort_range
	data["curiosity_level"] = curiosity_level
	data["max_curiosity"] = max_curiosity
	data["following_human"] = following_human ? following_human.name : "None"
	data["comfort_cooldown_remaining"] = max(0, comfort_cooldown - world.time)
	return data
