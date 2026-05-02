// SCP-049 - The Plague Doctor
// Complete Foundation-19 implementation with persistence and sanity integration
// Ported from: https://github.com/Foundation-19/Daedelus-Foundation/pull/13/files

/mob/living/carbon/human/scp049
	name = "SCP-049"
	desc = "A tall humanoid figure wearing the black robes and bird-like mask of a medieval plague doctor."
	icon = 'icons/scp/scp-049.dmi'
	icon_state = ""
	real_name = "SCP-049"

	// Core mechanics from Foundation-19
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

	// Audio and announcements (Foundation-19 style)
	var/last_announcement = 0
	var/announcement_cooldown = 300 SECONDS
	var/list/announcement_messages = list(
		"The pestilence must be cured...",
		"I can see the disease within you...",
		"The cure is within my grasp...",
		"Death is not the end, but the beginning of the cure...",
		"I will save you all from the pestilence...",
		"My work here is not yet complete...",
		"The Great Work must continue..."
	)

	// Enhanced persistence tracking
	var/infections_performed = 0
	var/cures_attempted = 0
	var/cures_successful = 0
	var/doors_breached = 0
	var/research_breakthroughs = 0
	var/evolution_events = 0
	var/total_pestilence_spread = 0
	var/total_damage_dealt = 0
	var/session_start_time = 0
	var/total_playtime = 0

	// Progression integration tracking
	var/cures_performed = 0
	var/containment_breaches = 0

/mob/living/carbon/human/scp049/Initialize()
	. = ..()

	// Set proper species (Foundation-19 approach)
	set_species(/datum/species/scp049)

	// Create SCP datum with proper flags
	SCP = new /datum/scp(src, "Plague Doctor", SCP_EUCLID, "049", SCP_SENTIENT)

	// Add door breacher component
	AddComponent(/datum/component/doorBreacher, breach_range, breach_power, breach_cooldown_time, 'sound/scp/scp049/SCP049_2.ogg', "breaches through the doors with unnatural force!")

	// Set session start time
	session_start_time = world.time

	// Set up HUD systems
	setup_pestilence_hud()

	// Initial announcement
	announce_presence()

	// Load persistence data
	load_persistence_data()

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-049"] = new /datum/scp_instance("SCP-049", src)

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

	// Grant language
	grant_language(/datum/language/common, TRUE, TRUE)

/mob/living/carbon/human/scp049/proc/setup_pestilence_hud()
	// Add pestilence HUD capability (handled by species)
	var/datum/atom_hud/data/human/pestilence/pestilence_hud = GLOB.huds[DATA_HUD_PESTILENCE]
	if(pestilence_hud)
		pestilence_hud.add_atom_to_hud(src)

/mob/living/carbon/human/scp049/proc/announce_presence()
	if(world.time < last_announcement + announcement_cooldown)
		return

	last_announcement = world.time
	var/announcement = pick(announcement_messages)

	// Play characteristic audio (Foundation-19 approach)
	playsound(src, 'sound/scp/scp049/SCP049_1.ogg', 50, 0)

	// Send announcement to nearby players
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.z == z && get_dist(H, src) <= 15)
			to_chat(H, "<span class='danger'><b>[announcement]</b></span>")

			// Apply sanity effects for non-Foundation personnel
			if(H.job != "Site Director" && H.job != "Research Director" && H.job != "Senior Researcher")
				// Sanity system integration would go here
				// if(SSsanity)
				// 	SSsanity.adjustSanityLoss(H, 5, "Heard SCP-049 speak")
				continue

