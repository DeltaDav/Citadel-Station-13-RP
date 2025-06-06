//Stand-in until this is made more lore-friendly.
/datum/species/xenos
	id = SPECIES_ID_XENOMORPH
	uid = SPECIES_ID_XENOMORPH
	name = SPECIES_XENO
	name_plural = "Xenomorphs"

	default_language = LANGUAGE_ID_XENOMORPH
	intrinsic_languages = list(
		LANGUAGE_ID_XENOMORPH,
		LANGUAGE_ID_XENOMORPH_HIVEMIND
	)
	assisted_langs = list()
	unarmed_types = list(/datum/melee_attack/unarmed/claws/strong/xeno, /datum/melee_attack/unarmed/bite/strong/xeno)
	hud_type = /datum/hud_data/alien
	//rarity_value = 3

	has_fine_manipulation = 0
	siemens_coefficient = 0
	gluttonous = 2

	brute_mod = 0.5 // Hardened carapace.
	burn_mod = 2    // Weak to fire.

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	species_flags =  NO_SCAN | NO_PAIN | NO_SLIP | NO_POISON | NO_MINOR_CUT | NO_INFECT
	species_spawn_flags = SPECIES_SPAWN_SPECIAL

	reagent_tag = IS_XENOS

	blood_color = "#05EE05"
	flesh_color = "#282846"
	gibbed_anim = "gibbed-a"
	dusted_anim = "dust-a"
	death_message = "lets out a waning guttural screech, green blood bubbling from its maw."
	death_sound = 'sound/voice/hiss6.ogg'

	speech_sounds = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
	speech_chance = 100

	virus_immune = TRUE

	breath_type = null
	poison_type = null

	vision_flags = SEE_SELF|SEE_MOBS
	vision_organ = O_EYES

	has_organ = list(
		O_HEART =    /obj/item/organ/internal/heart,
		O_BRAIN =    /obj/item/organ/internal/brain/xeno,
		O_PLASMA =   /obj/item/organ/internal/xenos/plasmavessel,
		O_HIVE =     /obj/item/organ/internal/xenos/hivenode,
		O_NUTRIENT = /obj/item/organ/internal/diona/nutrients,
		O_STOMACH =		/obj/item/organ/internal/stomach/xeno,
		O_INTESTINE =	/obj/item/organ/internal/intestine/xeno
		)

	bump_flag = ALIEN
	swap_flags = ~HEAVY
	push_flags = (~HEAVY) ^ ROBOT

	var/alien_number = 0
	var/caste_name = "creature" // Used to update alien name.
	var/weeds_heal_rate = 1     // Health regen on weeds.
	var/weeds_plasma_rate = 5   // Plasma regen on weeds.

	has_limbs = list(
		BP_TORSO =  list("path" = /obj/item/organ/external/chest/unseverable/xeno),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/unseverable/xeno),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/unseverable/xeno),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/unseverable/xeno),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/unseverable/xeno),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/unseverable/xeno),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/unseverable/xeno),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/unseverable/xeno),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/unseverable/xeno),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/unseverable/xeno),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/unseverable/xeno)
		)

	iff_factions_inherent = list(
		MOB_IFF_FACTION_XENOMORPH,
	)

/datum/species/xenos/get_bodytype_legacy()
	return SPECIES_XENO

/datum/species/xenos/get_random_name()
	return "alien [caste_name] ([alien_number])"

/datum/species/xenos/can_understand(var/mob/other)

	if(istype(other,/mob/living/carbon/alien/larva))
		return 1

	return 0

/datum/species/xenos/hug(var/mob/living/carbon/human/H,var/mob/living/target)
	H.visible_message("<span class='notice'>[H] caresses [target] with its scythe-like arm.</span>", \
					"<span class='notice'>You caress [target] with your scythe-like arm.</span>")

/datum/species/xenos/handle_post_spawn(var/mob/living/carbon/human/H)

	if(H.mind)
		H.mind.assigned_role = "Alien"
		H.mind.special_role = "Alien"

	alien_number++ //Keep track of how many aliens we've had so far.
	H.real_name = "alien [caste_name] ([alien_number])"
	H.name = H.real_name

	..()

/datum/species/xenos/handle_environment_special(mob/living/carbon/human/H, datum/gas_mixture/environment, dt)
	if(!environment)
		return

	if(environment.gas[GAS_ID_PHORON] > 0 || locate(/obj/structure/alien/weeds) in get_turf(H))
		if(!regenerate(H))
			var/obj/item/organ/internal/xenos/plasmavessel/P = H.internal_organs_by_name[O_PLASMA]
			P.stored_plasma += weeds_plasma_rate
			P.stored_plasma = min(max(P.stored_plasma,0),P.max_plasma)

