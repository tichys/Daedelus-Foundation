// SCP-966 - Sleep Killer
// An invisible creature that causes sleep deprivation

/mob/living/carbon/scp/scp966
	name = "SCP-966"
	desc = "An invisible creature that causes sleep deprivation."
	icon = 'icons/scp/nonhumanoidscps(32x32).dmi'
	icon_state = "scp966"
	real_name = "SCP-966"

	// Maximum Enhanced SCP-966 variables
	var/list/sleep_affected_targets = list()
	var/sleep_drain_cooldown = 0
	var/sleep_drain_cooldown_time = 10 SECONDS
	var/invisibility_level = 0
	var/max_invisibility = 100
	var/stealth_mode = FALSE
	var/stealth_cooldown = 0
	var/stealth_cooldown_time = 20 SECONDS
	var/sleep_deprivation_intensity = 1
	var/max_sleep_deprivation = 5
	var/list/stalked_targets = list()
	var/nightmare_manipulation = 0
	var/max_nightmare_manipulation = 100
	var/sleep_paralysis_skill = 0
	var/max_sleep_paralysis_skill = 100
	var/dream_invasion_level = 0
	var/max_dream_invasion_level = 5
	var/reality_distortion = 0
	var/max_reality_distortion = 100
	var/psychological_horror = 0
	var/max_psychological_horror = 100
	var/invisibility_evolution = 1
	var/max_invisibility_evolution = 5
	var/nightmare_cooldown = 0
	var/nightmare_cooldown_time = 15 SECONDS
	var/dream_invasion_cooldown = 0
	var/dream_invasion_cooldown_time = 25 SECONDS

	// Persistence tracking
	var/sleep_drain_sessions = 0
	var/stealth_activations = 0
	var/targets_stalked = 0
	var/nightmares_created = 0
	var/sleep_paralysis_events = 0
	var/dream_invasions = 0
	var/reality_distortions = 0
	var/psychological_horrors = 0
	var/invisibility_evolutions = 0

/mob/living/carbon/scp/scp966/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-966",
		SCP_EUCLID,
		"966",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 15
	SCP_datum.min_time = 25 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 150
	scp_health = max_scp_health
	max_scp_armor = 30
	scp_armor = max_scp_armor

	// Add maximum enhanced abilities
	add_ability("drain_sleep", "drain_sleep_ability")
	add_ability("toggle_stealth", "toggle_stealth_ability")
	add_ability("stalk_target", "stalk_target_ability")
	add_ability("intensify_deprivation", "intensify_deprivation_ability")
	add_ability("view_stalked_targets", "view_stalked_targets_ability")
	add_ability("create_nightmare", "create_nightmare_ability")
	add_ability("sleep_paralysis", "sleep_paralysis_ability")
	add_ability("invade_dreams", "invade_dreams_ability")
	add_ability("distort_reality", "distort_reality_ability")
	add_ability("psychological_horror", "psychological_horror_ability")
	add_ability("evolve_invisibility", "evolve_invisibility_ability")
	add_ability("nightmare_mastery", "nightmare_mastery_ability")

	// Add passive effects
	add_passive_effect("invisibility")
	add_passive_effect("sleep_deprivation")
	add_passive_effect("stealth_mastery")
	add_passive_effect("nightmare_manipulation")
	add_passive_effect("sleep_paralysis")
	add_passive_effect("dream_invasion")
	add_passive_effect("reality_distortion")
	add_passive_effect("psychological_horror")
	add_passive_effect("invisibility_evolution")

/mob/living/carbon/scp/scp966/Destroy()
	sleep_affected_targets = list()
	stalked_targets = list()
	return ..()

/mob/living/carbon/scp/scp966/process_scp_effects()
	. = ..()

	// Enhanced sleep drain behavior
	if(world.time >= sleep_drain_cooldown)
		sleep_drain_cooldown = world.time + sleep_drain_cooldown_time
		drain_nearby_sleep()

	// Stealth behavior
	if(stealth_mode)
		process_stealth()

	// Stalking behavior
	process_stalking()

	// Process nightmare manipulation
	process_nightmare_manipulation()

	// Process sleep paralysis
	process_sleep_paralysis()

	// Process dream invasion
	process_dream_invasion()

	// Process reality distortion
	process_reality_distortion()

	// Process psychological horror
	process_psychological_horror()

	// Process invisibility evolution
	process_invisibility_evolution()

