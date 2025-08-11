// SCP-895: Camera Disruption
// An area that causes cameras to malfunction and show disturbing images

/obj/effect/scp895_area
	name = "SCP-895 Area"
	desc = "An area where cameras malfunction and show disturbing images."
	icon = 'icons/effects/effects.dmi'
	icon_state = "scp895_area"
	layer = ABOVE_MOB_LAYER
	invisibility = INVISIBILITY_ABSTRACT
	var/area_range = 5
	var/list/affected_cameras = list()
	var/list/affected_humans = list()
	var/disturbance_intensity = 1
	var/max_intensity = 5
	var/camera_malfunction_cooldown = 0
	var/CAMERA_MALFUNCTION_COOLDOWN = 30 SECONDS
	var/list/disturbing_images = list(
		"corpses",
		"blood",
		"shadows",
		"faces",
		"movement",
		"distortion"
	)

/obj/effect/scp895_area/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/scp895_area/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/scp895_area/process()
	. = ..()
	affect_cameras()
	affect_humans()

/obj/effect/scp895_area/proc/affect_cameras()
	for(var/obj/machinery/camera/C in range(area_range, src))
		if(C.status & BROKEN)
			continue

		// Add to affected cameras
		if(!(C in affected_cameras))
			affected_cameras += C
			C.add_filter("scp895_distortion", 1, list("type" = "wave", "x" = 20, "y" = 20))

		// Apply camera effects
		if(world.time >= camera_malfunction_cooldown)
			apply_camera_disturbance(C)

	// Clean up affected cameras
	for(var/obj/machinery/camera/C in affected_cameras)
		if(!(C in range(area_range, src)))
			affected_cameras -= C
			C.remove_filter("scp895_distortion")

/obj/effect/scp895_area/proc/affect_humans()
	for(var/mob/living/carbon/human/H in range(area_range, src))
		if(H.stat == DEAD)
			continue

		// Apply psychological effects
		H.adjustSanity(-2, "scp895_area")
		H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 60 SECONDS, disturbance_intensity)
		H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 90 SECONDS, disturbance_intensity)

		// Apply vision effects
		// Vision effects removed (Foundation-19 style)

		// Add to affected list
		if(!(H in affected_humans))
			affected_humans += H

	// Clean up affected list
	for(var/mob/living/carbon/human/H in affected_humans)
		if(!(H in range(area_range, src)))
			affected_humans -= H

