// Event & Story Management System
// Manages dynamic storytelling, player-driven narratives, and emergent events

SUBSYSTEM_DEF(event_story_management)
	name = "Event Story Management"
	wait = 300 // 5 minutes
	priority = FIRE_PRIORITY_ROLEPLAY
	init_order = INIT_ORDER_ROLEPLAY
	var/datum/event_story_manager/manager

/datum/controller/subsystem/event_story_management/Initialize()
	manager = new /datum/event_story_manager()
	world.log << "Event Story Management Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/event_story_management/fire()
	if(manager)
		manager.process_event_story_system()

// Event Story Manager
/datum/event_story_manager
	var/list/active_events = list() // event_id -> event_data
	var/list/event_templates = list() // template_id -> template_data
	var/list/story_arcs = list() // arc_id -> arc_data
	var/list/player_initiated_events = list() // event_id -> event_data
	var/list/emergent_stories = list() // story_id -> story_data
	var/list/event_triggers = list() // trigger_id -> trigger_data

	// Event management metrics
	var/total_events_created = 0
	var/active_story_arcs = 0
	var/player_participation_rate = 0
	var/event_completion_rate = 0
	var/story_coherence_score = 0

/datum/event_story_manager/New()
	. = ..()
	initialize_event_templates()
	initialize_story_arcs()
	initialize_event_triggers()

/datum/event_story_manager/proc/process_event_story_system()
	// Process active events
	for(var/event_id in active_events)
		var/datum/event/event = active_events[event_id]
		if(event)
			event.process_event_progression()

	// Process story arcs
	process_story_arcs()

	// Check for emergent stories
	check_emergent_stories()

	// Update metrics
	update_event_metrics()

// Event System
/datum/event
	var/event_id = ""
	var/event_title = ""
	var/event_type = "" // "containment_breach", "research_discovery", "personnel_conflict", "scp_interaction", "facility_incident"
	var/event_description = ""
	var/event_status = "active" // "active", "resolved", "failed", "escalated"
	var/event_severity = 1 // 1-10 scale
	var/event_priority = 1 // 1-5 scale

	// Event progression
	var/list/event_stages = list()
	var/current_stage = 1
	var/event_start_time = 0
	var/event_estimated_duration = 0
	var/event_actual_duration = 0

	// Event participants
	var/list/event_participants = list()
	var/list/event_roles = list()
	var/list/event_actions = list()
	var/list/event_outcomes = list()

	// Story integration
	var/datum/story_arc/linked_story_arc
	var/list/event_consequences = list()
	var/list/event_requirements = list()
	var/event_creation_date = 0
	var/event_last_updated = 0

/datum/event/New(var/id, var/title, var/type, var/description)
	event_id = id
	event_title = title
	event_type = type
	event_description = description
	event_creation_date = world.time
	event_last_updated = world.time
	event_start_time = world.time

/datum/event/proc/process_event_progression()
	// Update event based on current stage and participant actions
	event_last_updated = world.time

	// Check if event should progress to next stage
	check_stage_progression()

	// Process participant actions
	process_participant_actions()

	// Check for event completion
	check_event_completion()

/datum/event/proc/check_stage_progression()
	// Check if event should progress to next stage
	if(current_stage < length(event_stages))
		var/datum/event_stage/current_stage_data = event_stages[current_stage]
		if(current_stage_data && current_stage_data.check_completion_conditions())
			progress_to_next_stage()

/datum/event/proc/progress_to_next_stage()
	current_stage++

	// Notify participants of stage progression
	for(var/participant_ckey in event_participants)
		for(var/client/C in GLOB.clients)
			if(C.ckey == participant_ckey)
				to_chat(C, "<span class='notice'>Event '[event_title]' has progressed to stage [current_stage]!</span>")
				break

	// Award experience to participants
	award_event_experience()

/datum/event/proc/process_participant_actions()
	// Process recent actions by participants
	for(var/action in event_actions)
		// Apply action effects
		apply_action_effects(action)

		// Check for action consequences
		check_action_consequences(action)

/datum/event/proc/apply_action_effects(action)
	// Apply effects of participant actions
	// This would implement action effect logic
	world.log << "Event Story: Applying effects of action [action] in event [event_title]"

/datum/event/proc/check_action_consequences(action)
	// Check for consequences of participant actions
	// This would implement consequence checking logic
	world.log << "Event Story: Checking consequences of action [action] in event [event_title]"

/datum/event/proc/check_event_completion()
	// Check if event meets completion criteria
	if(current_stage >= length(event_stages))
		complete_event()

