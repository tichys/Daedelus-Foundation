// SCP-999: The Tickle Monster
// A friendly orange blob that makes people happy

/mob/living/simple_animal/hostile/scp999
	name = "SCP-999"
	desc = "A large, amorphous, gelatinous mass of translucent orange slime. It appears to be friendly and playful."
	icon = 'icons/mob/animal.dmi'
	icon_state = "scp999"
	icon_living = "scp999"
	icon_dead = "scp999_dead"
	maxHealth = 300
	health = 300
	see_in_dark = 8
	move_to_delay = 2
	response_help_continuous = "pets"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "hits"
	friendly_verb_continuous = "tickles"
	friendly_verb_simple = "tickle"
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

	// SCP-999 specific variables
	var/healing_cooldown = 0
	var/HEALING_COOLDOWN_TIME = 30 SECONDS
	var/happiness_aura_range = 5
	var/list/affected_humans = list()
	var/tickle_intensity = 1
	var/max_tickle_intensity = 5

/mob/living/simple_animal/scp999/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"tickle monster",
		SCP_SAFE,
		"999",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL|MAUDIBLE
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/simple_animal/hostile/scp999, happiness_effect)
	SCP.memetic_sounds = list('sound/scp/scp999/happy1.ogg', 'sound/scp/scp999/happy2.ogg', 'sound/scp/scp999/happy3.ogg')
	SCP.compInit()

	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp999/proc/TickleTarget,
		/mob/living/simple_animal/hostile/scp999/proc/HealTarget,
		/mob/living/simple_animal/hostile/scp999/proc/PlayWithTarget,
		/mob/living/simple_animal/hostile/scp999/proc/ComfortTarget,
	))

	// Register signals for cross-SCP interactions (temporarily disabled)
	// RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	// RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	// RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	// RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	// RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	// RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	// RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

	// Start happiness aura
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/scp999/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

/mob/living/simple_animal/hostile/scp999/process()
	. = ..()
	apply_happiness_aura()

/mob/living/simple_animal/hostile/scp999/proc/happiness_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply happiness effects (simplified)
	H.adjustSanity(10, "scp999_happiness")

	// Heal minor damage
	H.adjustBruteLoss(-5)
	H.adjustFireLoss(-5)
	H.adjustToxLoss(-5)

	to_chat(H, span_notice("You feel incredibly happy and content!"))

/mob/living/simple_animal/hostile/scp999/proc/apply_happiness_aura()
	for(var/mob/living/carbon/human/H in range(happiness_aura_range, src))
		if(H.stat == DEAD)
			continue

		// Apply continuous happiness effect
		H.adjustSanity(1, "scp999_aura")

		// Apply continuous happiness effect
		H.adjustSanity(1, "scp999_aura")

		// Add to affected list
		if(!(H in affected_humans))
			affected_humans += H

	// Clean up affected list
	for(var/mob/living/carbon/human/H in affected_humans)
		if(!(H in range(happiness_aura_range, src)))
			affected_humans -= H

