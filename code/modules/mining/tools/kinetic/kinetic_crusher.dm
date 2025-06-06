/*********************Mining Hammer****************/
/obj/item/kinetic_crusher
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusher"
	item_state = "crusher0"
	item_icons = list(
		SLOT_ID_LEFT_HAND = 'icons/mob/inhands/weapons/hammers_lefthand.dmi',
		SLOT_ID_RIGHT_HAND = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
		)
	name = "proto-kinetic crusher"
	desc = "An early design of the proto-kinetic accelerator, it is little more than an combination of various mining tools cobbled together, forming a high-tech club. \
	While it is an effective mining tool, it did little to aid any but the most skilled and/or suicidal miners against local fauna."
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	throw_force = 5
	throw_speed = 4
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("smashed", "crushed", "cleaved", "chopped", "pulped")
	damage_mode = DAMAGE_MODE_SHARP | DAMAGE_MODE_EDGE
	item_action_name = "Toggle Light"
	light_wedge = LIGHT_WIDE
	// actions_types = list(/datum/action/item_action/toggle_light)
	// var/list/trophies = list()
	var/charged = TRUE
	var/charge_time = 15
	var/detonation_damage = 50
	var/backstab_bonus = 30
	var/light_on = FALSE
	var/brightness_on = 7
	var/wielded = FALSE // track wielded status on item
	/// Damage penalty factor to detonation damage to non simple mobs
	var/human_damage_nerf = 0.25
	/// Damage penalty factor to backstab bonus damage to non simple mobs
	var/human_backstab_nerf = 0.25
	/// damage buff for throw impacts
	var/thrown_bonus = 35
	/// do we need to be wielded?
	var/requires_wield = TRUE
	/// do we have a charge overlay?
	var/charge_overlay = TRUE
	/// do we update item state?
	var/update_item_state = FALSE

/obj/item/kinetic_crusher/cyborg //probably give this a unique sprite later
	desc = "An integrated version of the standard kinetic crusher with a grinded down axe head to dissuade mis-use against crewmen. Deals damage equal to the standard crusher against creatures, however."
	damage_force = 10 //wouldn't want to give a borg a 20 brute melee weapon unemagged now would we
	detonation_damage = 60
	wielded = 1

/obj/item/kinetic_crusher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/conflict_checking, CONFLICT_ELEMENT_CRUSHER)

/*
/obj/item/kinetic_crusher/Initialize(mapload)
	. = ..()
	if(requires_Wield)
		RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))
		RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, PROC_REF(on_unwield))
/obj/item/kinetic_crusher/ComponentInitialize()
	. = ..()
	if(requires_wield)
		AddComponent(/datum/component/butchering, 60, 110) //technically it's huge and bulky, but this provides an incentive to use it
		AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=20)
*/

/obj/item/kinetic_crusher/Destroy()
	// QDEL_LIST(trophies)
	return ..()

/obj/item/kinetic_crusher/emag_act()
	. = ..()
	if(obj_flags & OBJ_EMAGGED)
		return
	obj_flags |= OBJ_EMAGGED

/obj/item/kinetic_crusher/proc/can_mark(mob/living/victim)
	if(obj_flags & OBJ_EMAGGED)
		return TRUE
	return !ishuman(victim) && !issilicon(victim)

/obj/item/kinetic_crusher/examine(mob/living/user)
	. = ..()
	. += "<span class='notice'>Mark a large creature with the destabilizing force, then hit them in melee to do <b>[damage_force + detonation_damage]</b> damage.</span>"
	. += "<span class='notice'>Does <b>[damage_force + detonation_damage + backstab_bonus]</b> damage if the target is backstabbed, instead of <b>[damage_force + detonation_damage]</b>.</span>"
/*
	for(var/t in trophies)
		var/obj/item/crusher_trophy/T = t
		. += "<span class='notice'>It has \a [T] attached, which causes [T.effect_desc()].</span>"
*/

/*
/obj/item/kinetic_crusher/attackby(obj/item/I, mob/living/user)
	if(I.tool_behaviour == TOOL_CROWBAR)
		if(LAZYLEN(trophies))
			to_chat(user, "<span class='notice'>You remove [src]'s trophies.</span>")
			I.play_tool_sound(src)
			for(var/t in trophies)
				var/obj/item/crusher_trophy/T = t
				T.remove_from(src, user)
		else
			to_chat(user, "<span class='warning'>There are no trophies on [src].</span>")
	else if(istype(I, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/T = I
		T.add_to(src, user)
	else
		return ..()
*/

