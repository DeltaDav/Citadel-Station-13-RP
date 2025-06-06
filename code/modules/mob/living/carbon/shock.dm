/mob/living/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	if (!can_feel_pain())
		shock_stage = 0
		src.traumatic_shock = 0
		return 0

	src.traumatic_shock = 			\
	1	* src.getOxyLoss() + 		\
	0.7	* src.getToxLoss() + 		\
	max(1.25 * src.getShockFireLoss(), 2 * src.halloss) + 		\
	1	* src.getShockBruteLoss() + 		\
	1.35 * src.getCloneLoss() + 		\
	-1	* src.chem_effects[CE_PAINKILLER]

	if(src.slurring)
		src.traumatic_shock -= 20

	// broken or ripped off organs will add quite a bit of pain
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		for(var/obj/item/organ/external/organ in M.organs)
			if(organ.is_broken() || organ.open)
				src.traumatic_shock += 30
			else if(organ.is_dislocated())
				src.traumatic_shock += 15

	if(src.traumatic_shock < 0)
		src.traumatic_shock = 0

	return src.traumatic_shock


/mob/living/carbon/proc/handle_shock()
	updateshock()
