//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////
// Internal Bleeding Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/fix_vein
	step_name = "Fix vein"

	priority = 2
	allowed_tools = list(
	/obj/item/surgical/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..()) return FALSE
	if(!hasorgans(target))
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected) return
	var/internal_bleeding = 0
	for(var/datum/wound/W as anything in affected.wounds)
		if(W.internal)
			internal_bleeding = 1
			break

	return affected.open == (affected.encased ? 3 : 2) && internal_bleeding

/datum/surgery_step/fix_vein/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts patching the damaged vein in [target]'s [affected.name] with \the [tool]." , \
	"You start patching the damaged vein in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("The pain in [affected.name] is unbearable!", 100)
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color=#4F49AF>[user] has patched the damaged vein in [target]'s [affected.name] with \the [tool].</font>", \
		"<font color=#4F49AF>You have patched the damaged vein in [target]'s [affected.name] with \the [tool].</font>")

	var/cured = FALSE
	for(var/datum/wound/W as anything in affected.wounds)
		if(!W.internal)
			continue
		cured = TRUE
		affected.cure_exact_wound(W)
	if(cured)
		affected.update_damages()

	if (ishuman(user) && prob(40))
		var/mob/living/carbon/human/H = user
		H.bloody_hands(target, 0)

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</font>" , \
	"<font color='red'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</font>")
	affected.inflict_bodypart_damage(
		brute = 5,
	)

///////////////////////////////////////////////////////////////
// Necrosis Surgery Step 1
///////////////////////////////////////////////////////////////
/datum/surgery_step/fix_dead_tissue        //Debridement
	step_name = "Debride tissue"

	priority = 2
	allowed_tools = list(
		/obj/item/surgical/scalpel = 100,        \
		/obj/item/surgical/scalpel_bronze = 90,	\
		/obj/item/surgical/scalpel_primitive = 80,	\
		/obj/item/material/knife = 75,    \
		/obj/item/material/shard = 50,         \
	)

	can_infect = 1
	blood_level = 1

	min_duration = 110
	max_duration = 160

/datum/surgery_step/fix_dead_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return 0

	if (target_zone == O_MOUTH || target_zone == O_EYES)
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	return affected && affected.open >= 2 && (affected.status & ORGAN_DEAD)

/datum/surgery_step/fix_dead_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts cutting away necrotic tissue in [target]'s [affected.name] with \the [tool]." , \
	"You start cutting away necrotic tissue in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("The pain in [affected.name] is unbearable!", 100)
	..()

/datum/surgery_step/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color=#4F49AF>[user] has cut away necrotic tissue in [target]'s [affected.name] with \the [tool].</font>", \
		"<font color=#4F49AF>You have cut away necrotic tissue in [target]'s [affected.name] with \the [tool].</font>")
	affected.open = 3

/datum/surgery_step/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</font>", \
	"<font color='red'>Your hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</font>")
	affected.create_wound(WOUND_TYPE_CUT, 20, 1)

///////////////////////////////////////////////////////////////
// Necrosis Surgery Step 2
///////////////////////////////////////////////////////////////
/datum/surgery_step/treat_necrosis
	step_name = "Treat necrosis"

	priority = 2
	allowed_tools = list(
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/glass/bottle = 75,
		/obj/item/reagent_containers/glass/beaker = 75,
		/obj/item/reagent_containers/spray = 50,
		/obj/item/reagent_containers/glass/bucket = 50,
	)

	can_infect = 0
	blood_level = 0

	min_duration = 50
	max_duration = 60

/datum/surgery_step/treat_necrosis/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!istype(tool, /obj/item/reagent_containers))
		return 0

	var/obj/item/reagent_containers/container = tool
	if(!container.reagents.has_reagent("peridaxon"))
		return 0

	if(!hasorgans(target))
		return 0

	if (target_zone == O_MOUTH || target_zone == O_EYES)
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.open == 3 && (affected.status & ORGAN_DEAD)

/datum/surgery_step/treat_necrosis/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts applying medication to the affected tissue in [target]'s [affected.name] with \the [tool]." , \
	"You start applying medication to the affected tissue in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!", 50)
	..()

/datum/surgery_step/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if (!istype(tool, /obj/item/reagent_containers))
		return

	var/obj/item/reagent_containers/container = tool

	var/trans = container.reagents.trans_to_mob(target, container.amount_per_transfer_from_this, CHEM_INJECT) //technically it's contact, but the reagents are being applied to internal tissue
	if (trans > 0)
		affected.status &= ~ORGAN_DEAD
		affected.owner.update_icons_body()

		user.visible_message("<font color=#4F49AF>[user] applies [trans] units of the solution to affected tissue in [target]'s [affected.name].</font>", \
			"<font color=#4F49AF>You apply [trans] units of the solution to affected tissue in [target]'s [affected.name] with \the [tool].</font>")

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if (!istype(tool, /obj/item/reagent_containers))
		return

	var/obj/item/reagent_containers/container = tool

	var/trans = container.reagents.trans_to_mob(target, container.amount_per_transfer_from_this, CHEM_INJECT)

	user.visible_message("<font color='red'>[user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!</font>" , \
	"<font color='red'>Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!</font>")

	//no damage or anything, just wastes medicine

