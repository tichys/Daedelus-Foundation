// D-Class Verbs and Interface
// Commands and actions available to D-Class players

// D-Class Status Verb
/mob/living/carbon/human/verb/dclass_status()
	set name = "D-Class Status"
	set category = "D-Class"
	set desc = "View your current D-Class status and progression"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	// Display status information
	var/info = player.get_status_info()

	// Add current time and routine information
	if(SSdclass.manager)
		info += "<br><b>Current Time:</b> [SSdclass.manager.current_time_slot]<br>"
		info += "<b>Security Level:</b> [SSdclass.manager.get_security_level()]/4<br>"

	// Add contraband list
	info += "<br><h4>Contraband Inventory:</h4>"
	if(player.contraband.len > 0)
		for(var/item in player.contraband)
			info += "- [item] (x[player.contraband[item]])<br>"
	else
		info += "No contraband items.<br>"

	// Add skills information
	info += "<br><h4>Skills:</h4>"
	for(var/skill in player.skills)
		info += "- [skill]: [player.skills[skill]]<br>"

	// Add abilities information
	info += "<br><h4>Abilities:</h4>"
	if(player.abilities.len > 0)
		for(var/ability in player.abilities)
			if(ability != "disguise_effectiveness")
				info += "- [ability]<br>"
	else
		info += "No special abilities.<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

// D-Class Escape Planning Verb
/mob/living/carbon/human/verb/dclass_escape_plan()
	set name = "Plan Escape"
	set category = "D-Class"
	set desc = "Plan and attempt an escape route"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	// Show available escape routes
	var/list/available_routes = list()
	for(var/route_id in SSdclass.manager.escape_routes)
		var/list/route_data = SSdclass.manager.escape_routes[route_id]
		var/route_name = route_data["name"]
		available_routes[route_name] = route_id

	// Add cancel option
	available_routes["Cancel"] = "cancel"

	var/choice = input(src, "Choose an escape route:", "Plan Escape") as null|anything in available_routes
	if(!choice || choice == "Cancel")
		return

	var/route_id = available_routes[choice]
	var/list/route_data = SSdclass.manager.escape_routes[route_id]

	// Show route information
	var/info = "<h3>[route_data["name"]]</h3>"
	info += "<b>Description:</b> [route_data["description"]]<br>"
	info += "<b>Difficulty:</b> [route_data["difficulty"]]/5<br>"
	info += "<b>Time Required:</b> [route_data["time_required"] / 10] seconds<br>"
	info += "<b>Success Chance:</b> [route_data["success_chance"]]%<br>"

	info += "<br><b>Requirements:</b><br>"
	for(var/requirement in route_data["requirements"])
		var/has_item = player.has_contraband(requirement)
		var/status = has_item ? "✓" : "✗"
		info += "[status] [requirement]<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

	// Ask if player wants to attempt escape
	var/attempt = input(src, "Do you want to attempt this escape?", "Attempt Escape") as null|anything in list("Yes", "No")
	if(attempt == "Yes")
		player.attempt_escape(route_id)

// D-Class Work Assignment Verb
/mob/living/carbon/human/verb/dclass_work_info()
	set name = "Work Info"
	set category = "D-Class"
	set desc = "View current work assignment and available jobs"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	var/info = "<h3>Work Assignment Information</h3>"

	// Current work assignment
	if(player.current_work_assignment)
		var/list/work_data = SSdclass.manager.work_assignments[player.current_work_assignment]
		info += "<b>Current Assignment:</b> [work_data["name"]]<br>"
		info += "<b>Description:</b> [work_data["description"]]<br>"
		info += "<b>Risk Level:</b> [work_data["risk"]]/5<br>"
		info += "<b>Reward:</b> [work_data["reward"]] XP<br>"

		info += "<br><b>Available Tools:</b><br>"
		for(var/tool in work_data["tools"])
			info += "- [tool]<br>"

		info += "<br><b>Access Areas:</b><br>"
		for(var/area in work_data["access"])
			info += "- [area]<br>"
	else
		info += "<b>Current Assignment:</b> None<br>"
		info += "Work assignments are distributed during scheduled times.<br>"

	// Available work assignments
	info += "<br><h4>Available Work Assignments:</h4>"
	for(var/work_id in SSdclass.manager.work_assignments)
		var/list/work_data = SSdclass.manager.work_assignments[work_id]
		var/available = player.level >= work_data["risk"]
		var/status = available ? "Available" : "Requires Level [work_data["risk"]]"
		info += "- [work_data["name"]]: [status]<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

