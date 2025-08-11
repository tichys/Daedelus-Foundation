// SCP-035: The Possessive Mask
// A mask that possesses its wearer and changes their personality

/datum/scp035_personality
	var/name = "Unknown"
	var/description = "A mysterious personality"
	var/list/traits = list()
	var/list/abilities = list()
	var/aggression_level = 0 // 0-10 scale
	var/intelligence_level = 0 // 0-10 scale
	var/charisma_level = 0 // 0-10 scale

/datum/scp035_personality/psychopath
	name = "The Psychopath"
	description = "A violent and sadistic personality that enjoys causing pain"
	traits = list("violent", "sadistic", "manipulative", "unpredictable")
	abilities = list("enhanced_strength", "pain_resistance", "weapon_mastery")
	aggression_level = 9
	intelligence_level = 7
	charisma_level = 6

/datum/scp035_personality/scientist
	name = "The Scientist"
	description = "A brilliant but amoral researcher obsessed with knowledge"
	traits = list("intelligent", "curious", "amoral", "methodical")
	abilities = list("enhanced_intelligence", "research_mastery", "technical_expertise")
	aggression_level = 3
	intelligence_level = 10
	charisma_level = 4

/datum/scp035_personality/charmer
	name = "The Charmer"
	description = "A charming and manipulative personality that excels at social interaction"
	traits = list("charismatic", "manipulative", "persuasive", "deceptive")
	abilities = list("enhanced_charisma", "social_mastery", "persuasion")
	aggression_level = 2
	intelligence_level = 6
	charisma_level = 10

/datum/scp035_personality/warrior
	name = "The Warrior"
	description = "A disciplined and honorable warrior personality"
	traits = list("honorable", "disciplined", "protective", "loyal")
	abilities = list("combat_mastery", "tactical_awareness", "leadership")
	aggression_level = 6
	intelligence_level = 7
	charisma_level = 7

/obj/item/clothing/mask/scp035
	name = "SCP-035"
	desc = "A white ceramic mask with a sad expression. It seems to be crying black tears."
	icon = 'icons/mob/animal.dmi'
	icon_state = "scp035"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE
	var/datum/scp035_personality/current_personality
	var/mob/living/carbon/human/possessed_host
	var/possession_time = 0
	var/possession_duration = 0
	var/list/available_personalities = list()
	var/cooldown_time = 0
	var/MAX_POSSESSION_TIME = 30 MINUTES
	var/COOLDOWN_TIME = 5 MINUTES

/obj/item/clothing/mask/scp035/Initialize()
	. = ..()
	// Initialize available personalities
	available_personalities = list(
		new /datum/scp035_personality/psychopath(),
		new /datum/scp035_personality/scientist(),
		new /datum/scp035_personality/charmer(),
		new /datum/scp035_personality/warrior()
	)
	// Randomly select initial personality
	current_personality = pick(available_personalities)

	// Register signals for cross-SCP interactions
	RegisterSignal(src, COMSIG_SCP_MEMETIC_AFFECTED, PROC_REF(on_memetic_affected))
	RegisterSignal(src, COMSIG_SCP106_CORROSION_APPLIED, PROC_REF(on_corrosion_applied))
	RegisterSignal(src, COMSIG_SCP049_CURE_STARTED, PROC_REF(on_cure_started))
	RegisterSignal(src, COMSIG_SCP096_RAGE_TRIGGERED, PROC_REF(on_rage_triggered))
	RegisterSignal(src, COMSIG_SCP173_EYE_CONTACT_MADE, PROC_REF(on_eye_contact))
	RegisterSignal(src, COMSIG_SCP682_ADAPTED, PROC_REF(on_adaptation))

/obj/item/clothing/mask/scp035/proc/on_equipped(datum/source, mob/living/carbon/human/user, slot)
	if(slot == ITEM_SLOT_MASK && ishuman(user))
		start_possession(user)

