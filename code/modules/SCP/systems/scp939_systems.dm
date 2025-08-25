// SCP-939 System Datums
// Voice Mimicry, Pack Coordination, Psychological Manipulation, Territory Control, and Hunting Systems

// ========================================
// VOICE MIMICRY SYSTEM
// ========================================

/datum/scp939_voice_system
    var/mob/living/carbon/human/scp939/owner = null
    var/list/learned_voices = list()
    var/mimicry_accuracy = 30
    var/max_mimicry_accuracy = 100
    var/voice_evolution_stage = 1
    var/max_voice_evolution = 5
    var/emotional_manipulation = 0
    var/max_emotional_manipulation = 100
    var/context_adaptation = 0
    var/max_context_adaptation = 100
    var/current_mimicked_voice = null
    var/speech_cooldown = 0
    var/speech_cooldown_time = 15 SECONDS
    var/list/voice_evolution_data = list()
    var/learning_rate = 1.0
    var/voice_retention = 0.95
    var/last_voice_learning = 0
    var/voice_learning_interval = 30 SECONDS

/datum/scp939_voice_system/New(mob/living/carbon/human/scp939/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)
    setup_voice_requirements()

/datum/scp939_voice_system/proc/process_voice()
    if(world.time >= last_voice_learning + voice_learning_interval)
        scan_for_voices()
        last_voice_learning = world.time

    if(speech_cooldown > 0)
        speech_cooldown = max(0, speech_cooldown - 1)

/datum/scp939_voice_system/proc/setup_voice_requirements()
    // Set up evolution requirements
    voice_evolution_data[1] = list("accuracy" = 20, "voices" = 3, "emotional" = 10)
    voice_evolution_data[2] = list("accuracy" = 40, "voices" = 8, "emotional" = 25)
    voice_evolution_data[3] = list("accuracy" = 60, "voices" = 15, "emotional" = 50)
    voice_evolution_data[4] = list("accuracy" = 80, "voices" = 25, "emotional" = 75)
    voice_evolution_data[5] = list("accuracy" = 100, "voices" = 40, "emotional" = 100)

/datum/scp939_voice_system/proc/scan_for_voices()
    if(!owner || !owner.fovangle)
        return

    for(var/mob/living/carbon/human/H in view(7, owner))
        if(owner.can_see_cone(H) && H.stat != DEAD)
            learn_voice(H)

/datum/scp939_voice_system/proc/learn_voice(mob/living/carbon/human/speaker)
    if(!speaker || !speaker.name)
        return

    var/voice_id = speaker.name
    if(!learned_voices[voice_id])
        learned_voices[voice_id] = list(
            "name" = speaker.name,
            "voice_pattern" = generate_voice_pattern(speaker),
            "emotional_context" = list(),
            "usage_count" = 0,
            "last_heard" = world.time,
            "accuracy" = 30
        )

    // Update voice data
    var/list/voice_data = learned_voices[voice_id]
    voice_data["last_heard"] = world.time
    voice_data["usage_count"]++

    // Improve accuracy with more exposure
    voice_data["accuracy"] = min(100, voice_data["accuracy"] + learning_rate)

    // Learn emotional context
    learn_emotional_context(voice_id, speaker)

/datum/scp939_voice_system/proc/generate_voice_pattern(mob/living/carbon/human/speaker)
    // Generate unique voice pattern based on speaker characteristics
    var/pattern = ""
    pattern += "[speaker.gender]"
    pattern += "[speaker.age]"
    return pattern

/datum/scp939_voice_system/proc/learn_emotional_context(voice_id, mob/living/carbon/human/speaker)
    var/list/voice_data = learned_voices[voice_id]
    var/list/context = voice_data["emotional_context"]

    // Analyze current emotional state
    var/emotion = determine_emotion(speaker)
    if(emotion)
        context[emotion] = context[emotion] ? context[emotion] + 1 : 1

/datum/scp939_voice_system/proc/determine_emotion(mob/living/carbon/human/speaker)
    // Simple emotion detection based on health and status
    if(speaker.health < 50)
        return "fear"
    else if(speaker.health < 75)
        return "distress"
    else
        return "normal"

