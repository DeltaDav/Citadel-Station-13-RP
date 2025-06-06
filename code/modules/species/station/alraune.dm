/datum/physiology_modifier/intrinsic/species/alraune
	carry_strength_add = CARRY_STRENGTH_ADD_ALRAUNE
	carry_strength_factor = CARRY_FACTOR_MOD_ALRAUNE

/datum/species/alraune
	uid = SPECIES_ID_ALRAUNE
	id = SPECIES_ID_ALRAUNE
	name = SPECIES_ALRAUNE
	name_plural = "Alraunes"
	mob_physiology_modifier = /datum/physiology_modifier/intrinsic/species/alraune

	icobase = 'icons/mob/species/human/body_greyscale.dmi'
	deform  = 'icons/mob/species/human/deformed_body_greyscale.dmi'

	blurb = {"
	Alraunes are an uncommon sight in space. Their bodies are reminiscent of that of plants, and yet they share many
	traits with other humanoid beings, occasionally mimicking their forms to lure in prey.

	Most Alraune are rather opportunistic in nature, being primarily self-serving; however, this does not mean they
	are selfish or unable to empathize with others.

	They are highly adaptable both mentally and physically, but tend to have a collecting intra-species mindset.
	"}

	max_additional_languages = 3
	intrinsic_languages = LANGUAGE_ID_VERNAL

	movement_base_speed = 4.5
	snow_movement  = -1 // Alraune can still wear shoes. Combined with winter boots, negates light snow slowdown but still slowed on ice.
	water_movement = -1 // Combined with swimming fins, negates shallow water slowdown.
	total_health = 100 //standard
	metabolic_rate = 0.75 // slow metabolism

	vision_organ = O_EYES

	brute_mod     = 1    //nothing special
	burn_mod      = 1.1  //plants don't like fire
	radiation_mod = 0.7  //cit change: plants seem to be pretty resilient. shouldn't come up much.

	item_slowdown_mod = 0.1 //while they start slow, they don't get much slower
	bloodloss_rate = 0.1 //While they do bleed, they bleed out VERY slowly
	max_age = 500
	health_hud_intensity = 1.5
	selects_bodytype = TRUE

	body_temperature = T20C
	breath_type = GAS_ID_CARBON_DIOXIDE
	poison_type = GAS_ID_PHORON
	exhale_type = GAS_ID_OXYGEN

	// Heat and cold resistances are 20 degrees broader on the level 1 range, level 2 is default, level 3 is much weaker, halfway between L2 and normal L3.
	// Essentially, they can tolerate a broader range of comfortable temperatures, but suffer more at extremes.
	cold_level_1 = 240
	cold_level_2 = 200
	cold_level_3 = 160
	cold_discomfort_level = 260	//they start feeling uncomfortable around the point where humans take damage

	heat_level_1 = 380
	heat_level_2 = 400
	heat_level_3 = 700
	heat_discomfort_level = 360

	breath_cold_level_1 = 240 //They don't have lungs, they breathe through their skin
	breath_cold_level_2 = 180 //sadly for them, their breath tolerance is no better than anyone else's.
	breath_cold_level_3 = 140 //mainly 'cause breath tolerance is more generous than body temp tolerance.

	breath_heat_level_1 = 400 //slightly better heat tolerance in air though. Slightly.
	breath_heat_level_2 = 450
	breath_heat_level_3 = 800 //lower incineration threshold though

	species_flags = NO_SCAN | IS_PLANT | NO_MINOR_CUT
	species_spawn_flags = SPECIES_SPAWN_CHARACTER
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_SKIN_COLOR | HAS_EYE_COLOR

	unarmed_types = list(
		/datum/melee_attack/unarmed/stomp,
		/datum/melee_attack/unarmed/kick,
		/datum/melee_attack/unarmed/punch,
		/datum/melee_attack/unarmed/bite,
	)

	inherent_verbs = list(
		/mob/living/carbon/human/proc/succubus_drain,
		/mob/living/carbon/human/proc/succubus_drain_finalize,
		/mob/living/carbon/human/proc/succubus_drain_lethal,
		/mob/living/carbon/human/proc/bloodsuck,
		/mob/living/carbon/human/proc/regenerate,
		/mob/living/carbon/human/proc/alraune_fruit_select,
		/mob/living/carbon/human/proc/tie_hair,
		/mob/living/carbon/human/proc/hide_horns,
		/mob/living/carbon/human/proc/hide_wings,
		/mob/living/carbon/human/proc/hide_tail,
	) //Give them the voremodes related to wrapping people in vines and sapping their fluids

	color_mult  = 1
	flesh_color = "#9ee02c"
	blood_color = "#edf4d0" //sap!
	base_color  = "#1a5600"

	reagent_tag = IS_ALRAUNE

	has_limbs = list( //cit change - unbreakable, can survive decapitation, but damage spreads to nearby neighbors when at max dmg.
		BP_TORSO  = list("path" = /obj/item/organ/external/chest/unbreakable/plant),
		BP_GROIN  = list("path" = /obj/item/organ/external/groin/unbreakable/plant),
		BP_HEAD   = list("path" = /obj/item/organ/external/head/unbreakable/plant),
		BP_L_ARM  = list("path" = /obj/item/organ/external/arm/unbreakable/plant),
		BP_R_ARM  = list("path" = /obj/item/organ/external/arm/right/unbreakable/plant),
		BP_L_LEG  = list("path" = /obj/item/organ/external/leg/unbreakable/plant),
		BP_R_LEG  = list("path" = /obj/item/organ/external/leg/right/unbreakable/plant),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/unbreakable/plant),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/unbreakable/plant),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/unbreakable/plant),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/unbreakable/plant),
	)

	// limited organs, 'cause they're simple
	has_organ = list(
		O_LIVER   = /obj/item/organ/internal/liver/alraune,
		O_KIDNEYS = /obj/item/organ/internal/kidneys/alraune,
		O_BRAIN   = /obj/item/organ/internal/brain/alraune,
		O_EYES    = /obj/item/organ/internal/eyes/alraune,
		O_FRUIT   = /obj/item/organ/internal/fruitgland,
	)

