// SCP Carbon Base Type
// A custom carbon type specifically designed for SCP entities

/mob/living/carbon/scp
	name = "SCP Entity"
	desc = "A mysterious SCP entity."
	icon = 'icons/mob/animal.dmi'
	icon_state = "scp_generic"
	real_name = "SCP Entity"
	status_flags = 0

	// SCP-specific variables
	var/datum/scp/SCP_datum = null
	var/containment_status = "contained"
	var/breach_count = 0
	var/last_breach_time = 0
	var/scp_health = 100
	var/max_scp_health = 100
	var/scp_armor = 0
	var/max_scp_armor = 50

	// SCP abilities
	var/list/scp_abilities = list()
	var/list/active_effects = list()
	var/list/passive_effects = list()

	// SCP interactions
	var/list/interaction_history = list()
	var/list/affected_targets = list()
	var/list/containment_requirements = list()

	// SCP persistence
	var/persistence_id = ""
	var/persistence_data = list()
	var/last_persistence_save = 0
	var/persistence_save_interval = 300 // 5 minutes

/mob/living/carbon/scp/Initialize()
	. = ..()

	// Initialize basic SCP properties
	scp_health = max_scp_health
	scp_armor = max_scp_armor

	// Set up persistence ID
	persistence_id = "[type]"

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances[persistence_id] = new /datum/scp_instance(persistence_id, src)

/mob/living/carbon/scp/Destroy()
	// Clean up SCP data
	scp_abilities.Cut()
	active_effects.Cut()
	passive_effects.Cut()
	interaction_history.Cut()
	affected_targets.Cut()
	containment_requirements.Cut()
	persistence_data = list()

	// Remove from persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances -= persistence_id

	return ..()

// Core SCP mechanics
/mob/living/carbon/scp/Life()
	. = ..()

	// Process SCP-specific effects
	process_scp_effects()

	// Update persistence
	update_persistence()

	// Check containment status
	check_containment()

// Process SCP-specific effects
/mob/living/carbon/scp/proc/process_scp_effects()
	// Process active effects
	for(var/effect in active_effects)
		process_effect(effect)

	// Process passive effects
	for(var/effect in passive_effects)
		process_passive_effect(effect)

// Process individual effect
/mob/living/carbon/scp/proc/process_effect(effect)
	// Override in specific SCP implementations
	return

// Process passive effect
/mob/living/carbon/scp/proc/process_passive_effect(effect)
	// Override in specific SCP implementations
	return

// Update persistence data
/mob/living/carbon/scp/proc/update_persistence()
	if(world.time < last_persistence_save + persistence_save_interval)
		return

	last_persistence_save = world.time

	// Update persistence data
	persistence_data["health"] = scp_health
	persistence_data["armor"] = scp_armor
	persistence_data["containment_status"] = containment_status
	persistence_data["breach_count"] = breach_count
	persistence_data["last_breach_time"] = last_breach_time
	persistence_data["interaction_history"] = interaction_history.Copy()
	persistence_data["affected_targets"] = affected_targets.Copy()

// Check containment status
/mob/living/carbon/scp/proc/check_containment()
	// Override in specific SCP implementations
	return

