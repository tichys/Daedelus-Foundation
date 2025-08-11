// SCP-106 (The Old Man)

/datum/scp106_pocket
    /// Manages the pocket dimension instance and teleports
    var/datum/turf_reservation/reservation
    var/area/pocket_area
    var/turf/entry_turf
    var/turf/exit_turf
    /// Containment breach status
    var/containment_breached = FALSE
    /// Victims currently in pocket dimension
    var/list/victims = list()
    /// Containment field strength (0-100)
    var/containment_strength = 100
    /// Time until next containment check
    var/next_containment_check = 0

    /datum/scp106_pocket/proc/ensure_initialized()
        if(reservation)
            return TRUE
        // Create a 9x9 pocket room
        reservation = SSmapping.RequestBlockReservation(9, 9)
        // Use reinforced floor and indestructible walls to keep contained
        for(var/x in 0 to 8)
            for(var/y in 0 to 8)
                var/tx = reservation.bottom_left_coords[1] + x
                var/ty = reservation.bottom_left_coords[2] + y
                var/tz = reservation.bottom_left_coords[3]
                var/turf/T
                if(x == 0 || y == 0 || x == 8 || y == 8)
                    T = locate(tx, ty, tz)
                    new /turf/closed/indestructible/hotelwall(T)
                else
                    T = locate(tx, ty, tz)
                    new /turf/open/indestructible/hotelwood(T)
        pocket_area = get_area(locate(reservation.bottom_left_coords[1]+1, reservation.bottom_left_coords[2]+1, reservation.bottom_left_coords[3]))
        if(pocket_area)
            pocket_area.name = "SCP-106 Pocket Dimension"
        entry_turf = locate(reservation.bottom_left_coords[1]+4, reservation.bottom_left_coords[2]+4, reservation.bottom_left_coords[3])
        exit_turf = locate(reservation.bottom_left_coords[1]+4, reservation.bottom_left_coords[2]+1, reservation.bottom_left_coords[3])
        return TRUE

/datum/scp106_pocket/proc/send_to_pocket(atom/movable/A)
	if(!ensure_initialized() || !A)
		return FALSE
	A.forceMove(entry_turf)
	if(isliving(A))
		victims += A
		// Start containment degradation
		containment_strength = max(0, containment_strength - 5)
		check_containment_breach()
	return TRUE

/datum/scp106_pocket/proc/remove_victim(atom/movable/A)
	if(A in victims)
		victims -= A
		// Slight containment recovery when victims escape
		containment_strength = min(100, containment_strength + 2)

/datum/scp106_pocket/proc/check_containment_breach()
	if(containment_strength <= 0 && !containment_breached)
		containment_breached = TRUE
		log_game("SCP-106: CONTAINMENT BREACH - Pocket dimension destabilized!")
		// Notify all SCP-106 instances
		for(var/mob/living/simple_animal/hostile/retaliate/scp106/S in world)
			to_chat(S, span_danger("CONTAINMENT BREACH: Your pocket dimension is destabilizing!"))
			S.containment_breached = TRUE

/datum/scp106_pocket/proc/random_exit_to_world() as turf
	// Pick a random station turf as exit
	var/turf/T = get_safe_random_station_turf()
	if(!T)
		// try any world turf
		var/max = world.maxx-TRANSITIONEDGE
		var/min = 1+TRANSITIONEDGE
		var/list/space_levels = list()
		for(var/AZ in SSmapping.z_list)
			var/datum/space_level/D = AZ
			if(D.linkage == CROSSLINKED)
				space_levels += D.z_value
		var/_z = length(space_levels) ? pick(space_levels) : 1
		T = locate(rand(min,max), rand(min,max), isnum(_z) ? _z : 1)
	return T

// Global pocket instance
GLOBAL_DATUM_INIT(scp106_pocket, /datum/scp106_pocket, new)

