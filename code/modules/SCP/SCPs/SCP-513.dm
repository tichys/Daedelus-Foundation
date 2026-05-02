/obj/item/scp513
	name = "SCP-513"
	desc = "A small cowbell that produces an unsettling sound when rung. It seems to cause fear and paranoia in those who hear it."
	icon = 'icons/scp/scp-513.dmi'
	icon_state = "bell"
	var/ring_cooldown = 0
	var/ring_cooldown_time = 30 SECONDS
	var/fear_radius = 5
	var/list/affected_targets = list()
	var/list/fear_levels = list()
	var/ring_count = 0
	var/max_fear_level = 100

	// Persistence tracking
	var/rings_performed = 0
	var/fear_induced = 0
	var/panic_events = 0
	var/containment_status = "contained"

	var/datum/scp513_fear_system/fear_system
	var/datum/scp513_research_system/research_system

/obj/item/scp513/Initialize()
	. = ..()
	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-513",
		SCP_EUCLID,
		"513",
	)
	SCP.min_playercount = 15
	SCP.min_time = 20 MINUTES
	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-513"] = new /datum/scp_instance("SCP-513", src)
	// Systems
	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

/obj/item/scp513/proc/initialize_systems()
	fear_system = new /datum/scp513_fear_system(src)
	research_system = new /datum/scp513_research_system(src)

/obj/item/scp513/Destroy()
	affected_targets = list()
	fear_levels = list()
	return ..()

// Ring the cowbell
/obj/item/scp513/proc/ring_bell(mob/user)
	if(world.time < ring_cooldown)
		return
	ring_cooldown = world.time + ring_cooldown_time
	ring_count++
	rings_performed++
	containment_status = "breached"
	visible_message("<span class='danger'>[user] rings SCP-513!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	// Affect nearby targets
	affect_nearby_targets(user)
	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-513"]
		if(instance)
			instance.add_interaction_record(user, "ring_bell")
	// Tick systems once due to event
	fear_system?.process_fear()
	research_system?.process_research()

// Affect nearby targets with fear
/obj/item/scp513/proc/affect_nearby_targets(mob/user)
	for(var/mob/living/carbon/human/H in range(fear_radius, src))
		if(H == user || H.SCP || H.stat == DEAD)
			continue
		apply_fear_effect(H)

// Apply fear effect to target
/obj/item/scp513/proc/apply_fear_effect(mob/living/carbon/human/target)
	if(!target)
		return
	// Initialize fear level if not present
	if(!(target in fear_levels))
		fear_levels[target] = 0
	// Increase fear level
	fear_levels[target] = min(max_fear_level, fear_levels[target] + 20)
	fear_induced++
	// Add to affected targets
	if(!(target in affected_targets))
		affected_targets += target
	// Apply fear effects based on level
	var/fear_level = fear_levels[target]
	if(fear_level >= 20)
		to_chat(target, "<span class='warning'>You hear an unsettling sound that fills you with unease.</span>")
		target.stamina.adjust(-10)
	if(fear_level >= 40)
		to_chat(target, "<span class='danger'>The sound is getting louder! You feel paranoid and afraid.</span>")
		target.stamina.adjust(-20)
		target.adjustBruteLoss(5)
	if(fear_level >= 60)
		to_chat(target, "<span class='danger'>The sound is overwhelming! You're in a state of panic!</span>")
		target.stamina.adjust(-30)
		target.adjustBruteLoss(10)
		panic_events++
		// Random movement
		if(prob(30))
			var/list/directions = list(NORTH, SOUTH, EAST, WEST)
			target.forceMove(get_step(target, pick(directions)))
	if(fear_level >= 80)
		to_chat(target, "<span class='danger'>You can't take it anymore! The fear is consuming you!</span>")
		target.stamina.adjust(-50)
		target.adjustBruteLoss(20)
		// Flee in random direction
		var/list/directions = list(NORTH, SOUTH, EAST, WEST)
		for(var/i = 1 to 3)
			target.forceMove(get_step(target, pick(directions)))
	if(fear_level >= 100)
		to_chat(target, "<span class='danger'>The fear has driven you to the brink of madness!</span>")
		target.stamina.adjust(-100)
		target.adjustBruteLoss(30)
		// Temporary insanity effect
		addtimer(CALLBACK(src, PROC_REF(subside_fear), target), 300)
	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-513"]
		if(instance)
			instance.add_interaction_record(target, "fear_induced")

// Attack behavior - ring when used
/obj/item/scp513/attack_self(mob/user)
	ring_bell(user)

// Human interaction - when humans hear the bell
/mob/living/carbon/human/proc/hear_scp513()
	if(!src || stat == DEAD)
		return
	// Apply immediate fear effect
	stamina.adjust(-15)
	adjustBruteLoss(5)
	to_chat(src, "<span class='danger'>You hear an unsettling sound that fills you with dread!</span>")
	// Random panic behavior
	if(prob(25))
		var/list/directions = list(NORTH, SOUTH, EAST, WEST)
		forceMove(get_step(src, pick(directions)))
		to_chat(src, "<span class='danger'>You panic and move involuntarily!</span>")

// Override examine for SCP-513
/obj/item/scp513/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-513, a cowbell that induces fear and paranoia in those who hear it.</span>")
		else
			to_chat(user, "<span class='danger'>A small cowbell that seems to radiate an aura of unease. You feel anxious just looking at it.</span>")

/obj/item/scp513/proc/subside_fear(mob/living/carbon/human/target)
	if(target && target.stat != DEAD)
		to_chat(target, "<span class='notice'>The fear begins to subside...</span>")

/obj/item/scp513/proc/on_bell_ring(mob/living/carbon/human/ringer)
	if(!ringer)
		return
	hook_scp_breach("SCP-513", src)
	hook_scp_interaction(ringer, "SCP-513", INTERACTION_TYPE_CONTAINMENT)

/obj/item/scp513/proc/on_fear_induced(mob/living/carbon/human/victim, level)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-513", 0, level / 10)
	if(level >= 100)
		hook_player_death_near_scp(victim, "SCP-513")


