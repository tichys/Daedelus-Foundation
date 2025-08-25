// SCP-106 System Datums
// Dimensional Phasing, Pocket Dimensions, Corrosion, Hunting, Containment, and Research Systems

// ========================================
// DIMENSIONAL PHASING SYSTEM
// ========================================

/datum/scp106_phasing_system
    var/mob/living/carbon/human/scp106/owner = null
    var/dimensional_energy = 100
    var/max_dimensional_energy = 100
    var/phase_mastery = 1.0
    var/max_phase_mastery = 5.0
    var/phase_range = 3
    var/max_phase_range = 10
    var/corrosion_trail = FALSE
    var/dimensional_stability = 100
    var/max_dimensional_stability = 100
    var/phase_cooldown = 0
    var/phase_cooldown_time = 10 SECONDS
    var/last_phase = 0
    var/phase_energy_regen = 5
    var/phase_energy_regen_interval = 30 SECONDS
    var/last_energy_regen = 0

/datum/scp106_phasing_system/New(mob/living/carbon/human/scp106/new_owner)
    . = ..()
    owner = new_owner

/datum/scp106_phasing_system/proc/process_phasing()
    // Regenerate dimensional energy
    if(world.time >= last_energy_regen + phase_energy_regen_interval)
        dimensional_energy = min(max_dimensional_energy, dimensional_energy + phase_energy_regen)
        last_energy_regen = world.time

    if(phase_cooldown > 0)
        phase_cooldown = max(0, phase_cooldown - 1)

/datum/scp106_phasing_system/proc/phase_through_wall(turf/target_turf)
    if(phase_cooldown > 0)
        return FALSE

    if(dimensional_energy < 20)
        return FALSE

    if(!target_turf || !can_phase_to(target_turf))
        return FALSE

    // Calculate phase cost based on distance and mastery
    var/phase_cost = calculate_phase_cost(target_turf)
    if(dimensional_energy < phase_cost)
        return FALSE

    // Execute phase
    dimensional_energy -= phase_cost
    phase_cooldown = phase_cooldown_time
    last_phase = world.time

    // Move to target location
    var/old_loc = owner.loc
    owner.forceMove(target_turf)

    // Visual and audio effects
    playsound(owner, 'sound/effects/phasein.ogg', 50, 0)
    owner.visible_message("<span class='danger'>[owner] phases through reality!</span>")

    // Apply corrosive effects if enabled
    if(corrosion_trail)
        create_corrosion_trail(old_loc, target_turf)

    // Damage nearby targets
    apply_phase_damage()

    return TRUE

/datum/scp106_phasing_system/proc/can_phase_to(turf/target)
    if(!target)
        return FALSE

    // Check if target is within phase range
    if(get_dist(owner, target) > phase_range)
        return FALSE

    // Check if target is accessible (not blocked by solid objects)
    if(target.density && !istype(target, /turf/closed))
        return TRUE

    return FALSE

/datum/scp106_phasing_system/proc/calculate_phase_cost(turf/target)
    var/distance = get_dist(owner, target)
    var/base_cost = 20
    var/distance_cost = distance * 5
    var/mastery_discount = phase_mastery * 2

    return max(10, base_cost + distance_cost - mastery_discount)

/datum/scp106_phasing_system/proc/create_corrosion_trail(turf/start, turf/end)
    // Create corrosive trail between start and end points
    var/list/trail_turfs = get_line(start, end)
    for(var/turf/T in trail_turfs)
        if(T != start && T != end)
            // Apply corrosion effect to trail
            if(owner.corrosion_system)
                owner.corrosion_system.apply_corrosion_to_turf(T, 10)

/datum/scp106_phasing_system/proc/apply_phase_damage()
    for(var/mob/living/carbon/human/H in range(2, owner))
        if(H != owner && H.health > 0)
            var/damage = 20 * phase_mastery
            H.adjustBruteLoss(damage)
            H.adjustToxLoss(damage * 0.5)

            // Apply sanity damage
            if(H.sanity)
                H.sanity.adjust_sanity(-10, "scp106_phase")

            H.visible_message("<span class='danger'>[H] feels reality distort as SCP-106 phases nearby!</span>")

