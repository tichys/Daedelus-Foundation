#ifndef SCP_TEST_PENDING
#define SCP_TEST_PENDING 0
#define SCP_TEST_APPROVED 1
#define SCP_TEST_IN_PROGRESS 2
#define SCP_TEST_COMPLETE 3
#define SCP_TEST_REJECTED 4
#endif

SUBSYSTEM_DEF(scp_testing)
	name = "SCP Testing Protocol"
	wait = 30 SECONDS
	flags = SS_NO_FIRE

	var/list/test_proposals = list()
	var/list/active_tests = list()
	var/list/completed_tests = list()
	var/list/researcher_stats = list()
	var/total_tests_conducted = 0
	var/total_research_earned = 0
	var/total_incidents_during_tests = 0
	var/total_ethics_violations_from_tests = 0

/datum/controller/subsystem/scp_testing/Initialize(start_timeofday)
	. = ..()
	auto_approve_low_risk()

/datum/controller/subsystem/scp_testing/proc/submit_test_proposal(mob/living/carbon/human/researcher, scp_id, test_type, risk_level, subject_name, description)
	if(!ishuman(researcher) || !scp_id || !test_type)
		return null
	risk_level = clamp(risk_level, 1, 5)
	var/proposal_id = "test_[world.time]_[rand(100,999)]"
	var/ethics_required = risk_level >= 3
	var/list/proposal = list(
		"proposal_id" = proposal_id,
		"researcher" = researcher.real_name,
		"researcher_ckey" = researcher.ckey,
		"scp_id" = scp_id,
		"test_type" = test_type,
		"risk_level" = risk_level,
		"subject_name" = subject_name,
		"description" = description,
		"status" = SCP_TEST_PENDING,
		"ethics_required" = ethics_required,
		"time_submitted" = world.time,
		"time_approved" = 0,
		"time_completed" = 0,
		"outcome" = "",
		"research_points" = 0,
	)
	test_proposals[proposal_id] = proposal
	var/list/stats = get_researcher_stats(researcher.ckey)
	stats["total_proposals"]++
	stats["last_active"] = world.time
	if(ethics_required)
		if(SSethics_committee)
			SSethics_committee.flag_test_for_oversight(proposal_id, scp_id, researcher.real_name, risk_level)
			SSethics_committee.active_test_oversights[proposal_id] = list(
				"test_id" = proposal_id,
				"scp_name" = scp_id,
				"researcher" = researcher.real_name,
				"risk_level" = risk_level,
				"flagged_time" = world.time,
				"approved" = FALSE,
				"denied" = FALSE,
			)
	else
		proposal["status"] = SCP_TEST_APPROVED
		proposal["time_approved"] = world.time
		to_chat(researcher, "<span class='notice'>Test proposal [proposal_id] has been auto-approved (low risk).</span>")
	return proposal_id

/datum/controller/subsystem/scp_testing/proc/approve_proposal(proposal_id, approved_by)
	if(!test_proposals[proposal_id])
		return FALSE
	var/list/proposal = test_proposals[proposal_id]
	if(proposal["status"] != SCP_TEST_PENDING)
		return FALSE
	proposal["status"] = SCP_TEST_APPROVED
	proposal["time_approved"] = world.time
	if(proposal["ethics_required"] && SSethics_committee)
		SSethics_committee.approve_test(proposal_id)
	var/researcher_ckey = proposal["researcher_ckey"]
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.ckey == researcher_ckey)
			to_chat(H, "<span class='notice'>Your test proposal [proposal_id] for [proposal["scp_id"]] has been approved by [approved_by].</span>")
			break
	return TRUE

/datum/controller/subsystem/scp_testing/proc/reject_proposal(proposal_id, reason)
	if(!test_proposals[proposal_id])
		return FALSE
	var/list/proposal = test_proposals[proposal_id]
	if(proposal["status"] != SCP_TEST_PENDING && proposal["status"] != SCP_TEST_APPROVED)
		return FALSE
	proposal["status"] = SCP_TEST_REJECTED
	proposal["outcome"] = "Rejected: [reason]"
	if(proposal["ethics_required"] && SSethics_committee)
		SSethics_committee.deny_test(proposal_id)
	var/researcher_ckey = proposal["researcher_ckey"]
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.ckey == researcher_ckey)
			to_chat(H, "<span class='warning'>Your test proposal [proposal_id] for [proposal["scp_id"]] has been rejected. Reason: [reason]</span>")
			break
	return TRUE

