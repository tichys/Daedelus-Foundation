// SCP-082 System Datums
// Rage Management, Cannibalistic Consumption, Enhanced Strength, Psychological Terror, Physical Enhancement, and Research Systems

// ========================================
// RAGE MANAGEMENT SYSTEM
// ========================================

/datum/scp082_rage_system
    var/mob/living/carbon/human/scp082/owner = null
    var/rage_level = 0
    var/max_rage_level = 100
    var/rage_decay_rate = 0.5
    var/berserk_threshold = 80
    var/combat_efficiency = 1.0
    var/max_combat_efficiency = 3.0
    var/rage_damage_bonus = 0
    var/rage_speed_bonus = 0
    var/intimidation_radius = 3
    var/max_intimidation_radius = 7
    var/berserk_mode = FALSE
    var/rage_cooldown = 0
    var/rage_cooldown_time = 30 SECONDS
    var/last_rage_trigger = 0
    var/rage_decay_interval = 10 SECONDS
    var/last_decay = 0

/datum/scp082_rage_system/New(mob/living/carbon/human/scp082/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)

/datum/scp082_rage_system/proc/process_rage()
    // Decay rage over time
    if(world.time >= last_decay + rage_decay_interval)
        rage_level = max(0, rage_level - rage_decay_rate)
        last_decay = world.time
        update_rage_effects()

    // Update berserk mode
    if(rage_level >= berserk_threshold && !berserk_mode)
        enter_berserk_mode()
    else if(rage_level < berserk_threshold * 0.7 && berserk_mode)
        exit_berserk_mode()

    if(rage_cooldown > 0)
        rage_cooldown = max(0, rage_cooldown - 1)

/datum/scp082_rage_system/proc/add_rage(amount, trigger_type = "unknown")
    rage_level = min(max_rage_level, rage_level + amount)
    last_rage_trigger = world.time

    // Apply immediate effects
    update_rage_effects()

    // Visual feedback
    owner.visible_message("<span class='danger'>[owner] becomes more agitated! Rage: [rage_level]/[max_rage_level]</span>")

    // Trigger intimidation
    if(rage_level > 30)
        apply_intimidation_aura()

/datum/scp082_rage_system/proc/trigger_rage(trigger_type, intensity = 10)
    if(rage_cooldown > 0)
        return FALSE

    var/rage_amount = intensity

    // Modify rage gain based on trigger type
    switch(trigger_type)
        if("damage_taken")
            rage_amount *= 1.5
        if("hunger")
            rage_amount *= 1.2
        if("threats")
            rage_amount *= 0.8
        if("containment")
            rage_amount *= 2.0
        if("feeding_denied")
            rage_amount *= 1.8

    add_rage(rage_amount, trigger_type)
    rage_cooldown = rage_cooldown_time

    return TRUE

/datum/scp082_rage_system/proc/update_rage_effects()
    // Calculate combat efficiency based on rage level
    combat_efficiency = 1.0 + (rage_level / max_rage_level) * (max_combat_efficiency - 1.0)

    // Calculate damage and speed bonuses
    rage_damage_bonus = (rage_level / max_rage_level) * 50
    rage_speed_bonus = (rage_level / max_rage_level) * 0.5

    // Update intimidation radius
    intimidation_radius = 3 + ((rage_level / max_rage_level) * (max_intimidation_radius - 3))

/datum/scp082_rage_system/proc/enter_berserk_mode()
    berserk_mode = TRUE

    // Massive combat bonuses
    combat_efficiency = max_combat_efficiency
    rage_damage_bonus = 75
    rage_speed_bonus = 1.0

    // Visual effects
    owner.visible_message("<span class='danger'>[owner] enters a berserk rage!</span>")
    playsound(owner, 'sound/effects/roar.ogg', 100, 0)

    // Apply fear to nearby humans
    for(var/mob/living/carbon/human/H in range(intimidation_radius, owner))
        if(H != owner && H.health > 0)
            if(H.sanity)
                H.sanity.adjust_sanity(-25, "scp082_berserk")
            H.visible_message("<span class='danger'>[H] is terrified by [owner]'s berserk rage!</span>")

/datum/scp082_rage_system/proc/exit_berserk_mode()
    berserk_mode = FALSE
    update_rage_effects()

    owner.visible_message("<span class='notice'>[owner] calms down slightly from the berserk state.</span>")

