/obj/item/paper/scp012
	name = "SCP-012"
	desc = "A sheet of paper with an incomplete musical composition that seems to drive those who read it to complete it with their own blood."
	icon = 'icons/scp/scp-012.dmi'
	icon_state = "paper"
	var/completion_progress = 0
	var/max_completion = 100
	var/list/affected_composers = list()
	var/list/composition_notes = list()
	var/sanity_drain_radius = 4
	var/composition_cooldown = 0
	var/composition_cooldown_time = 60 SECONDS
	var/musical_obsession_level = 0
	var/max_obsession = 100
	var/composition_style = "classical"
	var/list/composition_styles = list("classical", "romantic", "baroque", "modern", "jazz", "folk")
	var/musical_inspiration_level = 0
	var/max_inspiration = 100
	var/list/composer_skills = list()
	var/composition_difficulty = 1
	var/musical_harmony_bonus = 0
	var/list/completed_movements = list()
	var/max_movements = 4
	var/current_movement = 1
	var/composition_quality = 0
	var/max_quality = 100

	// Persistence tracking
	var/composers_affected = 0
	var/completion_attempts = 0
	var/sanity_drained = 0
	var/containment_status = "contained"
	var/total_blood_used = 0
	var/musical_masterpieces_created = 0
	var/composer_deaths = 0
	var/harmonic_resonance_events = 0

/obj/item/paper/scp012/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-012",
		SCP_EUCLID,
		"012",

	)

	SCP.min_playercount = 15
	SCP.min_time = 20 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-012"] = new /datum/scp_instance("SCP-012", src)

/obj/item/paper/scp012/Destroy()
	affected_composers = list()
	composition_notes = list()
	return ..()

// Core mechanics
/obj/item/paper/scp012/process()
	. = ..()

	// Drain sanity from nearby targets
	drain_nearby_sanity()

// Drain sanity from nearby targets
/obj/item/paper/scp012/proc/drain_nearby_sanity()
	for(var/mob/living/carbon/human/H in range(sanity_drain_radius, src))
		if(H.SCP || H.stat == DEAD)
			continue

		apply_sanity_drain(H)

// Apply sanity drain effect
/obj/item/paper/scp012/proc/apply_sanity_drain(mob/living/carbon/human/target)
	if(!target)
		return

	// Initialize obsession level if not present
	if(!(target in affected_composers))
		affected_composers[target] = 0
		composer_skills[target] = rand(1, 10) // Random musical skill level

	// Increase obsession level
	affected_composers[target] = min(max_obsession, affected_composers[target] + 2)
	sanity_drained++

	// Increase musical inspiration
	musical_inspiration_level = min(max_inspiration, musical_inspiration_level + 1)

	// Harmonic resonance effect
	if(prob(5))
		harmonic_resonance_events++
		to_chat(target, "<span class='notice'>You feel a harmonic resonance with the composition!</span>")
		musical_harmony_bonus += 5

	// Apply sanity effects based on obsession level
	var/obsession_level = affected_composers[target]

	if(obsession_level >= 20)
		to_chat(target, "<span class='warning'>You feel drawn to the musical composition...</span>")
		target.adjustToxLoss(1)

	if(obsession_level >= 40)
		to_chat(target, "<span class='danger'>The composition is calling to you! You must complete it!</span>")
		target.adjustToxLoss(3)
		target.stamina.adjust(-10)

	if(obsession_level >= 60)
		to_chat(target, "<span class='danger'>The music is overwhelming! You can't think of anything else!</span>")
		target.adjustToxLoss(5)
		target.stamina.adjust(-20)

		// Random movement towards the composition
		if(prob(30))
			step_towards(target, src)
			to_chat(target, "<span class='danger'>You move closer to the composition!</span>")

	if(obsession_level >= 80)
		to_chat(target, "<span class='danger'>You're completely obsessed! You must complete the composition with your blood!</span>")
		target.adjustToxLoss(8)
		target.stamina.adjust(-30)

		// Force attempt to complete
		if(prob(50))
			attempt_completion(target)

	if(obsession_level >= 100)
		to_chat(target, "<span class='danger'>The obsession has consumed you! You will complete the composition or die trying!</span>")
		target.adjustToxLoss(15)
		target.stamina.adjust(-50)

		// Immediate completion attempt
		attempt_completion(target)

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-012"]
		if(instance)
			instance.add_interaction_record(target, "sanity_drain")

