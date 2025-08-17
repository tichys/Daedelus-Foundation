// SCP Research Console
// Allows researchers to view and manage their research projects

/obj/machinery/computer/scp_research_console
	name = "SCP Research Console"
	desc = "A computer console for managing SCP research projects and viewing research data."
	icon_screen = "research"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/scp_research_console
	var/list/access_required = list(ACCESS_SCIENCE)
	var/obj/item/card/id/scan = null

/obj/machinery/computer/scp_research_console/Initialize()
	. = ..()
	update_icon()

/obj/machinery/computer/scp_research_console/update_icon()
	. = ..()
	if(machine_stat & BROKEN)
		icon_screen = "research_broken"
	else if(machine_stat & NOPOWER)
		icon_screen = "research_off"
	else
		icon_screen = "research"

/obj/machinery/computer/scp_research_console/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(!scan)
			if(!user.transferItemToLoc(I, src))
				return
			scan = I
			to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>There's already an ID card in [src].</span>")
		return
	return ..()

/obj/machinery/computer/scp_research_console/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/scp_research_console/interact(mob/user)
	if(!SSscp_research || !SSscp_research.manager)
		to_chat(user, "<span class='warning'>Research system not available.</span>")
		return

	var/datum/browser/popup = new(user, "scp_research_console", "SCP Research Console", 800, 600)
	popup.set_content(generate_ui(user))
	popup.open()

/obj/machinery/computer/scp_research_console/proc/generate_ui(mob/user)
	var/datum/researcher_data/researcher = get_researcher_data(user.ckey)
	var/list/html = list()
	
	html += "<html><head><title>SCP Research Console</title></head><body>"
	html += "<h1>SCP Research Console</h1>"
	
	if(!researcher)
		html += "<p>No research data found. Start researching SCPs to see your progress.</p>"
	else
		html += "<h2>Research Profile</h2>"
		html += "<table border='1' style='width:100%; border-collapse: collapse;'>"
		html += "<tr><td><b>Research Points:</b></td><td>[researcher.research_points]</td></tr>"
		html += "<tr><td><b>Research Funding:</b></td><td>[researcher.research_funding]</td></tr>"
		html += "<tr><td><b>Progression Points:</b></td><td>[researcher.progression_points]</td></tr>"
		html += "<tr><td><b>Research Rank:</b></td><td>[researcher.research_rank]</td></tr>"
		html += "<tr><td><b>Total Projects:</b></td><td>[researcher.total_projects]</td></tr>"
		html += "<tr><td><b>Completed Projects:</b></td><td>[researcher.completed_projects]</td></tr>"
		html += "<tr><td><b>Failed Projects:</b></td><td>[researcher.failed_projects]</td></tr>"
		html += "</table>"
		
		if(researcher.achievements.len > 0)
			html += "<h2>Achievements</h2>"
			html += "<ul>"
			for(var/achievement in researcher.achievements)
				html += "<li>[achievement]</li>"
			html += "</ul>"
		
		if(researcher.completed_research.len > 0)
			html += "<h2>Completed Research</h2>"
			html += "<ul>"
			for(var/research in researcher.completed_research)
				html += "<li>[research]</li>"
			html += "</ul>"
		
		html += "<h2>Active Research Projects</h2>"
		var/found_projects = FALSE
		html += "<table border='1' style='width:100%; border-collapse: collapse;'>"
		html += "<tr><th>SCP</th><th>Type</th><th>Level</th><th>Progress</th><th>Time</th></tr>"
		
		for(var/project_id in SSscp_research.manager.research_projects)
			var/datum/research_data/project = SSscp_research.manager.research_projects[project_id]
			if(project.researcher_ckey == user.ckey && project.status == "ACTIVE")
				found_projects = TRUE
				var/progress_percent = round((project.research_points / project.research_cost) * 100)
				var/time_minutes = round((world.time - project.timestamp) / 600)
				html += "<tr>"
				html += "<td>[project.scp_designation]</td>"
				html += "<td>[project.research_type]</td>"
				html += "<td>[project.research_level]/[project.max_research_level]</td>"
				html += "<td>[project.research_points]/[project.research_cost] ([progress_percent]%)</td>"
				html += "<td>[time_minutes] minutes</td>"
				html += "</tr>"
		
		if(!found_projects)
			html += "<tr><td colspan='5'>No active research projects</td></tr>"
		
		html += "</table>"
	
	html += "<br><a href='?src=[REF(src)];refresh=1'>Refresh</a>"
	html += "</body></html>"
	
	return jointext(html, "")

/obj/machinery/computer/scp_research_console/Topic(href, href_list)
	if(..())
		return
	
	if(href_list["refresh"])
		interact(usr)
		return

/obj/item/circuitboard/computer/scp_research_console
	name = "SCP Research Console (Computer Board)"
	build_path = /obj/machinery/computer/scp_research_console
