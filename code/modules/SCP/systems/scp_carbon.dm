// SCP Carbon Base Type
// A custom carbon type specifically designed for SCP entities

/mob/living/scp
	name = "SCP Entity"
	desc = "A mysterious SCP entity."
	real_name = "SCP Entity"
	status_flags = 0

	// SCP-specific variables
	var/datum/scp/SCP = null
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

	// SCP rendering control
	var/use_custom_sprite = FALSE // Set to TRUE for SCPs with custom sprites

	// Enhanced Containment System
	var/list/containment_protocols = list()
	var/list/security_measures = list()
	var/containment_level = 1 // 1-5, higher = more secure
	var/containment_integrity = 100 // 0-100, lower = easier to breach
	var/containment_resistance = 0 // SCP's resistance to containment
	var/max_containment_resistance = 100
	var/containment_breach_attempts = 0
	var/last_containment_check = 0
	var/containment_check_interval = 30 SECONDS
	var/list/containment_abilities = list()
	var/list/active_containment_effects = list()

	// Skill and Leveling System
	var/list/skill_cooldowns = list() // Track cooldowns for each skill
	var/list/skill_levels = list() // Current level of each skill (0-100)
	var/list/skill_requirements = list() // Requirements for each skill level
	var/list/skill_experience = list() // Experience points for each skill
	var/last_skill_use = 0 // Global cooldown for skill usage
	var/skill_use_cooldown = 5 SECONDS // Minimum time between skill uses
	var/level_up_cooldown = 0 // Cooldown for leveling up
	var/level_up_cooldown_time = 60 SECONDS // Time between level ups
	var/max_skill_level = 100 // Maximum level for any skill
	var/skill_experience_rate = 1 // Base experience gain rate
	// Marker for one-time restoration from persistence
	var/skills_restored = FALSE

	// Modular System (Optional)
	var/list/enabled_features = list() // List of enabled features for this SCP
	var/list/feature_configs = list() // Configuration for each feature

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

	// Initialize modular features
	setup_modular_features()

	// Ensure base bodyparts are instantiated before adding organs
	ensure_bodyparts_created()

	// Ensure all essential organs exist for SCPs to function properly
	create_scp_organs()

	// Recalculate tint now that eyes exist
	update_tint()

	// Handle overlays based on sprite type
	if(use_custom_sprite)
		// For custom sprites, keep bodyparts for organ containers but suppress their overlays
		remove_overlay(BODYPARTS_LAYER)
		remove_overlay(EYE_LAYER)
		// Force overlay map to drop bodypart layers
		overlays_standing[BODYPARTS_LAYER] = null
		overlays_standing[EYE_LAYER] = null

// Override bodypart rendering for SCPs with custom sprites
/mob/living/carbon/scp/update_body_parts(update_limb_data)
	if(use_custom_sprite)
		return // Skip bodypart rendering for SCPs with custom sprites
	return ..()

/mob/living/carbon/scp/Destroy()
	// Clean up SCP data
	scp_abilities = list()
	active_effects = list()
	passive_effects = list()
	interaction_history = list()
	affected_targets = list()
	containment_requirements = list()
	persistence_data = list()

	// Remove from persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances -= persistence_id

	return ..()

// Ensure the bodyparts list contains instantiated bodypart objects (not just type paths)
/mob/living/carbon/scp/proc/ensure_bodyparts_created()
	// Always ensure instantiated bodyparts exist so organs can attach

	if(!bodyparts || !length(bodyparts))
		return

	var/first = bodyparts[1]
	if(ispath(first, /obj/item/bodypart))
		create_bodyparts()
		update_body_parts(TRUE)

