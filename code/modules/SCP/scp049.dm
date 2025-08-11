// SCP-049 (The Plague Doctor)

/datum/scp049_cure_progress
	var/mob/living/carbon/human/patient
	var/progress = 0
	var/cure_time = 30 SECONDS
	var/cure_type = "standard"
	var/start_time = 0

/datum/scp049_cure_progress/New(mob/living/carbon/human/P, cure_type = "standard")
	patient = P
	src.cure_type = cure_type
	start_time = world.time

/datum/scp049_cure_progress/proc/update_progress()
	progress = min(100, ((world.time - start_time) / cure_time) * 100)
	return progress >= 100

// Global cure tracking
GLOBAL_LIST_INIT(scp049_cures, list())

/mob/living/simple_animal/hostile/scp049
	name = "plague doctor"
	desc = "A humanoid figure wearing a black robe and a white mask resembling a plague doctor's beak."
	icon = 'icons/mob/animal.dmi'
	icon_state = "049"
	icon_living = "049"
	icon_dead = "049_dead"
	maxHealth = 800
	health = 800
	see_in_dark = 8
	move_to_delay = 3
	melee_damage_lower = 15
	melee_damage_upper = 25
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE

	// SCP-049 specific variables
	var/cure_cooldown = 45 SECONDS
	var/last_cure = 0
	var/cure_range = 2
	var/list/cure_progress = list()
	var/cure_success_rate = 75
	var/zombie_creation_chance = 25
	var/list/cured_patients = list()
	var/list/failed_cures = list()

/mob/living/simple_animal/hostile/scp049/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"plague doctor",
		SCP_KETER,
		"049",
		SCP_PLAYABLE
	)
	grant_language(/datum/language/common, TRUE, TRUE)
	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp049/proc/CurePatient,
		/mob/living/simple_animal/hostile/scp049/proc/ExaminePatient,
		/mob/living/simple_animal/hostile/scp049/proc/ResearchCure,
		/mob/living/simple_animal/hostile/scp049/proc/InteractWithSCP,
	))

// SCP-049 abilities
/mob/living/simple_animal/hostile/scp049/proc/CurePatient()
	set category = "SCP-049"
	set name = "Cure Patient"

	if(world.time - last_cure < cure_cooldown)
		to_chat(src, span_warning("You must wait before attempting another cure."))
		return

	var/list/nearby_patients = list()
	for(var/mob/living/carbon/human/H in range(cure_range, src))
		if(H.stat != DEAD)
			nearby_patients += H

	if(!nearby_patients.len)
		to_chat(src, span_warning("No suitable patients nearby to cure."))
		return

	var/mob/living/carbon/human/selected_patient = input(src, "Select patient to cure:", "Cure Patient") as null|anything in nearby_patients
	if(!selected_patient)
		return

	// Start cure process
	to_chat(src, span_notice("You begin examining [selected_patient] for signs of the pestilence..."))
	to_chat(selected_patient, span_danger("The plague doctor approaches you with unsettling intent!"))

	// Create cure progress tracking
	var/datum/scp049_cure_progress/cure = new(selected_patient, "standard")
	cure_progress[selected_patient] = cure
	GLOB.scp049_cures += cure

	last_cure = world.time
	SEND_SIGNAL(src, COMSIG_SCP049_CURE_STARTED, selected_patient)

/mob/living/simple_animal/hostile/scp049/proc/ExaminePatient()
	set category = "SCP-049"
	set name = "Examine Patient"

	var/list/nearby_patients = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat != DEAD)
			nearby_patients += H

	if(!nearby_patients.len)
		to_chat(src, span_warning("No patients nearby to examine."))
		return

	var/mob/living/carbon/human/selected_patient = input(src, "Select patient to examine:", "Examine Patient") as null|anything in nearby_patients
	if(!selected_patient)
		return

	// Examine the patient
	var/examination_result = examine_patient_condition(selected_patient)
	to_chat(src, span_notice("Examination of [selected_patient]: [examination_result]"))
	SEND_SIGNAL(src, COMSIG_SCP049_PATIENT_EXAMINED, selected_patient, examination_result)

/mob/living/simple_animal/hostile/scp049/proc/ResearchCure()
	set category = "SCP-049"
	set name = "Research Cure"

	to_chat(src, span_notice("You begin researching new cure methods..."))

	// Research new cure types
	var/list/cure_types = list("standard", "advanced", "experimental")
	var/selected_cure = input(src, "Select cure type to research:", "Research Cure") as null|anything in cure_types
	if(!selected_cure)
		return

	// Research takes time and has a chance to improve cure success rate
	if(prob(60))
		cure_success_rate = min(95, cure_success_rate + 5)
		to_chat(src, span_green("Research successful! Cure success rate improved to [cure_success_rate]%."))
		SEND_SIGNAL(src, COMSIG_SCP049_CURE_RESEARCHED, selected_cure, cure_success_rate)
	else
		to_chat(src, span_warning("Research inconclusive. More testing needed."))

/mob/living/simple_animal/hostile/scp049/proc/InteractWithSCP()
	set category = "SCP-049"
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
		if("106")
			interact_with_106(selected_scp)
		if("012")
			interact_with_012(selected_scp)
		if("113")
			interact_with_113(selected_scp)
		if("216")
			interact_with_216(selected_scp)
		else
			generic_scp_interaction(selected_scp)

// SCP-specific interaction methods
/mob/living/simple_animal/hostile/scp049/proc/interact_with_106(atom/scp106)
	to_chat(src, span_notice("You attempt to cure the corrosive essence of SCP-106."))
	if(prob(40))
		to_chat(src, span_green("You successfully neutralize some of SCP-106's corrosive properties."))
		SEND_SIGNAL(scp106, COMSIG_SCP106_CORROSION_NEUTRALIZED, src)
	else
		to_chat(src, span_warning("The corrosive essence resists your cure attempt."))

