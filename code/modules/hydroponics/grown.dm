//Grown foods.
/obj/item/reagent_containers/food/snacks/grown

	name = "fruit"
	icon = 'icons/obj/hydroponics_products.dmi'
	icon_state = "blank"
	desc = "Nutritious! Probably."
	atom_flags = NOCONDUCT
	slot_flags = SLOT_HOLSTER
	drop_sound = 'sound/items/drop/herb.ogg'
	pickup_sound = 'sound/items/pickup/herb.ogg'

	var/plantname
	var/datum/seed/seed
	var/potency = -1

/obj/item/reagent_containers/food/snacks/grown/Initialize(mapload, planttype)
	. = ..()
	if(!dried_type)
		dried_type = type
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

	// Fill the object up with the appropriate reagents.
	if(planttype)
		plantname = planttype

	if(!plantname)
		return

	seed = SSplants.seeds[plantname]

	if(!seed)
		return

	name = "[seed.seed_name]"
	trash = seed.get_trash_type()

	update_icon()

	if(!seed.chems)
		return

	potency = seed.get_trait(TRAIT_POTENCY)

	for(var/rid in seed.chems)
		var/list/reagent_data = seed.chems[rid]
		if(reagent_data && reagent_data.len)
			var/rtotal = reagent_data[1]
			var/list/data = list()
			if(reagent_data.len > 1 && potency > 0)
				rtotal += round(potency/reagent_data[2])
			if(rid == "nutriment")
				data[seed.seed_name] = max(1,rtotal)

			reagents.add_reagent(rid,max(1,rtotal),data)
	update_desc()
	if(reagents.total_volume > 0)
		bitesize = 1+round(reagents.total_volume / 2, 1)
	if(seed.get_trait(TRAIT_STINGS))
		damage_force = 1
	catalogue_data = seed.catalog_data_grown

/obj/item/reagent_containers/food/snacks/grown/update_desc()
	. = ..()
	if(!seed)
		return

	if(SSplants.product_descs["[seed.uid]"])
		desc = SSplants.product_descs["[seed.uid]"]
	else
		var/list/descriptors = list()
		if(reagents.has_reagent("sugar") || reagents.has_reagent("cherryjelly") || reagents.has_reagent("honey") || reagents.has_reagent("berryjuice"))
			descriptors |= "sweet"
		if(reagents.has_reagent("anti_toxin"))
			descriptors |= "astringent"
		if(reagents.has_reagent("frostoil"))
			descriptors |= "numbing"
		if(reagents.has_reagent("nutriment"))
			descriptors |= "nutritious"
		if(reagents.has_reagent("condensedcapsaicin") || reagents.has_reagent("capsaicin"))
			descriptors |= "spicy"
		if(reagents.has_reagent("coco"))
			descriptors |= "bitter"
		if(reagents.has_reagent("orangejuice") || reagents.has_reagent("lemonjuice") || reagents.has_reagent("limejuice"))
			descriptors |= "sweet-sour"
		if(reagents.has_reagent("radium") || reagents.has_reagent("uranium"))
			descriptors |= "radioactive"
		if(reagents.has_reagent("amatoxin") || reagents.has_reagent("toxin"))
			descriptors |= "poisonous"
		if(reagents.has_reagent("psilocybin") || reagents.has_reagent("space_drugs")|| reagents.has_reagent("earthsblood"))
			descriptors |= "hallucinogenic"
		if(reagents.has_reagent("bicaridine")  || reagents.has_reagent("earthsblood"))
			descriptors |= "medicinal"
		if(reagents.has_reagent("gold"))
			descriptors |= "shiny"
		if(reagents.has_reagent("lube"))
			descriptors |= "slippery"
		if(reagents.has_reagent("pacid") || reagents.has_reagent("sacid"))
			descriptors |= "acidic"
		if(seed.get_trait(TRAIT_JUICY))
			descriptors |= "juicy"
		if(seed.get_trait(TRAIT_STINGS))
			descriptors |= "stinging"
		if(seed.get_trait(TRAIT_TELEPORTING))
			descriptors |= "glowing"
		if(seed.get_trait(TRAIT_EXPLOSIVE))
			descriptors |= "bulbous"

		var/descriptor_num = rand(2,4)
		var/descriptor_count = descriptor_num
		desc = "A"
		while(descriptors.len && descriptor_num > 0)
			var/chosen = pick(descriptors)
			descriptors -= chosen
			desc += "[(descriptor_count>1 && descriptor_count!=descriptor_num) ? "," : "" ] [chosen]"
			descriptor_num--
		if(seed.seed_noun == "spores")
			desc += " mushroom"
		else
			desc += " fruit"
		SSplants.product_descs["[seed.uid]"] = desc
	desc += ". Delicious! Probably."

