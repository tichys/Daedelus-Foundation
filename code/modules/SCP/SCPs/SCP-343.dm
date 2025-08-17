// SCP-343 - God
// An entity claiming to be God with reality manipulation and divine powers

/mob/living/carbon/scp/scp343
	name = "SCP-343"
	desc = "An elderly man who claims to be God. He radiates an aura of divine power and benevolence."
	icon = 'icons/scp/scp-343.dmi'
	icon_state = "scp343"
	real_name = "SCP-343"

	// Maximum Enhanced SCP-343 variables
	var/divine_power = 0
	var/max_divine_power = 100
	var/reality_manipulation = 0
	var/max_reality_manipulation = 100
	var/miracle_creation = 0
	var/max_miracle_creation = 100
	var/omnipotence_level = 1
	var/max_omnipotence_level = 10
	var/divine_mastery = 0
	var/max_divine_mastery = 100
	var/reality_mastery = 0
	var/max_reality_mastery = 100
	var/miracle_mastery = 0
	var/max_miracle_mastery = 100
	var/omnipotence_mastery = 0
	var/max_omnipotence_mastery = 100
	var/divine_evolution = 1
	var/max_divine_evolution = 5
	var/divine_cooldown = 0
	var/divine_cooldown_time = 30 SECONDS
	var/reality_cooldown = 0
	var/reality_cooldown_time = 20 SECONDS
	var/miracle_cooldown = 0
	var/miracle_cooldown_time = 45 SECONDS

	// Persistence tracking
	var/miracles_performed = 0
	var/reality_events = 0
	var/divine_events = 0
	var/omnipotence_events = 0
	var/divine_masteries = 0
	var/reality_masteries = 0
	var/miracle_masteries = 0
	var/omnipotence_masteries = 0
	var/evolution_events = 0

/mob/living/carbon/scp/scp343/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-343",
		SCP_SAFE,
		"343",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 40
	SCP_datum.min_time = 90 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 200
	scp_health = max_scp_health
	max_scp_armor = 100
	scp_armor = max_scp_armor

	// Add maximum enhanced abilities
	add_ability("divine_intervention", "divine_intervention_ability")
	add_ability("reality_manipulation", "reality_manipulation_ability")
	add_ability("miracle_creation", "miracle_creation_ability")
	add_ability("omnipotence", "omnipotence_ability")
	add_ability("divine_mastery", "divine_mastery_ability")
	add_ability("reality_mastery", "reality_mastery_ability")
	add_ability("miracle_mastery", "miracle_mastery_ability")
	add_ability("omnipotence_mastery", "omnipotence_mastery_ability")
	add_ability("evolve_divine", "evolve_divine_ability")
	add_ability("divine_blessing", "divine_blessing_ability")
	add_ability("ultimate_divine", "ultimate_divine_ability")
	add_ability("divine_synthesis", "divine_synthesis_ability")

	// Add passive effects
	add_passive_effect("divine_aura")
	add_passive_effect("reality_manipulation")
	add_passive_effect("miracle_creation")
	add_passive_effect("omnipotence")
	add_passive_effect("divine_mastery")
	add_passive_effect("reality_mastery")
	add_passive_effect("miracle_mastery")
	add_passive_effect("omnipotence_mastery")
	add_passive_effect("divine_evolution")

/mob/living/carbon/scp/scp343/Destroy()
	return ..()

// Override core mechanics
/mob/living/carbon/scp/scp343/process_scp_effects()
	. = ..()

	// Process divine powers
	process_divine_powers()

	// Process reality manipulation
	process_reality_manipulation()

	// Process miracle creation
	process_miracle_creation()

	// Process omnipotence
	process_omnipotence()

	// Process divine evolution
	process_divine_evolution()