/datum/species/alraune/can_breathe_water()
	return TRUE //eh, why not? Aquatic plants are a thing.


/datum/species/alraune/handle_environment_special(mob/living/carbon/human/H, datum/gas_mixture/environment, dt)
	if(H.inStasisNow()) // if they're in stasis, they won't need this stuff.
		return

	//? Setting these here 'cause ugh the defines for life are in the wrong place to compile properly.
	//? Set them back to HUMAN_MAX_OXYLOSS if we move the life defines to the defines folder at any point.

	/// Defines how much oxyloss humans can get per tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.
	var/ALRAUNE_MAX_OXYLOSS = 1
	/// The amount of damage you'll get when in critical condition. We want this to be a 5 minute deal = 300s.
	/// There are 50HP to get through, so (1/6)*last_tick_duration per second.
	///Breaths however only happen every 4 ticks. last_tick_duration = ~2.0 on average.
	var/ALRAUNE_CRIT_MAX_OXYLOSS = (2.0 / 6)

	//They don't have lungs so breathe() will just return. Instead, they breathe through their skin.
	//This is mostly normal breath code with some tweaks that apply to their particular biology.

	//just fuck off with this snowflake bullshit about checking if they're sealed off and just test for internals. too complicated.
	var/datum/gas_mixture/breath = H.get_breath_from_internal()

	if(!breath) //No breath from internals so let's try to get air from our location
		// cut-down version of get_breath_from_environment - notably, gas masks provide no benefit
		var/datum/gas_mixture/environment2
		if(H.loc)
			environment2 = H.loc.return_air_for_internal_lifeform(H)

		if(environment2)
			breath = environment2.remove_volume(BREATH_VOLUME)
			H.handle_chemical_smoke(environment2) //handle chemical smoke while we're at it

	// NOW a crude copypasta of handle_breath. Leaving some things out that don't apply to plants.
	if(H.does_not_breathe)
		H.failed_last_breath = 0
		H.adjustOxyLoss(-5)
		return // if somehow they don't breathe, abort breathing.

	if(!breath || (breath.total_moles == 0))
		H.failed_last_breath = 1
		if(H.health > H.getCritHealth())
			H.adjustOxyLoss(ALRAUNE_MAX_OXYLOSS)
		else
			H.adjustOxyLoss(ALRAUNE_CRIT_MAX_OXYLOSS)

		H.oxygen_alert = max(H.oxygen_alert, 1)

		return // skip air processing if there's no air

	// now into the good stuff

	//var/safe_pressure_min = species.minimum_breath_pressure // Minimum safe partial pressure of breathable gas in kPa
	//just replace safe_pressure_min with minimum_breath_pressure, no need to declare a new var

	var/safe_exhaled_max = 10
	var/safe_toxins_max = 0.2
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/inhaled_gas_used = 0

	var/breath_pressure = (breath.total_moles*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	var/inhaling
	var/poison
	var/exhaling

	var/failed_inhale = 0
	var/failed_exhale = 0

	inhaling = breath.gas[breath_type]
	poison = breath.gas[poison_type]
	exhaling = breath.gas[exhale_type]

	var/inhale_pp = (inhaling/breath.total_moles)*breath_pressure
	var/toxins_pp = (poison/breath.total_moles)*breath_pressure
	var/exhaled_pp = (exhaling/breath.total_moles)*breath_pressure

	// Not enough to breathe
	if((inhale_pp + exhaled_pp) < minimum_breath_pressure) //they can breathe either oxygen OR CO2
		if(prob(20))
			spawn(0) H.emote("gasp")

		var/ratio = (inhale_pp + exhaled_pp)/minimum_breath_pressure
		// Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS (1) after all!)
		H.adjustOxyLoss(max(ALRAUNE_MAX_OXYLOSS*(1-ratio), 0))
		failed_inhale = 1

		H.oxygen_alert = max(H.oxygen_alert, 1)
	else
		// We're in safe limits
		H.oxygen_alert = 0

	inhaled_gas_used = inhaling/6
	breath.adjust_gas(breath_type, -inhaled_gas_used, update = 0) //update afterwards
	breath.adjust_gas_temp(exhale_type, inhaled_gas_used, H.bodytemperature, update = 0) //update afterwards

	//Now we handle CO2.
	if(inhale_pp > safe_exhaled_max * 0.7) // For a human, this would be too much exhaled gas in the air. But plants don't care.
		H.co2_alert = 1 // Give them the alert on the HUD. They'll be aware when the good stuff is present.

	else
		H.co2_alert = 0

	//do the CO2 buff stuff here

	var/co2buff = 0
	if(inhaling)
		co2buff = (clamp(inhale_pp, 0, minimum_breath_pressure))/minimum_breath_pressure //returns a value between 0 and 1.

	var/light_amount = H.getlightlevel()

	if(co2buff && !H.toxloss && light_amount >= 0.1) //if there's enough light and CO2 and you're not poisoned, heal. Note if you're wearing a sealed suit your heal rate will suck.
		H.adjustBruteLoss(-(light_amount * co2buff * 2)) //at a full partial pressure of CO2 and full light, you'll only heal half as fast as diona.
		H.adjustFireLoss(-(light_amount * co2buff)) //this won't let you tank environmental damage from fire. MAYBE cold until your body temp drops.

	if(H.nutrition < (200 + 400*co2buff)) //if no CO2, a fully lit tile gives them 1/tick up to 200. With CO2, potentially up to 600.
		H.nutrition += (light_amount*(1+co2buff*5))

	// Too much poison in the air.
	if(toxins_pp > safe_toxins_max)
		var/ratio = (poison/safe_toxins_max) * 10
		if(H.reagents)
			H.reagents.add_reagent("toxin", clamp(ratio, MIN_TOXIN_DAMAGE, MAX_TOXIN_DAMAGE))
			breath.adjust_gas(poison_type, -poison/6, update = 0) //update after
		H.phoron_alert = max(H.phoron_alert, 1)
	else
		H.phoron_alert = 0

	// If there's some other shit in the air lets deal with it here.
	if(breath.gas[GAS_ID_NITROUS_OXIDE])
		var/SA_pp = (breath.gas[GAS_ID_NITROUS_OXIDE] / breath.total_moles) * breath_pressure

		// Enough to make us paralysed for a bit
		if(SA_pp > SA_para_min)

			// 3 gives them one second to wake up and run away a bit!
			H.afflict_unconscious(20 * 3)

			// Enough to make us sleep as well
			if(SA_pp > SA_sleep_min)
				H.afflict_sleeping(20 * 5)

		// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
		else if(SA_pp > 0.15)
			if(prob(20))
				spawn(0) H.emote(pick("giggle", "laugh"))
		breath.adjust_gas(GAS_ID_NITROUS_OXIDE, -breath.gas[GAS_ID_NITROUS_OXIDE]/6, update = 0) //update after

	// Were we able to breathe?
	if (failed_inhale || failed_exhale)
		H.failed_last_breath = 1
	else
		H.failed_last_breath = 0
		H.adjustOxyLoss(-5)


	// Hot air hurts :(
	if((breath.temperature < breath_cold_level_1 || breath.temperature > breath_heat_level_1) && !(MUTATION_COLD_RESIST in H.mutations))

		if(breath.temperature <= breath_cold_level_1)
			if(prob(20))
				to_chat(H, "<span class='danger'>You feel icicles forming on your skin!</span>")
		else if(breath.temperature >= breath_heat_level_1)
			if(prob(20))
				to_chat(H, "<span class='danger'>You feel yourself smouldering in the heat!</span>")

		var/bodypart = pick(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND,BP_TORSO,BP_GROIN,BP_HEAD)
		if(breath.temperature >= breath_heat_level_1)
			if(breath.temperature < breath_heat_level_2)
				H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, DAMAGE_TYPE_BURN, bodypart, used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)
			else if(breath.temperature < breath_heat_level_3)
				H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, DAMAGE_TYPE_BURN, bodypart, used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)
			else
				H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, DAMAGE_TYPE_BURN, bodypart, used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)

		else if(breath.temperature <= breath_cold_level_1)
			if(breath.temperature > breath_cold_level_2)
				H.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, DAMAGE_TYPE_BURN, bodypart, used_weapon = "Excessive Cold")
				H.fire_alert = max(H.fire_alert, 1)
			else if(breath.temperature > breath_cold_level_3)
				H.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, DAMAGE_TYPE_BURN, bodypart, used_weapon = "Excessive Cold")
				H.fire_alert = max(H.fire_alert, 1)
			else
				H.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, DAMAGE_TYPE_BURN, bodypart, used_weapon = "Excessive Cold")
				H.fire_alert = max(H.fire_alert, 1)


		//breathing in hot/cold air also heats/cools you a bit
		var/temp_adj = breath.temperature - H.bodytemperature
		if (temp_adj < 0)
			temp_adj /= (BODYTEMP_COLD_DIVISOR * 5)	//don't raise temperature as much as if we were directly exposed
		else
			temp_adj /= (BODYTEMP_HEAT_DIVISOR * 5)	//don't raise temperature as much as if we were directly exposed

		var/relative_density = 8 * breath.total_moles / (CELL_MOLES * BREATH_PERCENTAGE)
		temp_adj *= relative_density

		if (temp_adj > BODYTEMP_HEATING_MAX) temp_adj = BODYTEMP_HEATING_MAX
		if (temp_adj < BODYTEMP_COOLING_MAX) temp_adj = BODYTEMP_COOLING_MAX
		//to_chat(world, "Breath: [breath.temperature], [src]: [bodytemperature], Adjusting: [temp_adj]")
		H.bodytemperature += temp_adj

	else if(breath.temperature >= heat_discomfort_level)
		get_environment_discomfort(src,"heat")
	else if(breath.temperature <= cold_discomfort_level)
		get_environment_discomfort(src,"cold")

	breath.update_values()
	return 1


