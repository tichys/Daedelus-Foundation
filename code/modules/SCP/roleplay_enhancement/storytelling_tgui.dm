// Storytelling System TGUI Backend
// Handles the TGUI interface for storytelling and documentation

/datum/storytelling_ui
	var/mob/user
	var/datum/story/selected_story

/datum/storytelling_ui/New(mob/user)
	src.user = user

/datum/storytelling_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "StorytellingSystem", "SCP Foundation - Storytelling System", 800, 600)
		ui.open()

/datum/storytelling_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/storytelling_ui/ui_data(mob/user)
	var/list/data = list()

	// Get all stories
	data["stories"] = get_all_stories()

	// Get story templates
	if(SSstorytelling && SSstorytelling.manager)
		data["story_templates"] = SSstorytelling.manager.story_templates

	// Get collaborative sessions
	data["collaborative_sessions"] = get_collaborative_sessions()

	// Get user's stories and contributions
	data["user_stories"] = get_user_stories(user.ckey)
	data["user_contributions"] = get_user_contributions(user.ckey)

	// Get metrics
	data["metrics"] = get_storytelling_metrics()

	return data

/datum/storytelling_ui/proc/get_all_stories()
	var/list/stories = list()

	if(SSstorytelling && SSstorytelling.manager)
		for(var/story_id in SSstorytelling.manager.active_stories)
			var/datum/story/story = SSstorytelling.manager.active_stories[story_id]
			if(story)
				stories += list(list(
					"story_id" = story.story_id,
					"story_title" = story.story_title,
					"story_type" = story.story_type,
					"story_status" = story.story_status,
					"story_priority" = story.story_priority,
					"story_description" = story.story_description,
					"story_creation_date" = story.story_creation_date,
					"story_last_updated" = story.story_last_updated,
					"story_chapters" = story.story_chapters,
					"story_contributors" = story.story_contributors,
					"story_characters" = story.story_characters,
					"story_locations" = story.story_locations,
					"story_events" = story.story_events,
					"story_artifacts" = story.story_artifacts,
					"story_tags" = story.story_tags
				))

	return stories

/datum/storytelling_ui/proc/get_collaborative_sessions()
	var/list/sessions = list()

	if(SSstorytelling && SSstorytelling.manager)
		for(var/session_id in SSstorytelling.manager.collaborative_sessions)
			var/datum/collaborative_session/session = SSstorytelling.manager.collaborative_sessions[session_id]
			if(session)
				sessions += list(list(
					"session_id" = session.session_id,
					"session_title" = session.session_title,
					"session_type" = session.session_type,
					"session_status" = session.session_status,
					"session_creation_date" = session.session_creation_date,
					"session_last_activity" = session.session_last_activity,
					"session_participants" = session.session_participants,
					"session_notes" = session.session_notes,
					"session_decisions" = session.session_decisions,
					"session_assignments" = session.session_assignments
				))

	return sessions

/datum/storytelling_ui/proc/get_user_stories(ckey)
	var/list/user_stories = list()

	if(SSstorytelling && SSstorytelling.manager)
		for(var/story_id in SSstorytelling.manager.active_stories)
			var/datum/story/story = SSstorytelling.manager.active_stories[story_id]
			if(story && story.primary_author && story.primary_author.ckey == ckey)
				user_stories += list(list(
					"story_id" = story.story_id,
					"story_title" = story.story_title,
					"story_type" = story.story_type,
					"story_status" = story.story_status,
					"story_chapters" = story.story_chapters
				))

	return user_stories

/datum/storytelling_ui/proc/get_user_contributions(ckey)
	var/list/user_contributions = list()

	if(SSstorytelling && SSstorytelling.manager)
		for(var/story_id in SSstorytelling.manager.active_stories)
			var/datum/story/story = SSstorytelling.manager.active_stories[story_id]
			if(story && story.story_contributors && story.story_contributors[ckey])
				var/contribution_data = story.story_contributors[ckey]
				user_contributions += list(list(
					"story_id" = story.story_id,
					"story_title" = story.story_title,
					"role" = contribution_data["role"],
					"chapters_contributed" = get_chapters_contributed_by_user(story, ckey)
				))

	return user_contributions

/datum/storytelling_ui/proc/get_chapters_contributed_by_user(datum/story/story, ckey)
	var/chapter_count = 0

	if(story && story.story_chapters)
		for(var/datum/story_chapter/chapter in story.story_chapters)
			if(chapter.chapter_author == ckey)
				chapter_count++

	return chapter_count

/datum/storytelling_ui/proc/get_storytelling_metrics()
	var/list/metrics = list()

	if(SSstorytelling && SSstorytelling.manager)
		metrics["total_stories"] = SSstorytelling.manager.total_stories_created
		metrics["active_collaborations"] = SSstorytelling.manager.active_collaborations
		metrics["story_contributions_count"] = SSstorytelling.manager.story_contributions_count
		metrics["average_story_length"] = SSstorytelling.manager.average_story_length
		metrics["story_completion_rate"] = SSstorytelling.manager.story_completion_rate

	return metrics

