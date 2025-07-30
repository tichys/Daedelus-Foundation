// SCP-106: The Old Man - Feature-rich, lore-accurate, player-controlled

/mob/living/carbon/human/scp106
    name = "SCP-106"
    real_name = "SCP-106"
    desc = "A withered, necrotic old man, oozing corrosive black slime. Its presence is deeply unsettling."
    icon = 'icons/scp/scp-106.dmi' // You must provide this icon file
    icon_state = "scp106"
    gender = MALE
    see_in_dark = 10
    maxHealth = 700
    health = 700
    // Use standard movement delay if available, else slow by default
    //faction = list("scp") // Uncomment if your codebase uses this var

    // Ability cooldowns
    var/obj/effect/portal/scp106_portal = null
    var/last_corrosion = 0
    var/last_teleport = 0
    var/last_drag = 0
    var/corrosion_cooldown = 10
    var/teleport_cooldown = 30
    var/drag_cooldown = 20

    Initialize()
        . = ..()
        to_chat(src, "A sickly-sweet stench of rot fills the air...")
        if(isnull(GLOB.SCP_list))
            GLOB.SCP_list = list()
        GLOB.SCP_list += src

    // Corrosive touch: damages and corrodes objects/mobs
    attack_hand(atom/target)
        if(world.time < last_corrosion + corrosion_cooldown)
            return ..()
        last_corrosion = world.time
        if(istype(target, /mob/living/carbon/human))
            var/mob/living/carbon/human/M = target
            M.adjustBruteLoss(40)
            to_chat(M, "SCP-106's touch burns and rots your flesh!")
        else
            to_chat(src, "You corrode [target]'s surface with black slime.")
        return ..()

    // Portal creation: Place a portal at current location
    verb/create_portal()
        set name = "Create Portal"
        set desc = "Create a portal to your pocket dimension. You can teleport to it later."
        if(world.time < last_teleport + teleport_cooldown)
            to_chat(src, "You must wait before creating another portal.")
            return
        if(scp106_portal)
            qdel(scp106_portal)
        scp106_portal = new /obj/effect/portal/scp106(get_turf(src))
        to_chat(src, "You open a black, oozing portal in the floor.")
        last_teleport = world.time

    // Teleport to portal
    verb/teleport_to_portal()
        set name = "Teleport to Portal"
        set desc = "Teleport to your placed portal."
        if(!scp106_portal)
            to_chat(src, "No portal exists.")
            return
        if(world.time < last_teleport + teleport_cooldown)
            to_chat(src, "You must wait before teleporting again.")
            return
        src.loc = get_turf(scp106_portal)
        to_chat(src, "You phase through reality and emerge from your portal.")
        last_teleport = world.time

    // Drag victim to pocket dimension
    verb/drag_to_pocket_dimension(mob/living/carbon/human/victim as mob in oview(1))
        set name = "Drag to Pocket Dimension"
        set desc = "Drag a nearby victim into your pocket dimension."
        if(world.time < last_drag + drag_cooldown)
            to_chat(src, "You must wait before dragging another victim.")
            return
        if(!victim || !istype(victim, /mob/living/carbon/human))
            to_chat(src, "No valid victim nearby.")
            return
        // Move victim to pocket dimension
        var/area/pocket = locate(/area/scp106_pocket_dimension)
        if(!pocket)
            pocket = new /area/scp106_pocket_dimension()
        victim.loc = pocket
        to_chat(victim, "SCP-106 drags you into a nightmarish void!")
        to_chat(src, "You drag [victim] into your pocket dimension.")
        last_drag = world.time

    // Special death: return to pocket dimension instead of dying
    death(gibbed = FALSE)
        to_chat(src, "SCP-106 melts into the floor, returning to its pocket dimension...")
        src.loc = locate(/area/scp106_pocket_dimension)
        health = maxHealth
        return

// Pocket dimension area (simple placeholder)
/area/scp106_pocket_dimension
    name = "Pocket Dimension"
    icon_state = "pocketdim"
    // Add special effects, darkness, etc.

// Portal object
/obj/effect/portal/scp106
    name = "Oozing Black Portal"
    desc = "A black, corrosive portal left by SCP-106."
    icon = 'icons/scp/scp-106.dmi'
    icon_state = "portal"
    anchored = TRUE
    mouse_opacity = 0
    // Optionally add effects for stepping in
