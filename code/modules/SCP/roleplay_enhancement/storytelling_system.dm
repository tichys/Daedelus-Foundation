// Storytelling & Documentation System
// Enables collaborative narrative creation and story documentation

SUBSYSTEM_DEF(storytelling)
	name = "Storytelling"
	wait = 600 // 10 minutes
	priority = FIRE_PRIORITY_ROLEPLAY
	init_order = INIT_ORDER_ROLEPLAY
	var/datum/storytelling_manager/manager

/datum/controller/subsystem/storytelling/Initialize()
	manager = new /datum/storytelling_manager()
	world.log << "Storytelling Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/storytelling/fire()
	if(manager)
		manager.process_storytelling_system()

// Storytelling Manager
/datum/storytelling_manager
	var/list/active_stories = list() // story_id -> story_data
	var/list/story_templates = list() // template_id -> template_data
	var/list/story_contributors = list() // contributor_id -> contributor_data
	var/list/story_events = list() // event_id -> event_data
	var/list/story_archives = list() // archive_id -> archive_data
	var/list/collaborative_sessions = list() // session_id -> session_data

	// Storytelling metrics
	var/total_stories_created = 0
	var/active_collaborations = 0
	var/story_contributions_count = 0
	var/average_story_length = 0
	var/story_completion_rate = 0

/datum/storytelling_manager/New()
	. = ..()
	initialize_story_templates()
	initialize_story_categories()

/datum/storytelling_manager/proc/process_storytelling_system()
	// Process active stories
	for(var/story_id in active_stories)
		var/datum/story/story = active_stories[story_id]
		if(story)
			story.process_story_development()

	// Update metrics
	update_storytelling_metrics()

	// Process collaborative sessions
	process_collaborative_sessions()

// Story Datum
/datum/story
	var/story_id = ""
	var/story_title = ""
	var/story_type = "" // "containment_breach", "research_discovery", "character_development", "world_event"
	var/story_description = ""
	var/story_status = "active" // "active", "completed", "archived", "abandoned"
	var/story_priority = 1 // 1-5 scale

	// Story content
	var/list/story_chapters = list()
	var/list/story_characters = list()
	var/list/story_locations = list()
	var/list/story_events = list()
	var/list/story_artifacts = list()

	// Collaboration
	var/list/story_contributors = list()
	var/list/story_permissions = list()
	var/list/story_versions = list()
	var/story_creation_date = 0
	var/story_last_updated = 0

	// Integration
	var/datum/roleplay_character_sheet/primary_author
	var/list/linked_characters = list()
	var/list/story_tags = list()

/datum/story/New(var/id, var/title, var/type, var/author_ckey)
	story_id = id
	story_title = title
	story_type = type
	story_creation_date = world.time
	story_last_updated = world.time

	// Link to primary author
	if(author_ckey && SSroleplay_character && SSroleplay_character.manager)
		primary_author = SSroleplay_character.manager.get_character(author_ckey)
		if(primary_author)
			story_contributors[author_ckey] = list(
				"role" = "primary_author",
				"contribution_date" = world.time,
				"permissions" = list("read", "write", "edit", "delete")
			)

/datum/story/proc/process_story_development()
	// Update story based on recent activities
	story_last_updated = world.time

	// Check for story completion conditions
	check_story_completion()

	// Award experience to contributors
	award_story_experience()

/datum/story/proc/check_story_completion()
	// Check if story meets completion criteria
	var/completion_score = 0

	// Score based on story elements
	if(length(story_chapters) >= 3)
		completion_score += 25
	if(length(story_characters) >= 2)
		completion_score += 20
	if(length(story_events) >= 5)
		completion_score += 25
	if(length(story_contributors) >= 2)
		completion_score += 15
	if(length(story_description) > 500)
		completion_score += 15

	if(completion_score >= 80)
		complete_story()

/datum/story/proc/complete_story()
	story_status = "completed"

	// Award experience to all contributors
	for(var/contributor_ckey in story_contributors)
		var/datum/roleplay_character_sheet/contributor = null
		if(SSroleplay_character && SSroleplay_character.manager)
			contributor = SSroleplay_character.manager.get_character(contributor_ckey)

		if(contributor && contributor.growth)
			var/experience_award = 50 // Base completion award
			if(story_contributors[contributor_ckey]["role"] == "primary_author")
				experience_award += 25 // Bonus for primary author

			contributor.growth.add_experience(experience_award, "Story Completion: [story_title]")

			// Notify contributor if online
			for(var/client/C in GLOB.clients)
				if(C.ckey == contributor_ckey)
					to_chat(C, "<span class='notice'>Your story '[story_title]' has been completed! You gained [experience_award] experience.</span>")
					break

/datum/story/proc/award_story_experience()
	// Award experience for story contributions
	for(var/contributor_ckey in story_contributors)
		var/datum/roleplay_character_sheet/contributor = null
		if(SSroleplay_character && SSroleplay_character.manager)
			contributor = SSroleplay_character.manager.get_character(contributor_ckey)

		if(contributor && contributor.growth)
			var/experience_award = 5 // Base contribution award
			contributor.growth.add_experience(experience_award, "Story Contribution: [story_title]")

// Story Chapter System
/datum/story_chapter
	var/chapter_id = ""
	var/chapter_title = ""
	var/chapter_content = ""
	var/chapter_author = ""
	var/chapter_creation_date = 0
	var/chapter_last_edited = 0
	var/chapter_version = 1
	var/list/chapter_characters = list()
	var/list/chapter_locations = list()
	var/list/chapter_events = list()
	var/chapter_visibility = "public" // "public", "private", "restricted"

