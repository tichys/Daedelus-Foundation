// Roleplay Character Sheet TGUI Backend
// Handles the TGUI interface for character sheet management

/datum/roleplay_character_ui
	var/mob/user
	var/datum/roleplay_character_sheet/character

/datum/roleplay_character_ui/New(mob/user)
	src.user = user
	load_character()

/datum/roleplay_character_ui/proc/load_character()
	if(!user || !user.ckey)
		return

	if(SSroleplay_character && SSroleplay_character.manager)
		character = SSroleplay_character.manager.get_character(user.ckey)

		// Create character if it doesn't exist
		if(!character)
			var/character_type = determine_character_type()
			var/character_name = user.real_name || user.name
			character = SSroleplay_character.manager.create_character(user.ckey, character_name, character_type)

/datum/roleplay_character_ui/proc/determine_character_type()
	if(!user)
		return "foundation"

	// Determine character type based on job or role
	if(user.mind && user.mind.assigned_role)
		var/job_title = user.mind.assigned_role.title
		if(findtext(job_title, "SCP") || user.SCP)
			return "scp"
		else if(findtext(job_title, "D-Class") || findtext(job_title, "Prisoner"))
			return "dclass"
		else if(findtext(job_title, "Visitor") || findtext(job_title, "Guest"))
			return "visitor"
		else
			return "foundation"

	return "foundation"

/datum/roleplay_character_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoleplayCharacterSheet")
		ui.open()

/datum/roleplay_character_ui/ui_data(mob/user)
	var/list/data = list()

	if(!character)
		load_character()

	if(character)
		data["character"] = list(
			"character_name" = character.character_name,
			"character_type" = character.character_type,
			"character_background" = character.character_background,
			"character_creation_date" = character.character_creation_date,
			"character_last_updated" = character.character_last_updated,
			"character_goals" = character.character_goals,
			"personality" = list(
				"traits" = character.personality?.traits || list(),
				"quirks" = character.personality?.quirks || list(),
				"fears" = character.personality?.fears || list(),
				"aspirations" = character.personality?.aspirations || list()
			),
			"appearance" = list(
				"face_details" = character.appearance?.face_details || list(),
				"body_details" = character.appearance?.body_details || list(),
				"clothing_preferences" = character.appearance?.clothing_preferences || list(),
				"unique_features" = character.appearance?.unique_features || list(),
				"character_style" = character.appearance?.character_style || ""
			),
			"growth" = list(
				"character_level" = character.growth?.character_level || 1,
				"roleplay_experience_points" = character.growth?.roleplay_experience_points || 0,
				"growth_milestones" = character.growth?.growth_milestones || list()
			)
		)

	// Personality traits
	if(SSroleplay_character && SSroleplay_character.manager)
		data["personality_traits"] = SSroleplay_character.manager.personality_traits
		data["character_goals"] = SSroleplay_character.manager.character_goals
		data["achievements"] = SSroleplay_character.manager.character_achievements

	// Relationships
	data["relationships"] = get_character_relationships()

	// Editable status
	data["editable"] = can_edit_character(user)

	return data

/datum/roleplay_character_ui/proc/get_character_relationships()
	var/list/relationships = list()

	if(!character || !SSroleplay_character || !SSroleplay_character.manager)
		return relationships

	// Get relationships for this character
	for(var/relationship_id in SSroleplay_character.manager.character_relationships)
		var/relationship = SSroleplay_character.manager.character_relationships[relationship_id]
		if(relationship["character1"] == character.ckey || relationship["character2"] == character.ckey)
			var/other_character = relationship["character1"] == character.ckey ? relationship["character2"] : relationship["character1"]
			relationships += list(list(
				"other_character" = other_character,
				"type" = relationship["type"],
				"strength" = relationship["strength"],
				"trust" = relationship["trust"]
			))

	return relationships

/datum/roleplay_character_ui/proc/can_edit_character(mob/user)
	if(!user || !character)
		return FALSE

	// Only the character owner can edit
	return user.ckey == character.ckey

