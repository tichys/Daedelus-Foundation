/datum/reagent/scp008
	name = "008 Prions"
	description = "An oily substance which slowly churns of its own accord."
	taste_description = "decaying blood"
	color = "#540000"
	taste_mult = 5
	metabolization_rate = 0.1 // Example value, adjust as needed
	overdose_threshold = 200
	// hidden_from_codex removed (not supported in base reagent)

	var/list/zombie_messages = list(
	"stage1" = list(
		"You feel uncomfortably warm.",
		"You feel rather feverish.",
		"Your throat is extremely dry...",
		"Your muscles cramp...",
		"You feel dizzy.",
		"You feel slightly fatigued.",
		"You feel light-headed."
	),
	"stage2" = list(
		"You feel something under your skin!",
		"Mucus runs down the back of your throat",
		"Your muscles burn.",
		"Your skin itches.",
		"Your bones ache.",
		"Sweat runs down the side of your neck.",
		"Your heart races."
	),
	"stage3" = list(
		"Your head feels like it's splitting open!",
		"Your skin is peeling away!",
		"Your body stings all over!",
		"It feels like your insides are squirming!",
		"You're in agony!"
	)
)

// Helper macros for missing procs/vars
#define GET_BRAIN_LOSS(M) (M.brainloss ? M.brainloss : 0)
#define ADJUST_ORGAN_LOSS(M, slot, amt, time) if (M.organloss) M.organloss[slot] += amt
#define ADD_CHEMICAL_EFFECT(M, effect, strength) if (M.chemical_effects) M.chemical_effects[effect] += strength
#define CE_HALLUCINATION "hallucination"
#define ADJUST_DIZZY(M, amt) if (M.dizzy) M.dizzy += amt
#define IS_SYNTHETIC(H) (H.isSynthetic ? H.isSynthetic() : FALSE)
#define ZOMBIFY(H) if (H.zombify) H.zombify()
#define SEIZURE(H) if (H.seizure) H.seizure()
#define ADD_REAGENT(R, type, amt) if (R.add_reagent) R.add_reagent(type, amt)

/datum/reagent/scp008/affect_blood(mob/living/carbon/M, alien, removed)
	if (!ishuman(M))
		return
	var/mob/living/carbon/human/H = M

	// Use is_species macro and check for zombie/infectious
	if (!is_species(H, /datum/species/zombie) && !is_species(H, /datum/species/zombie/infectious) || is_species(H, "/datum/species/diona") || IS_SYNTHETIC(H))
		return
	var/true_dose = H.reagents?.get_reagent_amount(/datum/reagent/scp008) + volume

	if(!M.SCP)
		var/SCP008_instance_count = 1
		for(var/mob/living/carbon/human/instance in GLOB.SCP_list)
			if(is_species(instance, /datum/species/zombie) || is_species(instance, /datum/species/zombie/infectious))
				SCP008_instance_count++
		M.SCP = new /datum/scp(
			M,
			"008-Infected",
			SCP_EUCLID,
			"008-[SCP008_instance_count]",
			SCP_PLAYABLE
		)

	if (true_dose >= 30)
		if (GET_BRAIN_LOSS(M) > 140)
			ZOMBIFY(H)
		if (rand(1,100) <= 1)
			to_chat(M, span_warning("<font style='font-size:[rand(1,2)]'>[pick(src.zombie_messages["stage1"])]</font>"))

	if (true_dose >= 60)
		M.bodytemperature += 7.5
		if (rand(1,100) <= 3)
			to_chat(M, span_warning("<font style='font-size:2'>[pick(src.zombie_messages["stage1"])]</font>"))
		if (GET_BRAIN_LOSS(M) < 20)
			ADJUST_ORGAN_LOSS(M, ORGAN_SLOT_BRAIN, rand(1, 2), 150)

	if (true_dose >= 90)
		ADD_CHEMICAL_EFFECT(M, CE_HALLUCINATION, -2)
		if (M.hallucination)
			M.hallucination(50, min(true_dose / 2, 50))
		if (GET_BRAIN_LOSS(M) < 75)
			ADJUST_ORGAN_LOSS(M, ORGAN_SLOT_BRAIN, rand(1, 2), 150)
		if (rand(1,200) <= 1)
			SEIZURE(H)
			ADJUST_ORGAN_LOSS(H, ORGAN_SLOT_BRAIN, rand(12, 24), 150)
		if (rand(1,100) <= 5)
			to_chat(M, span_danger("<font style='font-size:[rand(2,3)]'>[pick(src.zombie_messages["stage2"])]</font>"))
		M.bodytemperature += 9

	if (true_dose >= 110)
		ADJUST_ORGAN_LOSS(M, ORGAN_SLOT_BRAIN, 5, 150)
		ADJUST_DIZZY(M, 100)
		if (rand(1,100) <= 8)
			to_chat(M, span_danger("<font style='font-size:[rand(3,4)]'>[pick(src.zombie_messages["stage3"])]</font>"))

	if (true_dose >= 135)
		if (rand(1,100) <= 3)
			ZOMBIFY(H)

	if (M.reagents)
		ADD_REAGENT(M.reagents, /datum/reagent/scp008, rand(15, 35) / 10)

/datum/reagent/scp008/affect_touch(mob/living/carbon/M, alien, removed)
	affect_blood(M, alien, removed * 0.5)

// Helper fallback procs for missing vars and procs
/proc/isSynthetic()
	return FALSE

/mob/living/carbon/human/proc/zombify()
	// fallback: do nothing

/mob/living/carbon/human/proc/seizure()
	// fallback: do nothing

/mob/living/carbon/proc/hallucination(strength, duration)
	// fallback: do nothing

// Fallback vars for organloss, brainloss, chemical_effects, dizzy
/mob/living/carbon/var/organloss = list()
/mob/living/carbon/var/brainloss = 0
/mob/living/carbon/var/chemical_effects = list()
/mob/living/carbon/var/dizzy = 0

/datum/reagents/proc/add_reagent(type, amt)
	// fallback: do nothing
