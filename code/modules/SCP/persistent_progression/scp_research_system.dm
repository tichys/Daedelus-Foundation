// SCP Research Incentive System
// Provides rewards and progression for researching SCPs

SUBSYSTEM_DEF(scp_research)
	name = "SCP Research"
	wait = 600 // 10 minutes
	priority = FIRE_PRIORITY_INPUT

	var/datum/scp_research_manager/manager

/datum/scp_research_manager
	var/list/research_projects = list() // project_id -> research_data
	var/list/research_rewards = list() // reward_id -> reward_data
	var/list/researcher_profiles = list() // ckey -> researcher_data
	var/list/research_milestones = list() // milestone_id -> milestone_data

	// Research metrics
	var/total_research_points = 0
	var/total_research_funding = 0
	var/research_breakthroughs = 0
	var/containment_improvements = 0
	var/classification_updates = 0

	// Reward multipliers
	var/research_point_multiplier = 1.0
	var/budget_reward_multiplier = 1.0
	var/progression_multiplier = 1.0

/datum/research_data
	var/project_id
	var/scp_designation
	var/research_type
	var/research_level = 0
	var/max_research_level = 10
	var/research_points = 0
	var/research_cost = 1000
	var/research_time = 0
	var/researcher_ckey
	var/status = "ACTIVE"
	var/list/research_notes = list()
	var/list/discoveries = list()
	var/timestamp
	var/completion_reward = 0

/datum/research_data/New(project_id, scp_designation, research_type, researcher_ckey)
	src.project_id = project_id
	src.scp_designation = scp_designation
	src.research_type = research_type
	src.researcher_ckey = researcher_ckey
	src.timestamp = world.time

/datum/researcher_data
	var/ckey
	var/research_points = 0
	var/research_funding = 0
	var/progression_points = 0
	var/total_projects = 0
	var/completed_projects = 0
	var/failed_projects = 0
	var/research_rank = "Trainee"
	var/list/completed_research = list()
	var/list/achievements = list()
	var/list/specializations = list()
	var/timestamp

/datum/researcher_data/New(ckey)
	src.ckey = ckey
	src.timestamp = world.time

/datum/research_reward_data
	var/reward_id
	var/reward_type
	var/reward_amount = 0
	var/reward_description = ""
	var/requirements = list()
	var/unlocked = FALSE
	var/timestamp

/datum/research_reward_data/New(reward_id, reward_type, reward_amount, reward_description)
	src.reward_id = reward_id
	src.reward_type = reward_type
	src.reward_amount = reward_amount
	src.reward_description = reward_description
	src.timestamp = world.time

/datum/research_milestone_data
	var/milestone_id
	var/milestone_name
	var/milestone_description
	var/requirements = list()
	var/rewards = list()
	var/completed = FALSE
	var/completion_time
	var/completed_by

/datum/research_milestone_data/New(milestone_id, milestone_name, milestone_description)
	src.milestone_id = milestone_id
	src.milestone_name = milestone_name
	src.milestone_description = milestone_description

// Research Manager Methods
/datum/scp_research_manager/proc/initialize_research_system()
	// Initialize research rewards
	initialize_research_rewards()

	// Initialize research milestones
	initialize_research_milestones()

	world.log << "SCP Research: Research system initialized with [length(research_rewards)] rewards and [length(research_milestones)] milestones"

/datum/scp_research_manager/proc/initialize_research_rewards()
	// Budget rewards
	add_research_reward("budget_1000", "budget", 1000, "Research Grant: Basic funding for SCP research")
	add_research_reward("budget_5000", "budget", 5000, "Research Grant: Substantial funding for advanced research")
	add_research_reward("budget_10000", "budget", 10000, "Research Grant: Major funding for breakthrough research")

	// Progression rewards
	add_research_reward("progression_100", "progression", 100, "Research Experience: Basic research skills")
	add_research_reward("progression_500", "progression", 500, "Research Experience: Advanced research methodology")
	add_research_reward("progression_1000", "progression", 1000, "Research Experience: Expert research techniques")

	// Equipment rewards
	add_research_reward("equipment_scanner", "equipment", 1, "Advanced SCP Scanner: Enhanced detection capabilities")
	add_research_reward("equipment_analyzer", "equipment", 1, "SCP Analyzer: Detailed SCP property analysis")
	add_research_reward("equipment_containment", "equipment", 1, "Containment Tools: Improved SCP containment methods")