/datum/scp106_phasing_system/proc/emerge_from_surface(surface_type)
    // Emerge from walls, floors, or ceilings
    var/list/valid_emergence_points = list()

    for(var/turf/T in range(phase_range, owner))
        if(T.density && !istype(T, /turf/closed))
            valid_emergence_points += T

    if(valid_emergence_points.len > 0)
        var/turf/emergence_point = pick(valid_emergence_points)
        phase_through_wall(emergence_point)
        return TRUE

    return FALSE

// ========================================
// POCKET DIMENSION SYSTEM
// ========================================

/datum/scp106_pocket_dimension_system
    var/mob/living/carbon/human/scp106/owner = null
    var/list/active_dimensions = list()
    var/dimension_capacity = 3
    var/max_dimension_capacity = 5
    var/torture_efficiency = 50
    var/max_torture_efficiency = 100
    var/dimension_stability = 100
    var/max_dimension_stability = 100
    var/extraction_difficulty = 50
    var/max_extraction_difficulty = 100
    var/dimension_energy_cost = 10
    var/dimension_maintenance_interval = 60 SECONDS
    var/last_maintenance = 0

/datum/scp106_pocket_dimension_system/New(mob/living/carbon/human/scp106/new_owner)
    . = ..()
    owner = new_owner

/datum/scp106_pocket_dimension_system/proc/process_dimensions()
    if(world.time >= last_maintenance + dimension_maintenance_interval)
        maintain_dimensions()
        last_maintenance = world.time

/datum/scp106_pocket_dimension_system/proc/create_pocket_dimension(dimension_type = "decay_chamber")
    if(active_dimensions.len >= dimension_capacity)
        return FALSE

    if(owner.dimensional_energy < dimension_energy_cost)
        return FALSE

    var/dimension_id = "dimension_[world.time]"
    var/list/dimension_data = list(
        "id" = dimension_id,
        "type" = dimension_type,
        "created_time" = world.time,
        "victims" = list(),
        "torture_level" = 0,
        "stability" = dimension_stability,
        "extraction_difficulty" = extraction_difficulty
    )

    active_dimensions[dimension_id] = dimension_data
    owner.dimensional_energy -= dimension_energy_cost

    return dimension_id

/datum/scp106_pocket_dimension_system/proc/drag_victim_to_dimension(mob/living/carbon/human/victim, dimension_id)
    if(!victim || victim.health <= 0)
        return FALSE

    if(!active_dimensions[dimension_id])
        return FALSE

    var/list/dimension_data = active_dimensions[dimension_id]
    var/list/victims = dimension_data["victims"]

    // Add victim to dimension
    victims[victim.name] = list(
        "mob" = victim,
        "capture_time" = world.time,
        "torture_level" = 0,
        "escape_attempts" = 0
    )

    // Apply initial effects
    apply_dimension_effects(victim, dimension_data)

    // Visual effects
    victim.visible_message("<span class='danger'>[victim] is dragged into a pocket dimension!</span>")
    playsound(victim, 'sound/effects/phasein.ogg', 50, 0)

    return TRUE

/datum/scp106_pocket_dimension_system/proc/manage_dimension_torture(dimension_id)
    if(!active_dimensions[dimension_id])
        return

    var/list/dimension_data = active_dimensions[dimension_id]
    var/list/victims = dimension_data["victims"]

    for(var/victim_name in victims)
        var/list/victim_data = victims[victim_name]
        var/mob/living/carbon/human/victim = victim_data["mob"]

        if(victim && victim.health > 0)
            // Apply torture effects
            apply_torture_effects(victim, dimension_data)

            // Check for escape attempts
            if(prob(5)) // 5% chance per cycle for escape attempt
                attempt_victim_escape(victim, dimension_data)

/datum/scp106_pocket_dimension_system/proc/apply_dimension_effects(mob/living/carbon/human/victim, list/dimension_data)
    // Apply initial dimension effects
    if(victim.sanity)
        victim.sanity.adjust_sanity(-20, "pocket_dimension_entry")

    // Apply physical effects based on dimension type
    switch(dimension_data["type"])
        if("decay_chamber")
            victim.adjustBruteLoss(10)
            victim.adjustToxLoss(5)
        if("horror_maze")
            if(victim.sanity)
                victim.sanity.adjust_sanity(-15, "horror_maze")
        if("memory_loop")
            if(victim.sanity)
                victim.sanity.adjust_sanity(-10, "memory_loop")
        if("sensory_deprivation")
            victim.adjustBruteLoss(5)
            if(victim.sanity)
                victim.sanity.adjust_sanity(-25, "sensory_deprivation")

