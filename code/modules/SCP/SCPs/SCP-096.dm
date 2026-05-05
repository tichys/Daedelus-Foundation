// SCP-096 - The Shy Guy
// A tall, thin humanoid that becomes enraged when its face is viewed

#define SCP096_DOCILE "docile"
#define SCP096_SCREAMING "screaming"
#define SCP096_PURSUING "pursuing"
#define SCP096_VIEW_RANGE 12
#define SCP096_SCREAM_PHASE_MIN (60 SECONDS)
#define SCP096_SCREAM_PHASE_MAX (120 SECONDS)
#define SCP096_PURSUIT_SPEED_MOD -3
#define SCP096_PURSUIT_DAMAGE 60
#define SCP096_RAGE_DAMAGE_MULT 0.15
#define SCP096_FACE_COVER_EMOTE_COOLDOWN (10 SECONDS)

/datum/movespeed_modifier/scp096_pursuit
	id = "scp096_pursuit"
	priority = 100
	slowdown = SCP096_PURSUIT_SPEED_MOD

/mob/living/carbon/human/scp096
	name = "SCP-096"
	desc = "A tall, thin humanoid figure with pale skin and disproportionately long arms. It covers its face with its hands."
	icon = 'icons/scp/scp-096.dmi'
	icon_state = "scp096"
	real_name = "SCP-096"

	var/state = SCP096_DOCILE
	var/mob/living/current_target = null
	var/list/face_viewers = list()
	var/kills_count = 0
	var/scream_phase_end = 0
	var/last_face_cover_emote = 0
	var/rage_activations = 0
	var/victims_hunted = 0
	var/containment_escapes = 0

