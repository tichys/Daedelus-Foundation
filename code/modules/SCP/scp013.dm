/obj/item/clothing/mask/cigarette/scp013
	name = "'Blue Lady' cigarette"
	desc = "The words 'Blue Lady' are written on this deftly-rolled cigarette in blue ink."

	smoketime = 24 HOURS //dont want this going out before anyone undergoing the effects is finished

	//Config
	///Our callback messages to the affected individual that happen from time to time
	var/list/blmessages = list(
		"I miss her...",
		"Where did she go...",
		"You spot a glimpse of her in a nearby reflection...",
		"I know her I just can't remember...",
		"I love her... Where did she go?"
	)
	//Mechanical

	///Humans who have smoked 013, helps us prevent it from extinguishing if someone is still undergoing the effects
	var/list/affected_weakref

/obj/item/clothing/mask/cigarette/scp013/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"'Blue Lady' cigarette", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_SAFE, //Obj Class
		"013", //Numerical Designation
	)

	LAZYINITLIST(affected_weakref)

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

/obj/item/clothing/mask/cigarette/scp013/Destroy()
	LAZYNULL(affected_weakref)
	QDEL_NULL(SCP)
	return ..()

//Mechanics

/obj/item/clothing/mask/cigarette/scp013/proc/effect(mob/living/carbon/human/H)
	if(!lit)
		return
	if(H.humanStageHandler.createStage("BlueLady"))
		update_013_status(H)
		LAZYOR(affected_weakref,WEAKREF(H))

/obj/item/clothing/mask/cigarette/scp013/proc/update_013_status(mob/living/carbon/human/H)
	H.humanStageHandler.adjustStage("BlueLady", 1)
	switch(H.humanStageHandler.getStage("BlueLady"))
		if(1)
			to_chat(H, span_boldnotice("You can't remember what you did this morning, or the day before..."))
			// Apply sanity and vision effects
			H.adjustSanity(-10, "scp013_memory_loss")
			H.add_sanity_effect(SANITY_EFFECT_ANXIETY, 120 SECONDS, 1)
			// Vision effects removed (Foundation-19 style)
			addtimer(CALLBACK(src, PROC_REF(update_013_status), H), 2 MINUTES)
		if(2)
			to_chat(H, span_boldnotice("You remember now, you were looking in the mirror as you painted your lips blue."))
			// Apply stronger effects
			H.adjustSanity(-15, "scp013_blue_lady_memory")
			H.add_sanity_effect(SANITY_EFFECT_DEPRESSION, 180 SECONDS, 2)
			// Vision effects removed (Foundation-19 style)
			addtimer(CALLBACK(src, PROC_REF(update_013_status), H), 1 MINUTES)
			H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "bluelady", get_bluelady_image(H), H)
		if(3)
			to_chat(H, span_boldnotice("Briefly, she fades from your mind. You miss her already."))
			// Intensify effects
			H.adjustSanity(-20, "scp013_missing_her")
			H.add_sanity_effect(SANITY_EFFECT_WITHDRAWAL, 240 SECONDS, 2)
			H.add_sanity_effect(SANITY_EFFECT_DEPRESSION, 240 SECONDS, 3)
			// Vision effects removed (Foundation-19 style)
			addtimer(CALLBACK(src, PROC_REF(update_013_status), H), 2 MINUTE)
			H.remove_alt_appearance("bluelady")
		if(4)
			to_chat(H, span_boldnotice("You put the blue dress on, that's all you can recall. How did you get here?"))
			// Severe effects
			H.adjustSanity(-25, "scp013_identity_confusion")
			H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 300 SECONDS, 2)
			H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 300 SECONDS, 2)
			// Vision effects removed (Foundation-19 style)
			addtimer(CALLBACK(src, PROC_REF(update_013_status), H), 3 MINUTE)
			H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "bluelady", get_bluelady_image(H), H)
		if(5)
			to_chat(H, span_boldnotice("Who were you? You try to remember in more detail..."))
			// Critical effects
			H.adjustSanity(-30, "scp013_identity_crisis")
			H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 360 SECONDS, 3)
			H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 360 SECONDS, 3)
			// Vision effects removed (Foundation-19 style)
			addtimer(CALLBACK(src, PROC_REF(update_013_status), H), 1 MINUTE)
		if(6)
			to_chat(H, span_boldnotice("I can't live without her..."))
			// Catastrophic effects
			H.adjustSanity(-40, "scp013_despair")
			H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 420 SECONDS, 4)
			H.add_sanity_effect(SANITY_EFFECT_DEPRESSION, 420 SECONDS, 4)
			H.add_sanity_effect(SANITY_EFFECT_WITHDRAWAL, 420 SECONDS, 3)
			// Vision effects removed (Foundation-19 style)
			addtimer(CALLBACK(src, PROC_REF(update_013_status), H), 55 SECONDS)
		if(7)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, bluelady_message), blmessages), 10 SECONDS)
			LAZYREMOVE(affected_weakref, WEAKREF(H))
			if(!LAZYLEN(affected_weakref))
				put_out(H)

