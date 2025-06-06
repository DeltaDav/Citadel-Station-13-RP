/* Toys!
 * Contains:
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy swords
 *		Toy bosun's whistle
 *      Toy mechs
 *		Snap pops
 *		Water flower
 *      Therapy dolls
 *      Toddler doll
 *      Inflatable duck
 *		Action figures
 *		Plushies
 *		Toy cult sword
 *		Bouquets
 		Stick Horse
 */


/obj/item/toy
	throw_force = 0
	throw_speed = 4
	throw_range = 20
	damage_force = 0

/*
 * Balloons
 */

/obj/item/toy/syndicateballoon
	name = "criminal balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	throw_force = 0
	throw_speed = 4
	throw_range = 20
	damage_force = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/toy/nanotrasenballoon
	name = "criminal balloon"
	desc = "Across the balloon the following is printed: \"Man, I love Nanotrasen soooo much. I use only NT products. You have NO idea.\""
	throw_force = 0
	throw_speed = 4
	throw_range = 20
	damage_force = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "ntballoon"
	w_class = WEIGHT_CLASS_BULKY

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/obj/item/toy/blink/Initialize(mapload)
	. = ..()
	add_overlay("[initial(icon_state)]_on")

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "gravitational singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/*
 * Toy crossbow
 */

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/gun/energy.dmi'
	icon_state = "crossbow"
	item_icons = list(
		icon_l_hand = 'icons/mob/items/lefthand_guns.dmi',
		icon_r_hand = 'icons/mob/items/righthand_guns.dmi',
		)
	slot_flags = SLOT_HOLSTER
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "struck", "hit")
	var/bullets = 5

/obj/item/toy/crossbow/examine(mob/user, dist)
	if(..(user, 2) && bullets)
		to_chat(user, "<span class='notice'>It is loaded with [bullets] foam darts!</span>")

/obj/item/toy/crossbow/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/toy/ammo/crossbow))
		if(bullets <= 4)
			if(!user.attempt_consume_item_for_construction(I))
				return
			bullets++
			to_chat(user, "<span class='notice'>You load the foam dart into the crossbow.</span>")
		else
			to_chat(user, "<span class='warning'>It's already fully loaded.</span>")

/obj/item/toy/crossbow/afterattack(atom/target, mob/user, clickchain_flags, list/params)
	if(!isturf(target.loc) || target == user) return
	if(clickchain_flags & CLICKCHAIN_HAS_PROXIMITY) return

	if (locate (/obj/structure/table, src.loc))
		return
	else if (bullets)
		var/turf/trg = get_turf(target)
		var/obj/effect/foam_dart_dummy/D = new/obj/effect/foam_dart_dummy(get_turf(src))
		bullets--
		D.icon_state = "foamdart"
		D.name = "foam dart"
		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if (D)
				if(D.loc == trg) break
				step_towards(D,trg)

				for(var/mob/living/M in D.loc)
					if(!istype(M,/mob/living)) continue
					if(M == user) continue
					for(var/mob/O in viewers(world.view, D))
						O.show_message(SPAN_WARNING("\The [M] was hit by the foam dart!"), 1)
					new /obj/item/toy/ammo/crossbow(M.loc)
					qdel(D)
					return

				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density)
						new /obj/item/toy/ammo/crossbow(A.loc)
						qdel(D)

			sleep(1)

		spawn(10)
			if(D)
				new /obj/item/toy/ammo/crossbow(D.loc)
				qdel(D)

		return
	else if (bullets == 0)
		user.afflict_paralyze(20 * 5)
		for(var/mob/O in viewers(world.view, user))
			O.show_message(SPAN_WARNING("\The [user] realized they were out of ammo and starting scrounging for some!"), 1)


/obj/item/toy/crossbow/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	. = ..()
	src.add_fingerprint(user)

// ******* Check

	if (src.bullets > 0 && target.lying)

		for(var/mob/O in viewers(target, null))
			if(O.client)
				O.show_message(SPAN_DANGER("\The [user] casually lines up a shot with [target]'s head and pulls the trigger!"), 1, SPAN_WARNING("You hear the sound of foam against skull"), 2)
				O.show_message(SPAN_WARNING("\The [target] was hit in the head by the foam dart!"), 1)

		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)
		new /obj/item/toy/ammo/crossbow(target.loc)
		src.bullets--
	else if (target.lying && src.bullets == 0)
		for(var/mob/O in viewers(target, null))
			if (O.client)
				O.show_message(SPAN_DANGER("\The [user] casually lines up a shot with [target]'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!"), 1, SPAN_WARNING("You hear someone fall"), 2)
		user.afflict_paralyze(20 * 5)

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_EARS

/obj/effect/foam_dart_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/toy.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up. It can be recolored via Alt-Click."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "esword"
	item_icons = list(
		SLOT_ID_LEFT_HAND = 'icons/mob/items/lefthand_melee.dmi',
		SLOT_ID_RIGHT_HAND = 'icons/mob/items/righthand_melee.dmi',
		)
	var/active = 0
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "struck", "hit")
	color = "#0099FF"
	var/colorable = TRUE
	var/rainbow = FALSE

/obj/item/toy/sword/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if (active)
		deactivate(user)
	else
		activate(user)

	update_worn_icon()
	add_fingerprint(user)

/obj/item/toy/sword/proc/activate(mob/living/user)
	if(active)
		return
	active = 1
	if(rainbow)
		item_state = "[icon_state]_blade_rainbow"
	else
		item_state = "[icon_state]_blade"
	set_weight_class(WEIGHT_CLASS_BULKY)
	playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
	update_icon()
	to_chat(user, SPAN_NOTICE("You extend the plastic blade with a quick flick of your wrist."))

/obj/item/toy/sword/proc/deactivate(mob/living/user)
	if(!active)
		return
	playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You push the plastic blade back down into the handle."))
	item_state = "[icon_state]"
	active = 0
	set_weight_class(initial(w_class))
	update_icon()

/obj/item/toy/sword/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/multitool) && colorable && !active)
		if(!rainbow)
			rainbow = TRUE
		else
			rainbow = FALSE
		to_chat(user, "<span class='notice'>You manipulate the color controller in [src].</span>")
		update_icon()
	return ..()