/mob/living/simple_animal/hostile/scp049/proc/interact_with_012(atom/scp012)
	to_chat(src, span_notice("You attempt to cure the memetic effects of SCP-012."))
	if(prob(70))
		to_chat(src, span_green("You successfully weaken SCP-012's memetic influence."))
		SEND_SIGNAL(scp012, COMSIG_SCP012_MEMETIC_WEAKENED, src)
	else
		to_chat(src, span_warning("The memetic effects resist your cure attempt."))

/mob/living/simple_animal/hostile/scp049/proc/interact_with_113(atom/scp113)
	to_chat(src, span_notice("You attempt to cure the gender-changing properties of SCP-113."))
	if(prob(65))
		to_chat(src, span_green("You successfully stabilize SCP-113's effects."))
		SEND_SIGNAL(scp113, COMSIG_SCP113_STABILIZED, src)
	else
		to_chat(src, span_warning("The gender-changing properties resist your cure attempt."))

/mob/living/simple_animal/hostile/scp049/proc/interact_with_216(atom/scp216)
	to_chat(src, span_notice("You attempt to cure the temporal displacement effects of SCP-216."))
	if(prob(50))
		to_chat(src, span_green("You successfully reduce SCP-216's temporal instability."))
		SEND_SIGNAL(scp216, COMSIG_SCP216_TEMPORAL_STABILIZED, src)
	else
		to_chat(src, span_warning("The temporal effects resist your cure attempt."))

/mob/living/simple_animal/hostile/scp049/proc/generic_scp_interaction(atom/scp)
	to_chat(src, span_notice("You attempt to cure the anomalous properties of [scp.SCP.designation]."))
	if(prob(30))
		to_chat(src, span_green("You successfully weaken [scp.SCP.designation]'s effects."))
		SEND_SIGNAL(scp, COMSIG_SCP_CURED, src)
	else
		to_chat(src, span_warning("[scp.SCP.designation]'s properties resist your cure attempt."))

// Helper methods
/mob/living/simple_animal/hostile/scp049/proc/examine_patient_condition(mob/living/carbon/human/patient)
	var/condition = "Healthy"

	if(patient.stat == DEAD)
		condition = "Deceased"
	else if(patient.health < 25)
		condition = "Critical condition"
	else if(patient.health < 50)
		condition = "Poor condition"
	else if(patient.health < 75)
		condition = "Fair condition"

	// Check for specific conditions
	// if(patient.has_disease(/datum/disease/plague))
	// 	condition += " - Infected with pestilence"

	return condition

// Life process to handle cure progress
/mob/living/simple_animal/hostile/scp049/Life()
	. = ..()
	if(.)
		process_cures()

/mob/living/simple_animal/hostile/scp049/proc/process_cures()
	for(var/mob/living/carbon/human/patient in cure_progress)
		var/datum/scp049_cure_progress/cure = cure_progress[patient]
		if(!cure || !patient || patient.stat == DEAD)
			cure_progress -= patient
			continue

		if(cure.update_progress())
			// Cure completed
			complete_cure(patient, cure)
			cure_progress -= patient

/mob/living/simple_animal/hostile/scp049/proc/complete_cure(mob/living/carbon/human/patient, datum/scp049_cure_progress/cure)
	if(!patient || patient.stat == DEAD)
		return

	// Determine cure success
	if(prob(cure_success_rate))
		// Successful cure
		to_chat(src, span_green("The cure is successful! [patient] has been treated."))
		to_chat(patient, span_notice("You feel strangely better..."))

		// Heal the patient
		patient.adjustBruteLoss(-50)
		patient.adjustFireLoss(-50)
		patient.adjustToxLoss(-50)

		cured_patients += patient
		SEND_SIGNAL(src, COMSIG_SCP049_CURE_SUCCESSFUL, patient)
	else
		// Failed cure - chance to create zombie
		to_chat(src, span_warning("The cure failed. [patient] has succumbed to the pestilence."))
		to_chat(patient, span_danger("You feel your body changing..."))

		failed_cures += patient

		if(prob(zombie_creation_chance))
			create_zombie(patient)

		SEND_SIGNAL(src, COMSIG_SCP049_CURE_FAILED, patient)

/mob/living/simple_animal/hostile/scp049/proc/create_zombie(mob/living/carbon/human/patient)
	if(!patient || patient.stat == DEAD)
		return

	// Transform patient into zombie (simplified)
	patient.name = "Zombie ([patient.real_name])"
	patient.desc = "A reanimated corpse with pale, decaying flesh."

	to_chat(src, span_green("The pestilence has taken hold. [patient] has been reanimated."))
	to_chat(patient, span_danger("You have been reanimated by the plague doctor!"))

	SEND_SIGNAL(src, COMSIG_SCP049_ZOMBIE_CREATED, patient)

// Override attack to use cure mechanics
/mob/living/simple_animal/hostile/scp049/UnarmedAttack(atom/A, proximity)
	if(isliving(A) && ishuman(A))
		var/mob/living/carbon/human/H = A
		if(prob(30)) // 30% chance to start cure on melee attack
			if(!(H in cure_progress))
				var/datum/scp049_cure_progress/cure = new(H, "melee")
				cure_progress[H] = cure
				GLOB.scp049_cures += cure
				to_chat(src, span_notice("You begin examining [H] for the pestilence."))
				to_chat(H, span_danger("The plague doctor touches you with unsettling intent!"))
				SEND_SIGNAL(src, COMSIG_SCP049_CURE_STARTED, H)
		else
			. = ..()
	else
		. = ..()


