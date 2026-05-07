/datum/scp_chain_breach
	var/breach_id
	var/list/trigger_conditions = list()
	var/list/breach_effects = list()
	var/triggered = FALSE
	var/trigger_time = 0

/datum/scp_chain_breach/proc/check_trigger()
	if(triggered)
		return FALSE
	for(var/condition in trigger_conditions)
		if(!evaluate_condition(condition))
			return FALSE
	return TRUE

/datum/scp_chain_breach/proc/evaluate_condition(condition)
	switch(condition)
		if("multi_breach")
			var/breached_count = 0
			if(SSscp_persistence?.manager?.scp_instances)
				for(var/scp_id in SSscp_persistence.manager.scp_instances)
					var/datum/scp_instance/SI = SSscp_persistence.manager.scp_instances[scp_id]
					if(SI.containment_status == "breached")
						breached_count++
			return breached_count >= 2
		if("power_failure")
			for(var/obj/machinery/power/apc/APC in world)
				if(istype(get_area(APC), /area/scp) && APC.machine_stat & NOPOWER)
					return TRUE
			return FALSE
		if("containment_critical")
			for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
				var/datum/scp_instance/SI = SSscp_persistence.manager.scp_instances[scp_id]
				if(SI.containment_status == "critical")
					return TRUE
			return FALSE
		if("dclass_riot")
			if(SSdclass?.manager?.current_security_level >= 4)
				return TRUE
			return FALSE
	return FALSE

/datum/scp_chain_breach/proc/trigger_breach()
	if(triggered)
		return
	triggered = TRUE
	trigger_time = world.time
	for(var/effect in breach_effects)
		apply_effect(effect)

/datum/scp_chain_breach/proc/apply_effect(effect)
	switch(effect)
		if("cascade_containment_failure")
			if(SSscp_persistence?.manager?.scp_instances)
				for(var/scp_id in SSscp_persistence.manager.scp_instances)
					var/datum/scp_instance/SI = SSscp_persistence.manager.scp_instances[scp_id]
					if(SI.containment_health > 0)
						SI.containment_health = max(0, SI.containment_health - 15)
			priority_announce("CASCADE CONTAINMENT FAILURE DETECTED. ALL SCP CONTAINMENT SYSTEMS COMPROMISED.", title = "CRITICAL ALERT", sound = 'sound/misc/notice1.ogg')
		if("facility_lockdown")
			trigger_facility_lockdown("Chain Breach Protocol")
		if("power_diversion")
			for(var/obj/machinery/power/apc/APC in world)
				if(istype(get_area(APC), /area/scp/hcz))
					APC.charging = APC_CHARGING
			priority_announce("POWER DIVERSION TO HEAVY CONTAINMENT. LIGHT CONTAINMENT POWER REDUCED.", title = "POWER ALERT", sound = 'sound/misc/notice1.ogg')
		if("security_recall")
			for(var/mob/living/carbon/human/H in world)
				if((H.mind?.assigned_role?.title in list("Security Officer", "Head of Security", "MTF Operative")))
					to_chat(H, span_warning("Chain breach protocol activated. All security personnel report to containment zones immediately."))
		if("scp_079_awakening")
			for(var/mob/living/scp079/S in world)
				S.advance_tier()
		if("scp_106_empowerment")
			for(var/mob/living/scp/scp106/S in world)
				if(SSscp_persistence?.manager?.scp_instances["SCP-106"])
					var/datum/scp_instance/SI = SSscp_persistence.manager.scp_instances["SCP-106"]
					SI.containment_health = max(0, SI.containment_health - 25)

/proc/check_chain_breaches()
	for(var/datum/scp_chain_breach/CB in GLOB.scp_chain_breaches)
		if(CB.check_trigger())
			CB.trigger_breach()

GLOBAL_LIST_EMPTY(scp_chain_breaches)

/proc/initialize_chain_breaches()
	GLOB.scp_chain_breaches = list()

	var/datum/scp_chain_breach/cascade = new()
	cascade.breach_id = "cascade_failure"
	cascade.trigger_conditions = list("multi_breach")
	cascade.breach_effects = list("cascade_containment_failure", "facility_lockdown")
	GLOB.scp_chain_breaches += cascade

	var/datum/scp_chain_breach/power_cascade = new()
	power_cascade.breach_id = "power_cascade"
	power_cascade.trigger_conditions = list("power_failure", "containment_critical")
	power_cascade.breach_effects = list("cascade_containment_failure", "power_diversion")
	GLOB.scp_chain_breaches += power_cascade

	var/datum/scp_chain_breach/riot_cascade = new()
	riot_cascade.breach_id = "riot_cascade"
	riot_cascade.trigger_conditions = list("dclass_riot", "containment_critical")
	riot_cascade.breach_effects = list("security_recall", "facility_lockdown")
	GLOB.scp_chain_breaches += riot_cascade

	var/datum/scp_chain_breach/scp079_empower = new()
	scp079_empower.breach_id = "079_empowerment"
	scp079_empower.trigger_conditions = list("power_failure")
	scp079_empower.breach_effects = list("scp_079_awakening")
	GLOB.scp_chain_breaches += scp079_empower

	var/datum/scp_chain_breach/scp106_empower = new()
	scp106_empower.breach_id = "106_empowerment"
	scp106_empower.trigger_conditions = list("multi_breach")
	scp106_empower.breach_effects = list("scp_106_empowerment")
	GLOB.scp_chain_breaches += scp106_empower
