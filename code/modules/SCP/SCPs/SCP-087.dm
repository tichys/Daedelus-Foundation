// SCP-087 - The Stairwell
// An endless stairwell that induces psychological horror and contains a mysterious entity

/obj/structure/scp087
	name = "SCP-087"
	desc = "A seemingly endless stairwell that descends into darkness. The air feels heavy with dread."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "stairs"
	density = FALSE
	anchored = TRUE

	// SCP-087 variables
	var/descent_level = 0
	var/max_descent_level = 100
	var/psychological_horror = 0
	var/max_psychological_horror = 50
	var/entity_encounters = 0
	var/max_entity_encounters = 25
	var/darkness_level = 1
	var/max_darkness_level = 5
	var/descent_intensity = 0
	var/max_descent_intensity = 50
	var/horror_intensity = 0
	var/max_horror_intensity = 50
	var/entity_presence = 0
	var/max_entity_presence = 25
	var/descent_cooldown = 0
	var/descent_cooldown_time = 30 SECONDS
	var/horror_cooldown = 0
	var/horror_cooldown_time = 20 SECONDS
	var/entity_cooldown = 0
	var/entity_cooldown_time = 45 SECONDS

	// Persistence tracking
	var/descents_performed = 0
	var/horror_events = 0
	var/entity_events = 0
	var/darkness_events = 0
	var/descent_intensities = 0
	var/horror_intensities = 0
	var/entity_presences = 0

/obj/structure/scp087/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-087",
		SCP_EUCLID,
		"087",

	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-087"] = new /datum/scp_instance("SCP-087", src)

/obj/structure/scp087/Destroy()
	return ..()

// Core mechanics
/obj/structure/scp087/process()
	. = ..()

	// Process descent effects
	process_descent_effects()

	// Process psychological horror
	process_psychological_horror()

	// Process entity encounters
	process_entity_encounters()

	// Process descent intensity
	process_descent_intensity()

// Process descent effects
/obj/structure/scp087/proc/process_descent_effects()
	if(descent_level > 0 && prob(1))
		descent_level = min(max_descent_level, descent_level + 1)

// Process psychological horror
/obj/structure/scp087/proc/process_psychological_horror()
	if(psychological_horror > 0 && prob(2))
		// Affect nearby humans with psychological horror
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>You feel an overwhelming sense of dread and despair...</span>")
				H.adjustBruteLoss(5)
				horror_events++

