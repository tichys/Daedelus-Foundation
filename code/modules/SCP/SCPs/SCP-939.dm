// SCP-939 - With Many Voices
// A reptilian creature that hunts in packs using advanced voice mimicry

/mob/living/carbon/human/scp939
	name = "SCP-939"
	desc = "A large, reptilian creature with sharp claws and teeth."
	icon = 'icons/scp/scp_939.dmi'
	icon_state = "crawling"
	real_name = "SCP-939"

	// Core system datums
	var/datum/scp939_voice_system/voice_system
	var/datum/scp939_pack_system/pack_system
	var/datum/scp939_psychology_system/psychology_system
	var/datum/scp939_territory_system/territory_system
	var/datum/scp939_hunting_system/hunting_system
	var/datum/scp939_research_integration/research_integration

	// Core stats (now human-based)
	var/hunting_experience = 0
	var/voice_evolution_stage = 1
	var/pack_hierarchy_rank = 1
	var/territory_control = 0

	// Persistence tracking
	var/hunts_completed = 0
	var/victims_hunted = 0
	var/voices_mimicked = 0
	var/pack_communications = 0
	var/territories_claimed = 0
	var/psychological_manipulations = 0
	var/hunting_strategies_developed = 0
	var/voice_evolutions_completed = 0

	// Progression integration tracking
	var/voices_learned = 0

/mob/living/carbon/human/scp939/Initialize()
	. = ..()

	// Set species properly
	set_species(/datum/species/scp939)

	// Initialize core systems
	voice_system = new /datum/scp939_voice_system(src)
	pack_system = new /datum/scp939_pack_system(src)
	psychology_system = new /datum/scp939_psychology_system(src)
	territory_system = new /datum/scp939_territory_system(src)
	hunting_system = new /datum/scp939_hunting_system(src)
	research_integration = new /datum/scp939_research_integration(src)

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-939",
		SCP_KETER,
		"939",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	// Set up human-specific properties for SCP-939
	maxHealth = SCP939_MAX_HEALTH
	health = maxHealth

	// Initialize vision cone
	fovangle = 90
	update_fov_angles()
	update_cone_show()

	// Start processing
	START_PROCESSING(SSobj, src)

/mob/living/carbon/human/scp939/process(delta_time)
	// Don't call parent - we're implementing our own process logic

	// Update all systems
	voice_system?.process_voice()
	pack_system?.process_pack()
	psychology_system?.process_psychology()
	territory_system?.process_territory()
	hunting_system?.process_hunting()
	research_integration?.process_research()

	// Return nothing to continue processing (not PROCESS_KILL)

// SCP-939 Status Display
/mob/living/carbon/human/scp939/proc/get_scp939_status_items()
	var/list/status_items = list()

	// Voice system status
	if(voice_system)
		status_items += "Voice Evolution: [voice_system.voice_evolution_stage]/[voice_system.max_voice_evolution]"
		status_items += "Mimicry Accuracy: [voice_system.mimicry_accuracy]%"
		status_items += "Learned Voices: [length(voice_system.learned_voices)]"

	// Pack system status
	if(pack_system)
		status_items += "Pack Coordination: [pack_system.pack_coordination]/[pack_system.max_pack_coordination]"
		status_items += "Pack Members: [length(pack_system.pack_members)]"
		status_items += "Hierarchy Rank: [pack_system.pack_hierarchy_rank]/[pack_system.max_pack_hierarchy]"

	// Psychology system status
	if(psychology_system)
		status_items += "Psychological Manipulation: [psychology_system.psychological_manipulation]/[psychology_system.max_psychological_manipulation]"
		status_items += "Target Profiles: [length(psychology_system.target_profiles)]"

	// Territory system status
	if(territory_system)
		status_items += "Territory Control: [territory_system.territory_control]/[territory_system.max_territory_control]"
		status_items += "Controlled Areas: [length(territory_system.controlled_areas)]"

	// Hunting system status
	if(hunting_system)
		status_items += "Hunting Experience: [hunting_system.hunting_experience]/[hunting_system.max_hunting_experience]"
		status_items += "Hunt Mode: [hunting_system.hunt_mode ? "ACTIVE" : "INACTIVE"]"
		if(hunting_system.current_target)
			status_items += "Current Target: [hunting_system.current_target.name]"

	return status_items

