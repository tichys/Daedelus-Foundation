// SCP-500: Panacea
// A pill that can cure any disease or condition

/obj/item/reagent_containers/pill/scp500
	name = "SCP-500"
	desc = "A small red pill with the number '500' printed on it. It appears to be a miracle cure."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill5"
	list_reagents = list(/datum/reagent/medicine/scp500 = 1)
	volume = 1
	var/uses_remaining = 1
	var/max_uses = 1
	var/regeneration_time = 0
	var/REGENERATION_DELAY = 24 HOURS

/obj/item/reagent_containers/pill/scp500/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"panacea pill",
		SCP_SAFE,
		"500",
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

/obj/item/reagent_containers/pill/scp500/Destroy()
	QDEL_NULL(SCP)
	return ..()

/obj/item/reagent_containers/pill/scp500/attack(mob/living/M, mob/user, def_zone)
	if(!ishuman(M))
		return ..()

	var/mob/living/carbon/human/H = M
	if(uses_remaining <= 0)
		to_chat(user, span_warning("SCP-500 has no uses remaining."))
		return

	// Apply panacea effect
	apply_panacea_effect(H, user)
	uses_remaining--

	if(uses_remaining <= 0)
		// Start regeneration timer
		regeneration_time = world.time + REGENERATION_DELAY
		addtimer(CALLBACK(src, PROC_REF(regenerate_pill)), REGENERATION_DELAY)

	to_chat(user, span_notice("You administer SCP-500 to [H]."))
	to_chat(H, span_notice("You feel an overwhelming sense of wellness and healing."))

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP500_ADMINISTERED, H, user)

	return TRUE

/obj/item/reagent_containers/pill/scp500/proc/apply_panacea_effect(mob/living/carbon/human/target, mob/user)
	// Heal all damage
	target.adjustBruteLoss(-target.getBruteLoss())
	target.adjustFireLoss(-target.getFireLoss())
	target.adjustToxLoss(-target.getToxLoss())
	target.adjustOxyLoss(-target.getOxyLoss())

	// Restore organs
	for(var/obj/item/organ/O in target.organs)
		O.setOrganDamage(0)

	// Cure diseases
	for(var/datum/disease/D in target.diseases)
		D.cure()

	// Remove sanity effects
	target.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)
	target.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
	target.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
	target.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
	target.remove_sanity_effect(SANITY_EFFECT_AGGRESSION)
	target.remove_sanity_effect(SANITY_EFFECT_WITHDRAWAL)

	// Restore sanity
	target.adjustSanity(50, "scp500_panacea")

	// Remove vision effects
			// Vision effects removed (Foundation-19 style)

	// Remove addictions
	for(var/addiction_type in target.mind.active_addictions)
		target.mind.remove_addiction_points(addiction_type, 1000) // Force remove addiction

	// Heal brain damage
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, -target.getOrganLoss(ORGAN_SLOT_BRAIN))

	// Remove radiation (if supported)
	// target.radiation = 0

	// Remove genetic mutations
	target.dna.remove_all_mutations()

	// Remove cybernetic implants (optional)
	// for(var/obj/item/organ/cyberimp/C in target.organs)
	//     C.Remove(target)

/obj/item/reagent_containers/pill/scp500/proc/regenerate_pill()
	uses_remaining = max_uses
	regeneration_time = 0
	to_chat(get_turf(src), span_notice("SCP-500 has regenerated and is ready for use again."))

/obj/item/reagent_containers/pill/scp500/examine(mob/user)
	. = ..()
	if(uses_remaining > 0)
		. += span_notice("Uses remaining: [uses_remaining]")
	else
		. += span_warning("No uses remaining.")
		if(regeneration_time > 0)
			var/time_remaining = regeneration_time - world.time
			if(time_remaining > 0)
				. += span_notice("Regenerates in [round(time_remaining / 600, 0.1)] minutes.")

// Cross-SCP interaction methods
/obj/item/reagent_containers/pill/scp500/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage SCP-500
	to_chat(victim, span_warning("The corrosive effect damages the panacea pill!"))
	// Reduce effectiveness temporarily
	uses_remaining = max(0, uses_remaining - 1)

/obj/item/reagent_containers/pill/scp500/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can enhance SCP-500's effects
	if(patient in range(3, src))
		to_chat(patient, span_notice("The cure's power enhances the panacea's healing properties."))
		// Increase healing effect
		patient.adjustSanity(10, "enhanced_panacea")

/obj/item/reagent_containers/pill/scp500/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be calmed by SCP-500
	if(target in range(3, src))
		to_chat(target, span_notice("The panacea's calming effect helps soothe your rage."))
		target.adjustSanity(15, "panacea_calm")

/obj/item/reagent_containers/pill/scp500/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-500
	if(viewer in range(3, src))
		to_chat(viewer, span_danger("You see a statue near the panacea pill!"))
		viewer.adjustSanity(-10, "scp173_near_500")

/obj/item/reagent_containers/pill/scp500/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-500's effects
	if(adaptor in range(3, src))
		to_chat(adaptor, span_notice("Your adaptation helps you resist the panacea's influence."))
		adaptor.adjustSanity(5, "adaptation_resistance")

/obj/item/reagent_containers/pill/scp500/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-500
	if(host in range(3, src))
		to_chat(host, span_notice("The mask's personality finds the panacea interesting."))
		host.adjustSanity(8, "mask_panacea_interest")

/obj/item/reagent_containers/pill/scp500/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-500's effects
	if(explorer in range(3, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure affects the panacea!"))
		explorer.adjustSanity(-20, "amplified_panacea")

// Panacea reagent
/datum/reagent/medicine/scp500
	name = "Panacea"
	description = "A miraculous substance that can cure any ailment."
	reagent_state = SOLID
	color = "#FF0000"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 5

/datum/reagent/medicine/scp500/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	// Continuous healing effect
	M.adjustBruteLoss(-2 * delta_time)
	M.adjustFireLoss(-2 * delta_time)
	M.adjustToxLoss(-2 * delta_time)
	M.adjustOxyLoss(-2 * delta_time)

	if(M.sanity)
		M.adjustSanity(1 * delta_time, "panacea_continuous")

/datum/reagent/medicine/scp500/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	// Overdose can cause temporary euphoria
	M.adjustSanity(5 * delta_time, "panacea_overdose")
	if(DT_PROB(10, delta_time))
		to_chat(M, span_notice("You feel incredibly euphoric!"))

// Research system integration
/obj/item/reagent_containers/pill/scp500/proc/get_research_data()
	var/list/data = list()
	data["uses_remaining"] = uses_remaining
	data["max_uses"] = max_uses
	data["regeneration_time"] = regeneration_time
	data["time_until_regeneration"] = max(0, regeneration_time - world.time)
	return data

