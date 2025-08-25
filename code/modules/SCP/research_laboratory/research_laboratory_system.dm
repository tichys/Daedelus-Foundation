// Advanced Research Laboratory System
// A comprehensive, centralized research system for SCP Foundation experiments and studies

SUBSYSTEM_DEF(research_laboratory)
	name = "Research Laboratory"
	wait = 600 // 10 seconds
	priority = FIRE_PRIORITY_RESEARCH
	init_order = INIT_ORDER_RESEARCH
	var/datum/research_laboratory_manager/manager

/datum/controller/subsystem/research_laboratory/Initialize()
	manager = new /datum/research_laboratory_manager()
	world.log << "Research Laboratory Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/research_laboratory/fire()
	if(manager)
		manager.process_research_laboratory()

// Research Laboratory Manager
/datum/research_laboratory_manager
	var/list/research_projects = list() // project_id -> project_data
	var/list/active_experiments = list() // experiment_id -> experiment_data
	var/list/research_facilities = list() // facility_id -> facility_data
	var/list/research_teams = list() // team_id -> team_data
	var/list/research_data = list() // data_id -> research_data
	var/list/experiment_protocols = list() // protocol_id -> protocol_data
	var/list/safety_protocols = list() // safety_id -> safety_data
	var/list/research_achievements = list() // achievement_id -> achievement_data

	// Research metrics
	var/total_research_points = 0
	var/total_experiments_conducted = 0
	var/total_breakthroughs = 0
	var/research_efficiency = 1.0
	var/safety_rating = 100.0
	var/containment_breaches = 0
	var/research_incidents = 0

	// Facility management
	var/list/laboratory_rooms = list()
	var/list/containment_chambers = list()
	var/list/observation_decks = list()
	var/list/analysis_labs = list()
	var/list/storage_facilities = list()

/datum/research_laboratory_manager/proc/process_research_laboratory()
	// Process active experiments with skill integration
	for(var/experiment_id in active_experiments)
		var/list/experiment = active_experiments[experiment_id]
		if(experiment["status"] == "active")
			process_experiment_with_skills(experiment_id)

	// Generate research reports
	generate_research_reports()

	// Update research metrics
	// update_research_metrics() // This proc will be implemented when research metrics are needed