// Create all essential organs for SCPs
/mob/living/carbon/scp/proc/create_scp_organs()
	// Brain - essential for consciousness
	if(!getorganslot(ORGAN_SLOT_BRAIN))
		var/obj/item/organ/brain/B = new /obj/item/organ/brain()
		B.Insert(src)

	// Eyes - essential for vision
	if(!getorganslot(ORGAN_SLOT_EYES))
		var/obj/item/organ/eyes/E = new /obj/item/organ/eyes()
		E.Insert(src)
		cure_blind(EYES_COVERED)

	// Lungs - essential for breathing
	if(!getorganslot(ORGAN_SLOT_LUNGS))
		var/obj/item/organ/lungs/L = new /obj/item/organ/lungs()
		L.Insert(src)

	// Heart - essential for blood circulation
	if(!getorganslot(ORGAN_SLOT_HEART))
		var/obj/item/organ/heart/H = new /obj/item/organ/heart()
		H.Insert(src)

	// Liver - essential for metabolism
	if(!getorganslot(ORGAN_SLOT_LIVER))
		var/obj/item/organ/liver/L = new /obj/item/organ/liver()
		L.Insert(src)

	// Stomach - essential for digestion
	if(!getorganslot(ORGAN_SLOT_STOMACH))
		var/obj/item/organ/stomach/S = new /obj/item/organ/stomach()
		S.Insert(src)

	// Tongue - essential for speech and taste
	if(!getorganslot(ORGAN_SLOT_TONGUE))
		var/obj/item/organ/tongue/T = new /obj/item/organ/tongue()
		T.Insert(src)

	// Ears - essential for hearing
	if(!getorganslot(ORGAN_SLOT_EARS))
		var/obj/item/organ/ears/E = new /obj/item/organ/ears()
		E.Insert(src)

	// Appendix - useful for immune system
	if(!getorganslot(ORGAN_SLOT_APPENDIX))
		var/obj/item/organ/appendix/A = new /obj/item/organ/appendix()
		A.Insert(src)

// Modular Feature Management Methods

// Setup modular features - override in specific SCPs
/mob/living/carbon/scp/proc/setup_modular_features()
	// Default features - override in specific SCPs to customize
	enabled_features = list(
		"skill_system" = TRUE,
		"containment_system" = TRUE,
		"persistence_system" = TRUE,
		"effect_system" = TRUE,
		"ability_system" = TRUE,
		"interaction_system" = TRUE
	)

// Process modular features
/mob/living/carbon/scp/proc/process_modular_features()
	// Override in specific SCPs to add custom feature processing
	return

// Enable a feature
/mob/living/carbon/scp/proc/enable_feature(feature_name)
	enabled_features[feature_name] = TRUE

// Disable a feature
/mob/living/carbon/scp/proc/disable_feature(feature_name)
	enabled_features[feature_name] = FALSE

// Check if a feature is enabled
/mob/living/carbon/scp/proc/is_feature_enabled(feature_name)
	return enabled_features[feature_name] || FALSE

// Configure a feature
/mob/living/carbon/scp/proc/configure_feature(feature_name, config_data)
	feature_configs[feature_name] = config_data

// Get feature configuration
/mob/living/carbon/scp/proc/get_feature_config(feature_name)
	return feature_configs[feature_name]

// Core SCP mechanics
/mob/living/carbon/scp/Life()
	. = ..()

	// Process SCP-specific effects
	process_scp_effects()

	// Update persistence
	update_persistence()

	// Check containment status
	check_containment()

	// Process modular features
	process_modular_features()

// Process SCP-specific effects
/mob/living/carbon/scp/proc/process_scp_effects()
	// Process active effects
	for(var/effect in active_effects)
		process_effect(effect)

	// Process passive effects
	for(var/effect in passive_effects)
		process_passive_effect(effect)

	// Process skill effects
	process_skill_effects()

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
	// Skills
	persistence_data["skill_levels"] = islist(skill_levels) ? skill_levels.Copy() : list()
	persistence_data["skill_experience"] = islist(skill_experience) ? skill_experience.Copy() : list()
	persistence_data["skill_cooldowns"] = islist(skill_cooldowns) ? skill_cooldowns.Copy() : list()
	persistence_data["last_skill_use"] = last_skill_use
	persistence_data["level_up_cooldown"] = level_up_cooldown

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

// Enhanced Containment System Methods

// Add containment protocol
/mob/living/carbon/scp/proc/add_containment_protocol(protocol_name, protocol_description)
	if(!(protocol_name in containment_protocols))
		containment_protocols[protocol_name] = protocol_description
		containment_integrity = min(100, containment_integrity + 10)
		to_chat(src, "<span class='notice'>Containment protocol '[protocol_name]' added. Integrity: [containment_integrity]%</span>")

// Remove containment protocol
/mob/living/carbon/scp/proc/remove_containment_protocol(protocol_name)
	if(protocol_name in containment_protocols)
		containment_protocols -= protocol_name
		containment_integrity = max(0, containment_integrity - 10)
		to_chat(src, "<span class='warning'>Containment protocol '[protocol_name]' removed. Integrity: [containment_integrity]%</span>")

