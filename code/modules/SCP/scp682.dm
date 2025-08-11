// SCP-682 (The Hard-to-Destroy Reptile)

/datum/scp682_adaptation
	var/adaptation_type = "generic"
	var/strength = 1
	var/duration = 0
	var/start_time = 0
	var/description = ""

/datum/scp682_adaptation/New(adapt_type, strength = 1, duration = 0, desc = "")
	adaptation_type = adapt_type
	src.strength = strength
	src.duration = duration
	src.description = desc
	start_time = world.time

/datum/scp682_adaptation/proc/is_expired()
	if(duration <= 0)
		return FALSE
	return (world.time - start_time) > duration

// Global adaptation tracking
GLOBAL_LIST_INIT(scp682_adaptations, list())

/mob/living/simple_animal/hostile/scp682
	name = "hard-to-destroy reptile"
	desc = "A massive, reptilian creature with incredible regenerative abilities and adaptive capabilities."
	icon = 'icons/mob/animal.dmi'
	icon_state = "682"
	icon_living = "682"
	icon_dead = "682_dead"
	maxHealth = 2000
	health = 2000
	see_in_dark = 8
	move_to_delay = 2
	melee_damage_lower = 40
	melee_damage_upper = 60
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE

	// SCP-682 specific variables
	var/list/adaptations = list()
	var/regeneration_rate = 5
	var/adaptation_cooldown = 30 SECONDS
	var/last_adaptation = 0
	var/containment_breached = FALSE
	var/containment_field_active = FALSE
	var/list/containment_protocols = list()
	var/acid_resistance = 50
	var/fire_resistance = 50
	var/radiation_resistance = 50
	var/list/containment_attempts = list()
	var/evolution_stage = 1
	var/max_evolution_stage = 5

/mob/living/simple_animal/hostile/scp682/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"hard-to-destroy reptile",
		SCP_KETER,
		"682",
		SCP_PLAYABLE
	)
	grant_language(/datum/language/common, TRUE, TRUE)
	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp682/proc/CheckAdaptations,
		/mob/living/simple_animal/hostile/scp682/proc/InteractWithSCP,
		/mob/living/simple_animal/hostile/scp682/proc/ContainmentProtocol,
		/mob/living/simple_animal/hostile/scp682/proc/ForceAdaptation,
	))

// SCP-682 abilities
/mob/living/simple_animal/hostile/scp682/proc/CheckAdaptations()
	set category = "SCP-682"
	set name = "Check Adaptations"

	to_chat(src, span_notice("=== SCP-682 Adaptation Status ==="))
	to_chat(src, span_notice("Evolution Stage: [evolution_stage]/[max_evolution_stage]"))
	to_chat(src, span_notice("Containment Breached: [containment_breached ? "YES" : "NO"]"))
	to_chat(src, span_notice("Active Adaptations: [length(adaptations)]"))

	for(var/datum/scp682_adaptation/adapt in adaptations)
		if(adapt.is_expired())
			to_chat(src, span_notice("- [adapt.description] (EXPIRED)"))
		else
			to_chat(src, span_notice("- [adapt.description] (Strength: [adapt.strength])"))

	to_chat(src, span_notice("================================"))

/mob/living/simple_animal/hostile/scp682/proc/InteractWithSCP()
	set category = "SCP-682"
	set name = "Interact with SCP"

	var/list/nearby_scps = list()
	for(var/atom/A in range(3, src))
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

/mob/living/simple_animal/hostile/scp682/proc/ContainmentProtocol()
	set category = "SCP-682"
	set name = "Containment Protocol"

	if(containment_breached)
		to_chat(src, span_warning("Containment has been breached. Protocol activation required."))
		activate_containment_protocol()
	else
		to_chat(src, span_notice("Containment is currently stable."))

/mob/living/simple_animal/hostile/scp682/proc/ForceAdaptation()
	set category = "SCP-682"
	set name = "Force Adaptation"

	if(world.time - last_adaptation < adaptation_cooldown)
		to_chat(src, span_warning("You must wait before forcing another adaptation."))
		return

	var/list/adaptation_types = list(
		"acid_resistance" = "Acid Resistance",
		"fire_resistance" = "Fire Resistance",
		"radiation_resistance" = "Radiation Resistance",
		"speed_boost" = "Speed Boost",
		"strength_boost" = "Strength Boost",
		"regeneration_boost" = "Regeneration Boost"
	)

	var/selected_type = input(src, "Select adaptation type:", "Force Adaptation") as null|anything in adaptation_types
	if(!selected_type)
		return

	force_adaptation(selected_type)
	last_adaptation = world.time

