// SCP-173 (The Sculpture)

/datum/scp173_eye_tracker
	var/mob/living/carbon/human/viewer
	var/last_eye_contact = 0
	var/eye_contact_duration = 0
	var/break_contact_time = 0

/datum/scp173_eye_tracker/New(mob/living/carbon/human/V)
	viewer = V
	last_eye_contact = world.time

/datum/scp173_eye_tracker/proc/update_eye_contact()
	var/current_time = world.time
	eye_contact_duration = current_time - last_eye_contact
	return eye_contact_duration

// Global eye contact tracking
GLOBAL_LIST_INIT(scp173_viewers, list())

/mob/living/simple_animal/hostile/scp173
	name = "sculpture"
	desc = "A concrete sculpture resembling a humanoid figure with a featureless face."
	icon = 'icons/scp/scp-173.dmi'
	icon_state = "173"
	icon_living = "173"
	icon_dead = "173_dead"
	maxHealth = 1200
	health = 1200
	see_in_dark = 8
	move_to_delay = 1
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = 'sound/weapons/punch1.ogg'
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	check_friendly_fire = FALSE

	// SCP-173 specific variables
	var/list/eye_trackers = list()
	var/immobilized = TRUE
	var/neck_snap_cooldown = 10 SECONDS
	var/last_neck_snap = 0
	var/containment_breached = FALSE
	var/containment_field_active = FALSE
	var/list/containment_protocols = list()
	var/eye_contact_threshold = 2 SECONDS // Time without eye contact before moving
	var/movement_speed = 3
	var/list/neck_snap_victims = list()

/mob/living/simple_animal/hostile/scp173/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"sculpture",
		SCP_KETER,
		"173",
		SCP_PLAYABLE
	)
	grant_language(/datum/language/common, TRUE, TRUE)
	add_verb(src, list(
		/mob/living/simple_animal/hostile/scp173/proc/CheckEyeContact,
		/mob/living/simple_animal/hostile/scp173/proc/InteractWithSCP,
		/mob/living/simple_animal/hostile/scp173/proc/ContainmentProtocol,
	))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

// SCP-173 abilities
/mob/living/simple_animal/hostile/scp173/proc/CheckEyeContact()
	set category = "SCP-173"
	set name = "Check Eye Contact"

	to_chat(src, span_notice("=== SCP-173 Eye Contact Status ==="))
	to_chat(src, span_notice("Immobilized: [immobilized ? "YES" : "NO"]"))
	to_chat(src, span_notice("Containment Breached: [containment_breached ? "YES" : "NO"]"))
	to_chat(src, span_notice("Active Viewers: [length(eye_trackers)]"))

	for(var/datum/scp173_eye_tracker/tracker in eye_trackers)
		if(tracker.viewer)
			var/contact_duration = tracker.update_eye_contact()
			to_chat(src, span_notice("- [tracker.viewer.name] (Contact: [contact_duration/10]s)"))

	to_chat(src, span_notice("================================"))

/mob/living/simple_animal/hostile/scp173/proc/InteractWithSCP()
	set category = "SCP-173"
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
		if("096")
			interact_with_096(selected_scp)
		if("106")
			interact_with_106(selected_scp)
		else
			generic_scp_interaction(selected_scp)

/mob/living/simple_animal/hostile/scp173/proc/ContainmentProtocol()
	set category = "SCP-173"
	set name = "Containment Protocol"

	if(containment_breached)
		to_chat(src, span_warning("Containment has been breached. Protocol activation required."))
		activate_containment_protocol()
	else
		to_chat(src, span_notice("Containment is currently stable."))

// Cross-SCP interaction methods
/mob/living/simple_animal/hostile/scp173/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can affect SCP-173
	to_chat(src, span_warning("The corrosive effect damages your concrete form!"))
	// Reduce health temporarily
	adjustHealth(100)

/mob/living/simple_animal/hostile/scp173/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can affect SCP-173
	to_chat(src, span_warning("The cure attempts to affect your anomalous properties!"))
	// Temporarily reduce movement speed
	movement_speed = min(5, movement_speed + 1)

/mob/living/simple_animal/hostile/scp173/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can interact with SCP-173
	if(target in eye_trackers)
		to_chat(src, span_notice("The raging entity breaks eye contact!"))
		to_chat(target, span_warning("Your rage breaks eye contact with SCP-173!"))
		remove_viewer(target)

/mob/living/simple_animal/hostile/scp173/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-173's effects
	if(adaptor in eye_trackers)
		to_chat(src, span_warning("Your target's adaptation makes them harder to immobilize!"))
		to_chat(adaptor, span_notice("Your adaptation helps you resist SCP-173's immobilization."))
		// Reduce immobilization effectiveness
		eye_contact_threshold = max(1 SECONDS, eye_contact_threshold - 0.5 SECONDS)