/datum/scp082_rage_system/proc/apply_intimidation_aura()
    for(var/mob/living/carbon/human/H in range(intimidation_radius, owner))
        if(H != owner && H.health > 0)
            // Apply fear effects
            if(H.sanity)
                var/fear_damage = 5 + (rage_level / 10)
                H.sanity.adjust_sanity(-fear_damage, "scp082_intimidation")

            // Chance to cause panic
            if(prob(rage_level / 5))
                H.visible_message("<span class='warning'>[H] backs away in fear from [owner]!</span>")

/datum/scp082_rage_system/proc/channel_rage_for_attack()
    if(rage_level < 20)
        return FALSE

    var/rage_cost = 15
    rage_level = max(0, rage_level - rage_cost)

    // Return damage multiplier
    return 1.0 + (rage_damage_bonus / 100)

// ========================================
// CANNIBALISTIC CONSUMPTION SYSTEM
// ========================================

/datum/scp082_consumption_system
    var/mob/living/carbon/human/scp082/owner = null
    var/hunger_level = 50
    var/max_hunger_level = 100
    var/satiation_level = 50
    var/max_satiation_level = 100
    var/consumption_efficiency = 1.0
    var/max_consumption_efficiency = 2.5
    var/feeding_frequency = 120 SECONDS
    var/last_feeding = 0
    var/hunger_decay_rate = 0.3
    var/hunger_decay_interval = 30 SECONDS
    var/last_hunger_decay = 0
    var/consumption_cooldown = 0
    var/consumption_cooldown_time = 60 SECONDS
    var/feeding_in_progress = FALSE
    var/feeding_target = null

/datum/scp082_consumption_system/New(mob/living/carbon/human/scp082/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)

/datum/scp082_consumption_system/proc/process_consumption()
    // Increase hunger over time
    if(world.time >= last_hunger_decay + hunger_decay_interval)
        hunger_level = min(max_hunger_level, hunger_level + hunger_decay_rate)
        satiation_level = max(0, satiation_level - hunger_decay_rate * 0.5)
        last_hunger_decay = world.time

        // Trigger hunger effects
        apply_hunger_effects()

    if(consumption_cooldown > 0)
        consumption_cooldown = max(0, consumption_cooldown - 1)

/datum/scp082_consumption_system/proc/apply_hunger_effects()
    // Increase rage when hungry
    if(hunger_level > 70 && owner.rage_system)
        owner.rage_system.add_rage(2, "hunger")

    // Apply hunger penalties
    if(hunger_level > 80)
        // High hunger causes weakness
        owner.visible_message("<span class='warning'>[owner] looks extremely hungry and agitated!</span>")

        // Chance for hunger rage
        if(prob(10))
            owner.rage_system?.trigger_rage("hunger", 15)

/datum/scp082_consumption_system/proc/attempt_consumption(mob/living/carbon/human/target)
    if(consumption_cooldown > 0)
        return FALSE

    if(!target || target.health <= 0)
        return FALSE

    if(feeding_in_progress)
        return FALSE

    if(get_dist(owner, target) > 1)
        return FALSE

    // Start feeding process
    feeding_in_progress = TRUE
    feeding_target = target
    consumption_cooldown = consumption_cooldown_time

    // Immobilize target
    target.visible_message("<span class='danger'>[owner] grabs [target] for consumption!</span>")

    // Begin feeding sequence
    spawn(0)
        execute_feeding_sequence(target)

    return TRUE

/datum/scp082_consumption_system/proc/execute_feeding_sequence(mob/living/carbon/human/target)
    if(!target || !feeding_in_progress)
        return

    // Stage 1: Grapple and immobilize
    target.visible_message("<span class='danger'>[owner] pins [target] down!</span>")
    playsound(owner, 'sound/effects/phasein.ogg', 50, 0)

    sleep(20) // 2 seconds

    if(!target || target.health <= 0 || get_dist(owner, target) > 1)
        feeding_in_progress = FALSE
        feeding_target = null
        return

    // Stage 2: Initial consumption
    target.visible_message("<span class='danger'>[owner] begins consuming [target]!</span>")
    playsound(owner, 'sound/effects/phasein.ogg', 70, 0)

    var/consumption_damage = 50 * consumption_efficiency
    target.adjustBruteLoss(consumption_damage)

    sleep(30) // 3 seconds

    if(!target || target.health <= 0)
        complete_consumption(target)
        return

    if(get_dist(owner, target) > 1)
        feeding_in_progress = FALSE
        feeding_target = null
        return

    // Stage 3: Full consumption
    target.visible_message("<span class='danger'>[owner] devours [target] completely!</span>")
    playsound(owner, 'sound/effects/phasein.ogg', 80, 0)

    complete_consumption(target)