/datum/scp_research_manager/proc/initialize_research_milestones()
	// Research milestones
	add_research_milestone("first_research", "First Research Project", "Complete your first SCP research project")
	add_research_milestone("research_10", "Dedicated Researcher", "Complete 10 research projects")
	add_research_milestone("research_50", "Research Expert", "Complete 50 research projects")
	add_research_milestone("research_100", "Research Master", "Complete 100 research projects")

	// Breakthrough milestones
	add_research_milestone("first_breakthrough", "First Breakthrough", "Achieve your first research breakthrough")
	add_research_milestone("breakthrough_5", "Breakthrough Specialist", "Achieve 5 research breakthroughs")
	add_research_milestone("breakthrough_10", "Breakthrough Master", "Achieve 10 research breakthroughs")

/datum/scp_research_manager/proc/add_research_reward(var/reward_id, var/reward_type, var/reward_amount, var/reward_description)
	var/datum/research_reward_data/reward = new(reward_id, reward_type, reward_amount, reward_description)
	research_rewards[reward_id] = reward

/datum/scp_research_manager/proc/add_research_milestone(var/milestone_id, var/milestone_name, var/milestone_description)
	var/datum/research_milestone_data/milestone = new(milestone_id, milestone_name, milestone_description)
	research_milestones[milestone_id] = milestone

/datum/scp_research_manager/proc/start_research_project(var/scp_designation, var/research_type, var/researcher_ckey)
	var/project_id = "research_[scp_designation]_[research_type]_[world.time]"
	var/datum/research_data/project = new(project_id, scp_designation, research_type, researcher_ckey)

	research_projects[project_id] = project

	// Get or create researcher profile
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	researcher.total_projects++

	world.log << "SCP Research: Research project [project_id] started by [researcher_ckey]"
	return project

/datum/scp_research_manager/proc/get_researcher_profile(var/ckey)
	if(!researcher_profiles[ckey])
		researcher_profiles[ckey] = new /datum/researcher_data(ckey)
	return researcher_profiles[ckey]

/datum/scp_research_manager/proc/add_research_points(var/project_id, var/points, var/researcher_ckey)
	var/datum/research_data/project = research_projects[project_id]
	if(!project)
		return FALSE

	project.research_points += points * research_point_multiplier
	project.research_time = world.time - project.timestamp

	// Check for level up
	var/old_level = project.research_level
	project.research_level = min(project.max_research_level, floor(project.research_points / 100))

	if(project.research_level > old_level)
		on_research_level_up(project, researcher_ckey)
		check_cross_interaction_discoveries(project.scp_designation, researcher_ckey)

	// Update researcher profile
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	researcher.research_points += points * research_point_multiplier

	// Check for breakthroughs
	if(project.research_points >= project.research_cost && project.status == "ACTIVE")
		complete_research_project(project_id, researcher_ckey)

	return TRUE

/datum/scp_research_manager/proc/on_research_level_up(var/datum/research_data/project, var/researcher_ckey)
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)

	// Give immediate rewards for level up
	var/level_reward = project.research_level * 100
	researcher.research_points += level_reward

	// Notify researcher
	notify_researcher(researcher_ckey, "Research Level Up!", "Your research on [project.scp_designation] has reached level [project.research_level]! +[level_reward] research points")

	world.log << "SCP Research: [researcher_ckey] reached research level [project.research_level] on [project.scp_designation]"

