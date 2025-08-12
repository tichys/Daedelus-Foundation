/client/proc/award_experience()
	set name = "Award Experience"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "Award Experience") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/amount = input("Enter experience amount", "Award Experience") as num
	if(amount <= 0)
		to_chat(src, span_warning("Experience amount must be positive."))
		return

	var/reason = input("Enter reason for award", "Award Experience") as text
	if(!reason)
		reason = "Admin Award"

	var/awarded = SSpersistent_progression.award_experience(target.ckey, "admin_award", amount, reason)

	if(awarded > 0)
		to_chat(src, span_notice("Successfully awarded [awarded] experience to [target.name] for: [reason]"))
		to_chat(target, span_notice("You received [awarded] experience for: [reason]"))
		log_admin("[key_name(usr)] awarded [amount] experience to [key_name(target)] for: [reason]")
		message_admins("[key_name(usr)] awarded [amount] experience to [key_name(target)] for: [reason]")
	else
		to_chat(src, span_warning("Failed to award experience."))

/client/proc/set_player_rank()
	set name = "Set Player Rank"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "Set Rank") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data)
		to_chat(src, span_warning("No persistent data found for this player."))
		return

	var/list/available_classes = list()
	for(var/class_id in SSpersistent_progression.classes)
		var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
		available_classes["[class.class_name] ([class_id])"] = class_id

	var/selected_class = input("Select class", "Set Rank") as null|anything in available_classes
	if(!selected_class)
		return

	var/class_id = available_classes[selected_class]
	var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)

	var/rank_level = input("Select rank level (0-[class.max_rank])", "Set Rank") as num
	if(rank_level < 0 || rank_level > class.max_rank)
		to_chat(src, span_warning("Invalid rank level."))
		return

	// Set the rank by giving enough experience
	var/required_exp = class.get_rank_requirement(rank_level)
	var/exp_needed = required_exp - data.total_experience

	if(exp_needed > 0)
		SSpersistent_progression.award_experience(target.ckey, "admin_award", exp_needed, "Admin Rank Set")

	to_chat(src, span_notice("Set [target.name]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]"))
	log_admin("[key_name(usr)] set [key_name(target)]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]")
	message_admins("[key_name(usr)] set [key_name(target)]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]")

/client/proc/reset_player_progress()
	set name = "Reset Player Progress"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "Reset Progress") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/confirm = alert("Are you sure you want to reset [target.name]'s persistent progress? This cannot be undone.", "Confirm Reset", "Yes", "No")
	if(confirm != "Yes")
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(data)
		data.initialize_default_data()
		SSpersistent_progression.save_player_data(target.ckey)

	to_chat(src, span_notice("Reset [target.name]'s persistent progress."))
	to_chat(target, span_warning("Your persistent progress has been reset by an administrator."))
	log_admin("[key_name(usr)] reset [key_name(target)]'s persistent progress")
	message_admins("[key_name(usr)] reset [key_name(target)]'s persistent progress")

/client/proc/view_player_progress()
	set name = "View Player Progress"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "View Progress") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/datum/persistent_progression_player_view_ui/player_view = new(target.ckey)
	player_view.ui_interact(src)

/client/proc/persistent_progression_panel()
	set name = "Persistent Progression Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	new /datum/persistent_progression_admin_ui(src)

