/*
SCP-080 "Dark Form"
A hostile shadow entity capable of possessing electronic devices and traveling through electrical systems.
Can manifest physically in areas with sufficient electrical power.
*/

/mob/living/simple_animal/hostile/scp080
	name = "dark shadow"
	desc = "A writhing mass of living darkness that seems to absorb light around it."
	icon = 'icons/mob/cult.dmi' // TODO: Replace with proper SCP-080 icon
	icon_state = "shade_cult"
	icon_living = "shade_cult"
	icon_dead = "shade_cult_dead"
	
	// Basic stats - weaker than 173 but more evasive
	maxHealth = 800
	health = 800
	melee_damage_lower = 15
	melee_damage_upper = 25
	obj_damage = 30
	
	// Shadow entity properties
	mob_biotypes = MOB_SPIRIT
	speak_emote = list("whispers", "hisses")
	emote_hear = list("crackles electrically", "hums with power")
	attack_verb_continuous = "electrically burns"
	attack_verb_simple = "electrically burn"
	attack_sound = 'sound/machines/defib_zap.ogg'
	melee_damage_type = BURN
	
	// Environmental requirements - needs electrical power
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	
	// Movement and behavior
	move_to_delay = 2
	vision_range = 8
	aggro_vision_range = 10
	
	faction = list("scp")
	
	// Incorporeal and electrical properties
	density = FALSE
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	pass_flags = PASSTABLE | PASSMOB | PASSGRILLE
	mob_size = MOB_SIZE_TINY
	
	deathmessage = "dissipates into wisps of darkness..."
	
	// SCP-080 specific variables
	var/electrical_power = 100 // Current electrical charge (0-100)
	var/max_electrical_power = 100
	var/power_drain_rate = 2 // Power lost per Life() cycle when not near electronics
	var/power_gain_rate = 5 // Power gained when near electronics
	
	// Possession system
	var/obj/machinery/possessed_device = null
	var/possession_time = 0
	var/max_possession_time = 300 // 5 minutes max possession
	
	// Cable travel system
	var/traveling_through_cables = FALSE
	var/obj/structure/cable/current_cable = null
	var/list/cable_path = list()
	
	// Environmental effects
	var/light_drain_range = 3
	var/last_power_feedback = 0
	
	// SCP cross-interaction vars
	var/list/nearby_scps = list()
	var/scp_interaction_range = 7
	
	// Combat vars
	var/last_attack = 0

/mob/living/simple_animal/hostile/scp080/Initialize()
	. = ..()
	
	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"dark shadow",
		SCP_EUCLID,
		"080",
		SCP_MEMETIC // Can cause fear/paranoia through electrical interference
	)
	
	// Set up memetic properties - causes fear through electrical manipulation
	SCP.memeticFlags = MVISUAL | MAUDIBLE
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/simple_animal/hostile/scp080, memetic_effect)
	SCP.compInit()
	
	// Add special traits
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	AddElement(/datum/element/simple_flying)
	
	// Start electrical monitoring
	START_PROCESSING(SSobj, src)
	
	// Initial area power scan
	scan_for_power_sources()

/mob/living/simple_animal/hostile/scp080/Destroy()
	if(possessed_device)
		end_possession()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(SCP)
	return ..()

//=============================================================================
// ELECTRICAL POWER SYSTEM
//=============================================================================

/mob/living/simple_animal/hostile/scp080/Life()
	. = ..()
	if(stat == DEAD)
		return
		
	// Update electrical power
	update_electrical_power()
	
	// Check for SCP interactions
	scan_for_nearby_scps()
	
	// Update environmental effects
	drain_nearby_lights()
	
	// Handle possession mechanics
	if(possessed_device)
		handle_possession()
	else if(traveling_through_cables)
		move_through_cables()
	
	// Power-based behavior changes
	update_behavior_based_on_power()

