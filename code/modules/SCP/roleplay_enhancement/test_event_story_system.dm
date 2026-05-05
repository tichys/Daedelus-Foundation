// Test script for Event & Story Management System
// This file can be used to test the system functionality

/mob/verb/test_event_story_system_basic()
	set name = "Test Event Story System (Basic)"
	set category = "Debug"
	set desc = "Run basic tests for the Event & Story Management system"

	if(!check_rights(R_DEBUG))
		to_chat(src, "<span class='warning'>You don't have permission to run tests.</span>")
		return

	to_chat(src, "<span class='notice'>=== Testing Event & Story Management System ===</span>")

	// Test 1: Check if subsystem exists
	if(!SSevent_story_management)
		to_chat(src, "<span class='warning'>FAIL: SSevent_story_management subsystem not found.</span>")
		return

	to_chat(src, "<span class='notice'>PASS: SSevent_story_management subsystem found.</span>")

	// Test 2: Check if manager exists
	if(!SSevent_story_management.manager)
		to_chat(src, "<span class='warning'>FAIL: Event story management manager not found.</span>")
		return

	to_chat(src, "<span class='notice'>PASS: Event story management manager found.</span>")

	// Test 3: Test event creation
	var/datum/event/test_event = SSevent_story_management.manager.create_event(
		"Test Event",
		"containment_breach",
		"This is a test event for system validation."
	)

	if(!test_event)
		to_chat(src, "<span class='warning'>FAIL: Event creation failed.</span>")
		return

	to_chat(src, "<span class='notice'>PASS: Event created successfully - [test_event.event_title]</span>")

	// Test 4: Test story arc creation
	var/datum/story_arc/test_arc = SSevent_story_management.manager.create_story_arc(
		"Test Story Arc",
		"containment_breach",
		"This is a test story arc for system validation."
	)

	if(!test_arc)
		to_chat(src, "<span class='warning'>FAIL: Story arc creation failed.</span>")
		return

	to_chat(src, "<span class='notice'>PASS: Story arc created successfully - [test_arc.arc_title]</span>")

	// Test 5: Test player event creation
	var/datum/player_initiated_event/test_player_event = SSevent_story_management.manager.create_player_event(
		"Test Player Event",
		"research_discovery",
		"This is a test player event for system validation.",
		src.ckey
	)

	if(!test_player_event)
		to_chat(src, "<span class='warning'>FAIL: Player event creation failed.</span>")
		return

	to_chat(src, "<span class='notice'>PASS: Player event created successfully - [test_player_event.event_title]</span>")

	// Test 6: Test event progression
	var/initial_stage = test_event.current_stage
	test_event.progress_to_next_stage()

	if(test_event.current_stage != initial_stage + 1)
		to_chat(src, "<span class='warning'>FAIL: Event progression failed.</span>")
		return

	to_chat(src, "<span class='notice'>PASS: Event progression working - Stage [test_event.current_stage]</span>")

	// Test 7: Test TGUI interface
	var/datum/event_story_management_ui/test_ui = new /datum/event_story_management_ui(src)
	if(!test_ui)
		to_chat(src, "<span class='warning'>FAIL: TGUI interface creation failed.</span>")
		return

	to_chat(src, "<span class='notice'>PASS: TGUI interface created successfully.</span>")

	// Test 8: Test metrics calculation
	SSevent_story_management.manager.calculate_metrics()
	to_chat(src, "<span class='notice'>PASS: Metrics calculation completed.</span>")

	// Display current system status
	to_chat(src, "<span class='notice'>=== System Status ===")
	to_chat(src, "<span class='notice'>Active Events: [length(SSevent_story_management.manager.active_events)]</span>")
	to_chat(src, "<span class='notice'>Story Arcs: [length(SSevent_story_management.manager.story_arcs)]</span>")
	to_chat(src, "<span class='notice'>Player Events: [length(SSevent_story_management.manager.player_initiated_events)]</span>")
	to_chat(src, "<span class='notice'>Total Events Created: [SSevent_story_management.manager.total_events_created]</span>")
	to_chat(src, "<span class='notice'>Player Participation Rate: [SSevent_story_management.manager.player_participation_rate]%</span>")
	to_chat(src, "<span class='notice'>Event Completion Rate: [SSevent_story_management.manager.event_completion_rate]%</span>")
	to_chat(src, "<span class='notice'>Story Coherence Score: [SSevent_story_management.manager.story_coherence_score]%</span>")

	to_chat(src, "<span class='notice'>=== All Tests Passed! ===</span>")
	to_chat(src, "<span class='notice'>The Event & Story Management System is working correctly.</span>")

/mob/verb/open_event_story_test_ui()
	set name = "Open Event Story Test UI"
	set category = "Debug"
	set desc = "Open the Event & Story Management UI for testing"

	if(!check_rights(R_DEBUG))
		to_chat(src, "<span class='warning'>You don't have permission to access the test UI.</span>")
		return

	var/datum/event_story_management_ui/ui = new /datum/event_story_management_ui(src)
	ui.ui_interact(src)

	to_chat(src, "<span class='notice'>Event & Story Management UI opened for testing.</span>")

