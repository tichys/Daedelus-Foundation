// Security Persistence System
// Tracks security incidents, personnel records, clearance levels, and security protocols

SUBSYSTEM_DEF(security_persistence)
	name = "Security Persistence"
	wait = 600 // 1 minute
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_INPUT

	var/datum/security_persistence_manager/manager

/datum/security_persistence_manager
	var/list/security_records = list() // ckey -> security_record
	var/list/security_incidents = list() // incident_id -> security_incident
	var/list/clearance_requests = list() // request_id -> clearance_request
	var/list/security_protocols = list() // protocol_id -> security_protocol
	var/list/access_logs = list() // log_id -> access_log
	var/list/security_statistics = list() // stat_name -> value

	// Global security metrics
	var/total_security_incidents = 0
	var/active_threats = 0
	var/security_clearance_level = 1
	var/security_budget = 2000000
	var/security_staff_count = 0
	var/containment_breaches = 0
	var/unauthorized_access_attempts = 0

/datum/security_record
	var/ckey
	var/real_name
	var/security_clearance = 1
	var/security_rating = 100
	var/list/security_incidents = list()
	var/list/access_logs = list()
	var/list/clearance_history = list()
	var/list/disciplinary_actions = list()
	var/security_status = "ACTIVE" // ACTIVE, SUSPENDED, TERMINATED, CLEARED
	var/last_updated

	New(var/ckey, var/real_name)
		src.ckey = ckey
		src.real_name = real_name
		src.last_updated = world.time

/datum/security_incident
	var/incident_id
	var/incident_type
	var/incident_description
	var/severity = 1
	var/location
	var/involved_personnel = list()
	var/witnesses = list()
	var/timestamp
	var/resolved = FALSE
	var/resolution_notes = ""
	var/security_rating_impact = 0

	New(var/incident_id, var/incident_type, var/incident_description, var/severity)
		src.incident_id = incident_id
		src.incident_type = incident_type
		src.incident_description = incident_description
		src.severity = severity
		src.timestamp = world.time

/datum/clearance_request
	var/request_id
	var/applicant_ckey
	var/requested_clearance
	var/reason
	var/approver_ckey
	var/status = "PENDING" // PENDING, APPROVED, DENIED
	var/timestamp
	var/approval_notes = ""

	New(var/request_id, var/applicant_ckey, var/requested_clearance, var/reason)
		src.request_id = request_id
		src.applicant_ckey = applicant_ckey
		src.requested_clearance = requested_clearance
		src.reason = reason
		src.timestamp = world.time

/datum/security_protocol
	var/protocol_id
	var/protocol_name
	var/protocol_description
	var/clearance_required = 1
	var/activation_conditions = list()
	var/protocol_steps = list()
	var/status = "ACTIVE" // ACTIVE, SUSPENDED, DEPRECATED
	var/effectiveness_rating = 100
	var/last_updated

	New(var/protocol_id, var/protocol_name, var/protocol_description)
		src.protocol_id = protocol_id
		src.protocol_name = protocol_name
		src.protocol_description = protocol_description
		src.last_updated = world.time

/datum/access_log
	var/log_id
	var/ckey
	var/access_point
	var/access_granted
	var/timestamp
	var/clearance_level
	var/reason

	New(var/log_id, var/ckey, var/access_point, var/access_granted, var/clearance_level)
		src.log_id = log_id
		src.ckey = ckey
		src.access_point = access_point
		src.access_granted = access_granted
		src.clearance_level = clearance_level
		src.timestamp = world.time

// Security Persistence Manager Methods
/datum/security_persistence_manager/proc/process_security()
	// Update security statistics
	update_security_statistics()

	// Process active incidents
	process_incidents()

	// Update security protocols
	update_security_protocols()

	// Save data periodically
	if(world.time % 3000 == 0) // Every 5 minutes
		save_security_data()

/datum/security_persistence_manager/proc/add_security_record(var/ckey, var/real_name)
	if(!(ckey in security_records))
		security_records[ckey] = new /datum/security_record(ckey, real_name)

		// Sync with existing security records system
		sync_with_security_records(ckey, real_name)
		return security_records[ckey]
	return security_records[ckey]