/obj/item/kinetic_crusher/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	var/mob/living/L = target
	if(!istype(L))
		return ..()
	if(!wielded && requires_wield)
		to_chat(user, "<span class='warning'>[src] is too heavy to use with one hand.")
		return
	. = ..()
/*
	for(var/t in trophies)
		if(!QDELETED(L))
			var/obj/item/crusher_trophy/T = t
			T.on_melee_hit(L, user)
*/

/obj/item/kinetic_crusher/afterattack(atom/target, mob/user, clickchain_flags, list/params)
	. = ..()
/*
	if(istype(target, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/T = target
		T.add_to(src, user)
*/
	if(requires_wield && !wielded)
		return
	if(!(clickchain_flags & CLICKCHAIN_HAS_PROXIMITY) && charged)//Mark a target, or mine a tile.
		var/turf/proj_turf = user.loc
		if(!isturf(proj_turf))
			return
		var/obj/projectile/destabilizer/D = new /obj/projectile/destabilizer(proj_turf)
/*
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_projectile_fire(D, user)
*/
		D.preparePixelProjectile(target, user, list2params(params))
		D.firer = user
		D.hammer_synced = src
		playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, 1)
		D.fire()
		charged = FALSE
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(Recharge)), charge_time * (user?.ConflictElementCount(CONFLICT_ELEMENT_CRUSHER) || 1))
		return
	if((clickchain_flags & CLICKCHAIN_HAS_PROXIMITY) && isliving(target))
		detonate(target, user)

/obj/item/kinetic_crusher/proc/detonate(mob/living/L, mob/living/user, thrown = FALSE)
	var/datum/status_effect/grouped/proto_kinetic_mark/CM = L.has_status_effect(/datum/status_effect/grouped/proto_kinetic_mark)
	if(!CM || (CM.has_source(WEAKREF(src))) || !L.remove_status_effect(/datum/status_effect/grouped/proto_kinetic_mark))
		return
	if(!QDELETED(L))
		new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
		var/backstab_dir = get_dir(user, L)
		var/def_check = L.legacy_mob_armor(type = "bomb")
		var/detonation_damage = src.detonation_damage * (!ishuman(L)? 1 : human_damage_nerf)
		var/backstab_bonus = src.backstab_bonus * (!ishuman(L)? 1 : human_backstab_nerf)
		var/thrown_bonus = thrown? (src.thrown_bonus * (!ishuman(L)? 1 : human_damage_nerf)) : 0
		if(thrown? (get_dir(src, L) & L.dir) : ((user.dir & backstab_dir) && (L.dir & backstab_dir)))
			L.apply_damage(detonation_damage + backstab_bonus + thrown_bonus, DAMAGE_TYPE_BRUTE, blocked = def_check)
			playsound(src, 'sound/weapons/kenetic_accel.ogg', 100, TRUE)
		else
			L.apply_damage(detonation_damage + thrown_bonus, DAMAGE_TYPE_BRUTE, blocked = def_check)
			playsound(src, 'sound/weapons/resonator_blast.ogg', 75, TRUE)

/obj/item/kinetic_crusher/throw_impact(atom/A, datum/thrownthing/TT)
	. = ..()
	if(!isliving(A))
		return
	var/mob/living/L = A
	if(!L.has_status_effect(/datum/status_effect/grouped/proto_kinetic_mark))
		detonate(L, TT.thrower, TRUE)

/obj/item/kinetic_crusher/proc/Recharge()
	if(!charged)
		charged = TRUE
		update_icon()
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)

/obj/item/kinetic_crusher/ui_action_click(datum/action/action, datum/event_args/actor/actor)
	light_on = !light_on
	playsound(src, 'sound/weapons/empty.ogg', 100, TRUE)
	update_brightness(actor.performer)
	update_icon()

/obj/item/kinetic_crusher/proc/update_brightness(mob/user = null)
	if(light_on)
		set_light(brightness_on)
	else
		set_light(0)

/obj/item/kinetic_crusher/update_icon_state()
	. = ..()
	if(update_item_state)
		item_state = "crusher[wielded]" // this is not icon_state and not supported by 2hcomponent