// Containment equipment
/obj/item/containment_field_generator
	name = "SCP-106 Containment Field Generator"
	desc = "A device that generates a containment field to prevent SCP-106 from using its abilities."
	icon = 'icons/obj/device.dmi'
	icon_state = "field_gen"
	w_class = WEIGHT_CLASS_NORMAL
	var/field_strength = 50
	var/active = FALSE
	var/range = 3
	var/cooldown = 30 SECONDS
	var/last_activation = 0

/obj/item/containment_field_generator/attack_self(mob/user)
	if(world.time - last_activation < cooldown)
		to_chat(user, span_warning("The generator is recharging."))
		return
	active = !active
	last_activation = world.time
	if(active)
		to_chat(user, span_notice("You activate the containment field generator."))
		icon_state = "field_gen_on"
		START_PROCESSING(SSobj, src)
	else
		to_chat(user, span_notice("You deactivate the containment field generator."))
		icon_state = "field_gen"
		STOP_PROCESSING(SSobj, src)

/obj/item/containment_field_generator/process()
	if(!active)
		return
	// Check for SCP-106 in range
	for(var/mob/living/simple_animal/hostile/retaliate/scp106/S in range(range, get_turf(src)))
		if(S.containment_breached)
			S.containment_breached = FALSE
			to_chat(S, span_warning("The containment field is suppressing your abilities."))
		// Prevent portal creation and abduction
		S.portal_cooldown = max(S.portal_cooldown, 60 SECONDS)
		S.abduct_cooldown = max(S.abduct_cooldown, 60 SECONDS)

/obj/effect/portal/scp106
	name = "corroded void"
	desc = "A tear of corroded reality leading... somewhere else."
	anchored = TRUE
	density = FALSE
	var/turf/target
	var/timeout = 20 SECONDS

/obj/effect/portal/scp106/Initialize()
	. = ..()
	if(timeout)
		addtimer(CALLBACK(src, PROC_REF(qdel_self)), timeout)

/obj/effect/portal/scp106/proc/qdel_self()
	if(src)
		qdel(src)

/obj/effect/portal/scp106/Crossed(atom/movable/AM)
	. = ..()
	if(!target || !AM)
		return
	AM.forceMove(target)
	SEND_SIGNAL(src, COMSIG_SCP106_PORTAL_USED, AM)

// SCP-106 Containment Chamber
/obj/machinery/scp106_containment
	name = "SCP-106 Containment Chamber"
	desc = "A specialized containment chamber designed to hold SCP-106 using multiple containment protocols."
	icon = 'icons/obj/structures.dmi'
	icon_state = "containment_chamber"
	density = TRUE
	anchored = TRUE
	var/containment_active = FALSE
	var/containment_strength = 100
	var/breach_warning = FALSE
	var/list/contained_scp106 = list()

/obj/machinery/scp106_containment/Initialize()
	. = ..()
	update_icon()

/obj/machinery/scp106_containment/process()
	if(!containment_active)
		return

	// Check for SCP-106 in containment area
	var/list/scp106_in_area = list()
	for(var/mob/living/simple_animal/hostile/retaliate/scp106/S in range(2, src))
		scp106_in_area += S
		if(!(S in contained_scp106))
			contained_scp106 += S
			to_chat(S, span_warning("You are being contained by the specialized chamber."))

	// Remove SCP-106 that left the area
	for(var/mob/living/simple_animal/hostile/retaliate/scp106/S in contained_scp106)
		if(!(S in scp106_in_area))
			contained_scp106 -= S
			to_chat(S, span_notice("You have escaped the containment chamber."))

	// Apply containment effects
	for(var/mob/living/simple_animal/hostile/retaliate/scp106/S in contained_scp106)
		S.containment_breached = FALSE
		S.portal_cooldown = max(S.portal_cooldown, 120 SECONDS)
		S.abduct_cooldown = max(S.abduct_cooldown, 120 SECONDS)
		S.corrosion_cooldown = max(S.corrosion_cooldown, 60 SECONDS)