/datum/scp082_consumption_system/proc/complete_consumption(mob/living/carbon/human/target)
    if(!target)
        return

    // Calculate nutritional value
    var/nutritional_value = calculate_nutritional_value(target)

    // Apply consumption benefits
    apply_consumption_benefits(nutritional_value)

    // Remove target
    target.death()

    // Visual effects
    owner.visible_message("<span class='danger'>[owner] finishes consuming [target]!</span>")

    // Update feeding status
    last_feeding = world.time
    feeding_in_progress = FALSE
    feeding_target = null

    // Reduce rage from successful feeding
    if(owner.rage_system)
        owner.rage_system.rage_level = max(0, owner.rage_system.rage_level - 20)

    // Gain satisfaction
    satiation_level = min(max_satiation_level, satiation_level + nutritional_value)
    hunger_level = max(0, hunger_level - nutritional_value)

/datum/scp082_consumption_system/proc/calculate_nutritional_value(mob/living/carbon/human/target)
    var/base_value = 30

    // Modify based on target health
    var/health_modifier = (target.maxHealth / 100) * 0.5

    // Modify based on target type/role
    var/role_modifier = 1.0
    // Simplified role detection to avoid job access issues

    return base_value * health_modifier * role_modifier

/datum/scp082_consumption_system/proc/apply_consumption_benefits(nutritional_value)
    // Health regeneration
    var/health_gain = nutritional_value * 0.8
    owner.health = min(owner.maxHealth, owner.health + health_gain)

    // Strength enhancement
    if(owner.strength_system)
        owner.strength_system.add_strength_boost(nutritional_value * 0.5)

    // Temporary rage reduction
    if(owner.rage_system)
        owner.rage_system.rage_level = max(0, owner.rage_system.rage_level - nutritional_value * 0.3)

// ========================================
// ENHANCED STRENGTH SYSTEM
// ========================================

/datum/scp082_strength_system
    var/mob/living/carbon/human/scp082/owner = null
    var/base_strength = 100
    var/current_strength = 100
    var/max_strength = 200
    var/strength_modifiers = 0
    var/lifting_capacity = 500
    var/max_lifting_capacity = 2000
    var/destructive_force = 50
    var/max_destructive_force = 150
    var/grappling_power = 70
    var/max_grappling_power = 150
    var/strength_boost_duration = 0
    var/strength_boost_amount = 0
    var/strength_cooldown = 0
    var/strength_cooldown_time = 45 SECONDS

/datum/scp082_strength_system/New(mob/living/carbon/human/scp082/new_owner)
    . = ..()
    owner = new_owner
    current_strength = base_strength
    START_PROCESSING(SSobj, src)

/datum/scp082_strength_system/proc/process_strength()
    // Update strength modifiers from other systems
    update_strength_modifiers()

    // Handle temporary strength boosts
    if(strength_boost_duration > 0)
        strength_boost_duration = max(0, strength_boost_duration - 1)
        if(strength_boost_duration <= 0)
            strength_boost_amount = 0
            update_strength_values()

    if(strength_cooldown > 0)
        strength_cooldown = max(0, strength_cooldown - 1)

/datum/scp082_strength_system/proc/update_strength_modifiers()
    strength_modifiers = 0

    // Rage bonuses
    if(owner.rage_system)
        strength_modifiers += owner.rage_system.rage_level * 0.5

    // Satiation bonuses
    if(owner.consumption_system)
        strength_modifiers += owner.consumption_system.satiation_level * 0.3

    // Enhancement bonuses
    if(owner.enhancement_system)
        strength_modifiers += owner.enhancement_system.physical_growth * 10

    update_strength_values()