/obj/item/kinetic_crusher/update_overlays()
	. = ..()
	if(!charged && charge_overlay)
		. += "[icon_state]_uncharged"
	if(light_on)
		. += "[icon_state]_lit"

/*
/obj/item/kinetic_crusher/glaive
	name = "proto-kinetic glaive"
	desc = "A modified design of a proto-kinetic crusher, it is still little more of a combination of various mining tools cobbled together \
	and kit-bashed into a high-tech cleaver on a stick - with a handguard and a goliath hide grip. While it is still of little use to any \
	but the most skilled and/or suicidal miners against local fauna, it's an elegant weapon for a more civilized hunter."
	attack_verb = list("stabbed", "diced", "sliced", "cleaved", "chopped", "lacerated", "cut", "jabbed", "punctured")
	icon_state = "crusher-glaive"
	item_state = "crusher0-glaive"
	block_parry_data = /datum/block_parry_data/crusherglaive
	//ideas: altclick that lets you pummel people with the handguard/handle?
	//parrying functionality?
/datum/block_parry_data/crusherglaive // small perfect window, active for a fair while, time it right or use the Forbidden Technique
	parry_time_windup = 0
	parry_time_active = 8
	parry_time_spindown = 0
	parry_time_perfect = 1
	parry_time_perfect_leeway = 2
	parry_imperfect_falloff_percent = 20
	parry_efficiency_to_counterattack = 100 // perfect parry or you're cringe
	parry_failed_stagger_duration = 1.5 SECONDS // a good time to reconsider your actions...
	parry_failed_clickcd_duration = 1.5 SECONDS // or your failures
/obj/item/kinetic_crusher/glaive/on_active_parry(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, list/block_return, parry_efficiency, parry_time) // if you're dumb enough to go for a parry...
	var/turf/proj_turf = owner.loc // destabilizer bolt, ignoring cooldown
	if(!isturf(proj_turf))
		return
	var/obj/projectile/destabilizer/D = new /obj/projectile/destabilizer(proj_turf)
	for(var/t in trophies)
		var/obj/item/crusher_trophy/T = t
		T.on_projectile_fire(D, owner)
	D.preparePixelProjectile(attacker, owner)
	D.firer = owner
	D.hammer_synced = src
	playsound(owner, 'sound/weapons/plasma_cutter.ogg', 100, 1)
	D.fire()
/obj/item/kinetic_crusher/glaive/active_parry_reflex_counter(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, list/return_list, parry_efficiency, list/effect_text)
	if(owner.Adjacent(attacker) && (!attacker.anchored || ismegafauna(attacker))) // free backstab, if you perfect parry
		attacker.dir = get_dir(owner,attacker)
/// triggered on wield of two handed item
/obj/item/kinetic_crusher/glaive/on_wield(obj/item/source, mob/user)
	wielded = TRUE
	item_flags |= (ITEM_CAN_PARRY)
/// triggered on unwield of two handed item
/obj/item/kinetic_crusher/glaive/on_unwield(obj/item/source, mob/user)
	wielded = FALSE
	item_flags &= ~(ITEM_CAN_PARRY)
/obj/item/kinetic_crusher/glaive/update_icon_state()
	item_state = "crusher[wielded]-glaive" // this is not icon_state and not supported by 2hcomponent
*/

/obj/item/kinetic_crusher/dagger
	name = "proto-kinetic dagger"
	desc = "A scaled down version of a protokinetic crusher, usually used in a last ditch scenario."
	icon_state = "glaive-dagger"
	item_icons = list(
			SLOT_ID_LEFT_HAND = 'icons/mob/items/lefthand_material.dmi',
			SLOT_ID_RIGHT_HAND = 'icons/mob/items/righthand_material.dmi',
			)
	item_state = "machete"
	w_class = WEIGHT_CLASS_SMALL
	damage_force = 15
	requires_wield = FALSE
	charge_overlay = FALSE
	// yeah yeah buff but rp mobs are tough as fuck.
	backstab_bonus = 35
	detonation_damage = 25
	// woohoo
	thrown_bonus = 35
	update_item_state = FALSE

