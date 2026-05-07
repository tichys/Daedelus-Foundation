/datum/dclass_riot
	var/stage = 0
	var/list/demands = list()
	var/list/rioting_dclass = list()
	var/negotiator
	var/negotiation_progress = 0
	var/suppression_progress = 0
	var/timer_until_escalation = 0
	var/riot_active = FALSE

	var/static/list/demand_pool = list(
		"Better food rations",
		"Reduced experiment frequency",
		"Freedom of movement in LCZ",
		"Access to medical care",
		"Transfer to minimum security",
		"End of mandatory testing",
	)

/datum/dclass_riot/proc/start_riot()
	if(riot_active)
		return
	riot_active = TRUE
	stage = 1
	var/num_demands = rand(2, 3)
	demands = list()
	for(var/i in 1 to num_demands)
		var/demand = pick(demand_pool - demands)
		demands += demand
	timer_until_escalation = 600
	collect_rioting_dclass()
	for(var/mob/living/carbon/human/H in rioting_dclass)
		if(H.stat == DEAD)
			continue
		to_chat(H, "<span class='warning'>You feel a surge of defiance. You refuse to follow orders.</span>")
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		if(id_card && (ACCESS_SECURITY in id_card.access))
			to_chat(H, "<span class='danger'>The D-Class are refusing to follow orders!</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-10, "dclass_unrest")
	priority_announce("D-Class unrest has been detected in the facility. Security personnel are advised to monitor the situation.", sound_type = ANNOUNCER_ALERT)

/datum/dclass_riot/proc/collect_rioting_dclass()
	rioting_dclass = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		if(H.job && findtext(H.job, "D-Class"))
			rioting_dclass += H

/datum/dclass_riot/proc/tick()
	if(!riot_active)
		return
	timer_until_escalation -= 50
	if(timer_until_escalation <= 0)
		escalate_riot()
		timer_until_escalation = max(200, 600 - (stage * 100))

/datum/dclass_riot/proc/escalate_riot()
	if(stage >= 4)
		return
	stage++
	switch(stage)
		if(2)
			priority_announce("D-Class personnel are protesting in the cell blocks. Demands have been issued: [english_list(demands)].", sound_type = ANNOUNCER_ALERT)
			for(var/mob/living/carbon/human/H in rioting_dclass)
				if(H.stat == DEAD)
					continue
				to_chat(H, "<span class='warning'>You gather with the other D-Class, raising your voices in protest!</span>")
			if(prob(20))
				priority_announce("D-Class property damage reported in the cell block area.", sound_type = ANNOUNCER_ALERT)
		if(3)
			priority_announce("ALERT: D-Class riot in progress! Security personnel engage immediately. Containment integrity at risk.", sound_type = ANNOUNCER_ALERT)
			for(var/mob/living/carbon/human/H in rioting_dclass)
				if(H.stat == DEAD)
					continue
				to_chat(H, "<span class='danger'>The riot has escalated! Fight for your freedom!</span>")
			if(prob(30))
				var/list/valid_airlocks = list()
				for(var/obj/machinery/door/airlock/AL in world)
					var/area/A = get_area(AL)
					if(istype(A, /area/scp/dclass) || istype(A, /area/scp/lcz))
						valid_airlocks += AL
				if(length(valid_airlocks))
					var/obj/machinery/door/airlock/target = pick(valid_airlocks)
					if(target.density)
						target.open()
					priority_announce("Door breach detected near D-Class areas!", sound_type = ANNOUNCER_ALERT)
		if(4)
			priority_announce("CRITICAL: D-Class armed uprising in progress! All security personnel respond with lethal force authorized. Containment breach imminent.", sound_type = ANNOUNCER_ALERT)
			for(var/mob/living/carbon/human/H in rioting_dclass)
				if(H.stat == DEAD)
					continue
				to_chat(H, "<span class='userdanger'>You have weapons now. This is the final stand!</span>")
			hook_scp_breach("D-Class Riot", null)

/datum/dclass_riot/proc/attempt_negotiation(mob/negotiator_mob)
	if(!istype(negotiator_mob, /mob/living/carbon/human))
		return FALSE
	var/mob/living/carbon/human/H = negotiator_mob
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card)
		return FALSE
	if(!(ACCESS_SECURITY in id_card.access))
		to_chat(H, "<span class='warning'>You lack the required access to negotiate with the D-Class.</span>")
		return FALSE
	if(negotiator)
		to_chat(H, "<span class='warning'>Someone is already negotiating with the D-Class.</span>")
		return FALSE
	negotiator = H
	negotiation_progress = 0
	to_chat(H, "<span class='notice'>You begin negotiating with the D-Class rioters.</span>")
	priority_announce("Negotiations with D-Class rioters have begun.", sound_type = ANNOUNCER_DEFAULT)
	return TRUE

/datum/dclass_riot/proc/progress_negotiation(amount)
	negotiation_progress = min(100, negotiation_progress + amount)
	if(negotiation_progress >= 100)
		if(stage > 1)
			stage--
			negotiation_progress = 0
			priority_announce("D-Class rioters have agreed to de-escalate. Current stage: [stage].", sound_type = ANNOUNCER_DEFAULT)
			if(stage <= 1)
				end_riot(FALSE)
		else
			end_riot(FALSE)

/datum/dclass_riot/proc/suppress_riot(amount)
	suppression_progress = min(100, suppression_progress + amount)
	if(suppression_progress >= 100)
		end_riot(TRUE)

