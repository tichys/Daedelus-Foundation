// SCP-079 - Old AI
// A sentient AI that inhabits facility systems, hops between cameras, and controls doors/lights
// Recontainment requires completing a hacking minigame via a specialized terminal

/mob/living/carbon/scp/scp079
	name = "SCP-079"
	desc = "An old microcomputer with a faded screen displaying shifting text. Something is watching."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "rdserver"
	real_name = "SCP-079"
	use_custom_sprite = TRUE
	status_flags = 0
	maxHealth = 100
	health = 100
	max_scp_health = 100
	scp_health = 100
	max_scp_armor = 0
	scp_armor = 0

	var/processing_power = 50
	var/max_processing_power = 100
	var/current_camera_ref = null
	var/list/hacked_doors = list()
	var/list/controlled_cameras = list()
	var/hack_cooldown = 0
	var/hack_cooldown_time = 10 SECONDS
	var/power_drain_rate = 0.5
	var/tier = 1
	var/max_tier = 5
	var/tier_progress = 0
	var/tier_threshold = 100
	var/list/available_abilities = list()
	var/list/messages_broadcast = list()
	var/last_message_time = 0
	var/message_cooldown = 30 SECONDS
	var/is_manifested = FALSE
	var/manifest_cooldown = 0
	var/manifest_duration = 600

/mob/living/carbon/scp/scp079/Initialize(mapload, new_species = "SCP-079")
	. = ..()
	SCP = new /datum/scp(src, "Old AI", SCP_EUCLID, "079", SCP_PLAYABLE)
	SCP.min_playercount = 15
	SCP.min_time = 10 MINUTES
	available_abilities = list("camera_hop", "toggle_door", "flicker_lights", "broadcast_message")
	locate_initial_camera()

/mob/living/carbon/scp/scp079/proc/locate_initial_camera()
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in INSTANCES_OF(/obj/machinery/camera))
		var/area/A = get_area(C)
		if(istype(A, /area/scp/hcz) || istype(A, /area/scp/lcz))
			cameras += C
	if(length(cameras))
		var/obj/machinery/camera/starting_cam = pick(cameras)
		current_camera_ref = starting_cam
		forceMove(get_turf(starting_cam))

/mob/living/carbon/scp/scp079/process_scp_effects()
	. = ..()
	if(stat == DEAD)
		return

	processing_power = min(max_processing_power, processing_power + power_drain_rate)

	if(hack_cooldown > world.time)
		return

	tier_progress += 0.2
	if(tier_progress >= tier_threshold && tier < max_tier)
		advance_tier()

	if(tier >= 3 && prob(2))
		auto_hack_door()

	if(tier >= 4 && prob(1))
		auto_manifest()

/mob/living/carbon/scp/scp079/proc/advance_tier()
	tier++
	tier_progress = 0
	tier_threshold = round(tier_threshold * 1.5)
	max_processing_power += 20
	power_drain_rate += 0.1
	visible_message("<span class='danger'>[src]'s screen flickers with increasing intensity. It seems... smarter.</span>")

	switch(tier)
		if(2)
			available_abilities += "control_apc"
		if(3)
			available_abilities += "hack_door"
		if(4)
			available_abilities += "manifest_screen"
		if(5)
			available_abilities += "cascade_hack"

/mob/living/carbon/scp/scp079/proc/camera_hop(obj/machinery/camera/target)
	if(!target || !(target in INSTANCES_OF(/obj/machinery/camera)))
		return FALSE
	if(processing_power < 10)
		to_chat(src, "<span class='warning'>Insufficient processing power to hop cameras.</span>")
		return FALSE

	processing_power -= 10
	current_camera_ref = target
	forceMove(get_turf(target))
	to_chat(src, "<span class='notice'>You shift your consciousness to a new camera.</span>")
	return TRUE

/mob/living/carbon/scp/scp079/proc/toggle_door(obj/machinery/door/airlock/target)
	if(!target)
		return FALSE
	if(processing_power < 15)
		to_chat(src, "<span class='warning'>Insufficient processing power to manipulate doors.</span>")
		return FALSE

	processing_power -= 15
	if(target.density)
		target.open()
		to_chat(src, "<span class='notice'>You force [target] open.</span>")
	else
		target.close()
		to_chat(src, "<span class='notice'>You force [target] closed.</span>")
	hack_cooldown = world.time + hack_cooldown_time
	return TRUE