/obj/item/toy/sword/update_icon()
	var/mutable_appearance/blade_overlay = mutable_appearance(icon, "[icon_state]_blade")
	blade_overlay.color = color
	if(rainbow)
		blade_overlay = mutable_appearance(icon, "[icon_state]_blade_rainbow")
		blade_overlay.color = "FFFFFF"
		color = "FFFFFF"
	cut_overlays()		//So that it doesn't keep stacking overlays non-stop on top of each other
	if(active)
		add_overlay(blade_overlay)
	. = ..()
	update_worn_icon()

/obj/item/toy/sword/AltClick(mob/living/user)
	if(!colorable) //checks if is not colorable
		return
	if(!in_range(src, user))	//Basic checks to prevent abuse
		return
	if(user.incapacitated() || !istype(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return

	if(alert("Are you sure you want to recolor your blade?", "Confirm Recolor", "Yes", "No") == "Yes")
		var/energy_color_input = input(usr,"","Choose Energy Color",color) as color|null
		if(energy_color_input)
			color = "#[sanitize_hexcolor(energy_color_input)]"
			deactivate()
		update_icon()
	. = ..()

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	item_icons = list(
		SLOT_ID_LEFT_HAND = 'icons/mob/items/lefthand_material.dmi',
		SLOT_ID_RIGHT_HAND = 'icons/mob/items/righthand_material.dmi',
		)
	slot_flags = SLOT_BELT | SLOT_BACK
	damage_force = 5
	throw_force = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/snappop/throw_impact(atom/hit_atom)
	..()
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	new /obj/effect/debris/cleanable/ash(src.loc)
	src.visible_message(
		SPAN_WARNING("The [src.name] explodes!"),
		SPAN_WARNING("You hear a snap!"),
		SPAN_HEAR("You hear a snap!"),
	)
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	qdel(src)
	return COMPONENT_THROW_HIT_TERMINATE

/obj/item/toy/snappop/Crossed(atom/movable/H as mob|obj)
	. = ..()
	if(H.is_incorporeal() || H.is_avoiding_ground())
		return
	if((ishuman(H))) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(M.m_intent == "run")
			to_chat(M, "<span class='warning'>You step on the snap pop!</span>")

			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(2, 0, src)
			s.start()
			new /obj/effect/debris/cleanable/ash(src.loc)
			src.visible_message("<span class='warning'>The [src.name] explodes!</span>","<span class='warning'>You hear a snap!</span>")
			playsound(src, 'sound/effects/snap.ogg', 50, 1)
			qdel(src)


/*
 * Bosun's whistle
 */

/obj/item/toy/bosunwhistle
	name = "bosun's whistle"
	desc = "A genuine Admiral Krush Bosun's Whistle, for the aspiring ship's captain! Suitable for ages 8 and up, do not swallow."
	icon = 'icons/obj/toy.dmi'
	icon_state = "bosunwhistle"
	var/cooldown = 0
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_EARS | SLOT_HOLSTER

/obj/item/toy/bosunwhistle/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(cooldown < world.time - 35)
		to_chat(user, "<span class='notice'>You blow on [src], creating an ear-splitting noise!</span>")
		playsound(user, 'sound/misc/boatswain.ogg', 20, 1)
		cooldown = world.time

/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You play with [src].</span>")
		playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, "<span class='notice'>You play with [src].</span>")
			playsound(user, 'sound/mecha/mechturn.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"

/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/*
 * Action figures
 */
/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = "A \"Space Life\" brand... wait, what the hell is this thing?"
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	var/cooldown = 0
	var/toysay = "What the fuck did you do?"

/obj/item/toy/figure/Initialize(mapload)
	. = ..()
	desc = "A \"Space Life\" brand [name]"

/obj/item/toy/figure/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(cooldown < world.time)
		cooldown = (world.time + 30) //3 second cooldown
		user.visible_message("<span class='notice'>The [src] says \"[toysay]\".</span>")
		playsound(user, 'sound/machines/click.ogg', 20, 1)

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	desc = "A \"Space Life\" brand Chief Medical Officer action figure."
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	desc = "A \"Space Life\" brand Assistant action figure."
	icon_state = "assistant"
	toysay = "Grey tide station wide!"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	desc = "A \"Space Life\" brand Atmospheric Technician action figure."
	icon_state = "atmos"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	desc = "A \"Space Life\" brand Bartender action figure."
	icon_state = "bartender"
	toysay = "Where's my monkey?"

/obj/item/toy/figure/borg
	name = "Drone action figure"
	desc = "A \"Space Life\" brand Drone action figure."
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."

/obj/item/toy/figure/gardener
	name = "Gardener action figure"
	desc = "A \"Space Life\" brand Gardener action figure."
	icon_state = "botanist"
	toysay = "Dude, I see colors..."

/obj/item/toy/figure/captain
	name = "Facility Director action figure"
	desc = "A \"Space Life\" brand Facility Director action figure."
	icon_state = "captain"
	toysay = "How do I open this display case?"

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	desc = "A \"Space Life\" brand Cargo Technician action figure."
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	desc = "A \"Space Life\" brand Chief Engineer action figure."
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	desc = "A \"Space Life\" brand Chaplain action figure."
	icon_state = "chaplain"
	toysay = "Gods make me a killing machine please!"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	desc = "A \"Space Life\" brand Chef action figure."
	icon_state = "chef"
	toysay = "I swear it's not human meat."

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	desc = "A \"Space Life\" brand Chemist action figure."
	icon_state = "chemist"
	toysay = "Get your pills!"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	desc = "A \"Space Life\" brand Clown action figure."
	icon_state = "clown"
	toysay = "<font face='comic sans ms'><b>Honk!</b></font>"

/obj/item/toy/figure/corgi
	name = "Corgi action figure"
	desc = "A \"Space Life\" brand Corgi action figure."
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	desc = "A \"Space Life\" brand Detective action figure."
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/dsquad
	name = "Space Commando action figure"
	desc = "A \"Space Life\" brand Space Commando action figure."
	icon_state = "dsquad"
	toysay = "Eliminate all threats!"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	desc = "A \"Space Life\" brand Engineer action figure."
	icon_state = "engineer"
	toysay = "Oh god, the engine is gonna go!"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	desc = "A \"Space Life\" brand Geneticist action figure, which was recently dicontinued."
	icon_state = "geneticist"
	toysay = "I'm not qualified for this job."

/obj/item/toy/figure/hop
	name = "Head of Personnel action figure"
	desc = "A \"Space Life\" brand Head of Personnel action figure."
	icon_state = "hop"
	toysay = "Giving out all access!"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	desc = "A \"Space Life\" brand Head of Security action figure."
	icon_state = "hos"
	toysay = "I'm here to win, anything else is secondary."

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	desc = "A \"Space Life\" brand Quartermaster action figure."
	icon_state = "qm"
	toysay = "Hail Cargonia!"

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	desc = "A \"Space Life\" brand Janitor action figure."
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."

/obj/item/toy/figure/agent
	name = "Internal Affairs Agent action figure"
	desc = "A \"Space Life\" brand Internal Affairs Agent action figure."
	icon_state = "agent"
	toysay = "Standard Operating Procedure says they're guilty! Hacking is proof they're an Enemy of the Corporation!"

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	desc = "A \"Space Life\" brand Librarian action figure."
	icon_state = "librarian"
	toysay = "One day while..."

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	desc = "A \"Space Life\" brand Medical Doctor action figure."
	icon_state = "md"
	toysay = "The patient is already dead!"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	desc = "A \"Space Life\" brand Mime action figure."
	icon_state = "mime"
	toysay = "..."

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	desc = "A \"Space Life\" brand Shaft Miner action figure."
	icon_state = "miner"
	toysay = "Oh god, it's eating my intestines!"

/obj/item/toy/figure/ninja
	name = "Space Ninja action figure"
	desc = "A \"Space Life\" brand Space Ninja action figure."
	icon_state = "ninja"
	toysay = "Oh god! Stop shooting, I'm friendly!"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	desc = "A \"Space Life\" brand Wizard action figure."
	icon_state = "wizard"
	toysay = "Ei Nath!"

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	desc = "A \"Space Life\" brand Research Director action figure."
	icon_state = "rd"
	toysay = "Blowing all of the borgs!"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	desc = "A \"Space Life\" brand Roboticist action figure."
	icon_state = "roboticist"
	toysay = "He asked to be borged!"

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	desc = "A \"Space Life\" brand Scientist action figure."
	icon_state = "scientist"
	toysay = "Someone else must have made those bombs!"

/obj/item/toy/figure/syndie
	name = "Doom Operative action figure"
	desc = "A \"Space Life\" brand Doom Operative action figure."
	icon_state = "syndie"
	toysay = "Get that fucking disk!"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	desc = "A \"Space Life\" brand Security Officer action figure."
	icon_state = "secofficer"
	toysay = "I am the law!"

/obj/item/toy/figure/virologist
	name = "Virologist action figure"
	desc = "A \"Space Life\" brand Virologist action figure."
	icon_state = "virologist"
	toysay = "The cure is potassium!"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	desc = "A \"Space Life\" brand Warden action figure."
	icon_state = "warden"
	toysay = "Execute him for breaking in!"

/obj/item/toy/figure/psychologist
	name = "Psychologist action figure"
	desc = "A \"Space Life\" brand Psychologist action figure."
	icon_state = "psychologist"
	toysay = "The analyzer says you're fine!"

/obj/item/toy/figure/paramedic
	name = "Paramedic action figure"
	desc = "A \"Space Life\" brand Paramedic action figure."
	icon_state = "paramedic"
	toysay = "WHERE ARE YOU??"

/obj/item/toy/figure/ert
	name = "Emergency Response Team Commander action figure"
	desc = "A \"Space Life\" brand Emergency Response Team Commander action figure."
	icon_state = "ert"
	toysay = "We're probably the good guys!"

/*
 * Plushies
 */

/*
 * Carp plushie
 */

/obj/item/toy/plushie/carp
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon = 'icons/obj/toy.dmi'
	icon_state = "basecarp"
	attack_verb = list("bitten", "eaten", "fin slapped")
	var/bitesound = 'sound/weapons/bite.ogg'

// Attack mob
/obj/item/toy/plushie/carp/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	. = ..()
	playsound(src, bitesound, 20, 1)	// Play bite sound in local area

// Attack self
/obj/item/toy/plushie/carp/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	playsound(src, bitesound, 20, 1)

/obj/random/carp_plushie
	name = "Random Carp Plushie"
	desc = "This is a random plushie"
	icon = 'icons/obj/toy.dmi'
	icon_state = "basecarp"

/obj/random/carp_plushie/item_to_spawn()
	return pick(typesof(/obj/item/toy/plushie/carp)) //can pick any carp plushie, even the original.

/obj/item/toy/plushie/carp/ice
	name = "ice carp plushie"
	icon_state = "icecarp"

/obj/item/toy/plushie/carp/silent
	name = "monochrome carp plushie"
	icon_state = "silentcarp"

/obj/item/toy/plushie/carp/electric
	name = "electric carp plushie"
	icon_state = "electriccarp"

/obj/item/toy/plushie/carp/gold
	name = "golden carp plushie"
	icon_state = "goldcarp"

/obj/item/toy/plushie/carp/toxin
	name = "toxic carp plushie"
	icon_state = "toxincarp"

/obj/item/toy/plushie/carp/dragon
	name = "dragon carp plushie"
	icon_state = "dragoncarp"

/obj/item/toy/plushie/carp/pink
	name = "pink carp plushie"
	icon_state = "pinkcarp"

/obj/item/toy/plushie/carp/candy
	name = "candy carp plushie"
	icon_state = "candycarp"

/obj/item/toy/plushie/carp/nebula
	name = "nebula carp plushie"
	icon_state = "nebulacarp"

/obj/item/toy/plushie/carp/void
	name = "void carp plushie"
	icon_state = "voidcarp"

//Large plushies.
/obj/structure/plushie
	name = "generic plush"
	desc = "A very generic plushie. It seems to not want to exist."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ianplushie"
	anchored = 0
	density = 1
	var/phrase = "I don't want to exist anymore!"

/obj/structure/plushie/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	user.setClickCooldownLegacy(DEFAULT_ATTACK_COOLDOWN)
	if(user.a_intent == INTENT_HELP)
		user.visible_message("<span class='notice'><b>\The [user]</b> hugs [src]!</span>","<span class='notice'>You hug [src]!</span>")
	else if (user.a_intent == INTENT_HARM)
		user.visible_message("<span class='warning'><b>\The [user]</b> punches [src]!</span>","<span class='warning'>You punch [src]!</span>")
	else if (user.a_intent == INTENT_GRAB)
		user.visible_message("<span class='warning'><b>\The [user]</b> attempts to strangle [src]!</span>","<span class='warning'>You attempt to strangle [src]!</span>")
	else
		user.visible_message("<span class='notice'><b>\The [user]</b> pokes the [src].</span>","<span class='notice'>You poke the [src].</span>")
		visible_message("[src] says, \"[phrase]\"")


/obj/structure/plushie/ian
	name = "plush corgi"
	desc = "A plushie of an adorable corgi! Don't you just want to hug it and squeeze it and call it \"Ian\"?"
	icon_state = "ianplushie"
	phrase = "Arf!"

/obj/structure/plushie/drone
	name = "plush drone"
	desc = "A plushie of a happy drone! It appears to be smiling."
	icon_state = "droneplushie"
	phrase = "Beep boop!"

/obj/structure/plushie/carp
	name = "plush carp"
	desc = "A plushie of an elated carp! Straight from the wilds of the Vir frontier, now right here in your hands."
	icon_state = "carpplushie"
	phrase = "Glorf!"

/obj/structure/plushie/beepsky
	name = "plush Officer Sweepsky"
	desc = "A plushie of a popular industrious cleaning robot! If it could feel emotions, it would love you."
	icon_state = "beepskyplushie"
	phrase = "Ping!"

//Small plushies.
/obj/item/toy/plushie
	name = "generic small plush"
	desc = "A small toy plushie. It's very cute."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nymphplushie"
	w_class = WEIGHT_CLASS_TINY
	var/last_message = 0
	var/pokephrase = "Uww!"

/obj/item/toy/plushie/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(world.time - last_message <= 1 SECOND)
		return
	if(user.a_intent == INTENT_HELP)
		user.visible_message("<span class='notice'><b>\The [user]</b> hugs [src]!</span>","<span class='notice'>You hug [src]!</span>")
	else if (user.a_intent == INTENT_HARM)
		user.visible_message("<span class='warning'><b>\The [user]</b> punches [src]!</span>","<span class='warning'>You punch [src]!</span>")
	else if (user.a_intent == INTENT_GRAB)
		user.visible_message("<span class='warning'><b>\The [user]</b> attempts to strangle [src]!</span>","<span class='warning'>You attempt to strangle [src]!</span>")
	else
		user.visible_message("<span class='notice'><b>\The [user]</b> pokes [src].</span>","<span class='notice'>You poke [src].</span>")
		visible_message("[src] says, \"[pokephrase]\"")
	last_message = world.time

/obj/item/toy/plushie/verb/rename_plushie()
	set name = "Name Plushie"
	set category = VERB_CATEGORY_OBJECT
	set desc = "Give your plushie a cute name!"
	var/mob/M = usr
	if(!M.mind)
		return 0

	var/input = sanitizeSafe(input("What do you want to name the plushie?", ,""), MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src))
		name = input
		to_chat(M, "You name the plushie [input], giving it a hug for good luck.")
		return 1

/obj/item/toy/plushie/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/toy/plushie) || istype(I, /obj/item/organ/external/head))
		user.visible_message("<span class='notice'>[user] makes \the [I] kiss \the [src]!.</span>", \
		"<span class='notice'>You make \the [I] kiss \the [src]!</span>")
	return ..()

