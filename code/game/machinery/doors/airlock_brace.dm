// MAINTENANCE JACK - Allows removing of braces with certain delay.
/obj/item/crowbar/brace_jack
	name = "maintenance jack"
	desc = "A special crowbar that can be used to safely remove airlock braces from airlocks."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/tools.dmi'
	icon_state = "maintenance_jack"
	force = 17.5 //It has a hammer head, should probably do some more damage. - Cirra

// BRACE - Can be installed on airlock to reinforce it and keep it closed.
// Set req_access if you dont want the brace and its electronics to derive their access from the door its placed on.
/obj/item/airlock_brace
	name = "airlock brace"
	desc = "A sturdy device that can be attached to an airlock to reinforce it and provide additional security."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "brace_open"
	var/cur_health
	var/max_health = 450
	var/obj/machinery/door/airlock/airlock = null
	var/obj/item/electronics/airlock/brace/electronics

/obj/item/airlock_brace/examine(mob/user)
	. = ..()
	to_chat(user, examine_health())


// This is also called from airlock's examine, so it's a different proc to prevent code copypaste.
/obj/item/airlock_brace/proc/examine_health()
	switch(health_percentage())
		if(-100 to 25)
			return (span_danger("\The [src] looks seriously damaged, and probably won't last much more."))
		if(25 to 50)
			return (span_notice("\The [src] looks damaged."))
		if(50 to 75)
			return "\The [src] looks slightly damaged."
		if(75 to 99)
			return "\The [src] has few dents."
		if(99 to INFINITY)
			return "\The [src] is in excellent condition."


/obj/item/airlock_brace/update_icon()
	..()
	if(airlock)
		icon_state = "brace_closed"
	else
		icon_state = "brace_open"


/obj/item/airlock_brace/New()
	..()
	cur_health = max_health
	electronics = new /obj/item/electronics/airlock/brace(src)
	if(length(req_access))
		electronics.req_access = req_access
	update_access()


/obj/item/airlock_brace/Destroy()
	if(airlock)
		airlock.seal = null
		airlock.update_appearance()
		airlock = null
	qdel(electronics)
	electronics = null
	..()


// Interact with the electronics to set access requirements.
/obj/item/airlock_brace/attack_self(mob/user as mob)
	electronics.attack_self(user)


/obj/item/airlock_brace/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W.GetID(), /obj/item/card/id))
		if(!airlock)
			attack_self(user)
			return
		else
			var/obj/item/card/id/C = W.GetID()
			update_access()
			if(check_access(C))
				to_chat(user, "You swipe \the [C] through \the [src].")
				if(do_after(user, 1 SECOND, airlock))
					to_chat(user, "\The [src] clicks a few times and detaches itself from \the [airlock]!")
					forceMove(user)
					airlock.seal = null
					airlock.update_appearance()
					airlock = null
					update_icon()
			else
				to_chat(user, "You swipe \the [C] through \the [src], but it does not react.")
		return

	if (istype(W, /obj/item/crowbar/brace_jack))
		if(!airlock)
			return
		var/obj/item/crowbar/brace_jack/C = W
		to_chat(user, "You begin forcibly removing \the [src] with \the [C].")
		if(do_after(user, 25 SECONDS, airlock))
			to_chat(user, "You finish removing \the [src].")
			forceMove(user)
			airlock.seal = null
			airlock.update_appearance()
			airlock = null
			update_icon()
		return

	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/C = W
		if(cur_health == max_health)
			to_chat(user, "\The [src] does not require repairs.")
			return
		if(C.use(0,user))
			playsound(src, 'sound/items/welder.ogg', 100, 1)
			cur_health = min(cur_health + rand(80,120), max_health)
			if(cur_health == max_health)
				to_chat(user, "You repair some dents on \the [src]. It is in perfect condition now.")
			else
				to_chat(user, "You repair some dents on \the [src].")


/obj/item/airlock_brace/take_damage(amount)
	cur_health = min(max(cur_health - amount, 0), max_health)
	if(!cur_health)
		if(airlock)
			airlock.visible_message(span_danger("\The [src] breaks off of \the [airlock]!"))
			forceMove(loc)
			airlock.seal = null
			airlock.update_appearance()
			airlock = null
			update_icon()
		qdel(src)


/obj/item/airlock_brace/proc/health_percentage()
	if(!max_health)
		return 0
	return (cur_health / max_health) * 100

/obj/item/airlock_brace/proc/update_access()
	if(!electronics)
		return
	req_access = electronics.req_access
