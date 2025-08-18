// SCP Antagonist System
// This system allows players to play as SCPs and hostile groups of interest

// SCP Antagonist Base
/datum/antagonist/scp
	name = "SCP Entity"
	roundend_category = "SCPs"
	antagpanel_category = "SCPs"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSCP"
	var/scp_id = ""
	var/scp_class = "Safe"
	var/containment_status = "contained"
	var/breach_objectives = list()

/datum/antagonist/scp/on_gain()
	. = ..()
	if(owner.current)
		// Add SCP-specific abilities and traits
		apply_scp_effects()

/datum/antagonist/scp/on_removal()
	. = ..()
	if(owner.current)
		remove_scp_effects()

/datum/antagonist/scp/proc/apply_scp_effects()
	// Override in subtypes
	return

/datum/antagonist/scp/proc/remove_scp_effects()
	// Override in subtypes
	return

/datum/antagonist/scp/proc/set_scp_data(id, class, status)
	scp_id = id
	scp_class = class
	containment_status = status

// SCP-173 Antagonist
/datum/antagonist/scp/scp173
	name = "SCP-173"
	scp_id = "SCP-173"
	scp_class = "Euclid"
	description = "You are SCP-173, a concrete sculpture that moves when not observed. You can only move when no one is looking at you."

/datum/antagonist/scp/scp173/apply_scp_effects()
	if(owner.current)
		ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
		// Add movement restriction when observed
		RegisterSignal(owner.current, COMSIG_MOB_SAY, PROC_REF(on_speak))

/datum/antagonist/scp/scp173/remove_scp_effects()
	if(owner.current)
		REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
		UnregisterSignal(owner.current, COMSIG_MOB_SAY)

/datum/antagonist/scp/scp173/proc/on_speak(mob/living/source, list/speech_args)
	// SCP-173 cannot speak
	speech_args[SPEECH_MESSAGE] = ""
	return

// SCP-096 Antagonist
/datum/antagonist/scp/scp096
	name = "SCP-096"
	scp_id = "SCP-096"
	scp_class = "Euclid"
	description = "You are SCP-096, the Shy Guy. You become aggressive when someone sees your face."

/datum/antagonist/scp/scp096/apply_scp_effects()
	if(owner.current)
		ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
		// Add face-seeing detection
		RegisterSignal(owner.current, COMSIG_MOB_EYECONTACT, PROC_REF(on_face_seen))

/datum/antagonist/scp/scp096/remove_scp_effects()
	if(owner.current)
		REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
		UnregisterSignal(owner.current, COMSIG_MOB_EYECONTACT)

/datum/antagonist/scp/scp096/proc/on_face_seen(mob/living/source, mob/living/seer)
	// Trigger aggressive behavior when face is seen
	to_chat(owner.current, span_danger("Someone has seen your face! You must eliminate them!"))
	// Add berserk effect - would need mood system implementation

// SCP-008 Antagonist (Zombie Plague)
/datum/antagonist/scp/scp008
	name = "SCP-008 Infection"
	scp_id = "SCP-008"
	scp_class = "Keter"
	description = "You are infected with SCP-008, the zombie plague virus. Spread the infection and convert others."

/datum/antagonist/scp/scp008/apply_scp_effects()
	if(owner.current)
		ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
		// Add infection spreading ability
		RegisterSignal(owner.current, COMSIG_MOB_ATTACK_HAND, PROC_REF(on_attack))

/datum/antagonist/scp/scp008/remove_scp_effects()
	if(owner.current)
		REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
		UnregisterSignal(owner.current, COMSIG_MOB_ATTACK_HAND)


/datum/antagonist/scp/scp008/proc/on_attack(mob/living/source, mob/living/target)
	// Spread infection on attack
	if(ishuman(target))
		// Add infection logic here
		to_chat(target, span_danger("You feel sick..."))

// SCP-035 Antagonist (Possessive Mask)
/datum/antagonist/scp/scp035
	name = "SCP-035"
	scp_id = "SCP-035"
	scp_class = "Keter"
	description = "You are SCP-035, a possessive mask that secretes corrosive liquid. Manipulate and control hosts."

/datum/antagonist/scp/scp035/apply_scp_effects()
	if(owner.current)
		ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)

/datum/antagonist/scp/scp035/remove_scp_effects()
	if(owner.current)
		REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)

// SCP-049 Antagonist (Plague Doctor)
/datum/antagonist/scp/scp049
	name = "SCP-049"
	scp_id = "SCP-049"
	scp_class = "Euclid"
	description = "You are SCP-049, the Plague Doctor. You seek to cure the pestilence."

/datum/antagonist/scp/scp049/apply_scp_effects()
	if(owner.current)
		ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)

/datum/antagonist/scp/scp049/remove_scp_effects()
	if(owner.current)
		REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)

