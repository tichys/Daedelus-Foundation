// SCP-513: The Cowbell
// A cowbell that causes paranoia and hallucinations when heard

/obj/item/scp513
	name = "SCP-513"
	desc = "A small brass cowbell with an unusual design. It seems to emit a haunting sound."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "scp513"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	hitsound = 'sound/scp/scp513/ring.ogg'
	var/list/affected_humans = list()
	var/ring_cooldown = 0
	var/RING_COOLDOWN = 10 SECONDS
	var/paranoia_intensity = 1
	var/max_intensity = 5
	var/list/ring_history = list()
	var/max_ring_history = 10
	var/mysterious_figure_spawned = FALSE
	var/mysterious_figure_cooldown = 0
	var/MYSTERIOUS_FIGURE_COOLDOWN = 5 MINUTES

/obj/item/scp513/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"cowbell",
		SCP_EUCLID,
		"513",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MAUDIBLE | MPERSISTENT
	SCP.memetic_proc = TYPE_PROC_REF(/obj/item/scp513, paranoia_effect)
	SCP.compInit()

	add_verb(src, list(
		/obj/item/scp513/proc/RingBell,
		/obj/item/scp513/proc/IncreaseIntensity,
		/obj/item/scp513/proc/ShowRingHistory,
		/obj/item/scp513/proc/InteractWithSCP,
	))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

/obj/item/scp513/Destroy()
	QDEL_NULL(SCP)
	return ..()

/obj/item/scp513/proc/paranoia_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply paranoia effects
	H.adjustSanity(-15, "scp513_paranoia")
	H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 180 SECONDS, paranoia_intensity)
	H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 120 SECONDS, paranoia_intensity)

	// Apply vision effects
			// Vision effects removed (Foundation-19 style)

	to_chat(H, span_danger("You hear the haunting sound of the cowbell and feel overwhelming paranoia!"))

	// Chance to spawn mysterious figure
	if(!mysterious_figure_spawned && world.time >= mysterious_figure_cooldown && prob(20))
		spawn_mysterious_figure(H)

/obj/item/scp513/proc/spawn_mysterious_figure(mob/living/carbon/human/H)
	if(mysterious_figure_spawned)
		return

	// Create mysterious figure
	var/mob/living/simple_animal/hostile/mysterious_figure/figure = new(get_turf(H))
	mysterious_figure_spawned = TRUE
	mysterious_figure_cooldown = world.time + MYSTERIOUS_FIGURE_COOLDOWN

	to_chat(H, span_danger("A mysterious figure appears from the shadows!"))
	playsound(H, 'sound/scp/scp513/figure_spawn.ogg', 50, TRUE)

	// Set figure to follow the affected human
	figure.target = H

	// Clean up figure after some time
	QDEL_IN(figure, 3 MINUTES)

	SEND_SIGNAL(src, COMSIG_SCP513_FIGURE_SPAWNED, figure, H)

// SCP-513 abilities
/obj/item/scp513/proc/RingBell()
	set category = "SCP-513"
	set name = "Ring Bell"

	if(world.time < ring_cooldown)
		to_chat(usr, span_warning("The bell needs time to recharge."))
		return

	// Ring the bell
	playsound(src, 'sound/scp/scp513/ring.ogg', 50, TRUE)
	visible_message(span_warning("[src] emits a haunting sound!"))

	// Apply effects to nearby humans
	for(var/mob/living/carbon/human/H in range(8, src))
		if(H.stat == DEAD)
			continue

		to_chat(H, span_danger("You hear the haunting sound of the cowbell!"))
		H.adjustSanity(-10, "scp513_ring")
		H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 120 SECONDS, paranoia_intensity)
		H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 90 SECONDS, paranoia_intensity)

		// Add to affected list
		if(!(H in affected_humans))
			affected_humans += H

	// Record ring in history
	var/ring_data = list(
		"time" = world.time,
		"location" = get_turf(src),
		"intensity" = paranoia_intensity,
		"affected_count" = length(affected_humans)
	)
	ring_history += ring_data

	// Limit history size
	if(length(ring_history) > max_ring_history)
		ring_history.Cut(1, 2)

	ring_cooldown = world.time + RING_COOLDOWN
	to_chat(usr, span_notice("You ring the cowbell, spreading paranoia."))
	SEND_SIGNAL(src, COMSIG_SCP513_RUNG)

/obj/item/scp513/proc/IncreaseIntensity()
	set category = "SCP-513"
	set name = "Increase Intensity"

	if(paranoia_intensity >= max_intensity)
		to_chat(usr, span_warning("The paranoia intensity is already at maximum."))
		return

	paranoia_intensity++
	to_chat(usr, span_notice("You increase the paranoia intensity to [paranoia_intensity]."))

	// Apply increased effects to affected humans
	for(var/mob/living/carbon/human/H in affected_humans)
		if(H.stat == DEAD)
			continue

		H.adjustSanity(-5, "scp513_intensity_increase")
		H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 60 SECONDS, paranoia_intensity)

	SEND_SIGNAL(src, COMSIG_SCP513_INTENSITY_INCREASED, paranoia_intensity)

/obj/item/scp513/proc/InteractWithSCP()
	set category = "SCP-513"
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

/obj/item/scp513/proc/interact_with_049(atom/scp049)
	to_chat(usr, span_notice("You ring the bell near SCP-049."))
	SEND_SIGNAL(scp049, COMSIG_SCP049_BELL_RUNG, src)

/obj/item/scp513/proc/interact_with_096(atom/scp096)
	to_chat(usr, span_notice("You ring the bell near SCP-096."))
	to_chat(usr, span_warning("The bell's sound seems to agitate SCP-096 further."))