/datum/event/proc/complete_event()
	event_status = "resolved"
	event_actual_duration = world.time - event_start_time

	// Award experience to all participants
	for(var/participant_ckey in event_participants)
		var/datum/roleplay_character_sheet/participant = null
		if(SSroleplay_character && SSroleplay_character.manager)
			participant = SSroleplay_character.manager.get_character(participant_ckey)

		if(participant && participant.growth)
			var/experience_award = 25 // Base completion award
			experience_award += event_severity * 5 // Bonus for severity

			participant.growth.add_experience(experience_award, "Event Completion: [event_title]")

			// Notify participant if online
			for(var/client/C in GLOB.clients)
				if(C.ckey == participant_ckey)
					to_chat(C, "<span class='notice'>Event '[event_title]' has been completed! You gained [experience_award] experience.</span>")
					break

/datum/event/proc/award_event_experience()
	// Award experience for event participation
	for(var/participant_ckey in event_participants)
		var/datum/roleplay_character_sheet/participant = null
		if(SSroleplay_character && SSroleplay_character.manager)
			participant = SSroleplay_character.manager.get_character(participant_ckey)

		if(participant && participant.growth)
			var/experience_award = 5 // Base participation award
			participant.growth.add_experience(experience_award, "Event Participation: [event_title]")

// Event Stage System
/datum/event_stage
	var/stage_id = ""
	var/stage_title = ""
	var/stage_description = ""
	var/stage_requirements = list()
	var/stage_actions = list()
	var/stage_duration = 0
	var/stage_completion_conditions = list()
	var/stage_failure_conditions = list()
	var/stage_rewards = list()

/datum/event_stage/New(var/id, var/title, var/description)
	stage_id = id
	stage_title = title
	stage_description = description

/datum/event_stage/proc/check_completion_conditions()
	// Check if stage completion conditions are met
	// This would implement completion condition checking logic
	return prob(30) // 30% chance of completion per check

// Story Arc System
/datum/story_arc
	var/arc_id = ""
	var/arc_title = ""
	var/arc_type = "" // "containment_breach", "research_project", "personnel_drama", "scp_awakening", "facility_crisis"
	var/arc_description = ""
	var/arc_status = "active" // "active", "completed", "failed", "paused"
	var/arc_complexity = 1 // 1-10 scale

	// Arc progression
	var/list/arc_events = list()
	var/list/arc_characters = list()
	var/list/arc_locations = list()
	var/list/arc_objectives = list()
	var/list/arc_milestones = list()

	// Story elements
	var/list/arc_themes = list()
	var/list/arc_conflicts = list()
	var/list/arc_resolutions = list()
	var/arc_creation_date = 0
	var/arc_last_updated = 0

/datum/story_arc/New(var/id, var/title, var/type, var/description)
	arc_id = id
	arc_title = title
	arc_type = type
	arc_description = description
	arc_creation_date = world.time
	arc_last_updated = world.time

// Player Initiated Event System
/datum/player_initiated_event
	var/event_id = ""
	var/event_title = ""
	var/event_type = ""
	var/event_description = ""
	var/event_initiator = ""
	var/event_participants = list()
	var/event_status = "proposed" // "proposed", "approved", "active", "completed", "rejected"
	var/event_approval_votes = list()
	var/event_creation_date = 0
	var/event_approval_date = 0

/datum/player_initiated_event/New(var/id, var/title, var/type, var/description, var/initiator)
	event_id = id
	event_title = title
	event_type = type
	event_description = description
	event_initiator = initiator
	event_creation_date = world.time

// Event Story Manager Procs
/datum/event_story_manager/proc/create_event(title, event_type, description)
	var/event_id = "event_[world.time]_[rand(1000, 9999)]"

	var/datum/event/new_event = new /datum/event(event_id, title, event_type, description)
	active_events[event_id] = new_event
	total_events_created++

	world.log << "Event Story: Created event [title] ([event_type])"
	return new_event

/datum/event_story_manager/proc/create_story_arc(title, arc_type, description)
	var/arc_id = "arc_[world.time]_[rand(1000, 9999)]"

	var/datum/story_arc/new_arc = new /datum/story_arc(arc_id, title, arc_type, description)
	story_arcs[arc_id] = new_arc
	active_story_arcs++

	world.log << "Event Story: Created story arc [title] ([arc_type])"
	return new_arc

/datum/event_story_manager/proc/create_player_event(title, event_type, description, initiator)
	var/event_id = "player_event_[world.time]_[initiator]"

	var/datum/player_initiated_event/new_event = new /datum/player_initiated_event(event_id, title, event_type, description, initiator)
	player_initiated_events[event_id] = new_event

	world.log << "Event Story: Created player-initiated event [title] ([event_type]) by [initiator]"
	return new_event

