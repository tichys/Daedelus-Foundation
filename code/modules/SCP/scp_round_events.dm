/datum/round_event_control/scp_containment_breach
	name = "SCP Containment Breach"
	typepath = /datum/round_event/scp_containment_breach
	max_occurrences = 5
	weight = 20
	earliest_start = 15 MINUTES
	min_players = 10

/datum/round_event/scp_containment_breach
	var/breached_scp

/datum/round_event/scp_containment_breach/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 50

/datum/round_event/scp_containment_breach/announce(fake)
	priority_announce("ALERT: Containment failure detected in secure storage. All security personnel respond immediately.", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_containment_breach/start()
	var/list/breachable_scps = list("SCP-173", "SCP-049", "SCP-096", "SCP-106", "SCP-049", "SCP-939", "SCP-457", "SCP-035")
	breached_scp = pick(breachable_scps)
	hook_scp_breach(breached_scp, null)

/datum/round_event/scp_containment_breach/tick()
	if(activeFor == 30)
		priority_announce("ALERT: [breached_scp] containment status: BREACHED. Enact recontainment protocol immediately.", sound_type = ANNOUNCER_ALERT)

/datum/round_event_control/scp_power_fluctuation
	name = "SCP Facility Power Fluctuation"
	typepath = /datum/round_event/scp_power_fluctuation
	max_occurrences = 4
	weight = 20
	earliest_start = 15 MINUTES
	min_players = 10

/datum/round_event/scp_power_fluctuation

/datum/round_event/scp_power_fluctuation/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 30

/datum/round_event/scp_power_fluctuation/announce(fake)
	priority_announce("WARNING: Power grid instability detected in containment wing. Backup generators standing by.", sound_type = ANNOUNCER_POWEROFF)

/datum/round_event/scp_power_fluctuation/start()
	for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
		if(prob(30))
			A.energy_fail(rand(30, 120))

/datum/round_event_control/scp_memetic_hazard
	name = "SCP Memetic Hazard"
	typepath = /datum/round_event/scp_memetic_hazard
	max_occurrences = 2
	weight = 10
	earliest_start = 25 MINUTES
	min_players = 15

/datum/round_event/scp_memetic_hazard

/datum/round_event/scp_memetic_hazard/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 20

/datum/round_event/scp_memetic_hazard/announce(fake)
	priority_announce("WARNING: Memetic hazard detected in facility. Avoid unauthorized visual contact with anomalous objects.", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_memetic_hazard/start()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		var/zone = get_containment_zone(A)
		if(zone == "lcz" || zone == "hcz")
			if(H.sanity && prob(40))
				H.sanity.adjust_sanity(-15, "memetic_hazard_event")
				to_chat(H, "<span class='warning'>Your mind feels violated by an unseen force!</span>")

/datum/round_event_control/scp_cascade_warning
	name = "SCP Cascade Warning"
	typepath = /datum/round_event/scp_cascade_warning
	max_occurrences = 1
	weight = 5
	earliest_start = 40 MINUTES
	min_players = 20

/datum/round_event/scp_cascade_warning

/datum/round_event/scp_cascade_warning/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 40

/datum/round_event/scp_cascade_warning/announce(fake)
	priority_announce("CRITICAL: Multiple SCP containment anomalies detected. Facility-wide cascade event possible. All personnel brace for impact.", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_cascade_warning/start()
	var/list/breachable = list("SCP-173", "SCP-106", "SCP-049", "SCP-682", "SCP-096")
	for(var/i in 1 to 2)
		hook_scp_breach(pick(breachable), null)

	for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
		if(prob(50))
			A.energy_fail(rand(60, 180))

/datum/round_event_control/scp_research_breakthrough
	name = "SCP Research Breakthrough"
	typepath = /datum/round_event/scp_research_breakthrough
	max_occurrences = 3
	weight = 15
	earliest_start = 10 MINUTES
	min_players = 5

/datum/round_event/scp_research_breakthrough

/datum/round_event/scp_research_breakthrough/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 10

/datum/round_event/scp_research_breakthrough/announce(fake)
	priority_announce("NOTICE: Research breakthrough achieved. Bonus funding allocated to Science department.", sound_type = ANNOUNCER_DEFAULT)

/datum/round_event/scp_research_breakthrough/start()
	if(SSpersistent_progression)
		for(var/ckey in SSpersistent_progression.player_data)
			var/datum/persistent_player_data/pdata = SSpersistent_progression.player_data[ckey]
			if(pdata && pdata.current_job && findtext(pdata.current_job, "Researcher"))
				SSpersistent_progression.award_experience(ckey, "scp_research_contribution", 50, "Research Breakthrough Event")

/datum/round_event_control/scp_security_alert
	name = "SCP Security Alert"
	typepath = /datum/round_event/scp_security_alert
	max_occurrences = 6
	weight = 25
	earliest_start = 5 MINUTES
	min_players = 8

/datum/round_event/scp_security_alert

/datum/round_event/scp_security_alert/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 25

/datum/round_event/scp_security_alert/announce(fake)
	var/alert_type = pick("unauthorized access", "intrusion detection", "suspicious activity", "contraband detection")
	priority_announce("SECURITY ALERT: [alert_type] reported in containment wing. Security personnel investigate.", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_security_alert/start()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		if(id_card && (ACCESS_SECURITY in id_card.access))
			to_chat(H, "<span class='danger'>Your security headset crackles: Priority alert in effect. Report to containment wing.</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-5, "security_alert_stress")

/datum/round_event_control/scp_dclass_uprising
	name = "D-Class Incident"
	typepath = /datum/round_event/scp_dclass_uprising
	max_occurrences = 2
	weight = 10
	earliest_start = 15 MINUTES
	min_players = 10

/datum/round_event/scp_dclass_uprising

/datum/round_event/scp_dclass_uprising/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 30

/datum/round_event/scp_dclass_uprising/announce(fake)
	priority_announce("ALERT: D-Class disturbance reported in cell block. Security personnel respond to D-Class areas.", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_dclass_uprising/start()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/dclass))
			to_chat(H, "<span class='warning'>The air of tension in the cell block is palpable. Something is about to happen.</span>")
			if(SSdclass && SSdclass.manager)
				var/datum/dclass_player/player = SSdclass.manager.dclass_players[H.ckey]
				if(player)
					player.adjust_trust(5, "dclass_incident")
					player.add_contraband("improvised_tool", 1)

// ================================================================
// CHAOS INSURGENCY RAID EVENT
// ================================================================

/datum/round_event_control/scp_ci_raid
	name = "Chaos Insurgency Raid"
	typepath = /datum/round_event/scp_ci_raid
	max_occurrences = 2
	weight = 15
	earliest_start = 20 MINUTES
	min_players = 15

/datum/round_event/scp_ci_raid
	var/list/spawned_mobs = list()

/datum/round_event/scp_ci_raid/setup()
	startWhen = 1
	announceWhen = 3
	endWhen = 600

/datum/round_event/scp_ci_raid/announce(fake)
	priority_announce("SECURITY BREACH: Unidentified hostiles have breached the facility perimeter. All security personnel engage hostile forces.", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_ci_raid/start()
	var/list/entry_points = GLOB.station_turfs.Copy()
	if(!length(entry_points))
		return

	var/raider_count = min(4, max(2, round(length(GLOB.player_list) / 10)))

	for(var/i = 1 to raider_count)
		var/turf/spawn_loc = pick(entry_points)
		var/mob/living/carbon/human/raider = new(spawn_loc)
		raider.set_species(/datum/species/human)
		raider.real_name = pick("Marcus Webb", "Elena Vasquez", "Dmitri Volkov", "Sarah Chen", "James Okafor")
		spawned_mobs += raider

		addtimer(CALLBACK(src, .proc/grant_raider_antag, raider), 1 SECOND)

/datum/round_event/scp_ci_raid/proc/grant_raider_antag(mob/living/carbon/human/raider)
	if(!raider || !raider.mind)
		return

	var/datum/antagonist/chaos_insurgency/ci_antag = new()
	raider.mind.add_antag_datum(ci_antag)
	to_chat(raider, span_danger("You are a member of the Chaos Insurgency. Infiltrate the facility and complete your mission."))

	ci_antag.equip_ci_operative()

/datum/round_event/scp_ci_raid/tick()
	if(activeFor == 50)
		priority_announce("INTEL UPDATE: Hostile operatives detected near containment areas. Security status: ORANGE.", sound_type = ANNOUNCER_DEFAULT)

/datum/round_event/scp_ci_raid/end()
	var/survivors = 0
	var/objective_completed = FALSE
	for(var/mob/living/M in spawned_mobs)
		if(M.stat != DEAD)
			survivors++
		if(M.mind)
			var/datum/antagonist/chaos_insurgency/ci = M.mind.has_antag_datum(/datum/antagonist/chaos_insurgency)
			if(ci && ci.objectives)
				for(var/datum/objective/O in ci.objectives)
					if(O.check_completion() == TRUE)
						objective_completed = TRUE

	if(objective_completed && survivors > 0)
		priority_announce("CRITICAL FAILURE: Chaos Insurgency operatives completed primary objective. Containment breach confirmed.", sound_type = ANNOUNCER_ALERT)
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(QDELETED(H))
				continue
			if(H.stat != DEAD && H.client && (ACCESS_SECURITY in H.get_idcard(TRUE)?.access))
				to_chat(H, span_userdanger("Mission failed. Chaos Insurgency won."))
	else if(survivors == 0)
		priority_announce("THREAT NEUTRALIZED: All hostile operatives eliminated. Security forces triumphant.", sound_type = ANNOUNCER_DEFAULT)
	else
		priority_announce("ALERT: Hostile operatives withdrew. Containment maintained.", sound_type = ANNOUNCER_DEFAULT)
