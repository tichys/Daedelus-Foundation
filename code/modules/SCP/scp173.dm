/mob/living/simple_animal/hostile/statue/scp173
	name = "concrete sculpture"
	desc = "A large, vaguely humanoid concrete sculpture. It seems to have an unsettling presence."
	icon = 'icons/scp/scp-173.dmi' // TODO: Replace with proper SCP-173 icon
	icon_state = "173"
	icon_living = "173"
	icon_dead = "173_dead"

	maxHealth = 10000
	health = 10000

	melee_damage_lower = 200 // Instant neck snap damage
	melee_damage_upper = 200
	obj_damage = 200

	attack_verb_continuous = "snaps the neck of"
	attack_verb_simple = "snap the neck of"
	attack_sound = 'sound/effects/snap.ogg'

	move_to_delay = 1

	see_in_dark = 10
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	faction = list("scp")

	deathmessage = "crumbles into concrete chunks."

	// SCP-173 specific variables
	var/last_attack_time = 0
	var/neck_snap_sound = 'sound/effects/snap.ogg'
	var/footstep_sound = 'sound/effects/footstep/heavy1.ogg'
	var/list/possible_feces = list(
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/blood/old
	)

/mob/living/simple_animal/hostile/statue/scp173/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"concrete sculpture",
		SCP_EUCLID,
		"173"
	)
	// Randomly spawn some feces/blood around containment
	if(prob(30))
		var/obj/mess = pick(possible_feces)
		new mess(get_turf(src))

/mob/living/simple_animal/hostile/statue/scp173/Destroy()
	QDEL_NULL(SCP)
	return ..()

/mob/living/simple_animal/hostile/statue/scp173/Move(NewLoc, direct)
	if(can_be_seen(NewLoc))
		return FALSE

	// Play movement sound when not being watched
	if(footstep_sound)
		playsound(src, footstep_sound, 50, TRUE)

	// Chance to leave traces
	if(prob(15))
		var/obj/mess = pick(possible_feces)
		new mess(get_turf(src))

	return ..()

/mob/living/simple_animal/hostile/statue/scp173/AttackingTarget()
	check_scp_interactions() // Check for SCP cross-interactions

	if(can_be_seen(get_turf(loc)))
		return FALSE

	if(isliving(target))
		var/mob/living/victim = target

		// Special neck snap attack for humans
		if(ishuman(victim))
			return snap_neck(victim)
		else
			return ..()
	return ..()

/mob/living/simple_animal/hostile/statue/scp173/proc/snap_neck(mob/living/carbon/human/victim)
	if(!victim || !isliving(victim))
		return FALSE

	// Check if we can be seen during the attack
	if(can_be_seen(get_turf(loc)))
		return FALSE

	do_attack_animation(victim)

	// Play snap sound
	playsound(src, neck_snap_sound, 75, TRUE)

	// Deliver fatal damage
	victim.apply_damage(melee_damage_upper, BRUTE, BODY_ZONE_HEAD)

	// Attempt to instantly kill if low health
	if(victim.health <= 50)
		victim.death()
		victim.visible_message(
			span_danger("[src] snaps [victim]'s neck with a sickening crack!"),
			span_userdanger("You feel your neck being twisted with incredible force before everything goes black!")
		)
	else
		victim.visible_message(
			span_danger("[src] grabs [victim]'s head and twists it violently!"),
			span_userdanger("You feel crushing pressure around your neck!")
		)

	last_attack_time = world.time
	return TRUE

// Override death to leave concrete debris
/mob/living/simple_animal/hostile/statue/scp173/death(gibbed)
	. = ..()
	if(!gibbed)
		// Drop concrete chunks (using iron as placeholder)
		for(var/i in 1 to rand(3,6))
			var/obj/item/stack/sheet/iron/concrete_chunk = new(get_turf(src))
			concrete_chunk.amount = rand(1,3)

		// Final blood/feces mess
		var/obj/mess = pick(possible_feces)
		new mess(get_turf(src))

// SCP-173 can only be damaged when observed (for balance)
/mob/living/simple_animal/hostile/statue/scp173/bullet_act(obj/projectile/P, def_zone, piercing_hit = FALSE)
	if(can_be_seen(get_turf(src)))
		return ..()
	else
		visible_message(span_notice("[P] passes harmlessly through [src]!"))
		return BULLET_ACT_FORCE_PIERCE

