// D-Class Enhanced Verbs
// New commands for SCP integration, dynamic events, and persistence features

// Dynamic Events Status Verb
/mob/living/carbon/human/verb/dclass_events_status()
	set name = "Events Status"
	set category = "D-Class"
	set desc = "View current dynamic events and their effects"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	var/info = "<h3>Dynamic Events Status</h3>"

	if(SSdclass.manager.event_manager && SSdclass.manager.event_manager.active_events.len > 0)
		info += "<h4>Active Events:</h4>"
		for(var/datum/dclass_event/event in SSdclass.manager.event_manager.active_events)
			var/time_remaining = (event.start_time + event.duration - world.time) / 10
			info += "<b>[event.name]:</b> [event.description]<br>"
			info += "Time Remaining: [time_remaining] seconds<br>"
			info += "Type: [event.event_type]<br>"
			info += "Escape Bonus: [event.escape_bonus]%<br>"
			info += "Contraband Bonus: [event.contraband_bonus]%<br>"
			info += "Security Impact: [event.security_impact]<br><br>"
	else
		info += "No active events.<br>"

	// Show next event prediction
	if(SSdclass.manager.event_manager)
		var/time_since_last = (world.time - SSdclass.manager.event_manager.last_event_time) / 10
		var/time_until_next = (SSdclass.manager.event_manager.event_cooldown - time_since_last) / 10
		if(time_until_next > 0)
			info += "<b>Next Event:</b> [time_until_next] seconds<br>"
		else
			info += "<b>Next Event:</b> Any moment now!<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

// SCP Integration Verb
/mob/living/carbon/human/verb/dclass_scp_interaction()
	set name = "SCP Interaction"
	set category = "D-Class"
	set desc = "Interact with SCPs and exploit their abilities"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	// Find nearby SCPs
	var/list/nearby_scps = list()
	for(var/mob/living/carbon/scp/S in view(7, src))
		if(S.stat != DEAD)
			nearby_scps += S

	var/info = "<h3>SCP Interaction</h3>"

	if(nearby_scps.len > 0)
		info += "<h4>Nearby SCPs:</h4>"
		for(var/mob/living/carbon/scp/S in nearby_scps)
			info += "<b>[S.name]:</b> [S.desc]<br>"
			info += "Status: [S.containment_status]<br>"
			info += "Distance: [get_dist(src, S)] tiles<br><br>"

		// SCP interaction options
		var/action = input(src, "What would you like to do?", "SCP Interaction") as null|anything in list("Study SCP", "Use SCP for Distraction", "Steal SCP Materials", "Cancel")

		switch(action)
			if("Study SCP")
				if(nearby_scps.len > 0)
					var/mob/living/carbon/scp/selected_scp = pick(nearby_scps)
					study_scp(player, selected_scp)
			if("Use SCP for Distraction")
				if(nearby_scps.len > 0)
					var/mob/living/carbon/scp/selected_scp = pick(nearby_scps)
					use_scp_distraction(player, selected_scp)
			if("Steal SCP Materials")
				if(nearby_scps.len > 0)
					var/mob/living/carbon/scp/selected_scp = pick(nearby_scps)
					steal_scp_materials(player, selected_scp)
	else
		info += "No SCPs nearby.<br>"
		info += "SCPs can provide unique opportunities for escape and contraband gathering.<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

