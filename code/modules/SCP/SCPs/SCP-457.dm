// SCP-457 - The Living Flame
// A sentient flame that can spread and consume

/mob/living/carbon/scp/scp457
	name = "SCP-457"
	desc = "A living flame that moves with purpose."
	icon = 'icons/scp/scp-457.dmi'
	icon_state = "scp457"
	real_name = "SCP-457"
	use_custom_sprite = TRUE

	// Maximum Enhanced SCP-457 variables
	var/spread_cooldown = 0
	var/spread_cooldown_time = 5 SECONDS
	var/heat_level = 50
	var/max_heat = 100
	var/flame_radius = 2
	var/max_flame_radius = 5
	var/list/created_fires = list()
	var/list/consumed_targets = list()
	var/flame_intensity = 1
	var/max_flame_intensity = 3
	var/elemental_mastery = 0
	var/max_elemental_mastery = 100
	var/combustion_skill = 0
	var/max_combustion_skill = 100
	var/heat_absorption = 0
	var/max_heat_absorption = 100
	var/fire_storm_level = 0
	var/max_fire_storm_level = 5
	var/environmental_destruction = 0
	var/max_environmental_destruction = 100
	var/flame_evolution_stage = 1
	var/max_flame_evolution = 5
	var/heat_manipulation_cooldown = 0
	var/heat_manipulation_cooldown_time = 10 SECONDS
	var/fire_storm_cooldown = 0
	var/fire_storm_cooldown_time = 30 SECONDS

	// Persistence tracking
	var/fires_created = 0
	var/targets_consumed = 0
	var/heat_manipulations = 0
	var/elemental_masteries = 0
	var/combustion_events = 0
	var/fire_storms_created = 0
	var/environmental_damage = 0
	var/flame_evolutions = 0

/mob/living/carbon/scp/scp457/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-457",
		SCP_KETER,
		"457",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 20
	SCP_datum.min_time = 30 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 200
	scp_health = max_scp_health
	max_scp_armor = 50
	scp_armor = max_scp_armor

	// Add passive effects
	add_passive_effect("flame_aura")
	add_passive_effect("heat_manipulation")
	add_passive_effect("fire_creation")
	add_passive_effect("elemental_control")
	add_passive_effect("combustion_mastery")
	add_passive_effect("heat_absorption")
	add_passive_effect("fire_storm")
	add_passive_effect("environmental_destruction")
	add_passive_effect("flame_evolution")

	// Initialize SCP-457 specific skills with cooldowns and requirements
	initialize_skill("spread_flame", 10 SECONDS, list("base_cooldown" = 10 SECONDS))
	initialize_skill("create_fire", 20 SECONDS, list("base_cooldown" = 20 SECONDS, "requires_level_10" = TRUE))
	initialize_skill("manipulate_heat", 30 SECONDS, list("base_cooldown" = 30 SECONDS, "requires_level_15" = TRUE))
	initialize_skill("expand_radius", 45 SECONDS, list("base_cooldown" = 45 SECONDS, "requires_level_20" = TRUE))
	initialize_skill("consume_target", 25 SECONDS, list("base_cooldown" = 25 SECONDS, "requires_level_25" = TRUE))
	initialize_skill("elemental_control", 60 SECONDS, list("base_cooldown" = 60 SECONDS, "requires_level_30" = TRUE))
	initialize_skill("combustion_mastery", 90 SECONDS, list("base_cooldown" = 90 SECONDS, "requires_level_35" = TRUE))
	initialize_skill("heat_absorption", 40 SECONDS, list("base_cooldown" = 40 SECONDS, "requires_level_40" = TRUE))
	initialize_skill("create_fire_storm", 120 SECONDS, list("base_cooldown" = 120 SECONDS, "requires_level_50" = TRUE, "requires_breach" = TRUE))
	initialize_skill("environmental_destruction", 150 SECONDS, list("base_cooldown" = 150 SECONDS, "requires_level_60" = TRUE, "requires_breach" = TRUE))
	initialize_skill("evolve_flame", 180 SECONDS, list("base_cooldown" = 180 SECONDS, "requires_level_70" = TRUE, "requires_breach" = TRUE))
	initialize_skill("heat_manipulation", 75 SECONDS, list("base_cooldown" = 75 SECONDS, "requires_level_45" = TRUE))

	// Set up default containment protocols and security measures
	setup_default_containment()

/mob/living/carbon/scp/scp457/Destroy()
	created_fires = list()
	consumed_targets = list()
	return ..()

