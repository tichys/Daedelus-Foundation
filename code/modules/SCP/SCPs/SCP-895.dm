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

/obj/machinery/camera/scp895/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-895",
		SCP_EUCLID,
		"895",
		SCP_DISABLED
	)

	SCP.min_playercount = 15
	SCP.min_time = 20 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-895"] = new /datum/scp_instance("SCP-895", src)

/obj/machinery/camera/scp895/Destroy()
	affected_targets.Cut()
	sickness_levels.Cut()
	return ..()

// Core mechanics
/obj/machinery/camera/scp895/process()
	. = ..()

	// Affect nearby targets
	affect_nearby_targets()

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

// Verb commands
/obj/machinery/camera/scp895/verb/view_feed_verb()
	set name = "View Camera Feed"
	set category = "SCP"
	set desc = "View the SCP-895 camera feed (warning: may cause sickness)."

	view_camera_feed(usr)

/obj/machinery/camera/scp895/verb/expand_sickness_radius()
	set name = "Expand Sickness Radius"
	set category = "SCP"
	set desc = "Expand the radius of sickness effects."

	sickness_radius = min(8, sickness_radius + 1)
	to_chat(usr, "<span class='notice'>Sickness radius expanded to [sickness_radius] tiles.</span>")

/obj/machinery/camera/scp895/verb/view_sickness_status()
	set name = "View Sickness Status"
	set category = "SCP"
	set desc = "View the sickness status of nearby targets."

	var/message = "<h2>SCP-895 Sickness Status</h2>"
	message += "<b>Sickness Radius:</b> [sickness_radius] tiles<br>"
	message += "<b>Total Views:</b> [views_caused]<br>"
	message += "<b>Sickness Induced:</b> [sickness_induced]<br>"
	message += "<b>Vomiting Events:</b> [vomiting_events]<br><br>"

	if(sickness_levels.len)
		message += "<h3>Affected Targets:</h3>"
		for(var/mob/living/carbon/human/H in sickness_levels)
			var/sickness_level = sickness_levels[H]
			message += "- [H.name]: Sickness Level [sickness_level]/[max_sickness_level]<br>"
	else
		message += "<i>No targets currently affected.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/machinery/camera/scp895/verb/reset_sickness_levels()
	set name = "Reset Sickness Levels"
	set category = "SCP"
	set desc = "Reset all sickness levels to zero."

	sickness_levels.Cut()
	affected_targets.Cut()
	to_chat(usr, "<span class='notice'>All sickness levels have been reset.</span>")

// Admin verb to view SCP-895 persistence data
/obj/machinery/camera/scp895/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-895 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-895 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Views Caused:</b> [views_caused]<br>"
	message += "<b>Sickness Induced:</b> [sickness_induced]<br>"
	message += "<b>Vomiting Events:</b> [vomiting_events]<br>"
	message += "<b>Affected Targets:</b> [affected_targets.len]<br>"
	message += "<b>Sickness Radius:</b> [sickness_radius] tiles<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-895"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

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

// Override camera functionality
/obj/machinery/camera/scp895/attack_hand(mob/living/carbon/human/user)
	if(ishuman(user))
		view_camera_feed(user)
		return TRUE
	return ..()


