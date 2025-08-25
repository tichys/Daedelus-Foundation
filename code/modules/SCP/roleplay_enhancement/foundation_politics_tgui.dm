// Foundation Politics System TGUI Backend
// Handles the TGUI interface for Foundation politics and hierarchy

/datum/foundation_politics_ui
	var/mob/user
	var/datum/department/selected_department
	var/datum/faction/selected_faction

/datum/foundation_politics_ui/New(mob/user)
	src.user = user

/datum/foundation_politics_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationPolitics")
		ui.open()

/datum/foundation_politics_ui/ui_data(mob/user)
	var/list/data = list()

	// Get departments
	data["departments"] = get_departments()

	// Get factions
	data["factions"] = get_factions()

	// Get power structures
	data["power_structures"] = get_power_structures()

	// Get political events
	data["political_events"] = get_political_events()

	// Get alliances and conflicts
	data["alliances"] = get_alliances()
	data["conflicts"] = get_conflicts()

	// Get metrics
	data["metrics"] = get_politics_metrics()

	return data

/datum/foundation_politics_ui/proc/get_departments()
	var/list/departments = list()

	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/dept_id in SSfoundation_politics.manager.departments)
			var/datum/department/dept = SSfoundation_politics.manager.departments[dept_id]
			if(dept)
				departments[dept_id] = list(
					"department_id" = dept.department_id,
					"name" = dept.department_name,
					"type" = dept.department_type,
					"head" = dept.department_head,
					"budget" = dept.department_budget,
					"influence" = dept.department_influence,
					"status" = dept.department_status,
					"members" = dept.department_members,
					"projects" = dept.department_projects,
					"resources" = dept.department_resources,
					"policies" = dept.department_policies,
					"allies" = dept.department_allies,
					"rivals" = dept.department_rivals,
					"goals" = dept.department_goals,
					"achievements" = dept.department_achievements,
					"creation_date" = dept.department_creation_date,
					"last_updated" = dept.department_last_updated
				)

	return departments

/datum/foundation_politics_ui/proc/get_factions()
	var/list/factions = list()

	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/faction_id in SSfoundation_politics.manager.factions)
			var/datum/faction/faction = SSfoundation_politics.manager.factions[faction_id]
			if(faction)
				factions[faction_id] = list(
					"faction_id" = faction.faction_id,
					"name" = faction.faction_name,
					"type" = faction.faction_type,
					"leader" = faction.faction_leader,
					"influence" = faction.faction_influence,
					"membership" = faction.faction_membership,
					"goals" = faction.faction_goals,
					"ideology" = faction.faction_ideology,
					"resources" = faction.faction_resources,
					"allies" = faction.faction_allies,
					"enemies" = faction.faction_enemies,
					"activities" = faction.faction_activities,
					"achievements" = faction.faction_achievements,
					"creation_date" = faction.faction_creation_date,
					"last_updated" = faction.faction_last_updated
				)

	return factions

/datum/foundation_politics_ui/proc/get_power_structures()
	var/list/power_structures = list()

	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/structure_id in SSfoundation_politics.manager.power_structures)
			var/datum/power_structure/structure = SSfoundation_politics.manager.power_structures[structure_id]
			if(structure)
				power_structures[structure_id] = list(
					"structure_id" = structure.structure_id,
					"name" = structure.structure_name,
					"type" = structure.structure_type,
					"leader" = structure.structure_leader,
					"members" = structure.structure_members,
					"policies" = structure.structure_policies,
					"influence" = structure.structure_influence,
					"alliances" = structure.structure_alliances,
					"conflicts" = structure.structure_conflicts,
					"decisions" = structure.structure_decisions,
					"creation_date" = structure.structure_creation_date,
					"last_updated" = structure.structure_last_updated
				)

	return power_structures