/mob/living/carbon/human/scp096/Initialize()
	. = ..()

	set_species(/datum/species/scp096)

	SCP = new /datum/scp(src, "Shy Guy", SCP_EUCLID, "096", SCP_SENTIENT)

	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()

	remove_overlay(BODYPARTS_LAYER)
	remove_overlay(EYE_LAYER)
	remove_overlay(BODY_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	overlays_standing[EYE_LAYER] = null
	overlays_standing[BODY_LAYER] = null

	START_PROCESSING(SSobj, src)

/mob/living/carbon/human/scp096/Destroy()
	STOP_PROCESSING(SSobj, src)
	face_viewers = null
	return ..()

/mob/living/carbon/human/scp096/process(delta_time)
	if(stat == DEAD)
		return

	switch(state)
		if(SCP096_DOCILE)
			process_docile()
		if(SCP096_SCREAMING)
			process_screaming()
		if(SCP096_PURSUING)
			process_pursuing()

/mob/living/carbon/human/scp096/proc/process_docile()
	if(world.time > last_face_cover_emote + SCP096_FACE_COVER_EMOTE_COOLDOWN)
		if(prob(15))
			visible_message("<span class='notice'>[src] quietly covers its face with its hands.</span>")
			last_face_cover_emote = world.time

	check_face_viewing()

/mob/living/carbon/human/scp096/proc/process_screaming()
	if(world.time >= scream_phase_end)
		begin_pursuit()
		return

	if(prob(25))
		visible_message("<span class='danger'>[src] screams in utter anguish!</span>")

	if(prob(10))
		playsound(src, 'sound/scp/scare1.ogg', 100, FALSE, extrarange = 100)

/mob/living/carbon/human/scp096/proc/process_pursuing()
	if(!current_target || current_target.stat == DEAD)
		if(current_target && current_target.stat == DEAD)
			on_target_killed()
		return_to_docile()
		return

	if(get_dist(src, current_target) <= 1)
		attack_target()
	else
		step_to(src, current_target, 0)

/mob/living/carbon/human/scp096/proc/check_face_viewing()
	var/list/new_viewers = list()

	for(var/mob/living/carbon/human/H in view(SCP096_VIEW_RANGE, src))
		if(H == src || H.stat == DEAD)
			continue
		if(!(H in face_viewers))
			if(can_viewer_see_face(H))
				trigger_face_view(H)
		new_viewers += H

	face_viewers = new_viewers

/mob/living/carbon/human/scp096/proc/can_viewer_see_face(mob/living/carbon/human/viewer)
	if(!viewer.client)
		return FALSE

	var/direction_to_scp = get_dir(viewer, src)
	if(!(direction_to_scp & viewer.dir))
		return FALSE

	if(!viewer.can_see_cone(src))
		return FALSE

	if(!has_los_to(viewer))
		return FALSE

	var/obj/item/clothing/head/hood_scp096/hood = get_item_by_slot(ITEM_SLOT_HEAD)
	if(istype(hood))
		return FALSE

	return TRUE

/mob/living/carbon/human/scp096/proc/has_los_to(mob/viewer)
	var/turf/T = get_turf(src)
	var/turf/V = get_turf(viewer)
	if(!T || !V)
		return FALSE
	if(T.z != V.z)
		return FALSE

	if(get_dist(T, V) < 1)
		return TRUE

	for(var/turf/check in get_line(get_turf(V), get_turf(T)))
		if(check.opacity)
			return FALSE
	return TRUE

/mob/living/carbon/human/scp096/proc/trigger_face_view(mob/living/carbon/human/viewer)
	if(state != SCP096_DOCILE)
		if(state == SCP096_SCREAMING && !(viewer in face_viewers))
			face_viewers += viewer
			to_chat(viewer, "<span class='userdanger'>You see SCP-096's face! It begins to scream!</span>")
			hook_scp_observation(viewer, "SCP-096")
			start_scp_survival_tracking(viewer, "SCP-096", INTERACTION_RISK_CRITICAL)
		return

	state = SCP096_SCREAMING
	current_target = viewer
	rage_activations++

	var/scream_duration = rand(SCP096_SCREAM_PHASE_MIN, SCP096_SCREAM_PHASE_MAX)
	scream_phase_end = world.time + scream_duration

	on_rage_trigger(viewer)

	to_chat(viewer, "<span class='userdanger'>You see SCP-096's face! It begins to scream!</span>")

	playsound(src, 'sound/scp/scare1.ogg', 100, FALSE, extrarange = 100)

	visible_message("<span class='danger'>[src] begins screaming in utter anguish!</span>")

	for(var/mob/M in GLOB.player_list)
		if(M.z == z && M != src && M != viewer)
			var/dist = get_dist(M, src)
			if(dist <= 30)
				to_chat(M, "<span class='danger'>You hear a horrifying scream echoing from somewhere nearby!</span>")
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.sanity)
						H.sanity.adjust_sanity(-15, "Heard SCP-096 scream")
						H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 20)

/mob/living/carbon/human/scp096/proc/begin_pursuit()
	state = SCP096_PURSUING

	add_movespeed_modifier(/datum/movespeed_modifier/scp096_pursuit)

	if(!physiology)
		physiology = new /datum/physiology(src)
	physiology.brute_mod = SCP096_RAGE_DAMAGE_MULT
	physiology.burn_mod = SCP096_RAGE_DAMAGE_MULT

	visible_message("<span class='danger'>[src] lowers its hands and sprints with terrifying speed!</span>")

	hook_scp_breach("SCP-096", src)

