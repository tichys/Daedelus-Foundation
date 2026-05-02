/obj/machinery/camera/scp895
	name = "SCP-895"
	desc = "A security camera that seems to cause illness and discomfort in those who view its feed."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "camera"
	var/active = TRUE
	var/sickness_radius = 3
	var/list/affected_targets = list()
	var/list/sickness_levels = list()
	var/viewing_cooldown = 0
	var/viewing_cooldown_time = 10 SECONDS
	var/max_sickness_level = 100

	// Persistence tracking
	var/views_caused = 0
	var/sickness_induced = 0
	var/vomiting_events = 0
	var/containment_status = "contained"

	var/datum/scp895_sickness_system/sickness_system
	var/datum/scp895_research_system/research_system

/obj/machinery/camera/scp895/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-895",
		SCP_EUCLID,
		"895",
	)

	SCP.min_playercount = 15
	SCP.min_time = 20 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-895"] = new /datum/scp_instance("SCP-895", src)

	// Systems
	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

/obj/machinery/camera/scp895/proc/initialize_systems()
	sickness_system = new /datum/scp895_sickness_system(src)
	research_system = new /datum/scp895_research_system(src)

/obj/machinery/camera/scp895/Destroy()
	affected_targets = list()
	sickness_levels = list()
	return ..()

// Core mechanics
/obj/machinery/camera/scp895/process()
	. = ..()
	if(!active)
		return
	// Systems update
	sickness_system?.process_sickness()
	research_system?.process_research()

// Affect nearby targets with sickness
/obj/machinery/camera/scp895/proc/affect_nearby_targets()
	for(var/mob/living/carbon/human/H in range(sickness_radius, src))
		if(H.SCP || H.stat == DEAD)
			continue
		apply_sickness_effect(H)

// Apply sickness effect to target
/obj/machinery/camera/scp895/proc/apply_sickness_effect(mob/living/carbon/human/target)
	if(!target)
		return
	// Initialize sickness level if not present
	if(!(target in sickness_levels))
		sickness_levels[target] = 0
	// Increase sickness level
	sickness_levels[target] = min(max_sickness_level, sickness_levels[target] + 5)
	sickness_induced++
	// Add to affected targets
	if(!(target in affected_targets))
		affected_targets += target
	// Apply sickness effects based on level
	var/sickness_level = sickness_levels[target]
	if(sickness_level >= 20)
		to_chat(target, "<span class='warning'>You feel slightly nauseous looking at the camera.</span>")
		target.adjustToxLoss(2)
	if(sickness_level >= 40)
		to_chat(target, "<span class='danger'>The camera is making you feel very sick!</span>")
		target.adjustToxLoss(5)
		target.stamina.adjust(-10)
	if(sickness_level >= 60)
		to_chat(target, "<span class='danger'>You feel extremely ill! The camera feed is unbearable!</span>")
		target.adjustToxLoss(10)
		target.stamina.adjust(-20)
		// Random vomiting
		if(prob(30))
			vomiting_events++
			to_chat(target, "<span class='danger'>You vomit from the sickness!</span>")
			target.adjustToxLoss(15)
	if(sickness_level >= 80)
		to_chat(target, "<span class='danger'>The sickness is overwhelming! You can barely stand!</span>")
		target.adjustToxLoss(15)
		target.stamina.adjust(-30)
		// Force movement away
		if(prob(50))
			var/list/directions = list(NORTH, SOUTH, EAST, WEST)
			target.forceMove(get_step(target, pick(directions)))
			to_chat(target, "<span class='danger'>You stumble away from the camera!</span>")
	if(sickness_level >= 100)
		to_chat(target, "<span class='danger'>The sickness has reached critical levels! You're on the verge of collapse!</span>")
		target.adjustToxLoss(25)
		target.stamina.adjust(-50)
		// Temporary unconsciousness
		if(prob(20))
			target.Unconscious(100)
			to_chat(target, "<span class='danger'>You pass out from the extreme sickness!</span>")
	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-895"]
		if(instance)
			instance.add_interaction_record(target, "sickness_induced")

// When someone views the camera feed
/obj/machinery/camera/scp895/proc/view_camera_feed(mob/user)
	if(world.time < viewing_cooldown)
		return
	viewing_cooldown = world.time + viewing_cooldown_time
	views_caused++
	containment_status = "breached"
	to_chat(user, "<span class='danger'>You view the SCP-895 camera feed and immediately feel sick!</span>")
	// Apply immediate sickness effect
	apply_sickness_effect(user)
	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-895"]
		if(instance)
			instance.add_interaction_record(user, "viewed_feed")

// Human interaction - when humans view the camera
/mob/living/carbon/human/proc/view_scp895_camera()
	if(!src || stat == DEAD)
		return
	// Apply immediate sickness effect
	adjustToxLoss(10)
	stamina.adjust(-20)
	to_chat(src, "<span class='danger'>You feel extremely sick after viewing the camera feed!</span>")
	// Random vomiting
	if(prob(40))
		to_chat(src, "<span class='danger'>You vomit from the extreme sickness!</span>")
		adjustToxLoss(20)

// Override examine for SCP-895
/obj/machinery/camera/scp895/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-895, a camera that causes illness and sickness in those who view its feed.</span>")
		else
			to_chat(user, "<span class='danger'>A security camera that seems to radiate an aura of sickness. You feel nauseous just looking at it.</span>")

// Override camera functionality (no verbs; interaction via using the camera)
/obj/machinery/camera/scp895/attack_hand(mob/living/carbon/human/user)
	if(ishuman(user))
		view_camera_feed(user)
		hook_scp_interaction(user, "SCP-895", INTERACTION_TYPE_OBSERVATION)
		return TRUE
	return ..()

/obj/machinery/camera/scp895/proc/on_sickness_induced(mob/living/carbon/human/victim, level)
	if(!victim)
		return
	hook_scp_interaction(victim, "SCP-895", INTERACTION_TYPE_COMBAT)
	if(level >= 100)
		hook_player_death_near_scp(victim, "SCP-895")