/datum/foundation_politics_ui/proc/get_political_events()
	var/list/events = list()

	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/event_id in SSfoundation_politics.manager.political_events)
			var/datum/political_event/event = SSfoundation_politics.manager.political_events[event_id]
			if(event)
				events += list(list(
					"event_id" = event.event_id,
					"event_type" = event.event_type,
					"event_title" = event.event_title,
					"event_description" = event.event_description,
					"event_participants" = event.event_participants,
					"event_outcome" = event.event_outcome,
					"event_impact" = event.event_impact,
					"event_creation_date" = event.event_creation_date,
					"event_resolution_date" = event.event_resolution_date
				))

	return events

/datum/foundation_politics_ui/proc/get_alliances()
	var/list/alliances = list()

	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/alliance_id in SSfoundation_politics.manager.alliances)
			var/alliance = SSfoundation_politics.manager.alliances[alliance_id]
			if(alliance)
				alliances += list(list(
					"alliance_id" = alliance_id,
					"alliance_name" = alliance["name"],
					"alliance_type" = alliance["type"],
					"alliance_description" = alliance["description"],
					"alliance_strength" = alliance["strength"],
					"alliance_members" = alliance["members"]
				))

	return alliances

/datum/foundation_politics_ui/proc/get_conflicts()
	var/list/conflicts = list()

	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/conflict_id in SSfoundation_politics.manager.conflicts)
			var/conflict = SSfoundation_politics.manager.conflicts[conflict_id]
			if(conflict)
				conflicts += list(list(
					"conflict_id" = conflict_id,
					"conflict_title" = conflict["title"],
					"conflict_type" = conflict["type"],
					"conflict_description" = conflict["description"],
					"conflict_severity" = conflict["severity"],
					"conflict_parties" = conflict["parties"]
				))

	return conflicts

/datum/foundation_politics_ui/proc/get_politics_metrics()
	var/list/metrics = list()

	if(SSfoundation_politics && SSfoundation_politics.manager)
		metrics["total_departments"] = SSfoundation_politics.manager.total_departments
		metrics["active_factions"] = SSfoundation_politics.manager.active_factions
		metrics["political_tensions"] = SSfoundation_politics.manager.political_tensions
		metrics["power_balance_score"] = SSfoundation_politics.manager.power_balance_score
		metrics["alliance_network_size"] = SSfoundation_politics.manager.alliance_network_size
		metrics["conflict_resolution_rate"] = SSfoundation_politics.manager.conflict_resolution_rate

	return metrics

