// Sanity-Related Chemicals
// Chemicals that affect sanity and mental state

/datum/reagent/medicine/psicodine
	name = "Psicodine"
	description = "A powerful antipsychotic medication that can restore sanity levels to normal."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 20
	addiction_types = list(/datum/addiction/medicine = 8)
	// pH = 9.2

/datum/reagent/medicine/psicodine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(M.sanity)
		M.adjustSanity(2 * delta_time, "psicodine")
		M.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)
		M.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
		M.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		M.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
		M.remove_sanity_effect(SANITY_EFFECT_AGGRESSION)
		M.remove_sanity_effect(SANITY_EFFECT_WITHDRAWAL)

/datum/reagent/medicine/psicodine/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1 * delta_time)
	if(DT_PROB(10, delta_time))
		M.adjustSanity(-1, "psicodine_overdose")

/datum/reagent/medicine/antipsychotic
	name = "Antipsychotic"
	description = "A medication that reduces hallucinations and paranoia."
	reagent_state = LIQUID
	color = "#B0E0E6"
	metabolization_rate = 0.3 * REAGENTS_METABOLISM
	overdose_threshold = 15
	addiction_types = list(/datum/addiction/medicine = 6)
	// pH = 8.5

/datum/reagent/medicine/antipsychotic/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(M.sanity)
		M.adjustSanity(1 * delta_time, "antipsychotic")
		M.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)
		M.remove_sanity_effect(SANITY_EFFECT_PARANOIA)

/datum/reagent/medicine/antipsychotic/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * delta_time)
	if(DT_PROB(5, delta_time))
		M.adjustSanity(-1, "antipsychotic_overdose")

/datum/reagent/medicine/anxiolytic
	name = "Anxiolytic"
	description = "A medication that reduces anxiety and stress."
	reagent_state = LIQUID
	color = "#98FB98"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	overdose_threshold = 25
	addiction_types = list(/datum/addiction/medicine = 10)
	// pH = 7.8

/datum/reagent/medicine/anxiolytic/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(M.sanity)
		M.adjustSanity(1.5 * delta_time, "anxiolytic")
		M.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		M.remove_sanity_effect(SANITY_EFFECT_AGGRESSION)

/datum/reagent/medicine/anxiolytic/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.5 * delta_time)
	if(DT_PROB(8, delta_time))
		M.adjustSanity(-1, "anxiolytic_overdose")

/datum/reagent/medicine/antidepressant
	name = "Antidepressant"
	description = "A medication that treats depression and improves mood."
	reagent_state = LIQUID
	color = "#FFB6C1"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	overdose_threshold = 30
	addiction_types = list(/datum/addiction/medicine = 12)
	// pH = 7.2

/datum/reagent/medicine/antidepressant/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(M.sanity)
		M.adjustSanity(1.2 * delta_time, "antidepressant")
		M.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)
		M.remove_sanity_effect(SANITY_EFFECT_WITHDRAWAL)

/datum/reagent/medicine/antidepressant/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 0.3 * delta_time)
	if(DT_PROB(6, delta_time))
		M.adjustSanity(-1, "antidepressant_overdose")

/datum/reagent/medicine/sedative
	name = "Sedative"
	description = "A medication that induces calmness and reduces mental agitation."
	reagent_state = LIQUID
	color = "#E6E6FA"
	metabolization_rate = 0.6 * REAGENTS_METABOLISM
	overdose_threshold = 18
	addiction_types = list(/datum/addiction/medicine = 7)
	// pH = 8.0

/datum/reagent/medicine/sedative/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(M.sanity)
		M.adjustSanity(0.8 * delta_time, "sedative")
		M.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		M.remove_sanity_effect(SANITY_EFFECT_AGGRESSION)
		M.remove_sanity_effect(SANITY_EFFECT_PARANOIA)

/datum/reagent/medicine/sedative/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.8 * delta_time)
	if(DT_PROB(12, delta_time))
		M.adjustSanity(-1, "sedative_overdose")

// Sanity-damaging chemicals
/datum/reagent/toxin/mindbreaker
	name = "Mindbreaker Toxin"
	description = "A powerful hallucinogenic that causes severe mental damage."
	reagent_state = LIQUID
	color = "#FF69B4"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	toxpwr = 0
	// chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/mindbreaker/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(M.sanity)
		M.adjustSanity(-3 * delta_time, "mindbreaker_toxin")
		M.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 0, 3)
		M.add_sanity_effect(SANITY_EFFECT_PARANOIA, 0, 2)
		M.add_sanity_effect(SANITY_EFFECT_ANXIETY, 0, 2)

/datum/reagent/toxin/psychotic
	name = "Psychotic Compound"
	description = "A dangerous chemical that induces psychotic episodes."
	reagent_state = LIQUID
	color = "#8B0000"
	metabolization_rate = 0.05 * REAGENTS_METABOLISM
	toxpwr = 1
	// chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/psychotic/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(M.sanity)
		M.adjustSanity(-4 * delta_time, "psychotic_compound")
		M.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 0, 4)
		M.add_sanity_effect(SANITY_EFFECT_PARANOIA, 0, 3)
		M.add_sanity_effect(SANITY_EFFECT_AGGRESSION, 0, 2)

// Sanity-neutral chemicals that can be used for research
/datum/reagent/medicine/placebo
	name = "Placebo"
	description = "A harmless substance that can have psychological effects due to belief."
	reagent_state = LIQUID
	color = "#FFFFFF"
	metabolization_rate = 0.8 * REAGENTS_METABOLISM
	// pH = 7.0

/datum/reagent/medicine/placebo/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	// Placebo effect - if the mob believes it will help, it might
	if(prob(30))
		M.adjustSanity(0.5 * delta_time, "placebo_effect")
	else if(prob(10))
		M.adjustSanity(-0.2 * delta_time, "placebo_nocebo")