/mob/living/simple_animal/hostile/statue/scp173/attackby(obj/item/O, mob/user, params)
	if(can_be_seen(get_turf(src)))
		return ..()
	else
		to_chat(user, span_warning("[O] seems to phase through [src]!"))
		return TRUE

// Enhanced examine text
/mob/living/simple_animal/hostile/statue/scp173/examine(mob/user)
	. = ..()
	if(ishuman(user))
		. += span_notice("The sculpture appears to be made of concrete and rebar, with some kind of spray paint on it.")
		. += span_warning("You feel like you shouldn't take your eyes off it...")
		. += span_warning("There are dark stains around its base.")

// Override can_be_seen to account for cameras and better vision detection
/mob/living/simple_animal/hostile/statue/scp173/can_be_seen(turf/location = get_turf(src))
	if(!location)
		return FALSE

	// Check for any living mobs that can see us
	for(var/mob/living/watcher in view(world.view + 1, location))
		if(watcher == src)
			continue

		if(watcher.stat >= UNCONSCIOUS)
			continue

		if(!watcher.client)
			continue

		// Check if they have direct line of sight
		if(can_see(watcher, location, world.view + 1))
			return TRUE

	// Also check for cameras (if implemented)
	for(var/obj/machinery/camera/cam in view(7, location))
		if(cam.can_use() && cam.status)
			// Simple check - if camera is functional and nearby
			if(get_dist(cam, location) <= 7)
				return TRUE

	return FALSE

// Ambient sounds when not observed
/mob/living/simple_animal/hostile/statue/scp173/Life()
	. = ..()

	// Occasional scraping sounds when no one is watching
	if(!can_be_seen() && prob(5))
		var/list/ambient_sounds = list(
			'sound/effects/stonedoor_openclose.ogg',
			'sound/effects/grillehit.ogg'
		)
		playsound(src, pick(ambient_sounds), 25, TRUE)

// Custom AI targeting - prioritize isolated targets
/mob/living/simple_animal/hostile/statue/scp173/ListTargets()
	var/list/potential_targets = ..()
	var/list/isolated_targets = list()

	// Prefer targets that are alone or have fewer observers
	for(var/mob/living/potential_target in potential_targets)
		var/observer_count = 0
		for(var/mob/living/other in view(7, potential_target))
			if(other != potential_target && other != src && other.stat < UNCONSCIOUS)
				observer_count++

		if(observer_count <= 1) // Alone or with only one other person
			isolated_targets += potential_target

	return isolated_targets.len ? isolated_targets : potential_targets

//=============================================================================
// SCP CROSS-INTERACTIONS
//=============================================================================

// SCP-173 interactions with specific SCPs
/mob/living/simple_animal/hostile/statue/scp173/CanAttack(atom/the_target)
	. = ..()
	if(!.)
		return FALSE

	// Special interactions with other SCPs
	if(hasscp(the_target))
		var/atom/scp_target = the_target
		if(!scp_target.SCP)
			return TRUE

		switch(scp_target.SCP.designation)
			if("012") // SCP-012 "On Mount Golgotha"
				// SCP-173 ignores SCP-012 - no interest in inanimate objects
				return FALSE

			if("013") // SCP-013 "Blue Lady" cigarette
				// SCP-173 cannot interact with small objects effectively
				return FALSE

			if("049") // SCP-049 "Plague Doctor" (if implemented)
				// Both are hostile but 049's touch is dangerous even to 173
				if(prob(25)) // 25% chance to avoid 049
					visible_message(span_warning("[src] seems to hesitate near [the_target]..."))
					return FALSE
				return TRUE

			if("096") // SCP-096 "The Shy Guy" (if implemented)
				// Two unstoppable forces - mutual avoidance
				if(prob(75)) // 75% chance to avoid confrontation
					visible_message(span_notice("[src] and [the_target] seem to avoid each other..."))
					return FALSE
				return TRUE

			if("682") // SCP-682 "Hard-to-Destroy Reptile" (if implemented)
				// Both are extremely hostile - will fight
				visible_message(span_danger("[src] focuses intently on [the_target]!"))
				return TRUE

			if("999") // SCP-999 "The Tickle Monster" (if implemented)
				// SCP-999's anomalous calming effect works on 173
				if(get_dist(src, the_target) <= 3)
					visible_message(span_notice("[src] seems oddly calm near [the_target]..."))
					return FALSE
				return TRUE

	return TRUE

