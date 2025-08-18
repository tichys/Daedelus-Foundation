/mob/living/carbon/human/scp2020
	name = "Green humanoid"
	desc = "A strange Green humanoid"
	status_flags = 0
	var/teleport_cooldown = 0
	var/teleport_range = 7

/mob/living/carbon/human/scp2020/Initialize(mapload, new_species = "SCP-2020")
	. = ..()
	SCP = new /datum/scp(src, "Artie", SCP_EUCLID, "2020", SCP_PLAYABLE|SCP_ROLEPLAY)
	SCP.min_time = 1 MINUTES
	SCP.min_playercount = 0
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-2020"] = new /datum/scp_instance("SCP-2020", src)

/mob/living/carbon/human/scp2020/verb/teleport_to_target()
	set name = "Teleport to Target"
	set desc = "Teleport to a visible target"
	set category = "SCP"

	if(teleport_cooldown > world.time)
		to_chat(src, "<span class='warning'>Teleportation is still recharging...</span>")
		return

	var/list/targets = list()
	for(var/mob/living/L in view(teleport_range, src))
		if(L != src && L.stat != DEAD)
			targets += L

	if(!targets.len)
		to_chat(src, "<span class='warning'>No valid targets in range.</span>")
		return

	var/mob/living/target = input(src, "Choose target to teleport to:", "Teleport") as null|anything in targets
	if(!target || target.stat == DEAD)
		return

	playsound(src, 'sound/effects/explosion1.ogg', 50)
	forceMove(get_turf(target))
	playsound(src, 'sound/effects/explosion2.ogg', 50)

	teleport_cooldown = world.time + 30 SECONDS
	to_chat(src, "<span class='notice'>You teleport to [target].</span>")

/mob/living/carbon/human/scp2020/verb/phase_through_walls()
	set name = "Phase Through Walls"
	set desc = "Phase through walls temporarily"
	set category = "SCP"

	if(teleport_cooldown > world.time)
		to_chat(src, "<span class='warning'>Phasing is still recharging...</span>")
		return

	var/turf/T = get_step(src, dir)
	if(!T)
		return

	if(T.density)
		playsound(src, 'sound/effects/explosion1.ogg', 50)
		forceMove(T)
		playsound(src, 'sound/effects/explosion2.ogg', 50)
		to_chat(src, "<span class='notice'>You phase through the wall.</span>")
		teleport_cooldown = world.time + 15 SECONDS
	else
		to_chat(src, "<span class='warning'>There's no wall to phase through.</span>")

/mob/living/carbon/human/scp2020/examine(mob/living/user)
	. = ..()
	to_chat(user, "<span class='notice'>This being seems to have supernatural abilities.</span>")