/datum/security_persistence_manager/proc/add_security_incident(var/incident_type, var/incident_description, var/severity = 1, var/location = "", var/involved_personnel = list())
	var/incident_id = "incident_[world.time]"
	var/datum/security_incident/incident = new /datum/security_incident(incident_id, incident_type, incident_description, severity)
	incident.location = location
	incident.involved_personnel = involved_personnel

	security_incidents[incident_id] = incident
	total_security_incidents++

	// Update involved personnel records
	for(var/ckey in involved_personnel)
		var/datum/security_record/record = security_records[ckey]
		if(record)
			record.security_incidents += incident
			record.security_rating = max(0, record.security_rating - severity * 5)
			record.last_updated = world.time

	// Check for containment breach
	if(incident_type == "CONTAINMENT_BREACH")
		containment_breaches++
		active_threats++

	return incident

// Old procedure removed - using updated version below

/datum/security_persistence_manager/proc/add_access_log(var/ckey, var/access_point, var/access_granted, var/clearance_level, var/reason = "")
	var/log_id = "access_[world.time]_[ckey]"
	var/datum/access_log/log = new /datum/access_log(log_id, ckey, access_point, access_granted, clearance_level)
	log.reason = reason

	access_logs[log_id] = log

	// Add to personnel record
	var/datum/security_record/record = security_records[ckey]
	if(record)
		record.access_logs += log
		record.last_updated = world.time

	// Track unauthorized access attempts
	if(!access_granted)
		unauthorized_access_attempts++

	return log

// Old procedure removed - using updated version below

/datum/security_persistence_manager/proc/update_security_statistics()
	security_statistics["total_personnel"] = security_records.len
	security_statistics["total_incidents"] = total_security_incidents
	security_statistics["active_threats"] = active_threats
	security_statistics["containment_breaches"] = containment_breaches
	security_statistics["unauthorized_access"] = unauthorized_access_attempts
	security_statistics["security_budget"] = security_budget
	security_statistics["security_staff"] = security_staff_count
	security_statistics["clearance_level"] = security_clearance_level

/datum/security_persistence_manager/proc/process_incidents()
	for(var/incident_id in security_incidents)
		var/datum/security_incident/incident = security_incidents[incident_id]
		if(!incident.resolved)
			// Simulate incident resolution
			if(prob(15)) // 15% chance to resolve
				incident.resolved = TRUE
				incident.resolution_notes = "Automatically resolved by security system"

				// Reduce active threats if it was a containment breach
				if(incident.incident_type == "CONTAINMENT_BREACH")
					active_threats = max(0, active_threats - 1)

/datum/security_persistence_manager/proc/update_security_protocols()
	for(var/protocol_id in security_protocols)
		var/datum/security_protocol/protocol = security_protocols[protocol_id]
		if(protocol.status == "ACTIVE")
			// Simulate protocol effectiveness changes
			if(prob(10)) // 10% chance to change effectiveness
				protocol.effectiveness_rating = max(0, min(100, protocol.effectiveness_rating + rand(-5, 5)))

