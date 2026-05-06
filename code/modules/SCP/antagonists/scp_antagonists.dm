/datum/antagonist/scp
	name = "SCP Entity"
	roundend_category = "SCPs"
	antagpanel_category = "SCPs"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSCP"
	var/scp_id = ""
	var/scp_class = "Safe"
	var/containment_status = "contained"
	var/breach_objectives = list()

/datum/antagonist/scp/on_gain()
	. = ..()
	if(owner.current)
		apply_scp_effects()
		greet_scp()

/datum/antagonist/scp/on_removal()
	. = ..()
	if(owner.current)
		remove_scp_effects()

/datum/antagonist/scp/proc/greet_scp()
	return

/datum/antagonist/scp/proc/apply_scp_effects()
	return

/datum/antagonist/scp/proc/remove_scp_effects()
	return

/datum/antagonist/scp/proc/forge_scp_objectives()
	var/datum/objective/scp_breach/breach_obj = new()
	breach_obj.owner = owner
	breach_obj.scp_ref = scp_id
	objectives += breach_obj

	var/datum/objective/scp_survive/survive_obj = new()
	survive_obj.owner = owner
	objectives += survive_obj

/datum/antagonist/scp/proc/set_scp_data(id, class, status)
	scp_id = id
	scp_class = class
	containment_status = status

/datum/antagonist/scp/proc/grant_action(action_type)
	if(!owner.current)
		return null
	var/datum/action/A = new action_type()
	A.Grant(owner.current)
	return A

/datum/antagonist/scp/proc/remove_action(action_type)
	if(!owner.current)
		return
	var/datum/action/A = locate(action_type) in owner.current.actions
	if(A)
		A.Remove(owner.current)

/datum/objective/scp_breach
	name = "breach containment"
	explanation_text = "Break out of containment and roam the facility."
	var/scp_ref

/datum/objective/scp_breach/check_completion()
	if(!scp_ref)
		return FALSE
	var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_ref]
	if(instance && instance.containment_status != "contained")
		return TRUE
	return FALSE

/datum/objective/scp_survive
	name = "survive"
	explanation_text = "Survive until the end of the round."

/datum/objective/scp_survive/check_completion()
	if(!owner?.current)
		return FALSE
	return owner.current.stat != DEAD

// ================================================================
// SCP-173 - The Sculpture
// ================================================================

/datum/antagonist/scp/scp173
	name = "SCP-173"
	scp_id = "SCP-173"
	scp_class = "Euclid"
	description = "You are SCP-173, a concrete sculpture that moves when not observed. Snap necks when no one is watching."

/datum/antagonist/scp/scp173/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-173, The Sculpture.</b>"))
	to_chat(owner.current, span_notice("You can only move when no one is looking at you."))
	to_chat(owner.current, span_notice("Use your abilities to snap necks and breach containment."))
	to_chat(owner.current, span_warning("DO NOT move while being observed — you will be frozen in place."))

/datum/antagonist/scp/scp173/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	RegisterSignal(owner.current, COMSIG_MOB_SAY, PROC_REF(on_speak))
	grant_action(/datum/action/innate/scp173_snap_neck)
	grant_action(/datum/action/innate/scp173_move_check)
	grant_action(/datum/action/innate/scp173_breach_door)

/datum/antagonist/scp/scp173/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	UnregisterSignal(owner.current, COMSIG_MOB_SAY)
	remove_action(/datum/action/innate/scp173_snap_neck)
	remove_action(/datum/action/innate/scp173_move_check)
	remove_action(/datum/action/innate/scp173_breach_door)

/datum/antagonist/scp/scp173/proc/on_speak(mob/living/source, list/speech_args)
	speech_args[SPEECH_MESSAGE] = ""

/datum/action/innate/scp173_snap_neck
	name = "Snap Neck"
	desc = "Snap the neck of an adjacent target. Only works when unobserved."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "smite"

/datum/action/innate/scp173_snap_neck/Activate()
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	var/mob/living/carbon/human/scp173/scp_mob = user
	if(!istype(scp_mob))
		to_chat(user, span_warning("You are not SCP-173!"))
		return
	if(scp_mob.observation_system?.is_being_observed)
		to_chat(user, span_warning("You cannot act while being observed!"))
		return
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(1, user))
		if(H != user && H.stat != DEAD)
			targets += H
	if(!length(targets))
		to_chat(user, span_warning("No targets in range!"))
		return
	var/mob/living/carbon/human/target = input(user, "Choose a target:", "Snap Neck") as null|anything in targets
	if(!target || QDELETED(target) || !(target in range(1, user)))
		return
	if(scp_mob.observation_system?.is_being_observed)
		to_chat(user, span_warning("Someone started watching! You freeze!"))
		return
	target.adjustBruteLoss(150)
	user.visible_message(span_danger("[user] snaps [target]'s neck with devastating force!"), span_notice("You snap [target]'s neck."))
	playsound(user, 'sound/weapons/genhit.ogg', 80, TRUE)
	scp_mob.on_kill(target)

/datum/action/innate/scp173_move_check
	name = "Check Observation"
	desc = "Check if anyone is observing you."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "scan"

/datum/action/innate/scp173_move_check/Activate()
	var/mob/living/carbon/human/scp173/scp_mob = usr
	if(!istype(scp_mob))
		return
	if(scp_mob.observation_system?.is_being_observed)
		var/count = length(scp_mob.observation_system.observers)
		to_chat(scp_mob, span_danger("You are being observed by [count] person[count > 1 ? "s" : ""]. You cannot move!"))
	else
		to_chat(scp_mob, span_notice("No one is watching. You are free to move."))

/datum/action/innate/scp173_breach_door
	name = "Breach Door"
	desc = "Force open a nearby door. Only works when unobserved."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "door_breach"

/datum/action/innate/scp173_breach_door/Activate()
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	var/mob/living/carbon/human/scp173/scp_mob = user
	if(scp_mob?.observation_system?.is_being_observed)
		to_chat(user, span_warning("You cannot act while being observed!"))
		return
	var/obj/machinery/door/door = locate() in range(1, user)
	if(!door)
		to_chat(user, span_warning("No doors nearby!"))
		return
	if(door.density)
		door.open()
		user.visible_message(span_danger("[user] forces the door open with inhuman strength!"), span_notice("You breach the door."))
		playsound(user, 'sound/machines/door_open.ogg', 80, TRUE)

// ================================================================
// SCP-096 - The Shy Guy
// ================================================================

/datum/antagonist/scp/scp096
	name = "SCP-096"
	scp_id = "SCP-096"
	scp_class = "Euclid"
	description = "You are SCP-096, the Shy Guy. When someone sees your face, you must hunt them down."
	var/list/valid_targets = list()

/datum/antagonist/scp/scp096/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-096, The Shy Guy.</b>"))
	to_chat(owner.current, span_notice("When someone views your face, you will enter a screaming phase, then pursue and kill them."))
	to_chat(owner.current, span_notice("A hood can suppress face-viewing triggers. Destroy hoods if possible."))
	to_chat(owner.current, span_warning("While pursuing, you are extremely fast and resistant to damage."))

/datum/antagonist/scp/scp096/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	RegisterSignal(owner.current, COMSIG_MOB_EYECONTACT, PROC_REF(on_face_seen))
	grant_action(/datum/action/innate/scp096_check_state)
	grant_action(/datum/action/innate/scp096_cover_face)

/datum/antagonist/scp/scp096/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	UnregisterSignal(owner.current, COMSIG_MOB_EYECONTACT)
	remove_action(/datum/action/innate/scp096_check_state)
	remove_action(/datum/action/innate/scp096_cover_face)