/mob/living/simple_animal/hostile/scp173/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-173
	if(host in eye_trackers)
		to_chat(src, span_notice("The mask's personality affects your behavior."))
		to_chat(host, span_notice("The mask's influence affects SCP-173."))
		// Modify behavior based on personality
		if(personality.aggression_level >= 8)
			movement_speed = max(2, movement_speed - 1)
		else
			movement_speed = min(5, movement_speed + 1)

/mob/living/simple_animal/hostile/scp173/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can affect SCP-173's behavior
	if(explorer in eye_trackers)
		to_chat(src, span_warning("The stairwell's psychological pressure affects your behavior!"))
		to_chat(explorer, span_danger("SCP-173's behavior is affected by the stairwell!"))
		// Increase movement speed in stairwell
		movement_speed = max(2, movement_speed - 1)

// SCP-specific interaction methods
/mob/living/simple_animal/hostile/scp173/proc/interact_with_049(atom/scp049)
	to_chat(src, span_notice("You attempt to avoid the plague doctor's cure attempts."))
	if(prob(70))
		to_chat(src, span_green("You successfully avoid SCP-049's cure attempts."))
		SEND_SIGNAL(scp049, COMSIG_SCP049_CURE_AVOIDED, src)
	else
		to_chat(src, span_warning("SCP-049 attempts to cure you."))

/mob/living/simple_animal/hostile/scp173/proc/interact_with_096(atom/scp096)
	to_chat(src, span_notice("You attempt to maintain eye contact with SCP-096."))
	if(prob(80))
		to_chat(src, span_green("You successfully maintain eye contact with SCP-096."))
		SEND_SIGNAL(scp096, COMSIG_SCP096_EYE_CONTACT_MAINTAINED, src)
	else
		to_chat(src, span_warning("You lose eye contact with SCP-096!"))

/mob/living/simple_animal/hostile/scp173/proc/interact_with_106(atom/scp106)
	to_chat(src, span_notice("You attempt to avoid SCP-106's pocket dimension."))
	if(prob(60))
		to_chat(src, span_green("You successfully avoid SCP-106's abduction attempt."))
		SEND_SIGNAL(scp106, COMSIG_SCP106_ABDUCTION_AVOIDED, src)
	else
		to_chat(src, span_warning("SCP-106 attempts to drag you into its pocket dimension!"))

/mob/living/simple_animal/hostile/scp173/proc/generic_scp_interaction(atom/scp)
	to_chat(src, span_notice("You attempt to interact with [scp.SCP.designation]."))
	if(prob(50))
		to_chat(src, span_green("You successfully interact with [scp.SCP.designation]."))
		SEND_SIGNAL(scp, COMSIG_SCP_INTERACTED, src)
	else
		to_chat(src, span_warning("[scp.SCP.designation] resists your interaction."))

// Eye contact tracking system
/mob/living/simple_animal/hostile/scp173/proc/add_viewer(mob/living/carbon/human/viewer)
	if(!viewer || viewer in eye_trackers)
		return

	var/datum/scp173_eye_tracker/tracker = new(viewer)
	eye_trackers += tracker
	GLOB.scp173_viewers += tracker

	to_chat(viewer, span_danger("You have made eye contact with SCP-173!"))
	to_chat(src, span_warning("[viewer] is watching you!"))

	// Apply sanity and vision effects to viewer
	viewer.adjustSanity(-20, "scp173_eye_contact")
	viewer.add_sanity_effect(SANITY_EFFECT_PARANOIA, 240 SECONDS, 2)
	viewer.add_sanity_effect(SANITY_EFFECT_ANXIETY, 180 SECONDS, 2)
			// Vision effects removed (Foundation-19 style)

	// Immobilize SCP-173 when being watched
	immobilized = TRUE
	SEND_SIGNAL(src, COMSIG_SCP173_EYE_CONTACT_MADE, viewer)

/mob/living/simple_animal/hostile/scp173/proc/remove_viewer(mob/living/carbon/human/viewer)
	if(!viewer || !(viewer in eye_trackers))
		return

	eye_trackers -= viewer
	GLOB.scp173_viewers -= viewer

	to_chat(viewer, span_notice("You have broken eye contact with SCP-173."))
	to_chat(src, span_notice("[viewer] has stopped watching you."))

	// Remove effects from viewer
	viewer.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
	viewer.remove_sanity_effect(SANITY_EFFECT_ANXIETY)

	// Check if any viewers remain
	if(!eye_trackers.len)
		immobilized = FALSE
		SEND_SIGNAL(src, COMSIG_SCP173_EYE_CONTACT_BROKEN, viewer)

