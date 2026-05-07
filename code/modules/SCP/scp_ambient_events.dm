/datum/controller/subsystem/scp_ambient
	var/list/ambient_events = list()

/datum/controller/subsystem/scp_ambient/proc/add_ambient_events()
	ambient_events = list(
		/datum/controller/subsystem/scp_ambient/proc/event_distant_screams,
		/datum/controller/subsystem/scp_ambient/proc/event_facility_hum_change,
		/datum/controller/subsystem/scp_ambient/proc/event_pa_static,
		/datum/controller/subsystem/scp_ambient/proc/event_emergency_light_flicker,
		/datum/controller/subsystem/scp_ambient/proc/event_door_malfunction,
		/datum/controller/subsystem/scp_ambient/proc/event_temperature_drop,
		/datum/controller/subsystem/scp_ambient/proc/event_shadow_movement,
		/datum/controller/subsystem/scp_ambient/proc/event_containment_rumble,
	)

/datum/controller/subsystem/scp_ambient/proc/event_distant_screams()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(40))
			to_chat(H, "<span class='warning'>You hear distant screams echoing through the facility corridors...</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-3, "distant_screams_ambient")

/datum/controller/subsystem/scp_ambient/proc/event_facility_hum_change()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(20))
			to_chat(H, "<span class='notice'>The ambient hum of the facility shifts pitch momentarily, sending a chill down your spine.</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-2, "facility_hum_change_ambient")

/datum/controller/subsystem/scp_ambient/proc/event_pa_static()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(15))
			playsound(H, 'sound/effects/phasein.ogg', 30, TRUE)
			to_chat(H, "<span class='warning'>The PA system crackles with static... a garbled announcement fades into noise.</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-2, "pa_static_ambient")

/datum/controller/subsystem/scp_ambient/proc/event_emergency_light_flicker()
	var/list/valid_areas = list()
	for(var/area/scp/A in world)
		valid_areas += A
	if(!length(valid_areas))
		return
	var/area/scp/target_area = pick(valid_areas)
	for(var/obj/machinery/light/L in target_area)
		if(prob(50))
			L.flicker(3)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(A == target_area)
			to_chat(H, "<span class='warning'>The emergency lights flicker violently around you!</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-1, "emergency_light_flicker_ambient")

/datum/controller/subsystem/scp_ambient/proc/event_door_malfunction()
	var/list/valid_airlocks = list()
	for(var/obj/machinery/door/airlock/AL in world)
		var/area/A = get_area(AL)
		if(istype(A, /area/scp/))
			valid_airlocks += AL
	if(!length(valid_airlocks))
		return
	var/obj/machinery/door/airlock/target = pick(valid_airlocks)
	if(target.density)
		playsound(target, 'sound/machines/door_open.ogg', 40, TRUE)
		target.open()
	else
		playsound(target, 'sound/machines/door_close.ogg', 40, TRUE)
		target.close()
	for(var/mob/living/carbon/human/H in view(7, target))
		if(H.stat == DEAD || !H.client)
			continue
		to_chat(H, "<span class='warning'>The door operates on its own...</span>")

/datum/controller/subsystem/scp_ambient/proc/event_temperature_drop()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(30))
			to_chat(H, "<span class='warning'>A sudden chill washes over you. The temperature seems to drop without explanation.</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-1, "temperature_drop_ambient")

/datum/controller/subsystem/scp_ambient/proc/event_shadow_movement()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(25))
			to_chat(H, "<span class='warning'>You catch a shadow moving in your peripheral vision, but nothing is there when you look...</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-4, "shadow_movement_ambient")

/datum/controller/subsystem/scp_ambient/proc/event_containment_rumble()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		playsound(H, 'sound/effects/bamf.ogg', 40, TRUE)
		to_chat(H, "<span class='warning'>A deep rumbling reverberates through the walls from the containment areas...</span>")
		if(H.sanity)
			H.sanity.adjust_sanity(-2, "containment_rumble_ambient")