/mob/verb/create_test_event_data()
	set name = "Create Test Event Data"
	set category = "Debug"
	set desc = "Create sample event data for testing"

	if(!check_rights(R_DEBUG))
		to_chat(src, "<span class='warning'>You don't have permission to create test data.</span>")
		return

	if(!SSevent_story_management || !SSevent_story_management.manager)
		to_chat(src, "<span class='warning'>Event & Story Management system not available.</span>")
		return

	// Create sample events
	var/event_types = list("containment_breach", "research_discovery", "personnel_conflict", "scp_interaction", "facility_incident")
	var/event_titles = list(
		"SCP-173 Containment Breach",
		"Breakthrough in SCP-682 Research",
		"Security vs Research Dispute",
		"SCP-049 Awakening Event",
		"Power Grid Failure"
	)
	var/event_descriptions = list(
		"A containment breach involving SCP-173 has occurred in Sector 3.",
		"Research team discovers new properties of SCP-682's regeneration.",
		"Tensions rise between Security and Research departments.",
		"SCP-049 has shown signs of increased activity and awareness.",
		"Critical power failure affects multiple containment zones."
	)

	for(var/i = 1; i <= 5; i++)
		var/event_type = event_types[i]
		var/event_title = event_titles[i]
		var/event_description = event_descriptions[i]

		var/datum/event/new_event = SSevent_story_management.manager.create_event(
			event_title,
			event_type,
			event_description
		)

		if(new_event)
			// Add some participants
			new_event.event_participants += "test_player_1"
			new_event.event_participants += "test_player_2"
			new_event.event_roles["test_player_1"] = "responder"
			new_event.event_roles["test_player_2"] = "coordinator"

			// Progress some events
			if(i <= 3)
				new_event.progress_to_next_stage()
			if(i <= 2)
				new_event.progress_to_next_stage()

	// Create sample story arcs
	var/arc_types = list("containment_breach", "research_project", "personnel_drama", "scp_awakening", "facility_crisis")
	var/arc_titles = list(
		"The Great Containment Crisis",
		"Project Phoenix Research Initiative",
		"The Department Wars",
		"SCP Consciousness Awakening",
		"Facility Infrastructure Crisis"
	)
	var/arc_descriptions = list(
		"A series of containment breaches that test the Foundation's capabilities.",
		"Long-term research project to understand SCP regeneration patterns.",
		"Ongoing conflicts between different Foundation departments.",
		"Multiple SCPs showing signs of increased consciousness.",
		"Critical infrastructure failures affecting the entire facility."
	)

	for(var/i = 1; i <= 5; i++)
		var/arc_type = arc_types[i]
		var/arc_title = arc_titles[i]
		var/arc_description = arc_descriptions[i]

		var/datum/story_arc/new_arc = SSevent_story_management.manager.create_story_arc(
			arc_title,
			arc_type,
			arc_description
		)

		if(new_arc)
			// Add some characters and locations
			new_arc.arc_characters += "Dr. Bright"
			new_arc.arc_characters += "Commander Johnson"
			new_arc.arc_locations += "Sector 3"
			new_arc.arc_locations += "Research Wing"

	// Create sample player events
	var/player_event_titles = list(
		"Proposed SCP Interaction Protocol",
		"Request for Additional Security",
		"Medical Emergency Response Plan",
		"Engineering Maintenance Schedule",
		"Administrative Policy Review"
	)

	for(var/i = 1; i <= 5; i++)
		var/player_event_title = player_event_titles[i]
		var/player_event_description = "Player-proposed event for testing purposes."

		var/datum/player_initiated_event/new_player_event = SSevent_story_management.manager.create_player_event(
			player_event_title,
			"facility_incident",
			player_event_description,
			"test_player_[i]"
		)

		if(new_player_event)
			// Add some approval votes
			new_player_event.event_approval_votes += "admin_1"
			new_player_event.event_approval_votes += "admin_2"

	// Calculate metrics
	SSevent_story_management.manager.calculate_metrics()

	to_chat(src, "<span class='notice'>Test event data created successfully!</span>")
	to_chat(src, "<span class='notice'>Created 5 events, 5 story arcs, and 5 player events.</span>")
	to_chat(src, "<span class='notice'>Use 'Open Event Story Test UI' to view the data.</span>")

/mob/verb/clear_event_story_data()
	set name = "Clear Event Story Data"
	set category = "Debug"
	set desc = "Clear all event and story data (WARNING: This will delete all data)"

	if(!check_rights(R_DEBUG))
		to_chat(src, "<span class='warning'>You don't have permission to clear data.</span>")
		return

	var/confirm = input(src, "Are you sure you want to clear all Event & Story Management data? This cannot be undone.", "Confirm Clear") as null|anything in list("Yes", "No")

	if(confirm != "Yes")
		to_chat(src, "<span class='notice'>Data clear cancelled.</span>")
		return

	if(!SSevent_story_management || !SSevent_story_management.manager)
		to_chat(src, "<span class='warning'>Event & Story Management system not available.</span>")
		return

	var/datum/event_story_management_manager/manager = SSevent_story_management.manager

	manager.active_events.Cut()
	manager.story_arcs.Cut()
	manager.player_initiated_events.Cut()
	manager.emergent_stories.Cut()
	manager.total_events_created = 0
	manager.active_story_arcs = 0
	manager.player_participation_rate = 0
	manager.event_completion_rate = 0
	manager.story_coherence_score = 0

	to_chat(src, "<span class='notice'>All Event & Story Management data cleared successfully.</span>")
