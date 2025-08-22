// SCP-049 - The Plague Doctor
// Complete Foundation-19 PR implementation with persistence integration

/mob/living/carbon/human/scp049
	name = "SCP-049"
	desc = "A tall humanoid figure wearing the black robes and bird-like mask of a medieval plague doctor."
	icon = 'icons/scp/scp-049.dmi'
	icon_state = "scp049"
	real_name = "SCP-049"

	// Pestilence mechanics
	var/pestilence_level = 0
	var/max_pestilence_level = 100
	var/pestilence_spread_radius = 3
	var/pestilence_infection_chance = 25
	var/pestilence_damage = 5
	var/pestilence_cooldown = 0
	var/pestilence_cooldown_time = 30 SECONDS

	// Cure mechanics
	var/cure_potency = 1
	var/max_cure_potency = 10
	var/cure_cooldown = 0
	var/cure_cooldown_time = 60 SECONDS
	var/cure_range = 2
	var/cure_effectiveness = 50

	// Door breaching
	var/breach_cooldown = 0
	var/breach_cooldown_time = 120 SECONDS
	var/breach_range = 5
	var/breach_power = 50

	// Research and evolution
	var/research_progress = 0
	var/max_research_progress = 1000
	var/evolution_stage = 1
	var/max_evolution_stage = 5
	var/research_cooldown = 0
	var/research_cooldown_time = 45 SECONDS

	// Audio and announcements
	var/last_announcement = 0
	var/announcement_cooldown = 300 SECONDS
	var/announcement_messages = list(
		"The pestilence must be cured...",
		"I can see the disease within you...",
		"The cure is within my grasp...",
		"Death is not the end, but the beginning of the cure...",
		"I will save you all from the pestilence..."
	)

	// Persistence tracking
	var/infections_performed = 0
	var/cures_attempted = 0
	var/cures_successful = 0
	var/doors_breached = 0
	var/research_breakthroughs = 0
	var/evolution_events = 0
	var/total_pestilence_spread = 0
	var/total_damage_dealt = 0

/mob/living/carbon/human/scp049/Initialize()
	. = ..()

	// Set species properly
	set_species(/datum/species/scp049)

	// Create SCP datum and enable advanced component system
	SCP = new /datum/scp(src, "Plague Doctor", SCP_EUCLID, "049", SCP_SENTIENT)
	SCP.uses_advanced_components = TRUE
	SCP.compInit_advanced()

	// Initialize SCP-049 specific skills
	initialize_scp_049_skills()

	// Add door breacher component
	AddComponent(/datum/component/doorBreacher)

	// Set up HUD
	setup_pestilence_hud()

	// Initial announcement
	announce_presence()

	// Load persistence data
	load_persistence_data()

/mob/living/carbon/human/scp049/proc/initialize_scp_049_skills()
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = SCP.get_component("skill_system")
	if(skill_system)
		skill_system.add_skill("Spread Pestilence", 30 SECONDS, list("requires_proximity"))
		skill_system.add_skill("Cure Target", 60 SECONDS, list("requires_proximity"))
		skill_system.add_skill("Breach Doors", 120 SECONDS, list("requires_power"))
		skill_system.add_skill("Research Cure", 45 SECONDS, list("requires_materials"))
		skill_system.add_skill("Evolve Pestilence", 300 SECONDS, list("requires_breach"))

/mob/living/carbon/human/scp049/proc/setup_pestilence_hud()
	// Add pestilence HUD
	var/datum/atom_hud/data/human/pestilence/pestilence_hud = GLOB.huds[DATA_HUD_PESTILENCE]
	if(pestilence_hud)
		pestilence_hud.add_atom_to_hud(src)

/mob/living/carbon/human/scp049/proc/announce_presence()
	if(world.time < last_announcement + announcement_cooldown)
		return

	last_announcement = world.time
	var/announcement = pick(announcement_messages)

	// Play audio
	playsound(src, 'sound/scp/scp049/SCP049_1.ogg', 50, 0)

	// Send announcement
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.z == z)
			to_chat(H, "<span class='danger'>[announcement]</span>")