/mob/living/carbon/human/scp096/proc/attack_target()
	if(!current_target || current_target.stat == DEAD)
		return

	current_target.adjustBruteLoss(SCP096_PURSUIT_DAMAGE)
	visible_message("<span class='danger'>[src] tears into [current_target] with devastating force!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	if(current_target.stat == DEAD)
		on_target_killed()
		return_to_docile()

/mob/living/carbon/human/scp096/proc/on_target_killed()
	var/mob/living/victim = current_target
	kills_count++
	victims_hunted++

	if(ishuman(victim))
		hook_scp_combat(victim, "SCP-096", 100, 0)
		hook_player_death_near_scp(victim, "SCP-096")
		stop_scp_survival_tracking(victim, "SCP-096")

/mob/living/carbon/human/scp096/proc/return_to_docile()
	state = SCP096_DOCILE
	current_target = null
	face_viewers = list()

	remove_movespeed_modifier(/datum/movespeed_modifier/scp096_pursuit)

	if(physiology)
		physiology.brute_mod = initial(physiology.brute_mod)
		physiology.burn_mod = initial(physiology.burn_mod)

	visible_message("<span class='notice'>[src] covers its face with its hands and returns to a docile state.</span>")

/mob/living/carbon/human/scp096/UnarmedAttack(atom/A)
	if(!isliving(A))
		return ..()

	var/mob/living/L = A

	if(state == SCP096_PURSUING && L == current_target)
		attack_target()
		return

	if(state == SCP096_DOCILE || state == SCP096_SCREAMING)
		return

/mob/living/carbon/human/scp096/examine(mob/user)
	. = ..()

	if(user == src)
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(H.stat == DEAD)
		return

	if(state == SCP096_DOCILE)
		. += "<span class='notice'>It is covering its face with its hands.</span>"
	else if(state == SCP096_SCREAMING)
		. += "<span class='danger'>It is screaming in pure anguish!</span>"
	else if(state == SCP096_PURSUING)
		. += "<span class='danger'>Its face is exposed — DO NOT LOOK!</span>"

	if(can_viewer_see_face(H) && state == SCP096_DOCILE)
		trigger_face_view(H)

/mob/living/carbon/human/scp096/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	if(state == SCP096_PURSUING && !forced)
		amount *= SCP096_RAGE_DAMAGE_MULT
	return ..()

/mob/living/carbon/human/scp096/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(state == SCP096_PURSUING && !forced)
		amount *= SCP096_RAGE_DAMAGE_MULT
	return ..()

/mob/living/carbon/human/scp096/death(gibbed)
	STOP_PROCESSING(SSobj, src)
	hook_scp_recontainment("SCP-096", list())
	. = ..()

/mob/living/carbon/human/scp096/Logout()
	. = ..()

/mob/living/carbon/human/scp096/proc/on_rage_trigger(mob/living/carbon/human/viewer)
	hook_scp_breach("SCP-096", src)
	if(viewer && ishuman(viewer))
		hook_scp_interaction(viewer, "SCP-096", INTERACTION_TYPE_OBSERVATION)
		hook_scp_observation(viewer, "SCP-096")
		start_scp_survival_tracking(viewer, "SCP-096", INTERACTION_RISK_CRITICAL)

/mob/living/carbon/human/scp096/get_status_tab_items()
	. = ..()
	. += "State: [state]"
	. += "Current Target: [current_target ? current_target.name : "None"]"
	. += "Total Kills: [kills_count]"

/mob/living/carbon/human/scp096/verb/show_status_verb()
	set name = "Show SCP Status"
	set category = "SCP-096"
	set desc = "Display your SCP-096 status"

	to_chat(src, "<span class='notice'>=== SCP-096 Status ===</span>")
	to_chat(src, "<span class='notice'>State: [state]</span>")
	to_chat(src, "<span class='notice'>Current Target: [current_target ? current_target.name : "None"]</span>")
	to_chat(src, "<span class='notice'>Total Kills: [kills_count]</span>")
	to_chat(src, "<span class='notice'>Rage Activations: [rage_activations]</span>")

#undef SCP096_DOCILE
#undef SCP096_SCREAMING
#undef SCP096_PURSUING
#undef SCP096_VIEW_RANGE
#undef SCP096_SCREAM_PHASE_MIN
#undef SCP096_SCREAM_PHASE_MAX
#undef SCP096_PURSUIT_SPEED_MOD
#undef SCP096_PURSUIT_DAMAGE
#undef SCP096_RAGE_DAMAGE_MULT
#undef SCP096_FACE_COVER_EMOTE_COOLDOWN
