/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	max_single_weight_class = WEIGHT_CLASS_SMALL
	max_combined_volume = STORAGE_VOLUME_BOX
	drop_sound = 'sound/items/drop/cardboardbox.ogg'
	pickup_sound = 'sound/items/pickup/cardboardbox.ogg'
	worth_intrinsic = 25

	var/foldable = /obj/item/stack/material/cardboard	// BubbleWrap - if set, can be folded (when empty) into a sheet of cardboard

	/// dynamic state support
	var/dynamic_state = TRUE
	/// dynamic state overlay, if any
	var/dynamic_overlay
	/// dynamic state x shift, for off-center sprites like cases
	var/dynamic_x_shift
	/// dynamic state y shift, for off-center sprites like cases
	var/dynamic_y_shift

// todo: implement dynamic state, like how /tg/ boxes work

// BubbleWrap - A box can be folded up to make card
/obj/item/storage/box/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(..()) return

	//try to fold it.
	if ( contents.len )
		return

	if ( !ispath(foldable) )
		return
	// Now make the cardboard
	to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
	new foldable(get_turf(src))
	qdel(src)

/obj/item/storage/box/legacy_survival
	name = "emergency supply box"
	desc = "A survival box issued to crew members for use in emergency situations."
	starts_with = list(
		/obj/item/clothing/mask/breath
	)

/obj/item/storage/box/legacy_survival/synth
	name = "synthetic supply box"
	desc = "A survival box issued to synthetic crew members for use in emergency situations."
	starts_with = list(
	)

/obj/item/storage/box/legacy_survival/comp
	name = "emergency supply box"
	desc = "A comprehensive survival box issued to crew members for use in emergency situations. Contains additional supplies."
	icon_state = "survival"
	starts_with = list(
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/flashlight/glowstick,
		/obj/item/reagent_containers/food/snacks/wrapped/proteinbar,
		/obj/item/clothing/mask/breath
	)

/obj/item/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex"
	starts_with = list(/obj/item/clothing/gloves/sterile/latex = 7)

/obj/item/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"
	starts_with = list(/obj/item/clothing/mask/surgical = 7)

/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	icon_state = "syringe"
	starts_with = list(/obj/item/reagent_containers/syringe = 7)

/obj/item/storage/box/syringegun
	name = "box of syringe gun cartridges"
	desc = "A box full of compressed gas cartridges."
	icon_state = "syringe"
	starts_with = list(/obj/item/ammo_casing/syringe = 7)

/obj/item/storage/box/beakers
	name = "box of beakers"
	icon_state = "beaker"
	starts_with = list(/obj/item/reagent_containers/glass/beaker = 7)

/obj/item/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors it seems."
	starts_with = list(
		/obj/item/dnainjector/h2m = 3,
		/obj/item/dnainjector/m2h = 3
	)

// todo: all this should be special ammo magazines or something i hate abusing box-code lmao

/obj/item/storage/box/blanks
	name = "box of blank shells"
	desc = "It has a picture of a gun and several warning symbols on the front."
	icon_state = "blankshot_box"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	starts_with = list(/obj/item/ammo_casing/a12g/blank = 8)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/blanks/large
	starts_with = list(/obj/item/ammo_casing/a12g/blank = 16)

/obj/item/storage/box/beanbags
	name = "box of beanbag shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	icon_state = "beanshot_box"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/beanbags/legacy_spawn_contents()
	for(var/i in 1 to 8)
		new /obj/item/ammo_casing/a12g/beanbag(src)

/obj/item/storage/box/beanbags/large/legacy_spawn_contents()
	for(var/i in 1 to 16)
		new /obj/item/ammo_casing/a12g/beanbag(src)

/obj/item/storage/box/shotgunammo
	name = "box of shotgun slugs"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	icon_state = "lethalshellshot_box"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	starts_with = list(/obj/item/ammo_casing/a12g = 8)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/shotgunammo/large
	starts_with = list(/obj/item/ammo_casing/a12g = 16)

/obj/item/storage/box/shotgunshells
	name = "box of shotgun shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	icon_state = "lethalslug_box"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	starts_with = list(/obj/item/ammo_casing/a12g/pellet = 8)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/shotgunshells/large
	starts_with = list(/obj/item/ammo_casing/a12g/pellet = 16)