///////////////////////////////////////////////////////////////
// Hardsuit Removal Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/hardsuit
	step_name = "Remove hardsuit"

	allowed_tools = list(
		/obj/item/weldingtool = 80,
		/obj/item/surgical/circular_saw = 60,
		/obj/item/surgical/saw_bronze = 30,
		/obj/item/surgical/saw_primitive = 25,
		/obj/item/pickaxe/plasmacutter = 100
		)
	req_open = 0

	can_infect = 0
	blood_level = 0

	min_duration = 120
	max_duration = 180

/datum/surgery_step/hardsuit/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!istype(target))
		return 0
	if(istype(tool,/obj/item/weldingtool))
		var/obj/item/weldingtool/welder = tool
		if(!welder.isOn() || !welder.remove_fuel(1,user))
			return 0
	if(!(target_zone == BP_TORSO))
		return FALSE
	var/obj/item/hardsuit/R = target.get_hardsuit(TRUE)
	if(!R)
		return FALSE
	return TRUE

/datum/surgery_step/hardsuit/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/hardsuit/hardsuit = target.get_hardsuit(TRUE)
	user.visible_message("[user] starts cutting through the support systems of \the [hardsuit] on [target] with \the [tool]." , \
	"You start cutting through the support systems of \the [hardsuit] on [target] with \the [tool].")
	..()

/datum/surgery_step/hardsuit/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/hardsuit/hardsuit = target.get_hardsuit(TRUE)
	hardsuit.reset()
	user.visible_message("<span class='notice'>[user] has cut through the support systems of \the [hardsuit] on [target] with \the [tool].</span>", \
		"<span class='notice'>You have cut through the support systems of \the [hardsuit] on [target] with \the [tool].</span>")

/datum/surgery_step/hardsuit/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='danger'>[user]'s [tool] can't quite seem to get through the metal...</span>", \
	"<span class='danger'>\The [tool] can't quite seem to get through the metal. It's weakening, though - try again.</span>")

/datum/surgery_status/
	var/dehusk = 0

///////////////////////////////////////////////////////////////
// Dehusking Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/dehusk/
	priority = 1
	can_infect = 0
	blood_level = 1

/datum/surgery_step/dehusk/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (!affected || (affected.robotic >= ORGAN_ROBOT))
		return 0
	return target_zone == BP_TORSO && (MUTATION_HUSK in target.mutations)

/datum/surgery_step/dehusk/structinitial
	step_name = "Create mesh"

	allowed_tools = list(
		/obj/item/surgical/bioregen = 100
	)
	min_duration = 90
	max_duration = 120

/datum/surgery_step/dehusk/structinitial/can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.dehusk == 0

/datum/surgery_step/dehusk/structinitial/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] begins to create a fleshy but rigid looking mesh over gaps in [target]'s flesh with \the [tool].</span>", \
	"<span class='notice'>You begin to create a fleshy but rigid looking mesh over gaps in [target]'s flesh with \the [tool].</span>")
	..()

/datum/surgery_step/dehusk/structinitial/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] creates a fleshy but rigid looking mesh over gaps in [target]'s flesh with \the [tool].</span>", \
	"<span class='notice'>You create a fleshy but rigid looking mesh over gaps in [target]'s flesh with \the [tool].</span>")
	target.op_stage.dehusk = 1
	..()

/datum/surgery_step/dehusk/structinitial/fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='danger'>[user]'s hand slips, and the mesh falls, with \the [tool] scraping [target]'s body.</span>", \
	"<span class='danger'>Your hand slips, and the mesh falls, with \the [tool] scraping [target]'s body.</span>")
	affected.create_wound(WOUND_TYPE_CUT, 15)
	affected.create_wound(WOUND_TYPE_BRUISE, 10)
	..()

/datum/surgery_step/dehusk/relocateflesh
	step_name = "Relocate flesh"

	allowed_tools = list(
		/obj/item/surgical/hemostat = 100,	\
		/obj/item/stack/cable_coil = 75, 	\
		/obj/item/surgical/hemostat_primitive = 50, \
		/obj/item/assembly/mousetrap = 20
	)
	min_duration = 90
	max_duration = 120

/datum/surgery_step/dehusk/relocateflesh/can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.dehusk == 1

/datum/surgery_step/dehusk/relocateflesh/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] begins to relocate some of [target]'s flesh with \the [tool], using it to fill in gaps.</span>", \
	"<span class='notice'>You begin to relocate some of [target]'s flesh with \the [tool], using it to fill in gaps.</span>")
	..()