/obj/item/toy/plushie/nymph
	name = "diona nymph plush"
	desc = "A plushie of an adorable diona nymph! While its level of self-awareness is still being debated, its level of cuteness is not."
	icon_state = "nymphplushie"
	pokephrase = "Chirp!"

/obj/item/toy/plushie/teshari
	name = "teshari plush"
	desc = "This is a plush teshari. Very soft, with a pompom on the tail. The toy is made well, as if alive. Looks like she is sleeping. Shhh!"
	icon_state = "teshariplushie"
	pokephrase = "Rya!"

/obj/item/toy/plushie/mouse
	name = "mouse plush (brown)"
	desc = "A plushie of a delightful mouse! What was once considered a vile rodent is now your very best friend."
	icon_state = "mouseplushie"	//TFF 12/11/19 - updated icon to show a sprite that doesn't replicate a dead mouse. Heck you for that! >:C
	item_state = "mouseplushie_brown"
	slot_flags = SLOT_HEAD
	pokephrase = "Squeak!"

/obj/item/toy/plushie/mouse/grey
	name = "mouse plush (grey)"
	desc = "A plushie of a delightful mouse! What was once considered a vile rodent is now your very best friend. Now in fuzzy grey!"
	icon_state = "mouseplushie_grey"	//TFF 12/11/19 - updated icon to show a sprite that doesn't replicate a dead mouse. Heck you for that! >:C
	item_state = "mouseplushie_grey"
	pokephrase = "Squeak!"

