/obj/machinery/scp_femur_breaker
	name = "Femur Breaker"
	desc = "A containment device used to lure SCP-106 back to its cell. Requires a human subject."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "centrifuge"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/occupied = FALSE
	var/activation_progress = 0
	var/activation_threshold = 100

/obj/machinery/scp_femur_breaker/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(occupied)
		var/confirm = alert(H, "Activate the Femur Breaker? This will cause severe harm to the subject.", "Femur Breaker", "Activate", "Cancel")
		if(confirm != "Activate")
			return
		activate(H)
		return

	var/confirm = alert(H, "Enter the Femur Breaker? This is extremely dangerous.", "Femur Breaker", "Enter", "Cancel")
	if(confirm != "Enter")
		return

	occupied = TRUE
	H.forceMove(src)
	H.visible_message("<span class='danger'>[H] enters the Femur Breaker!</span>")

/obj/machinery/scp_femur_breaker/proc/activate(mob/activator)
	if(!occupied)
		to_chat(activator, "<span class='warning'>The Femur Breaker requires a subject.</span>")
		return

	for(var/mob/living/carbon/human/H in src)
		H.adjustBruteLoss(80)
		H.emote("scream")
		visible_message("<span class='danger'>The Femur Breaker activates! [H] screams in agony!</span>")

		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-106"]
			if(instance && instance.containment_status == "breached")
				priority_announce("ATTENTION: Femur Breaker protocol activated. SCP-106 is being lured back to containment.", sound_type = ANNOUNCER_ALERT)
				addtimer(CALLBACK(src, .proc/complete_femur_breaker, H), 300)

		H.forceMove(get_turf(src))
		occupied = FALSE
		return

/obj/machinery/scp_femur_breaker/proc/complete_femur_breaker(mob/living/carbon/human/victim)
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-106"]
	if(instance)
		instance.containment_status = "contained"
		instance.containment_health = 100
		instance.add_interaction_record(victim, "femur_breaker_recontainment")
		SSscp_persistence.manager.active_breaches = max(0, SSscp_persistence.manager.active_breaches - 1)
		SSscp_persistence.manager.global_containment_stability = min(100, SSscp_persistence.manager.global_containment_stability + 5)

	hook_scp_recontainment("SCP-106", list(victim))
	priority_announce("SCP-106 has been recontained via Femur Breaker protocol.", sound_type = ANNOUNCER_DEFAULT)

/obj/item/scp096_bag
	name = "SCP-096 Containment Bag"
	desc = "A reinforced bag designed to be placed over SCP-096's head to prevent further enrage triggers."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "muzzle"

/obj/item/scp096_bag/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/found_scp = FALSE
	for(var/mob/living/carbon/human/scp096/S in oview(1, H))
		if(S.head && istype(S.head, /obj/item/clothing/head/scp096_hood))
			continue
		user.visible_message("<span class='danger'>[user] attempts to place the containment bag over SCP-096's head!</span>")
		if(do_after(user, 30, target = S))
			var/hood = new /obj/item/clothing/head/scp096_hood()
			S.equip_to_slot_or_del(hood, ITEM_SLOT_HEAD)
			S.emote("scream")
			to_chat(user, "<span class='notice'>You place the containment bag over SCP-096's head!</span>")
			qdel(src)
		found_scp = TRUE
		break
	if(!found_scp)
		to_chat(user, "<span class='warning'>No nearby SCP-096 without head covering.</span>")

/obj/item/clothing/head/scp096_hood
	name = "SCP-096 Containment Hood"
	desc = "A reinforced hood placed over SCP-096's head to prevent enrage triggers."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "muzzle"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	var/can_trigger = FALSE

/obj/item/clothing/head/scp096_hood/equipped(mob/living/carbon/human/H, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD && istype(H, /mob/living/carbon/human/scp096))
		can_trigger = FALSE
		H.visible_message("<span class='notice'>SCP-096's face is now covered.</span>")

/obj/item/scp173_blink_kit
	name = "SCP-173 Observation Kit"
	desc = "A kit containing eye drops and stimulants to help maintain visual contact with SCP-173."
	var/uses = 5

/obj/item/scp173_blink_kit/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(uses <= 0)
		to_chat(user, "<span class='warning'>The kit is empty.</span>")
		return

	uses--
	var/mob/living/carbon/human/H = user
	H.stamina.adjust(30)
	to_chat(H, "<span class='notice'>You apply the eye drops and stimulants. Your eyes feel refreshed!</span>")
	H.set_drugginess(10)

/obj/machinery/scp457_suppression
	name = "SCP-457 Fire Suppression Unit"
	desc = "A specialized fire suppression system designed for recontaining SCP-457."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "mass_driver"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	var/suppression_charge = 100
	var/max_charge = 100
	var/recharge_rate = 0.5

/obj/machinery/scp457_suppression/process()
	if(suppression_charge < max_charge)
		suppression_charge = min(max_charge, suppression_charge + recharge_rate)

/obj/machinery/scp457_suppression/attack_hand(mob/user)
	if(!ishuman(user))
		return

	if(suppression_charge < 30)
		to_chat(user, "<span class='warning'>Insufficient charge. Current: [round(suppression_charge)]%</span>")
		return

	var/confirm = alert(user, "Activate fire suppression? Charge: [round(suppression_charge)]%", "Suppression", "Activate", "Cancel")
	if(confirm != "Activate")
		return

	suppression_charge -= 30
	visible_message("<span class='notice'>[src] discharges a massive blast of fire retardant!</span>")

	for(var/mob/living/L in range(5, src))
		if(istype(L, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = L
			if(H.on_fire)
				H.extinguish_mob()

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-457"]
		if(instance && instance.containment_status == "breached")
			hook_scp_recontainment("SCP-457", list(user))
			priority_announce("SCP-457 has been suppressed via fire containment system.", sound_type = ANNOUNCER_DEFAULT)

/obj/machinery/scp049_cure_station
	name = "SCP-049 Containment Lure"
	desc = "A device that broadcasts a signal designed to lure SCP-049 back to containment."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "cellcharger"
	density = TRUE
	anchored = TRUE
	var/lure_active = FALSE
	var/lure_duration = 300

/obj/machinery/scp049_cure_station/attack_hand(mob/user)
	if(!ishuman(user))
		return

	if(lure_active)
		to_chat(user, "<span class='warning'>The lure is already active.</span>")
		return

	if(!ishuman(user))
		to_chat(user, "<span class='warning'>Requires Science access.</span>")
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		to_chat(user, "<span class='warning'>Requires Science access.</span>")
		return

	lure_active = TRUE
	visible_message("<span class='notice'>[src] begins broadcasting the containment lure signal.</span>")
	priority_announce("SCP-049 containment lure protocol activated. The Doctor is being called back.", sound_type = ANNOUNCER_DEFAULT)

	addtimer(CALLBACK(src, .proc/deactivate_lure), lure_duration)

/obj/machinery/scp049_cure_station/proc/deactivate_lure()
	lure_active = FALSE
	visible_message("<span class='notice'>[src] stops broadcasting.</span>")

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-049"]
		if(instance && instance.containment_status == "breached")
			hook_scp_recontainment("SCP-049", list())