/mob/living/simple_animal/hostile/scp080/proc/update_electrical_power()
	var/area/current_area = get_area(src)
	if(!current_area)
		return
		
	var/power_available = FALSE
	var/power_change = 0
	
	// Check for nearby electrical devices
	for(var/obj/machinery/power/device in view(3, src))
		if(device.avail())
			power_available = TRUE
			power_change += power_gain_rate
			
			// Drain power from device
			device.add_load(50)
			
			// Visual feedback
			if(prob(20))
				var/list/electrical_effects = list(
					"[device] sparks violently!",
					"[device] flickers ominously!",
					"Electrical energy arcs toward [src]!"
				)
				visible_message(span_warning(pick(electrical_effects)))
				
	// Check APCs specifically
	if(current_area.apc)
		var/obj/machinery/power/apc/local_apc = current_area.apc
		if(local_apc.cell?.charge > 0)
			power_available = TRUE
			power_change += power_gain_rate * 2 // APCs provide more power
			
			// Drain APC power
			local_apc.cell.use(100)
			
			if(prob(15))
				visible_message(span_boldwarning("The lights flicker as [src] draws power from the area!"))
				local_apc.energy_fail(30 SECONDS)
	
	// Power decay when not near electronics
	if(!power_available)
		power_change -= power_drain_rate
		
	// Apply power changes
	electrical_power = clamp(electrical_power + power_change, 0, max_electrical_power)
	
	// Death from power loss
	if(electrical_power <= 0)
		if(prob(10))
			visible_message(span_notice("[src] grows fainter as its electrical energy dissipates..."))
		if(electrical_power <= -50)
			death()

/mob/living/simple_animal/hostile/scp080/proc/scan_for_power_sources()
	// Find all power sources in range for strategic movement
	var/list/power_sources = list()
	
	for(var/obj/machinery/power/device in view(vision_range, src))
		power_sources += device
			
	return power_sources

/mob/living/simple_animal/hostile/scp080/proc/update_behavior_based_on_power()
	// Power level affects capabilities
	if(electrical_power > 75)
		// High power - very aggressive and fast
		move_to_delay = 1
		melee_damage_lower = 20
		melee_damage_upper = 35
		alpha = 255
		
	else if(electrical_power > 50)
		// Medium power - normal behavior
		move_to_delay = 2
		melee_damage_lower = 15
		melee_damage_upper = 25
		alpha = 200
		
	else if(electrical_power > 25)
		// Low power - slower and weaker
		move_to_delay = 3
		melee_damage_lower = 10
		melee_damage_upper = 15
		alpha = 150
		
	else
		// Critical power - very weak
		move_to_delay = 4
		melee_damage_lower = 5
		melee_damage_upper = 10
		alpha = 100

//=============================================================================
// POSSESSION SYSTEM
//=============================================================================

/mob/living/simple_animal/hostile/scp080/proc/attempt_possession(obj/machinery/target)
	if(possessed_device || !target || traveling_through_cables)
		return FALSE
		
	// Check if device is possessable (simplified check)
	if(!istype(target, /obj/machinery))
		return FALSE
		
	// Must be adjacent or very close
	if(get_dist(src, target) > 1)
		return FALSE
		
	// Need sufficient power
	if(electrical_power < 30)
		return FALSE
		
	// Start possession
	start_possession(target)
	return TRUE

/mob/living/simple_animal/hostile/scp080/proc/start_possession(obj/machinery/target)
	possessed_device = target
	possession_time = 0
	
	// Move into the device
	forceMove(target)
	
	// Visual effects
	target.visible_message(span_boldwarning("[target] suddenly sparks and hums with dark energy!"))
	playsound(target, 'sound/machines/defib_zap.ogg', 50, TRUE)
	
	// Add electrical overlay to device
	var/image/electrical_overlay = image('icons/effects/effects.dmi', target, "electricity")
	electrical_overlay.alpha = 150
	target.add_overlay(electrical_overlay)
	
	// Register for device signals
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_possessed_device_destroyed))

