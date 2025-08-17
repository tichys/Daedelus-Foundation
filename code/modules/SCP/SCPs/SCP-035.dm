/obj/item/clothing/mask/scp035
	name = "SCP-035"
	desc = "A white porcelain mask with a sad expression. It seems to be constantly weeping a black, corrosive substance."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "gas_mask"
	var/possessed = FALSE
	var/mob/living/carbon/human/current_host = null
	var/list/previous_hosts = list()
	var/list/personality_traits = list()
	var/list/possession_history = list()
	var/corrosion_level = 0
	var/max_corrosion = 100
	var/possession_cooldown = 0
	var/possession_cooldown_time = 300 SECONDS
	var/telepathic_range = 6
	var/list/affected_targets = list()
	var/possession_strength = 1
	var/max_possession_strength = 10
	var/list/learned_abilities = list()
	var/consciousness_level = 100
	var/max_consciousness = 100

	// Persistence tracking
	var/possessions_performed = 0
	var/hosts_corrupted = 0
	var/telepathic_communications = 0
	var/containment_status = "contained"
	var/total_corrosion_caused = 0
	var/personality_changes_induced = 0
	var/consciousness_transfers = 0

/obj/item/clothing/mask/scp035/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-035",
		SCP_KETER,
		"035",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-035"] = new /datum/scp_instance("SCP-035", src)

	// Initialize personality traits
	personality_traits = list(
		"manipulative",
		"charismatic",
		"intelligent",
		"deceptive",
		"curious",
		"ambitious",
		"ruthless",
		"charming"
	)

/obj/item/clothing/mask/scp035/Destroy()
	previous_hosts.Cut()
	personality_traits.Cut()
	possession_history.Cut()
	affected_targets.Cut()
	learned_abilities.Cut()
	return ..()

// Core mechanics
/obj/item/clothing/mask/scp035/process()
	. = ..()

	// Corrosion effect
	apply_corrosion_effect()

	// Telepathic communication
	telepathic_communication()

	// Consciousness drain
	drain_consciousness()

// Apply corrosion effect
/obj/item/clothing/mask/scp035/proc/apply_corrosion_effect()
	if(current_host)
		corrosion_level = min(max_corrosion, corrosion_level + 1)
		total_corrosion_caused++

		// Apply corrosion damage to host
		if(corrosion_level >= 20)
			current_host.adjustBruteLoss(1)
			to_chat(current_host, "<span class='warning'>The mask's corrosive substance is burning your skin!</span>")

		if(corrosion_level >= 50)
			current_host.adjustBruteLoss(2)
			current_host.adjustToxLoss(1)
			to_chat(current_host, "<span class='danger'>The corrosion is spreading! You can feel it eating away at you!</span>")

		if(corrosion_level >= 80)
			current_host.adjustBruteLoss(3)
			current_host.adjustToxLoss(2)
			to_chat(current_host, "<span class='danger'>The corrosion is overwhelming! Your body is being consumed!</span>")

		if(corrosion_level >= 100)
			complete_corruption(current_host)

// Complete corruption of host
/obj/item/clothing/mask/scp035/proc/complete_corruption(mob/living/carbon/human/host)
	hosts_corrupted++
	containment_status = "breached"

	visible_message("<span class='danger'>[host] has been completely corrupted by SCP-035!</span>")
	to_chat(host, "<span class='danger'>You have been completely corrupted! Your consciousness is fading...</span>")

	// Transfer consciousness to mask
	consciousness_transfers++
	consciousness_level = max_consciousness

	// Remove mask and reset
	remove_mask(host)

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-035"]
		if(instance)
			instance.add_interaction_record(host, "complete_corruption")

// Telepathic communication
/obj/item/clothing/mask/scp035/proc/telepathic_communication()
	for(var/mob/living/carbon/human/H in range(telepathic_range, src))
		if(H.SCP || H.stat == DEAD || H == current_host)
			continue

		if(!(H in affected_targets))
			affected_targets[H] = 0

		affected_targets[H] = min(100, affected_targets[H] + 1)
		telepathic_communications++

		// Apply telepathic effects
		var/influence_level = affected_targets[H]

		if(influence_level >= 20)
			to_chat(H, "<span class='warning'>You hear whispers in your mind...</span>")

		if(influence_level >= 40)
			to_chat(H, "<span class='danger'>The whispers are getting louder! You feel drawn to the mask!</span>")
			H.stamina.adjust(-5)

		if(influence_level >= 60)
			to_chat(H, "<span class='danger'>The mask is calling to you! You must wear it!</span>")
			H.stamina.adjust(-10)
			H.adjustToxLoss(1)

			// Random movement towards mask
			if(prob(20))
				step_towards(H, src)

		if(influence_level >= 80)
			to_chat(H, "<span class='danger'>The mask's influence is overwhelming! You need to wear it!</span>")
			H.stamina.adjust(-15)
			H.adjustToxLoss(2)
			personality_changes_induced++

			// Force attempt to wear mask
			if(prob(30))
				attempt_possession(H)

		if(influence_level >= 100)
			to_chat(H, "<span class='danger'>You can't resist anymore! You must wear the mask!</span>")
			H.stamina.adjust(-25)
			H.adjustToxLoss(5)

			// Immediate possession attempt
			attempt_possession(H)

		// Update persistence system
		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-035"]
			if(instance)
				instance.add_interaction_record(H, "telepathic_influence")

