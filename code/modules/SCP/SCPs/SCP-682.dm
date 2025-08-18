// SCP-682 - The Hard-to-Destroy Reptile
// A massive, vaguely reptilian creature with powerful regenerative abilities and extreme hostility towards all life

/mob/living/carbon/scp/scp682
	name = "SCP-682"
	desc = "A massive, vaguely reptilian creature with powerful regenerative abilities and extreme hostility towards all life."
	icon = 'icons/scp/nonhumanoidscps(32x32).dmi'
	icon_state = "scp682"
	use_custom_sprite = TRUE
	real_name = "SCP-682"

	// Maximum Enhanced SCP-682 variables
	var/adaptation_level = 0
	var/max_adaptation = 100
	var/regeneration_rate = 5
	var/regeneration_cooldown = 0
	var/regeneration_cooldown_time = 10 SECONDS
	var/rage_level = 0
	var/max_rage = 100
	var/list/adaptations = list()
	var/list/damage_history = list()
	var/containment_acid_level = 0
	var/max_acid_level = 100
	var/evolution_stage = 1
	var/max_evolution_stage = 5
	var/destruction_potential = 0
	var/max_destruction_potential = 100
	var/containment_breach_level = 0
	var/max_containment_breach = 100
	var/adaptation_mastery = 0
	var/max_adaptation_mastery = 100
	var/rage_mastery = 0
	var/max_rage_mastery = 100
	var/regeneration_mastery = 0
	var/max_regeneration_mastery = 100
	// Note: containment_resistance and max_containment_resistance are inherited from base SCP type
	var/evolution_cooldown = 0
	var/evolution_cooldown_time = 30 SECONDS
	var/rage_burst_cooldown = 0
	var/rage_burst_cooldown_time = 20 SECONDS
	var/adaptation_cooldown = 0
	var/adaptation_cooldown_time = 15 SECONDS

	// Persistence tracking
	var/damage_taken = 0
	var/damage_dealt = 0
	var/adaptations_developed = 0
	var/containment_breaches = 0
	var/evolution_events = 0
	var/destruction_events = 0
	var/rage_bursts = 0
	var/adaptation_masteries = 0
	var/containment_resistances = 0

/mob/living/carbon/scp/scp682/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-682",
		SCP_KETER,
		"682",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 30
	SCP_datum.min_time = 60 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 1000
	scp_health = max_scp_health
	max_scp_armor = 300
	scp_armor = max_scp_armor

	// Add maximum enhanced abilities
	add_ability("rage_attack", "rage_attack_ability")
	add_ability("escape_containment", "escape_containment_ability")
	add_ability("view_adaptations", "view_adaptations_ability")
	add_ability("evolve", "evolve_ability")
	add_ability("rage_burst", "rage_burst_ability")
	add_ability("adaptation_mastery", "adaptation_mastery_ability")
	add_ability("containment_resistance", "containment_resistance_ability")
	add_ability("destruction_potential", "destruction_potential_ability")
	add_ability("regeneration_mastery", "regeneration_mastery_ability")
	add_ability("rage_mastery", "rage_mastery_ability")
	add_ability("ultimate_destruction", "ultimate_destruction_ability")
	add_ability("adaptation_synthesis", "adaptation_synthesis_ability")

	// Add passive effects
	add_passive_effect("regeneration")
	add_passive_effect("adaptation_development")
	add_passive_effect("rage_escalation")
	add_passive_effect("evolution")
	add_passive_effect("destruction_potential")
	add_passive_effect("containment_resistance")
	add_passive_effect("adaptation_mastery")
	add_passive_effect("rage_mastery")
	add_passive_effect("regeneration_mastery")

	// Initialize SCP-682 specific skills with cooldowns and requirements
	initialize_skill("rage_attack", 15 SECONDS, list("base_cooldown" = 15 SECONDS))
	initialize_skill("escape_containment", 60 SECONDS, list("base_cooldown" = 60 SECONDS, "requires_level_20" = TRUE))
	initialize_skill("view_adaptations", 30 SECONDS, list("base_cooldown" = 30 SECONDS, "requires_level_10" = TRUE))
	initialize_skill("evolve", 120 SECONDS, list("base_cooldown" = 120 SECONDS, "requires_level_30" = TRUE))
	initialize_skill("rage_burst", 45 SECONDS, list("base_cooldown" = 45 SECONDS, "requires_level_25" = TRUE))
	initialize_skill("adaptation_mastery", 90 SECONDS, list("base_cooldown" = 90 SECONDS, "requires_level_35" = TRUE))
	initialize_skill("containment_resistance", 75 SECONDS, list("base_cooldown" = 75 SECONDS, "requires_level_40" = TRUE))
	initialize_skill("destruction_potential", 150 SECONDS, list("base_cooldown" = 150 SECONDS, "requires_level_50" = TRUE, "requires_breach" = TRUE))
	initialize_skill("regeneration_mastery", 60 SECONDS, list("base_cooldown" = 60 SECONDS, "requires_level_30" = TRUE))
	initialize_skill("rage_mastery", 80 SECONDS, list("base_cooldown" = 80 SECONDS, "requires_level_45" = TRUE))
	initialize_skill("ultimate_destruction", 300 SECONDS, list("base_cooldown" = 300 SECONDS, "requires_level_70" = TRUE, "requires_breach" = TRUE))
	initialize_skill("adaptation_synthesis", 180 SECONDS, list("base_cooldown" = 180 SECONDS, "requires_level_60" = TRUE, "requires_breach" = TRUE))

	// Set up default containment protocols and security measures
	setup_default_containment()

