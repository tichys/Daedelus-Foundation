/datum/persistent_progression_master_ui
	var/client/admin_client

/datum/persistent_progression_master_ui/New(client/admin)
	admin_client = admin
	ui_interact(admin.mob, null)

/datum/persistent_progression_master_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PersistenceMasterPanel", "SCP Foundation - Persistence Control Terminal", 800, 600)
		ui.open()

/datum/persistent_progression_master_ui/ui_state(mob/user)
	if(!admin_client || !admin_client.holder || !check_rights(R_ADMIN, FALSE, admin_client))
		return GLOB.never_state
	return GLOB.always_state

/datum/persistent_progression_master_ui/ui_data(mob/user)
	var/list/data = list()

	// Facility Data
	var/list/facility_data = list()
	if(SSfacility_persistence && SSfacility_persistence.manager)
		var/datum/facility_persistence_manager/facility_manager = SSfacility_persistence.manager
		facility_data = list(
			"facility_health" = facility_manager.facility_health,
			"maintenance_level" = facility_manager.maintenance_level,
			"security_level" = facility_manager.security_level,
			"power_efficiency" = facility_manager.power_efficiency,
			"containment_stability" = facility_manager.containment_stability,
			"room_states_count" = facility_manager.room_states.len,
			"equipment_operational" = facility_manager.equipment_status.len,
			"security_systems_count" = facility_manager.security_systems.len,
		)
	data["facility_data"] = facility_data

	// SCP Data
	var/list/scp_data = list()
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_persistence_manager/scp_manager = SSscp_persistence.manager
		scp_data = list(
			"global_containment_stability" = scp_manager.global_containment_stability,
			"active_breaches" = scp_manager.active_breaches,
			"research_progress" = scp_manager.research_progress,
			"containment_effectiveness" = scp_manager.containment_effectiveness,
			"scp_instances_count" = scp_manager.scp_instances.len,
		)
	data["scp_data"] = scp_data

	// Technology Data
	var/list/technology_data = list()
	if(SStechnology_persistence && SStechnology_persistence.manager)
		var/datum/technology_persistence_manager/tech_manager = SStechnology_persistence.manager
		technology_data = list(
			"technology_level" = tech_manager.technology_level,
			"research_progress" = tech_manager.research_progress,
			"innovation_score" = tech_manager.innovation_score,
			"research_budget" = tech_manager.research_budget,
			"research_efficiency" = tech_manager.research_efficiency,
		)
	data["technology_data"] = technology_data

	// Player Data
	var/list/player_data = list()
	if(SSpersistent_progression)
		var/active_players = 0
		var/total_experience = 0
		var/total_rank = 0
		var/achievements_unlocked = 0
		var/player_count = 0

		for(var/ckey in SSpersistent_progression.player_data)
			var/datum/persistent_player_data/pdata = SSpersistent_progression.player_data[ckey]
			if(pdata)
				active_players++
				total_experience += pdata.total_experience
				total_rank += pdata.current_rank
				achievements_unlocked += pdata.total_achievements_unlocked
				player_count++

		player_data = list(
			"active_players" = active_players,
			"total_experience" = total_experience,
			"average_rank" = player_count > 0 ? total_rank / player_count : 0,
			"achievements_unlocked" = achievements_unlocked,
		)
	data["player_data"] = player_data

	// System Status
	data["system_status"] = "operational"

	return data