/obj/machinery/scp106_containment/attack_hand(mob/user)
	if(!containment_active)
		containment_active = TRUE
		to_chat(user, span_notice("You activate the SCP-106 containment chamber."))
		icon_state = "containment_chamber_active"
		START_PROCESSING(SSmachines, src)
	else
		containment_active = FALSE
		to_chat(user, span_notice("You deactivate the SCP-106 containment chamber."))
		icon_state = "containment_chamber"
		STOP_PROCESSING(SSmachines, src)
	update_icon()

/mob/living/simple_animal/hostile/retaliate/scp106
	name = "old man"
	desc = "An emaciated humanoid with a pitch-black, tar-like appearance."
	icon = 'icons/scp/scp-106.dmi'
	icon_state = ""
	icon_living = ""
	icon_dead = ""
	maxHealth = 600
	health = 600
	see_in_dark = 8
	move_to_delay = 4 // slow
	melee_damage_lower = 10
	melee_damage_upper = 20

	// Ability cooldowns
	var/corrosion_cooldown = 10 SECONDS
	var/portal_cooldown = 30 SECONDS
	var/abduct_cooldown = 20 SECONDS

	var/last_corrosion = 0
	var/last_portal = 0
	var/last_abduct = 0
	/// Containment breach status
	var/containment_breached = FALSE
	/// Cross-SCP interaction cooldowns
	var/list/scp_interaction_cooldowns = list()

/mob/living/simple_animal/hostile/retaliate/scp106/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"old man",
		SCP_KETER,
		"106",
		SCP_PLAYABLE
	)
	grant_language(/datum/language/common, TRUE, TRUE)
	add_verb(src, list(
		/mob/living/simple_animal/hostile/retaliate/scp106/proc/Corrode,
		/mob/living/simple_animal/hostile/retaliate/scp106/proc/OpenPortal,
		/mob/living/simple_animal/hostile/retaliate/scp106/proc/Abduct,
		/mob/living/simple_animal/hostile/retaliate/scp106/proc/ReturnFromPocket,
		/mob/living/simple_animal/hostile/retaliate/scp106/proc/InteractWithSCP,
	))

// Abilities
/mob/living/simple_animal/hostile/retaliate/scp106/proc/Corrode()
	set category = "SCP-106"
	set name = "Corrode"
	var/atom/target = get_step(src, src.dir)
	if(world.time - last_corrosion < corrosion_cooldown)
		to_chat(src, span_warning("You must wait before corroding again."))
		return
	if(isturf(target))
		var/turf/T = target
		if(isclosedturf(T))
			// Try to dissolve the wall
			if(hascall(T, "acid_act"))
				call(T, "acid_act")(50, 100)
		else
			// corrode objects ahead
			for(var/obj/O in get_turf(src))
				if(hascall(O, "acid_act"))
					call(O, "acid_act")(50, 100)
	last_corrosion = world.time
	SEND_SIGNAL(src, COMSIG_SCP106_CORROSION_APPLIED)

/mob/living/simple_animal/hostile/retaliate/scp106/proc/OpenPortal()
	set category = "SCP-106"
	set name = "Open Pocket Portal"
	if(world.time - last_portal < portal_cooldown)
		to_chat(src, span_warning("You must wait before opening another portal."))
		return
	if(!GLOB.scp106_pocket.ensure_initialized())
		to_chat(src, span_warning("The pocket dimension is unstable."))
		return
	var/obj/effect/portal/scp106/P = new(get_turf(src))
	P.target = GLOB.scp106_pocket.entry_turf
	last_portal = world.time
	to_chat(src, span_notice("You tear open a corroded void."))
	SEND_SIGNAL(src, COMSIG_SCP106_PORTAL_OPENED)

/mob/living/simple_animal/hostile/retaliate/scp106/proc/Abduct()
	set category = "SCP-106"
	set name = "Abduct Target"
	if(world.time - last_abduct < abduct_cooldown)
		to_chat(src, span_warning("You must wait before abducting again."))
		return
	var/atom/movable/target = get_step(src, src.dir)
	if(!(isliving(target) && ishuman(target)))
		to_chat(src, span_warning("No human victim directly ahead."))
		return
	var/mob/living/carbon/human/H = target
	if(GLOB.scp106_pocket.send_to_pocket(H))
		last_abduct = world.time
		to_chat(src, span_notice("You drag [H] into your pocket dimension."))
		SEND_SIGNAL(src, COMSIG_SCP106_VICTIM_ABDUCTED, H)

