// SCP-173 - The Sculpture
// Complete Production-Ready Redesign Implementation
// Phase 1: Core Foundation - Observation System Overhaul

// ============================================================================
// CORE OBSERVATION SYSTEM DATUMS
// ============================================================================

// Observer Quality Management System
/datum/observer_quality
	var/mob/living/carbon/human/observer
	var/quality_level = 0.8  // Base effectiveness
	var/equipment_bonus = 0.0
	var/condition_penalty = 0.0
	var/coordination_bonus = 0.0
	var/training_level = 0.6  // Untrained by default
	var/fatigue_hours = 0
	var/stress_level = 0
	var/fear_level = 0
	var/equipment_type = "none"
	var/coordination_team = null

/datum/observer_quality/New(mob/living/carbon/human/new_observer)
	. = ..()
	observer = new_observer
	update_quality()

/datum/observer_quality/proc/update_quality()
	var/base_effectiveness = training_level

	// Equipment modifiers
	var/equipment_multiplier = 1.0
	switch(equipment_type)
		if("none") equipment_multiplier = 0.8
		if("standard") equipment_multiplier = 1.0
		if("protective") equipment_multiplier = 1.1
		if("night_vision") equipment_multiplier = 1.3
		if("specialized") equipment_multiplier = 1.5
		if("advanced") equipment_multiplier = 1.7

	// Condition penalties
	var/condition_multiplier = 1.0
	condition_multiplier -= (fatigue_hours * 0.05)  // -5% per hour
	condition_multiplier -= (stress_level * 0.02)   // -2% per stress point
	condition_multiplier -= (fear_level * 0.05)     // -5% per fear level
	condition_multiplier = max(0.1, condition_multiplier)  // Minimum 10%

	// Calculate final quality
	quality_level = base_effectiveness * equipment_multiplier * condition_multiplier + coordination_bonus
	quality_level = max(0.1, min(2.0, quality_level))  // Clamp between 10% and 200%

/datum/observer_quality/proc/add_fatigue(hours = 1)
	fatigue_hours += hours
	update_quality()

/datum/observer_quality/proc/set_equipment(equipment)
	equipment_type = equipment
	update_quality()

/datum/observer_quality/proc/set_training_level(level)
	training_level = level
	update_quality()

// Blink Management System
/datum/blink_manager
	var/mob/living/carbon/human/owner
	var/last_blink_time = 0
	var/blink_interval = 4 SECONDS  // Base 4 seconds
	var/blink_duration = 0.15 SECONDS
	var/next_blink_time = 0
	var/voluntary_delay = 0
	var/emergency_override = FALSE
	var/coordination_team = null

/datum/blink_manager/New(mob/living/carbon/human/new_owner)
	. = ..()
	owner = new_owner
	next_blink_time = world.time + blink_interval + rand(-10, 10)  // Add randomness

/datum/blink_manager/proc/update_blink()
	if(world.time >= next_blink_time && !emergency_override)
		perform_blink()
		schedule_next_blink()

/datum/blink_manager/proc/perform_blink()
	last_blink_time = world.time
	// Notify SCP-173 systems of blink event
	if(owner.mind)
		for(var/mob/living/carbon/scp/scp173/S in world)
			if(S.observation_system)
				S.observation_system.handle_observer_blink(owner)

/datum/blink_manager/proc/schedule_next_blink()
	var/base_interval = blink_interval

	// Fatigue modifier
	if(owner.observer_quality)
		base_interval -= (owner.observer_quality.fatigue_hours * 0.1 SECONDS)

	// Stress modifier
	base_interval -= (owner.observer_quality.stress_level * 0.2 SECONDS)

	// Random variation
	base_interval += rand(-10, 10)

	// Clamp to reasonable bounds
	base_interval = max(2 SECONDS, min(8 SECONDS, base_interval))

	next_blink_time = world.time + base_interval

