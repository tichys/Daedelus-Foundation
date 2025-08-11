/mob/living/simple_animal/hostile/retaliate/scp066
	name = "ball of yarn"
	desc = "An amorphous red mass of braided yarn and ribbon."
	icon = 'icons/scp/nonhumanoidscps(32x32).dmi'

	icon_state = "066"
	icon_living = "066"
	icon_dead = "dead"
	response_help_continuous = "plays with"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "kicks"

	maxHealth = 500
	health = 500

	see_in_dark = 3

	var/movement_sound = 'sound/scp/scp066/Roll.ogg'

	//Config

	///How long until we can do a regular emote
	var/emote_passive_cooldown = 10 SECONDS
	///How long until we can do a harmful emote
	var/emote_harmful_cooldown = 2 MINUTES

	//Mechanical
	speak_chance = 2
	var/emote_passive_track = 0
	var/emote_harmful_track = 0


	speak = list("Eric?", "Are you Eric?", "Eric, is that you?", "Have you seen Eric?")
	speak_emote = list("makes a strange sound.", "makes an odd noise.", "plays a strange tune.")
	emote_hear = list(
		'sound/scp/scp066/Notes1.ogg' = 16,
		'sound/scp/scp066/Notes2.ogg' = 16,
		'sound/scp/scp066/Notes3.ogg' = 16,
		'sound/scp/scp066/Notes4.ogg' = 16,
		'sound/scp/scp066/Notes5.ogg' = 16,
		'sound/scp/scp066/Notes6.ogg' = 16,
		'sound/scp/scp066/Eric1.ogg' = 33,
		'sound/scp/scp066/Eric2.ogg' = 33,
		'sound/scp/scp066/Eric3.ogg' = 33
		)


/mob/living/simple_animal/hostile/retaliate/scp066/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"ball of yarn", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_EUCLID, //Obj Class
		"066", //Numerical Designation
		SCP_PLAYABLE|SCP_MEMETIC
	)

	SCP.memeticFlags = MAUDIBLE
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/simple_animal/hostile/retaliate/scp066, audibleEffect)
	SCP.memetic_sounds = list('sound/scp/scp066/BeethovenLOUD.ogg')
	SCP.compInit()

	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/simple_animal/hostile/retaliate/scp066/proc/Eric,
		/mob/living/simple_animal/hostile/retaliate/scp066/proc/LoudNoise,
		/mob/living/simple_animal/hostile/retaliate/scp066/proc/Noise,
	))

	RegisterSignal(src, COMSIG_SCP066_ATTACK_TARGET, PROC_REF(handle_attack_target_signal))
	RegisterSignal(src, COMSIG_SCP066_AUTOHISS, PROC_REF(handle_autohiss_signal))
	RegisterSignal(src, COMSIG_SCP066_NOISE_EMOTE, PROC_REF(handle_noise_emote_signal))
	RegisterSignal(src, COMSIG_SCP066_ERIC_EMOTE, PROC_REF(handle_eric_emote_signal))
	RegisterSignal(src, COMSIG_SCP066_LOUD_NOISE_EMOTE, PROC_REF(handle_loud_noise_emote_signal))

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))


/mob/living/simple_animal/hostile/retaliate/scp066/proc/can_attack(atom/movable/the_target, vision_required)
	if((world.time - emote_harmful_track) > emote_harmful_cooldown)
		var/datum/targetting_datum/basic/target_checker = new
		return target_checker.can_attack(src, the_target)
	else
		return FALSE

//Mechanics

