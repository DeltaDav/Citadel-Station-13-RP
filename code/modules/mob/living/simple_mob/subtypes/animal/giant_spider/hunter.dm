// Hunters are fast, fragile, and possess a leaping attack.
// The leaping attack is somewhat telegraphed and can be dodged if one is paying attention.
// The AI would've followed up after a successful leap with dragging the downed victim away, but the dragging code was too janky.

/datum/category_item/catalogue/fauna/giant_spider/hunter_spider
	name = "Giant Spider - Hunter"
	desc = "This specific spider has been catalogued as 'Hunter', \
	and it belongs to the 'Hunter' caste. \
	The spider is entirely black in color, with purple eyes. \
	<br><br>\
	The Hunter spider is noted for being one of the most agile types of spiders, being able \
	to move quickly, and do a short leap in the air. Due to their considerable weight, being leaped on \
	will often cause the victim to fall over, making this their main hunting tactic. \
	<br><br>\
	The venom inside these spiders has no special properties beyond being toxic."
	value = CATALOGUER_REWARD_EASY

/mob/living/simple_mob/animal/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	catalogue_data = list(/datum/category_item/catalogue/fauna/giant_spider/hunter_spider)

	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"

	maxHealth = 120
	health = 120

	poison_per_bite = 5
	legacy_melee_damage_lower = 9
	legacy_melee_damage_upper = 15

	movement_base_speed = 6.66 // Hunters are FAST.

	ai_holder_type = /datum/ai_holder/polaris/simple_mob/melee/hunter_spider

	player_msg = "You are very fast, and <b>can perform a leaping attack</b> by clicking on someone from a short distance away.<br>\
	If the leap succeeds, the target will be knocked down briefly and you will be on top of them.<br>\
	Note that there is a short delay before you leap!<br>\
	In addition, you will do more damage to incapacitated opponents."

	// Leaping is a special attack, so these values determine when leap can happen.
	// Leaping won't occur if its on cooldown.
	special_attack_min_range = 2
	special_attack_max_range = 4
	special_attack_cooldown = 10 SECONDS

	var/leap_warmup = 1 SECOND // How long the leap telegraphing is.
	var/leap_sound = 'sound/weapons/spiderlunge.ogg'

// Multiplies damage if the victim is stunned in some form, including a successful leap.
/mob/living/simple_mob/animal/giant_spider/hunter/apply_bonus_melee_damage(atom/A, damage_amount)
	if(isliving(A))
		var/mob/living/L = A
		if(L.incapacitated(INCAPACITATION_DISABLED))
			return damage_amount * 1.5
	return ..()


// The actual leaping attack.
/mob/living/simple_mob/animal/giant_spider/hunter/do_special_attack(atom/A)
	set waitfor = FALSE
	set_AI_busy(TRUE)

	// Telegraph, since getting stunned suddenly feels bad.
	do_windup_animation(A, leap_warmup)
	sleep(leap_warmup) // For the telegraphing.

	// Do the actual leap.
	status_flags |= STATUS_LEAPING // Lets us pass over everything.
	visible_message(SPAN_DANGER("\The [src] leaps at \the [A]!"))
	throw_at_old(get_step(get_turf(A), get_turf(src)), special_attack_max_range+1, 1, src)
	playsound(src, leap_sound, 75, 1)

	sleep(5) // For the throw to complete. It won't hold up the AI SSticker due to waitfor being false.

	if(status_flags & STATUS_LEAPING)
		status_flags &= ~STATUS_LEAPING // Revert special passage ability.

	var/turf/T = get_turf(src) // Where we landed. This might be different than A's turf.

	. = FALSE

	// Now for the stun.
	var/mob/living/victim = null
	for(var/mob/living/L in T) // So player-controlled spiders only need to click the tile to stun them.
		if(L == src)
			continue

		var/list/shieldcall_result = L.atom_shieldcall(
			40,
			DAMAGE_TYPE_BRUTE,
			3,
			ARMOR_MELEE,
			NONE,
			ATTACK_TYPE_MELEE,
		)
		if(shieldcall_result[SHIELDCALL_ARG_FLAGS] & SHIELDCALL_FLAGS_BLOCK_ATTACK)
			continue

		victim = L
		break

	if(victim)
		victim.afflict_paralyze(20 * 2)
		victim.visible_message(SPAN_DANGER("\The [src] knocks down \the [victim]!"))
		to_chat(victim, SPAN_CRITICAL("\The [src] jumps on you!"))
		. = TRUE

	set_AI_busy(FALSE)






//		var/obj/item/grab/G = new(src, victim)
//		put_in_active_hand(G)

//		G.synch()
//		G.affecting = victim
//		victim.LAssailant = src

//		visible_message("<span class='warning'>\The [src] seizes \the [victim] aggressively!</span>")
//		do_attack_animation(victim)


// This AI would've isolated people it stuns with its 'leap' attack, by dragging them away.
/datum/ai_holder/polaris/simple_mob/melee/hunter_spider

/*

/datum/ai_holder/polaris/simple_mob/melee/hunter_spider/post_special_attack(mob/living/L)
	drag_away(L)

// Called after a successful leap.
/datum/ai_holder/polaris/simple_mob/melee/hunter_spider/proc/drag_away(mob/living/L)
	to_chat(world, "Doing drag_away attack on [L]")
	if(!istype(L))
		to_chat(world, "Invalid type.")
		return FALSE

	// If they didn't get stunned, then don't bother.
	if(!L.incapacitated(INCAPACITATION_DISABLED))
		to_chat(world, "Not incapcitated.")
		return FALSE

	// Grab them.
	if(!holder.start_pulling(L))
		to_chat(world, "Failed to pull.")
		return FALSE

	holder.visible_message(SPAN_DANGER("\The [holder] starts to drag \the [L] away!"))

	var/list/allies = list()
	var/list/enemies = list()
	for(var/mob/living/thing in hearers(vision_range, holder))
		if(thing == holder || thing == L) // Don't count ourselves or the thing we just started pulling.
			continue
		if(holder.IIsAlly(thing))
			allies += thing
		else
			enemies += thing

	// First priority: Move our victim to our friends.
	if(allies.len)
		to_chat(world, "Going to move to ally")
		give_destination(get_turf(pick(allies)), min_distance = 2, combat = TRUE) // This will switch our stance.

	// Second priority: Move our victim away from their friends.
	// There's a chance of it derping and pulling towards enemies if there's more than two people.
	// Preventing that will likely be both a lot of effort for developers and the CPU.
	else if(enemies.len)
		to_chat(world, "Going to move away from enemies")
		var/mob/living/hostile = pick(enemies)
		var/turf/move_to = get_turf(hostile)
		for(var/i = 1 to vision_range) // Move them this many steps away from their friend.
			move_to = get_step_away(move_to, L, 7)
		if(move_to)
			give_destination(move_to, min_distance = 2, combat = TRUE) // This will switch our stance.

	// Third priority: Move our victim SOMEWHERE away from where they were.
	else
		to_chat(world, "Going to move away randomly")
		var/turf/move_to = get_turf(L)
		move_to = get_step(move_to, pick(GLOB.cardinal))
		for(var/i = 1 to vision_range) // Move them this many steps away from where they were before.
			move_to = get_step_away(move_to, L, 7)
		if(move_to)
			give_destination(move_to, min_distance = 2, combat = TRUE) // This will switch our stance.
*/
