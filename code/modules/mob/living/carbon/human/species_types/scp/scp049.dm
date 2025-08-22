// SCP-049 Species Definition from Foundation-19 PR #13
// Defines the biological traits and characteristics of SCP-049

/datum/species/scp049
	name = "\improper SCP-049"
	plural_form = "SCP-049 instances"
	id = SPECIES_SCP049
	
	bodyflag = FLAG_SCP
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_NOHUNGER,
		TRAIT_NOGERMS,
		TRAIT_NOCLONELOSS,
		TRAIT_TOXIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_NOSLIPALL
	)
	inherent_biotypes = MOB_HUMANOID | MOB_UNDEAD
	
	mutant_bodyparts = list("ipc_screen", "ipc_antenna", "ipc_chassis")
	default_features = list("ipc_screen" = "Static", "ipc_antenna" = "None", "ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)")
	
	species_cookie = /obj/item/food/no_bake_cookie
	liked_food = JUNKFOOD | FRIED
	disliked_food = TOXIC | RAW | GROSS
	toxic_food = NONE
	
	bodytemp_normal = T20C
	bodytemp_heat_damage_limit = 500 // Very resistant to heat
	bodytemp_cold_damage_limit = 200 // Somewhat resistant to cold
	bodytemp_heat_level_1 = 400
	bodytemp_heat_level_2 = 450
	bodytemp_heat_level_3 = 500
	bodytemp_cold_level_1 = 260
	bodytemp_cold_level_2 = 230
	bodytemp_cold_level_3 = 200
	
	coldmod = 0.5
	heatmod = 0.5
	burnmod = 0.5
	brutemod = 0.8
	staminamod = 0.8
	
	// Special SCP-049 characteristics
	payday_modifier = 0 // SCPs don't get paid
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	outfit_important_for_life = /datum/outfit/scp049
	species_language_holder = /datum/language_holder/scp049
	
	// Visual characteristics
	meat = /obj/item/food/meat/slab/human/mutant/skeleton
	skinned_type = /obj/item/stack/sheet/bone
	exotic_bloodtype = "X*" // Unique blood type
	
	// No DNA or fingerprints
	has_unique_blood = TRUE
	blood_color = "#2F4F2F" // Dark greenish blood
	
	/// List of emotes with cooldowns
	var/list/emote_cooldowns = list()
	/// Default emote cooldown time
	var/emote_cooldown_time = 3 SECONDS

/datum/species/scp049/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load)
	. = ..()
	
	// Set up SCP-049 specific traits
	H.real_name = "SCP-049"
	H.name = "SCP-049"
	
	// Add pestilence HUD capability
	var/datum/atom_hud/data/human/pestilence/pestilence_hud = GLOB.huds[DATA_HUD_PESTILENCE]
	if(pestilence_hud)
		pestilence_hud.add_atom_to_hud(H)
	
	// Register for pestilence trait updates
	RegisterSignal(H, COMSIG_TRAIT_GAINED, PROC_REF(on_trait_gain))
	RegisterSignal(H, COMSIG_TRAIT_LOST, PROC_REF(on_trait_loss))
	
	// Grant cure action
	var/datum/action/scp049cure/cure_action = new()
	cure_action.Grant(H)
	
	// Add emote cooldown tracking
	emote_cooldowns = list()

/datum/species/scp049/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	
	// Remove pestilence HUD
	var/datum/atom_hud/data/human/pestilence/pestilence_hud = GLOB.huds[DATA_HUD_PESTILENCE]
	if(pestilence_hud)
		pestilence_hud.remove_atom_from_hud(H)
	
	// Unregister signals
	UnregisterSignal(H, COMSIG_TRAIT_GAINED)
	UnregisterSignal(H, COMSIG_TRAIT_LOST)
	
	// Remove cure action
	for(var/datum/action/scp049cure/cure_action in H.actions)
		cure_action.Remove(H)
		qdel(cure_action)

/datum/species/scp049/proc/on_trait_gain(mob/living/carbon/human/source, trait)
	SIGNAL_HANDLER
	if(trait == TRAIT_PESTILENCE)
		source.update_pestilence_hud()

/datum/species/scp049/proc/on_trait_loss(mob/living/carbon/human/source, trait)
	SIGNAL_HANDLER
	if(trait == TRAIT_PESTILENCE)
		source.update_pestilence_hud()

/datum/species/scp049/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	
	// SCP-049 doesn't need most life processes
	// But we can add special behaviors here
	
	// Slowly regenerate health when not in combat
	if(H.health < H.maxHealth && !H.has_status_effect(/datum/status_effect/incapacitating))
		H.adjustBruteLoss(-0.5 * seconds_per_tick)
		H.adjustFireLoss(-0.5 * seconds_per_tick)

// Emote system with cooldowns
/datum/species/scp049/handle_speech(datum/source, list/speech_args)
	. = ..()
	var/mob/living/carbon/human/H = source
	
	// Add distinctive speech patterns for SCP-049
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		// Replace certain words to make speech more characteristic
		message = replacetext(message, "disease", "pestilence")
		message = replacetext(message, "illness", "pestilence") 
		message = replacetext(message, "sickness", "pestilence")
		message = replacetext(message, "cure", "great work")
		speech_args[SPEECH_MESSAGE] = message

/datum/species/scp049/proc/can_emote(mob/living/carbon/human/H, emote_key)
	if(emote_key in emote_cooldowns)
		if(world.time < emote_cooldowns[emote_key])
			return FALSE
	return TRUE

/datum/species/scp049/proc/set_emote_cooldown(mob/living/carbon/human/H, emote_key)
	emote_cooldowns[emote_key] = world.time + emote_cooldown_time

// Language holder for SCP-049
/datum/language_holder/scp049
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM))
	blocked_languages = list()
	grant_all_languages = FALSE
	omnitongue = FALSE

// Outfit for SCP-049
/datum/outfit/scp049
	name = "SCP-049"
	
	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/black
	
/datum/outfit/scp049/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	// Remove default clothes and set proper appearance
	if(!visualsOnly)
		for(var/obj/item/clothing/C in H.get_equipped_items(include_pockets = TRUE))
			qdel(C)

// Constants
#define SPECIES_SCP049 "scp049"
