// 9mm (Makarov and Stechkin APS)

/obj/projectile/bullet/c9mm
	name = "9mm bullet"
	damage = 30
	embedding = list(embed_chance=15, fall_chance=0, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)

/obj/projectile/bullet/c9mm/ap
	name = "9mm armor-piercing bullet"
	damage = 30
	armor_penetration = 40
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/c9mm/hp
	name = "9mm hollow-point bullet"
	damage = 40
	weak_against_armor = 2

/obj/projectile/bullet/incendiary/c9mm
	name = "9mm incendiary bullet"
	damage = 15
	fire_stacks = 2

/obj/projectile/bullet/c9mm/rubber //"rubber" bullets
	name = "rubber bullet"
	damage = 60
	weak_against_armor = 2


// 10mm

/obj/projectile/bullet/c10mm
	name = "10mm bullet"
	damage = 40

/obj/projectile/bullet/c10mm/ap
	name = "10mm armor-piercing bullet"
	damage = 37
	armor_penetration = 40

/obj/projectile/bullet/c10mm/hp
	name = "10mm hollow-point bullet"
	damage = 60
	weak_against_armor = 2

/obj/projectile/bullet/incendiary/c10mm
	name = "10mm incendiary bullet"
	damage = 20
	fire_stacks = 2

// P90 SMG
/obj/projectile/bullet/a57
	armor_penetration = 10

/obj/projectile/bullet/a57/rubber
	armor_penetration = 0

/obj/projectile/bullet/a57/hollowpoint
	armor_penetration = 0

/obj/projectile/bullet/a57/ap
	armor_penetration = 20

/obj/projectile/bullet/a57/silver
	armor_penetration = 10
