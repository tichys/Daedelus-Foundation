// SCP-3008: A Perfectly Normal, Regular Old IKEA
// An infinite IKEA store that can trap people inside

/obj/machinery/scp3008
	name = "SCP-3008"
	desc = "An entrance to what appears to be a normal IKEA store. Something seems off about it."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "scp3008"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 200
	var/entrance_active = TRUE
	var/trapped_humans = list()
	var/escape_cooldown = 0
	var/ESCAPE_COOLDOWN_TIME = 10 MINUTES
	var/ikea_level = 1
	var/max_level = 10
	var/level_generation_time = 0
	var/LEVEL_GENERATION_TIME = 5 MINUTES
	var/list/ikea_entities = list()
	var/entity_spawn_cooldown = 0
	var/ENTITY_SPAWN_COOLDOWN = 2 MINUTES

/obj/machinery/scp3008/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"infinite IKEA",
		SCP_KETER,
		"3008",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL|MAUDIBLE
	SCP.memetic_proc = TYPE_PROC_REF(/obj/machinery/scp3008, ikea_effect)
	SCP.memetic_sounds = list('sound/scp/scp3008/ikea_ambient1.ogg', 'sound/scp/scp3008/ikea_ambient2.ogg', 'sound/scp/scp3008/ikea_ambient3.ogg')
	SCP.compInit()

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

	// Start IKEA processing
	START_PROCESSING(SSobj, src)

/obj/machinery/scp3008/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

/obj/machinery/scp3008/process()
	. = ..()
	if(!entrance_active)
		return

	process_ikea_levels()
	spawn_ikea_entities()

/obj/machinery/scp3008/proc/ikea_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply IKEA entrance effects
	H.adjustSanity(-15, "scp3008_entrance")
	H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 180 SECONDS, 2)
	H.add_sanity_effect(SANITY_EFFECT_ANXIETY, 120 SECONDS, 2)

	// Apply vision effects
			// Vision effects removed (Foundation-19 style)

	to_chat(H, span_warning("You feel disoriented as you enter the IKEA..."))

/obj/machinery/scp3008/proc/process_ikea_levels()
	if(world.time < level_generation_time)
		return

	// Generate new IKEA level
	generate_ikea_level()
	level_generation_time = world.time + LEVEL_GENERATION_TIME

/obj/machinery/scp3008/proc/generate_ikea_level()
	ikea_level++
	if(ikea_level > max_level)
		ikea_level = 1

	// Apply effects to trapped humans
	for(var/mob/living/carbon/human/H in trapped_humans)
		if(!H || H.stat == DEAD)
			trapped_humans -= H
			continue

		to_chat(H, span_warning("The IKEA layout seems to have changed..."))
		H.adjustSanity(-5, "scp3008_level_change")
		H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 60 SECONDS, 1)

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP3008_LEVEL_GENERATED, ikea_level)

/obj/machinery/scp3008/proc/spawn_ikea_entities()
	if(world.time < entity_spawn_cooldown)
		return

	// Spawn IKEA staff entities
	spawn_ikea_staff()
	entity_spawn_cooldown = world.time + ENTITY_SPAWN_COOLDOWN