/datum/scp939_voice_system/proc/mimic_voice(voice_id, message, emotion = null)
    if(speech_cooldown > 0)
        return FALSE

    if(!learned_voices[voice_id])
        return FALSE

    var/list/voice_data = learned_voices[voice_id]
    var/accuracy = voice_data["accuracy"] * (mimicry_accuracy / 100)

    if(prob(accuracy))
        // Successful mimicry
        owner.say(message)
        speech_cooldown = speech_cooldown_time
        current_mimicked_voice = voice_id

        // Apply psychological effects to nearby humans
        apply_voice_effects(message, voice_id, emotion)
        return TRUE

    return FALSE

/datum/scp939_voice_system/proc/apply_voice_effects(message, voice_id, emotion)
    for(var/mob/living/carbon/human/H in view(7, owner))
        if(H.stat != DEAD && H != owner)
            // Apply sanity damage through trust violation
            if(H.sanity)
                H.sanity.adjust_sanity(-5, "voice_mimicry")

            // Create confusion and fear
            if(prob(30))
                H.visible_message("<span class='warning'>[H] looks confused and frightened.</span>")

/datum/scp939_voice_system/proc/evolve_voice_stage()
    if(voice_evolution_stage >= max_voice_evolution)
        return FALSE

    var/list/requirements = voice_evolution_data[voice_evolution_stage + 1]
    if(mimicry_accuracy >= requirements["accuracy"] && learned_voices.len >= requirements["voices"] && emotional_manipulation >= requirements["emotional"])

        voice_evolution_stage++
        mimicry_accuracy = min(max_mimicry_accuracy, mimicry_accuracy + 10)
        emotional_manipulation = min(max_emotional_manipulation, emotional_manipulation + 15)
        return TRUE

    return FALSE

// ========================================
// PACK COORDINATION SYSTEM
// ========================================

/datum/scp939_pack_system
    var/mob/living/carbon/human/scp939/owner = null
    var/list/pack_members = list()
    var/pack_coordination = 0
    var/max_pack_coordination = 100
    var/pack_hierarchy_rank = 1
    var/max_pack_hierarchy = 5
    var/list/hunting_formation = list()
    var/list/territory_boundaries = list()
    var/list/hierarchy_structure = list()
    var/pack_communication_cooldown = 0
    var/pack_communication_time = 10 SECONDS
    var/last_pack_update = 0
    var/pack_update_interval = 60 SECONDS

/datum/scp939_pack_system/New(mob/living/carbon/human/scp939/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)
    find_pack_members()

/datum/scp939_pack_system/proc/process_pack()
    if(world.time >= last_pack_update + pack_update_interval)
        update_pack_status()
        last_pack_update = world.time

    if(pack_communication_cooldown > 0)
        pack_communication_cooldown = max(0, pack_communication_cooldown - 1)

/datum/scp939_pack_system/proc/find_pack_members()
    pack_members.Cut()
    for(var/mob/living/carbon/human/scp939/other_939 in world)
        if(other_939 != owner && other_939.stat != DEAD)
            pack_members += other_939
            if(other_939.pack_system)
                other_939.pack_system.pack_members += owner

/datum/scp939_pack_system/proc/update_pack_status()
    pack_coordination = min(max_pack_coordination, pack_members.len * 20)

    // Update hierarchy based on experience and coordination
    var/rank = 1
    for(var/mob/living/carbon/human/scp939/member in pack_members)
        if(member.hunting_experience > owner.hunting_experience)
            rank++
    pack_hierarchy_rank = min(max_pack_hierarchy, rank)

/datum/scp939_pack_system/proc/coordinate_with_pack()
    if(pack_communication_cooldown > 0)
        return FALSE

    for(var/mob/living/carbon/human/scp939/member in pack_members)
        if(member.stat != DEAD && member.pack_system)
            member.pack_system.receive_coordination(owner)

    pack_communication_cooldown = pack_communication_time
    return TRUE

/datum/scp939_pack_system/proc/receive_coordination(mob/living/carbon/human/scp939/coordinator)
    // Receive coordination information from other pack members
    if(coordinator.hunting_system && coordinator.hunting_system.current_target)
        owner.hunting_system?.share_target(coordinator.hunting_system.current_target)

/datum/scp939_pack_system/proc/establish_territory()
    var/area/current_area = get_area(owner)
    if(current_area && !(current_area in territory_boundaries))
        territory_boundaries += current_area
        return TRUE
    return FALSE

// ========================================
// PSYCHOLOGICAL MANIPULATION SYSTEM
// ========================================

