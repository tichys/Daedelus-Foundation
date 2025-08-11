// SCP-1471: malO ver1.0.0
// A mobile app that shows a shadowy figure in photos and affects users psychologically

/obj/item/phone/scp1471
	name = "SCP-1471"
	desc = "A smartphone with the malO app installed. The app shows a shadowy figure in photos."
	icon = 'icons/obj/device.dmi'
	icon_state = "scp1471"
	w_class = WEIGHT_CLASS_SMALL
	var/app_active = FALSE
	var/app_version = "1.0.0"
	var/shadow_figure_intensity = 1
	var/max_intensity = 5
	var/affected_users = list()
	var/app_cooldown = 0
	var/APP_COOLDOWN_TIME = 30 SECONDS
	var/photo_count = 0
	var/max_photos = 10

/obj/item/phone/scp1471/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src,
		"malO app",
		SCP_EUCLID,
		"1471",
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL|MAUDIBLE
	SCP.memetic_proc = TYPE_PROC_REF(/obj/item/phone/scp1471, app_effect)
	SCP.memetic_sounds = list('sound/scp/scp1471/notification1.ogg', 'sound/scp/scp1471/notification2.ogg', 'sound/scp/scp1471/notification3.ogg')
	SCP.compInit()

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))
	RegisterSignal(src, COMSIG_SCP035_POSSESSION_STARTED, PROC_REF(on_possession_started))
	RegisterSignal(src, COMSIG_SCP087_EXPLORATION_STARTED, PROC_REF(on_exploration_started))

/obj/item/phone/scp1471/Destroy()
	QDEL_NULL(SCP)
	return ..()

/obj/item/phone/scp1471/attack_self(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(world.time < app_cooldown)
		to_chat(H, span_warning("The app needs time to process."))
		return

	// Activate the app
	activate_app(H)

/obj/item/phone/scp1471/proc/activate_app(mob/living/carbon/human/user)
	if(app_active)
		to_chat(user, span_warning("The app is already active."))
		return

	app_active = TRUE
	app_cooldown = world.time + APP_COOLDOWN_TIME

	to_chat(user, span_notice("You open the malO app. A shadowy figure appears in the camera view."))

	// Apply app effects
	apply_app_effects(user)

	// Add to affected users
	if(!(user in affected_users))
		affected_users += user

	// Start app processing
	START_PROCESSING(SSobj, src)

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP1471_APP_ACTIVATED, user)

/obj/item/phone/scp1471/proc/apply_app_effects(mob/living/carbon/human/user)
	// Apply psychological effects
	user.adjustSanity(-10, "scp1471_app_activation")
	user.add_sanity_effect(SANITY_EFFECT_PARANOIA, 120 SECONDS, shadow_figure_intensity)
	user.add_sanity_effect(SANITY_EFFECT_ANXIETY, 90 SECONDS, shadow_figure_intensity)

	// Apply vision effects
	// Vision effects removed (Foundation-19 style)

	// Show shadow figure message
	to_chat(user, span_warning("You notice a shadowy figure in the background of your photos..."))

/obj/item/phone/scp1471/process()
	. = ..()
	if(!app_active)
		STOP_PROCESSING(SSobj, src)
		return

	// Apply continuous effects to affected users
	for(var/mob/living/carbon/human/H in affected_users)
		if(!H || H.stat == DEAD)
			affected_users -= H
			continue

		// Apply continuous psychological pressure
		H.adjustSanity(-0.5, "scp1471_continuous")

		// Chance to increase shadow figure intensity
		if(prob(5) && shadow_figure_intensity < max_intensity)
			shadow_figure_intensity++
			to_chat(H, span_warning("The shadowy figure seems to be getting closer..."))
			H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 60 SECONDS, shadow_figure_intensity)

		// Chance to take a photo
		if(prob(10) && photo_count < max_photos)
			take_photo(H)

/obj/item/phone/scp1471/proc/take_photo(mob/living/carbon/human/user)
	photo_count++
	to_chat(user, span_notice("The app automatically takes a photo. The shadowy figure is clearly visible."))
	user.adjustSanity(-5, "scp1471_photo_taken")
	user.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 30 SECONDS, 1)

	playsound(user, 'sound/scp/scp1471/camera.ogg', 50, TRUE)

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP1471_PHOTO_TAKEN, user, photo_count)

/obj/item/phone/scp1471/proc/app_effect(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	// Apply memetic effect
	H.adjustSanity(-15, "scp1471_memetic")
	H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 180 SECONDS, shadow_figure_intensity)
	H.add_sanity_effect(SANITY_EFFECT_HALLUCINATIONS, 120 SECONDS, 2)

	// Apply vision effects
			// Vision effects removed (Foundation-19 style)

	to_chat(H, span_danger("You see the shadowy figure everywhere you look!"))

// SCP-1471 abilities
/obj/item/phone/scp1471/verb/take_manual_photo()
	set name = "Take Photo"
	set category = "SCP-1471"
	set src in usr

	if(!ishuman(usr))
		to_chat(usr, span_warning("This only works for humans."))
		return

	if(!app_active)
		to_chat(usr, span_warning("The app is not active."))
		return

	if(photo_count >= max_photos)
		to_chat(usr, span_warning("Maximum number of photos reached."))
		return

	var/mob/living/carbon/human/user = usr
	take_photo(user)