/datum/scp082_strength_system/proc/update_strength_values()
    current_strength = min(max_strength, base_strength + strength_modifiers + strength_boost_amount)
    lifting_capacity = 500 + (current_strength - base_strength) * 10
    destructive_force = 50 + (current_strength - base_strength) * 0.8
    grappling_power = 70 + (current_strength - base_strength) * 0.6

/datum/scp082_strength_system/proc/add_strength_boost(amount, duration = 300) // 5 minutes default
    strength_boost_amount += amount
    strength_boost_duration = max(strength_boost_duration, duration)
    update_strength_values()

    owner.visible_message("<span class='notice'>[owner] appears to grow stronger!</span>")

/datum/scp082_strength_system/proc/attempt_destruction(obj/target)
    if(strength_cooldown > 0)
        return FALSE

    if(!target || get_dist(owner, target) > 1)
        return FALSE

    // Calculate destruction chance based on strength and target
    var/destruction_chance = destructive_force
    var/target_resistance = 50 // Base resistance

    // Modify based on target type
    if(istype(target, /obj/machinery))
        target_resistance = 70
    else if(istype(target, /obj/structure/window))
        target_resistance = 30
    else if(istype(target, /obj/structure/table))
        target_resistance = 25
    else if(istype(target, /obj/structure))
        target_resistance = 80

    var/success_chance = min(95, (destruction_chance / target_resistance) * 100)

    if(prob(success_chance))
        // Successful destruction
        target.visible_message("<span class='danger'>[owner] destroys [target] with brute force!</span>")
        playsound(owner, 'sound/effects/phasein.ogg', 60, 0)

        target.take_damage(destructive_force * 2)

        strength_cooldown = strength_cooldown_time
        return TRUE
    else
        // Failed destruction
        target.visible_message("<span class='warning'>[owner] strikes [target] but fails to destroy it!</span>")
        target.take_damage(destructive_force * 0.5)
        return FALSE

/datum/scp082_strength_system/proc/grapple_target(mob/living/carbon/human/target)
    if(!target || target.health <= 0)
        return FALSE

    if(get_dist(owner, target) > 1)
        return FALSE

    // Calculate grapple success chance
    var/grapple_chance = min(95, grappling_power)

    if(prob(grapple_chance))
        // Successful grapple
        target.visible_message("<span class='danger'>[owner] grapples [target] with overwhelming strength!</span>")

        // Apply grapple effects
        var/grapple_damage = grappling_power * 0.8
        target.adjustBruteLoss(grapple_damage)

        // Apply fear
        if(target.sanity)
            target.sanity.adjust_sanity(-15, "scp082_grapple")

        return TRUE

    return FALSE

/datum/scp082_strength_system/proc/throw_object(obj/target, turf/destination)
    if(!target || !destination)
        return FALSE

    if(get_dist(owner, target) > 1)
        return FALSE

    // Check if object can be lifted
    var/object_weight = 100 // Default weight
    if(target.w_class)
        object_weight = target.w_class * 20

    if(object_weight > lifting_capacity)
        owner.visible_message("<span class='warning'>[owner] tries to lift [target] but it's too heavy!</span>")
        return FALSE

    // Throw object
    target.visible_message("<span class='danger'>[owner] hurls [target] with tremendous force!</span>")
    playsound(owner, 'sound/effects/phasein.ogg', 50, 0)

    target.throw_at(destination, 10, current_strength / 20)

    return TRUE

// ========================================
// PSYCHOLOGICAL TERROR SYSTEM
// ========================================

/datum/scp082_terror_system
    var/mob/living/carbon/human/scp082/owner = null
    var/intimidation_level = 50
    var/max_intimidation_level = 100
    var/presence_radius = 5
    var/max_presence_radius = 10
    var/terror_intensity = 30
    var/max_terror_intensity = 80
    var/psychological_pressure = 0
    var/dominance_display_cooldown = 0
    var/dominance_display_cooldown_time = 60 SECONDS
    var/terror_aura_active = FALSE
    var/territorial_radius = 7
    var/max_territorial_radius = 12

/datum/scp082_terror_system/New(mob/living/carbon/human/scp082/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)

/datum/scp082_terror_system/proc/process_terror()
    // Apply passive intimidation
    apply_passive_intimidation()

    // Update terror values based on other systems
    update_terror_values()

    if(dominance_display_cooldown > 0)
        dominance_display_cooldown = max(0, dominance_display_cooldown - 1)