/mob/living/simple_animal/hostile/retaliate/scp106/proc/ReturnFromPocket()
	set category = "SCP-106"
	set name = "Return From Pocket"
	if(!GLOB.scp106_pocket.ensure_initialized())
		return
	var/turf/T = GLOB.scp106_pocket.random_exit_to_world()
	if(T)
		forceMove(T)
		to_chat(src, span_notice("You emerge from a corroded void."))
		SEND_SIGNAL(src, COMSIG_SCP106_RETURNED)

/mob/living/simple_animal/hostile/retaliate/scp106/proc/InteractWithSCP()
	set category = "SCP-106"
	set name = "Interact with SCP"
	var/list/nearby_scps = list()

	// Find nearby SCPs
	for(var/atom/A in range(2, src))
		if(A.SCP)
			nearby_scps += A

	if(!nearby_scps.len)
		to_chat(src, span_warning("No SCPs nearby to interact with."))
		return

	var/atom/selected_scp = input(src, "Select SCP to interact with:", "SCP Interaction") as null|anything in nearby_scps
	if(!selected_scp)
		return

	// Check cooldown for this specific SCP
	var/scp_id = selected_scp.SCP.designation
	if(scp_interaction_cooldowns[scp_id] && world.time < scp_interaction_cooldowns[scp_id])
		to_chat(src, span_warning("You must wait before interacting with SCP-[scp_id] again."))
		return

	// Perform SCP-specific interactions
	switch(scp_id)
		if("012")
			interact_with_012(selected_scp)
		if("013")
			interact_with_013(selected_scp)
		if("066")
			interact_with_066(selected_scp)
		if("113")
			interact_with_113(selected_scp)
		if("216")
			interact_with_216(selected_scp)
		if("151")
			interact_with_151(selected_scp)
		else
			generic_scp_interaction(selected_scp)

	// Set cooldown
	scp_interaction_cooldowns[scp_id] = world.time + 60 SECONDS

// SCP-specific interaction methods
/mob/living/simple_animal/hostile/retaliate/scp106/proc/interact_with_012(atom/scp012)
	to_chat(src, span_notice("You attempt to corrupt SCP-012's musical composition with your corrosive essence."))
	// SCP-012 interaction: Corrupts the music, making it more dangerous
	if(prob(70))
		to_chat(src, span_green("You successfully corrupt SCP-012's composition. The music becomes more aggressive and dangerous."))
		// Signal to SCP-012 to increase its effects
		// SEND_SIGNAL(scp012, COMSIG_SCP012_CORRUPTED, src)
	else
		to_chat(src, span_warning("The composition resists your corruption attempt."))

/mob/living/simple_animal/hostile/retaliate/scp106/proc/interact_with_013(atom/scp013)
	to_chat(src, span_notice("You attempt to absorb SCP-013's addictive properties into your pocket dimension."))
	// SCP-013 interaction: Absorbs cigarettes into pocket dimension
	if(prob(80))
		to_chat(src, span_green("You successfully absorb SCP-013 into your pocket dimension. The cigarettes now exist in your realm."))
		if(GLOB.scp106_pocket.send_to_pocket(scp013))
			to_chat(src, span_notice("SCP-013 has been relocated to your pocket dimension."))
	else
		to_chat(src, span_warning("SCP-013 resists being absorbed."))

/mob/living/simple_animal/hostile/retaliate/scp106/proc/interact_with_066(atom/scp066)
	to_chat(src, span_notice("You attempt to silence SCP-066's noise with your corrosive void."))
	// SCP-066 interaction: Temporarily silences the ball
	if(prob(60))
		to_chat(src, span_green("You successfully silence SCP-066. The ball becomes temporarily quiet."))
		// SEND_SIGNAL(scp066, COMSIG_SCP066_SILENCED, src)
	else
		to_chat(src, span_warning("SCP-066's noise overwhelms your attempt to silence it."))

