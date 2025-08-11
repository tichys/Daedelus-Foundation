// SCP-096 (The Shy Guy)

/datum/scp096_sight_tracker
	var/mob/living/carbon/human/viewer
	var/view_time = 0
	var/triggered = FALSE
	var/rage_cooldown = 0

/datum/scp096_sight_tracker/New(mob/living/carbon/human/V)
	viewer = V
	view_time = world.time

/datum/scp096_sight_tracker/proc/trigger_rage()
	if(triggered || world.time < rage_cooldown)
		return FALSE
	triggered = TRUE
	rage_cooldown = world.time + 300 SECONDS // 5 minute cooldown
	return TRUE

// Global sight tracking
GLOBAL_LIST_INIT(scp096_viewers, list())

/mob/living/simple_animal/hostile/scp096
	name = "shy guy"
	desc = "A tall, pale humanoid with unnaturally long arms and no visible facial features."
	icon = 'icons/scp/scp-096.dmi'
	icon_state = "096"
	icon_living = "096"
	icon_dead = "096_dead"
	maxHealth = 1000
	health = 1000
	see_in_dark = 8
	move_to_delay = 2
	melee_damage_lower = 30
	melee_damage_upper = 50
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE

	// SCP-096 specific variables
	var/rage_mode = FALSE
	var/rage_duration = 60 SECONDS
	var/rage_start_time = 0
	var/list/sight_trackers = list()
	var/containment_breached = FALSE
	var/containment_field_active = FALSE
	var/rage_target = null
	var/rage_speed_multiplier = 3
	var/rage_damage_multiplier = 2
	var/melee_damage_multiplier = 1.0
	var/list/containment_protocols = list()

/mob/living/simple_animal/hostile/scp096/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"shy guy",
		SCP_KETER,
		"096",
		SCP_PLAYABLE
	)
	grant_language(/datum/language/common, TRUE, TRUE)
	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp096/proc/CheckSightStatus,
		/mob/living/simple_animal/hostile/scp096/proc/InteractWithSCP,
		/mob/living/simple_animal/hostile/scp096/proc/ContainmentProtocol,
	))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

// SCP-096 abilities
/mob/living/simple_animal/hostile/scp096/proc/CheckSightStatus()
	set category = "SCP-096"
	set name = "Check Sight Status"

	to_chat(src, span_notice("=== SCP-096 Sight Status ==="))
	to_chat(src, span_notice("Rage Mode: [rage_mode ? "ACTIVE" : "Inactive"]"))
	to_chat(src, span_notice("Containment Breached: [containment_breached ? "YES" : "NO"]"))
	to_chat(src, span_notice("Active Viewers: [length(sight_trackers)]"))

	for(var/datum/scp096_sight_tracker/tracker in sight_trackers)
		if(tracker.viewer)
			to_chat(src, span_notice("- [tracker.viewer.name] (Triggered: [tracker.triggered ? "YES" : "NO"])"))

	to_chat(src, span_notice("=========================="))

/mob/living/simple_animal/hostile/scp096/proc/InteractWithSCP()
	set category = "SCP-096"
	set name = "Interact with SCP"

	var/list/nearby_scps = list()
	for(var/atom/A in range(3, src))
		if(A.SCP && A != src)
			nearby_scps += A

	if(!nearby_scps.len)
		to_chat(src, span_warning("No SCPs nearby to interact with."))
		return

	var/atom/selected_scp = input(src, "Select SCP to interact with:", "SCP Interaction") as null|anything in nearby_scps
	if(!selected_scp)
		return

	// SCP-specific interactions
	var/scp_id = selected_scp.SCP.designation
	switch(scp_id)
		if("049")
			interact_with_049(selected_scp)
		if("106")
			interact_with_106(selected_scp)
		if("173")
			interact_with_173(selected_scp)
		else
			generic_scp_interaction(selected_scp)

