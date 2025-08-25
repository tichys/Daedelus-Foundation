// Event & Story Management System TGUI Backend
// Handles the TGUI interface for event and story management

// TGUI Interface Registration
/datum/tgui_module/event_story_management
	name = "Event Story Management"
	tgui_id = "EventStoryManagement"

/datum/tgui_module/event_story_management/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EventStoryManagement")
		ui.open()

/datum/event_story_management_ui
	var/mob/user
	var/datum/event/selected_event
	var/datum/story_arc/selected_arc

/datum/event_story_management_ui/New(mob/user)
	src.user = user

/datum/event_story_management_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EventStoryManagement")
		ui.open()

/datum/event_story_management_ui/ui_data(mob/user)
	var/list/data = list()

	// Get active events
	data["active_events"] = get_active_events()

	// Get event templates
	if(SSevent_story_management && SSevent_story_management.manager)
		data["event_templates"] = SSevent_story_management.manager.event_templates

	// Get story arcs
	data["story_arcs"] = get_story_arcs()

	// Get player initiated events
	data["player_initiated_events"] = get_player_initiated_events()

	// Get emergent stories
	data["emergent_stories"] = get_emergent_stories()

	// Get event triggers
	if(SSevent_story_management && SSevent_story_management.manager)
		data["event_triggers"] = SSevent_story_management.manager.event_triggers

	// Get metrics
	data["metrics"] = get_event_metrics()

	return data

/datum/event_story_management_ui/proc/get_active_events()
	var/list/events = list()

	if(SSevent_story_management && SSevent_story_management.manager)
		for(var/event_id in SSevent_story_management.manager.active_events)
			var/datum/event/event = SSevent_story_management.manager.active_events[event_id]
			if(event)
				events += list(list(
					"event_id" = event.event_id,
					"event_title" = event.event_title,
					"event_type" = event.event_type,
					"event_description" = event.event_description,
					"event_status" = event.event_status,
					"event_severity" = event.event_severity,
					"event_priority" = event.event_priority,
					"event_stages" = event.event_stages,
					"current_stage" = event.current_stage,
					"event_start_time" = event.event_start_time,
					"event_estimated_duration" = event.event_estimated_duration,
					"event_actual_duration" = event.event_actual_duration,
					"event_participants" = event.event_participants,
					"event_roles" = event.event_roles,
					"event_actions" = event.event_actions,
					"event_outcomes" = event.event_outcomes,
					"event_consequences" = event.event_consequences,
					"event_requirements" = event.event_requirements,
					"event_creation_date" = event.event_creation_date,
					"event_last_updated" = event.event_last_updated
				))

	return events

/datum/event_story_management_ui/proc/get_story_arcs()
	var/list/arcs = list()

	if(SSevent_story_management && SSevent_story_management.manager)
		for(var/arc_id in SSevent_story_management.manager.story_arcs)
			var/datum/story_arc/arc = SSevent_story_management.manager.story_arcs[arc_id]
			if(arc)
				arcs += list(list(
					"arc_id" = arc.arc_id,
					"arc_title" = arc.arc_title,
					"arc_type" = arc.arc_type,
					"arc_description" = arc.arc_description,
					"arc_status" = arc.arc_status,
					"arc_complexity" = arc.arc_complexity,
					"arc_events" = arc.arc_events,
					"arc_characters" = arc.arc_characters,
					"arc_locations" = arc.arc_locations,
					"arc_objectives" = arc.arc_objectives,
					"arc_milestones" = arc.arc_milestones,
					"arc_themes" = arc.arc_themes,
					"arc_conflicts" = arc.arc_conflicts,
					"arc_resolutions" = arc.arc_resolutions,
					"arc_creation_date" = arc.arc_creation_date,
					"arc_last_updated" = arc.arc_last_updated
				))

	return arcs

