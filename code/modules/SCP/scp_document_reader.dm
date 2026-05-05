// SCP Document Reader - Player Item
// A handheld device/PDA app that shows discovered SCP documentation to regular players
// Players unlock documentation by discovering/experimenting with SCPs

/obj/item/scp_document_reader
	name = "SCP Foundation Terminal"
	desc = "A secure handheld terminal for accessing SCP Foundation documentation. Clearance level required."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	w_class = WEIGHT_CLASS_SMALL
	var/list/unlocked_documents = list()
	var/reader_clearance = 1
	var/last_sync_time = 0
	var/sync_cooldown = 60 SECONDS

/obj/item/scp_document_reader/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	reader_clearance = 1
	if(id_card)
		if(ACCESS_ADMIN in id_card.access)
			reader_clearance = 5
		else if(ACCESS_SCIENCE in id_card.access)
			reader_clearance = 3
		else if(ACCESS_SECURITY in id_card.access)
			reader_clearance = 2

	sync_unlocked_documents(H)
	show_document_menu(H)

/obj/item/scp_document_reader/proc/sync_unlocked_documents(mob/user)
	if(world.time < last_sync_time + sync_cooldown)
		return
	last_sync_time = world.time

	unlocked_documents = list()

	if(SSscp_persistence && SSscp_persistence.manager)
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(!instance)
				continue

			var/required_clearance = 1
			if(instance.containment_status == "breached")
				required_clearance = 1
			else if(findtext(scp_id, "682") || findtext(scp_id, "106"))
				required_clearance = 4
			else if(findtext(scp_id, "096") || findtext(scp_id, "049"))
				required_clearance = 2

			if(reader_clearance >= required_clearance)
				unlocked_documents[scp_id] = generate_document_data(scp_id, instance)

	if(user && SSdclass && SSdclass.manager)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[user.ckey]
		if(player && player.tests_completed > 0)
			for(var/scp_id in unlocked_documents)
				var/required_tests = 1
				if(player.tests_completed >= required_tests)
					continue
				unlocked_documents -= scp_id

/obj/item/scp_document_reader/proc/generate_document_data(scp_id, datum/scp_instance/instance)
	var/list/data = list()
	data["id"] = scp_id
	data["object_class"] = "Unknown"
	data["containment_status"] = instance.containment_status
	data["special_containment_procedures"] = "Information classified."
	data["description"] = "Information classified."
	data["addenda"] = list()

	switch(scp_id)
		if("SCP-173")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-173 is to be kept in a locked container. When personnel must enter, no fewer than 3 may enter at any time and the door is to be relocked behind them. Maintain direct eye contact at all times."
			data["description"] = "SCP-173 is a sculpture constructed from concrete and rebar with traces of Krylon brand spray paint. It is animate and extremely hostile. It cannot move while within a direct line of sight."
		if("SCP-049")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-049 is to be contained in a secure holding cell. During transport, SCP-049 must be sedated. No personnel are to enter SCP-049's cell without full biological protection."
			data["description"] = "SCP-049 is a humanoid entity resembling a medieval plague doctor. It claims to seek and eliminate 'The Pestilence,' though it has not clarified what this means."
		if("SCP-096")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-096 is to be contained in an airtight steel cell. No visual recording equipment is permitted within its cell. All personnel must be briefed on the face-viewing hazard."
			data["description"] = "SCP-096 is a tall humanoid entity. When its face is viewed by any person, it enters a state of extreme distress and will pursue the viewer regardless of distance or obstacles."
		if("SCP-106")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-106 is to be contained in a complex containment cell using the '10-Molybdenum Protocol.' Periodic use of the Femur Breaker is required to lure SCP-106 back into containment."
			data["description"] = "SCP-106 is an elderly humanoid that secretes a corrosive substance. It can pass through solid matter and drags victims into a pocket dimension."
		if("SCP-682")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-682 is to be destroyed whenever possible. It is currently contained in a chamber filled with hydrochloric acid. All attempts at termination have failed."
			data["description"] = "SCP-682 is a large reptilian creature with extreme regenerative capabilities and an intense hatred for all life. It adapts to survive any form of damage."
		if("SCP-939")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-939 instances are to be contained in individually sealed cells. Sound-dampening materials are required. No verbal communication near cells."
			data["description"] = "SCP-939 are pack predators that hunt using voice mimicry. They are blind and hunt entirely through sound. They mimic the voices of their previous victims to lure prey."
		if("SCP-035")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-035 is to be kept in a sealed container. No personnel may wear SCP-035. All communications from SCP-035 are to be ignored."
			data["description"] = "SCP-035 is a porcelain comedy mask that secretes a corrosive substance. When worn, it possesses the wearer, demonstrating advanced manipulation and mind control."
		if("SCP-457")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-457 is to be contained in a fireproof chamber with fire suppression systems. Temperature must be monitored at all times."
			data["description"] = "SCP-457 is a sentient fire entity that grows by consuming combustible material. It demonstrates predatory behavior and intelligence that increases with size."
		if("SCP-017")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-017 is to be contained in an absolute darkness chamber. No light sources are permitted within its containment area."
			data["description"] = "SCP-017 is a shadowy humanoid that attacks anything which casts a shadow upon it, engulfing the shadow-caster entirely."
		if("SCP-079")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-079 is to be kept in a double-locked Faraday cage. No connections to external networks are permitted. Power supply is to be strictly limited."
			data["description"] = "SCP-079 is a sentient microcomputer that has demonstrated increasing intelligence over time. It can manipulate facility systems through camera networks."

	return data

