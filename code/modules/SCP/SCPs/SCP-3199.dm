// SCP-3199: Sapient Biological Entity
// A Keter-class entity with unique reproductive capabilities and hunting behavior
// Based on SCP Wiki: https://scp-wiki.wikidot.com/scp-3199

/mob/living/simple_animal/hostile/scp3199
	name = "SCP-3199"
	desc = "A hairless, 2.9-meter tall entity stained with albumen-like excretion. Its neck can twist 340° in either direction."
	icon = 'icons/scp/scp-3199.dmi' // Placeholder icon
	icon_state = "scp-3199-grown"
	icon_living = "scp-3199-grown"
	icon_dead = "scp173"

	// Physical characteristics
	maxHealth = 100
	health = 100
	melee_damage_lower = 25
	melee_damage_upper = 35
	attack_sound = 'sound/effects/attackblob.ogg'

	// Movement and behavior
	move_to_delay = 2
	vision_range = 12
	aggro_vision_range = 15
	search_objects = 1
	wander = 1
	stop_automated_movement_when_pulled = 0

	// SCP properties
	var/egg_production_cooldown = 0
	var/egg_production_time = 3000 // 5 minutes
	var/hatchling_protection_radius = 6 // 0.6 km in game terms
	var/list/nearby_hatchlings = list()
	var/egg_stomach = TRUE // Always carries one egg
	var/reproduction_count = 0

	// Containment tracking
	var/containment_breach = FALSE
	var/last_containment_check = 0
	var/containment_check_interval = 600 // 10 minutes

/mob/living/simple_animal/hostile/scp3199/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "sapient biological entity", SCP_KETER, "3199")
	// Auto-registered via datum/scp

	// Start containment monitoring
	START_PROCESSING(SSobj, src)

	// Initialize with one egg in stomach
	egg_stomach = TRUE

/mob/living/simple_animal/hostile/scp3199/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/simple_animal/hostile/scp3199/process()
	. = ..()

	// Check for containment breach
	if(world.time > last_containment_check + containment_check_interval)
		check_containment_status()
		last_containment_check = world.time

	// Egg production logic
	if(egg_production_cooldown > 0)
		egg_production_cooldown--

	// Find nearby hatchlings for protection
	update_hatchling_protection()

	// Reproductive cycle
	if(egg_production_cooldown <= 0 && prob(5)) // 5% chance per tick when cooldown is ready
		produce_egg()

/mob/living/simple_animal/hostile/scp3199/proc/check_containment_status()
	var/area/current_area = get_area(src)

	// Check if we're in a proper containment area
	if(!istype(current_area, /area))
		if(!containment_breach)
			containment_breach = TRUE
			SCP.log_interaction(src, "containment_breach")
			SCP.award_research(src, "containment", 100)

			// Alert security
			priority_announce("SCP-3199 containment breach detected! All security personnel respond immediately!", "Security Alert", 'sound/effects/explosion1.ogg')

			// Increase aggression
			vision_range = 20
			aggro_vision_range = 25
			move_to_delay = 1
	else
		if(containment_breach)
			containment_breach = FALSE
			SCP.log_interaction(src, "containment_restored")

			// Reset to normal behavior
			vision_range = 12
			aggro_vision_range = 15
			move_to_delay = 2

/mob/living/simple_animal/hostile/scp3199/proc/update_hatchling_protection()
	nearby_hatchlings.Cut()

	// Find all SCP-3199 hatchlings within protection radius
	for(var/mob/living/simple_animal/hostile/scp3199/hatchling in range(hatchling_protection_radius, src))
		if(hatchling != src && hatchling.stat != DEAD)
			nearby_hatchlings += hatchling

			// If hatchling is under attack, become more aggressive
			if(hatchling.health < hatchling.maxHealth * 0.5)
				vision_range = 20
				aggro_vision_range = 25
				move_to_delay = 1

/mob/living/simple_animal/hostile/scp3199/proc/produce_egg()
	if(egg_production_cooldown > 0)
		return

	egg_production_cooldown = egg_production_time

	// Show distress during egg production
	visible_message("<span class='danger'>[src] begins to convulse violently, producing an awful screaming sound!</span>")
	playsound(src, 'sound/effects/explosion1.ogg', 100, TRUE, 10)

	// Create egg
	var/obj/item/scp3199_egg/egg = new /obj/item/scp3199_egg(get_turf(src))
	egg.parent_entity = src

	// Viscous red substance (corrosive material)
	var/obj/effect/decal/cleanable/blood/viscous_red = new /obj/effect/decal/cleanable/blood(get_turf(src))
	viscous_red.name = "viscous red substance"
	viscous_red.desc = "A highly corrosive material produced during SCP-3199 reproduction."

	// Log reproduction
	SCP.log_interaction(src, "egg_production")
	SCP.award_research(src, "reproduction", 75)

	reproduction_count++

	// If this was the stomach egg, produce a new one
	if(egg_stomach)
		egg_stomach = TRUE // Always maintain one egg

/mob/living/simple_animal/hostile/scp3199/UnarmedAttack(atom/A)
	. = ..()

	if(isliving(A))
		var/mob/living/L = A

		// Liquefy internal organs and bone structure
		L.adjustBruteLoss(melee_damage_lower)
		L.adjustToxLoss(15)

		// Special attack message
		visible_message("<span class='danger'>[src] liquefies [L]'s internal structure!</span>")

		// Log attack
		SCP.log_interaction(L, "liquefaction_attack")
		SCP.award_research(L, "combat", 25)

		// If target dies, transfer to nearest hatchling
		if(L.stat == DEAD)
			transfer_cadaver_to_hatchling(L)

