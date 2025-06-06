/*
	Spiders come in various types, and are a fairly common enemy both inside and outside the station.
	Their attacks can inject reagents, which can cause harm long after the spider is killed.
	Thick material will prevent injections, similar to other means of injections.
*/

// Obtained by scanning any giant spider.
/datum/category_item/catalogue/fauna/giant_spider/giant_spiders
	name = "Giant Spiders"
	desc = "Giant Spiders are massive arachnids genetically descended from conventional Earth spiders, \
	however what caused ordinary arachnids to evolve into these are disputed. \
	Different initial species of spider have co-evolved and interbred to produce a robust biological caste system \
	capable of producing many varieties of giant spider. They are considered by most people to be a dangerous \
	invasive species, due to their hostility, venom, and high rate of reproduction. A strong resistance to \
	various poisons and toxins has been found, making it difficult to indirectly control their population.\
	<br><br>\
	Giant Spiders have three known castes, 'Guard', 'Hunter', and 'Nurse'. \
	Spiders in the Guard caste are generally the physically stronger, resilient types. \
	The ones in the Hunter caste are usually faster, or have some from of ability to \
	close the distance between them and their prey rapidly. \
	Finally, those in the Nurse caste generally act in a supporting role to the other two \
	castes, spinning webs and ensuring their nest grows larger and more terrifying."
	value = CATALOGUER_REWARD_TRIVIAL
	unlocked_by_any = list(/datum/category_item/catalogue/fauna/giant_spider)

// Obtained by scanning all spider types.
/datum/category_item/catalogue/fauna/all_giant_spiders
	name = "Collection - Giant Spiders"
	desc = "You have scanned a large array of different types of giant spiders, \
	and therefore you have been granted a large sum of points, through this \
	entry."
	value = CATALOGUER_REWARD_HARD
	unlocked_by_all = list(
		/datum/category_item/catalogue/fauna/giant_spider/guard_spider,
		/datum/category_item/catalogue/fauna/giant_spider/carrier_spider,
		/datum/category_item/catalogue/fauna/giant_spider/electric_spider,
		/datum/category_item/catalogue/fauna/giant_spider/frost_spider,
		/datum/category_item/catalogue/fauna/giant_spider/hunter_spider,
		/datum/category_item/catalogue/fauna/giant_spider/lurker_spider,
		/datum/category_item/catalogue/fauna/giant_spider/nurse_spider,
		/datum/category_item/catalogue/fauna/giant_spider/pepper_spider,
		/datum/category_item/catalogue/fauna/giant_spider/phorogenic_spider,
		/datum/category_item/catalogue/fauna/giant_spider/thermic_spider,
		/datum/category_item/catalogue/fauna/giant_spider/tunneler_spider,
		/datum/category_item/catalogue/fauna/giant_spider/webslinger_spider
		)

// Specific to guard spiders.
/datum/category_item/catalogue/fauna/giant_spider/guard_spider
	name = "Giant Spider - Guard"
	desc = "This specific spider has been catalogued as 'Guard', \
	and belongs to the 'Guard' caste. It has a brown coloration, with \
	red glowing eyes.\
	<br><br>\
	This spider, like the others in its caste, is bulky, strong, and resilient. It \
	relies on its raw strength to kill prey, due to having less potent venom compared \
	to other spiders."
	value = CATALOGUER_REWARD_EASY

// The base spider, in the 'walking tank' family.
/mob/living/simple_mob/animal/giant_spider
	name = "giant spider"
	desc = "Furry and brown, it makes you shudder to look at it. This one has deep red eyes."
	tt_desc = "X Atrax robustus gigantus"
	catalogue_data = list(/datum/category_item/catalogue/fauna/giant_spider/guard_spider)

	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	has_eye_glow = TRUE

	iff_factions = MOB_IFF_FACTION_SPIDER

	maxHealth = 200
	health = 200
	randomized = TRUE
	pass_flags = ATOM_PASS_TABLE
	movement_base_speed = 10 / 10
	movement_sound = 'sound/effects/spider_loop.ogg'
	poison_resist = 0.5
	taser_kill = 0 //These seem like they won't be bothered by a taser

	see_in_dark = 10

	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "punches"

	legacy_melee_damage_lower = 18
	legacy_melee_damage_upper = 30
	attack_sharp = 1
	attack_edge = 1
	attack_sound = 'sound/weapons/bite.ogg'

	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	minbodytemp = 175 // So they can all survive Sif without having to be classed under /sif subtype.

	speak_emote = list("chitters")

	meat_amount = 3
	meat_type = /obj/item/reagent_containers/food/snacks/xenomeat/spidermeat

	hide_amount = 1
	hide_type = /obj/item/stack/material/chitin //This used to be loot now its just the hide.

	exotic_amount = 1 //Spiders now drop their venom glands for reagent harvesting.
	exotic_type = /obj/item/reagent_containers/glass/venomgland/spider/s_toxin

	say_list_type = /datum/say_list/spider

	var/poison_type = "spidertoxin"	// The reagent that gets injected when it attacks.
	var/poison_chance = 10			// Chance for injection to occur.
	var/poison_per_bite = 5			// Amount added per injection.

/mob/living/simple_mob/animal/giant_spider/apply_melee_effects(var/atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.reagents)
			var/target_zone = pick(BP_TORSO,BP_TORSO,BP_TORSO,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_HEAD)
			if(L.can_inject(src, null, target_zone))
				inject_poison(L, target_zone)

// Does actual poison injection, after all checks passed.
/mob/living/simple_mob/animal/giant_spider/proc/inject_poison(mob/living/L, target_zone)
	if(prob(poison_chance))
		L.custom_pain(SPAN_WARNING("You feel a tiny prick."), 1, TRUE)
		L.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_mob/animal/giant_spider/proc/make_spiderling()
	adjust_scale(icon_scale_x * 0.7, icon_scale_y * 0.7)
	maxHealth = round(maxHealth * 0.5)
	health = round(health * 0.5)
	legacy_melee_damage_lower *= 0.7
	legacy_melee_damage_upper *= 0.7

	response_harm = "kicks"

	see_in_dark = max(2, round(see_in_dark * 0.6))

	if(poison_per_bite)
		poison_per_bite *= 1.3

//New Spider Exotic Drop: Poison Glands, for more reagents

/obj/item/reagent_containers/glass/venomgland/spider
	name = "Spider Venom Gland"
	desc = "A sac full of venom cut from a spider. This one seems depleted."
	icon_state = "venomgland"
	w_class = WEIGHT_CLASS_SMALL //These are not space effecient, as such they are meatn primarily to act as containers for spawning reagents.
	slot_flags = SLOT_BELT
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 15

/obj/item/reagent_containers/glass/venomgland/spider/s_toxin
	name = "Spider Venom Gland"
	desc = "A sac full of venom cut from a spider. This one looks rather average."

/obj/item/reagent_containers/glass/venomgland/spider/s_toxin/Initialize(mapload)
	. = ..()
	reagents.add_reagent("spidertoxin", 15)