/mob/living/carbon/scp/scp682/Destroy()
	adaptations = list()
	damage_history = list()
	return ..()

// Override core mechanics
/mob/living/carbon/scp/scp682/process_scp_effects()
	. = ..()

	// Regeneration
	if(world.time >= regeneration_cooldown)
		regenerate()

	// Adaptation development
	develop_adaptations()

	// Rage management
	manage_rage()

	// Containment acid effects
	process_containment_acid()

	// Evolution processing
	process_evolution()

	// Destruction potential processing
	process_destruction_potential()

	// Containment resistance processing
	process_containment_resistance()

	// Find and attack targets
	var/mob/living/target = find_target()
	if(target)
		attack_target(target)

	// Award research points to nearby researchers
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP) // Skip SCPs
			continue

		// Award research points for observing SCP-682
		award_research_points("682", "behavior", 3, H.ckey)

// Enhanced regeneration system
/mob/living/carbon/scp/scp682/proc/regenerate()
	regeneration_cooldown = world.time + regeneration_cooldown_time

	var/heal_amount = regeneration_rate * (1 + (adaptation_level / 50)) * (1 + (regeneration_mastery / 100))
	adjust_scp_health(heal_amount)

	if(scp_health < max_scp_health)
		visible_message("<span class='notice'>[src]'s wounds begin to heal rapidly!</span>")

// Enhanced adaptation development
/mob/living/carbon/scp/scp682/proc/develop_adaptations()
	if(adaptation_level >= max_adaptation)
		return

	// Develop adaptations based on damage taken
	if(damage_taken > 0 && prob(10))
		develop_adaptation()

// Develop a specific adaptation
/mob/living/carbon/scp/scp682/proc/develop_adaptation()
	var/list/possible_adaptations = list(
		"acid_resistance",
		"fire_resistance",
		"bullet_resistance",
		"explosive_resistance",
		"radiation_resistance",
		"poison_resistance",
		"freeze_resistance",
		"electric_resistance",
		"psychic_resistance",
		"reality_resistance"
	)

	var/list/available_adaptations = list()
	for(var/adaptation in possible_adaptations)
		if(!(adaptation in adaptations))
			available_adaptations += adaptation

	if(available_adaptations.len)
		var/chosen_adaptation = pick(available_adaptations)
		adaptations += chosen_adaptation
		adaptation_level = min(max_adaptation, adaptation_level + 10)
		adaptations_developed++

		visible_message("<span class='danger'>[src] develops [chosen_adaptation]!</span>")
		to_chat(src, "<span class='notice'>You develop [chosen_adaptation]! Adaptation Level: [adaptation_level]/[max_adaptation]</span>")

