// Vision Cone System - Complete Vanderlin-main implementation

// Missing defines that need to be added
#define FOV_DEFAULT 1
#define FOV_LEFT 2
#define FOV_RIGHT 4
#define FOV_BEHIND 8
#define FIELD_OF_VISION_BLOCKER_PLANE 102
#define GAME_PLANE_UPPER -5

// Missing subsystem - moved to proper location

/client
	var/list/hidden_atoms = list()
	var/list/hidden_mobs = list()
	var/list/hidden_images = list()

/mob
	var/fovangle

//Procs
/atom/proc/InCone(atom/center = usr, dir = NORTH)
	if(get_dist(center, src) == 0 || src == center) return 0
	var/d = get_dir(center, src)
	if(!d || d == dir) return 1
	if(dir & (dir-1))
		return (d & ~dir) ? 0 : 1
	if(!(d & dir)) return 0
	var/dx = abs(x - center.x)
	var/dy = abs(y - center.y)
	if(dx == dy) return 1
	if(dy > dx)
		return (dir & (NORTH|SOUTH)) ? 1 : 0
	return (dir & (EAST|WEST)) ? 1 : 0

/mob/dead/InCone(mob/center = usr, dir = NORTH)//So ghosts aren't calculated.
	return

/proc/cone(atom/center = usr, dirs, list/list = oview(center))
	for(var/atom/A in list)
		var/fou
		for(var/D in dirs)
			if(A.InCone(center, D))
				fou = TRUE
				break
		if(!fou)
			list -= A
	return list

/mob/dead/BehindAtom(mob/center = usr, dir = NORTH)//So ghosts aren't calculated.
	return

/atom/proc/BehindAtom(atom/center = usr, dir = NORTH)
	switch(dir)
		if(NORTH)
			if(y > center.y)
				return 1
		if(SOUTH)
			if(y < center.y)
				return 1
		if(EAST)
			if(x > center.x)
				return 1
		if(WEST)
			if(x < center.x)
				return 1

/proc/behind(atom/center = usr, dirs, list/list = oview(center))
	for(var/atom/A in list)
		var/fou
		for(var/D in dirs)
			if(A.BehindAtom(center, D))
				fou = TRUE
				break
		if(!fou)
			list -= A
	return list

/mob/proc/update_vision_cone()
	return

/mob/proc/update_cone()
	return

/mob/living/update_vision_cone()
	if(client)
		if(hud_used && hud_used.fov)
			hud_used.fov.dir = src.dir
			hud_used.fov_blocker.dir = src.dir
		START_PROCESSING(SSincone, client)

/client/proc/update_cone()
	if(mob)
		mob.update_cone()

/mob/living/update_cone()
	for(var/hidden_hud in client.hidden_images)
		client.images -= hidden_hud
		client.hidden_images -= hidden_hud
	if(hud_used?.fov)
		if(hud_used.fov.alpha == 0)
			return
	//! IMPORTANT: If Animations break remove this, tested most seemed fine
	var/image/I = image(src, src)

	I.plane = GAME_PLANE_UPPER
	I.layer = layer
	I.override = TRUE
	I.pixel_x = 0
	I.pixel_y = 0
	client.images += I
	client.hidden_images += I
	I.appearance_flags = KEEP_TOGETHER

/*	if(hud_used && hud_used.fov_blocker)
		fov_blocker

		var/icon/new_blocker = icon("icon"='icons/mob/vision_cone.dmi', "icon_state"=hud_used.fov_blocker.icon_state)
		var/icon/the_mob = icon("icon"='icons/mob/clothing/under/masking_helpers.dmi', "icon_state"="[(type == FEMALE_UNIFORM_FULL) ? "female_full" : "female_top"]")
		female_clothing_icon.Blend(female_s, ICON_MULTIPLY)
*/