/obj/item/reagent_containers/food/snacks/grown/update_icon()
	if(!seed || !SSplants || !SSplants.plant_icon_cache)
		return
	cut_overlays()
	var/image/plant_icon
	var/icon_key = "fruit-[seed.get_trait(TRAIT_PRODUCT_ICON)]-[seed.get_trait(TRAIT_PRODUCT_COLOUR)]-[seed.get_trait(TRAIT_PLANT_COLOUR)]"
	if(SSplants.plant_icon_cache[icon_key])
		plant_icon = SSplants.plant_icon_cache[icon_key]
	else
		plant_icon = image('icons/obj/hydroponics_products.dmi',"blank")
		var/image/fruit_base = image('icons/obj/hydroponics_products.dmi',"[seed.get_trait(TRAIT_PRODUCT_ICON)]-product")
		fruit_base.color = "[seed.get_trait(TRAIT_PRODUCT_COLOUR)]"
		plant_icon.add_overlay(fruit_base)
		if("[seed.get_trait(TRAIT_PRODUCT_ICON)]-leaf" in icon_states('icons/obj/hydroponics_products.dmi'))
			var/image/fruit_leaves = image('icons/obj/hydroponics_products.dmi',"[seed.get_trait(TRAIT_PRODUCT_ICON)]-leaf")
			fruit_leaves.color = "[seed.get_trait(TRAIT_PLANT_COLOUR)]"
			plant_icon.add_overlay(fruit_leaves)
		SSplants.plant_icon_cache[icon_key] = plant_icon
	add_overlay(plant_icon)

/obj/item/reagent_containers/food/snacks/grown/Crossed(var/mob/living/M)
	. = ..()
	if(M.is_incorporeal() || M.is_avoiding_ground())
		return
	if(seed && seed.get_trait(TRAIT_JUICY) == 2)
		if(istype(M))
			if(M.buckled)
				return
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.shoes && H.shoes.clothing_flags & NOSLIP)
					return
				if(H.species.species_flags & NO_SLIP)//Species that dont slip naturally
					return
			M.stop_pulling()
			to_chat(M, "<span class='notice'>You slipped on the [name]!</span>")
			playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
			M.afflict_stun(20 * 8)
			M.afflict_paralyze(20 * 5)
			seed.thrown_at(src,M)
			qdel(src)
			return

/obj/item/reagent_containers/food/snacks/grown/throw_impact(atom/hit_atom)
	if(seed) seed.thrown_at(src,hit_atom)
	..()

