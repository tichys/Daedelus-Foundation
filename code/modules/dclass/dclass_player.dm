// D-Class Player Datum
// Handles individual D-Class player data and progression

/datum/dclass_player
	var/ckey
	var/name
	var/mob/living/carbon/human/mob

	// Progression
	var/level = 1
	var/experience = 0
	var/reputation = 0 // -100 to 100
	var/escape_attempts = 0
	var/successful_escapes = 0

	// Current Status
	var/current_work_assignment = null
	var/current_cell = null
	var/current_location = null
	var/suspicion_level = 0 // 0-100
	var/last_seen_time = 0
	var/is_hiding = FALSE

	// Inventory & Contraband
	var/list/contraband = list()
	var/list/hidden_items = list()
	var/list/crafted_items = list()
	var/list/escape_plans = list()

	// Social & Alliances
	var/list/allies = list()
	var/list/enemies = list()
	var/list/trade_history = list()
	var/list/reported_players = list()

	// Skills & Abilities
	var/list/skills = list()
	var/list/abilities = list()
	var/list/known_routes = list()
	var/list/guard_patterns = list()

	// Persistence
	var/last_save_time = 0
	var/save_interval = 300 // 5 minutes
	var/data_file_path = ""

/datum/dclass_player/New(var/player_ckey)
	ckey = player_ckey
	data_file_path = "data/dclass/[ckey].json"
	initialize_skills()
	load_data()

/datum/dclass_player/proc/initialize_skills()
	skills["stealth"] = 1
	skills["crafting"] = 1
	skills["social"] = 1
	skills["observation"] = 1
	skills["escape_planning"] = 1
	skills["contraband_handling"] = 1

/datum/dclass_player/proc/process_player()
	// Update suspicion level
	update_suspicion()

	// Check for detection
	check_detection()

	// Process current work assignment
	if(current_work_assignment)
		process_work_assignment()

	// Save data periodically
	if(world.time > last_save_time + save_interval)
		save_data()
		last_save_time = world.time

// Experience and Leveling
/datum/dclass_player/proc/gain_experience(amount, reason = "Unknown")
	experience += amount

	// Check for level up
	var/required_exp = calculate_required_experience(level)
	if(experience >= required_exp && level < 5)
		level_up()

	// Notify player
	if(mob)
		to_chat(mob, "<span class='notice'>You gained [amount] experience for [reason]. Total: [experience]/[required_exp]</span>")

/datum/dclass_player/proc/calculate_required_experience(current_level)
	switch(current_level)
		if(1) return 100
		if(2) return 300
		if(3) return 600
		if(4) return 1000
		if(5) return 999999 // Max level
		else return 100

/datum/dclass_player/proc/level_up()
	level++
	experience = 0

	// Unlock new abilities based on level
	unlock_level_abilities(level)

	// Notify player
	if(mob)
		to_chat(mob, "<span class='notice'>Congratulations! You are now Level [level] D-Class!</span>")
		to_chat(mob, "<span class='notice'>New abilities and opportunities are now available.</span>")

/datum/dclass_player/proc/unlock_level_abilities(new_level)
	switch(new_level)
		if(2)
			abilities += "basic_alliance"
			abilities += "work_tools"
		if(3)
			abilities += "advanced_crafting"
			abilities += "leadership"
		if(4)
			abilities += "restricted_access"
			abilities += "coordination"
		if(5)
			abilities += "escape_mastery"
			abilities += "teaching"

// Work Assignment System
/datum/dclass_player/proc/assign_work(work_id)
	if(!SSdclass || !SSdclass.manager)
		return

	var/list/work_data = SSdclass.manager.work_assignments[work_id]
	if(!work_data)
		return

	current_work_assignment = work_id

	if(mob)
		to_chat(mob, "<span class='notice'>You have been assigned to [work_data["name"]]: [work_data["description"]]</span>")
		to_chat(mob, "<span class='notice'>Risk Level: [work_data["risk"]], Reward: [work_data["reward"]] XP</span>")

/datum/dclass_player/proc/process_work_assignment()
	if(!current_work_assignment || !SSdclass || !SSdclass.manager)
		return

	var/list/work_data = SSdclass.manager.work_assignments[current_work_assignment]
	if(!work_data)
		return

	// Check if player is in the correct work area
	if(mob && is_in_work_area())
		// Gain experience for working
		gain_experience(work_data["reward"] / 10, "working") // Divide by 10 for continuous gain

		// Chance to find contraband
		if(prob(5)) // 5% chance per process cycle
			find_contraband_at_work()

