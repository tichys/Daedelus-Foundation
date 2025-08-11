// SCP-914: The Clockworks
// A large clockwork device that can refine objects

/obj/machinery/scp914
	name = "SCP-914"
	desc = "A massive clockwork device with various gears, pulleys, and mechanisms. It has a large input tray and output tray."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "scp914"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 500
	var/obj/item/input_item
	var/obj/item/output_item
	var/refinement_setting = "1:1"
	var/refining = FALSE
	var/refinement_time = 30 SECONDS
	var/list/refinement_settings = list("Rough", "Coarse", "1:1", "Fine", "Very Fine")
	var/list/refinement_multipliers = list(0.5, 0.75, 1.0, 1.5, 2.0)
	var/cooldown_time = 0
	var/REFINEMENT_COOLDOWN = 60 SECONDS

/obj/machinery/scp914/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"clockwork device",
		SCP_EUCLID,
		"914",
		SCP_MEMETIC
	)

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

/obj/machinery/scp914/Destroy()
	QDEL_NULL(input_item)
	QDEL_NULL(output_item)
	QDEL_NULL(SCP)
	return ..()

/obj/machinery/scp914/attackby(obj/item/I, mob/user, params)
	if(refining)
		to_chat(user, span_warning("SCP-914 is currently refining an item."))
		return

	if(input_item)
		to_chat(user, span_warning("There is already an item in the input tray."))
		return

	if(!user.transferItemToLoc(I, src))
		return

	input_item = I
	to_chat(user, span_notice("You place [I] in SCP-914's input tray."))
	update_icon()

/obj/machinery/scp914/attack_hand(mob/user)
	if(refining)
		to_chat(user, span_warning("SCP-914 is currently refining an item."))
		return

	if(output_item)
		user.put_in_hands(output_item)
		to_chat(user, span_notice("You take [output_item] from SCP-914's output tray."))
		output_item = null
		update_icon()
		return

	if(!input_item)
		to_chat(user, span_warning("There is nothing in SCP-914's input tray."))
		return

	start_refinement(user)

/obj/machinery/scp914/proc/start_refinement(mob/user)
	if(world.time < cooldown_time)
		to_chat(user, span_warning("SCP-914 needs time to cool down."))
		return

	refining = TRUE
	cooldown_time = world.time + REFINEMENT_COOLDOWN

	to_chat(user, span_notice("You start SCP-914's refinement process with setting: [refinement_setting]"))
	playsound(src, 'sound/machines/clockwork.ogg', 50, TRUE)

	// Apply sanity effects to nearby observers
	for(var/mob/living/carbon/human/H in range(3, src))
		H.adjustSanity(-5, "scp914_refinement")

	addtimer(CALLBACK(src, PROC_REF(complete_refinement)), refinement_time)

/obj/machinery/scp914/proc/complete_refinement()
	if(!input_item)
		refining = FALSE
		return

	var/refinement_index = refinement_settings.Find(refinement_setting)
	var/multiplier = refinement_multipliers[refinement_index]

	// Create refined item
	output_item = create_refined_item(input_item, multiplier)

	// Clean up input
	QDEL_NULL(input_item)
	input_item = null

	refining = FALSE
	playsound(src, 'sound/machines/clockwork_complete.ogg', 50, TRUE)
	update_icon()

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP914_REFINEMENT_COMPLETE, output_item, refinement_setting)

/obj/machinery/scp914/proc/create_refined_item(obj/item/original, multiplier)
	var/obj/item/refined = new original.type()

	// Apply refinement effects based on setting
	switch(refinement_setting)
		if("Rough")
			// Degrade item
			refined.name = "damaged [original.name]"
			refined.desc = "[original.desc] It appears to be damaged and less effective."
			refined.force = max(0, original.force * 0.5)
		if("Coarse")
			// Slightly degrade
			refined.name = "worn [original.name]"
			refined.desc = "[original.desc] It appears to be worn and less effective."
			refined.force = max(0, original.force * 0.75)
		if("1:1")
			// No change
			refined.name = original.name
			refined.desc = original.desc
			refined.force = original.force
		if("Fine")
			// Improve item
			refined.name = "enhanced [original.name]"
			refined.desc = "[original.desc] It appears to be enhanced and more effective."
			refined.force = original.force * 1.5
		if("Very Fine")
			// Significantly improve
			refined.name = "perfected [original.name]"
			refined.desc = "[original.desc] It appears to be perfected and highly effective."
			refined.force = original.force * 2.0

	return refined

/obj/machinery/scp914/verb/change_setting()
	set name = "Change Refinement Setting"
	set category = "Object"
	set src in view(1)

	if(refining)
		to_chat(usr, span_warning("Cannot change setting while refining."))
		return

	var/new_setting = input(usr, "Select refinement setting:", "SCP-914 Setting") as null|anything in refinement_settings
	if(!new_setting)
		return

	refinement_setting = new_setting
	to_chat(usr, span_notice("SCP-914 refinement setting changed to: [refinement_setting]"))

// Cross-SCP interaction methods
/obj/machinery/scp914/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage SCP-914
	to_chat(victim, span_warning("The corrosive effect damages the clockwork mechanisms!"))
	// Increase cooldown temporarily
	cooldown_time = world.time + REFINEMENT_COOLDOWN * 2

/obj/machinery/scp914/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can improve SCP-914's efficiency
	if(patient in range(3, src))
		to_chat(patient, span_notice("The cure's power improves the clockwork's efficiency."))
		refinement_time = max(10 SECONDS, refinement_time * 0.8)

/obj/machinery/scp914/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can damage SCP-914
	if(target in range(3, src))
		to_chat(target, span_warning("Your rage damages the delicate clockwork!"))
		cooldown_time = world.time + REFINEMENT_COOLDOWN * 1.5

/obj/machinery/scp914/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-914
	if(viewer in range(3, src))
		to_chat(viewer, span_danger("You see a statue near the clockwork device!"))
		viewer.adjustSanity(-10, "scp173_near_914")

/obj/machinery/scp914/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can improve SCP-914's capabilities
	if(adaptor in range(3, src))
		to_chat(adaptor, span_notice("Your adaptation helps improve the clockwork's precision."))
		refinement_time = max(5 SECONDS, refinement_time * 0.7)

/obj/machinery/scp914/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-914
	if(host in range(3, src))
		to_chat(host, span_notice("The mask's personality finds the clockwork fascinating."))
		host.adjustSanity(5, "mask_clockwork_interest")

/obj/machinery/scp914/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-914's effects
	if(explorer in range(3, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure affects the clockwork!"))
		explorer.adjustSanity(-15, "amplified_clockwork")

/obj/machinery/scp914/update_icon()
	. = ..()
	if(input_item)
		icon_state = "scp914_input"
	else if(output_item)
		icon_state = "scp914_output"
	else if(refining)
		icon_state = "scp914_active"
	else
		icon_state = "scp914"

// Research system integration
/obj/machinery/scp914/proc/get_research_data()
	var/list/data = list()
	data["refinement_setting"] = refinement_setting
	data["refining"] = refining
	data["input_item"] = input_item ? input_item.name : "None"
	data["output_item"] = output_item ? output_item.name : "None"
	data["cooldown_remaining"] = max(0, cooldown_time - world.time)
	return data