/obj/item/reagent_containers/food/snacks/grown/attackby(var/obj/item/W, var/mob/living/user)

	if(seed)
		if(seed.get_trait(TRAIT_PRODUCES_POWER) && istype(W, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = W
			if(C.use(5))
				//TODO: generalize this.
				to_chat(user, "<span class='notice'>You add some cable to the [src.name] and slide it inside the battery casing.</span>")
				var/obj/item/cell/potato/pocell = new /obj/item/cell/potato(get_turf(user))
				if(src.loc == user && istype(user,/mob/living/carbon/human))
					user.put_in_hands(pocell)
				pocell.maxcharge = src.potency * 200 //fellas, have you ever actually tried to reach 200 potency? Let them have this if they can manage it.
				pocell.charge = pocell.maxcharge
				qdel(src)
				return
		else if(W.is_sharp())
			if(seed.kitchen_tag == "pumpkin") // Ugggh these checks are awful.
				user.show_message("<span class='notice'>You carve a face into [src]!</span>", 1)
				new /obj/item/clothing/head/pumpkinhead (user.loc)
				qdel(src)
				return
			else if(seed.chems)
				if((W.is_sharp() && W.is_edge()) && !isnull(seed.chems["woodpulp"]))
					user.show_message("<span class='notice'>You make planks out of \the [src]!</span>", 1)
					playsound(loc, 'sound/effects/woodcutting.ogg', 50, 1)
					var/flesh_colour = seed.get_trait(TRAIT_FLESH_COLOUR)
					if(!flesh_colour) flesh_colour = seed.get_trait(TRAIT_PRODUCT_COLOUR)
					for(var/i=0,i<2,i++)
						var/obj/item/stack/material/wood/NG = new (user.loc)
						if(flesh_colour) NG.color = flesh_colour
						for (var/obj/item/stack/material/wood/G in user.loc)
							if(G==NG)
								continue
							if(G.amount>=G.max_amount)
								continue
							G.attackby(NG, user)
						to_chat(user, "You add the newly-formed wood to the stack. It now contains [NG.amount] planks.")
					qdel(src)
					return
				else if(!isnull(seed.chems["potato"]))
					to_chat(user, "You slice \the [src] into sticks.")
					new /obj/item/reagent_containers/food/snacks/rawsticks(get_turf(src))
					qdel(src)
					return
				else if(!isnull(seed.chems["carrotjuice"]))
					to_chat(user, "You slice \the [src] into sticks.")
					new /obj/item/reagent_containers/food/snacks/carrotfries(get_turf(src))
					qdel(src)
					return
				else if(!isnull(seed.chems["soymilk"]))
					to_chat(user, "You roughly chop up \the [src].")
					new /obj/item/reagent_containers/food/snacks/soydope(get_turf(src))
					qdel(src)
					return
				else if(!isnull(seed.chems["pineapplejuice"]))
					to_chat(user, "You slice \the [src] into slices.")
					for(var/i in 1 to 4)
						new /obj/item/reagent_containers/food/snacks/pineapple_ring(get_turf(src))
					qdel(src)
					return
				else if(seed.get_trait(TRAIT_FLESH_COLOUR))
					to_chat(user, "You slice up \the [src].")
					var/slices = rand(3,5)
					var/reagents_to_transfer = round(reagents.total_volume/slices)
					for(var/i in 1 to slices)
						var/obj/item/reagent_containers/food/snacks/fruit_slice/F = new(get_turf(src),seed)
						if(reagents_to_transfer) reagents.trans_to_obj(F,reagents_to_transfer)
					qdel(src)
					return
	..()

/obj/item/reagent_containers/food/snacks/grown/melee_finalize(datum/event_args/actor/clickchain/clickchain, clickchain_flags, datum/melee_attack/weapon/attack_style)
	. = ..()
	if(. & (CLICKCHAIN_FLAGS_UNCONDITIONAL_ABORT | CLICKCHAIN_ATTACK_MISSED))
		return
	var/mob/living/L = clickchain.target
	if(!istype(L))
		return
	if(seed && seed.get_trait(TRAIT_STINGS))
		if(!reagents || reagents.total_volume <= 0)
			return
		reagents.remove_any(rand(1,3))
		seed.thrown_at(src, L)
		if(QDELETED(src))
			. |= CLICKCHAIN_DO_NOT_PROPAGATE
			return
		if(prob(35))
			if(clickchain.performer)
				to_chat(clickchain.performer, "<span class='danger'>\The [src] has fallen to bits.</span>")
				qdel(src)
				. |= CLICKCHAIN_DO_NOT_PROPAGATE

/obj/item/reagent_containers/food/snacks/grown/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return

	if(!seed)
		return

	if(istype(user.loc,/turf/space))
		return

	if(user.a_intent == INTENT_HARM)
		user.visible_message("<span class='danger'>[user] squashes [src]!</span>")
		seed.thrown_at(src,user)
		sleep(-1)
		if(src) qdel(src)
		return

	if(seed.kitchen_tag == "grass")
		user.show_message("<span class='notice'>You make a grass tile out of [src]!</span>", 1)
		var/flesh_colour = seed.get_trait(TRAIT_FLESH_COLOUR)
		if(!flesh_colour)
			flesh_colour = seed.get_trait(TRAIT_PRODUCT_COLOUR)
		var/obj/item/stack/tile/grass/G = new(user.loc, 2)		//2 grass tiles
		if(flesh_colour)
			G.color = flesh_colour
		qdel(src)
		return

	if(seed.get_trait(TRAIT_SPREAD) > 0)
		to_chat(user, "<span class='notice'>You plant the [src.name].</span>")
		new /obj/machinery/portable_atmospherics/hydroponics/soil/invisible(get_turf(user),src.seed)
		qdel(src)
		return

	/*
	if(seed.kitchen_tag)
		switch(seed.kitchen_tag)
			if("shand")
				var/obj/item/stack/medical/bruise_pack/tajaran/poultice = new /obj/item/stack/medical/bruise_pack/tajaran(user.loc)
				poultice.heal_brute = potency
				to_chat(user, "<span class='notice'>You mash the leaves into a poultice.</span>")
				qdel(src)
				return
			if("mtear")
				var/obj/item/stack/medical/ointment/tajaran/poultice = new /obj/item/stack/medical/ointment/tajaran(user.loc)
				poultice.heal_burn = potency
				to_chat(user, "<span class='notice'>You mash the petals into a poultice.</span>")
				qdel(src)
				return
	*/

/obj/item/reagent_containers/food/snacks/grown/pickup(mob/user, flags, atom/oldLoc)
	..()
	if(!seed)
		return
	if(seed.get_trait(TRAIT_STINGS))
		var/mob/living/carbon/human/H = user
		if(H.inventory.get_slot_single(/datum/inventory_slot/inventory/gloves::id))
			return
		if(!reagents || reagents.total_volume <= 0)
			return
		reagents.remove_any(rand(1,3)) //Todo, make it actually remove the reagents the seed uses.
		var/affected = pick("r_hand","l_hand")
		seed.do_thorns(H,src,affected)
		seed.do_sting(H,src,affected)

// Predefined types for placing on the map.

/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap
	plantname = "libertycap"

/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris
	plantname = "ambrosia"

/obj/item/reagent_containers/food/snacks/fruit_slice
	name = "fruit slice"
	desc = "A slice of some tasty fruit."
	icon = 'icons/obj/hydroponics_misc.dmi'
	icon_state = ""

var/list/fruit_icon_cache = list()

/obj/item/reagent_containers/food/snacks/fruit_slice/Initialize(mapload, datum/seed/S)
	. = ..()
	// Need to go through and make a general image caching controller. Todo.
	if(!istype(S))
		qdel(src)
		return

	name = "[S.seed_name] slice"
	desc = "A slice of \a [S.seed_name]. Tasty, probably."

	var/list/overlays_to_add = list()

	var/rind_colour = S.get_trait(TRAIT_PRODUCT_COLOUR)
	var/flesh_colour = S.get_trait(TRAIT_FLESH_COLOUR)
	if(!flesh_colour) flesh_colour = rind_colour
	if(!fruit_icon_cache["rind-[rind_colour]"])
		var/image/I = image(icon,"fruit_rind")
		I.color = rind_colour
		fruit_icon_cache["rind-[rind_colour]"] = I
	overlays_to_add += fruit_icon_cache["rind-[rind_colour]"]
	if(!fruit_icon_cache["slice-[rind_colour]"])
		var/image/I = image(icon,"fruit_slice")
		I.color = flesh_colour
		fruit_icon_cache["slice-[rind_colour]"] = I
	overlays_to_add += fruit_icon_cache["slice-[rind_colour]"]

	add_overlay(overlays_to_add)
