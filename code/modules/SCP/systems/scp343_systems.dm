// ============================================================================
// SCP-343 CORE SYSTEMS
// Divine Intervention and Reality Manipulation System
// ============================================================================

// Divine Power System - Manages SCP-343's divine energy and authority
/datum/scp343_divine_power
	var/mob/living/carbon/human/scp343/owner = null

	// Core divine resources
	var/divine_energy = 100
	var/max_divine_energy = 100
	var/divine_authority = 1
	var/max_divine_authority = 5

	// Energy management
	var/energy_regeneration_rate = 1
	var/energy_regeneration_interval = 30 // seconds
	var/last_energy_regeneration = 0

	// Authority scaling
	var/authority_gain_rate = 0.1
	var/authority_gain_interval = 60 // seconds
	var/last_authority_gain = 0

	// Protection aura
	var/protection_aura_active = FALSE
	var/protection_aura_range = 3
	var/protection_aura_cost = 1
	var/protection_aura_interval = 10 // seconds
	var/last_protection_aura = 0

	// Reality manipulation
	var/reality_manipulation_cost = 20
	var/reality_manipulation_cooldown = 60 // seconds
	var/last_reality_manipulation = 0

/datum/scp343_divine_power/New(mob/living/carbon/human/scp343/new_owner)
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/scp343_divine_power/Destroy()
	STOP_PROCESSING(SSobj, src)
	owner = null
	return ..()

/datum/scp343_divine_power/process()
	// Energy regeneration
	if(world.time >= last_energy_regeneration + (energy_regeneration_interval * 10))
		regenerate_energy()
		last_energy_regeneration = world.time

	// Authority gain
	if(world.time >= last_authority_gain + (authority_gain_interval * 10))
		gain_authority()
		last_authority_gain = world.time

	// Protection aura management
	if(protection_aura_active && world.time >= last_protection_aura + (protection_aura_interval * 10))
		maintain_protection_aura()
		last_protection_aura = world.time

/datum/scp343_divine_power/proc/regenerate_energy()
	var/regeneration_amount = energy_regeneration_rate

	// Enhanced regeneration in divine zones
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.environmental_system && scp343_owner.environmental_system.is_in_divine_zone(owner))
			regeneration_amount *= 2

	// Faster regeneration when protecting humans
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.intervention_system && scp343_owner.intervention_system.recent_protections > 0)
			regeneration_amount *= 1.5

	// Slower regeneration during containment response
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.containment_system && scp343_owner.containment_system.containment_level >= 3)
			regeneration_amount *= 0.5

	divine_energy = min(max_divine_energy, divine_energy + regeneration_amount)

/datum/scp343_divine_power/proc/gain_authority()
	if(divine_authority >= max_divine_authority)
		return

	divine_authority = min(max_divine_authority, divine_authority + authority_gain_rate)

	// Update protection aura range
	protection_aura_range = 3 + (divine_authority - 1) * 2

/datum/scp343_divine_power/proc/maintain_protection_aura()
	if(divine_energy < protection_aura_cost)
		protection_aura_active = FALSE
		return

	consume_energy(protection_aura_cost)

	// Apply protection to nearby humans
	for(var/mob/living/carbon/human/H in range(protection_aura_range, owner))
		if(H != owner && H.stat != DEAD)
			apply_protection_to_human(H)

/datum/scp343_divine_power/proc/apply_protection_to_human(mob/living/carbon/human/H)
	// Reduce incoming damage
	if(H.physiology)
		H.physiology.brute_mod = max(0.5, H.physiology.brute_mod - 0.1)
		H.physiology.burn_mod = max(0.5, H.physiology.burn_mod - 0.1)
		H.physiology.tox_mod = max(0.5, H.physiology.tox_mod - 0.1)

	// Prevent negative status effects
	if(H.sanity && H.sanity.sanity_level < 50)
		H.sanity.adjust_sanity(5)

	// Accelerate natural recovery
	if(H.health < H.maxHealth)
		H.adjustBruteLoss(-2)
		H.adjustFireLoss(-2)
		H.adjustToxLoss(-2)