/obj/effect/scp895_area/proc/apply_camera_disturbance(obj/machinery/camera/C)
	if(!C || C.status & BROKEN)
		return

	// Apply visual disturbance
	var/disturbing_image = pick(disturbing_images)
	C.add_filter("scp895_disturbance", 1, list("type" = "blur", "size" = 2))

	// Notify viewers
	for(var/mob/living/carbon/human/H in range(area_range, src))
		if(H.stat == DEAD)
			continue

		to_chat(H, span_warning("The camera feed shows disturbing images of [disturbing_image]!"))
		H.adjustSanity(-5, "scp895_camera_disturbance")
		H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 120 SECONDS, disturbance_intensity)

	camera_malfunction_cooldown = world.time + CAMERA_MALFUNCTION_COOLDOWN
	playsound(src, 'sound/scp/scp895/disturbance.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP895_CAMERA_DISTURBED, C, disturbing_image)

// SCP-895 Research System Integration
/obj/effect/scp895_area/proc/get_research_data()
	var/list/data = list()
	data["affected_cameras"] = length(affected_cameras)
	data["affected_humans"] = length(affected_humans)
	data["disturbance_intensity"] = disturbance_intensity
	data["max_intensity"] = max_intensity
	data["area_range"] = area_range
	data["camera_malfunction_cooldown_remaining"] = max(0, camera_malfunction_cooldown - world.time)
	data["disturbing_images"] = disturbing_images
	return data

// SCP-895 Camera Override
/obj/machinery/camera/proc/scp895_override()
	if(!src)
		return

	// Apply SCP-895 effects to this camera
	add_filter("scp895_override", 1, list("type" = "wave", "x" = 30, "y" = 30))
	add_filter("scp895_distortion", 1, list("type" = "blur", "size" = 3))

	// Notify nearby humans
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat == DEAD)
			continue

		to_chat(H, span_danger("The camera feed is completely distorted!"))
		H.adjustSanity(-8, "scp895_camera_override")
		H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 180 SECONDS, 2)

	playsound(src, 'sound/scp/scp895/override.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP895_CAMERA_OVERRIDDEN)

// SCP-895 Area Generator
/obj/machinery/scp895_generator
	name = "SCP-895 Generator"
	desc = "A device that generates SCP-895 areas. It seems to be malfunctioning."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "scp895_generator"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 500
	var/generator_active = TRUE
	var/generation_cooldown = 0
	var/GENERATION_COOLDOWN = 2 MINUTES
	var/list/generated_areas = list()
	var/max_areas = 3
	var/disturbance_intensity = 1
	var/max_intensity = 5

/obj/machinery/scp895_generator/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"camera disruption generator",
		SCP_EUCLID,
		"895",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL | MPERSISTENT
	SCP.memetic_proc = TYPE_PROC_REF(/obj/machinery/scp895_generator, generator_effect)
	SCP.compInit()

	add_verb(src, list(
		/obj/machinery/scp895_generator/proc/ToggleGenerator,
		/obj/machinery/scp895_generator/proc/GenerateArea,
		/obj/machinery/scp895_generator/proc/IncreaseIntensity,
		/obj/machinery/scp895_generator/proc/InteractWithSCP,
	))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

	START_PROCESSING(SSobj, src)

/obj/machinery/scp895_generator/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

/obj/machinery/scp895_generator/process()
	. = ..()
	if(generator_active && world.time >= generation_cooldown)
		generate_random_area()

/obj/machinery/scp895_generator/proc/generator_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply generator effects
	H.adjustSanity(-8, "scp895_generator")
	H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 120 SECONDS, disturbance_intensity)
	H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 90 SECONDS, disturbance_intensity)

	// Apply vision effects
			// Vision effects removed (Foundation-19 style)

	to_chat(H, span_danger("The camera disruption generator fills you with unease!"))

// SCP-895 Generator abilities
/obj/machinery/scp895_generator/proc/ToggleGenerator()
	set category = "SCP-895 Generator"
	set name = "Toggle Generator"

	generator_active = !generator_active
	to_chat(usr, span_notice("You [generator_active ? "activate" : "deactivate"] the generator."))

	if(!generator_active)
		// Remove all generated areas
		for(var/obj/effect/scp895_area/area in generated_areas)
			qdel(area)
		generated_areas.Cut()

	SEND_SIGNAL(src, COMSIG_SCP895_GENERATOR_TOGGLED, generator_active)

