/datum/net_firewall
	var/list/blocked_commands
	var/list/allowed_sources
	var/enabled = TRUE

/datum/net_firewall/proc/check_packet(datum/net_signal/signal)
	if(!enabled)
		return TRUE
	if((signal.command in blocked_commands))
		return FALSE
	if(length(allowed_sources) && !(signal.source in allowed_sources))
		return FALSE
	return TRUE