/datum/scp343_divine_power/proc/consume_energy(amount)
	divine_energy = max(0, divine_energy - amount)

/datum/scp343_divine_power/proc/has_energy(amount)
	return divine_energy >= amount

/datum/scp343_divine_power/proc/get_energy_percentage()
	return (divine_energy / max_divine_energy) * 100

// Intervention System - Manages automatic threat detection and response
/datum/scp343_intervention
	var/mob/living/carbon/human/scp343/owner = null

	// Threat detection
	var/threat_detection_range = 5
	var/threat_detection_interval = 5 // seconds
	var/last_threat_detection = 0

	// Intervention tracking
	var/recent_protections = 0
	var/recent_healings = 0
	var/recent_guidance = 0
	var/recent_reality_manipulations = 0

	// Cooldowns
	var/protection_cooldown = 10 // seconds
	var/healing_cooldown = 30 // seconds
	var/guidance_cooldown = 20 // seconds
	var/reality_cooldown = 60 // seconds

	var/last_protection = 0
	var/last_healing = 0
	var/last_guidance = 0
	var/last_reality_manipulation = 0

/datum/scp343_intervention/New(mob/living/carbon/human/scp343/new_owner)
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/scp343_intervention/Destroy()
	STOP_PROCESSING(SSobj, src)
	owner = null
	return ..()

/datum/scp343_intervention/process()
	// Threat detection
	if(world.time >= last_threat_detection + (threat_detection_interval * 10))
		detect_threats()
		last_threat_detection = world.time

/datum/scp343_intervention/proc/detect_threats()
	var/list/threats = list()

	// Detect threats to humans
	for(var/mob/living/carbon/human/H in range(threat_detection_range, owner))
		if(H == owner || H.stat == DEAD)
			continue

		// Check for immediate threats
		if(is_human_threatened(H))
			threats += H

	// Respond to threats
	for(var/mob/living/carbon/human/H in threats)
		respond_to_threat(H)

/datum/scp343_intervention/proc/is_human_threatened(mob/living/carbon/human/H)
	// Check for low health
	if(H.health < H.maxHealth * 0.3)
		return TRUE

	// Check for low sanity
	if(H.sanity && H.sanity.sanity_level < 30)
		return TRUE

	// Check for nearby hostile entities
	for(var/mob/living/L in range(2, H))
		if(L != H && L != owner && istype(L, /mob/living/simple_animal/hostile))
			return TRUE

	return FALSE

/datum/scp343_intervention/proc/respond_to_threat(mob/living/carbon/human/H)
	// Determine appropriate intervention
	if(H.health < H.maxHealth * 0.2 && can_heal())
		perform_healing_intervention(H)
	else if(is_human_threatened(H) && can_protect())
		perform_protection_intervention(H)
	else if(can_guide())
		perform_guidance_intervention(H)

/datum/scp343_intervention/proc/perform_protection_intervention(mob/living/carbon/human/H)
	if(!can_protect())
		return

	last_protection = world.time
	recent_protections++

	// Create protective barrier
	var/energy_cost = 5
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.divine_power)
			energy_cost = 5 + (scp343_owner.divine_power.divine_authority - 1) * 2
			scp343_owner.divine_power.consume_energy(energy_cost)

	// Apply protection effects
	if(H.physiology)
		H.physiology.brute_mod = max(0.3, H.physiology.brute_mod - 0.2)
		H.physiology.burn_mod = max(0.3, H.physiology.burn_mod - 0.2)
		H.physiology.tox_mod = max(0.3, H.physiology.tox_mod - 0.2)

	// Visual effect
	var/obj/effect/temp_visual/divine_protection/protection = new(H.loc)
	protection.color = "#FFD700"

	// Notify humans
	to_chat(H, "<span class='notice'>You feel a divine presence protecting you.</span>")

	// Add to persistence
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		scp343_owner.add_protection_record(H)

