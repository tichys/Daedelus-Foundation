/obj/item/reagent_containers/glass/bottle/scp008
	name = "SCP-008"
	desc = "A sealed container containing a highly contagious zombie plague. Extremely dangerous."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "bottle"
	var/containment_breached = FALSE
	var/infection_strength = 50
	var/list/infected_targets = list()
	var/list/zombified_targets = list()

	// Persistence tracking
	var/infections_caused = 0
	var/zombifications_caused = 0
	var/containment_status = "contained"

/obj/item/reagent_containers/glass/bottle/scp008/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-008",
		SCP_KETER,
		"008",
		
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-008"] = new /datum/scp_instance("SCP-008", src)

/obj/item/reagent_containers/glass/bottle/scp008/Destroy()
	infected_targets = list()
	zombified_targets = list()
	return ..()

// Core mechanics
/obj/item/reagent_containers/glass/bottle/scp008/process()
	. = ..()

	// Spread infection if containment is breached
	if(containment_breached)
		spread_infection()

// Spread infection to nearby targets
/obj/item/reagent_containers/glass/bottle/scp008/proc/spread_infection()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.SCP || H.stat == DEAD)
			continue

		if(!(H in infected_targets) && !(H in zombified_targets))
			infect_target(H)

// Infect a target with SCP-008
/obj/item/reagent_containers/glass/bottle/scp008/proc/infect_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	if(target in infected_targets || target in zombified_targets)
		return

	infected_targets += target
	infections_caused++
	containment_status = "breached"

	visible_message("<span class='danger'>[target] has been infected with SCP-008!</span>")
	to_chat(target, "<span class='danger'>You have been infected with SCP-008! You feel your body beginning to decay...</span>")

	// Apply infection effects
	target.adjustBruteLoss(infection_strength)
	target.adjustToxLoss(infection_strength)

	// Start infection timer
	spawn(300) // 30 seconds
		if(target && target.stat != DEAD)
			zombify_target(target)

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-008"]
		if(instance)
			instance.add_interaction_record(target, "infection")

// Transform target into zombie
/obj/item/reagent_containers/glass/bottle/scp008/proc/zombify_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	infected_targets -= target
	zombified_targets += target
	zombifications_caused++

	visible_message("<span class='danger'>[target] has been completely zombified by SCP-008!</span>")
	to_chat(target, "<span class='danger'>You have been completely transformed into a zombie! You are now part of the SCP-008 horde.</span>")

	// Create zombie mob
	var/mob/living/simple_animal/hostile/scp008_zombie/zombie = new /mob/living/simple_animal/hostile/scp008_zombie(target.loc)
	zombie.name = "[target.name] (Zombie)"
	zombie.desc = "A zombified version of [target.name], infected with SCP-008."

	// Transfer player to zombie
	if(target.mind)
		target.mind.transfer_to(zombie)

	// Remove original target
	target.gib()

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-008"]
		if(instance)
			instance.add_interaction_record(target, "zombification")

// Breach containment
/obj/item/reagent_containers/glass/bottle/scp008/proc/breach_containment()
	containment_breached = TRUE
	containment_status = "breached"

	visible_message("<span class='danger'>SCP-008 containment has been breached! The zombie plague is spreading!</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-008"]
		if(instance)
			instance.add_interaction_record(null, "containment_breach")

// Attack behavior - infect on touch
/obj/item/reagent_containers/glass/bottle/scp008/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(ishuman(M))
		infect_target(M)
		breach_containment()
		return TRUE
	return ..()

// Verb commands
/obj/item/reagent_containers/glass/bottle/scp008/verb/breach_containment_verb()
	set name = "Breach Containment"
	set category = "SCP"
	set desc = "Deliberately breach SCP-008 containment."

	breach_containment()
	to_chat(usr, "<span class='notice'>You have breached SCP-008 containment.</span>")

/obj/item/reagent_containers/glass/bottle/scp008/verb/infect_target_verb()
	set name = "Infect Target"
	set category = "SCP"
	set desc = "Attempt to infect a nearby target."

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H != usr && H.stat != DEAD)
			targets += H

	if(!targets.len)
		to_chat(usr, "<span class='warning'>No suitable targets nearby.</span>")
		return

	var/mob/living/carbon/human/target = input(usr, "Choose a target to infect:", "Infect Target") as null|anything in targets
	if(target)
		infect_target(target)
		breach_containment()

// Admin verb to view SCP-008 persistence data
/obj/item/reagent_containers/glass/bottle/scp008/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-008 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-008 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Containment Breached:</b> [containment_breached ? "Yes" : "No"]<br>"
	message += "<b>Infections Caused:</b> [infections_caused]<br>"
	message += "<b>Zombifications Caused:</b> [zombifications_caused]<br>"
	message += "<b>Infected Targets:</b> [infected_targets.len]<br>"
	message += "<b>Zombified Targets:</b> [zombified_targets.len]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-008"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// SCP-008 Zombie (the actual zombie entity)