// Enhanced pestilence spreading (Foundation-19 approach)
/mob/living/carbon/human/scp049/proc/spread_pestilence()
	if(world.time < pestilence_cooldown)
		to_chat(src, "<span class='warning'>The pestilence needs time to manifest...</span>")
		return FALSE

	pestilence_cooldown = world.time + pestilence_cooldown_time

	// Increase pestilence level
	pestilence_level = min(max_pestilence_level, pestilence_level + 10)

	// Find targets in vision cone
	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(pestilence_spread_radius, src))
		if(H != src && !HAS_TRAIT(H, TRAIT_PESTILENCE))
			// Check if in vision cone
			if(fovangle && can_see_cone(H))
				nearby_targets += H

	var/infected_count = 0
	for(var/mob/living/carbon/human/H in nearby_targets)
		if(prob(pestilence_infection_chance + (pestilence_level / 10)))
			infect_with_pestilence(H)
			infected_count++

	// Update persistence
		infections_performed++
	total_pestilence_spread += infected_count

	// Enhanced effects (Foundation-19 style)
	playsound(src, 'sound/scp/scp049/SCP049_2.ogg', 80, 0)
	visible_message("<span class='danger'>[src] spreads the pestilence with a sweeping gesture!</span>")

	// Create visual effect
	var/obj/effect/temp_visual/pestilence_spread/effect = new(loc)
	effect.alpha = 150

	to_chat(src, "<span class='notice'>Pestilence spread to [infected_count] targets. Level: [pestilence_level]/[max_pestilence_level]</span>")

	// Save persistence data
	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp049/proc/infect_with_pestilence(mob/living/carbon/human/target)
	if(!target || HAS_TRAIT(target, TRAIT_PESTILENCE))
		return FALSE

	// Check immunity
	if(HAS_TRAIT(target, TRAIT_PESTILENCE_IMMUNE))
		to_chat(src, "<span class='warning'>[target] seems resistant to the pestilence...</span>")
		return FALSE

	ADD_TRAIT(target, TRAIT_PESTILENCE, "scp049")
	target.update_pestilence_hud()

	to_chat(target, "<span class='danger'>You feel the pestilence taking hold... Something is terribly wrong.</span>")
	playsound(target, 'sound/scp/scp049/SCP049_3.ogg', 30, 0)

	// Sanity effects
	// if(SSsanity)
	// 	SSsanity.adjustSanityLoss(target, 15, "Infected with pestilence by SCP-049")

	// Start pestilence effects with timer
	addtimer(CALLBACK(src, PROC_REF(apply_pestilence_effects), target), 10 SECONDS)

/mob/living/carbon/human/scp049/proc/apply_pestilence_effects(mob/living/carbon/human/target)
	if(!target || !HAS_TRAIT(target, TRAIT_PESTILENCE))
		return

	// Apply scaling damage
	var/damage_multiplier = 1 + (pestilence_level / 100)
	target.adjustBruteLoss(pestilence_damage * damage_multiplier)
	target.adjustToxLoss(pestilence_damage * 0.5 * damage_multiplier)
	total_damage_dealt += pestilence_damage * damage_multiplier

	// Visual effects
	target.add_atom_colour("#00ff00", FIXED_COLOUR_PRIORITY)

	// Symptoms
	if(prob(20))
		target.emote("cough")
		to_chat(target, "<span class='warning'>You cough violently, the pestilence consuming your essence...</span>")

	// Chance to spread to nearby targets
	if(prob(10))
		for(var/mob/living/carbon/human/H in range(2, target))
			if(H != target && H != src && !HAS_TRAIT(H, TRAIT_PESTILENCE))
				if(prob(10))
					infect_with_pestilence(H)

	// Continue effects
	addtimer(CALLBACK(src, PROC_REF(apply_pestilence_effects), target), 20 SECONDS)

