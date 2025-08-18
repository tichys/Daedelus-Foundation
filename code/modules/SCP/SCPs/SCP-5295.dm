// SCP-5295: Temporal Entity
// An entity that can manipulate time and create temporal anomalies

/mob/living/carbon/scp/scp5295
	name = "temporal entity"
	desc = "A mysterious entity that seems to exist outside of normal time. Temporal distortions occur around it."
	icon = 'icons/scp/scp-173.dmi'
	icon_state = "temporal"
	status_flags = 0
	maxHealth = 225
	health = 225
	max_scp_health = 225
	scp_health = 225
	max_scp_armor = 70
	scp_armor = 70

	// Temporal manipulation abilities
	var/time_dilation_cooldown = 0
	var/time_dilation_cooldown_time = 30 SECONDS
	var/temporal_anomaly_cooldown = 0
	var/temporal_anomaly_cooldown_time = 50 SECONDS
	var/time_dilation_radius = 4
	var/temporal_anomaly_duration = 45 SECONDS

/mob/living/carbon/scp/scp5295/Initialize(mapload, new_species = "SCP-5295")
	. = ..()
	SCP = new /datum/scp(src, "temporal entity", SCP_KETER, "5295", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	// Add abilities
	add_ability("dilate_time", "dilate_time_ability")
	add_ability("create_temporal_anomaly", "create_temporal_anomaly_ability")
	add_passive_effect("temporal_distortion", "temporal_distortion_effect")

	// Auto-registered via datum/scp

/mob/living/carbon/scp/scp5295/process_scp_effects()
	. = ..()

	if(stat == DEAD)
		return

	// Passive temporal distortion effects
	if(prob(2))
		visible_message("<span class='notice'>Temporal distortions occur around [src].</span>")

/mob/living/carbon/scp/scp5295/UnarmedAttack(atom/A)
	if(!A || !istype(A, /mob/living))
		return ..()

	var/mob/living/L = A
	if(L.stat == DEAD)
		return ..()

	// Temporal manipulation attack
	to_chat(src, "<span class='notice'>You manipulate time around [L].</span>")
	to_chat(L, "<span class='danger'>Time seems to bend and distort around you!</span>")

	// Random temporal effects
	var/temporal_effect = rand(1, 5)
	switch(temporal_effect)
		if(1)
			L.adjustBruteLoss(20)
			to_chat(L, "<span class='danger'>Time dilation causes you harm!</span>")
		if(2)
			L.adjustBruteLoss(25)
			to_chat(L, "<span class='danger'>Temporal distortion affects your body!</span>")
		if(3)
			L.adjustBruteLoss(30)
			to_chat(L, "<span class='danger'>Time itself seems to attack you!</span>")
		if(4)
			L.adjustBruteLoss(35)
			to_chat(L, "<span class='danger'>Temporal anomalies cause damage!</span>")
		if(5)
			L.adjustBruteLoss(40)
			to_chat(L, "<span class='danger'>The flow of time is disrupted!</span>")

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Log interaction
	SCP.log_interaction(L, "temporal_manipulation_attack")
	SCP.award_research(L, "anomaly", 30)

	return ..()

/mob/living/carbon/scp/scp5295/get_status_tab_items()
	. = ..()
	. += "Time Dilation Cooldown: [max(0, round((time_dilation_cooldown - world.time) / 10))] seconds"
	. += "Temporal Anomaly Cooldown: [max(0, round((temporal_anomaly_cooldown - world.time) / 10))] seconds"

/mob/living/carbon/scp/scp5295/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This entity can manipulate time and create temporal anomalies.</span>"
	. += "<span class='warning'>Time seems to flow differently around it.</span>"

/mob/living/carbon/scp/scp5295/scp_death()
	visible_message("<span class='danger'>[src] dissolves into temporal distortion!</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 50)
	..()

// Temporal manipulation abilities
/mob/living/carbon/scp/scp5295/proc/dilate_time_ability()
	set name = "Dilate Time"
	set desc = "Create a time dilation field"
	set category = "SCP"

	if(time_dilation_cooldown > world.time)
		to_chat(src, "<span class='warning'>Time dilation is still recharging...</span>")
		return

	to_chat(src, "<span class='notice'>You create a time dilation field.</span>")
	visible_message("<span class='danger'>[src] creates a time dilation field!</span>")

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Affect all living beings in range
	for(var/mob/living/L in range(time_dilation_radius, src))
		if(L == src)
			continue
		if(L.stat == DEAD)
			continue

		// Time dilation effects
		L.adjustBruteLoss(15)
		to_chat(L, "<span class='danger'>Time seems to slow down around you!</span>")

		SCP.log_interaction(L, "time_dilation_field")
		SCP.award_research(L, "anomaly", 25)

	time_dilation_cooldown = world.time + time_dilation_cooldown_time

/mob/living/carbon/scp/scp5295/proc/create_temporal_anomaly_ability()
	set name = "Create Temporal Anomaly"
	set desc = "Create a temporal anomaly"
	set category = "SCP"

	if(temporal_anomaly_cooldown > world.time)
		to_chat(src, "<span class='warning'>Temporal anomaly creation is still recharging...</span>")
		return

	var/list/anomaly_types = list("Time Loop", "Temporal Rift", "Chronological Distortion", "Temporal Storm")
	var/anomaly_type = input(src, "Choose anomaly type:", "Create Temporal Anomaly") as null|anything in anomaly_types

	if(!anomaly_type)
		return

	var/turf/target_turf = get_turf(src)
	if(!target_turf)
		return

	to_chat(src, "<span class='notice'>You create a [anomaly_type] anomaly.</span>")
	visible_message("<span class='danger'>[src] creates a [anomaly_type] anomaly!</span>")

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Create the temporal anomaly
	new /obj/effect/temporal_anomaly(target_turf, anomaly_type, temporal_anomaly_duration)

	temporal_anomaly_cooldown = world.time + temporal_anomaly_cooldown_time

/mob/living/carbon/scp/scp5295/proc/temporal_distortion_effect()
	// Passive temporal distortion effects
	if(prob(1))
		visible_message("<span class='notice'>Temporal distortions occur around [src].</span>")

// Temporal Anomaly Object
/obj/effect/temporal_anomaly
	name = "temporal anomaly"
	desc = "A distortion in time. It seems to affect the flow of time around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity"
	density = FALSE
	anchored = TRUE
	var/anomaly_type = "Unknown"
	var/duration = 45 SECONDS
	var/creation_time = 0
	var/effect_radius = 3

/obj/effect/temporal_anomaly/New(loc, type, dur)
	..()
	anomaly_type = type
	duration = dur
	creation_time = world.time

	// Set up the anomaly effect
	setup_temporal_anomaly_effect()

	// Auto-destruct after duration
	spawn(duration)
		qdel(src)

/obj/effect/temporal_anomaly/proc/setup_temporal_anomaly_effect()
	switch(anomaly_type)
		if("Time Loop")
			name = "time loop"
			desc = "A localized time loop that repeats events."
			icon_state = "timeloop"
		if("Temporal Rift")
			name = "temporal rift"
			desc = "A rift in time that can transport objects."
			icon_state = "temporalrift"
		if("Chronological Distortion")
			name = "chronological distortion"
			desc = "A field where time flows backwards."
			icon_state = "chronodist"
		if("Temporal Storm")
			name = "temporal storm"
			desc = "A storm of temporal energy."
			icon_state = "temporalstorm"

/obj/effect/temporal_anomaly/Crossed(atom/movable/AM)
	if(!AM || !istype(AM, /mob/living))
		return

	var/mob/living/L = AM
	to_chat(L, "<span class='danger'>You pass through a [anomaly_type] anomaly!</span>")

	switch(anomaly_type)
		if("Time Loop")
			L.adjustBruteLoss(10)
			to_chat(L, "<span class='warning'>You experience a time loop!</span>")
		if("Temporal Rift")
			var/turf/random_turf = pick(range(7, src))
			L.forceMove(random_turf)
			to_chat(L, "<span class='warning'>You are transported through the temporal rift!</span>")
		if("Chronological Distortion")
			L.adjustBruteLoss(15)
			to_chat(L, "<span class='warning'>Time flows backwards around you!</span>")
		if("Temporal Storm")
			L.adjustBruteLoss(20)
			to_chat(L, "<span class='warning'>Temporal energy buffets you!</span>")

/obj/effect/temporal_anomaly/Destroy()
	visible_message("<span class='notice'>The [anomaly_type] anomaly fades away.</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 50)
	..()
