// SCP-966 Modular, verb-less systems

/datum/scp966_sleep_system
	var/mob/living/carbon/human/scp966/owner
	var/next_drain = 0
	var/drain_interval = 10 SECONDS
	var/effect_radius = 5
	var/intensity = 1
	var/max_intensity = 5

/datum/scp966_sleep_system/New(mob/living/carbon/human/scp966/new_owner)
	owner = new_owner

/datum/scp966_sleep_system/proc/process_sleep()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_drain)
		return
	next_drain = world.time + drain_interval
	for(var/mob/living/carbon/human/H in range(effect_radius, owner))
		if(H == owner || H.stat == DEAD)
			continue
		H.adjustBruteLoss(intensity * 0.2)
		to_chat(H, "<span class='warning'>An oppressive exhaustion presses upon you.</span>")

/datum/scp966_stealth_system
	var/mob/living/carbon/human/scp966/owner
	var/next_toggle = 0
	var/toggle_interval = 20 SECONDS
	var/active = TRUE

/datum/scp966_stealth_system/New(mob/living/carbon/human/scp966/new_owner)
	owner = new_owner

/datum/scp966_stealth_system/proc/process_stealth()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time > next_toggle && prob(10))
		next_toggle = world.time + toggle_interval
		active = !active
		// Cosmetic cue for nearby observers
		if(!active && prob(30))
			owner.visible_message("<span class='notice'>A shimmer reveals something in the air, then fades.</span>")

/datum/scp966_stalk_system
	var/mob/living/carbon/human/scp966/owner
	var/list/stalked = list()
	var/next_scan = 0
	var/scan_interval = 15 SECONDS

/datum/scp966_stalk_system/New(mob/living/carbon/human/scp966/new_owner)
	owner = new_owner

/datum/scp966_stalk_system/proc/process_stalk()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_scan)
		return
	next_scan = world.time + scan_interval
	// Track one nearby target opportunistically
	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in view(6, owner))
		if(H != owner && H.stat != DEAD)
			candidates += H
	if(length(candidates))
		var/mob/living/carbon/human/choice = pick(candidates)
		if(!(choice in stalked))
			stalked += choice
			to_chat(choice, "<span class='danger'>You feel an unseen gaze upon you...</span>")

/datum/scp966_nightmare_system
	var/mob/living/carbon/human/scp966/owner
	var/next_event = 0
	var/event_interval = 30 SECONDS

/datum/scp966_nightmare_system/New(mob/living/carbon/human/scp966/new_owner)
	owner = new_owner

/datum/scp966_nightmare_system/proc/process_nightmares()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_event)
		return
	next_event = world.time + event_interval
	if(prob(15))
		var/list/victims = list()
		for(var/mob/living/carbon/human/H in view(4, owner))
			if(H != owner && H.stat != DEAD)
				victims += H
		if(length(victims))
			var/mob/living/carbon/human/v = pick(victims)
			to_chat(v, "<span class='danger'>A waking nightmare grips you with dread.</span>")
			v.sanity?.adjust_sanity(-2)

/datum/scp966_research_system
	var/mob/living/carbon/human/scp966/owner
	var/last = 0
	var/gap = 40 SECONDS

/datum/scp966_research_system/New(mob/living/carbon/human/scp966/new_owner)
	owner = new_owner

/datum/scp966_research_system/proc/process_research()
	if(!owner)
		return
	if(world.time < last + gap)
		return
	last = world.time
	owner.SCP?.award_research(null, "sleep_deprivation_phenomena", 8)




