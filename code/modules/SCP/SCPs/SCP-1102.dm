/obj/item/storage/briefcase/scp1102ru
	name = "old plastic case"
	desc = "A strange plastic case covered in cloth."
	w_class = 4
	var/obj/structure/ladder/scp1102ladder/enter_point
	var/portal_cooldown = 0
	var/portal_cooldown_time = 30 SECONDS

/obj/item/storage/briefcase/scp1102ru/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "old plastic case", SCP_SAFE, "1102-RU")
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-1102-RU"] = new /datum/scp_instance("SCP-1102-RU", src)

/obj/item/storage/briefcase/scp1102ru/attack_hand(mob/user)
	. = ..()
	if(!enter_point)
		enter_point = new /obj/structure/ladder/scp1102ladder(get_turf(src))

/obj/item/storage/briefcase/scp1102ru/attack_self(mob/user)
	if(!user || !istype(user, /mob/living))
		return

	if(portal_cooldown > world.time)
		to_chat(user, "<span class='warning'>The portal is still recharging...</span>")
		return

	if(!enter_point)
		enter_point = new /obj/structure/ladder/scp1102ladder(get_turf(src))

	to_chat(user, "<span class='warning'>You feel a strange sensation as you open the case...</span>")
	to_chat(user, "<span class='notice'>You find yourself climbing down a ladder that shouldn't be there.</span>")

	// Create portal effect
	playsound(src, 'sound/effects/explosion1.ogg', 50)
	playsound(enter_point, 'sound/effects/explosion1.ogg', 50)

	// Move user to ladder
	var/mob/living/L = user
	L.forceMove(get_turf(enter_point))
	to_chat(user, "<span class='warning'>The case disappears behind you as you descend.</span>")

	// Set cooldown
	portal_cooldown = world.time + portal_cooldown_time

/obj/structure/ladder/scp1102ladder
	name = "strange ladder"
	desc = "A ladder that leads to nowhere."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	var/obj/item/storage/briefcase/scp1102ru/linked_case

/obj/structure/ladder/scp1102ladder/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "ladder", SCP_SAFE, "1102-RU-1")
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-1102-RU-1"] = new /datum/scp_instance("SCP-1102-RU-1", src)

	// Find and link to the case
	linked_case = locate(/obj/item/storage/briefcase/scp1102ru) in world

/obj/structure/ladder/scp1102ladder/use(mob/user, is_ghost=FALSE)
	if(!linked_case)
		to_chat(user, "<span class='warning'>The ladder seems to lead nowhere...</span>")
		return

	// Return to the case
	if(linked_case.portal_cooldown > world.time)
		to_chat(user, "<span class='warning'>The portal is still recharging...</span>")
		return

	to_chat(user, "<span class='notice'>You climb back up the ladder...</span>")
	playsound(src, 'sound/effects/explosion1.ogg', 50)
	playsound(linked_case, 'sound/effects/explosion1.ogg', 50)

	user.forceMove(get_turf(linked_case))
	to_chat(user, "<span class='notice'>You emerge from the strange case.</span>")

	// Set cooldown
	linked_case.portal_cooldown = world.time + linked_case.portal_cooldown_time
