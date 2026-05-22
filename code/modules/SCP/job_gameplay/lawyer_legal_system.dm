/datum/legal_case
	var/case_id = ""
	var/defendant_name = ""
	var	defendant_job = ""
	var	plaintiff_name = ""
	var	plaintiff_job = ""
	var	case_type = ""
	var	charges = ""
	var	defense = ""
	var	status = "pending"
	var	time_filed = 0
	var	verdict = ""
	var	verdict_notes = ""
	var/sentencing = ""

/datum/legal_case/New(defendant, plaintiff, ctype, chrgs)
	case_id = "LAW-[world.time]-[rand(100,999)]"
	time_filed = world.time
	if(istype(defendant, /mob/living/carbon/human))
		var/mob/living/carbon/human/D = defendant
		defendant_name = D.real_name
		defendant_job = D.job
	if(istype(plaintiff, /mob/living/carbon/human))
		var/mob/living/carbon/human/P = plaintiff
		plaintiff_name = P.real_name
		plaintiff_job = P.job
	case_type = ctype
	charges = chrgs

/datum/legal_case/proc/submit_defense(defense_text)
	defense = defense_text
	status = "defense_submitted"

/datum/legal_case/proc/render_verdict(verdict_text, notes, sentence)
	verdict = verdict_text
	verdict_notes = notes
	sentencing = sentence
	status = "resolved"
	if(verdict_text == "guilty" && SSinternal_tribunal)
		var/datum/tribunal_case/TC = new(defendant_name, plaintiff_name, charges, "Auto-generated from legal case [case_id]")
		SSinternal_tribunal.file_case(TC)
	if(SSraisa)
		var/datum/intel_report/R = new(null, "legal", defendant_name, defendant_job, "CONFIDENTIAL", "Legal case [case_id] resolved. Verdict: [verdict_text]. Charges: [charges].", "Legal record filed.")
		SSraisa.file_report(R)

SUBSYSTEM_DEF(legal_system)
	name = "Legal System"
	wait = 30 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/legal_case/cases = list()
	var/total_cases = 0
	var/resolved_cases = 0

/datum/controller/subsystem/legal_system/proc/file_case(datum/legal_case/C)
	cases += C
	total_cases++
	return C.case_id

/datum/controller/subsystem/legal_system/proc/submit_defense(case_id, defense_text)
	for(var/datum/legal_case/C in cases)
		if(C.case_id == case_id)
			C.submit_defense(defense_text)
			return TRUE
	return FALSE

/datum/controller/subsystem/legal_system/proc/render_verdict(case_id, verdict, notes, sentence)
	for(var/datum/legal_case/C in cases)
		if(C.case_id == case_id)
			C.render_verdict(verdict, notes, sentence)
			resolved_cases++
			return TRUE
	return FALSE