// SCP-2427-3 Antagonist (Sapient instance)
/datum/antagonist/scp/scp2427_3
	name = "SCP-2427-3"
	scp_id = "SCP-2427-3"
	scp_class = "Euclid"
	description = "You are SCP-2427-3, a sapient component of SCP-2427."

/datum/antagonist/scp/scp2427_3/apply_scp_effects()
	if(owner.current)
		ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)

/datum/antagonist/scp/scp2427_3/remove_scp_effects()
	if(owner.current)
		REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)

// Hostile Groups of Interest

// Sarkic Cult
/datum/antagonist/sarkic_cult
	name = "Sarkic Cultist"
	roundend_category = "Hostile Groups"
	antagpanel_category = "Hostile Groups"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSarkic"
	description = "You are a member of the Sarkic Cult, worshipping the flesh and seeking to spread your influence."

/datum/antagonist/sarkic_cult/on_gain()
	. = ..()
	if(owner.current)
		// Add cult abilities
		grant_cult_abilities()

/datum/antagonist/sarkic_cult/on_removal()
	. = ..()
	if(owner.current)
		remove_cult_abilities()

/datum/antagonist/sarkic_cult/proc/grant_cult_abilities()
	// Grant cult-specific abilities
	var/datum/action/innate/sarkic_ritual/ritual = new()
	ritual.Grant(owner.current)

/datum/antagonist/sarkic_cult/proc/remove_cult_abilities()
	// Remove cult abilities
	var/datum/action/innate/sarkic_ritual/ritual = locate() in owner.current.actions
	if(ritual)
		ritual.Remove(owner.current)

// Chaos Insurgency
/datum/antagonist/chaos_insurgency
	name = "Chaos Insurgency Agent"
	roundend_category = "Hostile Groups"
	antagpanel_category = "Hostile Groups"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoChaos"
	description = "You are an agent of the Chaos Insurgency, seeking to destabilize the Foundation and steal SCPs."

/datum/antagonist/chaos_insurgency/on_gain()
	. = ..()
	if(owner.current)
		// Add insurgency abilities
		grant_insurgency_abilities()

/datum/antagonist/chaos_insurgency/on_removal()
	. = ..()
	if(owner.current)
		remove_insurgency_abilities()

/datum/antagonist/chaos_insurgency/proc/grant_insurgency_abilities()
	// Grant insurgency-specific abilities
	var/datum/action/innate/insurgency_equipment/equipment = new()
	equipment.Grant(owner.current)

/datum/antagonist/chaos_insurgency/proc/remove_insurgency_abilities()
	// Remove insurgency abilities
	var/datum/action/innate/insurgency_equipment/equipment = locate() in owner.current.actions
	if(equipment)
		equipment.Remove(owner.current)

// Serpent's Hand
/datum/antagonist/serpents_hand
	name = "Serpent's Hand Member"
	roundend_category = "Hostile Groups"
	antagpanel_category = "Hostile Groups"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSerpents"
	description = "You are a member of the Serpent's Hand, seeking to free SCPs and spread knowledge of the anomalous."

/datum/antagonist/serpents_hand/on_gain()
	. = ..()
	if(owner.current)
		// Add Serpent's Hand abilities
		grant_serpents_abilities()

/datum/antagonist/serpents_hand/on_removal()
	. = ..()
	if(owner.current)
		remove_serpents_abilities()

/datum/antagonist/serpents_hand/proc/grant_serpents_abilities()
	// Grant Serpent's Hand-specific abilities
	var/datum/action/innate/serpents_knowledge/knowledge = new()
	knowledge.Grant(owner.current)

/datum/antagonist/serpents_hand/proc/remove_serpents_abilities()
	// Remove Serpent's Hand abilities
	var/datum/action/innate/serpents_knowledge/knowledge = locate() in owner.current.actions
	if(knowledge)
		knowledge.Remove(owner.current)

// Action definitions (placeholder - these would need to be implemented)
/datum/action/innate/sarkic_ritual
	name = "Perform Sarkic Ritual"
	desc = "Perform a ritual to spread your influence."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"

/datum/action/innate/sarkic_ritual/Trigger()
	// Implement ritual logic
	to_chat(owner, span_notice("You perform a Sarkic ritual."))

/datum/action/innate/insurgency_equipment
	name = "Request Equipment"
	desc = "Request Chaos Insurgency equipment."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "default"

/datum/action/innate/insurgency_equipment/Trigger()
	// Implement equipment request logic
	to_chat(owner, span_notice("You request equipment from the Insurgency."))

/datum/action/innate/serpents_knowledge
	name = "Share Knowledge"
	desc = "Share anomalous knowledge with others."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "default"

/datum/action/innate/serpents_knowledge/Trigger()
	// Implement knowledge sharing logic
	to_chat(owner, span_notice("You share knowledge of the anomalous."))
