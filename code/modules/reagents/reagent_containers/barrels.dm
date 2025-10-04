/obj/item/reagent_containers/barrel
	name = "Barrel"
	desc = "A dummy barrel."
	icon = 'icons/obj/aquaticprops.dmi'
	icon_state = "barrel_generic"
	possible_transfer_amounts = list(10,25,50,100)
	volume = 2500
	var/datum/reagent/selected_reagent

/obj/item/reagent_containers/barrel/proc/InitializeBarrelReagent()
	var/list/barrelreagents = list(/datum/reagent/consumable/cooking_oil = 30,
								/datum/reagent/medicine/cryoxadone = 20,
								/datum/reagent/cryptobiolin = 5,
								/datum/reagent/toxin/acid/hydrochloric = 3,
								/datum/reagent/nitroglycerin = 5,
								/datum/reagent/blood = 15,
								/datum/reagent/consumable/ethanol = 25,
								/datum/reagent/medicine/spaceacillin = 15,
								/datum/reagent/toxin/mutagen = 2,
								/datum/reagent/consumable/coffee = 20,
								/datum/reagent/drug/methamphetamine = 1,
								/datum/reagent/thermite = 3,
								/datum/reagent/consumable/laughter = 5,
								/datum/reagent/toxin/polonium = 1,
								/datum/reagent/consumable/orangejuice = 20,
								/datum/reagent/medicine/dexalin = 15,
								/datum/reagent/toxin/cyanide = 1,
								/datum/reagent/consumable/tea = 20,
								/datum/reagent/drug/space_drugs = 1,
								/datum/reagent/hydrogen = 25,
								/datum/reagent/silver = 15,
								/datum/reagent/consumable/caramel = 15,
								/datum/reagent/toxin/fentanyl = 1,
								/datum/reagent/medicine/morphine = 10,
								/datum/reagent/consumable/ethanol/whiskey = 20
								)
	var/reagentpicked = pick_weight(barrelreagents)  // Pick a random reagent based on weights
	selected_reagent = reagentpicked
	list_reagents = list(selected_reagent = volume)

/obj/item/reagent_containers/barrel/New()
	. = ..()
	InitializeBarrelReagent()

/obj/item/reagent_containers/barrel/generic
	name = "Barrel"
	desc = "A generic barrel."
	icon = 'icons/obj/aquaticprops.dmi'
	icon_state = "barrel_generic"
	possible_transfer_amounts = list(10,25,50,100)
	volume = 2500

//These two hitch off water and fuel tank logic since that's easier then rewriting all of the code, plus barrels aren't all That unique.
//The notable difference is that the quantities are much smaller.

/obj/item/reagent_containers/watertank/barrel
	name = "Blue Barrel"
	desc = "A blue barrel that probably contains water."
	icon = 'icons/obj/aquaticprops.dmi'
	icon_state = "barrel_water"
	volume = 2500

/obj/item/reagent_containers/fueltank/barrel
	name = "Red Barrel"
	desc = "A deep red barrel which probably contains welding fuel. Better keep guns away from this..."
	icon = 'icons/obj/aquaticprops.dmi'
	icon_state = "barrel_weld"
	volume = 2500

/obj/item/reagent_containers/barrel/cooking
	name = "Cooking Barrel"
	desc = "A barrel filled with a cooking-related reagent."
	icon = 'icons/obj/aquaticprops.dmi'
	volume = 2500

/obj/item/reagent_containers/barrel/cooking/InitializeBarrelReagent()
	var/list/barrelreagents = list(
		/datum/reagent/consumable/cooking_oil = 30,
		/datum/reagent/consumable/sugar = 25,
		/datum/reagent/consumable/soysauce = 15,
		/datum/reagent/consumable/ketchup = 15,
		/datum/reagent/consumable/salt = 20,
		/datum/reagent/consumable/blackpepper = 10,
		/datum/reagent/consumable/coco = 10,
		/datum/reagent/consumable/garlic = 15,
		/datum/reagent/consumable/flour = 20,
		/datum/reagent/consumable/rice = 15,
		/datum/reagent/consumable/vanilla = 10,
		/datum/reagent/consumable/eggyolk = 10,
		/datum/reagent/consumable/eggwhite = 10,
		/datum/reagent/consumable/corn_starch = 10,
		/datum/reagent/consumable/corn_syrup = 10,
		/datum/reagent/consumable/honey = 15,
		/datum/reagent/consumable/mayonnaise = 10,
		/datum/reagent/consumable/quality_oil = 20,
		/datum/reagent/consumable/cornmeal = 15,
		/datum/reagent/consumable/yoghurt = 10,
		/datum/reagent/consumable/peanut_butter = 15,
		/datum/reagent/consumable/vinegar = 10,
		/datum/reagent/consumable/bbqsauce = 15,
		/datum/reagent/consumable/gravy = 10,
		/datum/reagent/consumable/pancakebatter = 15,
		/datum/reagent/consumable/whipped_cream = 10,
		/datum/reagent/consumable/milk = 25,
		/datum/reagent/consumable/soymilk = 15,
		/datum/reagent/consumable/cream = 15,
		/datum/reagent/consumable/coffee = 20,
		/datum/reagent/consumable/tea = 20,
		/datum/reagent/consumable/grapejuice = 15,
		/datum/reagent/consumable/orangejuice = 20,
		/datum/reagent/consumable/tomatojuice = 15,
		/datum/reagent/consumable/limejuice = 15,
		/datum/reagent/consumable/applejuice = 20,
		/datum/reagent/consumable/pineapplejuice = 15,
		/datum/reagent/consumable/pumpkinjuice = 10,
		/datum/reagent/consumable/sodawater = 15,
		/datum/reagent/consumable/grenadine = 10
	)
	selected_reagent = pick_weight(barrelreagents)
	list_reagents = list(selected_reagent = volume)
