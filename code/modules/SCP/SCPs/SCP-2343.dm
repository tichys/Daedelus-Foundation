/mob/living/carbon/human/scp343/scp2343
	name = "strange american man"
	desc = "A brusk and wiley man of american decent."
	icon = 'icons/scp/scp_2343.dmi'
	icon_state = "americangod"
	status_flags = 0
	var/reality_manipulation_cooldown = 0
	var/manipulation_range = 5

/mob/living/carbon/human/scp343/scp2343/Initialize(mapload, new_species = "SCP-2343")
	. = ..()
	SCP = new /datum/scp(src, "strange american man", SCP_SAFE, "2343", SCP_PLAYABLE|SCP_ROLEPLAY)
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-2343"] = new /datum/scp_instance("SCP-2343", src)

/mob/living/carbon/human/scp343/scp2343/verb/manipulate_reality()
	set name = "Manipulate Reality"
	set desc = "Manipulate reality in a small area"
	set category = "SCP"

	if(reality_manipulation_cooldown > world.time)
		to_chat(src, "<span class='warning'>Reality manipulation is still recharging...</span>")
		return

	var/list/effects = list("Create Light", "Create Darkness", "Create Sound", "Create Silence", "Create Heat", "Create Cold")
	var/effect = input(src, "Choose reality effect:", "Reality Manipulation") as null|anything in effects
	if(!effect)
		return

	playsound(src, 'sound/effects/explosion1.ogg', 50)

	switch(effect)
		if("Create Light")
			visible_message("<span class='notice'>[src] creates a bright light!</span>")
			playsound(src, 'sound/effects/explosion2.ogg', 50)
		if("Create Darkness")
			visible_message("<span class='warning'>[src] creates an area of darkness!</span>")
			playsound(src, 'sound/effects/explosion2.ogg', 50)
		if("Create Sound")
			visible_message("<span class='notice'>[src] creates a loud sound!</span>")
			playsound(src, 'sound/effects/explosion2.ogg', 50)
		if("Create Silence")
			visible_message("<span class='warning'>[src] creates an area of silence!</span>")
		if("Create Heat")
			visible_message("<span class='danger'>[src] creates intense heat!</span>")
			playsound(src, 'sound/effects/explosion2.ogg', 50)
		if("Create Cold")
			visible_message("<span class='info'>[src] creates intense cold!</span>")
			playsound(src, 'sound/effects/explosion2.ogg', 50)

	reality_manipulation_cooldown = world.time + 60 SECONDS
	to_chat(src, "<span class='notice'>You manipulate reality to create [effect].</span>")

/mob/living/carbon/human/scp343/scp2343/verb/grant_wish()
	set name = "Grant Wish"
	set desc = "Grant a wish to someone"
	set category = "SCP"

	if(reality_manipulation_cooldown > world.time)
		to_chat(src, "<span class='warning'>Wish granting is still recharging...</span>")
		return

	var/list/targets = list()
	for(var/mob/living/L in view(manipulation_range, src))
		if(L != src && L.stat != DEAD)
			targets += L

	if(!targets.len)
		to_chat(src, "<span class='warning'>No valid targets in range.</span>")
		return

	var/mob/living/target = input(src, "Choose target to grant wish to:", "Grant Wish") as null|anything in targets
	if(!target || target.stat == DEAD)
		return

	var/wish = input(src, "What wish do you grant to [target]?", "Grant Wish") as text
	if(!wish)
		return

	playsound(src, 'sound/effects/explosion1.ogg', 50)
	to_chat(target, "<span class='good'>[src] grants your wish: [wish]</span>")
	to_chat(src, "<span class='notice'>You grant [target]'s wish: [wish]</span>")

	reality_manipulation_cooldown = world.time + 120 SECONDS

/mob/living/carbon/human/scp343/scp2343/examine(mob/living/user)
	. = ..()
	to_chat(user, "<span class='notice'>This being seems to have reality-bending powers.</span>")
