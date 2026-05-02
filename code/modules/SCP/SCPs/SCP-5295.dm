// SCP-5295: Temporal Entity
// An entity that can manipulate time and create temporal anomalies

/mob/living/carbon/human/scp5295
	name = "temporal entity"
	desc = "A mysterious entity that seems to exist outside of normal time. Temporal distortions occur around it."
	icon = 'icons/scp/scp-5295.dmi'
	icon_state = "temporal"
	status_flags = 0
	maxHealth = 225
	health = 225

	// Systems
	var/datum/scp5295_temporal_system/temporal_system
	var/datum/scp5295_reality_system/reality_system
	var/datum/scp5295_evolution_system/evolution_system
	var/datum/scp5295_containment_system/containment_system
	var/datum/scp5295_environmental_system/environmental_system
	var/datum/scp5295_research_system/research_system

/mob/living/carbon/human/scp5295/Initialize(mapload)
	. = ..()
	set_species(/datum/species/scp5295)
	SCP = new /datum/scp(src, "temporal entity", SCP_KETER, "5295", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	// Initialize systems after mob exists
	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

	// Remove bodypart overlays to prevent covering the SCP icon
	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

/mob/living/carbon/human/scp5295/proc/initialize_systems()
	temporal_system = new /datum/scp5295_temporal_system(src)
	reality_system = new /datum/scp5295_reality_system(src)
	evolution_system = new /datum/scp5295_evolution_system(src)
	containment_system = new /datum/scp5295_containment_system(src)
	environmental_system = new /datum/scp5295_environmental_system(src)
	research_system = new /datum/scp5295_research_system(src)

/mob/living/carbon/human/scp5295/Life(datum/controller/process/mobs/parent)
	. = ..()
	if(stat == DEAD)
		return
	// Update modular systems
	temporal_system?.process_temporal()
	reality_system?.process_reality()
	evolution_system?.process_evolution()
	containment_system?.process_containment()
	environmental_system?.process_environment()
	research_system?.process_research()

/mob/living/carbon/human/scp5295/UnarmedAttack(atom/A)
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
	SCP?.log_interaction(L, "temporal_manipulation_attack")
	SCP?.award_research(L, "anomaly", 30)

	return ..()

/mob/living/carbon/human/scp5295/get_status_tab_items()
	. = ..()
	. += "Temporal disturbances ripple subtly around you."

/mob/living/carbon/human/scp5295/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This entity can manipulate time and create temporal anomalies.</span>"
	. += "<span class='warning'>Time seems to flow differently around it.</span>"

/mob/living/carbon/human/scp5295/death(gibbed)
	visible_message("<span class='danger'>[src] dissolves into temporal distortion!</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 50)
	hook_scp_recontainment("SCP-5295", list())
	return ..()

/mob/living/carbon/human/scp5295/proc/on_temporal_manipulation(mob/living/carbon/human/target, effect_type)
	if(!target)
		return
	hook_scp_combat(target, "SCP-5295", 20, 0)

/mob/living/carbon/human/scp5295/proc/on_anomaly_created(anomaly_type)
	hook_scp_breach("SCP-5295", src)
	hook_facility_damage_near_scp("SCP-5295", 1)

/mob/living/carbon/human/scp5295/proc/on_reality_distortion(mob/living/carbon/human/affected)
	if(!affected)
		return
	hook_scp_interaction(affected, "SCP-5295", INTERACTION_TYPE_OBSERVATION)

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
	addtimer(CALLBACK(src, PROC_REF(qdel), src), duration)

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