/datum/persistent_progression_master_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!admin_client || !admin_client.holder || !check_rights(R_ADMIN, FALSE, admin_client))
		return

	switch(action)
		// Facility Actions
		if("facility_view_status")
			world.log << "PersistenceMasterPanel: Processing facility_view_status for [admin_client.ckey]"
			if(SSfacility_persistence && SSfacility_persistence.manager)
				var/datum/facility_persistence_manager/manager = SSfacility_persistence.manager
				var/message = "<h2>Facility Persistence Status</h2>"
				message += "<b>Facility Health:</b> [manager.facility_health]%<br>"
				message += "<b>Maintenance Level:</b> [manager.maintenance_level]%<br>"
				message += "<b>Security Level:</b> [manager.security_level]<br>"
				message += "<b>Power Efficiency:</b> [manager.power_efficiency * 100]%<br>"
				message += "<b>Containment Stability:</b> [manager.containment_stability]%<br>"
				message += "<b>Room States:</b> [manager.room_states.len]<br>"
				message += "<b>Equipment Status:</b> [manager.equipment_status.len]<br>"
				message += "<b>Security Systems:</b> [manager.security_systems.len]<br>"
				to_chat(admin_client, span_notice("[message]"))
				world.log << "PersistenceMasterPanel: Sent facility status message to [admin_client.ckey]"
			else
				to_chat(admin_client, span_warning("Facility persistence system not available."))
				world.log << "PersistenceMasterPanel: Facility persistence system not available for [admin_client.ckey]"

		if("facility_save_data")
			if(SSfacility_persistence && SSfacility_persistence.manager)
				SSfacility_persistence.manager.save_facility_data()
				to_chat(admin_client, span_notice("Facility data saved successfully."))

		if("facility_load_data")
			if(SSfacility_persistence && SSfacility_persistence.manager)
				SSfacility_persistence.manager.load_facility_data()
				to_chat(admin_client, span_notice("Facility data loaded successfully."))

		if("facility_reset_data")
			if(SSfacility_persistence && SSfacility_persistence.manager)
				if(alert(admin_client, "Are you sure you want to reset all facility persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
					var/datum/facility_persistence_manager/manager = SSfacility_persistence.manager
					manager.room_states = list()
					manager.equipment_status = list()
					manager.security_systems = list()
					manager.power_grid = list()
					manager.environmental_conditions = list()
					manager.containment_chambers = list()
					manager.research_labs = list()
					manager.medical_facilities = list()
					manager.engineering_systems = list()
					to_chat(admin_client, span_notice("Facility persistence data reset."))

		// SCP Actions
		if("scp_view_status")
			if(SSscp_persistence && SSscp_persistence.manager)
				var/datum/scp_persistence_manager/manager = SSscp_persistence.manager
				var/message = "<h2>SCP Persistence Status</h2>"
				message += "<b>Global Containment Stability:</b> [manager.global_containment_stability]%<br>"
				message += "<b>Active Breaches:</b> [manager.active_breaches]<br>"
				message += "<b>Research Progress:</b> [manager.research_progress]%<br>"
				message += "<b>Containment Effectiveness:</b> [manager.containment_effectiveness * 100]%<br>"
				to_chat(admin_client, span_notice("[message]"))

		if("scp_add_instance")
			if(SSscp_persistence && SSscp_persistence.manager)
				var/scp_id = input(admin_client, "Enter SCP ID (e.g., SCP-173):", "Add SCP Instance") as text
				if(scp_id)
					var/datum/scp_instance/new_instance = new /datum/scp_instance(scp_id, null)
					SSscp_persistence.manager.scp_instances[scp_id] = new_instance
					to_chat(admin_client, span_notice("SCP instance '[scp_id]' added successfully."))

		if("scp_add_research")
			if(SSscp_persistence && SSscp_persistence.manager)
				var/project_name = input(admin_client, "Enter project name:", "Add Research Project") as text
				var/project_desc = input(admin_client, "Enter project description:", "Add Research Project") as text
				if(project_name && project_desc)
					var/project_id = "project_[world.time]"
					var/datum/research_project/new_project = new /datum/research_project(project_id, project_name, project_desc)
					SSscp_persistence.manager.research_projects[project_id] = new_project
					to_chat(admin_client, span_notice("Research project '[project_name]' added successfully."))

		if("scp_save_data")
			if(SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence.manager.save_scp_data()
				to_chat(admin_client, span_notice("SCP data saved successfully."))

		// Technology Actions
		if("technology_view_status")
			world.log << "PersistenceMasterPanel: Processing technology_view_status for [admin_client.ckey]"
			if(SStechnology_persistence && SStechnology_persistence.manager)
				var/datum/technology_persistence_manager/manager = SStechnology_persistence.manager
				var/message = "<h2>Technology Persistence Status</h2>"
				message += "<b>Technology Level:</b> [manager.technology_level]<br>"
				message += "<b>Research Progress:</b> [manager.research_progress]%<br>"
				message += "<b>Innovation Score:</b> [manager.innovation_score]<br>"
				message += "<b>Research Budget:</b> $[manager.research_budget]<br>"
				message += "<b>Research Efficiency:</b> [manager.research_efficiency * 100]%<br>"
				message += "<b>Research Projects:</b> [manager.research_projects.len]<br>"
				message += "<b>Technology Tree:</b> [manager.technology_tree.len]<br>"
				to_chat(admin_client, span_notice("[message]"))
				world.log << "PersistenceMasterPanel: Sent technology status message to [admin_client.ckey]"
			else
				to_chat(admin_client, span_warning("Technology persistence system not available."))
				world.log << "PersistenceMasterPanel: Technology persistence system not available for [admin_client.ckey]"

		if("technology_add_project")
			if(SStechnology_persistence && SStechnology_persistence.manager)
				var/project_name = input(admin_client, "Enter project name:", "Add Research Project") as text
				var/project_desc = input(admin_client, "Enter project description:", "Add Research Project") as text
				var/research_field = input(admin_client, "Enter research field:", "Add Research Project") as text
				if(project_name && project_desc)
					var/project_id = "project_[project_name]"
					var/datum/tech_research_project/new_project = new /datum/tech_research_project(project_id, project_name, project_desc, research_field)
					SStechnology_persistence.manager.research_projects[project_id] = new_project
					to_chat(admin_client, span_notice("Research project '[project_name]' added successfully."))

		if("technology_add_tech")
			if(SStechnology_persistence && SStechnology_persistence.manager)
				var/tech_name = input(admin_client, "Enter technology name:", "Add Technology") as text
				var/tech_desc = input(admin_client, "Enter technology description:", "Add Technology") as text
				if(tech_name && tech_desc)
					var/tech_id = "tech_[tech_name]"
					var/datum/technology/new_tech = new /datum/technology(tech_id, tech_name, tech_desc)
					SStechnology_persistence.manager.technology_tree[tech_id] = new_tech
					to_chat(admin_client, span_notice("Technology '[tech_name]' added successfully."))

		if("technology_save_data")
			if(SStechnology_persistence && SStechnology_persistence.manager)
				SStechnology_persistence.manager.save_technology_data()
				to_chat(admin_client, span_notice("Technology data saved successfully."))

		// Player Actions
		if("player_view_data")
			world.log << "PersistenceMasterPanel: Processing player_view_data for [admin_client.ckey]"
			if(SSpersistent_progression)
				var/message = "<h2>Player Persistence Status</h2>"
				var/active_players = 0
				var/total_experience = 0
				var/total_rank = 0
				var/achievements_unlocked = 0
				var/player_count = 0

				for(var/ckey in SSpersistent_progression.player_data)
					var/datum/persistent_player_data/pdata = SSpersistent_progression.player_data[ckey]
					if(pdata)
						active_players++
						total_experience += pdata.total_experience
						total_rank += pdata.current_rank
						achievements_unlocked += pdata.total_achievements_unlocked
						player_count++

				message += "<b>Active Players:</b> [active_players]<br>"
				message += "<b>Total Experience:</b> [total_experience]<br>"
				message += "<b>Average Rank:</b> [player_count > 0 ? total_rank / player_count : 0]<br>"
				message += "<b>Achievements Unlocked:</b> [achievements_unlocked]<br>"
				message += "<b>Total Player Records:</b> [SSpersistent_progression.player_data.len]<br>"
				to_chat(admin_client, span_notice("[message]"))
				world.log << "PersistenceMasterPanel: Sent player status message to [admin_client.ckey]"
			else
				to_chat(admin_client, span_warning("Player persistence system not available."))
				world.log << "PersistenceMasterPanel: Player persistence system not available for [admin_client.ckey]"

		if("player_export_data")
			if(SSpersistent_progression)
				var/export_data = "Player Persistence Data Export\n"
				export_data += "Generated: [time2text(world.time, "YYYY-MM-DD HH:MM:SS")]\n\n"

				for(var/ckey in SSpersistent_progression.player_data)
					var/datum/persistent_player_data/pdata = SSpersistent_progression.player_data[ckey]
					if(pdata)
						export_data += "Player: [ckey]\n"
						export_data += "  Total Experience: [pdata.total_experience]\n"
						export_data += "  Current Rank: [pdata.current_rank]\n"
						export_data += "  Achievements Unlocked: [pdata.total_achievements_unlocked]\n"
						export_data += "  Last Login: [pdata.last_login]\n\n"

				// Save to file
				var/filename = "player_data_export_[time2text(world.time, "YYYY-MM-DD_HH-MM-SS")].txt"
				text2file(export_data, "data/[filename]")
				to_chat(admin_client, span_notice("Player data exported to [filename]"))

		if("player_reset_progress")
			if(SSpersistent_progression)
				if(alert(admin_client, "Are you sure you want to reset ALL player progression data? This cannot be undone!", "Confirm Reset", "Yes", "No") == "Yes")
					// Save empty data for all existing players to clear their progress
					var/list/player_keys = SSpersistent_progression.player_data.Copy()
					for(var/ckey in player_keys)
						var/datum/persistent_player_data/empty_data = new /datum/persistent_player_data()
						SSpersistent_progression.player_data[ckey] = empty_data
						SSpersistent_progression.save_player_data(ckey)
					to_chat(admin_client, span_notice("All player progression data has been reset."))

	return TRUE

// Update the master persistence panel command to use TGUI
/client/proc/master_persistence_panel()
	set name = "Master Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	new /datum/persistent_progression_master_ui(src)