/obj/item/scp513/proc/interact_with_173(atom/scp173)
	to_chat(usr, span_notice("You ring the bell near SCP-173."))
	to_chat(usr, span_warning("SCP-173 doesn't seem to respond to the bell."))

/obj/item/scp513/proc/interact_with_106(atom/scp106)
	to_chat(usr, span_notice("You ring the bell near SCP-106."))
	to_chat(usr, span_warning("SCP-106 doesn't seem affected by the bell."))

/obj/item/scp513/proc/generic_scp_interaction(atom/scp)
	to_chat(usr, span_notice("You ring the bell near [scp.name]."))

/obj/item/scp513/proc/ShowRingHistory()
	set category = "SCP-513"
	set name = "Show Ring History"

	if(length(ring_history) == 0)
		to_chat(usr, span_notice("No ring history available."))
		return

	to_chat(usr, span_notice("Ring History:"))
	for(var/i in 1 to length(ring_history))
		var/list/ring_data = ring_history[i]
		var/time_ago = round((world.time - ring_data["time"]) / 600, 0.1)
		to_chat(usr, span_notice("[i]. [time_ago] minutes ago - Intensity: [ring_data["intensity"]] - Affected: [ring_data["affected_count"]]"))

// Cross-SCP interaction methods
/obj/item/scp513/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can amplify SCP-513's effects
	if(victim in range(5, src))
		to_chat(victim, span_warning("The corrosive effect amplifies your paranoia!"))
		victim.adjustSanity(-15, "amplified_paranoia")
		paranoia_intensity = min(paranoia_intensity + 1, max_intensity)

/obj/item/scp513/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can help resist SCP-513's effects
	if(patient in range(5, src))
		to_chat(patient, span_notice("The cure's power helps you resist the cowbell's paranoia."))
		patient.adjustSanity(10, "cure_paranoia_resistance")
		patient.remove_sanity_effect(SANITY_EFFECT_PARANOIA)

/obj/item/scp513/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be amplified by SCP-513
	if(target in range(5, src))
		to_chat(target, span_warning("The cowbell's paranoia amplifies your rage!"))
		target.adjustSanity(-20, "amplified_rage_paranoia")

/obj/item/scp513/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-513
	if(viewer in range(5, src))
		to_chat(viewer, span_danger("You see a statue near the cowbell!"))
		viewer.adjustSanity(-15, "scp173_near_513")

/obj/item/scp513/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-513's effects
	if(adaptor in range(5, src))
		to_chat(adaptor, span_notice("Your adaptation helps you resist the cowbell's paranoia."))
		adaptor.adjustSanity(8, "adaptation_paranoia_resistance")

/obj/item/scp513/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-513
	if(host in range(5, src))
		to_chat(host, span_notice("The mask's personality finds the cowbell's sound fascinating."))
		host.adjustSanity(5, "mask_513_interest")

/obj/item/scp513/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-513's effects
	if(explorer in range(5, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure amplifies the cowbell's paranoia!"))
		explorer.adjustSanity(-25, "amplified_paranoia_effects")

// Research system integration
/obj/item/scp513/proc/get_research_data()
	var/list/data = list()
	data["affected_humans"] = length(affected_humans)
	data["paranoia_intensity"] = paranoia_intensity
	data["max_intensity"] = max_intensity
	data["ring_history"] = length(ring_history)
	data["max_ring_history"] = max_ring_history
	data["mysterious_figure_spawned"] = mysterious_figure_spawned
	data["ring_cooldown_remaining"] = max(0, ring_cooldown - world.time)
	data["mysterious_figure_cooldown_remaining"] = max(0, mysterious_figure_cooldown - world.time)
	return data

// Mysterious Figure
/mob/living/simple_animal/hostile/mysterious_figure
	name = "Mysterious Figure"
	desc = "A shadowy figure that appears when the cowbell rings. It seems to be following someone."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mysterious_figure"
	icon_living = "mysterious_figure"
	icon_dead = "mysterious_figure_dead"
	maxHealth = 200
	health = 200
	see_in_dark = 8
	move_to_delay = 2
	melee_damage_lower = 10
	melee_damage_upper = 20
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_NONE
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE

	var/mob/living/carbon/human/follow_target
	var/follow_range = 5
	var/list/terrified_humans = list()

/mob/living/simple_animal/hostile/mysterious_figure/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/mysterious_figure/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/simple_animal/hostile/mysterious_figure/process()
	. = ..()
	follow_target()
	apply_terror_aura()

/mob/living/simple_animal/hostile/mysterious_figure/proc/follow_target()
	if(!follow_target || follow_target.stat == DEAD || !(follow_target in range(10, src)))
		// Find new target
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD)
				follow_target = H
				to_chat(src, span_notice("You start following [H.name]."))
				break
		return

	// Follow the target
	if(get_dist(src, follow_target) > follow_range)
		step_towards(src, follow_target)

/mob/living/simple_animal/hostile/mysterious_figure/proc/apply_terror_aura()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat == DEAD)
			continue

		// Apply terror effects
		H.adjustSanity(-3, "mysterious_figure_terror")
		H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 60 SECONDS, 2)
		// Vision effects removed (Foundation-19 style)

		// Add to terrified list
		if(!(H in terrified_humans))
			terrified_humans += H

	// Clean up terrified list
	for(var/mob/living/carbon/human/H in terrified_humans)
		if(!(H in range(3, src)))
			terrified_humans -= H

/mob/living/simple_animal/hostile/mysterious_figure/AttackingTarget()
	. = ..()
	if(ishuman(follow_target))
		var/mob/living/carbon/human/H = follow_target
		to_chat(H, span_danger("The mysterious figure attacks you!"))
		H.adjustSanity(-10, "mysterious_figure_attack")
		H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 120 SECONDS, 3)
