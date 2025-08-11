// SCP-343: "God"
// A benevolent entity with reality-warping abilities that appears as an elderly man

/mob/living/carbon/human/scp343
	name = "SCP-343"
	desc = "An elderly man with a kind expression. He radiates an aura of benevolence and wisdom."
	icon = 'icons/mob/human.dmi'
	icon_state = "scp343"
	maxHealth = 1000
	health = 1000
	see_in_dark = 10

	// SCP-343 specific variables
	var/benevolence_aura_range = 8
	var/list/blessed_humans = list()
	var/reality_warp_cooldown = 0
	var/REALITY_WARP_COOLDOWN = 5 MINUTES
	var/healing_cooldown = 0
	var/HEALING_COOLDOWN = 2 MINUTES
	var/protection_cooldown = 0
	var/PROTECTION_COOLDOWN = 3 MINUTES
	var/list/protected_humans = list()
	var/max_protected = 5

/mob/living/carbon/human/scp343/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"god",
		SCP_SAFE,
		"343",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL | MPERSISTENT
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/carbon/human/scp343, benevolence_effect)
	SCP.compInit()

	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/carbon/human/scp343/proc/RealityWarp,
		/mob/living/carbon/human/scp343/proc/HealHuman,
		/mob/living/carbon/human/scp343/proc/ProtectHuman,
		/mob/living/carbon/human/scp343/proc/BlessArea,
		/mob/living/carbon/human/scp343/proc/InteractWithSCP,
	))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

	// Start benevolence aura
	START_PROCESSING(SSobj, src)

	// Set appearance
	real_name = "SCP-343"
	name = real_name
	gender = MALE
	age = 80
	skin_tone = "caucasian1"
	hair_color = "#FFFFFF"
	facial_hair_color = "#FFFFFF"
	eye_color_left = "#0000FF"
	eye_color_right = "#0000FF"
	update_body()

/mob/living/carbon/human/scp343/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

/mob/living/carbon/human/scp343/process()
	. = ..()
	apply_benevolence_aura()

/mob/living/carbon/human/scp343/proc/benevolence_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply benevolence effects
	H.adjustSanity(20, "scp343_benevolence")
	H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
	H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
	H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
	H.remove_sanity_effect(SANITY_EFFECT_AGGRESSION)
	H.add_sanity_effect(SANITY_EFFECT_CALM, 300 SECONDS, 3)

	// Apply vision effects
	// Clear vision effects (Foundation-19 style - no complex modifiers)

	// Heal some damage
	H.adjustBruteLoss(-10)
	H.adjustFireLoss(-10)
	H.adjustToxLoss(-10)

	to_chat(H, span_notice("You feel a sense of peace and well-being in SCP-343's presence."))

/mob/living/carbon/human/scp343/proc/apply_benevolence_aura()
	for(var/mob/living/carbon/human/H in range(benevolence_aura_range, src))
		if(H.stat == DEAD)
			continue

		// Apply continuous benevolence effects
		H.adjustSanity(2, "scp343_aura")
		// Clear vision effects (Foundation-19 style - no complex modifiers)

		// Chance to provide stronger effects
		if(prob(10))
			H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
			H.add_sanity_effect(SANITY_EFFECT_CALM, 120 SECONDS, 2)

		// Add to blessed list
		if(!(H in blessed_humans))
			blessed_humans += H

	// Clean up blessed list
	for(var/mob/living/carbon/human/H in blessed_humans)
		if(!(H in range(benevolence_aura_range, src)))
			blessed_humans -= H

// SCP-343 abilities
/mob/living/carbon/human/scp343/proc/RealityWarp()
	set category = "SCP-343"
	set name = "Reality Warp"

	if(world.time < reality_warp_cooldown)
		to_chat(src, span_warning("You need time to recharge your reality-warping ability."))
		return

	// Warp reality in the area
	for(var/mob/living/carbon/human/H in range(5, src))
		to_chat(H, span_notice("Reality seems to shift and become more harmonious around you."))
		H.adjustSanity(25, "scp343_reality_warp")
		H.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)
		H.add_sanity_effect(SANITY_EFFECT_CALM, 240 SECONDS, 3)
		H.adjustBruteLoss(-20)
		H.adjustFireLoss(-20)
		H.adjustToxLoss(-20)

	// Repair nearby structures
	for(var/obj/structure/S in range(3, src))
		if(S.atom_integrity < S.max_integrity)
			S.atom_integrity = S.max_integrity
			S.update_icon()

	reality_warp_cooldown = world.time + REALITY_WARP_COOLDOWN
	playsound(src, 'sound/scp/scp343/warp.ogg', 50, TRUE)

	to_chat(src, span_notice("You warp reality to bring harmony and healing to the area."))
	SEND_SIGNAL(src, COMSIG_SCP343_REALITY_WARPED)