/obj/machinery/scp3008/proc/spawn_ikea_staff()
	var/list/spawn_locations = list()
	for(var/turf/T in range(10, src))
		if(T.density)
			continue
		spawn_locations += T

	if(!spawn_locations.len)
		return

	var/turf/spawn_location = pick(spawn_locations)
	var/mob/living/simple_animal/hostile/ikea_staff/staff = new(spawn_location)
	ikea_entities += staff

	to_chat(get_turf(src), span_warning("An IKEA staff member appears!"))
	playsound(spawn_location, 'sound/scp/scp3008/staff_spawn.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP3008_STAFF_SPAWNED, staff)

/obj/machinery/scp3008/attack_hand(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(!entrance_active)
		to_chat(H, span_warning("The IKEA entrance is currently closed."))
		return

	// Enter the IKEA
	enter_ikea(H)

/obj/machinery/scp3008/proc/enter_ikea(mob/living/carbon/human/user)
	to_chat(user, span_notice("You enter the IKEA store..."))
	to_chat(user, span_warning("The store seems to go on forever..."))

	// Apply entrance effects
	apply_entrance_effects(user)

	// Add to trapped humans
	if(!(user in trapped_humans))
		trapped_humans += user

	// Teleport to a random location within the IKEA
	var/list/ikea_turfs = list()
	for(var/turf/T in range(20, src))
		if(T.density)
			continue
		ikea_turfs += T

	if(ikea_turfs.len)
		var/turf/destination = pick(ikea_turfs)
		user.forceMove(destination)

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP3008_HUMAN_ENTERED, user)

/obj/machinery/scp3008/proc/apply_entrance_effects(mob/living/carbon/human/user)
	// Apply psychological effects
	user.adjustSanity(-20, "scp3008_entrance")
	user.add_sanity_effect(SANITY_EFFECT_PARANOIA, 300 SECONDS, 3)
	user.add_sanity_effect(SANITY_EFFECT_ANXIETY, 240 SECONDS, 2)
	user.add_sanity_effect(SANITY_EFFECT_WITHDRAWAL, 180 SECONDS, 1)

	// Apply vision effects
			// Vision effects removed (Foundation-19 style)

// SCP-3008 abilities
/obj/machinery/scp3008/verb/toggle_entrance()
	set name = "Toggle Entrance"
	set category = "SCP-3008"
	set src in view(1)

	entrance_active = !entrance_active
	if(entrance_active)
		to_chat(usr, span_notice("IKEA entrance is now open."))
		START_PROCESSING(SSobj, src)
	else
		to_chat(usr, span_notice("IKEA entrance is now closed."))
		STOP_PROCESSING(SSobj, src)

/obj/machinery/scp3008/verb/force_escape()
	set name = "Force Escape"
	set category = "SCP-3008"
	set src in view(1)

	if(world.time < escape_cooldown)
		to_chat(usr, span_warning("Escape mechanism needs time to recharge."))
		return

	// Force escape for all trapped humans
	for(var/mob/living/carbon/human/H in trapped_humans)
		if(!H || H.stat == DEAD)
			trapped_humans -= H
			continue

		to_chat(H, span_notice("You find an exit and escape the IKEA!"))
		H.forceMove(get_turf(src))
		H.adjustSanity(15, "scp3008_escape")
		H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
		H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		H.remove_sanity_effect(SANITY_EFFECT_WITHDRAWAL)
		// Vision effects removed (Foundation-19 style)

	trapped_humans = list()
	escape_cooldown = world.time + ESCAPE_COOLDOWN_TIME

	to_chat(usr, span_notice("All trapped humans have been freed from the IKEA."))
	playsound(src, 'sound/scp/scp3008/escape.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP3008_FORCE_ESCAPE)

/obj/machinery/scp3008/verb/generate_new_level()
	set name = "Generate New Level"
	set category = "SCP-3008"
	set src in view(1)

	generate_ikea_level()
	to_chat(usr, span_notice("New IKEA level generated: Level [ikea_level]."))

/obj/machinery/scp3008/verb/spawn_staff_manually()
	set name = "Spawn Staff"
	set category = "SCP-3008"
	set src in view(1)

	spawn_ikea_staff()
	to_chat(usr, span_notice("IKEA staff member spawned."))

/obj/machinery/scp3008/examine(mob/user)
	. = ..()
	if(entrance_active)
		. += span_notice("The IKEA entrance is open.")
		. += span_notice("Current level: [ikea_level]/[max_level]")
		. += span_notice("Trapped humans: [length(trapped_humans)]")
		. += span_notice("IKEA entities: [length(ikea_entities)]")
	else
		. += span_notice("The IKEA entrance is closed.")

// Cross-SCP interaction methods
/obj/machinery/scp3008/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage SCP-3008
	to_chat(victim, span_warning("The corrosive effect damages the IKEA entrance!"))
	// Temporarily disable entrance
	entrance_active = FALSE
	addtimer(CALLBACK(src, PROC_REF(reactivate_entrance)), 5 MINUTES)

/obj/machinery/scp3008/proc/reactivate_entrance()
	entrance_active = TRUE
	to_chat(get_turf(src), span_notice("The IKEA entrance has been repaired."))

/obj/machinery/scp3008/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can help resist SCP-3008's effects
	if(patient in trapped_humans)
		to_chat(patient, span_notice("The cure's power helps you resist the IKEA's influence."))
		patient.adjustSanity(20, "cure_protection")
		patient.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
		patient.remove_sanity_effect(SANITY_EFFECT_ANXIETY)

/obj/machinery/scp3008/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be amplified by SCP-3008
	if(target in trapped_humans)
		to_chat(target, span_warning("The endless IKEA amplifies your rage!"))
		target.adjustSanity(-25, "amplified_rage")

/obj/machinery/scp3008/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear in SCP-3008
	if(viewer in trapped_humans)
		to_chat(viewer, span_danger("You see a statue in the IKEA!"))
		viewer.adjustSanity(-15, "scp173_in_ikea")

/obj/machinery/scp3008/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-3008's effects
	if(adaptor in trapped_humans)
		to_chat(adaptor, span_notice("Your adaptation helps you resist the IKEA's influence."))
		adaptor.adjustSanity(10, "adaptation_resistance")

/obj/machinery/scp3008/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-3008
	if(host in trapped_humans)
		to_chat(host, span_notice("The mask's personality finds the IKEA fascinating."))
		host.adjustSanity(8, "mask_ikea_interest")

/obj/machinery/scp3008/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-3008's effects
	if(explorer in trapped_humans)
		to_chat(explorer, span_warning("The stairwell's psychological pressure amplifies the IKEA's effects!"))
		explorer.adjustSanity(-30, "amplified_ikea_effects")

// Research system integration
/obj/machinery/scp3008/proc/get_research_data()
	var/list/data = list()
	data["entrance_active"] = entrance_active
	data["ikea_level"] = ikea_level
	data["max_level"] = max_level
	data["trapped_humans"] = length(trapped_humans)
	data["ikea_entities"] = length(ikea_entities)
	data["escape_cooldown_remaining"] = max(0, escape_cooldown - world.time)
	data["level_generation_remaining"] = max(0, level_generation_time - world.time)
	return data

// IKEA Staff Entity
/mob/living/simple_animal/hostile/ikea_staff
	name = "IKEA Staff"
	desc = "A staff member wearing an IKEA uniform. They seem to be made of cardboard."
	icon = 'icons/mob/animal.dmi'
	icon_state = "ikea_staff"
	icon_living = "ikea_staff"
	icon_dead = "ikea_staff_dead"
	maxHealth = 150
	health = 150
	see_in_dark = 8
	move_to_delay = 2
	melee_damage_lower = 10
	melee_damage_upper = 20
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE

	var/aggression_level = 1
	var/max_aggression = 5
	var/list/assaulted_humans = list()

/mob/living/simple_animal/hostile/ikea_staff/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"cardboard staff",
		SCP_EUCLID,
		"3008-A",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/simple_animal/hostile/ikea_staff, staff_effect)
	SCP.compInit()

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

/mob/living/simple_animal/hostile/ikea_staff/Destroy()
	QDEL_NULL(SCP)
	return ..()

/mob/living/simple_animal/hostile/ikea_staff/proc/staff_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply staff effects
	H.adjustSanity(-5, "scp3008_staff")
	H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 60 SECONDS, aggression_level)
	H.add_sanity_effect(SANITY_EFFECT_ANXIETY, 45 SECONDS, aggression_level)

	to_chat(H, span_warning("The IKEA staff member approaches you menacingly!"))