/datum/event_story_manager/proc/process_story_arcs()
	// Process active story arcs
	for(var/arc_id in story_arcs)
		var/datum/story_arc/arc = story_arcs[arc_id]
		if(arc && arc.arc_status == "active")
			arc.arc_last_updated = world.time

			// Check for arc completion
			check_arc_completion(arc)

			// Generate new events for the arc
			if(prob(15)) // 15% chance per cycle
				generate_arc_event(arc)

/datum/event_story_manager/proc/check_arc_completion(arc)
	// Check if story arc meets completion criteria
	var/completion_score = 0

	// Score based on arc elements
	if(length(arc.arc_events) >= 3)
		completion_score += 25
	if(length(arc.arc_objectives) >= 2)
		completion_score += 20
	if(length(arc.arc_milestones) >= 5)
		completion_score += 25
	if(length(arc.arc_characters) >= 3)
		completion_score += 15
	if(length(arc.arc_conflicts) >= 2)
		completion_score += 15

	if(completion_score >= 80)
		complete_story_arc(arc)

/datum/event_story_manager/proc/complete_story_arc(arc)
	arc.arc_status = "completed"

	// Award experience to all participants
	for(var/character_ckey in arc.arc_characters)
		var/datum/roleplay_character_sheet/character = null
		if(SSroleplay_character && SSroleplay_character.manager)
			character = SSroleplay_character.manager.get_character(character_ckey)

		if(character && character.growth)
			var/experience_award = 100 // Base completion award
			experience_award += arc.arc_complexity * 10 // Bonus for complexity

			character.growth.add_experience(experience_award, "Story Arc Completion: [arc.arc_title]")

			// Notify participant if online
			for(var/client/C in GLOB.clients)
				if(C.ckey == character_ckey)
					to_chat(C, "<span class='notice'>Story arc '[arc.arc_title]' has been completed! You gained [experience_award] experience.</span>")
					break

/datum/event_story_manager/proc/generate_arc_event(arc)
	// Generate a new event for the story arc
	var/event_templates = list("containment_breach", "research_discovery", "personnel_conflict", "scp_interaction", "facility_incident")
	var/event_type = pick(event_templates)
	var/event_title = "[arc.arc_title] - [event_type]"
	var/event_description = "A new development in the [arc.arc_title] story arc."

	var/datum/event/new_event = create_event(event_title, event_type, event_description)
	if(new_event)
		arc.arc_events += new_event
		new_event.linked_story_arc = arc

/datum/event_story_manager/proc/check_emergent_stories()
	// Check for emergent stories based on player actions and events
	// This would implement emergent story detection logic
	if(prob(5)) // 5% chance per cycle
		generate_emergent_story()

/datum/event_story_manager/proc/generate_emergent_story()
	// Generate an emergent story based on recent events and player actions
	var/story_types = list("containment_breach", "research_discovery", "personnel_drama", "scp_awakening", "facility_crisis")
	var/story_type = pick(story_types)
	var/story_title = "Emergent [story_type]"
	var/story_description = "An emergent story has developed from recent events."

	var/story_id = "emergent_[world.time]_[rand(1000, 9999)]"
	emergent_stories[story_id] = list(
		"story_id" = story_id,
		"story_title" = story_title,
		"story_type" = story_type,
		"story_description" = story_description,
		"story_creation_date" = world.time
	)

	world.log << "Event Story: Generated emergent story [story_title]"

/datum/event_story_manager/proc/update_event_metrics()
	// Update event management metrics
	active_story_arcs = 0
	for(var/arc_id in story_arcs)
		var/datum/story_arc/arc = story_arcs[arc_id]
		if(arc && arc.arc_status == "active")
			active_story_arcs++

	// Calculate player participation rate
	var/total_participants = 0
	var/total_events = length(active_events)
	for(var/event_id in active_events)
		var/datum/event/event = active_events[event_id]
		if(event)
			total_participants += length(event.event_participants)

	if(total_events > 0)
		player_participation_rate = total_participants / total_events

	// Calculate event completion rate
	var/completed_events = 0
	for(var/event_id in active_events)
		var/datum/event/event = active_events[event_id]
		if(event && event.event_status == "resolved")
			completed_events++

	if(total_events > 0)
		event_completion_rate = (completed_events / total_events) * 100

