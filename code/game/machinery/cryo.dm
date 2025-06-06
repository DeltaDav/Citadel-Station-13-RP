///249840 J/K, for a 72 kg person.
// #define HEAT_CAPACITY_HUMAN 100
#define HEAT_CAPACITY_HUMAN 5
/obj/machinery/atmospherics/component/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/medical/cryogenics.dmi' // map only
	icon_state = "pod_preview"
	density = TRUE
	anchored = TRUE
	layer = UNDER_JUNK_LAYER
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_ALLOW_SILICON

	use_power = USE_POWER_IDLE
	idle_power_usage = 20
	active_power_usage = 200
	buckle_lying = FALSE
	buckle_dir = SOUTH

	var/temperature_archived
	var/mob/living/carbon/occupant = null
	var/obj/item/reagent_containers/glass/beaker = null

	var/current_heat_capacity = 50

	var/image/fluid

/obj/machinery/atmospherics/component/unary/cryo_cell/Initialize(mapload)
	icon = 'icons/obj/medical/cryogenics_split.dmi'
	icon_state = "base"
	initialize_directions = dir

	var/image/tank = image(icon,"tank")
	tank.alpha = 200
	tank.pixel_y = 18
	tank.plane = MOB_PLANE
	tank.layer = MOB_LAYER+0.2 //Above fluid
	fluid = image(icon, "tube_filler")
	fluid.pixel_y = 18
	fluid.alpha = 200
	fluid.plane = MOB_PLANE
	fluid.layer = MOB_LAYER+0.1 //Below glass, above mob

	add_overlay(tank)

	. = ..()

	// todo: duped, components update icon on init right?
	update_icon()

/obj/machinery/atmospherics/component/unary/cryo_cell/Destroy()
	var/turf/T = src.loc
	T.contents += contents
	if(beaker)
		beaker.forceMove(get_step(loc, SOUTH)) //Beaker is carefully ejected from the wreckage of the cryotube
		beaker = null
	. = ..()

/obj/machinery/atmospherics/component/unary/cryo_cell/process(delta_time)
	..()
	if(!node)
		return
	if(!on)
		return

	if(occupant)
		if(occupant.stat != 2)
			process_occupant()

	if(air_contents)
		temperature_archived = air_contents.temperature
		heat_gas_contents()
		expel_gas()
		update_icon()

	if(abs(temperature_archived-air_contents.temperature) > 1)
		network.update = TRUE

	return TRUE

/obj/machinery/atmospherics/component/unary/cryo_cell/relaymove(mob/user)
	// note that relaymove will also be called for mobs outside the cell with UI open
	if(occupant == user && !user.stat)
		go_out()

/obj/machinery/atmospherics/component/unary/cryo_cell/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	nano_ui_interact(user)

 /**
  * The nano_ui_interact proc is used to open and update Nano UIs
  * If nano_ui_interact is not used then the UI will not update correctly
  * nano_ui_interact is currently defined for /atom/movable (which is inherited by /obj and /mob)
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/atmospherics/component/unary/cryo_cell/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)

	if(user == occupant || user.stat)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? TRUE : FALSE

	var/occupantData[0]
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.getMaxHealth()
		occupantData["minHealth"] = occupant.getMinHealth()
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData;

	data["cellTemperature"] = round(air_contents.temperature)
	data["cellTemperatureStatus"] = "good"
	if(air_contents.temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(air_contents.temperature > 225)
		data["cellTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? TRUE : FALSE
	/* // Removing beaker contents list from front-end, replacing with a total remaining volume
	var beakerContents[0]
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents
	*/
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(beaker)
		data["beakerLabel"] = beaker.label_text ? beaker.label_text : null
		if(beaker.reagents)
			data["beakerVolume"] = beaker.reagents?.total_volume

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "cryo.tmpl", "Cryo Cell Control System", 520, 410)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/component/unary/cryo_cell/Topic(href, href_list)
	if(usr == occupant)
		return FALSE // don't update UIs attached to this object

	if(..())
		return FALSE // don't update UIs attached to this object

	if(href_list["switchOn"])
		on = TRUE
		update_icon()

	if(href_list["switchOff"])
		on = FALSE
		update_icon()

	if(href_list["ejectBeaker"])
		if(beaker)
			beaker.loc = get_step(src.loc, SOUTH)
			beaker = null
			update_icon()

	if(href_list["ejectOccupant"])
		if(!occupant || isslime(usr) || ispAI(usr))
			return FALSE // don't update UIs attached to this object
		go_out()

	return TRUE // update UIs attached to this object

