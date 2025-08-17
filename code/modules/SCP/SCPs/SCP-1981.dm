// SCP-1981 - RONALD REAGAN CUT UP WHILE TALKING
// A video recording that causes reality distortion and temporal effects

/obj/item/scp1981
	name = "SCP-1981"
	desc = "A video recording that appears to show Ronald Reagan being cut up while talking."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "scp1981"
	w_class = WEIGHT_CLASS_SMALL

	// Maximum Enhanced SCP-1981 variables
	var/video_manipulation = 0
	var/max_video_manipulation = 100
	var/reality_distortion = 0
	var/max_reality_distortion = 100
	var/temporal_effects = 0
	var/max_temporal_effects = 100
	var/video_evolution = 1
	var/max_video_evolution = 5
	var/distortion_potency = 1
	var/max_distortion_potency = 10
	var/temporal_mastery = 0
	var/max_temporal_mastery = 100
	var/video_cooldown = 0
	var/video_cooldown_time = 30 SECONDS
	var/reality_cooldown = 0
	var/reality_cooldown_time = 20 SECONDS
	var/temporal_cooldown = 0
	var/temporal_cooldown_time = 45 SECONDS

	// Persistence tracking
	var/video_events = 0
	var/reality_events = 0
	var/temporal_events = 0
	var/distortion_events = 0
	var/video_masteries = 0
	var/reality_masteries = 0
	var/temporal_masteries = 0
	var/evolution_events = 0

/obj/item/scp1981/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-1981",
		SCP_EUCLID,
		"1981",

	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-1981"] = new /datum/scp_instance("SCP-1981", src)

/obj/item/scp1981/Destroy()
	return ..()

// Core mechanics
/obj/item/scp1981/process()
	. = ..()

	// Process video manipulation
	process_video_manipulation()

	// Process reality distortion
	process_reality_distortion()

	// Process temporal effects
	process_temporal_effects()

	// Process video evolution
	process_video_evolution()

// Process video manipulation
/obj/item/scp1981/proc/process_video_manipulation()
	if(video_manipulation > 0 && prob(1))
		// Create video effects
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>You see disturbing video imagery...</span>")
				video_events++

