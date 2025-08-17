/obj/item/reagent_containers/pill/scp500
	name = "SCP-500"
	desc = "A small red pill that appears to cure any disease or ailment when consumed."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "pill"
	var/healing_power = 100
	var/max_healing_power = 100
	var/list/cured_diseases = list()
	var/list/cured_targets = list()
	var/list/healing_history = list()
	var/cure_cooldown = 0
	var/cure_cooldown_time = 30 SECONDS
	var/healing_radius = 3
	var/list/affected_targets = list()
	var/healing_efficiency = 1.0
	var/max_efficiency = 2.0
	var/list/known_cures = list()
	var/cure_research_progress = 0
	var/max_research_progress = 100

	// Persistence tracking
	var/cures_performed = 0
	var/diseases_cured = 0
	var/targets_healed = 0
	var/containment_status = "contained"
	var/total_healing_power_used = 0
	var/cure_breakthroughs = 0
	var/healing_masterpieces = 0

/obj/item/reagent_containers/pill/scp500/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-500",
		SCP_SAFE,
		"500",
		SCP_DISABLED
	)

	SCP.min_playercount = 5
	SCP.min_time = 10 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-500"] = new /datum/scp_instance("SCP-500", src)

/obj/item/reagent_containers/pill/scp500/Destroy()
	cured_diseases = list()
	cured_targets = list()
	healing_history = list()
	affected_targets = list()
	known_cures = list()
	return ..()

// Core mechanics
/obj/item/reagent_containers/pill/scp500/process()
	. = ..()

	// Passive healing aura
	apply_healing_aura()

	// Research progress
	update_cure_research()

// Apply healing aura to nearby targets
/obj/item/reagent_containers/pill/scp500/proc/apply_healing_aura()
	for(var/mob/living/carbon/human/H in range(healing_radius, src))
		if(H.SCP || H.stat == DEAD)
			continue

		if(!(H in affected_targets))
			affected_targets[H] = 0

		affected_targets[H] = min(100, affected_targets[H] + 1)

		// Apply passive healing effects
		var/healing_strength = healing_efficiency * 0.5

		if(H.health < H.maxHealth)
			H.adjustBruteLoss(-healing_strength)
			H.adjustFireLoss(-healing_strength)
			H.adjustToxLoss(-healing_strength)
			H.stamina.adjust(healing_strength * 2)

		// Cure minor ailments (simplified)
		if(H.health < H.maxHealth * 0.8 && prob(5))
			cure_minor_ailment(H)

// Cure minor ailment
/obj/item/reagent_containers/pill/scp500/proc/cure_minor_ailment(mob/living/carbon/human/target)
	if(!target)
		return

	// Cure minor health issues (simplified)
	if(target.health < target.maxHealth)
		target.adjustBruteLoss(-10)
		target.adjustFireLoss(-10)
		target.adjustToxLoss(-10)
		cured_diseases += "minor_injury"
		diseases_cured++

		to_chat(target, "<span class='notice'>You feel a minor ailment being cured by SCP-500's aura.</span>")

		// Update persistence system
		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-500"]
			if(instance)
				instance.add_interaction_record(target, "minor_cure")

// Update cure research progress
/obj/item/reagent_containers/pill/scp500/proc/update_cure_research()
	if(cure_research_progress < max_research_progress)
		cure_research_progress += 0.1

		// Research breakthrough
		if(cure_research_progress >= 25 && !("basic_healing" in known_cures))
			known_cures += "basic_healing"
			cure_breakthroughs++
			world.log << "SCP-500: Basic healing cure discovered"

		if(cure_research_progress >= 50 && !("disease_cure" in known_cures))
			known_cures += "disease_cure"
			cure_breakthroughs++
			world.log << "SCP-500: Disease cure discovered"

		if(cure_research_progress >= 75 && !("regeneration" in known_cures))
			known_cures += "regeneration"
			cure_breakthroughs++
			world.log << "SCP-500: Regeneration cure discovered"

		if(cure_research_progress >= 100 && !("immortality" in known_cures))
			known_cures += "immortality"
			cure_breakthroughs++
			healing_masterpieces++
			world.log << "SCP-500: Immortality cure discovered!"

// Attempt to cure a target
/obj/item/reagent_containers/pill/scp500/proc/attempt_cure(mob/living/carbon/human/target)
	if(world.time < cure_cooldown)
		return FALSE

	if(!target || target.SCP || target.stat == DEAD)
		return FALSE

	cure_cooldown = world.time + cure_cooldown_time
	cures_performed++
	total_healing_power_used += healing_power

	// Create healing record
	var/healing_record = "[time2text(world.time, "YYYY-MM-DD hh:mm:ss")]: [target.name] cured by SCP-500"
	healing_history += healing_record

	// Apply comprehensive healing
	apply_comprehensive_healing(target)

	// Add to cured targets
	if(!(target in cured_targets))
		cured_targets += target

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-500"]
		if(instance)
			instance.add_interaction_record(target, "comprehensive_cure")

	return TRUE