// Drain sleep from nearby targets
/mob/living/carbon/scp/scp966/proc/drain_nearby_sleep()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H == src || H.SCP)
			continue

		if(!(H in sleep_affected_targets))
			sleep_affected_targets += H

		// Enhanced sleep deprivation effects
		var/deprivation_damage = 5 * sleep_deprivation_intensity
		H.adjustBruteLoss(deprivation_damage)
		H.adjustToxLoss(deprivation_damage)

		// Apply sleep deprivation messages
		var/list/deprivation_messages = list(
			"You feel an overwhelming sense of exhaustion...",
			"Your eyes are heavy, but you cannot sleep...",
			"A deep fatigue settles in, but rest eludes you...",
			"You're so tired, but sleep is impossible...",
			"Exhaustion grips you, yet you remain awake...",
			"Your mind screams for rest, but your body refuses...",
			"Sleep is just beyond your reach...",
			"You feel like you're being watched while you try to rest...",
			"Every time you close your eyes, something keeps you awake...",
			"Rest is a distant memory..."
		)

		to_chat(H, "<span class='warning'>[pick(deprivation_messages)]</span>")

		add_interaction_record(H, "sleep_drain")
		sleep_drain_sessions++

// Process stealth behavior
/mob/living/carbon/scp/scp966/proc/process_stealth()
	if(!stealth_mode)
		return

	// Increase invisibility while in stealth
	invisibility_level = min(max_invisibility, invisibility_level + 2)

	// Move silently
	for(var/mob/living/carbon/human/H in view(3, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='notice'>You hear a faint whisper in the darkness...</span>")

// Process stalking behavior
/mob/living/carbon/scp/scp966/proc/process_stalking()
	for(var/mob/living/carbon/human/H in stalked_targets)
		if(H.stat == DEAD || !H)
			stalked_targets -= H
			continue

		// Follow stalked targets
		if(get_dist(src, H) > 7)
			step_towards(src, H)

		// Intensify sleep deprivation on stalked targets
		if(get_dist(src, H) <= 3)
			H.adjustBruteLoss(2 * sleep_deprivation_intensity)
			H.adjustToxLoss(2 * sleep_deprivation_intensity)

// Process nightmare manipulation
/mob/living/carbon/scp/scp966/proc/process_nightmare_manipulation()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H == src || H.SCP)
			continue

		if(prob(3))
			create_nightmare_effect(H)

// Create nightmare effect
/mob/living/carbon/scp/scp966/proc/create_nightmare_effect(mob/living/carbon/human/target)
	var/list/nightmare_messages = list(
		"<span class='danger'>You see shadows moving in the corner of your eye...</span>",
		"<span class='danger'>A cold hand brushes against your neck...</span>",
		"<span class='danger'>You hear your name whispered from the darkness...</span>",
		"<span class='danger'>Something is watching you from the shadows...</span>",
		"<span class='danger'>You feel an overwhelming sense of dread...</span>"
	)

	to_chat(target, pick(nightmare_messages))
	target.adjustBruteLoss(3)
	nightmare_manipulation = min(max_nightmare_manipulation, nightmare_manipulation + 1)

// Process sleep paralysis
/mob/living/carbon/scp/scp966/proc/process_sleep_paralysis()
	for(var/mob/living/carbon/human/H in view(4, src))
		if(H == src || H.SCP)
			continue

		if(prob(2))
			induce_sleep_paralysis(H)

// Induce sleep paralysis
/mob/living/carbon/scp/scp966/proc/induce_sleep_paralysis(mob/living/carbon/human/target)
	to_chat(target, "<span class='danger'>You feel paralyzed, unable to move or speak!</span>")
	target.adjustBruteLoss(5)
	sleep_paralysis_skill = min(max_sleep_paralysis_skill, sleep_paralysis_skill + 1)

// Process dream invasion
/mob/living/carbon/scp/scp966/proc/process_dream_invasion()
	if(dream_invasion_level > 0)
		for(var/mob/living/carbon/human/H in view(dream_invasion_level * 2, src))
			if(H != src && !H.SCP)
				if(prob(5))
					invade_dream(H)

// Invade dream
/mob/living/carbon/scp/scp966/proc/invade_dream(mob/living/carbon/human/target)
	to_chat(target, "<span class='danger'>Your dreams are invaded by nightmarish visions!</span>")
	target.adjustBruteLoss(8)
	target.adjustToxLoss(5)

// Process reality distortion
/mob/living/carbon/scp/scp966/proc/process_reality_distortion()
	for(var/mob/living/carbon/human/H in view(6, src))
		if(H == src || H.SCP)
			continue

		if(prob(1))
			distort_reality_for_target(H)

// Distort reality for target
/mob/living/carbon/scp/scp966/proc/distort_reality_for_target(mob/living/carbon/human/target)
	var/list/distortion_messages = list(
		"<span class='danger'>The world around you seems to shift and distort...</span>",
		"<span class='danger'>Reality itself feels unstable...</span>",
		"<span class='danger'>You question what is real and what is not...</span>",
		"<span class='danger'>The boundaries between dream and reality blur...</span>",
		"<span class='danger'>You feel like you're trapped in a nightmare...</span>"
	)

	to_chat(target, pick(distortion_messages))
	target.adjustBruteLoss(4)
	reality_distortion = min(max_reality_distortion, reality_distortion + 1)

// Process psychological horror
/mob/living/carbon/scp/scp966/proc/process_psychological_horror()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H == src || H.SCP)
			continue

		if(prob(2))
			induce_psychological_horror(H)