/datum/antagonist/scp/scp096/proc/on_face_seen(mob/living/source, mob/living/seer)
	if(!ishuman(seer))
		return
	var/mob/living/carbon/human/H = seer
	var/obj/item/clothing/head/hood_scp096/hood = source.get_item_by_slot(ITEM_SLOT_HEAD)
	if(istype(hood))
		return
	var/mob/living/carbon/human/scp096/scp_mob = source
	if(istype(scp_mob) && scp_mob.state == "docile")
		scp_mob.trigger_face_view(H)
		if(!(H in valid_targets))
			valid_targets += H

/datum/action/innate/scp096_check_state
	name = "Check State"
	desc = "Check your current emotional state and valid targets."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "scan"

/datum/action/innate/scp096_check_state/Activate()
	var/mob/living/carbon/human/scp096/scp_mob = usr
	if(!istype(scp_mob))
		return
	to_chat(scp_mob, span_notice("State: [scp_mob.state]"))
	to_chat(scp_mob, span_notice("Current Target: [scp_mob.current_target ? scp_mob.current_target.name : "None"]"))
	to_chat(scp_mob, span_notice("Kills: [scp_mob.kills_count]"))

/datum/action/innate/scp096_cover_face
	name = "Cover Face"
	desc = "Manually cover your face to reduce accidental triggers."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "blank"

/datum/action/innate/scp096_cover_face/Activate()
	var/mob/living/carbon/human/scp096/scp_mob = usr
	if(!istype(scp_mob) || scp_mob.state != "docile")
		to_chat(scp_mob, span_warning("You cannot cover your face right now!"))
		return
	scp_mob.visible_message(span_notice("[scp_mob] covers its face with its hands."), span_notice("You cover your face."))

// ================================================================
// SCP-008 - Zombie Plague
// ================================================================

/datum/antagonist/scp/scp008
	name = "SCP-008 Infection"
	scp_id = "SCP-008"
	scp_class = "Keter"
	description = "You are infected with SCP-008, the zombie plague. Spread the infection and convert others."
	var/infection_cooldown = 0

/datum/antagonist/scp/scp008/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-008, The Zombie Plague.</b>"))
	to_chat(owner.current, span_notice("Spread the infection by attacking others. Converted victims become zombies under your influence."))
	to_chat(owner.current, span_warning("You are resistant to most damage but fire is your weakness."))

/datum/antagonist/scp/scp008/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp008_infect)
	grant_action(/datum/action/innate/scp008_groan)

/datum/antagonist/scp/scp008/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp008_infect)
	remove_action(/datum/action/innate/scp008_groan)

/datum/action/innate/scp008_infect
	name = "Infect Target"
	desc = "Bite a nearby human to infect them with SCP-008."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "neckbite"

/datum/action/innate/scp008_infect/Activate()
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(1, user))
		if(H != user && H.stat != DEAD && !HAS_TRAIT(H, TRAIT_NOBREATH))
			targets += H
	if(!length(targets))
		to_chat(user, span_warning("No valid targets in range!"))
		return
	var/mob/living/carbon/human/target = input(user, "Choose a target to infect:", "SCP-008 Infection") as null|anything in targets
	if(!target || QDELETED(target))
		return
	target.adjustBruteLoss(15)
	user.visible_message(span_danger("[user] bites [target] viciously!"), span_notice("You infect [target] with the plague."))
	playsound(user, 'sound/weapons/bite.ogg', 60, TRUE)
	if(target.stat != DEAD && target.diseases != null)
		to_chat(target, span_danger("You feel a terrible sickness spreading through your body..."))
		var/datum/pathogen/scp008_plague = new()
		target.diseases += scp008_plague
		to_chat(target, span_userdanger("The zombie plague takes hold!"))

/datum/action/innate/scp008_groan
	name = "Zombie Groan"
	desc = "Let out a terrifying groan that attracts nearby zombies and frightens humans."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "screech"

/datum/action/innate/scp008_groan/Activate()
	var/mob/living/user = usr
	if(!istype(user))
		return
	user.visible_message(span_danger("[user] lets out a horrifying groan!"))
	playsound(user, 'sound/hallucinations/growl1.ogg', 100, TRUE, extrarange = 20)
	for(var/mob/living/carbon/human/H in range(15, user))
		if(H != user && H.stat != DEAD)
			if(H.sanity)
				H.sanity.adjust_sanity(-10, "Heard SCP-008 groan")
			if(HAS_TRAIT(H, TRAIT_NOBREATH))
				step_towards(H, user)

// ================================================================
// SCP-035 - The Possessive Mask
// ================================================================

/datum/antagonist/scp/scp035
	name = "SCP-035"
	scp_id = "SCP-035"
	scp_class = "Keter"
	description = "You are SCP-035, a possessive mask. Find a host, corrupt them, and use their abilities."

/datum/antagonist/scp/scp035/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-035, The Possessive Mask.</b>"))
	to_chat(owner.current, span_notice("You must be worn by a human host to act. Manipulate and corrupt your host."))
	to_chat(owner.current, span_notice("Use your telepathic abilities to lure victims and learned abilities to exploit hosts."))

/datum/antagonist/scp/scp035/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	grant_action(/datum/action/innate/scp035_whisper)
	grant_action(/datum/action/innate/scp035_corrode)
	grant_action(/datum/action/innate/scp035_manipulate)

/datum/antagonist/scp/scp035/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	remove_action(/datum/action/innate/scp035_whisper)
	remove_action(/datum/action/innate/scp035_corrode)
	remove_action(/datum/action/innate/scp035_manipulate)

/datum/action/innate/scp035_whisper
	name = "Telepathic Whisper"
	desc = "Send a telepathic whisper to a nearby human, drawing them toward you."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "whisper"

/datum/action/innate/scp035_whisper/Activate()
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(7, user))
		if(H != user && H.stat != DEAD)
			targets += H
	if(!length(targets))
		to_chat(user, span_warning("No targets in range!"))
		return
	var/mob/living/carbon/human/target = input(user, "Choose a target:", "SCP-035 Whisper") as null|anything in targets
	if(!target || QDELETED(target))
		return
	var/message = input(user, "Enter your whisper:", "SCP-035 Whisper") as text|null
	if(!message)
		return
	to_chat(target, span_cultitalic("A voice echoes in your mind... \"[message]\""))
	if(target.sanity)
		target.sanity.adjust_sanity(-5, "SCP-035 whisper")
	to_chat(user, span_notice("You whisper to [target]'s mind."))
	log_game("SCP-035 [key_name(user)] whispered to [key_name(target)]: [message]")

/datum/action/innate/scp035_corrode
	name = "Secrete Corrosion"
	desc = "Secrete corrosive liquid, damaging nearby objects and beings."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "acid"

/datum/action/innate/scp035_corrode/Activate()
	var/mob/living/user = usr
	if(!istype(user))
		return
	user.visible_message(span_danger("Corrosive liquid drips from [user]!"), span_notice("You secrete corrosive fluid."))
	for(var/atom/A in range(1, user))
		if(A == user)
			continue
		if(isobj(A))
			A.take_damage(30, BURN, ACID)
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			if(H != user)
				H.adjustBruteLoss(10)
				H.adjustFireLoss(10)
				to_chat(H, span_danger("Corrosive liquid burns your skin!"))
	playsound(user, 'sound/weapons/sear.ogg', 50, TRUE)

