/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 9.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 1.5
	mod_handy = 1.0
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")

/obj/item/mop/New()
	create_reagents(30)

/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(istype(A, /turf) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='notice'>Your mop is dry!</span>")
			return
		var/turf/T = get_turf(A)
		if(!T)
			return

		user.visible_message("<span class='warning'>[user] begins to clean \the [T].</span>")

		if(do_after(user, 40, T))
			if(T)
				T.clean(src, user)
			to_chat(user, "<span class='notice'>You have finished mopping!</span>")


/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	..()
