/// Attacks mobs (atm only simple ones due to friendly fire issues) that are adjacent to the target and user.
/obj/item/proc/cleave(mob/living/user, atom/target)
	if(cleaving)
		return FALSE // We're busy.
	if(!target.Adjacent(user))
		return FALSE // Too far.
	if(get_turf(user) == get_turf(target))
		return FALSE // Otherwise we would hit all eight surrounding tiles.

	cleaving = TRUE
	var/hit_mobs = 0
	for(var/mob/living/simple_mob/SM in range(get_turf(target), 1))
		if(SM.stat == DEAD) // Don't beat a dead horse.
			continue
		if(SM == user) // Don't hit ourselves.  Simple mobs shouldn't be able to do this but that might change later to be able to hit all mob/living-s.
			continue
		if(SM == target) // We (presumably) already hit the target before cleave() was called.  orange() should prevent this but just to be safe...
			continue
		if(!SM.Adjacent(user) || !SM.Adjacent(target)) // Cleaving only hits mobs near the target mob and user.
			continue
		//! WARNING: infinite loop risk here. !//
		//* if cleave() is ever refactored, make sure we're not calling melee_attack_chain *//
		//* if we're being called *from* melee_attack_chain!                               *//
		var/datum/event_args/actor/clickchain/created_clickchain = user.default_clickchain_event_args(target, FALSE)
		created_clickchain.attack_melee_multiplier *= 0.5
		melee_attack_chain(created_clickchain)
		hit_mobs++

	cleave_visual(user, target)

	if(hit_mobs)
		to_chat(user, SPAN_DANGER("You used \the [src] to attack [hit_mobs] other thing\s!"))
	cleaving = FALSE // We're done now.
	return hit_mobs > 0 // Returns TRUE if anything got hit.

/// This cannot go into afterattack since some mobs delete themselves upon dying.
/obj/item/material/pre_attack(atom/target, mob/user, clickchain_flags, list/params)
	if(can_cleave && isliving(target))
		cleave(user, target)
	return ..()

/// This is purely the visual effect of cleaving.
/obj/item/proc/cleave_visual(mob/living/user, mob/living/target)
	var/obj/effect/temporary_effect/cleave_attack/E = new(get_turf(src))
	E.dir = get_dir(user, target)