/obj/item/toy/plushie/mouse/white
	name = "mouse plush (white)"
	desc = "A plushie of a delightful mouse! What was once considered a vile rodent is now your very best friend. Now in labcoat white!"
	icon_state = "mouseplushie_white"	//TFF 12/11/19 - updated icon to show a sprite that doesn't replicate a dead mouse. Heck you for that! >:C
	item_state = "mouseplushie_white"
	pokephrase = "Squeak!"

/obj/item/toy/plushie/kitten
	name = "kitten plush"
	desc = "A plushie of a cute kitten! Watch as it purrs its way right into your heart."
	icon_state = "kittenplushie"
	pokephrase = "Mrow!"

/obj/item/toy/plushie/lizard
	name = "lizard plush"
	desc = "A plushie of a scaly lizard! Very controversial, after being accused as \"racist\" by some Unathi."
	icon_state = "lizardplushie"
	pokephrase = "Hiss!"

/obj/item/toy/plushie/spider
	name = "spider plush"
	desc = "A plushie of a fuzzy spider! It has eight legs - all the better to hug you with."
	icon_state = "spiderplushie"
	pokephrase = "Sksksk!"

/obj/item/toy/plushie/farwa
	name = "farwa plush"
	desc = "A farwa plush doll. It's soft and comforting!"
	icon_state = "farwaplushie"
	pokephrase = "Squaw!"

/obj/item/toy/plushie/corgi
	name = "corgi plushie"
	icon_state = "corgi"
	pokephrase = "Woof!"

/obj/item/toy/plushie/girly_corgi
	name = "corgi plushie"
	icon_state = "girlycorgi"
	pokephrase = "Arf!"