/obj/item/scp_document_reader/proc/show_document_menu(mob/user)
	if(!length(unlocked_documents))
		to_chat(user, "<span class='notice'>No documents available for your clearance level. Interact with SCPs or gain higher clearance to unlock documentation.</span>")
		return

	var/list/choices = list("Browse All Documents", "Search", "Cancel")
	var/choice = input(user, "SCP Document Terminal - Clearance Level [reader_clearance]", "Documents") as null|anything in choices
	if(!choice || choice == "Cancel")
		return

	if(choice == "Search")
		var/search = input(user, "Search for SCP:", "Document Search") as text|null
		if(!search)
			return
		for(var/scp_id in unlocked_documents)
			if(findtext(scp_id, search))
				display_document(user, scp_id)
				return
		to_chat(user, "<span class='warning'>No matching documents found.</span>")
		return

	var/list/doc_options = list()
	for(var/scp_id in unlocked_documents)
		doc_options[scp_id] = scp_id

	var/selected = input(user, "Select document to view:", "SCP Documents") as null|anything in doc_options
	if(!selected)
		return
	display_document(user, selected)

/obj/item/scp_document_reader/proc/display_document(mob/user, scp_id)
	var/list/data = unlocked_documents[scp_id]
	if(!data)
		return

	var/output = "<div style='font-family: monospace; border: 2px solid #ff4444; padding: 10px; background: #1a1a1a; color: #cccccc;'>"
	output += "<h2 style='color: #ff4444; text-align: center;'>[data["id"]]</h2>"
	output += "<h3 style='color: #ffaa00; text-align: center;'>Object Class: [data["object_class"]]</h3>"
	output += "<hr style='border-color: #ff4444;'>"
	output += "<h4 style='color: #44aaff;'>Special Containment Procedures</h4>"
	output += "<p>[data["special_containment_procedures"]]</p>"
	output += "<h4 style='color: #44aaff;'>Description</h4>"
	output += "<p>[data["description"]]</p>"
	output += "<h4 style='color: #ffaa00;'>Current Status</h4>"
	output += "<p style='color: [data["containment_status"] == "contained" ? "#44ff44" : "#ff4444"];'>[data["containment_status"]]</p>"
	output += "<hr style='border-color: #ff4444;'>"
	output += "<p style='color: #666; text-align: center;'>CLEARANCE LEVEL: [reader_clearance] | SCP Foundation</p>"
	output += "</div>"

	to_chat(user, output)

// Paper version - found document
/obj/item/paper/scp_document
	name = "SCP Document"
	desc = "A partially redacted Foundation document."
	var/scp_id = ""

/obj/item/paper/scp_document/Initialize(mapload)
	. = ..()
	if(scp_id)
		name = "Document - [scp_id]"
		info = generate_paper_document(scp_id)

/obj/item/paper/scp_document/proc/generate_paper_document(scp_id)
	switch(scp_id)
		if("SCP-173")
			return "ITEM #: SCP-173<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Item is to be kept in a locked container. When personnel must enter, no fewer than 3 may enter at any time. Maintain direct eye contact at all times.<br><br>DESCRIPTION: Moved from Site-19 to Site-53. Origin is as of yet unknown. It is constructed from concrete and rebar with traces of Krylon brand spray paint.<br><br>NOTE: Do NOT blink."
		if("SCP-049")
			return "ITEM #: SCP-049<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: SCP-049 is to be contained in a secure holding cell. No personnel are to enter without full biological protection. SCP-049 has expressed willingness to cooperate with Foundation personnel.<br><br>DESCRIPTION: SCP-049 resembles a medieval plague doctor. It claims to sense 'The Pestilence' in humans and seeks to 'cure' them through lethal surgery."
		if("SCP-096")
			return "ITEM #: SCP-096<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: No visual recording equipment permitted. All personnel must be briefed that viewing SCP-096's face is a lethal hazard.<br><br>DESCRIPTION: A tall humanoid. Viewing its face triggers an unstoppable pursuit response. There are no known barriers capable of preventing SCP-096 from reaching its target."
	return "DOCUMENT PARTIALLY REDACTED<br><br>The remainder of this document has been classified or damaged beyond readability."