// Enhanced cure mechanics (Foundation-19 approach)
/mob/living/carbon/human/scp049/proc/cure_target(mob/living/carbon/human/target)
	if(world.time < cure_cooldown)
		to_chat(src, "<span class='warning'>The cure needs time to prepare...</span>")
		return FALSE

	if(!target || !HAS_TRAIT(target, TRAIT_PESTILENCE))
		to_chat(src, "<span class='warning'>This subject is not afflicted with the pestilence.</span>")
		return FALSE

	if(get_dist(src, target) > cure_range)
		to_chat(src, "<span class='warning'>You must be closer to perform the cure.</span>")
		return FALSE

	cure_cooldown = world.time + cure_cooldown_time
	cures_attempted++

	// Enhanced cure process
	visible_message("<span class='notice'>[src] begins the great work on [target]...</span>")
	playsound(src, 'sound/scp/scp049/SCP049_Cure1.ogg', 60, 0)

	// Cure success chance based on potency
	var/success_chance = cure_effectiveness + (cure_potency * 10)
	if(prob(success_chance))
		// Successful cure
		REMOVE_TRAIT(target, TRAIT_PESTILENCE, "scp049")
		target.update_pestilence_hud()
		target.remove_atom_colour(FIXED_COLOUR_PRIORITY, "#00ff00")

		// Heal the target
		target.adjustBruteLoss(-50)
		target.adjustFireLoss(-50)
		target.adjustToxLoss(-50)

		to_chat(src, "<span class='notice'>The cure is successful! The pestilence has been cleansed.</span>")
		to_chat(target, "<span class='notice'>You feel the pestilence leaving your body... You are cured!</span>")

		playsound(src, 'sound/scp/scp049/SCP049_Cure2.ogg', 50, 0)

		cures_successful++
		cure_potency = min(max_cure_potency, cure_potency + 1)

		// Track progression event
		track_scp049_cure(src, target, TRUE)

		// Sanity restoration
		// if(SSsanity)
		// 	SSsanity.adjustSanityLoss(target, -20, "Cured by SCP-049")
	else
		// Failed cure - convert to SCP-049-1
		to_chat(src, "<span class='warning'>The cure has failed... But perhaps this subject can serve the Great Work differently.</span>")
		to_chat(target, "<span class='danger'>The 'cure' process is agony beyond description...</span>")

		// Track progression event
		track_scp049_cure(src, target, FALSE)

		// Create SCP-049-1 instance
		create_scp049_1(target)

	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp049/proc/create_scp049_1(mob/living/carbon/human/target)
	// Enhanced SCP-049-1 creation process
	target.dust(just_ash = FALSE, drop_items = TRUE, force = TRUE)

	var/mob/living/simple_animal/hostile/zombie/scp049_1/zombie = new(target.loc)
	zombie.name = "SCP-049-1"
	zombie.real_name = "SCP-049-1"
	zombie.maxHealth = target.maxHealth * 1.5
	zombie.health = zombie.maxHealth

	// Transfer some characteristics
	if(target.client)
		zombie.key = target.key
		to_chat(zombie, "<span class='danger'>You have been converted into SCP-049-1! You are now a mindless servant of SCP-049.</span>")

	visible_message("<span class='danger'>[target] has been converted into SCP-049-1!</span>")
	playsound(src, 'sound/scp/scp049/SCP049_4.ogg', 70, 0)

// Door breaching (uses component)
/mob/living/carbon/human/scp049/proc/breach_doors()
	// Trigger the door breacher component
	SEND_SIGNAL(src, COMSIG_MOB_BREACH_DOORS)

// Research mechanics
/mob/living/carbon/human/scp049/proc/research_cure()
	if(world.time < research_cooldown)
		to_chat(src, "<span class='warning'>More research time is required...</span>")
		return FALSE

	research_cooldown = world.time + research_cooldown_time
	research_progress += rand(10, 25)

	to_chat(src, "<span class='notice'>Research progress: [research_progress]/[max_research_progress]</span>")

	if(research_progress >= max_research_progress)
		trigger_evolution()

	save_persistence_data()
	return TRUE

/mob/living/carbon/human/scp049/proc/trigger_evolution()
	if(evolution_stage >= max_evolution_stage)
		to_chat(src, "<span class='notice'>You have achieved the pinnacle of the Great Work.</span>")
		return

	evolution_stage++
	evolution_events++
	research_progress = 0

	// Enhanced abilities per evolution stage
	switch(evolution_stage)
		if(2)
			pestilence_spread_radius++
			cure_effectiveness += 10
			to_chat(src, "<span class='notice'>Your understanding deepens. The pestilence spreads further.</span>")
		if(3)
			pestilence_infection_chance += 10
			cure_range++
			to_chat(src, "<span class='notice'>Your cure becomes more refined and potent.</span>")
		if(4)
			max_pestilence_level += 50
			breach_power += 25
			to_chat(src, "<span class='notice'>Your influence grows stronger. Barriers mean nothing.</span>")
		if(5)
			to_chat(src, "<span class='notice'>You have achieved perfect understanding of the Great Work.</span>")
			// Grant special end-game abilities

	research_breakthroughs++
	announce_evolution()
	save_persistence_data()

