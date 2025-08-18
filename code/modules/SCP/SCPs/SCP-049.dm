// SCP-049 - The Plague Doctor
// A mysterious plague doctor who seeks to cure the "pestilence" through lethal means

/mob/living/carbon/scp/scp049
	name = "SCP-049"
	desc = "A tall humanoid figure wearing the black robes and bird-like mask of a medieval plague doctor."
	icon = 'icons/scp/scp-049.dmi'
	icon_state = "scp049"
	real_name = "SCP-049"
	use_custom_sprite = TRUE

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

	// Initialize SCP-049 specific skills with cooldowns and requirements
	initialize_skill("infect_target", 20 SECONDS, list("base_cooldown" = 20 SECONDS))
	initialize_skill("cure_target", 45 SECONDS, list("base_cooldown" = 45 SECONDS, "requires_level_15" = TRUE))
	initialize_skill("research_pestilence", 60 SECONDS, list("base_cooldown" = 60 SECONDS, "requires_level_10" = TRUE))
	initialize_skill("pestilence_mastery", 90 SECONDS, list("base_cooldown" = 90 SECONDS, "requires_level_25" = TRUE))
	initialize_skill("medical_expertise", 30 SECONDS, list("base_cooldown" = 30 SECONDS, "requires_level_20" = TRUE))
	initialize_skill("cure_research", 120 SECONDS, list("base_cooldown" = 120 SECONDS, "requires_level_30" = TRUE))
	initialize_skill("evolve_plague", 180 SECONDS, list("base_cooldown" = 180 SECONDS, "requires_level_40" = TRUE, "requires_breach" = TRUE))
	initialize_skill("infection_potency", 75 SECONDS, list("base_cooldown" = 75 SECONDS, "requires_level_35" = TRUE))
	initialize_skill("research_breakthrough", 150 SECONDS, list("base_cooldown" = 150 SECONDS, "requires_level_50" = TRUE))
	initialize_skill("ultimate_pestilence", 300 SECONDS, list("base_cooldown" = 300 SECONDS, "requires_level_70" = TRUE, "requires_breach" = TRUE))
	initialize_skill("plague_synthesis", 240 SECONDS, list("base_cooldown" = 240 SECONDS, "requires_level_60" = TRUE, "requires_breach" = TRUE))

	// Set up default containment protocols and security measures
	setup_default_containment()

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

/mob/living/carbon/scp/scp049/proc/infect_target_ability()
	if(!use_skill("infect_target", 1, 0.8))
		return
	
	to_chat(src, "<span class='notice'>You attempt to infect a target with the pestilence.</span>")

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
	if(!use_skill("cure_target", 2, 1.2))
		return
	
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
	if(!use_skill("research_pestilence", 3, 1.0))
		return
	
	cure_research = min(max_cure_research, cure_research + 10)
	research_notes++
	to_chat(src, "<span class='notice'>You conduct pestilence research. Research: [cure_research]/[max_cure_research]</span>")

/mob/living/carbon/scp/scp049/proc/pestilence_mastery_ability()
	if(!use_skill("pestilence_mastery", 4, 1.5))
		return
	
	if(pestilence_mastery >= max_pestilence_mastery)
		to_chat(src, "<span class='warning'>You have reached maximum pestilence mastery.</span>")
		return

	pestilence_mastery = min(max_pestilence_mastery, pestilence_mastery + 10)
	pestilence_masteries++
	to_chat(src, "<span class='notice'>Your pestilence mastery is enhanced. Mastery: [pestilence_mastery]/[max_pestilence_mastery]</span>")

/mob/living/carbon/scp/scp049/proc/medical_expertise_ability()
	if(!use_skill("medical_expertise", 2, 1.0))
		return
	
	medical_expertise = min(max_medical_expertise, medical_expertise + 10)
	medical_masteries++
	to_chat(src, "<span class='notice'>Your medical expertise is enhanced. Expertise: [medical_expertise]/[max_medical_expertise]</span>")

/mob/living/carbon/scp/scp049/proc/cure_research_ability()
	if(!use_skill("cure_research", 5, 1.8))
		return
	
	cure_research = min(max_cure_research, cure_research + 15)
	research_masteries++
	to_chat(src, "<span class='notice'>Your cure research advances. Research: [cure_research]/[max_cure_research]</span>")

/mob/living/carbon/scp/scp049/proc/evolve_plague_ability()
	if(!use_skill("evolve_plague", 6, 2.0))
		return
	
	if(plague_evolution >= max_plague_evolution)
		to_chat(src, "<span class='warning'>You have reached maximum plague evolution.</span>")
		return

	if(pestilence_mastery < max_pestilence_mastery)
		to_chat(src, "<span class='warning'>You need more pestilence mastery to evolve.</span>")
		return

	evolve_plague_stage()

/mob/living/carbon/scp/scp049/proc/infection_potency_ability()
	if(!use_skill("infection_potency", 3, 1.3))
		return
	
	if(infection_potency >= max_infection_potency)
		to_chat(src, "<span class='warning'>You have reached maximum infection potency.</span>")
		return

	infection_potency = min(max_infection_potency, infection_potency + 1)
	to_chat(src, "<span class='notice'>Your infection potency increases. Potency: [infection_potency]/[max_infection_potency]</span>")

