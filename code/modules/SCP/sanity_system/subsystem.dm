// Sanity Subsystem
// Manages sanity mechanics, effects, and recovery for all mobs

SUBSYSTEM_DEF(sanity)
	name = "Sanity"
	wait = 1 SECONDS
	priority = FIRE_PRIORITY_INPUT
	flags = SS_NO_INIT
	var/list/sanity_effects = list()
	var/list/sanity_recovery_sources = list()
	var/list/sanity_damage_sources = list()
	var/list/sanity_research_data = list()

/datum/controller/subsystem/sanity/fire(resumed = FALSE)
	if(!resumed)
		sanity_effects.Cut()
		sanity_recovery_sources.Cut()
		sanity_damage_sources.Cut()

	var/list/current_sanity_effects = sanity_effects.Copy()
	for(var/datum/sanity_effect/effect in current_sanity_effects)
		if(QDELETED(effect))
			sanity_effects -= effect
			continue
		effect.process_effect()

	var/list/current_recovery_sources = sanity_recovery_sources.Copy()
	for(var/datum/sanity_recovery_source/source in current_recovery_sources)
		if(QDELETED(source))
			sanity_recovery_sources -= source
			continue
		source.process_recovery()

	var/list/current_damage_sources = sanity_damage_sources.Copy()
	for(var/datum/sanity_damage_source/source in current_damage_sources)
		if(QDELETED(source))
			sanity_damage_sources -= source
			continue
		source.process_damage()

// Sanity Effect Datum
/datum/sanity_effect
	var/mob/living/carbon/target
	var/effect_type = SANITY_EFFECT_HALLUCINATIONS
	var/duration = 0
	var/intensity = 1
	var/start_time = 0
	var/active = FALSE

/datum/sanity_effect/New(mob/living/carbon/new_target, new_effect_type, new_duration = 0, new_intensity = 1)
	. = ..()
	target = new_target
	effect_type = new_effect_type
	duration = new_duration
	intensity = new_intensity
	start_time = world.time
	active = TRUE

/datum/sanity_effect/proc/process_effect()
	if(!target || target.stat == DEAD)
		active = FALSE
		return

	if(duration > 0 && world.time > start_time + duration)
		active = FALSE
		return

	apply_effect()

/datum/sanity_effect/proc/apply_effect()
	switch(effect_type)
		if(SANITY_EFFECT_HALLUCINATIONS)
			if(prob(5 * intensity))
				target.hallucination += rand(5, 15)
		if(SANITY_EFFECT_PARANOIA)
			if(prob(3 * intensity))
				to_chat(target, span_warning("You feel like someone is watching you..."))
		if(SANITY_EFFECT_ANXIETY)
			if(prob(4 * intensity))
				to_chat(target, span_warning("You feel anxious and on edge."))
		if(SANITY_EFFECT_DEPRESSION)
			if(prob(3 * intensity))
				to_chat(target, span_notice("You feel hopeless and depressed."))
		if(SANITY_EFFECT_AGGRESSION)
			if(prob(2 * intensity))
				to_chat(target, span_danger("You feel an overwhelming urge to lash out!"))
		if(SANITY_EFFECT_WITHDRAWAL)
			if(prob(4 * intensity))
				to_chat(target, span_notice("You want to be alone and away from others."))

/datum/sanity_effect/proc/remove()
	active = FALSE
	qdel(src)

// Sanity Recovery Source Datum
/datum/sanity_recovery_source
	var/mob/living/carbon/target
	var/recovery_type = SANITY_RECOVERY_REST
	var/recovery_rate = SANITY_RECOVERY_RATE_BASE
	var/duration = 0
	var/start_time = 0
	var/active = FALSE

/datum/sanity_recovery_source/New(mob/living/carbon/new_target, new_recovery_type, new_recovery_rate = SANITY_RECOVERY_RATE_BASE, new_duration = 0)
	. = ..()
	target = new_target
	recovery_type = new_recovery_type
	recovery_rate = new_recovery_rate
	duration = new_duration
	start_time = world.time
	active = TRUE

/datum/sanity_recovery_source/proc/process_recovery()
	if(!target || target.stat == DEAD)
		active = FALSE
		return

	if(duration > 0 && world.time > start_time + duration)
		active = FALSE
		return

	apply_recovery()