/obj/item/storage/box/flashshells
	name = "box of illumination shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	icon_state = "illumshot_box"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

	starts_with = list(/obj/item/ammo_casing/a12g/flare = 8)

/obj/item/storage/box/flashshells/large
	starts_with = list(/obj/item/ammo_casing/a12g/flare = 16)

/obj/item/storage/box/stunshells
	name = "box of stun shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	icon_state = "stunshot_box"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	starts_with = list(/obj/item/ammo_casing/a12g/stunshell = 8)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/stunshells/large
	starts_with = list(/obj/item/ammo_casing/a12g/stunshell = 16)

/obj/item/storage/box/practiceshells
	name = "box of practice shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	icon_state = "blankshot_box"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	starts_with = list(/obj/item/ammo_casing/a12g/practice = 8)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/practiceshells/large
	starts_with = list(/obj/item/ammo_casing/a12g/practice = 16)

/obj/item/storage/box/empshells
	name = "box of emp shells"
	desc = "It has a picture of a gun and several warning symbols on the front."
	icon_state = "empshot_box"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	starts_with = list(/obj/item/ammo_casing/a12g/techshell/emp = 8)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/empshells/large
	starts_with = list(/obj/item/ammo_casing/a12g/techshell/emp = 16)

/obj/item/storage/box/sniperammo
	name = "box of 12.7mm shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	starts_with = list(/obj/item/ammo_casing/a12_7mm = 7)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"
	starts_with = list(/obj/item/grenade/simple/flashbang = 7)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/emps
	name = "box of emp grenades"
	desc = "A box containing 5 military grade EMP grenades.<br> WARNING: Do not use near unshielded electronics or biomechanical augmentations, death or permanent paralysis may occur."
	icon_state = "emp"
	starts_with = list(/obj/item/grenade/simple/emp = 7)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/empslite
	name = "box of low yield emp grenades"
	desc = "A box containing 5 low yield EMP grenades.<br> WARNING: Do not use near unshielded electronics or biomechanical augmentations, death or permanent paralysis may occur."
	icon_state = "emp"
	starts_with = list(/obj/item/grenade/simple/emp/low_yield = 7)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/smokes
	name = "box of smoke bombs"
	desc = "A box containing 7 smoke bombs."
	icon_state = "flashbang"
	starts_with = list(/obj/item/grenade/simple/smoke = 7)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/anti_photons
	name = "box of anti-photon grenades"
	desc = "A box containing 7 experimental photon disruption grenades."
	icon_state = "flashbang"
	starts_with = list(/obj/item/grenade/simple/antiphoton = 7)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/frags
	name = "box of fragmentation grenades (WARNING)"
	desc = "A box containing 7 military grade fragmentation grenades.<br> WARNING: These devices are extremely dangerous and can cause limb loss or death in repeated use."
	icon_state = "frag"
	starts_with = list(/obj/item/grenade/simple/explosive = 7)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/frags_half_box
	name = "box of fragmentation grenades (WARNING)"
	desc = "A box containing 4 military grade fragmentation grenades.<br> WARNING: These devices are extremely dangerous and can cause limb loss or death in repeated use."
	icon_state = "frag"
	starts_with = list(/obj/item/grenade/simple/explosive = 4)
	drop_sound = 'sound/items/drop/ammobox.ogg'
	pickup_sound = 'sound/items/pickup/ammobox.ogg'

/obj/item/storage/box/metalfoam
	name = "box of metal foam grenades."
	desc = "A box containing 7 metal foam grenades."
	icon_state = "flashbang"
	starts_with = list(/obj/item/grenade/simple/chemical/premade/metalfoam = 7)

/obj/item/storage/box/teargas
	name = "box of teargas grenades"
	desc = "A box containing 7 teargas grenades."
	icon_state = "flashbang"
	starts_with = list(/obj/item/grenade/simple/chemical/premade/teargas = 7)

/obj/item/storage/box/flare
	name = "box of flares"
	desc = "A box containing 4 flares."
	starts_with = list(/obj/item/flashlight/flare = 4)