/obj/machinery/scp895_generator/proc/GenerateArea()
	set category = "SCP-895 Generator"
	set name = "Generate Area"

	if(world.time < generation_cooldown)
		to_chat(usr, span_warning("The generator needs time to recharge."))
		return

	if(length(generated_areas) >= max_areas)
		to_chat(usr, span_warning("Maximum number of areas already generated."))
		return

	// Generate area at a random nearby location
	var/turf/target_turf = get_step(src, pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
	if(!target_turf)
		target_turf = get_turf(src)

	var/obj/effect/scp895_area/new_area = new(target_turf)
	new_area.disturbance_intensity = disturbance_intensity
	generated_areas += new_area

	generation_cooldown = world.time + GENERATION_COOLDOWN
	to_chat(usr, span_notice("You generate a new SCP-895 area."))
	playsound(src, 'sound/scp/scp895/generate.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP895_AREA_GENERATED, new_area)

/obj/machinery/scp895_generator/proc/IncreaseIntensity()
	set category = "SCP-895 Generator"
	set name = "Increase Intensity"

	if(disturbance_intensity >= max_intensity)
		to_chat(usr, span_warning("The disturbance intensity is already at maximum."))
		return

	disturbance_intensity++
	to_chat(usr, span_notice("You increase the disturbance intensity to [disturbance_intensity]."))

	// Update existing areas
	for(var/obj/effect/scp895_area/area in generated_areas)
		area.disturbance_intensity = disturbance_intensity

	SEND_SIGNAL(src, COMSIG_SCP895_INTENSITY_INCREASED, disturbance_intensity)

/obj/machinery/scp895_generator/proc/InteractWithSCP()
	set category = "SCP-895 Generator"
	set name = "Interact with SCP"

	var/list/nearby_scps = list()
	for(var/atom/A in range(5, src))
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

/obj/machinery/scp895_generator/proc/interact_with_049(atom/scp049)
	to_chat(usr, span_notice("You disrupt SCP-049's cure attempts with camera interference."))
	SEND_SIGNAL(scp049, COMSIG_SCP049_CAMERA_DISRUPTED, src)

/obj/machinery/scp895_generator/proc/interact_with_096(atom/scp096)
	to_chat(usr, span_notice("You attempt to disrupt SCP-096 with camera interference."))
	to_chat(usr, span_warning("SCP-096 seems unaffected by camera disruption."))

/obj/machinery/scp895_generator/proc/interact_with_173(atom/scp173)
	to_chat(usr, span_notice("You attempt to disrupt SCP-173 with camera interference."))
	to_chat(usr, span_warning("SCP-173 doesn't seem affected by camera disruption."))

/obj/machinery/scp895_generator/proc/interact_with_106(atom/scp106)
	to_chat(usr, span_notice("You attempt to disrupt SCP-106 with camera interference."))
	to_chat(usr, span_warning("SCP-106 doesn't seem affected by camera disruption."))

/obj/machinery/scp895_generator/proc/generic_scp_interaction(atom/scp)
	to_chat(usr, span_notice("You disrupt [scp.name] with camera interference."))

/obj/machinery/scp895_generator/proc/generate_random_area()
	if(length(generated_areas) >= max_areas)
		return

	// Generate area at a random location within range
	var/list/possible_turfs = list()
	for(var/turf/T in range(10, src))
		if(!locate(/obj/effect/scp895_area) in T)
			possible_turfs += T

	if(length(possible_turfs) == 0)
		return

	var/turf/target_turf = pick(possible_turfs)
	var/obj/effect/scp895_area/new_area = new(target_turf)
	new_area.disturbance_intensity = disturbance_intensity
	generated_areas += new_area

	generation_cooldown = world.time + GENERATION_COOLDOWN
	playsound(src, 'sound/scp/scp895/generate.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP895_AREA_GENERATED, new_area)

// Cross-SCP interaction methods
/obj/machinery/scp895_generator/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage the generator
	if(victim in range(5, src))
		to_chat(victim, span_warning("The corrosive effect damages the generator!"))
		disturbance_intensity = min(disturbance_intensity + 1, max_intensity)

/obj/machinery/scp895_generator/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can help resist SCP-895's effects
	if(patient in range(5, src))
		to_chat(patient, span_notice("The cure's power helps you resist the generator's effects."))
		patient.adjustSanity(10, "cure_generator_resistance")

/obj/machinery/scp895_generator/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be amplified by SCP-895
	if(target in range(5, src))
		to_chat(target, span_warning("The generator's effects amplify your rage!"))
		target.adjustSanity(-15, "amplified_rage_generator")

/obj/machinery/scp895_generator/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-895
	if(viewer in range(5, src))
		to_chat(viewer, span_danger("You see a statue near the generator!"))
		viewer.adjustSanity(-12, "scp173_near_895")

/obj/machinery/scp895_generator/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-895's effects
	if(adaptor in range(5, src))
		to_chat(adaptor, span_notice("Your adaptation helps you resist the generator's effects."))
		adaptor.adjustSanity(8, "adaptation_generator_resistance")

/obj/machinery/scp895_generator/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-895
	if(host in range(5, src))
		to_chat(host, span_notice("The mask's personality finds the generator's effects interesting."))
		host.adjustSanity(5, "mask_895_interest")

/obj/machinery/scp895_generator/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-895's effects
	if(explorer in range(5, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure amplifies the generator's effects!"))
		explorer.adjustSanity(-20, "amplified_generator_effects")

// Research system integration
/obj/machinery/scp895_generator/proc/get_research_data()
	var/list/data = list()
	data["generator_active"] = generator_active
	data["generated_areas"] = length(generated_areas)
	data["max_areas"] = max_areas
	data["disturbance_intensity"] = disturbance_intensity
	data["max_intensity"] = max_intensity
	data["generation_cooldown_remaining"] = max(0, generation_cooldown - world.time)
	return data