/datum/scp_research_manager/proc/complete_research_project(var/project_id, var/researcher_ckey)
	var/datum/research_data/project = research_projects[project_id]
	if(!project || project.status != "ACTIVE")
		return FALSE

	project.status = "COMPLETED"
	project.completion_reward = calculate_completion_reward(project)

	// Update researcher profile
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	researcher.completed_projects++
	researcher.research_points += project.completion_reward
	researcher.completed_research += project.scp_designation

	// Award budget to research department
	var/budget_reward = project.completion_reward * budget_reward_multiplier
	if(SSbudget_system && SSbudget_system.manager)
		SSbudget_system.manager.add_transaction("research", "REVENUE", budget_reward, "research_funding", "Research completion: [project.scp_designation] - [project.research_type]", researcher_ckey)

	// Award progression points
	var/progression_reward = project.completion_reward * progression_multiplier
	researcher.progression_points += progression_reward

	// Check for breakthroughs
	if(project.research_level >= 5)
		research_breakthroughs++
		notify_researcher(researcher_ckey, "Research Breakthrough!", "You've achieved a breakthrough in [project.scp_designation] research!")

	// Check milestones
	check_research_milestones(researcher_ckey)

	// Notify researcher
	notify_researcher(researcher_ckey, "Research Complete!", "Research on [project.scp_designation] completed! +[project.completion_reward] research points, +[budget_reward] budget, +[progression_reward] progression")

	world.log << "SCP Research: [researcher_ckey] completed research on [project.scp_designation]"
	return TRUE

/datum/scp_research_manager/proc/calculate_completion_reward(var/datum/research_data/project)
	var/base_reward = 500
	var/level_bonus = project.research_level * 100
	var/time_bonus = min(1000, (world.time - project.timestamp) / 600) // 1 point per 10 minutes, max 1000

	return base_reward + level_bonus + time_bonus

/datum/scp_research_manager/proc/check_research_milestones(var/researcher_ckey)
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)

	for(var/milestone_id in research_milestones)
		var/datum/research_milestone_data/milestone = research_milestones[milestone_id]
		if(milestone.completed)
			continue

		var/completed = FALSE
		switch(milestone_id)
			if("first_research")
				completed = researcher.completed_projects >= 1
			if("research_10")
				completed = researcher.completed_projects >= 10
			if("research_50")
				completed = researcher.completed_projects >= 50
			if("research_100")
				completed = researcher.completed_projects >= 100
			if("first_breakthrough")
				completed = research_breakthroughs >= 1
			if("breakthrough_5")
				completed = research_breakthroughs >= 5
			if("breakthrough_10")
				completed = research_breakthroughs >= 10

		if(completed)
			complete_milestone(milestone_id, researcher_ckey)

/datum/scp_research_manager/proc/complete_milestone(var/milestone_id, var/researcher_ckey)
	var/datum/research_milestone_data/milestone = research_milestones[milestone_id]
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)

	milestone.completed = TRUE
	milestone.completion_time = world.time
	milestone.completed_by = researcher_ckey

	// Award milestone rewards
	var/milestone_reward = 1000
	researcher.research_points += milestone_reward
	researcher.achievements += milestone.milestone_name

	// Notify researcher
	notify_researcher(researcher_ckey, "Milestone Achieved!", "[milestone.milestone_name]: [milestone.milestone_description] +[milestone_reward] research points")

	world.log << "SCP Research: [researcher_ckey] achieved milestone [milestone.milestone_name]"

/datum/scp_research_manager/proc/notify_researcher(var/ckey, var/title, var/message)
	// Send notification to researcher
	for(var/client/C in GLOB.clients)
		if(C.ckey == ckey)
			to_chat(C, "<span class='notice'><b>[title]</b>: [message]</span>")
			break

// Subsystem initialization
/datum/controller/subsystem/scp_research/Initialize()
	world.log << "SCP Research system initializing..."
	manager = new /datum/scp_research_manager()
	manager.initialize_research_system()
	world.log << "SCP Research system initialized"
	return ..()

/datum/controller/subsystem/scp_research/fire()
	if(manager)
		manager.process_research_projects()

/datum/scp_research_manager/proc/process_research()
	return

/datum/scp_research_manager/proc/process_research_projects()
	for(var/project_id in research_projects)
		var/datum/research_data/project = research_projects[project_id]
		if(project.status == "ACTIVE")
			process_scp_research_with_skills(project)