/obj/item/toy/plushie/robo_corgi
	name = "borgi plushie"
	icon_state = "robotcorgi"
	pokephrase = "Bark."

/obj/item/toy/plushie/octopus
	name = "octopus plushie"
	icon_state = "loveable"
	pokephrase = "Squish!"

/obj/item/toy/plushie/face_hugger
	name = "facehugger plushie"
	icon_state = "huggable"
	pokephrase = "Hug!"

/obj/item/toy/plushie/voxie
	name = "vox plushie"
	icon_state = "voxie"
	pokephrase = "Skree!"

//foxes are basically the best
/obj/item/toy/plushie/red_fox
	name = "red fox plushie"
	icon_state = "redfox"
	pokephrase = "Gecker!"

/obj/item/toy/plushie/black_fox
	name = "black fox plushie"
	icon_state = "blackfox"
	pokephrase = "Ack!"

/obj/item/toy/plushie/marble_fox
	name = "marble fox plushie"
	icon_state = "marblefox"
	pokephrase = "Awoo!"

/obj/item/toy/plushie/blue_fox
	name = "blue fox plushie"
	icon_state = "bluefox"
	pokephrase = "Yoww!"

/obj/item/toy/plushie/orange_fox
	name = "orange fox plushie"
	icon_state = "orangefox"
	pokephrase = "Yagh!"

/obj/item/toy/plushie/coffee_fox
	name = "coffee fox plushie"
	icon_state = "coffeefox"
	pokephrase = "Gerr!"

/obj/item/toy/plushie/pink_fox
	name = "pink fox plushie"
	icon_state = "pinkfox"
	pokephrase = "Yack!"

/obj/item/toy/plushie/purple_fox
	name = "purple fox plushie"
	icon_state = "purplefox"
	pokephrase = "Whine!"

/obj/item/toy/plushie/crimson_fox
	name = "crimson fox plushie"
	icon_state = "crimsonfox"
	pokephrase = "Auuu!"

/obj/item/toy/plushie/deer
	name = "deer plushie"
	icon_state = "deer"
	pokephrase = "Bleat!"

/obj/item/toy/plushie/black_cat
	name = "black cat plushie"
	icon_state = "blackcat"
	pokephrase = "Mlem!"

/obj/item/toy/plushie/grey_cat
	name = "grey cat plushie"
	icon_state = "greycat"
	pokephrase = "Mraw!"

/obj/item/toy/plushie/white_cat
	name = "white cat plushie"
	icon_state = "whitecat"
	pokephrase = "Mew!"

/obj/item/toy/plushie/orange_cat
	name = "orange cat plushie"
	icon_state = "orangecat"
	pokephrase = "Meow!"

/obj/item/toy/plushie/siamese_cat
	name = "siamese cat plushie"
	icon_state = "siamesecat"
	pokephrase = "Mrew?"

/obj/item/toy/plushie/tabby_cat
	name = "tabby cat plushie"
	icon_state = "tabbycat"
	pokephrase = "Purr!"

/obj/item/toy/plushie/tuxedo_cat
	name = "tuxedo cat plushie"
	icon_state = "tuxedocat"
	pokephrase = "Mrowww!!"

/obj/item/toy/plushie/toad
	name = "\improper Toad plushie"
	desc = "Not actually a replica of a toad, but a humanoid toadstool! It wont stop screaming (lovingly) when you poke and squeeze it, but somehow it's cute anyways. Reminds you of times spent racing."
	icon_state = "toadplush"
	pokephrase = "Waaah!!"

/obj/item/toy/plushie/petrock
	name = "\improper Rock"
	desc = "A large boulder the size of a small boulder."
	icon_state = "petrock"
	pokephrase = ". . ."
	drop_sound = 'sound/items/drop/screwdriver.ogg'
	pickup_sound = 'sound/items/pickup/screwdriver.ogg'

// nah, squids are better than foxes :>	//there are no squidgirls on citadel this is factually false
/obj/item/toy/plushie/squid/green
	name = "green squid plushie"
	desc = "A small, cute and loveable squid friend. This one is green."
	icon = 'icons/obj/toy.dmi'
	icon_state = "greensquid"
	slot_flags = SLOT_HEAD
	pokephrase = "Squrr!"

/obj/item/toy/plushie/squid/mint
	name = "mint squid plushie"
	desc = "A small, cute and loveable squid friend. This one is mint coloured."
	icon = 'icons/obj/toy.dmi'
	icon_state = "mintsquid"
	slot_flags = SLOT_HEAD
	pokephrase = "Blurble!"

/obj/item/toy/plushie/squid/blue
	name = "blue squid plushie"
	desc = "A small, cute and loveable squid friend. This one is blue."
	icon = 'icons/obj/toy.dmi'
	icon_state = "bluesquid"
	slot_flags = SLOT_HEAD
	pokephrase = "Blob!"

/obj/item/toy/plushie/squid/orange
	name = "orange squid plushie"
	desc = "A small, cute and loveable squid friend. This one is orange."
	icon = 'icons/obj/toy.dmi'
	icon_state = "orangesquid"
	slot_flags = SLOT_HEAD
	pokephrase = "Squash!"

/obj/item/toy/plushie/squid/yellow
	name = "yellow squid plushie"
	desc = "A small, cute and loveable squid friend. This one is yellow."
	icon = 'icons/obj/toy.dmi'
	icon_state = "yellowsquid"
	slot_flags = SLOT_HEAD
	pokephrase = "Glorble!"

/obj/item/toy/plushie/squid/pink
	name = "pink squid plushie"
	desc = "A small, cute and loveable squid friend. This one is pink."
	icon = 'icons/obj/toy.dmi'
	icon_state = "pinksquid"
	slot_flags = SLOT_HEAD
	pokephrase = "Wobble!"

//Therapy Dolls, aka show me on the doll where the furry touched you
/obj/item/toy/plushie/therapy/red
	name = "red therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is red."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapyred"
	item_state = "egg4" // It's the red egg in items_left/righthand

/obj/item/toy/plushie/therapy/purple
	name = "purple therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is purple."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapypurple"
	item_state = "egg1" // It's the magenta egg in items_left/righthand

/obj/item/toy/plushie/therapy/blue
	name = "blue therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is blue."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapyblue"
	item_state = "egg2" // It's the blue egg in items_left/righthand