// Attempt to complete the composition
/obj/item/paper/scp012/proc/attempt_completion(mob/living/carbon/human/composer)
	if(world.time < composition_cooldown)
		return

	composition_cooldown = world.time + composition_cooldown_time
	completion_attempts++
	composers_affected++

	// Calculate composer skill and difficulty
	var/composer_skill = composer_skills[composer] ? composer_skills[composer] : 5
	var/skill_bonus = composer_skill * 2
	var/inspiration_bonus = musical_inspiration_level / 10
	var/harmony_bonus = musical_harmony_bonus / 10

	// Calculate total progress based on skill and bonuses
	var/progress_gain = 10 + skill_bonus + inspiration_bonus + harmony_bonus

	visible_message("<span class='danger'>[composer] attempts to complete SCP-012 with their blood!</span>")
	to_chat(composer, "<span class='danger'>You begin writing in your own blood to complete the composition!</span>")

	// Apply blood loss based on skill and inspiration
	var/blood_loss = 20 - (composer_skill * 2)
	blood_loss = max(5, blood_loss) // Minimum blood loss
	composer.adjustBruteLoss(blood_loss)
	composer.adjustToxLoss(10)
	total_blood_used += blood_loss

	// Check for composer death
	if(composer.stat == DEAD)
		composer_deaths++
		to_chat(composer, "<span class='danger'>You have died completing the composition! Your sacrifice will be remembered!</span>")

	// Add composition note with enhanced details
	var/composition_note = generate_composition_note(composer, composer_skill, progress_gain)
	composition_notes += composition_note
	completion_progress += progress_gain
	composition_quality += composer_skill

	// Check for completion
	if(completion_progress >= max_completion)
		complete_composition(composer)
	else
		to_chat(composer, "<span class='notice'>You add a musical phrase to the composition. Progress: [completion_progress]/[max_completion]</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-012"]
		if(instance)
			instance.add_interaction_record(composer, "completion_attempt")

// Generate a composition note
/obj/item/paper/scp012/proc/generate_composition_note(mob/living/carbon/human/composer, composer_skill, progress_gain)
	var/timestamp = time2text(world.time, "YYYY-MM-DD hh:mm:ss")
	var/list/musical_phrases = list(
		"Allegro con brio",
		"Adagio sostenuto",
		"Scherzo: Allegro vivace",
		"Finale: Allegro ma non troppo",
		"Crescendo e diminuendo",
		"Pianissimo e fortissimo",
		"Legato e staccato",
		"Ritardando e accelerando",
		"Sonata form exposition",
		"Fugue subject and answer",
		"Rondo theme development",
		"Variation on a theme",
		"Counterpoint and harmony",
		"Modulation to relative minor",
		"Recapitulation of main theme",
		"Coda with final cadence"
	)

	var/list/composition_emotions = list(
		"with passionate intensity",
		"with melancholic beauty",
		"with dramatic flair",
		"with serene contemplation",
		"with fiery determination",
		"with gentle grace",
		"with thunderous power",
		"with delicate precision"
	)

	var/phrase = pick(musical_phrases)
	var/emotion = pick(composition_emotions)
	var/quality_rating = ""

	if(composer_skill >= 8)
		quality_rating = " (Masterpiece quality)"
	else if(composer_skill >= 6)
		quality_rating = " (Excellent quality)"
	else if(composer_skill >= 4)
		quality_rating = " (Good quality)"
	else
		quality_rating = " (Basic quality)"

	return "[timestamp]: [composer.name] added '[phrase]' [emotion] to Movement [current_movement]. Progress: +[progress_gain]%[quality_rating]"