/datum/scp082_terror_system/proc/update_terror_values()
    // Base intimidation from rage
    if(owner.rage_system)
        intimidation_level = 50 + (owner.rage_system.rage_level * 0.3)

    // Bonuses from recent feeding
    if(owner.consumption_system)
        if(world.time - owner.consumption_system.last_feeding < 300) // Within 5 minutes
            intimidation_level += 15

    // Size bonuses from enhancement
    if(owner.enhancement_system)
        intimidation_level += owner.enhancement_system.physical_growth * 5

    intimidation_level = min(max_intimidation_level, intimidation_level)

    // Update other values
    presence_radius = 5 + ((intimidation_level - 50) / 10)
    terror_intensity = 30 + ((intimidation_level - 50) * 0.4)

/datum/scp082_terror_system/proc/apply_passive_intimidation()
    for(var/mob/living/carbon/human/H in range(presence_radius, owner))
        if(H != owner && H.health > 0)
            // Apply passive fear
            if(H.sanity)
                var/fear_amount = terror_intensity * 0.1
                H.sanity.adjust_sanity(-fear_amount, "scp082_presence")

            // Chance for fear reactions
            if(prob(5))
                H.visible_message("<span class='warning'>[H] feels uneasy in [owner]'s presence.</span>")

/datum/scp082_terror_system/proc/dominance_display()
    if(dominance_display_cooldown > 0)
        return FALSE

    dominance_display_cooldown = dominance_display_cooldown_time

    // Dramatic display
    owner.visible_message("<span class='danger'>[owner] roars and beats its chest in a terrifying display!</span>")
    playsound(owner, 'sound/effects/roar.ogg', 100, 0)

    // Apply fear to all nearby humans
    for(var/mob/living/carbon/human/H in range(presence_radius * 1.5, owner))
        if(H != owner && H.health > 0)
            if(H.sanity)
                var/fear_damage = terror_intensity
                H.sanity.adjust_sanity(-fear_damage, "scp082_dominance")

            H.visible_message("<span class='danger'>[H] is terrified by [owner]'s display!</span>")

            // Chance to cause panic
            if(prob(30))
                H.visible_message("<span class='warning'>[H] panics and tries to flee!</span>")

    return TRUE

/datum/scp082_terror_system/proc/territorial_claim(turf/center)
    if(!center)
        center = get_turf(owner)

    // Mark territory
    owner.visible_message("<span class='danger'>[owner] claims this area as its territory!</span>")

    // Apply dominance effects
    for(var/mob/living/carbon/human/H in range(territorial_radius, center))
        if(H != owner && H.health > 0)
            if(H.sanity)
                H.sanity.adjust_sanity(-20, "scp082_territory")

            H.visible_message("<span class='warning'>[H] feels unwelcome in [owner]'s territory!</span>")

/datum/scp082_terror_system/proc/predatory_stalk(mob/living/carbon/human/target)
    if(!target || target.health <= 0)
        return FALSE

    // Apply stalking pressure
    if(target.sanity)
        target.sanity.adjust_sanity(-10, "scp082_stalking")

    target.visible_message("<span class='warning'>[target] feels like they're being hunted!</span>")

    return TRUE

// ========================================
// PHYSICAL ENHANCEMENT SYSTEM
// ========================================

/datum/scp082_enhancement_system
    var/mob/living/carbon/human/scp082/owner = null
    var/regeneration_rate = 5
    var/max_regeneration_rate = 15
    var/adaptation_level = 0
    var/max_adaptation_level = 100
    var/physical_growth = 0
    var/max_physical_growth = 10
    var/metabolic_efficiency = 1.0
    var/max_metabolic_efficiency = 2.0
    var/evolutionary_pressure = 0
    var/max_evolutionary_pressure = 100
    var/regeneration_cooldown = 0
    var/regeneration_cooldown_time = 30 SECONDS
    var/adaptation_progress = 0
    var/growth_progress = 0
    var/list/damage_resistances = list()
    var/regeneration_interval = 20 SECONDS
    var/last_regeneration = 0

/datum/scp082_enhancement_system/New(mob/living/carbon/human/scp082/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)

