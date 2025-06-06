/obj/projectile/energy/blob //Not super strong.
	name = "spore"
	icon_state = "declone"
	damage_force = 3
	damage_tier = 3.5
	damage_type = DAMAGE_TYPE_BRUTE
	damage_flag = ARMOR_MELEE
	pass_flags = ATOM_PASS_TABLE | ATOM_PASS_BLOB
	fire_sound = 'sound/effects/slime_squish.ogg'
	var/splatter = FALSE			// Will this make a cloud of reagents?
	var/splatter_volume = 5			// The volume of its chemical container, for said cloud of reagents.
	var/list/my_chems = list("mold")

/obj/projectile/energy/blob/splattering
	splatter = TRUE

/obj/projectile/energy/blob/Initialize(mapload)
	. = ..()
	if(splatter)
		create_reagents(splatter_volume)
		ready_chemicals()

/obj/projectile/energy/blob/Destroy()
	qdel(reagents)
	reagents = null
	..()

/obj/projectile/energy/blob/on_impact(atom/target, impact_flags, def_zone, efficiency)
	. = ..()
	if(. & PROJECTILE_IMPACT_FLAGS_UNCONDITIONAL_ABORT)
		return

	if(splatter)
		var/turf/location = get_turf(src)
		var/datum/effect_system/smoke_spread/chem/S = new /datum/effect_system/smoke_spread/chem
		S.attach(location)
		S.set_up(reagents, splatter_volume, 0, location)
		playsound(location, 'sound/effects/slime_squish.ogg', 30, 1, -3)
		spawn(0)
			S.start()

/obj/projectile/energy/blob/proc/ready_chemicals()
	if(reagents)
		var/reagent_vol = (round((splatter_volume / my_chems.len) * 100) / 100) //Cut it at the hundreds place, please.
		for(var/reagent in my_chems)
			reagents.add_reagent(reagent, reagent_vol)

/obj/projectile/energy/blob/toxic
	damage_type = DAMAGE_TYPE_TOX
	damage_flag = ARMOR_BIO
	my_chems = list("amatoxin")

/obj/projectile/energy/blob/toxic/splattering
	splatter = TRUE

/obj/projectile/energy/blob/acid
	damage_type = DAMAGE_TYPE_BURN
	damage_flag = ARMOR_BIO
	my_chems = list("sacid", "mold")

/obj/projectile/energy/blob/acid/splattering
	splatter = TRUE

/obj/projectile/energy/blob/combustible
	splatter = TRUE
	flammability = 0.25
	my_chems = list("fuel", "mold")

/obj/projectile/energy/blob/freezing
	my_chems = list("frostoil")
	modifier_type_to_apply = /datum/modifier/chilled
	modifier_duration = 1 MINUTE

/obj/projectile/energy/blob/freezing/splattering
	splatter = TRUE
