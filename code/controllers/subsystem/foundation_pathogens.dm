SUBSYSTEM_DEF(foundation_pathogens)
	name = "Foundation Pathogens"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DCLASS

	var/list/active_infections = list()
	var/list/cure_log = list()
	var/list/bsl_zones = list()
	var/list/pathogen_research_data = list()

/datum/controller/subsystem/foundation_pathogens/Initialize(timeofday)
	setup_bsl_zones()
	setup_research_data()
	return ..()

/datum/controller/subsystem/foundation_pathogens/proc/setup_bsl_zones()
	bsl_zones = list(
		BSL_1 = list(
			"name" = "Low Containment",
			"required_access" = ACCESS_MEDICAL,
			"suit_required" = FALSE,
			"decon_required" = FALSE,
		),
		BSL_2 = list(
			"name" = "Standard Containment",
			"required_access" = ACCESS_SCIENCE,
			"suit_required" = FALSE,
			"decon_required" = TRUE,
		),
		BSL_3 = list(
			"name" = "High Containment",
			"required_access" = ACCESS_SECURITY_LVL3,
			"suit_required" = TRUE,
			"decon_required" = TRUE,
		),
		BSL_4 = list(
			"name" = "Maximum Containment",
			"required_access" = ACCESS_SECURITY_LVL5,
			"suit_required" = TRUE,
			"decon_required" = TRUE,
			"double_door" = TRUE,
		),
	)

/datum/controller/subsystem/foundation_pathogens/proc/setup_research_data()
	for(var/T in subtypesof(/datum/pathogen/foundation))
		var/datum/pathogen/foundation/F = T
		pathogen_research_data["[T]"] = list(
			"name" = initial(F.name),
			"bsl" = initial(F.bsl_level),
			"anomalous" = initial(F.is_anomalous),
			"research_stage" = initial(F.research_stage),
			"transmission" = initial(F.transmission_types),
		)

/datum/controller/subsystem/foundation_pathogens/proc/register_infection(datum/pathogen/foundation/F)
	var/key = "[F.type]_[F.affected_mob?.ckey]"
	active_infections[key] = list(
		"pathogen_type" = "[F.type]",
		"host" = F.affected_mob,
		"bsl" = F.bsl_level,
		"time" = world.time,
	)

/datum/controller/subsystem/foundation_pathogens/proc/register_cure(datum/pathogen/foundation/F)
	var/key = "[F.type]_[F.affected_mob?.ckey]"
	active_infections -= key
	cure_log += list(list(
		"pathogen_type" = "[F.type]",
		"host_ckey" = F.affected_mob?.ckey,
		"bsl" = F.bsl_level,
		"time" = world.time,
	))

/datum/controller/subsystem/foundation_pathogens/proc/get_infections_by_bsl(bsl)
	var/list/result = list()
	for(var/key in active_infections)
		if(active_infections[key]["bsl"] == bsl)
			result += active_infections[key]
	return result

/datum/controller/subsystem/foundation_pathogens/proc/get_research_progress(pathogen_type)
	if(!pathogen_research_data["[pathogen_type]"])
		return 0
	return pathogen_research_data["[pathogen_type]"]["research_stage"]

/datum/controller/subsystem/foundation_pathogens/proc/advance_research(pathogen_type, stages = 1)
	if(!pathogen_research_data["[pathogen_type]"])
		return FALSE
	var/current = pathogen_research_data["[pathogen_type]"]["research_stage"]
	pathogen_research_data["[pathogen_type]"]["research_stage"] = min(current + stages, RESEARCH_STAGE_CURED)
	return TRUE
