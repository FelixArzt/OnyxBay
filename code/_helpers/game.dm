#define RANGE_TURFS(RADIUS, CENTER) \
  block( \
    locate(max(CENTER.x - (RADIUS), 1),          max(CENTER.y - (RADIUS), 1),          CENTER.z), \
    locate(min(CENTER.x + (RADIUS), world.maxx), min(CENTER.y + (RADIUS), world.maxy), CENTER.z) \
  )

/proc/dopage(src, target)
	var/href_list
	var/href
	href_list = params2list("src=\ref[src]&[target]=1")
	href = "src=\ref[src];[target]=1"
	src:temphtml = null
	src:Topic(href, href_list)
	return null

/proc/is_on_same_plane_or_station(z1, z2)
	if(z1 == z2)
		return 1
	if((z1 in GLOB.using_map.station_levels) &&	(z2 in GLOB.using_map.station_levels))
		return 1
	return 0

/proc/living_observers_present(list/zlevels)
	if(LAZYLEN(zlevels))
		for(var/client/C in GLOB.clients) // if a tree ticks on the empty zlevel does it really tick
			if(isliving(C.mob)) // (no it doesn't)
				var/turf/T = get_turf(C.mob)
				if(T && (T.z in zlevels))
					return TRUE
	return FALSE

/proc/get_z(O)
	var/turf/loc = get_turf(O)
	return loc ? loc.z : 0

/proc/get_area(O)
	if(isarea(O))
		return O
	var/turf/loc = get_turf(O)
	return loc ? loc.loc : null

/proc/get_area_name(N) // get area by its name
	for(var/area/A in world)
		if(A.name == N)
			return A
	return 0

/proc/get_area_master(const/O)
	var/area/A = get_area(O)
	if (isarea(A))
		return A

/proc/in_range(source, user)
	if(get_dist(source, user) <= 1)
		return 1
	return 0 // not in range and not telekinetic

// Like view but bypasses luminosity check
/proc/hear(range, atom/source)
	var/lum = source.luminosity
	source.luminosity = 6

	. = view(range, source)
	source.luminosity = lum

/proc/isStationLevel(level)
	return level in GLOB.using_map.station_levels

/proc/isNotStationLevel(level)
	return !isStationLevel(level)

/proc/isPlayerLevel(level)
	return level in GLOB.using_map.player_levels

/proc/isAdminLevel(level)
	return level in GLOB.using_map.admin_levels

/proc/isNotAdminLevel(level)
	return !isAdminLevel(level)

/proc/isContactLevel(level)
	return level in GLOB.using_map.contact_levels

/proc/circlerange(center = usr, radius = 3)
	var/turf/centerturf = get_turf(center)
	var/list/turfs = new /list()
	var/rsq = radius * (radius + 0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx * dx + dy * dy <= rsq)
			turfs += T

	return turfs

/proc/circleview(center = usr, radius = 3)
	var/turf/centerturf = get_turf(center)
	var/list/atoms = new /list()
	var/rsq = radius * (radius + 0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx * dx + dy * dy <= rsq)
			atoms += A

	return atoms

// alternative to range (ONLY processes turfs and thus less intensive)
/proc/trange(rad = 0, turf/centre = null)
	if(!centre)
		return

	var/turf/x1y1 = locate(((centre.x - rad)<1 ? 1 : centre.x - rad),((centre.y - rad)<1 ? 1 : centre.y - rad),centre.z)
	var/turf/x2y2 = locate(((centre.x + rad)>world.maxx ? world.maxx : centre.x + rad),((centre.y + rad)>world.maxy ? world.maxy : centre.y + rad),centre.z)
	return block(x1y1, x2y2)

/proc/get_dist_euclidian(atom/Loc1, atom/Loc2)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx ** 2 + dy ** 2)

	return dist

