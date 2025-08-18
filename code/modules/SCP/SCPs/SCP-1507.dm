/mob/living/simple_animal/hostile/retaliate/scp1507
	name = "pink flamingo"
	desc = "A pink plastic flamingo that acts like a real one."
	icon = 'icons/scp/scp-1507.dmi'
	maxHealth = 100
	health = 100
	icon_state = "flamingo"
	icon_living = "flamingo"
	icon_dead = "dead"
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	faction = "scp"
	var/static/spawn_count = 1
	// Interaction flavor compatible with simple_animal
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	// Enhanced combat variables
	var/enrage_potency = 4
	var/max_damage = 25
	var/enraged = FALSE
	var/enrage_threshold = 50 // Health threshold to trigger enrage

/mob/living/simple_animal/hostile/retaliate/scp1507/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "pink plastic flamingo", SCP_EUCLID, "1507", SCP_PLAYABLE)
	name += " ([spawn_count])"
	spawn_count += 1
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-1507"] = new /datum/scp_instance("SCP-1507", src)

/mob/living/simple_animal/hostile/retaliate/scp1507/Life()
	. = ..()
	if(stat == DEAD)
		return

	// Enrage when health drops below threshold
	if(health < enrage_threshold && !enraged)
		enrage()

/mob/living/simple_animal/hostile/retaliate/scp1507/proc/enrage()
	if(enraged)
		return

	enraged = TRUE
	melee_damage_lower = min(melee_damage_lower + enrage_potency, max_damage)
	melee_damage_upper = min(melee_damage_upper + enrage_potency, max_damage)

	to_chat(src, "<span class='danger'>You become enraged!</span>")
	visible_message("<span class='danger'>[src] becomes enraged!</span>")
	playsound(src, 'sound/effects/explosion1.ogg', 50)

/mob/living/simple_animal/hostile/retaliate/scp1507/attack_hand(mob/living/carbon/human/M)
	. = ..()
	// Enrage when attacked
	enrage()

/mob/living/simple_animal/hostile/retaliate/scp1507/examine(mob/living/user)
	. = ..()
	if(enraged)
		to_chat(user, "<span class='danger'>It looks extremely angry!</span>")
	else
		to_chat(user, "<span class='notice'>It looks like a normal plastic flamingo.</span>")
