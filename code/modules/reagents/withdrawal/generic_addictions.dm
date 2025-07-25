///Opiods
/datum/addiction/opiods
	name = "opiod"
	withdrawal_stage_messages = list("I feel aches in my bodies..", "I need some pain relief...", "It aches all over...I need some opiods!")

/datum/addiction/opiods/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(10, delta_time))
		affected_carbon.emote("yawn")

/datum/addiction/opiods/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/high_blood_pressure)
	affected_carbon.stats?.set_skill_modifier(-1, /datum/rpg_skill/willpower, SKILL_SOURCE_OPIOD_WITHDRAWL)

/datum/addiction/opiods/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(affected_carbon.disgust < DISGUST_LEVEL_DISGUSTED && DT_PROB(7.5, delta_time))
		affected_carbon.adjust_disgust(12.5 * delta_time)


/datum/addiction/opiods/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_status_effect(/datum/status_effect/high_blood_pressure)
	affected_carbon.set_disgust(affected_carbon.disgust * 0.5) //half their disgust to help
	affected_carbon.stats?.remove_skill_modifier(/datum/rpg_skill/willpower, SKILL_SOURCE_OPIOD_WITHDRAWL)

///Stimulants

/datum/addiction/stimulants
	name = "stimulant"
	withdrawal_stage_messages = list("You feel a bit tired...You could really use a pick me up.", "You are getting a bit woozy...", "So...Tired...")

/datum/addiction/stimulants/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.add_actionspeed_modifier(/datum/actionspeed_modifier/stimulants)

/datum/addiction/stimulants/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/woozy)

/datum/addiction/stimulants/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.add_movespeed_modifier(/datum/movespeed_modifier/stimulants)

/datum/addiction/stimulants/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_actionspeed_modifier(ACTIONSPEED_ID_STIMULANTS)
	affected_carbon.remove_status_effect(/datum/status_effect/woozy)
	affected_carbon.remove_movespeed_modifier(MOVESPEED_ID_STIMULANTS)

///Alcohol
/datum/addiction/alcohol
	name = "alcohol"
	withdrawal_stage_messages = list("I could use a drink...", "Maybe the bar is still open?..", "God I need a drink!")

/datum/addiction/alcohol/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_timed_status_effect(10 SECONDS * delta_time, /datum/status_effect/jitter, only_if_higher = TRUE)
	affected_carbon.stats?.set_skill_modifier(-2, /datum/rpg_skill/handicraft, SKILL_SOURCE_ALCHOHOL_WITHDRAWL)

/datum/addiction/alcohol/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_timed_status_effect(20 SECONDS * delta_time, /datum/status_effect/jitter, only_if_higher = TRUE)
	affected_carbon.hallucination = max(5 SECONDS, affected_carbon.hallucination)

/datum/addiction/alcohol/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_timed_status_effect(30 SECONDS * delta_time, /datum/status_effect/jitter, only_if_higher = TRUE)
	affected_carbon.hallucination = max(5 SECONDS, affected_carbon.hallucination)
	if(DT_PROB(4, delta_time))
		if(!HAS_TRAIT(affected_carbon, TRAIT_ANTICONVULSANT))
			affected_carbon.apply_status_effect(/datum/status_effect/seizure)

/datum/addiction/alcohol/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.stats?.remove_skill_modifier(/datum/rpg_skill/handicraft, SKILL_SOURCE_ALCHOHOL_WITHDRAWL)

/datum/addiction/hallucinogens
	name = "hallucinogen"
	withdrawal_stage_messages = list("I feel so empty...", "I wonder what the machine elves are up to?..", "I need to see the beautiful colors again!!")

/datum/addiction/hallucinogens/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_carbon.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.add_filter("hallucinogen_wave", 10, wave_filter(300, 300, 3, 0, WAVE_SIDEWAYS))
	game_plane_master_controller.add_filter("hallucinogen_blur", 10, angular_blur_filter(0, 0, 3))


/datum/addiction/hallucinogens/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/trance, 40 SECONDS, TRUE)

/datum/addiction/hallucinogens/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_carbon.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("hallucinogen_blur")
	game_plane_master_controller.remove_filter("hallucinogen_wave")
	affected_carbon.remove_status_effect(/datum/status_effect/trance, 40 SECONDS, TRUE)

/datum/addiction/maintenance_drugs
	name = "maintenance drug"
	withdrawal_stage_messages = list("", "", "")

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.hal_screwyhud = SCREWYHUD_HEALTHY