// Cross-SCP interaction methods
/mob/living/simple_animal/hostile/ikea_staff/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage IKEA staff
	to_chat(victim, span_warning("The corrosive effect damages the cardboard staff member!"))
	adjustHealth(30)

/mob/living/simple_animal/hostile/ikea_staff/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can help resist IKEA staff
	if(patient in range(5, src))
		to_chat(patient, span_notice("The cure's power helps you resist the staff member."))
		patient.adjustSanity(8, "cure_protection")

/mob/living/simple_animal/hostile/ikea_staff/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be amplified by IKEA staff
	if(target in range(5, src))
		to_chat(target, span_warning("The staff member's presence amplifies your rage!"))
		target.adjustSanity(-15, "amplified_rage")

/mob/living/simple_animal/hostile/ikea_staff/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near IKEA staff
	if(viewer in range(5, src))
		to_chat(viewer, span_danger("You see a statue near the staff member!"))
		viewer.adjustSanity(-10, "scp173_near_staff")

/mob/living/simple_animal/hostile/ikea_staff/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist IKEA staff
	if(adaptor in range(5, src))
		to_chat(adaptor, span_notice("Your adaptation helps you resist the staff member."))
		adaptor.adjustSanity(5, "adaptation_resistance")

/mob/living/simple_animal/hostile/ikea_staff/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with IKEA staff
	if(host in range(5, src))
		to_chat(host, span_notice("The mask's personality finds the staff member interesting."))
		host.adjustSanity(3, "mask_staff_interest")

/mob/living/simple_animal/hostile/ikea_staff/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify IKEA staff effects
	if(explorer in range(5, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure amplifies the staff member's effects!"))
		explorer.adjustSanity(-20, "amplified_staff_effects")

// Research system integration
/mob/living/simple_animal/hostile/ikea_staff/proc/get_research_data()
	var/list/data = list()
	data["health"] = health
	data["max_health"] = maxHealth
	data["aggression_level"] = aggression_level
	data["max_aggression"] = max_aggression
	data["assaulted_humans"] = length(assaulted_humans)
	return data

