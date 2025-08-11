// SCP-1048: The Teddy Bear
// A teddy bear that can create more teddy bears and has various abilities

/mob/living/simple_animal/hostile/scp1048
	name = "SCP-1048"
	desc = "A small, brown teddy bear with button eyes and a friendly appearance. It seems to be alive and aware."
	icon = 'icons/mob/animal.dmi'
	icon_state = "scp1048"
	icon_living = "scp1048"
	icon_dead = "scp1048_dead"
	maxHealth = 200
	health = 200
	see_in_dark = 6
	move_to_delay = 3
	response_help_continuous = "hugs"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "hits"
	friendly_verb_continuous = "hugs"
	friendly_verb_simple = "hug"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_NONE
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE
	// Make it non-aggressive
	AIStatus = AI_OFF

	// SCP-1048 specific variables
	var/reproduction_cooldown = 0
	var/REPRODUCTION_COOLDOWN_TIME = 5 MINUTES
	var/max_offspring = 5
	var/current_offspring = 0
	var/list/offspring_list = list()
	var/comfort_aura_range = 3
	var/list/comforted_humans = list()
	var/aggression_level = 0 // 0-10 scale
	var/protection_mode = FALSE

/mob/living/simple_animal/hostile/scp1048/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"teddy bear",
		SCP_EUCLID,
		"1048",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL|MAUDIBLE
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/simple_animal/hostile/scp1048, comfort_effect)
	SCP.memetic_sounds = list('sound/scp/scp1048/hug1.ogg', 'sound/scp/scp1048/hug2.ogg', 'sound/scp/scp1048/hug3.ogg')
	SCP.compInit()

	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp1048/proc/CreateOffspring,
		/mob/living/simple_animal/hostile/scp1048/proc/ComfortTarget,
		/mob/living/simple_animal/hostile/scp1048/proc/ProtectTarget,
		/mob/living/simple_animal/hostile/scp1048/proc/PlayWithTarget,
		/mob/living/simple_animal/hostile/scp1048/proc/ToggleProtectionMode,
	))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

	// Start comfort aura
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/scp1048/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

/mob/living/simple_animal/hostile/scp1048/process()
	. = ..()
	apply_comfort_aura()

/mob/living/simple_animal/hostile/scp1048/proc/comfort_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply comfort effects
	H.adjustSanity(8, "scp1048_comfort")
	H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
	H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
	H.remove_sanity_effect(SANITY_EFFECT_WITHDRAWAL)

	// Heal minor damage
	H.adjustBruteLoss(-3)
	H.adjustFireLoss(-3)

	to_chat(H, span_notice("The teddy bear gives you a warm, comforting hug!"))

/mob/living/simple_animal/hostile/scp1048/proc/apply_comfort_aura()
	for(var/mob/living/carbon/human/H in range(comfort_aura_range, src))
		if(H.stat == DEAD)
			continue

		// Apply continuous comfort effect
		H.adjustSanity(0.5, "scp1048_aura")

		// Remove negative sanity effects over time
		if(prob(8))
			H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
		if(prob(8))
			H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)

		// Add to comforted list
		if(!(H in comforted_humans))
			comforted_humans += H

	// Clean up comforted list
	for(var/mob/living/carbon/human/H in comforted_humans)
		if(!(H in range(comfort_aura_range, src)))
			comforted_humans -= H