/mob/living/simple_animal/hostile/scp080/proc/handle_possession()
	if(!possessed_device)
		end_possession()
		return
		
	possession_time++
	
	// End possession if time limit reached
	if(possession_time >= max_possession_time)
		end_possession()
		return
		
	// Drain device power
	if(istype(possessed_device, /obj/machinery/power))
		var/obj/machinery/power/power_device = possessed_device
		power_device.add_load(25)
		
	// Random malfunctions
	if(prob(15))
		cause_device_malfunction()
		
	// Gain power from possession
	electrical_power = min(electrical_power + 1, max_electrical_power)

/mob/living/simple_animal/hostile/scp080/proc/cause_device_malfunction()
	if(!possessed_device)
		return
		
	var/list/malfunction_effects = list()
	
	// Type-specific malfunctions
	if(istype(possessed_device, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = possessed_device
		if(prob(30))
			apc.energy_fail(60 SECONDS)
			malfunction_effects += "cycles power channels erratically"
			
	else if(istype(possessed_device, /obj/machinery/light))
		if(prob(40))
			malfunction_effects += "flickers violently"
			possessed_device.visible_message(span_warning("[possessed_device] strobes intensely!"))
			
	else if(istype(possessed_device, /obj/machinery/door))
		if(prob(25))
			malfunction_effects += "cycles open and closed"
			
	// Generic electrical effects
	if(prob(20))
		malfunction_effects += "emits shower of sparks"
		var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
		sparks.set_up(3, 1, possessed_device)
		sparks.start()
		
	if(length(malfunction_effects))
		possessed_device.visible_message(span_warning("[possessed_device] [pick(malfunction_effects)]!"))

/mob/living/simple_animal/hostile/scp080/proc/end_possession()
	if(!possessed_device)
		return
		
	var/obj/machinery/old_device = possessed_device
	
	// Remove overlays
	old_device.cut_overlays()
	
	// Exit the device
	var/turf/exit_turf = get_turf(old_device)
	if(exit_turf)
		forceMove(exit_turf)
		
	// Visual effects
	old_device.visible_message(span_notice("Dark energy dissipates from [old_device]."))
	
	// Cleanup
	UnregisterSignal(old_device, COMSIG_PARENT_QDELETING)
	possessed_device = null
	possession_time = 0

/mob/living/simple_animal/hostile/scp080/proc/on_possessed_device_destroyed()
	SIGNAL_HANDLER
	end_possession()

//=============================================================================
// CABLE TRAVEL SYSTEM
//=============================================================================

/mob/living/simple_animal/hostile/scp080/proc/attempt_cable_travel(obj/structure/cable/entry_cable)
	if(traveling_through_cables || possessed_device)
		return FALSE
		
	if(get_dist(src, entry_cable) > 1)
		return FALSE
		
	if(electrical_power < 20)
		return FALSE
		
	start_cable_travel(entry_cable)
	return TRUE

/mob/living/simple_animal/hostile/scp080/proc/start_cable_travel(obj/structure/cable/entry_cable)
	traveling_through_cables = TRUE
	current_cable = entry_cable
	
	// Become invisible while traveling
	alpha = 50
	density = FALSE
	
	// Visual effect
	entry_cable.visible_message(span_warning("Electrical energy surges through the power cables!"))
	
	// Find path through cable network
	find_cable_path()

/mob/living/simple_animal/hostile/scp080/proc/find_cable_path()
	if(!current_cable)
		end_cable_travel()
		return
		
	cable_path = list()
	var/list/connected_cables = list()
	
	// Find connected cables using the powernet
	if(current_cable.powernet)
		for(var/obj/structure/cable/cable in view(15, current_cable))
			if(cable.powernet == current_cable.powernet)
				connected_cables += cable
				
	// Choose random path
	if(length(connected_cables) > 1)
		cable_path = connected_cables.Copy()
		cable_path -= current_cable
		
	addtimer(CALLBACK(src, PROC_REF(move_through_cables)), 2 SECONDS)

/mob/living/simple_animal/hostile/scp080/proc/move_through_cables()
	if(!traveling_through_cables || !length(cable_path))
		end_cable_travel()
		return
		
	// Move to next cable
	var/obj/structure/cable/next_cable = pick(cable_path)
	forceMove(get_turf(next_cable))
	current_cable = next_cable
	
	// Electrical effects along the path
	if(prob(30))
		next_cable.visible_message(span_warning("Electricity arcs through the cables!"))
		
	// Continue or exit travel
	if(prob(40) || length(cable_path) <= 1)
		end_cable_travel()
	else
		cable_path -= next_cable
		addtimer(CALLBACK(src, PROC_REF(move_through_cables)), 1 SECONDS)

/mob/living/simple_animal/hostile/scp080/proc/end_cable_travel()
	traveling_through_cables = FALSE
	current_cable = null
	cable_path = list()
	
	// Become visible again
	alpha = initial(alpha)
	update_behavior_based_on_power()
	
	// Exit effect
	visible_message(span_boldwarning("[src] materializes from the electrical system!"))

//=============================================================================
// ENVIRONMENTAL EFFECTS
//=============================================================================

/mob/living/simple_animal/hostile/scp080/proc/drain_nearby_lights()
	for(var/obj/machinery/light/light in view(light_drain_range, src))
		if(!light.on || light.status != LIGHT_OK)
			continue
			
		if(prob(10))
			light.flicker()
			electrical_power = min(electrical_power + 1, max_electrical_power)
			
		if(prob(5) && electrical_power < 50)
			// Drain light completely when low on power
			light.on = FALSE
			light.update()
			electrical_power = min(electrical_power + 5, max_electrical_power)
			light.visible_message(span_warning("[light] dims and goes out as darkness creeps closer!"))

/mob/living/simple_animal/hostile/scp080/proc/memetic_effect(mob/living/carbon/human/target)
	if(!target || target.stat >= UNCONSCIOUS)
		return
		
	// Cause fear and paranoia through electrical interference
	var/list/fear_messages = list(
		"The lights seem to flicker whenever you're not looking directly at them...",
		"You hear a faint electrical humming that makes your skin crawl...", 
		"Something feels wrong with the electronics around you...",
		"The shadows seem darker than they should be...",
		"You feel like you're being watched through the security cameras..."
	)
	
	if(prob(20))
		to_chat(target, span_warning(pick(fear_messages)))
		// TODO: Add mood system integration when available

//=============================================================================
// COMBAT OVERRIDES
//=============================================================================

/mob/living/simple_animal/hostile/scp080/AttackingTarget()
	// Cannot attack while possessing or traveling
	if(possessed_device || traveling_through_cables)
		return FALSE
		
	// Electrical attacks
	if(isliving(target))
		electrical_attack(target)
		return TRUE
	else
		return ..()

/mob/living/simple_animal/hostile/scp080/proc/electrical_attack(mob/living/victim)
	do_attack_animation(victim)
	
	// Visual effects
	victim.visible_message(
		span_danger("[src] reaches out and electricity arcs into [victim]!"),
		span_userdanger("Searing electrical energy courses through your body!")
	)
	
	// Electrical damage
	var/damage = rand(melee_damage_lower, melee_damage_upper)
	victim.apply_damage(damage, BURN)
	
	// Special effects based on target type
	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		
		// Chance to disable electronic equipment  
		if(prob(25))
			// Find electronic items (simplified)
			for(var/obj/item/electronic_item in human_victim.get_all_contents())
				if(istype(electronic_item, /obj/item/electronics))
					electronic_item.visible_message(span_warning("[electronic_item] sparks and malfunctions!"))
					if(prob(50))
						qdel(electronic_item) // Fry the electronics
					break
					
	// Gain power from successful attacks
	electrical_power = min(electrical_power + 3, max_electrical_power)
	
	playsound(src, attack_sound, 50, TRUE)
	last_attack = world.time

//=============================================================================
// SCP CROSS-INTERACTIONS
//=============================================================================

/mob/living/simple_animal/hostile/scp080/proc/scan_for_nearby_scps()
	nearby_scps.Cut()
	
	for(var/atom/A in view(scp_interaction_range, src))
		if(hasscp(A) && A != src)
			nearby_scps[A] = A.SCP.designation
			handle_scp_interaction(A)

/mob/living/simple_animal/hostile/scp080/proc/handle_scp_interaction(atom/other_scp)
	if(!other_scp.SCP)
		return
		
	var/designation = other_scp.SCP.designation
	
	switch(designation)
		if("173") // SCP-173 "The Sculpture"
			// SCP-080 can interfere with 173's detection systems
			if(prob(20))
				// Possess nearby cameras to create blind spots
				for(var/obj/machinery/camera/cam in view(5, other_scp))
					if(cam.can_use() && !possessed_device)
						visible_message(span_warning("The security camera near [other_scp] flickers and goes dark!"))
						cam.toggle_cam(null, 0) // Disable camera
						electrical_power = min(electrical_power + 5, max_electrical_power)
						break
						
			// Occasionally disrupt lights around 173
			if(prob(15))
				for(var/obj/machinery/light/light in view(3, other_scp))
					if(light.on)
						light.flicker()
						if(prob(30))
							light.on = FALSE
							light.update()
							
		if("012") // SCP-012 "On Mount Golgotha"  
			// SCP-080 can possess audio equipment to amplify 012's effects
			if(prob(10))
				visible_message(span_boldwarning("Electrical interference causes audio equipment to emit eerie sounds!"))
				playsound(src, 'sound/effects/space_wind.ogg', 30, TRUE)
				
				// Boost 012's memetic range if both are present (simplified)
				visible_message(span_warning("[other_scp]'s effect seems amplified by the electrical interference!"))
					
		if("013") // SCP-013 "Blue Lady" cigarette
			// Reality distortion interaction - electrical systems flicker
			var/obj/item/clothing/mask/cigarette/scp013/cig = other_scp
			if(cig.lit && prob(15))
				visible_message(span_warning("Electrical systems flicker as reality bends around [other_scp]!"))
				
				// Temporary power surge
				electrical_power = min(electrical_power + 10, max_electrical_power)
				
				// Cause area-wide electrical interference
				var/area/current_area = get_area(src)
				if(current_area?.apc)
					current_area.apc.energy_fail(15 SECONDS)
					
		if("049") // SCP-049 "Plague Doctor" (if implemented)
			// 080 avoids 049 - fears the "cure"
			if(get_dist(src, other_scp) <= 3)
				visible_message(span_notice("[src] seems to recoil from [other_scp]..."))
				
		if("096") // SCP-096 "The Shy Guy" (if implemented)
			// 080 can interfere with electronics to prevent 096 viewing
			if(prob(25))
				// Disable cameras and screens to prevent accidental viewing
				for(var/obj/machinery/computer/comp in view(7, src))
					comp.visible_message(span_warning("[comp] screen flickers and goes dark!"))
					
		if("682") // SCP-682 "Hard-to-Destroy Reptile" (if implemented)
			// Both are hostile - electrical attacks vs adaptive evolution
			if(prob(10))
				visible_message(span_danger("Electrical energy crackles between [src] and [other_scp]!"))

/mob/living/simple_animal/hostile/scp080/proc/hasscp(atom/target)
	if(!target)
		return FALSE
	return !isnull(target.SCP)

// Multiple SCP interaction - electrical interference amplifies
/mob/living/simple_animal/hostile/scp080/proc/multiple_scp_interference()
	if(length(nearby_scps) >= 2)
		// Massive electrical interference
		visible_message(span_boldwarning("Multiple anomalies cause electrical systems to overload!"))
		
		// Area-wide power failure
		var/area/current_area = get_area(src)
		if(current_area?.apc)
			current_area.apc.energy_fail(120 SECONDS)
			
		// Damage electronics in range
		for(var/obj/machinery/device in view(5, src))
			if(device.use_power && prob(40))
				device.visible_message(span_boldwarning("[device] overloads and sparks violently!"))
				device.take_damage(50, BURN)
				
		// Massive power gain
		electrical_power = max_electrical_power

//=============================================================================
// SPECIAL INTERACTIONS
//=============================================================================

// Interaction with APCs - can enter and control them
/mob/living/simple_animal/hostile/scp080/proc/interact_with_apc(obj/machinery/power/apc/apc)
	if(possessed_device == apc)
		return
		
	if(get_dist(src, apc) <= 1 && electrical_power >= 30)
		attempt_possession(apc)

// Enhanced possession of APCs
/obj/machinery/power/apc/proc/scp080_possession_effects()
	// 080 can control power distribution
	if(prob(20))
		// Random power channel manipulation
		var/random_channel = pick("lighting", "equipment", "environ")
		visible_message(span_warning("[src] cycles [random_channel] power!"))
		
	if(prob(15))
		// Lighting disruption (simplified)
		visible_message(span_warning("[src] causes lighting fluctuations throughout the area!"))

// Override normal movement to consider electrical systems
/mob/living/simple_animal/hostile/scp080/Move(NewLoc, Dir)
	// Prefer moving toward electrical sources when low on power
	if(electrical_power < 50 && !possessed_device && !traveling_through_cables)
		var/list/power_sources = scan_for_power_sources()
		if(length(power_sources))
			var/obj/closest_source = get_closest_atom(/obj/machinery/power, power_sources)
			if(closest_source && get_dist(src, closest_source) > 1)
				// Try to move toward power source
				var/turf/target_turf = get_step_towards(src, closest_source)
				if(target_turf)
					NewLoc = target_turf
					
	return ..()

// Special examine text with power level indication
/mob/living/simple_animal/hostile/scp080/examine(mob/user)
	. = ..()
	
	if(electrical_power > 75)
		. += span_boldwarning("It crackles with intense electrical energy!")
	else if(electrical_power > 50)
		. += span_warning("Electricity arcs around its form.")
	else if(electrical_power > 25)
		. += span_notice("Faint electrical activity surrounds it.")
	else
		. += span_notice("Its form seems faint and unstable.")
		
	if(possessed_device)
		. += span_boldwarning("It appears to be inhabiting [possessed_device]!")
		
	if(traveling_through_cables)
		. += span_warning("It seems to be moving through the electrical systems!")

// Death effects - EMP burst
/mob/living/simple_animal/hostile/scp080/death(gibbed)
	if(!gibbed)
		visible_message(span_boldwarning("[src] releases all its stored electrical energy in a final surge!"))
		
		// EMP-like effect - damage nearby electronics
		for(var/obj/machinery/device in view(electrical_power / 20, src))
			if(device.use_power && prob(60))
				device.visible_message(span_boldwarning("[device] overloads and sparks!"))
				device.take_damage(50, BURN)
		
		// Area power drain
		var/area/death_area = get_area(src)
		if(death_area?.apc)
			death_area.apc.energy_fail(electrical_power * 2) // Longer blackout for more power
			
	if(possessed_device)
		end_possession()
		
	return ..()

// AI targeting - prefer electronic targets and isolated victims
/mob/living/simple_animal/hostile/scp080/ListTargets()
	var/list/potential_targets = ..()
	var/list/priority_targets = list()
	
	// Prioritize targets near electronics (easier to attack via possession)
	for(var/mob/living/target in potential_targets)
		var/electronics_nearby = FALSE
		for(var/obj/machinery/device in view(2, target))
			if(device.use_power)
				electronics_nearby = TRUE
				break
				
		if(electronics_nearby)
			priority_targets += target
			
	return priority_targets.len ? priority_targets : potential_targets

// TODO: Add mood events when mood system is available