/obj/item/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"
	starts_with = list(
		/obj/item/implantcase/tracking = 4,
		/obj/item/implanter,
		/obj/item/implantpad,
		/obj/item/locator
	)

/obj/item/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"
	starts_with = list(
		/obj/item/implantcase/chem = 5,
		/obj/item/implanter,
		/obj/item/implantpad
	)

/obj/item/storage/box/camerabug
	name = "mobile camera pod box"
	desc = "A box containing some mobile camera pods."
	icon_state = "pda"
	starts_with = list(
		/obj/item/camerabug = 6,
		/obj/item/bug_monitor
	)

/obj/item/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"
	starts_with = list(/obj/item/clothing/glasses/regular = 7)

/obj/item/storage/box/cdeathalarm_kit
	name = "death alarm kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	starts_with = list(
		/obj/item/implantcase/death_alarm = 7,
		/obj/item/implanter
	)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	starts_with = list(/obj/item/reagent_containers/food/condiment = 7)

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	starts_with = list(/obj/item/reagent_containers/food/drinks/sillycup = 7)

/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"
	starts_with = list(/obj/item/reagent_containers/food/snacks/donkpocket = 7)

/obj/item/storage/box/sinpockets
	name = "box of sin-pockets"
	desc = "<B>Instructions:</B> <I>Crush bottom of package to initiate chemical heating. Wait for 20 seconds before consumption. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"
	starts_with = list(/obj/item/reagent_containers/food/snacks/donkpocket/sinpocket = 7)

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycubebox"
	insertion_whitelist = list(/obj/item/reagent_containers/food/snacks/monkeycube)
	starts_with = list(/obj/item/reagent_containers/food/snacks/monkeycube/wrapped = 4)

/obj/item/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Meralar. Just add water!"
	starts_with = list(/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/farwacube = 4)

/obj/item/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"
	starts_with = list(/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/stokcube = 4)

/obj/item/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"
	starts_with = list(/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube = 4)

/obj/item/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"
	starts_with = list(/obj/item/card/id = 7)

/obj/item/storage/box/seccarts
	name = "box of spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda"
	starts_with = list(/obj/item/cartridge/security = 7)

/obj/item/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"
	starts_with = list(/obj/item/handcuffs = 7)

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<B><FONT color='red'>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"
	starts_with = list(/obj/item/assembly/mousetrap = 7)

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	starts_with = list(/obj/item/storage/pill_bottle = 7)
	icon_state = "pillbox"

/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	insertion_whitelist = list(/obj/item/toy/snappop)
	starts_with = list(/obj/item/toy/snappop = 8)

/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of 'Space-Proof' premium matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_BELT
	insertion_whitelist = list(/obj/item/flame/match)
	starts_with = list(/obj/item/flame/match = 10)
	drop_sound = 'sound/items/drop/matchbox.ogg'
	pickup_sound =  'sound/items/pickup/matchbox.ogg'

/obj/item/storage/box/matches/attackby(obj/item/flame/match/W as obj, mob/user as mob)
	if(istype(W) && !W.lit && !W.burnt)
		W.lit = 1
		W.damage_type = "burn"
		W.icon_state = "match_lit"
		START_PROCESSING(SSobj, W)
	W.update_icon()
	return

/obj/item/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"
	starts_with = list(/obj/item/reagent_containers/hypospray/autoinjector = 7)

/obj/item/storage/box/lights
	name = "box of replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "syringe_kit", SLOT_ID_LEFT_HAND = "syringe_kit")
	max_items = 24
	insertion_whitelist = list(/obj/item/light/tube, /obj/item/light/bulb)
	max_combined_volume = WEIGHT_VOLUME_SMALL * 24 //holds 24 items of w_class 2
	allow_mass_gather = TRUE // for picking up broken bulbs, not that most people will try

/obj/item/storage/box/lights/bulbs
	starts_with = list(/obj/item/light/bulb = 24)

/obj/item/storage/box/lights/tubes
	name = "box of replacement tubes"
	icon_state = "lighttube"
	starts_with = list(/obj/item/light/tube = 24)

