/datum/loadout_ui
	var/client/owner

	New(client/C)
		. = ..()
		owner = C
		ui_interact(C.mob)

	ui_state(mob/user)
		return GLOB.always_state

	ui_status(mob/user, datum/ui_state/state)
		return user?.client == owner ? UI_INTERACTIVE : UI_CLOSE

	ui_static_data(mob/user)
		// Provide predictable shape on first paint
		return list("loadout_entries" = list())

	ui_interact(mob/user, datum/tgui/ui)
		var/datum/preferences/prefs = user?.client?.prefs
		if (!prefs)
			return FALSE
		ui = SStgui.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "LoadoutPanel")
			ui.set_autoupdate(TRUE)
			ui.open()
		return TRUE

	ui_data(mob/user)
		var/datum/preferences/prefs = user?.client?.prefs
		var/list/data = list()

		// Current loadout items
		var/list/loadout = prefs?.read_preference(/datum/preference/blob/loadout) || list()
		var/list/current_items = list()
		for (var/datum/loadout_entry/E as anything in loadout)
			var/datum/loadout_item/LI = locate(E.path) in GLOB.loadout_items
			if(!LI)
				continue
			current_items += list(list(
				"path" = "[E.path]",
				"name" = E.custom_name || LI.name,
				"desc" = E.custom_desc || LI.description,
				"cost" = LI.cost,
				"equipped" = TRUE
			))
		data["current_loadout"] = current_items

		// Available categories and current selection
		data["categories"] = list()
		for(var/category in GLOB.loadout_category_to_subcategory_to_items)
			data["categories"] += category
		data["current_category"] = prefs.loadout_category || LOADOUT_CATEGORY_BACKPACK

		// Available subcategories for current category
		data["subcategories"] = list()
		if(data["current_category"] in GLOB.loadout_category_to_subcategory_to_items)
			for(var/subcategory in GLOB.loadout_category_to_subcategory_to_items[data["current_category"]])
				data["subcategories"] += subcategory
		data["current_subcategory"] = prefs.loadout_subcategory || LOADOUT_SUBCATEGORY_MISC

		// Available items in current subcategory
		var/list/available_items = list()
		var/list/items_in_subcat = GLOB.loadout_category_to_subcategory_to_items[data["current_category"]]?[data["current_subcategory"]]
		for(var/datum/loadout_item/LI as anything in items_in_subcat)
			var/datum/loadout_entry/entry = prefs.get_loadout_entry_for_loadout_item(LI, loadout)
			available_items += list(list(
				"path" = "[LI.type]",
				"name" = LI.name,
				"desc" = LI.description,
				"cost" = LI.cost,
				"equipped" = !!entry
			))
		data["available_items"] = available_items

		// Loadout points
		data["remaining_points"] = prefs.calculate_loadout_points()
		data["max_points"] = LOADOUT_POINTS_MAX

		return data

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		var/datum/preferences/prefs = owner?.prefs
		switch(action)
			if ("loadout_toggle")
				var/datum/preference/P = GLOB.preference_entries[/datum/preference/blob/loadout]
				var/result = P.button_act(owner.mob, prefs, list("item" = params["item"], "change_loadout" = 1))
				if(result)
					SStgui.update_uis(src)
					// Also update any open CharacterSetup UIs to refresh loadout display
					for(var/datum/tgui/char_ui in SStgui.open_uis)
						if(char_ui.interface == "CharacterSetup" && char_ui.user?.client == owner)
							char_ui.update_static_data()
				return result
			if ("set_category")
				var/datum/preference/P = GLOB.preference_entries[/datum/preference/blob/loadout]
				var/result = P.button_act(owner.mob, prefs, list("category_set" = params["category"]))
				if(result)
					SStgui.update_uis(src)
				return result
			if ("set_subcategory")
				var/datum/preference/P = GLOB.preference_entries[/datum/preference/blob/loadout]
				var/result = P.button_act(owner.mob, prefs, list("subcategory_set" = params["subcategory"]))
				if(result)
					SStgui.update_uis(src)
				return result
			if ("close")
				return TRUE
		return FALSE