/datum/blink_manager/proc/voluntary_blink()
	if(world.time >= last_blink_time + 1 SECONDS)  // Prevent spam
		perform_blink()
		schedule_next_blink()

// Observation Coverage Zone System
/datum/observation_zone
	var/turf/center
	var/zone_type = "primary"  // primary, secondary, tertiary, blind
	var/coverage_quality = 1.0
	var/list/observers = list()
	var/lighting_quality = 1.0
	var/obstruction_level = 0.0

/datum/observation_zone/New(turf/new_center, new_zone_type = "primary")
	. = ..()
	center = new_center
	zone_type = new_zone_type
	update_coverage_quality()

/datum/observation_zone/proc/update_coverage_quality()
	switch(zone_type)
		if("primary")
			coverage_quality = 1.0
		if("secondary")
			coverage_quality = 0.75
		if("tertiary")
			coverage_quality = 0.5
		if("blind")
			coverage_quality = 0.0

	// Apply environmental modifiers
	coverage_quality *= lighting_quality
	coverage_quality *= (1.0 - obstruction_level)
	coverage_quality = max(0.0, min(1.0, coverage_quality))

// ============================================================================
// MAIN OBSERVATION SYSTEM
// ============================================================================

/datum/observation_system
	var/mob/living/carbon/scp/scp173/owner
	var/list/active_observers = list()
	var/list/observation_zones = list()
	var/observation_quality = 0.0
	var/coordination_bonus = 0.0
	var/system_efficiency = 100.0
	var/last_update = 0
	var/update_interval = 1 SECONDS