/datum/storytelling_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!user || !user.ckey)
		return

	switch(action)
		if("create_story")
			var/title = input(user, "Enter story title:", "Create Story") as text|null
			if(!title)
				return

			var/story_type = input(user, "Select story type:", "Create Story") as null|anything in list("containment_breach", "research_discovery", "character_development", "world_event", "investigation")
			if(!story_type)
				return

			if(SSstorytelling && SSstorytelling.manager)
				var/datum/story/new_story = SSstorytelling.manager.create_story(title, story_type, user.ckey)
				if(new_story)
					to_chat(user, "<span class='notice'>Story '[title]' created successfully!</span>")
					. = TRUE

		if("create_session")
			var/title = input(user, "Enter session title:", "Create Collaboration") as text|null
			if(!title)
				return

			var/session_type = input(user, "Select session type:", "Create Collaboration") as null|anything in list("story_creation", "character_development", "world_building", "event_planning")
			if(!session_type)
				return

			if(SSstorytelling && SSstorytelling.manager)
				var/datum/collaborative_session/new_session = SSstorytelling.manager.create_collaborative_session(title, session_type, user.ckey)
				if(new_session)
					to_chat(user, "<span class='notice'>Collaborative session '[title]' created successfully!</span>")
					. = TRUE

		if("update_story")
			var/story_id = params["story_id"]
			var/field = params["field"]
			var/value = params["value"]

			if(story_id && field && value != null)
				if(SSstorytelling && SSstorytelling.manager)
					var/updates = list()
					updates[field] = value
					if(SSstorytelling.manager.update_story(story_id, updates))
						. = TRUE

		if("add_chapter")
			var/story_id = params["story_id"]
			if(!story_id)
				return

			var/title = input(user, "Enter chapter title:", "Add Chapter") as text|null
			if(!title)
				return

			var/content = input(user, "Enter chapter content:", "Add Chapter") as message|null
			if(!content)
				return

			if(SSstorytelling && SSstorytelling.manager)
				var/datum/story/story = SSstorytelling.manager.get_story(story_id)
				if(story)
					var/chapter_id = "chapter_[world.time]_[user.ckey]"
					var/datum/story_chapter/new_chapter = new /datum/story_chapter(chapter_id, title, content, user.ckey)
					story.story_chapters += new_chapter
					story.story_last_updated = world.time
					to_chat(user, "<span class='notice'>Chapter '[title]' added to story!</span>")
					. = TRUE

		if("invite_contributor")
			var/story_id = params["story_id"]
			if(!story_id)
				return

			var/contributor_ckey = input(user, "Enter contributor ckey:", "Invite Contributor") as text|null
			if(!contributor_ckey)
				return

			var/role = input(user, "Select role:", "Invite Contributor") as null|anything in list("co_author", "contributor", "reviewer", "editor")
			if(!role)
				return

			if(SSstorytelling && SSstorytelling.manager)
				var/permissions = list("read", "write")
				if(role == "co_author")
					permissions += "edit"
				if(role == "editor")
					permissions += "edit"

				if(SSstorytelling.manager.add_story_contributor(story_id, contributor_ckey, role, permissions))
					to_chat(user, "<span class='notice'>Invited [contributor_ckey] as [role]!</span>")
					. = TRUE

		if("join_session")
			var/session_id = params["session_id"]
			if(!session_id)
				return

			if(SSstorytelling && SSstorytelling.manager)
				var/datum/collaborative_session/session = SSstorytelling.manager.collaborative_sessions[session_id]
				if(session && session.session_status == "active")
					session.session_participants[user.ckey] = list(
						"role" = "participant",
						"join_date" = world.time,
						"permissions" = list("read", "write")
					)
					session.session_last_activity = world.time
					to_chat(user, "<span class='notice'>Joined collaborative session!</span>")
					. = TRUE

		if("use_template")
			var/template_id = params["template_id"]
			if(!template_id)
				return

			if(SSstorytelling && SSstorytelling.manager)
				var/template = SSstorytelling.manager.story_templates[template_id]
				if(template)
					var/title = input(user, "Enter story title:", "Use Template") as text|null
					if(!title)
						return

					var/datum/story/new_story = SSstorytelling.manager.create_story(title, template_id, user.ckey)
					if(new_story)
						// Apply template structure
						new_story.story_description = "Story based on [template["name"]] template.\n\nStructure:\n"
						for(var/step in template["structure"])
							new_story.story_description += "- [step]\n"

						to_chat(user, "<span class='notice'>Story '[title]' created using [template["name"]] template!</span>")
						. = TRUE

		if("open_story")
			var/story_id = params["story_id"]
			if(!story_id)
				return

			// This would open the story in a detailed view
			// For now, just notify the user
			to_chat(user, "<span class='notice'>Opening story...</span>")
			. = TRUE

		if("save_story")
			var/story_id = params["story_id"]
			if(story_id)
				to_chat(user, "<span class='notice'>Story saved successfully!</span>")
				. = TRUE

// Verb to open storytelling system
/mob/verb/open_storytelling_system()
	set name = "Open Storytelling System"
	set category = "Roleplay"
	set desc = "Open the storytelling and documentation system"

	var/datum/storytelling_ui/ui = new /datum/storytelling_ui(src)
	ui.ui_interact(src)

// Admin verb to manage storytelling system
/mob/proc/manage_storytelling_system()
	set name = "Manage Storytelling System"
	set category = "Admin"
	set desc = "Manage the storytelling system"

	if(!check_rights(R_ADMIN))
		return

	var/datum/storytelling_ui/ui = new /datum/storytelling_ui(src)
	ui.ui_interact(src)
