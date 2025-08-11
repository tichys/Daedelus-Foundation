// Sanity-Related Equipment
// Items and equipment that affect sanity and mental state

// Therapy Couch
/obj/structure/bed/therapy_couch
	name = "Therapy Couch"
	desc = "A comfortable couch designed for therapy sessions and mental recovery."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "therapy_couch"
	anchored = TRUE
	var/therapy_cooldown = 0
	var/THERAPY_COOLDOWN_TIME = 300 SECONDS // 5 minutes

/obj/structure/bed/therapy_couch/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/obj/structure/bed/therapy_couch/proc/on_entered(datum/source, atom/movable/entering)
	if(!ishuman(entering))
		return

	var/mob/living/carbon/human/H = entering
	if(world.time < therapy_cooldown)
		to_chat(H, span_warning("The therapy couch needs time to recharge."))
		return

	H.add_sanity_recovery_source(SANITY_RECOVERY_THERAPY, SANITY_RECOVERY_RATE_THERAPY, 0)
	to_chat(H, span_notice("You feel the calming effects of the therapy couch."))

/obj/structure/bed/therapy_couch/proc/on_exited(datum/source, atom/movable/exiting)
	if(!ishuman(exiting))
		return

	var/mob/living/carbon/human/H = exiting
	H.remove_sanity_recovery_source(SANITY_RECOVERY_THERAPY)

/obj/structure/bed/therapy_couch/verb/conduct_therapy()
	set name = "Conduct Therapy"
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr))
		to_chat(usr, span_warning("This only works for humans."))
		return

	if(world.time < therapy_cooldown)
		to_chat(usr, span_warning("The therapy couch needs time to recharge."))
		return

	var/mob/living/carbon/human/therapist = usr
	var/list/nearby_patients = list()

	for(var/mob/living/carbon/human/H in range(2, src))
		if(H != therapist && H.stat == CONSCIOUS)
			nearby_patients += H

	if(!nearby_patients.len)
		to_chat(therapist, span_warning("No patients nearby to conduct therapy with."))
		return

	var/mob/living/carbon/human/patient = input(therapist, "Select a patient for therapy:", "Therapy Session") as null|anything in nearby_patients
	if(!patient)
		return

	to_chat(therapist, span_notice("You begin conducting a therapy session with [patient]..."))
	to_chat(patient, span_notice("[therapist] begins conducting a therapy session with you..."))

	if(do_after(therapist, 60 SECONDS, target = src))
		patient.adjustSanity(15, "therapy_session")
		therapist.adjustSanity(5, "conducting_therapy")
		therapy_cooldown = world.time + THERAPY_COOLDOWN_TIME

		to_chat(therapist, span_notice("Therapy session completed successfully."))
		to_chat(patient, span_notice("You feel much better after the therapy session."))

// Meditation Chamber
/obj/machinery/meditation_chamber
	name = "Meditation Chamber"
	desc = "An advanced chamber designed for deep meditation and mental recovery."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "meditation_chamber"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 200
	var/meditation_cooldown = 0
	var/meditation_duration = 0
	var/MAX_MEDITATION_DURATION = 300 SECONDS // 5 minutes
	var/MEDITATION_COOLDOWN_TIME = 600 SECONDS // 10 minutes

/obj/machinery/meditation_chamber/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/obj/machinery/meditation_chamber/proc/on_entered(datum/source, atom/movable/entering)
	if(!ishuman(entering))
		return

	var/mob/living/carbon/human/H = entering
	if(world.time < meditation_cooldown)
		to_chat(H, span_warning("The meditation chamber needs time to recharge."))
		return

	meditation_duration = 0
	H.add_sanity_recovery_source(SANITY_RECOVERY_REST, SANITY_RECOVERY_RATE_REST * 2, 0)
	to_chat(H, span_notice("You enter a deep meditative state."))

/obj/machinery/meditation_chamber/proc/on_exited(datum/source, atom/movable/exiting)
	if(!ishuman(exiting))
		return

	var/mob/living/carbon/human/H = exiting
	H.remove_sanity_recovery_source(SANITY_RECOVERY_REST)

	if(meditation_duration >= MAX_MEDITATION_DURATION)
		H.adjustSanity(25, "deep_meditation")
		meditation_cooldown = world.time + MEDITATION_COOLDOWN_TIME
		to_chat(H, span_notice("You feel completely refreshed after your deep meditation."))