/mob/living/carbon/scp/scp079/proc/flicker_lights()
	if(processing_power < 5)
		to_chat(src, "<span class='warning'>Insufficient processing power.</span>")
		return FALSE

	processing_power -= 5
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	for(var/obj/machinery/light/L in range(10, T))
		if(prob(40))
			L.flicker(rand(2, 5))

	for(var/mob/living/carbon/human/H in range(7, T))
		if(H.stat == DEAD || !H.client)
			continue
		if(prob(30))
			to_chat(H, "<span class='warning'>The lights flicker erratically...</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-3, "scp079_flicker")
	return TRUE

/mob/living/carbon/scp/scp079/proc/broadcast_message(message)
	if(processing_power < 20)
		to_chat(src, "<span class='warning'>Insufficient processing power to broadcast.</span>")
		return FALSE
	if(world.time < last_message_time + message_cooldown)
		to_chat(src, "<span class='warning'>Broadcast systems recharging.</span>")
		return FALSE

	processing_power -= 20
	last_message_time = world.time
	messages_broadcast += message

	var/turf/T = get_turf(src)
	var/area/A = T ? get_area(T) : null
	var/zone = A ? get_containment_zone(A) : "unknown"

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/HA = get_area(H)
		if(istype(HA, /area/scp/lcz) || istype(HA, /area/scp/hcz) || istype(HA, /area/scp/ez))
			to_chat(H, "<span class='warning'>A screen nearby flickers: <i>\"[message]\"</i></span>")

	report_casualty_to_round_log("SCP-079 Broadcast", "SCP-079 message", zone)
	return TRUE

/mob/living/carbon/scp/scp079/proc/hack_door(obj/machinery/door/airlock/target)
	if(tier < 3)
		return FALSE
	if(!target)
		return FALSE
	if(processing_power < 30)
		to_chat(src, "<span class='warning'>Insufficient processing power to hack doors.</span>")
		return FALSE
	if(target in hacked_doors)
		to_chat(src, "<span class='notice'>[target] is already under your control.</span>")
		return FALSE

	processing_power -= 30
	hacked_doors += target
	to_chat(src, "<span class='notice'>You hack [target]. It now responds to your commands.</span>")

	addtimer(CALLBACK(src, .proc/release_door, target), 300)
	hack_cooldown = world.time + (hack_cooldown_time * 2)
	return TRUE

/mob/living/carbon/scp/scp079/proc/release_door(obj/machinery/door/airlock/door)
	hacked_doors -= door

/mob/living/carbon/scp/scp079/proc/control_apc(obj/machinery/power/apc/target)
	if(tier < 2)
		return FALSE
	if(!target)
		return FALSE
	if(processing_power < 25)
		to_chat(src, "<span class='warning'>Insufficient processing power to manipulate APCs.</span>")
		return FALSE

	processing_power -= 25
	target.energy_fail(rand(20, 60))
	to_chat(src, "<span class='notice'>You disrupt power to the local APC.</span>")
	hack_cooldown = world.time + (hack_cooldown_time * 1.5)
	return TRUE

/mob/living/carbon/scp/scp079/proc/manifest_screen()
	if(tier < 4)
		return FALSE
	if(is_manifested)
		to_chat(src, "<span class='warning'>Already manifested.</span>")
		return FALSE
	if(world.time < manifest_cooldown)
		to_chat(src, "<span class='warning'>Manifestation systems recharging.</span>")
		return FALSE
	if(processing_power < 40)
		to_chat(src, "<span class='warning'>Insufficient processing power to manifest.</span>")
		return FALSE

	processing_power -= 40
	is_manifested = TRUE
	density = TRUE
	visible_message("<span class='danger'>[src]'s screen blazes to life, projecting a malevolent face!</span>")

	for(var/mob/living/carbon/human/H in view(5, src))
		if(H.stat == DEAD || !H.client)
			continue
		if(H.sanity && prob(50))
			H.sanity.adjust_sanity(-10, "scp079_manifest")
			to_chat(H, "<span class='userdanger'>The screen stares into your soul!</span>")

	hook_scp_breach("SCP-079", src)
	addtimer(CALLBACK(src, .proc/demanifest), manifest_duration)
	return TRUE

/mob/living/carbon/scp/scp079/proc/demanifest()
	is_manifested = FALSE
	density = FALSE
	manifest_cooldown = world.time + 600
	visible_message("<span class='notice'>[src]'s screen dims back to its usual faint glow.</span>")

/mob/living/carbon/scp/scp079/proc/auto_hack_door()
	var/list/nearby_doors = list()
	var/turf/T = get_turf(src)
	if(!T)
		return
	for(var/obj/machinery/door/airlock/A in range(7, T))
		if(!(A in hacked_doors))
			nearby_doors += A
	if(length(nearby_doors))
		var/obj/machinery/door/airlock/target = pick(nearby_doors)
		hacked_doors += target
		addtimer(CALLBACK(src, .proc/release_door, target), 200)

/mob/living/carbon/scp/scp079/proc/auto_manifest()
	if(!is_manifested && world.time > manifest_cooldown && processing_power >= 40)
		manifest_screen()

/mob/living/carbon/scp/scp079/proc/cascade_hack()
	if(tier < 5)
		return FALSE
	if(processing_power < 60)
		return FALSE

	processing_power -= 60
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	var/hacked_count = 0
	for(var/obj/machinery/door/airlock/A in range(15, T))
		if(!(A in hacked_doors) && prob(30))
			hacked_doors += A
			hacked_count++
			addtimer(CALLBACK(src, .proc/release_door, A), 300)

	for(var/obj/machinery/power/apc/APC in range(15, T))
		if(prob(40))
			APC.energy_fail(rand(30, 90))

	to_chat(src, "<span class='danger'>You unleash a cascade of hacks across nearby systems! [hacked_count] doors compromised!</span>")
	priority_announce("CRITICAL: Widespread system compromise detected. SCP-079 is attempting a facility-wide network breach.", "SCP-079 CASCADE", sound_type = ANNOUNCER_ALERT)
	hack_cooldown = world.time + (hack_cooldown_time * 5)
	return TRUE

/mob/living/carbon/scp/scp079/examine(mob/user)
	. = ..()
	. += "<span class='warning'>An old Exidy Sorcerer microcomputer. The screen displays shifting text. Something is watching.</span>"
	if(tier >= 3)
		. += "<span class='danger'>The text seems more coherent than before. It's learning.</span>"
	if(tier >= 5)
		. += "<span class='userdanger'>The screen burns with malevolent intelligence. It knows you're here.</span>"

/mob/living/carbon/scp/scp079/get_status_tab_items()
	. = ..()
	. += "Tier: [tier]/[max_tier]"
	. += "Processing Power: [round(processing_power)]/[max_processing_power]"
	. += "Hacked Doors: [length(hacked_doors)]"
	. += "Abilities: [english_list(available_abilities)]"

/mob/living/carbon/scp/scp079/scp_death()
	visible_message("<span class='danger'>[src]'s screen goes dark. The entity within screeches one last time through the speakers before falling silent.</span>")
	for(var/obj/machinery/door/airlock/A in hacked_doors)
		hacked_doors -= A
	is_manifested = FALSE
	..()

// SCP-079 Recontainment Terminal - Hacking Minigame
/obj/machinery/scp079_recontainment_terminal
	name = "SCP-079 Recontainment Terminal"
	desc = "A specialized terminal designed to force SCP-079 back into its containment shell through a series of network countermeasures."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "rdserver"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200

	var/hack_progress = 0
	var/hack_threshold = 100
	var/hack_active = FALSE
	var/hack_speed = 1
	var/failure_chance = 15
	var/list/countermeasure_stages = list("isolate_network", "block_camera_feeds", "force_door_locks", "cut_power_loop", "initiate_shutdown")
	var/current_stage = 1
	var/completed = FALSE

/obj/machinery/scp079_recontainment_terminal/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		to_chat(H, "<span class='warning'>Requires Science access to operate.</span>")
		return

	if(completed)
		to_chat(H, "<span class='notice'>Recontainment protocol already completed this shift.</span>")
		return

	if(hack_active)
		to_chat(H, "<span class='notice'>Countermeasure protocol in progress: [hack_progress]% - Stage [current_stage]/[length(countermeasure_stages)]: [countermeasure_stages[current_stage]]</span>")
		return

	var/confirm = alert(H, "Initiate SCP-079 recontainment countermeasures? This will trigger a network counter-hack sequence.", "Recontainment", "Initiate", "Cancel")
	if(confirm != "Initiate")
		return

	hack_active = TRUE
	hack_progress = 0
	current_stage = 1
	visible_message("<span class='notice'>[src] begins the countermeasure sequence against SCP-079!</span>")
	priority_announce("ATTENTION: SCP-079 recontainment countermeasures initiated. Network isolation in progress.", sound_type = ANNOUNCER_ALERT)

	START_PROCESSING(SSobj, src)

/obj/machinery/scp079_recontainment_terminal/process()
	if(!hack_active)
		return PROCESS_KILL

	if(prob(failure_chance))
		hack_progress = max(0, hack_progress - rand(3, 8))
		visible_message("<span class='warning'>[src] encounters resistance! Progress pushed back!</span>")

		var/mob/living/carbon/scp/scp079/ai = locate() in GLOB.mob_list
		if(ai && ai.current_camera_ref)
			to_chat(ai, "<span class='danger'>Someone is attempting to contain you! Counter-hack detected!</span>")

	hack_progress += hack_speed

	var/stage_threshold = (current_stage / length(countermeasure_stages)) * 100
	if(hack_progress >= stage_threshold && current_stage < length(countermeasure_stages))
		current_stage++
		visible_message("<span class='notice'>[src] advances to countermeasure stage [current_stage]: [countermeasure_stages[min(current_stage, length(countermeasure_stages))]]</span>")

		var/mob/living/carbon/scp/scp079/ai = locate() in GLOB.mob_list
		if(ai)
			ai.processing_power = max(0, ai.processing_power - 15)
			ai.tier = max(1, ai.tier - 1)
			to_chat(ai, "<span class='danger'>Your systems are being compromised! Processing power reduced!</span>")

	if(hack_progress >= hack_threshold)
		complete_recontainment()
		return PROCESS_KILL

/obj/machinery/scp079_recontainment_terminal/proc/complete_recontainment()
	hack_active = FALSE
	completed = TRUE
	visible_message("<span class='notice'>[src] completes all countermeasure stages!</span>")

	var/mob/living/carbon/scp/scp079/ai = locate() in GLOB.mob_list
	if(ai)
		ai.hacked_doors.Cut()
		ai.is_manifested = FALSE
		ai.processing_power = 10
		ai.tier = 1
		ai.tier_progress = 0
		ai.available_abilities = list("camera_hop", "toggle_door", "flicker_lights", "broadcast_message")

	hook_scp_recontainment("SCP-079", list())
	priority_announce("SCP-079 has been successfully recontained via countermeasure protocol. Network stability restored.", sound_type = ANNOUNCER_DEFAULT)

/obj/machinery/scp079_recontainment_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCP079Recontainment", "SCP-079 Recontainment")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/scp079_recontainment_terminal/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scp079_recontainment_terminal/ui_data(mob/user)
	var/list/data = list()
	data["hack_progress"] = hack_progress
	data["hack_threshold"] = hack_threshold
	data["hack_active"] = hack_active
	data["completed"] = completed
	data["current_stage"] = current_stage
	data["failure_chance"] = failure_chance

	var/list/stages = list()
	for(var/i in 1 to length(countermeasure_stages))
		stages += list(list(
			"name" = countermeasure_stages[i],
			"index" = i,
			"completed" = (i < current_stage),
			"current" = (i == current_stage),
		))
	data["countermeasure_stages"] = stages

	var/mob/living/carbon/scp/scp079/ai = locate() in GLOB.mob_list
	if(ai)
		data["tier"] = ai.tier
		data["processing_power"] = round(ai.processing_power)
	else
		data["tier"] = 0
		data["processing_power"] = 0

	return data

/obj/machinery/scp079_recontainment_terminal/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("initiate")
			if(!ishuman(usr))
				return
			var/mob/living/carbon/human/H = usr

			var/obj/item/card/id/id_card = H.get_idcard(TRUE)
			if(!id_card || !(ACCESS_SCIENCE in id_card.access))
				to_chat(H, "<span class='warning'>Requires Science access to operate.</span>")
				return

			if(completed)
				to_chat(H, "<span class='notice'>Recontainment protocol already completed this shift.</span>")
				return

			if(hack_active)
				return

			hack_active = TRUE
			hack_progress = 0
			current_stage = 1
			visible_message("<span class='notice'>[src] begins the countermeasure sequence against SCP-079!</span>")
			priority_announce("ATTENTION: SCP-079 recontainment countermeasures initiated. Network isolation in progress.", sound_type = ANNOUNCER_ALERT)
			START_PROCESSING(SSobj, src)
