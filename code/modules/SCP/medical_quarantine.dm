// Medical Quarantine Zone
// Physical quarantine area for SCP-008/049 infection treatment with airlock, decontamination, and treatment bays

/area/scp/medical/quarantine
	name = "Medical Quarantine Zone"
	icon_state = "medbay_quar"

/area/scp/medical/quarantine/lobby
	name = "Quarantine Lobby"
	icon_state = "medbay_quar_lobby"

/area/scp/medical/quarantine/airlock
	name = "Quarantine Airlock"
	icon_state = "medbay_quar_air"

/area/scp/medical/quarantine/decontamination
	name = "Decontamination Chamber"
	icon_state = "medbay_quar_decon"

/area/scp/medical/quarantine/treatment_a
	name = "Quarantine Treatment Bay A"
	icon_state = "medbay_quar_a"

/area/scp/medical/quarantine/treatment_b
	name = "Quarantine Treatment Bay B"
	icon_state = "medbay_quar_b"

/area/scp/medical/quarantine/observation
	name = "Quarantine Observation"
	icon_state = "medbay_quar_obs"

/obj/machinery/quarantine_console
	name = "Quarantine Control Console"
	desc = "Controls the medical quarantine zone airlocks, decontamination, and containment protocols."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "rdserver"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100

	var/quarantine_active = FALSE
	var/decon_active = FALSE
	var/list/quarantined_patients = list()
	var/treatment_progress = list()
	var/infection_types = list("scp008", "scp049_pestilence")

/obj/machinery/quarantine_console/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		to_chat(H, "<span class='warning'>Requires Medical access to operate quarantine systems.</span>")
		return

	if(quarantine_active)
		var/choice = alert(H, "Quarantine is ACTIVE. Options:", "Quarantine Control", "Run Decontamination", "Lift Quarantine", "Cancel")
		if(choice == "Run Decontamination")
			run_decontamination(H)
		else if(choice == "Lift Quarantine")
			lift_quarantine(H)
		return

	var/choice = alert(H, "Quarantine is INACTIVE. Options:", "Quarantine Control", "Activate Quarantine", "Cancel")
	if(choice == "Activate Quarantine")
		activate_quarantine(H)

/obj/machinery/quarantine_console/proc/activate_quarantine(mob/user)
	quarantine_active = TRUE
	priority_announce("MEDICAL ALERT: Quarantine protocols activated in Medical Quarantine Zone. All infected personnel report to quarantine immediately.", "QUARANTINE", sound_type = ANNOUNCER_ALERT)

	for(var/obj/machinery/door/airlock/A in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/area = get_area(A)
		if(istype(area, /area/scp/medical/quarantine/airlock))
			A.lock()

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/medical/quarantine/treatment_a) || istype(A, /area/scp/medical/quarantine/treatment_b))
			quarantined_patients += H.ckey
			to_chat(H, "<span class='warning'>Quarantine protocols activated. You are now under medical quarantine. Do not leave the treatment bay.</span>")

	report_lockdown_to_round_log("Medical quarantine activated", 0)
	to_chat(user, "<span class='notice'>Quarantine protocols activated. Airlocks sealed.</span>")

/obj/machinery/quarantine_console/proc/lift_quarantine(mob/user)
	quarantine_active = FALSE
	quarantined_patients.Cut()
	treatment_progress = list()

	for(var/obj/machinery/door/airlock/A in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/area = get_area(A)
		if(istype(area, /area/scp/medical/quarantine/airlock))
			A.unlock()

	priority_announce("Medical quarantine has been lifted. All quarantine patients cleared for release.", "QUARANTINE LIFTED", sound_type = ANNOUNCER_DEFAULT)
	to_chat(user, "<span class='notice'>Quarantine lifted. Airlocks unlocked.</span>")

/obj/machinery/quarantine_console/proc/run_decontamination(mob/user)
	if(decon_active)
		to_chat(user, "<span class='warning'>Decontamination already in progress.</span>")
		return

	decon_active = TRUE
	to_chat(user, "<span class='notice'>Decontamination sequence initiated.</span>")

	var/list/patients = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/medical/quarantine/decontamination))
			patients += H

	if(!length(patients))
		to_chat(user, "<span class='warning'>No patients in decontamination chamber.</span>")
		decon_active = FALSE
		return

	for(var/mob/living/carbon/human/H in patients)
		to_chat(H, "<span class='warning'>Decontamination spray activated! The chamber fills with sterilizing agents.</span>")
		H.adjustFireLoss(5)

		if(H.sanity)
			H.sanity.adjust_sanity(-10, "decontamination")

		var/cured = FALSE
		for(var/datum/pathogen/P in H.diseases)
			if(findtext("[P.type]", "scp") || findtext("[P.type]", "008") || findtext("[P.type]", "049"))
				qdel(P)
				cured = TRUE
				break

		if(cured)
			to_chat(H, "<span class='green'>You feel the infection receding... Treatment appears effective!</span>")
		else
			to_chat(H, "<span class='warning'>The decontamination stings but doesn't seem to help your condition.</span>")

	addtimer(CALLBACK(src, .proc/finish_decontamination), 100)

