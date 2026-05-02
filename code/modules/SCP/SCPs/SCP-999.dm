// SCP-999 - The Tickle Monster
// A large, amorphous, gelatinous mass of translucent orange slime that heals and improves mood

/mob/living/carbon/scp/scp999
	name = "SCP-999"
	desc = "A large, amorphous, gelatinous mass of translucent orange slime. It appears to be friendly and seeks physical contact."
	icon = 'icons/scp/scp-999.dmi'
	icon_state = "scp999"
	real_name = "SCP-999"
	use_custom_sprite = TRUE

	// Maximum Enhanced SCP-999 variables
	var/healing_power = 25
	var/mood_boost = 50
	var/healing_cooldown = 0
	var/healing_cooldown_time = 15 SECONDS
	var/list/healed_targets = list()
	var/list/mood_improved_targets = list()
	var/happiness_level = 0
	var/max_happiness = 100
	var/comfort_radius = 3
	var/healing_mastery = 0
	var/max_healing_mastery = 100
	var/emotional_manipulation = 0
	var/max_emotional_manipulation = 100
	var/comfort_mastery = 0
	var/max_comfort_mastery = 100
	var/happiness_evolution = 1
	var/max_happiness_evolution = 5
	var/healing_efficiency = 1.0
	var/max_healing_efficiency = 3.0
	var/comfort_radius_expansion = 0
	var/max_comfort_radius_expansion = 5
	var/emotional_resonance = 0
	var/max_emotional_resonance = 100
	var/healing_cooldown_reduction = 0
	var/max_cooldown_reduction = 50
	var/healing_cooldown_enhancement = 0
	var/healing_cooldown_enhancement_time = 20 SECONDS
	var/emotional_manipulation_cooldown = 0
	var/emotional_manipulation_cooldown_time = 30 SECONDS
	var/comfort_mastery_cooldown = 0
	var/comfort_mastery_cooldown_time = 25 SECONDS

	// Persistence tracking
	var/healing_sessions = 0
	var/mood_improvements = 0
	var/comfort_provided = 0
	var/healing_masteries = 0
	var/emotional_manipulations = 0
	var/comfort_masteries = 0
	var/happiness_evolutions = 0
	var/efficiency_improvements = 0

/mob/living/carbon/scp/scp999/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-999",
		SCP_SAFE,
		"999",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 15
	SCP_datum.min_time = 20 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 150
	scp_health = max_scp_health
	max_scp_armor = 25
	scp_armor = max_scp_armor

	// Add maximum enhanced abilities
	add_ability("heal_nearby", "heal_nearby_ability")
	add_ability("comfort_zone", "comfort_zone_ability")
	add_ability("view_healing_stats", "view_healing_stats_ability")
	add_ability("healing_mastery", "healing_mastery_ability")
	add_ability("emotional_manipulation", "emotional_manipulation_ability")
	add_ability("comfort_mastery", "comfort_mastery_ability")
	add_ability("evolve_happiness", "evolve_happiness_ability")
	add_ability("healing_efficiency", "healing_efficiency_ability")
	add_ability("comfort_radius_expansion", "comfort_radius_expansion_ability")
	add_ability("emotional_resonance", "emotional_resonance_ability")
	add_ability("ultimate_healing", "ultimate_healing_ability")
	add_ability("happiness_synthesis", "happiness_synthesis_ability")

	// Add passive effects
	add_passive_effect("healing_aura")
	add_passive_effect("mood_improvement")
	add_passive_effect("comfort_radiance")
	add_passive_effect("healing_mastery")
	add_passive_effect("emotional_manipulation")
	add_passive_effect("comfort_mastery")
	add_passive_effect("happiness_evolution")
	add_passive_effect("healing_efficiency")
	add_passive_effect("emotional_resonance")

	// Initialize SCP-999 specific skills with balanced cooldowns and requirements
	initialize_skill("heal_nearby", 60 SECONDS, list("base_cooldown" = 60 SECONDS, "requires_proximity" = TRUE))
	initialize_skill("comfort_zone", 90 SECONDS, list("base_cooldown" = 90 SECONDS))
	initialize_skill("view_healing_stats", 30 SECONDS, list("base_cooldown" = 30 SECONDS))
	initialize_skill("healing_mastery", 120 SECONDS, list("base_cooldown" = 120 SECONDS, "requires_level_15" = TRUE))
	initialize_skill("emotional_manipulation", 150 SECONDS, list("base_cooldown" = 150 SECONDS, "requires_level_20" = TRUE))
	initialize_skill("comfort_mastery", 180 SECONDS, list("base_cooldown" = 180 SECONDS, "requires_level_25" = TRUE))
	initialize_skill("evolve_happiness", 300 SECONDS, list("base_cooldown" = 300 SECONDS, "requires_level_30" = TRUE))
	initialize_skill("healing_efficiency", 120 SECONDS, list("base_cooldown" = 120 SECONDS, "requires_level_35" = TRUE))
	initialize_skill("comfort_radius_expansion", 240 SECONDS, list("base_cooldown" = 240 SECONDS, "requires_level_40" = TRUE))
	initialize_skill("emotional_resonance", 200 SECONDS, list("base_cooldown" = 200 SECONDS, "requires_level_45" = TRUE))
	initialize_skill("ultimate_healing", 360 SECONDS, list("base_cooldown" = 360 SECONDS, "requires_level_50" = TRUE))
	initialize_skill("happiness_synthesis", 420 SECONDS, list("base_cooldown" = 420 SECONDS, "requires_level_60" = TRUE))

