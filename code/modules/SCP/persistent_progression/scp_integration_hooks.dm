#define INTERACTION_TYPE_OBSERVATION 1
#define INTERACTION_TYPE_COMBAT 2
#define INTERACTION_TYPE_CONTAINMENT 3
#define INTERACTION_TYPE_RESEARCH 4
#define INTERACTION_TYPE_COMMUNICATION 5
#define INTERACTION_TYPE_EXPERIMENT 6
#define INTERACTION_TYPE_CARE 7
#define INTERACTION_TYPE_EXPLORATION 8
#define INTERACTION_TYPE_SURVIVAL 9
#define INTERACTION_TYPE_MEDICAL 10

#define INTERACTION_RISK_NONE 0
#define INTERACTION_RISK_LOW 1
#define INTERACTION_RISK_MEDIUM 2
#define INTERACTION_RISK_HIGH 3
#define INTERACTION_RISK_CRITICAL 4

/proc/hook_scp_breach(scp_id, atom/scp_atom)
	return TRUE

/proc/hook_scp_recontainment(scp_id, list/participants)
	return TRUE

/proc/hook_scp_interaction(mob/living/carbon/human/player, scp_id, interaction_type, list/data = null)
	if(!player || !scp_id)
		return FALSE
	if(SSscp_interactions)
		SSscp_interactions.manager?.log_interaction(player, scp_id, interaction_type, data)
	return TRUE

/proc/hook_scp_observation(mob/living/carbon/human/observer, scp_id)
	if(!observer || !scp_id)
		return FALSE
	hook_scp_interaction(observer, scp_id, INTERACTION_TYPE_OBSERVATION)
	return TRUE

/proc/hook_scp_combat(mob/living/carbon/human/fighter, scp_id, damage_dealt = 0, damage_taken = 0)
	if(!fighter || !scp_id)
		return FALSE
	var/list/data = list("damage_dealt" = damage_dealt, "damage_taken" = damage_taken)
	hook_scp_interaction(fighter, scp_id, INTERACTION_TYPE_COMBAT, data)
	return TRUE

/proc/hook_scp_research(mob/living/carbon/human/researcher, scp_id, research_type = "general")
	if(!researcher || !scp_id)
		return FALSE
	hook_scp_interaction(researcher, scp_id, INTERACTION_TYPE_RESEARCH, list("type" = research_type))
	return TRUE

/proc/hook_scp_experiment(mob/living/carbon/human/researcher, scp_id, experiment_type)
	if(!researcher || !scp_id)
		return FALSE
	hook_scp_interaction(researcher, scp_id, INTERACTION_TYPE_EXPERIMENT, list("type" = experiment_type))
	return TRUE

/proc/hook_scp_care(mob/living/carbon/human/caregiver, scp_id, care_type = "standard")
	if(!caregiver || !scp_id)
		return FALSE
	hook_scp_interaction(caregiver, scp_id, INTERACTION_TYPE_CARE, list("type" = care_type))
	return TRUE

/proc/hook_scp_communication(mob/living/carbon/human/speaker, scp_id, message = "")
	if(!speaker || !scp_id)
		return FALSE
	hook_scp_interaction(speaker, scp_id, INTERACTION_TYPE_COMMUNICATION, list("message" = message))
	return TRUE

/proc/hook_scp_exploration(mob/living/carbon/human/explorer, scp_id, depth = 0, duration = 0)
	if(!explorer || !scp_id)
		return FALSE
	hook_scp_interaction(explorer, scp_id, INTERACTION_TYPE_EXPLORATION, list("depth" = depth, "duration" = duration))
	return TRUE

/proc/hook_player_death_near_scp(mob/living/carbon/human/victim, scp_id)
	return

/proc/hook_scp_damage(scp_id, damage_percent)
	return

/proc/hook_facility_damage_near_scp(scp_id, damage_level)
	return