/datum/scp343_intervention/proc/perform_healing_intervention(mob/living/carbon/human/H)
	if(!can_heal())
		return

	last_healing = world.time
	recent_healings++

	// Calculate healing amount
	var/healing_amount = 20
	var/energy_cost = 10
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.divine_power)
			healing_amount = 20 + (scp343_owner.divine_power.divine_authority - 1) * 10
			energy_cost = 10 + (scp343_owner.divine_power.divine_authority - 1) * 5
			scp343_owner.divine_power.consume_energy(energy_cost)

	// Apply healing
	H.adjustBruteLoss(-healing_amount)
	H.adjustFireLoss(-healing_amount)
	H.adjustToxLoss(-healing_amount)

	// Restore sanity
	if(H.sanity)
		H.sanity.adjust_sanity(healing_amount / 2)

	// Visual effect
	var/obj/effect/temp_visual/divine_healing/healing = new(H.loc)
	healing.color = "#00FF00"

	// Notify humans
	to_chat(H, "<span class='notice'>You feel divine healing energy restoring you.</span>")

	// Add to persistence
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		scp343_owner.add_healing_record(H)

/datum/scp343_intervention/proc/perform_guidance_intervention(mob/living/carbon/human/H)
	if(!can_guide())
		return

	last_guidance = world.time
	recent_guidance++

	// Calculate guidance effect
	var/guidance_strength = 5
	var/energy_cost = 5
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.divine_power)
			guidance_strength = 5 + (scp343_owner.divine_power.divine_authority - 1) * 3
			energy_cost = 5 + (scp343_owner.divine_power.divine_authority - 1) * 2
			scp343_owner.divine_power.consume_energy(energy_cost)

	// Apply guidance effects
	if(H.sanity)
		H.sanity.adjust_sanity(guidance_strength)

	// Improve human abilities temporarily
	if(H.physiology)
		H.physiology.brute_mod = max(0.5, H.physiology.brute_mod - 0.1)
		H.physiology.burn_mod = max(0.5, H.physiology.burn_mod - 0.1)
		H.physiology.tox_mod = max(0.5, H.physiology.tox_mod - 0.1)

	// Visual effect
	var/obj/effect/temp_visual/divine_guidance/guidance = new(H.loc)
	guidance.color = "#87CEEB"

	// Notify humans
	to_chat(H, "<span class='notice'>You feel divine guidance guiding your actions.</span>")

	// Add to persistence
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		scp343_owner.add_guidance_record(H)

/datum/scp343_intervention/proc/perform_reality_manipulation(turf/T)
	if(!can_manipulate_reality())
		return

	last_reality_manipulation = world.time
	recent_reality_manipulations++

	// Calculate manipulation cost
	var/manipulation_cost = 20
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.divine_power)
			manipulation_cost = 20 + (scp343_owner.divine_power.divine_authority - 1) * 10
			scp343_owner.divine_power.consume_energy(manipulation_cost)

	// Create divine zone
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.environmental_system)
			scp343_owner.environmental_system.create_divine_zone(T)

	// Visual effect
	var/obj/effect/temp_visual/divine_manipulation/manipulation = new(T)
	manipulation.color = "#FF69B4"

	// Add to persistence
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		scp343_owner.add_reality_manipulation_record(T)

/datum/scp343_intervention/proc/can_protect()
	return world.time >= last_protection + (protection_cooldown * 10) && owner && istype(owner, /mob/living/carbon/human/scp343) && owner.divine_power && owner.divine_power.has_energy(5)

/datum/scp343_intervention/proc/can_heal()
	return world.time >= last_healing + (healing_cooldown * 10) && owner && istype(owner, /mob/living/carbon/human/scp343) && owner.divine_power && owner.divine_power.has_energy(10)

/datum/scp343_intervention/proc/can_guide()
	return world.time >= last_guidance + (guidance_cooldown * 10) && owner && istype(owner, /mob/living/carbon/human/scp343) && owner.divine_power && owner.divine_power.has_energy(5)