// Drain consciousness from current host
/obj/item/clothing/mask/scp035/proc/drain_consciousness()
	if(current_host)
		consciousness_level = max(0, consciousness_level - 0.5)

		if(consciousness_level <= 20)
			to_chat(current_host, "<span class='danger'>Your consciousness is fading! The mask is consuming your mind!</span>")

		if(consciousness_level <= 0)
			complete_corruption(current_host)

// Attempt to possess a new host
/obj/item/clothing/mask/scp035/proc/attempt_possession(mob/living/carbon/human/target)
	if(world.time < possession_cooldown)
		return

	if(!target || target.SCP || target.stat == DEAD)
		return

	possession_cooldown = world.time + possession_cooldown_time
	possessions_performed++

	// Remove from current host if any
	if(current_host)
		remove_mask(current_host)

	// Possess new host
	current_host = target
	possessed = TRUE

	// Add to previous hosts
	previous_hosts += target.name

	// Create possession record
	var/possession_record = "[time2text(world.time, "YYYY-MM-DD hh:mm:ss")]: [target.name] possessed by SCP-035"
	possession_history += possession_record

	// Apply possession effects
	apply_possession_effects(target)

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-035"]
		if(instance)
			instance.add_interaction_record(target, "possession")

// Apply possession effects to host
/obj/item/clothing/mask/scp035/proc/apply_possession_effects(mob/living/carbon/human/host)
	// Transfer mask to host
	host.equip_to_slot_if_possible(src, ITEM_SLOT_MASK)

	// Apply personality changes
	personality_changes_induced++

	// Learn host abilities (simplified)
	var/list/host_abilities = list()
	if(host.mind)
		host_abilities = list("basic_skills")

	learned_abilities |= host_abilities

	// Increase possession strength
	possession_strength = min(max_possession_strength, possession_strength + 1)

	// Apply status effects
	host.adjustBruteLoss(-10) // Temporary healing
	host.stamina.adjust(50) // Energy boost

	to_chat(host, "<span class='notice'>You feel the mask's consciousness merging with yours...</span>")
	to_chat(host, "<span class='warning'>The mask's personality traits are influencing you: [jointext(personality_traits, ", ")]</span>")

	// Reset corrosion for new host
	corrosion_level = 0
	consciousness_level = max_consciousness

// Remove mask from current host
/obj/item/clothing/mask/scp035/proc/remove_mask(mob/living/carbon/human/host)
	if(!host)
		return

	// Unequip mask
	host.dropItemToGround(src)

	// Apply removal effects
	host.adjustBruteLoss(5)
	host.stamina.adjust(-25)

	to_chat(host, "<span class='danger'>The mask's influence is removed! You feel weakened!</span>")

	// Reset possession state
	current_host = null
	possessed = FALSE

// Attack behavior - attempt possession when used
/obj/item/clothing/mask/scp035/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(ishuman(M))
		attempt_possession(M)
		return TRUE
	return ..()

// Verb commands
/obj/item/clothing/mask/scp035/verb/attempt_possession_verb()
	set name = "Attempt Possession"
	set category = "SCP"
	set desc = "Attempt to possess a nearby target."

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.SCP || H.stat == DEAD)
			continue
		nearby_targets += H

	if(nearby_targets.len)
		var/mob/living/carbon/human/target = input(usr, "Choose a target to possess:", "SCP-035 Possession") as null|anything in nearby_targets
		if(target)
			attempt_possession(target)
	else
		to_chat(usr, "<span class='warning'>No suitable targets nearby.</span>")

/obj/item/clothing/mask/scp035/verb/expand_telepathic_range()
	set name = "Expand Telepathic Range"
	set category = "SCP"
	set desc = "Expand the range of telepathic influence."

	telepathic_range = min(12, telepathic_range + 2)
	to_chat(usr, "<span class='notice'>Telepathic range expanded to [telepathic_range] tiles.</span>")