//destablizing force
/obj/projectile/destabilizer
	name = "destabilizing force"
	icon_state = "pulse1"
	nodamage = TRUE
	// We're just here to mark people. This is still a melee weapon.
	damage_force = 0
	damage_type = DAMAGE_TYPE_BRUTE
	damage_flag = ARMOR_BOMB
	range = WORLD_ICON_SIZE * 6
	accuracy_disabled = TRUE
	// log_override = TRUE
	var/obj/item/kinetic_crusher/hammer_synced

/obj/projectile/destabilizer/Destroy()
	hammer_synced = null
	return ..()

/obj/projectile/destabilizer/on_impact(atom/target, impact_flags, def_zone, efficiency)
	. = ..()
	if(. & PROJECTILE_IMPACT_FLAGS_UNCONDITIONAL_ABORT)
		return
	if(isliving(target))
		var/mob/living/L = target
		if(hammer_synced.can_mark(L))
			L.apply_grouped_status_effect(
				/datum/status_effect/grouped/proto_kinetic_mark,
				WEAKREF(src),
				TRUE,
			)
		// var/had_effect = (L.has_status_effect(/datum/status_effect/grouped/proto_kinetic_mark)) //used as a boolean
		// var/datum/status_effect/grouped/proto_kinetic_mark/CM = L.apply_status_effect(/datum/status_effect/grouped/proto_kinetic_mark, hammer_synced)
/*
		if(hammer_synced)
			for(var/t in hammer_synced.trophies)
				var/obj/item/crusher_trophy/T = t
				T.on_mark_application(target, CM, had_effect)
*/
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		var/turf/simulated/mineral/M = target_turf
		new /obj/effect/temp_visual/kinetic_blast(M)
		M.GetDrilled(firer)

/*
//trophies
/obj/item/crusher_trophy
	name = "tail spike"
	desc = "A strange spike with no usage."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "tail_spike"
	var/bonus_value = 10 //if it has a bonus effect, this is how much that effect is
	var/denied_type = /obj/item/crusher_trophy
/obj/item/crusher_trophy/examine(mob/living/user)
	. = ..()
	. += "<span class='notice'>Causes [effect_desc()] when attached to a kinetic crusher.</span>"
/obj/item/crusher_trophy/proc/effect_desc()
	return "errors"
/obj/item/crusher_trophy/attackby(obj/item/A, mob/living/user)
	if(istype(A, /obj/item/kinetic_crusher))
		add_to(A, user)
	else
		..()
/obj/item/crusher_trophy/proc/add_to(obj/item/kinetic_crusher/H, mob/living/user)
	for(var/t in H.trophies)
		var/obj/item/crusher_trophy/T = t
		if(istype(T, denied_type) || istype(src, T.denied_type))
			to_chat(user, "<span class='warning'>You can't seem to attach [src] to [H]. Maybe remove a few trophies?</span>")
			return FALSE
	if(!user.transferItemToLoc(src, H))
		return
	H.trophies += src
	to_chat(user, "<span class='notice'>You attach [src] to [H].</span>")
	return TRUE
/obj/item/crusher_trophy/proc/remove_from(obj/item/kinetic_crusher/H, mob/living/user)
	forceMove(get_turf(H))
	H.trophies -= src
	return TRUE
/obj/item/crusher_trophy/proc/on_melee_hit(mob/living/target, mob/living/user) //the target and the user
/obj/item/crusher_trophy/proc/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user) //the projectile fired and the user
/obj/item/crusher_trophy/proc/on_mark_application(mob/living/target, datum/status_effect/crusher_mark/mark, had_mark) //the target, the mark applied, and if the target had a mark before
/obj/item/crusher_trophy/proc/on_mark_detonation(mob/living/target, mob/living/user) //the target and the user
//goliath
/obj/item/crusher_trophy/goliath_tentacle
	name = "goliath tentacle"
	desc = "A sliced-off goliath tentacle. Suitable as a trophy for a kinetic crusher."
	icon_state = "goliath_tentacle"
	denied_type = /obj/item/crusher_trophy/goliath_tentacle
	bonus_value = 2
	var/missing_health_ratio = 0.1
	var/missing_health_desc = 10
/obj/item/crusher_trophy/goliath_tentacle/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> more damage for every <b>[missing_health_desc]</b> health you are missing"
/obj/item/crusher_trophy/goliath_tentacle/on_mark_detonation(mob/living/target, mob/living/user)
	var/missing_health = user.health - user.maxHealth
	missing_health *= missing_health_ratio //bonus is active at all times, even if you're above 90 health
	missing_health *= bonus_value //multiply the remaining amount by bonus_value
	if(missing_health > 0)
		target.adjustBruteLoss(missing_health) //and do that much damage
/*
//watcher
/obj/item/crusher_trophy/watcher_wing
	name = "watcher wing"
	desc = "A wing ripped from a watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "watcher_wing"
	denied_type = /obj/item/crusher_trophy/watcher_wing
	bonus_value = 10
/obj/item/crusher_trophy/watcher_wing/effect_desc()
	return "mark detonation to prevent certain creatures from using certain attacks for <b>[bonus_value*0.1]</b> second\s"
/obj/item/crusher_trophy/watcher_wing/on_mark_detonation(mob/living/target, mob/living/user)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = target
		if(H.ranged) //briefly delay ranged attacks
			if(H.ranged_cooldown >= world.time)
				H.ranged_cooldown += bonus_value
			else
				H.ranged_cooldown = bonus_value + world.time
//magmawing watcher
/obj/item/crusher_trophy/blaster_tubes/magma_wing
	name = "magmawing watcher wing"
	desc = "A still-searing wing from a magmawing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "magma_wing"
	gender = NEUTER
	bonus_value = 5
/obj/item/crusher_trophy/blaster_tubes/magma_wing/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[bonus_value]</b> damage"
/obj/item/crusher_trophy/blaster_tubes/magma_wing/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "heated [marker.name]"
		marker.icon_state = "lava"
		marker.damage = bonus_value
		marker.nodamage = FALSE
		deadly_shot = FALSE
//icewing watcher
/obj/item/crusher_trophy/watcher_wing/ice_wing
	name = "icewing watcher wing"
	desc = "A carefully preserved frozen wing from an icewing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "ice_wing"
	bonus_value = 8
*/
//legion
/obj/item/crusher_trophy/legion_skull
	name = "legion skull"
	desc = "A dead and lifeless legion skull. Suitable as a trophy for a kinetic crusher."
	icon_state = "legion_skull"
	denied_type = /obj/item/crusher_trophy/legion_skull
	bonus_value = 3
