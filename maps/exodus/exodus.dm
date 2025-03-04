#if !defined(USING_MAP_DATUM)

	#include "exodus_announcements.dm"
	#include "exodus_areas.dm"
	#include "exodus_effects.dm"
	#include "exodus_elevator.dm"
	#include "exodus_holodecks.dm"
	#include "exodus_presets.dm"
	#include "exodus_shuttles.dm"
	#include "exodus_jobs.dm"

	#include "dynamic/null-1.dmm"
	#include "dynamic/null-2.dmm"
	#include "dynamic/null-3.dmm"
	#include "exodus-4.dmm"
	#include "exodus-5.dmm"
	#include "dynamic/null-6.dmm"
	#include "exodus-7.dmm"
	#include "derelicts/snowasteroid.dmm"
	#include "derelicts/original/derelict.dmm"
	#include "derelicts/bearcat/bearcat-1.dmm"
	#include "derelicts/bearcat/bearcat-2.dmm"
	#include "derelicts/jungleplanet/jungle_planet.dmm"
	#include "derelicts/old_restaurant/old_restaurant.dmm"

	#define USING_MAP_DATUM /datum/map/exodus

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Exodus

#endif