/datum/security_persistence_manager/proc/save_security_data()
	var/list/data = list()

	// Save security records
	data["security_records"] = list()
	for(var/ckey in security_records)
		var/datum/security_record/record = security_records[ckey]
		data["security_records"][ckey] = list(
			"real_name" = record.real_name,
			"security_clearance" = record.security_clearance,
			"security_rating" = record.security_rating,
			"security_status" = record.security_status,
			"clearance_history" = record.clearance_history,
			"disciplinary_actions" = record.disciplinary_actions,
			"last_updated" = record.last_updated
		)

	// Save security incidents
	data["security_incidents"] = list()
	for(var/incident_id in security_incidents)
		var/datum/security_incident/incident = security_incidents[incident_id]
		data["security_incidents"][incident_id] = list(
			"incident_type" = incident.incident_type,
			"incident_description" = incident.incident_description,
			"severity" = incident.severity,
			"location" = incident.location,
			"involved_personnel" = incident.involved_personnel,
			"witnesses" = incident.witnesses,
			"timestamp" = incident.timestamp,
			"resolved" = incident.resolved,
			"resolution_notes" = incident.resolution_notes,
			"security_rating_impact" = incident.security_rating_impact
		)

	// Save clearance requests
	data["clearance_requests"] = list()
	for(var/request_id in clearance_requests)
		var/datum/clearance_request/request = clearance_requests[request_id]
		data["clearance_requests"][request_id] = list(
			"applicant_ckey" = request.applicant_ckey,
			"requested_clearance" = request.requested_clearance,
			"reason" = request.reason,
			"approver_ckey" = request.approver_ckey,
			"status" = request.status,
			"timestamp" = request.timestamp,
			"approval_notes" = request.approval_notes
		)

	// Save security protocols
	data["security_protocols"] = list()
	for(var/protocol_id in security_protocols)
		var/datum/security_protocol/protocol = security_protocols[protocol_id]
		data["security_protocols"][protocol_id] = list(
			"protocol_name" = protocol.protocol_name,
			"protocol_description" = protocol.protocol_description,
			"clearance_required" = protocol.clearance_required,
			"activation_conditions" = protocol.activation_conditions,
			"protocol_steps" = protocol.protocol_steps,
			"status" = protocol.status,
			"effectiveness_rating" = protocol.effectiveness_rating,
			"last_updated" = protocol.last_updated
		)

	// Save access logs
	data["access_logs"] = list()
	for(var/log_id in access_logs)
		var/datum/access_log/log = access_logs[log_id]
		data["access_logs"][log_id] = list(
			"ckey" = log.ckey,
			"access_point" = log.access_point,
			"access_granted" = log.access_granted,
			"timestamp" = log.timestamp,
			"clearance_level" = log.clearance_level,
			"reason" = log.reason
		)

	// Save global statistics
	data["global_stats"] = list(
		"total_security_incidents" = total_security_incidents,
		"active_threats" = active_threats,
		"security_clearance_level" = security_clearance_level,
		"security_budget" = security_budget,
		"security_staff_count" = security_staff_count,
		"containment_breaches" = containment_breaches,
		"unauthorized_access_attempts" = unauthorized_access_attempts
	)

	// Write to JSON file
	var/json_data = json_encode(data)
	var/savefile/S = new /savefile("data/security_persistence.json")
	S["data"] << json_data

/datum/security_persistence_manager/proc/load_security_data()
	var/savefile/S = new /savefile("data/security_persistence.json")
	if(!S["data"])
		return

	var/json_data
	S["data"] >> json_data

	var/list/data = json_decode(json_data)
	if(!data)
		return

	// Load security records
	if(data["security_records"])
		for(var/ckey in data["security_records"])
			var/list/record_data = data["security_records"][ckey]
			var/datum/security_record/record = new /datum/security_record(ckey, record_data["real_name"])
			record.security_clearance = record_data["security_clearance"]
			record.security_rating = record_data["security_rating"]
			record.security_status = record_data["security_status"]
			record.clearance_history = record_data["clearance_history"]
			record.disciplinary_actions = record_data["disciplinary_actions"]
			record.last_updated = record_data["last_updated"]
			security_records[ckey] = record

	// Load security incidents
	if(data["security_incidents"])
		for(var/incident_id in data["security_incidents"])
			var/list/incident_data = data["security_incidents"][incident_id]
			var/datum/security_incident/incident = new /datum/security_incident(incident_id, incident_data["incident_type"], incident_data["incident_description"], incident_data["severity"])
			incident.location = incident_data["location"]
			incident.involved_personnel = incident_data["involved_personnel"]
			incident.witnesses = incident_data["witnesses"]
			incident.timestamp = incident_data["timestamp"]
			incident.resolved = incident_data["resolved"]
			incident.resolution_notes = incident_data["resolution_notes"]
			incident.security_rating_impact = incident_data["security_rating_impact"]
			security_incidents[incident_id] = incident
			if(!incident.resolved && incident.incident_type == "CONTAINMENT_BREACH")
				active_threats++

	// Load clearance requests
	if(data["clearance_requests"])
		for(var/request_id in data["clearance_requests"])
			var/list/request_data = data["clearance_requests"][request_id]
			var/datum/clearance_request/request = new /datum/clearance_request(request_id, request_data["applicant_ckey"], request_data["requested_clearance"], request_data["reason"])
			request.approver_ckey = request_data["approver_ckey"]
			request.status = request_data["status"]
			request.timestamp = request_data["timestamp"]
			request.approval_notes = request_data["approval_notes"]
			clearance_requests[request_id] = request

	// Load security protocols
	if(data["security_protocols"])
		for(var/protocol_id in data["security_protocols"])
			var/list/protocol_data = data["security_protocols"][protocol_id]
			var/datum/security_protocol/protocol = new /datum/security_protocol(protocol_id, protocol_data["protocol_name"], protocol_data["protocol_description"])
			protocol.clearance_required = protocol_data["clearance_required"]
			protocol.activation_conditions = protocol_data["activation_conditions"]
			protocol.protocol_steps = protocol_data["protocol_steps"]
			protocol.status = protocol_data["status"]
			protocol.effectiveness_rating = protocol_data["effectiveness_rating"]
			protocol.last_updated = protocol_data["last_updated"]
			security_protocols[protocol_id] = protocol

	// Load access logs
	if(data["access_logs"])
		for(var/log_id in data["access_logs"])
			var/list/log_data = data["access_logs"][log_id]
			var/datum/access_log/log = new /datum/access_log(log_id, log_data["ckey"], log_data["access_point"], log_data["access_granted"], log_data["clearance_level"])
			log.timestamp = log_data["timestamp"]
			log.reason = log_data["reason"]
			access_logs[log_id] = log

	// Load global statistics
	if(data["global_stats"])
		var/list/stats = data["global_stats"]
		total_security_incidents = stats["total_security_incidents"]
		security_clearance_level = stats["security_clearance_level"]
		security_budget = stats["security_budget"]
		security_staff_count = stats["security_staff_count"]
		containment_breaches = stats["containment_breaches"]
		unauthorized_access_attempts = stats["unauthorized_access_attempts"]

