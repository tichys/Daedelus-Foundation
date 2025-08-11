SUBSYSTEM_DEF(foundation_economy)
	name = "Foundation Economy"
	wait = 30 SECONDS
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_FOUNDATION_ECONOMY

	/// List of all economy consoles
	var/list/economy_consoles = list()
	/// List of all status boards
	var/list/status_boards = list()
	/// Automatic penalty tracking
	var/list/penalty_tracking = list()
	/// Round start time for tracking
	var/round_start_time = 0

/datum/controller/subsystem/foundation_economy/Initialize()
	round_start_time = world.time
	build_penalty_tracking()
	return ..()

/datum/controller/subsystem/foundation_economy/proc/build_penalty_tracking()
	penalty_tracking = list(
		"excessive_force" = list(
			"count" = 0,
			"last_occurrence" = 0,
			"threshold" = 3, // Number of incidents before auto-penalty
			"cooldown" = 5 MINUTES
		),
		"dclass_abuse" = list(
			"count" = 0,
			"last_occurrence" = 0,
			"threshold" = 2,
			"cooldown" = 3 MINUTES
		),
		"research_negligence" = list(
			"count" = 0,
			"last_occurrence" = 0,
			"threshold" = 4,
			"cooldown" = 10 MINUTES
		),
		"equipment_misuse" = list(
			"count" = 0,
			"last_occurrence" = 0,
			"threshold" = 5,
			"cooldown" = 2 MINUTES
		)
	)

/datum/controller/subsystem/foundation_economy/proc/register_console(obj/machinery/computer/foundation_economy_console/console)
	if(!(console in economy_consoles))
		economy_consoles += console

/datum/controller/subsystem/foundation_economy/proc/unregister_console(obj/machinery/computer/foundation_economy_console/console)
	economy_consoles -= console

/datum/controller/subsystem/foundation_economy/proc/register_status_board(obj/machinery/display/department_status_board/board)
	if(!(board in status_boards))
		status_boards += board

/datum/controller/subsystem/foundation_economy/proc/unregister_status_board(obj/machinery/display/department_status_board/board)
	status_boards -= board

/datum/controller/subsystem/foundation_economy/proc/track_violation(violation_type, mob/user, details = "")
	if(!penalty_tracking[violation_type])
		return

	var/tracking = penalty_tracking[violation_type]
	var/current_time = world.time

	// Check cooldown
	if(current_time - tracking["last_occurrence"] < tracking["cooldown"])
		return

	tracking["count"]++
	tracking["last_occurrence"] = current_time

	// Log the violation
	log_game("Foundation-Economy: [violation_type] violation by [user?.ckey || "UNKNOWN"] - [details]")

	// Check if threshold reached for auto-penalty
	if(tracking["count"] >= tracking["threshold"])
		apply_automatic_penalty(violation_type, user, details)
		tracking["count"] = 0 // Reset counter

/datum/controller/subsystem/foundation_economy/proc/apply_automatic_penalty(violation_type, mob/user, details)
	// Find the first available economy console to apply the penalty
	for(var/obj/machinery/computer/foundation_economy_console/console in economy_consoles)
		if(console.powered())
			console.apply_penalty(user, violation_type)
			to_chat(user, span_warning("Automatic penalty applied for [violation_type] violation."))
			return

	// If no console available, apply directly to the economy system
	if(SSeconomy)
		var/penalty_definitions = list(
			"excessive_force" = list("department" = ACCOUNT_SEC, "amount" = -500),
			"dclass_abuse" = list("department" = ACCOUNT_SEC, "amount" = -300),
			"research_negligence" = list("department" = ACCOUNT_RND, "amount" = -400),
			"equipment_misuse" = list("department" = ACCOUNT_ENG, "amount" = -200)
		)

		var/penalty = penalty_definitions[violation_type]
		if(penalty)
			var/datum/bank_account/department/dept = SSeconomy.department_accounts_by_id[penalty["department"]]
			if(dept)
				dept.adjust_money(penalty["amount"])
				log_game("Foundation-Economy: Automatic penalty [violation_type] applied to [penalty["department"]] - [penalty["amount"]] credits")

/datum/controller/subsystem/foundation_economy/proc/get_economy_summary()
	var/list/summary = list()

	if(SSeconomy)
		summary["total_budget"] = 0
		summary["departments"] = list()

		for(var/dept_id in SSeconomy.department_id2name)
			var/datum/bank_account/department/dept = SSeconomy.department_accounts_by_id[dept_id]
			if(dept)
				summary["total_budget"] += dept.account_balance
				summary["departments"][dept_id] = list(
					"name" = SSeconomy.department_id2name[dept_id],
					"balance" = dept.account_balance
				)

	summary["round_duration"] = world.time - round_start_time
	summary["violations"] = penalty_tracking

	return summary

/datum/controller/subsystem/foundation_economy/fire()
	// Periodic economy monitoring and automatic actions
	if(!SSeconomy)
		return

	// Check for critically low budgets and apply warnings
	for(var/dept_id in SSeconomy.department_id2name)
		var/datum/bank_account/department/dept = SSeconomy.department_accounts_by_id[dept_id]
		if(dept && dept.account_balance < -1000)
			// Send warning to relevant personnel
			var/warning_msg = "CRITICAL: [SSeconomy.department_id2name[dept_id]] budget critically low: [dept.account_balance] credits"
			log_game("Foundation-Economy: [warning_msg]")

			// Notify heads of staff
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.mind && H.mind.assigned_role && (H.mind.assigned_role in list("Captain", "Head of Personnel", "Head of Security", "Research Director", "Chief Engineer")))
					to_chat(H, span_warning("[warning_msg]"))

/datum/controller/subsystem/foundation_economy/stat_entry(msg)
	msg = "Consoles:[length(economy_consoles)] Boards:[length(status_boards)]"
	return ..()