// Add security measure
/mob/living/carbon/scp/proc/add_security_measure(measure_name, measure_description)
	if(!(measure_name in security_measures))
		security_measures[measure_name] = measure_description
		containment_level = min(5, containment_level + 1)
		to_chat(src, "<span class='notice'>Security measure '[measure_name]' added. Level: [containment_level]/5</span>")

// Remove security measure
/mob/living/carbon/scp/proc/remove_security_measure(measure_name)
	if(measure_name in security_measures)
		security_measures -= measure_name
		containment_level = max(1, containment_level - 1)
		to_chat(src, "<span class='warning'>Security measure '[measure_name]' removed. Level: [containment_level]/5</span>")

// Attempt to breach containment
/mob/living/carbon/scp/proc/attempt_containment_breach()
	if(containment_status == "breached")
		to_chat(src, "<span class='warning'>You are already breached!</span>")
		return FALSE

	containment_breach_attempts++
	var/breach_chance = calculate_breach_chance()

	if(prob(breach_chance))
		breach_containment()
		to_chat(src, "<span class='danger'>Containment breach successful!</span>")
		return TRUE
	else
		to_chat(src, "<span class='warning'>Containment breach failed. Chance was [breach_chance]%</span>")
		// Reduce integrity on failed attempts
		containment_integrity = max(0, containment_integrity - 5)
		return FALSE

// Calculate breach chance based on containment factors
/mob/living/carbon/scp/proc/calculate_breach_chance()
	var/base_chance = 20
	var/integrity_modifier = (100 - containment_integrity) / 10 // 0-10
	var/level_modifier = (5 - containment_level) * 5 // 0-20
	var/resistance_modifier = containment_resistance / 10 // 0-10

	var/final_chance = base_chance + integrity_modifier + level_modifier + resistance_modifier
	return min(95, max(5, final_chance))

// Enhance containment resistance
/mob/living/carbon/scp/proc/enhance_containment_resistance(amount = 10)
	containment_resistance = min(max_containment_resistance, containment_resistance + amount)
	to_chat(src, "<span class='notice'>Containment resistance enhanced to [containment_resistance]/[max_containment_resistance]</span>")

// Reduce containment integrity
/mob/living/carbon/scp/proc/reduce_containment_integrity(amount = 10)
	containment_integrity = max(0, containment_integrity - amount)
	to_chat(src, "<span class='warning'>Containment integrity reduced to [containment_integrity]%</span>")

// Restore containment integrity
/mob/living/carbon/scp/proc/restore_containment_integrity(amount = 10)
	containment_integrity = min(100, containment_integrity + amount)
	to_chat(src, "<span class='notice'>Containment integrity restored to [containment_integrity]%</span>")

// Add containment ability
/mob/living/carbon/scp/proc/add_containment_ability(ability_name, ability_proc)
	if(!(ability_name in containment_abilities))
		containment_abilities[ability_name] = ability_proc

// Remove containment ability
/mob/living/carbon/scp/proc/remove_containment_ability(ability_name)
	containment_abilities -= ability_name

// Add containment effect
/mob/living/carbon/scp/proc/add_containment_effect(effect_name)
	if(!(effect_name in active_containment_effects))
		active_containment_effects += effect_name

// Remove containment effect
/mob/living/carbon/scp/proc/remove_containment_effect(effect_name)
	active_containment_effects -= effect_name

// Process containment effects
/mob/living/carbon/scp/proc/process_containment_effects()
	for(var/effect in active_containment_effects)
		process_containment_effect(effect)

// Process individual containment effect
/mob/living/carbon/scp/proc/process_containment_effect(effect)
	// Override in specific SCP implementations
	return

