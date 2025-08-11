// Disease System
// Basic disease mechanics for SCP-008 and other disease-related SCPs

// Disease Severity Levels
#define DISEASE_SEVERITY_MINOR 1
#define DISEASE_SEVERITY_MODERATE 2
#define DISEASE_SEVERITY_MAJOR 3
#define DISEASE_SEVERITY_BIOHAZARD 4

// Disease Base Class
/datum/disease
	var/name = "Unknown Disease"
	var/desc = "A mysterious illness."
	var/agent = "Unknown"
	var/agent_name = "Unknown Agent"
	var/spread_text = "Unknown"
	var/viable_mobtypes = list(/mob/living/carbon/human)
	var/permeability_mod = 1
	var/cure_text = "Unknown"
	var/list/cures = list()
	var/cure_chance = 0
	var/severity = DISEASE_SEVERITY_MINOR
	var/visibility_flags = 0
	var/list/required_organs = list()
	var/bypasses_immunity = FALSE
	var/mob/living/carbon/affected_mob = null
	var/stage = 1
	var/max_stages = 4

/datum/disease/New()
	. = ..()

/datum/disease/proc/stage_act()
	// Override in subtypes
	if(!affected_mob)
		return

	// Basic stage progression
	if(prob(5)) // 5% chance to progress each call
		stage = min(stage + 1, max_stages)

	return

/datum/disease/proc/cure()
	// Remove the disease from the affected mob
	if(affected_mob)
		// Remove from mob's disease list
		affected_mob.diseases -= src
		// Clear the affected_mob reference
		affected_mob = null
	qdel(src)

// Disease Instance (attached to mobs)
/datum/disease_advance
	var/datum/disease/disease
	var/mob/living/carbon/affected_mob
	var/stage = 1
	var/stage_prob = 10
	var/next_stage = 0
	var/spread_flags = 0
	var/spread_timer = 0

/datum/disease_advance/New(datum/disease/new_disease, mob/living/carbon/new_mob)
	. = ..()
	disease = new_disease
	affected_mob = new_mob

/datum/disease_advance/proc/stage_act()
	if(!affected_mob || affected_mob.stat == DEAD)
		return

	if(world.time >= next_stage)
		next_stage = world.time + rand(10 SECONDS, 30 SECONDS)
		if(prob(stage_prob))
			stage++

	disease.stage_act()

// Disease System Integration for Carbon Mobs
/mob/living/carbon/proc/has_disease(datum/disease/disease_type)
	for(var/datum/disease_advance/D in diseases)
		if(istype(D.disease, disease_type))
			return D
	return FALSE

/mob/living/carbon/proc/ForceContractDisease(datum/disease/disease_type)
	if(has_disease(disease_type))
		return FALSE

	var/datum/disease/disease = new disease_type()
	var/datum/disease_advance/disease_advance = new /datum/disease_advance(disease, src)
	diseases += disease_advance

	return disease_advance

// SCP-008 Specific Disease
/datum/disease/scp008
	name = "SCP-008 Infection"
	desc = "A highly contagious viral infection that causes rapid cellular mutation and reanimation."
	agent = "SCP-008"
	agent_name = "SCP-008 Viral Agent"
	spread_text = "Blood contact, airborne transmission"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1.5
	cure_text = "No known cure"
	cures = list()
	cure_chance = 0
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	required_organs = list()
	bypasses_immunity = TRUE

/datum/disease/scp008/stage_act()
	if(!affected_mob)
		return

	switch(stage)
		if(1)
			// Initial infection - mild symptoms
			if(prob(5))
				to_chat(affected_mob, span_warning("You feel feverish and nauseous."))
				if(affected_mob.sanity)
					affected_mob.adjustSanity(-2, "scp008_early_symptoms")
		if(2)
			// Progression - more severe symptoms
			if(prob(10))
				to_chat(affected_mob, span_warning("Your skin feels hot and your muscles ache."))
				if(affected_mob.sanity)
					affected_mob.adjustSanity(-5, "scp008_progression")
					affected_mob.add_sanity_effect(SANITY_EFFECT_ANXIETY, 30 SECONDS, 1)
		if(3)
			// Advanced stage - severe symptoms
			if(prob(15))
				to_chat(affected_mob, span_danger("You feel your body changing... something is wrong!"))
				if(affected_mob.sanity)
					affected_mob.adjustSanity(-10, "scp008_advanced")
					affected_mob.add_sanity_effect(SANITY_EFFECT_PARANOIA, 60 SECONDS, 2)
		if(4)
			// Final stage - transformation
			if(prob(20))
				to_chat(affected_mob, span_danger("The transformation is complete... you are no longer human!"))
				if(affected_mob.sanity)
					affected_mob.adjustSanity(-50, "scp008_transformation")
					affected_mob.add_sanity_effect(SANITY_EFFECT_AGGRESSION, 120 SECONDS, 3)
				// Trigger transformation
				transform_to_zombie()



// Zombie Mob for SCP-008
/mob/living/simple_animal/hostile/zombie
	name = "Zombie"
	desc = "A reanimated corpse infected with SCP-008. It hungers for flesh."
	icon = 'icons/mob/animal.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	icon_dead = "zombie_dead"
	maxHealth = 150
	health = 150
	see_in_dark = 8
	move_to_delay = 3
	melee_damage_lower = 15
	melee_damage_upper = 25
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_NONE
	stat_attack = CONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE

	var/zombie_infection_chance = 25
	var/list/infected_targets = list()

/mob/living/simple_animal/hostile/zombie/AttackingTarget()
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(prob(zombie_infection_chance))
			if(!H.has_disease(/datum/disease/scp008))
				H.ForceContractDisease(/datum/disease/scp008)
				to_chat(H, span_danger("You feel the zombie's bite infect you with something terrible!"))
				infected_targets += H