/mob/living/simple_animal/hostile/scp173/proc/activate_containment_protocol()
	containment_field_active = TRUE
	to_chat(src, span_warning("Containment protocol activated. Movement restricted."))

	// Add containment effects
	// add_trait(TRAIT_IMMOBILIZED, "containment")
	// add_trait(TRAIT_MUTE, "containment")

	// Containment field visual effect
	var/obj/effect/containment_field/field = new(get_turf(src))
	field.target = src

	SEND_SIGNAL(src, COMSIG_SCP173_CONTAINMENT_ACTIVATED)

/mob/living/simple_animal/hostile/scp173/proc/deactivate_containment_protocol()
	containment_field_active = FALSE
	to_chat(src, span_notice("Containment protocol deactivated."))

	// Remove containment effects
	// remove_trait(TRAIT_IMMOBILIZED, "containment")
	// remove_trait(TRAIT_MUTE, "containment")

	SEND_SIGNAL(src, COMSIG_SCP173_CONTAINMENT_DEACTIVATED)

// Life process to handle eye contact and movement
/mob/living/simple_animal/hostile/scp173/Life()
	. = ..()
	if(.)
		process_eye_contact()
		process_movement()

/mob/living/simple_animal/hostile/scp173/proc/process_eye_contact()
	// Check for new viewers
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.client && H.stat != DEAD)
			// Check if they can see SCP-173
			if(can_see_scp173(H))
				if(!(H in eye_trackers))
					add_viewer(H)
			else
				if(H in eye_trackers)
					remove_viewer(H)

	// Update existing viewers
	for(var/datum/scp173_eye_tracker/tracker in eye_trackers)
		if(!tracker.viewer || tracker.viewer.stat == DEAD || !can_see_scp173(tracker.viewer))
			remove_viewer(tracker.viewer)

/mob/living/simple_animal/hostile/scp173/proc/process_movement()
	if(immobilized || containment_field_active)
		return

	// Find nearest target to move towards
	var/mob/living/carbon/human/nearest_target = null
	var/shortest_distance = INFINITY

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.stat != DEAD && H != src)
			var/distance = get_dist(src, H)
			if(distance < shortest_distance)
				shortest_distance = distance
				nearest_target = H

	if(nearest_target)
		// Move towards target
		walk_to(src, nearest_target, 1, movement_speed)

		// Check if close enough to attack
		if(get_dist(src, nearest_target) <= 1)
			attempt_neck_snap(nearest_target)

/mob/living/simple_animal/hostile/scp173/proc/can_see_scp173(mob/living/carbon/human/viewer)
	// Check if viewer has line of sight to SCP-173
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

/mob/living/simple_animal/hostile/scp173/proc/attempt_neck_snap(mob/living/carbon/human/target)
	if(world.time - last_neck_snap < neck_snap_cooldown)
		return

	if(!target || target.stat == DEAD)
		return

	// Perform neck snap
	last_neck_snap = world.time
	target.adjustBruteLoss(100)
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50)

	// Apply sanity and vision effects
	target.adjustSanity(-40, "scp173_neck_snap")
	target.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 300 SECONDS, 3)
	target.add_sanity_effect(SANITY_EFFECT_PARANOIA, 360 SECONDS, 3)
			// Vision effects removed (Foundation-19 style)

	to_chat(target, span_danger("SCP-173 snaps your neck!"))
	to_chat(src, span_green("You snap [target]'s neck!"))

	neck_snap_victims += target
	SEND_SIGNAL(src, COMSIG_SCP173_NECK_SNAPPED, target)

// Override attack to use neck snap mechanics
/mob/living/simple_animal/hostile/scp173/UnarmedAttack(atom/A, proximity)
	if(proximity && isliving(A) && ishuman(A))
		var/mob/living/carbon/human/H = A
		attempt_neck_snap(H)
		return

	. = ..()

// Research goals for SCP-173
/datum/scp_research_goal/scp173_eye_contact
	id = "173_eye_contact"
	title = "SCP-173 Eye Contact Tracking"
	desc = "Document instances of eye contact with SCP-173 and its immobilization effects."
	designation_filter = list("173")
	event_filter = list("eye_contact_made", "eye_contact_broken")
	required_count = 5
	points_reward = 12
	cash_reward = 1200
	budget_reward = 600
	repeatable = TRUE

/datum/scp_research_goal/scp173_neck_snaps
	id = "173_neck_snaps"
	title = "SCP-173 Neck Snap Analysis"
	desc = "Study SCP-173's neck snapping behavior and victim patterns."
	designation_filter = list("173")
	event_filter = list("neck_snapped")
	required_count = 3
	points_reward = 18
	cash_reward = 1800
	budget_reward = 900
	repeatable = TRUE