/datum/scp939_psychology_system
    var/mob/living/carbon/human/scp939/owner = null
    var/list/target_profiles = list()
    var/list/manipulation_tactics = list()
    var/fear_induction = 0
    var/max_fear_induction = 100
    var/trust_exploitation = 0
    var/max_trust_exploitation = 100
    var/group_dynamics = 0
    var/max_group_dynamics = 100
    var/psychological_manipulation = 0
    var/max_psychological_manipulation = 100
    var/last_psychology_update = 0
    var/psychology_update_interval = 45 SECONDS

/datum/scp939_psychology_system/New(mob/living/carbon/human/scp939/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)
    setup_manipulation_tactics()

/datum/scp939_psychology_system/proc/process_psychology()
    if(world.time >= last_psychology_update + psychology_update_interval)
        update_psychological_profiles()
        last_psychology_update = world.time

/datum/scp939_psychology_system/proc/setup_manipulation_tactics()
    manipulation_tactics = list(
        "trust_violation" = "Use familiar voices to betray expectations",
        "isolation" = "Separate targets from groups using voice calls",
        "false_hope" = "Offer apparent rescue to increase despair",
        "authority_confusion" = "Undermine command structure with false orders",
        "social_exploitation" = "Use knowledge of relationships against targets"
    )

/datum/scp939_psychology_system/proc/update_psychological_profiles()
    for(var/mob/living/carbon/human/H in view(10, owner))
        if(owner.can_see_cone(H) && H.stat != DEAD)
            analyze_target_psychology(H)

/datum/scp939_psychology_system/proc/analyze_target_psychology(mob/living/carbon/human/target)
    var/target_id = target.name
    if(!target_profiles[target_id])
        target_profiles[target_id] = list(
            "name" = target.name,
            "fear_level" = 0,
            "trust_level" = 100,
            "social_bonds" = list(),
            "vulnerabilities" = list(),
            "last_analysis" = world.time
        )

    var/list/profile = target_profiles[target_id]
    profile["last_analysis"] = world.time

    // Analyze current psychological state
    if(target.sanity)
        profile["fear_level"] = 100 - target.sanity.sanity_level
        profile["trust_level"] = max(0, profile["trust_level"] - 5)

/datum/scp939_psychology_system/proc/apply_psychological_pressure(mob/living/carbon/human/target)
    var/target_id = target.name
    if(!target_profiles[target_id])
        return FALSE

    var/list/profile = target_profiles[target_id]

    // Apply fear effects
    if(target.sanity)
        target.sanity.adjust_sanity(-10, "psychological_pressure")

    // Reduce trust
    profile["trust_level"] = max(0, profile["trust_level"] - 10)

    // Visual fear response
    target.visible_message("<span class='warning'>[target] looks increasingly terrified.</span>")
    return TRUE

/datum/scp939_psychology_system/proc/exploit_social_bonds(mob/living/carbon/human/target, relationship)
    // Use knowledge of social relationships to manipulate targets
    var/target_id = target.name
    if(!target_profiles[target_id])
        return FALSE

    var/list/profile = target_profiles[target_id]
    if(relationship in profile["social_bonds"])
        // Exploit known relationship
        if(target.sanity)
            target.sanity.adjust_sanity(-15, "social_exploitation")
        return TRUE

    return FALSE

// ========================================
// TERRITORY CONTROL SYSTEM
// ========================================

/datum/scp939_territory_system
    var/mob/living/carbon/human/scp939/owner = null
    var/list/controlled_areas = list()
    var/list/patrol_routes = list()
    var/list/ambush_points = list()
    var/list/escape_routes = list()
    var/list/resource_caches = list()
    var/territory_control = 0
    var/max_territory_control = 100
    var/territory_radius = 10
    var/max_territory_radius = 20
    var/last_territory_update = 0
    var/territory_update_interval = 90 SECONDS

/datum/scp939_territory_system/New(mob/living/carbon/human/scp939/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)

/datum/scp939_territory_system/proc/process_territory()
    if(world.time >= last_territory_update + territory_update_interval)
        update_territory_control()
        last_territory_update = world.time

/datum/scp939_territory_system/proc/update_territory_control()
    var/area/current_area = get_area(owner)
    if(current_area && !(current_area in controlled_areas))
        controlled_areas += current_area
        territory_control = min(max_territory_control, controlled_areas.len * 20)

        // Establish patrol routes in new territory
        establish_patrol_routes(current_area)

