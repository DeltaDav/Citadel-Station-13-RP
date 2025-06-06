// Generic damage proc (slimes and monkeys).
/atom/proc/attack_generic(mob/user as mob)
	return 0

/atom/proc/attack_alien(mob/user)

/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	// if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
	// 	if(src == A)
	// 		check_self_for_injuries()
	// 	return
	if(!..())
		return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(istype(G) && G.Touch(A,1))
		return

	A.attack_hand(src, default_clickchain_event_args(A))

/// Return TRUE to cancel other attack hand effects that respect it.
//  todo: better desc
//  todo: e_args is not specified all the time, yet.
/atom/proc/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	// todo: remove
	if(isnull(e_args))
		e_args = user.default_clickchain_event_args(src, TRUE)
	// end
	if(on_attack_hand(e_args, NONE))
		return TRUE
	if(user.a_intent == INTENT_HARM)
		return user.melee_attack_chain(e_args)
	. = _try_interact(user)

/**
 * Override this instead of attack_hand.
 * This happens before melee attack chain checks.
 *
 * @params
 * * e_args - click data
 *
 * @return clickchain flags
 */
/atom/proc/on_attack_hand(datum/event_args/actor/clickchain/clickchain, clickchain_flags)
	return NONE

//Return a non FALSE value to cancel whatever called this from propagating, if it respects it.
/atom/proc/_try_interact(mob/user)
	// if(isAdminGhostAI(user))		//admin abuse
	// 	return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user)
	// if(!user.can_interact_with(src))
	// 	return FALSE
	// if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
	// 	to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
	// 	return FALSE
	// if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
	// 	return FALSE
	return TRUE

/atom/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(!can_interact(user) && !IsAdminGhost(user))
		. = min(., UI_UPDATE)

/atom/movable/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	if(!anchored && (interaction_flags_atom & INTERACT_ATOM_REQUIRES_ANCHORED))
		return FALSE

/atom/proc/interact(mob/user)
	if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	// if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
	return (ui_interact(user) || nano_ui_interact(user))
	// return FALSE

/mob/living/carbon/human/RestrainedClickOn(var/atom/A)
	return

/mob/living/carbon/human/RangedAttack(atom/A)
	. = ..()
	if(.)
		return
	if(isturf(A) && get_dist(A, src) <= 1)
		move_pulled_towards(A)
		return
	if(!gloves && !mutations.len && !spitting)
		return
	var/obj/item/clothing/gloves/G = gloves
	if((MUTATION_LASER in mutations) && a_intent == INTENT_HARM)
		LaserEyes(A) // moved into a proc below

	else if(istype(G) && G.Touch(A,0)) // for magic gloves
		return

	else if(MUTATION_TELEKINESIS in mutations)
		A.attack_tk(src)

	else if(spitting) //Only used by xenos right now, can be expanded.
		Spit(A)

/mob/living/RestrainedClickOn(var/atom/A)
	return

/*
	Animals & All Unspecified
*/
// /mob/living/UnarmedAttack(atom/A)
// 	A.attack_animal(src)

// /atom/proc/attack_animal(mob/user)
// 	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ANIMAL, user)

/*
	Aliens
*/

/mob/living/carbon/alien/RestrainedClickOn(var/atom/A)
	return

/mob/living/carbon/alien/UnarmedAttack(atom/A)
	if(!..())
		return FALSE

	setClickCooldownLegacy(get_attack_speed_legacy())
	A.attack_generic(src,rand(5,6),"bitten")

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/ClickOn()
	return