/datum/species/xenos/proc/regenerate(var/mob/living/carbon/human/H)
	var/heal_rate = weeds_heal_rate
	var/mend_prob = 10
	if (!H.resting)
		heal_rate = weeds_heal_rate / 3
		mend_prob = 1

	//first heal damages
	if (H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())
		H.adjustBruteLoss(-heal_rate)
		H.adjustFireLoss(-heal_rate)
		H.adjustOxyLoss(-heal_rate)
		H.adjustToxLoss(-heal_rate)
		if (prob(5))
			to_chat(H, "<span class='alien'>You feel a soothing sensation come over you...</span>")
		return 1

	//next internal organs
	for(var/obj/item/organ/I in H.internal_organs)
		if(I.damage > 0)
			I.heal_damage_i(heal_rate, can_revive = TRUE)
			if (prob(5))
				to_chat(H, "<span class='alien'>You feel a soothing sensation within your [I.parent_organ]...</span>")
			return 1

	//next mend broken bones, approx 10 ticks each
	for(var/obj/item/organ/external/E in H.bad_external_organs)
		if (E.status & ORGAN_BROKEN)
			if (prob(mend_prob))
				if (E.mend_fracture())
					to_chat(H, "<span class='alien'>You feel something mend itself inside your [E.name].</span>")
			return 1

	return 0
/*
/datum/species/xenos/handle_login_special(var/mob/living/carbon/human/H)
	H.AddInfectionImages()
	..()

/datum/species/xenos/handle_logout_special(var/mob/living/carbon/human/H)
	H.RemoveInfectionImages()
	..()
*/

/datum/species/xenos/drone
	uid = SPECIES_ID_XENOMORPH_DRONE
	name = SPECIES_XENO_DRONE
	caste_name = "drone"
	weeds_plasma_rate = 15

	sprite_accessory_defaults = list(
		SPRITE_ACCESSORY_SLOT_TAIL = /datum/sprite_accessory/tail/bodyset/xenomorph/drone,
	)

	icobase = 'icons/mob/species/xenomorph/drone.dmi'
	deform =  'icons/mob/species/xenomorph/drone.dmi'

	has_organ = list(
		O_HEART =		/obj/item/organ/internal/heart,
		O_BRAIN =		/obj/item/organ/internal/brain/xeno,
		O_PLASMA =		/obj/item/organ/internal/xenos/plasmavessel/queen,
		O_ACID =		/obj/item/organ/internal/xenos/acidgland,
		O_HIVE =		/obj/item/organ/internal/xenos/hivenode,
		O_RESIN =		/obj/item/organ/internal/xenos/resinspinner,
		O_NUTRIENT =	/obj/item/organ/internal/diona/nutrients,
		O_STOMACH =		/obj/item/organ/internal/stomach/xeno,
		O_INTESTINE =	/obj/item/organ/internal/intestine/xeno
		)

	movement_base_speed = 5.5

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/evolve,
		/mob/living/carbon/human/proc/corrosive_acid
		)

/datum/species/xenos/drone/handle_post_spawn(var/mob/living/carbon/human/H)

	var/mob/living/carbon/human/A = H
	if(!istype(A))
		return ..()
	..()

/datum/species/xenos/hunter
	uid = SPECIES_ID_XENOMORPH_HUNTER
	name = SPECIES_XENO_HUNTER
	weeds_plasma_rate = 5
	caste_name = "hunter"
	total_health = 150

	sprite_accessory_defaults = list(
		SPRITE_ACCESSORY_SLOT_TAIL = /datum/sprite_accessory/tail/bodyset/xenomorph/hunter,
	)

	icobase = 'icons/mob/species/xenomorph/hunter.dmi'
	deform =  'icons/mob/species/xenomorph/hunter.dmi'

	movement_base_speed = 10

	has_organ = list(
		O_HEART =    /obj/item/organ/internal/heart,
		O_BRAIN =    /obj/item/organ/internal/brain/xeno,
		O_PLASMA =   /obj/item/organ/internal/xenos/plasmavessel/hunter,
		O_HIVE =     /obj/item/organ/internal/xenos/hivenode,
		O_NUTRIENT = /obj/item/organ/internal/diona/nutrients,
		O_STOMACH =		/obj/item/organ/internal/stomach/xeno,
		O_INTESTINE =	/obj/item/organ/internal/intestine/xeno
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/gut,
		/mob/living/carbon/human/proc/leap,
		/mob/living/carbon/human/proc/psychic_whisper,
		/mob/living/carbon/human/proc/regurgitate
		)

