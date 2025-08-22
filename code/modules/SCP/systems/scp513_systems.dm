// SCP-513 Systems - object-based, no verbs

/datum/scp513_fear_system
	var/obj/item/scp513/owner
	var/next_decay = 0
	var/decay_interval = 5 SECONDS
	var/decay_amount = 5

/datum/scp513_fear_system/New(obj/item/scp513/new_owner)
	owner = new_owner

/datum/scp513_fear_system/proc/process_fear()
	if(!owner || QDELETED(owner))
		return
	if(world.time < next_decay)
		return
	next_decay = world.time + decay_interval
	// Gradually reduce fear levels and clean up
	var/list/to_remove = list()
	for(var/mob/living/carbon/human/H in owner.fear_levels)
		if(!H || H.stat == DEAD)
			to_remove += H
			continue
		owner.fear_levels[H] = max(0, owner.fear_levels[H] - decay_amount)
		if(owner.fear_levels[H] <= 0)
			to_remove += H
	for(var/mob/living/carbon/human/R in to_remove)
		owner.fear_levels -= R
		owner.affected_targets -= R

/datum/scp513_research_system
	var/obj/item/scp513/owner
	var/last = 0
	var/gap = 30 SECONDS

/datum/scp513_research_system/New(obj/item/scp513/new_owner)
	owner = new_owner

/datum/scp513_research_system/proc/process_research()
	if(!owner)
		return
	if(world.time < last + gap)
		return
	last = world.time
	owner.SCP?.award_research(null, "acoustic_anomaly_fear", 6)