/datum/scp106_pocket_dimension_system/proc/apply_torture_effects(mob/living/carbon/human/victim, list/dimension_data)
    var/torture_level = dimension_data["torture_level"]
    var/efficiency = torture_efficiency / 100

    // Physical torture
    var/physical_damage = (5 + torture_level) * efficiency
    victim.adjustBruteLoss(physical_damage)
    victim.adjustToxLoss(physical_damage * 0.5)

    // Psychological torture
    if(victim.sanity)
        var/psychological_damage = (10 + torture_level * 2) * efficiency
        victim.sanity.adjust_sanity(-psychological_damage, "pocket_dimension_torture")

    // Increase torture level
    dimension_data["torture_level"] = min(100, torture_level + 1)

/datum/scp106_pocket_dimension_system/proc/attempt_victim_escape(mob/living/carbon/human/victim, list/dimension_data)
    var/escape_chance = 5 // Base 5% chance
    var/difficulty = dimension_data["extraction_difficulty"]

    // Reduce chance based on difficulty
    escape_chance = max(1, escape_chance - (difficulty / 10))

    if(prob(escape_chance))
        // Successful escape
        release_victim_from_dimension(victim, dimension_data)
        return TRUE

    return FALSE

/datum/scp106_pocket_dimension_system/proc/release_victim_from_dimension(mob/living/carbon/human/victim, list/dimension_data)
    // Find and remove victim from dimension
    var/list/victims = dimension_data["victims"]
    for(var/victim_name in victims)
        var/list/victim_data = victims[victim_name]
        if(victim_data["mob"] == victim)
            victims.Remove(victim_name)
            break

    // Return victim to facility
    var/turf/escape_location = get_turf(victim)
    if(escape_location)
        victim.forceMove(escape_location)

    victim.visible_message("<span class='notice'>[victim] emerges from a pocket dimension!</span>")
    playsound(victim, 'sound/effects/phasein.ogg', 50, 0)

/datum/scp106_pocket_dimension_system/proc/maintain_dimensions()
    // Maintain all active dimensions
    for(var/dimension_id in active_dimensions)
        var/list/dimension_data = active_dimensions[dimension_id]

        // Reduce stability over time
        dimension_data["stability"] = max(0, dimension_data["stability"] - 1)

        // If stability reaches 0, dimension collapses
        if(dimension_data["stability"] <= 0)
            collapse_dimension(dimension_id)

        // Apply torture to victims
        manage_dimension_torture(dimension_id)

/datum/scp106_pocket_dimension_system/proc/collapse_dimension(dimension_id)
    if(!active_dimensions[dimension_id])
        return

    var/list/dimension_data = active_dimensions[dimension_id]
    var/list/victims = dimension_data["victims"]

    // Release all victims
    for(var/victim_name in victims)
        var/list/victim_data = victims[victim_name]
        var/mob/living/carbon/human/victim = victim_data["mob"]
        if(victim)
            release_victim_from_dimension(victim, dimension_data)

    // Remove dimension
    active_dimensions.Remove(dimension_id)

// ========================================
// CORROSION SYSTEM
// ========================================

/datum/scp106_corrosion_system
    var/mob/living/carbon/human/scp106/owner = null
    var/corrosion_potency = 50
    var/max_corrosion_potency = 100
    var/corrosion_spread = 2
    var/max_corrosion_spread = 5
    var/material_dissolution = 10
    var/max_material_dissolution = 50
    var/organic_decay = 15
    var/max_organic_decay = 50
    var/environmental_impact = 25
    var/max_environmental_impact = 100
    var/corrosion_cooldown = 0
    var/corrosion_cooldown_time = 45 SECONDS
    var/last_corrosion = 0

/datum/scp106_corrosion_system/New(mob/living/carbon/human/scp106/new_owner)
    . = ..()
    owner = new_owner

