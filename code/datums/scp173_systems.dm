// SCP-173 System Datums
// Containment, Breach, and Research Systems

// ============================================================================
// CONTAINMENT SYSTEM
// ============================================================================

/datum/containment_system
	var/mob/living/carbon/scp/scp173/owner
	var/structural_integrity = 100
	var/observation_protocol = 100
	var/security_measures = 100
	var/environmental_controls = 100
	var/containment_state = "secure"
	var/degradation_rate = 0
	var/repair_progress = 0
	var/last_maintenance = 0
	var/maintenance_interval = 30 MINUTES

/datum/containment_system/New(mob/living/carbon/scp/scp173/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/containment_system/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/containment_system/process()
	if(world.time >= last_maintenance + maintenance_interval)
		perform_maintenance()
		last_maintenance = world.time

/datum/containment_system/proc/calculate_total_integrity()
	var/total = (structural_integrity * 0.4) + (observation_protocol * 0.25) + (security_measures * 0.25) + (environmental_controls * 0.1)
	return max(0, min(100, total))

/datum/containment_system/proc/update_containment_state()
	var/total_integrity = calculate_total_integrity()

	if(total_integrity >= 90)
		containment_state = "secure"
	else if(total_integrity >= 70)
		containment_state = "stable"
	else if(total_integrity >= 50)
		containment_state = "degraded"
	else if(total_integrity >= 25)
		containment_state = "critical"
	else if(total_integrity >= 1)
		containment_state = "failing"
	else
		containment_state = "breached"

/datum/containment_system/proc/process_degradation()
	// Natural degradation over time
	degradation_rate = 0.1  // 0.1% per minute

	// Apply degradation
	structural_integrity = max(0, structural_integrity - degradation_rate)
	observation_protocol = max(0, observation_protocol - degradation_rate * 0.5)
	security_measures = max(0, security_measures - degradation_rate * 0.3)
	environmental_controls = max(0, environmental_controls - degradation_rate * 0.2)

	update_containment_state()

/datum/containment_system/proc/handle_maintenance()
	// Repair progress
	if(repair_progress > 0)
		repair_progress += 1
		if(repair_progress >= 100)
			complete_repair()

/datum/containment_system/proc/perform_maintenance()
	// Basic maintenance prevents degradation
	degradation_rate = max(0, degradation_rate - 0.05)

	// Small repairs
	structural_integrity = min(100, structural_integrity + 1)
	observation_protocol = min(100, observation_protocol + 0.5)
	security_measures = min(100, security_measures + 0.3)
	environmental_controls = min(100, environmental_controls + 0.2)

/datum/containment_system/proc/complete_repair()
	repair_progress = 0
	structural_integrity = min(100, structural_integrity + 10)
	update_containment_state()

/datum/containment_system/proc/check_containment()
	if(containment_state == "breached")
		return

	// Check if we're still in containment area
	if(owner.containment_area && get_area(owner) != owner.containment_area)
		breach_containment()

/datum/containment_system/proc/check_specific_containment()
	// Check observation-based containment
	if(owner.observation_system && !owner.observation_system.is_being_observed())
		reduce_containment_integrity(1)

		// Chance to breach if integrity is very low
		if(calculate_total_integrity() < 20 && prob(5))
			attempt_containment_breach()

/datum/containment_system/proc/reduce_containment_integrity(amount)
	structural_integrity = max(0, structural_integrity - amount)
	update_containment_state()

/datum/containment_system/proc/attempt_containment_breach()
	if(owner.breach_system)
		owner.breach_system.trigger_breach_sequence()

/datum/containment_system/proc/breach_containment()
	containment_state = "breached"
	if(owner.breach_system)
		owner.breach_system.trigger_breach_sequence()

// ============================================================================
// BREACH SYSTEM
// ============================================================================

/datum/breach_system
	var/mob/living/carbon/scp/scp173/owner
	var/breach_phase = "none"  // none, initial, active, full
	var/escalation_timer = 0
	var/threat_level = 0
	var/list/response_teams_deployed = list()
	var/observation_failure_threshold = 5 SECONDS
	var/integrity_critical_threshold = 25
	var/system_failure_count = 0
	var/breach_start_time = 0

/datum/breach_system/New(mob/living/carbon/scp/scp173/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/breach_system/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/breach_system/process()
	if(breach_phase != "none")
		escalation_timer++
		check_escalation_conditions()

/datum/breach_system/proc/evaluate_breach_conditions()
	// Check observation failure
	if(owner.observation_system && !owner.observation_system.is_being_observed())
		if(world.time - owner.observation_system.last_update > observation_failure_threshold)
			return TRUE

	// Check containment integrity
	if(owner.containment_system && owner.containment_system.calculate_total_integrity() < integrity_critical_threshold)
		return TRUE

	// Check system failures
	if(system_failure_count >= 3)
		return TRUE

	return FALSE

/datum/breach_system/proc/trigger_breach_sequence()
	if(breach_phase != "none")
		return  // Already breached

	breach_phase = "initial"
	breach_start_time = world.time
	escalation_timer = 0
	threat_level = 1

	// Initial breach effects
	owner.breach_count++
	owner.last_breach_time = world.time

	// Notify facility
	notify_facility_breach()

	// Apply initial breach bonuses to SCP-173
	apply_breach_effects()

/datum/breach_system/proc/check_escalation_conditions()
	if(breach_phase == "initial" && escalation_timer >= 300)  // 5 minutes
		escalate_breach_phase()
	else if(breach_phase == "active" && escalation_timer >= 600)  // 10 minutes
		escalate_breach_phase()

/datum/breach_system/proc/escalate_breach_phase()
	if(breach_phase == "initial")
		breach_phase = "active"
		threat_level = 2
		escalation_timer = 0
		apply_active_breach_effects()
	else if(breach_phase == "active")
		breach_phase = "full"
		threat_level = 3
		escalation_timer = 0
		apply_full_breach_effects()

/datum/breach_system/proc/apply_breach_effects()
	// Phase 1 effects
	owner.move_cooldown_time = max(0.5 SECONDS, owner.move_cooldown_time * 0.8)  // 20% faster movement
	owner.stealth_mode = FALSE  // Disable stealth in breach
	owner.aggressive_mode = TRUE  // Enable aggressive mode

/datum/breach_system/proc/apply_active_breach_effects()
	// Phase 2 effects
	owner.move_cooldown_time = max(0.3 SECONDS, owner.move_cooldown_time * 0.6)  // 40% faster movement
	owner.max_scp_health += 50  // Health bonus
	owner.scp_health = min(owner.scp_health + 50, owner.max_scp_health)

/datum/breach_system/proc/apply_full_breach_effects()
	// Phase 3 effects
	owner.move_cooldown_time = max(0.2 SECONDS, owner.move_cooldown_time * 0.4)  // 60% faster movement
	owner.max_scp_health += 100  // Major health bonus
	owner.scp_health = min(owner.scp_health + 100, owner.max_scp_health)

/datum/breach_system/proc/notify_facility_breach()
	// Send facility-wide alert
	for(var/mob/living/carbon/human/H in world)
		if(H.client)
			to_chat(H, "<span class='danger'>🚨 CONTAINMENT BREACH ALERT: SCP-173 has breached containment! 🚨</span>")
			playsound(H, 'sound/effects/alert.ogg', 50, 1)

/datum/breach_system/proc/coordinate_response()
	// Deploy response teams
	if(breach_phase != "none")
		// This would integrate with security team systems
		// For now, just track that response is active
		response_teams_deployed["security"] = TRUE

// ============================================================================
// RESEARCH INTEGRATION WITH EXISTING RESEARCH PERSISTENCE SYSTEM
// ============================================================================

// SCP-173 Research Integration Datum
/datum/scp173_research_integration
	var/mob/living/carbon/scp/scp173/owner
	var/list/active_research_projects = list() // Links to research_persistence projects
	var/behavioral_knowledge = 0
	var/containment_expertise = 0
	var/anomalous_understanding = 0
	var/last_research_update = 0
	var/research_interval = 60 SECONDS

/datum/scp173_research_integration/New(mob/living/carbon/scp/scp173/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/scp173_research_integration/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/scp173_research_integration/process()
	if(world.time >= last_research_update + research_interval)
		process_scp173_research()
		last_research_update = world.time

/datum/scp173_research_integration/proc/process_scp173_research()
	// Check for completed research projects related to SCP-173
	if(SSresearch_persistence && SSresearch_persistence.manager)
		for(var/project_id in active_research_projects)
			var/datum/research_persistence_project/project = SSresearch_persistence.manager.research_projects[project_id]
			if(project && project.status == "COMPLETED")
				complete_scp173_research_project(project)

/datum/scp173_research_integration/proc/start_scp173_research_project(project_name, project_description, research_field, lead_researcher, budget = 1000, priority = 1)
	if(!SSresearch_persistence || !SSresearch_persistence.manager)
		return null

	var/datum/research_persistence_project/project = SSresearch_persistence.manager.add_research_project(
		project_name,
		project_description,
		research_field,
		lead_researcher,
		budget,
		priority
	)

	if(project)
		active_research_projects[project.project_id] = project
		return project
	return null

/datum/scp173_research_integration/proc/complete_scp173_research_project(datum/research_persistence_project/project)
	if(!project)
		return

	// Apply research benefits based on project type
	switch(project.research_field)
		if("SCP-173_BEHAVIORAL")
			behavioral_knowledge += 10
			apply_behavioral_research_benefits()
		if("SCP-173_CONTAINMENT")
			containment_expertise += 10
			apply_containment_research_benefits()
		if("SCP-173_ANOMALOUS")
			anomalous_understanding += 10
			apply_anomalous_research_benefits()

	// Remove from active projects
	active_research_projects -= project.project_id

	// Add scientific discovery to research persistence
	if(SSresearch_persistence && SSresearch_persistence.manager)
		SSresearch_persistence.manager.add_scientific_discovery(
			"SCP-173 Research: [project.project_name]",
			"Research findings related to SCP-173: [project.project_description]",
			"SCP_RESEARCH",
			"SCP-173",
			project.lead_researcher,
			2 // Medium significance
		)

/datum/scp173_research_integration/proc/apply_behavioral_research_benefits()
	// Improve observer effectiveness
	for(var/mob/living/carbon/human/H in world)
		if(H.observer_quality)
			H.observer_quality.training_level = min(1.4, H.observer_quality.training_level + 0.01)

/datum/scp173_research_integration/proc/apply_containment_research_benefits()
	// Improve containment systems
	if(owner.containment_system)
		owner.containment_system.degradation_rate = max(0, owner.containment_system.degradation_rate - 0.001)

/datum/scp173_research_integration/proc/apply_anomalous_research_benefits()
	// Unlock new technologies or abilities
	if(anomalous_understanding >= 50)
		unlock_experimental_technologies()

/datum/scp173_research_integration/proc/unlock_experimental_technologies()
	// Unlock experimental technologies for SCP-173
	// This could include new abilities, equipment, or containment methods
	return

/datum/scp173_research_integration/proc/get_research_status()
	var/list/status = list()
	status["behavioral_knowledge"] = behavioral_knowledge
	status["containment_expertise"] = containment_expertise
	status["anomalous_understanding"] = anomalous_understanding
	status["active_projects"] = active_research_projects.len
	return status

// ============================================================================
// END OF SCP-173 SYSTEM DATUMS
// ============================================================================
