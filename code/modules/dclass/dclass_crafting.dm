// D-Class Craftable Items
// Simple items D-Class can craft

/obj/item/dclass_crafting_kit
	name = "Improvised Crafting Kit"
	desc = "Materials for crafting."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/dclass_crafting_kit/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/datum/dclass_player/player = SSdclass?.manager?.get_dclass_player(H.ckey)
	if(!player)
		return

	var/list/recipes = list("Shiv" = "shiv", "Lockpick" = "lockpick", "Pouch" = "pouch")
	var/choice = input(H, "Craft:", "Crafting") as null|anything in recipes
	if(!choice)
		return

	var/item_id = recipes[choice]
	var/has_materials = FALSE

	switch(item_id)
		if("shiv")
			if(player.has_contraband("metal_pipe"))
				player.remove_contraband("metal_pipe", 1)
				has_materials = TRUE
		if("lockpick")
			if(player.has_contraband("wire") && player.get_contraband_count("wire") >= 2)
				player.remove_contraband("wire", 2)
				has_materials = TRUE
		if("pouch")
			if(player.has_contraband("fabric_scraps") && player.get_contraband_count("fabric_scraps") >= 2)
				player.remove_contraband("fabric_scraps", 2)
				has_materials = TRUE

	if(has_materials)
		var/obj/item/I
		switch(item_id)
			if("shiv")
				I = new /obj/item/knife/kitchen/shiv(get_turf(H))
			if("lockpick")
				I = new /obj/item/screwdriver(get_turf(H))
			if("pouch")
				I = new /obj/item/storage/belt(get_turf(H))
		if(I)
			H.put_in_hands(I)
			player.gain_experience(15, "crafting")
			player.increase_suspicion(5)
			to_chat(H, span_notice("You craft [choice]."))
	else
		to_chat(H, span_warning("You don't have materials for that."))

/obj/item/knife/kitchen/shiv
	name = "improvised blade"
	desc = "A crude weapon."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "knife"
	force = 12