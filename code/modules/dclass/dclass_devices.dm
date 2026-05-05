// D-Class Tablet and Management Console
// In-game devices for D-Class status and management

#ifndef DCLASS_STATUS_GENERAL
#define DCLASS_STATUS_GENERAL 0
#define DCLASS_STATUS_MEDICAL_SUBJECT 1
#define DCLASS_STATUS_TEST_SUBJECT 2
#define DCLASS_STATUS_OBSERVATION 3
#define DCLASS_STATUS_SCP_HOST 4
#define DCLASS_STATUS_ESCAPED 5
#endif

/obj/item/dclass_tablet
	name = "D-Class Terminal"
	desc = "A locked-down tablet for D-Class personnel."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/dclass_tablet/attack_self(mob/user)
	if(!ishuman(user))
		return
	ui_interact(user)

/obj/item/dclass_tablet/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DclassTablet", name)
		ui.open()

/obj/item/dclass_tablet/ui_data(mob/user)
	var/list/data = list()
	var/datum/dclass_player/player = SSdclass?.manager?.get_dclass_player(user.ckey)
	if(!player)
		return data

	data["dclass_number"] = player.dclass_number || "D-????"
	data["trust_level"] = player.trust_level
	data["trust_name"] = player.get_trust_name(player.trust_level)
	data["trust_points"] = player.trust_points
	data["credits"] = player.credits
	data["level"] = player.level
	data["experience"] = player.experience
	data["required_experience"] = player.calculate_required_experience(player.level)
	data["tests_completed"] = player.tests_completed
	data["strikes"] = player.strikes
	data["max_strikes"] = 3
	data["status"] = player.status
	data["can_volunteer"] = player.can_volunteer
	data["is_informant"] = player.informant

	return data

/obj/item/dclass_tablet/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/H = usr
	if(!ishuman(H))
		return

	var/datum/dclass_player/player = SSdclass?.manager?.get_dclass_player(H.ckey)
	if(!player)
		return

	switch(action)
		if("volunteer")
			if(player.can_volunteer && player.status == DCLASS_STATUS_GENERAL)
				H.volunteer_for_testing()
				. = TRUE
		if("view_work")
			if(player.current_work_assignment)
				to_chat(H, span_notice("Current work: [player.current_work_assignment]"))
			else
				to_chat(H, span_notice("No current work assignment."))

/obj/machinery/computer/dclass_management
	name = "D-Class Management Console"
	desc = "Console for managing D-Class."
	icon = 'icons/obj/computer.dmi'
	icon_state = "research"
	anchored = TRUE

/obj/machinery/computer/dclass_management/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/list/authorized = list("Research Director", "Scientist", "Senior Researcher", "Containment Specialist")
	if(!(H.job in authorized))
		to_chat(H, span_warning("Access denied."))
		return

	var/info = "<h3>D-CLASS MANAGEMENT</h3>"
	info += "<b>Total D-Class:</b> [length(SSdclass?.manager?.dclass_players || list())]<br>"
	info += "<b>Active Tests:</b> [length(SSdclass_experiments?.active_test_subjects || list())]<br>"

	if(SSdclass?.manager)
		info += "<b>Security:</b> [SSdclass.manager.current_security_level]/4<br>"
		info += "<b>Time:</b> [SSdclass.manager.current_time_slot]<br>"

	to_chat(H, span_notice(info))

	for(var/ckey in SSdclass?.manager?.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player) continue
		info = "[player.dclass_number || ckey] - Trust: [player.get_trust_name(player.trust_level)], Tests: [player.tests_completed]"
		to_chat(H, span_notice(info))