/obj/item/storage/box/lights/mixed
	name = "box of replacement lights"
	icon_state = "lightmixed"
	starts_with = list(
		/obj/item/light/tube = 16,
		/obj/item/light/bulb = 8,
	)

/obj/item/storage/box/lights/fairy
	name = "box of replacement fairy bulbs"
	icon_state = "lightfairy"
	insertion_whitelist = list(/obj/item/light/bulb/fairy)
	starts_with = list(/obj/item/light/bulb/fairy = 24)

//Colored Lights
/obj/item/storage/box/lights/bulbs_colored
	name = "box of colored bulbs"
	icon_state = "light_color"
	starts_with = list(
		/obj/item/light/bulb/red = 4,
		/obj/item/light/bulb/orange = 4,
		/obj/item/light/bulb/yellow = 4,
		/obj/item/light/bulb/green = 4,
		/obj/item/light/bulb/blue = 4,
		/obj/item/light/bulb/purple = 4,
	)

/obj/item/storage/box/lights/bulbs_neon
	name = "box of neon bulbs"
	icon_state = "light_color"
	max_items = 30
	starts_with = list(
		/obj/item/light/bulb/neon_pink = 6,
		/obj/item/light/bulb/neon_blue = 6,
		/obj/item/light/bulb/neon_green = 6,
		/obj/item/light/bulb/neon_yellow = 6,
		/obj/item/light/bulb/neon_white = 6,
	)

/obj/item/storage/box/lights/tubes_colored
	name = "box of colored tubes"
	icon_state = "lighttube_color"
	starts_with = list(
		/obj/item/light/tube/red = 4,
		/obj/item/light/tube/orange = 4,
		/obj/item/light/tube/yellow = 4,
		/obj/item/light/tube/green = 4,
		/obj/item/light/tube/blue = 4,
		/obj/item/light/tube/purple = 4,
	)

/obj/item/storage/box/lights/tubes_neon
	name = "box of neon tubes"
	icon_state = "lighttube_color"
	max_items = 30
	starts_with = list(
		/obj/item/light/tube/neon_pink = 6,
		/obj/item/light/tube/neon_blue = 6,
		/obj/item/light/tube/neon_green = 6,
		/obj/item/light/tube/neon_yellow = 6,
		/obj/item/light/tube/neon_white = 6,
	)

/obj/item/storage/box/lights/mixed_colored
	name = "box of colored lights"
	icon_state = "lightmixed_color"
	starts_with = list(
		/obj/item/light/tube/red = 2,
		/obj/item/light/tube/orange = 2,
		/obj/item/light/tube/yellow = 2,
		/obj/item/light/tube/green = 2,
		/obj/item/light/tube/blue = 2,
		/obj/item/light/tube/purple = 2,
		/obj/item/light/bulb/red = 2,
		/obj/item/light/bulb/orange = 2,
		/obj/item/light/bulb/yellow = 2,
		/obj/item/light/bulb/green = 2,
		/obj/item/light/bulb/blue = 2,
		/obj/item/light/bulb/purple = 2,
	)

/obj/item/storage/box/lights/mixed_neon
	name = "box of neon lights"
	icon_state = "lightmixed_color"
	max_items = 30
	starts_with = list(
		/obj/item/light/tube/neon_pink = 3,
		/obj/item/light/tube/neon_blue = 3,
		/obj/item/light/tube/neon_green = 3,
		/obj/item/light/tube/neon_yellow = 3,
		/obj/item/light/tube/neon_white = 3,
		/obj/item/light/bulb/neon_pink = 3,
		/obj/item/light/bulb/neon_blue = 3,
		/obj/item/light/bulb/neon_green = 3,
		/obj/item/light/bulb/neon_yellow = 3,
		/obj/item/light/bulb/neon_white = 3,
	)

/obj/item/storage/box/freezer
	name = "portable freezer"
	desc = "This nifty shock-resistant device will keep your 'groceries' nice and non-spoiled."
	icon = 'icons/obj/storage.dmi'
	icon_state = "portafreezer"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "medicalpack", SLOT_ID_LEFT_HAND = "medicalpack")
	foldable = null
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	insertion_whitelist = list(/obj/item/organ)
	max_combined_volume = WEIGHT_VOLUME_NORMAL * 5 // Formally 21.  Odd numbers are bad.
	allow_mass_gather = TRUE // for picking up broken bulbs, not that most people will try
	worth_intrinsic = 150