// SCP-1048 abilities
/mob/living/simple_animal/hostile/scp1048/proc/CreateOffspring()
	set category = "SCP-1048"
	set name = "Create Offspring"

	if(world.time < reproduction_cooldown)
		to_chat(src, span_warning("You need time to rest before creating another teddy bear."))
		return

	if(current_offspring >= max_offspring)
		to_chat(src, span_warning("You have reached the maximum number of offspring."))
		return

	// Create offspring
	var/mob/living/simple_animal/hostile/scp1048_offspring/offspring = new(get_turf(src))
	offspring_list += offspring
	current_offspring++

	reproduction_cooldown = world.time + REPRODUCTION_COOLDOWN_TIME

	to_chat(src, span_notice("You create a new teddy bear offspring!"))
	playsound(src, 'sound/scp/scp1048/create.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP1048_OFFSPRING_CREATED, offspring)

/mob/living/simple_animal/hostile/scp1048/proc/ComfortTarget()
	set category = "SCP-1048"
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
	to_chat(src, span_notice("You comfort [target] with a warm hug."))
	to_chat(target, span_notice("SCP-1048 gives you a warm, comforting hug!"))

	// Apply comfort effects
	target.adjustSanity(15, "scp1048_hug")
	target.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
	target.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
	target.remove_sanity_effect(SANITY_EFFECT_WITHDRAWAL)

	// Heal some damage
	target.adjustBruteLoss(-8)
	target.adjustFireLoss(-8)

	playsound(target, 'sound/scp/scp1048/hug.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP1048_COMFORTED, target)

/mob/living/simple_animal/hostile/scp1048/proc/ProtectTarget()
	set category = "SCP-1048"
	set name = "Protect Target"

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat != DEAD)
			nearby_targets += H

	if(!nearby_targets.len)
		to_chat(src, span_warning("No one nearby to protect."))
		return

	var/mob/living/carbon/human/target = input(src, "Select target to protect:", "Protect Target") as null|anything in nearby_targets
	if(!target)
		return

	// Protect the target
	to_chat(src, span_notice("You vow to protect [target]!"))
	to_chat(target, span_notice("SCP-1048 promises to protect you!"))

	// Apply protection effects
	target.adjustSanity(10, "scp1048_protection")
	protection_mode = TRUE
	aggression_level = min(10, aggression_level + 2)

	// Temporarily increase damage
	melee_damage_lower = 8
	melee_damage_upper = 15

	playsound(target, 'sound/scp/scp1048/protect.ogg', 50, TRUE)

	// Reset after some time
	addtimer(CALLBACK(src, PROC_REF(reset_protection_mode)), 2 MINUTES)

	SEND_SIGNAL(src, COMSIG_SCP1048_PROTECTING, target)

/mob/living/simple_animal/hostile/scp1048/proc/PlayWithTarget()
	set category = "SCP-1048"
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
	to_chat(target, span_notice("SCP-1048 plays with you! You feel your spirits lifting!"))

	// Apply play effects
	target.adjustSanity(12, "scp1048_play")
	target.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
	target.remove_sanity_effect(SANITY_EFFECT_WITHDRAWAL)

	// Heal minor damage
	target.adjustBruteLoss(-3)
	target.adjustFireLoss(-3)

	playsound(target, 'sound/scp/scp1048/play.ogg', 50, TRUE)

	SEND_SIGNAL(src, COMSIG_SCP1048_PLAYED, target)

/mob/living/simple_animal/hostile/scp1048/proc/ToggleProtectionMode()
	set category = "SCP-1048"
	set name = "Toggle Protection Mode"

	protection_mode = !protection_mode
	if(protection_mode)
		to_chat(src, span_notice("Protection mode activated. You will defend those in need."))
		aggression_level = min(10, aggression_level + 3)
		melee_damage_lower = 8
		melee_damage_upper = 15
	else
		to_chat(src, span_notice("Protection mode deactivated. You return to your peaceful state."))
		aggression_level = max(0, aggression_level - 2)
		melee_damage_lower = 5
		melee_damage_upper = 10

/mob/living/simple_animal/hostile/scp1048/proc/reset_protection_mode()
	protection_mode = FALSE
	aggression_level = max(0, aggression_level - 2)
	melee_damage_lower = 5
	melee_damage_upper = 10
	to_chat(src, span_notice("Protection mode has ended."))

// Cross-SCP interaction methods
/mob/living/simple_animal/hostile/scp1048/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage SCP-1048
	to_chat(victim, span_warning("The corrosive effect damages the teddy bear!"))
	adjustHealth(15)

/mob/living/simple_animal/hostile/scp1048/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can enhance SCP-1048's healing
	if(patient in range(5, src))
		to_chat(patient, span_notice("The cure's power enhances the teddy bear's comfort."))
		patient.adjustSanity(12, "enhanced_comfort")

/mob/living/simple_animal/hostile/scp1048/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-1048 can calm SCP-096's rage
	if(target in range(5, src))
		to_chat(target, span_notice("The teddy bear's comforting presence helps calm your rage."))
		target.adjustSanity(20, "teddy_calm")
		if(prob(30))
			SEND_SIGNAL(source, COMSIG_SCP096_RAGE_ENDED)

/mob/living/simple_animal/hostile/scp1048/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-1048
	if(viewer in range(5, src))
		to_chat(viewer, span_danger("You see a statue near the teddy bear!"))
		viewer.adjustSanity(-8, "scp173_near_1048")

/mob/living/simple_animal/hostile/scp1048/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-1048's effects
	if(adaptor in range(5, src))
		to_chat(adaptor, span_notice("Your adaptation helps you resist the teddy bear's influence."))
		adaptor.adjustSanity(3, "adaptation_resistance")

/mob/living/simple_animal/hostile/scp1048/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-1048
	if(host in range(5, src))
		to_chat(host, span_notice("The mask's personality finds the teddy bear cute."))
		host.adjustSanity(8, "mask_teddy_affection")

/mob/living/simple_animal/hostile/scp1048/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can dampen SCP-1048's effects
	if(explorer in range(5, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure dampens the teddy bear's comfort."))
		explorer.adjustSanity(-8, "dampened_comfort")

// Override attack to be more protective when in protection mode
/mob/living/simple_animal/hostile/scp1048/UnarmedAttack(atom/A, proximity)
	if(protection_mode && isliving(A) && !ishuman(A))
		// Attack non-humans more aggressively in protection mode
		to_chat(src, span_notice("You defend against [A]!"))
		return ..()
	else if(isliving(A) && ishuman(A))
		var/mob/living/carbon/human/H = A
		// Always hug humans
		to_chat(src, span_notice("You give [H] a comforting hug!"))
		to_chat(H, span_notice("SCP-1048 gives you a warm hug!"))
		H.adjustSanity(8, "scp1048_hug")
		playsound(H, 'sound/scp/scp1048/hug.ogg', 50, TRUE)
		return
	return ..()

// Research system integration
/mob/living/simple_animal/hostile/scp1048/proc/get_research_data()
	var/list/data = list()
	data["health"] = health
	data["max_health"] = maxHealth
	data["current_offspring"] = current_offspring
	data["max_offspring"] = max_offspring
	data["comforted_humans"] = length(comforted_humans)
	data["comfort_aura_range"] = comfort_aura_range
	data["aggression_level"] = aggression_level
	data["protection_mode"] = protection_mode
	data["reproduction_cooldown_remaining"] = max(0, reproduction_cooldown - world.time)
	return data

// SCP-1048 Offspring
/mob/living/simple_animal/hostile/scp1048_offspring
	name = "SCP-1048-A"
	desc = "A small teddy bear offspring. It appears to be a miniature version of SCP-1048."
	icon = 'icons/mob/animal.dmi'
	icon_state = "scp1048_offspring"
	icon_living = "scp1048_offspring"
	icon_dead = "scp1048_offspring_dead"
	maxHealth = 100
	health = 100
	see_in_dark = 4
	move_to_delay = 4
	response_help_continuous = "hugs"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "hits"
	friendly_verb_continuous = "hugs"
	friendly_verb_simple = "hug"
	harm_intent_damage = 2
	melee_damage_lower = 2
	melee_damage_upper = 5
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_NONE
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE
	// Make it non-aggressive
	AIStatus = AI_OFF

	var/comfort_range = 2
	var/list/comforted_targets = list()

/mob/living/simple_animal/hostile/scp1048_offspring/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"teddy bear offspring",
		SCP_SAFE,
		"1048-A",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/simple_animal/hostile/scp1048_offspring, comfort_effect)
	SCP.compInit()

	// Start comfort aura
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/scp1048_offspring/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

/mob/living/simple_animal/hostile/scp1048_offspring/process()
	. = ..()
	apply_comfort_aura()

/mob/living/simple_animal/hostile/scp1048_offspring/proc/comfort_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply comfort effects (weaker than parent)
	H.adjustSanity(4, "scp1048_offspring_comfort")
	H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
	H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)

	// Heal minor damage
	H.adjustBruteLoss(-1)
	H.adjustFireLoss(-1)

	to_chat(H, span_notice("The small teddy bear gives you a gentle hug!"))

/mob/living/simple_animal/hostile/scp1048_offspring/proc/apply_comfort_aura()
	for(var/mob/living/carbon/human/H in range(comfort_range, src))
		if(H.stat == DEAD)
			continue

		// Apply continuous comfort effect (weaker than parent)
		H.adjustSanity(0.2, "scp1048_offspring_aura")

		// Remove negative sanity effects over time
		if(prob(5))
			H.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
		if(prob(5))
			H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)

		// Add to comforted list
		if(!(H in comforted_targets))
			comforted_targets += H

	// Clean up comforted list
	for(var/mob/living/carbon/human/H in comforted_targets)
		if(!(H in range(comfort_range, src)))
			comforted_targets -= H

// Override attack to be friendly
/mob/living/simple_animal/hostile/scp1048_offspring/UnarmedAttack(atom/A, proximity)
	if(isliving(A) && ishuman(A))
		var/mob/living/carbon/human/H = A
		// Always hug humans
		to_chat(src, span_notice("You give [H] a gentle hug!"))
		to_chat(H, span_notice("The small teddy bear gives you a gentle hug!"))
		H.adjustSanity(4, "scp1048_offspring_hug")
		playsound(H, 'sound/scp/scp1048/hug.ogg', 30, TRUE)
		return
	return ..()

// Research system integration
/mob/living/simple_animal/hostile/scp1048_offspring/proc/get_research_data()
	var/list/data = list()
	data["health"] = health
	data["max_health"] = maxHealth
	data["comforted_targets"] = length(comforted_targets)
	data["comfort_range"] = comfort_range
	return data