/datum/controller/subsystem/scp_testing/proc/start_test(proposal_id, mob/living/carbon/human/researcher)
	if(!test_proposals[proposal_id])
		return FALSE
	var/list/proposal = test_proposals[proposal_id]
	if(proposal["status"] != SCP_TEST_APPROVED)
		return FALSE
	if(!ishuman(researcher))
		return FALSE
	var/area/researcher_area = get_area(researcher)
	var/near_scp = FALSE
	if(researcher_area)
		var/area_name = lowertext(researcher_area.name)
		if(findtext(area_name, lowertext(proposal["scp_id"])) || findtext(area_name, "containment") || findtext(area_name, "research") || findtext(area_name, "lab"))
			near_scp = TRUE
	if(!near_scp)
		to_chat(researcher, "<span class='warning'>You must be near the SCP containment area or a research lab to start this test.</span>")
		return FALSE
	proposal["status"] = SCP_TEST_IN_PROGRESS
	active_tests[proposal_id] = proposal
	test_proposals -= proposal_id
	var/subject_name = proposal["subject_name"]
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.real_name == subject_name || H.name == subject_name)
			to_chat(H, "<span class='warning'>You have been selected as a test subject for [proposal["scp_id"]] testing. Report to the containment chamber immediately.</span>")
			break
	to_chat(researcher, "<span class='notice'>Test [proposal_id] on [proposal["scp_id"]] is now in progress. Proceed with the test protocol.</span>")
	return TRUE

/datum/controller/subsystem/scp_testing/proc/execute_test(proposal_id, mob/living/carbon/human/researcher)
	if(!active_tests[proposal_id])
		return FALSE
	var/list/proposal = active_tests[proposal_id]
	if(proposal["status"] != SCP_TEST_IN_PROGRESS)
		return FALSE
	if(!ishuman(researcher))
		return FALSE
	var/subject_name = proposal["subject_name"]
	var/mob/living/carbon/human/test_subject = null
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.real_name == subject_name || H.name == subject_name)
			test_subject = H
			break
	if(!test_subject || test_subject.stat == DEAD)
		proposal["status"] = SCP_TEST_COMPLETE
		proposal["time_completed"] = world.time
		proposal["outcome"] = "Test subject unavailable or deceased."
		proposal["research_points"] = 0
		completed_tests[proposal_id] = proposal
		active_tests -= proposal_id
		total_tests_conducted++
		to_chat(researcher, "<span class='warning'>Test [proposal_id] could not be completed: subject unavailable or deceased.</span>")
		return TRUE
	var/list/outcome = scp_execute_test_outcome(test_subject, proposal["scp_id"], proposal["test_type"], proposal["risk_level"])
	hook_scp_interaction(researcher, proposal["scp_id"], INTERACTION_TYPE_EXPERIMENT)
	proposal["status"] = SCP_TEST_COMPLETE
	proposal["time_completed"] = world.time
	proposal["outcome"] = outcome["message"]
	var/danger_triggered = outcome["danger_triggered"]
	var/points_earned = outcome["research_points"]
	proposal["research_points"] = points_earned
	total_tests_conducted++
	total_research_earned += points_earned
	if(SSscp_research?.manager)
		SSscp_research.manager.adjust_research_points(points_earned, "scp_test:[proposal_id]:[researcher.ckey]")
	if(danger_triggered)
		total_incidents_during_tests++
		if(SSscp_medical_response)
			SSscp_medical_response.report_scp_injury(test_subject, "test_injury", proposal["risk_level"], proposal["scp_id"])
		if(proposal["risk_level"] >= 3 && SSethics_committee)
			var/datum/ethics_violation/V = new(researcher, researcher, "Dangerous Test Incident", "Test [proposal_id] on [proposal["scp_id"]] resulted in subject injury during high-risk testing.", ETHICS_VIOLATION_SEVERE)
			SSethics_committee.file_violation(V)
			total_ethics_violations_from_tests++
		priority_announce("Test incident reported: [proposal["scp_id"]] test resulted in subject injury. Researcher: [researcher.real_name].", "TESTING ALERT", null, ANNOUNCER_ALERT)
	else
		to_chat(researcher, "<span class='notice'>Test [proposal_id] completed successfully. Research points earned: [points_earned].</span>")
	var/list/stats = get_researcher_stats(researcher.ckey)
	stats["total_completed"]++
	stats["total_research_earned"] += points_earned
	if(danger_triggered)
		stats["total_incidents"]++
	stats["last_active"] = world.time
	completed_tests[proposal_id] = proposal
	active_tests -= proposal_id
	return TRUE