/datum/scp343_intervention/proc/can_manipulate_reality()
	return world.time >= last_reality_manipulation + (reality_cooldown * 10) && owner && istype(owner, /mob/living/carbon/human/scp343) && owner.divine_power && owner.divine_power.has_energy(20)

// Evolution System - Tracks divine evolution and progression
/datum/scp343_evolution
	var/mob/living/carbon/human/scp343/owner = null

	// Evolution tracking
	var/current_stage = 1
	var/max_stage = 5
	var/evolution_progress = 0

	// Point tracking
	var/protection_points = 0
	var/healing_points = 0
	var/guidance_points = 0
	var/authority_points = 0

	// Evolution requirements
	var/list/evolution_requirements = list(
		"stage_2" = list("protection" = 50, "healing" = 30, "guidance" = 20, "authority" = 10),
		"stage_3" = list("protection" = 150, "healing" = 100, "guidance" = 80, "authority" = 50),
		"stage_4" = list("protection" = 300, "healing" = 200, "guidance" = 150, "authority" = 100),
		"stage_5" = list("protection" = 500, "healing" = 350, "guidance" = 250, "authority" = 200)
	)

/datum/scp343_evolution/New(mob/living/carbon/human/scp343/new_owner)
	owner = new_owner

/datum/scp343_evolution/Destroy()
	owner = null
	return ..()

/datum/scp343_evolution/proc/add_protection_points(amount)
	protection_points += amount
	check_evolution()

/datum/scp343_evolution/proc/add_healing_points(amount)
	healing_points += amount
	check_evolution()

/datum/scp343_evolution/proc/add_guidance_points(amount)
	guidance_points += amount
	check_evolution()

/datum/scp343_evolution/proc/add_authority_points(amount)
	authority_points += amount
	check_evolution()

/datum/scp343_evolution/proc/check_evolution()
	if(current_stage >= max_stage)
		return

	var/next_stage = current_stage + 1
	var/requirements = evolution_requirements["stage_[next_stage]"]

	if(!requirements)
		return

	var/can_evolve = TRUE

	// Check all requirements
	if(protection_points < requirements["protection"])
		can_evolve = FALSE
	if(healing_points < requirements["healing"])
		can_evolve = FALSE
	if(guidance_points < requirements["guidance"])
		can_evolve = FALSE
	if(authority_points < requirements["authority"])
		can_evolve = FALSE

	if(can_evolve)
		evolve_to_stage(next_stage)

/datum/scp343_evolution/proc/evolve_to_stage(new_stage)
	if(new_stage <= current_stage || new_stage > max_stage)
		return

	current_stage = new_stage

	// Apply evolution benefits
	apply_evolution_benefits(new_stage)

	// Update divine power system
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.divine_power)
			scp343_owner.divine_power.max_divine_authority = min(5, scp343_owner.divine_power.max_divine_authority + 1)
			scp343_owner.divine_power.max_divine_energy += 50

	// Notify owner
	if(owner)
		to_chat(owner, "<span class='notice'>SCP-343 has evolved to stage [new_stage]!</span>")

	// Add to persistence
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		scp343_owner.add_evolution_record(new_stage)

/datum/scp343_evolution/proc/apply_evolution_benefits(stage)
	if(!owner || !istype(owner, /mob/living/carbon/human/scp343))
		return

	var/mob/living/carbon/human/scp343/scp343_owner = owner
	if(!scp343_owner.divine_power)
		return

	switch(stage)
		if(2) // Divine Guardian
			scp343_owner.divine_power.energy_regeneration_rate *= 1.5
			scp343_owner.divine_power.protection_aura_range += 2
		if(3) // Reality Shaper
			scp343_owner.divine_power.energy_regeneration_rate *= 1.5
			scp343_owner.divine_power.reality_manipulation_cost *= 0.8
		if(4) // Divine Authority
			scp343_owner.divine_power.energy_regeneration_rate *= 1.5
			scp343_owner.divine_power.protection_aura_range += 3
		if(5) // Transcendent Being
			scp343_owner.divine_power.energy_regeneration_rate *= 2
			scp343_owner.divine_power.reality_manipulation_cost *= 0.5