// Induce psychological horror
/mob/living/carbon/scp/scp966/proc/induce_psychological_horror(mob/living/carbon/human/target)
	var/list/horror_messages = list(
		"<span class='danger'>You feel an overwhelming sense of terror...</span>",
		"<span class='danger'>Your sanity begins to slip...</span>",
		"<span class='danger'>You hear voices that shouldn't exist...</span>",
		"<span class='danger'>Your mind is filled with horrific images...</span>",
		"<span class='danger'>You feel like you're losing your mind...</span>"
	)

	to_chat(target, pick(horror_messages))
	target.adjustBruteLoss(6)
	psychological_horror = min(max_psychological_horror, psychological_horror + 1)

// Process invisibility evolution
/mob/living/carbon/scp/scp966/proc/process_invisibility_evolution()
	if(invisibility_level >= max_invisibility && invisibility_evolution < max_invisibility_evolution)
		if(prob(1))
			evolve_invisibility_stage()

// Evolve invisibility stage
/mob/living/carbon/scp/scp966/proc/evolve_invisibility_stage()
	invisibility_evolution = min(max_invisibility_evolution, invisibility_evolution + 1)
	invisibility_evolutions++

	var/evolution_message = ""
	switch(invisibility_evolution)
		if(2)
			evolution_message = "Your invisibility has evolved to include sound dampening!"
		if(3)
			evolution_message = "You can now phase through solid objects!"
		if(4)
			evolution_message = "Your invisibility can now distort reality around you!"
		if(5)
			evolution_message = "You have achieved perfect invisibility mastery!"

	to_chat(src, "<span class='notice'>[evolution_message] Invisibility Evolution: [invisibility_evolution]/[max_invisibility_evolution]</span>")

// Enhanced attack behavior
/mob/living/carbon/scp/scp966/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		var/damage = 25 + (sleep_deprivation_intensity * 5) + (nightmare_manipulation / 10)

		visible_message("<span class='danger'>[H] suddenly looks exhausted!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 30, TRUE)

		H.adjustBruteLoss(damage)
		H.adjustToxLoss(damage)

		// Add to stalked targets
		if(!(H in stalked_targets))
			stalked_targets += H
			targets_stalked++

		add_interaction_record(H, "sleep_attack")
		return

	return ..()

// Maximum enhanced abilities
/mob/living/carbon/scp/scp966/proc/drain_sleep_ability()
	to_chat(src, "<span class='notice'>You drain sleep from nearby targets. Affected: [sleep_affected_targets.len]</span>")

	// Intensify drain on all affected targets
	for(var/mob/living/carbon/human/H in sleep_affected_targets)
		if(H && H.stat != DEAD)
			H.adjustBruteLoss(10 * sleep_deprivation_intensity)
			H.adjustToxLoss(10 * sleep_deprivation_intensity)
			to_chat(H, "<span class='danger'>You feel your life force being drained!</span>")

/mob/living/carbon/scp/scp966/proc/toggle_stealth_ability()
	if(world.time < stealth_cooldown)
		to_chat(src, "<span class='warning'>You need to wait before toggling stealth again.</span>")
		return

	stealth_mode = !stealth_mode
	stealth_cooldown = world.time + stealth_cooldown_time
	stealth_activations++

	if(stealth_mode)
		to_chat(src, "<span class='notice'>You enter stealth mode. Invisibility: [invisibility_level]/[max_invisibility]</span>")
		visible_message("<span class='notice'>A shadow seems to move in the darkness...</span>")
	else
		to_chat(src, "<span class='notice'>You exit stealth mode.</span>")

/mob/living/carbon/scp/scp966/proc/stalk_target_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No suitable targets to stalk.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to stalk:", "Stalk Target") as null|anything in targets
	if(target)
		if(!(target in stalked_targets))
			stalked_targets += target
			targets_stalked++
			to_chat(src, "<span class='notice'>You begin stalking [target].</span>")
			to_chat(target, "<span class='warning'>You feel like you're being watched...</span>")
		else
			stalked_targets -= target
			to_chat(src, "<span class='notice'>You stop stalking [target].</span>")

/mob/living/carbon/scp/scp966/proc/intensify_deprivation_ability()
	if(sleep_deprivation_intensity >= max_sleep_deprivation)
		to_chat(src, "<span class='warning'>Your sleep deprivation intensity is already at maximum.</span>")
		return

	sleep_deprivation_intensity = min(max_sleep_deprivation, sleep_deprivation_intensity + 1)
	to_chat(src, "<span class='notice'>You intensify your sleep deprivation effects. Intensity: [sleep_deprivation_intensity]/[max_sleep_deprivation]</span>")

/mob/living/carbon/scp/scp966/proc/view_stalked_targets_ability()
	var/message = "<h2>SCP-966 Stalking Status</h2>"
	message += "<b>Stalked Targets:</b> [stalked_targets.len]<br>"
	message += "<b>Sleep Deprivation Intensity:</b> [sleep_deprivation_intensity]/[max_sleep_deprivation]<br>"
	message += "<b>Stealth Mode:</b> [stealth_mode ? "Active" : "Inactive"]<br>"
	message += "<b>Invisibility Level:</b> [invisibility_level]/[max_invisibility]<br>"

	if(stalked_targets.len)
		message += "<h3>Currently Stalking:</h3>"
		for(var/mob/living/carbon/human/H in stalked_targets)
			if(H)
				message += "- [H.name] (Distance: [get_dist(src, H)])<br>"
	else
		message += "<i>No targets currently being stalked.</i>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/living/carbon/scp/scp966/proc/create_nightmare_ability()
	if(world.time < nightmare_cooldown)
		to_chat(src, "<span class='warning'>You need to wait before creating another nightmare.</span>")
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets nearby to create nightmares for.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to create a nightmare for:", "Create Nightmare") as null|anything in targets
	if(target)
		create_nightmare_effect(target)
		nightmare_cooldown = world.time + nightmare_cooldown_time
		nightmares_created++

		to_chat(src, "<span class='notice'>You create a nightmare for [target].</span>")

/mob/living/carbon/scp/scp966/proc/sleep_paralysis_ability()
	if(sleep_paralysis_skill < max_sleep_paralysis_skill)
		to_chat(src, "<span class='warning'>You need more sleep paralysis skill to use this ability.</span>")
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(4, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets nearby for sleep paralysis.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target for sleep paralysis:", "Sleep Paralysis") as null|anything in targets
	if(target)
		induce_sleep_paralysis(target)
		sleep_paralysis_events++

		to_chat(src, "<span class='notice'>You induce sleep paralysis in [target].</span>")

/mob/living/carbon/scp/scp966/proc/invade_dreams_ability()
	if(world.time < dream_invasion_cooldown)
		to_chat(src, "<span class='warning'>You need to wait before invading dreams again.</span>")
		return

	if(dream_invasion_level >= max_dream_invasion_level)
		to_chat(src, "<span class='warning'>Your dream invasion is already at maximum level.</span>")
		return

	dream_invasion_level = min(max_dream_invasion_level, dream_invasion_level + 1)
	dream_invasion_cooldown = world.time + dream_invasion_cooldown_time
	dream_invasions++

	to_chat(src, "<span class='notice'>You enhance your dream invasion abilities. Level: [dream_invasion_level]/[max_dream_invasion_level]</span>")

/mob/living/carbon/scp/scp966/proc/distort_reality_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(6, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets nearby to distort reality for.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to distort reality for:", "Distort Reality") as null|anything in targets
	if(target)
		distort_reality_for_target(target)
		reality_distortions++

		to_chat(src, "<span class='notice'>You distort reality for [target].</span>")

/mob/living/carbon/scp/scp966/proc/psychological_horror_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets nearby for psychological horror.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target for psychological horror:", "Psychological Horror") as null|anything in targets
	if(target)
		induce_psychological_horror(target)
		psychological_horrors++

		to_chat(src, "<span class='notice'>You induce psychological horror in [target].</span>")

/mob/living/carbon/scp/scp966/proc/evolve_invisibility_ability()
	if(invisibility_evolution >= max_invisibility_evolution)
		to_chat(src, "<span class='warning'>Your invisibility has reached maximum evolution.</span>")
		return

	if(invisibility_level < max_invisibility)
		to_chat(src, "<span class='warning'>You need more invisibility to evolve.</span>")
		return

	evolve_invisibility_stage()

/mob/living/carbon/scp/scp966/proc/nightmare_mastery_ability()
	if(nightmare_manipulation < max_nightmare_manipulation)
		to_chat(src, "<span class='warning'>You need more nightmare manipulation to use this ability.</span>")
		return

	// Create a massive nightmare effect
	for(var/mob/living/carbon/human/H in view(8, src))
		if(H != src && !H.SCP)
			create_nightmare_effect(H)
			induce_sleep_paralysis(H)
			induce_psychological_horror(H)

	to_chat(src, "<span class='notice'>You unleash nightmare mastery on all nearby targets.</span>")

// Enhanced status display
/mob/living/carbon/scp/scp966/get_status_tab_items()
	. = ..()
	. += "Affected Targets: [sleep_affected_targets.len]"
	. += "Invisibility: [invisibility_level]/[max_invisibility]"
	. += "Stealth Mode: [stealth_mode ? "Active" : "Inactive"]"
	. += "Sleep Deprivation: [sleep_deprivation_intensity]/[max_sleep_deprivation]"
	. += "Stalked Targets: [stalked_targets.len]"
	. += "Nightmare Manipulation: [nightmare_manipulation]/[max_nightmare_manipulation]"
	. += "Sleep Paralysis: [sleep_paralysis_skill]/[max_sleep_paralysis_skill]"
	. += "Dream Invasion: [dream_invasion_level]/[max_dream_invasion_level]"
	. += "Reality Distortion: [reality_distortion]/[max_reality_distortion]"
	. += "Psychological Horror: [psychological_horror]/[max_psychological_horror]"
	. += "Invisibility Evolution: [invisibility_evolution]/[max_invisibility_evolution]"

// Override examine behavior
/mob/living/carbon/scp/scp966/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-966, an invisible creature that causes sleep deprivation.</span>")
		else
			to_chat(user, "<span class='danger'>You feel an overwhelming sense of exhaustion and dread...</span>")

// Override SCP death
/mob/living/carbon/scp/scp966/scp_death()
	visible_message("<span class='danger'>[src] becomes visible as it collapses!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Enhanced verbs
/mob/living/carbon/scp/scp966/verb/drain_sleep()
	set name = "Drain Sleep"
	set category = "SCP"
	set desc = "Drain sleep from nearby targets."

	drain_sleep_ability()

/mob/living/carbon/scp/scp966/verb/toggle_stealth()
	set name = "Toggle Stealth"
	set category = "SCP"
	set desc = "Toggle stealth mode."

	toggle_stealth_ability()

/mob/living/carbon/scp/scp966/verb/stalk_target()
	set name = "Stalk Target"
	set category = "SCP"
	set desc = "Stalk a specific target."

	stalk_target_ability()

/mob/living/carbon/scp/scp966/verb/intensify_deprivation()
	set name = "Intensify Deprivation"
	set category = "SCP"
	set desc = "Intensify sleep deprivation effects."

	intensify_deprivation_ability()

/mob/living/carbon/scp/scp966/verb/view_stalked_targets()
	set name = "View Stalked Targets"
	set category = "SCP"
	set desc = "View your stalking status."

	view_stalked_targets_ability()

/mob/living/carbon/scp/scp966/verb/create_nightmare()
	set name = "Create Nightmare"
	set category = "SCP"
	set desc = "Create a nightmare for a target."

	create_nightmare_ability()

/mob/living/carbon/scp/scp966/verb/sleep_paralysis()
	set name = "Sleep Paralysis"
	set category = "SCP"
	set desc = "Induce sleep paralysis in a target."

	sleep_paralysis_ability()

/mob/living/carbon/scp/scp966/verb/invade_dreams()
	set name = "Invade Dreams"
	set category = "SCP"
	set desc = "Enhance dream invasion abilities."

	invade_dreams_ability()

/mob/living/carbon/scp/scp966/verb/distort_reality()
	set name = "Distort Reality"
	set category = "SCP"
	set desc = "Distort reality for a target."

	distort_reality_ability()

/mob/living/carbon/scp/scp966/verb/psychological_horror()
	set name = "Psychological Horror"
	set category = "SCP"
	set desc = "Induce psychological horror in a target."

	psychological_horror_ability()

/mob/living/carbon/scp/scp966/verb/evolve_invisibility()
	set name = "Evolve Invisibility"
	set category = "SCP"
	set desc = "Evolve your invisibility abilities."

	evolve_invisibility_ability()

/mob/living/carbon/scp/scp966/verb/nightmare_mastery()
	set name = "Nightmare Mastery"
	set category = "SCP"
	set desc = "Unleash nightmare mastery on all nearby targets."

	nightmare_mastery_ability()

// Enhanced persistence data view
/mob/living/carbon/scp/scp966/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-966 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-966 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Sleep Drain Sessions:</b> [sleep_drain_sessions]<br>"
	message += "<b>Stealth Activations:</b> [stealth_activations]<br>"
	message += "<b>Targets Stalked:</b> [targets_stalked]<br>"
	message += "<b>Nightmares Created:</b> [nightmares_created]<br>"
	message += "<b>Sleep Paralysis Events:</b> [sleep_paralysis_events]<br>"
	message += "<b>Dream Invasions:</b> [dream_invasions]<br>"
	message += "<b>Reality Distortions:</b> [reality_distortions]<br>"
	message += "<b>Psychological Horrors:</b> [psychological_horrors]<br>"
	message += "<b>Invisibility Evolutions:</b> [invisibility_evolutions]<br>"
	message += "<b>Affected Targets:</b> [sleep_affected_targets.len]<br>"
	message += "<b>Stalked Targets:</b> [stalked_targets.len]<br>"
	message += "<b>Nightmare Manipulation:</b> [nightmare_manipulation]/[max_nightmare_manipulation]<br>"
	message += "<b>Sleep Paralysis Skill:</b> [sleep_paralysis_skill]/[max_sleep_paralysis_skill]<br>"
	message += "<b>Dream Invasion Level:</b> [dream_invasion_level]/[max_dream_invasion_level]<br>"
	message += "<b>Reality Distortion:</b> [reality_distortion]/[max_reality_distortion]<br>"
	message += "<b>Psychological Horror:</b> [psychological_horror]/[max_psychological_horror]<br>"
	message += "<b>Invisibility Evolution:</b> [invisibility_evolution]/[max_invisibility_evolution]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")