// Skill-based abilities for SCP-457
/mob/living/carbon/scp/scp457/proc/spread_flame_ability()
	if(!use_skill("spread_flame", 1, 0.8))
		return

	to_chat(src, "<span class='notice'>You spread your flames. Heat level: [heat_level]/[max_heat]</span>")
	// Create fires in a pattern
	for(var/turf/T in range(flame_radius, src))
		if(prob(30) && !T.density)
			create_fire_at_turf(T)

/mob/living/carbon/scp/scp457/proc/create_fire_ability()
	if(!use_skill("create_fire", 2, 1.0))
		return

	var/list/target_turfs = list()
	for(var/turf/T in view(5, src))
		if(!T.density && !locate(/obj/effect) in T)
			target_turfs += T

	if(!target_turfs.len)
		to_chat(src, "<span class='warning'>No suitable locations to create fire.</span>")
		return

	var/turf/chosen_turf = input(src, "Choose a location to create fire:", "Create Fire") as null|anything in target_turfs
	if(chosen_turf)
		create_fire_at_turf(chosen_turf)
		to_chat(src, "<span class='notice'>You create a fire at the chosen location.</span>")

/mob/living/carbon/scp/scp457/proc/manipulate_heat_ability()
	if(!use_skill("manipulate_heat", 3, 1.2))
		return

	var/list/options = list("Increase Heat", "Decrease Heat", "Maximize Heat", "Stabilize Heat")
	var/choice = input(src, "Choose heat manipulation:", "Manipulate Heat") as null|anything in options

	switch(choice)
		if("Increase Heat")
			heat_level = min(max_heat, heat_level + 20)
			to_chat(src, "<span class='notice'>You increase your heat level to [heat_level]/[max_heat].</span>")
		if("Decrease Heat")
			heat_level = max(0, heat_level - 20)
			to_chat(src, "<span class='notice'>You decrease your heat level to [heat_level]/[max_heat].</span>")
		if("Maximize Heat")
			heat_level = max_heat
			to_chat(src, "<span class='notice'>You maximize your heat level to [heat_level]/[max_heat].</span>")
		if("Stabilize Heat")
			heat_level = max_heat / 2
			to_chat(src, "<span class='notice'>You stabilize your heat level to [heat_level]/[max_heat].</span>")

/mob/living/carbon/scp/scp457/proc/expand_radius_ability()
	if(!use_skill("expand_radius", 2, 1.5))
		return

	if(flame_radius >= max_flame_radius)
		to_chat(src, "<span class='warning'>Your flame radius is already at maximum.</span>")
		return

	flame_radius = min(max_flame_radius, flame_radius + 1)
	to_chat(src, "<span class='notice'>You expand your flame radius to [flame_radius] tiles.</span>")

