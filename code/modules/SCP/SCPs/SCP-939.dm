// SCP-939 - With Many Voices
// A reptilian creature that hunts in packs

/mob/living/carbon/scp/scp939
	name = "SCP-939"
	desc = "A large, reptilian creature with sharp claws and teeth."
	icon = 'icons/scp/nonhumanoidscps(32x32).dmi'
	icon_state = "scp939"
	real_name = "SCP-939"

	// Maximum Enhanced SCP-939 variables
	var/list/pack_members = list()
	var/list/hunting_targets = list()
	var/list/mimicked_voices = list()
	var/list/territory_areas = list()
	var/list/psychological_profiles = list()
	var/list/hunting_strategies = list()
	var/list/voice_evolution_data = list()
	var/hunt_mode = FALSE
	var/pack_coordination = 0
	var/max_pack_coordination = 100
	var/voice_mimicry_skill = 0
	var/max_voice_mimicry = 100
	var/speech_cooldown = 0
	var/speech_cooldown_time = 15 SECONDS
	var/territory_control = 0
	var/max_territory_control = 100
	var/psychological_manipulation = 0
	var/max_psychological_manipulation = 100
	var/hunting_experience = 0
	var/max_hunting_experience = 100
	var/voice_evolution_stage = 1
	var/max_voice_evolution = 5
	var/territory_radius = 10
	var/max_territory_radius = 20
	var/pack_hierarchy_rank = 1
	var/max_pack_hierarchy = 5

	// Persistence tracking
	var/hunts_completed = 0
	var/victims_hunted = 0
	var/voices_mimicked = 0
	var/pack_communications = 0
	var/territories_claimed = 0
	var/psychological_manipulations = 0
	var/hunting_strategies_developed = 0
	var/voice_evolutions_completed = 0

/mob/living/carbon/scp/scp939/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP_datum = new /datum/scp(
		src,
		"SCP-939",
		SCP_KETER,
		"939",
		SCP_PLAYABLE
	)

	SCP_datum.min_playercount = 25
	SCP_datum.min_time = 40 MINUTES

	// Set up SCP-specific properties
	max_scp_health = 350
	scp_health = max_scp_health
	max_scp_armor = 100
	scp_armor = max_scp_armor

	// Add maximum enhanced abilities
	add_ability("find_pack", "find_pack_ability")
	add_ability("mimic_voice", "mimic_voice_ability")
	add_ability("coordinate_pack", "coordinate_pack_ability")
	add_ability("start_hunt", "start_hunt_ability")
	add_ability("use_mimicked_voice", "use_mimicked_voice_ability")
	add_ability("claim_territory", "claim_territory_ability")
	add_ability("develop_strategy", "develop_strategy_ability")
	add_ability("evolve_voice", "evolve_voice_ability")
	add_ability("psychological_warfare", "psychological_warfare_ability")
	add_ability("pack_hierarchy", "pack_hierarchy_ability")
	add_ability("territory_defense", "territory_defense_ability")
	add_ability("advanced_hunting", "advanced_hunting_ability")

	// Add passive effects
	add_passive_effect("pack_instincts")
	add_passive_effect("hunting_instincts")
	add_passive_effect("voice_mimicry")
	add_passive_effect("territory_control")
	add_passive_effect("psychological_manipulation")
	add_passive_effect("voice_evolution")
	add_passive_effect("pack_hierarchy")
	add_passive_effect("advanced_hunting")

/mob/living/carbon/scp/scp939/Destroy()
	pack_members.Cut()
	hunting_targets.Cut()
	mimicked_voices.Cut()
	territory_areas.Cut()
	psychological_profiles.Cut()
	hunting_strategies.Cut()
	voice_evolution_data.Cut()
	return ..()

// Override core mechanics
/mob/living/carbon/scp/scp939/process_scp_effects()
	. = ..()

	// Find pack members
	find_pack_members()

	// Coordinate with pack
	if(pack_members.len > 0)
		coordinate_with_pack()

	// Hunt behavior
	if(hunt_mode)
		execute_hunt()

	// Practice voice mimicry
	practice_voice_mimicry()

	// Territory management
	manage_territory()

	// Psychological warfare
	conduct_psychological_warfare()

	// Voice evolution
	process_voice_evolution()

	// Pack hierarchy management
	manage_pack_hierarchy()

