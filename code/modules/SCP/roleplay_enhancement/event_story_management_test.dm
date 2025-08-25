// Event & Story Management System Test File
// Contains test procedures and debug functions

/datum/event_story_management_test
	var/test_results = list()

/datum/event_story_management_test/proc/run_all_tests()
	world.log << "=== Event & Story Management System Tests ==="

	test_manager_initialization()
	test_event_creation()
	test_story_arc_creation()
	test_player_event_creation()
	test_event_progression()
	test_metrics_calculation()
	test_tgui_interface()

	world.log << "=== Test Results ==="
	for(var/test_name in test_results)
		var/result = test_results[test_name]
		world.log << "[test_name]: [result ? "PASS" : "FAIL"]"

	world.log << "=== Tests Complete ==="

/datum/event_story_management_test/proc/test_manager_initialization()
	world.log << "Testing manager initialization..."

	if(!SSevent_story_management)
		test_results["Manager Initialization"] = FALSE
		world.log << "FAIL: SSevent_story_management not found"
		return

	if(!SSevent_story_management.manager)
		test_results["Manager Initialization"] = FALSE
		world.log << "FAIL: Manager not initialized"
		return

	test_results["Manager Initialization"] = TRUE
	world.log << "PASS: Manager initialized successfully"

/datum/event_story_management_test/proc/test_event_creation()
	world.log << "Testing event creation..."

	if(!SSevent_story_management || !SSevent_story_management.manager)
		test_results["Event Creation"] = FALSE
		return

	var/datum/event/test_event = SSevent_story_management.manager.create_event(
		"Test Event",
		"containment_breach",
		"This is a test event for system validation."
	)

	if(!test_event)
		test_results["Event Creation"] = FALSE
		world.log << "FAIL: Event creation failed"
		return

	if(test_event.event_title != "Test Event")
		test_results["Event Creation"] = FALSE
		world.log << "FAIL: Event title mismatch"
		return

	if(test_event.event_type != "containment_breach")
		test_results["Event Creation"] = FALSE
		world.log << "FAIL: Event type mismatch"
		return

	test_results["Event Creation"] = TRUE
	world.log << "PASS: Event created successfully"

	// Clean up
	SSevent_story_management.manager.active_events -= test_event.event_id

/datum/event_story_management_test/proc/test_story_arc_creation()
	world.log << "Testing story arc creation..."

	if(!SSevent_story_management || !SSevent_story_management.manager)
		test_results["Story Arc Creation"] = FALSE
		return

	var/datum/story_arc/test_arc = SSevent_story_management.manager.create_story_arc(
		"Test Story Arc",
		"containment_breach",
		"This is a test story arc for system validation."
	)

	if(!test_arc)
		test_results["Story Arc Creation"] = FALSE
		world.log << "FAIL: Story arc creation failed"
		return

	if(test_arc.arc_title != "Test Story Arc")
		test_results["Story Arc Creation"] = FALSE
		world.log << "FAIL: Story arc title mismatch"
		return

	if(test_arc.arc_type != "containment_breach")
		test_results["Story Arc Creation"] = FALSE
		world.log << "FAIL: Story arc type mismatch"
		return

	test_results["Story Arc Creation"] = TRUE
	world.log << "PASS: Story arc created successfully"

	// Clean up
	SSevent_story_management.manager.story_arcs -= test_arc.arc_id

/datum/event_story_management_test/proc/test_player_event_creation()
	world.log << "Testing player event creation..."

	if(!SSevent_story_management || !SSevent_story_management.manager)
		test_results["Player Event Creation"] = FALSE
		return

	var/datum/player_initiated_event/test_player_event = SSevent_story_management.manager.create_player_event(
		"Test Player Event",
		"research_discovery",
		"This is a test player event for system validation.",
		"test_player"
	)

	if(!test_player_event)
		test_results["Player Event Creation"] = FALSE
		world.log << "FAIL: Player event creation failed"
		return

	if(test_player_event.event_title != "Test Player Event")
		test_results["Player Event Creation"] = FALSE
		world.log << "FAIL: Player event title mismatch"
		return

	if(test_player_event.event_initiator != "test_player")
		test_results["Player Event Creation"] = FALSE
		world.log << "FAIL: Player event initiator mismatch"
		return

	test_results["Player Event Creation"] = TRUE
	world.log << "PASS: Player event created successfully"

	// Clean up
	SSevent_story_management.manager.player_initiated_events -= test_player_event.event_id

