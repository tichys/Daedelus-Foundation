/obj/item/scp513
	name = "SCP-513"
	desc = "A small cowbell that produces an unsettling sound when rung. It seems to cause fear and paranoia in those who hear it."
	icon = 'icons/scp/scp-513.dmi'
	icon_state = "bell"
	var/ring_cooldown = 0
	var/ring_cooldown_time = 30 SECONDS
	var/fear_radius = 5
	var/list/affected_targets = list()
	var/list/fear_levels = list()
	var/ring_count = 0
	var/max_fear_level = 100

	// Persistence tracking
	var/rings_performed = 0
	var/fear_induced = 0
	var/panic_events = 0
	var/containment_status = "contained"

/obj/item/scp513/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-513",
		SCP_EUCLID,
		"513",
		SCP_DISABLED
	)

	SCP.min_playercount = 15
	SCP.min_time = 20 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-513"] = new /datum/scp_instance("SCP-513", src)

/obj/item/scp513/Destroy()
	affected_targets = list()
	fear_levels = list()
	return ..()

// Ring the cowbell
/obj/item/scp513/proc/ring_bell(mob/user)
	if(world.time < ring_cooldown)
		return

	ring_cooldown = world.time + ring_cooldown_time
	ring_count++
	rings_performed++
	containment_status = "breached"

	visible_message("<span class='danger'>[user] rings SCP-513!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	// Affect nearby targets
	affect_nearby_targets(user)

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-513"]
		if(instance)
			instance.add_interaction_record(user, "ring_bell")

// Affect nearby targets with fear
/obj/item/scp513/proc/affect_nearby_targets(mob/user)
	for(var/mob/living/carbon/human/H in range(fear_radius, src))
		if(H == user || H.SCP || H.stat == DEAD)
			continue

		apply_fear_effect(H)

// Apply fear effect to target
/obj/item/scp513/proc/apply_fear_effect(mob/living/carbon/human/target)
	if(!target)
		return

	// Initialize fear level if not present
	if(!(target in fear_levels))
		fear_levels[target] = 0

	// Increase fear level
	fear_levels[target] = min(max_fear_level, fear_levels[target] + 20)
	fear_induced++

	// Add to affected targets
	if(!(target in affected_targets))
		affected_targets += target

	// Apply fear effects based on level
	var/fear_level = fear_levels[target]

	if(fear_level >= 20)
		to_chat(target, "<span class='warning'>You hear an unsettling sound that fills you with unease.</span>")
		target.stamina.adjust(-10)

	if(fear_level >= 40)
		to_chat(target, "<span class='danger'>The sound is getting louder! You feel paranoid and afraid.</span>")
		target.stamina.adjust(-20)
		target.adjustBruteLoss(5)

	if(fear_level >= 60)
		to_chat(target, "<span class='danger'>The sound is overwhelming! You're in a state of panic!</span>")
		target.stamina.adjust(-30)
		target.adjustBruteLoss(10)
		panic_events++

		// Random movement
		if(prob(30))
			var/list/directions = list(NORTH, SOUTH, EAST, WEST)
			target.forceMove(get_step(target, pick(directions)))

	if(fear_level >= 80)
		to_chat(target, "<span class='danger'>You can't take it anymore! The fear is consuming you!</span>")
		target.stamina.adjust(-50)
		target.adjustBruteLoss(20)

		// Flee in random direction
		var/list/directions = list(NORTH, SOUTH, EAST, WEST)
		for(var/i = 1 to 3)
			target.forceMove(get_step(target, pick(directions)))

	if(fear_level >= 100)
		to_chat(target, "<span class='danger'>The fear has driven you to the brink of madness!</span>")
		target.stamina.adjust(-100)
		target.adjustBruteLoss(30)

		// Temporary insanity effect
		spawn(300) // 30 seconds
			if(target && target.stat != DEAD)
				to_chat(target, "<span class='notice'>The fear begins to subside...</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-513"]
		if(instance)
			instance.add_interaction_record(target, "fear_induced")

// Attack behavior - ring when used
/obj/item/scp513/attack_self(mob/user)
	ring_bell(user)

// Verb commands
/obj/item/scp513/verb/ring_bell_verb()
	set name = "Ring Bell"
	set category = "SCP"
	set desc = "Ring SCP-513 to cause fear in nearby targets."

	ring_bell(usr)

/obj/item/scp513/verb/expand_fear_radius()
	set name = "Expand Fear Radius"
	set category = "SCP"
	set desc = "Expand the radius of fear effects."

	fear_radius = min(10, fear_radius + 1)
	to_chat(usr, "<span class='notice'>Fear radius expanded to [fear_radius] tiles.</span>")

/obj/item/scp513/verb/view_fear_status()
	set name = "View Fear Status"
	set category = "SCP"
	set desc = "View the fear status of nearby targets."

	var/message = "<h2>SCP-513 Fear Status</h2>"
	message += "<b>Fear Radius:</b> [fear_radius] tiles<br>"
	message += "<b>Total Rings:</b> [rings_performed]<br>"
	message += "<b>Fear Induced:</b> [fear_induced]<br>"
	message += "<b>Panic Events:</b> [panic_events]<br><br>"

	if(fear_levels.len)
		message += "<h3>Affected Targets:</h3>"
		for(var/mob/living/carbon/human/H in fear_levels)
			var/fear_level = fear_levels[H]
			message += "- [H.name]: Fear Level [fear_level]/[max_fear_level]<br>"
	else
		message += "<i>No targets currently affected.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/scp513/verb/reset_fear_levels()
	set name = "Reset Fear Levels"
	set category = "SCP"
	set desc = "Reset all fear levels to zero."

	fear_levels.Cut()
	affected_targets.Cut()
	to_chat(usr, "<span class='notice'>All fear levels have been reset.</span>")

// Admin verb to view SCP-513 persistence data
/obj/item/scp513/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-513 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-513 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Rings Performed:</b> [rings_performed]<br>"
	message += "<b>Fear Induced:</b> [fear_induced]<br>"
	message += "<b>Panic Events:</b> [panic_events]<br>"
	message += "<b>Affected Targets:</b> [affected_targets.len]<br>"
	message += "<b>Fear Radius:</b> [fear_radius] tiles<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-513"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Human interaction - when humans hear the bell
/mob/living/carbon/human/proc/hear_scp513()
	if(!src || stat == DEAD)
		return

	// Apply immediate fear effect
	stamina.adjust(-15)
	adjustBruteLoss(5)

	to_chat(src, "<span class='danger'>You hear an unsettling sound that fills you with dread!</span>")

	// Random panic behavior
	if(prob(25))
		var/list/directions = list(NORTH, SOUTH, EAST, WEST)
		forceMove(get_step(src, pick(directions)))
		to_chat(src, "<span class='danger'>You panic and move involuntarily!</span>")

// Override examine for SCP-513
/obj/item/scp513/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-513, a cowbell that induces fear and paranoia in those who hear it.</span>")
		else
			to_chat(user, "<span class='danger'>A small cowbell that seems to radiate an aura of unease. You feel anxious just looking at it.</span>")