// Complete the composition
/obj/item/paper/scp012/proc/complete_composition(mob/living/carbon/human/composer)
	containment_status = "breached"
	musical_masterpieces_created++

	// Calculate final quality
	var/final_quality = composition_quality / completion_attempts
	var/quality_title = ""

	if(final_quality >= 80)
		quality_title = "Masterpiece"
	else if(final_quality >= 60)
		quality_title = "Excellent"
	else if(final_quality >= 40)
		quality_title = "Good"
	else
		quality_title = "Basic"

	visible_message("<span class='danger'>[composer] has completed SCP-012! The composition is now finished!</span>")
	to_chat(composer, "<span class='notice'>You have completed the composition! The musical obsession is finally satisfied.</span>")
	to_chat(composer, "<span class='notice'>Final Composition Quality: [quality_title] ([final_quality]/100)</span>")

	// Create musical masterpiece effect
	create_musical_masterpiece_effect(composer, final_quality)

	// Reset obsession for all affected composers
	for(var/mob/living/carbon/human/H in affected_composers)
		affected_composers[H] = 0
		to_chat(H, "<span class='notice'>The musical obsession has been lifted!</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-012"]
		if(instance)
			instance.add_interaction_record(composer, "composition_completed")

// Create musical masterpiece effect
/obj/item/paper/scp012/proc/create_musical_masterpiece_effect(mob/living/carbon/human/composer, final_quality)
	// Create a beautiful musical effect
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	// Apply healing effect to the composer
	if(composer.stat != DEAD)
		composer.adjustBruteLoss(-30)
		composer.adjustToxLoss(-20)
		to_chat(composer, "<span class='notice'>The completion of the masterpiece heals your wounds!</span>")

	// Create musical notes effect around the composition
	for(var/i = 1 to 5)
		addtimer(CALLBACK(src, PROC_REF(create_musical_effect), i), i * 10)

// Change composition style
/obj/item/paper/scp012/proc/change_composition_style(new_style)
	if(new_style in composition_styles)
		composition_style = new_style
		to_chat(usr, "<span class='notice'>Composition style changed to [new_style].</span>")

		// Apply style-specific bonuses
		switch(new_style)
			if("classical")
				musical_harmony_bonus += 10
			if("romantic")
				musical_inspiration_level += 20
			if("baroque")
				composition_difficulty += 1
			if("modern")
				composition_quality += 15
			if("jazz")
				musical_harmony_bonus += 15
			if("folk")
				composition_difficulty -= 1

// Advance to next movement
/obj/item/paper/scp012/proc/advance_movement()
	if(current_movement < max_movements)
		current_movement++
		completed_movements += current_movement - 1
		to_chat(usr, "<span class='notice'>Advanced to Movement [current_movement].</span>")

		// Reset progress for new movement
		completion_progress = 0
		composition_quality = 0

		// Apply movement bonus
		musical_inspiration_level += 30
		musical_harmony_bonus += 20
	else
		to_chat(usr, "<span class='warning'>Already at the final movement!</span>")

// Attack behavior - attempt completion when used
/obj/item/paper/scp012/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		attempt_completion(H)
		return TRUE
	return ..()

// Verb commands
/obj/item/paper/scp012/verb/attempt_completion_verb()
	set name = "Attempt Completion"
	set category = "SCP"
	set desc = "Attempt to complete SCP-012 with your blood."

	attempt_completion(usr)

/obj/item/paper/scp012/verb/expand_sanity_radius()
	set name = "Expand Sanity Drain Radius"
	set category = "SCP"
	set desc = "Expand the radius of sanity drain effects."

	sanity_drain_radius = min(8, sanity_drain_radius + 1)
	to_chat(usr, "<span class='notice'>Sanity drain radius expanded to [sanity_drain_radius] tiles.</span>")

