#define ATMOS_CATEGORY 0
#define DISPOSALS_CATEGORY 1
#define TRANSIT_CATEGORY 2

#define BUILD_MODE (1<<0)
#define WRENCH_MODE (1<<1)
#define DESTROY_MODE (1<<2)
#define PAINT_MODE (1<<3)

/obj/item/pipe_dispenser
	name = "Rapid Piping Device (RPD)"
	desc = "A device used to rapidly pipe things."
	icon = 'icons/obj/tools_vr.dmi'
	icon_state = "rpd"
	item_state = "rpd"
	item_icons = list(
		SLOT_ID_LEFT_HAND = 'icons/mob/items/lefthand.dmi',
		SLOT_ID_RIGHT_HAND = 'icons/mob/items/righthand.dmi',
	)
	item_flags = ITEM_NO_BLUDGEON | ITEM_ENCUMBERS_WHILE_HELD
	damage_force = 10
	throw_force = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_BELT
	materials_base = list(MAT_STEEL = 20000, MAT_GLASS = 10000)
	///Sparks system used when changing device in the UI
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	///Direction of the device we are going to spawn, set up in the UI
	var/p_dir = NORTH
	///Initial direction of the smart pipe we are going to spawn, set up in the UI
	var/p_init_dir = ALL_CARDINALS
	///Is the device of the flipped type?
	var/p_flipped = FALSE
	///Color of the device we are going to spawn
	var/paint_color = "grey"
	///Category currently active (Atmos, disposal, transit)
	var/category = ATMOS_CATEGORY
	///Piping layer we are going to spawn the atmos device in
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/obj/item/tool/wrench/tool
	///Stores the current device to spawn
	var/datum/pipe_info/recipe
	///Stores the first atmos device
	var/static/datum/pipe_info/first_atmos
	///Stores the first disposal device
	var/static/datum/pipe_info/first_disposal
	///Stores the first transit device
	//var/static/datum/pipe_info/first_transit
	///The modes that are allowed for the RPD
	var/mode = BUILD_MODE | DESTROY_MODE | WRENCH_MODE //| REPROGRAM_MODE
	var/static/list/pipe_layers = list(
		"Regular" = PIPING_LAYER_REGULAR,
		"Supply" = PIPING_LAYER_SUPPLY,
		"Scrubber" = PIPING_LAYER_SCRUBBER,
		"Fuel" = PIPING_LAYER_FUEL,
		"Aux" = PIPING_LAYER_AUX
	)

/obj/item/pipe_dispenser/Initialize(mapload)
	. = ..()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	tool = new /obj/item/tool/wrench/cyborg(src)

/obj/item/pipe_dispenser/proc/SetupPipes()
	if(!first_atmos)
		first_atmos = GLOB.atmos_pipe_recipes[GLOB.atmos_pipe_recipes[1]][1]
	if(!first_disposal)
		first_disposal = GLOB.disposal_pipe_recipes[GLOB.disposal_pipe_recipes[1]][1]
	//if(!first_transit)
	//	first_transit = GLOB.transit_tube_recipes[GLOB.transit_tube_recipes[1]][1]
	if(!recipe)
		recipe = first_atmos

/obj/item/pipe_dispenser/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(tool)
	return ..()

/obj/item/pipe_dispenser/examine(mob/user, dist)
	. = ..()
	. += "You can scroll your mouse wheel to change the piping layer."

/obj/item/pipe_dispenser/equipped(mob/user, slot, flags)
	. = ..()
	if(slot == SLOT_ID_HANDS)
		RegisterSignal(user, COMSIG_MOUSE_SCROLL_ON, PROC_REF(mouse_wheeled))
	else
		UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)

/obj/item/pipe_dispenser/unequipped(mob/user, slot, flags)
	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
	return ..()

///obj/item/pipe_dispenser/cyborg_unequip(mob/user)
//	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
//	return ..()

/obj/item/pipe_dispenser/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/item/pipe_dispenser/ui_asset_injection(datum/tgui/ui, list/immediate, list/deferred)
	immediate += /datum/asset_pack/spritesheet/pipes
	return ..()

/obj/item/pipe_dispenser/ui_state()
	return GLOB.inventory_state

/obj/item/pipe_dispenser/ui_interact(mob/user, datum/tgui/ui)
	SetupPipes()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RapidPipeDispenser", name)
		ui.open()

/obj/item/pipe_dispenser/ui_static_data(mob/user, datum/tgui/ui)
	var/list/data = list("paint_colors" = GLOB.pipe_paint_colors)
	return data