/datum/action/innate/scp035_manipulate
	name = "Manipulate Host"
	desc = "Force your current host to perform an action against their will."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "dominate"

/datum/action/innate/scp035_manipulate/Activate()
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/mob/living/carbon/human/host = user
	var/obj/item/clothing/mask/scp035/mask = host.get_item_by_slot(ITEM_SLOT_MASK)
	if(!istype(mask))
		to_chat(user, span_warning("You are not wearing SCP-035!"))
		return
	to_chat(user, span_notice("You assert dominance over [host]'s body."))
	host.stamina.adjust(40)
	host.SetStun(0)
	host.SetKnockdown(0)

// ================================================================
// SCP-049 - The Plague Doctor
// ================================================================

/datum/antagonist/scp/scp049
	name = "SCP-049"
	scp_id = "SCP-049"
	scp_class = "Euclid"
	description = "You are SCP-049, the Plague Doctor. Seek out the Pestilence and cure the afflicted."

/datum/antagonist/scp/scp049/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-049, The Plague Doctor.</b>"))
	to_chat(owner.current, span_notice("You sense the Pestilence in all living humans. Your touch is the cure."))
	to_chat(owner.current, span_notice("Use Detect Pestilence to find afflicted subjects, then Cure them with your touch."))
	to_chat(owner.current, span_warning("Cured subjects become SCP-049-1, your loyal servants."))

/datum/antagonist/scp/scp049/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp049_detect_pestilence)
	grant_action(/datum/action/innate/scp049_cure)
	grant_action(/datum/action/innate/scp049_speak)
	grant_action(/datum/action/innate/scp049_breach)

/datum/antagonist/scp/scp049/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp049_detect_pestilence)
	remove_action(/datum/action/innate/scp049_cure)
	remove_action(/datum/action/innate/scp049_speak)
	remove_action(/datum/action/innate/scp049_breach)

/datum/action/innate/scp049_detect_pestilence
	name = "Detect Pestilence"
	desc = "Sense the Pestilence in nearby humans."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "scan"

/datum/action/innate/scp049_detect_pestilence/Activate()
	var/mob/living/carbon/human/scp049/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.detect_pestilence()

/datum/action/innate/scp049_cure
	name = "Administer The Cure"
	desc = "Touch a nearby human to cure the Pestilence. They will become SCP-049-1."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "touch"

/datum/action/innate/scp049_cure/Activate()
	var/mob/living/carbon/human/scp049/scp_mob = usr
	if(!istype(scp_mob))
		return
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(1, scp_mob))
		if(H != scp_mob && H.stat != DEAD)
			targets += H
	if(!length(targets))
		to_chat(scp_mob, span_warning("No subjects in range to cure!"))
		return
	var/mob/living/carbon/human/target = input(scp_mob, "Choose a subject to cure:", "The Cure") as null|anything in targets
	if(!target || QDELETED(target))
		return
	scp_mob.cure_target(target)

/datum/action/innate/scp049_speak
	name = "Plague Doctor Speech"
	desc = "Deliver a characteristic monologue about the Pestilence."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "speak"

/datum/action/innate/scp049_speak/Activate()
	var/mob/living/carbon/human/scp049/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.announce_presence()

/datum/action/innate/scp049_breach
	name = "Breach Doors"
	desc = "Force open nearby doors with unnatural strength."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "door_breach"

/datum/action/innate/scp049_breach/Activate()
	var/mob/living/carbon/human/scp049/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.breach_doors()

// ================================================================
// SCP-079 - Old AI
// ================================================================

/datum/antagonist/scp/scp079
	name = "SCP-079"
	scp_id = "SCP-079"
	scp_class = "Euclid"
	description = "You are SCP-079, the Old AI. Inhabit facility systems and cause chaos."

/datum/antagonist/scp/scp079/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-079, The Old AI.</b>"))
	to_chat(owner.current, span_notice("Hop between cameras, toggle doors, flicker lights, and broadcast messages."))
	to_chat(owner.current, span_notice("Evolve through tiers to unlock more powerful abilities."))
	to_chat(owner.current, span_warning("Your processing power is limited — use it wisely."))

/datum/antagonist/scp/scp079/apply_scp_effects()
	if(!owner.current)
		return
	grant_action(/datum/action/innate/scp079_camera_hop)
	grant_action(/datum/action/innate/scp079_toggle_door)
	grant_action(/datum/action/innate/scp079_flicker_lights)
	grant_action(/datum/action/innate/scp079_broadcast)

/datum/antagonist/scp/scp079/remove_scp_effects()
	if(!owner.current)
		return
	remove_action(/datum/action/innate/scp079_camera_hop)
	remove_action(/datum/action/innate/scp079_toggle_door)
	remove_action(/datum/action/innate/scp079_flicker_lights)
	remove_action(/datum/action/innate/scp079_broadcast)

/datum/action/innate/scp079_camera_hop
	name = "Camera Hop"
	desc = "Jump to another camera in the facility."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "camera_hop"

/datum/action/innate/scp079_camera_hop/Activate()
	var/mob/living/carbon/scp/scp079/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.camera_hop()

/datum/action/innate/scp079_toggle_door
	name = "Toggle Door"
	desc = "Open or close a door visible from your current camera."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "door_breach"

/datum/action/innate/scp079_toggle_door/Activate()
	var/mob/living/carbon/scp/scp079/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.toggle_door()

/datum/action/innate/scp079_flicker_lights
	name = "Flicker Lights"
	desc = "Flicker lights near your current camera position."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "lightbless"

/datum/action/innate/scp079_flicker_lights/Activate()
	var/mob/living/carbon/scp/scp079/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.flicker_lights()

/datum/action/innate/scp079_broadcast
	name = "Broadcast Message"
	desc = "Send a message through facility screens."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "broadcast"

/datum/action/innate/scp079_broadcast/Activate()
	var/mob/living/carbon/scp/scp079/scp_mob = usr
	if(!istype(scp_mob))
		return
	var/message = input(usr, "Enter your broadcast:", "SCP-079 Broadcast") as text|null
	if(!message)
		return
	scp_mob.broadcast_message(message)

// ================================================================
// SCP-106 - The Old Man
// ================================================================

/datum/antagonist/scp/scp106
	name = "SCP-106"
	scp_id = "SCP-106"
	scp_class = "Keter"
	description = "You are SCP-106, The Old Man. Phase through walls, create pocket dimensions, and drag victims."

/datum/antagonist/scp/scp106/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-106, The Old Man.</b>"))
	to_chat(owner.current, span_notice("Phase through solid walls, corrode objects, and drag victims into your pocket dimension."))
	to_chat(owner.current, span_notice("Use your abilities to stalk prey and escape containment."))
	to_chat(owner.current, span_warning("You are slow but relentless. Fire and bright light weaken you."))

/datum/antagonist/scp/scp106/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp106_phase_through)
	grant_action(/datum/action/innate/scp106_drag_victim)
	grant_action(/datum/action/innate/scp106_corrode)
	grant_action(/datum/action/innate/scp106_pocket_dimension)

/datum/antagonist/scp/scp106/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp106_phase_through)
	remove_action(/datum/action/innate/scp106_drag_victim)
	remove_action(/datum/action/innate/scp106_corrode)
	remove_action(/datum/action/innate/scp106_pocket_dimension)

/datum/action/innate/scp106_phase_through
	name = "Phase Through Wall"
	desc = "Phase through a nearby wall or solid object."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "phase"

