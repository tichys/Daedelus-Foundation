// SCP-087: The Stairwell
// An infinite staircase with psychological effects and a mysterious entity

/datum/scp087_level
	var/level_number = 0
	var/light_level = 100 // 0-100 scale
	var/psychological_pressure = 0 // 0-100 scale
	var/list/entities = list()
	var/list/effects = list()
	var/desc = "A seemingly endless staircase descending into darkness."

/datum/scp087_level/proc/setup_level(level_num)
	level_number = level_num
	light_level = max(0, 100 - (level_num * 10))
	psychological_pressure = min(100, level_num * 15)

	// Add level-specific effects
	if(level_num >= 5)
		effects += "whispers"
	if(level_num >= 10)
		effects += "cold"
	if(level_num >= 15)
		effects += "paranoia"
	if(level_num >= 20)
		effects += "hallucinations"

/obj/structure/stairs/scp087
	name = "SCP-087 Stairwell"
	desc = "A seemingly endless staircase descending into darkness. The air feels heavy with dread."
	icon = 'icons/mob/animal.dmi'
	icon_state = "stairs"
	density = FALSE
	anchored = TRUE
	var/datum/scp087_level/current_level
	var/list/explorers = list()
	var/list/level_cache = list()
	var/MAX_LEVELS = 50
	var/entity_spawn_chance = 5 // 5% chance per level
	var/psychological_damage_timer = 0
	var/PSYCHOLOGICAL_DAMAGE_INTERVAL = 30 SECONDS

/obj/structure/stairs/scp087/Initialize()
	. = ..()
	current_level = new()
	current_level.setup_level(1)
	level_cache[1] = current_level

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(src, COMSIG_SCP_MEMETIC_AFFECTED, PROC_REF(on_memetic_affected))
	RegisterSignal(src, COMSIG_SCP106_PORTAL_OPENED, PROC_REF(on_portal_opened))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))

/obj/structure/stairs/scp087/proc/on_entered(datum/source, atom/movable/entering)
	if(!ishuman(entering))
		return

	var/mob/living/carbon/human/H = entering
	explorers[H] = current_level.level_number

	// Apply psychological effects
	apply_psychological_effects(H)

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP087_EXPLORATION_STARTED, H, current_level)

	to_chat(H, span_warning("You begin descending into the endless staircase..."))
	to_chat(H, span_notice("Level [current_level.level_number]: [current_level.desc]"))

	// Start psychological damage timer
	if(!psychological_damage_timer)
		psychological_damage_timer = addtimer(CALLBACK(src, PROC_REF(apply_psychological_damage)), PSYCHOLOGICAL_DAMAGE_INTERVAL, TIMER_STOPPABLE)

/obj/structure/stairs/scp087/proc/on_exited(datum/source, atom/movable/exiting)
	if(!ishuman(exiting))
		return

	var/mob/living/carbon/human/H = exiting
	if(explorers[H])
		var/level_reached = explorers[H]
		explorers -= H

		// Remove psychological effects
		remove_psychological_effects(H)

		// Notify research system
		SEND_SIGNAL(src, COMSIG_SCP087_EXPLORATION_ENDED, H, level_reached)

		to_chat(H, span_notice("You escape from the stairwell. You reached level [level_reached]."))

/obj/structure/stairs/scp087/proc/apply_psychological_effects(mob/living/carbon/human/H)
	if(!current_level)
		return

	// Apply psychological effects through messages
	to_chat(H, span_warning("The stairwell's atmosphere affects your mind..."))

	// Apply light level effects
	if(current_level.light_level < 50)
		to_chat(H, span_notice("Your eyes adjust to the darkness."))

	// Apply psychological pressure effects
	if(current_level.psychological_pressure >= 50)
		to_chat(H, span_warning("You feel paranoid."))

	if(current_level.psychological_pressure >= 75)
		to_chat(H, span_danger("Your sanity is being tested!"))

	// Apply level-specific effects
	if("whispers" in current_level.effects)
		to_chat(H, span_warning("You hear distant whispers..."))

	if("cold" in current_level.effects)
		to_chat(H, span_notice("The air feels cold."))

	if("paranoia" in current_level.effects)
		to_chat(H, span_warning("You feel overwhelming paranoia."))

	if("hallucinations" in current_level.effects)
		to_chat(H, span_danger("You begin to hallucinate!"))

/obj/structure/stairs/scp087/proc/remove_psychological_effects(mob/living/carbon/human/H)
	to_chat(H, span_notice("The stairwell's effects fade away as you escape."))