/datum/scp106_corrosion_system/proc/process_corrosion()
    if(corrosion_cooldown > 0)
        corrosion_cooldown = max(0, corrosion_cooldown - 1)

/datum/scp106_corrosion_system/proc/apply_corrosive_touch(mob/living/carbon/human/target)
    if(corrosion_cooldown > 0)
        return FALSE

    if(!target || target.health <= 0)
        return FALSE

    corrosion_cooldown = corrosion_cooldown_time
    last_corrosion = world.time

    // Apply direct corrosion damage
    var/damage = corrosion_potency
    target.adjustBruteLoss(damage)
    target.adjustToxLoss(damage * 0.7)

    // Apply sanity damage
    if(target.sanity)
        target.sanity.adjust_sanity(-15, "corrosive_touch")

    // Visual effects
    target.visible_message("<span class='danger'>[target] is touched by SCP-106's corrosive hand!</span>")
    playsound(target, 'sound/effects/phasein.ogg', 50, 0)

    // Spread corrosion to nearby area
    spread_corrosion(target.loc, corrosion_spread)

    return TRUE

/datum/scp106_corrosion_system/proc/spread_corrosion(turf/center, radius)
    for(var/turf/T in range(radius, center))
        if(T != center)
            apply_corrosion_to_turf(T, environmental_impact)

/datum/scp106_corrosion_system/proc/apply_corrosion_to_turf(turf/T, intensity)
    // Apply corrosion effects to the turf
    if(T.density)
        // Damage dense structures
        if(prob(intensity))
            // Create visual corrosion effect
            new /obj/effect/corrosion_effect(T)

    // Damage any objects on the turf
    for(var/obj/O in T)
        if(prob(intensity))
            O.take_damage(material_dissolution)

/datum/scp106_corrosion_system/proc/corrode_structure(obj/structure)
    if(!structure)
        return FALSE

    // Apply structural damage
    structure.take_damage(material_dissolution)

    // Visual effects
    structure.visible_message("<span class='danger'>[structure] begins to corrode and decay!</span>")

    return TRUE

/datum/scp106_corrosion_system/proc/environmental_contamination()
    // Create persistent hazardous area
    var/turf/center = owner.loc
    if(!center)
        return

    // Create contamination zone
    for(var/turf/T in range(corrosion_spread, center))
        if(prob(environmental_impact))
            new /obj/effect/corrosion_zone(T)

// Corrosion effect objects
/obj/effect/corrosion_effect
    name = "corrosion"
    desc = "A dark, decaying area where reality itself seems to rot."
    icon = 'icons/effects/effects.dmi'
    icon_state = "corrosion"
    layer = ABOVE_OPEN_TURF_LAYER

/obj/effect/corrosion_zone
    name = "corrosion zone"
    desc = "A hazardous area contaminated by SCP-106's corrosive touch."
    icon = 'icons/effects/effects.dmi'
    icon_state = "corrosion_zone"
    layer = ABOVE_OPEN_TURF_LAYER

    var/damage_tick = 0
    var/damage_interval = 30 SECONDS

    New()
        . = ..()

    process()
        damage_tick++
        if(damage_tick >= damage_interval)
            damage_tick = 0
            apply_zone_damage()

    proc/apply_zone_damage()
        for(var/mob/living/carbon/human/H in range(1, src))
            if(H.health > 0)
                H.adjustBruteLoss(5)
                H.adjustToxLoss(3)
                if(H.sanity)
                    H.sanity.adjust_sanity(-5, "corrosion_zone")

// ========================================
// HUNTING SYSTEM
// ========================================

/datum/scp106_hunting_system
    var/mob/living/carbon/human/scp106/owner = null
    var/list/preferred_targets = list()
    var/stalking_patience = 0
    var/max_stalking_patience = 100
    var/hunt_experience = 0
    var/max_hunt_experience = 100
    var/ambush_mastery = 50
    var/max_ambush_mastery = 100
    var/psychological_pressure = 0
    var/max_psychological_pressure = 100
    var/hunt_mode = FALSE
    var/mob/living/carbon/human/current_target = null
    var/stalking_cooldown = 0
    var/stalking_cooldown_time = 30 SECONDS