/obj/item/clothing/mask/scp035/proc/on_dropped(datum/source, mob/living/carbon/human/user)
	if(possessed_host == user)
		end_possession()

/obj/item/clothing/mask/scp035/proc/start_possession(mob/living/carbon/human/host)
	if(possessed_host || world.time < cooldown_time)
		return

	possessed_host = host
	possession_time = world.time
	possession_duration = rand(10 MINUTES, MAX_POSSESSION_TIME)

	// Apply personality effects
	apply_personality_effects()

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP035_POSSESSION_STARTED, host, current_personality)

	to_chat(host, span_warning("You feel a strange presence taking over your mind..."))
	to_chat(host, span_notice("You are now [current_personality.name]: [current_personality.description]"))

	// Start possession timer
	addtimer(CALLBACK(src, PROC_REF(check_possession_time)), 1 MINUTES)

/obj/item/clothing/mask/scp035/proc/end_possession()
	if(!possessed_host)
		return

	var/mob/living/carbon/human/old_host = possessed_host

	// Remove personality effects
	remove_personality_effects()

	// Notify research system
	SEND_SIGNAL(src, COMSIG_SCP035_POSSESSION_ENDED, old_host, current_personality)

	to_chat(old_host, span_notice("The strange presence leaves your mind. You feel like yourself again."))

	possessed_host = null
	possession_time = 0
	possession_duration = 0
	cooldown_time = world.time + COOLDOWN_TIME

	// Change personality for next possession
	change_personality()

/obj/item/clothing/mask/scp035/proc/apply_personality_effects()
	if(!possessed_host || !current_personality)
		return

	// Apply personality effects through messages
	to_chat(possessed_host, span_notice("You feel the mask's personality affecting you..."))

	if("enhanced_strength" in current_personality.abilities)
		to_chat(possessed_host, span_notice("You feel stronger."))

	if("enhanced_intelligence" in current_personality.abilities)
		to_chat(possessed_host, span_notice("Your mind feels sharper."))

	if("pain_resistance" in current_personality.abilities)
		to_chat(possessed_host, span_notice("You feel more resistant to pain."))

	// Apply personality-specific behaviors
	if(current_personality.aggression_level >= 7)
		to_chat(possessed_host, span_warning("You feel more aggressive."))

	if(current_personality.intelligence_level >= 8)
		to_chat(possessed_host, span_notice("You feel incredibly intelligent."))

/obj/item/clothing/mask/scp035/proc/remove_personality_effects()
	if(!possessed_host)
		return

	// Remove personality effects through messages
	to_chat(possessed_host, span_notice("The mask's influence fades away..."))

/obj/item/clothing/mask/scp035/proc/change_personality()
	var/datum/scp035_personality/old_personality = current_personality
	current_personality = pick(available_personalities)

	// Ensure we don't get the same personality twice in a row
	if(current_personality == old_personality && length(available_personalities) > 1)
		var/list/other_personalities = available_personalities - list(old_personality)
		current_personality = pick(other_personalities)

	to_chat(possessed_host, span_notice("The mask's personality shifts to [current_personality.name]."))

/obj/item/clothing/mask/scp035/proc/check_possession_time()
	if(!possessed_host || world.time < possession_time + possession_duration)
		return

	// Force end possession if time limit exceeded
	end_possession()

// Cross-SCP interaction methods
/obj/item/clothing/mask/scp035/proc/on_memetic_affected(datum/source, mob/living/carbon/human/affected)
	if(possessed_host && affected == possessed_host)
		// SCP-035 can resist memetic effects due to its own memetic nature
		if(prob(70))
			to_chat(possessed_host, span_notice("The mask's influence protects you from the memetic effect."))
			possessed_host.adjustSanity(5, "mask_protection")
		else
			to_chat(possessed_host, span_warning("The memetic effect overwhelms even the mask's influence!"))
			possessed_host.adjustSanity(-10, "overwhelming_memetic")