/obj/item/toy/plushie/therapy/yellow
	name = "yellow therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is yellow."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapyyellow"
	item_state = "egg5" // It's the yellow egg in items_left/righthand

/obj/item/toy/plushie/therapy/orange
	name = "orange therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is orange."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapyorange"
	item_state = "egg4" // It's the red one again, lacking an orange item_state and making a new one is pointless

/obj/item/toy/plushie/therapy/green
	name = "green therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is green."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapygreen"
	item_state = "egg3" // It's the green egg in items_left/righthand

//Pingus, the aristocrat's choice of plushie.
/obj/item/toy/plushie/penguin_emperor
	name = "emperor penguin plushie"
	icon_state = "emperor_penguin_plush"
	pokephrase = "Noot Noot!"

/obj/item/toy/plushie/penguin_baby
	name = "baby penguin plushie"
	icon_state = "baby_penguin_plush"
	pokephrase = "Noot!"

//dogborg plushies because why not
/obj/item/toy/plushie/borgplushie
	name = "medihound plushie"
	desc = "An adorable, stuffed toy of a cyborg. This one looks like a Medihound model!"
	icon_state = "medihound"
	slot_flags = SLOT_HEAD
	pokephrase = "Beep!"
	attack_verb = list("beeped", "booped", "pinged")

/obj/item/toy/plushie/borgplushie/securityk9
	name = "k9 plushie"
	desc = "An adorable, stuffed toy of a cyborg. This one looks like a K9 model!"
	icon_state = "securityk9"

/obj/item/toy/plushie/borgplushie/scrubpuppy
	name = "scrubpuppy plushie"
	desc = "An adorable, stuffed toy of a cyborg. This one looks like a Scrubpup model!"
	icon_state = "scrubpuppy"

/obj/item/toy/plushie/borgplushie/pupdozer
	name = "pupdozer plushie"
	desc = "An adorable, stuffed toy of a cyborg. This one looks like a Pup Dozer model!"
	icon_state = "pupdozer"


//More Misc Plushies
/obj/item/toy/plushie/gondola
	name = "gondola plushie"
	icon_state = "gondola_plush"
	pokephrase = ". . ."

/obj/item/toy/plushie/crab
	name = "crab plushie"
	icon_state = "crab_plush"
	pokephrase = "Clack!"

/obj/item/toy/plushie/frog
	name = "frog plushie"
	icon_state = "frog_plush"
	pokephrase = "REEEEEEEEEEE!"

/obj/item/toy/plushie/dolphin
	name = "dolphin plushie"
	icon_state = "dolphin_plush"
	pokephrase = "Ekikikiki!"

/obj/item/toy/plushie/rat
	name = "rat plushie"
	icon_state = "rat_plush"
	pokephrase = "Squeak!"

/obj/item/toy/plushie/cyancowgirl
	name = "cyan cowgirl"
	icon_state = "cyancowgirl"
	pokephrase = "Yee Haw!"

/obj/item/toy/plushie/bear_grizzly
	name = "Grizzly Bear"
	icon_state = "bear_grizzly"
	pokephrase = "Grrrowl!"

/obj/item/toy/plushie/bear_polar
	name = "Polar Bear"
	icon_state = "bear_polar"
	pokephrase = "Rrrrrh!"

/obj/item/toy/plushie/bear_soda
	name = "Soda Bear"
	icon_state = "bear_soda"
	pokephrase = "Consume!"

/obj/item/toy/plushie/bear_bloody
	name = "Bloody Bear"
	icon_state = "bear_bloody"
	pokephrase = "ROOOOOAAARRR!"

/obj/item/toy/plushie/bear_panda
	name = "Panda Bear"
	icon_state = "bear_panda"
	pokephrase = "Grrrhh!"

/obj/item/toy/plushie/bear_space
	name = "Space Bear"
	icon_state = "bear_space"
	pokephrase = "Mission is Grrrreen!"

/obj/item/toy/plushie/doll
	name = "Black and white doll"
	icon_state = "doll"
	pokephrase = ""

//Toy cult sword
/obj/item/toy/cultsword
	name = "foam sword"
	desc = "An arcane weapon (made of foam) wielded by the followers of the hit Saturday morning cartoon \"King Nursee and the Acolytes of Heroism\"."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cultblade"
	item_icons = list(
		SLOT_ID_LEFT_HAND = 'icons/mob/items/lefthand_melee.dmi',
		SLOT_ID_RIGHT_HAND = 'icons/mob/items/righthand_melee.dmi',
		)
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("attacked", "slashed", "stabbed", "poked")

//Flowers fake & real

/obj/item/toy/bouquet
	name = "bouquet"
	desc = "A lovely bouquet of flowers. Smells nice!"
	icon = 'icons/obj/items.dmi'
	icon_state = "bouquet"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/bouquet/fake
	name = "plastic bouquet"
	desc = "A cheap plastic bouquet of flowers. Smells like cheap, toxic plastic."

/obj/item/toy/stickhorse
	name = "stick horse"
	desc = "A pretend horse on a stick for any aspiring little cowboy to ride."
	icon = 'icons/obj/toy.dmi'
	icon_state = "stickhorse"
	w_class = WEIGHT_CLASS_BULKY

//////////////////////////////////////////////////////
//				Magic 8-Ball / Conch				//
//////////////////////////////////////////////////////

/obj/item/toy/eight_ball
	name = "\improper Magic 8-Ball"
	desc = "Mystical! Magical! Ages 8+!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "eight-ball"
	var/use_action = "shakes the ball"
	var/cooldown = 0
	var/list/possible_answers = list("Definitely.", "All signs point to yes.", "Most likely.", "Yes.", "Ask again later.", "Better not tell you now.", "Future unclear.", "Maybe.", "Doubtful.", "No.", "Don't count on it.", "Never.")

/obj/item/toy/eight_ball/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(!cooldown)
		var/answer = pick(possible_answers)
		user.visible_message("<span class='notice'>[user] focuses on their question and [use_action]...</span>")
		user.visible_message("<span class='notice'>The [src] says \"[answer]\"</span>")
		spawn(30)
			cooldown = 0
		return

/obj/item/toy/eight_ball/conch
	name = "Magic Conch shell"
	desc = "All hail the Magic Conch!"
	icon_state = "conch"
	use_action = "pulls the string"
	possible_answers = list("Yes.", "No.", "Try asking again.", "Nothing.", "I don't think so.", "Neither.", "Maybe someday.")

