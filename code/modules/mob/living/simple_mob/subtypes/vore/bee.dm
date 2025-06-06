/datum/category_item/catalogue/fauna/bee
	name = "Space Bumble Bee"
	desc = "Unlike other attempts at modifying species for easier space transportation, \
	bumble bee modification went off without a hitch. Space Bees are not capable of flight \
	in space, obviously, but their survivability in hostile environments has been substantially \
	improved."
	value = CATALOGUER_REWARD_TRIVIAL

/mob/living/simple_mob/vore/bee
	name = "space bumble bee"
	desc = "Buzz buzz."
	catalogue_data = list(/datum/category_item/catalogue/fauna/bee)

	icon_state = "bee"
	icon_living = "bee"
	icon_dead = "bee-dead"
	icon = 'icons/mob/vore.dmi'

	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"

	movement_base_speed = 10 / 5
//	speed = 5
	maxHealth = 25
	health = 25

	harm_intent_damage = 4
	legacy_melee_damage_lower = 2
	legacy_melee_damage_upper = 4
	attacktext = list("stung")

	say_list_type = /datum/say_list/bee
	ai_holder_type = /datum/ai_holder/polaris/simple_mob/retaliate

	//Space bees aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	iff_factions = MOB_IFF_FACTION_FARM_ANIMAL

	var/poison_type = "spidertoxin"	// The reagent that gets injected when it attacks, can be changed to different toxin.
	var/poison_chance = 10			// Chance for injection to occur.
	var/poison_per_bite = 1			// Amount added per injection.

/mob/living/simple_mob/vore/bee/Process_Spacemove(var/check_drift = 0)
	return 1	//No drifting in space for space bee!

// Activate Noms!
/mob/living/simple_mob/vore/bee

/mob/living/simple_mob/vore/bee/apply_melee_effects(var/atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.reagents)
			var/target_zone = pick(BP_TORSO,BP_TORSO,BP_TORSO,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_HEAD)
			if(L.can_inject(src, null, target_zone))
				inject_poison(L, target_zone)

// Does actual poison injection, after all checks passed.
/mob/living/simple_mob/vore/bee/proc/inject_poison(mob/living/L, target_zone)
	if(prob(poison_chance))
		L.custom_pain(SPAN_WARNING("You feel a tiny prick."), 1, TRUE)
		L.reagents.add_reagent(poison_type, poison_per_bite)

/datum/say_list/bee
	speak = list("Buzzzz")