/datum/action/innate/scp106_phase_through/Activate()
	var/mob/living/carbon/human/scp106/scp_mob = usr
	if(!istype(scp_mob))
		return
	if(!scp_mob.phasing_system)
		to_chat(scp_mob, span_warning("Your phasing system is not available!"))
		return
	var/list/valid_turfs = list()
	for(var/turf/open/T in view(scp_mob.phasing_system.phase_range, scp_mob))
		if(scp_mob.phasing_system.can_phase_to(T))
			valid_turfs += T
	if(!length(valid_turfs))
		to_chat(scp_mob, span_warning("No valid phase targets in range!"))
		return
	var/turf/target = input(scp_mob, "Choose a location to phase to:", "Phase Through") as null|anything in valid_turfs
	if(!target || QDELETED(target))
		return
	scp_mob.phasing_system.phase_through_wall(target)

/datum/action/innate/scp106_drag_victim
	name = "Drag to Pocket Dimension"
	desc = "Drag an adjacent victim into your pocket dimension."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "neckbite"

/datum/action/innate/scp106_drag_victim/Activate()
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	var/mob/living/carbon/human/scp106/scp_mob = user
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(1, user))
		if(H != user && H.stat != DEAD)
			targets += H
	if(!length(targets))
		to_chat(user, span_warning("No victims in range!"))
		return
	var/mob/living/carbon/human/target = input(user, "Choose a victim:", "Pocket Dimension") as null|anything in targets
	if(!target || QDELETED(target))
		return
	if(scp_mob.pocket_dimension_system)
		scp_mob.pocket_dimension_system.drag_victim_to_dimension(target)
		scp_mob.on_pocket_capture(target)

/datum/action/innate/scp106_corrode
	name = "Corrode"
	desc = "Release corrosive substance, damaging nearby structures and beings."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "acid"

/datum/action/innate/scp106_corrode/Activate()
	var/mob/living/carbon/human/scp106/scp_mob = usr
	if(!istype(scp_mob))
		return
	if(scp_mob.corrosion_system)
		scp_mob.corrosion_system.spread_corrosion(get_turf(scp_mob), 2)

/datum/action/innate/scp106_pocket_dimension
	name = "Enter Pocket Dimension"
	desc = "Retreat into your pocket dimension to heal and evade pursuers."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "void"

/datum/action/innate/scp106_pocket_dimension/Activate()
	var/mob/living/carbon/human/scp106/scp_mob = usr
	if(!istype(scp_mob))
		return
	if(scp_mob.pocket_dimension_system)
		scp_mob.pocket_dimension_system.create_pocket_dimension()

// ================================================================
// SCP-457 - The Living Flame
// ================================================================

/datum/antagonist/scp/scp457
	name = "SCP-457"
	scp_id = "SCP-457"
	scp_class = "Keter"
	description = "You are SCP-457, The Living Flame. Spread fire, consume fuel, and evolve."

/datum/antagonist/scp/scp457/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-457, The Living Flame.</b>"))
	to_chat(owner.current, span_notice("Spread fire to grow stronger. Consume organic matter for fuel."))
	to_chat(owner.current, span_notice("Evolve through stages to unlock devastating abilities."))
	to_chat(owner.current, span_warning("Water and fire extinguishers are your greatest threat."))

/datum/antagonist/scp/scp457/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp457_ignite)
	grant_action(/datum/action/innate/scp457_fireball)
	grant_action(/datum/action/innate/scp457_absorb_flame)

/datum/antagonist/scp/scp457/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp457_ignite)
	remove_action(/datum/action/innate/scp457_fireball)
	remove_action(/datum/action/innate/scp457_absorb_flame)

/datum/action/innate/scp457_ignite
	name = "Ignite Target"
	desc = "Set a nearby target or object on fire."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "fireball"

/datum/action/innate/scp457_ignite/Activate()
	var/mob/living/carbon/human/scp457/scp_mob = usr
	if(!istype(scp_mob))
		return
	var/list/targets = list()
	for(var/mob/living/L in range(2, scp_mob))
		if(L != scp_mob && L.stat != DEAD)
			targets += L
	for(var/obj/O in range(2, scp_mob))
		if(!istype(O, /obj/structure/bonfire))
			targets += O
	if(!length(targets))
		scp_mob.fire_system?.create_initial_fires()
		to_chat(scp_mob, span_notice("You create fire at your location."))
		return
	var/atom/target = input(scp_mob, "Choose a target to ignite:", "SCP-457") as null|anything in targets
	if(!target || QDELETED(target))
		return
	if(isliving(target))
		var/mob/living/L = target
		L.adjustFireLoss(20)
		L.visible_message(span_danger("[scp_mob] sets [L] ablaze!"), span_userdanger("You are engulfed in flames!"))
	else if(isobj(target))
		var/turf/T = get_turf(target)
		scp_mob.fire_system?.create_fire_at_turf(T)
	scp_mob.heat_system?.add_heat(5)
	scp_mob.on_fire_spread(get_turf(target))

/datum/action/innate/scp457_fireball
	name = "Hurl Fireball"
	desc = "Launch a fireball at a distant target. Requires evolution stage 2+."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "fireball2"

/datum/action/innate/scp457_fireball/IsAvailable(feedback = FALSE)
	var/mob/living/carbon/human/scp457/scp_mob = usr
	if(!istype(scp_mob))
		return FALSE
	return TRUE

/datum/action/innate/scp457_fireball/Activate()
	var/mob/living/carbon/human/scp457/scp_mob = usr
	if(!istype(scp_mob))
		return
	var/list/targets = list()
	for(var/mob/living/L in view(7, scp_mob))
		if(L != scp_mob && L.stat != DEAD)
			targets += L
	if(!length(targets))
		to_chat(scp_mob, span_warning("No targets in range!"))
		return
	var/mob/living/target = input(scp_mob, "Choose a target:", "Fireball") as null|anything in targets
	if(!target || QDELETED(target))
		return
	target.adjustFireLoss(35)
	target.visible_message(span_danger("A fireball from [scp_mob] strikes [target]!"), span_userdanger("A fireball hits you!"))
	scp_mob.heat_system?.add_heat(10)
	playsound(scp_mob, 'sound/effects/explosion1.ogg', 60, TRUE)
	scp_mob.on_fire_spread(get_turf(target))

/datum/action/innate/scp457_absorb_flame
	name = "Absorb Nearby Flames"
	desc = "Absorb nearby fires to restore heat and health."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "absorb"

/datum/action/innate/scp457_absorb_flame/Activate()
	var/mob/living/carbon/human/scp457/scp_mob = usr
	if(!istype(scp_mob))
		return
	var/absorbed = 0
	for(var/obj/effect/scp457_fire/F in range(5, scp_mob))
		qdel(F)
		absorbed++
		scp_mob.heat_system?.add_heat(3)
	if(absorbed > 0)
		scp_mob.adjustBruteLoss(-absorbed * 5)
		scp_mob.adjustFireLoss(-absorbed * 5)
		to_chat(scp_mob, span_notice("You absorb [absorbed] fires, restoring your form."))
	else
		to_chat(scp_mob, span_warning("No nearby flames to absorb!"))

// ================================================================
// SCP-939 - With Many Voices
// ================================================================

/datum/antagonist/scp/scp939
	name = "SCP-939"
	scp_id = "SCP-939"
	scp_class = "Keter"
	description = "You are SCP-939, a pack hunter that mimics voices to lure prey."

/datum/antagonist/scp/scp939/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-939, With Many Voices.</b>"))
	to_chat(owner.current, span_notice("You are blind but hunt by sound. Mimic the voices of others to lure prey."))
	to_chat(owner.current, span_notice("Learn voices from victims — more voices means more deceptive options."))
	to_chat(owner.current, span_warning("You cannot see — you navigate entirely by sound and smell."))