/datum/addiction/maintenance_drugs/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(7.5, delta_time))
		affected_carbon.emote("growls")

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/affected_human = affected_carbon
	if(affected_human.gender == MALE)
		to_chat(affected_human, span_warning("Your chin itches."))
		affected_human.facial_hairstyle = "Beard (Full)"
		affected_human.update_body_parts()
	//Only like gross food
	affected_human.dna?.species.liked_food = GROSS
	affected_human.dna?.species.disliked_food = NONE
	affected_human.dna?.species.toxic_food = ~GROSS

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	if(!ishuman(affected_carbon))
		return
	to_chat(affected_carbon, span_warning("You feel yourself adapt to the darkness."))
	var/mob/living/carbon/human/affected_human = affected_carbon
	var/obj/item/organ/eyes/empowered_eyes = affected_human.getorgan(/obj/item/organ/eyes)
	if(empowered_eyes)
		ADD_TRAIT(affected_human, TRAIT_NIGHT_VISION, "maint_drug_addiction")
		empowered_eyes?.refresh()

/datum/addiction/maintenance_drugs/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/affected_human = affected_carbon
	var/turf/T = get_turf(affected_human)
	var/lums = T.get_lumcount()
	if(lums > 0.5)
		affected_human.adjust_timed_status_effect(6 SECONDS, /datum/status_effect/dizziness, max_duration = 80 SECONDS)
		affected_human.adjust_timed_status_effect(0.5 SECONDS * delta_time, /datum/status_effect/confusion, max_duration = 20 SECONDS)

/datum/addiction/maintenance_drugs/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.hal_screwyhud = SCREWYHUD_NONE
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/affected_human = affected_carbon
	affected_human.dna?.species.liked_food = initial(affected_human.dna?.species.liked_food)
	affected_human.dna?.species.disliked_food = initial(affected_human.dna?.species.disliked_food)
	affected_human.dna?.species.toxic_food = initial(affected_human.dna?.species.toxic_food)
	REMOVE_TRAIT(affected_human, TRAIT_NIGHT_VISION, "maint_drug_addiction")
	affected_carbon.update_eyes()

///Makes you a hypochondriac - I'd like to call it hypochondria, but "I could use some hypochondria" doesn't work
/datum/addiction/medicine
	name = "medicine"
	withdrawal_stage_messages = list("", "", "")
	var/datum/hallucination/fake_alert/hallucination
	var/datum/hallucination/fake_health_doll/hallucination2

/datum/addiction/medicine/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/human_mob = affected_carbon
	hallucination2 = new(human_mob, TRUE, severity = 1, duration = 120 MINUTES)

/datum/addiction/medicine/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(10, delta_time))
		affected_carbon.emote("cough")

/datum/addiction/medicine/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	var/list/possibilities = list()
	if(!HAS_TRAIT(affected_carbon, TRAIT_RESISTHEAT))
		possibilities += ALERT_TEMPERATURE_HOT
	if(!HAS_TRAIT(affected_carbon, TRAIT_RESISTCOLD))
		possibilities += ALERT_TEMPERATURE_COLD
	var/obj/item/organ/lungs/lungs = affected_carbon.getorganslot(ORGAN_SLOT_LUNGS)
	if(lungs)
		if(lungs.safe_oxygen_min)
			possibilities += ALERT_NOT_ENOUGH_OXYGEN
		if(lungs.safe_oxygen_max)
			possibilities += ALERT_TOO_MUCH_OXYGEN
	var/type = pick(possibilities)
	hallucination = new(affected_carbon, TRUE, type, 120 MINUTES)//last for a while basically

/datum/addiction/medicine/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(10, delta_time))
		hallucination2.add_fake_limb(severity = 1)
		return
	if(DT_PROB(5, delta_time))
		hallucination2.increment_fake_damage()

/datum/addiction/medicine/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.hal_screwyhud = SCREWYHUD_CRIT

/datum/addiction/medicine/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(5, delta_time))
		hallucination2.increment_fake_damage()
		return
	if(DT_PROB(15, delta_time))
		affected_carbon.emote("cough")
		return
	if(DT_PROB(65, delta_time))
		return
	if(affected_carbon.stat != CONSCIOUS)
		return

	var/obj/item/organ/organ = pick(affected_carbon.processing_organs)
	if(organ.low_threshold)
		to_chat(affected_carbon, organ.low_threshold_passed)
		return
	else if (organ.high_threshold_passed)
		to_chat(affected_carbon, organ.high_threshold_passed)
		return
	to_chat(affected_carbon, span_warning("You feel a dull pain in your [organ.name]."))

