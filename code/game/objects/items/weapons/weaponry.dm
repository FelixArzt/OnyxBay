/obj/item/nullrod
	name = "null sceptre"
	desc = "A sceptre of pure black obsidian capped at both ends with silver ferrules. Some religious groups claim it disrupts and dampens the powers of paranormal phenomenae."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "nullrod"
	item_state = "nullrod"
	slot_flags = SLOT_BELT
	force = 11.5
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.2
	mod_reach = 0.75
	mod_handy = 1.0

/obj/item/nullrod/attack(mob/M, mob/living/user)
	admin_attack_log(user, M, "Attacked using \a [src]", "Was attacked with \a [src]", "used \a [src] to attack")

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(M)
	if(M.mind && LAZYLEN(M.mind.learned_spells))
		M.silence_spells(30 SECONDS)
		to_chat(M, SPAN_DANGER("You've been silenced!"))
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, SPAN_WARNING("You don't have the dexterity to do this!</span>"))
		return

	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN_DANGER("The rod slips out of your hand and hits your head."))
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

	if(GLOB.cult && iscultist(M))
		M.visible_message(SPAN_NOTICE("\The [user] waves \the [src] over \the [M]'s head."))
		GLOB.cult.remove_antagonist(usr.mind, 1)
		return

	..()

/obj/item/nullrod/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return

	if(istype(A, /turf/simulated/wall/cult))
		var/turf/simulated/wall/cult/W = A
		user.visible_message(SPAN("notice", "\The [user] touches \the [A] with \the [src], and the enchantment affecting it fizzles away."))
		W.decultify_wall()

	if(istype(A, /turf/simulated/floor/misc/cult))
		var/turf/simulated/floor/misc/cult/F = A
		user.visible_message(SPAN("notice", "\The [user] touches \the [A] with \the [src], and the enchantment affecting it fizzles away."))
		F.decultify_floor()
		playsound(F, 'sound/effects/fighting/Genhit.ogg', 25, 1)




/obj/item/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"
	throwforce = 0
	force = 0
	var/net_type = /obj/effect/energy_net

/obj/item/energy_net/safari
	name = "animal net"
	desc = "An energized net meant to subdue animals."
	net_type = /obj/effect/energy_net/safari

/obj/item/energy_net/dropped()
	..()
	spawn(10)
		if(src) qdel(src)

/obj/item/energy_net/throw_impact(atom/hit_atom)
	..()

	var/mob/living/M = hit_atom

	if(!istype(M) || locate(/obj/effect/energy_net) in M.loc)
		qdel(src)
		return 0

	var/turf/T = get_turf(M)
	if(T)
		var/obj/effect/energy_net/net = new net_type(T)
		net.capture_mob(M)
		qdel(src)

	// If we miss or hit an obstacle, we still want to delete the net.
	spawn(10)
		if(src) qdel(src)

/obj/effect/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"

	density = 1
	opacity = 0
	mouse_opacity = 1
	anchored = 1
	can_buckle = 0 //no manual buckling or unbuckling

	var/health = 25
	var/countdown = 15
	var/temporary = 1
	var/mob/living/carbon/captured = null
	var/min_free_time = 50
	var/max_free_time = 85

/obj/effect/energy_net/safari
	name = "animal net"
	desc = "An energized net meant to subdue animals."

	anchored = 0
	health = 5
	temporary = 0
	min_free_time = 5
	max_free_time = 10

/obj/effect/energy_net/teleport
	countdown = 60

/obj/effect/energy_net/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/energy_net/Destroy()
	if(istype(captured, /mob/living/carbon))
		if(captured.handcuffed == src)
			captured.handcuffed = null
	if(captured)
		unbuckle_mob()
	STOP_PROCESSING(SSobj, src)
	captured = null
	return ..()

/obj/effect/energy_net/Process()
	if(temporary)
		countdown--
	if(captured.buckled != src)
		health = 0
	if(get_turf(src) != get_turf(captured))  //just in case they somehow teleport around or
		countdown = 0
	if(countdown <= 0)
		health = 0
	healthcheck()

/obj/effect/energy_net/Move()
	..()

	if(buckled_mob)
		buckled_mob.forceMove(loc, unbuckle_mob = FALSE)
	else
		countdown = 0


/obj/effect/energy_net/proc/capture_mob(mob/living/M)
	captured = M
	if(M.buckled)
		M.buckled.unbuckle_mob()
	buckle_mob(M)
	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		if(!C.handcuffed)
			C.handcuffed = src
	return 1

/obj/effect/energy_net/post_buckle_mob(mob/living/M)
	if(buckled_mob)

		layer = ABOVE_HUMAN_LAYER
		visible_message("\The [M] was caught in [src]!")
	else
		to_chat(M,"<span class='warning'>You are free of the net!</span>")
		reset_plane_and_layer()

/obj/effect/energy_net/proc/healthcheck()
	if(health <=0)
		set_density(0)
		if(countdown <= 0)
			visible_message("<span class='warning'>\The [src] fades away!</span>")
		else
			visible_message("<span class='danger'>\The [src] is torn apart!</span>")
		qdel(src)

/obj/effect/energy_net/bullet_act(obj/item/projectile/Proj)
	health -= Proj.get_structure_damage()
	healthcheck()
	return 0

/obj/effect/energy_net/ex_act()
	health = 0
	healthcheck()

/obj/effect/energy_net/attack_hand(mob/user)

	var/mob/living/carbon/human/H = user
	if(istype(H))
		if(H.species.can_shred(H))
			playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
			health -= rand(10, 20)
		else
			health -= rand(1,3)

	else if (MUTATION_HULK in user.mutations)
		health = 0
	else
		health -= rand(5,8)

	to_chat(H,"<span class='danger'>You claw at the energy net.</span>")

	healthcheck()
	return

/obj/effect/energy_net/attackby(obj/item/W as obj, mob/user as mob)
	health -= W.force
	healthcheck()
	..()

/obj/effect/energy_net/user_unbuckle_mob(mob/user)
	return escape_net(user)

/obj/effect/energy_net/proc/escape_net(mob/user as mob)
	visible_message(
		"<span class='warning'>\The [user] attempts to free themselves from \the [src]!</span>",
		"<span class='warning'>You attempt to free yourself from \the [src]!</span>"
		)
	if(do_after(user, rand(min_free_time, max_free_time), src, incapacitation_flags = INCAPACITATION_DISABLED))
		health = 0
		healthcheck()
		return 1
	else
		return 0