/datum/event_story_management_test/proc/test_event_progression()
	world.log << "Testing event progression..."

	if(!SSevent_story_management || !SSevent_story_management.manager)
		test_results["Event Progression"] = FALSE
		return

	var/datum/event/test_event = SSevent_story_management.manager.create_event(
		"Progression Test Event",
		"facility_incident",
		"Testing event progression functionality."
	)

	if(!test_event)
		test_results["Event Progression"] = FALSE
		return

	var/initial_stage = test_event.current_stage
	test_event.progress_to_next_stage()

	if(test_event.current_stage != initial_stage + 1)
		test_results["Event Progression"] = FALSE
		world.log << "FAIL: Event stage did not progress"
		return

	test_results["Event Progression"] = TRUE
	world.log << "PASS: Event progression working"

	// Clean up
	SSevent_story_management.manager.active_events -= test_event.event_id

/datum/event_story_management_test/proc/test_metrics_calculation()
	world.log << "Testing metrics calculation..."

	if(!SSevent_story_management || !SSevent_story_management.manager)
		test_results["Metrics Calculation"] = FALSE
		return

	// Create some test data
	var/datum/event/event1 = SSevent_story_management.manager.create_event("Test Event 1", "containment_breach", "Test")
	var/datum/event/event2 = SSevent_story_management.manager.create_event("Test Event 2", "research_discovery", "Test")

	event1.event_participants += "player1"
	event1.event_participants += "player2"
	event2.event_participants += "player1"

	// Calculate metrics
	SSevent_story_management.manager.calculate_metrics()

	if(SSevent_story_management.manager.total_events_created < 2)
		test_results["Metrics Calculation"] = FALSE
		world.log << "FAIL: Total events count incorrect"
		return

	test_results["Metrics Calculation"] = TRUE
	world.log << "PASS: Metrics calculation working"

	// Clean up
	SSevent_story_management.manager.active_events -= event1.event_id
	SSevent_story_management.manager.active_events -= event2.event_id

/datum/event_story_management_test/proc/test_tgui_interface()
	world.log << "Testing TGUI interface..."

	// Test UI creation
	var/datum/event_story_management_ui/test_ui = new /datum/event_story_management_ui()

	if(!test_ui)
		test_results["TGUI Interface"] = FALSE
		world.log << "FAIL: TGUI interface creation failed"
		return

	test_results["TGUI Interface"] = TRUE
	world.log << "PASS: TGUI interface created successfully"

// Debug commands for testing
/mob/verb/test_event_story_management()
	set name = "Test Event Story Management"
	set category = "Debug"
	set desc = "Run tests for the Event & Story Management system"

	if(!check_rights(R_DEBUG))
		to_chat(src, "<span class='warning'>You don't have permission to run tests.</span>")
		return

	var/datum/event_story_management_test/test_suite = new /datum/event_story_management_test()
	test_suite.run_all_tests()

	to_chat(src, "<span class='notice'>Event & Story Management tests completed. Check server logs for results.</span>")

/mob/verb/debug_event_story_management()
	set name = "Debug Event Story Management"
	set category = "Debug"
	set desc = "Show debug information for the Event & Story Management system"

	if(!check_rights(R_DEBUG))
		to_chat(src, "<span class='warning'>You don't have permission to access debug information.</span>")
		return

	if(!SSevent_story_management)
		to_chat(src, "<span class='warning'>Event Story Management subsystem not found.</span>")
		return

	if(!SSevent_story_management.manager)
		to_chat(src, "<span class='warning'>Event Story Management manager not initialized.</span>")
		return

	var/datum/event_story_management_manager/manager = SSevent_story_management.manager

	to_chat(src, "<span class='notice'>=== Event & Story Management Debug Info ===</span>")
	to_chat(src, "<span class='notice'>Active Events: [manager.active_events.len]</span>")
	to_chat(src, "<span class='notice'>Story Arcs: [manager.story_arcs.len]</span>")
	to_chat(src, "<span class='notice'>Player Events: [manager.player_initiated_events.len]</span>")
	to_chat(src, "<span class='notice'>Event Templates: [manager.event_templates.len]</span>")
	to_chat(src, "<span class='notice'>Total Events Created: [manager.total_events_created]</span>")
	to_chat(src, "<span class='notice'>Player Participation Rate: [manager.player_participation_rate]%</span>")
	to_chat(src, "<span class='notice'>Event Completion Rate: [manager.event_completion_rate]%</span>")
	to_chat(src, "<span class='notice'>Story Coherence Score: [manager.story_coherence_score]%</span>")

/mob/verb/reset_event_story_management()
	set name = "Reset Event Story Management"
	set category = "Debug"
	set desc = "Reset the Event & Story Management system (WARNING: This will clear all data)"

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to reset the system.</span>")
		return

	var/confirm = input(src, "Are you sure you want to reset the Event & Story Management system? This will clear ALL data.", "Confirm Reset") as null|anything in list("Yes", "No")

	if(confirm != "Yes")
		to_chat(src, "<span class='notice'>Reset cancelled.</span>")
		return

	if(!SSevent_story_management || !SSevent_story_management.manager)
		to_chat(src, "<span class='warning'>System not found or not initialized.</span>")
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

	to_chat(src, "<span class='notice'>Event & Story Management system reset successfully.</span>")
