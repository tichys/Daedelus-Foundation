// SCP-420-J - The Best ████ in the World
// A mysterious substance that enhances the quality of various items

/obj/item/scp420j
	name = "SCP-420-J"
	desc = "A mysterious substance that claims to be the best ████ in the world."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "scp420j"
	w_class = WEIGHT_CLASS_SMALL

	// SCP-420-J variables
	var/quality_enhancement = 0
	var/max_quality_enhancement = 50
	var/taste_improvement = 0
	var/max_taste_improvement = 50
	var/enhancement_level = 1
	var/max_enhancement_level = 5
	var/quality_rating = 0
	var/max_quality_rating = 50
	var/taste_rating = 0
	var/max_taste_rating = 50
	var/quality_cooldown = 0
	var/quality_cooldown_time = 30 SECONDS
	var/taste_cooldown = 0
	var/taste_cooldown_time = 20 SECONDS
	var/enhancement_cooldown = 0
	var/enhancement_cooldown_time = 45 SECONDS

	// Persistence tracking
	var/enhancements_performed = 0
	var/taste_events = 0
	var/quality_events = 0
	var/quality_ratings = 0
	var/taste_ratings = 0
	var/enhancement_events = 0

/obj/item/scp420j/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-420-J",
		SCP_SAFE,
		"420-J",

	)

	SCP.min_playercount = 15
	SCP.min_time = 20 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-420-J"] = new /datum/scp_instance("SCP-420-J", src)

/obj/item/scp420j/Destroy()
	return ..()

// Core mechanics
/obj/item/scp420j/process()
	. = ..()

	// Process quality enhancement
	process_quality_enhancement()

	// Process taste improvement
	process_taste_improvement()

	// Process enhancement level
	process_enhancement_level()

// Process quality enhancement
/obj/item/scp420j/proc/process_quality_enhancement()
	if(quality_enhancement > 0 && prob(1))
		// Enhance nearby items
		for(var/obj/item/I in range(3, src))
			if(I != src)
				to_chat(usr, "<span class='notice'>SCP-420-J enhances the quality of [I].</span>")
				enhancements_performed++

