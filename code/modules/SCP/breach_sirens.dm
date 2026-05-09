// Dedicated Breach Sirens
// Physical siren objects placed in facility that activate on containment breach
// Different tones for different breach severity

/obj/machinery/breach_siren
	name = "containment breach siren"
	desc = "A heavy-duty siren that activates during containment breach events. Do not tamper."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 200
	max_integrity = 200
	integrity_failure = 0.5

	var/active = FALSE
	var/siren_type = "breach"
	var/sound_range = 25
	var/cycle_cooldown = 0
	var/cycle_interval = 8 SECONDS
	var/cycle_timerid

/obj/machinery/breach_siren/Initialize()
	. = ..()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_security_level_changed))

/obj/machinery/breach_siren/Destroy()
	if(active)
		deactivate()
	return ..()

/obj/machinery/breach_siren/proc/on_security_level_changed(datum/source, new_level)
	SIGNAL_HANDLER
	if(machine_stat & BROKEN)
		return
	switch(new_level)
		if(SEC_LEVEL_GREEN)
			if(active)
				deactivate()
		if(SEC_LEVEL_BLUE)
			if(active)
				deactivate()
		if(SEC_LEVEL_RED)
			activate("breach")
		if(SEC_LEVEL_DELTA)
			activate("critical")

/obj/machinery/breach_siren/proc/activate(new_type)
	if(active || (machine_stat & BROKEN) || !powered())
		return
	active = TRUE
	siren_type = new_type
	use_power = ACTIVE_POWER_USE
	update_icon()
	begin_cycle()

/obj/machinery/breach_siren/proc/deactivate()
	active = FALSE
	use_power = IDLE_POWER_USE
	cycle_cooldown = 0
	deltimer(cycle_timerid)
	cycle_timerid = null
	update_icon()

/obj/machinery/breach_siren/proc/begin_cycle()
	if(!active)
		return
	play_siren_sound()
	cycle_cooldown = world.time + cycle_interval
	cycle_timerid = addtimer(CALLBACK(src, PROC_REF(begin_cycle)), cycle_interval, TIMER_STOPPABLE)

/obj/machinery/breach_siren/proc/play_siren_sound()
	if(!active || (machine_stat & BROKEN) || !powered())
		deactivate()
		return
	var/sound_file = 'sound/machines/alarm.ogg'
	switch(siren_type)
		if("breach")
			sound_file = 'sound/machines/alarm.ogg'
		if("critical")
			sound_file = 'sound/machines/alarm.ogg'
		else
			sound_file = 'sound/machines/alarm.ogg'
	playsound(src, sound_file, 80, FALSE, sound_range)

/obj/machinery/breach_siren/update_icon()
	if(active && powered())
		icon_state = "flasher_on"
		set_light(3, 2, LIGHT_COLOR_INTENSE_RED)
	else
		icon_state = "flasher"
		set_light(0)

/obj/machinery/breach_siren/attack_hand(mob/user)
	if(!active)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		to_chat(H, span_warning("You cannot silence the breach siren without command authorization."))
		return
	deactivate()
	to_chat(H, span_notice("You silence the breach siren."))

/obj/machinery/breach_siren/emp_act(severity)
	. = ..()
	if(active)
		deactivate()