/datum/scp939_territory_system/proc/establish_patrol_routes(area/territory)
    // Create patrol routes within the territory
    var/list/routes = list()
    for(var/turf/T in territory)
        if(prob(5)) // 5% chance for each turf to be a patrol point
            routes += T

    patrol_routes[territory] = routes

/datum/scp939_territory_system/proc/prepare_ambush_point(turf/location)
    if(!(location in ambush_points))
        ambush_points += location
        return TRUE
    return FALSE

/datum/scp939_territory_system/proc/is_in_controlled_territory(atom/target)
    var/area/target_area = get_area(target)
    return target_area in controlled_areas

// ========================================
// HUNTING SYSTEM
// ========================================

/datum/scp939_hunting_system
    var/mob/living/carbon/human/scp939/owner = null
    var/list/hunting_targets = list()
    var/mob/living/carbon/human/current_target = null
    var/hunt_mode = FALSE
    var/hunting_experience = 0
    var/max_hunting_experience = 100
    var/ambush_prepared = FALSE
    var/list/hunting_strategies = list()
    var/current_strategy = null
    var/last_hunt_update = 0
    var/hunt_update_interval = 30 SECONDS

/datum/scp939_hunting_system/New(mob/living/carbon/human/scp939/new_owner)
    . = ..()
    owner = new_owner
    START_PROCESSING(SSobj, src)
    setup_hunting_strategies()

/datum/scp939_hunting_system/proc/process_hunting()
    if(world.time >= last_hunt_update + hunt_update_interval)
        update_hunting_status()
        last_hunt_update = world.time

/datum/scp939_hunting_system/proc/setup_hunting_strategies()
    hunting_strategies = list(
        "lure" = "Use voice mimicry to attract targets",
        "ambush" = "Set up coordinated ambush points",
        "pack_hunt" = "Coordinate with pack members",
        "psychological" = "Use psychological manipulation",
        "territorial" = "Use territory control advantages"
    )

/datum/scp939_hunting_system/proc/update_hunting_status()
    if(!current_target || current_target.stat == DEAD)
        current_target = null
        hunt_mode = FALSE
        return

    // Check if target is still in range
    if(get_dist(owner, current_target) > 15)
        current_target = null
        hunt_mode = FALSE
        return

    // Continue hunting current target
    execute_hunting_strategy()

/datum/scp939_hunting_system/proc/identify_targets()
    hunting_targets.Cut()

    for(var/mob/living/carbon/human/H in view(10, owner))
        if(owner.can_see_cone(H) && H.stat != DEAD && H != owner)
            var/target_score = calculate_target_score(H)
            hunting_targets[H] = target_score

    // Sort targets by score
    hunting_targets = sort_list(hunting_targets, /proc/cmp_numeric_dsc)

/datum/scp939_hunting_system/proc/calculate_target_score(mob/living/carbon/human/target)
    var/score = 0

    // Prefer isolated targets
    var/nearby_allies = 0
    for(var/mob/living/carbon/human/H in view(3, target))
        if(H != target && H.stat != DEAD)
            nearby_allies++

    score += (5 - nearby_allies) * 10

    // Prefer vulnerable targets
    if(target.health < 50)
        score += 20

    // Prefer targets with low sanity
    if(target.sanity && target.sanity.sanity_level < 50)
        score += 15

    return score

/datum/scp939_hunting_system/proc/select_target()
    identify_targets()

    if(hunting_targets.len > 0)
        current_target = hunting_targets[1]
        hunt_mode = TRUE
        return TRUE

    return FALSE

/datum/scp939_hunting_system/proc/execute_hunting_strategy()
    if(!current_target)
        return

    // Choose strategy based on current situation
    if(!current_strategy)
        current_strategy = choose_strategy()

    switch(current_strategy)
        if("lure")
            execute_lure_strategy()
        if("ambush")
            execute_ambush_strategy()
        if("pack_hunt")
            execute_pack_hunt_strategy()
        if("psychological")
            execute_psychological_strategy()
        if("territorial")
            execute_territorial_strategy()

/datum/scp939_hunting_system/proc/choose_strategy()
    if(owner.pack_system && owner.pack_system.pack_members.len > 0)
        return "pack_hunt"
    else if(owner.territory_system && owner.territory_system.is_in_controlled_territory(current_target))
        return "territorial"
    else if(owner.psychology_system && owner.psychology_system.target_profiles[current_target.name])
        return "psychological"
    else if(owner.territory_system && owner.territory_system.ambush_points.len > 0)
        return "ambush"
    else
        return "lure"