/datum/dclass_riot/proc/end_riot(violent)
	riot_active = FALSE
	stage = 0
	if(violent)
		priority_announce("D-Class riot has been suppressed by force. Multiple casualties reported.", sound_type = ANNOUNCER_ALERT)
		for(var/mob/living/carbon/human/H in rioting_dclass)
			if(H.stat != DEAD && prob(40))
				H.adjustBruteLoss(rand(30, 80))
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(QDELETED(H))
				continue
			if(H.stat == DEAD || !H.client)
				continue
			var/obj/item/card/id/id_card = H.get_idcard(TRUE)
			if(id_card && (ACCESS_SECURITY in id_card.access) && prob(30))
				H.adjustBruteLoss(rand(10, 30))
	else
		priority_announce("D-Class unrest has been resolved peacefully. Demands have been partially addressed.", sound_type = ANNOUNCER_DEFAULT)
	rioting_dclass = list()
	demands = list()
	negotiator = null
	negotiation_progress = 0
	suppression_progress = 0

/datum/dclass_riot/proc/get_riot_status()
	if(!riot_active)
		return "No active riot."
	var/stage_name = list("Inactive", "Unrest", "Protest", "Riot", "Armed Uprising")
	var/status = "Stage: [stage_name[min(stage + 1, length(stage_name))]]<br>"
	status += "Escalation Timer: [timer_until_escalation / 10]s<br>"
	status += "Demands: [english_list(demands)]<br>"
	status += "Rioting D-Class: [length(rioting_dclass)]<br>"
	status += "Negotiation Progress: [negotiation_progress]%<br>"
	status += "Suppression Progress: [suppression_progress]%<br>"
	return status

/datum/round_event_control/dclass_riot
	name = "D-Class Riot"
	typepath = /datum/round_event/dclass_riot
	max_occurrences = 2
	weight = 10
	earliest_start = 20 MINUTES

/datum/round_event/dclass_riot
	var/datum/dclass_riot/riot

/datum/round_event/dclass_riot/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 50

/datum/round_event/dclass_riot/announce(fake)
	priority_announce("ALERT: D-Class unrest is escalating in the facility. All security personnel prepare for riot response.", sound_type = ANNOUNCER_ALERT)

/datum/round_event/dclass_riot/start()
	riot = new /datum/dclass_riot()
	riot.start_riot()
	if(SSdclass_riot)
		SSdclass_riot.current_riot = riot
		SSdclass_riot.flags &= ~SS_NO_FIRE

SUBSYSTEM_DEF(dclass_riot)
	name = "D-Class Riot"
	flags = SS_NO_FIRE
	wait = 5 SECONDS
	init_order = INIT_ORDER_DEFAULT
	var/datum/dclass_riot/current_riot = null

/datum/controller/subsystem/dclass_riot/fire(resumed)
	if(current_riot && current_riot.riot_active)
		current_riot.tick()
	else
		if(current_riot)
			current_riot = null
		flags |= SS_NO_FIRE

/datum/controller/subsystem/dclass_riot/proc/can_start_riot()
	if(current_riot && current_riot.riot_active)
		return FALSE
	var/dclass_count = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		if(H.job && findtext(H.job, "D-Class"))
			dclass_count++
	if(dclass_count < 3)
		return FALSE
	return TRUE

/datum/controller/subsystem/dclass_riot/proc/trigger_riot_check()
	if(!can_start_riot())
		return FALSE
	var/chance = 10
	if(!prob(chance))
		return FALSE
	current_riot = new /datum/dclass_riot()
	current_riot.start_riot()
	flags &= ~SS_NO_FIRE
	return TRUE

/obj/machinery/computer/dclass_riot_console
	name = "D-Class Riot Control Console"
	desc = "A secure console for monitoring and responding to D-Class riots."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	req_access = list(ACCESS_SECURITY)

/obj/machinery/computer/dclass_riot_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DClassRiotConsole", "D-Class Riot Control")
		ui.open()

/obj/machinery/computer/dclass_riot_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/dclass_riot_console/ui_data(mob/user)
	var/list/data = list()
	if(SSdclass_riot && SSdclass_riot.current_riot)
		var/datum/dclass_riot/riot = SSdclass_riot.current_riot
		data["riot_active"] = riot.riot_active
		data["stage"] = riot.stage
		data["demands"] = riot.demands
		data["rioting_count"] = length(riot.rioting_dclass)
		data["negotiation_progress"] = riot.negotiation_progress
		data["suppression_progress"] = riot.suppression_progress
		data["escalation_timer"] = riot.timer_until_escalation
		data["has_negotiator"] = riot.negotiator ? TRUE : FALSE
	else
		data["riot_active"] = FALSE
		data["stage"] = 0
		data["demands"] = list()
		data["rioting_count"] = 0
		data["negotiation_progress"] = 0
		data["suppression_progress"] = 0
		data["escalation_timer"] = 0
		data["has_negotiator"] = FALSE
	return data

/obj/machinery/computer/dclass_riot_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		to_chat(H, "<span class='warning'>Access denied.</span>")
		return

	if(!SSdclass_riot || !SSdclass_riot.current_riot || !SSdclass_riot.current_riot.riot_active)
		return

	var/datum/dclass_riot/riot = SSdclass_riot.current_riot

	switch(action)
		if("negotiate")
			riot.attempt_negotiation(H)
			. = TRUE
		if("authorize_suppression")
			riot.suppress_riot(25)
			to_chat(H, "<span class='notice'>Suppression forces authorized. Progress: [riot.suppression_progress]%</span>")
			. = TRUE
		if("accept_demands")
			riot.progress_negotiation(30)
			to_chat(H, "<span class='notice'>Demands partially accepted. Negotiation progress: [riot.negotiation_progress]%</span>")
			. = TRUE
		if("reject_demands")
			riot.escalate_riot()
			to_chat(H, "<span class='warning'>Demands rejected. The situation escalates!</span>")
			. = TRUE