// Enhanced rage management
/mob/living/carbon/scp/scp682/proc/manage_rage()
	// Increase rage over time
	rage_level = min(max_rage, rage_level + 1)

	// Rage affects damage output
	if(rage_level > 50)
		visible_message("<span class='danger'>[src] becomes increasingly enraged!</span>")

// Process containment acid effects
/mob/living/carbon/scp/scp682/proc/process_containment_acid()
	if(containment_acid_level > 0)
		// Acid damages SCP-682 but also increases adaptation
		adjust_scp_health(-containment_acid_level / 10)
		adaptation_level = min(max_adaptation, adaptation_level + 1)

		containment_acid_level = max(0, containment_acid_level - 1)

// Process evolution
/mob/living/carbon/scp/scp682/proc/process_evolution()
	if(adaptation_level >= max_adaptation && evolution_stage < max_evolution_stage)
		if(prob(1))
			evolve_stage()

// Evolve to next stage
/mob/living/carbon/scp/scp682/proc/evolve_stage()
	evolution_stage = min(max_evolution_stage, evolution_stage + 1)
	evolution_events++

	var/evolution_message = ""
	switch(evolution_stage)
		if(2)
			evolution_message = "You evolve enhanced regeneration and adaptation!"
		if(3)
			evolution_message = "You evolve advanced rage and destruction capabilities!"
		if(4)
			evolution_message = "You evolve containment resistance and reality manipulation!"
		if(5)
			evolution_message = "You achieve ultimate evolution - nothing can contain you!"

	to_chat(src, "<span class='notice'>[evolution_message] Evolution Stage: [evolution_stage]/[max_evolution_stage]</span>")

// Process destruction potential
/mob/living/carbon/scp/scp682/proc/process_destruction_potential()
	if(damage_dealt > 0 && prob(5))
		destruction_potential = min(max_destruction_potential, destruction_potential + 1)

// Process containment resistance
/mob/living/carbon/scp/scp682/proc/process_containment_resistance()
	if(containment_breach_level > 0)
		containment_resistance = min(max_containment_resistance, containment_resistance + 1)

// Find targets to attack
/mob/living/carbon/scp/scp682/proc/find_target()
	var/list/targets = list()
	for(var/mob/living/L in view(10, src))
		if(L != src && !L.SCP)
			targets += L

	if(targets.len)
		return pick(targets)
	return null