// DND Character minis. Use the naming convention (type)character for the icon states.
/obj/item/toy/character
	icon = 'icons/obj/toy.dmi'
	w_class = WEIGHT_CLASS_SMALL
	pixel_z = 5

/obj/item/toy/character/alien
	name = "xenomorph xiniature"
	desc = "A miniature xenomorph. Scary!"
	icon_state = "aliencharacter"
/obj/item/toy/character/cleric
	name = "cleric miniature"
	desc = "A wee little cleric, with his wee little staff."
	icon_state = "clericcharacter"
/obj/item/toy/character/warrior
	name = "warrior miniature"
	desc = "That sword would make a decent toothpick."
	icon_state = "warriorcharacter"
/obj/item/toy/character/thief
	name = "thief miniature"
	desc = "Hey, where did my wallet go!?"
	icon_state = "thiefcharacter"
/obj/item/toy/character/wizard
	name = "wizard miniature"
	desc = "MAGIC!"
	icon_state = "wizardcharacter"
/obj/item/toy/character/voidone
	name = "void one miniature"
	desc = "The dark lord has risen!"
	icon_state = "darkmastercharacter"
/obj/item/toy/character/lich
	name = "lich miniature"
	desc = "Murderboner extraordinaire."
	icon_state = "lichcharacter"
/obj/item/storage/box/characters
	name = "box of miniatures"
	desc = "The nerd's best friends."
	icon_state = "box"
/obj/item/storage/box/characters/starts_with = list(
//	/obj/item/toy/character/alien,
	/obj/item/toy/character/cleric,
	/obj/item/toy/character/warrior,
	/obj/item/toy/character/thief,
	/obj/item/toy/character/wizard,
	/obj/item/toy/character/voidone,
	/obj/item/toy/character/lich
	)