// Find other SCP-939 pack members
/mob/living/carbon/scp/scp939/proc/find_pack_members()
	for(var/mob/living/carbon/scp/scp939/other in view(15, src))
		if(other != src && !(other in pack_members))
			pack_members += other
			other.pack_members += src
			pack_communications++

			// Establish hierarchy
			if(pack_hierarchy_rank > other.pack_hierarchy_rank)
				other.pack_hierarchy_rank = pack_hierarchy_rank - 1

			visible_message("<span class='notice'>[src] and [other] recognize each other as pack members!</span>")
			to_chat(src, "<span class='notice'>You have found a pack member! Hierarchy: [pack_hierarchy_rank]/[max_pack_hierarchy]</span>")

			add_interaction_record(other, "pack_member_found")

// Coordinate with pack members
/mob/living/carbon/scp/scp939/proc/coordinate_with_pack()
	if(pack_members.len == 0)
		return

	// Increase pack coordination
	pack_coordination = min(max_pack_coordination, pack_coordination + 1)

	// Share information with pack
	for(var/mob/living/carbon/scp/scp939/pack_member in pack_members)
		if(get_dist(src, pack_member) <= 10)
			// Share hunting targets
			for(var/mob/living/target in hunting_targets)
				if(!(target in pack_member.hunting_targets))
					pack_member.hunting_targets += target

			// Share mimicked voices
			for(var/voice in mimicked_voices)
				if(!(voice in pack_member.mimicked_voices))
					pack_member.mimicked_voices += voice

			// Share territory information
			for(var/area/territory in territory_areas)
				if(!(territory in pack_member.territory_areas))
					pack_member.territory_areas += territory

			// Share hunting strategies
			for(var/strategy in hunting_strategies)
				if(!(strategy in pack_member.hunting_strategies))
					pack_member.hunting_strategies += strategy

// Execute hunting behavior
/mob/living/carbon/scp/scp939/proc/execute_hunt()
	if(!hunting_targets.len)
		hunt_mode = FALSE
		return

	// Find closest target
	var/mob/living/closest_target = null
	var/shortest_distance = 999

	for(var/mob/living/target in hunting_targets)
		if(target.stat == DEAD)
			hunting_targets -= target
			continue

		var/distance = get_dist(src, target)
		if(distance < shortest_distance)
			shortest_distance = distance
			closest_target = target

	if(closest_target)
		// Use advanced hunting strategies
		apply_hunting_strategy(closest_target)

		// Move towards target
		step_towards(src, closest_target)

		// Attack if close enough
		if(get_dist(src, closest_target) <= 1)
			UnarmedAttack(closest_target)

		// Use voice mimicry to lure target
		if(world.time >= speech_cooldown && mimicked_voices.len > 0 && prob(20))
			use_mimicked_voice_internal(closest_target)

// Apply hunting strategies
/mob/living/carbon/scp/scp939/proc/apply_hunting_strategy(mob/living/target)
	if(!hunting_strategies.len)
		return

	var/strategy = pick(hunting_strategies)
	switch(strategy)
		if("ambush")
			if(get_dist(src, target) <= 3)
				visible_message("<span class='danger'>[src] ambushes [target] from the shadows!</span>")
				target.adjustBruteLoss(20)
		if("psychological")
			to_chat(target, "<span class='danger'>You feel an overwhelming sense of dread...</span>")
		if("coordinated")
			for(var/mob/living/carbon/scp/scp939/pack_member in pack_members)
				if(get_dist(pack_member, target) <= 5)
					step_towards(pack_member, target)

// Practice voice mimicry
/mob/living/carbon/scp/scp939/proc/practice_voice_mimicry()
	// Listen to nearby humans for voice patterns
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H == src || H.SCP)
			continue

		// Practice mimicking their voice
		if(world.time >= speech_cooldown && prob(5))
			practice_mimicry(H)

// Practice mimicking a specific human
/mob/living/carbon/scp/scp939/proc/practice_mimicry(mob/living/carbon/human/target)
	speech_cooldown = world.time + speech_cooldown_time

	var/voice_pattern = "Voice of [target.name]"
	if(!(voice_pattern in mimicked_voices))
		mimicked_voices += voice_pattern
		voices_mimicked++
		voice_mimicry_skill = min(max_voice_mimicry, voice_mimicry_skill + 5)

		// Create psychological profile
		var/profile = "Profile of [target.name]"
		if(!(profile in psychological_profiles))
			psychological_profiles += profile

		visible_message("<span class='notice'>[src] appears to be studying [target]'s voice patterns.</span>")
		to_chat(src, "<span class='notice'>You have learned to mimic [target]'s voice!</span>")

		add_interaction_record(target, "voice_mimicry_practice")