// Get containment status report
/mob/living/carbon/scp/proc/get_containment_report()
	var/report = "<h3>Containment Status Report</h3>"
	report += "<b>Status:</b> [containment_status]<br>"
	report += "<b>Level:</b> [containment_level]/5<br>"
	report += "<b>Integrity:</b> [containment_integrity]%<br>"
	report += "<b>Resistance:</b> [containment_resistance]/[max_containment_resistance]<br>"
	report += "<b>Breach Attempts:</b> [containment_breach_attempts]<br>"

	if(length(containment_protocols))
		report += "<b>Active Protocols:</b><br>"
		for(var/protocol in containment_protocols)
			report += "- [protocol]: [containment_protocols[protocol]]<br>"

	if(length(security_measures))
		report += "<b>Security Measures:</b><br>"
		for(var/measure in security_measures)
			report += "- [measure]: [security_measures[measure]]<br>"

	if(length(active_containment_effects))
		report += "<b>Active Effects:</b><br>"
		for(var/effect in active_containment_effects)
			report += "- [effect]<br>"

	return report

// Override containment check to include enhanced system
/mob/living/carbon/scp/check_containment()
	if(world.time < last_containment_check + containment_check_interval)
		return

	last_containment_check = world.time

	// Process containment effects
	process_containment_effects()

	// Call specific SCP containment check
	check_specific_containment()

// Specific containment check - override in individual SCPs
/mob/living/carbon/scp/proc/check_specific_containment()
	// Override in specific SCP implementations
	return

// Setup default containment protocols and security measures
/mob/living/carbon/scp/proc/setup_default_containment()
	// Default containment protocols
	add_containment_protocol("Standard Containment", "Basic containment procedures for SCP entities")
	add_containment_protocol("Personnel Monitoring", "Regular monitoring of personnel interacting with the SCP")

	// Default security measures
	add_security_measure("Access Control", "Restricted access to SCP containment area")
	add_security_measure("Surveillance", "24/7 monitoring of SCP containment area")

	// Set default containment level based on SCP class
	if(SCP)
		switch(SCP.classification)
			if(SCP_SAFE)
				containment_level = 2
				containment_integrity = 80
			if(SCP_EUCLID)
				containment_level = 3
				containment_integrity = 70
			if(SCP_KETER)
				containment_level = 4
				containment_integrity = 60
			if(SCP_THAUMIEL)
				containment_level = 5
				containment_integrity = 90
			if(SCP_NEUTRALIZED)
				containment_level = 1
				containment_integrity = 100
	else
		// Fallback if SCP is not set
		containment_level = 3
		containment_integrity = 70

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
	. += "Containment: [containment_status]"
	. += "Containment Level: [containment_level]/5"
	. += "Containment Integrity: [containment_integrity]%"
	. += "Containment Resistance: [containment_resistance]/[max_containment_resistance]"
	. += "Breach Attempts: [containment_breach_attempts]"
	. += "Breach Count: [breach_count]"
	. += "Active Effects: [length(active_effects)]"
	. += "Skills: [length(skill_levels)]"
	. += "Level Up Cooldown: [max(0, (level_up_cooldown - world.time) / 10)]s"
	. += "Passive Effects: [length(passive_effects)]"
	. += "Abilities: [length(scp_abilities)]"
	
	// Add modular feature status
	. += "Features: [length(enabled_features)] enabled"
	for(var/feature_name in enabled_features)
		if(enabled_features[feature_name])
			. += "Feature: [feature_name] - Enabled"

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
/mob/living/carbon/scp/proc/view_persistence_data()

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
	message += "<b>Active Effects:</b> [length(active_effects)]<br>"
	message += "<b>Passive Effects:</b> [length(passive_effects)]<br>"
	message += "<b>Abilities:</b> [length(scp_abilities)]<br>"
	message += "<b>Interaction History:</b> [length(interaction_history)] records<br>"
	message += "<b>Affected Targets:</b> [length(affected_targets)]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Persistence System Records:</b> [length(instance.interaction_history)] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

// Verb to toggle abilities
/mob/living/carbon/scp/verb/toggle_ability()
	set name = "Toggle Ability"
	set category = "SCP"
	set desc = "Toggle an SCP ability."

	if(!length(scp_abilities))
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

	if(length(scp_abilities))
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
	if(length(active_effects))
		for(var/effect in active_effects)
			message += "- [effect]<br>"
	else
		message += "<i>No active effects.</i>"

	message += "<h3>Passive Effects:</h3>"
	if(length(passive_effects))
		for(var/effect in passive_effects)
			message += "- [effect]<br>"
	else
		message += "<i>No passive effects.</i>"

	to_chat(src, "<span class='notice'>[message]</span>")



// Skill and Leveling System Methods