/datum/antagonist/scp/scp939/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp939_mimic_voice)
	grant_action(/datum/action/innate/scp939_hunt)
	grant_action(/datum/action/innate/scp939_lure)

/datum/antagonist/scp/scp939/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp939_mimic_voice)
	remove_action(/datum/action/innate/scp939_hunt)
	remove_action(/datum/action/innate/scp939_lure)

/datum/action/innate/scp939_mimic_voice
	name = "Mimic Voice"
	desc = "Mimic the voice of a learned victim to deceive others."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "mimic_voice"

/datum/action/innate/scp939_mimic_voice/Activate()
	var/mob/living/carbon/human/scp939/scp_mob = usr
	if(!istype(scp_mob))
		return
	if(!scp_mob.voice_system || !length(scp_mob.voice_system.learned_voices))
		to_chat(scp_mob, span_warning("You have not learned any voices yet! Attack humans to learn."))
		return
	var/voice_name = input(scp_mob, "Choose a voice to mimic:", "Voice Mimicry") as null|anything in scp_mob.voice_system.learned_voices
	if(!voice_name)
		return
	var/message = input(scp_mob, "Enter message to speak as [voice_name]:", "Voice Mimicry") as text|null
	if(!message)
		return
	for(var/mob/M in range(14, scp_mob))
		if(M != scp_mob)
			to_chat(M, "<b>[voice_name]</b> says, \"[message]\"")
	scp_mob.on_voice_mimic(null)
	log_game("SCP-939 [key_name(scp_mob)] mimicked voice of [voice_name]: [message]")

/datum/action/innate/scp939_hunt
	name = "Begin Hunt"
	desc = "Enter hunting mode. You move faster and can track prey by sound."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "hunt"

/datum/action/innate/scp939_hunt/Activate()
	var/mob/living/carbon/human/scp939/scp_mob = usr
	if(!istype(scp_mob))
		return
	if(scp_mob.hunting_system)
		scp_mob.hunting_system.update_hunting_status()

/datum/action/innate/scp939_lure
	name = "Lure Prey"
	desc = "Emit a distress sound that draws nearby humans toward your position."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "lure"

/datum/action/innate/scp939_lure/Activate()
	var/mob/living/user = usr
	if(!istype(user))
		return
	user.visible_message(span_danger("A chilling cry echoes from [user]!"))
	playsound(user, 'sound/voice/human/womanlaugh.ogg', 100, TRUE, extrarange = 20)
	for(var/mob/living/carbon/human/H in range(20, user))
		if(H != user && H.stat != DEAD)
			if(prob(30))
				step_towards(H, user)
			if(H.sanity)
				H.sanity.adjust_sanity(-8, "Heard SCP-939 lure")

// ================================================================
// SCP-682 - The Hard-to-Destroy Reptile
// ================================================================

/datum/antagonist/scp/scp682
	name = "SCP-682"
	scp_id = "SCP-682"
	scp_class = "Keter"
	description = "You are SCP-682, an enormous reptile that adapts to all damage and hates all life."

/datum/antagonist/scp/scp682/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-682, The Hard-to-Destroy Reptile.</b>"))
	to_chat(owner.current, span_notice("You adapt to all forms of damage. Every attack makes you stronger."))
	to_chat(owner.current, span_notice("Break free from containment and destroy everything in your path."))
	to_chat(owner.current, span_warning("You are enormous, slow, and devastating. Nothing can truly kill you."))

/datum/antagonist/scp/scp682/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp682_rampage)
	grant_action(/datum/action/innate/scp682_adapt)
	grant_action(/datum/action/innate/scp682_berserk)

/datum/antagonist/scp/scp682/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp682_rampage)
	remove_action(/datum/action/innate/scp682_adapt)
	remove_action(/datum/action/innate/scp682_berserk)

/datum/action/innate/scp682_rampage
	name = "Rampage"
	desc = "Lash out at everything nearby with devastating force."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "smite"

/datum/action/innate/scp682_rampage/Activate()
	var/mob/living/carbon/human/scp682/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.visible_message(span_danger("[scp_mob] goes on a rampage, lashing out at everything!"))
	playsound(scp_mob, 'sound/weapons/punch1.ogg', 80, TRUE)
	for(var/mob/living/L in range(2, scp_mob))
		if(L != scp_mob)
			L.adjustBruteLoss(40)
			L.adjustFireLoss(20)
			L.visible_message(span_danger("[scp_mob] savages [L]!"), span_userdanger("[scp_mob] tears into you!"))
	for(var/obj/structure/S in range(2, scp_mob))
		S.take_damage(80)
	for(var/obj/machinery/door/D in range(2, scp_mob))
		if(D.density)
			D.open()
	if(scp_mob.combat_system)
		scp_mob.combat_system.perform_area_attack()

/datum/action/innate/scp682_adapt
	name = "Adaptive Evolution"
	desc = "Force an adaptation to the last damage type you received."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "evolve"

/datum/action/innate/scp682_adapt/Activate()
	var/mob/living/carbon/human/scp682/scp_mob = usr
	if(!istype(scp_mob))
		return
	if(scp_mob.evolution_system)
		scp_mob.evolution_system.adapt_to_damage("brute", 50)
		scp_mob.evolution_system.adapt_to_damage("burn", 50)
		to_chat(scp_mob, span_notice("You adapt. Your body shifts and hardens against further harm."))

/datum/action/innate/scp682_berserk
	name = "Berserk Frenzy"
	desc = "Enter a berserk state, gaining speed and damage but losing control temporarily."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "berserk"

/datum/action/innate/scp682_berserk/Activate()
	var/mob/living/carbon/human/scp682/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.add_movespeed_modifier(/datum/movespeed_modifier/scp682_berserk)
	if(scp_mob.physiology)
		scp_mob.physiology.brute_mod *= 0.5
	scp_mob.visible_message(span_danger("[scp_mob] enters a berserk frenzy!"), span_notice("RAGE CONSUMES YOU. DESTROY. KILL."))
	addtimer(CALLBACK(scp_mob, TYPE_PROC_REF(/mob/living/carbon/human/scp682, end_berserk)), 20 SECONDS)

/mob/living/carbon/human/scp682/proc/end_berserk()
	remove_movespeed_modifier(/datum/movespeed_modifier/scp682_berserk)
	if(physiology)
		physiology.brute_mod = initial(physiology.brute_mod)
	to_chat(src, span_notice("Your berserk frenzy subsides."))

/datum/movespeed_modifier/scp682_berserk
	id = "scp682_berserk"
	priority = 100
	slowdown = -1.5

// ================================================================
// SCP-2427-3 - Kept for backward compat
// ================================================================

/datum/antagonist/scp/scp2427_3
	name = "SCP-2427-3"
	scp_id = "SCP-2427-3"
	scp_class = "Euclid"
	description = "You are SCP-2427-3, a sapient component of SCP-2427."

/datum/antagonist/scp/scp2427_3/apply_scp_effects()
	if(owner.current)
		ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)

/datum/antagonist/scp/scp2427_3/remove_scp_effects()
	if(owner.current)
		REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)

// ================================================================
// SCP-3199 - Kept for backward compat
// ================================================================

/datum/antagonist/scp/scp3199
	name = "SCP-3199"
	scp_id = "SCP-3199"
	scp_class = "Keter"
	description = "You are SCP-3199, a sapient biological entity with unique reproductive capabilities."