// Pestilence spreading mechanics
/mob/living/carbon/human/scp049/proc/spread_pestilence()
	if(world.time < pestilence_cooldown)
		to_chat(src, "<span class='warning'>The pestilence needs time to manifest...</span>")
		return FALSE

	pestilence_cooldown = world.time + pestilence_cooldown_time

	// Increase pestilence level
	pestilence_level = min(max_pestilence_level, pestilence_level + 10)

	// Spread to nearby targets within vision cone
	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(pestilence_spread_radius, src))
		if(H != src && !HAS_TRAIT(H, TRAIT_PESTILENCE))
			// Only affect targets within SCP-049's vision cone
			if(fovangle && can_see_cone(H))
				nearby_targets += H

	var/infected_count = 0
	for(var/mob/living/carbon/human/H in nearby_targets)
		if(prob(pestilence_infection_chance))
			infect_with_pestilence(H)
			infected_count++

	// Update persistence
	infections_performed++
	total_pestilence_spread += infected_count

	// Visual and audio effects
	playsound(src, 'sound/scp/scp049/SCP049_2.ogg', 50, 0)
	visible_message("<span class='danger'>[src] spreads the pestilence!</span>")

	to_chat(src, "<span class='notice'>Pestilence spread to [infected_count] targets. Level: [pestilence_level]/[max_pestilence_level]</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp049/proc/infect_with_pestilence(mob/living/carbon/human/target)
	if(!target || HAS_TRAIT(target, TRAIT_PESTILENCE))
		return FALSE

	ADD_TRAIT(target, TRAIT_PESTILENCE, "scp049")
	target.update_pestilence_hud()

	to_chat(target, "<span class='danger'>You feel the pestilence taking hold...</span>")
	playsound(target, 'sound/scp/scp049/SCP049_3.ogg', 30, 0)

	// Start pestilence effects
	spawn(10 SECONDS)
		apply_pestilence_effects(target)

/mob/living/carbon/human/scp049/proc/apply_pestilence_effects(mob/living/carbon/human/target)
	if(!target || !HAS_TRAIT(target, TRAIT_PESTILENCE))
		return

	// Apply damage over time with scaling based on pestilence level
	var/damage_multiplier = 1 + (pestilence_level / 100)
	target.adjustBruteLoss(pestilence_damage * damage_multiplier)
	target.adjustToxLoss(pestilence_damage * 0.5 * damage_multiplier)
	total_damage_dealt += pestilence_damage * damage_multiplier

	// Enhanced visual effects
	target.add_atom_colour("#00ff00", FIXED_COLOUR_PRIORITY)

	// Add coughing and other symptoms
	if(prob(20))
		target.emote("cough")
		to_chat(target, "<span class='warning'>You cough violently, the pestilence taking its toll...</span>")

	// Chance to spread to nearby targets
	if(prob(10))
		for(var/mob/living/carbon/human/H in range(1, target))
			if(H != target && H != src && !HAS_TRAIT(H, TRAIT_PESTILENCE))
				if(prob(15))
					infect_with_pestilence(H)

	// Continue effects with shorter interval for more aggressive progression
	spawn(20 SECONDS)
		apply_pestilence_effects(target)

// Cure mechanics
/mob/living/carbon/human/scp049/proc/cure_target(mob/living/carbon/human/target)
	if(world.time < cure_cooldown)
		to_chat(src, "<span class='warning'>The cure needs time to prepare...</span>")
		return FALSE

	if(!target)
		to_chat(src, "<span class='warning'>You need a target to cure.</span>")
		return FALSE

	if(!HAS_TRAIT(target, TRAIT_PESTILENCE))
		to_chat(src, "<span class='warning'>This target is not afflicted with the pestilence.</span>")
		return FALSE

	cure_cooldown = world.time + cure_cooldown_time
	cures_attempted++

	// Attempt cure
	if(prob(cure_effectiveness * cure_potency))
		successful_cure(target)
		cures_successful++
	else
		failed_cure(target)

	playsound(src, 'sound/scp/scp049/SCP049_Cure1.ogg', 50, 0)

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp049/proc/successful_cure(mob/living/carbon/human/target)
	REMOVE_TRAIT(target, TRAIT_PESTILENCE, "scp049")
	target.update_pestilence_hud()
	target.remove_atom_colour(FIXED_COLOUR_PRIORITY, "#00ff00")

	to_chat(target, "<span class='notice'>You feel the pestilence leaving your body...</span>")
	to_chat(src, "<span class='notice'>You successfully cured [target] of the pestilence.</span>")

	playsound(target, 'sound/scp/scp049/SCP049_Cure2.ogg', 50, 0)

/mob/living/carbon/human/scp049/proc/failed_cure(mob/living/carbon/human/target)
	to_chat(target, "<span class='danger'>The cure attempt failed, the pestilence persists...</span>")
	to_chat(src, "<span class='warning'>The cure was not effective enough.</span>")

// Door breaching
/mob/living/carbon/human/scp049/proc/breach_doors()
	// Use the doorBreacher component if available
	var/datum/component/doorBreacher/breacher = GetComponent(/datum/component/doorBreacher)
	if(breacher)
		var/success = breacher.breach_doors()
		if(success)
			doors_breached += 1
			// Save persistence data
			save_persistence_data()
		return success

	// Fallback to manual breaching if component not available
	if(world.time < breach_cooldown)
		to_chat(src, "<span class='warning'>Door breaching systems are recharging...</span>")
		return FALSE

	breach_cooldown = world.time + breach_cooldown_time

	var/list/doors_in_range = list()
	for(var/obj/machinery/door/D in range(breach_range, src))
		if(D.density)
			doors_in_range += D

	if(doors_in_range.len == 0)
		to_chat(src, "<span class='warning'>No doors found in range.</span>")
		return FALSE

	// Enhanced door breaching with visual effects
	for(var/obj/machinery/door/D in doors_in_range)
		// Try to force open with enhanced probability based on breach power
		if(prob(min(breach_power, 80)))
			D.open()

			// Visual effects
			var/turf/T = get_turf(D)
			if(T)
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(3, 1, T)
				s.start()

	// EMP effect on nearby electronics
	for(var/obj/machinery/M in range(breach_range, src))
		if(M != src)
			M.emp_act(EMP_LIGHT)

	doors_breached += length(doors_in_range)

	playsound(src, 'sound/scp/scp049/SCP049_4.ogg', 50, 0)
	to_chat(src, "<span class='notice'>Breached [length(doors_in_range)] doors with enhanced force.</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

// Research and evolution
/mob/living/carbon/human/scp049/proc/research_cure()
	if(world.time < research_cooldown)
		to_chat(src, "<span class='warning'>Research systems are analyzing...</span>")
		return FALSE

	research_cooldown = world.time + research_cooldown_time

	// Enhanced research with multiple factors
	var/research_bonus = 0

	// Bonus for having infected targets nearby
	var/infected_nearby = 0
	for(var/mob/living/carbon/human/H in range(5, src))
		if(HAS_TRAIT(H, TRAIT_PESTILENCE))
			infected_nearby++

	research_bonus += infected_nearby * 10

	// Bonus for higher evolution stage
	research_bonus += evolution_stage * 5

	// Base research progress plus bonuses
	research_progress += 50 + research_bonus

	// Announce research progress
	var/progress_percent = (research_progress / max_research_progress) * 100
	to_chat(src, "<span class='notice'>Research progress: [research_progress]/[max_research_progress] ([round(progress_percent, 1)]%)</span>")

	if(infected_nearby > 0)
		to_chat(src, "<span class='notice'>Studying [infected_nearby] infected subjects provides valuable insights...</span>")

	if(research_progress >= max_research_progress)
		evolve_pestilence()

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp049/proc/evolve_pestilence()
	if(evolution_stage >= max_evolution_stage)
		to_chat(src, "<span class='warning'>Maximum evolution reached.</span>")
		return FALSE

	evolution_stage++
	research_progress = 0
	evolution_events++
	research_breakthroughs++

	// Enhanced ability improvements based on evolution stage
	pestilence_spread_radius += 1
	pestilence_infection_chance += 5
	cure_effectiveness += 10
	breach_power += 10

	// Additional enhancements based on stage
	switch(evolution_stage)
		if(2)
			to_chat(src, "<span class='notice'>Pestilence evolved to stage [evolution_stage]! Enhanced spread radius and infection chance.</span>")
		if(3)
			to_chat(src, "<span class='notice'>Pestilence evolved to stage [evolution_stage]! Improved cure effectiveness and door breaching power.</span>")
			// Add new abilities
			pestilence_damage += 2
		if(4)
			to_chat(src, "<span class='notice'>Pestilence evolved to stage [evolution_stage]! Advanced pestilence damage and enhanced research capabilities.</span>")
			// Add more abilities
			announcement_cooldown = max(60 SECONDS, announcement_cooldown - 60 SECONDS)
		if(5)
			to_chat(src, "<span class='notice'>Pestilence reached maximum evolution! Ultimate pestilence mastery achieved.</span>")
			// Ultimate abilities
			pestilence_spread_radius += 2
			pestilence_infection_chance += 10

	// Visual and audio effects
	playsound(src, 'sound/scp/scp049/SCP049_5.ogg', 50, 0)

	// Announce to nearby players
	for(var/mob/living/carbon/human/H in range(7, src))
		if(H != src)
			to_chat(H, "<span class='danger'>You feel an overwhelming sense of dread as the pestilence evolves...</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

// Life cycle
/mob/living/carbon/human/scp049/Life()
	. = ..()

	// Update components
	if(SCP && SCP.uses_advanced_components)
		SCP.update_components()

	// Passive pestilence spread
	if(prob(5) && pestilence_level > 0)
		passive_pestilence_spread()

	// Random announcements
	if(prob(1) && world.time > last_announcement + announcement_cooldown)
		announce_presence()

/mob/living/carbon/human/scp049/proc/passive_pestilence_spread()
	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(2, src))
		if(H != src && !HAS_TRAIT(H, TRAIT_PESTILENCE))
			nearby_targets += H

	for(var/mob/living/carbon/human/H in nearby_targets)
		if(prob(10))
			infect_with_pestilence(H)

// Persistence system integration
/mob/living/carbon/human/scp049/proc/save_persistence_data()
	if(!SCP || !SCP.uses_advanced_components)
		return

	var/datum/scp_advanced_component/advanced_persistence_system/persistence = SCP.get_component("persistence_system")
	if(persistence)
		var/list/persistence_data = list(
			"pestilence_level" = pestilence_level,
			"cure_potency" = cure_potency,
			"evolution_stage" = evolution_stage,
			"research_progress" = research_progress,
			"infections_performed" = infections_performed,
			"cures_attempted" = cures_attempted,
			"cures_successful" = cures_successful,
			"doors_breached" = doors_breached,
			"research_breakthroughs" = research_breakthroughs,
			"evolution_events" = evolution_events,
			"total_pestilence_spread" = total_pestilence_spread,
			"total_damage_dealt" = total_damage_dealt
		)
		persistence.save_data("scp049_stats", persistence_data)

/mob/living/carbon/human/scp049/proc/load_persistence_data()
	if(!SCP || !SCP.uses_advanced_components)
		return

	var/datum/scp_advanced_component/advanced_persistence_system/persistence = SCP.get_component("persistence_system")
	if(persistence)
		var/list/persistence_data = persistence.load_data("scp049_stats")
		if(persistence_data)
			pestilence_level = persistence_data["pestilence_level"] || 0
			cure_potency = persistence_data["cure_potency"] || 1
			evolution_stage = persistence_data["evolution_stage"] || 1
			research_progress = persistence_data["research_progress"] || 0
			infections_performed = persistence_data["infections_performed"] || 0
			cures_attempted = persistence_data["cures_attempted"] || 0
			cures_successful = persistence_data["cures_successful"] || 0
			doors_breached = persistence_data["doors_breached"] || 0
			research_breakthroughs = persistence_data["research_breakthroughs"] || 0
			evolution_events = persistence_data["evolution_events"] || 0
			total_pestilence_spread = persistence_data["total_pestilence_spread"] || 0
			total_damage_dealt = persistence_data["total_damage_dealt"] || 0

// Verbs
/mob/living/carbon/human/scp049/verb/spread_pestilence_verb()
	set name = "Spread Pestilence"
	set category = "SCP-049"
	set desc = "Spread the pestilence to nearby targets"

	spread_pestilence()

/mob/living/carbon/human/scp049/verb/cure_target_verb()
	set name = "Cure Target"
	set category = "SCP-049"
	set desc = "Attempt to cure a target of the pestilence"

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(cure_range, src))
		if(HAS_TRAIT(H, TRAIT_PESTILENCE))
			targets += H

	if(targets.len == 0)
		to_chat(src, "<span class='warning'>No afflicted targets in range.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Select target to cure:", "Cure Target") as null|mob in targets
	if(target)
		cure_target(target)

/mob/living/carbon/human/scp049/verb/breach_doors_verb()
	set name = "Breach Doors"
	set category = "SCP-049"
	set desc = "Breach nearby doors"

	breach_doors()

/mob/living/carbon/human/scp049/verb/research_cure_verb()
	set name = "Research Cure"
	set category = "SCP-049"
	set desc = "Research the cure for the pestilence"

	research_cure()

/mob/living/carbon/human/scp049/verb/evolve_pestilence_verb()
	set name = "Evolve Pestilence"
	set category = "SCP-049"
	set desc = "Evolve the pestilence to a higher stage"

	evolve_pestilence()

/mob/living/carbon/human/scp049/verb/show_status_verb()
	set name = "Show Status"
	set category = "SCP-049"
	set desc = "Display current SCP-049 status"

	var/status = "=== SCP-049 Status ===\n"
	status += "Pestilence Level: [pestilence_level]/[max_pestilence_level]\n"
	status += "Cure Potency: [cure_potency]/[max_cure_potency]\n"
	status += "Evolution Stage: [evolution_stage]/[max_evolution_stage]\n"
	status += "Research Progress: [research_progress]/[max_research_progress]\n"
	status += "Spread Radius: [pestilence_spread_radius]\n"
	status += "Infection Chance: [pestilence_infection_chance]%\n"
	status += "Cure Effectiveness: [cure_effectiveness]%\n"
	status += "Breach Power: [breach_power]\n"
	status += "=== Statistics ===\n"
	status += "Infections Performed: [infections_performed]\n"
	status += "Cures Attempted: [cures_attempted]\n"
	status += "Cures Successful: [cures_successful]\n"
	status += "Doors Breached: [doors_breached]\n"
	status += "Research Breakthroughs: [research_breakthroughs]\n"
	status += "Evolution Events: [evolution_events]\n"
	status += "Total Pestilence Spread: [total_pestilence_spread]\n"
	status += "Total Damage Dealt: [total_damage_dealt]"

	to_chat(src, "<span class='notice'>[status]</span>")

// Status display
/mob/living/carbon/human/scp049/proc/get_scp_status()
	var/status = "SCP-049 Status: "
	status += "Pestilence [pestilence_level]/[max_pestilence_level], "
	status += "Stage [evolution_stage]/[max_evolution_stage], "
	status += "Research [research_progress]/[max_research_progress], "
	status += "Infections: [infections_performed], "
	status += "Cures: [cures_successful]/[cures_attempted]"
	return status
