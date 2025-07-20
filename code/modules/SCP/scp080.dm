// SCP-080 - Dark Form

/mob/living/simple_animal/hostile/shadow/scp080
    name = "Dark Form"
    real_name = "SCP-080"
    desc = "A shadowy humanoid entity that induces hallucinations, paranoia, and sleep deprivation. Prolonged exposure is fatal."
    icon = 'icons/scp/scp-080.dmi'
    icon_state = "scp_080"
    density = TRUE
    health = 200
    see_in_dark = TRUE
    invisibility = 1 // Hard to see, but not fully invisible
    SCP = null
    var/list/hallucination_messages = list(
        "You see a dark figure out of the corner of your eye...",
        "Whispers echo in your mind...",
        "A sense of dread washes over you...",
        "You feel like you're being watched...",
        "Sleep feels impossible near this thing..."
    )

// Initialization
/mob/living/simple_animal/hostile/shadow/scp080/Initialize()
    . = ..()
    SCP = new /datum/scp(
        src,
        "Dark Form",
        SCP_EUCLID,
        "080",
        SCP_PLAYABLE|SCP_MEMETIC
    )
    SCP.memeticFlags = MVISUAL|MAUDIBLE|MSYNCED
    SCP.memetic_proc = TYPE_PROC_REF(/mob/living/simple_animal/hostile/shadow/scp080, memetic_effect)
    SCP.compInit()
    // Area change signal registration removed (not implemented)

// Cleanup
/mob/living/simple_animal/hostile/shadow/scp080/Destroy()
    QDEL_NULL(SCP)
    return ..()

// Main behavior
var/last_effect_tick = 0
var/regeneration_cooldown = 0
/mob/living/simple_animal/hostile/shadow/scp080/Life()
    . = ..()
    // Regeneration mechanic: if dead, revive after cooldown
    if(stat == DEAD)
        if(regeneration_cooldown == 0)
            regeneration_cooldown = world.time + 30 SECONDS // 30s respawn delay
            visible_message(src, "The darkness begins to re-form...")
        else if(world.time >= regeneration_cooldown)
            stat = CONSCIOUS
            health = 200
            regeneration_cooldown = 0
            visible_message(src, "SCP-080 regenerates from the shadows!")
            // Visual effect: spawn a shadowy particle burst
            if(isturf(loc))
                var/image/shadowburst = image(icon = 'icons/effects/effects.dmi', icon_state = "shadow_burst", loc = loc, layer = ABOVE_MOB_LAYER)
                shadowburst.appearance_flags = RESET_COLOR | RESET_ALPHA
                shadowburst.alpha = 200
                shadowburst.color = "#222222"
                overlays += shadowburst
                spawn(20)
                    overlays -= shadowburst
            // Update appearance
            update_icon()
        return
    // Only run effects every 3 seconds (adjust as needed)
    if(world.time - last_effect_tick < 3 SECONDS)
        return
    last_effect_tick = world.time


// Memetic effect
/mob/living/simple_animal/hostile/shadow/scp080/proc/memetic_effect(mob/living/carbon/human/H)
    if(!H || H.stat == UNCONSCIOUS) return
    // SCP-080's memetic effect: progressive insomnia, paranoia, and fatal exhaustion
    // Stage 1: Initial exposure - mild paranoia and visual hallucinations
    visible_message(H, pick(hallucination_messages))
    H.apply_status_effect(/datum/status_effect/confusion, 10 SECONDS)
    H.apply_status_effect(/datum/status_effect/dizziness, 10 SECONDS)
    H.apply_status_effect(/datum/status_effect/jitter, 10 SECONDS)
    // Use weighted random for effect triggers
    var/effect_roll = rand(1, 100)
    if(effect_roll <= 30)
        visible_message(H, "You feel uneasy, as if something is watching you...")
    effect_roll = rand(1, 100)
    if(effect_roll <= 40)
        visible_message(H, "You hear faint whispers in the darkness...")
        H.apply_status_effect(/datum/status_effect/drugginess, 15 SECONDS)
        H.apply_status_effect(/datum/status_effect/incapacitating/disoriented, 10 SECONDS)
    effect_roll = rand(1, 100)
    if(effect_roll <= 20)
        visible_message(H, "You cannot sleep. Your mind races with fear and exhaustion...")
        H.apply_status_effect(/datum/status_effect/incapacitating/stun, 10 SECONDS)
        H.apply_status_effect(/datum/status_effect/incapacitating/sleeping, 5 SECONDS)
        H.apply_status_effect(/datum/status_effect/incapacitating/incapacitated, 5 SECONDS)
    effect_roll = rand(1, 100)
    if(effect_roll <= 5)
        visible_message(H, "You collapse, unable to fight the exhaustion any longer...")
        H.apply_status_effect(/datum/status_effect/incapacitating/unconscious, 30 SECONDS)
        // If health system exists, apply brute damage or kill
        var/death_roll = rand(1, 100)
        if(death_roll <= 20)
            if(H.health)
                H.health -= 50
                if(H.health <= 0)
                    H.stat = DEAD
                    visible_message(H, "You die from exhaustion and terror...")
    effect_roll = rand(1, 100)
    if(effect_roll <= 10)
        visible_message(H, "You feel an overwhelming urge to flee the darkness...")
        step(H, pick(list(NORTH, SOUTH, EAST, WEST)))

// SCP cross-interactions
/mob/living/simple_animal/hostile/shadow/scp080/proc/proximity_effect(atom/other_scp)
    if(!src.hasscp(other_scp)) return
    var/designation = other_scp.SCP.designation
    switch(designation)
        if("012")
            // SCP-080 ignores SCP-012
            return
        if("013")
            // SCP-013 effect intensifies hallucinations
            if(ishuman(other_scp))
                visible_message(other_scp, "The darkness seems deeper... the Blue Lady is lost within it...")
        if("173")
            // SCP-173 hesitates near SCP-080
            if(prob(30))
                visible_message(null, "SCP-173 pauses, uncertain in the presence of darkness...")
        // Add more SCP interactions as needed

// Helper: does atom have SCP datum?
/mob/living/simple_animal/hostile/shadow/scp080/proc/hasscp(atom/target)
    return !isnull(target) && !isnull(target.SCP)

// Player control setup: implement logic in game controller or SCP assignment system
// /mob/living/simple_animal/hostile/shadow/scp080 can be assigned to a player via admin or SCP slot system