/mob/living/simple_animal/hostile/retaliate/scp066/proc/audibleEffect(mob/living/carbon/human/target)

	var/obj/item/organ/ears/ears = getorganslot(ORGAN_SLOT_EARS)

	target.Stun(4)
	target.adjust_confusion(10 SECONDS)
	ears.adjustEarDamage(rand(10, 20))
	shake_camera(target, 18, 5)

	// Apply sanity and vision effects
	target.adjustSanity(-15, "scp066_loud_noise")
	target.add_sanity_effect(SANITY_EFFECT_ANXIETY, 60 SECONDS, 2)
	target.add_sanity_effect(SANITY_EFFECT_PARANOIA, 90 SECONDS, 1)
	// Vision effects removed (Foundation-19 style)

/mob/living/simple_animal/hostile/retaliate/scp066/proc/imitate(atom/movable/imitate_target as obj|mob)
	var/icon/I = new /icon(imitate_target.icon, imitate_target.icon_state)
	I.ColorTone("#891313")
	icon = I
	name = imitate_target.name
	desc = "It appears to be \a [imitate_target] made out of yarn..."

// Cross-SCP interaction methods
/mob/living/simple_animal/hostile/retaliate/scp066/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage SCP-066
	to_chat(victim, span_warning("The corrosive effect damages the yarn ball!"))
	// Reduce health temporarily
	adjustHealth(50)

/mob/living/simple_animal/hostile/retaliate/scp066/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can help resist SCP-066's effects
	if(patient in range(5, src))
		to_chat(patient, span_notice("The cure's power helps you resist the yarn ball's noise."))
		patient.adjustSanity(10, "cure_protection")

/mob/living/simple_animal/hostile/retaliate/scp066/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be amplified by SCP-066
	if(target in range(5, src))
		to_chat(target, span_warning("The yarn ball's noise amplifies your rage!"))
		target.adjustSanity(-20, "amplified_rage")

/mob/living/simple_animal/hostile/retaliate/scp066/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-066
	if(viewer in range(5, src))
		to_chat(viewer, span_danger("You see a statue near the yarn ball!"))
		viewer.adjustSanity(-10, "scp173_near_066")

/mob/living/simple_animal/hostile/retaliate/scp066/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-066's effects
	if(adaptor in range(5, src))
		to_chat(adaptor, span_notice("Your adaptation helps you resist the yarn ball's noise."))
		adaptor.adjustSanity(15, "adaptation_resistance")

/mob/living/simple_animal/hostile/retaliate/scp066/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-066
	if(host in range(5, src))
		to_chat(host, span_notice("The mask's personality finds the yarn ball's music interesting."))
		host.adjustSanity(8, "mask_music_appreciation")