/obj/item/paper/scp012/verb/view_composition_status()
	set name = "View Composition Status"
	set category = "SCP"
	set desc = "View the composition status and progress."

	var/message = "<h2>SCP-012 Composition Status</h2>"
	message += "<b>Completion Progress:</b> [completion_progress]/[max_completion]<br>"
	message += "<b>Sanity Drain Radius:</b> [sanity_drain_radius] tiles<br>"
	message += "<b>Composers Affected:</b> [composers_affected]<br>"
	message += "<b>Completion Attempts:</b> [completion_attempts]<br>"
	message += "<b>Sanity Drained:</b> [sanity_drained]<br><br>"

	if(length(composition_notes))
		message += "<h3>Composition Notes:</h3>"
		for(var/note in composition_notes)
			message += "[note]<br>"
	else
		message += "<i>No composition notes yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/paper/scp012/verb/view_obsession_levels()
	set name = "View Obsession Levels"
	set category = "SCP"
	set desc = "View the obsession levels of nearby targets."

	var/message = "<h2>SCP-012 Obsession Levels</h2>"

	if(length(affected_composers))
		message += "<h3>Affected Composers:</h3>"
		for(var/mob/living/carbon/human/H in affected_composers)
			var/obsession_level = affected_composers[H]
			var/skill_level = composer_skills[H] ? composer_skills[H] : "Unknown"
			message += "- [H.name]: Obsession Level [obsession_level]/[max_obsession], Skill Level [skill_level]/10<br>"
	else
		message += "<i>No composers currently affected.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/paper/scp012/verb/change_style()
	set name = "Change Composition Style"
	set category = "SCP"
	set desc = "Change the composition style."

	var/new_style = input(usr, "Choose a composition style:", "SCP-012 Style Selection") as null|anything in composition_styles
	if(new_style)
		change_composition_style(new_style)

/obj/item/paper/scp012/verb/advance_movement_verb()
	set name = "Advance Movement"
	set category = "SCP"
	set desc = "Advance to the next movement of the composition."

	advance_movement()

/obj/item/paper/scp012/verb/view_musical_stats()
	set name = "View Musical Statistics"
	set category = "SCP"
	set desc = "View detailed musical statistics."

	var/message = "<h2>SCP-012 Musical Statistics</h2>"
	message += "<b>Current Style:</b> [composition_style]<br>"
	message += "<b>Current Movement:</b> [current_movement]/[max_movements]<br>"
	message += "<b>Musical Inspiration:</b> [musical_inspiration_level]/[max_inspiration]<br>"
	message += "<b>Harmony Bonus:</b> [musical_harmony_bonus]<br>"
	message += "<b>Composition Quality:</b> [composition_quality]/[max_quality]<br>"
	message += "<b>Composition Difficulty:</b> [composition_difficulty]<br>"
	message += "<b>Completed Movements:</b> [length(completed_movements)]<br>"
	message += "<b>Total Blood Used:</b> [total_blood_used] units<br>"
	message += "<b>Musical Masterpieces:</b> [musical_masterpieces_created]<br>"
	message += "<b>Composer Deaths:</b> [composer_deaths]<br>"
	message += "<b>Harmonic Resonance Events:</b> [harmonic_resonance_events]<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/paper/scp012/verb/inspire_composers()
	set name = "Inspire Composers"
	set category = "SCP"
	set desc = "Increase musical inspiration for all nearby composers."

	musical_inspiration_level = min(max_inspiration, musical_inspiration_level + 30)
	musical_harmony_bonus += 25

	for(var/mob/living/carbon/human/H in range(sanity_drain_radius, src))
		if(H.SCP || H.stat == DEAD)
			continue
		if(H in affected_composers)
			affected_composers[H] = min(max_obsession, affected_composers[H] + 10)
			to_chat(H, "<span class='notice'>You feel a surge of musical inspiration!</span>")

	to_chat(usr, "<span class='notice'>Musical inspiration increased for all nearby composers!</span>")

