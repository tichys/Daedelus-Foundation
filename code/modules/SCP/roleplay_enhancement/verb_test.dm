// Test file to verify roleplay enhancement verbs are working

/mob/verb/test_roleplay_verbs()
	set name = "Test Roleplay Verbs"
	set category = "Debug"
	set desc = "Test if the roleplay enhancement verbs are working"

	if(!check_rights(R_DEBUG))
		to_chat(src, "<span class='warning'>You don't have permission to run this test.</span>")
		return

	to_chat(src, "<span class='notice'>=== Testing Roleplay Enhancement Verbs ===</span>")

	// Test 1: Check if character system exists
	if(SSroleplay_character)
		to_chat(src, "<span class='notice'>✅ Roleplay Character System: Found</span>")
	else
		to_chat(src, "<span class='warning'>❌ Roleplay Character System: Not Found</span>")

	// Test 2: Check if storytelling system exists
	if(SSstorytelling)
		to_chat(src, "<span class='notice'>✅ Storytelling System: Found</span>")
	else
		to_chat(src, "<span class='warning'>❌ Storytelling System: Not Found</span>")

	// Test 3: Check if foundation politics system exists
	if(SSfoundation_politics)
		to_chat(src, "<span class='notice'>✅ Foundation Politics System: Found</span>")
	else
		to_chat(src, "<span class='warning'>❌ Foundation Politics System: Not Found</span>")

	// Test 4: Test verb functionality
	to_chat(src, "<span class='notice'>Testing verb functionality...</span>")

	// Try to create UI instances
	var/success_count = 0

		// Test character sheet UI
	try
		var/datum/roleplay_character_ui/char_ui = new /datum/roleplay_character_ui(src)
		if(char_ui)
			to_chat(src, "<span class='notice'>✅ Character Sheet UI: Created successfully</span>")
			success_count++
		else
			to_chat(src, "<span class='warning'>❌ Character Sheet UI: Failed to create</span>")
	catch(var/exception/char_error)
		to_chat(src, "<span class='warning'>❌ Character Sheet UI: Error - [char_error]</span>")

	// Test storytelling UI
	try
		var/datum/storytelling_ui/story_ui = new /datum/storytelling_ui(src)
		if(story_ui)
			to_chat(src, "<span class='notice'>✅ Storytelling UI: Created successfully</span>")
			success_count++
		else
			to_chat(src, "<span class='warning'>❌ Storytelling UI: Failed to create</span>")
	catch(var/exception/story_error)
		to_chat(src, "<span class='warning'>❌ Storytelling UI: Error - [story_error]</span>")

	// Test foundation politics UI
	try
		var/datum/foundation_politics_ui/politics_ui = new /datum/foundation_politics_ui(src)
		if(politics_ui)
			to_chat(src, "<span class='notice'>✅ Foundation Politics UI: Created successfully</span>")
			success_count++
		else
			to_chat(src, "<span class='warning'>❌ Foundation Politics UI: Failed to create</span>")
	catch(var/exception/politics_error)
		to_chat(src, "<span class='warning'>❌ Foundation Politics UI: Error - [politics_error]</span>")

	to_chat(src, "<span class='notice'>=== Test Results ===</span>")
	to_chat(src, "<span class='notice'>Successful UI creations: [success_count]/3</span>")

	if(success_count == 3)
		to_chat(src, "<span class='notice'>✅ All roleplay enhancement systems are working correctly!</span>")
		to_chat(src, "<span class='notice'>The buttons should work when you click them.</span>")
	else
		to_chat(src, "<span class='warning'>❌ Some systems are not working properly.</span>")
		to_chat(src, "<span class='warning'>Check the error messages above for details.</span>")

/mob/verb/open_all_roleplay_systems()
	set name = "Open All Roleplay Systems"
	set category = "Debug"
	set desc = "Open all roleplay enhancement systems for testing"

	if(!check_rights(R_DEBUG))
		to_chat(src, "<span class='warning'>You don't have permission to run this test.</span>")
		return

	to_chat(src, "<span class='notice'>Opening all roleplay enhancement systems...</span>")

		// Open character sheet
	try
		var/datum/roleplay_character_ui/char_ui = new /datum/roleplay_character_ui(src)
		char_ui.ui_interact(src)
		to_chat(src, "<span class='notice'>✅ Character Sheet opened</span>")
	catch(var/exception/char_error)
		to_chat(src, "<span class='warning'>❌ Character Sheet failed: [char_error]</span>")

	// Open storytelling system
	try
		var/datum/storytelling_ui/story_ui = new /datum/storytelling_ui(src)
		story_ui.ui_interact(src)
		to_chat(src, "<span class='notice'>✅ Storytelling System opened</span>")
	catch(var/exception/story_error)
		to_chat(src, "<span class='warning'>❌ Storytelling System failed: [story_error]</span>")

	// Open foundation politics
	try
		var/datum/foundation_politics_ui/politics_ui = new /datum/foundation_politics_ui(src)
		politics_ui.ui_interact(src)
		to_chat(src, "<span class='notice'>✅ Foundation Politics opened</span>")
	catch(var/exception/politics_error)
		to_chat(src, "<span class='warning'>❌ Foundation Politics failed: [politics_error]</span>")

	to_chat(src, "<span class='notice'>All systems opened. Check if the interfaces appear.</span>")
