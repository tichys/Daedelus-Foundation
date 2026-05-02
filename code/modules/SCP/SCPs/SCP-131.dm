// SCP-131 - The Eye Pods
// A pair of small, teardrop-shaped creatures with a single eye each that communicate telepathically

/mob/living/carbon/scp/scp131
	name = "SCP-131"
	desc = "A pair of small, teardrop-shaped creatures with a single eye each. They appear to be communicating telepathically."
	icon = 'icons/scp/SCP-131.dmi'
	icon_state = "scp131"
	real_name = "SCP-131"
	use_custom_sprite = TRUE

	// SCP-131 specific variables
	var/partner = null
	var/telepathy_range = 5
	var/telepathy_cooldown = 0
	var/telepathy_cooldown_time = 5 SECONDS
	var/list/telepathic_messages = list()
	var/list/observed_targets = list()
	var/emotional_state = "curious"
	var/list/emotional_states = list("curious", "excited", "worried", "happy", "sad")

	// Persistence tracking
	var/telepathic_communications = 0
	var/observations_made = 0
	var/partner_interactions = 0

/mob/living/carbon/scp/scp131/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-131",
		SCP_SAFE,
		"131",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 10
	SCP_datum.min_time = 15 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 100
	scp_health = max_scp_health
	max_scp_armor = 20
	scp_armor = max_scp_armor

	// Add SCP abilities
	add_ability("telepathic_message", "telepathic_message_ability")
	add_ability("change_emotional_state", "change_emotional_state_ability")
	add_ability("view_telepathic_log", "view_telepathic_log_ability")

	// Add passive effects
	add_passive_effect("telepathic_communication")
	add_passive_effect("emotional_sensitivity")
	add_passive_effect("partner_bonding")

/mob/living/carbon/scp/scp131/Destroy()
	telepathic_messages = list()
	observed_targets = list()
	return ..()

// Override core mechanics
/mob/living/carbon/scp/scp131/process_scp_effects()
	. = ..()

	// Find partner if not already found
	if(!partner)
		find_partner()

	// Communicate with partner
	if(partner && world.time >= telepathy_cooldown)
		communicate_with_partner()

	// Observe nearby beings
	observe_nearby_beings()

	// Update emotional state
	update_emotional_state()

// Find partner (another SCP-131)
/mob/living/carbon/scp/scp131/proc/find_partner()
	for(var/mob/living/carbon/scp/scp131/other in view(10, src))
		if(other != src && !other.partner)
			partner = other
			other.partner = src
			partner_interactions++

			visible_message("<span class='notice'>[src] and [other] appear to recognize each other!</span>")
			to_chat(src, "<span class='notice'>You have found your partner!</span>")
			to_chat(other, "<span class='notice'>You have found your partner!</span>")

			// Update persistence system
			add_interaction_record(other, "partner_found")
			break

