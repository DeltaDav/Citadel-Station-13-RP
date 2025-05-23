
var/global/list/weavable_structures = list()
var/global/list/weavable_items = list()

// Structures

/obj/effect/weaversilk
	name = "weaversilk web"
	desc = "A thin layer of fiberous webs. It looks like it can be torn down with one strong hit."
	icon = 'icons/vore/weaver_icons_vr.dmi'
	anchored = TRUE
	density = FALSE

/obj/effect/weaversilk/legacy_ex_act(severity)
	qdel(src)
	return

/obj/effect/weaversilk/attackby(var/obj/item/W, var/mob/user)
	user.setClickCooldownLegacy(user.get_attack_speed_legacy(W))

	if(W.damage_force)
		visible_message("<span class='warning'>\The [src] has been [W.get_attack_verb(src, user)] with \the [W][(user ? " by [user]." : ".")]</span>")
		qdel(src)

/obj/effect/weaversilk/on_bullet_act(obj/projectile/proj, impact_flags, list/bullet_act_args)
	. = ..()
	if(proj.get_structure_damage())
		qdel(src)

/obj/effect/weaversilk/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	qdel(src)

/obj/effect/weaversilk/attack_generic(mob/user as mob, var/damage)
	if(damage)
		qdel(src)

/obj/effect/weaversilk/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	..()
	if(user.a_intent == INTENT_HARM)
		to_chat(user,"<span class='warning'>You easily tear down [name].</span>")
		qdel(src)

/obj/effect/weaversilk/floor
	var/possible_icon_states = list("floorweb1", "floorweb2", "floorweb3", "floorweb4", "floorweb5", "floorweb6", "floorweb7", "floorweb8")

/obj/effect/weaversilk/floor/Initialize(mapload)
	..()
	icon_state = pick(possible_icon_states)

/obj/effect/weaversilk/wall
	name = "weaversilk web wall"
	desc = "A thin layer of fiberous webs, but just thick enough to block your way. It looks like it can be torn down with one strong hit."
	icon_state = "wallweb1"
	var/possible_icon_states = list("wallweb1", "wallweb2", "wallweb3")
	density = TRUE

/obj/effect/weaversilk/wall/Initialize(mapload)
	..()
	icon_state = pick(possible_icon_states)

/obj/effect/weaversilk/wall/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mover
		for(var/F in H.contents)
			if(istype(F, /obj/item/organ/internal/weaver))
				return TRUE
	..()

/obj/structure/bed/double/weaversilk_nest
	name = "weaversilk nest"
	desc = "A nest of some kind, made of fiberous material."
	icon = 'icons/vore/weaver_icons_vr.dmi'
	icon_state = "nest"
	base_icon = "nest"

/obj/structure/bed/double/weaversilk_nest/update_icon()
	return

/obj/structure/bed/double/weaversilk_nest/attackby(obj/item/W as obj, mob/user as mob)
	if(W.is_wrench() || istype(W,/obj/item/stack) || W.is_wirecutter())
		return
	..()

/obj/structure/bed/double/weaversilk_nest/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	..()
	if(user.a_intent == INTENT_HARM && !has_buckled_mobs())
		to_chat(user,"<span class='warning'>You easily tear down [name].</span>")
		qdel(src)

/obj/effect/weaversilk/trap
	name = "weaversilk trap"
	desc = "A silky, yet firm trap. Be careful not to step into it! Or don't..."
	icon_state = "trap"
	buckle_allowed = TRUE
	var/trap_active = TRUE

/obj/effect/weaversilk/trap/Crossed(atom/movable/AM as mob|obj)
	if(AM.is_incorporeal() || AM.is_avoiding_ground()) //The flavor is stepping onto it to trigger, so if we aren't stepping anywhere
		return
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		for(var/F in H.contents)
			if(istype(F, /obj/item/organ/internal/weaver))
				return

	if(isliving(AM) && trap_active)
		var/mob/living/L = AM
		if(L.m_intent == MOVE_INTENT_RUN)
			L.visible_message(
				"<span class='danger'>[L] steps on \the [src].</span>",
				"<span class='danger'>You step on \the [src]!</span>",
				"<b>You hear a squishy noise!</b>"
				)
			buckle_mob(L, BUCKLE_OP_FORCE)
			L.afflict_stun(20 * 1)
			to_chat(L, "<span class='danger'>The sticky fibers of \the [src] ensnare, trapping you in place!</span>")
			trap_active = FALSE
			desc += " Actually, it looks like it's been all spent."
	..()

/obj/effect/weaversilk/trap/MouseDroppedOnLegacy(atom/movable/AM,mob/user)
	return

// Items

// TODO: Spidersilk clothing and actual bindings, once sprites are ready.

/obj/item/clothing/suit/weaversilk_bindings
	icon = 'icons/vore/custom_clothes_vr.dmi'
	icon_override = 'icons/vore/custom_clothes_vr.dmi'
	name = "weaversilk bindings"
	desc = "A webbed cocoon that completely restrains the wearer."
	icon_state = "web_bindings"
	item_state = "web_bindings_mob"
	body_cover_flags = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL

