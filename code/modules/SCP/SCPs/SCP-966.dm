// SCP-966 - Sleep Killer
// Foundation-19 style: all mechanics inline, no modular datums.
// Passive: drains drowsyness in radius, causes nightmares, auto-stalks nearby humans.
// Click: attacks drowsy humans with invisible claws.
// Verbs: Toggle Invisibility, Stalk Target (in SCP-966 tab)

/mob/living/scp/scp966
	ai_enabled = TRUE
	name = "SCP-966"
	desc = "An invisible creature that causes sleep deprivation. You can barely make out its shimmering outline."
	icon = 'icons/scp/scp-966.dmi'
	icon_state = "scp966"
	real_name = "SCP-966"
	status_flags = 0

	var/sleep_intensity = 1
	var/max_sleep_intensity = 5
	var/sleep_drain_interval = 10 SECONDS
	var/next_sleep_drain = 0
	var/sleep_effect_radius = 5

	var/stealth_active = TRUE
	var/next_stealth_toggle = 0
	var/stealth_toggle_interval = 20 SECONDS

	var/list/stalked_targets = list()
	var/next_stalk_scan = 0
	var/stalk_scan_interval = 15 SECONDS

	var/next_nightmare = 0
	var/nightmare_interval = 30 SECONDS

	var/next_research = 0
	var/research_interval = 40 SECONDS

	var/victims_sleep_deprived = 0
	var/nightmares_caused = 0

/mob/living/scp/scp966/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Sleep Killer", SCP_EUCLID, "966", SCP_PLAYABLE)
	SCP.min_playercount = 25
	SCP.min_time = 10 MINUTES
	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/scp/scp966/proc/verb_toggle_invisibility,
		/mob/living/scp/scp966/proc/verb_stalk_target,
	))

/mob/living/scp/scp966/Life()
	. = ..()
	if(stat == DEAD)
		return
	ProcessSleepDrain()
	ProcessStealth()
	ProcessStalking()
	ProcessNightmares()
	ProcessResearch()

/mob/living/scp/scp966/proc/ProcessSleepDrain()
	if(world.time < next_sleep_drain)
		return
	next_sleep_drain = world.time + sleep_drain_interval
	for(var/mob/living/carbon/human/H in range(sleep_effect_radius, src))
		if(H == src || H.stat == DEAD)
			continue
		H.adjust_drowsyness(sleep_intensity * 2)
		if(prob(30))
			to_chat(H, span_warning("An oppressive exhaustion presses upon you. Your eyelids feel heavy."))
		if(H.drowsyness >= 60 && prob(15))
			H.AdjustSleeping(20)
			to_chat(H, span_warning("You can't keep your eyes open any longer..."))
			victims_sleep_deprived++

/mob/living/scp/scp966/proc/ProcessStealth()
	if(world.time > next_stealth_toggle && prob(10))
		next_stealth_toggle = world.time + stealth_toggle_interval
		stealth_active = !stealth_active
		if(!stealth_active && prob(30))
			visible_message(span_notice("A shimmer reveals something in the air, then fades."))

/mob/living/scp/scp966/proc/ProcessStalking()
	if(world.time < next_stalk_scan)
		return
	next_stalk_scan = world.time + stalk_scan_interval
	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in view(6, src))
		if(H != src && H.stat != DEAD)
			candidates += H
	if(length(candidates))
		var/mob/living/carbon/human/choice = pick(candidates)
		if(!(choice in stalked_targets))
			stalked_targets += choice
			to_chat(choice, span_danger("You feel an unseen gaze upon you..."))

/mob/living/scp/scp966/proc/ProcessNightmares()
	if(world.time < next_nightmare)
		return
	next_nightmare = world.time + nightmare_interval
	if(prob(15))
		var/list/victims = list()
		for(var/mob/living/carbon/human/H in view(4, src))
			if(H != src && H.stat != DEAD)
				victims += H
		if(length(victims))
			var/mob/living/carbon/human/v = pick(victims)
			to_chat(v, span_danger("A waking nightmare grips you with dread."))
			v.adjust_drowsyness(8)
			v.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
			nightmares_caused++

/mob/living/scp/scp966/proc/ProcessResearch()
	if(world.time < next_research)
		return
	next_research = world.time
	SCP?.award_research(null, "sleep_deprivation_phenomena", 8)

/mob/living/scp/scp966/UnarmedAttack(atom/A)
	if(!ishuman(A))
		return ..()
	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD)
		return ..()
	if(H.drowsyness >= 30)
		H.apply_damage(sleep_intensity * 3, BRUTE)
		H.visible_message(span_danger("Something invisible slashes at [H]!"), span_danger("You feel claws tear into you!"))
		hook_scp_combat(H, "SCP-966", sleep_intensity * 3, 10)
		return
	to_chat(src, span_warning("[H] is too alert to attack effectively. Weaken them first with sleep deprivation."))

/mob/living/scp/scp966/proc/verb_toggle_invisibility()
	set name = "Toggle Invisibility"
	set category = "SCP-966"
	stealth_active = !stealth_active
	to_chat(src, span_notice(stealth_active ? "You fade into the shadows." : "You become more visible."))

/mob/living/scp/scp966/proc/action_toggle_invisibility()
	verb_toggle_invisibility()

/mob/living/scp/scp966/proc/verb_stalk_target()
	set name = "Stalk Target"
	set category = "SCP-966"
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(15, src))
		if(H.stat != DEAD && H != src)
			targets += H
	if(!length(targets))
		to_chat(src, span_warning("No valid targets nearby."))
		return
	var/mob/living/carbon/human/target = input(src, "Choose target to stalk:", "Stalk") as null|anything in targets
	if(!target)
		return
	if(!(target in stalked_targets))
		stalked_targets += target
		hook_scp_interaction(target, "SCP-966", INTERACTION_TYPE_OBSERVATION)
		to_chat(target, span_danger("You feel an unseen gaze upon you..."))

/mob/living/scp/scp966/proc/action_stalk_target()
	verb_stalk_target()

/mob/living/scp/scp966/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(H, span_warning("SCP-966: A sleep-inducing predator. Victims suffer extreme sleep deprivation before being attacked."))
		else
			var/can_see = FALSE
			if(istype(H.glasses, /obj/item/clothing/glasses/night))
				can_see = TRUE
			if(H.has_quirk(/datum/quirk/item_quirk/nearsighted))
				can_see = FALSE
			if(can_see)
				to_chat(H, span_warning("Through your lenses, you can make out a thin, skeletal figure crouching in the air..."))
			else
				to_chat(H, span_warning("You can barely see something shimmering in the air..."))

/mob/living/scp/scp966/get_status_tab_items()
	. = ..()
	. += "Victims Deprived: [victims_sleep_deprived]"
	. += "Stalked Targets: [length(stalked_targets)]"
	. += "Nightmares Caused: [nightmares_caused]"
	. += "Sleep Intensity: [sleep_intensity]/[max_sleep_intensity]"
	. += "Invisible: [stealth_active ? "Yes" : "No"]"