// Communicate with partner
/mob/living/carbon/scp/scp131/proc/communicate_with_partner()
	if(!partner)
		return

	telepathy_cooldown = world.time + telepathy_cooldown_time
	telepathic_communications++

	var/message = generate_telepathic_message()
	telepathic_messages += message

	// Send message to partner
	if(partner)
		to_chat(partner, "<span class='notice'>[src] telepathically: [message]</span>")
		to_chat(src, "<span class='notice'>You telepathically: [message]</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			instance.add_communication_log(message, "telepathic_communication")

// Generate telepathic message based on emotional state
/mob/living/carbon/scp/scp131/proc/generate_telepathic_message()
	var/list/messages = list()

	switch(emotional_state)
		if("curious")
			messages = list("What's that?", "Interesting!", "Let's explore!", "I wonder what that is?")
		if("excited")
			messages = list("This is amazing!", "I love this!", "So much to see!", "Everything is wonderful!")
		if("worried")
			messages = list("I'm scared...", "Something's wrong", "I don't like this", "Help me!")
		if("happy")
			messages = list("I'm so happy!", "Life is beautiful!", "Everything is perfect!", "I love you!")
		if("sad")
			messages = list("I'm sad...", "I miss something", "Why am I here?", "I want to go home...")
		else
			messages = list("Hello!", "Hi there!", "How are you?", "Nice to meet you!")

	return pick(messages)

// Observe nearby beings
/mob/living/carbon/scp/scp131/proc/observe_nearby_beings()
	for(var/mob/living/carbon/human/H in range(telepathy_range, src))
		if(H == src || H.SCP)
			continue

		if(!(H in observed_targets))
			observed_targets += H
			observations_made++

			// React to the observation
			react_to_observation(H)

			// Update persistence system
			add_interaction_record(H, "observation")

// React to observing a being
/mob/living/carbon/scp/scp131/proc/react_to_observation(mob/living/carbon/human/target)
	var/reaction = ""

	if(target.health < target.maxHealth * 0.5)
		emotional_state = "worried"
		reaction = "worried about [target]'s injuries"
	else if(target.health >= target.maxHealth)
		emotional_state = "happy"
		reaction = "happy to see [target] is healthy"
	else
		emotional_state = "curious"
		reaction = "curious about [target]"

	visible_message("<span class='notice'>[src] looks at [target] with [emotional_state] eyes.</span>")
	to_chat(src, "<span class='notice'>You feel [reaction].</span>")

// Update emotional state
/mob/living/carbon/scp/scp131/proc/update_emotional_state()
	// Emotional state can change based on various factors
	if(partner && get_dist(src, partner) <= 2)
		emotional_state = "happy"
	else if(partner && get_dist(src, partner) > 10)
		emotional_state = "worried"
	else if(observations_made > 10)
		emotional_state = "excited"
	else
		emotional_state = "curious"

// Attack behavior (131 doesn't attack, only observes)
/mob/living/carbon/scp/scp131/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		react_to_observation(H)
		return

	return ..()

// SCP-131 specific abilities
/mob/living/carbon/scp/scp131/proc/telepathic_message_ability()
	if(!partner)
		to_chat(src, "<span class='warning'>You don't have a partner to communicate with.</span>")
		return

	if(world.time < telepathy_cooldown)
		to_chat(src, "<span class='warning'>You need to wait before sending another message.</span>")
		return

	var/message = input(src, "Enter your telepathic message:", "Telepathic Message") as text
	if(message)
		telepathic_messages += message
		telepathic_communications++

		to_chat(partner, "<span class='notice'>[src] telepathically: [message]</span>")
		to_chat(src, "<span class='notice'>You telepathically: [message]</span>")

		// Update persistence system
		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
			if(instance)
				instance.add_communication_log(message, "manual_telepathic_communication")

/mob/living/carbon/scp/scp131/proc/change_emotional_state_ability()
	var/new_state = input(src, "Choose your emotional state:", "Emotional State") as null|anything in emotional_states
	if(new_state)
		emotional_state = new_state
		to_chat(src, "<span class='notice'>You are now feeling [emotional_state].</span>")

/mob/living/carbon/scp/scp131/proc/view_telepathic_log_ability()
	var/message = "<h2>SCP-131 Telepathic Log</h2>"
	message += "<b>Total Communications:</b> [telepathic_communications]<br>"
	message += "<b>Current Emotional State:</b> [emotional_state]<br>"
	message += "<b>Partner:</b> [partner ? "Found" : "None"]<br><br>"

	if(length(telepathic_messages))
		message += "<h3>Recent Messages:</h3>"
		var/count = 0
		for(var/msg in telepathic_messages)
			if(count >= 10) // Show only last 10 messages
				break
			message += "[msg]<br>"
			count++
	else
		message += "<i>No telepathic messages yet.</i>"

	to_chat(src, "<span class='notice'>[message]</span>")

// Override status display
/mob/living/carbon/scp/scp131/get_status_tab_items()
	. = ..()
	. += "Emotional State: [emotional_state]"
	. += "Telepathic Communications: [telepathic_communications]"
	. += "Observations Made: [observations_made]"
	. += "Partner Interactions: [partner_interactions]"
	. += "Observed Targets: [observed_targets.len]"
	. += "Partner: [partner ? "Found" : "None"]"

// Override examine behavior
/mob/living/carbon/scp/scp131/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-131, a pair of telepathic eye-pods that observe and communicate.</span>")
		else
			to_chat(user, "<span class='notice'>A small teardrop-shaped creature with a single eye. It seems to be watching you curiously.</span>")

// Override SCP death
/mob/living/carbon/scp/scp131/scp_death()
	visible_message("<span class='danger'>[src] closes its eye and stops moving!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	if(partner)
		to_chat(partner, "<span class='danger'>You feel a deep sadness as your partner is gone!</span>")
		// Note: Partner cleanup handled by partner's own death proc

	..()

// Verb commands
/mob/living/carbon/scp/scp131/verb/telepathic_message()
	set name = "Send Telepathic Message"
	set category = "SCP"
	set desc = "Send a telepathic message to your partner."

	telepathic_message_ability()

/mob/living/carbon/scp/scp131/verb/change_emotional_state()
	set name = "Change Emotional State"
	set category = "SCP"
	set desc = "Change your emotional state."

	change_emotional_state_ability()

/mob/living/carbon/scp/scp131/verb/view_telepathic_log()
	set name = "View Telepathic Log"
	set category = "SCP"
	set desc = "View your telepathic communication log."

	view_telepathic_log_ability()

// Override persistence data view
/mob/living/carbon/scp/scp131/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-131 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-131 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Telepathic Communications:</b> [telepathic_communications]<br>"
	message += "<b>Observations Made:</b> [observations_made]<br>"
	message += "<b>Partner Interactions:</b> [partner_interactions]<br>"
	message += "<b>Current Emotional State:</b> [emotional_state]<br>"
	message += "<b>Observed Targets:</b> [observed_targets.len]<br>"
	message += "<b>Partner:</b> [partner ? "Found" : "None"]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"
			message += "<b>Communication Logs:</b> [instance.communication_logs.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/living/carbon/scp/scp131/proc/on_telepathic_communication(mob/living/carbon/human/target)
	if(!target)
		return
	hook_scp_interaction(target, "SCP-131", INTERACTION_TYPE_COMMUNICATION)

/mob/living/carbon/scp/scp131/proc/on_observation(mob/living/carbon/human/observed)
	if(!observed)
		return
	hook_scp_interaction(observed, "SCP-131", INTERACTION_TYPE_OBSERVATION)