/obj/structure/stairs/scp087/proc/apply_psychological_damage()
	if(!explorers.len)
		psychological_damage_timer = 0
		return

	for(var/mob/living/carbon/human/H in explorers)
		if(!H || H.stat == DEAD)
			explorers -= H
			continue

		// Apply psychological damage based on level
		var/level = explorers[H]
		var/damage = level * 2

		// Apply psychological damage
		H.adjustSanity(-damage, "stairwell_psychological_pressure")

		// Show psychological effects
		if(prob(30))
			to_chat(H, span_warning("You hear distant whispers echoing through the stairwell..."))

		if(prob(20))
			to_chat(H, span_warning("You feel an overwhelming sense of dread..."))

		if(prob(10))
			to_chat(H, span_warning("You see shadows moving in the darkness..."))

		// Check for entity spawn
		if(prob(entity_spawn_chance))
			spawn_entity(H)

	// Continue the timer
	psychological_damage_timer = addtimer(CALLBACK(src, PROC_REF(apply_psychological_damage)), PSYCHOLOGICAL_DAMAGE_INTERVAL, TIMER_STOPPABLE)

/obj/structure/stairs/scp087/proc/spawn_entity(mob/living/carbon/human/H)
	var/list/entity_types = list(
		/mob/living/simple_animal/hostile/scp087_child,
		/mob/living/simple_animal/hostile/scp087_shadow,
		/mob/living/simple_animal/hostile/scp087_whisper
	)

	var/entity_type = pick(entity_types)
	var/mob/living/simple_animal/hostile/entity = new entity_type(get_turf(H))

	to_chat(H, span_danger("Something emerges from the darkness!"))

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP087_ENTITY_SPAWNED, H, entity, current_level)

/obj/structure/stairs/scp087/proc/descend_level(mob/living/carbon/human/H)
	if(!H || !explorers[H])
		return

	var/current_level_num = explorers[H]
	var/next_level_num = current_level_num + 1

	if(next_level_num > MAX_LEVELS)
		to_chat(H, span_warning("You've reached the maximum depth of the stairwell."))
		return

	// Create or get the next level
	if(!level_cache[next_level_num])
		level_cache[next_level_num] = new /datum/scp087_level(next_level_num)

	current_level = level_cache[next_level_num]
	explorers[H] = next_level_num

	// Apply new level effects
	apply_psychological_effects(H)

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP087_LEVEL_DESCENDED, H, next_level_num)

	to_chat(H, span_notice("You descend to level [next_level_num]..."))
	to_chat(H, span_warning("The darkness grows deeper. Light level: [current_level.light_level]%"))
	to_chat(H, span_warning("Psychological pressure: [current_level.psychological_pressure]%"))

// Cross-SCP interaction methods
/obj/structure/stairs/scp087/proc/on_memetic_affected(datum/source, mob/living/carbon/human/affected)
	if(affected in explorers)
		// SCP-087 can amplify memetic effects
		to_chat(affected, span_warning("The stairwell's psychological pressure amplifies the memetic effect!"))
		affected.adjustSanity(-20, "amplified_memetic")

/obj/structure/stairs/scp087/proc/on_portal_opened(datum/source)
	// SCP-106 can create portals within SCP-087
	for(var/mob/living/carbon/human/H in explorers)
		to_chat(H, span_warning("A dark portal appears in the stairwell!"))
		SEND_SIGNAL(src, COMSIG_SCP087_PORTAL_CREATED, H)

/obj/structure/stairs/scp087/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	if(patient in explorers)
		// SCP-049's cure can help explorers escape
		to_chat(patient, span_notice("The cure's power helps you resist the stairwell's effects."))
		patient.adjustSanity(30, "cure_protection")

/obj/structure/stairs/scp087/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	if(target in explorers)
		// SCP-096's rage can be amplified by the stairwell
		to_chat(target, span_warning("The stairwell's psychological pressure amplifies your rage!"))
		target.adjustSanity(-15, "amplified_rage")

/obj/structure/stairs/scp087/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	if(viewer in explorers)
		// SCP-173 can appear in the stairwell
		to_chat(viewer, span_danger("You see a statue in the darkness!"))
		SEND_SIGNAL(src, COMSIG_SCP087_ENTITY_SPAWNED, viewer, null, current_level)