/obj/item/storage/box/freezer/Entered(var/atom/movable/AM)
	if(istype(AM, /obj/item/organ))
		var/obj/item/organ/O = AM
		O.preserve(PORTABLE_FREEZER_TRAIT)
	..()

/obj/item/storage/box/freezer/Exited(var/atom/movable/AM)
	if(istype(AM, /obj/item/organ))
		var/obj/item/organ/O = AM
		O.unpreserve(PORTABLE_FREEZER_TRAIT)
	..()

/obj/item/storage/box/ambrosia
	name = "ambrosia seeds box"
	desc = "Contains the seeds you need to get a little high."
	starts_with = list(/obj/item/seeds/ambrosiavulgarisseed = 7)

/obj/item/storage/box/ambrosiadeus
	name = "ambrosia deus seeds box"
	desc = "Contains the seeds you need to get a proper healthy high."
	starts_with = list(/obj/item/seeds/ambrosiadeusseed = 7)

/obj/item/storage/box/wormcan
	name = "box of worms"
	desc = "It's a box filled with worms."
	starts_with = list(/obj/item/reagent_containers/food/snacks/worm = 10)

/obj/item/storage/box/firingpins
	name = "box of standard firing pins"
	desc = "A box full of standard firing pins, to allow newly-developed firearms to operate."
	icon_state = "firingpins"
	starts_with = list(/obj/item/firing_pin = 8)

/obj/item/storage/box/legacy_survival
	starts_with = list(
		/obj/item/tool/prybar/red,
		/obj/item/clothing/glasses/goggles,
		/obj/item/clothing/mask/breath
	)

/obj/item/storage/box/legacy_survival/synth
	starts_with = list(
		/obj/item/tool/prybar/red,
		/obj/item/clothing/glasses/goggles
	)

/obj/item/storage/box/legacy_survival/comp
	starts_with = list(
		/obj/item/tool/prybar/red,
		/obj/item/clothing/glasses/goggles,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/flashlight/glowstick,
		/obj/item/reagent_containers/food/snacks/wrapped/proteinbar,
		/obj/item/clothing/mask/breath
	)

/obj/item/storage/box/explorerkeys
	name = "box of volunteer headsets"
	desc = "A box full of volunteer headsets, for issuing out to exploration volunteers."
	starts_with = list(/obj/item/radio/headset/volunteer = 7)

/obj/item/storage/box/treats
	name = "box of pet treats"
	desc = "A box full of small treats for pets, you could eat them too if you really wanted to, but why would you?"
	starts_with = list(/obj/item/reagent_containers/food/snacks/dtreat = 7)
/obj/item/storage/box/commandkeys
	name = "box of command keys"
	desc = "A box full of command keys, for command to give out as necessary."
	starts_with = list(/obj/item/encryptionkey/headset_com = 7)

/obj/item/storage/box/servicekeys
	name = "box of service keys"
	desc = "A box full of service keys, for the HoP to give out as necessary."
	starts_with = list(/obj/item/encryptionkey/headset_service = 7)

/obj/item/storage/box/legacy_survival/space
	name = "boxed emergency suit and helmet"
	icon_state = "survivaleng"
	starts_with = list(
		/obj/item/clothing/suit/space/emergency,
		/obj/item/clothing/head/helmet/space/emergency,
		/obj/item/clothing/mask/breath,
		/obj/item/tank/emergency/oxygen/double
	)

/obj/item/storage/secure/briefcase/trashmoney
	starts_with = list(/obj/item/spacecash/c200 = 10)

/obj/item/storage/box/rainponcho
	name = "foil raincoat pouch"
	icon_state = "rainponcho"
	foldable = null
	max_items = 1
	insertion_whitelist = list(/obj/item/clothing/suit/storage/hooded/rainponcho)
	starts_with = list(/obj/item/clothing/suit/storage/hooded/rainponcho)