// Initialize event templates
/datum/event_story_manager/proc/initialize_event_templates()
	event_templates = list(
		"containment_breach" = list(
			"name" = "Containment Breach",
			"description" = "An SCP has breached containment",
			"severity" = 8,
			"stages" = list("detection", "response", "containment", "investigation", "resolution"),
			"requirements" = list("security_personnel", "containment_protocols")
		),
		"research_discovery" = list(
			"name" = "Research Discovery",
			"description" = "A significant research breakthrough has occurred",
			"severity" = 4,
			"stages" = list("discovery", "analysis", "documentation", "peer_review", "publication"),
			"requirements" = list("research_personnel", "laboratory_equipment")
		),
		"personnel_conflict" = list(
			"name" = "Personnel Conflict",
			"description" = "A conflict has arisen between Foundation personnel",
			"severity" = 3,
			"stages" = list("escalation", "mediation", "resolution", "reconciliation", "prevention"),
			"requirements" = list("mediator", "conflict_resolution_protocols")
		),
		"scp_interaction" = list(
			"name" = "SCP Interaction",
			"description" = "An unusual interaction with an SCP has occurred",
			"severity" = 6,
			"stages" = list("observation", "analysis", "response", "containment", "documentation"),
			"requirements" = list("research_personnel", "security_personnel")
		),
		"facility_incident" = list(
			"name" = "Facility Incident",
			"description" = "A facility-wide incident has occurred",
			"severity" = 7,
			"stages" = list("detection", "response", "containment", "investigation", "recovery"),
			"requirements" = list("emergency_response", "facility_management")
		)
	)

// Initialize story arcs
/datum/event_story_manager/proc/initialize_story_arcs()
	story_arcs = list(
		"containment_crisis" = list(
			"name" = "Containment Crisis",
			"type" = "containment_breach",
			"description" = "A series of containment breaches threatens facility security",
			"complexity" = 8,
			"themes" = list("security", "containment", "crisis_management"),
			"objectives" = list("prevent_breaches", "improve_security", "investigate_cause")
		),
		"research_breakthrough" = list(
			"name" = "Research Breakthrough",
			"type" = "research_project",
			"description" = "A major research project reaches critical milestones",
			"complexity" = 6,
			"themes" = list("research", "discovery", "scientific_progress"),
			"objectives" = list("complete_research", "document_findings", "apply_knowledge")
		),
		"personnel_drama" = list(
			"name" = "Personnel Drama",
			"type" = "personnel_drama",
			"description" = "Interpersonal conflicts and drama among Foundation personnel",
			"complexity" = 4,
			"themes" = list("relationships", "conflict", "resolution"),
			"objectives" = list("resolve_conflicts", "improve_morale", "prevent_escalation")
		),
		"scp_awakening" = list(
			"name" = "SCP Awakening",
			"type" = "scp_awakening",
			"description" = "An SCP exhibits new or enhanced abilities",
			"complexity" = 9,
			"themes" = list("anomaly", "power", "containment"),
			"objectives" = list("understand_awakening", "maintain_containment", "prevent_escalation")
		),
		"facility_crisis" = list(
			"name" = "Facility Crisis",
			"type" = "facility_crisis",
			"description" = "A crisis affecting the entire facility",
			"complexity" = 7,
			"themes" = list("crisis", "survival", "cooperation"),
			"objectives" = list("resolve_crisis", "protect_personnel", "maintain_operations")
		)
	)

// Initialize event triggers
/datum/event_story_manager/proc/initialize_event_triggers()
	event_triggers = list(
		"scp_breach" = list(
			"trigger_type" = "scp_containment_failure",
			"conditions" = list("scp_containment_broken", "security_response_needed"),
			"event_type" = "containment_breach",
			"severity" = 8
		),
		"research_success" = list(
			"trigger_type" = "research_milestone",
			"conditions" = list("research_completed", "breakthrough_achieved"),
			"event_type" = "research_discovery",
			"severity" = 4
		),
		"personnel_conflict" = list(
			"trigger_type" = "interpersonal_conflict",
			"conditions" = list("conflict_escalated", "mediation_needed"),
			"event_type" = "personnel_conflict",
			"severity" = 3
		),
		"scp_anomaly" = list(
			"trigger_type" = "scp_behavior_change",
			"conditions" = list("scp_behavior_unusual", "investigation_needed"),
			"event_type" = "scp_interaction",
			"severity" = 6
		),
		"facility_emergency" = list(
			"trigger_type" = "facility_system_failure",
			"conditions" = list("system_failure", "emergency_response_needed"),
			"event_type" = "facility_incident",
			"severity" = 7
		)
	)