/mob/living/carbon/scp/scp457/proc/consume_target_ability()
	if(!use_skill("consume_target", 4, 1.3))
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(3, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No suitable targets to consume.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to consume:", "Consume Target") as null|anything in targets
	if(target)
		visible_message("<span class='danger'>[src] begins consuming [target] with intense flames!</span>")
		target.adjustFireLoss(50)
		target.adjustBruteLoss(25)

		if(!(target in consumed_targets))
			consumed_targets += target

		if(target.stat == DEAD)
			targets_consumed++

		to_chat(src, "<span class='notice'>You consume [target] with your flames.</span>")
		add_interaction_record(target, "target_consumption")

/mob/living/carbon/scp/scp457/proc/elemental_control_ability()
	if(!use_skill("elemental_control", 5, 1.8))
		return

	var/list/options = list("Fire Storm", "Heat Wave", "Flame Barrier", "Combustion Burst")
	var/choice = input(src, "Choose elemental control:", "Elemental Control") as null|anything in options

	switch(choice)
		if("Fire Storm")
			create_fire_storm_ability()
		if("Heat Wave")
			create_heat_wave()
		if("Flame Barrier")
			create_flame_barrier()
		if("Combustion Burst")
			create_combustion_burst()

/mob/living/carbon/scp/scp457/proc/combustion_mastery_ability()
	if(!use_skill("combustion_mastery", 4, 1.6))
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets for combustion mastery.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target for combustion:", "Combustion Mastery") as null|anything in targets
	if(target)
		visible_message("<span class='danger'>[src] causes [target] to spontaneously combust!</span>")
		target.adjustFireLoss(75)
		target.adjustBruteLoss(50)

		combustion_events++
		to_chat(src, "<span class='notice'>You cause [target] to combust.</span>")

/mob/living/carbon/scp/scp457/proc/heat_absorption_ability()
	if(!use_skill("heat_absorption", 3, 1.4))
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets to absorb heat from.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to absorb heat from:", "Heat Absorption") as null|anything in targets
	if(target)
		heat_absorption = min(max_heat_absorption, heat_absorption + 10)
		target.adjustFireLoss(-20)
		to_chat(target, "<span class='notice'>You feel your body temperature drop significantly.</span>")
		to_chat(src, "<span class='notice'>You absorb heat from [target]. Absorption: [heat_absorption]/[max_heat_absorption]</span>")

/mob/living/carbon/scp/scp457/proc/create_fire_storm_ability()
	if(!use_skill("create_fire_storm", 6, 2.0))
		return

	to_chat(src, "<span class='notice'>You create a massive fire storm!</span>")
	// Create fire storm effect
	for(var/mob/living/carbon/human/H in range(15, src))
		if(H != src && !H.SCP)
			H.adjustFireLoss(60)
			H.adjustBruteLoss(30)
			to_chat(H, "<span class='danger'>You're caught in a massive fire storm!</span>")

/mob/living/carbon/scp/scp457/proc/environmental_destruction_ability()
	if(!use_skill("environmental_destruction", 7, 2.2))
		return

	to_chat(src, "<span class='notice'>You cause massive environmental destruction!</span>")
	// Cause environmental damage
	for(var/turf/T in range(flame_radius * 2, src))
		if(prob(20))
			// Damage the environment
			to_chat(src, "<span class='notice'>You cause environmental destruction.</span>")

/mob/living/carbon/scp/scp457/proc/evolve_flame_ability()
	if(!use_skill("evolve_flame", 8, 2.5))
		return

	to_chat(src, "<span class='notice'>Your flame evolves to a new stage!</span>")
	// Evolve flame
	flame_evolution_stage = min(max_flame_evolution, flame_evolution_stage + 1)
	to_chat(src, "<span class='notice'>Flame Evolution Stage: [flame_evolution_stage]/[max_flame_evolution]</span>")

/mob/living/carbon/scp/scp457/proc/heat_manipulation_ability()
	if(!use_skill("heat_manipulation", 4, 1.7))
		return

	var/list/options = list("Superheat", "Freeze", "Thermal Shock", "Heat Transfer")
	var/choice = input(src, "Choose heat manipulation:", "Heat Manipulation") as null|anything in options

	switch(choice)
		if("Superheat")
			heat_level = max_heat
			flame_intensity = max_flame_intensity
			to_chat(src, "<span class='notice'>You superheat your flames!</span>")
		if("Freeze")
			heat_level = 0
			to_chat(src, "<span class='notice'>You freeze your flames!</span>")
		if("Thermal Shock")
			for(var/mob/living/carbon/human/H in range(5, src))
				if(H != src && !H.SCP)
					H.adjustFireLoss(30)
					to_chat(H, "<span class='danger'>You experience thermal shock!</span>")
		if("Heat Transfer")
			heat_absorption = min(max_heat_absorption, heat_absorption + 20)
			to_chat(src, "<span class='notice'>You transfer heat to yourself.</span>")

// Helper abilities
/mob/living/carbon/scp/scp457/proc/create_heat_wave()
	for(var/mob/living/carbon/human/H in range(10, src))
		if(H != src && !H.SCP)
			H.adjustFireLoss(20)
			to_chat(H, "<span class='danger'>You're caught in a heat wave!</span>")

/mob/living/carbon/scp/scp457/proc/create_flame_barrier()
	visible_message("<span class='danger'>[src] creates a barrier of flames!</span>")
	// Create multiple fires in a barrier pattern
	for(var/turf/T in range(3, src))
		if(prob(50) && !T.density)
			create_fire_at_turf(T)

/mob/living/carbon/scp/scp457/proc/create_combustion_burst()
	visible_message("<span class='danger'>[src] creates a combustion burst!</span>")
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H != src && !H.SCP)
			H.adjustFireLoss(40)
			H.adjustBruteLoss(20)
			to_chat(H, "<span class='danger'>You're caught in a combustion burst!</span>")