// Attack target with enhanced damage
/mob/living/carbon/scp/scp682/proc/attack_target(mob/living/target)
	if(!target)
		return

	var/damage = 50 + (rage_level / 2) + (adaptation_level / 4) + (evolution_stage * 20)

	visible_message("<span class='danger'>[src] viciously attacks [target]!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	target.adjustBruteLoss(damage)
	damage_dealt += damage

	add_interaction_record(target, "attack")

// Enhanced attack behavior
/mob/living/carbon/scp/scp682/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		var/damage = 60 + (rage_level / 2) + (adaptation_level / 4) + (evolution_stage * 25)

		visible_message("<span class='danger'>[src] viciously attacks [L]!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

		L.adjustBruteLoss(damage)
		damage_dealt += damage

		// Increase rage when attacking
		rage_level = min(max_rage, rage_level + 5)

		// Award research points to nearby researchers for observing attack
		for(var/mob/living/carbon/human/H in view(5, src))
			if(H != src && H != L && !H.SCP)
				award_research_points("682", "combat", 15, H.ckey)

		add_interaction_record(L, "attack")
		return

	return ..()

// Override damage to track damage types
/mob/living/carbon/scp/scp682/adjust_scp_health(amount)
	. = ..()
	if(amount < 0)
		damage_taken += abs(amount)
		damage_history += "brute"
		containment_breaches++

// Maximum enhanced abilities
/mob/living/carbon/scp/scp682/proc/rage_attack_ability()
	if(!use_skill("rage_attack", 1, 0.8))
		return

	if(rage_level < 20)
		to_chat(src, "<span class='warning'>You need more rage to perform a rage attack.</span>")
		return

	var/list/targets = list()
	for(var/mob/living/L in view(5, src))
		if(L != src && !L.SCP)
			targets += L

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets nearby for rage attack.</span>")
		return

	var/mob/living/target = pick(targets)
	var/damage = 100 + rage_level

	visible_message("<span class='danger'>[src] unleashes a devastating rage attack on [target]!</span>")
	target.adjustBruteLoss(damage)
	damage_dealt += damage

	rage_level = max(0, rage_level - 20)
	to_chat(src, "<span class='notice'>You perform a rage attack on [target]. Rage Level: [rage_level]/[max_rage]</span>")

/mob/living/carbon/scp/scp682/proc/escape_containment_ability()
	if(!use_skill("escape_containment", 3, 1.5))
		return

	containment_breach_level = min(max_containment_breach, containment_breach_level + 20)
	containment_breaches++

	visible_message("<span class='danger'>[src] attempts to breach containment!</span>")
	to_chat(src, "<span class='notice'>You attempt to breach containment. Breach Level: [containment_breach_level]/[max_containment_breach]</span>")

/mob/living/carbon/scp/scp682/proc/view_adaptations_ability()
	if(!use_skill("view_adaptations", 1, 0.5))
		return

	var/message = "<h2>SCP-682 Adaptations</h2>"
	message += "<b>Adaptation Level:</b> [adaptation_level]/[max_adaptation]<br>"
	message += "<b>Evolution Stage:</b> [evolution_stage]/[max_evolution_stage]<br>"
	message += "<b>Rage Level:</b> [rage_level]/[max_rage]<br>"
	message += "<b>Destruction Potential:</b> [destruction_potential]/[max_destruction_potential]<br>"
	message += "<b>Containment Resistance:</b> [containment_resistance]/[max_containment_resistance]<br>"

	if(adaptations.len)
		message += "<h3>Active Adaptations:</h3>"
		for(var/adaptation in adaptations)
			message += "- [adaptation]<br>"
	else
		message += "<i>No adaptations developed yet.</i>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/living/carbon/scp/scp682/proc/evolve_ability()
	if(!use_skill("evolve", 5, 1.8))
		return

	if(evolution_stage >= max_evolution_stage)
		to_chat(src, "<span class='warning'>You have reached maximum evolution.</span>")
		return

	if(adaptation_level < max_adaptation)
		to_chat(src, "<span class='warning'>You need more adaptations to evolve.</span>")
		return

	evolve_stage()

/mob/living/carbon/scp/scp682/proc/rage_burst_ability()
	if(!use_skill("rage_burst", 4, 1.3))
		return

	rage_bursts++

	// Affect all nearby targets
	for(var/mob/living/L in view(8, src))
		if(L != src && !L.SCP)
			L.adjustBruteLoss(75)
			to_chat(L, "<span class='danger'>You're caught in SCP-682's rage burst!</span>")

	visible_message("<span class='danger'>[src] unleashes a massive rage burst!</span>")
	to_chat(src, "<span class='notice'>You unleash a rage burst on all nearby targets.</span>")

/mob/living/carbon/scp/scp682/proc/adaptation_mastery_ability()
	if(!use_skill("adaptation_mastery", 3, 1.2))
		return

	if(adaptation_mastery >= max_adaptation_mastery)
		to_chat(src, "<span class='warning'>You have reached maximum adaptation mastery.</span>")
		return

	adaptation_mastery = min(max_adaptation_mastery, adaptation_mastery + 10)
	adaptation_masteries++

	to_chat(src, "<span class='notice'>You enhance your adaptation mastery. Mastery: [adaptation_mastery]/[max_adaptation_mastery]</span>")

/mob/living/carbon/scp/scp682/proc/containment_resistance_ability()
	if(!use_skill("containment_resistance", 2, 1.0))
		return

	if(containment_resistance >= max_containment_resistance)
		to_chat(src, "<span class='warning'>You have reached maximum containment resistance.</span>")
		return

	containment_resistance = min(max_containment_resistance, containment_resistance + 10)
	containment_resistances++

	to_chat(src, "<span class='notice'>You enhance your containment resistance. Resistance: [containment_resistance]/[max_containment_resistance]</span>")

/mob/living/carbon/scp/scp682/proc/destruction_potential_ability()
	if(!use_skill("destruction_potential", 6, 2.0))
		return

	if(destruction_potential >= max_destruction_potential)
		to_chat(src, "<span class='warning'>You have reached maximum destruction potential.</span>")
		return

	destruction_potential = min(max_destruction_potential, destruction_potential + 15)
	destruction_events++

	to_chat(src, "<span class='notice'>You enhance your destruction potential. Potential: [destruction_potential]/[max_destruction_potential]</span>")

/mob/living/carbon/scp/scp682/proc/regeneration_mastery_ability()
	if(!use_skill("regeneration_mastery", 2, 1.1))
		return

	if(regeneration_mastery >= max_regeneration_mastery)
		to_chat(src, "<span class='warning'>You have reached maximum regeneration mastery.</span>")
		return

	regeneration_mastery = min(max_regeneration_mastery, regeneration_mastery + 10)
	// regeneration_masteries++ // Variable not defined, removed

	to_chat(src, "<span class='notice'>You enhance your regeneration mastery. Mastery: [regeneration_mastery]/[max_regeneration_mastery]</span>")

/mob/living/carbon/scp/scp682/proc/rage_mastery_ability()
	if(!use_skill("rage_mastery", 3, 1.4))
		return

	if(rage_mastery >= max_rage_mastery)
		to_chat(src, "<span class='warning'>You have reached maximum rage mastery.</span>")
		return

	rage_mastery = min(max_rage_mastery, rage_mastery + 10)
	// rage_masteries++ // Variable not defined, removed

	to_chat(src, "<span class='notice'>You enhance your rage mastery. Mastery: [rage_mastery]/[max_rage_mastery]</span>")

/mob/living/carbon/scp/scp682/proc/ultimate_destruction_ability()
	if(!use_skill("ultimate_destruction", 8, 2.5))
		return

	to_chat(src, "<span class='notice'>You unleash ultimate destruction!</span>")
	// Affect all nearby targets with massive damage
	for(var/mob/living/L in view(20, src))
		if(L != src && !L.SCP)
			L.adjustBruteLoss(200)
			L.adjustFireLoss(100)
			to_chat(L, "<span class='danger'>You are devastated by SCP-682's ultimate destruction!</span>")

/mob/living/carbon/scp/scp682/proc/adaptation_synthesis_ability()
	if(!use_skill("adaptation_synthesis", 7, 2.2))
		return

	to_chat(src, "<span class='notice'>You synthesize new adaptations!</span>")
	// Create new adaptations
	adaptation_level = min(max_adaptation, adaptation_level + 10)
	evolution_stage = min(max_evolution_stage, evolution_stage + 1)
	to_chat(src, "<span class='notice'>Adaptation Level: [adaptation_level]/[max_adaptation], Evolution Stage: [evolution_stage]/[max_evolution_stage]</span>")

// Enhanced status display
/mob/living/carbon/scp/scp682/get_status_tab_items()
	. = ..()
	. += "Adaptation Level: [adaptation_level]/[max_adaptation]"
	. += "Evolution Stage: [evolution_stage]/[max_evolution_stage]"
	. += "Rage Level: [rage_level]/[max_rage]"
	. += "Destruction Potential: [destruction_potential]/[max_destruction_potential]"
	. += "Containment Resistance: [containment_resistance]/[max_containment_resistance]"
	. += "Adaptation Mastery: [adaptation_mastery]/[max_adaptation_mastery]"
	. += "Rage Mastery: [rage_mastery]/[max_rage_mastery]"
	. += "Regeneration Mastery: [regeneration_mastery]/[max_regeneration_mastery]"
	. += "Containment Breach: [containment_breach_level]/[max_containment_breach]"
	. += "Active Adaptations: [adaptations.len]"

// Override examine behavior
/mob/living/carbon/scp/scp682/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-682, a highly dangerous entity with extreme regenerative abilities and hostility towards all life.</span>")
		else
			to_chat(user, "<span class='danger'>A massive reptilian creature that radiates pure hatred and destruction.</span>")

// Override SCP death
/mob/living/carbon/scp/scp682/scp_death()
	visible_message("<span class='danger'>[src] collapses but continues to regenerate!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	..()

// Enhanced verbs
/mob/living/carbon/scp/scp682/verb/rage_attack()
	set name = "Rage Attack"
	set category = "SCP"
	set desc = "Perform a devastating rage attack."

	rage_attack_ability()

/mob/living/carbon/scp/scp682/verb/escape_containment()
	set name = "Escape Containment"
	set category = "SCP"
	set desc = "Attempt to breach containment."

	escape_containment_ability()

/mob/living/carbon/scp/scp682/verb/view_adaptations()
	set name = "View Adaptations"
	set category = "SCP"
	set desc = "View your current adaptations."

	view_adaptations_ability()

/mob/living/carbon/scp/scp682/verb/evolve()
	set name = "Evolve"
	set category = "SCP"
	set desc = "Evolve to the next stage."

	evolve_ability()

/mob/living/carbon/scp/scp682/verb/rage_burst()
	set name = "Rage Burst"
	set category = "SCP"
	set desc = "Unleash a rage burst on all nearby targets."

	rage_burst_ability()

/mob/living/carbon/scp/scp682/verb/adaptation_mastery()
	set name = "Adaptation Mastery"
	set category = "SCP"
	set desc = "Enhance your adaptation mastery."

	adaptation_mastery_ability()

/mob/living/carbon/scp/scp682/verb/containment_resistance()
	set name = "Containment Resistance"
	set category = "SCP"
	set desc = "Enhance your containment resistance."

	containment_resistance_ability()

/mob/living/carbon/scp/scp682/verb/destruction_potential()
	set name = "Destruction Potential"
	set category = "SCP"
	set desc = "Enhance your destruction potential."

	destruction_potential_ability()

/mob/living/carbon/scp/scp682/verb/regeneration_mastery()
	set name = "Regeneration Mastery"
	set category = "SCP"
	set desc = "Enhance your regeneration mastery."

	regeneration_mastery_ability()

/mob/living/carbon/scp/scp682/verb/rage_mastery()
	set name = "Rage Mastery"
	set category = "SCP"
	set desc = "Enhance your rage mastery."

	rage_mastery_ability()

/mob/living/carbon/scp/scp682/verb/ultimate_destruction()
	set name = "Ultimate Destruction"
	set category = "SCP"
	set desc = "Unleash ultimate destruction on the entire area."

	ultimate_destruction_ability()

/mob/living/carbon/scp/scp682/verb/adaptation_synthesis()
	set name = "Adaptation Synthesis"
	set category = "SCP"
	set desc = "Synthesize a new adaptation through mastery."

	adaptation_synthesis_ability()

// Enhanced persistence data view
/mob/living/carbon/scp/scp682/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-682 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-682 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Damage Taken:</b> [damage_taken]<br>"
	message += "<b>Damage Dealt:</b> [damage_dealt]<br>"
	message += "<b>Adaptations Developed:</b> [adaptations_developed]<br>"
	message += "<b>Containment Breaches:</b> [containment_breaches]<br>"
	message += "<b>Evolution Events:</b> [evolution_events]<br>"
	message += "<b>Destruction Events:</b> [destruction_events]<br>"
	message += "<b>Rage Bursts:</b> [rage_bursts]<br>"
	message += "<b>Adaptation Masteries:</b> [adaptation_masteries]<br>"
	message += "<b>Containment Resistances:</b> [containment_resistances]<br>"
	message += "<b>Active Adaptations:</b> [adaptations.len]<br>"
	message += "<b>Adaptation Level:</b> [adaptation_level]/[max_adaptation]<br>"
	message += "<b>Evolution Stage:</b> [evolution_stage]/[max_evolution_stage]<br>"
	message += "<b>Rage Level:</b> [rage_level]/[max_rage]<br>"
	message += "<b>Destruction Potential:</b> [destruction_potential]/[max_destruction_potential]<br>"
	message += "<b>Containment Resistance:</b> [containment_resistance]/[max_containment_resistance]<br>"
	message += "<b>Adaptation Mastery:</b> [adaptation_mastery]/[max_adaptation_mastery]<br>"
	message += "<b>Rage Mastery:</b> [rage_mastery]/[max_rage_mastery]<br>"
	message += "<b>Regeneration Mastery:</b> [regeneration_mastery]/[max_regeneration_mastery]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

// SCP-682 specific skill requirement checks
/mob/living/carbon/scp/scp682/check_skill_requirement(requirement, current_level)
	switch(requirement)
		if("requires_breach")
			return containment_status == "breached"
		if("requires_level_10")
			return current_level >= 10
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

// Apply skill level effects for SCP-682
/mob/living/carbon/scp/scp682/apply_skill_level_effects(skill_name, new_level)
	switch(skill_name)
		if("rage_attack")
			if(new_level >= 20)
				to_chat(src, "<span class='notice'>Your rage attacks affect a larger area.</span>")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your rage attacks can now hit multiple targets.</span>")
		if("escape_containment")
			if(new_level >= 25)
				to_chat(src, "<span class='notice'>Your containment escapes are more effective.</span>")
			if(new_level >= 50)
				to_chat(src, "<span class='notice'>Your containment escapes can now damage containment systems.</span>")
		if("view_adaptations")
			if(new_level >= 15)
				to_chat(src, "<span class='notice'>You can now see more detailed adaptation information.</span>")
			if(new_level >= 30)
				to_chat(src, "<span class='notice'>You can now predict future adaptations.</span>")
		if("evolve")
			if(new_level >= 35)
				to_chat(src, "<span class='notice'>Your evolution is more potent.</span>")
			if(new_level >= 70)
				to_chat(src, "<span class='notice'>Your evolution can now create new forms.</span>")
		if("rage_burst")
			if(new_level >= 30)
				to_chat(src, "<span class='notice'>Your rage burst affects a larger area.</span>")
			if(new_level >= 60)
				to_chat(src, "<span class='notice'>Your rage burst can now cause environmental damage.</span>")
		if("adaptation_mastery")
			if(new_level >= 40)
				to_chat(src, "<span class='notice'>Your adaptation mastery is more efficient.</span>")
			if(new_level >= 75)
				to_chat(src, "<span class='notice'>Your adaptation mastery can now create permanent adaptations.</span>")
		if("containment_resistance")
			if(new_level >= 45)
				to_chat(src, "<span class='notice'>Your containment resistance is more effective.</span>")
			if(new_level >= 80)
				to_chat(src, "<span class='notice'>Your containment resistance can now weaken containment systems.</span>")
		if("destruction_potential")
			if(new_level >= 55)
				to_chat(src, "<span class='notice'>Your destruction potential affects a larger area.</span>")
			if(new_level >= 85)
				to_chat(src, "<span class='notice'>Your destruction potential can now cause structural damage.</span>")
		if("regeneration_mastery")
			if(new_level >= 35)
				to_chat(src, "<span class='notice'>Your regeneration is faster.</span>")
			if(new_level >= 70)
				to_chat(src, "<span class='notice'>Your regeneration can now heal others.</span>")
		if("rage_mastery")
			if(new_level >= 50)
				to_chat(src, "<span class='notice'>Your rage mastery is more controlled.</span>")
			if(new_level >= 85)
				to_chat(src, "<span class='notice'>Your rage mastery can now influence others.</span>")
		if("ultimate_destruction")
			if(new_level >= 75)
				to_chat(src, "<span class='notice'>Your ultimate destruction affects a larger area.</span>")
			if(new_level >= 90)
				to_chat(src, "<span class='notice'>Your ultimate destruction can now cause permanent damage.</span>")
		if("adaptation_synthesis")
			if(new_level >= 65)
				to_chat(src, "<span class='notice'>Your adaptation synthesis creates more potent adaptations.</span>")
			if(new_level >= 85)
				to_chat(src, "<span class='notice'>Your adaptation synthesis can now create beneficial mutations.</span>")
