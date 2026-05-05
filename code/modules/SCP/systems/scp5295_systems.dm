// SCP-5295 Modular Systems

// Temporal System: handles passive time dilation/distortions
/datum/scp5295_temporal_system
	var/obj/machinery/computer/scp5295/owner
	var/next_pulse = 0
	var/pulse_interval = 4 SECONDS
	var/dilation_radius = 4

/datum/scp5295_temporal_system/New(obj/machinery/computer/scp5295/new_owner)
	owner = new_owner

/datum/scp5295_temporal_system/proc/process_temporal()
	if(!owner)
		return
	if(world.time < next_pulse)
		return
	next_pulse = world.time + pulse_interval

	if(prob(15))
		owner.visible_message("<span class='notice'>Temporal distortions shimmer around [owner].</span>")

	for(var/mob/living/L in range(dilation_radius, owner))
		if(L.stat == DEAD)
			continue
		if(prob(10))
			L.adjustBruteLoss(5)
			to_chat(L, "<span class='warning'>Time seems oddly heavy around you.</span>")

// Reality System: spawns and manages environmental anomalies
/datum/scp5295_reality_system
	var/obj/machinery/computer/scp5295/owner
	var/next_anomaly_check = 0
	var/anomaly_check_interval = 10 SECONDS
	var/min_anomaly_gap = 30 SECONDS
	var/last_anomaly_time = 0

/datum/scp5295_reality_system/New(obj/machinery/computer/scp5295/new_owner)
	owner = new_owner

/datum/scp5295_reality_system/proc/process_reality()
	if(!owner)
		return
	if(world.time < next_anomaly_check)
		return
	next_anomaly_check = world.time + anomaly_check_interval

	if(world.time < last_anomaly_time + min_anomaly_gap)
		return

	var/nearby_count = 0
	for(var/mob/living/L in view(5, owner))
		if(L.stat != DEAD)
			nearby_count++

	var/spawn_chance = min(50, 5 + (nearby_count * 3))
	if(prob(spawn_chance))
		last_anomaly_time = world.time
		owner.visible_message("<span class='danger'>Temporal space warps as an anomaly forms near [owner]!</span>")

// Evolution System: tracks temporal mastery and scales subtle strengths
/datum/scp5295_evolution_system
	var/obj/machinery/computer/scp5295/owner
	var/mastery = 0
	var/next_eval = 0
	var/eval_interval = 20 SECONDS

/datum/scp5295_evolution_system/New(obj/machinery/computer/scp5295/new_owner)
	owner = new_owner

/datum/scp5295_evolution_system/proc/process_evolution()
	if(!owner)
		return
	if(world.time < next_eval)
		return
	next_eval = world.time + eval_interval

	var/activity = 0
	for(var/mob/living/L in view(5, owner))
		if(L.stat != DEAD)
			activity++
	mastery = min(100, mastery + clamp(activity, 0, 5))

// Containment System: placeholder for now, tracks notional stability
/datum/scp5295_containment_system
	var/obj/machinery/computer/scp5295/owner
	var/containment_stability = 100

/datum/scp5295_containment_system/New(obj/machinery/computer/scp5295/new_owner)
	owner = new_owner

/datum/scp5295_containment_system/proc/process_containment()
	if(!owner)
		return
	if(prob(10))
		containment_stability = max(0, containment_stability - 1)

// Environmental System: area-wide temporal weather flavor
/datum/scp5295_environmental_system
	var/obj/machinery/computer/scp5295/owner
	var/next_weather = 0
	var/weather_interval = 12 SECONDS

/datum/scp5295_environmental_system/New(obj/machinery/computer/scp5295/new_owner)
	owner = new_owner

/datum/scp5295_environmental_system/proc/process_environment()
	if(!owner)
		return
	if(world.time < next_weather)
		return
	next_weather = world.time + weather_interval
	if(prob(8))
		owner.visible_message("<span class='notice'>The air hums with a faint chronological vibration.</span>")

// Research System: contributes simple metrics for now
/datum/scp5295_research_system
	var/obj/machinery/computer/scp5295/owner
	var/last_contrib = 0
	var/contrib_interval = 30 SECONDS

/datum/scp5295_research_system/New(obj/machinery/computer/scp5295/new_owner)
	owner = new_owner

/datum/scp5295_research_system/proc/process_research()
	if(!owner)
		return
	if(world.time < last_contrib + contrib_interval)
		return
	last_contrib = world.time