/datum/research_laboratory_manager/proc/process_experiment_with_skills(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	// Get research team members
	var/list/team_members = get_experiment_team_members(experiment_id)
	var/total_skill_bonus = 0

	// Calculate skill bonuses from team members
	for(var/member_data in team_members)
		var/mob/living/carbon/human/researcher = get_researcher_by_ckey(member_data["ckey"])
		if(researcher && researcher.mind)
			var/research_skill = researcher.mind.get_skill_level(/datum/skill/research) || 0
			total_skill_bonus += research_skill * 0.01 // +1% per skill level per team member

			// Apply research skill effects
			if(SSskill_integration && SSskill_integration.manager)
				SSskill_integration.manager.apply_research_skill_effects(researcher, experiment["name"])

	// Apply skill bonuses to experiment progress
	var/base_progress_rate = experiment["progress_rate"] || 1.0
	var/skill_enhanced_rate = base_progress_rate * (1 + total_skill_bonus)

	// Update experiment progress
	experiment["current_progress"] += skill_enhanced_rate

	// Check for breakthroughs with skill-enhanced chances
	if(experiment["current_progress"] >= experiment["max_progress"] * 0.8) // 80% progress
		var/base_breakthrough_chance = experiment["breakthrough_chance"] || 5
		var/enhanced_chance = base_breakthrough_chance

		// Apply skill-based breakthrough chance enhancement
		if(SSskill_integration && SSskill_integration.manager)
			var/lead_researcher = get_lead_researcher(experiment_id)
			if(lead_researcher)
				enhanced_chance = SSskill_integration.manager.calculate_research_breakthrough_chance(lead_researcher, base_breakthrough_chance)

		if(prob(enhanced_chance))
			trigger_research_breakthrough(experiment_id)

	// Check for completion
	if(experiment["current_progress"] >= experiment["max_progress"])
		complete_experiment(experiment_id)

/datum/research_laboratory_manager/proc/get_experiment_team_members(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return list()

	var/team_id = experiment["team_id"]
	if(!team_id)
		return list()

	var/list/team = research_teams[team_id]
	if(!team)
		return list()

	return team["members"] || list()

/datum/research_laboratory_manager/proc/get_researcher_by_ckey(ckey)
	for(var/mob/living/carbon/human/H in world)
		if(H.ckey == ckey)
			return H
	return null

/datum/research_laboratory_manager/proc/get_lead_researcher(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return null

	var/team_id = experiment["team_id"]
	if(!team_id)
		return null

	var/list/team = research_teams[team_id]
	if(!team || !team["members"])
		return null

	// Find the first team member as lead researcher
	var/list/members = team["members"]
	if(members.len > 0)
		return get_researcher_by_ckey(members[1]["ckey"])

	return null

/datum/research_laboratory_manager/proc/complete_experiment(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	experiment["status"] = "completed"
	experiment["completion_time"] = world.time

	// Award research points with skill bonuses
	var/base_points = experiment["research_points"] || 100
	var/enhanced_points = base_points

	// Apply skill bonuses to research points
	if(SSskill_integration)
		var/lead_researcher = get_lead_researcher(experiment_id)
		if(lead_researcher)
			enhanced_points = SSskill_integration.manager.apply_research_skill_bonuses(lead_researcher, "experiment", base_points)

	total_research_points += enhanced_points

	// Award experience to team members
	award_experiment_experience(experiment_id, enhanced_points)

	// Announce completion
	announce_experiment_completion(experiment_id, enhanced_points)

/datum/research_laboratory_manager/proc/award_experiment_experience(experiment_id, research_points)
	var/list/team_members = get_experiment_team_members(experiment_id)
	var/points_per_member = research_points / max(team_members.len, 1)

	for(var/member_data in team_members)
		var/mob/living/carbon/human/researcher = get_researcher_by_ckey(member_data["ckey"])
		if(researcher && SSskill_integration)
			SSskill_integration.manager.add_experience(researcher, /datum/skill/research, points_per_member)

/datum/research_laboratory_manager/proc/announce_experiment_completion(experiment_id, research_points)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	var/completion_message = "RESEARCH COMPLETED: [experiment["name"]] has been completed! Research points awarded: [research_points]"

	// Notify all research personnel
	for(var/mob/living/carbon/human/H in world)
		if(H.mind && H.mind.assigned_role && is_research_role(H.mind.assigned_role))
			to_chat(H, "<span class='boldnotice'>[completion_message]</span>")

	// Log completion
	log_game("Research experiment completed: [experiment["name"]] - [research_points] points")

/datum/research_laboratory_manager/proc/monitor_experiment_safety(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	var/risk_level = experiment["risk_level"] || 1
	var/safety_threshold = experiment["safety_threshold"] || 50

	// Check for safety violations
	if(risk_level > safety_threshold)
		trigger_safety_protocol(experiment_id)
		safety_rating = max(0, safety_rating - 5)

/datum/research_laboratory_manager/proc/trigger_safety_protocol(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	experiment["status"] = "suspended"
	experiment["safety_violations"] = (experiment["safety_violations"] || 0) + 1

	// Notify research team
	notify_research_team(experiment["team_id"], "Safety protocol triggered for experiment [experiment_id]")

	// Log incident
	log_research_incident(experiment_id, "Safety violation detected")

/datum/research_laboratory_manager/proc/trigger_research_breakthrough(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	total_breakthroughs++
	experiment["breakthrough"] = TRUE
	experiment["breakthrough_time"] = world.time

	// Award bonus research points
	var/bonus_points = experiment["research_points"] * 2
	total_research_points += bonus_points

	// Announce breakthrough
	announce_research_breakthrough(experiment_id)

/datum/research_laboratory_manager/proc/announce_research_breakthrough(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	var/breakthrough_message = "RESEARCH BREAKTHROUGH: [experiment["name"]] has achieved a major breakthrough!"

	// Notify all research personnel
	for(var/mob/living/carbon/human/H in world)
		if(H.mind && H.mind.assigned_role && is_research_role(H.mind.assigned_role))
			to_chat(H, "<span class='boldnotice'>[breakthrough_message]</span>")

	// Log breakthrough
	log_game("Research breakthrough achieved: [experiment["name"]]")

/datum/research_laboratory_manager/proc/is_research_role(role)
	var/research_roles = list("Scientist", "Research Director", "Geneticist", "Roboticist", "Xenobiologist")
	return role in research_roles

// Research Project Management
/datum/research_laboratory_manager/proc/create_research_project(project_data)
	var/project_id = "project_[world.time]_[rand(1000, 9999)]"

	project_data["id"] = project_id
	project_data["creation_time"] = world.time
	project_data["status"] = "proposed"
	project_data["progress"] = 0

	research_projects[project_id] = project_data

	return project_id

/datum/research_laboratory_manager/proc/approve_research_project(project_id)
	var/list/project = research_projects[project_id]
	if(!project)
		return FALSE

	project["status"] = "approved"
	project["approval_time"] = world.time

	// Create initial experiment
	create_experiment_from_project(project_id)

	return TRUE

/datum/research_laboratory_manager/proc/create_experiment_from_project(project_id)
	var/list/project = research_projects[project_id]
	if(!project)
		return

	var/experiment_id = "exp_[world.time]_[rand(1000, 9999)]"

	var/list/experiment_data = list(
		"id" = experiment_id,
		"project_id" = project_id,
		"name" = project["name"],
		"description" = project["description"],
		"scp_target" = project["scp_target"],
		"research_points" = project["research_points"] || 100,
		"risk_level" = project["risk_level"] || 1,
		"safety_threshold" = project["safety_threshold"] || 50,
		"progress_rate" = project["progress_rate"] || 1.0,
		"max_progress" = project["max_progress"] || 100,
		"breakthrough_chance" = project["breakthrough_chance"] || 5,
		"team_id" = project["team_id"],
		"facility_id" = project["facility_id"],
		"status" = "active",
		"start_time" = world.time,
		"current_progress" = 0,
		"data_points_collected" = 0
	)

	active_experiments[experiment_id] = experiment_data

	return experiment_id

// Research Team Management
/datum/research_laboratory_manager/proc/create_research_team(team_data)
	var/team_id = "team_[world.time]_[rand(1000, 9999)]"

	team_data["id"] = team_id
	team_data["creation_time"] = world.time
	team_data["status"] = "active"
	team_data["members"] = list()
	team_data["completed_experiments"] = 0
	team_data["total_research_points"] = 0

	research_teams[team_id] = team_data

	return team_id

/datum/research_laboratory_manager/proc/add_team_member(team_id, mob/living/carbon/human/researcher)
	var/list/team = research_teams[team_id]
	if(!team)
		return FALSE

	var/member_data = list(
		"ckey" = researcher.ckey,
		"name" = researcher.real_name,
		"role" = researcher.mind?.assigned_role || "Researcher",
		"join_time" = world.time,
		"research_contribution" = 0
	)

	team["members"] += list(member_data)

	return TRUE

/datum/research_laboratory_manager/proc/notify_research_team(team_id, message)
	var/list/team = research_teams[team_id]
	if(!team)
		return

	for(var/member in team["members"])
		var/ckey = member["ckey"]
		for(var/mob/living/carbon/human/H in world)
			if(H.ckey == ckey)
				to_chat(H, "<span class='notice'>[message]</span>")
				break

// Research Facility Management
/datum/research_laboratory_manager/proc/register_research_facility(facility_data)
	var/facility_id = "facility_[world.time]_[rand(1000, 9999)]"

	facility_data["id"] = facility_id
	facility_data["registration_time"] = world.time
	facility_data["status"] = "operational"
	facility_data["active_experiments"] = 0
	facility_data["safety_rating"] = 100.0

	research_facilities[facility_id] = facility_data

	return facility_id

/datum/research_laboratory_manager/proc/update_research_facilities()
	for(var/facility_id in research_facilities)
		var/list/facility = research_facilities[facility_id]
		if(!facility)
			continue

		// Count active experiments
		var/active_count = 0
		for(var/experiment_id in active_experiments)
			var/list/experiment = active_experiments[experiment_id]
			if(experiment["facility_id"] == facility_id && experiment["status"] == "active")
				active_count++

		facility["active_experiments"] = active_count

		// Update safety rating
		update_facility_safety_rating(facility_id)

/datum/research_laboratory_manager/proc/update_facility_safety_rating(facility_id)
	var/list/facility = research_facilities[facility_id]
	if(!facility)
		return

	var/total_risk = 0
	var/experiment_count = 0

	for(var/experiment_id in active_experiments)
		var/list/experiment = active_experiments[experiment_id]
		if(experiment["facility_id"] == facility_id && experiment["status"] == "active")
			total_risk += experiment["risk_level"] || 1
			experiment_count++

	if(experiment_count > 0)
		var/average_risk = total_risk / experiment_count
		facility["safety_rating"] = max(0, 100 - (average_risk * 10))

// Safety Protocol Management
/datum/research_laboratory_manager/proc/create_safety_protocol(protocol_data)
	var/protocol_id = "safety_[world.time]_[rand(1000, 9999)]"

	protocol_data["id"] = protocol_id
	protocol_data["creation_time"] = world.time
	protocol_data["status"] = "active"
	protocol_data["violations"] = 0

	safety_protocols[protocol_id] = protocol_data

	return protocol_id

/datum/research_laboratory_manager/proc/update_safety_protocols()
	for(var/protocol_id in safety_protocols)
		var/list/protocol = safety_protocols[protocol_id]
		if(!protocol)
			continue

		// Check for violations
		check_protocol_violations(protocol_id)

/datum/research_laboratory_manager/proc/check_protocol_violations(protocol_id)
	var/list/protocol = safety_protocols[protocol_id]
	if(!protocol)
		return

	var/violation_threshold = protocol["violation_threshold"] || 5
	var/current_violations = protocol["violations"] || 0

	if(current_violations >= violation_threshold)
		trigger_emergency_protocol(protocol_id)

/datum/research_laboratory_manager/proc/trigger_emergency_protocol(protocol_id)
	var/list/protocol = safety_protocols[protocol_id]
	if(!protocol)
		return

	protocol["status"] = "emergency"
	protocol["emergency_time"] = world.time

	// Notify all research personnel
	for(var/mob/living/carbon/human/H in world)
		if(H.mind && H.mind.assigned_role && is_research_role(H.mind.assigned_role))
			to_chat(H, "<span class='bolddanger'>EMERGENCY PROTOCOL ACTIVATED: [protocol["name"]]</span>")

	// Log emergency
	log_game("Emergency protocol activated: [protocol["name"]]")

// Research Data Management
/datum/research_laboratory_manager/proc/collect_research_data(experiment_id, data_type, data_value)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	var/data_id = "data_[world.time]_[rand(1000, 9999)]"

	var/list/data_entry = list(
		"id" = data_id,
		"experiment_id" = experiment_id,
		"data_type" = data_type,
		"data_value" = data_value,
		"collection_time" = world.time,
		"researcher" = "system"
	)

	research_data[data_id] = data_entry

	// Update experiment data points
	experiment["data_points_collected"] = (experiment["data_points_collected"] || 0) + 1

/datum/research_laboratory_manager/proc/generate_research_reports()
	// Generate periodic research reports
	if(world.time % 6000 == 0) // Every 10 minutes
		generate_system_report()

/datum/research_laboratory_manager/proc/generate_system_report()
	var/report = "=== RESEARCH LABORATORY SYSTEM REPORT ===\n"
	report += "Total Research Points: [total_research_points]\n"
	report += "Active Experiments: [length(active_experiments)]\n"
	report += "Research Teams: [length(research_teams)]\n"
	report += "Safety Rating: [safety_rating]%\n"
	report += "Total Breakthroughs: [total_breakthroughs]\n"
	report += "Research Incidents: [research_incidents]\n"
	report += "==========================================\n"

	world.log << report

/datum/research_laboratory_manager/proc/generate_experiment_report(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	var/report = "=== EXPERIMENT COMPLETION REPORT ===\n"
	report += "Experiment: [experiment["name"]]\n"
	report += "Duration: [round((experiment["completion_time"] - experiment["start_time"]) / 600)] minutes\n"
	report += "Research Points: [experiment["research_points"]]\n"
	report += "Data Points Collected: [experiment["data_points_collected"]]\n"
	report += "Breakthrough: [experiment["breakthrough"] ? "YES" : "NO"]\n"
	report += "Safety Violations: [experiment["safety_violations"] || 0]\n"
	report += "=====================================\n"

	world.log << report

/datum/research_laboratory_manager/proc/log_research_incident(experiment_id, incident_description)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	research_incidents++

	var/incident_log = "RESEARCH INCIDENT: [incident_description] - Experiment: [experiment["name"]]"
	world.log << incident_log

/datum/research_laboratory_manager/proc/check_research_achievements(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return

	// Check for various achievements
	if(experiment["breakthrough"])
		check_breakthrough_achievements(experiment_id)

	if(experiment["data_points_collected"] >= 100)
		check_data_collection_achievements(experiment_id)

/datum/research_laboratory_manager/proc/check_breakthrough_achievements(experiment_id)
	// Check for breakthrough-related achievements
	if(total_breakthroughs >= 10)
		unlock_achievement("breakthrough_master", "Achieved 10 research breakthroughs")

	if(total_breakthroughs >= 50)
		unlock_achievement("breakthrough_expert", "Achieved 50 research breakthroughs")

/datum/research_laboratory_manager/proc/check_data_collection_achievements(experiment_id)
	// Check for data collection achievements
	var/total_data_points = 0
	for(var/data_id in research_data)
		total_data_points++

	if(total_data_points >= 1000)
		unlock_achievement("data_collector", "Collected 1000 research data points")

	if(total_data_points >= 10000)
		unlock_achievement("data_expert", "Collected 10000 research data points")

/datum/research_laboratory_manager/proc/unlock_achievement(achievement_id, achievement_description)
	if(achievement_id in research_achievements)
		return // Already unlocked

	research_achievements[achievement_id] = list(
		"id" = achievement_id,
		"description" = achievement_description,
		"unlock_time" = world.time
	)

	// Announce achievement
	for(var/mob/living/carbon/human/H in world)
		if(H.mind && H.mind.assigned_role && is_research_role(H.mind.assigned_role))
			to_chat(H, "<span class='boldnotice'>ACHIEVEMENT UNLOCKED: [achievement_description]</span>")

	world.log << "Research Achievement Unlocked: [achievement_description]"

/datum/research_laboratory_manager/proc/save_research_data()
	// Save research data to persistent storage
	// This would integrate with your existing persistence system
	world.log << "Research Laboratory: Saving research data to persistent storage"

	// Sync with research persistence system
	sync_with_research_persistence()

	// Sync with SCP research system
	sync_with_scp_research()

	// Sync with technology persistence system
	sync_with_technology_persistence()

/datum/research_laboratory_manager/proc/sync_with_research_persistence()
	if(!SSresearch_persistence || !SSresearch_persistence.manager)
		return

	var/datum/research_persistence_manager/research_mgr = SSresearch_persistence.manager

	// Sync research projects
	for(var/project_id in research_projects)
		var/list/project = research_projects[project_id]
		if(project["source"] != "persistence") // Don't sync back to avoid loops
			// Create or update persistent project
			if(!research_mgr.research_projects[project_id])
				research_mgr.add_research_project(
					project["name"],
					project["description"],
					project["research_field"] || "GENERAL",
					project["lead_researcher"] || "",
					project["budget_allocated"] || 0,
					project["priority"] || 1
				)

	// Update global metrics
	research_mgr.total_research_projects = length(research_projects)
	research_mgr.research_efficiency = research_efficiency
	research_mgr.scientific_breakthroughs = total_breakthroughs

/datum/research_laboratory_manager/proc/sync_with_scp_research()
	if(!SSscp_research || !SSscp_research.manager)
		return

	var/datum/scp_research_manager/scp_mgr = SSscp_research.manager

	// Sync SCP research data
	scp_mgr.total_research_points = max(scp_mgr.total_research_points, total_research_points)
	scp_mgr.research_breakthroughs = max(scp_mgr.research_breakthroughs, total_breakthroughs)

/datum/research_laboratory_manager/proc/sync_with_technology_persistence()
	if(!SStechnology_persistence || !SStechnology_persistence.manager)
		return

	var/datum/technology_persistence_manager/tech_mgr = SStechnology_persistence.manager

	// Sync technology data
	tech_mgr.research_progress = max(tech_mgr.research_progress, total_experiments_conducted)
	tech_mgr.innovation_score = max(tech_mgr.innovation_score, total_breakthroughs * 100)

/datum/research_laboratory_manager/proc/process_research_teams()
	// Process and update research teams
	for(var/team_id in research_teams)
		var/list/team = research_teams[team_id]
		if(!team)
			continue

		// Update team performance metrics
		update_team_performance(team_id)

		// Check team achievements
		check_team_achievements(team_id)

		// Process team collaboration
		process_team_collaboration(team_id)

/datum/research_laboratory_manager/proc/update_team_performance(team_id)
	var/list/team = research_teams[team_id]
	if(!team)
		return

	// Calculate team performance based on completed experiments
	var/team_performance = 0
	for(var/experiment_id in active_experiments)
		var/list/experiment = active_experiments[experiment_id]
		if(experiment["team_id"] == team_id && experiment["status"] == "completed")
			team_performance += experiment["research_points"] || 0

	team["performance"] = team_performance
	team["last_updated"] = world.time

/datum/research_laboratory_manager/proc/check_team_achievements(team_id)
	var/list/team = research_teams[team_id]
	if(!team)
		return

	var/team_performance = team["performance"] || 0

	// Check for team performance achievements
	if(team_performance >= 1000)
		unlock_team_achievement(team_id, "high_performer", "Team achieved 1000 research points")

	if(team_performance >= 5000)
		unlock_team_achievement(team_id, "expert_team", "Team achieved 5000 research points")

/datum/research_laboratory_manager/proc/unlock_team_achievement(team_id, achievement_id, achievement_description)
	var/list/team = research_teams[team_id]
	if(!team)
		return

	if(!team["achievements"])
		team["achievements"] = list()

	if(achievement_id in team["achievements"])
		return // Already unlocked

	team["achievements"][achievement_id] = list(
		"id" = achievement_id,
		"description" = achievement_description,
		"unlock_time" = world.time
	)

	world.log << "Team Achievement Unlocked: [achievement_description] for team [team_id]"

/datum/research_laboratory_manager/proc/process_team_collaboration(team_id)
	var/list/team = research_teams[team_id]
	if(!team)
		return

	// Process team collaboration bonuses
	var/team_size = length(team["members"] || list())
	if(team_size >= 3)
		// Apply collaboration bonus
		team["collaboration_bonus"] = min(20, (team_size - 2) * 5)
	else
		team["collaboration_bonus"] = 0

// Research Laboratory Interface
/datum/research_laboratory_interface
	var/client/admin_client
	var/datum/research_laboratory_manager/lab_manager

/datum/research_laboratory_interface/New(client/admin)
	admin_client = admin
	lab_manager = SSresearch_laboratory.manager
	ui_interact(admin.mob, null)

/datum/research_laboratory_interface/ui_state(mob/user)
	return GLOB.admin_state

/datum/research_laboratory_interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ResearchLaboratory", "Research Laboratory System")
		ui.open()

/datum/research_laboratory_interface/ui_data(mob/user)
	var/list/data = list()

	// Get data from research laboratory manager
	data["research_projects"] = lab_manager.research_projects
	data["active_experiments"] = lab_manager.active_experiments
	data["research_teams"] = lab_manager.research_teams
	data["research_facilities"] = lab_manager.research_facilities
	data["safety_protocols"] = lab_manager.safety_protocols
	data["research_achievements"] = lab_manager.research_achievements

	// Add researcher skill data
	data["researcher_skills"] = get_researcher_skill_data()

	// Add skill-based bonuses to experiments
	enhance_experiments_with_skill_data(data["active_experiments"])

	// Add skill-based bonuses to teams
	enhance_teams_with_skill_data(data["research_teams"])

	// Integrate with existing research persistence systems
	if(SSresearch_persistence && SSresearch_persistence.manager)
		var/datum/research_persistence_manager/research_mgr = SSresearch_persistence.manager
		// Merge research projects from persistence system
		for(var/project_id in research_mgr.research_projects)
			if(!data["research_projects"][project_id])
				var/datum/research_persistence_project/persistent_project = research_mgr.research_projects[project_id]
				data["research_projects"][project_id] = list(
					"id" = project_id,
					"name" = persistent_project.project_name,
					"description" = persistent_project.project_description,
					"research_field" = persistent_project.research_field,
					"lead_researcher" = persistent_project.lead_researcher,
					"progress" = persistent_project.progress,
					"status" = persistent_project.status,
					"budget_allocated" = persistent_project.budget_allocated,
					"budget_used" = persistent_project.budget_used,
					"start_date" = persistent_project.start_date,
					"estimated_completion" = persistent_project.estimated_completion,
					"priority" = persistent_project.priority,
					"source" = "persistence"
				)

	// Integrate with SCP research system
	if(SSscp_research && SSscp_research.manager)
		var/datum/scp_research_manager/scp_mgr = SSscp_research.manager
		// Add SCP-specific research data
		data["scp_research_data"] = list(
			"total_research_points" = scp_mgr.total_research_points,
			"research_breakthroughs" = scp_mgr.research_breakthroughs,
			"containment_improvements" = scp_mgr.containment_improvements,
			"classification_updates" = scp_mgr.classification_updates
		)

	// Integrate with technology persistence system
	if(SStechnology_persistence && SStechnology_persistence.manager)
		var/datum/technology_persistence_manager/tech_mgr = SStechnology_persistence.manager
		data["technology_data"] = list(
			"technology_level" = tech_mgr.technology_level,
			"innovation_score" = tech_mgr.innovation_score,
			"research_progress" = tech_mgr.research_progress,
			"breakthrough_chance" = tech_mgr.breakthrough_chance
		)

	data["system_metrics"] = list(
		"total_research_points" = lab_manager.total_research_points,
		"total_experiments" = lab_manager.total_experiments_conducted,
		"total_breakthroughs" = lab_manager.total_breakthroughs,
		"research_efficiency" = lab_manager.research_efficiency,
		"safety_rating" = lab_manager.safety_rating,
		"containment_breaches" = lab_manager.containment_breaches,
		"research_incidents" = lab_manager.research_incidents
	)

	return data

/datum/research_laboratory_interface/proc/get_researcher_skill_data()
	var/list/researcher_skills = list()

	// Get all researchers and their skill levels
	for(var/mob/living/carbon/human/H in world)
		if(H.mind && H.mind.assigned_role && lab_manager.is_research_role(H.mind.assigned_role))
			var/research_skill = H.mind.get_skill_level(/datum/skill/research) || 0
			var/skill_bonus = research_skill * 2 // +2% per level

			researcher_skills[H.real_name] = list(
				"skill_name" = "Research",
				"level" = research_skill,
				"bonus" = skill_bonus,
				"ckey" = H.ckey
			)

	return researcher_skills

/datum/research_laboratory_interface/proc/enhance_experiments_with_skill_data(list/experiments)
	if(!experiments)
		return

	for(var/experiment_id in experiments)
		var/list/experiment = experiments[experiment_id]
		if(!experiment)
			continue

		// Calculate skill bonus for this experiment
		var/skill_bonus = 0
		var/breakthrough_chance = experiment["breakthrough_chance"] || 5

		// Get team members and calculate their skill bonuses
		var/team_id = experiment["team_id"]
		if(team_id && lab_manager.research_teams[team_id])
			var/list/team = lab_manager.research_teams[team_id]
			var/list/members = team["members"] || list()

			for(var/member_data in members)
				var/mob/living/carbon/human/researcher = lab_manager.get_researcher_by_ckey(member_data["ckey"])
				if(researcher && researcher.mind)
					var/research_skill = researcher.mind.get_skill_level(/datum/skill/research) || 0
					skill_bonus += research_skill * 1 // +1% per skill level per team member

			// Enhance breakthrough chance based on lead researcher
			var/lead_researcher = lab_manager.get_lead_researcher(experiment_id)
			if(lead_researcher && SSskill_integration)
				breakthrough_chance = SSskill_integration.manager.calculate_research_breakthrough_chance(lead_researcher, breakthrough_chance)

		experiment["skill_bonus"] = skill_bonus
		experiment["breakthrough_chance"] = breakthrough_chance

/datum/research_laboratory_interface/proc/enhance_teams_with_skill_data(list/teams)
	if(!teams)
		return

	for(var/team_id in teams)
		var/list/team = teams[team_id]
		if(!team)
			continue

		// Calculate average research skill for the team
		var/list/members = team["members"] || list()
		var/total_skill = 0
		var/skill_count = 0

		for(var/member_data in members)
			var/mob/living/carbon/human/researcher = lab_manager.get_researcher_by_ckey(member_data["ckey"])
			if(researcher && researcher.mind)
				var/research_skill = researcher.mind.get_skill_level(/datum/skill/research) || 0
				total_skill += research_skill
				skill_count++

		var/avg_skill = skill_count > 0 ? total_skill / skill_count : 0
		team["avg_research_skill"] = avg_skill

/datum/research_laboratory_interface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("create_project")
			create_new_project(params)
			. = TRUE

		if("approve_project")
			var/project_id = params["project_id"]
			if(project_id)
				lab_manager.approve_research_project(project_id)
			. = TRUE

		if("create_team")
			create_new_team(params)
			. = TRUE

		if("add_team_member")
			var/team_id = params["team_id"]
			var/mob/living/carbon/human/researcher = locate(params["researcher"])
			if(team_id && researcher)
				lab_manager.add_team_member(team_id, researcher)
			. = TRUE

		if("create_facility")
			create_new_facility(params)
			. = TRUE

		if("create_safety_protocol")
			create_new_safety_protocol(params)
			. = TRUE

/datum/research_laboratory_interface/proc/create_new_project(list/project_data)
	var/project_id = lab_manager.create_research_project(project_data)
	to_chat(admin_client, "<span class='notice'>Research project created: [project_id]</span>")

/datum/research_laboratory_interface/proc/create_new_team(list/team_data)
	var/team_id = lab_manager.create_research_team(team_data)
	to_chat(admin_client, "<span class='notice'>Research team created: [team_id]</span>")

/datum/research_laboratory_interface/proc/create_new_facility(list/facility_data)
	var/facility_id = lab_manager.register_research_facility(facility_data)
	to_chat(admin_client, "<span class='notice'>Research facility registered: [facility_id]</span>")

/datum/research_laboratory_interface/proc/create_new_safety_protocol(list/protocol_data)
	var/protocol_id = lab_manager.create_safety_protocol(protocol_data)
	to_chat(admin_client, "<span class='notice'>Safety protocol created: [protocol_id]</span>")

// Admin verb to access the research laboratory
/client/proc/open_research_laboratory()
	set name = "Research Laboratory"
	set category = "Admin"
	set desc = "Open the advanced research laboratory system"

	if(!check_rights(R_ADMIN))
		return

	var/datum/research_laboratory_interface/interface = new(src)
	interface.ui_interact(usr)


