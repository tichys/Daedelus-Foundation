/obj/item/paper/scp012
	name = "On Mount Golgotha"
	icon = 'icons/scp/scp-012.dmi'
	desc = "An old paper of handwritten sheet music, titled \"On Mount Golgotha\". The writing is in a conspicuous blood red."

	w_class = WEIGHT_CLASS_GIGANTIC

	//Config

	///How long for an effect to happen
	var/effect_cooldown = 5 SECONDS
	///Doubt Messages
	var/list/dmessages = list(
		"Oh how will I finish it...",
		"What can I write...",
		"It must be finished...",
		"It cant be finished...",
		"How beautiful..."
		)

	//Mechanical

	///Keeps track of the cooldown
	var/effect_cooldown_counter

	//Audio
	var/datum/looping_sound/scp012/soundloop

/obj/item/paper/scp012/Initialize()
	START_PROCESSING(SSobj, src)

	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"On Mount Golgotha", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_EUCLID, //Obj Class
		"012", //Numerical Designation
		SCP_MEMETIC //Meta Flags, refer to code/_defines/SCP.dm
	)

	SCP.memeticFlags = MVISUAL|MAUDIBLE|MSYNCED //Memetic flags determine required factors for a human to be affected
	SCP.memetic_proc = TYPE_PROC_REF(/obj/item/paper/scp012, memetic_effect) //proc to be called for the effect an affected individual should recieve
	SCP.memetic_sounds = list('sound/scp/scp012/012start.ogg','sound/scp/scp012/012mid1.ogg','sound/scp/scp012/012mid2.ogg','sound/scp/scp012/012mid3.ogg','sound/scp/scp012/012mid4.ogg','sound/scp/scp012/012mid5.ogg','sound/scp/scp012/012mid6.ogg','sound/scp/scp012/012mid7.ogg','sound/scp/scp012/012mid8.ogg','sound/scp/scp012/012mid9.ogg') //not including the end file since if its playing that we can assume the person is being relieve of the effect
	SCP.compInit()

	soundloop = new(src, TRUE)

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

	return ..()

/obj/item/paper/scp012/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(soundloop)
	QDEL_NULL(SCP)
	return ..()

//Mechanics
/obj/item/paper/scp012/proc/memetic_effect(mob/living/carbon/human/H)
	if(!H || H.stat == UNCONSCIOUS) //Unconscious individuals cant keep hurting themselves
		return
	if(H.body_position == LYING_DOWN)
		if(H.do_after_count() > 0)
			return //we are probably already attempting to stand up
		H.get_up()
		return
	if(get_dist(H, src) > 1)
		step_to(H, src)
		H.Stun(10, TRUE)
		return
	if(((world.time - effect_cooldown_counter) > effect_cooldown) || abs((world.time - effect_cooldown_counter) - effect_cooldown) < 0.1 SECONDS) //Last part is so that this can run for all affected humans without worrying about cooldown
		H.face_atom(src)
		H.Stun(60, TRUE)
		if(H.getBruteLoss())
			if(prob(40))
				H.visible_message(span_warning("[H] smears [H.p_their()] blood on \"[name]\", writing musical notes..."), span_danger("It calls to you! You must finish it!"))
			else if(prob(20))
				H.visible_message(span_danger("[H] rips into [H.p_their()] own flesh and covers [H.p_their()] hands in blood!"), span_danger("You rip into your arms and cover your hands in blood! It must be finished!"))
				H.emote("scream")
				H.apply_damage(15, BRUTE, prob(50) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
				H.bleed(50)
			else if(prob(60))
				if(prob(50))
					H.visible_message(span_notice("[H] looks at \"[name]\" and sighs dejectedly."), span_warning(pick(dmessages)))
					playsound(H, "sound/voice/human/emote/sigh_[H.gender].ogg", 100)
				else
					H.visible_message(span_notice("[H] looks at \"[name]\" and cries."), span_warning(pick(dmessages)))
					playsound(H, "sound/voice/human/emote/[H.gender]_cry[pick(list("1","2"))].ogg", 100)
		else
			if(prob(40))
				H.visible_message(span_danger("[H] rips into [H.p_their()] own flesh and covers [H.p_their()] hands in blood!"), span_danger("You rip into your arms and cover your hands in blood! It must be finished!"))
				H.emote("scream")
				H.apply_damage(15, BRUTE, prob(50) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
				H.bleed(50)
			else if(prob(70))
				if(prob(50))
					H.visible_message(span_notice("[H] looks at \"[name]\" and sighs dejectedly."), span_warning(pick(dmessages)))
					playsound(H, "sound/voice/human/emote/sigh_[H.gender].ogg", 100)
				else
					H.visible_message(span_notice("[H] looks at \"[name]\" and cries."), span_warning(pick(dmessages)))
					playsound(H, "sound/voice/human/emote/[H.gender]_cry[pick(list("1","2"))].ogg", 100)

		// Apply sanity and vision effects
		H.adjustSanity(-25, "scp012_memetic_effect")
		H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 60 SECONDS, 3)
		H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 120 SECONDS, 2)
		H.add_sanity_effect(SANITY_EFFECT_ANXIETY, 90 SECONDS, 2)

		// Apply vision effects
		// Vision effects removed (Foundation-19 style)

		effect_cooldown_counter = world.time
		// notify research via memetic component hook; SCP datum will emit COMSIG_SCP_MEMETIC_AFFECTED

