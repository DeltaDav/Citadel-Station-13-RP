//Procedures in this file: Organic limb repair
//////////////////////////////////////////////////////////////////
//						LIMB REPAIR SURGERY						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/repairflesh/
	priority = 1
	can_infect = 1
	blood_level = 1
	req_open = 1

/datum/surgery_step/repairflesh/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..()) return FALSE
	if (isslime(target))
		return 0
	if (target_zone == O_EYES || target_zone == O_MOUTH)
		return 0
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (affected == null)
		return 0
	if (affected.is_stump())
		return 0
	if (affected.robotic >= ORGAN_ROBOT)
		return 0
	return 1


//////////////////////////////////////////////////////////////////
//						SCAN STEP								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/repairflesh/scan_injury
	step_name = "Scan injury"

	allowed_tools = list(
	/obj/item/healthanalyzer = 100,
	/obj/item/atmos_analyzer = 10
	)

	priority = 2

	can_infect = 0 //The only exception here. Sweeping a scanner probably won't transfer many germs.

	min_duration = 10
	max_duration = 20

/datum/surgery_step/repairflesh/scan_injury/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(affected.burn_stage || affected.brute_stage)
			return 0
		return 1
	return 0

/datum/surgery_step/repairflesh/scan_injury/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] begins scanning [target]'s [affected] with \the [tool].</span>", \
	"<span class='notice'>You begin scanning [target]'s [affected] with \the [tool].</span>")
	..()

/datum/surgery_step/repairflesh/scan_injury/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] finishes scanning [target]'s [affected].</span>", \
	"<span class='notice'>You finish scanning [target]'s [affected].</span>")
	if(affected.brute_dam)
		to_chat(user, "<span class='notice'>The muscle in [target]'s [affected] is notably bruised.</span>")
		if(affected.status & ORGAN_BROKEN)
			to_chat(user, "<span class='warning'>\The [target]'s [affected] is broken!</span>")
		affected.brute_stage = max(1, affected.brute_stage)
	if(affected.burn_dam)
		to_chat(user, "<span class='notice'>\The muscle in [target]'s [affected] is notably charred.</span>")
		affected.burn_stage = max(1, affected.burn_stage)

/datum/surgery_step/repairflesh/scan_injury/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, dropping \the [tool] onto [target]'s [affected]!</span>" , \
	"<span class='warning'>Your hand slips, dropping \the [tool] onto [target]'s [affected]!</span>" )
	affected.create_wound(WOUND_TYPE_BRUISE, 10)

//////////////////////////////////////////////////////////////////
//						BURN STEP								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/repairflesh/repair_burns
	step_name = "Reconstruct skin"

	allowed_tools = list(
	/obj/item/stack/medical/advanced/ointment = 100,
	/obj/item/surgical/FixOVein = 100,
	/obj/item/surgical/hemostat = 60,
	/obj/item/stack/medical/ointment = 50,
	/obj/item/surgical/hemostat_primitive = 40,
	)

	priority = 3

	min_duration = 20
	max_duration = 20

/datum/surgery_step/repairflesh/repair_burns/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(affected.burn_stage < 1 || !(affected.burn_dam))
			return 0
		return 1
	return 0

/datum/surgery_step/repairflesh/repair_burns/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(istype(tool, /obj/item/duct_tape_roll) || istype(tool, /obj/item/barrier_tape_roll))
		user.visible_message("<span class='warning'>[user] begins taping up [target]'s [affected] with \the [tool].</span>", \
	"<span class='notice'>You begin taping up [target]'s [affected] with \the [tool].</span>")
		affected.jostle_bone(10)
	else if(istype(tool, /obj/item/surgical/hemostat) || istype(tool, /obj/item/surgical/FixOVein))
		user.visible_message("<span class='notice'>[user] begins mending the charred blood vessels in [target]'s [affected] with \the [tool].</span>", \
	"<span class='notice'>You begin mending the charred blood vessels in [target]'s [affected] with \the [tool].</span>")
	else
		user.visible_message("<span class='notice'>[user] begins coating the charred tissue in [target]'s [affected] with \the [tool].</span>", \
	"<span class='notice'>You begin coating the charred tissue in [target]'s [affected] with \the [tool].</span>")
	..()