/datum/event_story_management_ui/proc/get_player_initiated_events()
	var/list/events = list()

	if(SSevent_story_management && SSevent_story_management.manager)
		for(var/event_id in SSevent_story_management.manager.player_initiated_events)
			var/datum/player_initiated_event/event = SSevent_story_management.manager.player_initiated_events[event_id]
			if(event)
				events += list(list(
					"event_id" = event.event_id,
					"event_title" = event.event_title,
					"event_type" = event.event_type,
					"event_description" = event.event_description,
					"event_initiator" = event.event_initiator,
					"event_participants" = event.event_participants,
					"event_status" = event.event_status,
					"event_approval_votes" = event.event_approval_votes,
					"event_creation_date" = event.event_creation_date,
					"event_approval_date" = event.event_approval_date
				))

	return events

/datum/event_story_management_ui/proc/get_emergent_stories()
	var/list/stories = list()

	if(SSevent_story_management && SSevent_story_management.manager)
		for(var/story_id in SSevent_story_management.manager.emergent_stories)
			var/story = SSevent_story_management.manager.emergent_stories[story_id]
			if(story)
				stories += list(list(
					"story_id" = story_id,
					"story_title" = story["story_title"],
					"story_type" = story["story_type"],
					"story_description" = story["story_description"],
					"story_creation_date" = story["story_creation_date"]
				))

	return stories

/datum/event_story_management_ui/proc/get_event_metrics()
	var/list/metrics = list()

	if(SSevent_story_management && SSevent_story_management.manager)
		metrics["total_events_created"] = SSevent_story_management.manager.total_events_created
		metrics["active_story_arcs"] = SSevent_story_management.manager.active_story_arcs
		metrics["player_participation_rate"] = SSevent_story_management.manager.player_participation_rate
		metrics["event_completion_rate"] = SSevent_story_management.manager.event_completion_rate
		metrics["story_coherence_score"] = SSevent_story_management.manager.story_coherence_score

	return metrics