/datum/observation_system/New(mob/living/carbon/scp/scp173/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/observation_system/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/observation_system/proc/update_observation()
	if(world.time >= last_update + update_interval)
		update_observation_coverage()
		last_update = world.time


/datum/observation_system/proc/update_observation_coverage()
	// Clear old data
	active_observers.Cut()
	observation_zones.Cut()

	// Find all potential observers
	var/list/potential_observers = list()
	for(var/mob/living/carbon/human/H in view(15, owner))
		if(H.SCP || H.stat == DEAD)
			continue
		if(H.fovangle && H.can_see_cone(owner))
			potential_observers += H

	// Evaluate each observer
	for(var/mob/living/carbon/human/H in potential_observers)
		var/datum/observer_quality/quality = H.observer_quality
		if(!quality)
			quality = new /datum/observer_quality(H)
			H.observer_quality = quality

		// Update observer data
		quality.add_fatigue(0.1)  // Small fatigue increase
		active_observers[H] = quality

	// Calculate coordination bonuses
	calculate_coordination_bonuses()

	// Update observation quality
	calculate_total_observation_quality()

	// Create observation zones
	create_observation_zones()

/datum/observation_system/proc/calculate_coordination_bonuses()
	coordination_bonus = 0.0

	if(active_observers.len >= 2)
		coordination_bonus += 0.15  // +15% for 2+ observers
	if(active_observers.len >= 3)
		coordination_bonus += 0.10  // Additional +10% for 3+ observers
	if(active_observers.len >= 4)
		coordination_bonus += 0.05  // Additional +5% for 4+ observers

	// Check for trained teams
	var/trained_count = 0
	for(var/mob/living/carbon/human/H in active_observers)
		var/datum/observer_quality/quality = active_observers[H]
		if(quality.training_level >= 0.8)  // Advanced training or better
			trained_count++

	if(trained_count >= 2)
		coordination_bonus += 0.15  // +15% for trained team

/datum/observation_system/proc/calculate_total_observation_quality()
	observation_quality = 0.0

	if(active_observers.len == 0)
		observation_quality = 0.0
	else if(active_observers.len == 1)
		var/datum/observer_quality/quality = active_observers[active_observers[1]]
		observation_quality = quality.quality_level * 0.6  // Single observer penalty
	else
		// Multiple observers - average quality plus coordination bonus
		var/total_quality = 0.0
		for(var/mob/living/carbon/human/H in active_observers)
			var/datum/observer_quality/quality = active_observers[H]
			total_quality += quality.quality_level

		observation_quality = (total_quality / active_observers.len) + coordination_bonus

	observation_quality = max(0.0, min(2.0, observation_quality))

/datum/observation_system/proc/create_observation_zones()
	observation_zones.Cut()

	// Create zones around SCP-173
	for(var/turf/T in range(7, owner))
		var/distance = get_dist(owner, T)
		var/zone_type = "blind"

		if(distance <= 7)
			zone_type = "primary"
		else if(distance <= 12)
			zone_type = "secondary"
		else if(distance <= 15)
			zone_type = "tertiary"

		var/datum/observation_zone/zone = new /datum/observation_zone(T, zone_type)
		observation_zones[T] = zone

/datum/observation_system/proc/handle_observer_blink(mob/living/carbon/human/blinking_observer)
	// SCP-173 gets notified when an observer blinks
	// This creates opportunities for movement
	// SCP-173 gets notified when an observer blinks
	// This creates opportunities for movement
	// For now, just log the event

/datum/observation_system/proc/is_being_observed()
	return observation_quality > 0.3  // Threshold for "being observed"

/datum/observation_system/proc/get_observation_strength()
	return observation_quality

// ============================================================================
// ENHANCED SCP-173 MOB
// ============================================================================

/mob/living/carbon/scp/scp173
	name = "SCP-173"
	desc = "A concrete statue of a humanoid figure. It seems to be watching you intently."
	icon = 'icons/scp/scp-173.dmi'
	icon_state = "scp173"
	real_name = "SCP-173"
	use_custom_sprite = TRUE

	// Enhanced SCP-173 specific variables
	var/datum/observation_system/observation_system
	var/datum/containment_system/containment_system
	var/datum/breach_system/breach_system
	var/datum/scp173_research_integration/research_integration

	// Movement and combat
	var/move_cooldown = 0
	var/move_cooldown_time = 2 SECONDS
	var/stealth_mode = FALSE
	var/aggressive_mode = FALSE
	var/mob/living/carbon/human/current_target = null

	// Skill system
	var/experience_points = 0
	var/level = 1
	var/skill_points = 0
	var/list/skills = list()

	// Containment tracking
	var/containment_area = null
	var/kills_count = 0


/mob/living/carbon/scp/scp173/Initialize()
	. = ..()

	// Initialize core systems
	observation_system = new /datum/observation_system(src)
	containment_system = new /datum/containment_system(src)
	breach_system = new /datum/breach_system(src)
	research_integration = new /datum/scp173_research_integration(src)

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-173",
		SCP_KETER,
		"173",
		SCP_PLAYABLE
	)

	// Enable vision cone for SCP-173
	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()

	SCP_datum.min_playercount = 20
	SCP_datum.min_time = 30 MINUTES

	containment_area = get_area(src)

	// Set up SCP-specific properties
	max_scp_health = 300
	scp_health = max_scp_health
	max_scp_armor = 100
	scp_armor = max_scp_armor

	// Initialize skill system
	initialize_skill_system()

	// Start processing
	START_PROCESSING(SSobj, src)