// Use mimicked voice to lure target
/mob/living/carbon/scp/scp939/proc/use_mimicked_voice_internal(mob/living/target)
	if(!mimicked_voices.len)
		return

	speech_cooldown = world.time + speech_cooldown_time

	var/voice_pattern = pick(mimicked_voices)
	var/message = generate_luring_message()

	visible_message("<span class='notice'>[src] speaks in [voice_pattern]: \"[message]\"</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 30, TRUE)

	// Lure the target
	if(target && ishuman(target))
		var/mob/living/carbon/human/H = target
		to_chat(H, "<span class='notice'>You hear a familiar voice calling for help...</span>")

		// Apply psychological effects
		apply_psychological_effect(H)

// Generate luring message
/mob/living/carbon/scp/scp939/proc/generate_luring_message()
	var/list/messages = list(
		"Help me! I'm hurt!",
		"Please, I need assistance!",
		"Someone help! I'm trapped!",
		"Can anyone hear me? I need help!",
		"Please come quickly! It's urgent!",
		"I think I'm bleeding! Help!",
		"Someone please! I can't move!",
		"Help! I'm scared!",
		"Please don't leave me here!",
		"I need medical attention!",
		"Please, I'm begging you!",
		"I can hear you! Please help!",
		"I'm so cold... please help me...",
		"I don't want to die alone...",
		"Someone, anyone, please!"
	)

	return pick(messages)

// Manage territory
/mob/living/carbon/scp/scp939/proc/manage_territory()
	for(var/area/territory in territory_areas)
		// Patrol territory
		for(var/mob/living/carbon/human/H in range(territory_radius, src))
			if(H != src && !H.SCP)
				// Intimidate intruders
				if(prob(10))
					to_chat(H, "<span class='danger'>You feel like you're being watched...</span>")

// Conduct psychological warfare
/mob/living/carbon/scp/scp939/proc/conduct_psychological_warfare()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H == src || H.SCP)
			continue

		if(prob(5))
			apply_psychological_effect(H)

// Apply psychological effects
/mob/living/carbon/scp/scp939/proc/apply_psychological_effect(mob/living/carbon/human/target)
	var/list/effects = list(
		"<span class='danger'>You feel an overwhelming sense of paranoia...</span>",
		"<span class='danger'>Your heart races with unexplained fear...</span>",
		"<span class='danger'>You hear whispers in the darkness...</span>",
		"<span class='danger'>A cold sweat breaks out on your skin...</span>",
		"<span class='danger'>You feel like something is following you...</span>"
	)

	to_chat(target, pick(effects))
	target.adjustBruteLoss(2)
	psychological_manipulation = min(max_psychological_manipulation, psychological_manipulation + 1)

// Process voice evolution
/mob/living/carbon/scp/scp939/proc/process_voice_evolution()
	if(voice_mimicry_skill >= max_voice_mimicry && voice_evolution_stage < max_voice_evolution)
		if(prob(1))
			evolve_voice_stage()

// Evolve voice stage
/mob/living/carbon/scp/scp939/proc/evolve_voice_stage()
	voice_evolution_stage = min(max_voice_evolution, voice_evolution_stage + 1)
	voice_evolutions_completed++

	var/evolution_message = ""
	switch(voice_evolution_stage)
		if(2)
			evolution_message = "Your voice mimicry has evolved to include emotional tones!"
		if(3)
			evolution_message = "You can now mimic multiple voices simultaneously!"
		if(4)
			evolution_message = "Your voice mimicry can now include complex conversations!"
		if(5)
			evolution_message = "You have achieved perfect voice mimicry mastery!"

	to_chat(src, "<span class='notice'>[evolution_message] Voice Evolution: [voice_evolution_stage]/[max_voice_evolution]</span>")

// Manage pack hierarchy
/mob/living/carbon/scp/scp939/proc/manage_pack_hierarchy()
	if(pack_members.len > 0)
		// Establish dominance
		for(var/mob/living/carbon/scp/scp939/pack_member in pack_members)
			if(pack_hierarchy_rank > pack_member.pack_hierarchy_rank)
				pack_member.pack_hierarchy_rank = pack_hierarchy_rank - 1