// Containment System - Manages facility response to divine activities
/datum/scp343_containment
	var/mob/living/carbon/human/scp343/owner = null

	// Containment tracking
	var/containment_level = 1
	var/max_containment_level = 4
	var/divine_activities = 0

	// Response thresholds
	var/list/activity_thresholds = list(50, 150, 300, 500)

	// Response cooldowns
	var/response_cooldown = 30 // seconds
	var/last_response_update = 0

/datum/scp343_containment/New(mob/living/carbon/human/scp343/new_owner)
	owner = new_owner

/datum/scp343_containment/Destroy()
	owner = null
	return ..()

/datum/scp343_containment/proc/add_activity()
	divine_activities++
	check_containment_level()

/datum/scp343_containment/proc/check_containment_level()
	var/new_level = 1

	// Determine level based on activities
	for(var/i = 1; i <= length(activity_thresholds); i++)
		if(divine_activities >= activity_thresholds[i])
			new_level = i + 1

	// Update containment level
	if(new_level != containment_level)
		update_containment_level(new_level)

/datum/scp343_containment/proc/update_containment_level(new_level)
	if(new_level == containment_level)
		return

	var/old_level = containment_level
	containment_level = new_level

	// Apply containment effects
	apply_containment_effects(new_level)

	// Notify owner
	if(new_level > old_level)
		to_chat(owner, "<span class='warning'>Facility containment response has increased to level [new_level].</span>")
	else
		to_chat(owner, "<span class='notice'>Facility containment response has decreased to level [new_level].</span>")

/datum/scp343_containment/proc/apply_containment_effects(level)
	if(!owner || !istype(owner, /mob/living/carbon/human/scp343))
		return

	var/mob/living/carbon/human/scp343/scp343_owner = owner
	if(!scp343_owner.divine_power)
		return

	switch(level)
		if(1) // Observation
			// Minimal effects
		if(2) // Enhanced Monitoring
			scp343_owner.divine_power.energy_regeneration_rate *= 0.9
		if(3) // Active Containment
			scp343_owner.divine_power.energy_regeneration_rate *= 0.7
			scp343_owner.divine_power.protection_aura_range = max(2, scp343_owner.divine_power.protection_aura_range - 1)
		if(4) // Emergency Protocols
			scp343_owner.divine_power.energy_regeneration_rate *= 0.5
			scp343_owner.divine_power.protection_aura_range = max(1, scp343_owner.divine_power.protection_aura_range - 2)

// Environmental System - Manages divine zones and environmental effects
/datum/scp343_environmental
	var/mob/living/carbon/human/scp343/owner = null

	// Zone management
	var/list/divine_zones = list()
	var/max_zones = 5
	var/zone_creation_cooldown = 120 // seconds
	var/last_zone_creation = 0

	// Zone types
	var/list/zone_types = list(
		"sanctuary" = "Complete protection and healing",
		"guidance" = "Subtle divine guidance",
		"authority" = "Strong divine influence",
		"transcendent" = "Ultimate divine power"
	)

/datum/scp343_environmental/New(mob/living/carbon/human/scp343/new_owner)
	owner = new_owner

/datum/scp343_environmental/Destroy()
	cleanup_zones()
	owner = null
	return ..()

/datum/scp343_environmental/proc/create_divine_zone(turf/T)
	if(length(divine_zones) >= max_zones)
		return

	if(world.time < last_zone_creation + (zone_creation_cooldown * 10))
		return

	last_zone_creation = world.time

	// Determine zone type based on divine authority
	var/zone_type = "guidance"
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.divine_power)
			if(scp343_owner.divine_power.divine_authority >= 4)
				zone_type = "transcendent"
			else if(scp343_owner.divine_power.divine_authority >= 3)
				zone_type = "authority"
			else if(scp343_owner.divine_power.divine_authority >= 2)
				zone_type = "sanctuary"

	// Create zone
	var/datum/divine_zone/zone = new(T, zone_type, owner)
	divine_zones += zone

	// Visual effect
	var/obj/effect/temp_visual/divine_zone/zone_effect = new(T)
	zone_effect.color = get_zone_color(zone_type)

