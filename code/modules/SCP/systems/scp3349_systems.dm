// SCP-3349 Modular Systems

/datum/scp3349_distortion_system
	var/mob/living/carbon/human/scp3349/owner
	var/next_tick = 0
	var/tick_interval = 4 SECONDS
	var/distortion_radius = 5

/datum/scp3349_distortion_system/New(mob/living/carbon/human/scp3349/new_owner)
	owner = new_owner

/datum/scp3349_distortion_system/proc/process_distortion()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_tick)
		return
	next_tick = world.time + tick_interval

	if(prob(20))
		owner.visible_message("<span class='notice'>The air around [owner] ripples with distortion.</span>")

	for(var/mob/living/L in range(distortion_radius, owner))
		if(L == owner || L.stat == DEAD)
			continue
		if(prob(12))
			L.adjustBruteLoss(5)
			to_chat(L, "<span class='warning'>Reality feels unsteady around you.</span>")

/datum/scp3349_anomaly_system
	var/mob/living/carbon/human/scp3349/owner
	var/next_check = 0
	var/check_interval = 9 SECONDS
	var/last_spawn = 0
	var/min_gap = 35 SECONDS

/datum/scp3349_anomaly_system/New(mob/living/carbon/human/scp3349/new_owner)
	owner = new_owner

/datum/scp3349_anomaly_system/proc/process_anomalies()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_check)
		return
	next_check = world.time + check_interval
	if(world.time < last_spawn + min_gap)
		return

	var/nearby = 0
	for(var/mob/living/L in view(6, owner))
		if(L != owner && L.stat != DEAD)
			nearby++
	var/chance = min(50, 8 + nearby * 3)
	if(prob(chance))
		last_spawn = world.time
		var/list/types = list("Gravity Well", "Time Distortion", "Spatial Rift", "Reality Bubble")
		var/choice = pick(types)
		var/turf/T = get_turf(owner)
		if(T)
			new /obj/effect/reality_anomaly(T, choice, 45 SECONDS)
			owner.visible_message("<span class='danger'>A reality anomaly tears open near [owner]!</span>")

/datum/scp3349_evolution_system
	var/mob/living/carbon/human/scp3349/owner
	var/potency = 0
	var/next_eval = 0
	var/interval = 18 SECONDS

/datum/scp3349_evolution_system/New(mob/living/carbon/human/scp3349/new_owner)
	owner = new_owner

/datum/scp3349_evolution_system/proc/process_evolution()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_eval)
		return
	next_eval = world.time + interval

	var/pressure = 0
	for(var/mob/living/L in view(6, owner))
		if(L != owner && L.stat != DEAD)
			pressure++
	potency = min(100, potency + clamp(pressure, 0, 5))

/datum/scp3349_environment_system
	var/mob/living/carbon/human/scp3349/owner
	var/next_note = 0
	var/note_interval = 12 SECONDS

/datum/scp3349_environment_system/New(mob/living/carbon/human/scp3349/new_owner)
	owner = new_owner

/datum/scp3349_environment_system/proc/process_environment()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_note)
		return
	next_note = world.time + note_interval
	if(prob(10))
		owner.visible_message("<span class='notice'>Walls flex subtly as reality bends.</span>")

/datum/scp3349_research_system
	var/mob/living/carbon/human/scp3349/owner
	var/last = 0
	var/gap = 28 SECONDS

/datum/scp3349_research_system/New(mob/living/carbon/human/scp3349/new_owner)
	owner = new_owner

/datum/scp3349_research_system/proc/process_research()
	if(!owner || world.time < last + gap)
		return
	last = world.time
	owner.SCP?.award_research(null, "reality_phenomena", 8)




