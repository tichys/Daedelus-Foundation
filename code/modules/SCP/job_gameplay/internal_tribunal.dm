#define TRIBUNAL_CASE_PENDING 0
#define TRIBUNAL_CASE_HEARING 1
#define TRIBUNAL_CASE_DELIBERATION 2
#define TRIBUNAL_CASE_GUILTY 3
#define TRIBUNAL_CASE_NOT_GUILTY 4
#define TRIBUNAL_CASE_DISMISSED 5

#define SANCTION_REPRIMAND 1
#define SANCTION_SUSPENSION 2
#define SANCTION_DEMOTION 3
#define SANCTION_TERMINATION 4
#define SANCTION_AMNESTIC 5

/datum/tribunal_case
	var/case_id = ""
	var/defendant_name = ""
	var/defendant_job = ""
	var/prosecutor_name = ""
	var/charges = ""
	var/evidence_summary = ""
	var/status = TRIBUNAL_CASE_PENDING
	var/time_filed = 0
	var/hearing_start = 0
	var/verdict = ""
	var/sanction = 0
	var/sanction_text = ""
	var/list/witnesses = list()
	var/defense_statement = ""
	var/prosecution_statement = ""
	var/deliberation_progress = 0

/datum/tribunal_case/New(defendant, prosecutor, chrgs, evidence)
	case_id = "ITD-[world.time]-[rand(100,999)]"
	time_filed = world.time
	if(istype(defendant, /mob/living/carbon/human))
		var/mob/living/carbon/human/D = defendant
		defendant_name = D.real_name
		defendant_job = D.job
	else if(istext(defendant))
		defendant_name = defendant
	if(istype(prosecutor, /mob/living/carbon/human))
		var/mob/living/carbon/human/P = prosecutor
		prosecutor_name = P.real_name
	else if(istext(prosecutor))
		prosecutor_name = prosecutor
	charges = chrgs
	evidence_summary = evidence

/datum/tribunal_case/proc/get_status_text()
	switch(status)
		if(TRIBUNAL_CASE_PENDING)
			return "Pending Hearing"
		if(TRIBUNAL_CASE_HEARING)
			return "In Hearing"
		if(TRIBUNAL_CASE_DELIBERATION)
			return "Deliberation"
		if(TRIBUNAL_CASE_GUILTY)
			return "Guilty"
		if(TRIBUNAL_CASE_NOT_GUILTY)
			return "Not Guilty"
		if(TRIBUNAL_CASE_DISMISSED)
			return "Dismissed"

/datum/tribunal_case/proc/begin_hearing()
	if(status != TRIBUNAL_CASE_PENDING)
		return FALSE
	status = TRIBUNAL_CASE_HEARING
	hearing_start = world.time
	priority_announce("Internal Tribunal hearing now in session. Case [case_id]: [defendant_name] - [charges].", "Internal Tribunal Department", null, ANNOUNCER_DEFAULT)
	return TRUE

/datum/tribunal_case/proc/enter_deliberation()
	if(status != TRIBUNAL_CASE_HEARING)
		return FALSE
	status = TRIBUNAL_CASE_DELIBERATION
	deliberation_progress = 0
	return TRUE