/mob/living/simple_animal/hostile/retaliate/scp106/proc/interact_with_113(atom/scp113)
	to_chat(src, span_notice("You attempt to corrupt SCP-113's gender-changing properties."))
	// SCP-113 interaction: Corrupts the gender change effect
	if(prob(75))
		to_chat(src, span_green("You corrupt SCP-113's properties. The gender change becomes more extreme and unpredictable."))
		// SEND_SIGNAL(scp113, COMSIG_SCP113_CORRUPTED, src)
	else
		to_chat(src, span_warning("SCP-113's properties resist corruption."))

/mob/living/simple_animal/hostile/retaliate/scp106/proc/interact_with_216(atom/scp216)
	to_chat(src, span_notice("You attempt to create a temporal rift using SCP-216's properties."))
	// SCP-216 interaction: Creates temporal anomalies
	if(prob(50))
		to_chat(src, span_green("You successfully create a temporal rift. Time becomes unstable in the area."))
		// SEND_SIGNAL(scp216, COMSIG_SCP216_TEMPORAL_RIFT, src)
		// Create temporal effects
		for(var/mob/living/L in range(3, src))
			if(L != src)
				to_chat(L, span_danger("You feel time distorting around you!"))
	else
		to_chat(src, span_warning("The temporal manipulation fails."))

/mob/living/simple_animal/hostile/retaliate/scp106/proc/interact_with_151(atom/scp151)
	to_chat(src, span_notice("You attempt to absorb SCP-151's blood into your corrosive essence."))
	// SCP-151 interaction: Absorbs blood properties
	if(prob(65))
		to_chat(src, span_green("You successfully absorb SCP-151's blood properties. Your corrosive abilities become more potent."))
		melee_damage_lower += 5
		melee_damage_upper += 5
		// SEND_SIGNAL(scp151, COMSIG_SCP151_ABSORBED, src)
	else
		to_chat(src, span_warning("SCP-151's blood resists absorption."))

/mob/living/simple_animal/hostile/retaliate/scp106/proc/generic_scp_interaction(atom/scp)
	to_chat(src, span_notice("You attempt to corrupt [scp.SCP.designation] with your corrosive essence."))
	if(prob(40))
		to_chat(src, span_green("You successfully corrupt [scp.SCP.designation]. Its properties become more dangerous."))
		// SEND_SIGNAL(scp, COMSIG_SCP_CORRUPTED, src)
	else
		to_chat(src, span_warning("[scp.SCP.designation] resists your corruption attempt."))

// Override to add chance to abduct on melee attack
/mob/living/simple_animal/hostile/retaliate/scp106/UnarmedAttack(atom/A, proximity)
	. = ..()
	if(isliving(A) && ishuman(A))
		var/mob/living/carbon/human/H = A
		if(prob(20))
			if(GLOB.scp106_pocket.send_to_pocket(H))
				SEND_SIGNAL(src, COMSIG_SCP106_VICTIM_ABDUCTED, H)
				to_chat(H, span_danger("You are dragged into a nightmarish void!"))

// Containment breach detection
/mob/living/simple_animal/hostile/retaliate/scp106/proc/check_containment_status()
	if(containment_breached)
		// Enhanced abilities during breach
		corrosion_cooldown = max(5 SECONDS, corrosion_cooldown - 5 SECONDS)
		portal_cooldown = max(15 SECONDS, portal_cooldown - 15 SECONDS)
		abduct_cooldown = max(10 SECONDS, abduct_cooldown - 10 SECONDS)
		to_chat(src, span_danger("CONTAINMENT BREACH: Your abilities are enhanced!"))
	else
		// Normal cooldowns
		corrosion_cooldown = 10 SECONDS
		portal_cooldown = 30 SECONDS
		abduct_cooldown = 20 SECONDS

// Life process to handle containment
/mob/living/simple_animal/hostile/retaliate/scp106/Life()
	. = ..()
	if(.)
		check_containment_status()


