/mob/living/scp/scp999
	name = "SCP-999"
	desc = "A large, amorphous, gelatinous mass of translucent orange slime. It appears to be friendly and seeks physical contact."
	icon = 'icons/scp/scp-999.dmi'
	icon_state = "scp999"
	real_name = "SCP-999"
	use_custom_sprite = TRUE
	persistence_id = "SCP-999"
	maxHealth = 150
	health = 150

	var/healing_power = 25
	var/healing_cooldown = 0
	var/healing_cooldown_time = 15 SECONDS
	var/list/healed_targets = list()
	var/list/mood_improved_targets = list()
	var/happiness_level = 0
	var/max_happiness = 100
	var/comfort_radius = 3

	var/healing_sessions = 0
	var/mood_improvements = 0
	var/comfort_provided = 0

/mob/living/scp/scp999/Initialize()
	. = ..()

	SCP = new /datum/scp(
		src,
		"SCP-999",
		SCP_SAFE,
		"999",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 15
	SCP.min_time = 20 MINUTES

	max_scp_armor = 25
	scp_armor = max_scp_armor

/mob/living/scp/scp999/Destroy()
	healed_targets = list()
	mood_improved_targets = list()
	return ..()

/mob/living/scp/scp999/process_scp_effects()
	. = ..()

	provide_comfort()

	var/mob/living/carbon/human/target = find_target()
	if(target)
		approach_target(target)

	update_happiness()

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP)
			continue
		award_research_points("999", "behavior", 2, H.ckey)

/mob/living/scp/scp999/proc/provide_comfort()
	if(world.time < healing_cooldown)
		return

	healing_cooldown = world.time + 5 SECONDS

	for(var/mob/living/carbon/human/H in range(comfort_radius, src))
		if(H == src || H.SCP)
			continue

		var/heal_amount = 5
		if(H.health < H.maxHealth)
			H.adjustBruteLoss(-heal_amount)
			H.adjustFireLoss(-heal_amount)
			H.adjustToxLoss(-heal_amount)

		if(!(H.ckey in mood_improved_targets))
			mood_improved_targets += H.ckey
			if(length(mood_improved_targets) > 100)
				mood_improved_targets.Cut(1, 51)
			mood_improvements++
			comfort_provided++
			to_chat(H, "<span class='notice'>You feel a sense of calm and happiness from [src]'s presence.</span>")

/mob/living/scp/scp999/proc/find_target()
	var/mob/living/carbon/human/closest = null
	var/shortest_distance = 999

	for(var/mob/living/carbon/human/H in view(10, src))
		if(H == src || H.SCP)
			continue

		if(H.health < H.maxHealth * 0.8)
			var/distance = get_dist(src, H)
			if(distance < shortest_distance)
				shortest_distance = distance
				closest = H

	return closest

/mob/living/scp/scp999/proc/approach_target(mob/living/carbon/human/target)
	if(!target)
		return

	step_towards(src, target)

	if(get_dist(src, target) <= 1)
		heal_target(target)

/mob/living/scp/scp999/proc/heal_target(mob/living/carbon/human/target)
	if(!target || world.time < healing_cooldown)
		return

	healing_cooldown = world.time + healing_cooldown_time
	var/heal_amount = healing_power

	visible_message("<span class='notice'>[src] gently heals [target]!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 30, TRUE)

	target.adjustBruteLoss(-heal_amount)
	target.adjustFireLoss(-heal_amount)
	target.adjustToxLoss(-heal_amount)

	if(!(target.ckey in healed_targets))
		healed_targets += target.ckey
		if(length(healed_targets) > 100)
			healed_targets.Cut(1, 51)
		healing_sessions++

	to_chat(target, "<span class='notice'>You feel completely healed and rejuvenated!</span>")

	if(target && target.ckey)
		hook_scp_care(target, "SCP-999", "healing")
		hook_scp_interaction(target, "SCP-999", INTERACTION_TYPE_CARE, list("heal_amount" = heal_amount))

	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && H != target && !H.SCP)
			award_research_points("999", "healing", 12, H.ckey)

	add_interaction_record(target, "healing")