// Subsystem initialization
/datum/controller/subsystem/security_persistence/Initialize()
	manager = new /datum/security_persistence_manager()

	// Skip datacore loading entirely - force completely empty data
	world.log << "Skipping datacore loading - forcing completely empty security data"

	// Clear any existing persistent storage to ensure only real data is used
	world.log << "Clearing persistent storage to ensure only real data..."
	manager.clear_persistent_storage()

	// Force empty data - no persistent storage loading at all
	world.log << "Forcing empty security data - no persistent storage loading"
	manager.security_records.Cut()
	manager.security_incidents.Cut()
	manager.access_logs.Cut()
	manager.security_protocols.Cut()
	manager.clearance_requests.Cut()
	manager.active_threats = 0
	manager.containment_breaches = 0
	manager.unauthorized_access_attempts = 0

	return ..()

/datum/controller/subsystem/security_persistence/fire()
	if(manager)
		manager.process_security()

// Sync with existing security records system
/datum/security_persistence_manager/proc/sync_with_security_records(var/ckey, var/real_name)
	// Check if security record already exists in datacore
	var/datum/data/record/security/existing_record = SSdatacore.find_record("name", real_name, DATACORE_RECORDS_SECURITY)
	if(!existing_record)
		// Create new security record in datacore if it doesn't exist
		var/datum/data/record/security/new_record = new /datum/data/record/security()
		new_record.fields[DATACORE_NAME] = real_name
		new_record.fields[DATACORE_CRIMINAL_STATUS] = CRIMINAL_NONE
		new_record.fields[DATACORE_CITATIONS] = list()
		new_record.fields[DATACORE_CRIMES] = list()
		new_record.fields[DATACORE_NOTES] = "No security notes."

		// Add to datacore
		SSdatacore.library[DATACORE_RECORDS_SECURITY].inject_record(new_record)
	else
		// Update existing record if needed
		existing_record.fields[DATACORE_CRIMINAL_STATUS] = CRIMINAL_NONE
		existing_record.fields[DATACORE_NOTES] = "No security notes."

