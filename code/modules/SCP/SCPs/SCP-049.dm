// SCP-049 - The Plague Doctor
// A mysterious plague doctor who seeks to cure the "pestilence" through lethal means

/mob/living/carbon/scp/scp049
	name = "SCP-049"
	desc = "A tall humanoid figure wearing the black robes and bird-like mask of a medieval plague doctor."
	icon = 'icons/scp/scp-049.dmi'
	icon_state = "scp049"
	real_name = "SCP-049"

	// Maximum Enhanced SCP-049 variables
	var/pestilence_mastery = 0
	var/max_pestilence_mastery = 100
	var/medical_expertise = 0
	var/max_medical_expertise = 100
	var/cure_research = 0
	var/max_cure_research = 100
	var/plague_evolution = 1
	var/max_plague_evolution = 5
	var/infection_potency = 1
	var/max_infection_potency = 10
	var/research_breakthroughs = 0
	var/max_research_breakthroughs = 50
	var/pestilence_mastery_cooldown = 0
	var/pestilence_mastery_cooldown_time = 30 SECONDS
	var/medical_cooldown = 0
	var/medical_cooldown_time = 20 SECONDS
	var/research_cooldown = 0
	var/research_cooldown_time = 45 SECONDS

	// Persistence tracking
	var/infections_performed = 0
	var/cures_attempted = 0
	var/research_notes = 0
	var/breakthrough_events = 0
	var/pestilence_masteries = 0
	var/medical_masteries = 0
	var/research_masteries = 0
	var/evolution_events = 0

/mob/living/carbon/scp/scp049/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-049",
		SCP_EUCLID,
		"049",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 30
	SCP_datum.min_time = 60 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 150
	scp_health = max_scp_health
	max_scp_armor = 75
	scp_armor = max_scp_armor

	// Add maximum enhanced abilities
	add_ability("infect_target", "infect_target_ability")
	add_ability("cure_target", "cure_target_ability")
	add_ability("research_pestilence", "research_pestilence_ability")
	add_ability("pestilence_mastery", "pestilence_mastery_ability")
	add_ability("medical_expertise", "medical_expertise_ability")
	add_ability("cure_research", "cure_research_ability")
	add_ability("evolve_plague", "evolve_plague_ability")
	add_ability("infection_potency", "infection_potency_ability")
	add_ability("research_breakthrough", "research_breakthrough_ability")
	add_ability("ultimate_pestilence", "ultimate_pestilence_ability")
	add_ability("plague_synthesis", "plague_synthesis_ability")

	// Add passive effects
	add_passive_effect("pestilence_detection")
	add_passive_effect("medical_expertise")
	add_passive_effect("cure_research")
	add_passive_effect("plague_evolution")
	add_passive_effect("infection_potency")
	add_passive_effect("research_breakthroughs")

/mob/living/carbon/scp/scp049/Destroy()
	return ..()

// Override core mechanics
/mob/living/carbon/scp/scp049/process_scp_effects()
	. = ..()

	// Process pestilence detection
	process_pestilence_detection()

	// Process medical expertise
	process_medical_expertise()

	// Process cure research
	process_cure_research()

	// Process plague evolution
	process_plague_evolution()

	// Process infection potency
	process_infection_potency()

	// Process research breakthroughs
	process_research_breakthroughs()



// Process pestilence detection
/mob/living/carbon/scp/scp049/proc/process_pestilence_detection()
	if(pestilence_mastery > 0 && prob(1))
		// Detect pestilence in nearby targets
		for(var/mob/living/carbon/human/H in range(8, src))
			if(H != src && !H.SCP)
				to_chat(src, "<span class='notice'>You detect the pestilence in [H].</span>")
				infections_performed++

