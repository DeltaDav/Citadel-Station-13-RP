/datum/physiology_modifier/intrinsic/species/unathi
	carry_strength_add = CARRY_STRENGTH_ADD_UNATHI
	carry_strength_factor = CARRY_FACTOR_MOD_UNATHI

/datum/species/unathi
	uid = SPECIES_ID_UNATHI
	id = SPECIES_ID_UNATHI
	name = SPECIES_UNATHI
	category = "Unathi"
	name_plural = SPECIES_UNATHI
	primitive_form = SPECIES_MONKEY_UNATHI
	default_bodytype = BODYTYPE_UNATHI

	mob_physiology_modifier = /datum/physiology_modifier/intrinsic/species/unathi

	// icon_template = 'icons/mob/species/template_tall.dmi' //TODO: Tall Unathi :D
	icobase       = 'icons/mob/species/unathi/body_greyscale.dmi'
	deform        = 'icons/mob/species/unathi/deformed_body_greyscale.dmi'
	husk_icon     = 'icons/mob/species/unathi/husk.dmi'
	preview_icon  = 'icons/mob/species/unathi/preview.dmi'

	sprite_accessory_defaults = list(
		SPRITE_ACCESSORY_SLOT_TAIL = /datum/sprite_accessory/tail/bodyset/unathi,
	)

	blurb = {"
	A heavily reptillian species, Unathi hail from the Uuosa-Eso system, which roughly translates to 'burning mother'.

	Coming from a harsh, inhospitable planet, they mostly hold ideals of honesty, virtue, proficiency and bravery above
	all else, frequently even their own lives. They prefer warmer temperatures than most species and their native tongue
	is a heavy hissing laungage called Sinta'Unathi.
	"}
	wikilink = "https://citadel-station.net/wikiRP/index.php?title=Unathi"
	catalogue_data = list(/datum/category_item/catalogue/fauna/unathi)

	max_additional_languages = 3
	name_language    = LANGUAGE_ID_UNATHI
	intrinsic_languages = LANGUAGE_ID_UNATHI

	ambiguous_genders = TRUE
	gluttonous = 1

	movement_base_speed = 4.5
	item_slowdown_mod = 0.25

	total_health = 125

	brute_mod = 0.8
	flash_mod = 1.2

	metabolic_rate = 0.85
	mob_size = MOB_LARGE
	blood_volume = 840
	health_hud_intensity = 2.5

	max_age = 260


	cold_level_1 = 280
	cold_level_2 = 220
	cold_level_3 = 130

	breath_cold_level_1 = 260
	breath_cold_level_2 = 200
	breath_cold_level_3 = 120

	heat_level_1 = 420
	heat_level_2 = 480
	heat_level_3 = 1100

	breath_heat_level_1 = 450
	breath_heat_level_2 = 530
	breath_heat_level_3 = 1400

	minimum_breath_pressure = 18 // Bigger, means they need more air

	body_temperature = null //mesothermic is basically cold-blooded right?

	species_spawn_flags = SPECIES_SPAWN_CHARACTER // Species_can_join is the only spawn flag all the races get, so that none of them will be whitelist only if whitelist is enabled.
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_SKIN_COLOR | HAS_EYE_COLOR

	color_mult  = 1
	flesh_color = "#34AF10"
	blood_color = "#f24b2e"
	base_color  = "#066000"

	reagent_tag = IS_UNATHI

	move_trail = /obj/effect/debris/cleanable/blood/tracks/claw

	has_limbs = list(
		BP_TORSO  = list("path" = /obj/item/organ/external/chest/unathi),
		BP_GROIN  = list("path" = /obj/item/organ/external/groin/unathi),
		BP_HEAD   = list("path" = /obj/item/organ/external/head/unathi),
		BP_L_ARM  = list("path" = /obj/item/organ/external/arm),
		BP_R_ARM  = list("path" = /obj/item/organ/external/arm/right),
		BP_L_LEG  = list("path" = /obj/item/organ/external/leg),
		BP_R_LEG  = list("path" = /obj/item/organ/external/leg/right),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right),
	)

	//No kidneys or appendix
	has_organ = list(
		O_HEART     = /obj/item/organ/internal/heart/unathi,
		O_LUNGS     = /obj/item/organ/internal/lungs/unathi,
		O_LIVER     = /obj/item/organ/internal/liver/unathi,
		O_BRAIN     = /obj/item/organ/internal/brain/unathi,
		O_EYES      = /obj/item/organ/internal/eyes,
		O_STOMACH   = /obj/item/organ/internal/stomach/unathi,
		O_INTESTINE = /obj/item/organ/internal/intestine/unathi,
	)
	vision_organ = O_EYES

	unarmed_types = list(
		/datum/melee_attack/unarmed/stomp,
		/datum/melee_attack/unarmed/kick,
		/datum/melee_attack/unarmed/claws,
		/datum/melee_attack/unarmed/bite/sharp,
	)

	heat_discomfort_level = 343
	heat_discomfort_strings = list(
		"You feel soothingly warm.",
		"You feel the heat sink into your bones.",
		"You feel warm enough to take a nap.",
	)

	cold_discomfort_level = 282
	cold_discomfort_strings = list(
		"You feel chilly.",
		"You feel sluggish and cold.",
		"Your scales bristle against the cold.",
	)

	descriptors = list()

	inherent_verbs = list(
		/mob/living/proc/shred_limb,
		/mob/living/carbon/human/proc/tie_hair,
		/mob/living/carbon/human/proc/hide_horns,
		/mob/living/carbon/human/proc/hide_wings,
		/mob/living/carbon/human/proc/hide_tail,
	)

/datum/species/unathi/apply_racial_gear(mob/living/carbon/for_target, list/into_box, list/into_inv)
	var/footwear_type = /obj/item/clothing/shoes/sandal
	if(for_target && !for_target.inventory?.get_slot_single(/datum/inventory_slot/inventory/shoes))
		var/obj/item/footwear_instance = new footwear_type
		if(!for_target.inventory.equip_to_slot_if_possible(footwear_instance, /datum/inventory_slot/inventory/shoes))
			into_inv += footwear_instance
	else
		into_inv += footwear_type
	return ..()
