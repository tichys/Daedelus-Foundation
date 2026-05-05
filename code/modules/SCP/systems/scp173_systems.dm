// SCP-173 Modular Systems
// Observation, Movement, and Containment Systems

// Observation System
/datum/scp173_observation_system
	var/mob/living/carbon/human/scp173/owner
	var/is_being_observed = FALSE
	var/observation_quality = 1.0
	var/last_observation_check = 0
	var/observation_check_interval = 1 SECONDS
	var/list/observers = list()
	var/observation_threshold = SCP173_OBSERVATION_THRESHOLD

/datum/scp173_observation_system/New(mob/living/carbon/human/scp173/new_owner)
	owner = new_owner

/datum/scp173_observation_system/proc/process_observation()
	if(!owner || owner.stat == DEAD)
		return

	if(world.time >= last_observation_check + observation_check_interval)
		check_observation_status()
		last_observation_check = world.time

/datum/scp173_observation_system/proc/check_observation_status()
	var/list/current_observers = list()
	var/total_quality = 0

	// Check for observers in line of sight
	for(var/mob/living/carbon/human/H in range(7, owner))
		if(H.stat == DEAD || H == owner)
			continue

		if(can_see(H, owner))
			current_observers += H
			total_quality += get_observer_quality(H)

	// Update observation status
	observers = current_observers
	observation_quality = total_quality
	is_being_observed = (observation_quality >= observation_threshold)

/datum/scp173_observation_system/proc/can_see(mob/living/carbon/human/observer, atom/target)
	// Simple line of sight check
	var/turf/start = get_turf(observer)
	var/turf/end = get_turf(target)

	if(!start || !end)
		return FALSE

	var/list/turfs = get_line(start, end)
	for(var/turf/T in turfs)
		if(T.density)
			return FALSE

	return TRUE

/datum/scp173_observation_system/proc/get_observer_quality(mob/living/carbon/human/observer)
	var/quality = 1.0

	// Equipment modifiers
	if(observer.wear_mask)
		quality += 0.2
	if(observer.head)
		quality += 0.1

	// Health modifiers
	if(observer.health < observer.maxHealth * 0.5)
		quality *= 0.8

	// Distance modifier
	var/distance = get_dist(observer, owner)
	quality *= max(0.1, 1.0 - (distance * 0.1))

	return quality

/datum/scp173_observation_system/proc/is_being_observed()
	return is_being_observed

// Movement System
/datum/scp173_movement_system
	var/mob/living/carbon/human/scp173/owner
	var/movement_cooldown = 0
	var/movement_cooldown_time = SCP173_MOVEMENT_COOLDOWN
	var/movement_range = SCP173_MOVEMENT_RANGE
	var/last_movement = 0
	var/target_location = null

/datum/scp173_movement_system/New(mob/living/carbon/human/scp173/new_owner)
	owner = new_owner

/datum/scp173_movement_system/proc/process_movement()
	if(!owner || owner.stat == DEAD)
		return

	// Only move when not being observed
	if(owner.observation_system && owner.observation_system.is_being_observed())
		return

	// Check if we can move
	if(world.time < movement_cooldown)
		return

	// Find nearest target
	var/mob/living/carbon/human/target = find_nearest_target()
	if(target)
		move_towards_target(target)

/datum/scp173_movement_system/proc/find_nearest_target()
	var/mob/living/carbon/human/nearest = null
	var/shortest_distance = INFINITY

	for(var/mob/living/carbon/human/H in range(10, owner))
		if(H.stat == DEAD || H == owner)
			continue

		var/distance = get_dist(owner, H)
		if(distance < shortest_distance)
			shortest_distance = distance
			nearest = H

	return nearest

/datum/scp173_movement_system/proc/move_towards_target(mob/living/carbon/human/target)
	if(!target)
		return

	// Calculate direction to target
	var/direction = get_dir(owner, target)
	var/turf/target_turf = get_step(owner, direction)

	if(target_turf && !target_turf.density)
		// Move towards target
		owner.Move(target_turf)
		movement_cooldown = world.time + movement_cooldown_time
		last_movement = world.time

		// Play movement sound
		playsound(owner, 'sound/effects/ghost.ogg', 30, 0)

// Containment System
/datum/scp173_containment_system
	var/mob/living/carbon/human/scp173/owner
	var/containment_integrity = SCP173_DEFAULT_CONTAINMENT_INTEGRITY
	var/breach_threshold = SCP173_BREACH_THRESHOLD
	var/containment_area = null
	var/is_contained = TRUE
	var/breach_events = 0

