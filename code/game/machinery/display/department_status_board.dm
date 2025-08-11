/obj/machinery/display/department_status_board
	name = "Department Status Board"
	desc = "A display showing the current status and budget of all Foundation departments."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	light_color = LIGHT_COLOR_BLUE
	circuit = /obj/item/circuitboard/computer/department_status_board
	/// Whether the board is powered and operational
	var/operational = TRUE
	/// Update frequency in seconds
	var/update_frequency = 30
	/// Last update time
	var/last_update = 0
	/// Display mode: 0 = budgets, 1 = status, 2 = combined
	var/display_mode = 2
	/// Whether to show detailed information
	var/show_detailed = FALSE

/obj/machinery/display/department_status_board/Initialize()
	. = ..()
	update_icon()
	if(SSfoundation_economy)
		SSfoundation_economy.register_status_board(src)

/obj/machinery/display/department_status_board/process()
	if(!operational || !powered())
		return

	if(world.time - last_update >= update_frequency * 10)
		update_display()
		last_update = world.time

/obj/machinery/display/department_status_board/proc/update_display()
	if(!SSeconomy)
		return

	var/list/display_data = list()

	for(var/dept_id in SSeconomy.department_id2name)
		var/datum/bank_account/department/dept = SSeconomy.department_accounts_by_id[dept_id]
		if(dept)
			var/status = get_department_status(dept.account_balance)
			display_data[dept_id] = list(
				"name" = SSeconomy.department_id2name[dept_id],
				"balance" = dept.account_balance,
				"status" = status,
				"color" = get_status_color(status)
			)

	// Update the display with new data
	update_icon()

/obj/machinery/display/department_status_board/proc/get_department_status(balance)
	if(balance > 2000)
		return "EXCELLENT"
	else if(balance > 500)
		return "GOOD"
	else if(balance > 0)
		return "ADEQUATE"
	else if(balance > -500)
		return "LOW"
	else
		return "CRITICAL"

/obj/machinery/display/department_status_board/proc/get_status_color(status)
	switch(status)
		if("EXCELLENT")
			return "#00FF00" // Green
		if("GOOD")
			return "#90EE90" // Light green
		if("ADEQUATE")
			return "#FFFF00" // Yellow
		if("LOW")
			return "#FFA500" // Orange
		if("CRITICAL")
			return "#FF0000" // Red
		else
			return "#FFFFFF" // White

/obj/machinery/display/department_status_board/update_icon()
	. = ..()
	if(!operational || !powered())
		light_color = LIGHT_COLOR_INTENSE_RED
	else
		light_color = LIGHT_COLOR_BLUE

/obj/machinery/display/department_status_board/attack_hand(mob/user)
	if(!operational)
		to_chat(user, span_warning("The display is not operational."))
		return

	ui_interact(user)

/obj/machinery/display/department_status_board/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DepartmentStatusBoard")
		ui.open()

/obj/machinery/display/department_status_board/ui_data(mob/user)
	var/list/data = list()

	// Department data
	data["departments"] = list()
	if(SSeconomy)
		for(var/dept_id in SSeconomy.department_id2name)
			var/datum/bank_account/department/dept = SSeconomy.department_accounts_by_id[dept_id]
			if(dept)
				var/status = get_department_status(dept.account_balance)
				data["departments"] += list(list(
					"id" = dept_id,
					"name" = SSeconomy.department_id2name[dept_id],
					"balance" = dept.account_balance,
					"status" = status,
					"color" = get_status_color(status)
				))

	// Display settings
	data["display_mode"] = display_mode
	data["show_detailed"] = show_detailed
	data["operational"] = operational
	data["powered"] = powered()

	// Research system integration
	if(SSscp_research)
		data["research_points"] = SSscp_research.points_total
		data["active_goals"] = length(SSscp_research.active_goals)
		data["completed_goals"] = length(SSscp_research.completed_goals)

	return data

/obj/machinery/display/department_status_board/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_display_mode")
			display_mode = (display_mode + 1) % 3
			. = TRUE

		if("toggle_detailed")
			show_detailed = !show_detailed
			. = TRUE

/obj/machinery/display/department_status_board/ui_state(mob/user)
	return GLOB.default_state

/obj/item/circuitboard/computer/department_status_board
	name = "Department Status Board (Computer Board)"
	build_path = /obj/machinery/display/department_status_board

/obj/machinery/display/department_status_board/Destroy()
	if(SSfoundation_economy)
		SSfoundation_economy.unregister_status_board(src)
	return ..()