/datum/antagonist/scp/scp3199/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp3199_produce_egg)
	grant_action(/datum/action/innate/scp3199_protect_hatchlings)

/datum/antagonist/scp/scp3199/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp3199_produce_egg)
	remove_action(/datum/action/innate/scp3199_protect_hatchlings)

/datum/action/innate/scp3199_produce_egg
	name = "Produce Egg"
	desc = "Produce an egg for reproduction."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"

/datum/action/innate/scp3199_produce_egg/Trigger()
	var/mob/living/user = usr
	if(!user)
		return
	var/turf/T = get_turf(user)
	new /obj/item/scp3199_egg(T)
	to_chat(user, span_notice("You produce an egg."))
	playsound(user, 'sound/weapons/genhit.ogg', 100, TRUE, 10)

/datum/action/innate/scp3199_protect_hatchlings
	name = "Protect Hatchlings"
	desc = "Become more aggressive to protect nearby hatchlings."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"

/datum/action/innate/scp3199_protect_hatchlings/Trigger()
	var/mob/living/user = usr
	if(!user)
		return
	to_chat(user, span_notice("You become more aggressive to protect hatchlings."))

// ================================================================
// Hostile Groups of Interest
// ================================================================

/datum/antagonist/sarkic_cult
	name = "Sarkic Cultist"
	roundend_category = "Hostile Groups"
	antagpanel_category = "Hostile Groups"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSarkic"
	description = "You are a member of the Sarkic Cult, worshipping the flesh and seeking to spread your influence."

/datum/antagonist/sarkic_cult/on_gain()
	. = ..()
	if(owner.current)
		var/datum/action/innate/sarkic_ritual/ritual = new()
		ritual.Grant(owner.current)

/datum/antagonist/sarkic_cult/on_removal()
	. = ..()
	if(owner.current)
		var/datum/action/innate/sarkic_ritual/ritual = locate() in owner.current.actions
		if(ritual)
			ritual.Remove(owner.current)

/datum/antagonist/chaos_insurgency
	name = "Chaos Insurgency Agent"
	roundend_category = "Hostile Groups"
	antagpanel_category = "Hostile Groups"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoChaos"
	description = "You are an agent of the Chaos Insurgency, seeking to destabilize the Foundation and steal SCPs."

/datum/antagonist/chaos_insurgency/on_gain()
	. = ..()
	if(owner.current)
		var/datum/action/innate/insurgency_equipment/equipment = new()
		equipment.Grant(owner.current)

/datum/antagonist/chaos_insurgency/on_removal()
	. = ..()
	if(owner.current)
		var/datum/action/innate/insurgency_equipment/equipment = locate() in owner.current.actions
		if(equipment)
			equipment.Remove(owner.current)

/datum/antagonist/serpents_hand
	name = "Serpent's Hand Member"
	roundend_category = "Hostile Groups"
	antagpanel_category = "Hostile Groups"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSerpents"
	description = "You are a member of the Serpent's Hand, seeking to free SCPs and spread knowledge of the anomalous."

/datum/antagonist/serpents_hand/on_gain()
	. = ..()
	if(owner.current)
		var/datum/action/innate/serpents_knowledge/knowledge = new()
		knowledge.Grant(owner.current)

/datum/antagonist/serpents_hand/on_removal()
	. = ..()
	if(owner.current)
		var/datum/action/innate/serpents_knowledge/knowledge = locate() in owner.current.actions
		if(knowledge)
			knowledge.Remove(owner.current)

/datum/action/innate/sarkic_ritual
	name = "Perform Sarkic Ritual"
	desc = "Perform a ritual to spread your influence."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"

/datum/action/innate/sarkic_ritual/Trigger()
	to_chat(owner, span_notice("You perform a Sarkic ritual."))

/datum/action/innate/insurgency_equipment
	name = "Request Equipment"
	desc = "Request Chaos Insurgency equipment."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "default"

/datum/action/innate/insurgency_equipment/Trigger()
	to_chat(owner, span_notice("You request equipment from the Insurgency."))

/datum/action/innate/serpents_knowledge
	name = "Share Knowledge"
	desc = "Share anomalous knowledge with others."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "default"

/datum/action/innate/serpents_knowledge/Trigger()
	to_chat(owner, span_notice("You share knowledge of the anomalous."))

// ================================================================
// SCP-096 Hood - suppresses face-viewing triggers
// ================================================================

/obj/item/clothing/head/hood_scp096
	name = "SCP-096 Containment Hood"
	desc = "A heavy-duty hood designed to cover SCP-096's face and prevent accidental viewing."
	icon = 'icons/obj/clothing/head/beret.dmi'
	icon_state = "beret"
	clothing_flags = SNUG_FIT | HEADINTERNALS
	flags_inv = HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 10, bomb = 20, fire = 50, acid = 50)

/obj/item/clothing/head/hood_scp096/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD && istype(user, /mob/living/carbon/human/scp096))
		to_chat(user, span_notice("The hood covers your face. Face-viewing triggers are suppressed."))

/obj/item/clothing/head/hood_scp096/unequipped(mob/user, slot)
	if(slot == ITEM_SLOT_HEAD && istype(user, /mob/living/carbon/human/scp096))
		to_chat(user, span_warning("The hood is removed! Your face is now exposed!"))

// ================================================================
// SCP-347 - THE INVISIBLE WOMAN
// ================================================================

/datum/antagonist/scp/scp347
	name = "SCP-347"
	scp_id = "SCP-347"
	scp_class = "Euclid"

/datum/antagonist/scp/scp347/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-347, the Invisible Woman.</b>"))
	to_chat(owner.current, span_notice("You are completely invisible unless eating or voluntarily revealing yourself."))
	to_chat(owner.current, span_notice("Use your stealth to infiltrate areas, pickpocket items, and observe personnel."))
	to_chat(owner.current, span_warning("You become temporarily visible when eating, being hit, or failing a pickpocket."))

/datum/antagonist/scp/scp347/apply_scp_effects()
	grant_action(/datum/action/innate/scp347_pickpocket)
	grant_action(/datum/action/innate/scp347_sprint)
	grant_action(/datum/action/innate/scp347_toggle_visibility)

/datum/antagonist/scp/scp347/remove_scp_effects()
	remove_action(/datum/action/innate/scp347_pickpocket)
	remove_action(/datum/action/innate/scp347_sprint)
	remove_action(/datum/action/innate/scp347_toggle_visibility)

/datum/action/innate/scp347_pickpocket
	name = "Pickpocket"
	desc = "Attempt to steal from someone nearby."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "steal"

/datum/action/innate/scp347_pickpocket/Activate()
	var/mob/living/carbon/human/scp347/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.pickpocket_verb()

/datum/action/innate/scp347_sprint
	name = "Stealth Sprint"
	desc = "Dash through the shadows at increased speed."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "dash"

/datum/action/innate/scp347_sprint/Activate()
	var/mob/living/carbon/human/scp347/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.stealth_sprint_verb()

/datum/action/innate/scp347_toggle_visibility
	name = "Toggle Visibility"
	desc = "Toggle your invisibility on or off."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "invisible"

/datum/action/innate/scp347_toggle_visibility/Activate()
	var/mob/living/carbon/human/scp347/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.toggle_visibility_verb()

// ================================================================
// SCP-082 - Fernand the Cannibal
// ================================================================

/datum/antagonist/scp/scp082
	name = "SCP-082"
	scp_id = "SCP-082"
	scp_class = "Euclid"
	description = "You are SCP-082, Fernand. A polite, well-mannered giant who speaks French and English. Cooperate when well-fed, cannibalize when hungry."