// SCP-specific interaction methods
/mob/living/simple_animal/hostile/scp682/proc/interact_with_049(atom/scp049)
	to_chat(src, span_notice("You attempt to resist the plague doctor's cure attempts."))
	if(prob(90))
		to_chat(src, span_green("You successfully resist SCP-049's cure attempts."))
		SEND_SIGNAL(scp049, COMSIG_SCP049_CURE_RESISTED, src)
		force_adaptation("disease_resistance")
	else
		to_chat(src, span_warning("SCP-049's cure attempts affect you temporarily."))

/mob/living/simple_animal/hostile/scp682/proc/interact_with_096(atom/scp096)
	to_chat(src, span_notice("You attempt to resist SCP-096's rage."))
	if(prob(80))
		to_chat(src, span_green("You successfully resist SCP-096's rage."))
		SEND_SIGNAL(scp096, COMSIG_SCP096_RAGE_RESISTED, src)
		force_adaptation("rage_resistance")
	else
		to_chat(src, span_warning("SCP-096's rage affects you temporarily."))

/mob/living/simple_animal/hostile/scp682/proc/interact_with_173(atom/scp173)
	to_chat(src, span_notice("You attempt to resist SCP-173's immobilization."))
	if(prob(70))
		to_chat(src, span_green("You successfully resist SCP-173's immobilization."))
		SEND_SIGNAL(scp173, COMSIG_SCP173_IMMOBILIZATION_RESISTED, src)
		force_adaptation("immobilization_resistance")
	else
		to_chat(src, span_warning("SCP-173's immobilization affects you temporarily."))

/mob/living/simple_animal/hostile/scp682/proc/interact_with_106(atom/scp106)
	to_chat(src, span_notice("You attempt to resist SCP-106's pocket dimension."))
	if(prob(85))
		to_chat(src, span_green("You successfully resist SCP-106's pocket dimension."))
		SEND_SIGNAL(scp106, COMSIG_SCP106_ABDUCTION_RESISTED, src)
		force_adaptation("dimensional_resistance")
	else
		to_chat(src, span_warning("SCP-106's pocket dimension affects you temporarily."))

/mob/living/simple_animal/hostile/scp682/proc/generic_scp_interaction(atom/scp)
	to_chat(src, span_notice("You attempt to adapt to [scp.SCP.designation]'s effects."))
	if(prob(60))
		to_chat(src, span_green("You successfully adapt to [scp.SCP.designation]'s effects."))
		SEND_SIGNAL(scp, COMSIG_SCP_ADAPTED_TO, src)
		force_adaptation("generic_resistance")
	else
		to_chat(src, span_warning("[scp.SCP.designation]'s effects resist your adaptation."))

// Adaptation system
/mob/living/simple_animal/hostile/scp682/proc/force_adaptation(adaptation_type)
	var/datum/scp682_adaptation/adapt = new(adaptation_type, 1, 300 SECONDS, "Adapted to [adaptation_type]")
	adaptations += adapt
	GLOB.scp682_adaptations += adapt

	// Apply adaptation effects
	switch(adaptation_type)
		if("acid_resistance")
			acid_resistance = min(95, acid_resistance + 10)
		if("fire_resistance")
			fire_resistance = min(95, fire_resistance + 10)
		if("radiation_resistance")
			radiation_resistance = min(95, radiation_resistance + 10)
		if("speed_boost")
			move_to_delay = max(0.5, move_to_delay - 0.5)
		if("strength_boost")
			melee_damage_lower += 10
			melee_damage_upper += 10
		if("regeneration_boost")
			regeneration_rate += 2

	to_chat(src, span_green("You have adapted to [adaptation_type]!"))
	SEND_SIGNAL(src, COMSIG_SCP682_ADAPTED, adaptation_type)

/mob/living/simple_animal/hostile/scp682/proc/activate_containment_protocol()
	containment_field_active = TRUE
	to_chat(src, span_warning("Containment protocol activated. Movement restricted."))

	// Add containment effects
	// add_trait(TRAIT_IMMOBILIZED, "containment")
	// add_trait(TRAIT_MUTE, "containment")

	// Containment field visual effect
	var/obj/effect/containment_field/field = new(get_turf(src))
	field.target = src

	SEND_SIGNAL(src, COMSIG_SCP682_CONTAINMENT_ACTIVATED)