/mob/living/carbon/scp/scp173/Destroy()
	QDEL_NULL(observation_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(breach_system)
	QDEL_NULL(research_integration)
	containment_area = null
	return ..()

/mob/living/carbon/scp/scp173/process()
	. = ..()

	// Update all systems
	observation_system?.update_observation()
	containment_system?.process()
	breach_system?.process()
	research_integration?.process()

	// Handle movement and targeting
	process_movement_and_targeting()

/mob/living/carbon/scp/scp173/proc/process_movement_and_targeting()
	// Check containment status first
	update_containment_status()

	// Only process if not being observed or in stealth mode
	if(observation_system.is_being_observed() && !stealth_mode)
		return

	// Find targets
	if(!current_target || get_dist(src, current_target) > 10 || current_target.stat == DEAD)
		current_target = find_best_target()

	// Move towards target if available
	if(current_target && world.time >= move_cooldown)
		move_towards_target()

/mob/living/carbon/scp/scp173/proc/find_best_target()
	var/mob/living/carbon/human/best_target = null
	var/best_score = -999

	for(var/mob/living/carbon/human/H in view(10, src))
		if(H.SCP || H.stat == DEAD)
			continue

		var/score = calculate_target_score(H)

		// Bonus for targets in containment areas during breach
		if(breach_system && breach_system.breach_phase != "none")
			if(get_area(H) == containment_area)
				score += 50  // Prioritize containment personnel during breach

		if(score > best_score)
			best_score = score
			best_target = H

	return best_target

/mob/living/carbon/scp/scp173/proc/calculate_target_score(mob/living/carbon/human/target)
	var/score = 0

	// Distance factor (closer is better)
	var/distance = get_dist(src, target)
	score -= distance * 10

	// Isolation factor (alone targets are better)
	var/nearby_allies = 0
	for(var/mob/living/carbon/human/H in view(3, target))
		if(H != target && !H.SCP && H.stat != DEAD)
			nearby_allies++
	score -= nearby_allies * 20

	// Vulnerability factor
	if(target.observer_quality && target.observer_quality.fatigue_hours > 2)
		score += 30  // Tired observers are easier targets

	if(target.observer_quality && target.observer_quality.stress_level > 5)
		score += 25  // Stressed observers are easier targets

	// Equipment factor
	if(target.observer_quality && target.observer_quality.equipment_type == "none")
		score += 15  // Unprotected targets are easier

	return score

/mob/living/carbon/scp/scp173/proc/move_towards_target()
	if(!current_target)
		return

	move_cooldown = world.time + move_cooldown_time

	// Calculate movement speed
	var/movement_speed = 1
	if(stealth_mode)
		movement_speed = 0.5
	else if(aggressive_mode)
		movement_speed = 2.0
	else
		movement_speed = 1.0

	// Move towards target
	step_towards(src, current_target)

	// Check if we can attack
	if(get_dist(src, current_target) <= 1)
		attempt_attack(current_target)

/mob/living/carbon/scp/scp173/proc/attempt_attack(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	// Perform neck snap attack
	visible_message("<span class='danger'>[src] snaps [target]'s neck!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	// Apply damage
	target.adjustBruteLoss(100)
	target.stamina.adjust(-100)

	// Add experience
	add_experience(25)

	// Track kill
	if(target.stat == DEAD)
		kills_count++
		// Track kill (interaction record removed)

		// Reduce containment integrity when personnel are killed
		if(containment_system)
			containment_system.reduce_containment_integrity(5)

	// Apply sanity effects if target has sanity system
	if(target.sanity)
		target.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 30)
		target.sanity.adjust_sanity(-20)

// ============================================================================
// SKILL SYSTEM IMPLEMENTATION
// ============================================================================

/mob/living/carbon/scp/scp173/proc/initialize_skill_system()
	skills = list()

	// Initialize skill categories
	skills["movement"] = 0
	skills["combat"] = 0
	skills["containment"] = 0

	// Give initial skill points
	skill_points = 3

/mob/living/carbon/scp/scp173/proc/add_experience(amount)
	experience_points += amount

	// Check for level up
	var/required_xp = level * 100
	if(experience_points >= required_xp)
		level_up()

/mob/living/carbon/scp/scp173/proc/level_up()
	level++
	skill_points++
	experience_points = 0

	to_chat(src, "<span class='notice'>You have reached level [level]! You gained a skill point.</span>")

	// Apply level-based bonuses
	apply_level_effects()

/mob/living/carbon/scp/scp173/proc/apply_level_effects()
	// Movement speed bonus
	var/speed_bonus = (level - 1) * 0.05  // 5% per level
	move_cooldown_time = max(0.5 SECONDS, 2 SECONDS - (speed_bonus * 2 SECONDS))

	// Health bonus
	var/health_bonus = (level - 1) * 10
	max_scp_health = 300 + health_bonus
	scp_health = min(scp_health, max_scp_health)

// ============================================================================
// VERB COMMANDS
// ============================================================================



// ============================================================================
// STATUS DISPLAY OVERRIDES
// ============================================================================

/mob/living/carbon/scp/scp173/get_status_tab_items()
	. = ..()
	. += "Level: [level]"
	. += "Experience: [experience_points]/[level * 100]"
	. += "Skill Points: [skill_points]"
	. += "Kills: [kills_count]"
	. += "Breaches: [breach_count]"
	. += "Stealth Mode: [stealth_mode ? "ON" : "OFF"]"
	. += "Aggressive Mode: [aggressive_mode ? "ON" : "OFF"]"

	if(observation_system)
		. += "Observed: [observation_system.is_being_observed() ? "YES" : "NO"]"
		. += "Observers: [observation_system.active_observers.len]"

/mob/living/carbon/scp/scp173/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-173, a concrete statue that moves when not observed. Current level: [level]</span>")
		else
			to_chat(user, "<span class='danger'>A concrete statue. It seems to be watching you intently. You feel an overwhelming sense of dread.</span>")

			// Apply fear effect to non-SCP humans
			if(H.sanity)
				H.sanity.adjust_sanity(-1)
				H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 5)

// ============================================================================
// LEGACY COMPATIBILITY
// ============================================================================

// Maintain compatibility with existing systems
/mob/living/carbon/scp/scp173/process_scp_effects()
	. = ..()
	// Legacy processing handled by new systems

/mob/living/carbon/scp/scp173/check_containment()
	containment_system?.check_containment()

/mob/living/carbon/scp/scp173/check_specific_containment()
	containment_system?.check_specific_containment()

// ============================================================================
// PHASE 2: CONTAINMENT FRAMEWORK IMPLEMENTATION
// ============================================================================

// Enhanced containment checking with multi-layer system
/mob/living/carbon/scp/scp173/proc/update_containment_status()
	if(!containment_system)
		return

	var/total_integrity = containment_system.calculate_total_integrity()
	var/state = containment_system.containment_state

	// Update status display
	containment_status = state

	// Check for breach conditions
	if(state == "breached" || state == "failing")
		if(breach_system && breach_system.breach_phase == "none")
			breach_system.trigger_breach_sequence()



// ============================================================================
// VERB COMMANDS FOR CONTAINMENT MANAGEMENT
// ============================================================================



// ============================================================================
// ENHANCED STATUS DISPLAY
// ============================================================================

/mob/living/carbon/scp/scp173/get_status_tab_items()
	. = ..()
	. += "Level: [level]"
	. += "Experience: [experience_points]/[level * 100]"
	. += "Skill Points: [skill_points]"
	. += "Kills: [kills_count]"
	. += "Breaches: [breach_count]"
	. += "Stealth Mode: [stealth_mode ? "ON" : "OFF"]"
	. += "Aggressive Mode: [aggressive_mode ? "ON" : "OFF"]"

	if(observation_system)
		. += "Observed: [observation_system.is_being_observed() ? "YES" : "NO"]"
		. += "Observers: [observation_system.active_observers.len]"

	if(containment_system)
		. += "Containment: [containment_system.containment_state]"
		. += "Integrity: [round(containment_system.calculate_total_integrity())]%"

	if(breach_system)
		. += "Breach Phase: [breach_system.breach_phase]"
		. += "Threat Level: [breach_system.threat_level]"

	if(research_integration)
		var/list/research_status = research_integration.get_research_status()
		. += "Research Projects: [research_status["active_projects"]]"
		. += "Behavioral Knowledge: [research_status["behavioral_knowledge"]]"

// ============================================================================
// END OF PHASE 2 IMPLEMENTATION
// ============================================================================
