// 7.62 (Nagant Rifle)

/obj/item/ammo_casing/a762
	name = "7.62 bullet casing"
	desc = "A 7.62 bullet casing."
	icon_state = "762-casing"
	caliber = CALIBER_A762
	projectile_type = /obj/projectile/bullet/a762

/obj/item/ammo_casing/a762/enchanted
	projectile_type = /obj/projectile/bullet/a762/enchanted

/obj/item/ammo_casing/a762x54
	desc = "A 7.62x54mmR bullet casing."
	caliber = "7.62x54mmR"
	projectile_type = /obj/projectile/bullet/rifle/a762x54

/obj/item/ammo_casing/a762nato
	desc = "A 7.62x51mm NATO bullet casing."
	caliber = "a762nato"
	projectile_type = /obj/projectile/bullet/rifle/a762nato
	icon_state = "rifle-brass"

/obj/item/ammo_casing/a762/practice
	desc = "A 7.62mm practice bullet casing."
	projectile_type = /obj/projectile/bullet/a762/practice

// 5.56mm (M-90gl Carbine)

/obj/item/ammo_casing/a556
	name = "5.56mm bullet casing"
	desc = "A 5.56mm bullet casing."
	caliber = CALIBER_A556
	projectile_type = /obj/projectile/bullet/a556

/obj/item/ammo_casing/a556/phasic
	name = "5.56mm phasic bullet casing"
	desc = "A 5.56mm phasic bullet casing."
	projectile_type = /obj/projectile/bullet/a556/phasic

// 40mm (Grenade Launcher)

/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = CALIBER_40MM
	icon_state = "40mmHE"
	projectile_type = /obj/projectile/bullet/a40mm