/mob/living/carbon/human/proc/alraune_fruit_select() //So if someone doesn't want fruit/vegetables, they don't have to select one.
	set name = "Select Fruit"
	set desc = "Select what fruit/vegetable you wish to grow."
	set category = "Abilities"

	var/obj/item/organ/internal/fruitgland/fruit_gland
	for(var/F in contents)
		if(istype(F, /obj/item/organ/internal/fruitgland))
			fruit_gland = F
			break

	if(fruit_gland)
		var/selection = input(src, "Choose your character's fruit type. Choosing nothing will result in a default of apples.", "Fruit Type", fruit_gland.fruit_type) as null|anything in acceptable_fruit_types
		if(selection)
			fruit_gland.fruit_type = selection
		add_verb(src, /mob/living/carbon/human/proc/alraune_fruit_pick)
		remove_verb(src, /mob/living/carbon/human/proc/alraune_fruit_select)
		fruit_gland.emote_descriptor = list("fruit right off of [fruit_gland.owner]!", "a fruit from [fruit_gland.owner]!")
	else
		to_chat(src, SPAN_NOTICE("You lack the organ required to produce fruit."))

/mob/living/carbon/human/proc/alraune_fruit_pick()
	set name = "Pick Fruit"
	set desc = "Pick fruit."
	set category = VERB_CATEGORY_OBJECT
	set src in view(1)

	//do_reagent_implant(usr)
	if(!isliving(usr) || !usr.canClick())
		return

	if(usr.incapacitated() || usr.stat > CONSCIOUS)
		return

	var/obj/item/organ/internal/fruitgland/fruit_gland
	for(var/I in contents)
		if(istype(I, /obj/item/organ/internal/fruitgland))
			fruit_gland = I
			break
	if (fruit_gland) //Do they have the gland?
		if(fruit_gland.reagents.total_volume < fruit_gland.transfer_amount)
			to_chat(src, SPAN_NOTICE("[pick(fruit_gland.empty_message)]"))
			return

		var/datum/seed/S = SSplants.seeds["[fruit_gland.fruit_type]"]
		S.harvest(usr,0,0,1)

		var/index = rand(0,2)

		if (usr != src)
			var/emote = fruit_gland.emote_descriptor[index]
			var/verb_desc = fruit_gland.verb_descriptor[index]
			var/self_verb_desc = fruit_gland.self_verb_descriptor[index]
			usr.visible_message(
				SPAN_NOTICE("[usr] [verb_desc] [emote]"),
				SPAN_NOTICE("You [self_verb_desc] [emote]"),
			)
		else
			visible_message(
				SPAN_NOTICE("[src] [pick(fruit_gland.short_emote_descriptor)] a fruit."),
				SPAN_NOTICE("You [pick(fruit_gland.self_emote_descriptor)] a fruit."),
			)

		fruit_gland.reagents.remove_any(fruit_gland.transfer_amount)

//End of fruit gland code.

/datum/species/alraune/get_bodytype_legacy()
	return base_species

//! WARNING SHITCODE
/datum/species/alraune/get_race_key(mob/living/carbon/human/H)
	var/datum/species/real = SScharacters.resolve_species_name(base_species || SPECIES_HUMAN)
	return real.real_race_key(H)