// SCP-457 specific skill requirement checks
/mob/living/carbon/scp/scp457/check_skill_requirement(requirement, current_level)
	switch(requirement)
		if("requires_breach")
			return containment_status == "breached"
		if("requires_level_10")
			return current_level >= 10
		if("requires_level_15")
			return current_level >= 15
		if("requires_level_20")
			return current_level >= 20
		if("requires_level_25")
			return current_level >= 25
		if("requires_level_30")
			return current_level >= 30
		if("requires_level_35")
			return current_level >= 35
		if("requires_level_40")
			return current_level >= 40
		if("requires_level_45")
			return current_level >= 45
		if("requires_level_50")
			return current_level >= 50
		if("requires_level_60")
			return current_level >= 60
		if("requires_level_70")
			return current_level >= 70
		else
			return ..()

// Apply skill level effects for SCP-457
/mob/living/carbon/scp/scp457/apply_skill_level_effects(skill_name, new_level)
	switch(skill_name)
		if("spread_flame")
			if(new_level >= 20)
				to_chat(src, "<span class='notice'>Your flame spreading affects a larger area.</span>")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your flame spreading can now create fire trails.</span>")
		if("create_fire")
			if(new_level >= 25)
				to_chat(src, "<span class='notice'>Your fire creation is more efficient.</span>")
			if(new_level >= 50)
				to_chat(src, "<span class='notice'>Your fire creation can now create permanent fires.</span>")
		if("manipulate_heat")
			if(new_level >= 30)
				to_chat(src, "<span class='notice'>Your heat manipulation is more precise.</span>")
			if(new_level >= 60)
				to_chat(src, "<span class='notice'>Your heat manipulation can now affect the environment.</span>")
		if("expand_radius")
			if(new_level >= 35)
				to_chat(src, "<span class='notice'>Your radius expansion is more effective.</span>")
			if(new_level >= 70)
				to_chat(src, "<span class='notice'>Your radius expansion can now create fire zones.</span>")
		if("consume_target")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your target consumption is more efficient.</span>")
			if(new_level >= 75)
				to_chat(src, "<span class='notice'>Your target consumption can now spread to nearby targets.</span>")
		if("elemental_control")
			if(new_level >= 45)
				to_chat(src, "<span class='notice'>Your elemental control is more powerful.</span>")
			if(new_level >= 80)
				to_chat(src, "<span class='notice'>Your elemental control can now create elemental storms.</span>")
		if("combustion_mastery")
			if(new_level >= 50)
				to_chat(src, "<span class='notice'>Your combustion mastery affects more targets.</span>")
			if(new_level >= 85)
				to_chat(src, "<span class='notice'>Your combustion mastery can now cause chain reactions.</span>")
		if("heat_absorption")
			if(new_level >= 55)
				to_chat(src, "<span class='notice'>Your heat absorption is more efficient.</span>")
			if(new_level >= 90)
				to_chat(src, "<span class='notice'>Your heat absorption can now heal you.</span>")
		if("create_fire_storm")
			if(new_level >= 65)
				to_chat(src, "<span class='notice'>Your fire storms affect a larger area.</span>")
			if(new_level >= 85)
				to_chat(src, "<span class='notice'>Your fire storms can now create permanent fire zones.</span>")
		if("environmental_destruction")
			if(new_level >= 70)
				to_chat(src, "<span class='notice'>Your environmental destruction is more devastating.</span>")
			if(new_level >= 90)
				to_chat(src, "<span class='notice'>Your environmental destruction can now cause structural collapse.</span>")
		if("evolve_flame")
			if(new_level >= 75)
				to_chat(src, "<span class='notice'>Your flame evolution is more potent.</span>")
			if(new_level >= 95)
				to_chat(src, "<span class='notice'>Your flame evolution can now create new flame types.</span>")
		if("heat_manipulation")
			if(new_level >= 60)
				to_chat(src, "<span class='notice'>Your heat manipulation is more versatile.</span>")
			if(new_level >= 85)
				to_chat(src, "<span class='notice'>Your heat manipulation can now control temperature fields.</span>")

/mob/living/carbon/scp/scp457/process_scp_effects()
	. = ..()

	// Enhanced flame behavior
	if(world.time >= spread_cooldown)
		spread_cooldown = world.time + spread_cooldown_time
		heat_level = min(max_heat, heat_level + 5)
		passive_flame_spread()

	// Manage created fires
	manage_fires()

	// Process elemental mastery
	process_elemental_mastery()

	// Process combustion
	process_combustion()

	// Process heat absorption
	process_heat_absorption()

	// Process fire storm
	process_fire_storm()

	// Process flame evolution
	process_flame_evolution()

	// Process environmental destruction
	process_environmental_destruction()