// Enhanced attack behavior
/mob/living/carbon/scp/scp939/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		var/damage = 40 + (pack_coordination / 10) + (hunting_experience / 5)

		visible_message("<span class='danger'>[src] viciously attacks [L] with its claws!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

		L.adjustBruteLoss(damage)

		// Add to hunting targets if not already there
		if(!(L in hunting_targets))
			hunting_targets += L

		// Track victim for persistence
		if(L.stat == DEAD)
			victims_hunted++
			hunting_experience = min(max_hunting_experience, hunting_experience + 5)

		add_interaction_record(L, "hunt_attack")
		return

	return ..()

// Maximum enhanced abilities
/mob/living/carbon/scp/scp939/proc/find_pack_ability()
	to_chat(src, "<span class='notice'>You search for pack members. Found: [pack_members.len]</span>")

/mob/living/carbon/scp/scp939/proc/mimic_voice_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets nearby to mimic.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to mimic:", "Mimic Voice") as null|anything in targets
	if(target)
		practice_mimicry(target)

/mob/living/carbon/scp/scp939/proc/coordinate_pack_ability()
	if(pack_members.len == 0)
		to_chat(src, "<span class='warning'>You have no pack members to coordinate with.</span>")
		return

	pack_coordination = min(max_pack_coordination, pack_coordination + 20)
	to_chat(src, "<span class='notice'>You coordinate with your pack. Coordination: [pack_coordination]/[max_pack_coordination]</span>")

	// Share coordination with pack members
	for(var/mob/living/carbon/scp/scp939/pack_member in pack_members)
		if(get_dist(src, pack_member) <= 15)
			pack_member.pack_coordination = min(pack_member.max_pack_coordination, pack_member.pack_coordination + 10)

/mob/living/carbon/scp/scp939/proc/start_hunt_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(10, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No suitable hunting targets nearby.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a hunting target:", "Start Hunt") as null|anything in targets
	if(target)
		hunting_targets += target
		hunt_mode = TRUE
		hunts_completed++

		to_chat(src, "<span class='notice'>You begin hunting [target]!</span>")
		visible_message("<span class='danger'>[src] begins stalking [target]!</span>")

		// Coordinate with pack
		for(var/mob/living/carbon/scp/scp939/pack_member in pack_members)
			if(get_dist(src, pack_member) <= 15)
				pack_member.hunting_targets += target
				pack_member.hunt_mode = TRUE

/mob/living/carbon/scp/scp939/proc/use_mimicked_voice_ability()
	if(!mimicked_voices.len)
		to_chat(src, "<span class='warning'>You haven't learned any voices to mimic yet.</span>")
		return

	if(world.time < speech_cooldown)
		to_chat(src, "<span class='warning'>You need to wait before using voice mimicry again.</span>")
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets nearby to lure.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target to lure:", "Use Mimicked Voice") as null|anything in targets
	if(target)
		use_mimicked_voice_internal(target)

/mob/living/carbon/scp/scp939/proc/claim_territory_ability()
	var/list/areas = list()
	for(var/area/A in range(territory_radius, src))
		if(!(A in territory_areas))
			areas += A

	if(!areas.len)
		to_chat(src, "<span class='warning'>No new territories to claim nearby.</span>")
		return

	var/area/chosen_area = input(src, "Choose an area to claim as territory:", "Claim Territory") as null|anything in areas
	if(chosen_area)
		territory_areas += chosen_area
		territory_control = min(max_territory_control, territory_control + 10)
		territories_claimed++

		to_chat(src, "<span class='notice'>You claim [chosen_area] as your territory. Control: [territory_control]/[max_territory_control]</span>")

/mob/living/carbon/scp/scp939/proc/develop_strategy_ability()
	var/list/strategies = list("ambush", "psychological", "coordinated", "territorial", "evolutionary")
	var/list/available_strategies = list()

	for(var/strategy in strategies)
		if(!(strategy in hunting_strategies))
			available_strategies += strategy

	if(!available_strategies.len)
		to_chat(src, "<span class='warning'>You have developed all available hunting strategies.</span>")
		return

	var/chosen_strategy = input(src, "Choose a strategy to develop:", "Develop Strategy") as null|anything in available_strategies
	if(chosen_strategy)
		hunting_strategies += chosen_strategy
		hunting_strategies_developed++

		to_chat(src, "<span class='notice'>You develop the [chosen_strategy] hunting strategy!</span>")

/mob/living/carbon/scp/scp939/proc/evolve_voice_ability()
	if(voice_evolution_stage >= max_voice_evolution)
		to_chat(src, "<span class='warning'>Your voice has reached maximum evolution.</span>")
		return

	if(voice_mimicry_skill < max_voice_mimicry)
		to_chat(src, "<span class='warning'>You need more voice mimicry skill to evolve.</span>")
		return

	evolve_voice_stage()

/mob/living/carbon/scp/scp939/proc/psychological_warfare_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets nearby for psychological warfare.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target for psychological warfare:", "Psychological Warfare") as null|anything in targets
	if(target)
		apply_psychological_effect(target)
		psychological_manipulations++

		to_chat(src, "<span class='notice'>You conduct psychological warfare on [target].</span>")

/mob/living/carbon/scp/scp939/proc/pack_hierarchy_ability()
	if(pack_members.len == 0)
		to_chat(src, "<span class='warning'>You have no pack to establish hierarchy with.</span>")
		return

	pack_hierarchy_rank = min(max_pack_hierarchy, pack_hierarchy_rank + 1)

	// Update pack hierarchy
	for(var/mob/living/carbon/scp/scp939/pack_member in pack_members)
		if(pack_hierarchy_rank > pack_member.pack_hierarchy_rank)
			pack_member.pack_hierarchy_rank = pack_hierarchy_rank - 1

	to_chat(src, "<span class='notice'>You establish pack hierarchy. Rank: [pack_hierarchy_rank]/[max_pack_hierarchy]</span>")

/mob/living/carbon/scp/scp939/proc/territory_defense_ability()
	if(!territory_areas.len)
		to_chat(src, "<span class='warning'>You have no territories to defend.</span>")
		return

	// Defend all territories
	for(var/area/territory in territory_areas)
		for(var/mob/living/carbon/human/H in range(territory_radius, src))
			if(H != src && !H.SCP)
				to_chat(H, "<span class='danger'>You feel the territory's defenses closing in...</span>")
				H.adjustBruteLoss(5)

	to_chat(src, "<span class='notice'>You defend your territories.</span>")

/mob/living/carbon/scp/scp939/proc/advanced_hunting_ability()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(15, src))
		if(H != src && !H.SCP)
			targets += H

	if(!targets.len)
		to_chat(src, "<span class='warning'>No targets available for advanced hunting.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose a target for advanced hunting:", "Advanced Hunting") as null|anything in targets
	if(target)
		// Apply advanced hunting techniques
		target.adjustBruteLoss(15)
		to_chat(target, "<span class='danger'>You feel like prey being hunted by a master predator...</span>")

		hunting_experience = min(max_hunting_experience, hunting_experience + 10)
		to_chat(src, "<span class='notice'>You use advanced hunting techniques on [target]. Experience: [hunting_experience]/[max_hunting_experience]</span>")

// Enhanced status display
/mob/living/carbon/scp/scp939/get_status_tab_items()
	. = ..()
	. += "Pack Members: [pack_members.len]"
	. += "Pack Coordination: [pack_coordination]/[max_pack_coordination]"
	. += "Voice Mimicry: [voice_mimicry_skill]/[max_voice_mimicry]"
	. += "Voice Evolution: [voice_evolution_stage]/[max_voice_evolution]"
	. += "Mimicked Voices: [mimicked_voices.len]"
	. += "Hunting Targets: [hunting_targets.len]"
	. += "Hunt Mode: [hunt_mode ? "Active" : "Inactive"]"
	. += "Territory Control: [territory_control]/[max_territory_control]"
	. += "Territories: [territory_areas.len]"
	. += "Psychological: [psychological_manipulation]/[max_psychological_manipulation]"
	. += "Hunting Experience: [hunting_experience]/[max_hunting_experience]"
	. += "Pack Hierarchy: [pack_hierarchy_rank]/[max_pack_hierarchy]"
	. += "Hunting Strategies: [hunting_strategies.len]"
	. += "Hunts Completed: [hunts_completed]"
	. += "Victims Hunted: [victims_hunted]"

// Override examine behavior
/mob/living/carbon/scp/scp939/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-939, a reptilian creature that hunts in packs and mimics human speech.</span>")
		else
			to_chat(user, "<span class='danger'>A large reptilian creature with sharp claws. It seems to be studying you intently.</span>")

// Override SCP death
/mob/living/carbon/scp/scp939/scp_death()
	visible_message("<span class='danger'>[src] collapses and stops moving!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	// Notify pack members
	for(var/mob/living/carbon/scp/scp939/pack_member in pack_members)
		to_chat(pack_member, "<span class='danger'>You feel the loss of a pack member!</span>")
		pack_member.pack_members -= src

	..()

// Enhanced verbs
/mob/living/carbon/scp/scp939/verb/find_pack()
	set name = "Find Pack"
	set category = "SCP"
	set desc = "Search for pack members."

	find_pack_ability()

/mob/living/carbon/scp/scp939/verb/mimic_voice()
	set name = "Mimic Voice"
	set category = "SCP"
	set desc = "Mimic the voice of a nearby human."

	mimic_voice_ability()

/mob/living/carbon/scp/scp939/verb/coordinate_pack()
	set name = "Coordinate Pack"
	set category = "SCP"
	set desc = "Coordinate with your pack members."

	coordinate_pack_ability()

/mob/living/carbon/scp/scp939/verb/start_hunt()
	set name = "Start Hunt"
	set category = "SCP"
	set desc = "Begin hunting a specific target."

	start_hunt_ability()

/mob/living/carbon/scp/scp939/verb/use_mimicked_voice()
	set name = "Use Mimicked Voice"
	set category = "SCP"
	set desc = "Use a mimicked voice to lure targets."

	use_mimicked_voice_ability()

/mob/living/carbon/scp/scp939/verb/claim_territory()
	set name = "Claim Territory"
	set category = "SCP"
	set desc = "Claim an area as your territory."

	claim_territory_ability()

/mob/living/carbon/scp/scp939/verb/develop_strategy()
	set name = "Develop Strategy"
	set category = "SCP"
	set desc = "Develop a new hunting strategy."

	develop_strategy_ability()

/mob/living/carbon/scp/scp939/verb/evolve_voice()
	set name = "Evolve Voice"
	set category = "SCP"
	set desc = "Evolve your voice mimicry abilities."

	evolve_voice_ability()

/mob/living/carbon/scp/scp939/verb/psychological_warfare()
	set name = "Psychological Warfare"
	set category = "SCP"
	set desc = "Conduct psychological warfare on a target."

	psychological_warfare_ability()

/mob/living/carbon/scp/scp939/verb/pack_hierarchy()
	set name = "Pack Hierarchy"
	set category = "SCP"
	set desc = "Establish pack hierarchy."

	pack_hierarchy_ability()

/mob/living/carbon/scp/scp939/verb/territory_defense()
	set name = "Territory Defense"
	set category = "SCP"
	set desc = "Defend your territories."

	territory_defense_ability()

/mob/living/carbon/scp/scp939/verb/advanced_hunting()
	set name = "Advanced Hunting"
	set category = "SCP"
	set desc = "Use advanced hunting techniques."

	advanced_hunting_ability()

// Enhanced persistence data view
/mob/living/carbon/scp/scp939/view_persistence_data()
	set name = "View Persistence Data"
	set category = "SCP"
	set desc = "View SCP-939 persistence data."

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-939 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Hunts Completed:</b> [hunts_completed]<br>"
	message += "<b>Voices Mimicked:</b> [voices_mimicked]<br>"
	message += "<b>Pack Communications:</b> [pack_communications]<br>"
	message += "<b>Territories Claimed:</b> [territories_claimed]<br>"
	message += "<b>Psychological Manipulations:</b> [psychological_manipulations]<br>"
	message += "<b>Hunting Strategies Developed:</b> [hunting_strategies_developed]<br>"
	message += "<b>Voice Evolutions Completed:</b> [voice_evolutions_completed]<br>"
	message += "<b>Victims Hunted:</b> [victims_hunted]<br>"
	message += "<b>Pack Members:</b> [pack_members.len]<br>"
	message += "<b>Mimicked Voices:</b> [mimicked_voices.len]<br>"
	message += "<b>Territory Areas:</b> [territory_areas.len]<br>"
	message += "<b>Hunting Strategies:</b> [hunting_strategies.len]<br>"
	message += "<b>Voice Evolution Stage:</b> [voice_evolution_stage]/[max_voice_evolution]<br>"
	message += "<b>Pack Hierarchy Rank:</b> [pack_hierarchy_rank]/[max_pack_hierarchy]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [instance.interaction_history.len] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")
