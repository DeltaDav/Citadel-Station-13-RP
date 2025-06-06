/atom/proc/stumble_into(mob/living/M)
	playsound(get_turf(M), "punch", 25, 1, -1)
	visible_message("<span class='warning'>[M] [pick("ran", "slammed")] into \the [src]!</span>")
	to_chat(M, "<span class='warning'>You just [pick("ran", "slammed")] into \the [src]!</span>")
	M.apply_damage(5, DAMAGE_TYPE_BRUTE)
	M.afflict_paralyze(20 * 2)
	M.stop_flying()

/obj/structure/table/stumble_into(mob/living/M)
	var/obj/occupied = turf_is_crowded()
	if(occupied)
		return ..()
	if(material_base)
		playsound(get_turf(src), material_base.tableslam_noise, 25, 1, -1)
	else
		playsound(get_turf(src), 'sound/weapons/tablehit1.ogg', 25, 1, -1)
	visible_message("<span class='warning'>[M] flopped onto \the [src]!</span>")
	M.apply_damage(5, DAMAGE_TYPE_BRUTE)
	M.afflict_paralyze(20 * 2)
	M.forceMove(get_turf(src))
	M.stop_flying()

/obj/machinery/disposal/stumble_into(mob/living/M)
	playsound(get_turf(src), 'sound/effects/clang.ogg', 25, 1, -1)
	visible_message("<span class='warning'>[M] [pick("tripped", "stumbled")] into \the [src]!</span>")
	M.apply_damage(5, DAMAGE_TYPE_BRUTE)
	M.afflict_paralyze(20 * 2)
	M.forceMove(src)
	M.update_perspective()
	M.stop_flying()
	update()

/obj/structure/inflatable/stumble_into(mob/living/M)
	playsound(get_turf(M), "sound/effects/Glasshit.ogg", 25, 1, -1)
	visible_message("<span class='warning'>[M] [pick("ran", "slammed")] into \the [src]!</span>")
	M.afflict_paralyze(20 * 1)
	M.stop_flying()

/obj/structure/kitchenspike/stumble_into(mob/living/M)
	playsound(get_turf(M), "sound/weapons/pierce.ogg", 25, 1, -1)
	visible_message("<span class='warning'>[M] [pick("ran", "slammed")] into the spikes on \the [src]!</span>")
	M.apply_damage(15, DAMAGE_TYPE_BRUTE, sharp=1)
	M.afflict_paralyze(20 * 5)
	M.stop_flying()

/obj/structure/m_tray/stumble_into(mob/living/M)
	playsound(get_turf(src), 'sound/weapons/tablehit1.ogg', 25, 1, -1)
	visible_message("<span class='warning'>[M] flopped onto \the [src]!</span>")
	M.apply_damage(5, DAMAGE_TYPE_BRUTE)
	M.afflict_paralyze(20 * 2)
	M.forceMove(get_turf(src))
	M.stop_flying()

/obj/structure/c_tray/stumble_into(mob/living/M)
	playsound(get_turf(src), 'sound/weapons/tablehit1.ogg', 25, 1, -1)
	visible_message("<span class='warning'>[M] flopped onto \the [src]!</span>")
	M.apply_damage(5, DAMAGE_TYPE_BRUTE)
	M.afflict_paralyze(20 * 2)
	M.forceMove(get_turf(src))
	M.stop_flying()

/obj/structure/window/stumble_into(mob/living/M)
	visible_message("<span class='warning'>[M] [pick("ran", "slammed")] into \the [src]!</span>")
	M.apply_damage(5, DAMAGE_TYPE_BRUTE)
	M.afflict_paralyze(20 * 2)
	M.stop_flying()

/obj/structure/railing/stumble_into(mob/living/M)
	var/obj/occupied = neighbor_turf_impassable()
	if(occupied)
		return ..()
	playsound(get_turf(src), 'sound/misc/slip.ogg', 25, 1, -1)
	visible_message("<span class='warning'>[M] [pick("tripped", "stumbled")] over \the [src]!</span>")
	M.afflict_paralyze(20 * 2)
	M.stop_flying()
	if(get_turf(M) == get_turf(src))
		M.forceMove(get_step(src, src.dir))
	else
		M.forceMove(get_turf(src))

/obj/machinery/door/window/stumble_into(mob/living/M)
	..()
	bumpopen(M)

/obj/machinery/door/airlock/stumble_into(mob/living/M)
	..()
	bumpopen(M)

/obj/machinery/appliance/cooker/fryer/stumble_into(mob/living/M) // Citadel change
	visible_message("<span class='warning'>[M] [pick("ran", "slammed")] into \the [src]!</span>")
	M.apply_damage(15, DAMAGE_TYPE_BURN)
	M.afflict_paralyze(20 * 5)
	M.emote_nosleep("scream")
	M.stop_flying()

/obj/machinery/atmospherics/component/unary/cryo_cell/stumble_into(mob/living/M)
	if((machine_stat & (NOPOWER|BROKEN)) || !istype(M, /mob/living/carbon) || occupant || M.abiotic() || !node)
		return ..()
	playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 25, 1, -1)
	visible_message("<span class='warning'>[M] [pick("tripped", "stumbled")] into \the [src]!</span>")
	M.apply_damage(5, DAMAGE_TYPE_BRUTE)
	M.afflict_paralyze(20 * 2)
	put_mob(M)
	M.stop_flying()

/obj/machinery/porta_turret/stumble_into(mob/living/M)
	..()
	if(!attacked && !emagged)
		attacked = 1
		spawn()
			sleep(60)
			attacked = 0

/obj/machinery/space_heater/stumble_into(mob/living/M)
	..()
	if(on)
		M.apply_damage(10, DAMAGE_TYPE_BURN)
		M.emote_nosleep("scream")

/obj/machinery/suit_storage_unit/stumble_into(mob/living/M)
	if(!ishuman(M) || !isopen || !ispowered || isbroken || occupant || helmet_stored || suit_stored)
		return ..()
	playsound(src, 'sound/effects/clang.ogg', 25, 1, -1)
	visible_message("<span class='warning'>[M] [pick("tripped", "stumbled")] into \the [src]!</span>")
	M.forceMove(src)
	M.update_perspective()
	occupant = M
	isopen = 0
	update_icon()
	add_fingerprint(M)
	updateUsrDialog()
	M.stop_flying()

/obj/machinery/vending/stumble_into(mob/living/M)
	..()
	if(prob(2))
		throw_item()