/mob/living/simple_animal/hostile/scp096/proc/ContainmentProtocol()
	set category = "SCP-096"
	set name = "Containment Protocol"

	if(containment_breached)
		to_chat(src, span_warning("Containment has been breached. Protocol activation required."))
		activate_containment_protocol()
	else
		to_chat(src, span_notice("Containment is currently stable."))

// Cross-SCP interaction methods
/mob/living/simple_animal/hostile/scp096/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can affect SCP-096
	if(victim == rage_target)
		to_chat(src, span_warning("The corrosive effect interferes with your rage!"))
		// Reduce rage duration
		rage_duration = max(30 SECONDS, rage_duration - 15 SECONDS)

/mob/living/simple_animal/hostile/scp096/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can calm SCP-096
	if(patient == rage_target)
		to_chat(src, span_notice("The cure's power calms your rage."))
		to_chat(patient, span_notice("SCP-096 seems to be calmed by the cure."))
		end_rage_mode()

/mob/living/simple_animal/hostile/scp096/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can immobilize SCP-096
	if(viewer in sight_trackers)
		to_chat(src, span_warning("The statue's gaze immobilizes you!"))
		to_chat(viewer, span_notice("SCP-173 immobilizes SCP-096."))
		// Temporarily reduce movement speed
		move_to_delay = move_to_delay * 2

/mob/living/simple_animal/hostile/scp096/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-096's rage
	if(adaptor == rage_target)
		to_chat(src, span_warning("Your target's adaptation makes them harder to eliminate!"))
		to_chat(adaptor, span_notice("Your adaptation helps you resist SCP-096's attacks."))
		// Increase damage resistance for the target
		melee_damage_multiplier = max(1.0, melee_damage_multiplier - 0.5)

/mob/living/simple_animal/hostile/scp096/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-096
	if(host in sight_trackers)
		to_chat(src, span_notice("The mask's personality affects your behavior."))
		to_chat(host, span_notice("The mask's influence affects SCP-096."))
		// Modify rage behavior based on personality
		if(personality.aggression_level >= 8)
			rage_duration += 30 SECONDS
		else
			rage_duration = max(30 SECONDS, rage_duration - 15 SECONDS)

/mob/living/simple_animal/hostile/scp096/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-096's rage
	if(explorer in sight_trackers)
		to_chat(src, span_warning("The stairwell's psychological pressure amplifies your rage!"))
		to_chat(explorer, span_danger("SCP-096's rage is amplified by the stairwell!"))
		rage_duration += 30 SECONDS
		rage_speed_multiplier += 0.5

// SCP-specific interaction methods
/mob/living/simple_animal/hostile/scp096/proc/interact_with_049(atom/scp049)
	to_chat(src, span_notice("You attempt to avoid the plague doctor's attention."))
	if(prob(80))
		to_chat(src, span_green("You successfully avoid SCP-049's cure attempts."))
		SEND_SIGNAL(scp049, COMSIG_SCP049_CURE_AVOIDED, src)
	else
		to_chat(src, span_warning("SCP-049 notices you and attempts to cure you."))

/mob/living/simple_animal/hostile/scp096/proc/interact_with_106(atom/scp106)
	to_chat(src, span_notice("You attempt to avoid SCP-106's pocket dimension."))
	if(prob(70))
		to_chat(src, span_green("You successfully avoid SCP-106's abduction attempt."))
		SEND_SIGNAL(scp106, COMSIG_SCP106_ABDUCTION_AVOIDED, src)
	else
		to_chat(src, span_warning("SCP-106 attempts to drag you into its pocket dimension!"))

/mob/living/simple_animal/hostile/scp096/proc/interact_with_173(atom/scp173)
	to_chat(src, span_notice("You attempt to maintain eye contact with SCP-173."))
	if(prob(60))
		to_chat(src, span_green("You successfully maintain eye contact with SCP-173."))
		SEND_SIGNAL(scp173, COMSIG_SCP173_EYE_CONTACT_MAINTAINED, src)
	else
		to_chat(src, span_warning("You lose eye contact with SCP-173!"))
		rage_mode = TRUE
		rage_start_time = world.time