/obj/item/clothing/mask/cigarette/scp013/proc/get_bluelady_image(mob/living/carbon/human/H)
	var/image/I = image('icons/mob/human_parts_greyscale.dmi', H, "human_chest_f")
	I.override = 1
	I.add_overlay(image('icons/mob/human_parts_greyscale.dmi', H, "human_r_arm"))
	I.add_overlay(image('icons/mob/human_parts_greyscale.dmi', H, "human_l_arm"))
	I.add_overlay(image('icons/mob/human_parts_greyscale.dmi', H, "human_r_hand"))
	I.add_overlay(image('icons/mob/human_parts_greyscale.dmi', H, "human_l_hand"))
	I.add_overlay(image('icons/mob/human_parts_greyscale.dmi', H, "human_r_leg"))
	I.add_overlay(image('icons/mob/human_parts_greyscale.dmi', H, "human_l_leg"))
	I.add_overlay(image('icons/scp/scp-013-overlay.dmi', H, "bl_head"))

	var/image/hair = image('icons/mob/hair.dmi', icon_state = "hair_emofringe")
	hair.color = "#15120e"
	I.add_overlay(hair)
	I.add_overlay(image('icons/scp/scp-013-overlay.dmi', icon_state = "lady_in_blue_u"))
	I.add_overlay(image('icons/scp/scp-013-overlay.dmi', icon_state = "blue_heels"))

	return I

// Cross-SCP interaction methods
/obj/item/clothing/mask/cigarette/scp013/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can extinguish SCP-013
	if(victim in affected_weakref)
		to_chat(victim, span_warning("The corrosive effect extinguishes the cigarette!"))
		put_out(victim)

/obj/item/clothing/mask/cigarette/scp013/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can help resist SCP-013's effects
	if(patient in affected_weakref)
		to_chat(patient, span_notice("The cure's power helps you resist the cigarette's influence."))
		patient.adjustSanity(20, "cure_protection")
		patient.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)
		patient.remove_sanity_effect(SANITY_EFFECT_DEPRESSION)

/obj/item/clothing/mask/cigarette/scp013/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be calmed by SCP-013
	if(target in affected_weakref)
		to_chat(target, span_notice("The cigarette's calming effect helps soothe your rage."))
		target.adjustSanity(15, "cigarette_calm")

/obj/item/clothing/mask/cigarette/scp013/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear near SCP-013 users
	if(viewer in affected_weakref)
		to_chat(viewer, span_danger("You see a statue in the reflection!"))
		viewer.adjustSanity(-15, "scp173_reflection")

/obj/item/clothing/mask/cigarette/scp013/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-013's effects
	if(adaptor in affected_weakref)
		to_chat(adaptor, span_notice("Your adaptation helps you resist the cigarette's influence."))
		adaptor.adjustSanity(25, "adaptation_resistance")

/obj/item/clothing/mask/cigarette/scp013/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-013
	if(host in affected_weakref)
		to_chat(host, span_notice("The mask's personality finds the cigarette's effects interesting."))
		host.adjustSanity(10, "mask_curiosity")

/obj/item/clothing/mask/cigarette/scp013/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-013's effects
	if(explorer in affected_weakref)
		to_chat(explorer, span_warning("The stairwell's psychological pressure amplifies the cigarette's effects!"))
		explorer.adjustSanity(-25, "amplified_cigarette_effect")

//Overrides

/obj/item/clothing/mask/cigarette/scp013/light(flavor_text = null)
	. = ..()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/H = loc
	if(H.get_slot_by_item(src) != ITEM_SLOT_MASK)
		return
	effect(H)
	SEND_SIGNAL(src, COMSIG_SCP013_SMOKED, H)

/obj/item/clothing/mask/cigarette/scp013/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_MASK || !ishuman(user))
		return
	effect(user)

/obj/item/clothing/mask/cigarette/use_reagents(mob/living/carbon/user, drag)
	reagents.add_reagent_list(list_reagents) //infinite smoking chems
	return ..()

/obj/item/clothing/mask/cigarette/put_out(mob/user, done_early = FALSE)
	if(done_early)
		if(user)
			to_chat(user, span_notice("You cant bring yourself to put it out..."))
		return
	return ..()

//Human mechanics

/mob/living/carbon/human/proc/bluelady_message(blmessages) //This is needed since once the cigarette goes out it is no longer an instance of 013 (and callbacks dont work)
	if(!humanStageHandler.getStage("BlueLady")) //shouldent happen, but if admins do some fuckery with stages mid game then this will account for it
		return
	if(prob(15))
		to_chat(src, span_boldnotice(pick(blmessages)))
		// Apply ongoing sanity effects
		adjustSanity(-5, "bluelady_message")
		add_sanity_effect(SANITY_EFFECT_DEPRESSION, 30 SECONDS, 1)
	addtimer(CALLBACK(src, PROC_REF(bluelady_message), blmessages), 45 SECONDS)

//Cigarrete Pack

/obj/item/storage/fancy/cigarettes/bluelady
	name = "Pack of 'Blue Lady' cigarettes"
	icon_state = "bl"
	base_icon_state = "bl"
	desc = "A packet of six Blue Lady cigarettes. The SCP logo is stamped on the paper."

	spawn_type = /obj/item/clothing/mask/cigarette/scp013