/mob/living/carbon/scp/scp999/Destroy()
	healed_targets = list()
	mood_improved_targets = list()
	return ..()

// Override requirement checking for SCP-999 specific requirements
/mob/living/carbon/scp/scp999/check_skill_requirement(requirement, current_level)
	switch(requirement)
		if("requires_proximity")
			// Check if there are targets nearby
			for(var/mob/living/carbon/human/H in view(3, src))
				if(H != src && !H.SCP)
					return TRUE
			return FALSE
		else
			return ..()

// Override core mechanics
/mob/living/carbon/scp/scp999/process_scp_effects()
	. = ..()

	// Provide comfort to nearby beings
	provide_comfort()

	// Seek out injured or distressed targets
	var/mob/living/carbon/human/target = find_target()
	if(target)
		approach_target(target)

	// Update happiness based on interactions
	update_happiness()

	// Process healing mastery
	process_healing_mastery()

	// Process emotional manipulation
	process_emotional_manipulation()

	// Process comfort mastery
	process_comfort_mastery()

	// Process happiness evolution
	process_happiness_evolution()

	// Process emotional resonance
	process_emotional_resonance()

	// Award research points to nearby researchers
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP) // Skip SCPs
			continue

		// Award research points for observing SCP-999
		award_research_points("999", "behavior", 2, H.ckey)

// Enhanced comfort provision
/mob/living/carbon/scp/scp999/proc/provide_comfort()
	for(var/mob/living/carbon/human/H in range(comfort_radius + comfort_radius_expansion, src))
		if(H == src || H.SCP)
			continue

		// Provide enhanced passive healing and mood improvement
		var/heal_amount = 5 * healing_efficiency * (1 + (healing_mastery / 100))
		if(H.health < H.maxHealth)
			H.adjustBruteLoss(-heal_amount)
			H.adjustFireLoss(-heal_amount)
			H.adjustToxLoss(-heal_amount)

		// Improve mood with emotional manipulation
		if(!(H in mood_improved_targets))
			mood_improved_targets += H
			mood_improvements++
			comfort_provided++

			to_chat(H, "<span class='notice'>You feel a sense of calm and happiness from [src]'s presence.</span>")

// Process healing mastery
/mob/living/carbon/scp/scp999/proc/process_healing_mastery()
	if(healing_sessions > 0 && healing_mastery < max_healing_mastery)
		if(prob(2))
			healing_mastery = min(max_healing_mastery, healing_mastery + 1)