/datum/sanity_recovery_source/proc/apply_recovery()
	if(!target.sanity)
		return

	var/recovery_amount = recovery_rate * SSsanity.wait
	target.adjustSanity(recovery_amount)

/datum/sanity_recovery_source/proc/remove()
	active = FALSE
	qdel(src)

// Sanity Damage Source Datum
/datum/sanity_damage_source
	var/mob/living/carbon/target
	var/damage_type = SANITY_DAMAGE_PSYCHOLOGICAL
	var/damage_rate = SANITY_DAMAGE_RATE_STRESS
	var/duration = 0
	var/start_time = 0
	var/active = FALSE

/datum/sanity_damage_source/New(mob/living/carbon/new_target, new_damage_type, new_damage_rate = SANITY_DAMAGE_RATE_STRESS, new_duration = 0)
	. = ..()
	target = new_target
	damage_type = new_damage_type
	damage_rate = new_damage_rate
	duration = new_duration
	start_time = world.time
	active = TRUE

/datum/sanity_damage_source/proc/process_damage()
	if(!target || target.stat == DEAD)
		active = FALSE
		return

	if(duration > 0 && world.time > start_time + duration)
		active = FALSE
		return

	apply_damage()

/datum/sanity_damage_source/proc/apply_damage()
	if(!target.sanity)
		return

	var/damage_amount = damage_rate * SSsanity.wait
	target.adjustSanity(-damage_amount)

/datum/sanity_damage_source/proc/remove()
	active = FALSE
	qdel(src)

// Sanity Research Data
/datum/sanity_research_data
	var/mob/living/carbon/subject
	var/list/sanity_history = list()
	var/list/effect_history = list()
	var/list/recovery_history = list()
	var/list/damage_history = list()
	var/list/vision_history = list()
	var/list/vision_state_history = list()
	var/start_time = 0

/datum/sanity_research_data/New(mob/living/carbon/new_subject)
	. = ..()
	subject = new_subject
	start_time = world.time

/datum/sanity_research_data/proc/record_sanity_change(old_sanity, new_sanity, reason)
	var/list/entry = list(
		"time" = world.time,
		"old_sanity" = old_sanity,
		"new_sanity" = new_sanity,
		"change" = new_sanity - old_sanity,
		"reason" = reason
	)
	sanity_history += list(entry)

/datum/sanity_research_data/proc/record_effect(effect_type, intensity)
	var/list/entry = list(
		"time" = world.time,
		"effect_type" = effect_type,
		"intensity" = intensity
	)
	effect_history += list(entry)

/datum/sanity_research_data/proc/record_recovery(recovery_type, amount)
	var/list/entry = list(
		"time" = world.time,
		"recovery_type" = recovery_type,
		"amount" = amount
	)
	recovery_history += list(entry)

/datum/sanity_research_data/proc/record_damage(damage_type, amount)
	var/list/entry = list(
		"time" = world.time,
		"damage_type" = damage_type,
		"amount" = amount
	)
	damage_history += list(entry)

/datum/sanity_research_data/proc/record_vision_change(old_value, new_value, reason)
	var/list/entry = list(
		"time" = world.time,
		"old_value" = old_value,
		"new_value" = new_value,
		"change" = new_value - old_value,
		"reason" = reason
	)
	vision_history += list(entry)

/datum/sanity_research_data/proc/record_vision_state_change(old_state, new_state, reason)
	var/list/entry = list(
		"time" = world.time,
		"old_state" = old_state,
		"new_state" = new_state,
		"reason" = reason
	)
	vision_state_history += list(entry)

/datum/sanity_research_data/proc/get_summary()
	var/list/summary = list()
	summary["subject"] = subject.name
	summary["start_time"] = start_time
	summary["current_sanity"] = subject.sanity
	summary["sanity_changes"] = length(sanity_history)
	summary["effects_recorded"] = length(effect_history)
	summary["recoveries_recorded"] = length(recovery_history)
	summary["damages_recorded"] = length(damage_history)
	summary["vision_changes"] = length(vision_history)
	summary["vision_state_changes"] = length(vision_state_history)
	return summary