// Enhanced Life() to include SCP interactions
/mob/living/simple_animal/hostile/statue/scp173/Life()
	. = ..()

	// Check for nearby SCP-012 and reduce activity
	for(var/obj/item/paper/scp012/sheet in view(7, src))
		if(prob(10))
			visible_message(span_notice("[src] seems to slow down near the sheet music..."))
			return // Skip some normal Life() processing

	// Check for SCP-013 smoke effects
	for(var/obj/item/clothing/mask/cigarette/scp013/cig in view(5, src))
		if(cig.lit && prob(20))
			visible_message(span_warning("[src] appears to flicker slightly in the smoke..."))
			// SCP-173 is briefly disoriented by the Blue Lady effect
			if(target && prob(30))
				LoseTarget()

// Special behavior when multiple SCPs are present
/mob/living/simple_animal/hostile/statue/scp173/proc/check_scp_interactions()
	var/list/nearby_scps = list()

	// Find all SCPs within range
	for(var/atom/A in view(10, src))
		if(hasscp(A) && A != src)
			nearby_scps += A

	if(length(nearby_scps) >= 2)
		// Multiple SCP containment breach - increased aggression
		melee_damage_lower = min(melee_damage_lower + 50, 300)
		melee_damage_upper = min(melee_damage_upper + 50, 300)
		visible_message(span_boldwarning("[src] becomes more agitated with multiple anomalies present!"))

		// Play ominous sound
		playsound(src, 'sound/effects/stonedoor_openclose.ogg', 60, TRUE)

	else if(length(nearby_scps) == 0)
		// Reset damage if no other SCPs around
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)

// SCP-173 cross-contamination effects
/mob/living/simple_animal/hostile/statue/scp173/proc/scp_contamination_effect(mob/living/carbon/human/victim)
	if(!victim || !ishuman(victim))
		return

	// Check if victim is affected by other SCPs
	if(victim.humanStageHandler?.getStage("BlueLady")) // SCP-013 effect
		// SCP-173 neck snap is more brutal on Blue Lady affected victims
		victim.visible_message(
			span_boldwarning("[victim] seems to welcome [src]'s approach with an eerie calm..."),
			span_boldwarning("The melancholy makes you feel strangely accepting of your fate...")
		)
		// Instant death regardless of health
		victim.death()
		return TRUE

	// Future: Add interactions with other SCP effects like 012's compulsion
	return FALSE

// Helper proc to check if an atom has an SCP component
/mob/living/simple_animal/hostile/statue/scp173/proc/hasscp(atom/target)
	if(!target)
		return FALSE
	return !isnull(target.SCP)

// Proc called when SCP-173 is in same area as other dangerous SCPs
/mob/living/simple_animal/hostile/statue/scp173/proc/proximity_effect(atom/other_scp)
	if(!hasscp(other_scp))
		return

	var/designation = other_scp.SCP.designation

	switch(designation)
		if("012")
			// Near SCP-012, movement becomes slightly erratic
			if(prob(15))
				visible_message(span_notice("[src] pauses momentarily, as if listening..."))

		if("013")
			// Near lit SCP-013, occasional reality flickers
			var/obj/item/clothing/mask/cigarette/scp013/cig = other_scp
			if(cig.lit && prob(10))
				var/list/flicker_messages = list(
					"[src] seems to phase slightly...",
					"The air around [src] shimmers...",
					"[src] appears to exist in two places at once for a moment..."
				)
				visible_message(span_warning(pick(flicker_messages)))

// Environmental interaction - SCP-173 affects lighting when other SCPs are present
/mob/living/simple_animal/hostile/statue/scp173/Initialize()
	. = ..()

	// Register for area changes to check for SCP interactions
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_area_change))

/mob/living/simple_animal/hostile/statue/scp173/proc/on_area_change()
	// Check for other SCPs in new area
	addtimer(CALLBACK(src, PROC_REF(area_scp_check)), 1 SECOND)

/mob/living/simple_animal/hostile/statue/scp173/proc/area_scp_check()
	var/area/current_area = get_area(src)
	if(!current_area)
		return

	var/scp_count = 0
	for(var/atom/A in current_area)
		if(hasscp(A) && A != src)
			scp_count++
			proximity_effect(A)

	// Multiple SCPs in same area causes environmental effects
	if(scp_count >= 2)
		// Flicker lights in area
		for(var/obj/machinery/light/L in current_area)
			if(prob(30))
				addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, flicker)), rand(1, 10) SECONDS)