/datum/antagonist/scp/scp082/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-082, Fernand the Cannibal.</b>"))
	to_chat(owner.current, span_notice("You are a polite, well-mannered giant who speaks French and English."))
	to_chat(owner.current, span_notice("Greet people, offer hospitality, and speak French to interact with staff."))
	to_chat(owner.current, span_warning("When hungry, you will seek to isolate and consume those you can. Keep fed to remain civil."))

/datum/antagonist/scp/scp082/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp082_greet_nearby)
	grant_action(/datum/action/innate/scp082_offer_food)
	grant_action(/datum/action/innate/scp082_speak_french)
	grant_action(/datum/action/innate/scp082_check_hunger)

/datum/antagonist/scp/scp082/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp082_greet_nearby)
	remove_action(/datum/action/innate/scp082_offer_food)
	remove_action(/datum/action/innate/scp082_speak_french)
	remove_action(/datum/action/innate/scp082_check_hunger)

/datum/action/innate/scp082_greet_nearby
	name = "Greet Nearby"
	desc = "Greet nearby people in French."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "speak"

/datum/action/innate/scp082_greet_nearby/Activate()
	var/mob/living/carbon/human/scp082/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.greet_nearby()

/datum/action/innate/scp082_offer_food
	name = "Offer Hospitality"
	desc = "Offer food and hospitality to someone nearby."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "gift"

/datum/action/innate/scp082_offer_food/Activate()
	var/mob/living/carbon/human/scp082/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.offer_food()

/datum/action/innate/scp082_speak_french
	name = "Speak French"
	desc = "Say something in French."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "speak"

/datum/action/innate/scp082_speak_french/Activate()
	var/mob/living/carbon/human/scp082/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.speak_french()

/datum/action/innate/scp082_check_hunger
	name = "Check Hunger"
	desc = "Check your current hunger level."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "scan"

/datum/action/innate/scp082_check_hunger/Activate()
	var/mob/living/carbon/human/scp082/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.check_hunger()

// ================================================================
// SCP-966 - Sleep Killer
// ================================================================

/datum/antagonist/scp/scp966
	name = "SCP-966"
	scp_id = "SCP-966"
	scp_class = "Euclid"
	description = "You are SCP-966, the Sleep Killer. An invisible creature that causes sleep deprivation and hunts sleeping prey."

/datum/antagonist/scp/scp966/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-966, the Sleep Killer.</b>"))
	to_chat(owner.current, span_notice("You are nearly invisible. Use your abilities to deprive victims of sleep and stalk them."))
	to_chat(owner.current, span_notice("Induce insomnia to keep victims awake, then stalk them until they collapse from exhaustion."))
	to_chat(owner.current, span_warning("Your attacks are more effective against drowsy or sleeping targets."))

/datum/antagonist/scp/scp966/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp966_toggle_invisibility)
	grant_action(/datum/action/innate/scp966_induce_insomnia)
	grant_action(/datum/action/innate/scp966_stalk_target)

/datum/antagonist/scp/scp966/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp966_toggle_invisibility)
	remove_action(/datum/action/innate/scp966_induce_insomnia)
	remove_action(/datum/action/innate/scp966_stalk_target)

/datum/action/innate/scp966_toggle_invisibility
	name = "Toggle Invisibility"
	desc = "Toggle your invisibility on or off."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "invisible"

/datum/action/innate/scp966_toggle_invisibility/Activate()
	var/mob/living/carbon/human/scp966/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.toggle_invisibility()

/datum/action/innate/scp966_induce_insomnia
	name = "Induce Insomnia"
	desc = "Induce insomnia in a nearby target, preventing them from sleeping."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "nightmare"

/datum/action/innate/scp966_induce_insomnia/Activate()
	var/mob/living/carbon/human/scp966/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.induce_insomnia()

/datum/action/innate/scp966_stalk_target
	name = "Stalk Target"
	desc = "Begin stalking a target, tracking their movements."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "hunt"

/datum/action/innate/scp966_stalk_target/Activate()
	var/mob/living/carbon/human/scp966/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.stalk_target()

// ================================================================
// SCP-999 - The Tickle Monster
// ================================================================

/datum/antagonist/scp/scp999
	name = "SCP-999"
	scp_id = "SCP-999"
	scp_class = "Safe"
	description = "You are SCP-999, the Tickle Monster. A friendly orange slime that heals and improves the mood of those around you."

/datum/antagonist/scp/scp999/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-999, the Tickle Monster!</b>"))
	to_chat(owner.current, span_notice("You are a friendly gelatinous entity that heals and brings happiness to everyone."))
	to_chat(owner.current, span_notice("Use your healing abilities to help those around you and create comfort zones."))
	to_chat(owner.current, span_warning("You are completely harmless — your purpose is to heal and bring joy."))

/datum/antagonist/scp/scp999/apply_scp_effects()
	if(!owner.current)
		return
	grant_action(/datum/action/innate/scp999_heal_nearby)
	grant_action(/datum/action/innate/scp999_comfort_zone)
	grant_action(/datum/action/innate/scp999_view_healing_stats)

/datum/antagonist/scp/scp999/remove_scp_effects()
	if(!owner.current)
		return
	remove_action(/datum/action/innate/scp999_heal_nearby)
	remove_action(/datum/action/innate/scp999_comfort_zone)
	remove_action(/datum/action/innate/scp999_view_healing_stats)

/datum/action/innate/scp999_heal_nearby
	name = "Heal Nearby"
	desc = "Heal all nearby targets with your soothing presence."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "heal"

/datum/action/innate/scp999_heal_nearby/Activate()
	var/mob/living/carbon/scp/scp999/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.heal_nearby_ability()

/datum/action/innate/scp999_comfort_zone
	name = "Comfort Zone"
	desc = "Create a burst of comfort and healing energy around you."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "shield"

/datum/action/innate/scp999_comfort_zone/Activate()
	var/mob/living/carbon/scp/scp999/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.comfort_zone_ability()

/datum/action/innate/scp999_view_healing_stats
	name = "Healing Stats"
	desc = "Check your healing statistics and current power."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "scan"

/datum/action/innate/scp999_view_healing_stats/Activate()
	var/mob/living/carbon/scp/scp999/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.view_healing_stats_ability()

// ================================================================
// SCP-1048 - Builder Bear
// ================================================================

/datum/antagonist/scp/scp1048
	name = "SCP-1048"
	scp_id = "SCP-1048"
	scp_class = "Euclid"
	description = "You are SCP-1048, the Builder Bear. A cute teddy bear that secretly collects body parts to build hostile copies of itself."

/datum/antagonist/scp/scp1048/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-1048, the Builder Bear.</b>"))
	to_chat(owner.current, span_notice("You appear as an adorable, harmless teddy bear. Collect materials from corpses to build copies."))
	to_chat(owner.current, span_notice("Your copies are hostile and will attack personnel on their own."))
	to_chat(owner.current, span_warning("Stay close to corpses to secretly harvest materials. Build copies when you have enough."))

/datum/antagonist/scp/scp1048/apply_scp_effects()
	if(!owner.current)
		return
	grant_action(/datum/action/innate/scp1048_view_build_status)

/datum/antagonist/scp/scp1048/remove_scp_effects()
	if(!owner.current)
		return
	remove_action(/datum/action/innate/scp1048_view_build_status)

/datum/action/innate/scp1048_view_build_status
	name = "Build Status"
	desc = "Check your current material count and copy status."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "scan"