/mob/living/carbon/human/scp049/proc/announce_evolution()
	var/announcement = "SCP-049 has evolved to stage [evolution_stage]! The Great Work progresses..."
	for(var/mob/M in GLOB.player_list)
		to_chat(M, "<span class='danger'><b>[announcement]</b></span>")
	playsound(src, 'sound/scp/scp049/SCP049_5.ogg', 100, 0)

// Enhanced persistence integration
/mob/living/carbon/human/scp049/proc/save_persistence_data()
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
		"total_damage_dealt" = total_damage_dealt,
		"total_playtime" = total_playtime + (world.time - session_start_time)
	)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.save_scp_data("SCP-049", persistence_data)

/mob/living/carbon/human/scp049/proc/load_persistence_data()
	if(SSscp_persistence && SSscp_persistence.manager)
		var/list/persistence_data = SSscp_persistence.manager.load_scp_data("SCP-049")
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
			total_playtime = persistence_data["total_playtime"] || 0

// Verbs (Foundation-19 style)
/mob/living/carbon/human/scp049/verb/spread_pestilence_verb()
	set name = "Spread Pestilence"
	set category = "SCP-049"
	set desc = "Spread the pestilence to nearby targets"

	spread_pestilence()

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

/mob/living/carbon/human/scp049/verb/announce_verb()
	set name = "Make Announcement"
	set category = "SCP-049"
	set desc = "Make a characteristic announcement"

	announce_presence()

/mob/living/carbon/human/scp049/verb/show_status_verb()
	set name = "Show Status"
	set category = "SCP-049"
	set desc = "Display current SCP-049 status"

	show_status()

/mob/living/carbon/human/scp049/proc/show_status()
	var/status_text = "<b>SCP-049 Status Report:</b><br>"
	status_text += "Pestilence Level: [pestilence_level]/[max_pestilence_level]<br>"
	status_text += "Cure Potency: [cure_potency]/[max_cure_potency]<br>"
	status_text += "Evolution Stage: [evolution_stage]/[max_evolution_stage]<br>"
	status_text += "Research Progress: [research_progress]/[max_research_progress]<br>"
	status_text += "<br><b>Statistics:</b><br>"
	status_text += "Infections Performed: [infections_performed]<br>"
	status_text += "Cures Attempted: [cures_attempted] (Successful: [cures_successful])<br>"
	status_text += "Doors Breached: [doors_breached]<br>"
	status_text += "Research Breakthroughs: [research_breakthroughs]<br>"
	status_text += "Total Playtime: [round((total_playtime + (world.time - session_start_time))/600, 0.1)] minutes"

	to_chat(src, status_text)

// Visual effect for pestilence spread
/obj/effect/temp_visual/pestilence_spread
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	duration = 3 SECONDS
	color = "#00ff00"

// SCP-049-1 zombie definition
/mob/living/simple_animal/hostile/zombie/scp049_1
	name = "SCP-049-1"
	desc = "A reanimated corpse, the result of SCP-049's 'cure'. It shambles with unnatural purpose."
	icon_state = "zombie"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 25
	move_to_delay = 3
	faction = list("scp049")

/mob/living/simple_animal/hostile/zombie/scp049_1/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_PESTILENCE_IMMUNE, "scp049_1")


// Progression Integration Hooks
/mob/living/carbon/human/scp049/proc/on_cure_attempt(mob/living/carbon/human/target, success)
	if(!target || !target.ckey)
		return
	
	var/list/data = list("success" = success)
	hook_scp_interaction(target, "SCP-049", INTERACTION_TYPE_MEDICAL, data)
	
	if(success)
		hook_scp_care(target, "SCP-049", "cure")
	else
		hook_scp_combat(target, "SCP-049", 50, 0)

/mob/living/carbon/human/scp049/proc/on_pestilence_spread(mob/living/carbon/human/target)
	if(!target || !target.ckey)
		return
	
	hook_scp_combat(target, "SCP-049", pestilence_damage, 0)
	start_scp_survival_tracking(target, "SCP-049", INTERACTION_RISK_HIGH)

/mob/living/carbon/human/scp049/proc/on_evolution()
	if(SSscp_specializations && SSscp_specializations.manager && src.ckey)
		SSscp_specializations.manager.add_specialization_xp(src.ckey, SPEC_TRACK_RESEARCH, 100)
