// SCP-173 - The Sculpture
// A concrete statue that moves when not observed

/mob/living/carbon/scp/scp173
	name = "SCP-173"
	desc = "A concrete statue of a humanoid figure. It seems to be watching you."
	icon = 'icons/scp/scp-173.dmi'
	icon_state = "scp173"
	real_name = "SCP-173"

	// SCP-173 specific variables
	var/move_cooldown = 0
	var/move_cooldown_time = 2 SECONDS
	var/containment_area = null

	// Persistence tracking
	var/kills_count = 0

/mob/living/carbon/scp/scp173/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-173",
		SCP_KETER,
		"173",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 20
	SCP_datum.min_time = 30 MINUTES

	containment_area = get_area(src)

	// Set up SCP-specific properties
	max_scp_health = 300
	scp_health = max_scp_health
	max_scp_armor = 100
	scp_armor = max_scp_armor

	// Add SCP abilities
	add_ability("snap_neck", "snap_neck_ability")

	// Add passive effects
	add_passive_effect("motion_detection")
	add_passive_effect("concrete_durability")

/mob/living/carbon/scp/scp173/Destroy()
	containment_area = null
	return ..()

// Override core mechanics
/mob/living/carbon/scp/scp173/process_scp_effects()
	. = ..()

	// Check if anyone can see us
	var/can_move = TRUE
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP)
			continue
		if(can_see(H, src))
			can_move = FALSE
			break

	// Move if no one is watching
	if(can_move && world.time >= move_cooldown)
		move_cooldown = world.time + move_cooldown_time

		// Find nearest target
		var/mob/living/target = null
		var/shortest_distance = 999
		for(var/mob/living/L in view(7, src))
			if(L == src || L.SCP)
				continue
			var/distance = get_dist(src, L)
			if(distance < shortest_distance)
				shortest_distance = distance
				target = L

		if(target)
			step_towards(src, target)

// Override containment check
/mob/living/carbon/scp/scp173/check_containment()
	if(containment_status == "breached")
		return

	// Check if we're still in containment area
	if(get_area(src) == containment_area)
		return

	// Breach containment if we're outside containment area
	breach_containment()

// Attack behavior
/mob/living/carbon/scp/scp173/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		visible_message("<span class='danger'>[src] snaps [H]'s neck!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
		H.adjustBruteLoss(100)

		// Track kill for persistence
		if(H.stat == DEAD)
			kills_count++
			add_interaction_record(H, "kill")

		return

	return ..()

// SCP-173 specific abilities
/mob/living/carbon/scp/scp173/proc/snap_neck_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(1, src))
		if(H != src)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets in range.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to snap the neck of:", "Snap Neck") as null|anything in targets
	if(target)
		UnarmedAttack(target)

// Override status display
/mob/living/carbon/scp/scp173/get_status_tab_items()
	. = ..()
	. += "Move Cooldown: [move_cooldown_time/10] seconds"
	. += "Kills: [kills_count]"

// Override examine behavior
/mob/living/carbon/scp/scp173/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-173, a concrete statue that moves when not observed.</span>")
		else
			to_chat(user, "<span class='danger'>A concrete statue. It seems to be watching you intently.</span>")

// Override SCP death
/mob/living/carbon/scp/scp173/scp_death()
	visible_message("<span class='danger'>[src] crumbles to pieces!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Verb commands
/mob/living/carbon/scp/scp173/verb/snap_neck()
	set name = "Snap Neck"
	set category = "SCP"
	set desc = "Snap the neck of a nearby target."

	snap_neck_ability()

// Override persistence data view
/mob/living/carbon/scp/scp173/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-173 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-173 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Kills Count:</b> [kills_count]<br>"
	message += "<b>Breach Count:</b> [breach_count]<br>"
	message += "<b>Last Breach Time:</b> [last_breach_time ? time2text(last_breach_time, "YYYY-MM-DD hh:mm:ss") : "Never"]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"
			message += "<b>Breach History:</b> [instance.breach_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")
