SUBSYSTEM_DEF(scp_research)
    name = "SCP Research"
    flags = SS_NO_FIRE
    init_order = INIT_ORDER_ACHIEVEMENTS + 1

    /// Total SCP research points accrued this round
    var/points_total = 0
    /// Map of SCP designation => points
    var/list/points_by_designation = list()
    /// Map of ckey => points earned from research events
    var/list/points_by_ckey = list()
    /// Event log: list of associative entries with keys: time, designation, event, ckey, name, details
    var/list/event_log = list()

    /// Tracks which interactions have been counted already per mob to avoid spam
    var/list/already_awarded = list() // key: "[designation]|[event]|[ckey]" -> 1

    /// Active research goals for this round
    var/list/datum/scp_research_goal/active_goals = list()
    /// Completed (and repeatable progress history) research goals for this round
    var/list/datum/scp_research_goal/completed_goals = list()
    /// Submitted research reports (list of assoc entries)
    var/list/reports = list()

    /datum/controller/subsystem/scp_research/Initialize(start_timeofday)
        . = ..()
        points_total = 0
        points_by_designation = list()
        points_by_ckey = list()
        event_log = list()
        already_awarded = list()
        active_goals = list()
        completed_goals = list()
        reports = list()
        build_default_goals()
        // Debug: Log goal creation
        log_game("SCP-Research: Initialized with [length(active_goals)] active goals")

    /datum/controller/subsystem/scp_research/proc/register_scp(atom/parent_atom, datum/scp/S)
        if(!parent_atom || !S)
            return
        // Memetic event
        RegisterSignal(parent_atom, COMSIG_SCP_MEMETIC_AFFECTED, PROC_REF(on_memetic_affected))
        // Generic SCP-specific hooks we know of
        RegisterSignal(parent_atom, COMSIG_SCP013_SMOKED, PROC_REF(on_013_smoked))

        // SCP-066 emotes
        RegisterSignal(parent_atom, COMSIG_SCP066_NOISE_EMOTE, PROC_REF(on_066_noise))
        RegisterSignal(parent_atom, COMSIG_SCP066_ERIC_EMOTE, PROC_REF(on_066_eric))
        RegisterSignal(parent_atom, COMSIG_SCP066_LOUD_NOISE_EMOTE, PROC_REF(on_066_loud))
        // SCP-216 events
        RegisterSignal(parent_atom, COMSIG_SCP216_OPEN, PROC_REF(on_216_open))
        RegisterSignal(parent_atom, COMSIG_SCP216_CLOSE, PROC_REF(on_216_close))
        RegisterSignal(parent_atom, COMSIG_SCP216_MOB_RELEASED, PROC_REF(on_216_mob_released))
        RegisterSignal(parent_atom, COMSIG_SCP216_ITEM_INSERTED, PROC_REF(on_216_item_inserted))
        RegisterSignal(parent_atom, COMSIG_SCP216_ITEM_RETRIEVED, PROC_REF(on_216_item_retrieved))
        RegisterSignal(parent_atom, COMSIG_SCP216_CODE_CHANGED, PROC_REF(on_216_code_changed))
        RegisterSignal(parent_atom, COMSIG_SCP216_ITEMS_GENERATED, PROC_REF(on_216_items_generated))
        RegisterSignal(parent_atom, COMSIG_SCP216_TEMPORAL_DISPLACEMENT, PROC_REF(on_216_temporal_displacement))
        // SCP-106
        RegisterSignal(parent_atom, COMSIG_SCP106_PORTAL_OPENED, PROC_REF(on_106_portal_opened))
        RegisterSignal(parent_atom, COMSIG_SCP106_PORTAL_USED, PROC_REF(on_106_portal_used))
        RegisterSignal(parent_atom, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_106_corrosion))
        RegisterSignal(parent_atom, COMSIG_SCP106_VICTIM_ABDUCTED, PROC_REF(on_106_abducted))
        RegisterSignal(parent_atom, COMSIG_SCP106_RETURNED, PROC_REF(on_106_returned))

        // SCP-049
        RegisterSignal(parent_atom, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_049_cure_started))
        RegisterSignal(parent_atom, COMSIG_SCP049_CURE_SUCCESSFUL, PROC_REF(on_049_cure_successful))
        RegisterSignal(parent_atom, COMSIG_SCP049_CURE_FAILED, PROC_REF(on_049_cure_failed))
        RegisterSignal(parent_atom, COMSIG_SCP049_PATIENT_EXAMINED, PROC_REF(on_049_patient_examined))
        RegisterSignal(parent_atom, COMSIG_SCP049_CURE_RESEARCHED, PROC_REF(on_049_cure_researched))
        RegisterSignal(parent_atom, COMSIG_SCP049_ZOMBIE_CREATED, PROC_REF(on_049_zombie_created))

        // SCP-096
        RegisterSignal(parent_atom, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_096_rage_triggered))
        RegisterSignal(parent_atom, COMSIG_SCP096_RAGE_ENDED, PROC_REF(on_096_rage_ended))
        RegisterSignal(parent_atom, COMSIG_SCP096_CONTAINMENT_ACTIVATED, PROC_REF(on_096_containment_activated))
        RegisterSignal(parent_atom, COMSIG_SCP096_CONTAINMENT_DEACTIVATED, PROC_REF(on_096_containment_deactivated))

        // SCP-173
        RegisterSignal(parent_atom, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_173_eye_contact_made))
        RegisterSignal(parent_atom, COMSIG_SCP173_EYE_CONTACT_BROKEN, PROC_REF(on_173_eye_contact_broken))
        RegisterSignal(parent_atom, COMSIG_SCP173_NECK_SNAPPED, PROC_REF(on_173_neck_snapped))
        RegisterSignal(parent_atom, COMSIG_SCP173_CONTAINMENT_ACTIVATED, PROC_REF(on_173_containment_activated))
        RegisterSignal(parent_atom, COMSIG_SCP173_CONTAINMENT_DEACTIVATED, PROC_REF(on_173_containment_deactivated))

        // SCP-682
        RegisterSignal(parent_atom, COMSIG_SCP682_ADAPTED, PROC_REF(on_682_adapted))
        RegisterSignal(parent_atom, COMSIG_SCP682_EVOLVED, PROC_REF(on_682_evolved))
        RegisterSignal(parent_atom, COMSIG_SCP682_CONTAINMENT_ACTIVATED, PROC_REF(on_682_containment_activated))
        RegisterSignal(parent_atom, COMSIG_SCP682_CONTAINMENT_DEACTIVATED, PROC_REF(on_682_containment_deactivated))
        RegisterSignal(parent_atom, COMSIG_SCP682_ATTACKED, PROC_REF(on_682_attacked))

        // SCP-035
        RegisterSignal(parent_atom, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_035_possession_started))
        RegisterSignal(parent_atom, COMSIG_SCP035_POSSESSION_ENDED, PROC_REF(on_035_possession_ended))
        RegisterSignal(parent_atom, COMSIG_SCP035_PERSONALITY_CHANGED, PROC_REF(on_035_personality_changed))

        // SCP-087
        RegisterSignal(parent_atom, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_087_exploration_started))
        RegisterSignal(parent_atom, COMSIG_SCP087_EXPLORATION_ENDED, PROC_REF(on_087_exploration_ended))
        RegisterSignal(parent_atom, COMSIG_SCP087_LEVEL_DESCENDED, PROC_REF(on_087_level_descended))
        RegisterSignal(parent_atom, COMSIG_SCP087_ENTITY_SPAWNED, PROC_REF(on_087_entity_spawned))
        RegisterSignal(parent_atom, COMSIG_SCP087_PORTAL_CREATED, PROC_REF(on_087_portal_created))



        // Cross-SCP interaction signals (temporarily disabled)
        // RegisterSignal(parent_atom, COMSIG_SCP012_CORRUPTED, PROC_REF(on_106_cross_scp_interaction))
        // RegisterSignal(parent_atom, COMSIG_SCP066_SILENCED, PROC_REF(on_106_cross_scp_interaction))
        // RegisterSignal(parent_atom, COMSIG_SCP113_CORRUPTED, PROC_REF(on_106_cross_scp_interaction))
        // RegisterSignal(parent_atom, COMSIG_SCP216_TEMPORAL_RIFT, PROC_REF(on_106_cross_scp_interaction))
        // RegisterSignal(parent_atom, COMSIG_SCP151_ABSORBED, PROC_REF(on_106_cross_scp_interaction))
        // RegisterSignal(parent_atom, COMSIG_SCP_CORRUPTED, PROC_REF(on_106_cross_scp_interaction))

    /datum/controller/subsystem/scp_research/proc/award(atom/source, mob/living/carbon/human/actor, designation, event, base_points = 1, details)
        if(!designation)
            return
        var/ckey = actor ? actor.ckey : null
        if(ckey)
            var/key = "[designation]|[event]|[ckey]"
            if(already_awarded[key])
                return
            already_awarded[key] = TRUE

        points_total += base_points
        points_by_designation[designation] = (points_by_designation[designation] || 0) + base_points
        if(ckey)
            points_by_ckey[ckey] = (points_by_ckey[ckey] || 0) + base_points

        var/name = actor ? actor.name : "N/A"
        event_log += list(list(
            "time" = world.time,
            "designation" = designation,
            "event" = event,
            "ckey" = ckey,
            "name" = name,
            "details" = details
        ))

        // Optional: lightweight feedback to the actor
        if(actor)
            to_chat(actor, span_notice("SCP Research updated: +[base_points] for [event] on SCP-[designation]."))

        // Goal processing
        process_goals(source, actor, designation, event)

    // Handlers
    /datum/controller/subsystem/scp_research/proc/extract_designation_from(atom/source)
        if(!source)
            return null
        var/atom/A = source
        if(A.SCP && istype(A.SCP, /datum/scp))
            var/datum/scp/S = A.SCP
            return S.designation
        return null

    /datum/controller/subsystem/scp_research/proc/on_memetic_affected(datum/source, mob/living/carbon/human/target)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source)
        if(!designation)
            return
        award(source, target, designation, "memetic_effect", 1)

    /datum/controller/subsystem/scp_research/proc/on_013_smoked(datum/source, mob/living/carbon/human/user)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "013"
        award(source, user, designation, "smoked", 2)



    // SCP-066
    /datum/controller/subsystem/scp_research/proc/on_066_noise(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "066"
        award(source, null, designation, "noise", 1)

    /datum/controller/subsystem/scp_research/proc/on_066_eric(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "066"
        award(source, null, designation, "eric", 1)

    /datum/controller/subsystem/scp_research/proc/on_066_loud(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "066"
        award(source, null, designation, "deafening_noise", 2)

    // SCP-216
    /datum/controller/subsystem/scp_research/proc/on_216_open(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "216"
        award(source, null, designation, "open", 1)

    /datum/controller/subsystem/scp_research/proc/on_216_close(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "216"
        award(source, null, designation, "close", 1)

    /datum/controller/subsystem/scp_research/proc/on_216_mob_released(datum/source, mob/living/L)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "216"
        award(source, L, designation, "mob_released", 3)

    /datum/controller/subsystem/scp_research/proc/on_216_item_inserted(datum/source, atom/movable/A, mob/living/carbon/human/user)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "216"
        award(source, user, designation, "item_inserted", 1, details = A ? A.name : null)

    /datum/controller/subsystem/scp_research/proc/on_216_item_retrieved(datum/source, atom/movable/A, mob/living/carbon/human/user)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "216"
        award(source, user, designation, "item_retrieved", 1, details = A ? A.name : null)

    /datum/controller/subsystem/scp_research/proc/on_216_code_changed(datum/source, new_code)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "216"
        award(source, null, designation, "code_changed", 1, details = "[new_code]")

    /datum/controller/subsystem/scp_research/proc/on_216_items_generated(datum/source, code)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "216"
        award(source, null, designation, "items_generated", 2, details = "[code]")

    /datum/controller/subsystem/scp_research/proc/on_216_temporal_displacement(datum/source, atom/movable/A, mob/living/carbon/human/user)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "216"
        award(source, user, designation, "temporal_displacement", 5, details = A ? A.type : null)

    // Accessors used by console
    /datum/controller/subsystem/scp_research/proc/get_points_total()
        return points_total

    /datum/controller/subsystem/scp_research/proc/get_points_by_designation()
        return points_by_designation

    /datum/controller/subsystem/scp_research/proc/get_recent_events(limit = 30)
        var/list/out = list()
        var/start = max(1, length(event_log) - limit + 1)
        for(var/i in start to length(event_log))
            out += list(event_log[i])
        return out

    /datum/controller/subsystem/scp_research/proc/get_goals()
        return active_goals

    /datum/controller/subsystem/scp_research/proc/get_completed_goals()
        return completed_goals

    /datum/controller/subsystem/scp_research/proc/build_default_goals()
        // Populate default goals. These can be made configurable later.
        log_game("SCP-Research: Building default goals...")
        // 012: Document memetic effects
        active_goals += new /datum/scp_research_goal("012_memetics", "Document SCP-012 Memetics", "Record memetic responses near SCP-012 to study compulsion strength.", list("012"), list("memetic_effect"), 5, 5, 500, 250, TRUE)
        // 066: Capture loud performance
        active_goals += new /datum/scp_research_goal("066_loud", "SCP-066 Loud Performance", "Trigger and log deafening output from SCP-066.", list("066"), list("deafening_noise"), 3, 6, 600, 300, TRUE)
        // 113: Gender transpositions
        active_goals += new /datum/scp_research_goal(
            id = "113_contact",
            title = "SCP-113 Contact Trials",
            desc = "Safely perform and document SCP-113 contact trials.",
            designation_filter = list("113"),
            event_filter = list("contact"),
            required_count = 2,
            points_reward = 8,
            cash_reward = 800,
            budget_reward = 400,
            repeatable = TRUE,
        )
        // 216: Temporal displacement
        active_goals += new /datum/scp_research_goal(
            id = "216_temporal",
            title = "SCP-216 Temporal Event",
            desc = "Induce a temporal displacement and record reappearance metadata.",
            designation_filter = list("216"),
            event_filter = list("temporal_displacement"),
            required_count = 1,
            points_reward = 10,
            cash_reward = 1000,
            budget_reward = 500,
            repeatable = TRUE,
        )
        // 106: Abductions
        active_goals += new /datum/scp_research_goal(
            id = "106_abduct",
            title = "SCP-106 Abduction Case Studies",
            desc = "Document abductions into the pocket dimension and survivor reports.",
            designation_filter = list("106"),
            event_filter = list("abducted"),
            required_count = 2,
            points_reward = 12,
            cash_reward = 1200,
            budget_reward = 600,
            repeatable = TRUE,
        )

        active_goals += new /datum/scp_research_goal(
            id = "106_containment",
            title = "SCP-106 Containment Protocol Testing",
            desc = "Test and document containment field effectiveness against SCP-106.",
            designation_filter = list("106"),
            event_filter = list("containment_field", "containment_breach"),
            required_count = 3,
            points_reward = 15,
            cash_reward = 1500,
            budget_reward = 750,
            repeatable = TRUE,
        )

        active_goals += new /datum/scp_research_goal(
            id = "106_cross_scp",
            title = "SCP-106 Cross-SCP Interactions",
            desc = "Document SCP-106's interactions with other SCPs and their effects.",
            designation_filter = list("106"),
            event_filter = list("scp_interaction"),
            required_count = 4,
            points_reward = 20,
            cash_reward = 2000,
            budget_reward = 1000,
            repeatable = TRUE,
        )

        // SCP-049 goals
        active_goals += new /datum/scp_research_goal(
            id = "049_cures",
            title = "SCP-049 Cure Effectiveness",
            desc = "Document SCP-049's cure attempts and success rates.",
            designation_filter = list("049"),
            event_filter = list("cure_started", "cure_successful", "cure_failed"),
            required_count = 5,
            points_reward = 15,
            cash_reward = 1500,
            budget_reward = 750,
            repeatable = TRUE,
        )

        active_goals += new /datum/scp_research_goal(
            id = "049_zombies",
            title = "SCP-049 Zombie Creation",
            desc = "Study SCP-049's zombie creation process and zombie behavior.",
            designation_filter = list("049"),
            event_filter = list("zombie_created"),
            required_count = 3,
            points_reward = 18,
            cash_reward = 1800,
            budget_reward = 900,
            repeatable = TRUE,
        )

        // SCP-096 goals
        active_goals += new /datum/scp_research_goal(
            id = "096_sight",
            title = "SCP-096 Sight Tracking",
            desc = "Document instances where personnel have seen SCP-096's face.",
            designation_filter = list("096"),
            event_filter = list("sight_triggered"),
            required_count = 3,
            points_reward = 15,
            cash_reward = 1500,
            budget_reward = 750,
            repeatable = TRUE,
        )

        active_goals += new /datum/scp_research_goal(
            id = "096_rage",
            title = "SCP-096 Rage Mode Analysis",
            desc = "Study SCP-096's rage mode behavior and containment effectiveness.",
            designation_filter = list("096"),
            event_filter = list("rage_triggered", "rage_ended"),
            required_count = 2,
            points_reward = 20,
            cash_reward = 2000,
            budget_reward = 1000,
            repeatable = TRUE,
        )

        // SCP-173 goals
        active_goals += new /datum/scp_research_goal(
            id = "173_eye_contact",
            title = "SCP-173 Eye Contact Tracking",
            desc = "Document instances of eye contact with SCP-173 and its immobilization effects.",
            designation_filter = list("173"),
            event_filter = list("eye_contact_made", "eye_contact_broken"),
            required_count = 5,
            points_reward = 12,
            cash_reward = 1200,
            budget_reward = 600,
            repeatable = TRUE,
        )

        active_goals += new /datum/scp_research_goal(
            id = "173_neck_snaps",
            title = "SCP-173 Neck Snap Analysis",
            desc = "Study SCP-173's neck snapping behavior and victim patterns.",
            designation_filter = list("173"),
            event_filter = list("neck_snapped"),
            required_count = 3,
            points_reward = 18,
            cash_reward = 1800,
            budget_reward = 900,
            repeatable = TRUE,
        )

        // SCP-682 goals
        active_goals += new /datum/scp_research_goal(
            id = "682_adaptations",
            title = "SCP-682 Adaptation Analysis",
            desc = "Study SCP-682's adaptation mechanisms and resistance development.",
            designation_filter = list("682"),
            event_filter = list("adapted", "evolved"),
            required_count = 4,
            points_reward = 25,
            cash_reward = 2500,
            budget_reward = 1250,
            repeatable = TRUE,
        )

        active_goals += new /datum/scp_research_goal(
            id = "682_containment",
            title = "SCP-682 Containment Testing",
            desc = "Test various containment methods against SCP-682's adaptive capabilities.",
            designation_filter = list("682"),
            event_filter = list("containment_activated", "containment_breached"),
            required_count = 3,
            points_reward = 30,
            cash_reward = 3000,
            budget_reward = 1500,
            repeatable = TRUE,
        )

        // SCP-035 goals
        active_goals += new /datum/scp_research_goal(
            id = "035_possessions",
            title = "SCP-035 Possession Study",
            desc = "Document SCP-035's possession events and personality changes.",
            designation_filter = list("035"),
            event_filter = list("possession_started", "possession_ended"),
            required_count = 3,
            points_reward = 20,
            cash_reward = 2000,
            budget_reward = 1000,
            repeatable = TRUE,
        )

        active_goals += new /datum/scp_research_goal(
            id = "035_personalities",
            title = "SCP-035 Personality Analysis",
            desc = "Study the different personalities exhibited by SCP-035.",
            designation_filter = list("035"),
            event_filter = list("personality_changed"),
            required_count = 4,
            points_reward = 25,
            cash_reward = 2500,
            budget_reward = 1250,
            repeatable = TRUE,
        )

        // SCP-087 goals
        active_goals += new /datum/scp_research_goal(
            id = "087_explorations",
            title = "SCP-087 Exploration Study",
            desc = "Document exploration events within SCP-087's infinite stairwell.",
            designation_filter = list("087"),
            event_filter = list("exploration_started", "exploration_ended"),
            required_count = 2,
            points_reward = 15,
            cash_reward = 1500,
            budget_reward = 750,
            repeatable = TRUE,
        )

        active_goals += new /datum/scp_research_goal(
            id = "087_entities",
            title = "SCP-087 Entity Documentation",
            desc = "Study the entities that spawn within SCP-087.",
            designation_filter = list("087"),
            event_filter = list("entity_spawned"),
            required_count = 5,
            points_reward = 30,
            cash_reward = 3000,
            budget_reward = 1500,
            repeatable = TRUE,
        )

        // SCP-294 goals
        active_goals += new /datum/scp_research_goal(
            id = "294_requests",
            title = "SCP-294 Liquid Requests",
            desc = "Document liquid requests made to SCP-294.",
            designation_filter = list("294"),
            event_filter = list("liquid_requested"),
            required_count = 10,
            points_reward = 10,
            cash_reward = 1000,
            budget_reward = 500,
            repeatable = TRUE,
        )

        active_goals += new /datum/scp_research_goal(
            id = "294_custom_liquids",
            title = "SCP-294 Custom Liquid Creation",
            desc = "Study the creation of custom liquids by SCP-294.",
            designation_filter = list("294"),
            event_filter = list("custom_liquid_created"),
            required_count = 5,
            points_reward = 25,
            cash_reward = 2500,
            budget_reward = 1250,
            repeatable = TRUE,
        )

        log_game("SCP-Research: Created [length(active_goals)] total goals")

    // Debug command to check subsystem status
    /datum/controller/subsystem/scp_research/proc/debug_status(mob/user)
        if(!user)
            return
        to_chat(user, span_notice("=== SCP Research Subsystem Debug ==="))
        to_chat(user, span_notice("Subsystem exists: [SSscp_research ? "YES" : "NO"]"))
        if(SSscp_research)
            to_chat(user, span_notice("Active goals: [length(SSscp_research.active_goals)]"))
            to_chat(user, span_notice("Completed goals: [length(SSscp_research.completed_goals)]"))
            to_chat(user, span_notice("Total points: [SSscp_research.points_total]"))
            for(var/datum/scp_research_goal/G in SSscp_research.active_goals)
                to_chat(user, span_notice("- [G.title] (ID: [G.id])"))
        to_chat(user, span_notice("================================"))

    /datum/controller/subsystem/scp_research/proc/process_goals(atom/source, mob/living/carbon/human/actor, designation, event)
        if(!length(active_goals))
            return
        for(var/datum/scp_research_goal/G in active_goals)
            if(!G.matches(designation, event))
                continue
            if(G.progress_event())
                // Completed
                // Points reward
                points_total += G.points_reward
                points_by_designation[designation] = (points_by_designation[designation] || 0) + G.points_reward
                var/ckey = actor ? actor.ckey : null
                if(ckey)
                    points_by_ckey[ckey] = (points_by_ckey[ckey] || 0) + G.points_reward
                // Cash reward to actor if possible
                if(actor && G.cash_reward > 0 && SSeconomy)
                    SSeconomy.spawn_cash_for_amount(G.cash_reward, get_turf(actor))
                    to_chat(actor, span_boldnotice("Research Goal Completed: [G.title]! +[G.points_reward] points, [G.cash_reward] cr awarded."))
                // Department budget reward to R&D
                if(SSeconomy && isnum(G.budget_reward) && G.budget_reward > 0)
                    var/datum/bank_account/department/rd_budget = SSeconomy.department_accounts_by_id[ACCOUNT_RND]
                    if(rd_budget)
                        rd_budget.adjust_money(G.budget_reward)
                        var/msg = "R&D budget increased by [G.budget_reward] credits for goal [G.title]."
                        log_game("SCP-Research: [msg]")
                        if(actor)
                            to_chat(actor, span_notice(msg))
                // Log event
                event_log += list(list(
                    "time" = world.time,
                    "designation" = designation,
                    "event" = "goal_complete",
                    "ckey" = actor ? actor.ckey : null,
                    "name" = actor ? actor.name : "N/A",
                    "details" = G.id
                ))
                if(!G.repeatable)
                    completed_goals += G
                    active_goals -= G
                else
                    if(!(G in completed_goals))
                        completed_goals += G

    /datum/controller/subsystem/scp_research/proc/submit_report(mob/user, title, body, designation)
        var/ckey = user ? user.ckey : null
        var/name = user ? user.name : "N/A"
        var/id = "R[world.time]_[rand(1000,9999)]"
        // Truncate to guard size
        if(length(title) > 128)
            title = copytext(title, 1, 129)
        if(length(body) > 8000)
            body = copytext(body, 1, 8001)
        var/list/report = list(
            "id" = id,
            "time" = world.time,
            "ckey" = ckey,
            "name" = name,
            "designation" = designation,
            "title" = title,
            "body" = body,
            "status" = "submitted"
        )
        reports += list(report)
        // Optional: small point reward for paperwork
        points_total += 1
        if(ckey)
            points_by_ckey[ckey] = (points_by_ckey[ckey] || 0) + 1

        // Debug: Log report submission
        log_game("SCP-Research: Report submitted - ID: [id], Title: [title], Designation: [designation], Total reports: [length(reports)]")

        return id

    /datum/controller/subsystem/scp_research/proc/get_reports(limit = 20)
        var/list/out = list()
        var/start = max(1, length(reports) - limit + 1)
        for(var/i in start to length(reports))
            out += list(reports[i])

        // Debug: Log report retrieval
        log_game("SCP-Research: get_reports called - Total reports: [length(reports)], Returning: [length(out)], Limit: [limit]")

        return out

    // SCP-106 event handlers
    /datum/controller/subsystem/scp_research/proc/on_106_portal_opened(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "106"
        award(source, null, designation, "portal_opened", 2)

    /datum/controller/subsystem/scp_research/proc/on_106_portal_used(datum/source, atom/movable/crosser)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "106"
        var/mob/living/carbon/human/H = ishuman(crosser) ? crosser : null
        award(source, H, designation, "portal_used", 1)

    /datum/controller/subsystem/scp_research/proc/on_106_corrosion(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "106"
        award(source, null, designation, "corrosion", 1)

    /datum/controller/subsystem/scp_research/proc/on_106_abducted(datum/source, mob/living/carbon/human/victim)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "106"
        award(source, victim, designation, "abducted", 4)

    /datum/controller/subsystem/scp_research/proc/on_106_returned(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "106"
        award(source, null, designation, "returned", 2)

    // SCP-049 event handlers
    /datum/controller/subsystem/scp_research/proc/on_049_cure_started(datum/source, mob/living/carbon/human/patient)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "049"
        award(source, null, designation, "cure_started", 3, "SCP-049 started cure on [patient]")

    /datum/controller/subsystem/scp_research/proc/on_049_cure_successful(datum/source, mob/living/carbon/human/patient)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "049"
        award(source, null, designation, "cure_successful", 5, "SCP-049 successfully cured [patient]")

    /datum/controller/subsystem/scp_research/proc/on_049_cure_failed(datum/source, mob/living/carbon/human/patient)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "049"
        award(source, null, designation, "cure_failed", 2, "SCP-049's cure failed on [patient]")

    /datum/controller/subsystem/scp_research/proc/on_049_patient_examined(datum/source, mob/living/carbon/human/patient, examination_result)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "049"
        award(source, null, designation, "patient_examined", 1, "SCP-049 examined [patient]: [examination_result]")

    /datum/controller/subsystem/scp_research/proc/on_049_cure_researched(datum/source, cure_type, success_rate)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "049"
        award(source, null, designation, "cure_researched", 4, "SCP-049 researched [cure_type] cure (success rate: [success_rate]%)")

    /datum/controller/subsystem/scp_research/proc/on_049_zombie_created(datum/source, mob/living/carbon/human/zombie)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "049"
        award(source, null, designation, "zombie_created", 8, "SCP-049 created zombie from [zombie]")

    // SCP-096 event handlers
    /datum/controller/subsystem/scp_research/proc/on_096_rage_triggered(datum/source, mob/living/carbon/human/target)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "096"
        award(source, null, designation, "rage_triggered", 6, "SCP-096 rage triggered by [target]")

    /datum/controller/subsystem/scp_research/proc/on_096_rage_ended(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "096"
        award(source, null, designation, "rage_ended", 3, "SCP-096 rage mode ended")

    /datum/controller/subsystem/scp_research/proc/on_096_containment_activated(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "096"
        award(source, null, designation, "containment_activated", 4, "SCP-096 containment protocol activated")

    /datum/controller/subsystem/scp_research/proc/on_096_containment_deactivated(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "096"
        award(source, null, designation, "containment_deactivated", 2, "SCP-096 containment protocol deactivated")

    // SCP-173 event handlers
    /datum/controller/subsystem/scp_research/proc/on_173_eye_contact_made(datum/source, mob/living/carbon/human/viewer)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "173"
        award(source, null, designation, "eye_contact_made", 2, "SCP-173 eye contact made by [viewer]")

    /datum/controller/subsystem/scp_research/proc/on_173_eye_contact_broken(datum/source, mob/living/carbon/human/viewer)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "173"
        award(source, null, designation, "eye_contact_broken", 1, "SCP-173 eye contact broken by [viewer]")

    /datum/controller/subsystem/scp_research/proc/on_173_neck_snapped(datum/source, mob/living/carbon/human/victim)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "173"
        award(source, null, designation, "neck_snapped", 8, "SCP-173 snapped [victim]'s neck")

    /datum/controller/subsystem/scp_research/proc/on_173_containment_activated(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "173"
        award(source, null, designation, "containment_activated", 4, "SCP-173 containment protocol activated")

    /datum/controller/subsystem/scp_research/proc/on_173_containment_deactivated(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "173"
        award(source, null, designation, "containment_deactivated", 2, "SCP-173 containment protocol deactivated")

    // SCP-682 event handlers
    /datum/controller/subsystem/scp_research/proc/on_682_adapted(datum/source, adaptation_type)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "682"
        award(source, null, designation, "adapted", 5, "SCP-682 adapted to [adaptation_type]")

    /datum/controller/subsystem/scp_research/proc/on_682_evolved(datum/source, evolution_stage)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "682"
        award(source, null, designation, "evolved", 10, "SCP-682 evolved to stage [evolution_stage]")

    /datum/controller/subsystem/scp_research/proc/on_682_containment_activated(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "682"
        award(source, null, designation, "containment_activated", 4, "SCP-682 containment protocol activated")

    /datum/controller/subsystem/scp_research/proc/on_682_containment_deactivated(datum/source)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "682"
        award(source, null, designation, "containment_deactivated", 2, "SCP-682 containment protocol deactivated")

    /datum/controller/subsystem/scp_research/proc/on_682_attacked(datum/source, mob/living/target)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "682"
        award(source, null, designation, "attacked", 3, "SCP-682 attacked [target]")

    // SCP-035 event handlers
    /datum/controller/subsystem/scp_research/proc/on_035_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "035"
        award(source, host, designation, "possession_started", 4, "SCP-035 started possessing [host] as [personality.name]")

    /datum/controller/subsystem/scp_research/proc/on_035_possession_ended(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "035"
        award(source, host, designation, "possession_ended", 2, "SCP-035 ended possession of [host]")

    /datum/controller/subsystem/scp_research/proc/on_035_personality_changed(datum/source, datum/scp035_personality/old_personality, datum/scp035_personality/new_personality)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "035"
        award(source, null, designation, "personality_changed", 3, "SCP-035 changed from [old_personality.name] to [new_personality.name]")

    // SCP-087 event handlers
    /datum/controller/subsystem/scp_research/proc/on_087_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "087"
        award(source, explorer, designation, "exploration_started", 2, "SCP-087 exploration started by [explorer] at level [level.level_number]")

    /datum/controller/subsystem/scp_research/proc/on_087_exploration_ended(datum/source, mob/living/carbon/human/explorer, level_reached)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "087"
        award(source, explorer, designation, "exploration_ended", 3, "SCP-087 exploration ended by [explorer] at level [level_reached]")

    /datum/controller/subsystem/scp_research/proc/on_087_level_descended(datum/source, mob/living/carbon/human/explorer, new_level)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "087"
        award(source, explorer, designation, "level_descended", 2, "SCP-087 descended to level [new_level] by [explorer]")

    /datum/controller/subsystem/scp_research/proc/on_087_entity_spawned(datum/source, mob/living/carbon/human/explorer, mob/living/entity, datum/scp087_level/level)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "087"
        var/entity_name = entity ? entity.name : "unknown entity"
        award(source, explorer, designation, "entity_spawned", 5, "SCP-087 spawned [entity_name] for [explorer] at level [level.level_number]")

    /datum/controller/subsystem/scp_research/proc/on_087_portal_created(datum/source, mob/living/carbon/human/explorer)
        SIGNAL_HANDLER
        var/designation = extract_designation_from(source) || "087"
        award(source, explorer, designation, "portal_created", 4, "SCP-087 portal created for [explorer]")



    // /datum/controller/subsystem/scp_research/proc/on_106_cross_scp_interaction(datum/source, mob/living/simple_animal/hostile/retaliate/scp106/corruptor)
    //     SIGNAL_HANDLER
    //     var/designation = extract_designation_from(source) || "106"
    //     var/target_designation = extract_designation_from(source)
    //     var/interaction_type = "scp_interaction"
    //
    //     // Determine specific interaction type based on signal
    //     if(source.SCP && target_designation)
    //         interaction_type = "cross_scp_[target_designation]"
    //
    //     award(source, corruptor, designation, interaction_type, 5, "Cross-SCP interaction with SCP-[target_designation]")


// Research Goal Datum
/datum/scp_research_goal
    var/id
    var/title
    var/desc
    var/list/designation_filter // list of strings like "012"; null means any
    var/list/event_filter // list of event strings; null means any
    var/required_count = 1
    var/current_count = 0
    var/points_reward = 0
    var/cash_reward = 0
    var/budget_reward = 0 // credits applied to R&D departmental budget
    var/repeatable = FALSE
    var/times_completed = 0

    /datum/scp_research_goal/New(id, title, desc, designation_filter, event_filter, required_count = 1, points_reward = 0, cash_reward = 0, budget_reward = 0, repeatable = FALSE)
        src.id = id
        src.title = title
        src.desc = desc
        src.designation_filter = designation_filter
        src.event_filter = event_filter
        src.required_count = required_count
        src.points_reward = points_reward
        src.cash_reward = cash_reward
        src.budget_reward = budget_reward
        src.repeatable = repeatable

    /datum/scp_research_goal/proc/matches(designation, event)
        if(designation_filter && !(designation in designation_filter))
            return FALSE
        if(event_filter && !(event in event_filter))
            return FALSE
        return TRUE

    /datum/scp_research_goal/proc/progress_event()
        current_count++
        if(current_count >= required_count)
            times_completed++
            if(repeatable)
                current_count = 0
            return TRUE
        return FALSE

