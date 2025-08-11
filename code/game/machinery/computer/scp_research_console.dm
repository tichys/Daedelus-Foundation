/obj/machinery/computer/scp_research_console
	name = "SCP Research Terminal"
	desc = "Foundation terminal for research monitoring and report submission."
	icon = 'icons/obj/computer.dmi'
	icon_state = "research"
	icon_screen = "research"
	icon_keyboard = "generic_key"
	light_color = LIGHT_COLOR_GREEN
	circuit = /obj/item/circuitboard/computer/scp_research_console
	density = TRUE
	anchored = TRUE

/obj/machinery/computer/scp_research_console/Initialize()
	. = ..()
	// Add a test report if no reports exist (for debugging)
	if(SSscp_research && length(SSscp_research.reports) == 0)
		spawn(10) // Delay to ensure subsystem is fully initialized
			SSscp_research.submit_report(null, "Test Report", "This is a test report to verify the system is working.", "TEST")
			log_game("SCP-Research: Added test report for debugging")

/obj/machinery/computer/scp_research_console/attack_hand(mob/user)
	if(..())
		return
	if(!user || !Adjacent(user))
		return
	ui_interact(user)

/obj/machinery/computer/scp_research_console/verb/debug_research_system()
	set name = "Debug Research System"
	set category = "SCP Research"
	set src in view(1)

	if(SSscp_research)
		SSscp_research.debug_status(usr)
	else
		to_chat(usr, span_warning("SCP Research subsystem is not available!"))

/obj/machinery/computer/scp_research_console/verb/debug_reports()
	set name = "Debug Reports"
	set category = "SCP Research"
	set src in view(1)

	if(SSscp_research)
		to_chat(usr, span_notice("Total reports in system: [length(SSscp_research.reports)]"))
		if(length(SSscp_research.reports) > 0)
			to_chat(usr, span_notice("Recent reports:"))
			var/count = 0
			for(var/list/report in SSscp_research.reports)
				count++
				if(count > 5) break
				to_chat(usr, span_notice("- [report["title"]] (ID: [report["id"]]) by [report["name"]]"))
		else
			to_chat(usr, span_warning("No reports found in system!"))
	else
		to_chat(usr, span_warning("SCP Research subsystem is not available!"))

/obj/machinery/computer/scp_research_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpResearchConsole")
		ui.open()

/obj/machinery/computer/scp_research_console/ui_data(mob/user)
	var/list/data = list()

	// Research data
	data["points_total"] = SSscp_research ? SSscp_research.points_total : 0
	data["points_by_designation"] = SSscp_research ? SSscp_research.points_by_designation : list()
	data["points_by_player"] = SSscp_research ? SSscp_research.points_by_ckey : list()

	// Goals
	data["active_goals"] = list()
	data["completed_goals"] = list()
	if(SSscp_research)
		// Debug: Check if subsystem exists and has goals
		if(user)
			to_chat(user, span_notice("DEBUG: SSscp_research exists, active_goals count: [length(SSscp_research.active_goals)]"))

		for(var/datum/scp_research_goal/G in SSscp_research.active_goals)
			data["active_goals"] += list(list(
				"id" = G.id,
				"title" = G.title,
				"desc" = G.desc,
				"current_count" = G.current_count,
				"required_count" = G.required_count,
				"points_reward" = G.points_reward,
				"cash_reward" = G.cash_reward,
				"budget_reward" = G.budget_reward,
				"repeatable" = G.repeatable
			))
		for(var/datum/scp_research_goal/G in SSscp_research.completed_goals)
			data["completed_goals"] += list(list(
				"id" = G.id,
				"title" = G.title,
				"times_completed" = G.times_completed
			))
	else
		// Debug: Subsystem doesn't exist
		if(user)
			to_chat(user, span_warning("DEBUG: SSscp_research is null!"))

	// Reports
	data["reports"] = SSscp_research ? SSscp_research.get_reports(10) : list()
	// Debug: Log reports being sent to UI
	if(user && SSscp_research)
		to_chat(user, span_notice("DEBUG: Sending [length(data["reports"])] reports to UI"))

	// Recent events
	if(SSscp_research && SSscp_research.event_log)
		var/list/event_log = SSscp_research.event_log
		var/log_length = length(event_log)
		if(log_length > 0)
			var/start_index = max(1, log_length - 19)
			data["recent_events"] = event_log.Copy(start_index, log_length)
		else
			data["recent_events"] = list()
	else
		data["recent_events"] = list()

	return data

/obj/machinery/computer/scp_research_console/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("submit_report")
			// Debug: Log the action received
			log_game("SCP-Research: submit_report action received from [usr?.ckey || "unknown"]")
			log_game("SCP-Research: params = [json_encode(params)]")

			var/title = params["title"]
			var/body = params["body"]
			var/designation = params["designation"]

			if(!title || !body)
				to_chat(usr, span_warning("Report submission failed: Title and Body are required."))
				log_game("SCP-Research: Report submission failed - missing title or body")
				return

			if(SSscp_research)
				var/id = SSscp_research.submit_report(usr, title, body, designation)
				to_chat(usr, span_notice("Report [id] submitted successfully."))
				log_game("SCP-Research: Report [id] submitted successfully by [usr?.ckey || "unknown"]")
				// Force UI update to show the new report
				SStgui.update_uis(src)
				. = TRUE
			else
				log_game("SCP-Research: Report submission failed - SSscp_research is null")
				to_chat(usr, span_warning("Report submission failed: Research system unavailable."))

		if("test_action")
			log_game("SCP-Research: test_action received from [usr?.ckey || "unknown"]")
			to_chat(usr, span_notice("Test action received! Check server logs."))
			. = TRUE

/obj/machinery/computer/scp_research_console/ui_state(mob/user)
	return GLOB.default_state

/obj/item/circuitboard/computer/scp_research_console
	name = "SCP Research Terminal (Computer Board)"
	build_path = /obj/machinery/computer/scp_research_console