/mob/living/simple_animal/hostile/retaliate/scp066/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-066's effects
	if(explorer in range(5, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure amplifies the yarn ball's noise!"))
		explorer.adjustSanity(-25, "amplified_noise")

//Overrides

/mob/living/simple_animal/hostile/retaliate/scp066/UnarmedAttack(atom/A, proximity) //Allows 066 to imitate the look of objects.
	if(A == src)
		icon = new /icon(initial(icon), initial(icon_state))
		desc = initial(desc)
		name = SCP.name

	else if(isitem(A))
		var/obj/item/Itarget = A

		if(Itarget.w_class > MOB_SIZE_HUMAN)
			to_chat(src, span_warning("That is too big for you to imitate!"))
			return
		imitate(Itarget)

	else if(ismob(A) && !ishuman(A) && isliving(A))
		var/mob/living/Imob = A

		if(Imob.mob_size > MOB_SIZE_SMALL)
			to_chat(src, span_warning("That is too big for you to imitate!"))
			return
		imitate(Imob)

	else
		to_chat(src, span_warning("You cannot imitate [A]!"))
	return // Explicitly return to prevent further processing of attack

/mob/living/simple_animal/hostile/retaliate/scp066/proc/attack_target(atom/A)
	SEND_SIGNAL(src, COMSIG_SCP066_ATTACK_TARGET, A)

/mob/living/simple_animal/hostile/retaliate/scp066/proc/handle_autohiss(message, datum/language/L)
	if((world.time - emote_passive_track) > emote_passive_cooldown) //technically checked twice but this prevents the cooldown message form being spammed to 066's client.
		SEND_SIGNAL(src, COMSIG_SCP066_AUTOHISS, message, L)

// SCP-066 emotes

/mob/living/simple_animal/hostile/retaliate/scp066/proc/Noise()
	set category = "SCP-066"
	set name = "Make a Noise"

	if ((world.time - emote_passive_track) > emote_passive_cooldown)
		SEND_SIGNAL(src, COMSIG_SCP066_NOISE_EMOTE)
		emote_passive_track = world.time
	else
		to_chat(usr, span_warning("You are on cooldown!"))

/mob/living/simple_animal/hostile/retaliate/scp066/proc/Eric()
	set category = "SCP-066"
	set name = "Eric?"

	if ((world.time - emote_passive_track) > emote_passive_cooldown)
		SEND_SIGNAL(src, COMSIG_SCP066_ERIC_EMOTE)
		emote_passive_track = world.time
	else
		to_chat(usr, span_warning("You are on cooldown!"))

/mob/living/simple_animal/hostile/retaliate/scp066/proc/LoudNoise()
	set category = "SCP-066"
	set name = "Deafening Noise"

	if ((world.time - emote_harmful_track) > emote_harmful_cooldown)
		SEND_SIGNAL(src, COMSIG_SCP066_LOUD_NOISE_EMOTE)
		emote_harmful_track = world.time
		return TRUE
	else
		to_chat(usr, span_warning("You are on cooldown!"))
		return FALSE

/mob/living/simple_animal/hostile/retaliate/scp066/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, range)
  message = pick(speak)
  return ..()

/mob/living/simple_animal/hostile/retaliate/scp066/proc/handle_attack_target_signal(datum/source, atom/A)
	// Original LoudNoise() logic
	playsound(src, 'sound/scp/scp066/BeethovenLOUD.ogg', 40)
	// play_fov_effect(loc, 7, "talk", ignore_self = TRUE)

/mob/living/simple_animal/hostile/retaliate/scp066/proc/handle_autohiss_signal(datum/source, message, datum/language/L)
	// Original Eric() logic
	var/sound = pick('sound/scp/scp066/Eric1.ogg', 'sound/scp/scp066/Eric2.ogg', 'sound/scp/scp066/Eric3.ogg')
	playsound(src, sound, 25)
	// play_fov_effect(loc, 7, "talk", ignore_self = TRUE)

/mob/living/simple_animal/hostile/retaliate/scp066/proc/handle_noise_emote_signal(datum/source)
	// Original Noise() logic
	var/sound = pick('sound/scp/scp066/Notes1.ogg', 'sound/scp/scp066/Notes2.ogg', 'sound/scp/scp066/Notes3.ogg', 'sound/scp/scp066/Notes4.ogg', 'sound/scp/scp066/Notes5.ogg', 'sound/scp/scp066/Notes6.ogg')
	playsound(src, sound, 25)
	// play_fov_effect(loc, 7, "talk", ignore_self = TRUE)

/mob/living/simple_animal/hostile/retaliate/scp066/proc/handle_eric_emote_signal(datum/source)
	// Original Eric() logic (duplicate, but kept for clarity of signal handling)
	var/sound = pick('sound/scp/scp066/Eric1.ogg', 'sound/scp/scp066/Eric2.ogg', 'sound/scp/scp066/Eric3.ogg')
	playsound(src, sound, 25)
	// play_fov_effect(loc, 7, "talk", ignore_self = TRUE)

/mob/living/simple_animal/hostile/retaliate/scp066/proc/handle_loud_noise_emote_signal(datum/source)
	// Original LoudNoise() logic (duplicate, but kept for clarity of signal handling)
	playsound(src, 'sound/scp/scp066/BeethovenLOUD.ogg', 40)
	// play_fov_effect(loc, 7, "talk", ignore_self = TRUE)
