// SCP-3349: Reality-Bending Entity
// An entity that can manipulate reality and create environmental anomalies

/mob/living/carbon/human/scp3349
	name = "reality bender"
	desc = "A mysterious entity that seems to distort reality around it. The air around it shimmers unnaturally."
	icon = 'icons/scp/scp-3349.dmi'
	icon_state = "reality_bender"
	status_flags = 0
	maxHealth = 200
	health = 200

	// Modular systems
	var/datum/scp3349_distortion_system/distortion_system
	var/datum/scp3349_anomaly_system/anomaly_system
	var/datum/scp3349_evolution_system/evolution_system
	var/datum/scp3349_environment_system/environment_system
	var/datum/scp3349_research_system/research_system

/mob/living/carbon/human/scp3349/Initialize(mapload)
	. = ..()
	set_species(/datum/species/scp3349)
	SCP = new /datum/scp(src, "reality bender", SCP_KETER, "3349", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES
		// Initialize systems after a short delay
	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

/mob/living/carbon/human/scp3349/proc/initialize_systems()
	distortion_system = new /datum/scp3349_distortion_system(src)
	anomaly_system = new /datum/scp3349_anomaly_system(src)
	evolution_system = new /datum/scp3349_evolution_system(src)
	environment_system = new /datum/scp3349_environment_system(src)
	research_system = new /datum/scp3349_research_system(src)

/mob/living/carbon/human/scp3349/Life(datum/controller/process/mobs/parent)
	. = ..()
	if(stat == DEAD)
		return
	// Update modular systems
	distortion_system?.process_distortion()
	anomaly_system?.process_anomalies()
	evolution_system?.process_evolution()
	environment_system?.process_environment()
	research_system?.process_research()

/mob/living/carbon/human/scp3349/UnarmedAttack(atom/A)
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
	SCP?.log_interaction(L, "reality_distortion_attack")
	SCP?.award_research(L, "anomaly", 20)

	return ..()

/mob/living/carbon/human/scp3349/get_status_tab_items()
	. = ..()
	. += "Reality bends subtly in your presence."

/mob/living/carbon/human/scp3349/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This entity can manipulate reality and create environmental anomalies.</span>"
	. += "<span class='warning'>Localized anomalies may form spontaneously.</span>"

/mob/living/carbon/human/scp3349/death(gibbed)
	visible_message("<span class='danger'>[src] dissolves into reality distortion!</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 50)
	return ..()

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
	addtimer(CALLBACK(src, PROC_REF(qdel), src), duration)

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
