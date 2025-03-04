GLOBAL_DATUM_INIT(loyalists, /datum/antagonist/loyalists, new)

/datum/antagonist/loyalists
	id = MODE_LOYALIST
	role_text = "Head Loyalist"
	role_text_plural = "Loyalists"
	feedback_tag = "loyalist_objective"
	antag_indicator = "hudheadloyalist"
	victory_text = "The heads of staff remained at their posts! The loyalists win!"
	loss_text = "The heads of staff did not stop the revolution!"
	victory_feedback_tag = "win - rev heads killed"
	loss_feedback_tag = "loss - heads killed"
	antaghud_indicator = "hudloyalist"
	flags = 0

	hard_cap = 2
	hard_cap_round = 4
	initial_spawn_req = 2
	initial_spawn_target = 3

	// Inround loyalists.
	faction_role_text = "Loyalist"
	faction_descriptor = "COMPANY"
	faction_verb = /mob/living/proc/convert_to_loyalist
	faction_indicator = "hudloyalist"
	faction_invisible = 1
	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg)

	faction = "loyalist"

/datum/antagonist/loyalists/Initialize()
	..()
	welcome_text = "You belong to the [GLOB.using_map.company_name], body and soul. Preserve its interests against the conspirators amongst the crew."
	faction_welcome = "Preserve [GLOB.using_map.company_short]'s interests against the traitorous recidivists amongst the crew. Protect the heads of staff with your life."
	faction_descriptor = "[GLOB.using_map.company_name]"

	if(config.loyalists_min_age)
		min_player_age = config.loyalists_min_age

/datum/antagonist/loyalists/proc/count_score()
	var/loyal_score = 0
	for(var/area/A in GLOB.station_areas)
		if(A.is_controlled_by_corporation())
			loyal_score += A.importance
	return loyal_score

/datum/antagonist/loyalists/create_global_objectives()
	if(!..())
		return
	global_objectives = list()
	for(var/mob/living/carbon/human/player in SSmobs.mob_list)
		if(!player.mind || player.stat==2 || !(player.mind.assigned_role in GLOB.command_positions))
			continue
		var/datum/objective/protect/loyal_obj = new
		loyal_obj.target = player.mind
		loyal_obj.explanation_text = "Protect [player.real_name], the [player.mind.assigned_role]."
		global_objectives += loyal_obj