/datum/scp_research_manager/proc/process_scp_research_with_skills(datum/research_data/project)
	if(!project)
		return

	// Get researcher
	var/mob/living/carbon/human/researcher = get_researcher_by_ckey(project.researcher_ckey)
	if(!researcher)
		return

	// Calculate skill-enhanced research progress
	var/base_progress_rate = 1.0
	var/skill_enhanced_rate = base_progress_rate

	// Apply research skill bonuses
	if(SSskill_integration)
		skill_enhanced_rate = SSskill_integration.manager.apply_research_skill_bonuses(researcher, "scp_study", base_progress_rate)

		// Apply research skill effects
		SSskill_integration.manager.apply_research_skill_effects(researcher, "SCP-[project.scp_designation] research")

	// Update research progress
	project.research_level += skill_enhanced_rate * 0.1 // Slower progression for balance

	// Check for level completion
	if(project.research_level >= project.max_research_level)
		complete_scp_research_project(project)

	// Check for breakthroughs
	check_scp_research_breakthrough(project, researcher)

/datum/scp_research_manager/proc/get_researcher_by_ckey(ckey)
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(QDELETED(H))
			continue
		if(H.ckey == ckey)
			return H
	return null

/datum/scp_research_manager/proc/complete_scp_research_project(datum/research_data/project)
	if(!project)
		return

	project.status = "COMPLETED"
	project.research_level = project.max_research_level

	// Calculate skill-enhanced completion reward
	var/base_reward = project.completion_reward || 1000
	var/enhanced_reward = base_reward

	var/mob/living/carbon/human/researcher = get_researcher_by_ckey(project.researcher_ckey)
	if(researcher && SSskill_integration)
		enhanced_reward = SSskill_integration.manager.apply_research_skill_bonuses(researcher, "breakthrough", base_reward)

	// Award research points
	total_research_points += enhanced_reward

	// Award experience to researcher
	if(researcher && SSskill_integration)
		SSskill_integration.manager.add_experience(researcher, /datum/skill/research, enhanced_reward * 0.1)

	// Announce completion
	announce_scp_research_completion(project, enhanced_reward)

/datum/scp_research_manager/proc/check_scp_research_breakthrough(datum/research_data/project, mob/living/carbon/human/researcher)
	if(!project || !researcher)
		return

	// Calculate skill-enhanced breakthrough chance
	var/base_chance = 2 // 2% base chance
	var/enhanced_chance = base_chance

	if(SSskill_integration)
		enhanced_chance = SSskill_integration.manager.calculate_research_breakthrough_chance(researcher, base_chance)

	if(prob(enhanced_chance))
		trigger_scp_research_breakthrough(project, researcher)

/datum/scp_research_manager/proc/trigger_scp_research_breakthrough(datum/research_data/project, mob/living/carbon/human/researcher)
	if(!project || !researcher)
		return

	// Add breakthrough discovery
	var/list/breakthrough = list(
		"timestamp" = world.time,
		"type" = "research_breakthrough",
		"description" = "Major breakthrough in SCP-[project.scp_designation] research",
		"researcher" = researcher.name
	)
	project.discoveries += list(breakthrough)

	// Award breakthrough experience
	if(SSskill_integration)
		SSskill_integration.manager.add_experience(researcher, /datum/skill/research, 150)

	// Announce breakthrough
	to_chat(researcher, "<span class='boldnotice'>BREAKTHROUGH! You've made a major discovery in SCP-[project.scp_designation] research!</span>")

	// Update research metrics
	research_breakthroughs++

/datum/scp_research_manager/proc/announce_scp_research_completion(datum/research_data/project, reward)
	if(!project)
		return

	var/completion_message = "SCP RESEARCH COMPLETED: SCP-[project.scp_designation] research project completed! Reward: [reward] points"

	// Notify researcher
	var/mob/living/carbon/human/researcher = get_researcher_by_ckey(project.researcher_ckey)
	if(researcher)
		to_chat(researcher, "<span class='boldnotice'>[completion_message]</span>")

	// Log completion
	log_game("SCP research project completed: SCP-[project.scp_designation] - [reward] points")

