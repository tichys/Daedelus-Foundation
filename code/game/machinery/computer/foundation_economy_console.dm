/obj/machinery/computer/foundation_economy_console
	name = "Foundation Economy Console"
	desc = "A console for managing department budgets and financial oversight."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	icon_screen = "comm_logs"
	icon_keyboard = "generic_key"
	light_color = LIGHT_COLOR_GREEN
	circuit = /obj/item/circuitboard/computer/foundation_economy_console
	/// Access level required to use this console
	var/required_access = ACCESS_CAPTAIN
	/// Whether this console is locked
	var/locked = TRUE
	/// Audit log of all financial transactions
	var/list/audit_log = list()
	/// Penalty definitions for various violations
	var/list/penalty_definitions = list()

/obj/machinery/computer/foundation_economy_console/Initialize()
	. = ..()
	build_penalty_definitions()
	if(SSfoundation_economy)
		SSfoundation_economy.register_console(src)

/obj/machinery/computer/foundation_economy_console/proc/build_penalty_definitions()
	penalty_definitions = list(
		"excessive_force" = list(
			"name" = "Excessive Force",
			"description" = "Security personnel using unwarranted aggression",
			"department" = ACCOUNT_SEC,
			"amount" = -500,
			"points" = -2
		),
		"dclass_abuse" = list(
			"name" = "D-Class Abuse",
			"description" = "Unnecessary harm to D-Class personnel",
			"department" = ACCOUNT_SEC,
			"amount" = -300,
			"points" = -1
		),
		"research_negligence" = list(
			"name" = "Research Negligence",
			"description" = "Poor documentation or unsafe testing procedures",
			"department" = ACCOUNT_RND,
			"amount" = -400,
			"points" = -2
		),
		"ethics_violation" = list(
			"name" = "Ethics Violation",
			"description" = "Violation of Foundation ethical guidelines",
			"department" = ACCOUNT_GOV,
			"amount" = -1000,
			"points" = -5
		),
		"equipment_misuse" = list(
			"name" = "Equipment Misuse",
			"description" = "Improper use or damage of Foundation equipment",
			"department" = ACCOUNT_ENG,
			"amount" = -200,
			"points" = -1
		)
	)

/obj/machinery/computer/foundation_economy_console/proc/log_transaction(mob/user, action, details, amount = 0, department = null)
	var/log_entry = list(
		"time" = world.time,
		"user" = user ? user.ckey : "SYSTEM",
		"user_name" = user ? user.name : "SYSTEM",
		"action" = action,
		"details" = details,
		"amount" = amount,
		"department" = department
	)
	audit_log += list(log_entry)
	// Keep only last 100 entries
	if(length(audit_log) > 100)
		audit_log = audit_log.Copy(length(audit_log) - 99)

/obj/machinery/computer/foundation_economy_console/proc/apply_penalty(mob/user, penalty_type, target_department = null)
	if(!penalty_definitions[penalty_type])
		return FALSE

	var/penalty = penalty_definitions[penalty_type]
	var/dept = target_department || penalty["department"]
	var/amount = penalty["amount"]
	var/points = penalty["points"]

	if(!SSeconomy)
		return FALSE

	var/datum/bank_account/department/dept_account = SSeconomy.department_accounts_by_id[dept]
	if(!dept_account)
		return FALSE

	dept_account.adjust_money(amount)

	// Log the penalty
	log_transaction(user, "penalty", penalty["name"], amount, dept)

	// Notify relevant personnel
	var/msg = "Department budget penalized: [penalty["name"]] - [abs(amount)] credits"
	log_game("Foundation-Economy: [msg] by [user?.ckey || "SYSTEM"]")

	// Award research points if negative
	if(points < 0 && SSscp_research)
		SSscp_research.points_total += points
		if(user)
			SSscp_research.points_by_ckey[user.ckey] = (SSscp_research.points_by_ckey[user.ckey] || 0) + points

	return TRUE

/obj/machinery/computer/foundation_economy_console/proc/transfer_budget(mob/user, from_dept, to_dept, amount)
	if(!SSeconomy)
		return FALSE

	var/datum/bank_account/department/from_account = SSeconomy.department_accounts_by_id[from_dept]
	var/datum/bank_account/department/to_account = SSeconomy.department_accounts_by_id[to_dept]

	if(!from_account || !to_account)
		return FALSE

	if(from_account.account_balance < amount)
		return FALSE

	from_account.adjust_money(-amount)
	to_account.adjust_money(amount)

	log_transaction(user, "transfer", "Budget transfer from [from_dept] to [to_dept]", amount, from_dept)

	return TRUE

/obj/machinery/computer/foundation_economy_console/attack_hand(mob/user)
	if(!allowed(user))
		to_chat(user, span_warning("Access denied."))
		return

	ui_interact(user)

/obj/machinery/computer/foundation_economy_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationEconomyConsole")
		ui.open()

/obj/machinery/computer/foundation_economy_console/ui_data(mob/user)
	var/list/data = list()

	// Department budgets
	data["departments"] = list()
	if(SSeconomy)
		for(var/dept_id in SSeconomy.department_id2name)
			var/datum/bank_account/department/dept = SSeconomy.department_accounts_by_id[dept_id]
			if(dept)
				data["departments"] += list(list(
					"id" = dept_id,
					"name" = SSeconomy.department_id2name[dept_id],
					"balance" = dept.account_balance,
					"can_transfer" = (dept_id != ACCOUNT_GOV) // GOV can't be transferred from
				))

	// Penalty definitions
	data["penalties"] = penalty_definitions

	// Recent audit log (last 20 entries)
	data["audit_log"] = audit_log.Copy(length(audit_log) - 19, length(audit_log))

	// User permissions
	data["user_access"] = list(
		"can_penalize" = check_access(user, ACCESS_CAPTAIN),
		"can_transfer" = check_access(user, ACCESS_CAPTAIN),
		"can_view_logs" = TRUE
	)

	return data

/obj/machinery/computer/foundation_economy_console/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(!allowed(user))
		return

	switch(action)
		if("apply_penalty")
			var/penalty_type = params["penalty_type"]
			var/target_dept = params["department"]
			if(apply_penalty(user, penalty_type, target_dept))
				. = TRUE

		if("transfer_budget")
			var/from_dept = params["from_department"]
			var/to_dept = params["to_department"]
			var/amount = text2num(params["amount"])
			if(isnum(amount) && amount > 0)
				if(transfer_budget(user, from_dept, to_dept, amount))
					. = TRUE

/obj/machinery/computer/foundation_economy_console/ui_state(mob/user)
	return GLOB.default_state

/obj/item/circuitboard/computer/foundation_economy_console
	name = "Foundation Economy Console (Computer Board)"
	build_path = /obj/machinery/computer/foundation_economy_console

/obj/machinery/computer/foundation_economy_console/Destroy()
	if(SSfoundation_economy)
		SSfoundation_economy.unregister_console(src)
	return ..()