// Process emotional manipulation
/mob/living/carbon/scp/scp999/proc/process_emotional_manipulation()
	if(emotional_manipulation > 0 && prob(1))
		// Create emotional effects
		for(var/mob/living/carbon/human/H in range(comfort_radius + comfort_radius_expansion, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='notice'>You feel overwhelming joy and contentment...</span>")

// Process comfort mastery
/mob/living/carbon/scp/scp999/proc/process_comfort_mastery()
	if(comfort_provided > 0 && comfort_mastery < max_comfort_mastery)
		if(prob(1))
			comfort_mastery = min(max_comfort_mastery, comfort_mastery + 1)

// Process happiness evolution
/mob/living/carbon/scp/scp999/proc/process_happiness_evolution()
	if(happiness_level >= max_happiness && happiness_evolution < max_happiness_evolution)
		if(prob(1))
			evolve_happiness_stage()

// Evolve happiness stage
/mob/living/carbon/scp/scp999/proc/evolve_happiness_stage()
	happiness_evolution = min(max_happiness_evolution, happiness_evolution + 1)
	happiness_evolutions++

	var/evolution_message = ""
	switch(happiness_evolution)
		if(2)
			evolution_message = "Your happiness has evolved to include emotional healing!"
		if(3)
			evolution_message = "You can now manipulate emotions more effectively!"
		if(4)
			evolution_message = "Your happiness can now create reality-warping joy!"
		if(5)
			evolution_message = "You have achieved ultimate happiness evolution!"

	to_chat(src, "<span class='notice'>[evolution_message] Happiness Evolution: [happiness_evolution]/[max_happiness_evolution]</span>")

// Process emotional resonance
/mob/living/carbon/scp/scp999/proc/process_emotional_resonance()
	if(emotional_resonance > 0 && prob(1))
		// Create emotional resonance effects
		for(var/mob/living/carbon/human/H in range(comfort_radius + comfort_radius_expansion, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='notice'>You feel a deep emotional connection with SCP-999...</span>")

// Enhanced target finding
/mob/living/carbon/scp/scp999/proc/find_target()
	var/mob/living/carbon/human/closest = null
	var/shortest_distance = 999

	for(var/mob/living/carbon/human/H in view(10, src))
		if(H == src || H.SCP)
			continue

		// Prioritize injured or distressed targets
		if(H.health < H.maxHealth * 0.8)
			var/distance = get_dist(src, H)
			if(distance < shortest_distance)
				shortest_distance = distance
				closest = H

	return closest

// Enhanced target approach
/mob/living/carbon/scp/scp999/proc/approach_target(mob/living/carbon/human/target)
	if(!target)
		return

	// Move towards target
	step_towards(src, target)

	// Heal target if close enough
	if(get_dist(src, target) <= 1)
		heal_target(target)

// Enhanced target healing
/mob/living/carbon/scp/scp999/proc/heal_target(mob/living/carbon/human/target)
	if(!target || world.time < healing_cooldown)
		return

	healing_cooldown = world.time + healing_cooldown_time
	var/heal_amount = healing_power * healing_efficiency * (1 + (healing_mastery / 100))

	visible_message("<span class='notice'>[src] gently heals [target]!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 30, TRUE)

	target.adjustBruteLoss(-heal_amount)
	target.adjustFireLoss(-heal_amount)
	target.adjustToxLoss(-heal_amount)

	if(!(target in healed_targets))
		healed_targets += target
		healing_sessions++

	to_chat(target, "<span class='notice'>You feel completely healed and rejuvenated!</span>")

	// Progression integration
	if(target && target.ckey)
		hook_scp_care(target, "SCP-999", "healing")
		hook_scp_interaction(target, "SCP-999", INTERACTION_TYPE_CARE, list("heal_amount" = heal_amount))

	// Award research points to nearby researchers for observing healing
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && H != target && !H.SCP)
			award_research_points("999", "healing", 12, H.ckey)

	add_interaction_record(target, "healing")

// Enhanced happiness update
/mob/living/carbon/scp/scp999/proc/update_happiness()
	// Increase happiness based on healing and comfort provided
	if(healing_sessions > 0 || comfort_provided > 0)
		happiness_level = min(max_happiness, happiness_level + 1)

	// Happiness affects healing power
	healing_power = 25 + (happiness_level / 4)

// Enhanced attack behavior (friendly)
/mob/living/carbon/scp/scp999/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A

		// SCP-999 doesn't harm, only heals
		heal_target(H)
		return

	return ..()

// Maximum enhanced abilities
/mob/living/carbon/scp/scp999/proc/heal_nearby_ability()
	if(!use_skill("heal_nearby", 2, 1.0))
		return

	// Proximity requirement is now handled by the skill system
	to_chat(src, "<span class='notice'>You heal nearby targets. Healed: [healed_targets.len]</span>")

	// Heal all nearby targets
	for(var/mob/living/carbon/human/H in range(comfort_radius + comfort_radius_expansion, src))
		if(H != src && !H.SCP)
			heal_target(H)

/mob/living/carbon/scp/scp999/proc/comfort_zone_ability()
	if(!use_skill("comfort_zone", 3, 1.0))
		return

	to_chat(src, "<span class='notice'>You create a comfort zone. Comfort provided: [comfort_provided]</span>")

	// Create enhanced comfort zone
	for(var/mob/living/carbon/human/H in range(comfort_radius + comfort_radius_expansion, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='notice'>You feel overwhelming comfort and peace...</span>")
			H.adjustBruteLoss(-10)
			H.adjustFireLoss(-10)
			H.adjustToxLoss(-10)

/mob/living/carbon/scp/scp999/proc/view_healing_stats_ability()
	if(!use_skill("view_healing_stats", 1, 1.0))
		return

	var/message = "<h2>SCP-999 Healing Statistics</h2>"
	message += "<b>Healing Power:</b> [healing_power]<br>"
	message += "<b>Mood Boost:</b> [mood_boost]<br>"
	message += "<b>Happiness Level:</b> [happiness_level]/[max_happiness]<br>"
	message += "<b>Healing Mastery:</b> [healing_mastery]/[max_healing_mastery]<br>"
	message += "<b>Emotional Manipulation:</b> [emotional_manipulation]/[max_emotional_manipulation]<br>"
	message += "<b>Comfort Mastery:</b> [comfort_mastery]/[max_comfort_mastery]<br>"
	message += "<b>Happiness Evolution:</b> [happiness_evolution]/[max_happiness_evolution]<br>"
	message += "<b>Healing Efficiency:</b> [healing_efficiency]/[max_healing_efficiency]<br>"
	message += "<b>Comfort Radius:</b> [comfort_radius + comfort_radius_expansion]<br>"
	message += "<b>Emotional Resonance:</b> [emotional_resonance]/[max_emotional_resonance]<br>"
	message += "<b>Healed Targets:</b> [healed_targets.len]<br>"
	message += "<b>Mood Improvements:</b> [mood_improved_targets.len]<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/living/carbon/scp/scp999/proc/healing_mastery_ability()
	if(!use_skill("healing_mastery", 4, 1.0))
		return

	// Level requirement is now handled by the skill system
	healing_mastery = min(max_healing_mastery, healing_mastery + 10)
	healing_masteries++

	to_chat(src, "<span class='notice'>Your healing mastery is enhanced. Mastery: [healing_mastery]/[max_healing_mastery]</span>")

/mob/living/carbon/scp/scp999/proc/emotional_manipulation_ability()
	if(!use_skill("emotional_manipulation", 5, 1.0))
		return

	// Cooldown is now handled by the skill system
	emotional_manipulation = min(max_emotional_manipulation, emotional_manipulation + 20)
	emotional_manipulations++

	to_chat(src, "<span class='notice'>You begin emotional manipulation. Manipulation: [emotional_manipulation]/[max_emotional_manipulation]</span>")

/mob/living/carbon/scp/scp999/proc/comfort_mastery_ability()
	if(!use_skill("comfort_mastery", 4, 1.0))
		return

	// Cooldown is now handled by the skill system
	comfort_mastery = min(max_comfort_mastery, comfort_mastery + 10)
	comfort_masteries++

	to_chat(src, "<span class='notice'>Your comfort mastery is enhanced. Mastery: [comfort_mastery]/[max_comfort_mastery]</span>")

/mob/living/carbon/scp/scp999/proc/evolve_happiness_ability()
	if(!use_skill("evolve_happiness", 6, 1.0))
		return

	// Level and happiness requirements are now handled by the skill system
	evolve_happiness_stage()

/mob/living/carbon/scp/scp999/proc/healing_efficiency_ability()
	if(healing_efficiency >= max_healing_efficiency)
		to_chat(src, "<span class='warning'>You have reached maximum healing efficiency.</span>")
		return

	healing_efficiency = min(max_healing_efficiency, healing_efficiency + 0.2)
	efficiency_improvements++

	to_chat(src, "<span class='notice'>Your healing efficiency is improved. Efficiency: [healing_efficiency]/[max_healing_efficiency]</span>")

/mob/living/carbon/scp/scp999/proc/comfort_radius_expansion_ability()
	if(comfort_radius_expansion >= max_comfort_radius_expansion)
		to_chat(src, "<span class='warning'>You have reached maximum comfort radius expansion.</span>")
		return

	comfort_radius_expansion = min(max_comfort_radius_expansion, comfort_radius_expansion + 1)

	to_chat(src, "<span class='notice'>Your comfort radius is expanded. Radius: [comfort_radius + comfort_radius_expansion]</span>")

/mob/living/carbon/scp/scp999/proc/emotional_resonance_ability()
	emotional_resonance = min(max_emotional_resonance, emotional_resonance + 20)

	to_chat(src, "<span class='notice'>You create emotional resonance. Resonance: [emotional_resonance]/[max_emotional_resonance]</span>")

/mob/living/carbon/scp/scp999/proc/ultimate_healing_ability()
	if(healing_mastery < max_healing_mastery)
		to_chat(src, "<span class='warning'>You need maximum healing mastery for ultimate healing.</span>")
		return

	// Ultimate healing affects all nearby targets
	for(var/mob/living/carbon/human/H in range(comfort_radius + comfort_radius_expansion, src))
		if(H != src && !H.SCP)
			H.adjustBruteLoss(-100)
			H.adjustFireLoss(-100)
			H.adjustToxLoss(-100)
			to_chat(H, "<span class='notice'>You experience SCP-999's ultimate healing!</span>")

	to_chat(src, "<span class='notice'>You perform ultimate healing on all nearby targets.</span>")

/mob/living/carbon/scp/scp999/proc/happiness_synthesis_ability()
	if(happiness_level < max_happiness)
		to_chat(src, "<span class='warning'>You need more happiness to synthesize.</span>")
		return

	// Create a powerful happiness effect
	for(var/mob/living/carbon/human/H in range(comfort_radius + comfort_radius_expansion, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='notice'>You feel overwhelming joy and contentment from SCP-999's happiness synthesis!</span>")

	to_chat(src, "<span class='notice'>You synthesize happiness and spread it to all nearby targets.</span>")

// Enhanced status display
/mob/living/carbon/scp/scp999/get_status_tab_items()
	. = ..()
	. += "Healing Power: [healing_power]"
	. += "Happiness Level: [happiness_level]/[max_happiness]"
	. += "Healing Mastery: [healing_mastery]/[max_healing_mastery]"
	. += "Emotional Manipulation: [emotional_manipulation]/[max_emotional_manipulation]"
	. += "Comfort Mastery: [comfort_mastery]/[max_comfort_mastery]"
	. += "Happiness Evolution: [happiness_evolution]/[max_happiness_evolution]"
	. += "Healing Efficiency: [healing_efficiency]/[max_healing_efficiency]"
	. += "Comfort Radius: [comfort_radius + comfort_radius_expansion]"
	. += "Emotional Resonance: [emotional_resonance]/[max_emotional_resonance]"
	. += "Healed Targets: [healed_targets.len]"

// Override examine behavior
/mob/living/carbon/scp/scp999/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-999, a friendly gelatinous entity that heals and improves mood.</span>")
		else
			to_chat(user, "<span class='notice'>A friendly orange slime that seems to radiate happiness and healing energy.</span>")

// Override SCP death
/mob/living/carbon/scp/scp999/scp_death()
	visible_message("<span class='danger'>[src] appears to lose its vibrant color and stops moving!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Enhanced verbs
/mob/living/carbon/scp/scp999/verb/heal_nearby()
	set name = "Heal Nearby"
	set category = "SCP"
	set desc = "Heal all nearby targets."

	heal_nearby_ability()

/mob/living/carbon/scp/scp999/verb/comfort_zone()
	set name = "Comfort Zone"
	set category = "SCP"
	set desc = "Create a comfort zone for nearby targets."

	comfort_zone_ability()

/mob/living/carbon/scp/scp999/verb/view_healing_stats()
	set name = "View Healing Stats"
	set category = "SCP"
	set desc = "View your healing statistics."

	view_healing_stats_ability()

/mob/living/carbon/scp/scp999/verb/healing_mastery()
	set name = "Healing Mastery"
	set category = "SCP"
	set desc = "Enhance your healing mastery."

	healing_mastery_ability()

/mob/living/carbon/scp/scp999/verb/emotional_manipulation()
	set name = "Emotional Manipulation"
	set category = "SCP"
	set desc = "Begin emotional manipulation."

	emotional_manipulation_ability()

/mob/living/carbon/scp/scp999/verb/comfort_mastery()
	set name = "Comfort Mastery"
	set category = "SCP"
	set desc = "Enhance your comfort mastery."

	comfort_mastery_ability()

/mob/living/carbon/scp/scp999/verb/evolve_happiness()
	set name = "Evolve Happiness"
	set category = "SCP"
	set desc = "Evolve your happiness capabilities."

	evolve_happiness_ability()

/mob/living/carbon/scp/scp999/verb/healing_efficiency()
	set name = "Healing Efficiency"
	set category = "SCP"
	set desc = "Improve your healing efficiency."

	healing_efficiency_ability()

/mob/living/carbon/scp/scp999/verb/comfort_radius_expansion()
	set name = "Comfort Radius Expansion"
	set category = "SCP"
	set desc = "Expand your comfort radius."

	comfort_radius_expansion_ability()

/mob/living/carbon/scp/scp999/verb/emotional_resonance()
	set name = "Emotional Resonance"
	set category = "SCP"
	set desc = "Create emotional resonance."

	emotional_resonance_ability()

/mob/living/carbon/scp/scp999/verb/ultimate_healing()
	set name = "Ultimate Healing"
	set category = "SCP"
	set desc = "Perform ultimate healing on all nearby targets."

	ultimate_healing_ability()

/mob/living/carbon/scp/scp999/verb/happiness_synthesis()
	set name = "Happiness Synthesis"
	set category = "SCP"
	set desc = "Synthesize happiness and spread it to all nearby targets."

	happiness_synthesis_ability()

// Enhanced persistence data view
/mob/living/carbon/scp/scp999/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-999 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-999 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Healing Sessions:</b> [healing_sessions]<br>"
	message += "<b>Mood Improvements:</b> [mood_improvements]<br>"
	message += "<b>Comfort Provided:</b> [comfort_provided]<br>"
	message += "<b>Healing Masteries:</b> [healing_masteries]<br>"
	message += "<b>Emotional Manipulations:</b> [emotional_manipulations]<br>"
	message += "<b>Comfort Masteries:</b> [comfort_masteries]<br>"
	message += "<b>Happiness Evolutions:</b> [happiness_evolutions]<br>"
	message += "<b>Efficiency Improvements:</b> [efficiency_improvements]<br>"
	message += "<b>Healed Targets:</b> [healed_targets.len]<br>"
	message += "<b>Mood Improved Targets:</b> [mood_improved_targets.len]<br>"
	message += "<b>Healing Power:</b> [healing_power]<br>"
	message += "<b>Happiness Level:</b> [happiness_level]/[max_happiness]<br>"
	message += "<b>Healing Mastery:</b> [healing_mastery]/[max_healing_mastery]<br>"
	message += "<b>Emotional Manipulation:</b> [emotional_manipulation]/[max_emotional_manipulation]<br>"
	message += "<b>Comfort Mastery:</b> [comfort_mastery]/[max_comfort_mastery]<br>"
	message += "<b>Happiness Evolution:</b> [happiness_evolution]/[max_happiness_evolution]<br>"
	message += "<b>Healing Efficiency:</b> [healing_efficiency]/[max_healing_efficiency]<br>"
	message += "<b>Comfort Radius:</b> [comfort_radius + comfort_radius_expansion]<br>"
	message += "<b>Emotional Resonance:</b> [emotional_resonance]/[max_emotional_resonance]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")