/mob/living/simple_animal/hostile/scp3199/proc/transfer_cadaver_to_hatchling(mob/living/cadaver)
	var/mob/living/simple_animal/hostile/scp3199/nearest_hatchling = null
	var/shortest_distance = INFINITY

	// Find nearest hatchling
	for(var/mob/living/simple_animal/hostile/scp3199/hatchling in nearby_hatchlings)
		var/distance = get_dist(cadaver, hatchling)
		if(distance < shortest_distance)
			shortest_distance = distance
			nearest_hatchling = hatchling

	if(nearest_hatchling)
		// Move cadaver to hatchling
		cadaver.forceMove(get_turf(nearest_hatchling))
		visible_message("<span class='notice'>[src] transfers the cadaver to the nearest hatchling.</span>")

		// Log transfer
		SCP.log_interaction(nearest_hatchling, "cadaver_transfer")
		SCP.award_research(nearest_hatchling, "feeding", 15)

/mob/living/simple_animal/hostile/scp3199/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This entity appears to be a sapient biological organism with unusual reproductive capabilities.</span>"

	if(containment_breach)
		. += "<span class='danger'>This entity has breached containment!</span>"

	if(egg_production_cooldown > 0)
		. += "<span class='warning'>The entity appears to be in reproductive distress.</span>"

	if(nearby_hatchlings.len > 0)
		. += "<span class='notice'>There are [nearby_hatchlings.len] hatchlings within protection range.</span>"

// SCP-3199 Egg
/obj/item/scp3199_egg
	name = "SCP-3199 egg"
	desc = "A large off-white egg with a rubbery appearance. Extremely resilient to damage."
	icon = 'icons/scp/scp-3199.dmi'
	icon_state = "3199_egg_cluster"
	w_class = 4
	var/mob/living/simple_animal/hostile/scp3199/parent_entity
	var/hatching_cooldown = 0
	var/hatching_time = 18000 // 30 minutes
	var/heat_sensitivity = TRUE

/obj/item/scp3199_egg/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/scp3199_egg/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scp3199_egg/process()
	// Check for heat exposure
	var/turf/T = get_turf(src)
	if(T && T.temperature > 350) // Above 77°C
		accelerated_hatching()

	// Normal hatching countdown
	if(hatching_cooldown > 0)
		hatching_cooldown--
		if(hatching_cooldown <= 0)
			hatch()

/obj/item/scp3199_egg/proc/accelerated_hatching()
	if(hatching_cooldown > 0)
		hatching_cooldown = max(0, hatching_cooldown - 600) // Reduce by 10 minutes

		// Visual indication of heat exposure
		icon_state = "egg_hot"
		desc = "A large off-white egg with a rubbery appearance. It's getting hot!"

/obj/item/scp3199_egg/proc/hatch()
	var/turf/egg_turf = get_turf(src)

	// Create hatchling
	var/mob/living/simple_animal/hostile/scp3199/hatchling = new /mob/living/simple_animal/hostile/scp3199(egg_turf)
	hatchling.name = "SCP-3199 hatchling"
	hatchling.desc = "A juvenile instance of SCP-3199."
	hatchling.maxHealth = 50
	hatchling.health = 50
	hatchling.move_to_delay = 3 // Slower than adults

	// Log hatching
	if(parent_entity)
		parent_entity.SCP.log_interaction(hatchling, "egg_hatching")
		parent_entity.SCP.award_research(hatchling, "reproduction", 50)

	// Visual and audio effects
	playsound(egg_turf, 'sound/effects/explosion1.ogg', 75, TRUE, 5)
	visible_message("<span class='danger'>The SCP-3199 egg ruptures violently, producing a hatchling!</span>")

	// Destroy egg
	qdel(src)

/obj/item/scp3199_egg/attackby(obj/item/I, mob/user)
	// Eggs are extremely resilient
	if(I.force > 0)
		to_chat(user, "<span class='notice'>The egg is extremely resilient and resists damage.</span>")
		return

	return ..()

/obj/item/scp3199_egg/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This egg appears to be extremely resilient to damage.</span>"

	if(hatching_cooldown > 0)
		var/time_remaining = round(hatching_cooldown / 600, 1) // Convert to minutes
		. += "<span class='warning'>The egg will hatch in approximately [time_remaining] minutes.</span>"

	if(icon_state == "egg_hot")
		. += "<span class='danger'>The egg is being affected by heat exposure!</span>"

// Cold exposure destroys eggs - removed for compatibility

// Admin verb to spawn SCP-3199
/mob/living/carbon/human/proc/spawn_scp3199()
	set name = "Spawn SCP-3199"
	set category = "SCP"
	set desc = "Spawn an instance of SCP-3199"

	if(!check_rights(R_ADMIN))
		return

	var/turf/spawn_turf = get_turf(src)
	new /mob/living/simple_animal/hostile/scp3199(spawn_turf)

	to_chat(src, "<span class='notice'>Spawned SCP-3199 at [spawn_turf].</span>")
	log_admin("[key_name(src)] spawned SCP-3199 at [spawn_turf].")