/obj/item/clothing/mask/scp035/proc/on_corrosion_applied(datum/source, mob/living/carbon/human/victim)
	if(possessed_host && victim == possessed_host)
		// SCP-035 can resist SCP-106's corrosion
		if(prob(60))
			to_chat(possessed_host, span_notice("The mask's power shields you from the corrosive effect."))
			possessed_host.adjustSanity(3, "mask_corrosion_resistance")

/obj/item/clothing/mask/scp035/proc/on_cure_started(datum/source, mob/living/carbon/human/patient)
	if(possessed_host && patient == possessed_host)
		// SCP-049's cure can remove SCP-035's possession
		to_chat(possessed_host, span_warning("The cure attempts to remove the mask's influence!"))
		possessed_host.adjustSanity(-5, "cure_attempt")
		if(prob(50))
			end_possession()
			to_chat(possessed_host, span_notice("The cure successfully removes the mask's possession."))
			possessed_host.adjustSanity(15, "successful_cure")

/obj/item/clothing/mask/scp035/proc/on_rage_triggered(datum/source, mob/living/carbon/human/target)
	if(possessed_host && target == possessed_host)
		// SCP-035 can calm SCP-096's rage
		if(current_personality.charisma_level >= 8)
			to_chat(possessed_host, span_notice("Your charismatic personality calms the raging entity."))
			possessed_host.adjustSanity(8, "charisma_calm")
			SEND_SIGNAL(source, COMSIG_SCP096_RAGE_ENDED)

/obj/item/clothing/mask/scp035/proc/on_eye_contact(datum/source, mob/living/carbon/human/viewer)
	if(possessed_host && viewer == possessed_host)
		// SCP-035 can resist SCP-173's immobilization
		if(prob(40))
			to_chat(possessed_host, span_notice("The mask's willpower keeps you from being immobilized."))
			possessed_host.adjustSanity(2, "mask_willpower")

/obj/item/clothing/mask/scp035/proc/on_adaptation(datum/source, mob/living/carbon/human/adaptor)
	if(possessed_host && adaptor == possessed_host)
		// SCP-035 can enhance SCP-682's adaptation
		to_chat(possessed_host, span_notice("The mask's intelligence enhances the adaptation process."))
		possessed_host.adjustSanity(5, "enhanced_adaptation")
		SEND_SIGNAL(source, COMSIG_SCP682_EVOLVED)

// Verbs for possessed host
/obj/item/clothing/mask/scp035/verb/change_personality_verb()
	set name = "Change Personality"
	set category = "SCP-035"
	set src in view(1)

	if(!possessed_host || usr != possessed_host)
		to_chat(usr, span_warning("You must be wearing the mask to use this ability."))
		return

	if(world.time < cooldown_time)
		to_chat(usr, span_warning("The mask needs time to change personalities."))
		return

	change_personality()
	apply_personality_effects()

/obj/item/clothing/mask/scp035/verb/force_possession_verb()
	set name = "Force Possession"
	set category = "SCP-035"
	set src in view(1)

	if(!ishuman(usr))
		to_chat(usr, span_warning("This only works on humans."))
		return

	if(possessed_host)
		to_chat(usr, span_warning("The mask is already possessing someone."))
		return

	if(world.time < cooldown_time)
		to_chat(usr, span_warning("The mask is on cooldown."))
		return

	var/mob/living/carbon/human/target = usr
	if(target.wear_mask)
		to_chat(usr, span_warning("You must remove your current mask first."))
		return

	target.equip_to_slot_if_possible(src, ITEM_SLOT_MASK)

// Research system integration
/obj/item/clothing/mask/scp035/proc/get_research_data()
	var/list/data = list()
	data["personality"] = current_personality ? current_personality.name : "None"
	data["possession_time"] = possession_time
	data["possession_duration"] = possession_duration
	data["host"] = possessed_host ? possessed_host.name : "None"
	data["traits"] = current_personality ? current_personality.traits : list()
	data["abilities"] = current_personality ? current_personality.abilities : list()
	return data