// Load all existing security records from SSdatacore
/datum/security_persistence_manager/proc/load_existing_security_records()
	if(!SSdatacore)
		return

	world.log << "Security: Loading existing security records from datacore..."

	// Load from general records (station records)
	for(var/datum/data/record/general_record in SSdatacore.get_records(DATACORE_RECORDS_STATION))
		if(general_record.fields[DATACORE_NAME])
			var/ckey = ckey(general_record.fields[DATACORE_NAME])
			if(!(ckey in security_records))
				var/datum/security_record/security_record = new /datum/security_record(ckey, general_record.fields[DATACORE_NAME])
				security_record.security_clearance = 1 // Default clearance
				security_record.security_rating = 100
				security_record.last_updated = world.time
				security_records[ckey] = security_record

				world.log << "Security: Loaded general record for [general_record.fields[DATACORE_NAME]]"

	// Load from security records (detailed security data)
	for(var/datum/data/record/security_record in SSdatacore.get_records(DATACORE_RECORDS_SECURITY))
		if(security_record.fields[DATACORE_NAME])
			var/ckey = ckey(security_record.fields[DATACORE_NAME])
			var/datum/security_record/existing_record = security_records[ckey]

			if(existing_record)
				// Update criminal status
				if(security_record.fields[DATACORE_CRIMINAL_STATUS])
					existing_record.security_status = security_record.fields[DATACORE_CRIMINAL_STATUS]

				// Parse security notes for incidents
				if(security_record.fields[DATACORE_NOTES] && security_record.fields[DATACORE_NOTES] != "No notes.")
					var/notes = security_record.fields[DATACORE_NOTES]
					if(findtext(notes, "incident") || findtext(notes, "breach") || findtext(notes, "violation"))
						existing_record.security_rating = max(50, existing_record.security_rating - 10)

				existing_record.last_updated = world.time

				world.log << "Security: Updated security record for [security_record.fields[DATACORE_NAME]] (Status: [existing_record.security_status])"
			else
				// Create new record if general record doesn't exist
				var/datum/security_record/new_record = new /datum/security_record(ckey, security_record.fields[DATACORE_NAME])
				if(security_record.fields[DATACORE_CRIMINAL_STATUS])
					new_record.security_status = security_record.fields[DATACORE_CRIMINAL_STATUS]
				security_records[ckey] = new_record

				world.log << "Security: Created new security record for [security_record.fields[DATACORE_NAME]]"

	world.log << "Security: Loaded [security_records.len] security records from datacore"

// Add security personnel
/datum/security_persistence_manager/proc/add_security_personnel(var/ckey, var/real_name, var/clearance_level = 1)
	var/datum/security_record/personnel = new /datum/security_record(ckey, real_name)
	personnel.security_clearance = clearance_level
	personnel.security_rating = 100
	personnel.security_status = "ACTIVE"
	personnel.last_updated = world.time
	security_records[ckey] = personnel
	security_statistics["total_personnel"] = security_records.len
	return personnel

// Add security protocol (updated)
/datum/security_persistence_manager/proc/add_security_protocol(var/protocol_name, var/protocol_description, var/clearance_required = 1)
	var/protocol_id = "PROTOCOL_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/security_protocol/protocol = new /datum/security_protocol(protocol_id, protocol_name, protocol_description)
	protocol.clearance_required = clearance_required
	protocol.status = "ACTIVE"
	security_protocols[protocol_id] = protocol
	return protocol

// Add clearance request (updated)
/datum/security_persistence_manager/proc/add_clearance_request(var/personnel_ckey, var/requested_level, var/reason)
	var/request_id = "CLEARANCE_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/clearance_request/request = new /datum/clearance_request(request_id, personnel_ckey, requested_level)
	request.reason = reason
	request.status = "PENDING"
	clearance_requests[request_id] = request
	return request

// Clear persistent storage to ensure only real data is used
/datum/security_persistence_manager/proc/clear_persistent_storage()
	// Clear all existing data
	security_records.Cut()
	security_incidents.Cut()
	access_logs.Cut()
	security_protocols.Cut()
	clearance_requests.Cut()
	active_threats = 0
	containment_breaches = 0
	unauthorized_access_attempts = 0

	// Delete the persistent storage file
	var/savefile/S = new /savefile("data/security_persistence.json")
	if(S)
		S["data"] << null
		world.log << "Security: Cleared persistent storage file"

	world.log << "Security: Cleared all persistent storage data"