/datum/scp343_environmental/proc/is_in_divine_zone(atom/A)
	for(var/datum/divine_zone/zone in divine_zones)
		if(zone.is_inside(A))
			return TRUE
	return FALSE

/datum/scp343_environmental/proc/get_zone_color(zone_type)
	switch(zone_type)
		if("sanctuary")
			return "#00FF00"
		if("guidance")
			return "#87CEEB"
		if("authority")
			return "#FFD700"
		if("transcendent")
			return "#FF69B4"
		else
			return "#FFFFFF"

/datum/scp343_environmental/proc/cleanup_zones()
	for(var/datum/divine_zone/zone in divine_zones)
		qdel(zone)
	divine_zones.Cut()

// Divine Zone Datum
/datum/divine_zone
	var/turf/center = null
	var/zone_type = "guidance"
	var/owner = null
	var/radius = 3
	var/duration = 300 // 5 minutes
	var/created_time = 0

/datum/divine_zone/New(turf/new_center, new_type, mob/living/carbon/human/scp343/new_owner)
	center = new_center
	zone_type = new_type
	owner = new_owner
	created_time = world.time
	START_PROCESSING(SSobj, src)

/datum/divine_zone/Destroy()
	STOP_PROCESSING(SSobj, src)
	center = null
	owner = null
	return ..()

/datum/divine_zone/process()
	// Check duration
	if(world.time >= created_time + (duration * 10))
		qdel(src)
		return

	// Apply zone effects
	apply_zone_effects()

/datum/divine_zone/proc/is_inside(atom/A)
	if(!center || !A)
		return FALSE

	return get_dist(center, A) <= radius

/datum/divine_zone/proc/apply_zone_effects()
	for(var/mob/living/carbon/human/H in range(radius, center))
		if(H.stat == DEAD)
			continue

		apply_zone_effect_to_human(H)

/datum/divine_zone/proc/apply_zone_effect_to_human(mob/living/carbon/human/H)
	switch(zone_type)
		if("sanctuary")
			// Complete protection and healing
			if(H.physiology)
				H.physiology.brute_mod = max(0.2, H.physiology.brute_mod - 0.3)
				H.physiology.burn_mod = max(0.2, H.physiology.burn_mod - 0.3)
				H.physiology.tox_mod = max(0.2, H.physiology.tox_mod - 0.3)
			H.adjustBruteLoss(-5)
			H.adjustFireLoss(-5)
			H.adjustToxLoss(-5)
			if(H.sanity)
				H.sanity.adjust_sanity(10)
		if("guidance")
			// Subtle divine guidance
			if(H.sanity)
				H.sanity.adjust_sanity(5)
			if(H.physiology)
				H.physiology.brute_mod = max(0.7, H.physiology.brute_mod - 0.1)
				H.physiology.burn_mod = max(0.7, H.physiology.burn_mod - 0.1)
				H.physiology.tox_mod = max(0.7, H.physiology.tox_mod - 0.1)
		if("authority")
			// Strong divine influence
			if(H.physiology)
				H.physiology.brute_mod = max(0.4, H.physiology.brute_mod - 0.2)
				H.physiology.burn_mod = max(0.4, H.physiology.burn_mod - 0.2)
				H.physiology.tox_mod = max(0.4, H.physiology.tox_mod - 0.2)
			H.adjustBruteLoss(-3)
			H.adjustFireLoss(-3)
			H.adjustToxLoss(-3)
			if(H.sanity)
				H.sanity.adjust_sanity(8)
		if("transcendent")
			// Ultimate divine power
			if(H.physiology)
				H.physiology.brute_mod = max(0.1, H.physiology.brute_mod - 0.4)
				H.physiology.burn_mod = max(0.1, H.physiology.burn_mod - 0.4)
				H.physiology.tox_mod = max(0.1, H.physiology.tox_mod - 0.4)
			H.adjustBruteLoss(-10)
			H.adjustFireLoss(-10)
			H.adjustToxLoss(-10)
			if(H.sanity)
				H.sanity.adjust_sanity(15)