/obj/item/crusher_trophy/legion_skull/effect_desc()
	return "a kinetic crusher to recharge <b>[bonus_value*0.1]</b> second\s faster"
/obj/item/crusher_trophy/legion_skull/add_to(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time -= bonus_value
/obj/item/crusher_trophy/legion_skull/remove_from(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time += bonus_value
/*
//blood-drunk hunter
/obj/item/crusher_trophy/miner_eye
	name = "eye of a blood-drunk hunter"
	desc = "Its pupil is collapsed and turned to mush. Suitable as a trophy for a kinetic crusher."
	icon_state = "hunter_eye"
	denied_type = /obj/item/crusher_trophy/miner_eye
/obj/item/crusher_trophy/miner_eye/effect_desc()
	return "mark detonation to grant stun immunity and <b>90%</b> damage reduction for <b>1</b> second"
/obj/item/crusher_trophy/miner_eye/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_BLOODDRUNK)
*/
/*
//ash drake
/obj/item/crusher_trophy/tail_spike
	desc = "A spike taken from an ash drake's tail. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/tail_spike
	bonus_value = 5
/obj/item/crusher_trophy/tail_spike/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> damage to nearby creatures and push them back"
/obj/item/crusher_trophy/tail_spike/on_mark_detonation(mob/living/target, mob/living/user)
	for(var/mob/living/L in oview(2, user))
		if(L.stat == DEAD)
			continue
		playsound(L, 'sound/magic/fireball.ogg', 20, 1)
		new /obj/effect/temp_visual/fire(L.loc)
		addtimer(CALLBACK(src, PROC_REF(pushback), L, user), 1) //no free backstabs, we push AFTER module stuff is done
		L.adjustFireLoss(bonus_value, forced = TRUE)
/obj/item/crusher_trophy/tail_spike/proc/pushback(mob/living/target, mob/living/user)
	if(!QDELETED(target) && !QDELETED(user) && (!target.anchored || ismegafauna(target))) //megafauna will always be pushed
		step(target, get_dir(user, target))
*/
//bubblegum
/obj/item/crusher_trophy/demon_claws
	name = "demon claws"
	desc = "A set of blood-drenched claws from a massive demon's hand. Suitable as a trophy for a kinetic crusher."
	icon_state = "demon_claws"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/demon_claws
	bonus_value = 10
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)
/obj/item/crusher_trophy/demon_claws/effect_desc()
	return "melee hits to do <b>[bonus_value * 0.2]</b> more damage and heal you for <b>[bonus_value * 0.1]</b>, with <b>5X</b> effect on mark detonation"
/obj/item/crusher_trophy/demon_claws/add_to(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.damage_force += bonus_value * 0.2
		H.detonation_damage += bonus_value * 0.8
		if(requires_wield)
			AddComponent(/datum/component/two_handed, force_wielded=(20 + bonus_value * 0.2))
/obj/item/crusher_trophy/demon_claws/remove_from(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.damage_force -= bonus_value * 0.2
		H.detonation_damage -= bonus_value * 0.8
		if(requires_wield)
			AddComponent(/datum/component/two_handed, force_wielded=20)
/*
/obj/item/crusher_trophy/demon_claws/on_melee_hit(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.1, damage_heal_order)
/obj/item/crusher_trophy/demon_claws/on_mark_detonation(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.4, damage_heal_order)
*/
//colossus
/obj/item/crusher_trophy/blaster_tubes
	name = "blaster tubes"
	desc = "The blaster tubes from a colossus's arm. Suitable as a trophy for a kinetic crusher."
	icon_state = "blaster_tubes"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/blaster_tubes
	bonus_value = 15
	var/deadly_shot = FALSE
/obj/item/crusher_trophy/blaster_tubes/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[bonus_value]</b> damage but move slower"
/obj/item/crusher_trophy/blaster_tubes/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "deadly [marker.name]"
		marker.icon_state = "chronobolt"
		marker.damage = bonus_value
		marker.nodamage = FALSE
		marker.speed = 2
		deadly_shot = FALSE
/obj/item/crusher_trophy/blaster_tubes/on_mark_detonation(mob/living/target, mob/living/user)
	deadly_shot = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_deadly_shot)), 300, TIMER_UNIQUE|TIMER_OVERRIDE)