// Apply comprehensive healing to target
/obj/item/reagent_containers/pill/scp500/proc/apply_comprehensive_healing(mob/living/carbon/human/target)
	if(!target)
		return

	// Full health restoration
	target.adjustBruteLoss(-target.getBruteLoss())
	target.adjustFireLoss(-target.getFireLoss())
	target.adjustToxLoss(-target.getToxLoss())
	target.stamina.adjust(100)

	// Cure all health issues (simplified)
	var/diseases_cured_count = 0
	if(target.health < target.maxHealth)
		diseases_cured_count++
		cured_diseases += "health_restoration"
		diseases_cured++

	// Remove all status effects (simplified)
	// Note: Trait and mood systems would be implemented here

	// Apply regeneration effect
	apply_regeneration_effect(target)

	// Create healing effect
	create_healing_effect(target)

	to_chat(target, "<span class='notice'>You feel completely healed and rejuvenated by SCP-500!</span>")

	if(diseases_cured_count > 0)
		to_chat(target, "<span class='notice'>[diseases_cured_count] disease(s) have been cured.</span>")

// Apply regeneration effect
/obj/item/reagent_containers/pill/scp500/proc/apply_regeneration_effect(mob/living/carbon/human/target)
	if(!target)
		return

	// Apply regeneration effect (simplified)
	to_chat(target, "<span class='notice'>You feel a regenerative effect taking hold!</span>")

	// Temporary regeneration effect
	spawn(300) // 30 seconds
		if(target)
			target.adjustBruteLoss(-5)
			target.adjustFireLoss(-5)
			target.adjustToxLoss(-5)
			to_chat(target, "<span class='notice'>The regenerative effect fades.</span>")

// Create healing effect
/obj/item/reagent_containers/pill/scp500/proc/create_healing_effect(mob/living/carbon/human/target)
	// Visual effect
	playsound(target, 'sound/weapons/punch1.ogg', 30, TRUE)

	// Create healing particles
	for(var/i = 1 to 5)
		spawn(i * 5)
			var/list/directions = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			var/direction = pick(directions)
			var/turf/T = get_step(target, direction)
			if(T)
				playsound(T, 'sound/weapons/punch1.ogg', 20, TRUE)

// Attack behavior - attempt cure when used
/obj/item/reagent_containers/pill/scp500/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(ishuman(M))
		if(attempt_cure(M))
			visible_message("<span class='notice'>[user] administers SCP-500 to [M].</span>")
			qdel(src) // Consume the pill
			return TRUE
		else
			to_chat(user, "<span class='warning'>SCP-500 is on cooldown or target is invalid.</span>")
			return TRUE
	return ..()

// Verb commands
/obj/item/reagent_containers/pill/scp500/verb/attempt_cure_verb()
	set name = "Attempt Cure"
	set category = "SCP"
	set desc = "Attempt to cure a nearby target."

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.SCP || H.stat == DEAD)
			continue
		nearby_targets += H

	if(nearby_targets.len)
		var/mob/living/carbon/human/target = input(usr, "Choose a target to cure:", "SCP-500 Cure") as null|anything in nearby_targets
		if(target)
			if(attempt_cure(target))
				to_chat(usr, "<span class='notice'>[target.name] has been cured!</span>")
				qdel(src) // Consume the pill
			else
				to_chat(usr, "<span class='warning'>Failed to cure [target.name].</span>")
	else
		to_chat(usr, "<span class='warning'>No suitable targets nearby.</span>")

/obj/item/reagent_containers/pill/scp500/verb/expand_healing_radius()
	set name = "Expand Healing Radius"
	set category = "SCP"
	set desc = "Expand the radius of healing aura effects."

	healing_radius = min(8, healing_radius + 1)
	to_chat(usr, "<span class='notice'>Healing radius expanded to [healing_radius] tiles.</span>")