// Process entity encounters
/obj/structure/scp087/proc/process_entity_encounters()
	if(entity_encounters > 0 && prob(1))
		// Create entity encounter effects
		for(var/mob/living/carbon/human/H in range(3, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>You hear something moving in the darkness below...</span>")
				entity_events++

// Process descent intensity
/obj/structure/scp087/proc/process_descent_intensity()
	if(descent_intensity > 0 && prob(1))
		// Increase descent effects
		for(var/mob/living/carbon/human/H in range(3, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>The stairwell seems to descend deeper into darkness...</span>")
				descent_intensities++

// SCP-087 abilities
/obj/structure/scp087/proc/descent_intensity_ability()
	if(descent_intensity >= max_descent_intensity)
		to_chat(usr, "<span class='warning'>SCP-087 has reached maximum descent intensity.</span>")
		return

	descent_intensity = min(max_descent_intensity, descent_intensity + 10)
	descent_intensities++

	to_chat(usr, "<span class='notice'>SCP-087's descent intensity increases. Intensity: [descent_intensity]/[max_descent_intensity]</span>")

/obj/structure/scp087/proc/horror_intensity_ability()
	if(world.time < horror_cooldown)
		to_chat(usr, "<span class='warning'>SCP-087 needs time to increase horror intensity again.</span>")
		return

	horror_cooldown = world.time + horror_cooldown_time
	horror_intensity = min(max_horror_intensity, horror_intensity + 10)
	horror_intensities++

	to_chat(usr, "<span class='notice'>SCP-087's horror intensity increases. Intensity: [horror_intensity]/[max_horror_intensity]</span>")

/obj/structure/scp087/proc/entity_presence_ability()
	if(world.time < entity_cooldown)
		to_chat(usr, "<span class='warning'>SCP-087 needs time to manifest entity presence again.</span>")
		return

	entity_cooldown = world.time + entity_cooldown_time
	entity_presence = min(max_entity_presence, entity_presence + 5)
	entity_presences++

	to_chat(usr, "<span class='notice'>SCP-087 manifests entity presence. Presence: [entity_presence]/[max_entity_presence]</span>")

/obj/structure/scp087/proc/darkness_enhancement_ability()
	if(darkness_level >= max_darkness_level)
		to_chat(usr, "<span class='warning'>SCP-087 has reached maximum darkness level.</span>")
		return

	darkness_level = min(max_darkness_level, darkness_level + 1)
	darkness_events++

	to_chat(usr, "<span class='notice'>SCP-087's darkness increases. Darkness: [darkness_level]/[max_darkness_level]</span>")

/obj/structure/scp087/proc/psychological_horror_ability()
	psychological_horror = min(max_psychological_horror, psychological_horror + 10)
	horror_events++

	to_chat(usr, "<span class='notice'>SCP-087 creates psychological horror. Horror: [psychological_horror]/[max_psychological_horror]</span>")

/obj/structure/scp087/proc/entity_encounter_ability()
	entity_encounters = min(max_entity_encounters, entity_encounters + 3)
	entity_events++

	to_chat(usr, "<span class='notice'>SCP-087 creates entity encounters. Encounters: [entity_encounters]/[max_entity_encounters]</span>")

/obj/structure/scp087/proc/deep_descent_ability()
	if(descent_level < max_descent_level)
		to_chat(usr, "<span class='warning'>SCP-087 needs more descent levels for deep descent.</span>")
		return

	// Deep descent affects nearby targets
	for(var/mob/living/carbon/human/H in range(6, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='danger'>You feel yourself descending deeper into the stairwell...</span>")
			H.adjustBruteLoss(25)

	to_chat(usr, "<span class='notice'>SCP-087 creates a deep descent effect on nearby targets.</span>")

// Status display
/obj/structure/scp087/proc/get_descent_status()
	var/message = "<h2>SCP-087 Status</h2>"
	message += "<b>Descent Level:</b> [descent_level]/[max_descent_level]<br>"
	message += "<b>Psychological Horror:</b> [psychological_horror]/[max_psychological_horror]<br>"
	message += "<b>Entity Encounters:</b> [entity_encounters]/[max_entity_encounters]<br>"
	message += "<b>Darkness Level:</b> [darkness_level]/[max_darkness_level]<br>"
	message += "<b>Descent Intensity:</b> [descent_intensity]/[max_descent_intensity]<br>"
	message += "<b>Horror Intensity:</b> [horror_intensity]/[max_horror_intensity]<br>"
	message += "<b>Entity Presence:</b> [entity_presence]/[max_entity_presence]<br>"

	return message

// SCP-087 verbs
/obj/structure/scp087/verb/descent_intensity()
	set name = "Descent Intensity"
	set category = "SCP-087"
	set desc = "Increase SCP-087's descent intensity."

	descent_intensity_ability()

/obj/structure/scp087/verb/horror_intensity()
	set name = "Horror Intensity"
	set category = "SCP-087"
	set desc = "Increase SCP-087's horror intensity."

	horror_intensity_ability()

/obj/structure/scp087/verb/entity_presence()
	set name = "Entity Presence"
	set category = "SCP-087"
	set desc = "Manifest entity presence in SCP-087."

	entity_presence_ability()

/obj/structure/scp087/verb/darkness_enhancement()
	set name = "Darkness Enhancement"
	set category = "SCP-087"
	set desc = "Increase SCP-087's darkness level."

	darkness_enhancement_ability()

/obj/structure/scp087/verb/psychological_horror()
	set name = "Psychological Horror"
	set category = "SCP-087"
	set desc = "Create psychological horror effects."

	psychological_horror_ability()

/obj/structure/scp087/verb/entity_encounter()
	set name = "Entity Encounter"
	set category = "SCP-087"
	set desc = "Create entity encounters."

	entity_encounter_ability()

/obj/structure/scp087/verb/deep_descent()
	set name = "Deep Descent"
	set category = "SCP-087"
	set desc = "Create a deep descent effect on nearby targets."

	deep_descent_ability()

/obj/structure/scp087/verb/check_descent_level()
	set name = "Check Descent Level"
	set category = "SCP-087"
	set desc = "Check your current descent level in SCP-087."

	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>Only humans can check descent levels.</span>")
		return

	var/mob/living/carbon/human/H = usr
	if(H.SCP)
		to_chat(usr, "<span class='warning'>SCPs cannot check descent levels.</span>")
		return

	to_chat(usr, "<span class='notice'>Current Descent Level: [descent_level]/[max_descent_level]</span>")

	if(descent_level > 0)
		to_chat(usr, "<span class='notice'>You are currently [descent_level] levels deep in SCP-087.</span>")
	else
		to_chat(usr, "<span class='notice'>You are at the surface level of SCP-087.</span>")

/obj/structure/scp087/verb/descend_stairwell()
	set name = "Descend Stairwell"
	set category = "SCP-087"
	set desc = "Descend deeper into SCP-087."

	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>Only humans can descend into SCP-087.</span>")
		return

	var/mob/living/carbon/human/H = usr
	if(H.SCP)
		to_chat(usr, "<span class='warning'>SCPs cannot descend into SCP-087.</span>")
		return

	descend_into_stairwell(H)

/obj/structure/scp087/verb/climb_back_up()
	set name = "Climb Back Up"
	set category = "SCP-087"
	set desc = "Climb back up from SCP-087."

	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>Only humans can return from SCP-087.</span>")
		return

	var/mob/living/carbon/human/H = usr
	if(H.SCP)
		to_chat(usr, "<span class='warning'>SCPs cannot return from SCP-087.</span>")
		return

	return_from_stairwell(H)

// Admin verb to view SCP-087 persistence data
/obj/structure/scp087/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP-087"
	set desc = "View SCP-087 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-087 Persistence Data</h2>"
	message += "<b>Descents Performed:</b> [descents_performed]<br>"
	message += "<b>Horror Events:</b> [horror_events]<br>"
	message += "<b>Entity Events:</b> [entity_events]<br>"
	message += "<b>Darkness Events:</b> [darkness_events]<br>"
	message += "<b>Descent Intensities:</b> [descent_intensities]<br>"
	message += "<b>Horror Intensities:</b> [horror_intensities]<br>"
	message += "<b>Entity Presences:</b> [entity_presences]<br>"
	message += "<b>Descent Level:</b> [descent_level]/[max_descent_level]<br>"
	message += "<b>Psychological Horror:</b> [psychological_horror]/[max_psychological_horror]<br>"
	message += "<b>Entity Encounters:</b> [entity_encounters]/[max_entity_encounters]<br>"
	message += "<b>Darkness Level:</b> [darkness_level]/[max_darkness_level]<br>"
	message += "<b>Descent Intensity:</b> [descent_intensity]/[max_descent_intensity]<br>"
	message += "<b>Horror Intensity:</b> [horror_intensity]/[max_horror_intensity]<br>"
	message += "<b>Entity Presence:</b> [entity_presence]/[max_entity_presence]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-087"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-087
/obj/structure/scp087/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-087, an endless stairwell that induces psychological horror.</span>")
		else
			to_chat(user, "<span class='danger'>A dark stairwell that seems to descend forever into the depths of despair.</span>")
			to_chat(user, "<span class='notice'>You can <b>descend</b> into the stairwell to explore its depths.</span>")

// Allow players to descend into SCP-087
/obj/structure/scp087/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return ..()

	if(user.SCP)
		to_chat(user, "<span class='warning'>You cannot descend into SCP-087 as an SCP.</span>")
		return

	to_chat(user, "<span class='notice'>You begin to descend into SCP-087...</span>")

	// Start descent process
	descend_into_stairwell(user)

// Descend into the stairwell
/obj/structure/scp087/proc/descend_into_stairwell(mob/living/carbon/human/user)
	if(!user || user.stat == DEAD)
		return

	// Increase descent level
	descent_level = min(max_descent_level, descent_level + 1)
	descents_performed++

	// Apply psychological horror effects
	if(psychological_horror > 0)
		to_chat(user, "<span class='danger'>The darkness and silence become overwhelming...</span>")
		user.adjustBruteLoss(5)
		horror_events++

	// Apply entity encounter effects
	if(entity_encounters > 0 && prob(25))
		to_chat(user, "<span class='danger'>You hear something moving in the darkness below...</span>")
		user.adjustBruteLoss(10)
		entity_events++

	// Apply descent intensity effects
	if(descent_intensity > 0)
		to_chat(user, "<span class='danger'>The stairwell seems to descend deeper than possible...</span>")
		user.adjustBruteLoss(3)
		descent_intensities++

	// Check for deep descent effects
	if(descent_level >= max_descent_level * 0.8)
		to_chat(user, "<span class='danger'>You have descended very deep into SCP-087...</span>")
		user.adjustBruteLoss(15)

	// Update persistence
	add_interaction_record(user, "descent")

	// Give feedback to user
	to_chat(user, "<span class='notice'>You have descended to level [descent_level] of SCP-087.</span>")

// Allow players to return from the stairwell
/obj/structure/scp087/attack_hand_secondary(mob/living/carbon/human/user)
	if(!istype(user))
		return ..()

	if(user.SCP)
		to_chat(user, "<span class='warning'>You cannot return from SCP-087 as an SCP.</span>")
		return

	to_chat(user, "<span class='notice'>You begin to climb back up from SCP-087...</span>")

	// Start return process
	return_from_stairwell(user)

// Return from the stairwell
/obj/structure/scp087/proc/return_from_stairwell(mob/living/carbon/human/user)
	if(!user || user.stat == DEAD)
		return

	// Decrease descent level
	descent_level = max(0, descent_level - 1)

	// Apply return effects
	if(descent_level > 0)
		to_chat(user, "<span class='notice'>You climb back up one level...</span>")
	else
		to_chat(user, "<span class='notice'>You have returned to the surface from SCP-087.</span>")

	// Update persistence
	add_interaction_record(user, "return")

	// Give feedback to user
	to_chat(user, "<span class='notice'>You are now at level [descent_level] of SCP-087.</span>")

// Add interaction record
/obj/structure/scp087/proc/add_interaction_record(mob/living/carbon/human/user, interaction_type)
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-087"]
		if(instance)
			instance.add_interaction_record(user, interaction_type)