/datum/foundation_politics_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!user || !user.ckey)
		return

	switch(action)
		if("create_department")
			var/name = input(user, "Enter department name:", "Create Department") as text|null
			if(!name)
				return

			var/dept_type = input(user, "Select department type:", "Create Department") as null|anything in list("research", "security", "medical", "engineering", "administrative")
			if(!dept_type)
				return

			var/head = input(user, "Enter department head:", "Create Department") as text|null
			if(!head)
				return

			if(SSfoundation_politics && SSfoundation_politics.manager)
				var/datum/department/new_dept = SSfoundation_politics.manager.create_department(name, dept_type, head)
				if(new_dept)
					to_chat(user, "<span class='notice'>Department '[name]' created successfully!</span>")
					. = TRUE

		if("create_faction")
			var/name = input(user, "Enter faction name:", "Create Faction") as text|null
			if(!name)
				return

			var/faction_type = input(user, "Select faction type:", "Create Faction") as null|anything in list("conservative", "progressive", "militant", "scientific", "bureaucratic")
			if(!faction_type)
				return

			var/leader = input(user, "Enter faction leader:", "Create Faction") as text|null
			if(!leader)
				return

			if(SSfoundation_politics && SSfoundation_politics.manager)
				var/datum/faction/new_faction = SSfoundation_politics.manager.create_faction(name, faction_type, leader)
				if(new_faction)
					to_chat(user, "<span class='notice'>Faction '[name]' created successfully!</span>")
					. = TRUE

		if("create_power_structure")
			var/name = input(user, "Enter power structure name:", "Create Power Structure") as text|null
			if(!name)
				return

			var/structure_type = input(user, "Select structure type:", "Create Power Structure") as null|anything in list("hierarchical", "democratic", "oligarchic", "autocratic")
			if(!structure_type)
				return

			var/leader = input(user, "Enter structure leader:", "Create Power Structure") as text|null
			if(!leader)
				return

			if(SSfoundation_politics && SSfoundation_politics.manager)
				var/datum/power_structure/new_structure = SSfoundation_politics.manager.create_power_structure(name, structure_type, leader)
				if(new_structure)
					to_chat(user, "<span class='notice'>Power structure '[name]' created successfully!</span>")
					. = TRUE

		if("update_department")
			var/dept_id = params["dept_id"]
			var/field = params["field"]
			var/value = params["value"]

			if(dept_id && field && value != null)
				if(SSfoundation_politics && SSfoundation_politics.manager)
					var/datum/department/dept = SSfoundation_politics.manager.departments[dept_id]
					if(dept)
						dept.vars[field] = value
						dept.department_last_updated = world.time
						. = TRUE

		if("update_faction")
			var/faction_id = params["faction_id"]
			var/field = params["field"]
			var/value = params["value"]

			if(faction_id && field && value != null)
				if(SSfoundation_politics && SSfoundation_politics.manager)
					var/datum/faction/faction = SSfoundation_politics.manager.factions[faction_id]
					if(faction)
						faction.vars[field] = value
						faction.faction_last_updated = world.time
						. = TRUE

		if("add_department_member")
			var/dept_id = params["dept_id"]
			if(!dept_id)
				return

			var/member = input(user, "Enter member name:", "Add Department Member") as text|null
			if(!member)
				return

			if(SSfoundation_politics && SSfoundation_politics.manager)
				var/datum/department/dept = SSfoundation_politics.manager.departments[dept_id]
				if(dept)
					dept.department_members += member
					dept.department_last_updated = world.time
					to_chat(user, "<span class='notice'>Added [member] to department!</span>")
					. = TRUE

		if("add_faction_member")
			var/faction_id = params["faction_id"]
			if(!faction_id)
				return

			var/member = input(user, "Enter member name:", "Add Faction Member") as text|null
			if(!member)
				return

			if(SSfoundation_politics && SSfoundation_politics.manager)
				var/datum/faction/faction = SSfoundation_politics.manager.factions[faction_id]
				if(faction)
					faction.faction_membership += 1
					faction.faction_last_updated = world.time
					to_chat(user, "<span class='notice'>Added member to faction!</span>")
					. = TRUE

		if("create_political_event")
			var/event_type = input(user, "Select event type:", "Create Political Event") as null|anything in list("election", "scandal", "alliance", "conflict", "policy_change")
			if(!event_type)
				return

			var/title = input(user, "Enter event title:", "Create Political Event") as text|null
			if(!title)
				return

			var/description = input(user, "Enter event description:", "Create Political Event") as message|null
			if(!description)
				return

			if(SSfoundation_politics && SSfoundation_politics.manager)
				var/event_id = "event_[world.time]_[user.ckey]"
				var/datum/political_event/new_event = new /datum/political_event(event_id, event_type, title, description)
				SSfoundation_politics.manager.political_events[event_id] = new_event
				to_chat(user, "<span class='notice'>Political event '[title]' created successfully!</span>")
				. = TRUE

		if("resolve_conflict")
			var/conflict_id = params["conflict_id"]
			if(!conflict_id)
				return

			if(SSfoundation_politics && SSfoundation_politics.manager)
				SSfoundation_politics.manager.resolve_conflict(conflict_id)
				to_chat(user, "<span class='notice'>Conflict resolved successfully!</span>")
				. = TRUE

// Verb to open Foundation politics system
/mob/verb/open_foundation_politics()
	set name = "Open Foundation Politics"
	set category = "Roleplay"
	set desc = "Open the Foundation politics and hierarchy system"

	var/datum/foundation_politics_ui/ui = new /datum/foundation_politics_ui(src)
	ui.ui_interact(src)

// Admin verb to manage Foundation politics system
/mob/proc/manage_foundation_politics()
	set name = "Manage Foundation Politics"
	set category = "Admin"
	set desc = "Manage the Foundation politics system"

	if(!check_rights(R_ADMIN))
		return

	var/datum/foundation_politics_ui/ui = new /datum/foundation_politics_ui(src)
	ui.ui_interact(src)