/obj/item/crusher_trophy/blaster_tubes/proc/reset_deadly_shot()
	deadly_shot = FALSE
//hierophant
/obj/item/crusher_trophy/vortex_talisman
	name = "vortex talisman"
	desc = "A glowing trinket that was originally the Hierophant's beacon. Suitable as a trophy for a kinetic crusher."
	icon_state = "vortex_talisman"
	denied_type = /obj/item/crusher_trophy/vortex_talisman
	var/vortex_cd
/obj/item/crusher_trophy/vortex_talisman/effect_desc()
	return "mark detonation to create a barrier you can pass that lasts for <b>7.5 seconds</b>, with a cooldown of <b>9 seconds</b> after creation."
/obj/item/crusher_trophy/vortex_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	if(vortex_cd >= world.time)
		return
	var/turf/T = get_turf(user)
	var/obj/effect/temp_visual/hierophant/wall/crusher/W = new (T, user) //a wall only you can pass!
	var/turf/otherT = get_step(T, turn(user.dir, 90))
	if(otherT)
		new /obj/effect/temp_visual/hierophant/wall/crusher(otherT, user)
	otherT = get_step(T, turn(user.dir, -90))
	if(otherT)
		new /obj/effect/temp_visual/hierophant/wall/crusher(otherT, user)
	vortex_cd = world.time + W.duration * 1.2
/obj/effect/temp_visual/hierophant/wall/crusher
	duration = 75
*/

//Crusher Glaives
/obj/item/kinetic_crusher/glaive
	name = "kinetic crusher glaive"
	desc = "A refinement on the original Crusher's design, this high-tech glaive was modeled after observed weaponry carried by Ashlander hunters. \
	Still an effective mining tool, it provides marginally better support as a defensive weapon."
	icon_state = "crusher-glaive"
	item_state = "crusher0-glaive"
	throw_force = 10

/obj/item/kinetic_crusher/glaive/bone
	name = "bone crusher glaive"
	desc = "Crusher glaives were utilized by the Ashlanders long before the colonization of Surt. However, through rare cultural exchanges and trades, \
	the tribes have learned how to enhance the basic bone glaive with their own curious technology - effectively mimicking the kinetic crusher's utility."
	icon_state = "crusher-bone"
	throw_force = 10