// Passive flame spreading
/mob/living/carbon/scp/scp457/proc/passive_flame_spread()
	for(var/turf/T in range(flame_radius, src))
		if(prob(10) && !T.density)
			create_fire_at_turf(T)

// Create fire at specific turf
/mob/living/carbon/scp/scp457/proc/create_fire_at_turf(turf/T)
	if(!T || T.density)
		return

	// Create a fire effect
	var/obj/effect/fire_effect = new /obj/effect(T)
	fire_effect.name = "Living Flame"
	fire_effect.desc = "A flame created by SCP-457"
	fire_effect.icon = 'icons/effects/fire.dmi'
	fire_effect.icon_state = "fire1"
	fire_effect.layer = 3

	created_fires += fire_effect
	fires_created++

	// Damage nearby targets
	for(var/mob/living/L in range(1, T))
		if(L != src)
			L.adjustFireLoss(10)
			L.adjustBruteLoss(5)

	add_interaction_record(T, "fire_creation")

// Manage created fires
/mob/living/carbon/scp/scp457/proc/manage_fires()
	for(var/obj/effect/fire_effect in created_fires)
		if(!fire_effect || fire_effect.loc == null)
			created_fires -= fire_effect
			continue

		// Fire spreads naturally
		if(prob(5))
			var/list/adjacent_turfs = list()
			for(var/turf/adjacent in range(1, fire_effect))
				if(!adjacent.density && !locate(/obj/effect) in adjacent)
					adjacent_turfs += adjacent

			if(adjacent_turfs.len)
				var/turf/spread_turf = pick(adjacent_turfs)
				create_fire_at_turf(spread_turf)

// Process elemental mastery
/mob/living/carbon/scp/scp457/proc/process_elemental_mastery()
	if(heat_level >= max_heat && elemental_mastery < max_elemental_mastery)
		elemental_mastery = min(max_elemental_mastery, elemental_mastery + 1)

// Process combustion
/mob/living/carbon/scp/scp457/proc/process_combustion()
	if(flame_intensity >= max_flame_intensity && combustion_skill < max_combustion_skill)
		combustion_skill = min(max_combustion_skill, combustion_skill + 1)

// Process heat absorption
/mob/living/carbon/scp/scp457/proc/process_heat_absorption()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H != src && !H.SCP)
			// Absorb heat from humans
			if(prob(5))
				heat_absorption = min(max_heat_absorption, heat_absorption + 1)
				H.adjustFireLoss(-5) // Cool them down
				to_chat(H, "<span class='notice'>You feel strangely cooled...</span>")

// Process fire storm
/mob/living/carbon/scp/scp457/proc/process_fire_storm()
	if(fire_storm_level > 0)
		for(var/mob/living/carbon/human/H in range(fire_storm_level * 3, src))
			if(H != src && !H.SCP)
				H.adjustFireLoss(5)
				H.adjustBruteLoss(3)
				to_chat(H, "<span class='danger'>You're caught in a fire storm!</span>")

// Process flame evolution
/mob/living/carbon/scp/scp457/proc/process_flame_evolution()
	if(elemental_mastery >= max_elemental_mastery && flame_evolution_stage < max_flame_evolution)
		if(prob(1))
			evolve_flame_stage()

// Evolve flame stage
/mob/living/carbon/scp/scp457/proc/evolve_flame_stage()
	flame_evolution_stage = min(max_flame_evolution, flame_evolution_stage + 1)
	flame_evolutions++

	var/evolution_message = ""
	switch(flame_evolution_stage)
		if(2)
			evolution_message = "Your flames have evolved to include blue fire!"
		if(3)
			evolution_message = "You can now create white-hot flames!"
		if(4)
			evolution_message = "Your flames can now phase through matter!"
		if(5)
			evolution_message = "You have achieved perfect flame mastery!"

	to_chat(src, "<span class='notice'>[evolution_message] Flame Evolution: [flame_evolution_stage]/[max_flame_evolution]</span>")

// Process environmental destruction
/mob/living/carbon/scp/scp457/proc/process_environmental_destruction()
	if(environmental_destruction >= max_environmental_destruction)
		// Cause environmental damage
		for(var/turf/T in range(flame_radius, src))
			if(prob(1))
				// Damage the environment
				environmental_damage++