// Facility Persistence Admin Commands
/client/proc/facility_persistence_panel()
	set name = "Facility Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/facility_persistence_manager/manager = SSfacility_persistence.manager
	if(!manager)
		to_chat(src, span_warning("Facility persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "Facility Persistence Management") as null|anything in list(
		"View Facility Status",
		"Save Facility Data",
		"Load Facility Data",
		"Reset Facility Data",
		"View Room States",
		"View Equipment Status",
		"View Security Systems"
	)

	switch(action)
		if("View Facility Status")
			var/message = "<h2>Facility Persistence Status</h2>"
			message += "<b>Facility Health:</b> [manager.facility_health]%<br>"
			message += "<b>Maintenance Level:</b> [manager.maintenance_level]%<br>"
			message += "<b>Security Level:</b> [manager.security_level]<br>"
			message += "<b>Power Efficiency:</b> [manager.power_efficiency * 100]%<br>"
			message += "<b>Containment Stability:</b> [manager.containment_stability]%<br>"
			message += "<b>Facility Age:</b> [manager.facility_age] rounds<br><br>"

			message += "<b>Room States:</b> [manager.room_states.len]<br>"
			message += "<b>Equipment Status:</b> [manager.equipment_status.len]<br>"
			message += "<b>Security Systems:</b> [manager.security_systems.len]<br>"
			message += "<b>Containment Chambers:</b> [manager.containment_chambers.len]<br>"
			message += "<b>Research Labs:</b> [manager.research_labs.len]<br>"
			message += "<b>Medical Facilities:</b> [manager.medical_facilities.len]<br>"
			message += "<b>Engineering Systems:</b> [manager.engineering_systems.len]<br>"

			to_chat(src, span_notice("[message]"))

		if("Save Facility Data")
			manager.save_facility_data()
			to_chat(src, span_notice("Facility data saved successfully."))

		if("Load Facility Data")
			manager.load_facility_data()
			to_chat(src, span_notice("Facility data loaded successfully."))

		if("Reset Facility Data")
			if(alert(src, "Are you sure you want to reset all facility persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.room_states = list()
				manager.equipment_status = list()
				manager.security_systems = list()
				manager.power_grid = list()
				manager.environmental_conditions = list()
				manager.containment_chambers = list()
				manager.research_labs = list()
				manager.medical_facilities = list()
				manager.engineering_systems = list()
				to_chat(src, span_notice("Facility persistence data reset."))

		if("View Room States")
			var/message = "<h3>Room States ([manager.room_states.len])</h3>"
			for(var/type in manager.room_states)
				var/datum/room_state/state = manager.room_states[type]
				message += "<b>[type]:</b> [state.health]% health, [state.damage_level] damage<br>"
			to_chat(src, span_notice("[message]"))

		if("View Equipment Status")
			var/message = "<h3>Equipment Status ([manager.equipment_status.len])</h3>"
			for(var/type in manager.equipment_status)
				var/datum/equipment_status/status = manager.equipment_status[type]
				message += "<b>[type]:</b> [status.health]% health, [status.operational ? "Operational" : "Non-operational"]<br>"
			to_chat(src, span_notice("[message]"))

		if("View Security Systems")
			var/message = "<h3>Security Systems ([manager.security_systems.len])</h3>"
			for(var/key in manager.security_systems)
				var/datum/security_component/comp = manager.security_systems[key]
				message += "<b>[key]:</b> [comp.health]% health, [comp.operational ? "Operational" : "Non-operational"]<br>"
			to_chat(src, span_notice("[message]"))

// SCP Persistence Admin Commands
/client/proc/scp_persistence_panel()
	set name = "SCP Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager
	if(!manager)
		to_chat(src, span_warning("SCP persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "SCP Persistence Management") as null|anything in list(
		"View SCP Status",
		"Save SCP Data",
		"Load SCP Data",
		"Reset SCP Data",
		"Add Research Project",
		"Add SCP Instance",
		"View Research Projects",
		"View Containment Protocols"
	)

	switch(action)
		if("View SCP Status")
			var/message = "<h2>SCP Persistence Status</h2>"
			message += "<b>Global Containment Stability:</b> [manager.global_containment_stability]%<br>"
			message += "<b>Active Breaches:</b> [manager.active_breaches]<br>"
			message += "<b>Research Progress:</b> [manager.research_progress]%<br>"
			message += "<b>Containment Effectiveness:</b> [manager.containment_effectiveness * 100]%<br><br>"

			message += "<b>SCP Instances:</b> [manager.scp_instances.len]<br>"
			message += "<b>Research Projects:</b> [manager.research_projects.len]<br>"
			message += "<b>Containment Protocols:</b> [manager.containment_protocols.len]<br>"
			message += "<b>Anomaly Effects:</b> [manager.anomaly_effects.len]<br>"
			message += "<b>Environmental Changes:</b> [manager.environmental_changes.len]<br>"

			to_chat(src, span_notice("[message]"))

		if("Save SCP Data")
			manager.save_scp_data()
			to_chat(src, span_notice("SCP data saved successfully."))

		if("Load SCP Data")
			manager.load_scp_data()
			to_chat(src, span_notice("SCP data loaded successfully."))

		if("Reset SCP Data")
			if(alert(src, "Are you sure you want to reset all SCP persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.scp_instances = list()
				manager.research_projects = list()
				manager.containment_protocols = list()
				manager.anomaly_effects = list()
				manager.communication_logs = list()
				manager.environmental_changes = list()
				to_chat(src, span_notice("SCP persistence data reset."))

		if("Add Research Project")
			var/project_name = input(src, "Enter project name:", "Add Research Project") as text
			var/project_desc = input(src, "Enter project description:", "Add Research Project") as text

			if(project_name && project_desc)
				var/project_id = "project_[world.time]"
				var/datum/research_project/new_project = new /datum/research_project(project_id, project_name, project_desc)
				manager.research_projects[project_id] = new_project
				to_chat(src, span_notice("Research project '[project_name]' added successfully."))

		if("Add SCP Instance")
			var/scp_id = input(src, "Enter SCP ID (e.g., SCP-173):", "Add SCP Instance") as text
			if(scp_id)
				var/datum/scp_instance/new_instance = new /datum/scp_instance(scp_id, null)
				manager.scp_instances[scp_id] = new_instance
				to_chat(src, span_notice("SCP instance '[scp_id]' added successfully."))

		if("View Research Projects")
			var/message = "<h3>Research Projects ([manager.research_projects.len])</h3>"
			for(var/project_id in manager.research_projects)
				var/datum/research_project/project = manager.research_projects[project_id]
				message += "<b>[project.project_name]:</b> [project.progress]% complete ([project.research_status])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Containment Protocols")
			var/message = "<h3>Containment Protocols ([manager.containment_protocols.len])</h3>"
			for(var/protocol_id in manager.containment_protocols)
				var/datum/containment_protocol/protocol = manager.containment_protocols[protocol_id]
				message += "<b>[protocol.protocol_name]:</b> [protocol.effectiveness * 100]% effective ([protocol.protocol_status])<br>"
			to_chat(src, span_notice("[message]"))

// Technology Persistence Admin Commands
/client/proc/technology_persistence_panel()
	set name = "Technology Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/technology_persistence_manager/manager = SStechnology_persistence.manager
	if(!manager)
		to_chat(src, span_warning("Technology persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "Technology Persistence Management") as null|anything in list(
		"View Technology Status",
		"Save Technology Data",
		"Load Technology Data",
		"Reset Technology Data",
		"Add Research Project",
		"Add Technology",
		"View Research Projects",
		"View Technologies",
		"View Scientific Discoveries"
	)

	switch(action)
		if("View Technology Status")
			var/message = "<h2>Technology Persistence Status</h2>"
			message += "<b>Technology Level:</b> [manager.technology_level]<br>"
			message += "<b>Research Progress:</b> [manager.research_progress]%<br>"
			message += "<b>Innovation Score:</b> [manager.innovation_score]<br>"
			message += "<b>Research Budget:</b> $[manager.research_budget]<br>"
			message += "<b>Research Efficiency:</b> [manager.research_efficiency * 100]%<br><br>"

			message += "<b>Research Projects:</b> [manager.research_projects.len]<br>"
			message += "<b>Technologies:</b> [manager.technology_tree.len]<br>"
			message += "<b>Scientific Discoveries:</b> [manager.scientific_discoveries.len]<br>"
			message += "<b>Research Facilities:</b> [manager.research_facilities.len]<br>"
			message += "<b>Patents:</b> [manager.patents.len]<br>"
			message += "<b>Technology Transfers:</b> [manager.technology_transfers.len]<br>"

			to_chat(src, span_notice("[message]"))

		if("Save Technology Data")
			manager.save_technology_data()
			to_chat(src, span_notice("Technology data saved successfully."))

		if("Load Technology Data")
			manager.load_technology_data()
			to_chat(src, span_notice("Technology data loaded successfully."))

		if("Reset Technology Data")
			if(alert(src, "Are you sure you want to reset all technology persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.research_projects = list()
				manager.technology_tree = list()
				manager.equipment_blueprints = list()
				manager.scientific_discoveries = list()
				manager.research_facilities = list()
				manager.patents = list()
				manager.technology_transfers = list()
				to_chat(src, span_notice("Technology persistence data reset."))

		if("Add Research Project")
			var/project_name = input(src, "Enter project name:", "Add Research Project") as text
			var/project_desc = input(src, "Enter project description:", "Add Research Project") as text
			var/research_field = input(src, "Enter research field:", "Add Research Project") as text

			if(project_name && project_desc)
				var/project_id = "project_[world.time]"
				var/datum/tech_research_project/new_project = new /datum/tech_research_project(project_id, project_name, project_desc, research_field)
				manager.research_projects[project_id] = new_project
				to_chat(src, span_notice("Research project '[project_name]' added successfully."))

		if("Add Technology")
			var/tech_name = input(src, "Enter technology name:", "Add Technology") as text
			var/tech_desc = input(src, "Enter technology description:", "Add Technology") as text

			if(tech_name && tech_desc)
				var/tech_id = "tech_[world.time]"
				var/datum/technology/new_tech = new /datum/technology(tech_id, tech_name, tech_desc)
				manager.technology_tree[tech_id] = new_tech
				to_chat(src, span_notice("Technology '[tech_name]' added successfully."))

		if("View Research Projects")
			var/message = "<h3>Research Projects ([manager.research_projects.len])</h3>"
			for(var/project_id in manager.research_projects)
				var/datum/tech_research_project/project = manager.research_projects[project_id]
				message += "<b>[project.project_name]:</b> [project.progress]% complete ([project.research_status])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Technologies")
			var/message = "<h3>Technologies ([manager.technology_tree.len])</h3>"
			for(var/tech_id in manager.technology_tree)
				var/datum/technology/tech = manager.technology_tree[tech_id]
				message += "<b>[tech.tech_name]:</b> [tech.tech_status] (Level [tech.tech_level])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Scientific Discoveries")
			var/message = "<h3>Scientific Discoveries ([manager.scientific_discoveries.len])</h3>"
			for(var/discovery_id in manager.scientific_discoveries)
				var/datum/scientific_discovery/discovery = manager.scientific_discoveries[discovery_id]
				message += "<b>[discovery.discovery_name]:</b> [discovery.discovery_type] ([discovery.innovation_value] innovation)<br>"
			to_chat(src, span_notice("[message]"))

// Master Persistence Panel - Now uses TGUI interface
// The TGUI version is defined in tgui_master_panel.dm