/mob/living/simple_animal/hostile/scp096/proc/generic_scp_interaction(atom/scp)
	to_chat(src, span_notice("You attempt to interact with [scp.SCP.designation]."))
	if(prob(50))
		to_chat(src, span_green("You successfully interact with [scp.SCP.designation]."))
		SEND_SIGNAL(scp, COMSIG_SCP_INTERACTED, src)
	else
		to_chat(src, span_warning("[scp.SCP.designation] resists your interaction."))

// Sight tracking system
/mob/living/simple_animal/hostile/scp096/proc/add_viewer(mob/living/carbon/human/viewer)
	if(!viewer || viewer in sight_trackers)
		return

	var/datum/scp096_sight_tracker/tracker = new(viewer)
	sight_trackers += tracker
	GLOB.scp096_viewers += tracker

	to_chat(viewer, span_danger("You have seen SCP-096's face!"))
	to_chat(src, span_warning("[viewer] has seen your face!"))

	// Apply sanity and vision effects to viewer
	viewer.adjustSanity(-30, "scp096_face_sight")
	viewer.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 300 SECONDS, 3)
	viewer.add_sanity_effect(SANITY_EFFECT_PARANOIA, 360 SECONDS, 3)
	viewer.add_sanity_effect(SANITY_EFFECT_ANXIETY, 240 SECONDS, 2)
			// Vision effects removed (Foundation-19 style)

	// Trigger rage if not already in rage mode
	if(!rage_mode && tracker.trigger_rage())
		trigger_rage_mode(viewer)

/mob/living/simple_animal/hostile/scp096/proc/trigger_rage_mode(mob/living/carbon/human/target)
	if(rage_mode)
		return

	rage_mode = TRUE
	rage_target = target
	rage_start_time = world.time

	// Enhance abilities during rage
	move_to_delay = move_to_delay / rage_speed_multiplier
	melee_damage_lower *= rage_damage_multiplier
	melee_damage_upper *= rage_damage_multiplier

	to_chat(src, span_danger("RAGE MODE ACTIVATED! You must eliminate [target]!"))
	to_chat(target, span_danger("SCP-096 is now enraged and hunting you!"))

	// Apply additional effects to target
	target.adjustSanity(-50, "scp096_rage_target")
	target.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 600 SECONDS, 4)
	target.add_sanity_effect(SANITY_EFFECT_PARANOIA, 720 SECONDS, 4)
	target.add_sanity_effect(SANITY_EFFECT_ANXIETY, 480 SECONDS, 3)
			// Vision effects removed (Foundation-19 style)

	containment_breached = TRUE
	SEND_SIGNAL(src, COMSIG_SCP096_RAGE_TRIGGERED, target)

/mob/living/simple_animal/hostile/scp096/proc/end_rage_mode()
	if(!rage_mode)
		return

	rage_mode = FALSE
	rage_target = null

	// Restore normal abilities
	move_to_delay = 2
	melee_damage_lower = 30
	melee_damage_upper = 50

	to_chat(src, span_notice("Rage mode has ended. You return to your normal state."))
	SEND_SIGNAL(src, COMSIG_SCP096_RAGE_ENDED)

/mob/living/simple_animal/hostile/scp096/proc/activate_containment_protocol()
	containment_field_active = TRUE
	to_chat(src, span_warning("Containment protocol activated. Movement restricted."))

	// Add containment effects
	// add_trait(TRAIT_IMMOBILIZED, "containment")
	// add_trait(TRAIT_MUTE, "containment")

	// Containment field visual effect
	var/obj/effect/containment_field/field = new(get_turf(src))
	field.target = src

	SEND_SIGNAL(src, COMSIG_SCP096_CONTAINMENT_ACTIVATED)