/datum/addiction/medicine/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.hal_screwyhud = SCREWYHUD_NONE
	hallucination.cleanup()
	QDEL_NULL(hallucination2)

///Nicotine
/datum/addiction/nicotine
	name = "nicotine"
	addiction_relief_treshold = MIN_NICOTINE_ADDICTION_REAGENT_AMOUNT //much less because your intake is probably from ciggies
	withdrawal_stage_messages = list("Feel like having a smoke...", "Getting antsy. Really need a smoke now.", "I can't take it! Need a smoke NOW!")

/datum/addiction/nicotine/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_timed_status_effect(10 SECONDS * delta_time, /datum/status_effect/jitter, only_if_higher = TRUE)
	affected_carbon.stats?.set_skill_modifier(-2, /datum/rpg_skill/handicraft, SKILL_SOURCE_NICOTINE_WITHDRAWL) //can't focus without my cigs

/datum/addiction/nicotine/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_timed_status_effect(20 SECONDS * delta_time, /datum/status_effect/jitter, only_if_higher = TRUE)
	if(DT_PROB(10, delta_time))
		affected_carbon.emote("cough")

/datum/addiction/nicotine/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_timed_status_effect(30 SECONDS * delta_time, /datum/status_effect/jitter, only_if_higher = TRUE)
	if(DT_PROB(15, delta_time))
		affected_carbon.emote("cough")

/datum/addiction/nicotine/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.stats?.remove_skill_modifier(/datum/rpg_skill/handicraft, SKILL_SOURCE_NICOTINE_WITHDRAWL)

/// Amnestics
/datum/addiction/amnestics
	name = "Amnestics"
	withdrawal_stage_messages = list("What was I thinking about..?.", "I need to forget that...", "I can't take this anymore, I can't keep remembering things!")
	/// So that we don't spam accidentaly
	var/nostalgia_cooldown

/datum/addiction/amnestics/withdrawal_enters_stage_1(mob/living/carbon/victim, delta_time)
	. = ..()
	victim.hallucination += 1
	if(prob(5) && nostalgia_cooldown >= world.time)
		nostalgia_cooldown = world.time + 10 SECONDS
		victim.visible_message(span_warning("[victim] looks confused for a moment."))
		to_chat(victim, span_userdanger(pick("I forgot something important..?", "Did I just...", "Did I really do that..?", "Was that...")))
		victim.playsound_local(get_turf(victim), 'sound/effects/nostalgia1.ogg', 10, FALSE)
		flash_color(victim, flash_color="#FFBBBB", flash_time=5)
		victim.adjust_confusion_up_to(5 SECONDS, 20 SECONDS)

/datum/addiction/amnestics/withdrawal_enters_stage_2(mob/living/carbon/victim, delta_time)
	. = ..()
	victim.hallucination += 2
	if(prob(7) && nostalgia_cooldown >= world.time)
		nostalgia_cooldown = world.time + 10 SECONDS
		victim.visible_message(span_warning("[victim] looks confused for a moment."))
		to_chat(victim, span_userdanger(pick("My mind feels blank.", "The memories keep flooding in!", "My past is no more!", "My future is... no, that was yesterday..?")))
		victim.playsound_local(get_turf(victim), pick('sound/effects/nostalgia2.ogg', 'sound/effects/nostalgia3.ogg'), 25, FALSE)
		victim.adjust_confusion_up_to(10 SECONDS, 40 SECONDS)

/datum/addiction/amnestics/withdrawal_enters_stage_3(mob/living/carbon/victim, delta_time)
	. = ..()
	victim.hallucination += 3
	if(prob(9) && nostalgia_cooldown >= world.time)
		nostalgia_cooldown = world.time + 10 SECONDS
		victim.visible_message(span_warning("[victim] looks really confused for a moment."))
		to_chat(victim, span_userdanger(pick("Future, past and present, all lie intertwined...", "The memories hold no meaning anymore.", "What did I do today? What will I do tomorrow?", "Nothing really matters anymore.")))
		victim.playsound_local(get_turf(victim), pick('sound/effects/nostalgia4.ogg', 'sound/effects/nostalgia5.ogg'), 50, FALSE)
		victim.adjust_confusion_up_to(15 SECONDS, 60 SECONDS)

/datum/addiction/amnestics/end_withdrawal(mob/living/carbon/victim)
	to_chat(victim, span_good("I can see it all clearly now..."))
	victim.playsound_local(get_turf(victim), 'sound/effects/nostalgia5B.ogg', 50, FALSE)
	victim.hallucination -= 100
	return ..()