/*	if(src.client)
		var/image/I = null
		for(I in src.client.hidden_atoms)
			I.override = 0
			client.images -= I
			qdel(I)
		for(var/hidden_hud in client.hidden_images)
			client.images += hidden_hud
			client.hidden_images -= hidden_hud
		src.client.hidden_atoms = list()
		src.client.hidden_mobs = list()
		client.hidden_images = list()
		if(hud_used && hud_used.fov)
//			hud_used.fov.dir = src.dir
			if(hud_used.fov.alpha != 0)
				var/mob/living/M
				var/list/mobs2hide = list()

				if(fovangle & FOV_RIGHT)
					if(fovangle & FOV_LEFT)
						var/dirlist = list(turn(src.dir, 180),turn(src.dir, -90),turn(src.dir, 90))
						mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
					else
						if(fovangle & FOV_BEHIND)
							var/dirlist = list(turn(src.dir, -90))
							mobs2hide |= behind(src, list(turn(src.dir, 180)), GLOB.mob_living_list.Copy())
							mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
						else
							var/dirlist = list(turn(src.dir, 180),turn(src.dir, -90))
							mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
				else
					if(fovangle & FOV_LEFT)
						if(fovangle & FOV_BEHIND)
							var/dirlist = list(turn(src.dir, 90))
							mobs2hide |= behind(src, list(turn(src.dir, 180)), GLOB.mob_living_list.Copy())
							mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
						else
							var/dirlist = list(turn(src.dir, 180),turn(src.dir, 90))
							mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
					else
						if(fovangle & FOV_BEHIND)
							mobs2hide |= behind(src, list(turn(src.dir, 180)), GLOB.mob_living_list.Copy())
						else//default
							mobs2hide |= cone(src, list(turn(src.dir, 180)), GLOB.mob_living_list.Copy())

				for(M in mobs2hide)
					I = image("split", M)
					I.override = 1
					src.client.images += I
					src.client.hidden_atoms += I
					src.client.hidden_mobs += M
					if(src.pulling == M)//If we're pulling them we don't want them to be invisible, too hard to play like that.
						I.override = 0
					if(src.pulledby == M)
						I.icon = 'icons/mob/mob.dmi'
						I.icon_state = "anon"
		for(var/image/HUD in client.images)
			if(HUD.icon != 'icons/mob/hud.dmi')
				continue
			for(var/mob/living/M in client.hidden_mobs)
				if(HUD.loc == M)
					client.hidden_images += HUD
					client.images -= HUD
					break*/

/mob/proc/can_see_cone(mob/L)
	if(!isliving(src) || !isliving(L))
		return
	if(!client)
		return TRUE
	if(hud_used && hud_used.fov)
		if(hud_used.fov.alpha != 0)
			var/list/mobs2hide = list()

			if(fovangle & FOV_RIGHT)
				if(fovangle & FOV_LEFT)
					var/dirlist = list(turn(src.dir, 180),turn(src.dir, -90),turn(src.dir, 90))
					mobs2hide |= cone(src, dirlist, list(L))
				else
					if(fovangle & FOV_BEHIND)
						var/dirlist = list(turn(src.dir, -90))
						mobs2hide |= behind(src, list(turn(src.dir, 180)), list(L))
						mobs2hide |= cone(src, dirlist, list(L))
					else
						var/dirlist = list(turn(src.dir, 180),turn(src.dir, -90))
						mobs2hide |= cone(src, dirlist, list(L))
			else
				if(fovangle & FOV_LEFT)
					if(fovangle & FOV_BEHIND)
						var/dirlist = list(turn(src.dir, 90))
						mobs2hide |= behind(src, list(turn(src.dir, 180)), list(L))
						mobs2hide |= cone(src, dirlist, list(L))
					else
						var/dirlist = list(turn(src.dir, 180),turn(src.dir, 90))
						mobs2hide |= cone(src, dirlist, list(L))
				else
					if(fovangle & FOV_BEHIND)
						mobs2hide |= behind(src, list(turn(src.dir, 180)), list(L))
					else//default
						mobs2hide |= cone(src, list(turn(src.dir, 180)), list(L))

			if(L in mobs2hide)
				return FALSE
	return TRUE

/mob/proc/update_cone_show()
	if(!client)
		return
	if(client.perspective != MOB_PERSPECTIVE)
		return hide_cone()
	if(client.eye != src)
		return hide_cone()
	if(client.pixel_x || client.pixel_y)
		return hide_cone()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.resting || H.body_position == LYING_DOWN)
			return hide_cone()
	return show_cone()