/obj/item/reagent_containers/pill/scp500/verb/view_healing_status()
	set name = "View Healing Status"
	set category = "SCP"
	set desc = "View the current healing status."

	var/message = "<h2>SCP-500 Healing Status</h2>"
	message += "<b>Healing Power:</b> [healing_power]/[max_healing_power]<br>"
	message += "<b>Healing Efficiency:</b> [healing_efficiency]/[max_efficiency]<br>"
	message += "<b>Healing Radius:</b> [healing_radius] tiles<br>"
	message += "<b>Cure Research Progress:</b> [cure_research_progress]/[max_research_progress]<br>"
	message += "<b>Cures Performed:</b> [cures_performed]<br>"
	message += "<b>Diseases Cured:</b> [diseases_cured]<br>"
	message += "<b>Targets Healed:</b> [targets_healed]<br>"
	message += "<b>Total Healing Power Used:</b> [total_healing_power_used]<br>"
	message += "<b>Cure Breakthroughs:</b> [cure_breakthroughs]<br>"
	message += "<b>Healing Masterpieces:</b> [healing_masterpieces]<br><br>"

	if(healing_history.len)
		message += "<h3>Recent Healings:</h3>"
		for(var/i = max(1, healing_history.len - 5) to healing_history.len)
			message += "[healing_history[i]]<br>"
	else
		message += "<i>No healing history yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/reagent_containers/pill/scp500/verb/view_cured_targets()
	set name = "View Cured Targets"
	set category = "SCP"
	set desc = "View targets that have been cured."

	var/message = "<h2>SCP-500 Cured Targets</h2>"

	if(cured_targets.len)
		message += "<h3>Successfully Cured:</h3>"
		for(var/mob/living/carbon/human/H in cured_targets)
			message += "- [H.name]<br>"
	else
		message += "<i>No targets cured yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/reagent_containers/pill/scp500/verb/view_known_cures()
	set name = "View Known Cures"
	set category = "SCP"
	set desc = "View cures that have been discovered through research."

	var/message = "<h2>SCP-500 Known Cures</h2>"

	if(known_cures.len)
		message += "<h3>Discovered Cures:</h3>"
		for(var/cure in known_cures)
			message += "- [cure]<br>"
	else
		message += "<i>No cures discovered yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/reagent_containers/pill/scp500/verb/boost_healing_efficiency()
	set name = "Boost Healing Efficiency"
	set category = "SCP"
	set desc = "Boost the healing efficiency temporarily."

	healing_efficiency = min(max_efficiency, healing_efficiency + 0.2)
	to_chat(usr, "<span class='notice'>Healing efficiency boosted to [healing_efficiency].</span>")

// Admin verb to view SCP-500 persistence data
/obj/item/reagent_containers/pill/scp500/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-500 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-500 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Healing Power:</b> [healing_power]/[max_healing_power]<br>"
	message += "<b>Healing Efficiency:</b> [healing_efficiency]/[max_efficiency]<br>"
	message += "<b>Healing Radius:</b> [healing_radius] tiles<br>"
	message += "<b>Cure Research Progress:</b> [cure_research_progress]/[max_research_progress]<br>"
	message += "<b>Cures Performed:</b> [cures_performed]<br>"
	message += "<b>Diseases Cured:</b> [diseases_cured]<br>"
	message += "<b>Targets Healed:</b> [targets_healed]<br>"
	message += "<b>Total Healing Power Used:</b> [total_healing_power_used]<br>"
	message += "<b>Cure Breakthroughs:</b> [cure_breakthroughs]<br>"
	message += "<b>Healing Masterpieces:</b> [healing_masterpieces]<br>"
	message += "<b>Cured Targets:</b> [cured_targets.len]<br>"
	message += "<b>Affected Targets:</b> [affected_targets.len]<br>"
	message += "<b>Known Cures:</b> [known_cures.len]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-500"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-500
/obj/item/reagent_containers/pill/scp500/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-500, a miraculous healing pill that can cure any disease or ailment.</span>")
			to_chat(user, "<span class='info'>Healing Power: [healing_power]/[max_healing_power], Efficiency: [healing_efficiency]/[max_efficiency]</span>")
		else
			to_chat(user, "<span class='danger'>A small red pill that seems to radiate healing energy...</span>")
			to_chat(user, "<span class='warning'>You feel drawn to consume this pill...</span>")

			// Apply initial healing aura effect
			if(!(H in affected_targets))
				affected_targets[H] = 10
				to_chat(user, "<span class='notice'>You feel a gentle healing aura emanating from the pill.</span>")

// Enhanced status display
/obj/item/reagent_containers/pill/scp500/proc/get_status_tab_items()
	var/list/status_items = list()

	status_items += "Containment Status: [containment_status]"
	status_items += "Healing Power: [healing_power]/[max_healing_power]"
	status_items += "Healing Efficiency: [healing_efficiency]/[max_efficiency]"
	status_items += "Healing Radius: [healing_radius] tiles"
	status_items += "Cure Research Progress: [cure_research_progress]/[max_research_progress]"
	status_items += "Cures Performed: [cures_performed]"
	status_items += "Diseases Cured: [diseases_cured]"
	status_items += "Targets Healed: [targets_healed]"
	status_items += "Total Healing Power Used: [total_healing_power_used]"
	status_items += "Cure Breakthroughs: [cure_breakthroughs]"
	status_items += "Healing Masterpieces: [healing_masterpieces]"
	status_items += "Cured Targets: [cured_targets.len]"
	status_items += "Affected Targets: [affected_targets.len]"
	status_items += "Known Cures: [known_cures.len]"

	return status_items