/mob/living/simple_animal/hostile/scp096/proc/deactivate_containment_protocol()
	containment_field_active = FALSE
	to_chat(src, span_notice("Containment protocol deactivated."))

	// Remove containment effects
	// remove_trait(TRAIT_IMMOBILIZED, "containment")
	// remove_trait(TRAIT_MUTE, "containment")

	SEND_SIGNAL(src, COMSIG_SCP096_CONTAINMENT_DEACTIVATED)

// Life process to handle rage mode and sight tracking
/mob/living/simple_animal/hostile/scp096/Life()
	. = ..()
	if(.)
		process_rage_mode()
		process_sight_tracking()

/mob/living/simple_animal/hostile/scp096/proc/process_rage_mode()
	if(!rage_mode)
		return

	// Check if rage duration has expired
	if(world.time - rage_start_time > rage_duration)
		end_rage_mode()
		return

	// If rage target is dead or gone, end rage
	if(!rage_target || !istype(rage_target, /mob/living))
		end_rage_mode()
		return

	var/mob/living/L = rage_target
	if(L.stat == DEAD || !L.loc)
		end_rage_mode()
		return

	// Move towards rage target
	if(rage_target in view(7, src))
		walk_to(src, rage_target, 1, move_to_delay)

/mob/living/simple_animal/hostile/scp096/proc/process_sight_tracking()
	// Check for new viewers
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.client && H.stat != DEAD && !(H in sight_trackers))
			// Check if they can see SCP-096's face
			if(can_see_face(H))
				add_viewer(H)

/mob/living/simple_animal/hostile/scp096/proc/can_see_face(mob/living/carbon/human/viewer)
	// Check if viewer has line of sight to SCP-096's face
	var/turf/viewer_turf = get_turf(viewer)
	var/turf/scp_turf = get_turf(src)

	if(!viewer_turf || !scp_turf)
		return FALSE

	// Check line of sight
	var/list/line = get_line(viewer_turf, scp_turf)
	for(var/turf/T in line)
		if(T == viewer_turf || T == scp_turf)
			continue
		if(T.density)
			return FALSE

	return TRUE

// Override attack to use rage mechanics
/mob/living/simple_animal/hostile/scp096/UnarmedAttack(atom/A, proximity)
	if(rage_mode && isliving(A) && A == rage_target)
		// Enhanced attack against rage target
		var/mob/living/L = A
		L.adjustBruteLoss(melee_damage_upper)
		L.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)

		// Apply additional sanity damage
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.adjustSanity(-25, "scp096_attack")
			H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 120 SECONDS, 2)
			// Vision effects removed (Foundation-19 style)

		to_chat(L, span_danger("SCP-096 tears you apart with incredible force!"))
		to_chat(src, span_green("You eliminate your target!"))

		// End rage mode after eliminating target
		end_rage_mode()
		return

	. = ..()

// Containment field effect
/obj/effect/containment_field
	name = "containment field"
	desc = "A shimmering containment field designed to hold SCP-096."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	anchored = TRUE
	density = FALSE
	var/atom/target = null

/obj/effect/containment_field/Initialize()
	. = ..()
	if(target)
		forceMove(get_turf(target))

/obj/effect/containment_field/process()
	if(!target || !target.loc)
		qdel(src)
		return

	forceMove(get_turf(target))

// Research goals for SCP-096
/datum/scp_research_goal/scp096_sight
	id = "096_sight"
	title = "SCP-096 Sight Tracking"
	desc = "Document instances where personnel have seen SCP-096's face."
	designation_filter = list("096")
	event_filter = list("sight_triggered")
	required_count = 3
	points_reward = 15
	cash_reward = 1500
	budget_reward = 750
	repeatable = TRUE

/datum/scp_research_goal/scp096_rage
	id = "096_rage"
	title = "SCP-096 Rage Mode Analysis"
	desc = "Study SCP-096's rage mode behavior and containment effectiveness."
	designation_filter = list("096")
	event_filter = list("rage_triggered", "rage_ended")
	required_count = 2
	points_reward = 20
	cash_reward = 2000
	budget_reward = 1000
	repeatable = TRUE