/datum/scp106_hunting_system/New(mob/living/carbon/human/scp106/new_owner)
    . = ..()
    owner = new_owner

/datum/scp106_hunting_system/proc/process_hunting()
    if(stalking_cooldown > 0)
        stalking_cooldown = max(0, stalking_cooldown - 1)

    if(hunt_mode && current_target)
        execute_hunt()

/datum/scp106_hunting_system/proc/select_preferred_target()
    preferred_targets.Cut()

    for(var/mob/living/carbon/human/H in view(10, owner))
        if(H.health > 0 && H != owner)
            var/target_score = calculate_target_score(H)
            preferred_targets[H] = target_score

    // Sort targets by score
    preferred_targets = sort_list(preferred_targets, /proc/cmp_numeric_dsc)

    if(preferred_targets.len > 0)
        current_target = preferred_targets[1]
        hunt_mode = TRUE
        return TRUE

    return FALSE

/datum/scp106_hunting_system/proc/calculate_target_score(mob/living/carbon/human/target)
    var/score = 0

    // Prefer isolated targets
    var/nearby_allies = 0
    for(var/mob/living/carbon/human/H in view(3, target))
        if(H != target && H.health > 0)
            nearby_allies++

    score += (5 - nearby_allies) * 10

    // Prefer young targets
    if(target.age < 30)
        score += 15

    // Prefer vulnerable targets
    if(target.health < 50)
        score += 20

    // Prefer targets with low sanity
    if(target.sanity && target.sanity.sanity_level < 50)
        score += 15

    return score

/datum/scp106_hunting_system/proc/stalk_target(mob/living/carbon/human/target)
    if(stalking_cooldown > 0)
        return FALSE

    if(!target || target.health <= 0)
        return FALSE

    stalking_cooldown = stalking_cooldown_time
    stalking_patience = min(max_stalking_patience, stalking_patience + 10)

    // Apply psychological pressure
    if(target.sanity)
        target.sanity.adjust_sanity(-5, "scp106_stalking")

    // Visual stalking effect
    target.visible_message("<span class='warning'>[target] feels like they're being watched...</span>")

    return TRUE

/datum/scp106_hunting_system/proc/execute_hunt()
    if(!current_target || !istype(current_target, /mob/living/carbon/human) || current_target.health <= 0)
        current_target = null
        hunt_mode = FALSE
        return

    // Check if target is still in range
    if(get_dist(owner, current_target) > 15)
        current_target = null
        hunt_mode = FALSE
        return

    // Execute ambush if close enough
    if(get_dist(owner, current_target) <= 2)
        execute_ambush()

/datum/scp106_hunting_system/proc/execute_ambush()
    if(!current_target)
        return

    // Use phasing for dramatic entrance
    if(owner.phasing_system)
        owner.phasing_system.emerge_from_surface("wall")

    // Apply corrosive touch
    if(owner.corrosion_system)
        owner.corrosion_system.apply_corrosive_touch(current_target)

    // Attempt to drag to pocket dimension
    if(owner.pocket_dimension_system && owner.pocket_dimension_system.active_dimensions.len > 0)
        var/dimension_id = pick(owner.pocket_dimension_system.active_dimensions)
        owner.pocket_dimension_system.drag_victim_to_dimension(current_target, dimension_id)

    // Gain hunting experience
    hunt_experience = min(max_hunt_experience, hunt_experience + 10)

    // Clear current target
    current_target = null
    hunt_mode = FALSE

/datum/scp106_hunting_system/proc/induce_psychological_pressure()
    for(var/mob/living/carbon/human/H in view(7, owner))
        if(H.health > 0 && H != owner)
            if(H.sanity)
                H.sanity.adjust_sanity(-10, "scp106_presence")

            H.visible_message("<span class='warning'>[H] feels an overwhelming sense of dread...</span>")

// ========================================
// CONTAINMENT SYSTEM
// ========================================

/datum/scp106_containment_system
    var/mob/living/carbon/human/scp106/owner = null
    var/containment_status = "contained"
    var/breach_capability = 50
    var/max_breach_capability = 100
    var/escape_motivation = 0
    var/max_escape_motivation = 100
    var/femur_breaker_response = 0
    var/max_femur_breaker_response = 100
    var/dimensional_anchor = 50
    var/max_dimensional_anchor = 100
    var/containment_integrity = 100
    var/max_containment_integrity = 100
    var/last_breach_attempt = 0
    var/breach_attempt_cooldown = 300 SECONDS