/mob/living/carbon/scp/scp049/proc/research_breakthrough_ability()
	if(!use_skill("research_breakthrough", 4, 1.6))
		return
	
	research_breakthroughs = min(max_research_breakthroughs, research_breakthroughs + 5)
	breakthrough_events++
	to_chat(src, "<span class='notice'>You achieve a research breakthrough! Breakthroughs: [research_breakthroughs]/[max_research_breakthroughs]</span>")

/mob/living/carbon/scp/scp049/proc/ultimate_pestilence_ability()
	if(!use_skill("ultimate_pestilence", 8, 2.5))
		return
	
	if(plague_evolution < max_plague_evolution)
		to_chat(src, "<span class='warning'>You need maximum plague evolution for ultimate pestilence.</span>")
		return

	to_chat(src, "<span class='notice'>You unleash the ultimate pestilence!</span>")
	// Affect all nearby humans with ultimate pestilence
	for(var/mob/living/carbon/human/H in range(15, src))
		if(H != src && !H.SCP)
			H.adjustBruteLoss(50)
			H.adjustToxLoss(30)
			to_chat(H, "<span class='danger'>You are overwhelmed by the ultimate pestilence!</span>")

/mob/living/carbon/scp/scp049/proc/plague_synthesis_ability()
	if(!use_skill("plague_synthesis", 7, 2.2))
		return
	
	to_chat(src, "<span class='notice'>You synthesize a new strain of the pestilence!</span>")
	// Create a new plague effect
	plague_evolution = min(max_plague_evolution, plague_evolution + 1)
	infection_potency = min(max_infection_potency, infection_potency + 2)
	to_chat(src, "<span class='notice'>Plague evolution: [plague_evolution]/[max_plague_evolution], Potency: [infection_potency]/[max_infection_potency]</span>")

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

// SCP-049 specific skill requirement checks
/mob/living/carbon/scp/scp049/check_skill_requirement(requirement, current_level)
	switch(requirement)
		if("requires_breach")
			return containment_status == "breached"
		if("requires_level_10")
			return current_level >= 10
		if("requires_level_15")
			return current_level >= 15
		if("requires_level_20")
			return current_level >= 20
		if("requires_level_25")
			return current_level >= 25
		if("requires_level_30")
			return current_level >= 30
		if("requires_level_35")
			return current_level >= 35
		if("requires_level_40")
			return current_level >= 40
		if("requires_level_50")
			return current_level >= 50
		if("requires_level_60")
			return current_level >= 60
		if("requires_level_70")
			return current_level >= 70
		else
			return ..()

// Apply skill level effects for SCP-049
/mob/living/carbon/scp/scp049/apply_skill_level_effects(skill_name, new_level)
	switch(skill_name)
		if("infect_target")
			if(new_level >= 20)
				to_chat(src, "<span class='notice'>Your infection affects a larger area.</span>")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your infection can now affect multiple targets.</span>")
		if("cure_target")
			if(new_level >= 25)
				to_chat(src, "<span class='notice'>Your curing is more effective.</span>")
			if(new_level >= 50)
				to_chat(src, "<span class='notice'>Your curing can now heal allies.</span>")
		if("research_pestilence")
			if(new_level >= 20)
				to_chat(src, "<span class='notice'>Your research is more efficient.</span>")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your research can now unlock new abilities.</span>")
		if("pestilence_mastery")
			if(new_level >= 30)
				to_chat(src, "<span class='notice'>Your pestilence mastery affects a larger area.</span>")
			if(new_level >= 60)
				to_chat(src, "<span class='notice'>Your pestilence mastery can now control the disease.</span>")
		if("medical_expertise")
			if(new_level >= 25)
				to_chat(src, "<span class='notice'>Your medical expertise is more precise.</span>")
			if(new_level >= 50)
				to_chat(src, "<span class='notice'>Your medical expertise can now diagnose diseases.</span>")
		if("cure_research")
			if(new_level >= 35)
				to_chat(src, "<span class='notice'>Your cure research is more advanced.</span>")
			if(new_level >= 70)
				to_chat(src, "<span class='notice'>Your cure research can now create vaccines.</span>")
		if("evolve_plague")
			if(new_level >= 45)
				to_chat(src, "<span class='notice'>Your plague evolution is more potent.</span>")
			if(new_level >= 80)
				to_chat(src, "<span class='notice'>Your plague evolution can now create new strains.</span>")
		if("infection_potency")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your infection potency affects more targets.</span>")
			if(new_level >= 75)
				to_chat(src, "<span class='notice'>Your infection potency can now spread rapidly.</span>")
		if("research_breakthrough")
			if(new_level >= 55)
				to_chat(src, "<span class='notice'>Your research breakthroughs are more significant.</span>")
			if(new_level >= 85)
				to_chat(src, "<span class='notice'>Your research breakthroughs can now revolutionize medicine.</span>")
		if("ultimate_pestilence")
			if(new_level >= 75)
				to_chat(src, "<span class='notice'>Your ultimate pestilence affects a larger area.</span>")
			if(new_level >= 90)
				to_chat(src, "<span class='notice'>Your ultimate pestilence can now cause global outbreaks.</span>")
		if("plague_synthesis")
			if(new_level >= 65)
				to_chat(src, "<span class='notice'>Your plague synthesis creates more potent strains.</span>")
			if(new_level >= 85)
				to_chat(src, "<span class='notice'>Your plague synthesis can now create beneficial viruses.</span>")