/mob/proc/update_fov_angles()
	fovangle = initial(fovangle)
	if(ishuman(src) && fovangle)
		var/mob/living/carbon/human/H = src
		if(H.head)
			if(H.head.block2add)
				fovangle |= H.head.block2add
		if(H.wear_mask)
			if(H.wear_mask.block2add)
				fovangle |= H.wear_mask.block2add
		if(H.STAPER < 5)
			fovangle |= FOV_LEFT
			fovangle |= FOV_RIGHT
		else
			if(HAS_TRAIT(src, TRAIT_CYCLOPS_LEFT))
				fovangle |= FOV_LEFT
			if(HAS_TRAIT(src, TRAIT_CYCLOPS_RIGHT))
				fovangle |= FOV_RIGHT

	if(!hud_used)
		return
	if(!hud_used.fov)
		return
	if(!hud_used.fov_blocker)
		return
	if(fovangle & FOV_DEFAULT)
		if(fovangle & FOV_RIGHT)
			if(fovangle & FOV_LEFT)
				hud_used.fov.icon_state = "both"
				hud_used.fov_blocker.icon_state = "both_v"
				return
			hud_used.fov.icon_state = "right"
			hud_used.fov_blocker.icon_state = "right_v"
			if(fovangle & FOV_BEHIND)
				hud_used.fov.icon_state = "behind_r"
				hud_used.fov_blocker.icon_state = "behind_r_v"
			return
		else if(fovangle & FOV_LEFT)
			hud_used.fov.icon_state = "left"
			hud_used.fov_blocker.icon_state = "left_v"
			if(fovangle & FOV_BEHIND)
				hud_used.fov.icon_state = "behind_l"
				hud_used.fov_blocker.icon_state = "behind_l_v"
			return
		if(fovangle & FOV_BEHIND)
			hud_used.fov.icon_state = "behind"
			hud_used.fov_blocker.icon_state = "behind_v"
		else
			hud_used.fov.icon_state = "combat"
			hud_used.fov_blocker.icon_state = "combat_v"
	else
		hud_used.fov.icon_state = null
		hud_used.fov_blocker.icon_state = null
		return

//Making these generic procs so you can call them anywhere.
/mob/proc/show_cone()
	if(!client)
		return
	if(hud_used?.fov?.alpha == 255)
		return
	if(hud_used?.fov)
		hud_used.fov.alpha = 180 // Softer, more transparent for warm glow
		hud_used.fov_blocker.alpha = 200 // Slightly more opaque for darkness
		// Add vision cone objects to client screen
		client.screen += hud_used.fov
		client.screen += hud_used.fov_blocker
	// Ensure plane master is added and backdrop is set
	var/atom/movable/screen/plane_master/game_world_fov_hidden/PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in client.screen
	if(!PM)
		PM = new /atom/movable/screen/plane_master/game_world_fov_hidden(null, hud_used)
		client.screen += PM
	PM.backdrop(src)

/mob/proc/hide_cone()
	if(!client)
		return
	if(hud_used?.fov?.alpha == 0)
		return
	if(hud_used?.fov)
		hud_used.fov.alpha = 0
		hud_used.fov_blocker.alpha = 0
		// Remove vision cone objects from client screen
		client.screen -= hud_used.fov
		client.screen -= hud_used.fov_blocker
	var/atom/movable/screen/plane_master/game_world_fov_hidden/PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in client.screen
	PM.backdrop(src)

/atom/movable/screen/fov_blocker
	icon = 'icons/mob/vision_cone.dmi'
	icon_state = "combat_v"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	screen_loc = "1,1"
	color = "#000000" // Black for darkness

/atom/movable/screen/fov
	icon = 'icons/mob/vision_cone.dmi'
	icon_state = "combat"
	name = " "
	screen_loc = "1,1"
	mouse_opacity = 0
	plane = HUD_PLANE-1
	color = "#FFA500" // Warm orange color like torch light
	blend_mode = BLEND_ADD // Additive blending for glow effect

// Test verbs for debugging
/mob/living/verb/test_vision_cone()
	set name = "Test Vision Cone"
	set category = "Debug"

	to_chat(src, "<span class='notice'>Testing vision cone system...</span>")
	fovangle = FOV_DEFAULT
	update_cone_show()

/mob/living/verb/toggle_vision_cone()
	set name = "Toggle Vision Cone"
	set category = "Debug"

	if(fovangle)
		fovangle = 0
		hide_cone()
		to_chat(src, "<span class='notice'>Vision cone disabled.</span>")
	else
		fovangle = FOV_DEFAULT
		show_cone()
		to_chat(src, "<span class='notice'>Vision cone enabled.</span>")

/mob/living/verb/remove_vision_cone()
	set name = "Remove Vision Cone"
	set category = "Debug"

	fovangle = 0
	hide_cone()
	to_chat(src, "<span class='notice'>Vision cone removed.</span>")

/mob/living/verb/set_fov_left()
	set name = "Set FOV Left"
	set category = "Debug"

	fovangle = FOV_LEFT
	update_vision_cone()
	to_chat(src, "<span class='notice'>FOV set to left only.</span>")

/mob/living/verb/set_fov_right()
	set name = "Set FOV Right"
	set category = "Debug"

	fovangle = FOV_RIGHT
	update_vision_cone()
	to_chat(src, "<span class='notice'>FOV set to right only.</span>")

/mob/living/verb/set_fov_behind()
	set name = "Set FOV Behind"
	set category = "Debug"

	fovangle = FOV_BEHIND
	update_vision_cone()
	to_chat(src, "<span class='notice'>FOV set to behind only.</span>")