/datum/controller/subsystem/scp_testing/proc/cancel_test(proposal_id)
	if(!active_tests[proposal_id])
		return FALSE
	var/list/proposal = active_tests[proposal_id]
	if(proposal["status"] != SCP_TEST_IN_PROGRESS)
		return FALSE
	proposal["status"] = SCP_TEST_PENDING
	proposal["time_approved"] = 0
	test_proposals[proposal_id] = proposal
	active_tests -= proposal_id
	var/researcher_ckey = proposal["researcher_ckey"]
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.ckey == researcher_ckey)
			to_chat(H, "<span class='warning'>Test [proposal_id] has been cancelled and returned to pending status.</span>")
			break
	return TRUE

/datum/controller/subsystem/scp_testing/proc/get_researcher_stats(ckey)
	if(!researcher_stats[ckey])
		researcher_stats[ckey] = list(
			"total_proposals" = 0,
			"total_completed" = 0,
			"total_research_earned" = 0,
			"total_incidents" = 0,
			"last_active" = world.time,
		)
	return researcher_stats[ckey]

/datum/controller/subsystem/scp_testing/proc/get_pending_proposals()
	var/list/result = list()
	for(var/id in test_proposals)
		var/list/P = test_proposals[id]
		if(P["status"] == SCP_TEST_PENDING)
			result[id] = P
	return result

/datum/controller/subsystem/scp_testing/proc/get_active_tests()
	var/list/result = list()
	for(var/id in active_tests)
		var/list/T = active_tests[id]
		if(T["status"] == SCP_TEST_IN_PROGRESS)
			result[id] = T
	return result

/datum/controller/subsystem/scp_testing/proc/get_proposals_by_researcher(ckey)
	var/list/result = list()
	for(var/id in test_proposals)
		var/list/P = test_proposals[id]
		if(P["researcher_ckey"] == ckey)
			result[id] = P
	for(var/id in active_tests)
		var/list/T = active_tests[id]
		if(T["researcher_ckey"] == ckey)
			result[id] = T
	for(var/id in completed_tests)
		var/list/C = completed_tests[id]
		if(C["researcher_ckey"] == ckey)
			result[id] = C
	return result

/datum/controller/subsystem/scp_testing/proc/auto_approve_low_risk()
	var/count = 0
	for(var/id in test_proposals)
		var/list/P = test_proposals[id]
		if(P["status"] == SCP_TEST_PENDING && P["risk_level"] < 3 && !P["ethics_required"])
			P["status"] = SCP_TEST_APPROVED
			P["time_approved"] = world.time
			count++
	return count

/datum/controller/subsystem/scp_testing/proc/check_ethics_override(proposal_id)
	if(!test_proposals[proposal_id])
		return FALSE
	var/list/proposal = test_proposals[proposal_id]
	if(!SSethics_committee)
		return FALSE
	for(var/datum/ethics_violation/V in SSethics_committee.violations)
		if(V.accused_name == proposal["researcher"] && V.status == ETHICS_STATUS_UPHELD && (world.time - V.time_reported) < 10 MINUTES)
			reject_proposal(proposal_id, "Ethics Committee override: active upheld violation against researcher within 10 minutes.")
			return TRUE
	return FALSE

/obj/item/paper/foundation/test_proposal_form
	name = "SCP Test Proposal Form"
	desc = "A Foundation form for submitting supervised SCP test proposals."

