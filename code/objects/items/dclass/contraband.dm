// D-Class Contraband Items
// Items that D-Class can find and use for escape attempts

// Contraband Item Base Class
/obj/item/dclass_contraband
	var/contraband_type = "basic"
	var/risk_level = 1 // 1-5, higher = more dangerous
	var/legal_use = FALSE // Can this item be used legally?
	var/detection_chance = 20 // Base chance of being detected by guards
	var/uses = 0 // Number of uses remaining
	var/cleanliness = 100 // For disguise items
	var/quality = 50 // For items that need quality rating

// Basic Tools
/obj/item/dclass_contraband/wire
	name = "metal wire"
	desc = "A length of metal wire. Useful for crafting and electrical work."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "wire"
	w_class = WEIGHT_CLASS_TINY
	uses = 3

/obj/item/dclass_contraband/screwdriver
	name = "screwdriver"
	desc = "A basic screwdriver. Can be used for various tasks."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "screwdriver"
	w_class = WEIGHT_CLASS_TINY
	uses = 5

/obj/item/dclass_contraband/wrench
	name = "wrench"
	desc = "A sturdy wrench. Useful for mechanical work."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "wrench"
	w_class = WEIGHT_CLASS_SMALL
	uses = 4

/obj/item/dclass_contraband/knife
	name = "kitchen knife"
	desc = "A sharp kitchen knife. Handle with care."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "knife"
	w_class = WEIGHT_CLASS_SMALL
	force = 10
	uses = 6

// Disguise Items
/obj/item/dclass_contraband/staff_uniform
	name = "staff uniform"
	desc = "A clean staff uniform. Could be useful for disguise."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "uniform"
	w_class = WEIGHT_CLASS_SMALL
	cleanliness = 100 // 0-100, affects disguise effectiveness
	contraband_type = "disguise"

/obj/item/dclass_contraband/fake_id
	name = "fake ID card"
	desc = "A poorly made fake ID card. Might fool someone in a hurry."
	icon = 'icons/obj/card.dmi'
	icon_state = "id"
	w_class = WEIGHT_CLASS_TINY
	quality = 50 // 0-100, affects success chance
	contraband_type = "disguise"

/obj/item/dclass_contraband/mask
	name = "disguise mask"
	desc = "A simple mask to hide your identity."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_mask"
	w_class = WEIGHT_CLASS_SMALL
	var/effectiveness = 30 // 0-100, affects detection chance
	contraband_type = "disguise"

// Materials
/obj/item/dclass_contraband/metal_pipe
	name = "metal pipe"
	desc = "A sturdy metal pipe. Could be used for various purposes."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "pipe"
	w_class = WEIGHT_CLASS_NORMAL
	force = 15

/obj/item/dclass_contraband/fabric_scraps
	name = "fabric scraps"
	desc = "Various pieces of fabric. Useful for crafting disguises."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "fabric"
	w_class = WEIGHT_CLASS_TINY
	var/amount = 3

/obj/item/dclass_contraband/thread
	name = "thread"
	desc = "Strong thread for sewing and crafting."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "thread"
	w_class = WEIGHT_CLASS_TINY
	var/amount = 5

// Chemicals and Medical
/obj/item/dclass_contraband/medicine
	name = "medicine"
	desc = "Various medical supplies. Could be useful or dangerous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	w_class = WEIGHT_CLASS_TINY
	var/potency = 50

/obj/item/dclass_contraband/bandages
	name = "bandages"
	desc = "Clean bandages. Useful for medical purposes or crafting."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bandage"
	w_class = WEIGHT_CLASS_TINY
	var/amount = 4

/obj/item/dclass_contraband/chemicals
	name = "chemicals"
	desc = "Various chemical compounds. Handle with extreme care."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	w_class = WEIGHT_CLASS_SMALL
	var/toxicity = 70

// Advanced Tools
/obj/item/dclass_contraband/lockpick
	name = "lockpick"
	desc = "A crude but effective lockpick. Use carefully."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "lockpick"
	w_class = WEIGHT_CLASS_TINY
	quality = 60
	uses = 3

/obj/item/dclass_contraband/cutting_tool
	name = "cutting tool"
	desc = "A sharp cutting implement. Useful for various tasks."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "scissors"
	w_class = WEIGHT_CLASS_SMALL
	force = 8
	uses = 4

/obj/item/dclass_contraband/electronics
	name = "electronic components"
	desc = "Various electronic parts. Could be used for hacking or crafting."
	icon = 'icons/obj/module.dmi'
	icon_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	var/complexity = 40

/obj/item/dclass_contraband/Initialize()
	. = ..()
	// Add to D-Class player's contraband if they're holding it
	if(ismob(loc))
		var/mob/M = loc
		if(M.ckey && SSdclass && SSdclass.manager)
			var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(M.ckey)
			if(player)
				player.add_contraband(name)

// Use contraband item
/obj/item/dclass_contraband/attack_self(mob/user)
	if(!user.ckey)
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(user.ckey)
	if(!player)
		return

	// Check if item can be used
	if(!can_use(user, player))
		return

	// Use the item
	use_item(user, player)