/datum/story_chapter/New(var/id, var/title, var/content, var/author)
	chapter_id = id
	chapter_title = title
	chapter_content = content
	chapter_author = author
	chapter_creation_date = world.time
	chapter_last_edited = world.time

// Collaborative Session System
/datum/collaborative_session
	var/session_id = ""
	var/session_title = ""
	var/session_type = "" // "story_creation", "character_development", "world_building", "event_planning"
	var/session_status = "active" // "active", "paused", "completed"
	var/session_creation_date = 0
	var/session_last_activity = 0

	// Participants
	var/list/session_participants = list()
	var/list/session_permissions = list()
	var/list/session_contributions = list()

	// Session content
	var/list/session_notes = list()
	var/list/session_decisions = list()
	var/list/session_assignments = list()

/datum/collaborative_session/New(var/id, var/title, var/type)
	session_id = id
	session_title = title
	session_type = type
	session_creation_date = world.time
	session_last_activity = world.time

// Story Template System
/datum/story_template
	var/template_id = ""
	var/template_name = ""
	var/template_category = ""
	var/template_description = ""
	var/template_structure = list()
	var/template_requirements = list()
	var/template_examples = list()
	var/template_difficulty = 1 // 1-5 scale

/datum/story_template/New(var/id, var/name, var/category, var/description)
	template_id = id
	template_name = name
	template_category = category
	template_description = description

// Storytelling Manager Procs
/datum/storytelling_manager/proc/create_story(title, story_type, author_ckey)
	var/story_id = "story_[world.time]_[author_ckey]"

	var/datum/story/new_story = new /datum/story(story_id, title, story_type, author_ckey)
	active_stories[story_id] = new_story
	total_stories_created++

	world.log << "Storytelling: Created story [title] ([story_type]) by [author_ckey]"
	return new_story

/datum/storytelling_manager/proc/get_story(story_id)
	return active_stories[story_id]

/datum/storytelling_manager/proc/update_story(story_id, updates)
	var/datum/story/story = active_stories[story_id]
	if(!story)
		return FALSE

	for(var/field in updates)
		story.vars[field] = updates[field]

	story.story_last_updated = world.time
	return TRUE

/datum/storytelling_manager/proc/add_story_contributor(story_id, contributor_ckey, role, permissions)
	var/datum/story/story = active_stories[story_id]
	if(!story)
		return FALSE

	story.story_contributors[contributor_ckey] = list(
		"role" = role,
		"contribution_date" = world.time,
		"permissions" = permissions
	)

	story.story_last_updated = world.time
	return TRUE

/datum/storytelling_manager/proc/create_collaborative_session(title, session_type, creator_ckey)
	var/session_id = "session_[world.time]_[creator_ckey]"

	var/datum/collaborative_session/new_session = new /datum/collaborative_session(session_id, title, session_type)
	new_session.session_participants[creator_ckey] = list(
		"role" = "creator",
		"join_date" = world.time,
		"permissions" = list("read", "write", "edit", "delete", "invite")
	)

	collaborative_sessions[session_id] = new_session
	active_collaborations++

	world.log << "Storytelling: Created collaborative session [title] ([session_type]) by [creator_ckey]"
	return new_session

/datum/storytelling_manager/proc/process_collaborative_sessions()
	// Process active collaborative sessions
	for(var/session_id in collaborative_sessions)
		var/datum/collaborative_session/session = collaborative_sessions[session_id]
		if(session && session.session_status == "active")
			// Check for session timeout
			if(world.time - session.session_last_activity > 36000) // 10 minutes
				session.session_status = "paused"

/datum/storytelling_manager/proc/update_storytelling_metrics()
	active_collaborations = 0
	for(var/session_id in collaborative_sessions)
		var/datum/collaborative_session/session = collaborative_sessions[session_id]
		if(session && session.session_status == "active")
			active_collaborations++

	// Calculate average story length
	var/total_length = 0
	var/story_count = 0
	for(var/story_id in active_stories)
		var/datum/story/story = active_stories[story_id]
		if(story)
			total_length += length(story.story_description)
			story_count++

	if(story_count > 0)
		average_story_length = total_length / story_count

// Initialize story templates
/datum/storytelling_manager/proc/initialize_story_templates()
	story_templates = list(
		"containment_breach" = list(
			"name" = "Containment Breach",
			"category" = "action",
			"description" = "A story about an SCP containment failure and its consequences",
			"structure" = list("setup", "breach", "response", "containment", "aftermath"),
			"difficulty" = 3
		),
		"research_discovery" = list(
			"name" = "Research Discovery",
			"category" = "mystery",
			"description" = "A story about uncovering new SCP properties or anomalies",
			"structure" = list("hypothesis", "experiment", "discovery", "analysis", "implications"),
			"difficulty" = 2
		),
		"character_development" = list(
			"name" = "Character Development",
			"category" = "drama",
			"description" = "A story focused on character growth and relationships",
			"structure" = list("setup", "conflict", "development", "resolution", "growth"),
			"difficulty" = 1
		),
		"world_event" = list(
			"name" = "World Event",
			"category" = "epic",
			"description" = "A story about major events affecting the Foundation or world",
			"structure" = list("foreshadowing", "event", "impact", "response", "consequences"),
			"difficulty" = 4
		),
		"investigation" = list(
			"name" = "Investigation",
			"category" = "mystery",
			"description" = "A story about investigating anomalies or incidents",
			"structure" = list("clue_discovery", "investigation", "revelation", "confrontation", "resolution"),
			"difficulty" = 3
		)
	)

// Initialize story categories
/datum/storytelling_manager/proc/initialize_story_categories()
	// Story categories for organization
	// This will be used for filtering and browsing stories
