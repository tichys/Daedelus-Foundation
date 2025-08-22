// SCP-895 Systems - object-based anomaly (no player control)

/datum/scp895_sickness_system
	var/obj/machinery/camera/scp895/owner
	var/next_tick = 0
	var/tick_interval = 2 SECONDS

/datum/scp895_sickness_system/New(obj/machinery/camera/scp895/new_owner)
	owner = new_owner

/datum/scp895_sickness_system/proc/process_sickness()
	if(!owner || QDELETED(owner))
		return
	if(world.time < next_tick)
		return
	next_tick = world.time + tick_interval
	// Delegate to existing effect proc for consistency
	owner.affect_nearby_targets()

/datum/scp895_research_system
	var/obj/machinery/camera/scp895/owner
	var/last = 0
	var/gap = 20 SECONDS

/datum/scp895_research_system/New(obj/machinery/camera/scp895/new_owner)
	owner = new_owner

/datum/scp895_research_system/proc/process_research()
	if(!owner)
		return
	if(world.time < last + gap)
		return
	last = world.time
	owner.SCP?.award_research(null, "anomalous_visual_sickness", 5)




