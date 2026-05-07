/obj/machinery/computer/pathogen_research_console
	name = "Pathogen Research Console"
	desc = "A Foundation terminal for researching and developing countermeasures against pathogens."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/pathogen_research_console
	req_access = list(ACCESS_SCIENCE)

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/pathogen_research_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PathogenResearchConsole", name)
		ui.open()

/obj/machinery/computer/pathogen_research_console/ui_data(mob/user)
	var/list/data = list()

	data["active_infections"] = list()
	for(var/key in SSfoundation_pathogens.active_infections)
		var/list/inf = SSfoundation_pathogens.active_infections[key]
		data["active_infections"] += list(list(
			"pathogen_type" = inf["pathogen_type"],
			"host_name" = inf["host"] ? inf["host"].name : "Unknown",
			"bsl" = inf["bsl"],
			"time" = inf["time"],
		))

	data["cure_log"] = SSfoundation_pathogens.cure_log

	data["bsl_summary"] = list()
	for(var/bsl in list(BSL_1, BSL_2, BSL_3, BSL_4))
		var/list/infections = SSfoundation_pathogens.get_infections_by_bsl(bsl)
		data["bsl_summary"] += list(list(
			"level" = bsl,
			"count" = length(infections),
		))

	data["research_data"] = list()
	for(var/pkey in SSfoundation_pathogens.pathogen_research_data)
		var/list/pdata = SSfoundation_pathogens.pathogen_research_data[pkey]
		data["research_data"] += list(list(
			"type" = pkey,
			"name" = pdata["name"],
			"bsl" = pdata["bsl"],
			"anomalous" = pdata["anomalous"],
			"research_stage" = pdata["research_stage"],
			"transmission" = pdata["transmission"],
		))

	data["host_diseases"] = list()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/datum/pathogen/foundation/F in H.diseases)
			data["host_diseases"] += list(list(
				"name" = F.name,
				"bsl" = F.bsl_level,
				"stage" = F.stage,
				"max_stage" = F.max_stages,
				"anomalous" = F.is_anomalous,
				"research_stage" = F.research_stage,
			))

	return data

/obj/machinery/computer/pathogen_research_console/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("advance_research")
			var/pathogen_type = params["pathogen_type"]
			if(pathogen_type)
				SSfoundation_pathogens.advance_research(pathogen_type, 1)
				. = TRUE
		if("begin_cure_development")
			var/pathogen_type = params["pathogen_type"]
			if(pathogen_type)
				var/current = SSfoundation_pathogens.get_research_progress(pathogen_type)
				if(current >= RESEARCH_STAGE_MAPPED)
					SSfoundation_pathogens.advance_research(pathogen_type, 1)
					. = TRUE
		if("administer_scp500")
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				for(var/datum/pathogen/foundation/F in H.diseases)
					if(F.is_anomalous)
						F.force_cure()
						. = TRUE
						break

/obj/item/circuitboard/computer/pathogen_research_console
	name = "Pathogen Research Console (Computer Board)"
	build_path = /obj/machinery/computer/pathogen_research_console
