// SCP-131 - The Eye Pods
// Two teardrop-shaped creatures with a single large eye each
// SCP-131-A is orange, SCP-131-B is brownish and slightly larger
// They make babbling sounds and can stare down SCP-173, preventing it from moving

/mob/living/simple_animal/scp131a
	name = "SCP-131-A"
	desc = "A small, teardrop-shaped creature with a single large blue eye. It is orange in color and makes soft babbling noises."
	icon = 'icons/scp/SCP-131.dmi'
	icon_state = "scp131a"
	icon_living = "scp131a"
	icon_dead = "scp131a_dead"
	health = 50
	maxHealth = 50
	density = FALSE
	anchored = FALSE
	turns_per_move = 2
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "kicks"
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = 'sound/weapons/tap.ogg'
	speak = list("Babu!", "Bah!", "Bwee!", "Mmu?")
	speak_emote = list("babbles", "coos", "burbles")
	emote_hear = list("babbles softly", "coos", "makes baby-like sounds")
	emote_see = list("looks around curiously", "blinks its large eye", "wobbles slightly")

	var/babble_cooldown = 0
	var/babble_cooldown_time = 10 SECONDS
	var/list/following = list()
	var/scp173_stared = FALSE
	var/observation_range = 6

/mob/living/simple_animal/scp131a/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Eye Pods", SCP_SAFE, "131")

/mob/living/simple_animal/scp131a/Life()
	. = ..()
	if(stat == DEAD)
		return

	process_babbling()
	process_following()
	stare_down_scp173()

/mob/living/simple_animal/scp131a/proc/process_babbling()
	if(world.time < babble_cooldown)
		return

	babble_cooldown = world.time + babble_cooldown_time

	if(prob(30))
		var/babble = pick(speak)
		say(babble)

/mob/living/simple_animal/scp131a/proc/process_following()
	if(client)
		return

	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat != DEAD && !H.SCP)
			if(prob(10))
				step_towards(src, H)
			break

/mob/living/simple_animal/scp131a/proc/stare_down_scp173()
	for(var/mob/living/scp/scp173/scp in view(observation_range, src))
		if(scp.stat != DEAD && scp.observation_system)
			scp.observation_system.observers += src
			scp.observation_system.observation_quality += 2.0
			scp.observation_system.is_being_observed = TRUE
			scp173_stared = TRUE
			return

	scp173_stared = FALSE

/mob/living/simple_animal/scp131a/attack_hand(mob/living/carbon/human/user)
	. = ..()

	if(!user.combat_mode)
		say(pick("Bah!", "Bwee!", "Mmu!"))
		emote("coos at [user]", 1)
		hook_scp_interaction(user, "SCP-131", INTERACTION_TYPE_CARE)

/mob/living/simple_animal/scp131a/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A small orange teardrop-shaped creature with a single large eye. It babbles like a baby and seems friendly.</span>")
	to_chat(user, "<span class='notice'>It seems to have an intense gaze that could freeze even the most dangerous entities in their tracks.</span>")

/mob/living/simple_animal/scp131a/death()
	scp173_stared = FALSE
	visible_message("<span class='danger'>[src] closes its eye and goes still!</span>")
	..()

/mob/living/simple_animal/scp131b
	name = "SCP-131-B"
	desc = "A small, teardrop-shaped creature with a single large green eye. It is brownish-green in color and slightly larger than its partner."
	icon = 'icons/scp/SCP-131.dmi'
	icon_state = "scp131b"
	icon_living = "scp131b"
	icon_dead = "scp131b_dead"
	health = 60
	maxHealth = 60
	density = FALSE
	anchored = FALSE
	turns_per_move = 2
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "kicks"
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = 'sound/weapons/tap.ogg'
	speak = list("Bweh!", "Mrrp!", "Bah!", "Wuu?")
	speak_emote = list("babbles", "murmurs", "chirps")
	emote_hear = list("babbles softly", "murmurs", "makes baby-like sounds")
	emote_see = list("looks around alertly", "blinks its large eye", "shifts its weight")

	var/babble_cooldown = 0
	var/babble_cooldown_time = 12 SECONDS
	var/scp173_stared = FALSE
	var/observation_range = 6

/mob/living/simple_animal/scp131b/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Eye Pods", SCP_SAFE, "131")

/mob/living/simple_animal/scp131b/Life()
	. = ..()
	if(stat == DEAD)
		return

	process_babbling()
	process_following()
	stare_down_scp173()

/mob/living/simple_animal/scp131b/proc/process_babbling()
	if(world.time < babble_cooldown)
		return

	babble_cooldown = world.time + babble_cooldown_time

	if(prob(25))
		var/babble = pick(speak)
		say(babble)

/mob/living/simple_animal/scp131b/proc/process_following()
	if(client)
		return

	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat != DEAD && !H.SCP)
			if(prob(10))
				step_towards(src, H)
			break

/mob/living/simple_animal/scp131b/proc/stare_down_scp173()
	for(var/mob/living/scp/scp173/scp in view(observation_range, src))
		if(scp.stat != DEAD && scp.observation_system)
			scp.observation_system.observers += src
			scp.observation_system.observation_quality += 2.5
			scp.observation_system.is_being_observed = TRUE
			scp173_stared = TRUE
			return

	scp173_stared = FALSE

/mob/living/simple_animal/scp131b/attack_hand(mob/living/carbon/human/user)
	. = ..()

	if(!user.combat_mode)
		say(pick("Mrrp!", "Bah!", "Wuu!"))
		emote("murmurs at [user]", 1)
		hook_scp_interaction(user, "SCP-131", INTERACTION_TYPE_CARE)

/mob/living/simple_animal/scp131b/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A slightly larger brownish-green teardrop-shaped creature with a single large eye. It babbles like a baby and seems friendly.</span>")
	to_chat(user, "<span class='notice'>It seems to have an intense gaze that could freeze even the most dangerous entities in their tracks.</span>")

/mob/living/simple_animal/scp131b/death()
	scp173_stared = FALSE
	visible_message("<span class='danger'>[src] closes its eye and goes still!</span>")
	..()
