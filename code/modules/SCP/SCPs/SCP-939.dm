/mob/living/carbon/human/scp939
	name = "SCP-939"
	desc = "A large, reptilian creature with sharp claws and teeth."
	icon = 'icons/scp/scp_939.dmi'
	icon_state = "crawling"
	real_name = "SCP-939"

	var/datum/scp939_voice_system/voice_system
	var/datum/scp939_pack_system/pack_system
	var/datum/scp939_psychology_system/psychology_system
	var/datum/scp939_territory_system/territory_system
	var/datum/scp939_hunting_system/hunting_system
	var/datum/scp939_research_integration/research_integration

/mob/living/carbon/human/scp939/Initialize()
	. = ..()

	set_species(/datum/species/scp939)

	voice_system = new /datum/scp939_voice_system(src)
	pack_system = new /datum/scp939_pack_system(src)
	psychology_system = new /datum/scp939_psychology_system(src)
	territory_system = new /datum/scp939_territory_system(src)
	hunting_system = new /datum/scp939_hunting_system(src)
	research_integration = new /datum/scp939_research_integration(src)

	SCP = new /datum/scp(
		src,
		"SCP-939",
		SCP_KETER,
		"939",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	maxHealth = SCP939_MAX_HEALTH
	health = maxHealth

	fovangle = 360
	update_fov_angles()
	update_cone_show()

	START_PROCESSING(SSobj, src)

/mob/living/carbon/human/scp939/process(delta_time)
	voice_system?.process_voice()
	pack_system?.process_pack()
	psychology_system?.process_psychology()
	territory_system?.process_territory()
	hunting_system?.process_hunting()
	research_integration?.process_research()

/mob/living/carbon/human/scp939/Destroy()
	QDEL_NULL(voice_system)
	QDEL_NULL(pack_system)
	QDEL_NULL(psychology_system)
	QDEL_NULL(territory_system)
	QDEL_NULL(hunting_system)
	QDEL_NULL(research_integration)
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/carbon/human/scp939/proc/get_scp939_status_items()
	var/list/status_items = list()

	if(voice_system)
		status_items += "Learned Voices: [length(voice_system.learned_voices)]"

	if(pack_system)
		status_items += "Pack Members: [length(pack_system.pack_members)]"

	if(psychology_system)
		status_items += "Target Profiles: [length(psychology_system.target_profiles)]"

	if(territory_system)
		status_items += "Controlled Areas: [length(territory_system.controlled_areas)]"

	if(hunting_system)
		status_items += "Hunt Mode: [hunting_system.hunt_mode ? "ACTIVE" : "INACTIVE"]"
		if(hunting_system.current_target)
			status_items += "Current Target: [hunting_system.current_target.name]"

	return status_items

/mob/living/carbon/human/scp939/get_status_tab_items()
	var/list/status_items = ..()
	status_items += get_scp939_status_items()
	return status_items

/mob/living/carbon/human/scp939/examine(mob/user)
	. = ..()

	if(voice_system)
		. += "<span class='notice'>Learned Voices: [length(voice_system.learned_voices)]</span>"

	if(pack_system)
		. += "<span class='notice'>Pack Members: [length(pack_system.pack_members)]</span>"

	if(hunting_system && hunting_system.hunt_mode)
		. += "<span class='danger'>This SCP-939 is actively hunting!</span>"

/mob/living/carbon/human/scp939/proc/contribute_research_data()
	var/research_data = list(
		"scp_type" = "SCP-939",
		"learned_voices_count" = length(voice_system?.learned_voices) || 0,
		"pack_members_count" = length(pack_system?.pack_members) || 0,
		"controlled_areas_count" = length(territory_system?.controlled_areas) || 0,
		"current_target" = hunting_system?.current_target?.name || "none",
		"hunt_mode" = hunting_system?.hunt_mode || FALSE,
		"timestamp" = world.time
	)

	research_integration?.research_data["last_update"] = research_data

/mob/living/carbon/human/scp939/proc/on_voice_mimic(mob/living/carbon/human/target)
	if(!target)
		return
	hook_scp_interaction(target, "SCP-939", INTERACTION_TYPE_COMMUNICATION)

/mob/living/carbon/human/scp939/proc/on_pack_communication(mob/living/carbon/human/pack_member)
	if(!pack_member)
		return
	hook_scp_interaction(pack_member, "SCP-939", INTERACTION_TYPE_COMMUNICATION)

/mob/living/carbon/human/scp939/proc/on_hunt_kill(mob/living/carbon/human/victim)
	if(!victim)
		return
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
	hook_scp_breach("SCP-939", src)

/mob/living/carbon/human/scp939/proc/on_psychological_manipulation(mob/living/carbon/human/target)
	if(!target)
		return
	hook_scp_interaction(target, "SCP-939", INTERACTION_TYPE_COMMUNICATION)

/mob/living/carbon/human/scp939/proc/on_recontainment()
	hook_scp_recontainment("SCP-939", list("method" = "standard"))