/datum/scp939_hunting_system/proc/execute_lure_strategy()
    if(!current_target || !owner.voice_system)
        return

    // Use voice mimicry to lure target
    var/list/available_voices = owner.voice_system.learned_voices
    if(available_voices.len > 0)
        var/voice_id = pick(available_voices)
        var/message = "Help! I'm hurt! Please come quickly!"
        owner.voice_system.mimic_voice(voice_id, message, "distress")

/datum/scp939_hunting_system/proc/execute_ambush_strategy()
    if(!current_target || !owner.territory_system)
        return

    // Move to ambush position
    var/list/ambush_points = owner.territory_system.ambush_points
    if(ambush_points.len > 0)
        var/turf/ambush_point = pick(ambush_points)
        if(get_dist(owner, ambush_point) > 1)
            step_towards(owner, ambush_point)

/datum/scp939_hunting_system/proc/execute_pack_hunt_strategy()
    if(!current_target || !owner.pack_system)
        return

    // Coordinate with pack members
    owner.pack_system.coordinate_with_pack()

    // Share target information
    share_target(current_target)

/datum/scp939_hunting_system/proc/execute_psychological_strategy()
    if(!current_target || !owner.psychology_system)
        return

    // Apply psychological pressure
    owner.psychology_system.apply_psychological_pressure(current_target)

/datum/scp939_hunting_system/proc/execute_territorial_strategy()
    if(!current_target || !owner.territory_system)
        return

    // Use territory advantages
    if(owner.territory_system.is_in_controlled_territory(current_target))
        // Target is in our territory - we have the advantage
        if(get_dist(owner, current_target) <= 1)
            attack_target(current_target)

/datum/scp939_hunting_system/proc/share_target(mob/living/carbon/human/target)
    // Share target information with pack members
    for(var/mob/living/carbon/human/scp939/member in owner.pack_system.pack_members)
        if(member.hunting_system && member != owner)
            member.hunting_system.current_target = target
            member.hunting_system.hunt_mode = TRUE

/datum/scp939_hunting_system/proc/attack_target(mob/living/carbon/human/target)
    if(!target || target.stat == DEAD)
        return

    // Perform attack
    target.adjustBruteLoss(25)
    owner.visible_message("<span class='danger'>[owner] viciously attacks [target]!</span>")

    // Apply psychological effects
    if(target.sanity)
        target.sanity.adjust_sanity(-20, "scp939_attack")

    // Gain hunting experience
    hunting_experience = min(max_hunting_experience, hunting_experience + 5)

    // Check if target is eliminated
    if(target.health <= 0)
        hunting_experience += 10
        current_target = null
        hunt_mode = FALSE

// ========================================
// RESEARCH INTEGRATION SYSTEM
// ========================================

/datum/scp939_research_integration
    var/mob/living/carbon/human/scp939/owner = null
    var/list/research_data = list()
    var/last_research_update = 0
    var/research_update_interval = 120 SECONDS

/datum/scp939_research_integration/New(mob/living/carbon/human/scp939/new_owner)
    . = ..()
    owner = new_owner
    // Don't start processing - already handled by SCP-939's process() method

/datum/scp939_research_integration/proc/process_research()
    if(world.time >= last_research_update + research_update_interval)
        update_research_data()
        last_research_update = world.time

/datum/scp939_research_integration/proc/update_research_data()
    var/current_data = list(
        "voice_evolution_stage" = owner.voice_system?.voice_evolution_stage || 1,
        "learned_voices_count" = owner.voice_system?.learned_voices?.len || 0,
        "mimicry_accuracy" = owner.voice_system?.mimicry_accuracy || 0,
        "pack_coordination" = owner.pack_system?.pack_coordination || 0,
        "pack_members_count" = owner.pack_system?.pack_members?.len || 0,
        "psychological_manipulation" = owner.psychology_system?.psychological_manipulation || 0,
        "territory_control" = owner.territory_system?.territory_control || 0,
        "controlled_areas_count" = owner.territory_system?.controlled_areas?.len || 0,
        "hunting_experience" = owner.hunting_system?.hunting_experience || 0,
        "current_target" = owner.hunting_system?.current_target?.name || "none",
        "hunt_mode" = owner.hunting_system?.hunt_mode || FALSE,
        "timestamp" = world.time
    )

    research_data["last_update"] = current_data