/obj/machinery/atmospherics/component/unary/cryo_cell/attackby(obj/item/G, mob/user)
	if(istype(G, /obj/item/reagent_containers/glass))
		if(beaker)
			to_chat(user, SPAN_WARNING("A beaker is already loaded into the machine."))
			return
		if(!user.attempt_insert_item_for_installation(G, src))
			return
		beaker =  G
		user.visible_message("[user] adds \a [G] to \the [src]!", "You add \a [G] to \the [src]!")
		update_icon()

	else if(istype(G, /obj/item/grab))
		var/obj/item/grab/grab = G
		if(!ismob(grab.affecting))
			return
		if(occupant)
			to_chat(user, SPAN_WARNING("\The [src] is already occupied by [occupant]."))
		if(grab.affecting.has_buckled_mobs())
			to_chat(user, SPAN_WARNING( "\The [grab.affecting] has other entities attached to it. Remove them first."))
			return
		var/mob/M = grab.affecting
		qdel(grab)
		put_mob(M)

/obj/machinery/atmospherics/component/unary/cryo_cell/MouseDroppedOnLegacy(mob/target, mob/user) //Allows borgs to put people into cryo without external assistance
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user)|| !ishuman(target))
		return
	put_mob(target)

/obj/machinery/atmospherics/component/unary/cryo_cell/update_icon()
	. = ..()
	cut_overlay(fluid)
	fluid.color = null
	fluid.alpha = max(255 - air_contents.temperature, 50)
	if(on)
		if(beaker)
			fluid.color = beaker.reagents.get_color()
		add_overlay(fluid)

/obj/machinery/atmospherics/component/unary/cryo_cell/proc/process_occupant()
	if(air_contents.total_moles < 10)
		return
	if(occupant)
		if(occupant.stat >= DEAD)
			return
		// todo :kill bodyetmperature and rewrite it from scratch this is not real holy shit
		var/cooling_power = clamp(
			-(4 + ((occupant.nominal_bodytemperature() - occupant.bodytemperature) / BODYTEMP_AUTORECOVERY_DIVISOR)),
			(air_contents.temperature - occupant.bodytemperature),
			(air_contents.temperature - occupant.bodytemperature) * 0.5,
		)
		occupant.adjust_bodytemperature(cooling_power)
		occupant.setDir(src.dir)
		if(occupant.bodytemperature < T0C)
			occupant.afflict_sleeping(20 * max(5, (1/occupant.bodytemperature)*2000))
			occupant.afflict_unconscious(20 * max(5, (1/occupant.bodytemperature)*3000))
			if(air_contents.gas[GAS_ID_OXYGEN] > 2)
				if(occupant.getOxyLoss())
					occupant.adjustOxyLoss(-1)
			else
				occupant.adjustOxyLoss(-1)
			//severe damage should heal waaay slower without proper chemicals
			if(occupant.bodytemperature < 225)
				if(occupant.getToxLoss())
					occupant.adjustToxLoss(max(-1, -20/occupant.getToxLoss()))
				var/heal_brute = occupant.getBruteLoss() ? min(1, 20/occupant.getBruteLoss()) : 0
				var/heal_fire = occupant.getFireLoss() ? min(1, 20/occupant.getFireLoss()) : 0
				occupant.heal_organ_damage(heal_brute,heal_fire)
		var/has_cryo = occupant.reagents.get_reagent_amount("cryoxadone") >= 1
		var/has_clonexa = occupant.reagents.get_reagent_amount("clonexadone") >= 1
		var/has_cryo_medicine = has_cryo || has_clonexa
		if(beaker && !has_cryo_medicine)
			beaker.reagents.trans_to_mob(occupant, 1, CHEM_INJECT, 10)

/obj/machinery/atmospherics/component/unary/cryo_cell/proc/heat_gas_contents()
	if(air_contents.total_moles < 1)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = T20C*current_heat_capacity + air_heat_capacity*air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

/obj/machinery/atmospherics/component/unary/cryo_cell/proc/expel_gas()
	if(air_contents.total_moles < 1)
		return