// Initialize a skill with cooldown and requirements
/mob/living/carbon/scp/proc/initialize_skill(skill_name, base_cooldown = 30 SECONDS, base_requirements = list())
	if(!(skill_name in skill_levels))
		skill_levels[skill_name] = 0
		skill_experience[skill_name] = 0
		skill_cooldowns[skill_name] = 0
		skill_requirements[skill_name] = base_requirements
		to_chat(src, "<span class='notice'>Skill '[skill_name]' initialized. Level: 0/100</span>")

// Check if a skill can be used (cooldown and requirements)
/mob/living/carbon/scp/proc/can_use_skill(skill_name)
	// Check global cooldown
	if(world.time < last_skill_use + skill_use_cooldown)
		to_chat(src, "<span class='warning'>You must wait before using another skill.</span>")
		return FALSE

	// Check skill-specific cooldown
	if(world.time < skill_cooldowns[skill_name])
		var/remaining = (skill_cooldowns[skill_name] - world.time) / 10
		to_chat(src, "<span class='warning'>[skill_name] is on cooldown for [remaining] seconds.</span>")
		return FALSE

	// Check skill level requirements
	var/current_level = skill_levels[skill_name] || 0
	var/requirements = skill_requirements[skill_name] || list()

	for(var/requirement in requirements)
		if(!check_skill_requirement(requirement, current_level))
			to_chat(src, "<span class='warning'>You need to meet the requirements for [skill_name].</span>")
			return FALSE

	return TRUE

// Check if a skill requirement is met
/mob/living/carbon/scp/proc/check_skill_requirement(requirement, current_level)
	// Override in specific SCP implementations for custom requirements
	return TRUE

// Use a skill with cooldown and experience gain
/mob/living/carbon/scp/proc/use_skill(skill_name, experience_gain = 1, cooldown_multiplier = 1.0)
	if(!can_use_skill(skill_name))
		return FALSE

	// Set cooldowns
	last_skill_use = world.time
	var/base_cooldown = 30 SECONDS
	if(skill_requirements[skill_name] && skill_requirements[skill_name]["base_cooldown"])
		base_cooldown = skill_requirements[skill_name]["base_cooldown"]

	skill_cooldowns[skill_name] = world.time + (base_cooldown * cooldown_multiplier)

	// Gain experience
	gain_skill_experience(skill_name, experience_gain)

	to_chat(src, "<span class='notice'>Used [skill_name]. Cooldown: [base_cooldown * cooldown_multiplier / 10] seconds</span>")
	return TRUE

// Gain experience for a skill
/mob/living/carbon/scp/proc/gain_skill_experience(skill_name, amount)
	if(!(skill_name in skill_experience))
		skill_experience[skill_name] = 0

	skill_experience[skill_name] += amount * skill_experience_rate

	// Check for level up
	check_skill_level_up(skill_name)

// Check if a skill can level up
/mob/living/carbon/scp/proc/check_skill_level_up(skill_name)
	if(world.time < level_up_cooldown)
		return

	var/current_level = skill_levels[skill_name] || 0
	var/current_exp = skill_experience[skill_name] || 0
	var/required_exp = calculate_required_experience(current_level)

	if(current_exp >= required_exp && current_level < max_skill_level)
		level_up_skill(skill_name)

// Calculate required experience for next level
/mob/living/carbon/scp/proc/calculate_required_experience(current_level)
	// Exponential growth: each level requires more experience
	return (current_level + 1) * 10 + (current_level * current_level)

// Level up a skill with stringent requirements
/mob/living/carbon/scp/proc/level_up_skill(skill_name)
	var/current_level = skill_levels[skill_name] || 0
	var/requirements = skill_requirements[skill_name] || list()

	// Check stringent requirements
	if(!check_level_up_requirements(skill_name, current_level + 1, requirements))
		to_chat(src, "<span class='warning'>You don't meet the requirements to level up [skill_name].</span>")
		return FALSE

	// Set level up cooldown
	level_up_cooldown = world.time + level_up_cooldown_time

	// Level up
	skill_levels[skill_name] = current_level + 1
	skill_experience[skill_name] = 0 // Reset experience

	// Apply level up effects
	apply_skill_level_effects(skill_name, current_level + 1)

	to_chat(src, "<span class='notice'>[skill_name] leveled up to [current_level + 1]/100!</span>")
	return TRUE

