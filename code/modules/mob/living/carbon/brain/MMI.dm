//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi/digital/Initialize()
	. = ..()

	src.brainmob = new(src)
	src.brainmob.set_stat(CONSCIOUS)
	src.brainmob.add_language("Robot Talk")
	src.brainmob.add_language("Encoded Audio Language")

	src.brainmob.container = src
	src.brainmob.silent = 0
	PickName()

/obj/item/device/mmi/digital/proc/PickName()
	return

/obj/item/device/mmi/digital/attackby()
	return

/obj/item/device/mmi/digital/attack_self()
	return

/obj/item/device/mmi/digital/transfer_identity(mob/living/carbon/H)
	brainmob.dna = H.dna
	brainmob.timeofhostdeath = H.timeofdeath
	brainmob.set_stat(CONSCIOUS)
	if(H.mind)
		H.mind.transfer_to(brainmob)
	return

/obj/item/device/mmi
	name = "\improper Man-Machine Interface"
	desc = "A complex life support shell that interfaces between a brain and electronic devices."
	icon = 'icons/mob/human_races/organs/mmi.dmi'
	icon_state = "mmi-empty"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_BIO = 3)

	req_access = list(access_robotics)

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.

	var/locked = 0
	var/mob/living/carbon/brain/brainmob = null //The current occupant.
	var/obj/item/organ/internal/brain/brainobj = null	//The current brain organ.
	var/obj/mecha = null //This does not appear to be used outside of reference in mecha.dm.

/obj/item/device/mmi/update_icon()
	overlays.Cut()
	if(!brainobj)
		icon_state = "mmi-empty"
		return

	icon_state = "mmi-inner"
	if(brainobj?.species)
		overlays += "mmi-[lowertext(brainobj.species.name)]"
	else
		overlays += "mmi-human"
	if(brainmob.stat == DEAD)
		overlays += "mmi-outer-dead"
	else
		overlays += "mmi-outer"

/obj/item/device/mmi/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O,/obj/item/organ/internal/brain) && !brainmob) //Time to stick a brain in it --NEO

		var/obj/item/organ/internal/brain/B = O
		if(B.damage >= B.max_damage)
			to_chat(user, SPAN("warning", "That brain is well and truly dead."))
			return
		else if(!B.brainmob || !B.can_use_mmi)
			to_chat(user, SPAN("notice", "This brain is completely useless to you."))
			return

		user.visible_message(SPAN("notice", "\The [user] sticks \a [O] into \the [src]."))

		brainmob = B.brainmob
		B.brainmob = null
		brainmob.forceMove(src)
		brainmob.container = src
		brainmob.set_stat(CONSCIOUS)
		brainmob.switch_from_dead_to_living_mob_list() //Update dem lists

		user.drop_item()
		brainobj = O
		brainobj.forceMove(src)

		SetName("[initial(name)]: ([brainmob.real_name])")
		update_icon()

		locked = 1

		feedback_inc("cyborg_mmis_filled",1)

		return

	if((istype(O,/obj/item/card/id)||istype(O,/obj/item/device/pda)) && brainmob)
		if(allowed(user))
			locked = !locked
			to_chat(user, SPAN("notice", "You [locked ? "lock" : "unlock"] the brain holder."))
		else
			to_chat(user, SPAN("warning", "Access denied."))
		return
	if(brainmob)
		O.attack(brainmob, user)
		return
	..()

	//TODO: ORGAN REMOVAL UPDATE. Make the brain remain in the MMI so it doesn't lose organ data.

/obj/item/device/mmi/attack_self(mob/user as mob)
	if(!brainmob)
		to_chat(user, SPAN("warning", "You upend the MMI, but there's nothing in it."))
	else if(locked)
		to_chat(user, SPAN("warning", "You upend the MMI, but the brain is clamped into place."))
	else
		to_chat(user, SPAN("notice", "You upend the MMI, spilling the brain onto the floor."))
		var/obj/item/organ/internal/brain/brain
		//Pull brain organ out of MMI.
		if (brainobj)
			brainobj.forceMove(user.loc)
			brain = brainobj
			brainobj = null
		//Or make a new one if empty.
		else
			brain = new(user.loc)
		brainmob.container = null //Reset brainmob mmi var.
		brainmob.loc = brain //Throw mob into brain.
		brainmob.remove_from_living_mob_list() //Get outta here
		brain.brainmob = brainmob //Set the brain to use the brainmob
		brainmob = null //Set mmi brainmob var to null

		update_icon()
		SetName(initial(name))

//Same deal as the regular brain proc. Used for human --> robot people.
/obj/item/device/mmi/proc/transfer_identity(mob/living/carbon/human/H)
	brainmob = new(src)
	brainmob.SetName(H.real_name)
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna
	brainmob.container = src

	SetName("[initial(name)]: [brainmob.real_name]")
	update_icon()
	locked = 1
	return

/obj/item/device/mmi/relaymove(mob/user, direction)
	if(user.stat || user.stunned)
		return
	var/obj/item/rig/rig = src.get_rig()
	if(rig)
		rig.forced_move(direction, user)
	if(istype(loc, /obj/item/integrated_circuit/input/mmi_tank))
		var/obj/item/integrated_circuit/input/mmi_tank/tank = loc
		tank.relaymove(user, direction)

/obj/item/device/mmi/Destroy()
	if(isrobot(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	QDEL_NULL(brainmob)
	return ..()

/obj/item/device/mmi/radio_enabled
	name = "radio-enabled man-machine interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	origin_tech = list(TECH_BIO = 4)

	var/obj/item/device/radio/radio = null//Let's give it a radio.

/obj/item/device/mmi/radio_enabled/Initialize()
	. = ..()

	radio = new(src) //Spawns a radio inside the MMI.
	radio.broadcasting = 1 //So it's broadcasting from the start.

//Allows the brain to toggle the radio functions.
/obj/item/device/mmi/radio_enabled/verb/Toggle_Broadcasting()
	set name = "Toggle Broadcasting"
	set desc = "Toggle broadcasting channel on or off."
	set category = "MMI"
	set src = usr.loc //In user location, or in MMI in this case.
	set popup_menu = 0 //Will not appear when right clicking.

	if(brainmob.stat) //Only the brainmob will trigger these so no further check is necessary.
		to_chat(brainmob, "Can't do that while incapacitated or dead.")

	radio.broadcasting = !radio.broadcasting
	to_chat(brainmob, SPAN("notice", "Radio is [radio.broadcasting ? "now" : "no longer"] broadcasting."))

/obj/item/device/mmi/radio_enabled/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = 0

	if(brainmob.stat)
		to_chat(brainmob, "Can't do that while incapacitated or dead.")

	radio.listening = !radio.listening
	to_chat(brainmob, SPAN("notice", "Radio is [radio.broadcasting ? "now" : "no longer"] receiving broadcast."))

/obj/item/device/mmi/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()