/datum/event_story_management_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!user || !user.ckey)
		return

	switch(action)
		if("create_event")
			var/title = input(user, "Enter event title:", "Create Event") as text|null
			if(!title)
				return

			var/event_type = input(user, "Select event type:", "Create Event") as null|anything in list("containment_breach", "research_discovery", "personnel_conflict", "scp_interaction", "facility_incident")
			if(!event_type)
				return

			var/description = input(user, "Enter event description:", "Create Event") as message|null
			if(!description)
				return

			if(SSevent_story_management && SSevent_story_management.manager)
				var/datum/event/new_event = SSevent_story_management.manager.create_event(title, event_type, description)
				if(new_event)
					to_chat(user, "<span class='notice'>Event '[title]' created successfully!</span>")
					. = TRUE

		if("create_story_arc")
			var/title = input(user, "Enter story arc title:", "Create Story Arc") as text|null
			if(!title)
				return

			var/arc_type = input(user, "Select arc type:", "Create Story Arc") as null|anything in list("containment_breach", "research_project", "personnel_drama", "scp_awakening", "facility_crisis")
			if(!arc_type)
				return

			var/description = input(user, "Enter arc description:", "Create Story Arc") as message|null
			if(!description)
				return

			if(SSevent_story_management && SSevent_story_management.manager)
				var/datum/story_arc/new_arc = SSevent_story_management.manager.create_story_arc(title, arc_type, description)
				if(new_arc)
					to_chat(user, "<span class='notice'>Story arc '[title]' created successfully!</span>")
					. = TRUE

		if("propose_player_event")
			var/title = input(user, "Enter event title:", "Propose Player Event") as text|null
			if(!title)
				return

			var/event_type = input(user, "Select event type:", "Propose Player Event") as null|anything in list("containment_breach", "research_discovery", "personnel_conflict", "scp_interaction", "facility_incident")
			if(!event_type)
				return

			var/description = input(user, "Enter event description:", "Propose Player Event") as message|null
			if(!description)
				return

			if(SSevent_story_management && SSevent_story_management.manager)
				var/datum/player_initiated_event/new_event = SSevent_story_management.manager.create_player_event(title, event_type, description, user.ckey)
				if(new_event)
					to_chat(user, "<span class='notice'>Player event '[title]' proposed successfully!</span>")
					. = TRUE

		if("join_event")
			var/event_id = params["event_id"]
			if(!event_id)
				return

			if(SSevent_story_management && SSevent_story_management.manager)
				var/datum/event/event = SSevent_story_management.manager.active_events[event_id]
				if(event)
					event.event_participants += user.ckey
					event.event_roles[user.ckey] = "participant"
					event.event_last_updated = world.time
					to_chat(user, "<span class='notice'>Joined event '[event.event_title]'!</span>")
					. = TRUE

		if("advance_event")
			var/event_id = params["event_id"]
			if(!event_id)
				return

			if(SSevent_story_management && SSevent_story_management.manager)
				var/datum/event/event = SSevent_story_management.manager.active_events[event_id]
				if(event)
					event.progress_to_next_stage()
					to_chat(user, "<span class='notice'>Advanced event '[event.event_title]' to stage [event.current_stage]!</span>")
					. = TRUE

		if("add_event_to_arc")
			var/arc_id = params["arc_id"]
			if(!arc_id)
				return

			var/title = input(user, "Enter event title:", "Add Event to Arc") as text|null
			if(!title)
				return

			var/event_type = input(user, "Select event type:", "Add Event to Arc") as null|anything in list("containment_breach", "research_discovery", "personnel_conflict", "scp_interaction", "facility_incident")
			if(!event_type)
				return

			var/description = input(user, "Enter event description:", "Add Event to Arc") as message|null
			if(!description)
				return

			if(SSevent_story_management && SSevent_story_management.manager)
				var/datum/story_arc/arc = SSevent_story_management.manager.story_arcs[arc_id]
				if(arc)
					var/datum/event/new_event = SSevent_story_management.manager.create_event(title, event_type, description)
					if(new_event)
						arc.arc_events += new_event
						new_event.linked_story_arc = arc
						to_chat(user, "<span class='notice'>Added event '[title]' to story arc!</span>")
						. = TRUE

		if("approve_event")
			var/event_id = params["event_id"]
			if(!event_id)
				return

			if(SSevent_story_management && SSevent_story_management.manager)
				var/datum/player_initiated_event/event = SSevent_story_management.manager.player_initiated_events[event_id]
				if(event)
					event.event_status = "approved"
					event.event_approval_date = world.time
					to_chat(user, "<span class='notice'>Approved player event '[event.event_title]'!</span>")
					. = TRUE

		if("use_event_template")
			var/template_id = params["template_id"]
			if(!template_id)
				return

			if(SSevent_story_management && SSevent_story_management.manager)
				var/template = SSevent_story_management.manager.event_templates[template_id]
				if(template)
					var/title = input(user, "Enter event title:", "Use Event Template") as text|null
					if(!title)
						return

					var/datum/event/new_event = SSevent_story_management.manager.create_event(title, template_id, template["description"])
					if(new_event)
						new_event.event_severity = template["severity"]
						to_chat(user, "<span class='notice'>Created event '[title]' using [template["name"]] template!</span>")
						. = TRUE

// Verb to open event story management system
/mob/verb/open_event_story_management()
	set name = "Open Event Story Management"
	set category = "Roleplay"
	set desc = "Open the event and story management system"

	var/datum/event_story_management_ui/ui = new /datum/event_story_management_ui(src)
	ui.ui_interact(src)

// Admin verb to manage event story management system
/mob/proc/manage_event_story_management()
	set name = "Manage Event Story Management"
	set category = "Admin"
	set desc = "Manage the event and story management system"

	if(!check_rights(R_ADMIN))
		return

	var/datum/event_story_management_ui/ui = new /datum/event_story_management_ui(src)
	ui.ui_interact(src)