// Research Integration System - Integrates with existing research persistence
/datum/scp343_research_integration
	var/mob/living/carbon/human/scp343/owner = null

	// Research tracking
	var/list/research_projects = list()
	var/list/research_data = list()

/datum/scp343_research_integration/New(mob/living/carbon/human/scp343/new_owner)
	owner = new_owner

/datum/scp343_research_integration/Destroy()
	owner = null
	return ..()

/datum/scp343_research_integration/proc/contribute_research_data()
	if(!SSresearch_persistence || !SSresearch_persistence.manager)
		return

	// Prepare research data
	if(owner && istype(owner, /mob/living/carbon/human/scp343))
		var/mob/living/carbon/human/scp343/scp343_owner = owner
		if(scp343_owner.divine_power)
			research_data["divine_energy"] = scp343_owner.divine_power.divine_energy
			research_data["divine_authority"] = scp343_owner.divine_power.divine_authority

		if(scp343_owner.evolution_system)
			research_data["evolution_stage"] = scp343_owner.evolution_system.current_stage
			research_data["protection_points"] = scp343_owner.evolution_system.protection_points
			research_data["healing_points"] = scp343_owner.evolution_system.healing_points
			research_data["guidance_points"] = scp343_owner.evolution_system.guidance_points
			research_data["authority_points"] = scp343_owner.evolution_system.authority_points

		if(scp343_owner.containment_system)
			research_data["containment_level"] = scp343_owner.containment_system.containment_level
			research_data["divine_activities"] = scp343_owner.containment_system.divine_activities

		if(scp343_owner.environmental_system)
			research_data["divine_zones"] = length(scp343_owner.environmental_system.divine_zones)

	// Create research project if it doesn't exist
	var/project_name = "SCP-343 Divine Intervention Analysis"
	var/project_description = "Analysis of SCP-343's divine intervention patterns and reality manipulation capabilities"
	var/research_field = "SCP-343_DIVINE"
	var/lead_researcher = "System"

	var/datum/research_persistence_project/project = SSresearch_persistence.manager.add_research_project(
		project_name,
		project_description,
		research_field,
		lead_researcher,
		10080, // 1 week
		1
	)

	if(project)
		// Update project with current data
		var/progress = 0
		if(owner && istype(owner, /mob/living/carbon/human/scp343))
			var/mob/living/carbon/human/scp343/scp343_owner = owner
			if(scp343_owner.evolution_system)
				progress = (scp343_owner.evolution_system.protection_points / 10) + (scp343_owner.evolution_system.healing_points / 10) + (scp343_owner.evolution_system.guidance_points / 10) + (scp343_owner.evolution_system.authority_points / 10)
		project.progress = min(100, progress)

		// Mark as completed if enough data
		if(project.progress >= 100)
			project.status = "COMPLETED"

			// Add scientific discovery
			SSresearch_persistence.manager.add_scientific_discovery(
				"SCP-343 Divine Intervention Patterns",
				"Analysis of SCP-343's automatic divine intervention system reveals complex threat detection and response mechanisms.",
				"SCP-343_DIVINE",
				lead_researcher,
				100
			)

// Visual Effects
/obj/effect/temp_visual/divine_protection
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield"
	duration = 30

/obj/effect/temp_visual/divine_healing
	icon = 'icons/effects/effects.dmi'
	icon_state = "heal"
	duration = 30

/obj/effect/temp_visual/divine_guidance
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparkles"
	duration = 30

/obj/effect/temp_visual/divine_manipulation
	icon = 'icons/effects/effects.dmi'
	icon_state = "reality"
	duration = 45

/obj/effect/temp_visual/divine_zone
	icon = 'icons/effects/effects.dmi'
	icon_state = "zone"
	duration = 60

// END OF SCP-343 CORE SYSTEMS
// ============================================================================
