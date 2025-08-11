// SCP-008: The Zombie Virus
// A highly infectious virus that transforms humans into aggressive zombies

/datum/disease/scp008
	name = "SCP-008"
	desc = "A highly infectious virus that causes rapid cellular necrosis and aggressive behavior."
	agent = "SCP-008 Virus"
	agent_name = "SCP-008"
	spread_text = "Blood contact"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.8
	cure_text = "SCP-500 or SCP-049 cure"
	cures = list(/datum/reagent/medicine/scp500)
	cure_chance = 5
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = HIDDEN_SCANNER
	required_organs = list(ORGAN_SLOT_BRAIN)
	bypasses_immunity = TRUE
	max_stages = 5

	// SCP-008 specific variables
	var/transformation_time = 0
	var/TRANSFORMATION_DELAY = 2 MINUTES
	var/list/infected_humans = list()

/datum/disease/scp008/stage_act(delta_time, times_fired)
	. = ..()
	if(!affected_mob || affected_mob.stat == DEAD)
		return

	var/mob/living/carbon/human/H = affected_mob
	if(!ishuman(H))
		return

	// Progress infection
	if(stage < max_stages)
		stage++
		apply_stage_effects(H)

	// Check for transformation
	if(stage >= max_stages && world.time >= transformation_time)
		transform_to_zombie(H)

/datum/disease/scp008/proc/apply_stage_effects(mob/living/carbon/human/H)
	switch(stage)
		if(1)
			to_chat(H, span_warning("You feel feverish and nauseous."))
			H.adjustSanity(-5, "scp008_initial_infection")
			H.add_sanity_effect(SANITY_EFFECT_ANXIETY, 60 SECONDS, 1)
		if(2)
			to_chat(H, span_warning("Your skin feels cold and clammy."))
			H.adjustSanity(-10, "scp008_progression")
			H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 90 SECONDS, 1)
			H.adjustBruteLoss(5)
		if(3)
			to_chat(H, span_warning("You feel an overwhelming hunger for flesh."))
			H.adjustSanity(-15, "scp008_hunger")
			H.add_sanity_effect(SANITY_EFFECT_AGGRESSION, 120 SECONDS, 2)
			H.adjustBruteLoss(10)
		if(4)
			to_chat(H, span_danger("Your body is beginning to decay!"))
			H.adjustSanity(-20, "scp008_decay")
			H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 150 SECONDS, 2)
			H.adjustBruteLoss(15)
			H.adjustToxLoss(10)
		if(5)
			to_chat(H, span_danger("You are losing control of your body!"))
			H.adjustSanity(-25, "scp008_final_stage")
			H.add_sanity_effect(SANITY_EFFECT_AGGRESSION, 180 SECONDS, 3)
			H.adjustBruteLoss(20)
			H.adjustToxLoss(15)
			transformation_time = world.time + TRANSFORMATION_DELAY

/datum/disease/scp008/proc/transform_to_zombie(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Transform to zombie
	H.name = "Zombie ([H.real_name])"
	H.desc = "A reanimated corpse with decaying flesh and aggressive behavior."
	H.skin_tone = "albino"
	H.hair_color = "#000000"
	H.facial_hair_color = "#000000"
	H.update_body()

	// Apply zombie effects
	H.adjustSanity(-50, "scp008_transformation")
	H.add_sanity_effect(SANITY_EFFECT_AGGRESSION, 300 SECONDS, 5)
	H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 240 SECONDS, 3)

	// Enhance zombie abilities
	H.maxHealth = 200
	H.health = 200
	H.see_in_dark = 8

	// Add to infected list
	if(!(H in infected_humans))
		infected_humans += H

	to_chat(H, span_danger("You have been transformed into a zombie! You hunger for flesh!"))
	playsound(H, 'sound/scp/scp008/transform.ogg', 50, TRUE)

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP008_TRANSFORMATION, H)

// SCP-008 Contagion
/datum/reagent/toxin/scp008
	name = "SCP-008"
	description = "A highly infectious virus that causes rapid cellular necrosis."
	reagent_state = LIQUID
	color = "#8B0000"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	toxpwr = 0
	addiction_types = list(/datum/addiction/medicine = 10)

/datum/reagent/toxin/scp008/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M

	// Infect the target
	if(!H.has_disease(/datum/disease/scp008))
		var/datum/disease/scp008/infection = new()
		H.ForceContractDisease(infection)

	// Apply continuous effects
	H.adjustSanity(-2 * delta_time, "scp008_contagion")
	H.adjustBruteLoss(1 * delta_time)
	H.adjustToxLoss(1 * delta_time)

// SCP-008 Research System Integration
/datum/disease/scp008/proc/get_research_data()
	var/list/data = list()
	data["infection_stage"] = stage
	data["max_stages"] = max_stages
	data["infected_humans"] = length(infected_humans)
	data["transformation_time_remaining"] = max(0, transformation_time - world.time)
	return data