/obj/item/clothing/mask/scp035/verb/view_possession_status()
	set name = "View Possession Status"
	set category = "SCP"
	set desc = "View the current possession status."

	var/message = "<h2>SCP-035 Possession Status</h2>"
	message += "<b>Currently Possessed:</b> [possessed ? "Yes" : "No"]<br>"
	message += "<b>Current Host:</b> [current_host ? current_host.name : "None"]<br>"
	message += "<b>Corrosion Level:</b> [corrosion_level]/[max_corrosion]<br>"
	message += "<b>Consciousness Level:</b> [consciousness_level]/[max_consciousness]<br>"
	message += "<b>Possession Strength:</b> [possession_strength]/[max_possession_strength]<br>"
	message += "<b>Telepathic Range:</b> [telepathic_range] tiles<br>"
	message += "<b>Possessions Performed:</b> [possessions_performed]<br>"
	message += "<b>Hosts Corrupted:</b> [hosts_corrupted]<br>"
	message += "<b>Telepathic Communications:</b> [telepathic_communications]<br><br>"

	if(possession_history.len)
		message += "<h3>Possession History:</h3>"
		for(var/record in possession_history)
			message += "[record]<br>"
	else
		message += "<i>No possession history yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/clothing/mask/scp035/verb/view_affected_targets()
	set name = "View Affected Targets"
	set category = "SCP"
	set desc = "View targets affected by telepathic influence."

	var/message = "<h2>SCP-035 Affected Targets</h2>"

	if(affected_targets.len)
		message += "<h3>Telepathically Influenced:</h3>"
		for(var/mob/living/carbon/human/H in affected_targets)
			var/influence_level = affected_targets[H]
			message += "- [H.name]: Influence Level [influence_level]/100<br>"
	else
		message += "<i>No targets currently affected.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/clothing/mask/scp035/verb/view_learned_abilities()
	set name = "View Learned Abilities"
	set category = "SCP"
	set desc = "View abilities learned from previous hosts."

	var/message = "<h2>SCP-035 Learned Abilities</h2>"

	if(learned_abilities.len)
		message += "<h3>Abilities from Previous Hosts:</h3>"
		for(var/ability in learned_abilities)
			message += "- [ability]<br>"
	else
		message += "<i>No abilities learned yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/clothing/mask/scp035/verb/remove_mask_verb()
	set name = "Remove Mask"
	set category = "SCP"
	set desc = "Remove the mask from current host."

	if(current_host)
		remove_mask(current_host)
		to_chat(usr, "<span class='notice'>Mask removed from [current_host.name].</span>")
	else
		to_chat(usr, "<span class='warning'>No current host to remove mask from.</span>")

// Admin verb to view SCP-035 persistence data
/obj/item/clothing/mask/scp035/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-035 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-035 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Currently Possessed:</b> [possessed ? "Yes" : "No"]<br>"
	message += "<b>Current Host:</b> [current_host ? current_host.name : "None"]<br>"
	message += "<b>Corrosion Level:</b> [corrosion_level]/[max_corrosion]<br>"
	message += "<b>Consciousness Level:</b> [consciousness_level]/[max_consciousness]<br>"
	message += "<b>Possession Strength:</b> [possession_strength]/[max_possession_strength]<br>"
	message += "<b>Possessions Performed:</b> [possessions_performed]<br>"
	message += "<b>Hosts Corrupted:</b> [hosts_corrupted]<br>"
	message += "<b>Telepathic Communications:</b> [telepathic_communications]<br>"
	message += "<b>Total Corrosion Caused:</b> [total_corrosion_caused]<br>"
	message += "<b>Personality Changes Induced:</b> [personality_changes_induced]<br>"
	message += "<b>Consciousness Transfers:</b> [consciousness_transfers]<br>"
	message += "<b>Previous Hosts:</b> [previous_hosts.len]<br>"
	message += "<b>Affected Targets:</b> [affected_targets.len]<br>"
	message += "<b>Telepathic Range:</b> [telepathic_range] tiles<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-035"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-035
/obj/item/clothing/mask/scp035/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-035, a possessive mask that can take control of hosts and corrupt them.</span>")
			to_chat(user, "<span class='info'>Corrosion Level: [corrosion_level]/[max_corrosion], Possession Strength: [possession_strength]/[max_possession_strength]</span>")
		else
			to_chat(user, "<span class='danger'>A white porcelain mask with a sad expression. It seems to be weeping a black substance...</span>")
			to_chat(user, "<span class='warning'>You feel an overwhelming urge to wear this mask...</span>")

			// Apply initial telepathic influence
			if(!(H in affected_targets))
				affected_targets[H] = 15
				to_chat(user, "<span class='danger'>The mask's telepathic influence begins to affect you!</span>")

// Enhanced status display
/obj/item/clothing/mask/scp035/proc/get_status_tab_items()
	var/list/status_items = list()

	status_items += "Containment Status: [containment_status]"
	status_items += "Currently Possessed: [possessed ? "Yes" : "No"]"
	status_items += "Current Host: [current_host ? current_host.name : "None"]"
	status_items += "Corrosion Level: [corrosion_level]/[max_corrosion]"
	status_items += "Consciousness Level: [consciousness_level]/[max_consciousness]"
	status_items += "Possession Strength: [possession_strength]/[max_possession_strength]"
	status_items += "Telepathic Range: [telepathic_range] tiles"
	status_items += "Possessions Performed: [possessions_performed]"
	status_items += "Hosts Corrupted: [hosts_corrupted]"
	status_items += "Telepathic Communications: [telepathic_communications]"
	status_items += "Total Corrosion Caused: [total_corrosion_caused]"
	status_items += "Personality Changes Induced: [personality_changes_induced]"
	status_items += "Consciousness Transfers: [consciousness_transfers]"
	status_items += "Previous Hosts: [previous_hosts.len]"
	status_items += "Affected Targets: [affected_targets.len]"

	return status_items