// Check stringent requirements for leveling up
/mob/living/carbon/scp/proc/check_level_up_requirements(skill_name, new_level, requirements)
	// Base requirements that apply to all skills
	if(new_level > 50 && containment_status != "breached")
		to_chat(src, "<span class='warning'>You must breach containment to level up beyond 50.</span>")
		return FALSE

	if(new_level > 75 && breach_count < 3)
		to_chat(src, "<span class='warning'>You must have breached containment at least 3 times to level up beyond 75.</span>")
		return FALSE

	if(new_level > 90 && containment_integrity > 20)
		to_chat(src, "<span class='warning'>You must have very low containment integrity to level up beyond 90.</span>")
		return FALSE

	// Check skill-specific requirements
	for(var/requirement in requirements)
		if(!check_skill_requirement(requirement, new_level))
			return FALSE

	return TRUE

// Apply effects when a skill levels up
/mob/living/carbon/scp/proc/apply_skill_level_effects(skill_name, new_level)
	// Override in specific SCP implementations
	return

// Get skill information
/mob/living/carbon/scp/proc/get_skill_info(skill_name)
	var/current_level = skill_levels[skill_name] || 0
	var/current_exp = skill_experience[skill_name] || 0
	var/required_exp = calculate_required_experience(current_level)
	var/cooldown_remaining = max(0, (skill_cooldowns[skill_name] - world.time) / 10)

	var/info = "<b>[skill_name]</b><br>"
	info += "Level: [current_level]/[max_skill_level]<br>"
	info += "Experience: [current_exp]/[required_exp]<br>"
	info += "Cooldown: [cooldown_remaining] seconds<br>"

	if(skill_requirements[skill_name])
		info += "Requirements: [length(skill_requirements[skill_name])] active<br>"

	return info

// Get all skill information
/mob/living/carbon/scp/proc/get_all_skills_info()
	var/info = "<h3>Skill Information</h3>"

	for(var/skill in skill_levels)
		info += get_skill_info(skill) + "<br>"

	return info

// Reset all skill cooldowns (admin function)
/mob/living/carbon/scp/proc/reset_skill_cooldowns()
	for(var/skill in skill_cooldowns)
		skill_cooldowns[skill] = 0
	last_skill_use = 0
	level_up_cooldown = 0
	to_chat(src, "<span class='notice'>All skill cooldowns reset.</span>")

// Process skill cooldowns and effects
/mob/living/carbon/scp/proc/process_skill_effects()
	// Process skill-specific effects
	for(var/skill in skill_levels)
		process_skill_effect(skill)

// Process individual skill effects
/mob/living/carbon/scp/proc/process_skill_effect(skill_name)
	// Override in specific SCP implementations
	return

// Skill-related verbs for all SCPs

/mob/living/carbon/scp/verb/view_scp_skills()
	set name = "View SCP Skills"
	set category = "SCP"
	set desc = "View detailed skill information."

	to_chat(src, "<span class='notice'>[get_all_skills_info()]</span>")

/mob/living/carbon/scp/verb/reset_cooldowns()
	set name = "Reset Cooldowns"
	set category = "SCP"
	set desc = "Reset all skill cooldowns (Admin only)."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to reset cooldowns.</span>")
		return

	reset_skill_cooldowns()

/mob/living/carbon/scp/verb/check_skill_requirements()
	set name = "Check Requirements"
	set category = "SCP"
	set desc = "Check requirements for all skills."

	var/info = "<h3>Skill Requirements</h3>"
	for(var/skill in skill_levels)
		var/current_level = skill_levels[skill] || 0
		var/requirements = skill_requirements[skill] || list()

		info += "<b>[skill] (Level [current_level])</b><br>"
		if(length(requirements))
			for(var/req in requirements)
				info += "- [req]<br>"
		else
			info += "- No specific requirements<br>"

		// Show level up requirements
		if(current_level < max_skill_level)
			info += "Level [current_level + 1] Requirements:<br>"
			if(current_level + 1 > 50 && containment_status != "breached")
				info += "- Must breach containment<br>"
			if(current_level + 1 > 75 && breach_count < 3)
				info += "- Must breach containment 3+ times<br>"
			if(current_level + 1 > 90 && containment_integrity > 20)
				info += "- Must have very low containment integrity<br>"

		info += "<br>"

	to_chat(src, "<span class='notice'>[info]</span>")