// Process medical expertise
/mob/living/carbon/scp/scp049/proc/process_medical_expertise()
	if(medical_expertise > 0 && prob(1))
		// Apply medical knowledge
		for(var/mob/living/carbon/human/H in range(6, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='warning'>You feel the plague doctor's medical expertise analyzing you...</span>")
				medical_masteries++

// Process cure research
/mob/living/carbon/scp/scp049/proc/process_cure_research()
	if(cure_research > 0 && prob(1))
		// Conduct research
		cure_research = min(max_cure_research, cure_research + 5)
		research_notes++
		to_chat(src, "<span class='notice'>You make progress in your cure research. Progress: [cure_research]/[max_cure_research]</span>")

// Process plague evolution
/mob/living/carbon/scp/scp049/proc/process_plague_evolution()
	if(pestilence_mastery >= max_pestilence_mastery && plague_evolution < max_plague_evolution)
		if(prob(1))
			evolve_plague_stage()

// Process infection potency
/mob/living/carbon/scp/scp049/proc/process_infection_potency()
	if(infection_potency > 1 && prob(1))
		// Increase infection effects
		for(var/mob/living/carbon/human/H in range(4, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>The pestilence within you grows stronger...</span>")
				H.adjustToxLoss(5)

// Process research breakthroughs
/mob/living/carbon/scp/scp049/proc/process_research_breakthroughs()
	if(research_breakthroughs > 0 && prob(1))
		// Create breakthrough effects
		breakthrough_events++
		to_chat(src, "<span class='notice'>You achieve a research breakthrough!</span>")

// Evolve plague stage
/mob/living/carbon/scp/scp049/proc/evolve_plague_stage()
	plague_evolution = min(max_plague_evolution, plague_evolution + 1)
	evolution_events++

	var/evolution_message = ""
	switch(plague_evolution)
		if(2)
			evolution_message = "Your pestilence detection has evolved to include advanced analysis!"
		if(3)
			evolution_message = "Your medical expertise has reached new heights!"
		if(4)
			evolution_message = "Your cure research has achieved breakthrough capabilities!"
		if(5)
			evolution_message = "You have achieved ultimate plague evolution!"

	to_chat(src, "<span class='notice'>[evolution_message] Plague Evolution: [plague_evolution]/[max_plague_evolution]</span>")

// Maximum enhanced abilities
/mob/living/carbon/scp/scp049/proc/infect_target_ability()
	to_chat(src, "<span class='notice'>You attempt to cure the pestilence in a nearby target.</span>")

	// Find a target to infect
	var/mob/living/carbon/human/target = null
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H != src && !H.SCP)
			target = H
			break

	if(target)
		to_chat(target, "<span class='danger'>SCP-049 attempts to cure your pestilence!</span>")
		target.adjustBruteLoss(25)
		infections_performed++



		to_chat(src, "<span class='notice'>You have cured the pestilence in [target].</span>")
	else
		to_chat(src, "<span class='warning'>No suitable targets for curing found.</span>")

/mob/living/carbon/scp/scp049/proc/cure_target_ability()
	to_chat(src, "<span class='notice'>You attempt to cure a target of the pestilence.</span>")

	// Find a target to cure
	var/mob/living/carbon/human/target = null
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H != src && !H.SCP)
			target = H
			break

	if(target)
		to_chat(target, "<span class='notice'>SCP-049 attempts to cure you...</span>")
		cures_attempted++



		to_chat(src, "<span class='notice'>You attempt to cure [target].</span>")
	else
		to_chat(src, "<span class='warning'>No targets for curing found.</span>")

/mob/living/carbon/scp/scp049/proc/research_pestilence_ability()
	cure_research = min(max_cure_research, cure_research + 10)
	research_notes++

	to_chat(src, "<span class='notice'>You conduct pestilence research. Research: [cure_research]/[max_cure_research]</span>")

/mob/living/carbon/scp/scp049/proc/pestilence_mastery_ability()
	if(pestilence_mastery >= max_pestilence_mastery)
		to_chat(src, "<span class='warning'>You have reached maximum pestilence mastery.</span>")
		return

	pestilence_mastery = min(max_pestilence_mastery, pestilence_mastery + 10)
	pestilence_masteries++

	to_chat(src, "<span class='notice'>Your pestilence mastery is enhanced. Mastery: [pestilence_mastery]/[max_pestilence_mastery]</span>")

/mob/living/carbon/scp/scp049/proc/medical_expertise_ability()
	if(world.time < medical_cooldown)
		to_chat(src, "<span class='warning'>You need time to enhance your medical expertise again.</span>")
		return

	medical_cooldown = world.time + medical_cooldown_time
	medical_expertise = min(max_medical_expertise, medical_expertise + 10)
	medical_masteries++

	to_chat(src, "<span class='notice'>Your medical expertise is enhanced. Expertise: [medical_expertise]/[max_medical_expertise]</span>")

/mob/living/carbon/scp/scp049/proc/cure_research_ability()
	if(world.time < research_cooldown)
		to_chat(src, "<span class='warning'>You need time to conduct more research.</span>")
		return

	research_cooldown = world.time + research_cooldown_time
	cure_research = min(max_cure_research, cure_research + 15)
	research_masteries++

	to_chat(src, "<span class='notice'>Your cure research advances. Research: [cure_research]/[max_cure_research]</span>")

/mob/living/carbon/scp/scp049/proc/evolve_plague_ability()
	if(plague_evolution >= max_plague_evolution)
		to_chat(src, "<span class='warning'>You have reached maximum plague evolution.</span>")
		return

	if(pestilence_mastery < max_pestilence_mastery)
		to_chat(src, "<span class='warning'>You need more pestilence mastery to evolve.</span>")
		return

	evolve_plague_stage()

/mob/living/carbon/scp/scp049/proc/infection_potency_ability()
	if(infection_potency >= max_infection_potency)
		to_chat(src, "<span class='warning'>You have reached maximum infection potency.</span>")
		return

	infection_potency = min(max_infection_potency, infection_potency + 1)

	to_chat(src, "<span class='notice'>Your infection potency increases. Potency: [infection_potency]/[max_infection_potency]</span>")

/mob/living/carbon/scp/scp049/proc/research_breakthrough_ability()
	research_breakthroughs = min(max_research_breakthroughs, research_breakthroughs + 5)
	breakthrough_events++

	to_chat(src, "<span class='notice'>You achieve a research breakthrough! Breakthroughs: [research_breakthroughs]/[max_research_breakthroughs]</span>")

/mob/living/carbon/scp/scp049/proc/ultimate_pestilence_ability()
	if(plague_evolution < max_plague_evolution)
		to_chat(src, "<span class='warning'>You need maximum plague evolution for ultimate pestilence.</span>")
		return

	// Ultimate pestilence affects all nearby targets
	for(var/mob/living/carbon/human/H in range(10, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='danger'>SCP-049 performs ultimate pestilence cure!</span>")
			H.adjustBruteLoss(75)

	to_chat(src, "<span class='notice'>You perform ultimate pestilence cure on all nearby targets.</span>")

/mob/living/carbon/scp/scp049/proc/plague_synthesis_ability()
	if(pestilence_mastery < max_pestilence_mastery)
		to_chat(src, "<span class='warning'>You need more pestilence mastery to synthesize.</span>")
		return

	// Create a powerful pestilence effect
	for(var/mob/living/carbon/human/H in range(8, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='danger'>You feel the overwhelming presence of the pestilence...</span>")

	to_chat(src, "<span class='notice'>You synthesize pestilence and affect all nearby targets.</span>")

// Enhanced status display
/mob/living/carbon/scp/scp049/get_status_tab_items()
	. = ..()
	. += "Pestilence Mastery: [pestilence_mastery]/[max_pestilence_mastery]"
	. += "Medical Expertise: [medical_expertise]/[max_medical_expertise]"
	. += "Cure Research: [cure_research]/[max_cure_research]"
	. += "Plague Evolution: [plague_evolution]/[max_plague_evolution]"
	. += "Infection Potency: [infection_potency]/[max_infection_potency]"
	. += "Research Breakthroughs: [research_breakthroughs]/[max_research_breakthroughs]"
	. += "Infections Performed: [infections_performed]"
	. += "Cures Attempted: [cures_attempted]"

// Override examine behavior
/mob/living/carbon/scp/scp049/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-049, a plague doctor who seeks to cure the pestilence.</span>")
		else
			to_chat(user, "<span class='danger'>A mysterious plague doctor who seems to be studying you intently.</span>")

// Override SCP death
/mob/living/carbon/scp/scp049/scp_death()
	visible_message("<span class='danger'>[src] collapses, the pestilence cure incomplete!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Enhanced verbs
/mob/living/carbon/scp/scp049/verb/infect_target()
	set name = "Infect Target"
	set category = "SCP"
	set desc = "Attempt to cure the pestilence in a nearby target."

	infect_target_ability()

/mob/living/carbon/scp/scp049/verb/cure_target()
	set name = "Cure Target"
	set category = "SCP"
	set desc = "Attempt to cure a target of the pestilence."

	cure_target_ability()

/mob/living/carbon/scp/scp049/verb/research_pestilence()
	set name = "Research Pestilence"
	set category = "SCP"
	set desc = "Conduct pestilence research."

	research_pestilence_ability()

/mob/living/carbon/scp/scp049/verb/pestilence_mastery()
	set name = "Pestilence Mastery"
	set category = "SCP"
	set desc = "Enhance your pestilence mastery."

	pestilence_mastery_ability()

/mob/living/carbon/scp/scp049/verb/medical_expertise()
	set name = "Medical Expertise"
	set category = "SCP"
	set desc = "Enhance your medical expertise."

	medical_expertise_ability()

/mob/living/carbon/scp/scp049/verb/cure_research()
	set name = "Cure Research"
	set category = "SCP"
	set desc = "Advance your cure research."

	cure_research_ability()

/mob/living/carbon/scp/scp049/verb/evolve_plague()
	set name = "Evolve Plague"
	set category = "SCP"
	set desc = "Evolve your plague capabilities."

	evolve_plague_ability()

/mob/living/carbon/scp/scp049/verb/infection_potency()
	set name = "Infection Potency"
	set category = "SCP"
	set desc = "Increase your infection potency."

	infection_potency_ability()

/mob/living/carbon/scp/scp049/verb/research_breakthrough()
	set name = "Research Breakthrough"
	set category = "SCP"
	set desc = "Achieve a research breakthrough."

	research_breakthrough_ability()

/mob/living/carbon/scp/scp049/verb/ultimate_pestilence()
	set name = "Ultimate Pestilence"
	set category = "SCP"
	set desc = "Perform ultimate pestilence cure on all nearby targets."

	ultimate_pestilence_ability()

/mob/living/carbon/scp/scp049/verb/plague_synthesis()
	set name = "Plague Synthesis"
	set category = "SCP"
	set desc = "Synthesize pestilence and affect all nearby targets."

	plague_synthesis_ability()

// Enhanced persistence data view
/mob/living/carbon/scp/scp049/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-049 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-049 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Infections Performed:</b> [infections_performed]<br>"
	message += "<b>Cures Attempted:</b> [cures_attempted]<br>"
	message += "<b>Research Notes:</b> [research_notes]<br>"
	message += "<b>Breakthrough Events:</b> [breakthrough_events]<br>"
	message += "<b>Pestilence Masteries:</b> [pestilence_masteries]<br>"
	message += "<b>Medical Masteries:</b> [medical_masteries]<br>"
	message += "<b>Research Masteries:</b> [research_masteries]<br>"
	message += "<b>Evolution Events:</b> [evolution_events]<br>"
	message += "<b>Pestilence Mastery:</b> [pestilence_mastery]/[max_pestilence_mastery]<br>"
	message += "<b>Medical Expertise:</b> [medical_expertise]/[max_medical_expertise]<br>"
	message += "<b>Cure Research:</b> [cure_research]/[max_cure_research]<br>"
	message += "<b>Plague Evolution:</b> [plague_evolution]/[max_plague_evolution]<br>"
	message += "<b>Infection Potency:</b> [infection_potency]/[max_infection_potency]<br>"
	message += "<b>Research Breakthroughs:</b> [research_breakthroughs]/[max_research_breakthroughs]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")