/datum/surgery_step/repairflesh/repair_burns/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(istype(tool, /obj/item/duct_tape_roll) || istype(tool, /obj/item/barrier_tape_roll))
		user.visible_message("<span class='notice'>[user] finishes taping up [target]'s [affected] with \the [tool].</span>", \
	"<span class='notice'>You finish taping up [target]'s [affected] with \the [tool].</span>")
		affected.create_wound(WOUND_TYPE_BRUISE, 10)
	affected.heal_damage(0, 25, 0, 0)
	if(!(affected.burn_dam))
		affected.burn_stage = 0
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/T = tool
		T.use(1)
	..()

/datum/surgery_step/repairflesh/repair_burns/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='danger'>[user]'s hand slips, tearing up [target]'s [affected] with \the [tool].</span>", \
	"<span class='danger'>Your hand slips, tearing up [target]'s [affected] with \the [tool].</span>")
	affected.create_wound(WOUND_TYPE_BRUISE, 10)
	affected.create_wound(WOUND_TYPE_CUT, 5)
	if(istype(tool, /obj/item/stack) && prob(30))
		var/obj/item/stack/T = tool
		T.use(1)
	..()

//////////////////////////////////////////////////////////////////
//						BRUTE STEP								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/repairflesh/repair_brute
	step_name = "Repair skin"

	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack = 100,
	/obj/item/surgical/cautery = 100,
	/obj/item/surgical/cautery_primitive = 70,
	/obj/item/surgical/bonesetter = 60,
	/obj/item/stack/medical/bruise_pack = 50,
	/obj/item/surgical/bonesetter_primitive = 50,
	/obj/item/duct_tape_roll = 40,
	/obj/item/barrier_tape_roll = 10
	)

	priority = 3

	min_duration = 20
	max_duration = 20

/datum/surgery_step/repairflesh/repair_brute/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(affected.brute_stage < 1 || !(affected.brute_dam))
			return 0
		return 1
	return 0

/datum/surgery_step/repairflesh/repair_brute/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(istype(tool, /obj/item/duct_tape_roll) || istype(tool, /obj/item/barrier_tape_roll))
		user.visible_message("<span class='warning'>[user] begins taping up [target]'s [affected] with \the [tool].</span>", \
	"<span class='notice'>You begin taping up [target]'s [affected] with \the [tool].</span>")
		affected.jostle_bone(10)
	else if(istype(tool, /obj/item/surgical/FixOVein) || istype(tool, /obj/item/surgical/bonesetter) || istype(tool, /obj/item/surgical/bonesetter_primitive))
		user.visible_message("<span class='notice'>[user] begins mending the torn tissue in [target]'s [affected] with \the [tool].</span>", \
	"<span class='notice'>You begin mending the torn tissue in [target]'s [affected] with \the [tool].</span>")
	else
		user.visible_message("<span class='notice'>[user] begins coating the tissue in [target]'s [affected] with \the [tool].</span>", \
	"<span class='notice'>You begin coating the tissue in [target]'s [affected] with \the [tool].</span>")
	..()

/datum/surgery_step/repairflesh/repair_brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(istype(tool, /obj/item/duct_tape_roll) || istype(tool, /obj/item/barrier_tape_roll))
		user.visible_message("<span class='notice'>[user] finishes taping up [target]'s [affected] with \the [tool].</span>", \
	"<span class='notice'>You finish taping up [target]'s [affected] with \the [tool].</span>")
		affected.create_wound(WOUND_TYPE_BRUISE, 10)
	affected.heal_damage(25, 0, 0, 0)
	if(!(affected.brute_dam))
		affected.brute_stage = 0
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/T = tool
		T.use(1)
	..()

/datum/surgery_step/repairflesh/repair_brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='danger'>[user]'s hand slips, tearing up [target]'s [affected] with \the [tool].</span>", \
	"<span class='danger'>Your hand slips, tearing up [target]'s [affected] with \the [tool].</span>")
	affected.create_wound(WOUND_TYPE_BRUISE, 10)
	affected.create_wound(WOUND_TYPE_CUT, 5)
	if(istype(tool, /obj/item/stack) && prob(30))
		var/obj/item/stack/T = tool
		T.use(1)
	..()