//	var/datum/gas_mixture/expel_gas = new
//	var/remove_amount = air_contents.total_moles()/50
//	expel_gas = air_contents.remove(remove_amount)

	// Just have the gas disappear to nowhere.
	//expel_gas.temperature = T20C // Lets expel hot gas and see if that helps people not die as they are removed
	//loc.assume_air(expel_gas)

/obj/machinery/atmospherics/component/unary/cryo_cell/proc/go_out()
	if(!(occupant))
		return
	vis_contents -= occupant
	occupant.pixel_x = occupant.base_pixel_x
	occupant.pixel_y = occupant.base_pixel_y
	if(occupant.bodytemperature < 261 && occupant.bodytemperature >= 70) //Patch by Aranclanos to stop people from taking burn damage after being ejected
		occupant.set_bodytemperature(261)									  // Changed to 70 from 140 by Zuhayr due to reoccurance of bug.

	REMOVE_TRAIT(occupant, TRAIT_MOB_FORCED_STANDING, CRYO_TUBE_TRAIT)
	occupant.forceMove(loc)
	occupant.update_perspective()
	occupant.update_mobility() // make them rest again if needed
	occupant = null

	current_heat_capacity = initial(current_heat_capacity)
	update_use_power(USE_POWER_IDLE)
	return

/obj/machinery/atmospherics/component/unary/cryo_cell/proc/put_mob(mob/living/carbon/M as mob)
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(usr, SPAN_WARNING("The cryo cell is not functioning."))
		return
	if(!istype(M))
		to_chat(usr, SPAN_DANGER("The cryo cell cannot handle such a lifeform!"))
		return
	if(occupant)
		to_chat(usr, SPAN_DANGER("The cryo cell is already occupied!"))
		return
	if(M.abiotic())
		to_chat(usr, SPAN_WARNING("Subject may not have abiotic items on."))
		return
	if(M.buckled)
		to_chat(usr, SPAN_WARNING("[M] is buckled to something!"))
		return
	if(!node)
		to_chat(usr, SPAN_WARNING("The cell is not correctly connected to its pipe network!"))
		return
	M.forceMove(src)
	M.ExtinguishMob()
	if(!IS_DEAD(M))
		to_chat(M, SPAN_USERDANGER("You feel a cold liquid surround you. Your skin starts to freeze up."))

	occupant = M
	occupant.update_perspective()
	occupant.setDir(src.dir)
	ADD_TRAIT(occupant, TRAIT_MOB_FORCED_STANDING, CRYO_TUBE_TRAIT)
	occupant.set_resting(FALSE)
	occupant.pixel_y += 19
	vis_contents |= occupant

	current_heat_capacity = HEAT_CAPACITY_HUMAN
	update_use_power(USE_POWER_ACTIVE)
//	M.metabslow = 1
	add_fingerprint(usr)
	update_icon()
	return TRUE

/obj/machinery/atmospherics/component/unary/cryo_cell/verb/move_eject()
	set name = "Eject occupant"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)
	if(usr == occupant)//If the user is inside the tube...
		if(usr.stat == 2)//and he's not dead....
			return
		to_chat(usr, SPAN_NOTICE("Release sequence activated. This will take two minutes."))
		sleep(1200)
		if(!src || !usr || !occupant || (occupant != usr)) //Check if someone's released/replaced/bombed him already
			return
		go_out()//and release him from the eternal prison.
	else
		if(usr.stat != 0)
			return
		go_out()
	add_fingerprint(usr)
	return

/obj/machinery/atmospherics/component/unary/cryo_cell/verb/move_inside()
	set name = "Move Inside"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)
	if(isliving(usr))
		var/mob/living/L = usr
		if(L.has_buckled_mobs())
			to_chat(L, SPAN_WARNING("You have other entities attached to yourself. Remove them first."))
			return
		if(L.stat != CONSCIOUS)
			return
		put_mob(L)

/atom/proc/return_air_for_internal_lifeform(mob/living/lifeform)
	return return_air()

/obj/machinery/atmospherics/component/unary/cryo_cell/return_air_for_internal_lifeform()
	//assume that the cryo cell has some kind of breath mask or something that
	//draws from the cryo tube's environment, instead of the cold internal air.
	if(src.loc)
		return loc.return_air()
	else
		return null

/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user)
	return

/datum/data/function/proc/display()
	return