// Process divine powers
/mob/living/carbon/scp/scp343/proc/process_divine_powers()
	if(divine_power > 0 && prob(1))
		// Create divine effects
		for(var/mob/living/carbon/human/H in range(10, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='notice'>You feel a divine presence surrounding you...</span>")
				H.adjustBruteLoss(-5)
				divine_events++

// Process reality manipulation
/mob/living/carbon/scp/scp343/proc/process_reality_manipulation()
	if(reality_manipulation > 0 && prob(1))
		// Create reality effects
		for(var/mob/living/carbon/human/H in range(8, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='notice'>Reality seems to bend and shift around you...</span>")
				reality_events++

// Process miracle creation
/mob/living/carbon/scp/scp343/proc/process_miracle_creation()
	if(miracle_creation > 0 && prob(1))
		// Create miracle effects
		for(var/mob/living/carbon/human/H in range(6, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='notice'>You witness a miracle occurring...</span>")
				H.adjustBruteLoss(-10)
				H.adjustFireLoss(-10)
				H.adjustToxLoss(-10)
				miracles_performed++

// Process omnipotence
/mob/living/carbon/scp/scp343/proc/process_omnipotence()
	if(omnipotence_level > 1 && prob(1))
		// Create omnipotence effects
		for(var/mob/living/carbon/human/H in range(12, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='notice'>You feel the presence of omnipotent power...</span>")
				omnipotence_events++

// Process divine evolution
/mob/living/carbon/scp/scp343/proc/process_divine_evolution()
	if(divine_power >= max_divine_power && divine_evolution < max_divine_evolution)
		if(prob(1))
			evolve_divine_stage()

// Evolve divine stage
/mob/living/carbon/scp/scp343/proc/evolve_divine_stage()
	divine_evolution = min(max_divine_evolution, divine_evolution + 1)
	evolution_events++

	var/evolution_message = ""
	switch(divine_evolution)
		if(2)
			evolution_message = "Your divine powers have evolved to include reality manipulation!"
		if(3)
			evolution_message = "You can now create miracles and divine interventions!"
		if(4)
			evolution_message = "Your omnipotence has reached new heights!"
		if(5)
			evolution_message = "You have achieved ultimate divine evolution!"

	to_chat(src, "<span class='notice'>[evolution_message] Divine Evolution: [divine_evolution]/[max_divine_evolution]</span>")

// Maximum enhanced abilities
/mob/living/carbon/scp/scp343/proc/divine_intervention_ability()
	to_chat(src, "<span class='notice'>You perform divine intervention. Miracles: [miracles_performed]</span>")

	// Perform divine intervention on all nearby targets
	for(var/mob/living/carbon/human/H in range(10, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='notice'>You experience divine intervention!</span>")
			H.adjustBruteLoss(-50)
			H.adjustFireLoss(-50)
			H.adjustToxLoss(-50)

/mob/living/carbon/scp/scp343/proc/reality_manipulation_ability()
	reality_manipulation = min(max_reality_manipulation, reality_manipulation + 20)
	reality_events++

	to_chat(src, "<span class='notice'>You manipulate reality. Manipulation: [reality_manipulation]/[max_reality_manipulation]</span>")

/mob/living/carbon/scp/scp343/proc/miracle_creation_ability()
	miracle_creation = min(max_miracle_creation, miracle_creation + 20)
	miracles_performed++

	to_chat(src, "<span class='notice'>You create a miracle. Creation: [miracle_creation]/[max_miracle_creation]</span>")

/mob/living/carbon/scp/scp343/proc/omnipotence_ability()
	omnipotence_level = min(max_omnipotence_level, omnipotence_level + 1)
	omnipotence_events++

	to_chat(src, "<span class='notice'>Your omnipotence increases. Level: [omnipotence_level]/[max_omnipotence_level]</span>")

/mob/living/carbon/scp/scp343/proc/divine_mastery_ability()
	if(divine_mastery >= max_divine_mastery)
		to_chat(src, "<span class='warning'>You have reached maximum divine mastery.</span>")
		return

	divine_mastery = min(max_divine_mastery, divine_mastery + 10)
	divine_masteries++

	to_chat(src, "<span class='notice'>Your divine mastery is enhanced. Mastery: [divine_mastery]/[max_divine_mastery]</span>")

/mob/living/carbon/scp/scp343/proc/reality_mastery_ability()
	if(world.time < reality_cooldown)
		to_chat(src, "<span class='warning'>You need time to master reality again.</span>")
		return

	reality_cooldown = world.time + reality_cooldown_time
	reality_mastery = min(max_reality_mastery, reality_mastery + 10)
	reality_masteries++

	to_chat(src, "<span class='notice'>Your reality mastery is enhanced. Mastery: [reality_mastery]/[max_reality_mastery]</span>")

/mob/living/carbon/scp/scp343/proc/miracle_mastery_ability()
	if(world.time < miracle_cooldown)
		to_chat(src, "<span class='warning'>You need time to master miracles again.</span>")
		return

	miracle_cooldown = world.time + miracle_cooldown_time
	miracle_mastery = min(max_miracle_mastery, miracle_mastery + 10)
	miracle_masteries++

	to_chat(src, "<span class='notice'>Your miracle mastery is enhanced. Mastery: [miracle_mastery]/[max_miracle_mastery]</span>")

/mob/living/carbon/scp/scp343/proc/omnipotence_mastery_ability()
	omnipotence_mastery = min(max_omnipotence_mastery, omnipotence_mastery + 10)
	omnipotence_masteries++

	to_chat(src, "<span class='notice'>Your omnipotence mastery is enhanced. Mastery: [omnipotence_mastery]/[max_omnipotence_mastery]</span>")

/mob/living/carbon/scp/scp343/proc/evolve_divine_ability()
	if(divine_evolution >= max_divine_evolution)
		to_chat(src, "<span class='warning'>You have reached maximum divine evolution.</span>")
		return

	if(divine_power < max_divine_power)
		to_chat(src, "<span class='warning'>You need more divine power to evolve.</span>")
		return

	evolve_divine_stage()

/mob/living/carbon/scp/scp343/proc/divine_blessing_ability()
	divine_power = min(max_divine_power, divine_power + 20)
	divine_events++

	to_chat(src, "<span class='notice'>You receive divine blessing. Power: [divine_power]/[max_divine_power]</span>")

/mob/living/carbon/scp/scp343/proc/ultimate_divine_ability()
	if(divine_evolution < max_divine_evolution)
		to_chat(src, "<span class='warning'>You need maximum divine evolution for ultimate divine power.</span>")
		return

	// Ultimate divine affects all nearby targets
	for(var/mob/living/carbon/human/H in range(15, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='notice'>You experience ultimate divine power!</span>")
			H.adjustBruteLoss(-100)
			H.adjustFireLoss(-100)
			H.adjustToxLoss(-100)

	to_chat(src, "<span class='notice'>You perform ultimate divine intervention on all nearby targets.</span>")

/mob/living/carbon/scp/scp343/proc/divine_synthesis_ability()
	if(divine_power < max_divine_power)
		to_chat(src, "<span class='warning'>You need more divine power to synthesize.</span>")
		return

	// Create a powerful divine effect
	for(var/mob/living/carbon/human/H in range(12, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='notice'>You feel overwhelming divine power and benevolence...</span>")

	to_chat(src, "<span class='notice'>You synthesize divine power and affect all nearby targets.</span>")

// Enhanced status display
/mob/living/carbon/scp/scp343/get_status_tab_items()
	. = ..()
	. += "Divine Power: [divine_power]/[max_divine_power]"
	. += "Reality Manipulation: [reality_manipulation]/[max_reality_manipulation]"
	. += "Miracle Creation: [miracle_creation]/[max_miracle_creation]"
	. += "Omnipotence Level: [omnipotence_level]/[max_omnipotence_level]"
	. += "Divine Mastery: [divine_mastery]/[max_divine_mastery]"
	. += "Reality Mastery: [reality_mastery]/[max_reality_mastery]"
	. += "Miracle Mastery: [miracle_mastery]/[max_miracle_mastery]"
	. += "Omnipotence Mastery: [omnipotence_mastery]/[max_omnipotence_mastery]"
	. += "Divine Evolution: [divine_evolution]/[max_divine_evolution]"
	. += "Miracles Performed: [miracles_performed]"

// Override examine behavior
/mob/living/carbon/scp/scp343/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-343, an entity claiming to be God with divine powers.</span>")
		else
			to_chat(user, "<span class='notice'>An elderly man who radiates divine power and benevolence.</span>")

// Override SCP death
/mob/living/carbon/scp/scp343/scp_death()
	visible_message("<span class='danger'>[src] appears to transcend mortal existence!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Enhanced verbs
/mob/living/carbon/scp/scp343/verb/divine_intervention()
	set name = "Divine Intervention"
	set category = "SCP"
	set desc = "Perform divine intervention on nearby targets."

	divine_intervention_ability()

/mob/living/carbon/scp/scp343/verb/reality_manipulation()
	set name = "Reality Manipulation"
	set category = "SCP"
	set desc = "Manipulate reality."

	reality_manipulation_ability()

/mob/living/carbon/scp/scp343/verb/miracle_creation()
	set name = "Miracle Creation"
	set category = "SCP"
	set desc = "Create a miracle."

	miracle_creation_ability()

/mob/living/carbon/scp/scp343/verb/omnipotence()
	set name = "Omnipotence"
	set category = "SCP"
	set desc = "Increase omnipotence level."

	omnipotence_ability()

/mob/living/carbon/scp/scp343/verb/divine_mastery()
	set name = "Divine Mastery"
	set category = "SCP"
	set desc = "Enhance your divine mastery."

	divine_mastery_ability()

/mob/living/carbon/scp/scp343/verb/reality_mastery()
	set name = "Reality Mastery"
	set category = "SCP"
	set desc = "Enhance your reality mastery."

	reality_mastery_ability()

/mob/living/carbon/scp/scp343/verb/miracle_mastery()
	set name = "Miracle Mastery"
	set category = "SCP"
	set desc = "Enhance your miracle mastery."

	miracle_mastery_ability()

/mob/living/carbon/scp/scp343/verb/omnipotence_mastery()
	set name = "Omnipotence Mastery"
	set category = "SCP"
	set desc = "Enhance your omnipotence mastery."

	omnipotence_mastery_ability()

/mob/living/carbon/scp/scp343/verb/evolve_divine()
	set name = "Evolve Divine"
	set category = "SCP"
	set desc = "Evolve your divine capabilities."

	evolve_divine_ability()

/mob/living/carbon/scp/scp343/verb/divine_blessing()
	set name = "Divine Blessing"
	set category = "SCP"
	set desc = "Receive divine blessing."

	divine_blessing_ability()

/mob/living/carbon/scp/scp343/verb/ultimate_divine()
	set name = "Ultimate Divine"
	set category = "SCP"
	set desc = "Perform ultimate divine intervention on all nearby targets."

	ultimate_divine_ability()

/mob/living/carbon/scp/scp343/verb/divine_synthesis()
	set name = "Divine Synthesis"
	set category = "SCP"
	set desc = "Synthesize divine power and affect all nearby targets."

	divine_synthesis_ability()

// Enhanced persistence data view
/mob/living/carbon/scp/scp343/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-343 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-343 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Miracles Performed:</b> [miracles_performed]<br>"
	message += "<b>Reality Events:</b> [reality_events]<br>"
	message += "<b>Divine Events:</b> [divine_events]<br>"
	message += "<b>Omnipotence Events:</b> [omnipotence_events]<br>"
	message += "<b>Divine Masteries:</b> [divine_masteries]<br>"
	message += "<b>Reality Masteries:</b> [reality_masteries]<br>"
	message += "<b>Miracle Masteries:</b> [miracle_masteries]<br>"
	message += "<b>Omnipotence Masteries:</b> [omnipotence_masteries]<br>"
	message += "<b>Evolution Events:</b> [evolution_events]<br>"
	message += "<b>Divine Power:</b> [divine_power]/[max_divine_power]<br>"
	message += "<b>Reality Manipulation:</b> [reality_manipulation]/[max_reality_manipulation]<br>"
	message += "<b>Miracle Creation:</b> [miracle_creation]/[max_miracle_creation]<br>"
	message += "<b>Omnipotence Level:</b> [omnipotence_level]/[max_omnipotence_level]<br>"
	message += "<b>Divine Mastery:</b> [divine_mastery]/[max_divine_mastery]<br>"
	message += "<b>Reality Mastery:</b> [reality_mastery]/[max_reality_mastery]<br>"
	message += "<b>Miracle Mastery:</b> [miracle_mastery]/[max_miracle_mastery]<br>"
	message += "<b>Omnipotence Mastery:</b> [omnipotence_mastery]/[max_omnipotence_mastery]<br>"
	message += "<b>Divine Evolution:</b> [divine_evolution]/[max_divine_evolution]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