/mob/living/carbon/human/scp343/proc/HealHuman()
	set category = "SCP-343"
	set name = "Heal Human"

	if(world.time < healing_cooldown)
		to_chat(src, span_warning("You need time to recharge your healing ability."))
		return

	var/list/nearby_humans = list()
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat != DEAD)
			nearby_humans += H

	if(length(nearby_humans) == 0)
		to_chat(src, span_warning("No humans nearby to heal."))
		return

	var/mob/living/carbon/human/target = input(src, "Choose a human to heal:", "Heal Human") as null|mob in nearby_humans
	if(!target)
		return

	// Heal the target
	target.adjustBruteLoss(-50)
	target.adjustFireLoss(-50)
	target.adjustToxLoss(-50)
	target.adjustSanity(30, "scp343_healing")
	target.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
	target.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
	target.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
	target.add_sanity_effect(SANITY_EFFECT_CALM, 300 SECONDS, 3)

	to_chat(target, span_notice("You feel completely healed and at peace."))
	to_chat(src, span_notice("You heal [target.name] completely."))

	healing_cooldown = world.time + HEALING_COOLDOWN
	playsound(src, 'sound/scp/scp343/heal.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP343_HUMAN_HEALED, target)

/mob/living/carbon/human/scp343/proc/ProtectHuman()
	set category = "SCP-343"
	set name = "Protect Human"

	if(world.time < protection_cooldown)
		to_chat(src, span_warning("You need time to recharge your protection ability."))
		return

	if(length(protected_humans) >= max_protected)
		to_chat(src, span_warning("You can only protect a limited number of humans at once."))
		return

	var/list/nearby_humans = list()
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat != DEAD && !(H in protected_humans))
			nearby_humans += H

	if(length(nearby_humans) == 0)
		to_chat(src, span_warning("No unprotected humans nearby."))
		return

	var/mob/living/carbon/human/target = input(src, "Choose a human to protect:", "Protect Human") as null|mob in nearby_humans
	if(!target)
		return

	// Protect the target
	protected_humans += target
	to_chat(target, span_notice("You feel protected by SCP-343's divine presence."))
	to_chat(src, span_notice("You grant divine protection to [target.name]."))

	protection_cooldown = world.time + PROTECTION_COOLDOWN
	playsound(src, 'sound/scp/scp343/protect.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP343_HUMAN_PROTECTED, target)

/mob/living/carbon/human/scp343/proc/BlessArea()
	set category = "SCP-343"
	set name = "Bless Area"

	// Bless the current area
	for(var/mob/living/carbon/human/H in range(8, src))
		if(H.stat == DEAD)
			continue

		to_chat(H, span_notice("The area feels blessed and peaceful."))
		H.adjustSanity(15, "scp343_blessing")
		H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
		H.add_sanity_effect(SANITY_EFFECT_CALM, 180 SECONDS, 2)

	// Create a blessed area effect
	var/obj/effect/blessed_area/blessing = new(get_turf(src))
	QDEL_IN(blessing, 5 MINUTES)

	to_chat(src, span_notice("You bless the area with divine peace."))
	playsound(src, 'sound/scp/scp343/bless.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP343_AREA_BLESSED)

/mob/living/carbon/human/scp343/proc/InteractWithSCP()
	set category = "SCP-343"
	set name = "Interact with SCP"

	var/list/nearby_scps = list()
	for(var/atom/A in range(5, src))
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

/mob/living/carbon/human/scp343/proc/interact_with_049(atom/scp049)
	to_chat(src, span_notice("You bless SCP-049's cure attempts."))
	SEND_SIGNAL(scp049, COMSIG_SCP049_BLESSED, src)

/mob/living/carbon/human/scp343/proc/interact_with_096(atom/scp096)
	to_chat(src, span_notice("You attempt to calm SCP-096 with divine intervention."))
	if(prob(80))
		to_chat(src, span_green("You successfully calm SCP-096."))
		SEND_SIGNAL(scp096, COMSIG_SCP096_DIVINE_CALM, src)
	else
		to_chat(src, span_warning("SCP-096 is too enraged for divine intervention."))

/mob/living/carbon/human/scp343/proc/interact_with_173(atom/scp173)
	to_chat(src, span_notice("You attempt to contain SCP-173 with divine power."))
	to_chat(src, span_warning("SCP-173 resists divine containment."))

/mob/living/carbon/human/scp343/proc/interact_with_106(atom/scp106)
	to_chat(src, span_notice("You attempt to banish SCP-106 with divine power."))
	to_chat(src, span_warning("SCP-106 resists divine banishment."))

/mob/living/carbon/human/scp343/proc/generic_scp_interaction(atom/scp)
	to_chat(src, span_notice("You bless [scp.name] with divine protection."))

// Cross-SCP interaction methods
/mob/living/carbon/human/scp343/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-343 can protect against SCP-106's corrosion
	if(victim in protected_humans)
		to_chat(victim, span_notice("SCP-343's protection shields you from the corrosive effect!"))
		victim.adjustSanity(10, "scp343_protection")
		return

	if(victim in range(5, src))
		to_chat(victim, span_notice("SCP-343's presence lessens the corrosive effect."))
		victim.adjustSanity(5, "scp343_mitigation")

/mob/living/carbon/human/scp343/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-343 can enhance SCP-049's cure
	if(patient in range(5, src))
		to_chat(patient, span_notice("SCP-343's presence enhances the cure's effectiveness."))
		patient.adjustSanity(20, "enhanced_cure")

/mob/living/carbon/human/scp343/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-343 can calm SCP-096's rage
	if(target in range(5, src))
		to_chat(target, span_notice("SCP-343's presence helps calm your rage."))
		target.adjustSanity(15, "scp343_calm")
		target.remove_sanity_effect(SANITY_EFFECT_AGGRESSION)

/mob/living/carbon/human/scp343/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-343 can protect against SCP-173
	if(viewer in range(5, src))
		to_chat(viewer, span_notice("SCP-343's presence protects you from the statue's gaze."))
		viewer.adjustSanity(10, "scp343_protection")

/mob/living/carbon/human/scp343/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-343 can interact with SCP-682's adaptation
	if(adaptor in range(5, src))
		to_chat(adaptor, span_notice("SCP-343's presence influences your adaptation process."))
		adaptor.adjustSanity(8, "scp343_adaptation_influence")

/mob/living/carbon/human/scp343/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-343 can resist SCP-035's possession
	if(host in range(5, src))
		to_chat(host, span_notice("SCP-343's divine presence helps you resist the mask's influence."))
		host.adjustSanity(15, "scp343_resistance")

/mob/living/carbon/human/scp343/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-343 can protect against SCP-087's effects
	if(explorer in range(5, src))
		to_chat(explorer, span_notice("SCP-343's presence protects you from the stairwell's psychological pressure."))
		explorer.adjustSanity(20, "scp343_stairwell_protection")

// Research system integration
/mob/living/carbon/human/scp343/proc/get_research_data()
	var/list/data = list()
	data["health"] = health
	data["max_health"] = maxHealth
	data["blessed_humans"] = length(blessed_humans)
	data["protected_humans"] = length(protected_humans)
	data["max_protected"] = max_protected
	data["benevolence_aura_range"] = benevolence_aura_range
	data["reality_warp_cooldown_remaining"] = max(0, reality_warp_cooldown - world.time)
	data["healing_cooldown_remaining"] = max(0, healing_cooldown - world.time)
	data["protection_cooldown_remaining"] = max(0, protection_cooldown - world.time)
	return data

// Blessed Area Effect
/obj/effect/blessed_area
	name = "Blessed Area"
	desc = "An area blessed by SCP-343. It radiates peace and harmony."
	icon = 'icons/effects/effects.dmi'
	icon_state = "blessed_area"
	layer = ABOVE_MOB_LAYER
	var/list/blessed_humans = list()

/obj/effect/blessed_area/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/blessed_area/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/blessed_area/process()
	. = ..()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat == DEAD)
			continue

		// Apply blessed area effects
		H.adjustSanity(1, "blessed_area")
		// Clear vision effects (Foundation-19 style - no complex modifiers)

		// Add to blessed list
		if(!(H in blessed_humans))
			blessed_humans += H

	// Clean up blessed list
	for(var/mob/living/carbon/human/H in blessed_humans)
		if(!(H in range(3, src)))
			blessed_humans -= H