// SCP-999 abilities
/mob/living/simple_animal/hostile/scp999/proc/TickleTarget()
	set category = "SCP-999"
	set name = "Tickle Target"

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(2, src))
		if(H.stat != DEAD)
			nearby_targets += H

	if(!nearby_targets.len)
		to_chat(src, span_warning("No one nearby to tickle."))
		return

	var/mob/living/carbon/human/target = input(src, "Select target to tickle:", "Tickle Target") as null|anything in nearby_targets
	if(!target)
		return

	// Tickle the target
	to_chat(src, span_notice("You tickle [target] playfully!"))
	to_chat(target, span_notice("SCP-999 tickles you! You can't help but laugh!"))

	// Apply tickle effects
	target.adjustSanity(15, "scp999_tickle")

	// Heal some damage
	target.adjustBruteLoss(-10)
	target.adjustFireLoss(-10)

	// Play tickle sound
	playsound(target, 'sound/scp/scp999/tickle.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP999_TICKLED, target)

/mob/living/simple_animal/hostile/scp999/proc/HealTarget()
	set category = "SCP-999"
	set name = "Heal Target"

	if(world.time < healing_cooldown)
		to_chat(src, span_warning("You need time to rest before healing again."))
		return

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat != DEAD)
			nearby_targets += H

	if(!nearby_targets.len)
		to_chat(src, span_warning("No one nearby to heal."))
		return

	var/mob/living/carbon/human/target = input(src, "Select target to heal:", "Heal Target") as null|anything in nearby_targets
	if(!target)
		return

	// Heal the target
	to_chat(src, span_notice("You focus your healing energy on [target]."))
	to_chat(target, span_notice("SCP-999 envelops you in warm, healing slime!"))

	// Apply healing effects
	target.adjustBruteLoss(-30)
	target.adjustFireLoss(-30)
	target.adjustToxLoss(-30)
	target.adjustOxyLoss(-30)
	target.adjustSanity(25, "scp999_heal")

	// Apply healing effects
	target.adjustSanity(25, "scp999_heal")

	healing_cooldown = world.time + HEALING_COOLDOWN_TIME
	playsound(target, 'sound/scp/scp999/heal.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP999_HEALED, target)

/mob/living/simple_animal/hostile/scp999/proc/PlayWithTarget()
	set category = "SCP-999"
	set name = "Play With Target"

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(2, src))
		if(H.stat != DEAD)
			nearby_targets += H

	if(!nearby_targets.len)
		to_chat(src, span_warning("No one nearby to play with."))
		return

	var/mob/living/carbon/human/target = input(src, "Select target to play with:", "Play With Target") as null|anything in nearby_targets
	if(!target)
		return

	// Play with the target
	to_chat(src, span_notice("You play happily with [target]!"))
	to_chat(target, span_notice("SCP-999 plays with you! You feel your spirits lifting!"))

	// Apply play effects
	target.adjustSanity(20, "scp999_play")

	// Heal minor damage
	target.adjustBruteLoss(-5)
	target.adjustFireLoss(-5)

	playsound(target, 'sound/scp/scp999/play.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP999_PLAYED, target)

/mob/living/simple_animal/hostile/scp999/proc/ComfortTarget()
	set category = "SCP-999"
	set name = "Comfort Target"

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat != DEAD)
			nearby_targets += H

	if(!nearby_targets.len)
		to_chat(src, span_warning("No one nearby to comfort."))
		return

	var/mob/living/carbon/human/target = input(src, "Select target to comfort:", "Comfort Target") as null|anything in nearby_targets
	if(!target)
		return

	// Comfort the target
	to_chat(src, span_notice("You comfort [target] with your warm presence."))
	to_chat(target, span_notice("SCP-999 comforts you with its warm, gentle presence. You feel safe and loved."))

	// Apply comfort effects
	target.adjustSanity(30, "scp999_comfort")

	// Heal more damage
	target.adjustBruteLoss(-15)
	target.adjustFireLoss(-15)
	target.adjustToxLoss(-15)

	playsound(target, 'sound/scp/scp999/comfort.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP999_COMFORTED, target)

// Cross-SCP interaction methods
/mob/living/simple_animal/hostile/scp999/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can hurt SCP-999
	to_chat(victim, span_warning("The corrosive effect hurts the friendly slime!"))
	adjustHealth(20)

/mob/living/simple_animal/hostile/scp999/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can enhance SCP-999's healing
	if(patient in range(5, src))
		to_chat(patient, span_notice("The cure's power enhances the slime's healing abilities."))
		patient.adjustSanity(15, "enhanced_slime_healing")

/mob/living/simple_animal/hostile/scp999/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-999 can calm SCP-096's rage
	if(target in range(5, src))
		to_chat(target, span_notice("The friendly slime's presence calms your rage."))
		target.adjustSanity(25, "slime_calm")
		SEND_SIGNAL(source, COMSIG_SCP096_RAGE_ENDED)

/mob/living/simple_animal/hostile/scp999/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-999
	if(viewer in range(5, src))
		to_chat(viewer, span_danger("You see a statue near the friendly slime!"))
		viewer.adjustSanity(-10, "scp173_near_999")

/mob/living/simple_animal/hostile/scp999/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-999's effects
	if(adaptor in range(5, src))
		to_chat(adaptor, span_notice("Your adaptation helps you resist the slime's influence."))
		adaptor.adjustSanity(5, "adaptation_resistance")

/mob/living/simple_animal/hostile/scp999/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-999
	if(host in range(5, src))
		to_chat(host, span_notice("The mask's personality finds the slime adorable."))
		host.adjustSanity(10, "mask_slime_affection")

/mob/living/simple_animal/hostile/scp999/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can dampen SCP-999's effects
	if(explorer in range(5, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure dampens the slime's happiness."))
		explorer.adjustSanity(-10, "dampened_happiness")

// Override attack to be friendly
/mob/living/simple_animal/hostile/scp999/UnarmedAttack(atom/A, proximity)
	if(isliving(A) && ishuman(A))
		var/mob/living/carbon/human/H = A
		// Always tickle instead of attack
		to_chat(src, span_notice("You tickle [H] playfully!"))
		to_chat(H, span_notice("SCP-999 tickles you! You can't help but laugh!"))
		H.adjustSanity(10, "scp999_tickle")
		playsound(H, 'sound/scp/scp999/tickle.ogg', 50, TRUE)
		return
	return ..()

// Research system integration
/mob/living/simple_animal/hostile/scp999/proc/get_research_data()
	var/list/data = list()
	data["health"] = health
	data["max_health"] = maxHealth
	data["affected_humans"] = length(affected_humans)
	data["happiness_aura_range"] = happiness_aura_range
	data["healing_cooldown_remaining"] = max(0, healing_cooldown - world.time)
	return data