// Achievement and Statistics Verb
/mob/living/carbon/human/verb/dclass_achievements()
	set name = "Achievements"
	set category = "D-Class"
	set desc = "View your achievements and statistics"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	if(!SSdclass.manager.persistence_manager)
		to_chat(src, "<span class='warning'>Persistence system not available.</span>")
		return

	var/datum/dclass_persistence_data/data = SSdclass.manager.persistence_manager.get_persistence_data(ckey)

	var/info = "<h3>Achievements & Statistics</h3>"

	// Basic Statistics
	info += "<h4>Career Statistics:</h4>"
	info += "<b>Rounds Played:</b> [data.round_count]<br>"
	info += "<b>Total Escape Attempts:</b> [data.total_escape_attempts]<br>"
	info += "<b>Successful Escapes:</b> [data.total_successful_escapes]<br>"
	info += "<b>Contraband Found:</b> [data.total_contraband_found]<br>"
	info += "<b>Work Assignments:</b> [data.total_work_completed]<br>"
	info += "<b>Alliances Formed:</b> [data.total_alliances_formed]<br>"
	info += "<b>Players Betrayed:</b> [data.total_players_betrayed]<br>"
	info += "<b>Highest Level:</b> [data.highest_level_achieved]<br>"
	info += "<b>Longest Survival:</b> [data.longest_survival_time / 600] minutes<br>"

	// Achievements
	info += "<br><h4>Achievements ([length(data.achievements)]/[length(SSdclass.manager.persistence_manager.achievements)]):</h4>"

	for(var/achievement_id in SSdclass.manager.persistence_manager.achievements)
		var/datum/dclass_achievement/achievement = SSdclass.manager.persistence_manager.achievements[achievement_id]
		var/unlocked = (achievement_id in data.achievements)
		var/status = unlocked ? "✓" : "✗"
		var/color = unlocked ? "green" : "red"
		info += "<span style='color: [color];'>[status] [achievement.name]:</span> [achievement.description]<br>"

	// SCP Integration Statistics
	if(data.statistics["scp_rounds_played"])
		info += "<br><h4>SCP Integration:</h4>"
		info += "<b>SCP Rounds Played:</b> [data.statistics["scp_rounds_played"]]<br>"
		info += "<b>SCP Achievements:</b> [data.statistics["scp_achievements"]]<br>"
		info += "<b>SCP Violations:</b> [data.statistics["scp_violations"]]<br>"
		info += "<b>SCP Access Level:</b> [data.statistics["scp_access_level"]]<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

// Leaderboard Verb
/mob/living/carbon/human/verb/dclass_leaderboard()
	set name = "Leaderboard"
	set category = "D-Class"
	set desc = "View the D-Class leaderboard"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	if(!SSdclass.manager.persistence_manager)
		to_chat(src, "<span class='warning'>Persistence system not available.</span>")
		return

	var/list/leaderboard = SSdclass.manager.persistence_manager.get_player_leaderboard()

	var/info = "<h3>D-Class Leaderboard</h3>"
	info += "<h4>Top Escape Artists:</h4>"

	var/rank = 1
	for(var/list/player_data in leaderboard)
		if(rank > 10) // Show top 10
			break

		info += "<b>[rank]. [player_data["name"]]</b><br>"
		info += "Escapes: [player_data["successful_escapes"]] | "
		info += "Level: [player_data["highest_level"]] | "
		info += "Contraband: [player_data["contraband_found"]] | "
		info += "Achievements: [player_data["achievements"]]<br><br>"

		rank++

	to_chat(src, "<span class='notice'>[info]</span>")

// Enhanced Escape Planning with Event Bonuses
/mob/living/carbon/human/verb/dclass_enhanced_escape()
	set name = "Enhanced Escape"
	set category = "D-Class"
	set desc = "Plan escape with event bonuses and SCP integration"

	if(!ckey || !SSdclass || !SSdclass.manager)
		to_chat(src, "<span class='warning'>D-Class system not available.</span>")
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(ckey)
	if(!player)
		to_chat(src, "<span class='warning'>D-Class data not found.</span>")
		return

	// Show available escape routes with enhanced information
	var/list/available_routes = list()
	for(var/route_id in SSdclass.manager.escape_routes)
		var/list/route_data = SSdclass.manager.escape_routes[route_id]
		var/route_name = route_data["name"]
		available_routes[route_name] = route_id

	// Add cancel option
	available_routes["Cancel"] = "cancel"

	var/choice = input(src, "Choose an escape route:", "Enhanced Escape Planning") as null|anything in available_routes
	if(!choice || choice == "Cancel")
		return

	var/route_id = available_routes[choice]
	var/list/route_data = SSdclass.manager.escape_routes[route_id]

	// Calculate enhanced success chance
	var/base_chance = route_data["success_chance"]
	var/skill_bonus = (player.skills["escape_planning"] - 1) * 10
	var/security_penalty = (SSdclass.manager.get_security_level() - 1) * 10
	var/event_bonus = 0

	// Apply event bonuses
	if(SSdclass.manager.event_manager)
		for(var/datum/dclass_event/event in SSdclass.manager.event_manager.active_events)
			event_bonus += event.escape_bonus

	var/final_chance = base_chance + skill_bonus - security_penalty + event_bonus
	final_chance = max(0, min(100, final_chance)) // Clamp between 0-100

	// Show enhanced route information
	var/info = "<h3>[route_data["name"]] - Enhanced Analysis</h3>"
	info += "<b>Description:</b> [route_data["description"]]<br>"
	info += "<b>Base Success Chance:</b> [base_chance]%<br>"
	info += "<b>Skill Bonus:</b> [skill_bonus]%<br>"
	info += "<b>Security Penalty:</b> -[security_penalty]%<br>"
	info += "<b>Event Bonus:</b> [event_bonus]%<br>"
	info += "<b>Final Success Chance:</b> [final_chance]%<br>"
	info += "<b>Time Required:</b> [route_data["time_required"] / 10] seconds<br>"

	info += "<br><b>Requirements:</b><br>"
	for(var/requirement in route_data["requirements"])
		var/has_item = player.has_contraband(requirement)
		var/status = has_item ? "✓" : "✗"
		var/color = has_item ? "green" : "red"
		info += "<span style='color: [color];'>[status] [requirement]</span><br>"

	// Show active events affecting this escape
	if(SSdclass.manager.event_manager && SSdclass.manager.event_manager.active_events.len > 0)
		info += "<br><b>Active Events:</b><br>"
		for(var/datum/dclass_event/event in SSdclass.manager.event_manager.active_events)
			info += "- [event.name]: [event.escape_bonus]% bonus<br>"

	to_chat(src, "<span class='notice'>[info]</span>")

	// Ask if player wants to attempt escape
	var/attempt = input(src, "Do you want to attempt this escape?", "Attempt Enhanced Escape") as null|anything in list("Yes", "No")
	if(attempt == "Yes")
		player.attempt_escape_with_events(route_id)