/obj/machinery/meditation_chamber/process()
	. = ..()

	// Update meditation duration for anyone inside
	for(var/mob/living/carbon/human/H in get_turf(src))
		if(H.stat == CONSCIOUS)
			meditation_duration += SSobj.wait

// Biofeedback Device
/obj/item/biofeedback_device
	name = "Biofeedback Device"
	desc = "A device that monitors mental state and provides feedback for mental health."
	icon = 'icons/obj/device.dmi'
	icon_state = "biofeedback_device"
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE
	var/last_reading = 0
	var/READING_INTERVAL = 30 SECONDS

/obj/item/biofeedback_device/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))

/obj/item/biofeedback_device/proc/on_equipped(datum/source, mob/living/carbon/human/user, slot)
	if(slot == ITEM_SLOT_BELT)
		active = TRUE
		START_PROCESSING(SSobj, src)

/obj/item/biofeedback_device/proc/on_dropped(datum/source, mob/living/carbon/human/user)
	active = FALSE
	STOP_PROCESSING(SSobj, src)

/obj/item/biofeedback_device/process()
	if(!active || !ishuman(loc))
		return

	var/mob/living/carbon/human/H = loc
	if(world.time < last_reading + READING_INTERVAL)
		return

	last_reading = world.time
	var/sanity_state = H.getSanityState()
	// var/sanity_color = H.getSanityColor()

	to_chat(H, span_notice("Biofeedback reading: [H.sanity]/[H.max_sanity] - [sanity_state]"))

	// Provide recovery boost if sanity is low
	if(H.sanity <= SANITY_LOW)
		H.adjustSanity(2, "biofeedback_boost")
		to_chat(H, span_notice("The biofeedback device helps stabilize your mental state."))

/obj/item/biofeedback_device/verb/toggle_biofeedback()
	set name = "Toggle Biofeedback"
	set category = "Object"
	set src in usr

	if(!ishuman(usr))
		to_chat(usr, span_warning("This only works for humans."))
		return

	active = !active
	if(active)
		START_PROCESSING(SSobj, src)
		to_chat(usr, span_notice("Biofeedback device activated."))
	else
		STOP_PROCESSING(SSobj, src)
		to_chat(usr, span_notice("Biofeedback device deactivated."))

// Sanity Scanner
/obj/item/sanity_scanner
	name = "Sanity Scanner"
	desc = "A device that can analyze mental state and sanity levels."
	icon = 'icons/obj/device.dmi'
	icon_state = "sanity_scanner"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/sanity_scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag || !ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	var/sanity_state = H.getSanityState()
	// var/sanity_color = H.getSanityColor()

	to_chat(user, span_notice("=== Sanity Scan Results ==="))
	to_chat(user, span_notice("Subject: [H.name]"))
	to_chat(user, span_notice("Sanity Level: [H.sanity]/[H.max_sanity]"))
	to_chat(user, span_notice("Mental State: [sanity_state]"))
	to_chat(user, span_notice("Active Effects: [length(H.active_sanity_effects)]"))
	to_chat(user, span_notice("Recovery Sources: [length(H.active_sanity_recovery_sources)]"))
	to_chat(user, span_notice("Damage Sources: [length(H.active_sanity_damage_sources)]"))
	to_chat(user, span_notice("========================"))

// Sanity Stabilizer
/obj/item/reagent_containers/syringe/sanity_stabilizer
	name = "Sanity Stabilizer"
	desc = "A syringe containing a powerful mental stabilizer."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "sanity_stabilizer"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15)
	volume = 15

/obj/item/reagent_containers/syringe/sanity_stabilizer/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/medicine/psicodine, 15)

/obj/item/reagent_containers/syringe/sanity_stabilizer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag || !ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	if(H.sanity >= SANITY_NORMAL)
		to_chat(user, span_warning("[H]'s sanity is already stable."))
		return

	to_chat(user, span_notice("You inject [H] with the sanity stabilizer."))
	to_chat(H, span_notice("You feel a wave of mental clarity wash over you."))

	// Apply immediate sanity boost
	H.adjustSanity(20, "sanity_stabilizer_injection")

	// Remove negative effects
	H.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)
	H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
	H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
	H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
	H.remove_sanity_effect(SANITY_EFFECT_AGGRESSION)
	H.remove_sanity_effect(SANITY_EFFECT_WITHDRAWAL)