/mob/living/scp/scp999/proc/update_happiness()
	if(healing_sessions > 0 || comfort_provided > 0)
		happiness_level = min(max_happiness, happiness_level + 1)

	healing_power = 25 + (happiness_level / 4)

/mob/living/scp/scp999/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		heal_target(H)
		return

	return ..()

/mob/living/scp/scp999/proc/heal_nearby_ability()
	if(world.time < healing_cooldown)
		return

	var/heal_amount = healing_power / 2
	to_chat(src, "<span class='notice'>You heal nearby targets. Healed: [length(healed_targets)]</span>")

	for(var/mob/living/carbon/human/H in range(comfort_radius, src))
		if(H != src && !H.SCP)
			H.adjustBruteLoss(-heal_amount)
			H.adjustFireLoss(-heal_amount)
			H.adjustToxLoss(-heal_amount)
			if(!(H.ckey in healed_targets))
				healed_targets += H.ckey
				healing_sessions++
			to_chat(H, "<span class='notice'>You feel a wave of healing energy from [src]!</span>")

	healing_cooldown = world.time + healing_cooldown_time

/mob/living/scp/scp999/proc/comfort_zone_ability()
	to_chat(src, "<span class='notice'>You create a comfort zone. Comfort provided: [comfort_provided]</span>")

	for(var/mob/living/carbon/human/H in range(comfort_radius, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='notice'>You feel overwhelming comfort and peace...</span>")
			H.adjustBruteLoss(-(healing_power / 2))
			H.adjustFireLoss(-(healing_power / 2))
			H.adjustToxLoss(-(healing_power / 2))

/mob/living/scp/scp999/proc/view_healing_stats_ability()
	var/message = "<h2>SCP-999 Healing Statistics</h2>"
	message += "<b>Healing Power:</b> [healing_power]<br>"
	message += "<b>Happiness Level:</b> [happiness_level]/[max_happiness]<br>"
	message += "<b>Comfort Radius:</b> [comfort_radius]<br>"
	message += "<b>Cooldown:</b> [healing_cooldown_time / 10]s<br>"
	message += "<b>Healed Targets:</b> [length(healed_targets)]<br>"
	message += "<b>Mood Improvements:</b> [length(mood_improved_targets)]<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/living/scp/scp999/get_status_tab_items()
	. = ..()
	. += "Healing Power: [healing_power]"
	. += "Happiness Level: [happiness_level]/[max_happiness]"
	. += "Comfort Radius: [comfort_radius]"
	. += "Healed Targets: [length(healed_targets)]"

/mob/living/scp/scp999/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-999, a friendly gelatinous entity that heals and improves mood.</span>")
		else
			to_chat(user, "<span class='notice'>A friendly orange slime that seems to radiate happiness and healing energy.</span>")

/mob/living/scp/scp999/scp_death()
	visible_message("<span class='danger'>[src] appears to lose its vibrant color and stops moving!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

/mob/living/scp/scp999/proc/heal_nearby()
	heal_nearby_ability()

/mob/living/scp/scp999/proc/comfort_zone()
	comfort_zone_ability()

/mob/living/scp/scp999/proc/view_healing_stats()
	view_healing_stats_ability()

/mob/living/scp/scp999/proc/view_scp999_persistence_data()
	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-999 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Healing Sessions:</b> [healing_sessions]<br>"
	message += "<b>Mood Improvements:</b> [mood_improvements]<br>"
	message += "<b>Comfort Provided:</b> [comfort_provided]<br>"
	message += "<b>Healed Targets:</b> [length(healed_targets)]<br>"
	message += "<b>Mood Improved Targets:</b> [length(mood_improved_targets)]<br>"
	message += "<b>Healing Power:</b> [healing_power]<br>"
	message += "<b>Happiness Level:</b> [happiness_level]/[max_happiness]<br>"
	message += "<b>Comfort Radius:</b> [comfort_radius]<br>"
	message += "<b>Health:</b> [health]/[maxHealth]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [length(instance.interaction_history)] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")