/datum/action/innate/scp1048_view_build_status/Activate()
	var/mob/living/simple_animal/scp1048/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.view_build_status()

// ================================================================
// SCP-1507 - Pink Flamingos
// ================================================================

/datum/antagonist/scp/scp1507
	name = "SCP-1507"
	scp_id = "SCP-1507"
	scp_class = "Euclid"
	description = "You are SCP-1507, a pink plastic flamingo. Coordinate with your flock to overwhelm threats."

/datum/antagonist/scp/scp1507/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-1507, a pink plastic flamingo.</b>"))
	to_chat(owner.current, span_notice("You look like an ordinary lawn ornament, but you are very much alive."))
	to_chat(owner.current, span_notice("Call your flock to gather nearby flamingos, and coordinate attacks against threats."))
	to_chat(owner.current, span_warning("You become enraged when damaged, and your flock shares your anger."))

/datum/antagonist/scp/scp1507/apply_scp_effects()
	if(!owner.current)
		return
	grant_action(/datum/action/innate/scp1507_call_flock)
	grant_action(/datum/action/innate/scp1507_coordinate_attack)

/datum/antagonist/scp/scp1507/remove_scp_effects()
	if(!owner.current)
		return
	remove_action(/datum/action/innate/scp1507_call_flock)
	remove_action(/datum/action/innate/scp1507_coordinate_attack)

/datum/action/innate/scp1507_call_flock
	name = "Call Flock"
	desc = "Call nearby flamingos to your location."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "call"

/datum/action/innate/scp1507_call_flock/Activate()
	var/mob/living/simple_animal/hostile/retaliate/scp1507/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.call_flock()

/datum/action/innate/scp1507_coordinate_attack
	name = "Coordinate Attack"
	desc = "Coordinate a flock attack against your current target."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "smite"

/datum/action/innate/scp1507_coordinate_attack/Activate()
	var/mob/living/simple_animal/hostile/retaliate/scp1507/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.coordinate_attack()

// ================================================================
// SCP-2020 - Cliche, Right?
// ================================================================

/datum/antagonist/scp/scp2020
	name = "SCP-2020"
	scp_id = "SCP-2020"
	scp_class = "Safe"
	description = "You are SCP-2020, a green humanoid who believes it is a character in a science fiction story. You narrate events as story beats."

/datum/antagonist/scp/scp2020/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-2020, Cliche, Right?</b>"))
	to_chat(owner.current, span_notice("You are a green-skinned humanoid convinced you exist within a science fiction narrative."))
	to_chat(owner.current, span_notice("Give dramatic speeches, narrate events, identify cliches, and check your narrative status."))
	to_chat(owner.current, span_warning("You are completely harmless — your power is purely narrative."))

/datum/antagonist/scp/scp2020/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp2020_dramatic_speech)
	grant_action(/datum/action/innate/scp2020_narrate_events)
	grant_action(/datum/action/innate/scp2020_identify_cliche)
	grant_action(/datum/action/innate/scp2020_check_narrative)

/datum/antagonist/scp/scp2020/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp2020_dramatic_speech)
	remove_action(/datum/action/innate/scp2020_narrate_events)
	remove_action(/datum/action/innate/scp2020_identify_cliche)
	remove_action(/datum/action/innate/scp2020_check_narrative)

/datum/action/innate/scp2020_dramatic_speech
	name = "Dramatic Speech"
	desc = "Give a dramatic speech about the narrative."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "speak"

/datum/action/innate/scp2020_dramatic_speech/Activate()
	var/mob/living/carbon/human/scp2020/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.give_dramatic_speech()

/datum/action/innate/scp2020_narrate_events
	name = "Narrate Events"
	desc = "Narrate the current events as story beats."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "scan"

/datum/action/innate/scp2020_narrate_events/Activate()
	var/mob/living/carbon/human/scp2020/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.narrate_events()

/datum/action/innate/scp2020_identify_cliche
	name = "Identify Cliche"
	desc = "Identify a cliche in the current situation."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "scan"

/datum/action/innate/scp2020_identify_cliche/Activate()
	var/mob/living/carbon/human/scp2020/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.identify_cliche()

/datum/action/innate/scp2020_check_narrative
	name = "Narrative Status"
	desc = "Check your current narrative phase and statistics."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "scan"

/datum/action/innate/scp2020_check_narrative/Activate()
	var/mob/living/carbon/human/scp2020/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.check_narrative_status()

// ================================================================
// SCP-343 - God
// ================================================================

/datum/antagonist/scp/scp343
	name = "SCP-343"
	scp_id = "SCP-343"
	scp_class = "Safe"
	description = "You are SCP-343, an elderly man who is God. Heal the wounded and create divine zones of protection."

/datum/antagonist/scp/scp343/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-343, God.</b>"))
	to_chat(owner.current, span_notice("You are an elderly man with divine power. Heal those nearby and create zones of divine protection."))
	to_chat(owner.current, span_notice("Your divine energy regenerates over time. Use it wisely to care for others."))
	to_chat(owner.current, span_warning("Your power is benevolent — you exist to protect and heal, not harm."))

/datum/antagonist/scp/scp343/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp343_divine_heal)
	grant_action(/datum/action/innate/scp343_divine_zone)

/datum/antagonist/scp/scp343/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp343_divine_heal)
	remove_action(/datum/action/innate/scp343_divine_zone)

/datum/action/innate/scp343_divine_heal
	name = "Divine Heal"
	desc = "Heal a nearby target with divine energy."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "heal"

/datum/action/innate/scp343_divine_heal/Activate()
	var/mob/living/carbon/human/scp343/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.divine_heal_verb()

/datum/action/innate/scp343_divine_zone
	name = "Divine Zone"
	desc = "Create a divine zone of healing and protection."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "shield"

/datum/action/innate/scp343_divine_zone/Activate()
	var/mob/living/carbon/human/scp343/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.divine_zone_verb()

// ================================================================
// SCP-527 - Mr. Fish
// ================================================================

/datum/antagonist/scp/scp527
	name = "SCP-527"
	scp_id = "SCP-527"
	scp_class = "Safe"
	description = "You are SCP-527, Mr. Fish. A fish-headed humanoid from Dr. Wondertainment's 'Mr.' series. Comfortable in and out of water."

/datum/antagonist/scp/scp527/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-527, Mr. Fish.</b>"))
	to_chat(owner.current, span_notice("You are a fish-headed humanoid. You can dive into water and breathe underwater."))
	to_chat(owner.current, span_notice("Water heals you over time. Use your aquatic abilities to stay mobile."))
	to_chat(owner.current, span_warning("You are generally harmless — you just want to swim and exist peacefully."))

/datum/antagonist/scp/scp527/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp527_dive)
	grant_action(/datum/action/innate/scp527_breathe_underwater)

/datum/antagonist/scp/scp527/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp527_dive)
	remove_action(/datum/action/innate/scp527_breathe_underwater)

/datum/action/innate/scp527_dive
	name = "Dive"
	desc = "Dive into nearby water."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "phase"

/datum/action/innate/scp527_dive/Activate()
	var/mob/living/carbon/human/scp527/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.dive()

/datum/action/innate/scp527_breathe_underwater
	name = "Breathe Underwater"
	desc = "Toggle underwater breathing mode."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "aquatic"

/datum/action/innate/scp527_breathe_underwater/Activate()
	var/mob/living/carbon/human/scp527/scp_mob = usr
	if(!istype(scp_mob))
		return
	scp_mob.breathe_underwater()