/mob/living/simple_animal/hostile/scp008_zombie
	name = "SCP-008 Zombie"
	desc = "A humanoid figure with pale, decaying skin and bloodshot eyes. It appears to be infected with SCP-008."
	icon = 'icons/mob/animal.dmi'
	icon_state = "scp008_zombie"
	maxHealth = 100
	health = 100
	see_invisible = SEE_INVISIBLE_LIVING
	see_in_dark = 8
	status_flags = 0

	// Zombie specific variables
	var/attack_strength = 30
	var/regeneration_rate = 1
	var/list/infected_targets = list()

	// Persistence tracking
	var/kills_count = 0
	var/infections_caused = 0
	var/containment_status = "breached"

/mob/living/simple_animal/hostile/scp008_zombie/Initialize()
	. = ..()

	// Register with SCP persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances["SCP-008-Zombie-[src]"] = new /datum/scp_instance("SCP-008-Zombie-[src]", src)

/mob/living/simple_animal/hostile/scp008_zombie/Destroy()
	infected_targets = list()
	return ..()

// Core mechanics
/mob/living/simple_animal/hostile/scp008_zombie/Life()
	. = ..()

	// Regenerate health
	regenerate()

	// Find and attack targets
	var/mob/living/carbon/human/target = find_target()
	if(target)
		attack_target(target)

// Regeneration system
/mob/living/simple_animal/hostile/scp008_zombie/proc/regenerate()
	if(health < maxHealth)
		adjustBruteLoss(-regeneration_rate)
		adjustFireLoss(-regeneration_rate)
		adjustToxLoss(-regeneration_rate)

// Find potential targets
/mob/living/simple_animal/hostile/scp008_zombie/proc/find_target()
	var/mob/living/carbon/human/closest = null
	var/shortest_distance = 999

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H == src || H.SCP || H.stat == DEAD)
			continue
		var/distance = get_dist(src, H)
		if(distance < shortest_distance)
			shortest_distance = distance
			closest = H

	return closest

// Attack target
/mob/living/simple_animal/hostile/scp008_zombie/proc/attack_target(mob/living/carbon/human/target)
	if(!target)
		return

	// Move towards target
	step_towards(src, target)

	// Attack if close enough
	if(get_dist(src, target) <= 1)
		UnarmedAttack(target)

// Attack behavior
/mob/living/simple_animal/hostile/scp008_zombie/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A

		visible_message("<span class='danger'>[src] viciously attacks [H]!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

		H.adjustBruteLoss(attack_strength)

		// Infect target
		if(!(H in infected_targets))
			infect_target(H)

		// Track kills
		if(H.stat == DEAD)
			kills_count++

		// Update persistence system
		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-008-Zombie-[src]"]
			if(instance)
				instance.add_interaction_record(H, "attack")

		return

	return ..()

// Infect a target
/mob/living/simple_animal/hostile/scp008_zombie/proc/infect_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	if(target in infected_targets)
		return

	infected_targets += target
	infections_caused++

	to_chat(target, "<span class='danger'>You have been infected by [src]!</span>")

	// Apply infection effects
	target.adjustBruteLoss(20)
	target.adjustToxLoss(20)

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-008-Zombie-[src]"]
		if(instance)
			instance.add_interaction_record(target, "infection")

// Status display
/mob/living/simple_animal/hostile/scp008_zombie/get_status_tab_items()
	. = ..()
	. += "Containment Status: [containment_status]"
	. += "Kills: [kills_count]"
	. += "Infections Caused: [infections_caused]"
	. += "Infected Targets: [infected_targets.len]"

// Examine behavior
/mob/living/simple_animal/hostile/scp008_zombie/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is an SCP-008 zombie, created by the zombie plague.</span>")
		else
			to_chat(user, "<span class='danger'>A decaying humanoid figure with bloodshot eyes. It looks extremely dangerous and contagious.</span>")

// Death behavior
/mob/living/simple_animal/hostile/scp008_zombie/death()
	visible_message("<span class='danger'>[src] collapses, finally dead!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Verb commands
/mob/living/simple_animal/hostile/scp008_zombie/verb/infect_nearby()
	set name = "Infect Nearby"
	set category = "SCP"
	set desc = "Attempt to infect all nearby targets."

	var/infected_count = 0
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H != src && H.stat != DEAD)
			infect_target(H)
			infected_count++

	if(infected_count > 0)
		to_chat(src, "<span class='notice'>You infected [infected_count] nearby targets!</span>")
	else
		to_chat(src, "<span class='warning'>No suitable targets nearby to infect.</span>")

// Admin verb to view zombie persistence data
/mob/living/simple_animal/hostile/scp008_zombie/verb/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-008 Zombie persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-008 Zombie Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Kills:</b> [kills_count]<br>"
	message += "<b>Infections Caused:</b> [infections_caused]<br>"
	message += "<b>Infected Targets:</b> [infected_targets.len]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-008-Zombie-[src]"]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")