/datum/species/xenos/sentinel
	uid = SPECIES_ID_XENOMORPH_SENTINEL
	name = SPECIES_XENO_SENTINEL
	weeds_plasma_rate = 10
	caste_name = "sentinel"
	total_health = 200

	sprite_accessory_defaults = list(
		SPRITE_ACCESSORY_SLOT_TAIL = /datum/sprite_accessory/tail/bodyset/xenomorph/sentinel,
	)

	movement_base_speed = 6.66

	icobase = 'icons/mob/species/xenomorph/sentinel.dmi'
	deform =  'icons/mob/species/xenomorph/sentinel.dmi'

	has_organ = list(
		O_HEART =    /obj/item/organ/internal/heart,
		O_BRAIN =    /obj/item/organ/internal/brain/xeno,
		O_PLASMA =   /obj/item/organ/internal/xenos/plasmavessel/sentinel,
		O_ACID =     /obj/item/organ/internal/xenos/acidgland,
		O_HIVE =     /obj/item/organ/internal/xenos/hivenode,
		O_NUTRIENT = /obj/item/organ/internal/diona/nutrients,
		O_STOMACH =		/obj/item/organ/internal/stomach/xeno,
		O_INTESTINE =	/obj/item/organ/internal/intestine/xeno
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/corrosive_acid,
		/mob/living/carbon/human/proc/neurotoxin,
		/mob/living/carbon/human/proc/acidspit
		)

/datum/species/xenos/queen
	uid = SPECIES_ID_XENOMORPH_QUEEN
	name = SPECIES_XENO_QUEEN
	total_health = 250
	weeds_heal_rate = 5
	weeds_plasma_rate = 20
	caste_name = "queen"

	sprite_accessory_defaults = list(
		SPRITE_ACCESSORY_SLOT_TAIL = /datum/sprite_accessory/tail/bodyset/xenomorph/queen,
	)

	movement_base_speed = 3

	icobase = 'icons/mob/species/xenomorph/queen.dmi'
	deform =  'icons/mob/species/xenomorph/queen.dmi'

	unarmed_types = list(/datum/melee_attack/unarmed/claws/strong/xeno/queen, /datum/melee_attack/unarmed/bite/strong/xeno)

	has_organ = list(
		O_HEART =    /obj/item/organ/internal/heart,
		O_BRAIN =    /obj/item/organ/internal/brain/xeno,
		O_EGG =      /obj/item/organ/internal/xenos/eggsac,
		O_PLASMA =   /obj/item/organ/internal/xenos/plasmavessel/queen,
		O_ACID =     /obj/item/organ/internal/xenos/acidgland,
		O_HIVE =     /obj/item/organ/internal/xenos/hivenode,
		O_RESIN =    /obj/item/organ/internal/xenos/resinspinner,
		O_NUTRIENT = /obj/item/organ/internal/diona/nutrients,
		O_STOMACH =		/obj/item/organ/internal/stomach/xeno,
		O_INTESTINE =	/obj/item/organ/internal/intestine/xeno
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/psychic_whisper,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/lay_egg,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/corrosive_acid,
		/mob/living/carbon/human/proc/neurotoxin,
		/mob/living/carbon/human/proc/acidspit,
		)

	//* Inventory *//

	inventory_slots = list(
		/datum/inventory_slot/inventory/suit::id = list(
			INVENTORY_SLOT_REMAP_MAIN_AXIS = 0,
			INVENTORY_SLOT_REMAP_CROSS_AXIS = 4,
		),
		/datum/inventory_slot/inventory/pocket/left::id,
		/datum/inventory_slot/inventory/pocket/right::id,
		/datum/inventory_slot/inventory/head::id = list(
			INVENTORY_SLOT_REMAP_MAIN_AXIS = 0,
			INVENTORY_SLOT_REMAP_CROSS_AXIS = 3,
		),
	)

/datum/species/xenos/queen/handle_login_special(var/mob/living/carbon/human/H)
	..()
	// Make sure only one official queen exists at any point.
	if(!alien_queen_exists(1,H))
		H.real_name = "alien queen ([alien_number])"
		H.name = H.real_name
	else
		H.real_name = "alien princess ([alien_number])"
		H.name = H.real_name

/datum/hud_data/alien

	icon = 'icons/mob/screen1_alien.dmi'
	has_warnings =  1
	has_drop =      1
	has_throw =     1
	has_resist =    1
	has_pressure =  0
	has_nutrition = 0
	has_bodytemp =  0
	has_internals = 0