/obj/item/paper/foundation/test_proposal_form/Initialize(mapload)
	. = ..()
	setText({"<h2>SCP FOUNDATION - TEST PROPOSAL FORM</h2><hr>
<b>Proposal ID:</b> ________<br>
<b>Date:</b> ________<br><hr>
<b>Requesting Researcher:</b> ________________________<br>
<b>Clearance Level:</b> 1 / 2 / 3 / 4 / 5<br><hr>
<b>SCP Designation:</b> SCP-________<br>
<b>Test Type:</b> Observation / Physical / Stress / Audio / Biological / Cognitive / Chemical<br>
<b>Risk Level:</b> 1 (Low) / 2 / 3 / 4 / 5 (Extreme)<br><hr>
<b>D-Class Subject:</b> ________________________<br><hr>
<b>Test Description:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Safety Precautions:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Ethics Review Required:</b> Yes / No (mandatory if Risk >= 3)<br><hr>
<b>Researcher Signature:</b> ________________________ <b>Date:</b> ________<br>
<b>Supervisor Approval:</b> ________________________ <b>Date:</b> ________<br>
<b>Ethics Liaison Approval:</b> ________________________ <b>Date:</b> ________<br>"}, FALSE)

/obj/item/paper/foundation/test_result_report
	name = "SCP Test Result Report"
	desc = "A Foundation form for documenting SCP test outcomes."

/obj/item/paper/foundation/test_result_report/Initialize(mapload)
	. = ..()
	setText({"<h2>SCP FOUNDATION - TEST RESULT REPORT</h2><hr>
<b>Test ID:</b> ________<br>
<b>Date Completed:</b> ________<br><hr>
<b>Researcher:</b> ________________________<br>
<b>SCP Designation:</b> SCP-________<br>
<b>Test Type:</b> ________________________<br>
<b>Risk Level:</b> ________<br>
<b>D-Class Subject:</b> ________________________<br><hr>
<b>Test Outcome:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Danger Triggered:</b> Yes / No<br>
<b>Subject Status:</b> Intact / Injured / Deceased / Missing<br><hr>
<b>Research Points Earned:</b> ________<br>
<b>Notable Observations:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Ethics Violation Filed:</b> Yes / No<br>
<b>Follow-up Required:</b> Yes / No<br><hr>
<b>Researcher Signature:</b> ________________________ <b>Date:</b> ________<br>
<b>Supervisor Review:</b> ________________________ <b>Date:</b> ________<br>"}, FALSE)

/datum/computer_file/program/scp_testing_protocol
	filename = "scp_testing"
	filedesc = "SCP Testing Protocol"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Submit and execute SCP test proposals, track researcher productivity."
	size = 3
	tgui_id = "ScpTestingProtocol"
	program_icon = "flask"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SCIENCE)

/datum/computer_file/program/scp_testing_protocol/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	if(!SSscp_testing)
		return data
	data["test_proposals"] = SSscp_testing.test_proposals
	data["active_tests"] = SSscp_testing.active_tests
	var/list/recent_completed = list()
	var/completed_ids = list()
	for(var/id in SSscp_testing.completed_tests)
		completed_ids += id
	var/len = length(completed_ids)
	var/start_idx = max(1, len - 19)
	for(var/i in start_idx to len)
		var/cid = completed_ids[i]
		recent_completed[cid] = SSscp_testing.completed_tests[cid]
	data["completed_tests"] = recent_completed
	data["researcher_stats"] = SSscp_testing.get_researcher_stats(H.ckey)
	data["total_tests_conducted"] = SSscp_testing.total_tests_conducted
	data["total_research_earned"] = SSscp_testing.total_research_earned
	data["total_incidents_during_tests"] = SSscp_testing.total_incidents_during_tests
	var/pending_count = 0
	for(var/id in SSscp_testing.test_proposals)
		var/list/P = SSscp_testing.test_proposals[id]
		if(P["status"] == SCP_TEST_PENDING)
			pending_count++
	data["pending_count"] = pending_count
	return data

/datum/computer_file/program/scp_testing_protocol/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		return
	if(!SSscp_testing)
		return
	switch(action)
		if("submit_proposal")
			var/scp_id = params["scp_id"] || ""
			var/test_type = params["test_type"] || "observation"
			var/risk_level = text2num(params["risk_level"]) || 1
			var/subject_name = params["subject_name"] || ""
			var/description = params["description"] || ""
			if(!scp_id)
				return
			SSscp_testing.submit_test_proposal(H, scp_id, test_type, risk_level, subject_name, description)
			. = TRUE
		if("approve_proposal")
			var/proposal_id = params["proposal_id"]
			if(!proposal_id)
				return
			SSscp_testing.approve_proposal(proposal_id, H.real_name)
			. = TRUE
		if("reject_proposal")
			var/proposal_id = params["proposal_id"]
			var/reason = params["reason"] || "No reason provided"
			if(!proposal_id)
				return
			SSscp_testing.reject_proposal(proposal_id, reason)
			. = TRUE
		if("start_test")
			var/proposal_id = params["proposal_id"]
			if(!proposal_id)
				return
			SSscp_testing.start_test(proposal_id, H)
			. = TRUE
		if("execute_test")
			var/proposal_id = params["proposal_id"]
			if(!proposal_id)
				return
			SSscp_testing.execute_test(proposal_id, H)
			. = TRUE
		if("cancel_test")
			var/proposal_id = params["proposal_id"]
			if(!proposal_id)
				return
			SSscp_testing.cancel_test(proposal_id)
			. = TRUE