// Override get_status_tab_items to include SCP-939 specific information
/mob/living/carbon/human/scp939/get_status_tab_items()
	var/list/status_items = ..()
	status_items += get_scp939_status_items()
	return status_items

// Enhanced examine for SCP-939
/mob/living/carbon/human/scp939/examine(mob/user)
	. = ..()

	if(voice_system)
		. += "<span class='notice'>Voice Evolution Stage: [voice_system.voice_evolution_stage]/[voice_system.max_voice_evolution]</span>"
		. += "<span class='notice'>Learned Voices: [length(voice_system.learned_voices)]</span>"

	if(pack_system)
		. += "<span class='notice'>Pack Coordination: [pack_system.pack_coordination]/[pack_system.max_pack_coordination]</span>"
		. += "<span class='notice'>Pack Members: [length(pack_system.pack_members)]</span>"

	if(hunting_system && hunting_system.hunt_mode)
		. += "<span class='danger'>This SCP-939 is actively hunting!</span>"

// Research contribution
/mob/living/carbon/human/scp939/proc/contribute_research_data()
	var/research_data = list(
		"scp_type" = "SCP-939",
		"voice_evolution_stage" = voice_system?.voice_evolution_stage || 1,
		"learned_voices_count" = length(voice_system?.learned_voices) || 0,
		"mimicry_accuracy" = voice_system?.mimicry_accuracy || 0,
		"pack_coordination" = pack_system?.pack_coordination || 0,
		"pack_members_count" = length(pack_system?.pack_members) || 0,
		"psychological_manipulation" = psychology_system?.psychological_manipulation || 0,
		"territory_control" = territory_system?.territory_control || 0,
		"controlled_areas_count" = length(territory_system?.controlled_areas) || 0,
		"hunting_experience" = hunting_system?.hunting_experience || 0,
		"current_target" = hunting_system?.current_target?.name || "none",
		"hunt_mode" = hunting_system?.hunt_mode || FALSE,
		"timestamp" = world.time
	)

	research_integration?.research_data["last_update"] = research_data

/mob/living/carbon/human/scp939/proc/on_voice_mimic(mob/living/carbon/human/target)
	if(!target)
		return
	voices_mimicked++
	voices_learned++
	hook_scp_interaction(target, "SCP-939", INTERACTION_TYPE_COMMUNICATION)

/mob/living/carbon/human/scp939/proc/on_pack_communication(mob/living/carbon/human/pack_member)
	if(!pack_member)
		return
	pack_communications++
	hook_scp_interaction(pack_member, "SCP-939", INTERACTION_TYPE_COMMUNICATION)

/mob/living/carbon/human/scp939/proc/on_hunt_kill(mob/living/carbon/human/victim)
	if(!victim)
		return
	victims_hunted++
	hunts_completed++
	hook_scp_breach("SCP-939", src)
	hook_scp_combat(victim, "SCP-939", 100, 0)
	hook_player_death_near_scp(victim, "SCP-939")
	stop_scp_survival_tracking(victim, "SCP-939")

/mob/living/carbon/human/scp939/proc/on_hunt_start(mob/living/carbon/human/target)
	if(!target || !target.ckey)
		return
	start_scp_survival_tracking(target, "SCP-939", INTERACTION_RISK_HIGH)

/mob/living/carbon/human/scp939/proc/on_territory_claim(area/claimed_area)
	if(!claimed_area)
		return
	territories_claimed++
	hook_scp_breach("SCP-939", src)

/mob/living/carbon/human/scp939/proc/on_psychological_manipulation(mob/living/carbon/human/target)
	if(!target)
		return
	psychological_manipulations++
	hook_scp_interaction(target, "SCP-939", INTERACTION_TYPE_COMMUNICATION)

/mob/living/carbon/human/scp939/proc/on_recontainment()
	hook_scp_recontainment("SCP-939", list("method" = "standard"))