/datum/scp082_enhancement_system/proc/process_enhancement()
    // Handle regeneration
    if(world.time >= last_regeneration + regeneration_interval)
        apply_regeneration()
        last_regeneration = world.time

    // Process adaptations
    process_adaptations()

    // Handle growth
    process_physical_growth()

    if(regeneration_cooldown > 0)
        regeneration_cooldown = max(0, regeneration_cooldown - 1)

/datum/scp082_enhancement_system/proc/apply_regeneration()
    if(owner.health < owner.maxHealth)
        var/heal_amount = regeneration_rate

        // Bonuses from satiation
        if(owner.consumption_system)
            heal_amount *= (1.0 + (owner.consumption_system.satiation_level / 200))

        owner.health = min(owner.maxHealth, owner.health + heal_amount)

        if(heal_amount > regeneration_rate)
            owner.visible_message("<span class='notice'>[owner] regenerates more efficiently due to recent feeding.</span>")

/datum/scp082_enhancement_system/proc/process_adaptations()
    // Develop resistances to repeated damage types
    adaptation_progress += 0.1

    if(adaptation_progress >= 10)
        adaptation_progress = 0
        adaptation_level = min(max_adaptation_level, adaptation_level + 1)

        if(adaptation_level % 10 == 0)
            owner.visible_message("<span class='notice'>[owner] appears to adapt to environmental pressures.</span>")

/datum/scp082_enhancement_system/proc/process_physical_growth()
    // Gradual growth from feeding
    if(owner.consumption_system && owner.consumption_system.satiation_level > 70)
        growth_progress += 0.05

        if(growth_progress >= 20)
            growth_progress = 0
            physical_growth = min(max_physical_growth, physical_growth + 0.5)

            owner.visible_message("<span class='notice'>[owner] appears slightly larger and more imposing.</span>")

            // Update other systems
            update_growth_effects()

/datum/scp082_enhancement_system/proc/update_growth_effects()
    // Growth affects other systems
    if(owner.strength_system)
        owner.strength_system.base_strength = 100 + (physical_growth * 10)

    if(owner.terror_system)
        owner.terror_system.intimidation_level += physical_growth * 2

/datum/scp082_enhancement_system/proc/develop_resistance(damage_type, intensity = 1)
    if(!damage_resistances[damage_type])
        damage_resistances[damage_type] = 0

    damage_resistances[damage_type] = min(50, damage_resistances[damage_type] + intensity)

    owner.visible_message("<span class='notice'>[owner] appears to develop resistance to [damage_type].</span>")

/datum/scp082_enhancement_system/proc/trigger_active_regeneration()
    if(regeneration_cooldown > 0)
        return FALSE

    regeneration_cooldown = regeneration_cooldown_time

    // Massive healing burst
    var/heal_amount = regeneration_rate * 5
    owner.health = min(owner.maxHealth, owner.health + heal_amount)

    owner.visible_message("<span class='notice'>[owner] rapidly regenerates injuries!</span>")

    return TRUE

// ========================================
// RESEARCH INTEGRATION SYSTEM
// ========================================

/datum/scp082_research_integration
    var/mob/living/carbon/human/scp082/owner = null
    var/list/research_data = list()
    var/last_research_update = 0
    var/research_update_interval = 120 SECONDS

/datum/scp082_research_integration/New(mob/living/carbon/human/scp082/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)

/datum/scp082_research_integration/proc/process_research()
    if(world.time >= last_research_update + research_update_interval)
        update_research_data()
        last_research_update = world.time

/datum/scp082_research_integration/proc/update_research_data()
    var/current_data = list(
        "rage_level" = owner.rage_system?.rage_level || 0,
        "berserk_mode" = owner.rage_system?.berserk_mode || FALSE,
        "hunger_level" = owner.consumption_system?.hunger_level || 0,
        "satiation_level" = owner.consumption_system?.satiation_level || 0,
        "feeding_count" = owner.consumption_system?.last_feeding || 0,
        "current_strength" = owner.strength_system?.current_strength || 0,
        "intimidation_level" = owner.terror_system?.intimidation_level || 0,
        "adaptation_level" = owner.enhancement_system?.adaptation_level || 0,
        "physical_growth" = owner.enhancement_system?.physical_growth || 0,
        "regeneration_rate" = owner.enhancement_system?.regeneration_rate || 0,
        "timestamp" = world.time
    )

    research_data["last_update"] = current_data