/obj/item/dclass_contraband/proc/can_use(mob/user, datum/dclass_player/player)
	// Check if player has required skills
	if(risk_level > player.level)
		to_chat(user, "<span class='warning'>You need to be level [risk_level] to use this item safely.</span>")
		return FALSE

	// Check if item has uses remaining
	if(uses && uses <= 0)
		to_chat(user, "<span class='warning'>This item is broken or used up.</span>")
		return FALSE

	return TRUE

/obj/item/dclass_contraband/proc/use_item(mob/user, datum/dclass_player/player)
	// Base implementation - reduce uses
	if(uses)
		uses--
		if(uses <= 0)
			to_chat(user, "<span class='notice'>The [name] breaks or is used up.</span>")
			qdel(src)

	// Increase suspicion
	player.increase_suspicion(risk_level * 5)

// Specific item use implementations
/obj/item/dclass_contraband/lockpick/use_item(mob/user, datum/dclass_player/player)
	. = ..()

	// Attempt to pick a nearby lock
	var/list/nearby_doors = list()
	for(var/obj/machinery/door/D in view(1, user))
		if(D.density) // Only locked doors
			nearby_doors += D

	if(nearby_doors.len > 0)
		var/obj/machinery/door/target_door = pick(nearby_doors)
		var/success_chance = quality + (player.skills["stealth"] - 1) * 10

		if(prob(success_chance))
			target_door.open()
			to_chat(user, "<span class='notice'>You successfully pick the lock!</span>")
			player.gain_experience(10, "successful lockpicking")
		else
			to_chat(user, "<span class='warning'>You fail to pick the lock.</span>")
			player.increase_suspicion(15)
	else
		to_chat(user, "<span class='warning'>No locked doors nearby.</span>")

/obj/item/dclass_contraband/staff_uniform/use_item(mob/user, datum/dclass_player/player)
	. = ..()

	// Apply disguise effect
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.w_uniform)
			H.dropItemToGround(H.w_uniform)

		H.equip_to_slot_if_possible(src, ITEM_SLOT_ICLOTHING, disable_warning = TRUE)
		to_chat(user, "<span class='notice'>You put on the staff uniform as a disguise.</span>")

		// Disguise effectiveness based on cleanliness and player skills
		var/disguise_effectiveness = cleanliness + (player.skills["social"] - 1) * 10
		player.abilities += "disguised"
		player.abilities["disguise_effectiveness"] = disguise_effectiveness

/obj/item/dclass_contraband/knife/use_item(mob/user, datum/dclass_player/player)
	. = ..()

	// Can be used as a weapon or tool
	var/choice = input(user, "How do you want to use the knife?", "Use Knife") as null|anything in list("Weapon", "Tool", "Cancel")

	switch(choice)
		if("Weapon")
			// Equip as weapon
			if(user.put_in_hands(src))
				to_chat(user, "<span class='notice'>You ready the knife as a weapon.</span>")
		if("Tool")
			// Use for crafting or cutting
			to_chat(user, "<span class='notice'>You use the knife for precise cutting work.</span>")
			player.gain_experience(5, "using knife as tool")
		if("Cancel")
			return

// Contraband detection by guards
/obj/item/dclass_contraband/proc/check_detection(mob/user, datum/dclass_player/player)
	if(!user || !player)
		return

	// Check if guards are nearby
	var/list/nearby_guards = list()
	for(var/mob/living/carbon/human/H in view(3, user))
		if(H.job && findtext(H.job, "Guard"))
			nearby_guards += H

	if(nearby_guards.len > 0)
		var/current_detection_chance = detection_chance
		current_detection_chance -= (player.skills["stealth"] - 1) * 5 // Skill reduces detection

		if(prob(current_detection_chance))
			// Guard detects contraband
			var/mob/living/carbon/human/guard = pick(nearby_guards)
			player.detect_contraband(guard)
			to_chat(user, "<span class='danger'>A guard has spotted your [name]!</span>")
			return TRUE

	return FALSE

// Contraband item verbs
/obj/item/dclass_contraband/verb/examine_contraband()
	set name = "Examine Contraband"
	set category = "D-Class"
	set src in usr

	if(!usr.ckey)
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(usr.ckey)
	if(!player)
		return

	var/info = "<h3>[name]</h3>"
	info += "<b>Description:</b> [desc]<br>"
	info += "<b>Risk Level:</b> [risk_level]/5<br>"
	info += "<b>Detection Chance:</b> [detection_chance]%<br>"

	if(uses)
		info += "<b>Uses Remaining:</b> [uses]<br>"

	if(contraband_type == "disguise")
		info += "<b>Disguise Effectiveness:</b> [cleanliness]%<br>"

	to_chat(usr, "<span class='notice'>[info]</span>")

/obj/item/dclass_contraband/verb/hide_contraband()
	set name = "Hide Contraband"
	set category = "D-Class"
	set src in usr

	if(!usr.ckey)
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(usr.ckey)
	if(!player)
		return

	// Hide the item in player's hidden items
	player.hidden_items[name] = src
	usr.dropItemToGround(src)

	to_chat(usr, "<span class='notice'>You hide the [name] in your secret stash.</span>")
	player.increase_suspicion(2) // Small suspicion increase for hiding items