// D-Class Contraband Management Verb
/mob/living/carbon/human/verb/dclass_contraband_manage()
	set name = "Manage Contraband"
	set category = "D-Class"
	set desc = "Manage your contraband inventory"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	var/info = "<h3>Contraband Management</h3>"

	// Current contraband
	info += "<h4>Current Contraband:</h4>"
	if(player.contraband.len > 0)
		for(var/item in player.contraband)
			info += "- [item] (x[player.contraband[item]])<br>"
	else
		info += "No contraband items.<br>"

	// Hidden items
	info += "<br><h4>Hidden Items:</h4>"
	if(player.hidden_items.len > 0)
		for(var/item in player.hidden_items)
			info += "- [item]<br>"
	else
		info += "No hidden items.<br>"

	// Crafted items
	info += "<br><h4>Crafted Items:</h4>"
	if(player.crafted_items.len > 0)
		for(var/item in player.crafted_items)
			info += "- [item]<br>"
	else
		info += "No crafted items.<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

	// Contraband actions
	var/action = input(src, "What would you like to do?", "Contraband Actions") as null|anything in list("Drop Item", "Hide Item", "Use Item", "Cancel")

	switch(action)
		if("Drop Item")
			if(player.contraband.len > 0)
				var/item_choice = input(src, "Which item to drop?", "Drop Contraband") as null|anything in player.contraband
				if(item_choice)
					player.remove_contraband(item_choice, 1)
					to_chat(src, "<span class='notice'>You dropped [item_choice].</span>")
		if("Hide Item")
			if(player.contraband.len > 0)
				var/item_choice = input(src, "Which item to hide?", "Hide Contraband") as null|anything in player.contraband
				if(item_choice)
					player.hidden_items[item_choice] = player.contraband[item_choice]
					player.remove_contraband(item_choice, 1)
					to_chat(src, "<span class='notice'>You hid [item_choice].</span>")
		if("Use Item")
			if(player.contraband.len > 0)
				var/item_choice = input(src, "Which item to use?", "Use Contraband") as null|anything in player.contraband
				if(item_choice)
					// This would trigger the item's use function
					to_chat(src, "<span class='notice'>You attempt to use [item_choice].</span>")

// D-Class Social Interaction Verb
/mob/living/carbon/human/verb/dclass_social()
	set name = "Social"
	set category = "D-Class"
	set desc = "Interact with other D-Class and form alliances"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	// Find nearby D-Class players
	var/list/nearby_dclass = list()
	for(var/mob/living/carbon/human/H in view(3, src))
		if(H.ckey && H != src)
			var/datum/dclass_player/other_player = SSdclass.manager.get_dclass_player(H.ckey)
			if(other_player)
				nearby_dclass[H.name] = other_player

	if(nearby_dclass.len == 0)
		to_chat(src, "<span class='warning'>No other D-Class players nearby.</span>")
		return

	var/info = "<h3>Social Interaction</h3>"
	info += "<h4>Nearby D-Class:</h4>"

	for(var/name in nearby_dclass)
		var/datum/dclass_player/other_player = nearby_dclass[name]
		var/relationship = "Neutral"
		if(name in player.allies)
			relationship = "Ally"
		else if(name in player.enemies)
			relationship = "Enemy"

		info += "- [name] (Level [other_player.level], [relationship])<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

	// Social actions
	var/action = input(src, "What would you like to do?", "Social Actions") as null|anything in list("Form Alliance", "Trade", "Report Player", "Cancel")

	switch(action)
		if("Form Alliance")
			if(nearby_dclass.len > 0)
				var/target_name = input(src, "Who to form alliance with?", "Form Alliance") as null|anything in nearby_dclass
				if(target_name)
					player.allies += target_name
					to_chat(src, "<span class='notice'>You formed an alliance with [target_name].</span>")
		if("Trade")
			if(nearby_dclass.len > 0 && player.contraband.len > 0)
				var/target_name = input(src, "Who to trade with?", "Trade") as null|anything in nearby_dclass
				if(target_name)
					var/datum/dclass_player/other_player = nearby_dclass[target_name]
					if(other_player.contraband.len > 0)
						var/trade_item = input(src, "What to offer?", "Trade Offer") as null|anything in player.contraband
						if(trade_item)
							to_chat(src, "<span class='notice'>You offered [trade_item] to [target_name].</span>")
		if("Report Player")
			if(nearby_dclass.len > 0)
				var/target_name = input(src, "Who to report?", "Report Player") as null|anything in nearby_dclass
				if(target_name)
					player.reported_players += target_name
					player.gain_experience(10, "reporting player")
					to_chat(src, "<span class='notice'>You reported [target_name] to security.</span>")

