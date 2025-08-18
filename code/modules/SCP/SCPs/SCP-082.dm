// SCP-082: Large Aggressive Humanoid
// A massive, aggressive humanoid with enhanced strength and regeneration

/mob/living/carbon/scp/scp082
	name = "large humanoid"
	desc = "A massive, muscular humanoid with aggressive tendencies. It towers over most beings."
	icon = 'icons/scp/scp-082.dmi'
	icon_state = "humanoid"
	status_flags = 0
	maxHealth = 300
	health = 300
	max_scp_health = 300
	scp_health = 300
	max_scp_armor = 100
	scp_armor = 100

	// Enhanced abilities
	var/rage_cooldown = 0
	var/rage_cooldown_time = 30 SECONDS
	var/regeneration_cooldown = 0
	var/regeneration_cooldown_time = 20 SECONDS
	var/rage_damage_multiplier = 2.0
	var/regeneration_amount = 25
	var/is_raging = FALSE

/mob/living/carbon/scp/scp082/Initialize(mapload, new_species = "SCP-082")
	. = ..()
	SCP = new /datum/scp(src, "large humanoid", SCP_EUCLID, "082", SCP_PLAYABLE)
	SCP.min_playercount = 25
	SCP.min_time = 10 MINUTES

	// Add abilities
	add_ability("rage_mode", "rage_mode_ability")
	add_ability("regenerate", "regenerate_ability")
	add_passive_effect("enhanced_strength", "enhanced_strength_effect")

	// Auto-registered via datum/scp

/mob/living/carbon/scp/scp082/process_scp_effects()
	. = ..()

	if(stat == DEAD)
		return

	// Passive regeneration when health is low
	if(health < maxHealth * 0.3 && regeneration_cooldown <= world.time)
		adjust_scp_health(regeneration_amount * 0.5)
		regeneration_cooldown = world.time + regeneration_cooldown_time
		to_chat(src, "<span class='notice'>Your wounds begin to heal.</span>")

	// Rage effects
	if(is_raging && prob(10))
		visible_message("<span class='danger'>[src] roars in rage!</span>")
		playsound(src, 'sound/effects/explosion1.ogg', 50)

/mob/living/carbon/scp/scp082/UnarmedAttack(atom/A)
	if(!A || !istype(A, /mob/living))
		return ..()

	var/mob/living/L = A
	if(L.stat == DEAD)
		return ..()

	// Enhanced damage when raging
	var/damage_multiplier = is_raging ? rage_damage_multiplier : 1.0
	var/damage = 20 * damage_multiplier

	L.adjustBruteLoss(damage)

	if(is_raging)
		to_chat(src, "<span class='danger'>You crush [L] with your enhanced strength!</span>")
		to_chat(L, "<span class='danger'>[src] crushes you with incredible force!</span>")
	else
		to_chat(src, "<span class='notice'>You attack [L] with your massive strength.</span>")
		to_chat(L, "<span class='danger'>[src] attacks you with overwhelming force!</span>")

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Log interaction
	SCP.log_interaction(L, "enhanced_attack")
	SCP.award_research(L, "combat", 15)

	return ..()

/mob/living/carbon/scp/scp082/get_status_tab_items()
	. = ..()
	. += "Rage Mode: [is_raging ? "ACTIVE" : "Inactive"]"
	. += "Rage Cooldown: [max(0, round((rage_cooldown - world.time) / 10))] seconds"
	. += "Regeneration Cooldown: [max(0, round((regeneration_cooldown - world.time) / 10))] seconds"

/mob/living/carbon/scp/scp082/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This massive humanoid possesses incredible strength and regenerative abilities.</span>"
	if(is_raging)
		. += "<span class='danger'>The humanoid is in a state of rage!</span>"
	if(health < maxHealth * 0.5)
		. += "<span class='warning'>The humanoid appears wounded but is regenerating.</span>"

/mob/living/carbon/scp/scp082/scp_death()
	visible_message("<span class='danger'>[src] collapses with a thunderous crash!</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 50)
	..()

// Enhanced abilities
/mob/living/carbon/scp/scp082/proc/rage_mode_ability()
	set name = "Rage Mode"
	set desc = "Enter a state of enhanced rage and strength"
	set category = "SCP"

	if(rage_cooldown > world.time)
		to_chat(src, "<span class='warning'>Rage mode is still recharging...</span>")
		return

	if(is_raging)
		to_chat(src, "<span class='warning'>You are already in a rage!</span>")
		return

	is_raging = TRUE
	rage_cooldown = world.time + rage_cooldown_time

	to_chat(src, "<span class='danger'>You enter a state of uncontrollable rage!</span>")
	visible_message("<span class='danger'>[src] enters a state of rage!</span>")
	playsound(src, 'sound/effects/explosion1.ogg', 50)

	// Enhanced stats during rage
	adjust_scp_health(50) // Temporary health boost

	// Rage duration
	spawn(rage_cooldown_time)
		if(is_raging)
			is_raging = FALSE
			to_chat(src, "<span class='notice'>Your rage subsides.</span>")
			visible_message("<span class='notice'>[src]'s rage subsides.</span>")

/mob/living/carbon/scp/scp082/proc/regenerate_ability()
	set name = "Regenerate"
	set desc = "Actively regenerate health"
	set category = "SCP"

	if(regeneration_cooldown > world.time)
		to_chat(src, "<span class='warning'>Regeneration is still recharging...</span>")
		return

	if(health >= maxHealth)
		to_chat(src, "<span class='warning'>You are already at full health.</span>")
		return

	to_chat(src, "<span class='notice'>You focus on regenerating your wounds.</span>")
	visible_message("<span class='notice'>[src]'s wounds begin to heal rapidly.</span>")

	adjust_scp_health(regeneration_amount)
	regeneration_cooldown = world.time + regeneration_cooldown_time

	playsound(src, 'sound/effects/explosion2.ogg', 50)

/mob/living/carbon/scp/scp082/proc/enhanced_strength_effect()
	// Passive enhanced strength effects
	if(prob(2))
		visible_message("<span class='notice'>[src] flexes their massive muscles.</span>")