// Admin verb to view SCP-012 persistence data
/obj/item/paper/scp012/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-012 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-012 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Completion Progress:</b> [completion_progress]/[max_completion]<br>"
	message += "<b>Current Movement:</b> [current_movement]/[max_movements]<br>"
	message += "<b>Composition Style:</b> [composition_style]<br>"
	message += "<b>Musical Inspiration:</b> [musical_inspiration_level]/[max_inspiration]<br>"
	message += "<b>Composition Quality:</b> [composition_quality]/[max_quality]<br>"
	message += "<b>Composers Affected:</b> [composers_affected]<br>"
	message += "<b>Completion Attempts:</b> [completion_attempts]<br>"
	message += "<b>Sanity Drained:</b> [sanity_drained]<br>"
	message += "<b>Total Blood Used:</b> [total_blood_used] units<br>"
	message += "<b>Musical Masterpieces:</b> [musical_masterpieces_created]<br>"
	message += "<b>Composer Deaths:</b> [composer_deaths]<br>"
	message += "<b>Harmonic Resonance Events:</b> [harmonic_resonance_events]<br>"
	message += "<b>Affected Composers:</b> [length(affected_composers)]<br>"
	message += "<b>Sanity Drain Radius:</b> [sanity_drain_radius] tiles<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-012"]
		if(instance)
			message += "<b>Interaction History:</b> [length(instance.interaction_history)] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-012
/obj/item/paper/scp012/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-012, an incomplete musical composition that drives people to complete it with their blood.</span>")
			to_chat(user, "<span class='info'>Current Style: [composition_style], Movement: [current_movement]/[max_movements], Progress: [completion_progress]/[max_completion]%</span>")
		else
			to_chat(user, "<span class='danger'>A sheet of paper with an incomplete musical composition. You feel strangely drawn to it...</span>")
			to_chat(user, "<span class='info'>The composition seems to be in [composition_style] style, currently on movement [current_movement].</span>")

			// Apply initial obsession
			if(!(H in affected_composers))
				affected_composers[H] = 10
				composer_skills[H] = rand(1, 10)
				to_chat(user, "<span class='warning'>The composition begins to call to you...</span>")
				to_chat(user, "<span class='info'>You feel a musical talent awakening within you. Skill Level: [composer_skills[H]]/10</span>")

// Enhanced status display
/obj/item/paper/scp012/proc/get_status_tab_items()
	var/list/status_items = list()

	status_items += "Containment Status: [containment_status]"
	status_items += "Completion Progress: [completion_progress]/[max_completion]"
	status_items += "Current Movement: [current_movement]/[max_movements]"
	status_items += "Composition Style: [composition_style]"
	status_items += "Musical Inspiration: [musical_inspiration_level]/[max_inspiration]"
	status_items += "Harmony Bonus: [musical_harmony_bonus]"
	status_items += "Composition Quality: [composition_quality]/[max_quality]"
	status_items += "Composers Affected: [composers_affected]"
	status_items += "Completion Attempts: [completion_attempts]"
	status_items += "Total Blood Used: [total_blood_used] units"
	status_items += "Musical Masterpieces: [musical_masterpieces_created]"
	status_items += "Composer Deaths: [composer_deaths]"
	status_items += "Harmonic Resonance Events: [harmonic_resonance_events]"

	return status_items

/obj/item/paper/scp012/proc/create_musical_effect(var/i)
	var/list/directions = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	var/direction = pick(directions)
	var/turf/T = get_step(src, direction)
	if(T)
		playsound(T, 'sound/weapons/punch1.ogg', 30, TRUE)

/obj/item/paper/scp012/proc/on_composer_affected(mob/living/carbon/human/composer)
	if(!composer)
		return
	hook_scp_interaction(composer, "SCP-012", INTERACTION_TYPE_OBSERVATION)

/obj/item/paper/scp012/proc/on_completion_attempt(mob/living/carbon/human/composer)
	if(!composer)
		return
	hook_scp_combat(composer, "SCP-012", 0, 10)

/obj/item/paper/scp012/proc/on_composer_death(mob/living/carbon/human/composer)
	if(!composer)
		return
	hook_player_death_near_scp(composer, "SCP-012")


