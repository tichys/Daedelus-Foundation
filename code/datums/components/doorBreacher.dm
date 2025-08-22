// Door Breacher Component
// Allows SCPs to breach doors and security systems

/datum/component/doorBreacher
	var/breach_cooldown = 0
	var/breach_cooldown_time = 120 SECONDS
	var/breach_range = 5
	var/breach_power = 50
	var/emp_effect = TRUE
	var/breach_sound = 'sound/effects/explosion1.ogg'

/datum/component/doorBreacher/Initialize(breach_range = 5, breach_power = 50, emp_effect = TRUE)
	. = ..()
	src.breach_range = breach_range
	src.breach_power = breach_power
	src.emp_effect = emp_effect

/datum/component/doorBreacher/proc/breach_doors()
	var/mob/living/parent_mob = parent
	if(!parent_mob)
		return FALSE

	if(world.time < breach_cooldown)
		to_chat(parent_mob, "<span class='warning'>Door breaching systems are recharging...</span>")
		return FALSE

	breach_cooldown = world.time + breach_cooldown_time

	var/list/doors_in_range = list()
	for(var/obj/machinery/door/D in range(breach_range, parent_mob))
		if(D.density)
			doors_in_range += D

	if(doors_in_range.len == 0)
		to_chat(parent_mob, "<span class='warning'>No doors found in range.</span>")
		return FALSE

	// Breach doors
	for(var/obj/machinery/door/D in doors_in_range)
		breach_door(D)

	// EMP effect on nearby electronics
	if(emp_effect)
		for(var/obj/machinery/M in range(breach_range, parent_mob))
			if(M != parent_mob)
				M.emp_act(EMP_LIGHT)

	playsound(parent_mob, breach_sound, 50, 0)
	to_chat(parent_mob, "<span class='notice'>Breached [length(doors_in_range)] doors.</span>")
	return TRUE

/datum/component/doorBreacher/proc/breach_door(obj/machinery/door/D)
	if(!D)
		return

		// Try to force open
	if(prob(30))
		D.open()

	// Visual effects
	var/turf/T = get_turf(D)
	if(T)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, T)
		s.start()

// Register the component
/datum/component/doorBreacher/RegisterWithParent()
	// Component is ready

/datum/component/doorBreacher/UnregisterFromParent()
	// Component cleanup