// Cross-SCP interaction methods
/obj/item/paper/scp012/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage SCP-012
	to_chat(victim, span_warning("The corrosive effect damages the sheet music!"))
	// Reduce memetic effect temporarily
	effect_cooldown = 10 SECONDS

/obj/item/paper/scp012/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can help resist SCP-012's effects
	to_chat(patient, span_notice("The cure's power helps you resist the sheet music's influence."))
	patient.adjustSanity(15, "cure_protection")
	patient.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)
	patient.remove_sanity_effect(SANITY_EFFECT_PARANOIA)

/obj/item/paper/scp012/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be amplified by SCP-012
	if(target in range(3, src))
		to_chat(target, span_warning("The sheet music's influence amplifies your rage!"))
		target.adjustSanity(-20, "amplified_rage")

/obj/item/paper/scp012/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-012
	if(viewer in range(3, src))
		to_chat(viewer, span_danger("You see a statue near the sheet music!"))
		viewer.adjustSanity(-10, "scp173_near_012")

/obj/item/paper/scp012/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-012's effects
	if(adaptor in range(3, src))
		to_chat(adaptor, span_notice("Your adaptation helps you resist the sheet music's influence."))
		adaptor.adjustSanity(20, "adaptation_resistance")

/obj/item/paper/scp012/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-012
	if(host in range(3, src))
		to_chat(host, span_notice("The mask's personality finds the sheet music fascinating."))
		host.adjustSanity(10, "mask_interest")

/obj/item/paper/scp012/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-012's effects
	if(explorer in range(3, src))
		to_chat(explorer, span_warning("The stairwell's psychological pressure amplifies the sheet music's influence!"))
		explorer.adjustSanity(-30, "amplified_memetic")

// Overrides

/obj/item/paper/scp012/process(delta_Time)
	SCP.meme_comp.check_viewers()
	SCP.meme_comp.activate_memetic_effects() //Memetic effects are synced because of how we handle sound

// Very Fine - Deletes itself and forces every mob on z level to bleed temporarily while playing the silly music. Wait until 914 is ported to uncomment
// /obj/item/paper/scp012/Conversion914(mode = MODE_ONE_TO_ONE, mob/user = usr)
// 	switch(mode)
// 		if(MODE_VERY_FINE)
// 			for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
// 				if(H.z != z)
// 					continue
// 				H.playsound_local(get_turf(H), looping_sound, 50, FALSE)
// 				to_chat(H, SPAN_USERDANGER("The music is bleeding into your body!"))
// 				flash_color(H, flash_color = "#ff4444", flash_time = 200)
// 				for(var/i = 1 to 50)
// 					addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, bleed), 2), i * rand(2 SECONDS, 10 SECONDS))
// 			return null
// 	return ..()