/obj/item/pipe_dispenser/ui_data(mob/user, datum/tgui/ui)
	var/list/data = list(
		"category" = category,
		"piping_layer" = piping_layer,
		//"ducting_layer" = ducting_layer,
		"preview_rows" = recipe.get_preview(p_dir),
		"categories" = list(),
		"selected_color" = paint_color,
		"mode" = mode
	)

	var/list/recipes
	switch(category)
		if(ATMOS_CATEGORY)
			recipes = GLOB.atmos_pipe_recipes
		if(DISPOSALS_CATEGORY)
			recipes = GLOB.disposal_pipe_recipes
		//if(TRANSIT_CATEGORY)
		//	recipes = GLOB.transit_tube_recipes
	for(var/c in recipes)
		var/list/cat = recipes[c]
		var/list/r = list()
		for(var/i in 1 to cat.len)
			var/datum/pipe_info/info = cat[i]
			r += list(list("pipe_name" = info.name, "pipe_index" = i, "selected" = (info == recipe), "all_layers" = info.all_layers))
		data["categories"] += list(list("cat_name" = c, "recipes" = r))

	var/list/init_directions = list("north" = FALSE, "south" = FALSE, "east" = FALSE, "west" = FALSE)
	for(var/direction in ALL_CARDINALS)
		if(p_init_dir & direction)
			init_directions[dir2text(direction)] = TRUE
	data["init_directions"] = init_directions
	return data

/obj/item/pipe_dispenser/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!CHECK_MOBILITY(usr, MOBILITY_CAN_USE) || !in_range(loc, usr))
		return TRUE
	var/playeffect = TRUE
	switch(action)
		if("color")
			paint_color = params["paint_color"]
		if("category")
			category = text2num(params["category"])
			switch(category)
				if(DISPOSALS_CATEGORY)
					recipe = first_disposal
				if(ATMOS_CATEGORY)
					recipe = first_atmos
				//if(TRANSIT_CATEGORY)
				//	recipe = first_transit
			p_dir = NORTH
			playeffect = FALSE
		if("piping_layer")
			piping_layer = text2num(params["piping_layer"])
			playeffect = FALSE
		//if("ducting_layer")
		//	ducting_layer = text2num(params["ducting_layer"])
		//	playeffect = FALSE
		if("pipe_type")
			var/static/list/recipes
			if(!recipes)
				recipes = GLOB.disposal_pipe_recipes + GLOB.atmos_pipe_recipes //+ GLOB.transit_tube_recipes
			recipe = recipes[params["category"]][text2num(params["pipe_type"])]
			p_dir = NORTH
		if("setdir")
			p_dir = text2dir(params["dir"])
			p_flipped = text2num(params["flipped"])
			playeffect = FALSE
		if("mode")
			var/n = text2num(params["mode"])
			mode ^= n
		if("init_dir_setting")
			var/target_dir = p_init_dir ^ text2dir(params["dir_flag"])
			// Refuse to create a smart pipe that can only connect in one direction (it would act weirdly and lack an icon)
			if (ISNOTSTUB(target_dir))
				p_init_dir = target_dir
			else
				to_chat(usr, SPAN_WARNING("\The [src]'s screen flashes a warning: Can't configure a pipe to only connect in one direction."))
				playeffect = FALSE
		if("init_reset")
			p_init_dir = ALL_CARDINALS
	if(playeffect)
		spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, FALSE)
	return TRUE