// Breach containment
/mob/living/carbon/scp/proc/breach_containment()
	if(containment_status == "breached")
		return

	containment_status = "breached"
	breach_count++
	last_breach_time = world.time

	to_chat(src, "<span class='danger'>You have breached containment!</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			instance.containment_status = "breached"
			instance.add_breach_record()

// Return to containment
/mob/living/carbon/scp/proc/return_to_containment()
	if(containment_status == "contained")
		return

	containment_status = "contained"
	to_chat(src, "<span class='notice'>You have returned to containment.</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			instance.containment_status = "contained"

// Add interaction record
/mob/living/carbon/scp/proc/add_interaction_record(target, interaction_type)
	var/record = "[time2text(world.time, "YYYY-MM-DD hh:mm:ss")]: [interaction_type] with [target ? "[target]" : "unknown"]"
	interaction_history += record

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			instance.add_interaction_record(target, interaction_type)

// Add ability
/mob/living/carbon/scp/proc/add_ability(ability_name, ability_proc)
	scp_abilities[ability_name] = ability_proc

// Remove ability
/mob/living/carbon/scp/proc/remove_ability(ability_name)
	scp_abilities -= ability_name

// Add active effect
/mob/living/carbon/scp/proc/add_active_effect(effect_name)
	if(!(effect_name in active_effects))
		active_effects += effect_name

// Remove active effect
/mob/living/carbon/scp/proc/remove_active_effect(effect_name)
	active_effects -= effect_name

// Add passive effect
/mob/living/carbon/scp/proc/add_passive_effect(effect_name)
	if(!(effect_name in passive_effects))
		passive_effects += effect_name

// Remove passive effect
/mob/living/carbon/scp/proc/remove_passive_effect(effect_name)
	passive_effects -= effect_name

// Health management
/mob/living/carbon/scp/proc/adjust_scp_health(amount)
	scp_health = max(0, min(max_scp_health, scp_health + amount))

	if(scp_health <= 0)
		scp_death()

// Armor management
/mob/living/carbon/scp/proc/adjust_scp_armor(amount)
	scp_armor = max(0, min(max_scp_armor, scp_armor + amount))

// SCP death
/mob/living/carbon/scp/proc/scp_death()
	visible_message("<span class='danger'>[src] is neutralized!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			instance.containment_status = "neutralized"

// Status display
/mob/living/carbon/scp/get_status_tab_items()
	. = ..()
	. += "SCP Health: [scp_health]/[max_scp_health]"
	. += "SCP Armor: [scp_armor]/[max_scp_armor]"
	. += "Containment Status: [containment_status]"
	. += "Breach Count: [breach_count]"
	. += "Active Effects: [active_effects.len]"
	. += "Passive Effects: [passive_effects.len]"
	. += "Abilities: [scp_abilities.len]"

// Examine behavior
/mob/living/carbon/scp/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is an SCP entity with containment status: [containment_status]</span>")
		else
			to_chat(user, "<span class='danger'>A mysterious entity that seems to defy normal physics.</span>")

// Admin verb to view SCP persistence data
/mob/living/carbon/scp/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP Persistence Data</h2>"
	message += "<b>Persistence ID:</b> [persistence_id]<br>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"
	message += "<b>Breach Count:</b> [breach_count]<br>"
	message += "<b>Last Breach Time:</b> [last_breach_time ? time2text(last_breach_time, "YYYY-MM-DD hh:mm:ss") : "Never"]<br>"
	message += "<b>Active Effects:</b> [active_effects.len]<br>"
	message += "<b>Passive Effects:</b> [passive_effects.len]<br>"
	message += "<b>Abilities:</b> [scp_abilities.len]<br>"
	message += "<b>Interaction History:</b> [interaction_history.len] records<br>"
	message += "<b>Affected Targets:</b> [affected_targets.len]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Persistence System Records:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

// Verb to toggle abilities
/mob/living/carbon/scp/verb/toggle_ability()
	set name = "Toggle Ability"
	set category = "SCP"
	set desc = "Toggle an SCP ability."

	if(!scp_abilities.len)
		to_chat(src, "<span class='warning'>No abilities available.</span>")
		return

	var/ability_name = input(src, "Choose an ability to toggle:", "Toggle Ability") as null|anything in scp_abilities
	if(ability_name)
		var/ability_proc = scp_abilities[ability_name]
		if(ability_proc)
			call(src, ability_proc)()
		else
			to_chat(src, "<span class='warning'>Ability [ability_name] is not properly configured.</span>")

// Verb to view abilities
/mob/living/carbon/scp/verb/view_abilities()
	set name = "View Abilities"
	set category = "SCP"
	set desc = "View available SCP abilities."

	var/message = "<h2>SCP Abilities</h2>"

	if(scp_abilities.len)
		for(var/ability in scp_abilities)
			message += "- [ability]<br>"
	else
		message += "<i>No abilities available.</i>"

	to_chat(src, "<span class='notice'>[message]</span>")

// Verb to view effects
/mob/living/carbon/scp/verb/view_effects()
	set name = "View Effects"
	set category = "SCP"
	set desc = "View active and passive effects."

	var/message = "<h2>SCP Effects</h2>"

	message += "<h3>Active Effects:</h3>"
	if(active_effects.len)
		for(var/effect in active_effects)
			message += "- [effect]<br>"
	else
		message += "<i>No active effects.</i>"

	message += "<h3>Passive Effects:</h3>"
	if(passive_effects.len)
		for(var/effect in passive_effects)
			message += "- [effect]<br>"
	else
		message += "<i>No passive effects.</i>"

	to_chat(src, "<span class='notice'>[message]</span>")