/datum/dclass_player/proc/is_in_work_area()
	if(!mob || !current_work_assignment)
		return FALSE

	var/area/A = get_area(mob)
	if(!A)
		return FALSE

	// Check if player is in the correct work area
	switch(current_work_assignment)
		if("kitchen")
			return findtext(A.name, "kitchen") || findtext(A.name, "cafeteria")
		if("maintenance")
			return findtext(A.name, "maintenance") || findtext(A.name, "engineering")
		if("laundry")
			return findtext(A.name, "laundry") || findtext(A.name, "cleaning")
		if("medical")
			return findtext(A.name, "medical") || findtext(A.name, "clinic")

	return FALSE

/datum/dclass_player/proc/find_contraband_at_work()
	if(!current_work_assignment || !SSdclass || !SSdclass.manager)
		return

	var/list/contraband_data = SSdclass.manager.contraband_locations[current_work_assignment]
	if(!contraband_data)
		return

	// Find a random contraband item
	for(var/item in contraband_data)
		if(prob(contraband_data[item]))
			add_contraband(item)
			if(mob)
				to_chat(mob, "<span class='notice'>You found [item] while working!</span>")
			break

// Contraband System
/datum/dclass_player/proc/add_contraband(item)
	if(!(item in contraband))
		contraband[item] = 0
	contraband[item]++

	// Increase suspicion slightly
	increase_suspicion(5)

/datum/dclass_player/proc/remove_contraband(item, amount = 1)
	if(!(item in contraband))
		return FALSE

	contraband[item] -= amount
	if(contraband[item] <= 0)
		contraband -= item

	return TRUE

/datum/dclass_player/proc/has_contraband(item)
	return (item in contraband) && contraband[item] > 0

/datum/dclass_player/proc/get_contraband_count(item)
	return contraband[item] || 0

// Suspicion and Detection
/datum/dclass_player/proc/increase_suspicion(amount)
	suspicion_level = min(100, suspicion_level + amount)

	// Check for security level increase
	if(suspicion_level >= 80 && SSdclass && SSdclass.manager)
		SSdclass.manager.set_security_level(SSdclass.manager.get_security_level() + 1)

/datum/dclass_player/proc/decrease_suspicion(amount)
	suspicion_level = max(0, suspicion_level - amount)

/datum/dclass_player/proc/update_suspicion()
	// Natural suspicion decay
	if(suspicion_level > 0)
		decrease_suspicion(1) // Decay 1 point per process cycle

	// Update last seen time
	if(mob)
		last_seen_time = world.time

/datum/dclass_player/proc/check_detection()
	if(!mob)
		return

	// Check if player is being observed by guards
	var/list/nearby_guards = list()
	for(var/mob/living/carbon/human/H in view(7, mob))
		if(H.job && findtext(H.job, "Guard"))
			nearby_guards += H

	// If guards are nearby and player has contraband, risk detection
	if(nearby_guards.len > 0 && contraband.len > 0)
		var/detection_chance = suspicion_level / 10 // 0-10% based on suspicion
		if(prob(detection_chance))
			detect_contraband(pick(nearby_guards))

/datum/dclass_player/proc/detect_contraband(mob/living/carbon/human/guard)
	// Guard discovers contraband
	increase_suspicion(20)

	if(mob)
		to_chat(mob, "<span class='danger'>A guard has discovered your contraband!</span>")

	if(guard)
		to_chat(guard, "<span class='warning'>You found contraband on [mob.name]!</span>")

	// Remove some contraband
	var/items_to_remove = min(2, contraband.len)
	for(var/i = 1 to items_to_remove)
		if(contraband.len > 0)
			var/random_item = pick(contraband)
			remove_contraband(random_item, 1)

// Escape System
/datum/dclass_player/proc/attempt_escape(escape_type)
	if(!SSdclass || !SSdclass.manager)
		return FALSE

	var/list/escape_data = SSdclass.manager.escape_routes[escape_type]
	if(!escape_data)
		return FALSE

	escape_attempts++

	// Check if player meets requirements
	if(!check_escape_requirements(escape_data["requirements"]))
		if(mob)
			to_chat(mob, "<span class='warning'>You don't have the required items for this escape route.</span>")
		return FALSE

	// Calculate success chance
	var/success_chance = escape_data["success_chance"]
	success_chance += (skills["escape_planning"] - 1) * 10 // Skill bonus
	success_chance -= (SSdclass.manager.get_security_level() - 1) * 10 // Security penalty

	// Attempt escape
	if(prob(success_chance))
		successful_escape(escape_type)
		return TRUE
	else
		failed_escape(escape_type)
		return FALSE