/obj/item/pipe_dispenser/afterattack(atom/target, mob/user, clickchain_flags, list/params)
	if(!user.IsAdvancedToolUser() || istype(target, /turf/space/transit) || !(clickchain_flags & CLICKCHAIN_HAS_PROXIMITY))
		return ..()

	//So that changing the menu settings doesn't affect the pipes already being built.
	var/queued_piping_layer = piping_layer
	var/queued_p_dir = p_dir
	var/queued_p_flipped = p_flipped

	//Make sure what we're clicking is valid for the current mode
	var/static/list/make_pipe_whitelist
	if(!make_pipe_whitelist)
		make_pipe_whitelist = typecacheof(list(/obj/structure/lattice, /obj/structure/girder, /obj/item/pipe))
	var/can_make_pipe = (isturf(target) || is_type_in_typecache(target, make_pipe_whitelist))

	var/can_destroy_pipe = istype(target, /obj/item/pipe) || istype(target, /obj/item/pipe_meter) || istype(target, /obj/structure/disposalconstruct)

	. = TRUE
	if((mode & DESTROY_MODE) && can_destroy_pipe)
		to_chat(user, SPAN_NOTICE("You start destroying a pipe..."))
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, 2, target = target))
			activate()
			animate_deletion(target)
		return

	//Painting pipes
	if((mode & PAINT_MODE))
		if(istype(target, /obj/machinery/atmospherics/pipe))
			var/obj/machinery/atmospherics/pipe/P = target
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			P.change_color(pipe_colors[paint_color])
			user.visible_message(SPAN_NOTICE("[user] paints \the [P] [paint_color]."), SPAN_NOTICE("You paint \the [P] [paint_color]."))
			return

	//Making pipes
	if(mode & BUILD_MODE)
		switch(category)
			if(ATMOS_CATEGORY)
				if(!can_make_pipe)
					return ..()
				playsound(src, 'sound/machines/click.ogg', 50, 1)
				if(istype(recipe, /datum/pipe_info/meter))
					to_chat(user, SPAN_NOTICE("You start building a meter..."))
					if(do_after(user, 2, target = target))
						activate()
						var/obj/item/pipe_meter/PM = new /obj/item/pipe_meter(get_turf(target))
						PM.setAttachLayer(queued_piping_layer)
						if(mode & WRENCH_MODE)
							do_wrench(PM, user)
				else if(istype(recipe, /datum/pipe_info/pipe))
					if(recipe.all_layers == FALSE && (piping_layer == 1 || piping_layer == 5))
						to_chat(user, SPAN_NOTICE("You can't build this object on the layer..."))
						return ..()
					else
						var/datum/pipe_info/pipe/R = recipe
						to_chat(user, SPAN_NOTICE("You start building a pipe..."))
						if(do_after(user, 2, target = target))
							if(recipe.all_layers == FALSE && (piping_layer == 1 || piping_layer == 5))//double check to stop cheaters (and to not waste time waiting for something that can't be placed)
								to_chat(user, SPAN_NOTICE("You can't build this object on the layer..."))
								return ..()
							activate()
							var/obj/machinery/atmospherics/path = R.pipe_type
							var/pipe_item_type = initial(path.construction_type) || /obj/item/pipe
							var/obj/item/pipe/P = new pipe_item_type(get_turf(target), path, queued_p_dir)

							P.update()
							P.add_fingerprint(usr)
							if(R.paintable)
								P.color = pipe_colors[paint_color]
							P.setPipingLayer(queued_piping_layer)
							if(queued_p_flipped)
								P.do_a_flip()
							if(mode & WRENCH_MODE)
								do_wrench(P, user)
							else
								build_effect(P)

			//Making disposals pipes
			if(DISPOSALS_CATEGORY)
				var/datum/pipe_info/disposal/R = recipe
				if(!istype(R) || !can_make_pipe)
					return ..()
				target = get_turf(target)
				if(istype(target, /turf/unsimulated))
					to_chat(user, SPAN_WARNING("[src]'s error light flickers; there's something in the way!"))
					return
				to_chat(user, SPAN_NOTICE("You start building a disposals pipe..."))
				playsound(src, 'sound/machines/click.ogg', 50, 1)
				if(do_after(user, 4, target = target))
					var/obj/structure/disposalconstruct/C = new(target, R.pipe_type, queued_p_dir, queued_p_flipped, R.subtype)

					if(!C.can_place())
						to_chat(user, SPAN_WARNING("There's not enough room to build that here!"))
						qdel(C)
						return

					activate()

					C.add_fingerprint(usr)
					C.update_icon()
					if(mode & WRENCH_MODE)
						do_wrench(C, user)
					else
						build_effect(C)

			else
				return ..()

/obj/item/pipe_dispenser/proc/build_effect(var/obj/P, var/time = 1.5)
	set waitfor = FALSE
	P.filters += filter(type = "angular_blur", size = 30)
	animate(P.filters[P.filters.len], size = 0, time = time)
	var/outline = filter(type = "outline", size = 1, color = "#22AAFF")
	P.filters += outline
	sleep(time)
	P.filters -= outline
	P.filters -= filter(type = "angular_blur", size = 0)

/obj/item/pipe_dispenser/proc/animate_deletion(var/obj/P, var/time = 1.5)
	set waitfor = FALSE
	P.filters += filter(type = "angular_blur", size = 0)
	animate(P.filters[P.filters.len], size = 30, time = time)
	sleep(time)
	if(!QDELETED(P))
		P.filters -= filter(type = "angular_blur", size = 30)
		qdel(P)

/obj/item/pipe_dispenser/proc/activate()
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)

/obj/item/pipe_dispenser/proc/do_wrench(var/atom/target, mob/user)
	tool.melee_interaction_chain(target, user, CLICKCHAIN_HAS_PROXIMITY)

/obj/item/pipe_dispenser/proc/mouse_wheeled(mob/user, atom/A, delta_x, delta_y, params)
	SIGNAL_HANDLER
	if(user.incapacitated(INCAPACITATION_RESTRAINED))
		return

	if(delta_y < 0)
		piping_layer = min(PIPING_LAYER_MAX, piping_layer + 1)
	else if(delta_y > 0)
		piping_layer = max(PIPING_LAYER_MIN, piping_layer - 1)
	else
		return
	SStgui.update_uis(src)
	to_chat(user, SPAN_NOTICE("You set the layer to [piping_layer]."))

#undef ATMOS_CATEGORY
#undef DISPOSALS_CATEGORY
#undef TRANSIT_CATEGORY

#undef BUILD_MODE
#undef WRENCH_MODE
#undef DESTROY_MODE
#undef PAINT_MODE