/proc/circlerangeturfs(center = usr, radius = 3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new /list()
	var/rsq = radius * (radius + 0.5)

	for(var/turf/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx * dx + dy * dy <= rsq)
			turfs += T
	return turfs

// Is there even a diffrence between this proc and circlerangeturfs()?
/proc/circleviewturfs(center = usr, radius = 3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new /list()
	var/rsq = radius * (radius + 0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx * dx + dy * dy <= rsq)
			turfs += T
	return turfs

// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.
/proc/recursive_content_check(atom/O,  list/L = list(), recursion_limit = 3, client_check = 1, sight_check = 1, include_mobs = 1, include_objects = 1)
	if(!recursion_limit)
		return L

	for(var/I in O.contents)
		if(ismob(I))
			if(!sight_check || isInSight(I, O))
				L |= recursive_content_check(I, L, recursion_limit - 1, client_check, sight_check, include_mobs, include_objects)
				if(include_mobs)
					if(client_check)
						var/mob/M = I
						if(M.client)
							L |= M
					else
						L |= I

		else if(istype(I,/obj/))
			if(!sight_check || isInSight(I, O))
				L |= recursive_content_check(I, L, recursion_limit - 1, client_check, sight_check, include_mobs, include_objects)
				if(include_objects)
					L |= I

	return L

// Returns a list of mobs and/or objects in range of R from source. Used in radio and say code.
/proc/get_mobs_or_objects_in_view(R, atom/source, include_mobs = 1, include_objects = 1)
	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = hear(R, T)

	for(var/I in range)
		if(ismob(I))
			hear |= recursive_content_check(I, hear, 3, 1, 0, include_mobs, include_objects)
			if(include_mobs)
				var/mob/M = I
				if(M.client)
					hear += M
		else if(istype(I,/obj/))
			hear |= recursive_content_check(I, hear, 3, 1, 0, include_mobs, include_objects)
			if(include_objects)
				hear += I

	return hear


/proc/get_mobs_in_radio_ranges(list/obj/item/device/radio/radios)
	set background = 1

	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/r in radios)
		var/obj/item/device/radio/R = r // You better fucking be a radio.
		var/turf/speaker = get_turf(R)
		if(speaker)
			for(var/turf/T in hear(R.canhear_range, speaker))
				speaker_coverage[T] = R

	// Try to find all the players who can hear the message
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/M = GLOB.player_list[i]
		if(M.can_hear_radio(speaker_coverage))
			. += M

/mob/proc/can_hear_radio(list/hearturfs)
	return FALSE

/mob/living/can_hear_radio(list/hearturfs)
	return get_turf(src) in hearturfs

/mob/living/silicon/robot/can_hear_radio(list/hearturfs)
	var/turf/T = get_turf(src)
	var/obj/item/device/radio/borg/R = hearturfs[T] // this should be an assoc list of turf-to-radio

	// We heard it on our own radio? We use power for that.
	if(istype(R) && R.myborg == src)
		var/datum/robot_component/CO = get_robot_component("radio")
		if(!CO || !is_component_functioning("radio") || !cell_use_power(CO.active_usage))
			return FALSE // Sorry, couldn't hear

	return R // radio, true, false, what's the difference

/mob/observer/ghost/can_hear_radio(list/hearturfs)
	return get_preference_value(/datum/client_preference/ghost_radio) == GLOB.PREF_ALL_CHATTER

// Uses dview to quickly return mobs and objects in view,
// then adds additional mobs or objects if they are in range 'smartly',
// based on their presence in lists of players or registered objects
/proc/get_mobs_and_objs_in_view_fast(turf/T, range, list/mobs, list/objs, checkghosts = null)
	var/list/hear = dview(range, T, INVISIBILITY_MAXIMUM)
	var/list/hearturfs = list()

	for(var/thing in hear)
		// Can't use isobj() because /atom/movable returns true in that, and so lighting overlays would be included
		if(istype(thing, /obj))
			objs += thing
			hearturfs |= get_turf(thing)
			continue
		if(ismob(thing))
			mobs += thing
			hearturfs |= get_turf(thing)

	// A list of every mob with a client
	for(var/mob in GLOB.player_list)
		if(get_turf(mob) in hearturfs)
			mobs |= mob
			continue

		var/mob/M = mob
		if(checkghosts && M && M.stat == DEAD && M.get_preference_value(checkghosts) != GLOB.PREF_NEARBY)
			mobs |= M

	// For objects below the top level who still want to hear
	for(var/obj in GLOB.listening_objects)
		if(get_turf(obj) in hearturfs)
			objs |= obj


/proc/inLineOfSight(X1, Y1, X2, Y2, Z = 1, PX1 = 16.5, PY1 = 16.5, PX2 = 16.5, PY2 = 16.5)
	var/turf/T
	if(X1 == X2)
		if(Y1 == Y2)
			return 1 // Light cannot be blocked on same tile
		else
			var/s = SIMPLE_SIGN(Y2 - Y1)
			Y1 += s
			while(Y1 != Y2)
				T = locate(X1, Y1, Z)
				if(T.opacity)
					return 0
				Y1 += s
	else
		var/m = (32 * (Y2 - Y1) + (PY2 - PY1)) / (32 * (X2 - X1) + (PX2 - PX1))
		var/b = (Y1 + PY1 / 32 - 0.015625) - m * (X1 + PX1 / 32 - 0.015625) // In tiles
		var/signX = SIMPLE_SIGN(X2 - X1)
		var/signY = SIMPLE_SIGN(Y2 - Y1)
		if(X1 < X2)
			b += m
		while(X1!=X2 || Y1!=Y2)
			if(round(m * X1 + b - Y1))
				Y1 += signY // Line exits tile vertically
			else
				X1 += signX // Line exits tile horizontally
			T = locate(X1, Y1, Z)
			if(T.opacity)
				return 0
	return 1

/proc/isInSight(atom/A, atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	if(inLineOfSight(Aturf.x, Aturf.y, Bturf.x, Bturf.y, Aturf.z))
		return 1

	else
		return 0

// Returns the position of a step from start away from finish, in one of the cardinal directions
// Returns only NORTH, SOUTH, EAST, or WEST
/proc/get_cardinal_step_away(atom/start, atom/finish)
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y

	if(abs(dy) > abs (dx)) // Slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/get_mob_by_key(key)
	for(var/mob/M in SSmobs.mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null


// Will return a list of active candidates. It increases the buffer 5 times until it finds a candidate which is active within the buffer.
/proc/get_active_candidates(buffer = 1)
	// List of candidate KEYS to assume control of the new larva ~Carn
	var/list/candidates = list()
	var/i = 0
	while(candidates.len <= 0 && i < 5)
		for(var/mob/observer/ghost/G in GLOB.player_list)
			// The most active players are more likely to become an alien
			if(((G.client.inactivity/10)/60) <= buffer + i)
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					candidates += G.key
		i++
	return candidates

// Same as above but for alien candidates.
/proc/get_alien_candidates()
	// List of candidate KEYS to assume control of the new larva ~Carn
	var/list/candidates = list()
	var/i = 0
	while(candidates.len <= 0 && i < 5)
		for(var/mob/observer/ghost/G in GLOB.player_list)
			if(MODE_XENOMORPH in G.client.prefs.be_special_role)
				// The most active players are more likely to become an alien
				if(((G.client.inactivity/10)/60) <= ALIEN_SELECT_AFK_BUFFER + i)
					if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
						candidates += G.key
		i++
	return candidates

/proc/ScreenText(obj/O, maptext = "", screen_loc = "CENTER-7,CENTER-7", maptext_height = 480, maptext_width = 480)
	if(!isobj(O))	O = new /obj/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay = 0)
	if(!isobj(O))	return
	if(!group)	group = GLOB.clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	spawn(duration)
		for(var/client/C in show_to)
			C.images -= I

/datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(src_x, src_y, rotation, angle, power)
	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2 * power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance * sin(rotation);
	var/dest_y = src_y + distance * cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)

/proc/GetRedPart(const/hexa)
	return hex2num(copytext(hexa, 2, 4))

/proc/GetGreenPart(const/hexa)
	return hex2num(copytext(hexa, 4, 6))

/proc/GetBluePart(const/hexa)
	return hex2num(copytext(hexa, 6, 8))

/proc/GetHexColors(const/hexa)
	return list(
			GetRedPart(hexa),
			GetGreenPart(hexa),
			GetBluePart(hexa)
		)

/proc/rgb2hsl(red, grn, blu)
	red /= 255
	grn /= 255
	blu /= 255

	var/lo = min(red, grn, blu)
	var/hi = max(red, grn, blu)
	var/range = hi - lo
	var/hue = 0
	var/sat = 0
	var/lgh = 0

	if(range != 0)
		lgh = range/2
		if(lgh < 0.5)
			sat = range / (hi + lo)
		else
			sat = range / (2 - hi - lo)
		if(red == hi)
			hue = (grn - blu) / range
		else if(grn == hi)
			hue = 2 + (blu - red) / range
		else
			hue = 4 + (red - grn) / range
		if(hue < 0)
			hue += 6

	lgh = round(lgh * 100, 1)
	sat = round(sat * 100, 1)
	hue = round((hue / 6) * 360, 1)

	return list(hue, sat, lgh)

/proc/hsl2rgb(hue, sat, lgh)
	hue /= 360
	sat /= 100
	lgh /= 100

	var/red = 0
	var/grn = 0
	var/blu = 0

	if(!sat)
		red = lgh
		grn = lgh
		blu = lgh
	else
		var/temp1 = 0
		var/temp2 = 0
		var/temp3 = 0
		if(lgh < 0.5)
			temp2 = lgh * (1 + sat)
		else
			temp2 = lgh + sat - lgh * sat
		temp1 = 2 * lgh - temp2

		temp3 = hue + 1/3
		if(temp3 > 1)
			temp3--
		if(6 * temp3 < 1)
			red = temp1 + (temp2 - temp1) * 6 * temp3
		else if(2 * temp3 < 1)
			red = temp2
		else if(3 * temp3 < 2)
			red = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
		else
			red = temp1

		temp3 = hue
		if(6 * temp3 < 1)
			grn = temp1 + (temp2 - temp1) * 6 * temp3
		else if(2 * temp3 < 1)
			grn = temp2
		else if(3 * temp3 < 2)
			grn = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
		else
			grn = temp1

		temp3 = hue - 1/3
		if(temp3 < 0)
			temp3++
		if(6 * temp3 < 1)
			blu = temp1 + (temp2 - temp1) * 6 * temp3
		else if(2 * temp3 < 1)
			blu = temp2
		else if(3 * temp3 < 2)
			blu = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
		else
			blu = temp1

	red = round(red * 255, 1)
	grn = round(grn * 255, 1)
	blu = round(blu * 255, 1)

	return list(red, grn, blu)

/proc/MixColors(const/list/colors)
	var/list/reds = list()
	var/list/blues = list()
	var/list/greens = list()
	var/list/weights = list()

	for (var/i = 0, ++i <= colors.len)
		reds.Add(GetRedPart(colors[i]))
		blues.Add(GetBluePart(colors[i]))
		greens.Add(GetGreenPart(colors[i]))
		weights.Add(1)

	var/r = mixOneColor(weights, reds)
	var/g = mixOneColor(weights, greens)
	var/b = mixOneColor(weights, blues)
	return rgb(r, g, b)

/proc/mixOneColor(list/weight, list/color)
	if (!weight || !color || length(weight)!=length(color))
		return 0

	var/contents = length(weight)
	var/i

	// Normalize weights
	var/listsum = 0
	for(i = 1; i <= contents; i++)
		listsum += weight[i]
	for(i = 1; i <= contents; i++)
		weight[i] /= listsum

	// Mix them
	var/mixedcolor = 0
	for(i = 1; i <= contents; i++)
		mixedcolor += weight[i]*color[i]
	mixedcolor = round(mixedcolor)

	// until someone writes a formal proof for this algorithm, let's keep this in
	// 	if(mixedcolor<0x00 || mixedcolor>0xFF)
	//		return 0
	// that's not the kind of operation we are running here, nerd
	mixedcolor = min(max(mixedcolor, 0), 255)

	return mixedcolor

/*
	Gets the highest and lowest pressures from the tiles in cardinal directions
	around us, then checks the difference.
*/
/proc/getOPressureDifferential(turf/loc)
	var/minp = 16777216;
	var/maxp = 0;
	for(var/dir in GLOB.cardinal)
		var/turf/simulated/T = get_turf(get_step(loc, dir))
		var/cp = 0
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			cp = environment.return_pressure()
		else
			if(istype(T,/turf/simulated))
				continue
		if(cp < minp)minp = cp
		if(cp > maxp)maxp = cp
	return abs(minp - maxp)

/proc/convert_k2c(temp)
	return ((temp - T0C))

/proc/convert_c2k(temp)
	return ((temp + T0C))

/proc/getCardinalAirInfo(turf/loc, list/stats = list("temperature"))
	var/list/temps = new /list(4)
	for(var/dir in GLOB.cardinal)
		var/direction
		switch(dir)
			if(NORTH)
				direction = 1
			if(SOUTH)
				direction = 2
			if(EAST)
				direction = 3
			if(WEST)
				direction = 4
		var/turf/simulated/T = get_turf(get_step(loc, dir))
		var/list/rstats = new /list(stats.len)
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i = 1; i <= stats.len; i++)
				if(stats[i] == "pressure")
					rstats[i] = environment.return_pressure()
				else
					rstats[i] = environment.vars[stats[i]]
		else if(istype(T, /turf/simulated))
			rstats = null // Exclude zone (wall, door, etc).
		else if(istype(T, /turf))
			// Should still work.  (/turf/return_air())
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i = 1; i <= stats.len; i++)
				if(stats[i] == "pressure")
					rstats[i] = environment.return_pressure()
				else
					rstats[i] = environment.vars[stats[i]]
		temps[direction] = rstats
	return temps

/proc/MinutesToTicks(minutes)
	return SecondsToTicks(60 * minutes)

/proc/SecondsToTicks(seconds)
	return seconds * 10

/proc/round_is_spooky(spookiness_threshold = config.cult_ghostwriter_req_cultists)
	return (GLOB.cult.current_antagonists.len > spookiness_threshold)

/proc/getviewsize(view)
	var/viewX
	var/viewY
	if(isnum(view))
		var/totalviewrange = 1 + 2 * view
		viewX = totalviewrange
		viewY = totalviewrange
	else
		var/list/viewrangelist = splittext(view,"x")
		viewX = text2num(viewrangelist[1])
		viewY = text2num(viewrangelist[2])
	return list(viewX, viewY)