/datum/dclass_player/proc/check_escape_requirements(list/requirements)
	for(var/requirement in requirements)
		if(!has_contraband(requirement))
			return FALSE
	return TRUE

/datum/dclass_player/proc/successful_escape(escape_type)
	successful_escapes++
	gain_experience(200, "successful escape")

	if(mob)
		to_chat(mob, "<span class='notice'>Congratulations! You have successfully escaped using the [escape_type] route!</span>")
		to_chat(mob, "<span class='notice'>You are now free!</span>")

/datum/dclass_player/proc/failed_escape(escape_type)
	increase_suspicion(30)

	if(mob)
		to_chat(mob, "<span class='danger'>Your escape attempt failed! Security has been increased.</span>")

// Notification System
/datum/dclass_player/proc/notify_spawn()
	if(mob)
		to_chat(mob, "<span class='notice'>Welcome to D-Class containment. Your goal is to escape!</span>")
		to_chat(mob, "<span class='notice'>Current Level: [level], Experience: [experience]</span>")

/datum/dclass_player/proc/notify_cell_inspection()
	if(mob)
		to_chat(mob, "<span class='warning'>Cell inspection in progress. Hide any contraband!</span>")

/datum/dclass_player/proc/notify_cafeteria_open()
	if(mob)
		to_chat(mob, "<span class='notice'>Cafeteria is now open for meal time.</span>")

/datum/dclass_player/proc/notify_work_assignment()
	if(mob)
		to_chat(mob, "<span class='notice'>Work assignments are being distributed.</span>")

/datum/dclass_player/proc/notify_recreation_open()
	if(mob)
		to_chat(mob, "<span class='notice'>Recreation areas are now open.</span>")

/datum/dclass_player/proc/notify_showers_open()
	if(mob)
		to_chat(mob, "<span class='notice'>Shower areas are now open.</span>")

/datum/dclass_player/proc/notify_lockdown()
	if(mob)
		to_chat(mob, "<span class='danger'>Lockdown procedures initiated. Security level increased.</span>")

/datum/dclass_player/proc/notify_lights_out()
	if(mob)
		to_chat(mob, "<span class='notice'>Lights out. High-risk escape attempts may be attempted.</span>")

/datum/dclass_player/proc/notify_security_level_change(new_level)
	if(mob)
		to_chat(mob, "<span class='warning'>Security level changed to [new_level]. Escape attempts are now more difficult.</span>")

// Data Persistence
/datum/dclass_player/proc/save_data()
	var/list/data = list(
		"level" = level,
		"experience" = experience,
		"reputation" = reputation,
		"escape_attempts" = escape_attempts,
		"successful_escapes" = successful_escapes,
		"suspicion_level" = suspicion_level,
		"contraband" = contraband,
		"skills" = skills,
		"abilities" = abilities,
		"allies" = allies,
		"enemies" = enemies
	)

	var/filename = data_file_path
	fdel(filename)
	text2file(json_encode(data), filename)

/datum/dclass_player/proc/load_data()
	if(!fexists(data_file_path))
		return

	var/json_data = file2text(data_file_path)
	var/list/data = json_decode(json_data)
	if(!data)
		return

	level = data["level"] || 1
	experience = data["experience"] || 0
	reputation = data["reputation"] || 0
	escape_attempts = data["escape_attempts"] || 0
	successful_escapes = data["successful_escapes"] || 0
	suspicion_level = data["suspicion_level"] || 0
	contraband = data["contraband"] || list()
	skills = data["skills"] || skills
	abilities = data["abilities"] || list()
	allies = data["allies"] || list()
	enemies = data["enemies"] || list()

// Utility Functions
/datum/dclass_player/proc/get_status_info()
	var/info = "<h3>D-Class Status Report</h3>"
	info += "<b>Name:</b> [name]<br>"
	info += "<b>Level:</b> [level]/5<br>"
	info += "<b>Experience:</b> [experience]/[calculate_required_experience(level)]<br>"
	info += "<b>Reputation:</b> [reputation]<br>"
	info += "<b>Suspicion:</b> [suspicion_level]/100<br>"
	info += "<b>Escape Attempts:</b> [escape_attempts]<br>"
	info += "<b>Successful Escapes:</b> [successful_escapes]<br>"

	if(current_work_assignment)
		info += "<b>Current Work:</b> [current_work_assignment]<br>"

	info += "<b>Contraband:</b> [contraband.len] items<br>"
	info += "<b>Skills:</b> [skills.len] skills<br>"
	info += "<b>Abilities:</b> [abilities.len] abilities<br>"

	return info