/datum/scp106_containment_system/New(mob/living/carbon/human/scp106/new_owner)
    . = ..()
    owner = new_owner

/datum/scp106_containment_system/proc/process_containment()
    // Check containment status
    update_containment_status()

    // Attempt breach if motivated
    if(escape_motivation >= 50 && world.time >= last_breach_attempt + breach_attempt_cooldown)
        attempt_containment_breach()

/datum/scp106_containment_system/proc/update_containment_status()
    var/area/current_area = get_area(owner)
    if(current_area)
        if(findtext(current_area.name, "containment") || findtext(current_area.name, "SCP-106"))
            containment_status = "contained"
        else
            containment_status = "breached"

/datum/scp106_containment_system/proc/attempt_containment_breach()
    if(containment_status == "breached")
        return FALSE

    last_breach_attempt = world.time

    // Calculate breach success chance
    var/breach_chance = breach_capability / 10 // 10% base chance

    if(prob(breach_chance))
        // Successful breach
        containment_status = "breached"
        escape_motivation = 0 // Reset motivation after successful breach

        // Announce breach
        owner.visible_message("<span class='danger'>SCP-106 has breached containment!</span>")

        return TRUE

    return FALSE

/datum/scp106_containment_system/proc/respond_to_femur_breaker()
    // Respond to femur breaker activation
    femur_breaker_response = min(max_femur_breaker_response, femur_breaker_response + 25)

    // Force return to containment
    if(femur_breaker_response >= 50)
        force_return_to_containment()
        femur_breaker_response = 0

    return TRUE

/datum/scp106_containment_system/proc/force_return_to_containment()
    // Find containment area - simplified for now
    var/turf/containment_turf = get_turf(owner)
    if(containment_turf)
        owner.forceMove(containment_turf)
        containment_status = "contained"

        owner.visible_message("<span class='notice'>SCP-106 has been returned to containment.</span>")

/datum/scp106_containment_system/proc/resist_re_containment()
    // Resist attempts to re-contain
    var/resistance_chance = escape_motivation / 10

    if(prob(resistance_chance))
        // Successfully resist
        return TRUE

    return FALSE

/datum/scp106_containment_system/proc/escalate_breach_attempt()
    // Increase motivation and capability for breach
    escape_motivation = min(max_escape_motivation, escape_motivation + 10)
    breach_capability = min(max_breach_capability, breach_capability + 5)

// ========================================
// RESEARCH INTEGRATION SYSTEM
// ========================================

/datum/scp106_research_integration
    var/mob/living/carbon/human/scp106/owner = null
    var/list/research_data = list()
    var/last_research_update = 0
    var/research_update_interval = 120 SECONDS

/datum/scp106_research_integration/New(mob/living/carbon/human/scp106/new_owner)
    . = ..()
    owner = new_owner
    // Don't start processing - already handled by SCP-106's process() method

/datum/scp106_research_integration/proc/process_research()
    if(world.time >= last_research_update + research_update_interval)
        update_research_data()
        last_research_update = world.time

/datum/scp106_research_integration/proc/update_research_data()
    var/current_data = list(
        "dimensional_energy" = owner.phasing_system?.dimensional_energy || 0,
        "phase_mastery" = owner.phasing_system?.phase_mastery || 1.0,
        "active_dimensions" = owner.pocket_dimension_system?.active_dimensions?.len || 0,
        "torture_efficiency" = owner.pocket_dimension_system?.torture_efficiency || 0,
        "corrosion_potency" = owner.corrosion_system?.corrosion_potency || 0,
        "hunt_experience" = owner.hunting_system?.hunt_experience || 0,
        "containment_status" = owner.containment_system?.containment_status || "unknown",
        "breach_capability" = owner.containment_system?.breach_capability || 0,
        "escape_motivation" = owner.containment_system?.escape_motivation || 0,
        "timestamp" = world.time
    )

    research_data["last_update"] = current_data