/mob/living/simple_animal/hostile/scp682/proc/deactivate_containment_protocol()
	containment_field_active = FALSE
	to_chat(src, span_notice("Containment protocol deactivated."))

	// Remove containment effects
	// remove_trait(TRAIT_IMMOBILIZED, "containment")
	// remove_trait(TRAIT_MUTE, "containment")

	SEND_SIGNAL(src, COMSIG_SCP682_CONTAINMENT_DEACTIVATED)

// Life process to handle regeneration and adaptations
/mob/living/simple_animal/hostile/scp682/Life()
	. = ..()
	if(.)
		process_regeneration()
		process_adaptations()
		process_evolution()

/mob/living/simple_animal/hostile/scp682/proc/process_regeneration()
	if(health < maxHealth)
		adjustBruteLoss(-regeneration_rate)
		adjustFireLoss(-regeneration_rate)
		adjustToxLoss(-regeneration_rate)

/mob/living/simple_animal/hostile/scp682/proc/process_adaptations()
	// Remove expired adaptations
	for(var/datum/scp682_adaptation/adapt in adaptations)
		if(adapt.is_expired())
			adaptations -= adapt
			GLOB.scp682_adaptations -= adapt
			to_chat(src, span_notice("Your [adapt.adaptation_type] adaptation has expired."))

/mob/living/simple_animal/hostile/scp682/proc/process_evolution()
	// Check if evolution stage should increase
	if(health < maxHealth * 0.3 && evolution_stage < max_evolution_stage)
		evolution_stage++
		to_chat(src, span_danger("You have evolved to stage [evolution_stage]!"))

		// Enhance abilities with evolution
		maxHealth += 200
		health = maxHealth
		melee_damage_lower += 5
		melee_damage_upper += 5
		regeneration_rate += 1

		SEND_SIGNAL(src, COMSIG_SCP682_EVOLVED, evolution_stage)

// Override damage to trigger adaptations
/mob/living/simple_animal/hostile/scp682/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(amount > 0)
		// Trigger adaptation to physical damage
		if(prob(30))
			force_adaptation("physical_resistance")

/mob/living/simple_animal/hostile/scp682/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(amount > 0)
		// Trigger adaptation to fire damage
		if(prob(40))
			force_adaptation("fire_resistance")

/mob/living/simple_animal/hostile/scp682/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(amount > 0)
		// Trigger adaptation to toxic damage
		if(prob(35))
			force_adaptation("toxic_resistance")

// Override attack to use enhanced damage
/mob/living/simple_animal/hostile/scp682/UnarmedAttack(atom/A, proximity)
	if(proximity && isliving(A))
		var/mob/living/L = A
		// Enhanced attack with adaptation bonuses
		var/damage_bonus = 0
		for(var/datum/scp682_adaptation/adapt in adaptations)
			if(adapt.adaptation_type == "strength_boost")
				damage_bonus += adapt.strength * 5

		L.adjustBruteLoss(melee_damage_upper + damage_bonus)
		to_chat(L, span_danger("SCP-682 mauls you with incredible force!"))
		to_chat(src, span_green("You maul [L]!"))

		SEND_SIGNAL(src, COMSIG_SCP682_ATTACKED, L)
		return

	. = ..()

// Research goals for SCP-682
/datum/scp_research_goal/scp682_adaptations
	id = "682_adaptations"
	title = "SCP-682 Adaptation Analysis"
	desc = "Study SCP-682's adaptation mechanisms and resistance development."
	designation_filter = list("682")
	event_filter = list("adapted", "evolved")
	required_count = 4
	points_reward = 25
	cash_reward = 2500
	budget_reward = 1250
	repeatable = TRUE

/datum/scp_research_goal/scp682_containment
	id = "682_containment"
	title = "SCP-682 Containment Testing"
	desc = "Test various containment methods against SCP-682's adaptive capabilities."
	designation_filter = list("682")
	event_filter = list("containment_activated", "containment_breached")
	required_count = 3
	points_reward = 30
	cash_reward = 3000
	budget_reward = 1500
	repeatable = TRUE