/datum/roleplay_character_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!character || !can_edit_character(usr))
		return

	switch(action)
		if("update_character")
			var/field = params["field"]
			var/value = params["value"]

			if(field && value != null)
				character.vars[field] = value
				character.character_last_updated = world.time
				. = TRUE

		if("toggle_trait")
			var/trait = params["trait"]
			if(trait)
				if(!character.personality)
					character.personality = new /datum/roleplay_personality()

				if(character.personality.traits[trait])
					character.personality.traits -= trait
				else
					character.personality.traits[trait] = 1

				character.character_last_updated = world.time
				. = TRUE

		if("update_quirks")
			var/list/quirks = params["quirks"]
			if(quirks)
				if(!character.personality)
					character.personality = new /datum/roleplay_personality()

				character.personality.quirks = quirks
				character.character_last_updated = world.time
				. = TRUE

		if("update_face_details")
			var/list/details = params["details"]
			if(details)
				if(!character.appearance)
					character.appearance = new /datum/roleplay_appearance()

				character.appearance.face_details = details
				character.character_last_updated = world.time
				. = TRUE

		if("update_body_details")
			var/list/details = params["details"]
			if(details)
				if(!character.appearance)
					character.appearance = new /datum/roleplay_appearance()

				character.appearance.body_details = details
				character.character_last_updated = world.time
				. = TRUE

		if("update_clothing_preferences")
			var/list/preferences = params["preferences"]
			if(preferences)
				if(!character.appearance)
					character.appearance = new /datum/roleplay_appearance()

				character.appearance.clothing_preferences = preferences
				character.character_last_updated = world.time
				. = TRUE

		if("update_unique_features")
			var/list/features = params["features"]
			if(features)
				if(!character.appearance)
					character.appearance = new /datum/roleplay_appearance()

				character.appearance.unique_features = features
				character.character_last_updated = world.time
				. = TRUE

		if("update_character_style")
			var/style = params["style"]
			if(style != null)
				if(!character.appearance)
					character.appearance = new /datum/roleplay_appearance()

				character.appearance.character_style = style
				character.character_last_updated = world.time
				. = TRUE

		if("save_character")
			// Character is automatically saved when updated
			to_chat(usr, "<span class='notice'>Character saved successfully!</span>")
			. = TRUE

// Verb to open character sheet
/mob/verb/open_character_sheet()
	set name = "Open Character Sheet"
	set category = "Roleplay"
	set desc = "Open your roleplay character sheet"

	var/datum/roleplay_character_ui/ui = new /datum/roleplay_character_ui(src)
	ui.ui_interact(src)

// Admin verb to view any character sheet
/mob/proc/view_character_sheet(ckey)
	set name = "View Character Sheet"
	set category = "Admin"
	set desc = "View a player's character sheet"

	if(!check_rights(R_ADMIN))
		return

	if(!ckey)
		ckey = input("Enter player ckey:", "View Character Sheet") as text|null

	if(!ckey)
		return

	var/datum/roleplay_character_sheet/character = null
	if(SSroleplay_character && SSroleplay_character.manager)
		character = SSroleplay_character.manager.get_character(ckey)

	if(!character)
		to_chat(src, "<span class='warning'>No character found for [ckey].</span>")
		return

	// Create a temporary UI for viewing
	var/datum/roleplay_character_ui/ui = new /datum/roleplay_character_ui(src)
	ui.character = character
	ui.ui_interact(src)

// Integration with existing systems
/datum/roleplay_character_ui/proc/integrate_with_existing_systems()
	if(!character || !character.linked_mind)
		return

	var/datum/mind/mind = character.linked_mind

	// Integrate with skill system
	if(mind.known_skills && character.skills)
		character.skills.update_skills_from_mind(mind)

	// Integrate with personnel system
	if(character.linked_personnel_record)
		// Sync character data with personnel record
		character.linked_personnel_record.real_name = character.character_name

	// Award experience for roleplay activities
	award_roleplay_experience()

/datum/roleplay_character_ui/proc/award_roleplay_experience()
	if(!character || !character.growth)
		return

	// Award experience for various roleplay activities
	var/experience_gained = 0

	// Experience for character depth
	if(character.character_background && length(character.character_background) > 100)
		experience_gained += 10

	// Experience for personality traits
	if(character.personality && character.personality.traits)
		experience_gained += length(character.personality.traits) * 5

	// Experience for relationships
	if(character.character_relationships)
		experience_gained += length(character.character_relationships) * 15

	// Experience for achievements
	if(character.character_achievements)
		experience_gained += length(character.character_achievements) * 25

	if(experience_gained > 0)
		character.growth.add_experience(experience_gained, "Character Development")
		to_chat(usr, "<span class='notice'>Gained [experience_gained] roleplay experience for character development!</span>")

// Hook into existing systems
/datum/roleplay_character_ui/proc/setup_integration_hooks()
	// Hook into mind system for skill updates
	// if(character && character.linked_mind)
	// 	RegisterSignal(character.linked_mind, COMSIG_MIND_SKILL_UPDATED, PROC_REF(on_skill_updated))
	// 	Signal will be implemented when mind system signals are available

	// Hook into personnel system for record updates
	// if(character && character.linked_personnel_record)
	// 	RegisterSignal(character.linked_personnel_record, COMSIG_PERSONNEL_RECORD_UPDATED, PROC_REF(on_personnel_updated))
	// 	Signal will be implemented when personnel system signals are available

/datum/roleplay_character_ui/proc/on_skill_updated(datum/mind/mind, skill_type, new_level)
	if(character && character.skills)
		character.skills.update_skills_from_mind(mind)
		character.character_last_updated = world.time

/datum/roleplay_character_ui/proc/on_personnel_updated(datum/personnel_record/record)
	if(character)
		character.character_name = record.real_name
		character.character_last_updated = world.time
