// SCP-3349: Reality-Bending Entity
// An entity that can manipulate reality and create environmental anomalies

/mob/living/carbon/scp/scp3349
	name = "reality bender"
	desc = "A mysterious entity that seems to distort reality around it. The air around it shimmers unnaturally."
	icon = 'icons/scp/scp-173.dmi'
	icon_state = "reality_bender"
	status_flags = 0
	maxHealth = 200
	health = 200
	max_scp_health = 200
	scp_health = 200
	max_scp_armor = 75
	scp_armor = 75

	// Reality manipulation abilities
	var/reality_distortion_cooldown = 0
	var/reality_distortion_cooldown_time = 25 SECONDS
	var/anomaly_creation_cooldown = 0
	var/anomaly_creation_cooldown_time = 40 SECONDS
	var/distortion_radius = 5
	var/anomaly_duration = 60 SECONDS
	var/list/created_anomalies = list()

/mob/living/carbon/scp/scp3349/Initialize(mapload, new_species = "SCP-3349")
	. = ..()
	SCP = new /datum/scp(src, "reality bender", SCP_KETER, "3349", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	// Add abilities
	add_ability("distort_reality", "distort_reality_ability")
	add_ability("create_anomaly", "create_anomaly_ability")
	add_passive_effect("reality_distortion", "reality_distortion_effect")

	// Auto-registered via datum/scp

/mob/living/carbon/scp/scp3349/process_scp_effects()
	. = ..()

	if(stat == DEAD)
		return

	// Passive reality distortion effects
	if(prob(3))
		visible_message("<span class='notice'>The air around [src] shimmers with reality distortion.</span>")

	// Clean up expired anomalies
	for(var/obj/effect/reality_anomaly/anomaly in created_anomalies)
		if(!anomaly || anomaly.gc_destroyed)
			created_anomalies -= anomaly

/mob/living/carbon/scp/scp3349/UnarmedAttack(atom/A)
	if(!A || !istype(A, /mob/living))
		return ..()

	var/mob/living/L = A
	if(L.stat == DEAD)
		return ..()

	// Reality distortion attack
	to_chat(src, "<span class='notice'>You distort reality around [L].</span>")
	to_chat(L, "<span class='danger'>Reality seems to bend and distort around you!</span>")

	L.adjustBruteLoss(15)
	// Reality distortion causes confusion

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Log interaction
	SCP.log_interaction(L, "reality_distortion_attack")
	SCP.award_research(L, "anomaly", 20)

	return ..()

/mob/living/carbon/scp/scp3349/get_status_tab_items()
	. = ..()
	. += "Reality Distortion Cooldown: [max(0, round((reality_distortion_cooldown - world.time) / 10))] seconds"
	. += "Anomaly Creation Cooldown: [max(0, round((anomaly_creation_cooldown - world.time) / 10))] seconds"
	. += "Active Anomalies: [created_anomalies.len]"

/mob/living/carbon/scp/scp3349/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This entity can manipulate reality and create environmental anomalies.</span>"
	if(created_anomalies.len > 0)
		. += "<span class='warning'>The entity has created [created_anomalies.len] reality anomalies.</span>"

/mob/living/carbon/scp/scp3349/scp_death()
	visible_message("<span class='danger'>[src] dissolves into reality distortion!</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 50)

	// Remove all created anomalies
	for(var/obj/effect/reality_anomaly/anomaly in created_anomalies)
		if(anomaly && !anomaly.gc_destroyed)
			qdel(anomaly)
	created_anomalies = list()

	..()

// Reality manipulation abilities
/mob/living/carbon/scp/scp3349/proc/distort_reality_ability()
	set name = "Distort Reality"
	set desc = "Create a localized reality distortion field"
	set category = "SCP"

	if(reality_distortion_cooldown > world.time)
		to_chat(src, "<span class='warning'>Reality distortion is still recharging...</span>")
		return

	to_chat(src, "<span class='notice'>You create a reality distortion field around you.</span>")
	visible_message("<span class='danger'>[src] creates a reality distortion field!</span>")

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Affect all living beings in range
	for(var/mob/living/L in range(distortion_radius, src))
		if(L == src)
			continue
		if(L.stat == DEAD)
			continue

		to_chat(L, "<span class='danger'>Reality seems to bend and distort around you!</span>")
		L.adjustBruteLoss(10)

		SCP.log_interaction(L, "reality_distortion_field")
		SCP.award_research(L, "anomaly", 15)

	reality_distortion_cooldown = world.time + reality_distortion_cooldown_time

/mob/living/carbon/scp/scp3349/proc/create_anomaly_ability()
	set name = "Create Anomaly"
	set desc = "Create a permanent reality anomaly"
	set category = "SCP"

	if(anomaly_creation_cooldown > world.time)
		to_chat(src, "<span class='warning'>Anomaly creation is still recharging...</span>")
		return

	var/list/anomaly_types = list("Gravity Well", "Time Distortion", "Spatial Rift", "Reality Bubble")
	var/anomaly_type = input(src, "Choose anomaly type:", "Create Anomaly") as null|anything in anomaly_types

	if(!anomaly_type)
		return

	var/turf/target_turf = get_turf(src)
	if(!target_turf)
		return

	to_chat(src, "<span class='notice'>You create a [anomaly_type] anomaly.</span>")
	visible_message("<span class='danger'>[src] creates a [anomaly_type] anomaly!</span>")

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Create the anomaly
	var/obj/effect/reality_anomaly/anomaly = new /obj/effect/reality_anomaly(target_turf, anomaly_type, anomaly_duration)
	created_anomalies += anomaly

	anomaly_creation_cooldown = world.time + anomaly_creation_cooldown_time

/mob/living/carbon/scp/scp3349/proc/reality_distortion_effect()
	// Passive reality distortion effects
	if(prob(1))
		visible_message("<span class='notice'>The air around [src] shimmers with reality distortion.</span>")

// Reality Anomaly Object
/obj/effect/reality_anomaly
	name = "reality anomaly"
	desc = "A distortion in reality. It seems to affect the environment around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity"
	density = FALSE
	anchored = TRUE
	var/anomaly_type = "Unknown"
	var/duration = 60 SECONDS
	var/creation_time = 0
	var/effect_radius = 3

/obj/effect/reality_anomaly/New(loc, type, dur)
	..()
	anomaly_type = type
	duration = dur
	creation_time = world.time

	// Set up the anomaly effect
	setup_anomaly_effect()

	// Auto-destruct after duration
	spawn(duration)
		qdel(src)

/obj/effect/reality_anomaly/proc/setup_anomaly_effect()
	switch(anomaly_type)
		if("Gravity Well")
			name = "gravity well"
			desc = "A localized gravity well that pulls objects toward it."
			icon_state = "gravwell"
		if("Time Distortion")
			name = "time distortion"
			desc = "A field where time flows differently."
			icon_state = "timedist"
		if("Spatial Rift")
			name = "spatial rift"
			desc = "A tear in space that can transport objects."
			icon_state = "spatialrift"
		if("Reality Bubble")
			name = "reality bubble"
			desc = "A bubble where reality is altered."
			icon_state = "realitybubble"

/obj/effect/reality_anomaly/Crossed(atom/movable/AM)
	if(!AM || !istype(AM, /mob/living))
		return

	var/mob/living/L = AM
	to_chat(L, "<span class='danger'>You pass through a [anomaly_type] anomaly!</span>")

	switch(anomaly_type)
		if("Gravity Well")
			L.adjustBruteLoss(5)
			to_chat(L, "<span class='warning'>The gravity well pulls at your body!</span>")
		if("Time Distortion")
			to_chat(L, "<span class='warning'>Time seems to flow differently here!</span>")
		if("Spatial Rift")
			var/turf/random_turf = pick(range(5, src))
			L.forceMove(random_turf)
			to_chat(L, "<span class='warning'>You are transported through the spatial rift!</span>")
		if("Reality Bubble")
			L.adjustBruteLoss(10)
			to_chat(L, "<span class='warning'>Reality seems altered within this bubble!</span>")

/obj/effect/reality_anomaly/Destroy()
	visible_message("<span class='notice'>The [anomaly_type] anomaly fades away.</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 50)
	..()