/obj/machinery/quarantine_console/proc/finish_decontamination()
	decon_active = FALSE
	visible_message("<span class='notice'>[src] indicates decontamination cycle complete.</span>")

// Quarantine Scanner - Detects infections
/obj/machinery/quarantine_scanner
	name = "Quarantine Bio-Scanner"
	desc = "Scans for biological anomalies and SCP-related infections."
	icon = 'icons/obj/machines/bodyscanner.dmi'
	icon_state = "body_scanner"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	var/scan_cooldown = 0

/obj/machinery/quarantine_scanner/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(world.time < scan_cooldown)
		to_chat(user, "<span class='warning'>Scanner recharging.</span>")
		return

	var/mob/living/carbon/human/H = user
	scan_cooldown = world.time + 10 SECONDS

	var/list/infections = list()

	for(var/datum/pathogen/P in H.diseases)
		if(findtext("[P.type]", "scp") || findtext("[P.type]", "008") || findtext("[P.type]", "049"))
			infections += P.name

	if(H.reagents)
		for(var/datum/reagent/R in H.reagents.reagent_list)
			if(findtext("[R.type]", "scp") || findtext("[R.type]", "008") || findtext("[R.type]", "049"))
				infections += R.name

	var/pestilence_level = 0
	for(var/datum/pathogen/P in H.diseases)
		if(findtext("[P.type]", "049"))
			pestilence_level = 100

	to_chat(H, "<span class='boldnotice'>=== Bio-Scan Results ===</span>")
	if(length(infections))
		to_chat(H, "<span class='danger'>ANOMALOUS BIOLOGICAL AGENTS DETECTED:</span>")
		for(var/inf in infections)
			to_chat(H, "<span class='danger'>- [inf]</span>")
		to_chat(H, "<span class='warning'>QUARANTINE RECOMMENDED</span>")
	else
		to_chat(H, "<span class='green'>No anomalous biological agents detected. Subject is clear.</span>")

	if(pestilence_level > 0)
		to_chat(H, "<span class='userdanger'>PESTILENCE DETECTED - SCP-049 INFECTION CONFIRMED - IMMEDIATE QUARANTINE REQUIRED</span>")

// Treatment Bed
/obj/machinery/stasis/quarantine_bed
	name = "Quarantine Treatment Bed"
	desc = "A medical bed equipped with advanced treatment systems for anomalous infections."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/machinery/stasis/quarantine_bed/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.stat == DEAD)
		return

	var/list/options = list("Apply SCP-008 Countermeasure", "Apply SCP-049 Countermeasure", "General Treatment", "Cancel")
	var/choice = input(H, "Select treatment:", "Quarantine Bed") as null|anything in options
	if(!choice || choice == "Cancel")
		return

	switch(choice)
		if("Apply SCP-008 Countermeasure")
			H.adjustToxLoss(-20)
			H.adjustBruteLoss(-10)
			for(var/datum/pathogen/P in H.diseases)
				if(findtext("[P.type]", "008"))
					if(prob(60))
						qdel(P)
						to_chat(H, "<span class='green'>SCP-008 infection successfully treated!</span>")
					else
						to_chat(H, "<span class='warning'>Treatment partially effective. Infection weakened but not eliminated.</span>")
					break
		if("Apply SCP-049 Countermeasure")
			H.adjustToxLoss(-15)
			H.adjustBruteLoss(-10)
			for(var/datum/pathogen/P in H.diseases)
				if(findtext("[P.type]", "049"))
					if(prob(40))
						qdel(P)
						to_chat(H, "<span class='green'>Pestilence successfully treated!</span>")
					else
						to_chat(H, "<span class='warning'>Treatment partially effective. Pestilence remains.</span>")
					break
		if("General Treatment")
			H.adjustBruteLoss(-15)
			H.adjustFireLoss(-15)
			H.adjustToxLoss(-10)
			if(H.sanity)
				H.sanity.adjust_sanity(10, "quarantine_treatment")
			to_chat(H, "<span class='notice'>General treatment applied. You feel slightly better.</span>")
