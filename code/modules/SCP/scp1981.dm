// SCP-1981: "RONALD REAGAN CUTOUT"
// A cardboard cutout of Ronald Reagan that affects people's memories and perceptions

/obj/structure/scp1981
	name = "SCP-1981"
	desc = "A life-sized cardboard cutout of Ronald Reagan. It seems to be watching you."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "scp1981"
	density = TRUE
	anchored = TRUE
	var/affect_range = 5
	var/list/affected_humans = list()
	var/memory_alteration_intensity = 1
	var/max_intensity = 5
	var/active = TRUE
	var/cooldown_time = 0
	var/AFFECT_COOLDOWN = 60 SECONDS
	var/list/memory_messages = list(
		"You remember Reagan's famous speech about the Berlin Wall...",
		"You recall watching Reagan on television as a child...",
		"You remember Reagan's policies and their impact...",
		"You recall Reagan's charismatic leadership...",
		"You remember Reagan's role in ending the Cold War..."
	)

/obj/structure/scp1981/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"Reagan cutout",
		SCP_EUCLID,
		"1981",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL
	SCP.memetic_proc = TYPE_PROC_REF(/obj/structure/scp1981, memory_effect)
	SCP.compInit()

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

	// Start memory alteration process
	START_PROCESSING(SSobj, src)

/obj/structure/scp1981/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

/obj/structure/scp1981/process()
	. = ..()
	if(!active)
		return

	if(world.time < cooldown_time)
		return

	apply_memory_alteration()

/obj/structure/scp1981/proc/memory_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply memory alteration effects
	H.adjustSanity(-8, "scp1981_memory_alteration")
	H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 120 SECONDS, memory_alteration_intensity)
	H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 90 SECONDS, memory_alteration_intensity)

	// Apply vision effects
	// Vision effects removed (Foundation-19 style)

	// Show memory message
	to_chat(H, span_notice(pick(memory_messages)))

/obj/structure/scp1981/proc/apply_memory_alteration()
	for(var/mob/living/carbon/human/H in range(affect_range, src))
		if(H.stat == DEAD)
			continue

		// Apply memory alteration effects
		H.adjustSanity(-2, "scp1981_continuous")
		H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 30 SECONDS, memory_alteration_intensity)

		// Chance to show memory message
		if(prob(15))
			to_chat(H, span_notice(pick(memory_messages)))

		// Add to affected list
		if(!(H in affected_humans))
			affected_humans += H

	// Clean up affected list
	for(var/mob/living/carbon/human/H in affected_humans)
		if(!(H in range(affect_range, src)))
			affected_humans -= H

	cooldown_time = world.time + AFFECT_COOLDOWN

// SCP-1981 abilities
/obj/structure/scp1981/verb/toggle_active()
	set name = "Toggle Active"
	set category = "SCP-1981"
	set src in view(1)

	active = !active
	if(active)
		to_chat(usr, span_notice("SCP-1981 is now active."))
		START_PROCESSING(SSobj, src)
	else
		to_chat(usr, span_notice("SCP-1981 is now inactive."))
		STOP_PROCESSING(SSobj, src)

/obj/structure/scp1981/verb/increase_intensity()
	set name = "Increase Intensity"
	set category = "SCP-1981"
	set src in view(1)

	if(memory_alteration_intensity >= max_intensity)
		to_chat(usr, span_warning("Maximum intensity already reached."))
		return

	memory_alteration_intensity++
	to_chat(usr, span_notice("Memory alteration intensity increased to [memory_alteration_intensity]."))

	// Apply stronger effects to all affected humans
	for(var/mob/living/carbon/human/H in affected_humans)
		H.adjustSanity(-5, "scp1981_intensity_increase")
		H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 60 SECONDS, memory_alteration_intensity)

/obj/structure/scp1981/verb/decrease_intensity()
	set name = "Decrease Intensity"
	set category = "SCP-1981"
	set src in view(1)

	if(memory_alteration_intensity <= 1)
		to_chat(usr, span_warning("Minimum intensity already reached."))
		return

	memory_alteration_intensity--
	to_chat(usr, span_notice("Memory alteration intensity decreased to [memory_alteration_intensity]."))

/obj/structure/scp1981/verb/trigger_memory_flash()
	set name = "Trigger Memory Flash"
	set category = "SCP-1981"
	set src in view(1)

	if(world.time < cooldown_time)
		to_chat(usr, span_warning("SCP-1981 needs time to recharge."))
		return

	// Trigger memory flash for all nearby humans
	for(var/mob/living/carbon/human/H in range(affect_range, src))
		to_chat(H, span_notice("You experience a vivid memory flash..."))
		to_chat(H, span_notice(pick(memory_messages)))
		H.adjustSanity(-10, "scp1981_memory_flash")
		H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 120 SECONDS, memory_alteration_intensity * 2)
		// Vision effects removed (Foundation-19 style)

	cooldown_time = world.time + AFFECT_COOLDOWN
	playsound(src, 'sound/scp/scp1981/memory_flash.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP1981_MEMORY_FLASH_TRIGGERED)

/obj/structure/scp1981/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("The cutout appears to be watching you.")
		. += span_notice("Memory alteration intensity: [memory_alteration_intensity]/[max_intensity]")
		. += span_notice("Affected humans: [length(affected_humans)]")
	else
		. += span_notice("The cutout appears to be inactive.")

// Cross-SCP interaction methods
/obj/structure/scp1981/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage SCP-1981
	to_chat(victim, span_warning("The corrosive effect damages the cutout!"))
	// Reduce effectiveness temporarily
	memory_alteration_intensity = max(1, memory_alteration_intensity - 1)

/obj/structure/scp1981/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can help resist SCP-1981's effects
	if(patient in range(affect_range, src))
		to_chat(patient, span_notice("The cure's power helps you resist the memory alterations."))
		patient.adjustSanity(12, "cure_protection")
		patient.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)

/obj/structure/scp1981/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be affected by SCP-1981
	if(target in range(affect_range, src))
		to_chat(target, span_warning("The memory alterations confuse your rage!"))
		target.adjustSanity(-15, "confused_rage")

/obj/structure/scp1981/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-1981
	if(viewer in range(affect_range, src))
		to_chat(viewer, span_danger("You see a statue near the Reagan cutout!"))
		viewer.adjustSanity(-12, "scp173_near_1981")

/obj/structure/scp1981/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-1981's effects
	if(adaptor in range(affect_range, src))
		to_chat(adaptor, span_notice("Your adaptation helps you resist the memory alterations."))
		adaptor.adjustSanity(8, "adaptation_resistance")

/obj/structure/scp1981/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-1981
	if(host in range(affect_range, src))
		to_chat(host, span_notice("The mask's personality finds the cutout's effects interesting."))
		host.adjustSanity(6, "mask_cutout_interest")

/obj/structure/scp1981/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-1981's effects
	if(explorer in range(affect_range, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure amplifies the memory alterations!"))
		explorer.adjustSanity(-20, "amplified_memory_alteration")

// Research system integration
/obj/structure/scp1981/proc/get_research_data()
	var/list/data = list()
	data["active"] = active
	data["memory_alteration_intensity"] = memory_alteration_intensity
	data["max_intensity"] = max_intensity
	data["affected_humans"] = length(affected_humans)
	data["affect_range"] = affect_range
	data["cooldown_remaining"] = max(0, cooldown_time - world.time)
	return data