// Process taste improvement
/obj/item/scp420j/proc/process_taste_improvement()
	if(taste_improvement > 0 && prob(1))
		// Create taste effects
		for(var/mob/living/carbon/human/H in range(3, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='notice'>You taste something improved!</span>")
				taste_events++

// Process enhancement level
/obj/item/scp420j/proc/process_enhancement_level()
	if(enhancement_level > 1 && prob(1))
		// Create enhancement effects
		for(var/mob/living/carbon/human/H in range(2, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='notice'>You notice improved quality!</span>")
				enhancement_events++

// SCP-420-J abilities
/obj/item/scp420j/proc/quality_enhancement_ability()
	quality_enhancement = min(max_quality_enhancement, quality_enhancement + 10)
	enhancements_performed++

	to_chat(usr, "<span class='notice'>SCP-420-J enhances quality. Enhancement: [quality_enhancement]/[max_quality_enhancement]</span>")

/obj/item/scp420j/proc/taste_improvement_ability()
	if(world.time < taste_cooldown)
		to_chat(usr, "<span class='warning'>SCP-420-J needs time to improve taste again.</span>")
		return

	taste_cooldown = world.time + taste_cooldown_time
	taste_improvement = min(max_taste_improvement, taste_improvement + 10)
	taste_ratings++

	to_chat(usr, "<span class='notice'>SCP-420-J improves taste. Improvement: [taste_improvement]/[max_taste_improvement]</span>")

/obj/item/scp420j/proc/enhancement_level_ability()
	if(enhancement_level >= max_enhancement_level)
		to_chat(usr, "<span class='warning'>SCP-420-J has reached maximum enhancement level.</span>")
		return

	enhancement_level = min(max_enhancement_level, enhancement_level + 1)
	enhancement_events++

	to_chat(usr, "<span class='notice'>SCP-420-J's enhancement level increases. Level: [enhancement_level]/[max_enhancement_level]</span>")

/obj/item/scp420j/proc/quality_rating_ability()
	if(quality_rating >= max_quality_rating)
		to_chat(usr, "<span class='warning'>SCP-420-J has reached maximum quality rating.</span>")
		return

	quality_rating = min(max_quality_rating, quality_rating + 10)
	quality_ratings++

	to_chat(usr, "<span class='notice'>SCP-420-J's quality rating increases. Rating: [quality_rating]/[max_quality_rating]</span>")

/obj/item/scp420j/proc/taste_rating_ability()
	if(taste_rating >= max_taste_rating)
		to_chat(usr, "<span class='warning'>SCP-420-J has reached maximum taste rating.</span>")
		return

	taste_rating = min(max_taste_rating, taste_rating + 10)
	taste_ratings++

	to_chat(usr, "<span class='notice'>SCP-420-J's taste rating increases. Rating: [taste_rating]/[max_taste_rating]</span>")

/obj/item/scp420j/proc/improve_quality_ability()
	// Improve quality of nearby items
	for(var/obj/item/I in range(2, src))
		if(I != src)
			to_chat(usr, "<span class='notice'>SCP-420-J improves the quality of [I].</span>")
			quality_events++

	to_chat(usr, "<span class='notice'>SCP-420-J improves the quality of nearby items.</span>")

// Status display
/obj/item/scp420j/proc/get_quality_status()
	var/message = "<h2>SCP-420-J Status</h2>"
	message += "<b>Quality Enhancement:</b> [quality_enhancement]/[max_quality_enhancement]<br>"
	message += "<b>Taste Improvement:</b> [taste_improvement]/[max_taste_improvement]<br>"
	message += "<b>Enhancement Level:</b> [enhancement_level]/[max_enhancement_level]<br>"
	message += "<b>Quality Rating:</b> [quality_rating]/[max_quality_rating]<br>"
	message += "<b>Taste Rating:</b> [taste_rating]/[max_taste_rating]<br>"

	return message

// SCP-420-J verbs
/obj/item/scp420j/verb/quality_enhancement()
	set name = "Quality Enhancement"
	set category = "SCP-420-J"
	set desc = "Enhance quality with SCP-420-J."

	quality_enhancement_ability()

/obj/item/scp420j/verb/taste_improvement()
	set name = "Taste Improvement"
	set category = "SCP-420-J"
	set desc = "Improve taste with SCP-420-J."

	taste_improvement_ability()

/obj/item/scp420j/verb/enhancement_level()
	set name = "Enhancement Level"
	set category = "SCP-420-J"
	set desc = "Increase SCP-420-J's enhancement level."

	enhancement_level_ability()

/obj/item/scp420j/verb/quality_rating()
	set name = "Quality Rating"
	set category = "SCP-420-J"
	set desc = "Increase SCP-420-J's quality rating."

	quality_rating_ability()

/obj/item/scp420j/verb/taste_rating()
	set name = "Taste Rating"
	set category = "SCP-420-J"
	set desc = "Increase SCP-420-J's taste rating."

	taste_rating_ability()

/obj/item/scp420j/verb/improve_quality()
	set name = "Improve Quality"
	set category = "SCP-420-J"
	set desc = "Improve quality of nearby items."

	improve_quality_ability()

// Admin verb to view SCP-420-J persistence data
/obj/item/scp420j/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP-420-J"
	set desc = "View SCP-420-J persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-420-J Persistence Data</h2>"
	message += "<b>Enhancements Performed:</b> [enhancements_performed]<br>"
	message += "<b>Taste Events:</b> [taste_events]<br>"
	message += "<b>Quality Events:</b> [quality_events]<br>"
	message += "<b>Quality Ratings:</b> [quality_ratings]<br>"
	message += "<b>Taste Ratings:</b> [taste_ratings]<br>"
	message += "<b>Enhancement Events:</b> [enhancement_events]<br>"
	message += "<b>Quality Enhancement:</b> [quality_enhancement]/[max_quality_enhancement]<br>"
	message += "<b>Taste Improvement:</b> [taste_improvement]/[max_taste_improvement]<br>"
	message += "<b>Enhancement Level:</b> [enhancement_level]/[max_enhancement_level]<br>"
	message += "<b>Quality Rating:</b> [quality_rating]/[max_quality_rating]<br>"
	message += "<b>Taste Rating:</b> [taste_rating]/[max_taste_rating]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-420-J"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-420-J
/obj/item/scp420j/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-420-J, a substance that enhances quality.</span>")
		else
			to_chat(user, "<span class='notice'>A mysterious substance that seems to enhance the quality of things.</span>")

/obj/item/scp420j/proc/on_quality_enhancement(mob/living/carbon/human/user)
	if(!user)
		return
	hook_scp_interaction(user, "SCP-420-J", INTERACTION_TYPE_RESEARCH)

/obj/item/scp420j/proc/on_taste_improvement(mob/living/carbon/human/user)
	if(!user)
		return
	hook_scp_interaction(user, "SCP-420-J", INTERACTION_TYPE_OBSERVATION)