/datum/surgery_step/dehusk/relocateflesh/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] relocates some of [target]'s flesh with \the [tool], using it to fill in gaps.</span>", \
	"<span class='notice'>You relocate some of [target]'s flesh with \the [tool], using it to fill in gaps.</span>")
	target.op_stage.dehusk = 2
	..()

/datum/surgery_step/dehusk/relocateflesh/fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='danger'>[user] accidentally rips a massive chunk out of [target]'s flesh with \the [tool], causing massive damage.</span>", \
	"<span class='danger'>You accidentally rip a massive chunk out of [target]'s flesh with \the [tool], causing massive damage.</span>")
	affected.create_wound(WOUND_TYPE_CUT, 25)
	affected.create_wound(WOUND_TYPE_BRUISE, 10)
	..()

/datum/surgery_step/dehusk/structfinish
	step_name = "Finish structure"

	allowed_tools = list(
		/obj/item/surgical/bioregen = 100, \
		/obj/item/surgical/FixOVein = 30
	)
	min_duration = 90
	max_duration = 120

/datum/surgery_step/dehusk/structfinish/can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.dehusk == 2

/datum/surgery_step/dehusk/structfinish/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(istype(tool,/obj/item/surgical/bioregen))
		user.visible_message("<span class='notice'>[user] begins to recreate blood vessels and fill in the gaps in [target]'s flesh with \the [tool].</span>", \
	"<span class='notice'>You begin to recreate blood vessels and fill in the gaps in [target]'s flesh with \the [tool].</span>")
	else if(istype(tool,/obj/item/surgical/FixOVein))
		user.visible_message("<span class='notice'>[user] attempts to recreate blood vessels and fill in the gaps in [target]'s flesh with \the [tool].</span>", \
	"<span class='notice'>You attempt to recreate blood vessels and fill in the gaps in [target]'s flesh with \the [tool].</span>")
	..()

/datum/surgery_step/dehusk/structfinish/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] finishes recreating the missing biological structures and filling in gaps in [target]'s flesh with \the [tool].</span>", \
	"<span class='notice'>You finish recreating the missing biological structures and filling in gaps in [target]'s flesh with \the [tool].</span>")
	target.op_stage.dehusk = 0
	target.mutations.Remove(MUTATION_HUSK)
	target.update_icons_body()
	..()

/datum/surgery_step/dehusk/structfinish/fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(istype(tool,/obj/item/surgical/bioregen))
		user.visible_message("<span class='danger'>[user]'s hand slips, causing \the [tool] to scrape [target]'s body.</span>", \
	"<span class='danger'>Your hand slips, causing \the [tool] to scrape [target]'s body.</span>")
	else if(istype(tool,/obj/item/surgical/FixOVein))
		user.visible_message("<span class='danger'>[user] fails to finish the structure over the gaps in [target]'s flesh, doing more damage than good.</span>", \
	"<span class='danger'>You fail to finish the structure over the gaps in [target]'s flesh, doing more damage than good.</span>")
	affected.create_wound(WOUND_TYPE_CUT, 15)
	affected.create_wound(WOUND_TYPE_BRUISE, 10)
	..()

///////////////////////////////////////////////////////////////
// Detoxify Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/internal/detoxify
	step_name = "Detoxify"

	blood_level = 1
	allowed_tools = list(/obj/item/surgical/bioregen=100)
	min_duration = 90
	max_duration = 120

/datum/surgery_step/internal/detoxify/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == BP_TORSO && (target.toxloss > 25 || target.oxyloss > 25)

/datum/surgery_step/internal/detoxify/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] begins to pull toxins from, and restore oxygen to [target]'s musculature and organs with \the [tool].</span>", \
	"<span class='notice'>You begin to pull toxins from, and restore oxygen to [target]'s musculature and organs with \the [tool].</span>")
	..()

/datum/surgery_step/internal/detoxify/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] finishes pulling toxins from, and restoring oxygen to [target]'s musculature and organs with \the [tool].</span>", \
	"<span class='notice'>You finish pulling toxins from, and restoring oxygen to [target]'s musculature and organs with \the [tool].</span>")
	if(target.toxloss>25)
		target.adjustToxLoss(-20)
	if(target.oxyloss>25)
		target.adjustOxyLoss(-20)
	..()

/datum/surgery_step/internal/detoxify/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='danger'>[user]'s hand slips, failing to finish the surgery, and damaging [target] with \the [tool].</span>", \
	"<span class='danger'>Your hand slips, failing to finish the surgery, and damaging [target] with \the [tool].</span>")
	affected.create_wound(WOUND_TYPE_CUT, 15)
	affected.create_wound(WOUND_TYPE_BRUISE, 10)
	..()
