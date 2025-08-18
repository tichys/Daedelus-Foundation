/datum/preference_group/category/antagonists
	name = "SCPs & Hostile Groups"
	priority = 30

	modules = list(
		/datum/preference_group/scp_antagonists
	)

/datum/preference_group/category/antagonists/get_content(datum/preferences/prefs)
	. = ..()
	for(var/datum/preference_group/module as anything in modules)
		. += module.get_content(prefs)

/datum/preference_group/scp_antagonists

/datum/preference_group/scp_antagonists/get_content(datum/preferences/prefs)
	. = ..()
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block;min-width:50%;max-width:50%;margin-left: auto;margin-right: auto'>
		<legend class='computerLegend tooltip'>
			<b>SCPs & Hostile Groups</b>
			<span class='tooltiptext'>Choose which SCPs and hostile groups you can play as. Access is controlled by admins.</span>
		</legend>
		<div style='text-align: center'>
			[button_element(prefs, "Select All Available", "pref_act=[/datum/preference/blob/antagonists];select_all_available=1")]
			[button_element(prefs, "Deselect All", "pref_act=[/datum/preference/blob/antagonists];deselect_all=1")]
		</div>
	<div class='flexColumn' style='height: 560px;display: block;overflow-y: scroll'>
	"}

	// Get SCP management data to check access
	var/list/available_roles = get_available_scp_roles(prefs.parent.ckey)
	var/list/client_antags = sort_list(prefs.read_preference(/datum/preference/blob/antagonists))

	var/i = 0
	var/background_color = "#7c5500"
	for(var/antagonist in client_antags)
		// Only show SCP and hostile group roles
		if(!is_scp_or_hostile_role(antagonist))
			continue

		i++
		background_color = i %% 2 ? "#7c5500" : "#533200"

		var/access_status = "DISABLED"
		var/access_color = "red"
		var/access_tooltip = "No access granted by admins"

		if(antagonist in available_roles)
			access_status = "ENABLED"
			access_color = "green"
			access_tooltip = "Access granted by admins"

		. += {"
		<div class='flexRow' style='justify-content: space-between; background-color:[background_color]'>
			<div style='padding-left: 0.5em;padding-right: 0.5em'>
				<span class='computerText'>[antagonist]</span>
			</div>
			<div>
				<span class='computerText' style='color: [access_color]; margin-right: 0.5em;' title='[access_tooltip]'>[access_status]</span>
				[button_element(prefs, client_antags[antagonist] ? "ENABLED" : "DISABLED", "pref_act=[/datum/preference/blob/antagonists];toggle_antag=[antagonist]", style = "margin-right: 0.5em", disabled = !(antagonist in available_roles))]
			</div>
		</div>
		"}
	. += "</div></fieldset>"

/datum/preference_group/scp_antagonists/proc/get_available_scp_roles(ckey)
	var/list/available_roles = list()

	// Check SCP management system for player access
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

		// Get player permissions from the performance system
		available_roles = manager.get_player_available_scps(ckey)

	return available_roles

/datum/preference_group/scp_antagonists/proc/is_scp_or_hostile_role(role)
	// Check if the role is an SCP or hostile group role
	var/list/scp_roles = list(
		ROLE_SCP173,
		ROLE_SCP096,
		ROLE_SCP008,
		ROLE_SCP035,
		ROLE_SCP049,
		ROLE_SCP2427_3,
		ROLE_SARKIC_CULT,
		ROLE_CHAOS_INSURGENCY,
		ROLE_SERPENTS_HAND
	)

	return (role in scp_roles)