// Enhanced attack behavior
/mob/living/carbon/scp/scp457/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		var/damage = 30 + (heat_level / 10) + (flame_intensity * 10) + (elemental_mastery / 10)

		visible_message("<span class='danger'>[src] engulfs [L] in intense flames!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

		L.adjustBruteLoss(damage)
		L.adjustFireLoss(damage)

		// Add to consumed targets
		if(!(L in consumed_targets))
			consumed_targets += L

		// Track victim for persistence
		if(L.stat == DEAD)
			targets_consumed++

		add_interaction_record(L, "burn_attack")
		return

	return ..()

// Enhanced verbs
/mob/living/carbon/scp/scp457/verb/spread_flame()
	set name = "Spread Flame"
	set category = "SCP"
	set desc = "Spread your flames."

	spread_flame_ability()

/mob/living/carbon/scp/scp457/verb/create_fire()
	set name = "Create Fire"
	set category = "SCP"
	set desc = "Create fire at a specific location."

	create_fire_ability()

/mob/living/carbon/scp/scp457/verb/manipulate_heat()
	set name = "Manipulate Heat"
	set category = "SCP"
	set desc = "Manipulate your heat level."

	manipulate_heat_ability()

/mob/living/carbon/scp/scp457/verb/expand_radius()
	set name = "Expand Radius"
	set category = "SCP"
	set desc = "Expand your flame radius."

	expand_radius_ability()

/mob/living/carbon/scp/scp457/verb/consume_target()
	set name = "Consume Target"
	set category = "SCP"
	set desc = "Consume a target with intense flames."

	consume_target_ability()

/mob/living/carbon/scp/scp457/verb/elemental_control()
	set name = "Elemental Control"
	set category = "SCP"
	set desc = "Use advanced elemental control."

	elemental_control_ability()

/mob/living/carbon/scp/scp457/verb/combustion_mastery()
	set name = "Combustion Mastery"
	set category = "SCP"
	set desc = "Use combustion mastery on targets."

	combustion_mastery_ability()

/mob/living/carbon/scp/scp457/verb/heat_absorption()
	set name = "Heat Absorption"
	set category = "SCP"
	set desc = "Absorb heat from targets."

	heat_absorption_ability()

/mob/living/carbon/scp/scp457/verb/create_fire_storm()
	set name = "Create Fire Storm"
	set category = "SCP"
	set desc = "Create a devastating fire storm."

	create_fire_storm_ability()

/mob/living/carbon/scp/scp457/verb/environmental_destruction()
	set name = "Environmental Destruction"
	set category = "SCP"
	set desc = "Cause environmental destruction."

	environmental_destruction_ability()

/mob/living/carbon/scp/scp457/verb/evolve_flame()
	set name = "Evolve Flame"
	set category = "SCP"
	set desc = "Evolve your flame abilities."

	evolve_flame_ability()

/mob/living/carbon/scp/scp457/verb/heat_manipulation()
	set name = "Heat Manipulation"
	set category = "SCP"
	set desc = "Use advanced heat manipulation."

	heat_manipulation_ability()

// Enhanced persistence data view
/mob/living/carbon/scp/scp457/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-457 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-457 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Fires Created:</b> [fires_created]<br>"
	message += "<b>Targets Consumed:</b> [targets_consumed]<br>"
	message += "<b>Heat Manipulations:</b> [heat_manipulations]<br>"
	message += "<b>Elemental Masteries:</b> [elemental_masteries]<br>"
	message += "<b>Combustion Events:</b> [combustion_events]<br>"
	message += "<b>Fire Storms Created:</b> [fire_storms_created]<br>"
	message += "<b>Environmental Damage:</b> [environmental_damage]<br>"
	message += "<b>Flame Evolutions:</b> [flame_evolutions]<br>"
	message += "<b>Created Fires:</b> [created_fires.len]<br>"
	message += "<b>Consumed Targets:</b> [consumed_targets.len]<br>"
	message += "<b>Elemental Mastery:</b> [elemental_mastery]/[max_elemental_mastery]<br>"
	message += "<b>Combustion Skill:</b> [combustion_skill]/[max_combustion_skill]<br>"
	message += "<b>Heat Absorption:</b> [heat_absorption]/[max_heat_absorption]<br>"
	message += "<b>Fire Storm Level:</b> [fire_storm_level]/[max_fire_storm_level]<br>"
	message += "<b>Environmental Destruction:</b> [environmental_destruction]/[max_environmental_destruction]<br>"
	message += "<b>Flame Evolution Stage:</b> [flame_evolution_stage]/[max_flame_evolution]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")