// SCP Interaction Helper Functions
/proc/study_scp(datum/dclass_player/player, mob/living/carbon/scp/S)
	if(!player || !player.mob || !S)
		return

	// Study SCP to gain knowledge and experience
	player.gain_experience(15, "studying SCP")

	// Add SCP knowledge to player's known patterns
	if(!("scp_patterns" in player.guard_patterns))
		player.guard_patterns["scp_patterns"] = list()
	player.guard_patterns["scp_patterns"][S.name] = world.time

	to_chat(player.mob, "<span class='notice'>You study [S.name] and learn about its behavior patterns.</span>")

	// Chance to gain special knowledge
	if(prob(20))
		player.abilities += "scp_knowledge"
		to_chat(player.mob, "<span class='notice'>You gain special knowledge about [S.name]!</span>")

/proc/use_scp_distraction(datum/dclass_player/player, mob/living/carbon/scp/S)
	if(!player || !player.mob || !S)
		return

	// Use SCP to create a distraction
	player.gain_experience(10, "using SCP distraction")

	// Notify guards of SCP activity
	for(var/mob/living/carbon/human/H in world)
		if(H.job && findtext(H.job, "Guard"))
			to_chat(H, "<span class='warning'>SCP activity detected near [S.name]! Respond immediately!</span>")

	to_chat(player.mob, "<span class='notice'>You use [S.name] to create a distraction. Guards are responding!</span>")

	// Temporarily reduce suspicion
	player.decrease_suspicion(15)

/proc/steal_scp_materials(datum/dclass_player/player, mob/living/carbon/scp/S)
	if(!player || !player.mob || !S)
		return

	// Attempt to steal materials from SCP
	var/success_chance = 30 + (player.skills["stealth"] - 1) * 10

	if(prob(success_chance))
		// Successfully steal materials
		player.gain_experience(20, "stealing SCP materials")

		// Add SCP-derived contraband
		var/scp_material = "[S.name] material"
		player.add_contraband(scp_material)

		to_chat(player.mob, "<span class='notice'>You successfully steal materials from [S.name]!</span>")
	else
		// Failed attempt
		player.increase_suspicion(25)
		to_chat(player.mob, "<span class='danger'>You fail to steal materials from [S.name] and attract attention!</span>")

// Register enhanced verbs
/mob/living/carbon/human/proc/register_enhanced_dclass_verbs()
	if(job == "D-Class" && ckey)
		verbs += /mob/living/carbon/human/verb/dclass_events_status
		verbs += /mob/living/carbon/human/verb/dclass_scp_interaction
		verbs += /mob/living/carbon/human/verb/dclass_achievements
		verbs += /mob/living/carbon/human/verb/dclass_leaderboard
		verbs += /mob/living/carbon/human/verb/dclass_enhanced_escape

// Note: register_dclass_verbs() is defined in dclass_verbs.dm and should call register_enhanced_dclass_verbs()