/datum/tribunal_case/proc/render_verdict(guilty, sanction_type, sanction_desc)
	if(status != TRIBUNAL_CASE_DELIBERATION)
		return FALSE
	if(guilty)
		status = TRIBUNAL_CASE_GUILTY
		sanction = sanction_type
		sanction_text = sanction_desc
		var/mob/M = get_mob_by_name(defendant_name)
		if(M)
			switch(sanction)
				if(SANCTION_REPRIMAND)
					to_chat(M, span_warning("The Tribunal has found you GUILTY. Sanction: Formal Reprimand."))
				if(SANCTION_SUSPENSION)
					to_chat(M, span_warning("The Tribunal has found you GUILTY. Sanction: Suspension of duties pending review."))
					apply_suspension(M)
				if(SANCTION_DEMOTION)
					to_chat(M, span_danger("The Tribunal has found you GUILTY. Sanction: Demotion. Report to HR for reassignment."))
					apply_demotion(M)
				if(SANCTION_TERMINATION)
					to_chat(M, span_userdanger("The Tribunal has found you GUILTY. Sanction: Employment Termination. Security will escort you out."))
					apply_termination(M)
				if(SANCTION_AMNESTIC)
					to_chat(M, span_userdanger("The Tribunal has found you GUILTY. Sanction: Mandatory Amnestic Treatment."))
					apply_amnestic(M)
	else
		status = TRIBUNAL_CASE_NOT_GUILTY
		var/mob/M = get_mob_by_name(defendant_name)
		if(M)
			to_chat(M, span_notice("The Tribunal has found you NOT GUILTY. Charges dismissed."))
	priority_announce("Tribunal verdict rendered for case [case_id]: [defendant_name] - [get_status_text()].", "Internal Tribunal Department", null, ANNOUNCER_DEFAULT)
	return TRUE

/datum/tribunal_case/proc/apply_suspension(mob/M)
	if(!istype(M, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card)
		return
	id_card.access = list(ACCESS_DCLASS, ACCESS_SECURITY_LVL1)

/datum/tribunal_case/proc/apply_demotion(mob/M)
	if(!istype(M, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card)
		return
	id_card.access -= ACCESS_ADMIN_LVL5
	id_card.access -= ACCESS_ADMIN_LVL4
	id_card.access -= ACCESS_ADMIN_LVL3
	id_card.access -= ACCESS_SECURITY
	id_card.access -= ACCESS_SECURITY_LVL3
	id_card.assignment = "Demoted Staff"
	if(SSraisa)
		SSraisa.record_incident(H)

/datum/tribunal_case/proc/apply_termination(mob/M)
	if(!istype(M, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(id_card)
		id_card.access = list(ACCESS_DCLASS)
		id_card.assignment = "Terminated Staff"
	if(SSfoundation_comms)
		SSfoundation_comms.create_dispatch(null, 1, "Employment terminated for [H.real_name]. Security personnel escort subject off-site.", 2)

/datum/tribunal_case/proc/apply_amnestic(mob/M)
	if(!istype(M, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = M
	if(H.sanity)
		H.sanity.adjust_sanity(-30, "tribunal_amnestic")
	to_chat(H, span_userdanger("Your memories feel hazy and distant... something has been taken from you."))
	if(SSpsychology)
		SSpsychology.record_exposure(H, "Tribunal", "amnestic_treatment", "Forced amnestic administration by tribunal order")
		SSpsychology.amnestics_administered++

/datum/tribunal_case/proc/dismiss_case()
	if(status != TRIBUNAL_CASE_PENDING && status != TRIBUNAL_CASE_HEARING)
		return FALSE
	status = TRIBUNAL_CASE_DISMISSED
	priority_announce("Tribunal case [case_id] has been dismissed.", "Internal Tribunal Department", null, ANNOUNCER_DEFAULT)
	return TRUE

SUBSYSTEM_DEF(internal_tribunal)
	name = "Internal Tribunal"
	wait = 30 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/tribunal_case/cases = list()
	var/active_case = null
	var/total_cases = 0

/datum/controller/subsystem/internal_tribunal/fire()
	if(active_case)
		var/datum/tribunal_case/C = active_case
		if(C.status == TRIBUNAL_CASE_DELIBERATION)
			C.deliberation_progress = min(100, C.deliberation_progress + 10)

/datum/controller/subsystem/internal_tribunal/proc/file_case(datum/tribunal_case/C)
	cases += C
	total_cases++
	priority_announce("New tribunal case filed: [C.defendant_name] - [C.charges]. Case ID: [C.case_id].", "Internal Tribunal Department", null, ANNOUNCER_DEFAULT)
	return C.case_id

/datum/controller/subsystem/internal_tribunal/proc/get_pending_cases()
	var/list/result = list()
	for(var/datum/tribunal_case/C in cases)
		if(C.status == TRIBUNAL_CASE_PENDING)
			result += C
	return result