/obj/item/toy/AI
	name = "toy AI"
	desc = "A little toy model AI core!"// with real law announcing action!" //Alas, requires a rewrite of how ion laws work.
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
/*
/obj/item/toy/AI/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(!cooldown) //for the sanity of everyone
		var/message = generate_ion_law()
		to_chat(user, "<span class='notice'>You press the button on [src].</span>")
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		visible_message("<span class='danger'>[message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()
*/
/obj/item/toy/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon = 'icons/obj/toy.dmi'
	icon_state = "owlprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/owl/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You won't get away this time, Griffin!", "Stop right there, criminal!", "Hoot! Hoot!", "I am the night!")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		//playsound(user, 'sound/misc/hoot.ogg', 25, 1)
		visible_message("<span class='danger'>[message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return

/obj/item/toy/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon = 'icons/obj/toy.dmi'
	icon_state = "griffinprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/griffin/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You can't stop me, Owl!", "My plan is flawless! The vault is mine!", "Caaaawwww!", "You will never catch me!")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		//playsound(user, 'sound/misc/caw.ogg', 25, 1)
		visible_message("<span class='danger'>[message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return

/obj/item/toy/cowgirlprize
	name = "cyan cowgirl action figure"
	desc = "A detailed miniature figure based on the 'Cyan Cowgirl', fastest gun on the Frontier."
	icon = 'icons/obj/toy.dmi'
	icon_state = "cowgirlprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/cowgirlprize/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(!cooldown) //for the sanity of everyone
		var/message = pick("Yee haw!", "Enjoy my signature CC Root Beer, y'all!", "Shuck 'em up!", "What in tarnation?")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		//playsound(user, 'sound/misc/click.ogg', 20, 1)
		visible_message("<span class='danger'>[message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return

/obj/item/toy/snakeoilprize
	name = "snake oil salesman action figure"
	desc = "A detailed miniature figure based on the 'Snake Oil Salesman', villain and cheat, scourge of the Frontier."
	icon = 'icons/obj/toy.dmi'
	icon_state = "snakeoilprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/snakeoilprize/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(!cooldown) //for the sanity of everyone
		var/message = pick("Mwahahaha!", "Try my snake oil! Guaranteed to solve all problems!", "Time to skedaddle.", "Money money money!")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		//playsound(user, 'sound/misc/click.ogg', 20, 1)
		visible_message("<span class='danger'>[message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return

//This should really be somewhere else but I don't know where. w/e

/obj/item/inflatable_duck
	name = "inflatable duck"
	desc = "No bother to sink or swim when you can just float!"
	icon_state = "inflatable"
	icon = 'icons/obj/clothing/belts.dmi'
	slot_flags = SLOT_BELT

/obj/item/toy/xmastree
	name = "Miniature Christmas tree"
	desc = "Tiny cute Christmas tree."
	icon = 'icons/obj/toy.dmi'
	icon_state = "tinyxmastree"
	w_class = WEIGHT_CLASS_TINY
	damage_force = 1
	throw_force = 1

//Dakimakuras, ported from Main.

/obj/item/storage/daki
	name = "dakimakura"
	desc = "A large pillow depicting a girl in a compromising position. Featuring as many dimensions as you."
	icon = 'icons/obj/toy.dmi'
	icon_state = "daki_base"
	slot_flags = SLOT_BACK
	var/cooldowntime = 20
	var/static/list/dakimakura_options = list("Callie","Casca","Chaika","Elisabeth","Foxy Grandpa","Haruko","Holo","Ian","Jolyne","Kurisu","Marie","Mugi","Nar'Sie","Patchouli","Plutia","Rei","Reisen","Naga","Squid","Squigly","Tomoko","Toriel","Umaru","Yaranaika","Yoko") //Kurisu is the ideal girl." - Me, Logos.
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_BACK
	max_single_weight_class = WEIGHT_CLASS_SMALL
	max_combined_volume = STORAGE_VOLUME_BOX
	var/last_message = 0

/obj/item/storage/daki/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	var/body_choice
	var/custom_name

	if(icon_state == "daki_base")
		body_choice = input("Pick a body.") in dakimakura_options
		icon_state = "daki_[body_choice]"
		custom_name = stripped_input(user, "What's her name?")
		if(length(custom_name) > MAX_NAME_LEN)
			to_chat(user,"<span class='danger'>Name is too long!</span>")
			return FALSE
		if(custom_name)
			name = custom_name
			desc = "A large pillow depicting [custom_name] in a compromising position. Featuring as many dimensions as you."
	else
		if(world.time - last_message <= 1 SECOND)
			return
		if(user.a_intent == INTENT_HELP)
			user.visible_message("<span class='notice'>[user] hugs the [name].</span>")
			playsound(src, "rustle", 50, 1, -5)
		else if(user.a_intent == INTENT_DISARM)
			user.visible_message("<span class='notice'>[user] kisses the [name].</span>")
			playsound(src, "rustle", 50, 1, -5)
		else if(user.a_intent == INTENT_GRAB)
			user.visible_message("<span class='warning'>[user] holds the [name]!</span>")
			playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		else if(user.a_intent == INTENT_HARM)
			user.visible_message("<span class='danger'>[user] punches the [name]!</span>")
			playsound(src, 'sound/effects/shieldbash.ogg', 50, 1)
		last_message = world.time

	//Chess Variants

/obj/item/chess
	name = "Chess Piece"
	icon = 'icons/obj/chess.dmi'
	icon_state = "w-queen"
	desc = "Some sort of novelty chess piece."

/obj/item/chess/wpawn
	name = "White Pawn"
	desc = "A Novelty chess piece in the image of an assistant representing a white pawn."
	icon_state = "w-pawn"

/obj/item/chess/bpawn
	name = "Black Pawn"
	desc = "A Novelty chess piece in the image of a filthy unionizing employee, representing a black pawn."
	icon_state = "b-pawn"

/obj/item/chess/bknight
	name = "Black Knight"
	desc = "A Novelty chess piece in the image of a corporate traitor representing a black knight."
	icon_state = "b-knight"

/obj/item/chess/wknight
	icon_state = "w-knight"
	name = "White Knight"
	desc = "A Novelty chess piece in the image of a brave clown representing a white knight."

/obj/item/chess/brook
	name = "Black Rook"
	desc = "A Novelty chess piece in the image of a mercenary commando representing a black rook."
	icon_state = "b-rook"

/obj/item/chess/wrook
	name = "White Rook"
	desc = "A Novelty chess piece in the image of a loyal security officer representing a white rook."
	icon_state = "w-rook"

/obj/item/chess/bbishop
	name = "Black Bishop"
	desc = "A Novelty chess piece in the image of a vile mercenary swordsman representing a black bishop."
	icon_state = "b-bishop"

/obj/item/chess/wbishop
	name = "White Bishop"
	desc = "A Novelty chess piece in the image of a noble mime representing a white bishop."
	icon_state = "w-bishop"

/obj/item/chess/bqueen
	name = "Black Queen"
	desc = "A Novelty chess piece in the image of a super elite mercenary raider representing a black queen."
	icon_state = "b-queen"

/obj/item/chess/wqueen
	name = "White Queen"
	desc = "A Novelty chess piece in the image of a heoric member of asset protection representing a white queen."
	icon_state = "w-queen"

/obj/item/chess/bking
	name = "Black King"
	desc = "A Novelty chess piece in the image of a strange and vile creature representing a black king."
	icon_state = "b-king"

/obj/item/chess/wking
	name = "White King"
	desc = "A Novelty chess piece in the image of the most important asset on the station representing a white king."
	icon_state = "w-king"

/obj/item/checker
	name = "Checker Piece"
	icon = 'icons/mob/robots.dmi'
	icon_state = "zoomba-combat-shield"
	desc = "Some sort of novelty checker piece."

/obj/item/checker/black
	name = "Black Checker"
	icon_state = "zoomba-standard"
	desc = "A Novelty checker piece in the image of a noble standard zoomba."

/obj/item/checker/blackking
	name = "Black Checker King"
	icon_state = "zoomba-combat-roll"
	desc = "A Novelty checker piece in the image of the terrifying combat zoomba."

/obj/item/checker/red
	name = "Red Checker"
	icon_state = "zoomba-security"
	desc = "A Novelty checker piece in the image of a fierce security zoomba."

/obj/item/checker/redking
	name = "Red Checker King"
	icon_state = "zoomba-crisis"
	desc = "A Novelty checker piece in the image of the awe inspiring crisis zoomba."

//Step 1: Add Gnomes. Step 2: ??? Step 3. Profit.
/obj/item/toy/gnome
	name = "lawn gnome"
	icon_state = "gnome"
	item_state = "gnome"
	desc = "A ceramic gnome statue, often used in lawn displays. For a brief while, carrying a gnome safely through hazardous areas was seen as a popular challenge."
	attack_verb = list("gnomed", "bonked", "struck")
	throw_force = 5
	throw_speed = 4
	throw_range = 7
	damage_force = 5

/obj/item/toy/gnome/giant
	name = "giant lawn gnome"
	icon_state = "gnome_giant"
	desc = "A life-sized ceramic gnome statue, often used in lawn displays. For a brief while, carrying a gnome safely through hazardous areas was seen as a popular challenge."

//Squishimals
/obj/item/toy/axi
	name = "Axiom the Axolotl Squishimal"
	icon = 'icons/obj/toy.dmi'
	icon_state = "axi"
	desc = "Axiom the Axolotl, a little blue squishimal axolotl with fluffy fringes on his external gills."

/obj/item/toy/snek
	name = "Sneki the Snake Squishimal"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snek"
	desc = "Sneki the Snake, a medium sized yellow snake squishimal with velvety ventral scales."

/obj/item/toy/pan
	name = "Pandy the Red Panda Squishimal"
	icon = 'icons/obj/toy.dmi'
	icon_state = "pan"
	desc = "Pandy the Red Panda, a large fluffy red panda squishimal with big soft ears and silky cheek fur."

/obj/item/toy/bun
	name = "Matcha the Rabbit Squishimal"
	icon = 'icons/obj/toy.dmi'
	icon_state = "bun"
	desc = "Matcha the Rabbit, a large green squishimal that faintly smells of green tea and has floppy ears."

/obj/item/toy/demon
	name = "Demi the Imp Squishimal"
	icon = 'icons/obj/toy.dmi'
	icon_state = "demon"
	desc = "Demi the Imp, a squishimal imp with scaley glittery ears and horns."

/obj/item/toy/jay
	name = "Jaymes the Bluejay Squishimal"
	icon = 'icons/obj/toy.dmi'
	icon_state = "jay"
	desc = "Jaymes the Bluejay, a smaller squishimal that looks to resemble probably someone's favorite bird. Fun fact: Bluejays are corvids!"