// D-Class Observation Verb
/mob/living/carbon/human/verb/dclass_observe()
	set name = "Observe"
	set category = "D-Class"
	set desc = "Observe your surroundings and learn patterns"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	var/info = "<h3>Observation Report</h3>"

	// Current area information
	var/area/A = get_area(src)
	info += "<b>Current Area:</b> [A.name]<br>"

	// Nearby guards
	var/list/nearby_guards = list()
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.job && findtext(H.job, "Guard"))
			nearby_guards += H

	info += "<b>Nearby Guards:</b> [nearby_guards.len]<br>"

	// Nearby D-Class
	var/list/nearby_dclass = list()
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.ckey && H != src)
			var/datum/dclass_player/other_player = SSdclass.manager.get_dclass_player(H.ckey)
			if(other_player)
				nearby_dclass += H

	info += "<b>Nearby D-Class:</b> [nearby_dclass.len]<br>"

	// Security level
	info += "<b>Security Level:</b> [SSdclass.manager.get_security_level()]/4<br>"

	// Current time slot
	info += "<b>Current Time:</b> [SSdclass.manager.current_time_slot]<br>"

	// Observation skill gain
	player.gain_experience(2, "observation")

	to_chat(src, "<span class='notice'>[info]</span>")

// D-Class Stealth Verb
/mob/living/carbon/human/verb/dclass_stealth()
	set name = "Stealth Mode"
	set category = "D-Class"
	set desc = "Enter or exit stealth mode to avoid detection"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	if(player.is_hiding)
		// Exit stealth mode
		player.is_hiding = FALSE
		to_chat(src, "<span class='notice'>You exit stealth mode.</span>")
	else
		// Enter stealth mode
		player.is_hiding = TRUE
		to_chat(src, "<span class='notice'>You enter stealth mode. Move carefully to avoid detection.</span>")
		player.gain_experience(5, "entering stealth")

// D-Class Help Verb
/mob/living/carbon/human/verb/dclass_help()
	set name = "D-Class Help"
	set category = "D-Class"
	set desc = "View help information for D-Class gameplay"

	var/info = "<h3>D-Class Escapists 2 Style Guide</h3>"

	info += "<h4>Objective:</h4>"
	info += "Your goal is to escape from D-Class containment. Work alone or with others to gather resources, learn patterns, and execute escape plans.<br><br>"

	info += "<h4>Core Systems:</h4>"
	info += "<b>Progression:</b> Gain experience through work assignments, contraband operations, and social interactions. Level up to unlock new abilities.<br>"
	info += "<b>Contraband:</b> Find and collect useful items while working. Hide them from guards and use them for escape attempts.<br>"
	info += "<b>Work Assignments:</b> Perform various jobs to gain legitimate access to tools and areas. Different jobs have different risks and rewards.<br>"
	info += "<b>Social System:</b> Form alliances with other D-Class, trade contraband, or betray others for personal gain.<br>"
	info += "<b>Escape Routes:</b> Multiple ways to escape, each requiring different items and skills.<br><br>"

	info += "<h4>Daily Routine:</h4>"
	info += "The facility follows a strict schedule. Learn the patterns to exploit security gaps:<br>"
	info += "- 06:00: Cell inspection (hide contraband)<br>"
	info += "- 07:00: Breakfast (social time)<br>"
	info += "- 08:00: Work assignments<br>"
	info += "- 12:00: Lunch break<br>"
	info += "- 13:00: Afternoon work<br>"
	info += "- 17:00: Recreation time<br>"
	info += "- 18:00: Dinner<br>"
	info += "- 19:00: Showers (privacy)<br>"
	info += "- 20:00: Lockdown<br>"
	info += "- 22:00: Lights out (high-risk escapes)<br><br>"

	info += "<h4>Tips:</h4>"
	info += "- Always hide contraband during cell inspections<br>"
	info += "- Use work assignments to gain legitimate access to tools<br>"
	info += "- Form alliances with other D-Class for coordinated escapes<br>"
	info += "- Observe guard patrol patterns and exploit blind spots<br>"
	info += "- Stealth mode reduces detection chance but slows movement<br>"
	info += "- Higher security levels make escape attempts more difficult<br>"
	info += "- Some escape routes require specific items and skill levels<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

// Register D-Class verbs when player spawns
/mob/living/carbon/human/proc/register_dclass_verbs()
	if(job == "D-Class" && ckey)
		verbs += /mob/living/carbon/human/verb/dclass_status
		verbs += /mob/living/carbon/human/verb/dclass_escape_plan
		verbs += /mob/living/carbon/human/verb/dclass_work_info
		verbs += /mob/living/carbon/human/verb/dclass_contraband_manage
		verbs += /mob/living/carbon/human/verb/dclass_social
		verbs += /mob/living/carbon/human/verb/dclass_observe
		verbs += /mob/living/carbon/human/verb/dclass_stealth
		verbs += /mob/living/carbon/human/verb/dclass_help

		// Register enhanced verbs
		register_enhanced_dclass_verbs()

		// Register with D-Class manager
		if(SSdclass && SSdclass.manager)
			SSdclass.manager.register_dclass_player(src)

// Hook into player spawn
/mob/living/carbon/human/Initialize()
	. = ..()
	spawn(10) // Small delay to ensure job is set
		register_dclass_verbs()

// Hook into player death/disconnect
/mob/living/carbon/human/Destroy()
	if(ckey && SSdclass && SSdclass.manager)
		SSdclass.manager.unregister_dclass_player(ckey)
	return ..()