// Global instance
GLOBAL_DATUM_INIT(scp_research_manager, /datum/scp_research_manager, new)

// Integration functions for SCPs to call
/proc/award_research_points(var/scp_designation, var/research_type, var/points, var/researcher_ckey)
	if(SSscp_research && SSscp_research.manager)
		// Find or create research project
		var/project_id = "research_[scp_designation]_[research_type]_[researcher_ckey]"
		if(!SSscp_research.manager.research_projects[project_id])
			SSscp_research.manager.start_research_project(scp_designation, research_type, researcher_ckey)

		return SSscp_research.manager.add_research_points(project_id, points, researcher_ckey)
	return FALSE

/proc/get_researcher_data(var/ckey)
	if(SSscp_research && SSscp_research.manager)
		return SSscp_research.manager.get_researcher_profile(ckey)
	return null

/proc/check_research_achievements(var/ckey)
	if(SSscp_research && SSscp_research.manager)
		SSscp_research.manager.check_research_milestones(ckey)

// Player verbs for research system
/mob/proc/view_research_status()
	set name = "View Research Status"
	set category = "Research"
	set desc = "View your current research status and achievements."

	if(!SSscp_research || !SSscp_research.manager)
		to_chat(src, "<span class='warning'>Research system not available.</span>")
		return

	var/datum/researcher_data/researcher = get_researcher_data(ckey)
	if(!researcher)
		to_chat(src, "<span class='notice'>You haven't started any research projects yet.</span>")
		return

	to_chat(src, "<span class='notice'><b>=== RESEARCH STATUS ===</b></span>")
	to_chat(src, "<span class='notice'>Research Points: [researcher.research_points]</span>")
	to_chat(src, "<span class='notice'>Research Funding: [researcher.research_funding]</span>")
	to_chat(src, "<span class='notice'>Progression Points: [researcher.progression_points]</span>")
	to_chat(src, "<span class='notice'>Research Rank: [researcher.research_rank]</span>")
	to_chat(src, "<span class='notice'>Total Projects: [researcher.total_projects]</span>")
	to_chat(src, "<span class='notice'>Completed Projects: [researcher.completed_projects]</span>")
	to_chat(src, "<span class='notice'>Failed Projects: [researcher.failed_projects]</span>")

	if(length(researcher.achievements) > 0)
		to_chat(src, "<span class='notice'><b>Achievements:</b></span>")
		for(var/achievement in researcher.achievements)
			to_chat(src, "<span class='notice'>- [achievement]</span>")

	if(length(researcher.completed_research) > 0)
		to_chat(src, "<span class='notice'><b>Completed Research:</b></span>")
		for(var/research in researcher.completed_research)
			to_chat(src, "<span class='notice'>- [research]</span>")

/mob/proc/view_research_projects()
	set name = "View Research Projects"
	set category = "Research"
	set desc = "View your active research projects."

	if(!SSscp_research || !SSscp_research.manager)
		to_chat(src, "<span class='warning'>Research system not available.</span>")
		return

	var/found_projects = FALSE
	to_chat(src, "<span class='notice'><b>=== ACTIVE RESEARCH PROJECTS ===</b></span>")

	for(var/project_id in SSscp_research.manager.research_projects)
		var/datum/research_data/project = SSscp_research.manager.research_projects[project_id]
		if(project.researcher_ckey == ckey && project.status == "ACTIVE")
			found_projects = TRUE
			to_chat(src, "<span class='notice'>[project.scp_designation] - [project.research_type]</span>")
			to_chat(src, "<span class='notice'>  Level: [project.research_level]/[project.max_research_level]</span>")
			to_chat(src, "<span class='notice'>  Points: [project.research_points]/[project.research_cost]</span>")
			to_chat(src, "<span class='notice'>  Time: [round((world.time - project.timestamp) / 600)] minutes</span>")

	if(!found_projects)
		to_chat(src, "<span class='notice'>No active research projects.</span>")