/obj/structure/stairs/scp087/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	if(adaptor in explorers)
		// SCP-682's adaptation can help resist stairwell effects
		to_chat(adaptor, span_notice("Your adaptation helps you resist the stairwell's psychological pressure."))
		adaptor.adjustSanity(25, "adaptation_resistance")

// Verbs for explorers
/obj/structure/stairs/scp087/verb/descend_verb()
	set name = "Descend Deeper"
	set category = "SCP-087"
	set src in view(1)

	if(!ishuman(usr))
		to_chat(usr, span_warning("This only works for humans."))
		return

	if(!(usr in explorers))
		to_chat(usr, span_warning("You must be in the stairwell to descend."))
		return

	descend_level(usr)

/obj/structure/stairs/scp087/verb/escape_verb()
	set name = "Escape Stairwell"
	set category = "SCP-087"
	set src in view(1)

	if(!ishuman(usr))
		to_chat(usr, span_warning("This only works for humans."))
		return

	if(!(usr in explorers))
		to_chat(usr, span_warning("You're not in the stairwell."))
		return

	// Teleport to entrance
	usr.forceMove(get_turf(src))
	on_exited(src, usr)

// SCP-087 Entities
/mob/living/simple_animal/hostile/scp087_child
	name = "SCP-087-1"
	desc = "A pale, emaciated child with no face. It stares at you with empty eye sockets."
	icon = 'icons/mob/animal.dmi'
	icon_state = "child"
	icon_living = "child"
	icon_dead = "child_dead"
	health = 50
	maxHealth = 50
	melee_damage_lower = 15
	melee_damage_upper = 25
	attack_sound = 'sound/weapons/punch1.ogg'

	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = TRUE
	var/psychological_damage = 20

/mob/living/simple_animal/hostile/scp087_child/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_SCP_MEMETIC_AFFECTED, PROC_REF(on_memetic_affected))

/mob/living/simple_animal/hostile/scp087_child/AttackingTarget()
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustSanity(-psychological_damage, "scp087_child_terror")
		to_chat(H, span_warning("The child's presence fills you with overwhelming terror!"))

/mob/living/simple_animal/hostile/scp087_child/proc/on_memetic_affected(datum/source, mob/living/carbon/human/affected)
			// SCP-087-1 is immune to memetic effects
		to_chat(affected, span_notice("The child ignores the memetic effect."))

/mob/living/simple_animal/hostile/scp087_shadow
	name = "Shadow Figure"
	desc = "A dark, humanoid figure that seems to absorb light."
	icon = 'icons/mob/animal.dmi'
	icon_state = "shadow"
	icon_living = "shadow"
	icon_dead = "shadow_dead"
	health = 75
	maxHealth = 75
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_sound = 'sound/weapons/punch1.ogg'

	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = TRUE
	var/stealth_mode = TRUE

/mob/living/simple_animal/hostile/scp087_shadow/Initialize()
	. = ..()
	alpha = 100 // Semi-transparent
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))

/mob/living/simple_animal/hostile/scp087_shadow/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
			// SCP-087 shadow can resist SCP-106's corrosion
		to_chat(victim, span_notice("The shadow absorbs the corrosive effect."))

/mob/living/simple_animal/hostile/scp087_whisper
	name = "Whispering Entity"
	desc = "An invisible entity that whispers terrible things."
	icon = 'icons/mob/animal.dmi'
	icon_state = "whisper"
	icon_living = "whisper"
	icon_dead = "whisper_dead"
	health = 30
	maxHealth = 30
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_sound = 'sound/weapons/punch1.ogg'

	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = TRUE
	var/whisper_damage = 30

/mob/living/simple_animal/hostile/scp087_whisper/Initialize()
	. = ..()
	alpha = 50 // Very transparent
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))

/mob/living/simple_animal/hostile/scp087_whisper/AttackingTarget()
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustSanity(-whisper_damage, "scp087_whispers")
		to_chat(H, span_warning("The whispers fill your mind with terrible thoughts!"))

/mob/living/simple_animal/hostile/scp087_whisper/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can banish the whispering entity
	to_chat(patient, span_notice("The cure's power silences the whispering entity."))
	qdel(src)

// Research system integration
/obj/structure/stairs/scp087/proc/get_research_data()
	var/list/data = list()
	data["current_level"] = current_level ? current_level.level_number : 0
	data["explorers"] = length(explorers)
	data["max_levels"] = MAX_LEVELS
	data["entities_spawned"] = 0 // Track entity spawns
	return data
