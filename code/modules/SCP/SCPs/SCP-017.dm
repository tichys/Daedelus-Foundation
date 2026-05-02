// SCP-017: Shadow Person
// A humanoid shadow that can phase through walls and drain life from those it touches

/mob/living/carbon/scp/scp017
	name = "shadow person"
	desc = "A humanoid figure made entirely of shadow. It seems to absorb light around it."
	icon = 'icons/scp/scp-017.dmi'
	icon_state = "shadow"
	status_flags = 0
	maxHealth = 150
	health = 150
	max_scp_health = 150
	scp_health = 150
	max_scp_armor = 50
	scp_armor = 50

	// Shadow abilities
	var/phase_cooldown = 0
	var/phase_cooldown_time = 15 SECONDS
	var/life_drain_cooldown = 0
	var/life_drain_cooldown_time = 10 SECONDS
	var/drain_amount = 15
	var/phase_range = 7

/mob/living/carbon/scp/scp017/Initialize(mapload, new_species = "SCP-017")
	. = ..()
	SCP = new /datum/scp(src, "shadow person", SCP_EUCLID, "017", SCP_PLAYABLE)
	SCP.min_playercount = 20
	SCP.min_time = 5 MINUTES

	// Add abilities
	add_ability("phase_through_walls", "phase_through_walls_ability")
	add_ability("drain_life", "drain_life_ability")
	add_passive_effect("shadow_form", "shadow_form_effect")

	// Auto-registered via datum/scp

/mob/living/carbon/scp/scp017/process_scp_effects()
	. = ..()

	if(stat == DEAD)
		return

	// Shadow form effects
	if(prob(5))
		visible_message("<span class='notice'>[src] flickers like a shadow.</span>")

/mob/living/carbon/scp/scp017/UnarmedAttack(atom/A)
	if(!A || !istype(A, /mob/living))
		return ..()

	var/mob/living/L = A
	if(L.stat == DEAD)
		return ..()

	// Life drain on touch
	if(life_drain_cooldown <= world.time)
		to_chat(src, "<span class='notice'>You drain life from [L].</span>")
		to_chat(L, "<span class='danger'>You feel your life force being drained by [src]!</span>")

		L.adjustBruteLoss(drain_amount)
		adjust_scp_health(drain_amount * 0.5) // Heal from draining

		playsound(src, 'sound/effects/explosion1.ogg', 50)
		life_drain_cooldown = world.time + life_drain_cooldown_time

		// Log interaction
		SCP.log_interaction(L, "life_drain")
		SCP.award_research(L, "combat", 10)

	return ..()

/mob/living/carbon/scp/scp017/get_status_tab_items()
	. = ..()
	. += "Phase Cooldown: [max(0, round((phase_cooldown - world.time) / 10))] seconds"
	. += "Life Drain Cooldown: [max(0, round((life_drain_cooldown - world.time) / 10))] seconds"

/mob/living/carbon/scp/scp017/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This shadow person can phase through walls and drain life from living beings.</span>"
	if(health < maxHealth * 0.5)
		. += "<span class='warning'>The shadow appears weakened.</span>"

/mob/living/carbon/scp/scp017/scp_death()
	visible_message("<span class='danger'>[src] dissolves into darkness!</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 50)
	..()

// Shadow abilities
/mob/living/carbon/scp/scp017/proc/phase_through_walls_ability()
	set name = "Phase Through Walls"
	set desc = "Phase through walls to escape or ambush"
	set category = "SCP"

	if(phase_cooldown > world.time)
		to_chat(src, "<span class='warning'>Phasing is still recharging...</span>")
		return

	var/list/valid_turfs = list()
	for(var/turf/T in range(phase_range, src))
		if(T.density)
			continue
		if(get_dist(src, T) <= 1)
			continue
		valid_turfs += T

	if(!valid_turfs.len)
		to_chat(src, "<span class='warning'>No valid locations to phase to.</span>")
		return

	var/turf/target = pick(valid_turfs)

	to_chat(src, "<span class='notice'>You phase through the shadows to [target].</span>")
	playsound(src, 'sound/effects/explosion1.ogg', 50)

	forceMove(target)

	playsound(src, 'sound/effects/explosion2.ogg', 50)
	phase_cooldown = world.time + phase_cooldown_time

/mob/living/carbon/scp/scp017/proc/drain_life_ability()
	set name = "Drain Life"
	set desc = "Drain life from nearby living beings"
	set category = "SCP"

	if(life_drain_cooldown > world.time)
		to_chat(src, "<span class='warning'>Life drain is still recharging...</span>")
		return

	var/list/targets = list()
	for(var/mob/living/L in view(3, src))
		if(L != src && L.stat != DEAD)
			targets += L

	if(!targets.len)
		to_chat(src, "<span class='warning'>No living targets nearby.</span>")
		return

	var/mob/living/target = pick(targets)

	to_chat(src, "<span class='notice'>You drain life from [target].</span>")
	to_chat(target, "<span class='danger'>You feel your life force being drained by [src]!</span>")

	target.adjustBruteLoss(drain_amount * 2)
	adjust_scp_health(drain_amount)

	playsound(src, 'sound/effects/explosion1.ogg', 50)
	life_drain_cooldown = world.time + life_drain_cooldown_time

	SCP.log_interaction(target, "life_drain_ability")
	SCP.award_research(target, "combat", 15)

/mob/living/carbon/scp/scp017/proc/shadow_form_effect()
	// Passive shadow form effects
	if(prob(1))
		visible_message("<span class='notice'>[src] seems to absorb the light around it.</span>")

/mob/living/carbon/scp/scp017/proc/on_life_drain(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-017", drain_amount, 0)

/mob/living/carbon/scp/scp017/proc/on_phase(location)
	return