/datum/scp173_containment_system/New(mob/living/carbon/human/scp173/new_owner)
	owner = new_owner

/datum/scp173_containment_system/proc/process_containment()
	if(!owner || owner.stat == DEAD)
		return

	// Check if we're in containment
	check_containment_status()

	// Reduce containment integrity when not observed
	if(owner.observation_system && !owner.observation_system.is_being_observed())
		reduce_containment_integrity(SCP173_UNOBSERVED_INTEGRITY_DECAY)

/datum/scp173_containment_system/proc/check_containment_status()
	var/area/current_area = get_area(owner)

	// Check if we're in a containment area
	if(current_area && (findtext(current_area.name, "containment") || findtext(current_area.name, "cell")))
		is_contained = TRUE
		containment_area = current_area
	else
		is_contained = FALSE
		if(containment_integrity > breach_threshold)
			breach_containment()

/datum/scp173_containment_system/proc/reduce_containment_integrity(amount)
	containment_integrity = max(0, containment_integrity - amount)

	if(containment_integrity <= breach_threshold && is_contained)
		breach_containment()

/datum/scp173_containment_system/proc/breach_containment()
	if(!is_contained)
		return

	is_contained = FALSE
	breach_events++

	// Announce breach
	owner.visible_message("<span class='danger'>[owner] breaches containment!</span>")

	// Alert nearby personnel
	for(var/mob/living/carbon/human/H in range(10, owner))
		if(H != owner)
			to_chat(H, "<span class='danger'>SCP-173 has breached containment!</span>")

	// Progression integration
	if(owner && istype(owner, /mob/living/carbon/human/scp173))
		owner.on_breach()

// Combat System
/datum/scp173_combat_system
	var/mob/living/carbon/human/scp173/owner
	var/attack_cooldown = 0
	var/attack_cooldown_time = SCP173_ATTACK_COOLDOWN
	var/attack_damage = SCP173_ATTACK_DAMAGE
	var/kills_count = 0

/datum/scp173_combat_system/New(mob/living/carbon/human/scp173/new_owner)
	owner = new_owner

/datum/scp173_combat_system/proc/process_combat()
	if(!owner || owner.stat == DEAD)
		return

	// Check for targets in melee range
	for(var/mob/living/carbon/human/H in range(1, owner))
		if(H.stat == DEAD || H == owner)
			continue

		if(world.time >= attack_cooldown)
			perform_attack(H)

/datum/scp173_combat_system/proc/perform_attack(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	attack_cooldown = world.time + attack_cooldown_time

	// Deal damage
	target.adjustBruteLoss(attack_damage)

	// Visual and audio effects
	playsound(owner, 'sound/effects/ghost2.ogg', 50, 0)
	owner.visible_message("<span class='danger'>[owner] snaps [target]'s neck!</span>")

	// Check for kill
	if(target.health <= 0)
		kills_count++
		// Progression integration
		if(owner && istype(owner, /mob/living/carbon/human/scp173))
			owner.on_kill(target)
	else
		// Still log combat interaction
		if(owner && target && target.ckey)
			hook_scp_combat(target, "SCP-173", attack_damage, 0)

	to_chat(target, "<span class='danger'>You feel a sudden, violent snap!</span>")

// Research System
/datum/scp173_research_system
	var/mob/living/carbon/human/scp173/owner
	var/list/research_data = list()

/datum/scp173_research_system/New(mob/living/carbon/human/scp173/new_owner)
	owner = new_owner

/datum/scp173_research_system/proc/process_research()
	if(!owner || owner.stat == DEAD)
		return

	// Collect research data
	var/list/current_data = list(
		"is_observed" = owner.observation_system ? owner.observation_system.is_being_observed() : FALSE,
		"observation_quality" = owner.observation_system ? owner.observation_system.observation_quality : 0,
		"containment_integrity" = owner.containment_system ? owner.containment_system.containment_integrity : 100,
		"is_contained" = owner.containment_system ? owner.containment_system.is_contained : TRUE,
		"breach_events" = owner.containment_system ? owner.containment_system.breach_events : 0,
		"kills_count" = owner.combat_system ? owner.combat_system.kills_count : 0
	)

	// Store data for research integration
	research_data = current_data

/datum/scp173_research_system/proc/contribute_research_data()
	if(!owner || !owner.SCP)
		return

	// Store research data for later integration
	// Note: Research integration will be handled by the main SCP system
