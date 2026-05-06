SUBSYSTEM_DEF(scp_ambient)
	name = "SCP Ambient Events"
	wait = 30 SECONDS
	runlevels = RUNLEVEL_GAME

	var/list/active_effects = list()
	var/next_event_time = 0
	var/min_delay = 60 SECONDS
	var/max_delay = 300 SECONDS

/datum/controller/subsystem/scp_ambient/Initialize(time)
	next_event_time = world.time + rand(min_delay, max_delay)
	return ..()

/datum/controller/subsystem/scp_ambient/fire(resumed)
	if(world.time < next_event_time)
		return

	next_event_time = world.time + rand(min_delay, max_delay)
	trigger_random_ambient()

/datum/controller/subsystem/scp_ambient/proc/trigger_random_ambient()
	var/list/possible_events = list(
		/proc/scp_ambient_895_camera,
		/proc/scp_ambient_173_shifting,
		/proc/scp_ambient_049_distant_call,
		/proc/scp_ambient_096_crying,
		/proc/scp_ambient_106_corrosion,
		/proc/scp_ambient_939_echoing,
		/proc/scp_ambient_035_whisper,
		/proc/scp_ambient_513_bell,
		/proc/scp_ambient_1499_dimension_breach,
		/proc/scp_ambient_general_flicker,
	)

	var/event_type = pick(possible_events)
	call(event_type)()

/proc/scp_ambient_895_camera()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		if(prob(5))
			var/area/A = get_area(H)
			if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
				to_chat(H, "<span class='warning'>The nearby camera briefly shows a coffin where you stand...</span>")
				if(H.sanity && prob(30))
					H.sanity.adjust_sanity(-5, "scp895_camera_ambient")

/proc/scp_ambient_173_shifting()
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-173"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz))
			if(prob(8))
				to_chat(H, "<span class='notice'>You hear the faint sound of stone scraping from somewhere nearby...</span>")

/proc/scp_ambient_049_distant_call()
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-049"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
			if(prob(5))
				to_chat(H, "<span class='notice'>A distant, muffled voice echoes: <i>...I can cure this...</i></span>")

/proc/scp_ambient_096_crying()
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-096"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/hcz) || istype(A, /area/scp/lcz))
			if(prob(4))
				to_chat(H, "<span class='warning'>You hear faint sobbing from somewhere in the facility...</span>")
				if(H.sanity && prob(20))
					H.sanity.adjust_sanity(-3, "scp096_crying_ambient")

/proc/scp_ambient_106_corrosion()
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-106"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/hcz))
			if(prob(3))
				to_chat(H, "<span class='warning'>A dark, viscous substance seems to seep from the walls momentarily...</span>")

/proc/scp_ambient_939_echoing()
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-939"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/hcz))
			if(prob(4))
				var/list/phrases = list(
					"Is someone there?",
					"Help me...",
					"I can hear you...",
					"Don't leave me here...",
				)
				to_chat(H, "<span class='notice'>You hear a voice that sounds oddly familiar: <i>[pick(phrases)]</i></span>")

/proc/scp_ambient_035_whisper()
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-035"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
			if(prob(3))
				var/list/whispers = list(
					"You could just... let me out.",
					"I know what you're thinking.",
					"We could accomplish so much together.",
				)
				to_chat(H, "<span class='italics'>A whisper crosses your mind: <i>[pick(whispers)]</i></span>")
				if(H.sanity && prob(25))
					H.sanity.adjust_sanity(-3, "scp035_whisper_ambient")

/proc/scp_ambient_513_bell()
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-513"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		if(prob(2))
			to_chat(H, "<span class='warning'>You faintly hear the sound of a bell ringing in the distance...</span>")
			if(H.sanity && prob(40))
				H.sanity.adjust_sanity(-8, "scp513_bell_ambient")
				H.sanity.hallucination_level = min(H.sanity.hallucination_level + 5, H.sanity.max_hallucination)

/proc/scp_ambient_1499_dimension_breach()
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1499"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz))
			if(prob(2))
				to_chat(H, "<span class='warning'>For a split second, the air around you seems to shift and twist...</span>")
				if(H.sanity && prob(20))
					H.sanity.adjust_sanity(-5, "scp1499_dimension_ambient")

/proc/scp_ambient_general_flicker()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
			if(prob(10))
				to_chat(H, "<span class='notice'>The lights flicker momentarily.</span>")
				for(var/obj/machinery/light/L in range(5, H))
					if(prob(40))
						L.flicker(2)