// Process reality distortion
/obj/item/scp1981/proc/process_reality_distortion()
	if(reality_distortion > 0 && prob(1))
		// Create reality effects
		for(var/mob/living/carbon/human/H in range(4, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>Reality seems to distort around you...</span>")
				reality_events++

// Process temporal effects
/obj/item/scp1981/proc/process_temporal_effects()
	if(temporal_effects > 0 && prob(1))
		// Create temporal effects
		for(var/mob/living/carbon/human/H in range(6, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>Time seems to behave strangely...</span>")
				temporal_events++

// Process video evolution
/obj/item/scp1981/proc/process_video_evolution()
	if(video_manipulation >= max_video_manipulation && video_evolution < max_video_evolution)
		if(prob(1))
			evolve_video_stage()

// Evolve video stage
/obj/item/scp1981/proc/evolve_video_stage()
	video_evolution = min(max_video_evolution, video_evolution + 1)
	evolution_events++

	var/evolution_message = ""
	switch(video_evolution)
		if(2)
			evolution_message = "SCP-1981 evolves enhanced video manipulation!"
		if(3)
			evolution_message = "SCP-1981 evolves reality distortion abilities!"
		if(4)
			evolution_message = "SCP-1981 evolves temporal manipulation powers!"
		if(5)
			evolution_message = "SCP-1981 achieves ultimate video evolution!"

	visible_message("<span class='danger'>[evolution_message]</span>")

// Maximum enhanced abilities
/obj/item/scp1981/proc/video_manipulation_ability()
	video_manipulation = min(max_video_manipulation, video_manipulation + 20)
	video_events++

	to_chat(usr, "<span class='notice'>SCP-1981 manipulates video. Manipulation: [video_manipulation]/[max_video_manipulation]</span>")

/obj/item/scp1981/proc/reality_distortion_ability()
	if(world.time < reality_cooldown)
		to_chat(usr, "<span class='warning'>SCP-1981 needs time to distort reality again.</span>")
		return

	reality_cooldown = world.time + reality_cooldown_time
	reality_distortion = min(max_reality_distortion, reality_distortion + 20)
	reality_events++

	to_chat(usr, "<span class='notice'>SCP-1981 distorts reality. Distortion: [reality_distortion]/[max_reality_distortion]</span>")

/obj/item/scp1981/proc/temporal_effects_ability()
	if(world.time < temporal_cooldown)
		to_chat(usr, "<span class='warning'>SCP-1981 needs time to create temporal effects again.</span>")
		return

	temporal_cooldown = world.time + temporal_cooldown_time
	temporal_effects = min(max_temporal_effects, temporal_effects + 20)
	temporal_events++

	to_chat(usr, "<span class='notice'>SCP-1981 creates temporal effects. Effects: [temporal_effects]/[max_temporal_effects]</span>")

/obj/item/scp1981/proc/distortion_potency_ability()
	if(distortion_potency >= max_distortion_potency)
		to_chat(usr, "<span class='warning'>SCP-1981 has reached maximum distortion potency.</span>")
		return

	distortion_potency = min(max_distortion_potency, distortion_potency + 1)
	distortion_events++

	to_chat(usr, "<span class='notice'>SCP-1981's distortion potency increases. Potency: [distortion_potency]/[max_distortion_potency]</span>")

/obj/item/scp1981/proc/temporal_mastery_ability()
	if(temporal_mastery >= max_temporal_mastery)
		to_chat(usr, "<span class='warning'>SCP-1981 has reached maximum temporal mastery.</span>")
		return

	temporal_mastery = min(max_temporal_mastery, temporal_mastery + 10)
	temporal_masteries++

	to_chat(usr, "<span class='notice'>SCP-1981's temporal mastery is enhanced. Mastery: [temporal_mastery]/[max_temporal_mastery]</span>")

/obj/item/scp1981/proc/evolve_video_ability()
	if(video_evolution >= max_video_evolution)
		to_chat(usr, "<span class='warning'>SCP-1981 has reached maximum evolution.</span>")
		return

	if(video_manipulation < max_video_manipulation)
		to_chat(usr, "<span class='warning'>SCP-1981 needs more video manipulation to evolve.</span>")
		return

	evolve_video_stage()

/obj/item/scp1981/proc/ultimate_video_ability()
	if(video_evolution < max_video_evolution)
		to_chat(usr, "<span class='warning'>SCP-1981 needs maximum evolution for ultimate video.</span>")
		return

	// Ultimate video affects all nearby targets
	for(var/mob/living/carbon/human/H in range(10, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='danger'>You experience SCP-1981's ultimate video manipulation!</span>")
			H.adjustBruteLoss(50)

	to_chat(usr, "<span class='notice'>SCP-1981 performs ultimate video manipulation on all nearby targets.</span>")

/obj/item/scp1981/proc/video_synthesis_ability()
	if(video_manipulation < max_video_manipulation)
		to_chat(usr, "<span class='warning'>SCP-1981 needs more video manipulation to synthesize.</span>")
		return

	// Create a powerful video effect
	for(var/mob/living/carbon/human/H in range(8, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='danger'>You feel overwhelming video distortion and reality warping...</span>")

	to_chat(usr, "<span class='notice'>SCP-1981 synthesizes video and affects all nearby targets.</span>")

// Enhanced status display
/obj/item/scp1981/proc/get_video_status()
	var/message = "<h2>SCP-1981 Video Status</h2>"
	message += "<b>Video Manipulation:</b> [video_manipulation]/[max_video_manipulation]<br>"
	message += "<b>Reality Distortion:</b> [reality_distortion]/[max_reality_distortion]<br>"
	message += "<b>Temporal Effects:</b> [temporal_effects]/[max_temporal_effects]<br>"
	message += "<b>Video Evolution:</b> [video_evolution]/[max_video_evolution]<br>"
	message += "<b>Distortion Potency:</b> [distortion_potency]/[max_distortion_potency]<br>"
	message += "<b>Temporal Mastery:</b> [temporal_mastery]/[max_temporal_mastery]<br>"

	return message

// Enhanced verbs
/obj/item/scp1981/verb/video_manipulation()
	set name = "Video Manipulation"
	set category = "SCP-1981"
	set desc = "Manipulate video with SCP-1981."

	video_manipulation_ability()

/obj/item/scp1981/verb/reality_distortion()
	set name = "Reality Distortion"
	set category = "SCP-1981"
	set desc = "Distort reality with SCP-1981."

	reality_distortion_ability()

/obj/item/scp1981/verb/temporal_effects()
	set name = "Temporal Effects"
	set category = "SCP-1981"
	set desc = "Create temporal effects with SCP-1981."

	temporal_effects_ability()

/obj/item/scp1981/verb/distortion_potency()
	set name = "Distortion Potency"
	set category = "SCP-1981"
	set desc = "Increase SCP-1981's distortion potency."

	distortion_potency_ability()

/obj/item/scp1981/verb/temporal_mastery()
	set name = "Temporal Mastery"
	set category = "SCP-1981"
	set desc = "Enhance SCP-1981's temporal mastery."

	temporal_mastery_ability()

/obj/item/scp1981/verb/evolve_video()
	set name = "Evolve Video"
	set category = "SCP-1981"
	set desc = "Evolve SCP-1981's video capabilities."

	evolve_video_ability()

/obj/item/scp1981/verb/ultimate_video()
	set name = "Ultimate Video"
	set category = "SCP-1981"
	set desc = "Perform ultimate video manipulation on all nearby targets."

	ultimate_video_ability()

/obj/item/scp1981/verb/video_synthesis()
	set name = "Video Synthesis"
	set category = "SCP-1981"
	set desc = "Synthesize video and affect all nearby targets."

	video_synthesis_ability()

// Admin verb to view SCP-1981 persistence data
/obj/item/scp1981/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP-1981"
	set desc = "View SCP-1981 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-1981 Persistence Data</h2>"
	message += "<b>Video Events:</b> [video_events]<br>"
	message += "<b>Reality Events:</b> [reality_events]<br>"
	message += "<b>Temporal Events:</b> [temporal_events]<br>"
	message += "<b>Distortion Events:</b> [distortion_events]<br>"
	message += "<b>Video Masteries:</b> [video_masteries]<br>"
	message += "<b>Reality Masteries:</b> [reality_masteries]<br>"
	message += "<b>Temporal Masteries:</b> [temporal_masteries]<br>"
	message += "<b>Evolution Events:</b> [evolution_events]<br>"
	message += "<b>Video Manipulation:</b> [video_manipulation]/[max_video_manipulation]<br>"
	message += "<b>Reality Distortion:</b> [reality_distortion]/[max_reality_distortion]<br>"
	message += "<b>Temporal Effects:</b> [temporal_effects]/[max_temporal_effects]<br>"
	message += "<b>Video Evolution:</b> [video_evolution]/[max_video_evolution]<br>"
	message += "<b>Distortion Potency:</b> [distortion_potency]/[max_distortion_potency]<br>"
	message += "<b>Temporal Mastery:</b> [temporal_mastery]/[max_temporal_mastery]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1981"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-1981
/obj/item/scp1981/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-1981, a video recording that causes reality distortion.</span>")
		else
			to_chat(user, "<span class='danger'>A disturbing video recording that seems to distort reality.</span>")