/obj/item/phone/scp1471/verb/increase_intensity()
	set name = "Increase Intensity"
	set category = "SCP-1471"
	set src in usr

	if(!ishuman(usr))
		to_chat(usr, span_warning("This only works for humans."))
		return

	if(!app_active)
		to_chat(usr, span_warning("The app is not active."))
		return

	if(shadow_figure_intensity >= max_intensity)
		to_chat(usr, span_warning("Maximum intensity already reached."))
		return

	shadow_figure_intensity++
	to_chat(usr, span_notice("Shadow figure intensity increased to [shadow_figure_intensity]."))

	// Apply stronger effects
	for(var/mob/living/carbon/human/H in affected_users)
		H.adjustSanity(-5, "scp1471_intensity_increase")
		H.add_sanity_effect(SANITY_EFFECT_PARANOIA, 60 SECONDS, shadow_figure_intensity)

/obj/item/phone/scp1471/verb/deactivate_app()
	set name = "Deactivate App"
	set category = "SCP-1471"
	set src in usr

	if(!ishuman(usr))
		to_chat(usr, span_warning("This only works for humans."))
		return

	if(!app_active)
		to_chat(usr, span_warning("The app is not active."))
		return

	app_active = FALSE
	to_chat(usr, span_notice("You close the malO app. The shadowy figure disappears."))

	// Remove effects from all affected users
	for(var/mob/living/carbon/human/H in affected_users)
		H.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
		H.remove_sanity_effect(SANITY_EFFECT_ANXIETY)
		H.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)
		// Vision effects removed (Foundation-19 style)
		H.adjustSanity(10, "scp1471_app_deactivated")

	affected_users = list()
	STOP_PROCESSING(SSobj, src)

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP1471_APP_DEACTIVATED, usr)

/obj/item/phone/scp1471/examine(mob/user)
	. = ..()
	if(app_active)
		. += span_notice("The malO app is currently active.")
		. += span_notice("Shadow figure intensity: [shadow_figure_intensity]/[max_intensity]")
		. += span_notice("Photos taken: [photo_count]/[max_photos]")
		. += span_notice("Affected users: [length(affected_users)]")
	else
		. += span_notice("The malO app is inactive.")

// Cross-SCP interaction methods
/obj/item/phone/scp1471/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	// SCP-106's corrosion can damage SCP-1471
	to_chat(victim, span_warning("The corrosive effect damages the phone!"))
	// Reduce effectiveness temporarily
	shadow_figure_intensity = max(1, shadow_figure_intensity - 1)

/obj/item/phone/scp1471/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	// SCP-049's cure can help resist SCP-1471's effects
	if(patient in affected_users)
		to_chat(patient, span_notice("The cure's power helps you resist the app's influence."))
		patient.adjustSanity(15, "cure_protection")
		patient.remove_sanity_effect(SANITY_EFFECT_PARANOIA)
		patient.remove_sanity_effect(SANITY_EFFECT_HALLUCINATIONS)

/obj/item/phone/scp1471/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	// SCP-096's rage can be amplified by SCP-1471
	if(target in affected_users)
		to_chat(target, span_warning("The app's psychological pressure amplifies your rage!"))
		target.adjustSanity(-20, "amplified_rage")

/obj/item/phone/scp1471/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	// SCP-173 can appear in SCP-1471 photos
	if(viewer in affected_users)
		to_chat(viewer, span_danger("You see a statue in the app's photos!"))
		viewer.adjustSanity(-15, "scp173_in_photos")

/obj/item/phone/scp1471/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	// SCP-682's adaptation can resist SCP-1471's effects
	if(adaptor in affected_users)
		to_chat(adaptor, span_notice("Your adaptation helps you resist the app's influence."))
		adaptor.adjustSanity(10, "adaptation_resistance")

/obj/item/phone/scp1471/proc/on_possession_started(datum/source, mob/living/carbon/human/host, datum/scp035_personality/personality)
	// SCP-035's possession can interact with SCP-1471
	if(host in affected_users)
		to_chat(host, span_notice("The mask's personality finds the app's effects interesting."))
		host.adjustSanity(5, "mask_app_interest")

/obj/item/phone/scp1471/proc/on_exploration_started(datum/source, mob/living/carbon/human/explorer, datum/scp087_level/level)
	// SCP-087 can amplify SCP-1471's effects
	if(explorer in affected_users)
		to_chat(explorer, span_warning("The stairwell's psychological pressure amplifies the app's effects!"))
		explorer.adjustSanity(-25, "amplified_app_effects")

// Research system integration
/obj/item/phone/scp1471/proc/get_research_data()
	var/list/data = list()
	data["app_active"] = app_active
	data["app_version"] = app_version
	data["shadow_figure_intensity"] = shadow_figure_intensity
	data["max_intensity"] = max_intensity
	data["affected_users"] = length(affected_users)
	data["photo_count"] = photo_count
	data["max_photos"] = max_photos
	data["app_cooldown_remaining"] = max(0, app_cooldown - world.time)
	return data

