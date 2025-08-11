// SCP-066 signals
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/attack_target(): ()
#define COMSIG_SCP066_ATTACK_TARGET "scp066_attack_target"
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/handle_autohiss(): ()
#define COMSIG_SCP066_AUTOHISS "scp066_autohiss"
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/proc/Noise(): ()
#define COMSIG_SCP066_NOISE_EMOTE "scp066_noise_emote"
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/proc/Eric(): ()
#define COMSIG_SCP066_ERIC_EMOTE "scp066_eric_emote"
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/proc/LoudNoise(): ()
#define COMSIG_SCP066_LOUD_NOISE_EMOTE "scp066_loud_noise_emote"

// Generic SCP research signals
/// Emitted by memetic component parents when a memetic effect is applied to a human: (mob/living/carbon/human/target)
#define COMSIG_SCP_MEMETIC_AFFECTED "scp_memetic_affected"

// SCP-013 signals
/// Emitted by /obj/item/clothing/mask/cigarette/scp013 when its effect begins on a human: (mob/living/carbon/human/user)
#define COMSIG_SCP013_SMOKED "scp013_smoked"

// SCP-113 signals (object-level convenience for research)
/// Emitted by /obj/item/scp113 when a human makes direct contact and the effect chain starts: (mob/living/carbon/human/user)
#define COMSIG_SCP113_CONTACT "scp113_contact"

// SCP-106 signals
/// Emitted when SCP-106 opens a portal: ()
#define COMSIG_SCP106_PORTAL_OPENED "scp106_portal_opened"
/// Emitted when something uses SCP-106's portal: (atom/movable/user)
#define COMSIG_SCP106_PORTAL_USED "scp106_portal_used"
/// Emitted when SCP-106 applies corrosion: ()
#define COMSIG_SCP106_CORROSION_APPLIED "scp106_corrosion_applied"
/// Emitted when SCP-106 abducts a victim: (mob/living/carbon/human/victim)
#define COMSIG_SCP106_VICTIM_ABDUCTED "scp106_victim_abducted"
/// Emitted when SCP-106 returns from pocket dimension: ()
#define COMSIG_SCP106_RETURNED "scp106_returned"

// Cross-SCP interaction signals
/// Emitted when SCP-106 corrupts SCP-012: (mob/living/simple_animal/hostile/retaliate/scp106/corruptor)
#define COMSIG_SCP012_CORRUPTED "scp012_corrupted"
/// Emitted when SCP-106 silences SCP-066: (mob/living/simple_animal/hostile/retaliate/scp106/silencer)
#define COMSIG_SCP066_SILENCED "scp066_silenced"
/// Emitted when SCP-106 corrupts SCP-113: (mob/living/simple_animal/hostile/retaliate/scp106/corruptor)
#define COMSIG_SCP113_CORRUPTED "scp113_corrupted"
/// Emitted when SCP-106 creates temporal rift with SCP-216: (mob/living/simple_animal/hostile/retaliate/scp106/creator)
#define COMSIG_SCP216_TEMPORAL_RIFT "scp216_temporal_rift"
/// Emitted when SCP-106 absorbs SCP-151: (mob/living/simple_animal/hostile/retaliate/scp106/absorber)
#define COMSIG_SCP151_ABSORBED "scp151_absorbed"
/// Generic SCP corruption signal: (mob/living/simple_animal/hostile/retaliate/scp106/corruptor)
#define COMSIG_SCP_CORRUPTED "scp_corrupted"

// Additional SCP-106 signals
/// Emitted when SCP-106's corrosion is neutralized: (mob/living/simple_animal/hostile/scp049/neutralizer)
#define COMSIG_SCP106_CORROSION_NEUTRALIZED "scp106_corrosion_neutralized"
/// Emitted when SCP-106's abduction is avoided: (mob/living/simple_animal/hostile/scp096/avoider)
#define COMSIG_SCP106_ABDUCTION_AVOIDED "scp106_abduction_avoided"
/// Emitted when SCP-106's abduction is resisted: (mob/living/simple_animal/hostile/scp682/resister)
#define COMSIG_SCP106_ABDUCTION_RESISTED "scp106_abduction_resisted"

// SCP-049 signals
/// Emitted when SCP-049 starts a cure: (mob/living/carbon/human/patient)
#define COMSIG_SCP049_CURE_STARTED "scp049_cure_started"
/// Emitted when SCP-049 successfully cures a patient: (mob/living/carbon/human/patient)
#define COMSIG_SCP049_CURE_SUCCESSFUL "scp049_cure_successful"
/// Emitted when SCP-049's cure fails: (mob/living/carbon/human/patient)
#define COMSIG_SCP049_CURE_FAILED "scp049_cure_failed"
/// Emitted when SCP-049 examines a patient: (mob/living/carbon/human/patient, string/examination_result)
#define COMSIG_SCP049_PATIENT_EXAMINED "scp049_patient_examined"
/// Emitted when SCP-049 researches a cure: (string/cure_type, int/success_rate)
#define COMSIG_SCP049_CURE_RESEARCHED "scp049_cure_researched"
/// Emitted when SCP-049 creates a zombie: (mob/living/carbon/human/zombie)
#define COMSIG_SCP049_ZOMBIE_CREATED "scp049_zombie_created"
/// Emitted when SCP-049's cure is avoided: (mob/living/simple_animal/hostile/scp096/avoider)
#define COMSIG_SCP049_CURE_AVOIDED "scp049_cure_avoided"
/// Emitted when SCP-049's cure is resisted: (mob/living/simple_animal/hostile/scp682/resister)
#define COMSIG_SCP049_CURE_RESISTED "scp049_cure_resisted"

// SCP-096 signals
/// Emitted when SCP-096's rage is triggered: (mob/living/carbon/human/target)
#define COMSIG_SCP096_RAGE_TRIGGERED "scp096_rage_triggered"
/// Emitted when SCP-096's rage ends: ()
#define COMSIG_SCP096_RAGE_ENDED "scp096_rage_ended"
/// Emitted when SCP-096's containment is activated: ()
#define COMSIG_SCP096_CONTAINMENT_ACTIVATED "scp096_containment_activated"
/// Emitted when SCP-096's containment is deactivated: ()
#define COMSIG_SCP096_CONTAINMENT_DEACTIVATED "scp096_containment_deactivated"
/// Emitted when eye contact is maintained with SCP-096: (mob/living/simple_animal/hostile/scp173/maintainer)
#define COMSIG_SCP096_EYE_CONTACT_MAINTAINED "scp096_eye_contact_maintained"
/// Emitted when eye contact is maintained with SCP-173: (mob/living/simple_animal/hostile/scp096/maintainer)
#define COMSIG_SCP173_EYE_CONTACT_MAINTAINED "scp173_eye_contact_maintained"
/// Emitted when SCP-096's rage is resisted: (mob/living/simple_animal/hostile/scp682/resister)
#define COMSIG_SCP096_RAGE_RESISTED "scp096_rage_resisted"

// SCP-173 signals
/// Emitted when eye contact is made with SCP-173: (mob/living/carbon/human/viewer)
#define COMSIG_SCP173_EYE_CONTACT_MADE "scp173_eye_contact_made"
/// Emitted when eye contact is broken with SCP-173: (mob/living/carbon/human/viewer)
#define COMSIG_SCP173_EYE_CONTACT_BROKEN "scp173_eye_contact_broken"
/// Emitted when SCP-173 snaps a neck: (mob/living/carbon/human/victim)
#define COMSIG_SCP173_NECK_SNAPPED "scp173_neck_snapped"
/// Emitted when SCP-173's containment is activated: ()
#define COMSIG_SCP173_CONTAINMENT_ACTIVATED "scp173_containment_activated"
/// Emitted when SCP-173's containment is deactivated: ()
#define COMSIG_SCP173_CONTAINMENT_DEACTIVATED "scp173_containment_deactivated"
/// Emitted when SCP-173's immobilization is resisted: (mob/living/simple_animal/hostile/scp682/resister)
#define COMSIG_SCP173_IMMOBILIZATION_RESISTED "scp173_immobilization_resisted"

// SCP-682 signals
/// Emitted when SCP-682 adapts: (string/adaptation_type)
#define COMSIG_SCP682_ADAPTED "scp682_adapted"
/// Emitted when SCP-682 evolves: (int/evolution_stage)
#define COMSIG_SCP682_EVOLVED "scp682_evolved"
/// Emitted when SCP-682's containment is activated: ()
#define COMSIG_SCP682_CONTAINMENT_ACTIVATED "scp682_containment_activated"
/// Emitted when SCP-682's containment is deactivated: ()
#define COMSIG_SCP682_CONTAINMENT_DEACTIVATED "scp682_containment_deactivated"
/// Emitted when SCP-682 attacks: (mob/living/target)
#define COMSIG_SCP682_ATTACKED "scp682_attacked"

// Generic SCP interaction signals
/// Emitted when SCPs interact with each other: (mob/living/simple_animal/hostile/scp/interactor)
#define COMSIG_SCP_INTERACTED "scp_interacted"
/// Emitted when an SCP adapts to another SCP: (mob/living/simple_animal/hostile/scp682/adapter)
#define COMSIG_SCP_ADAPTED_TO "scp_adapted_to"
/// Emitted when an SCP is cured: (mob/living/simple_animal/hostile/scp049/curer)
#define COMSIG_SCP_CURED "scp_cured"

// Additional SCP interaction signals
/// Emitted when SCP-012's memetic effects are weakened: (mob/living/simple_animal/hostile/scp049/weakened)
#define COMSIG_SCP012_MEMETIC_WEAKENED "scp012_memetic_weakened"
/// Emitted when SCP-113's effects are stabilized: (mob/living/simple_animal/hostile/scp049/stabilized)
#define COMSIG_SCP113_STABILIZED "scp113_stabilized"
/// Emitted when SCP-216's temporal effects are stabilized: (mob/living/simple_animal/hostile/scp049/stabilized)
#define COMSIG_SCP216_TEMPORAL_STABILIZED "scp216_temporal_stabilized"

// SCP-035 signals
/// Emitted when SCP-035 starts possessing someone: (mob/living/carbon/human/host, datum/scp035_personality/personality)
#define COMSIG_SCP035_POSSESSION_STARTED "scp035_possession_started"
/// Emitted when SCP-035 ends possession: (mob/living/carbon/human/host, datum/scp035_personality/personality)
#define COMSIG_SCP035_POSSESSION_ENDED "scp035_possession_ended"
/// Emitted when SCP-035 changes personality: (datum/scp035_personality/old_personality, datum/scp035_personality/new_personality)
#define COMSIG_SCP035_PERSONALITY_CHANGED "scp035_personality_changed"

// SCP-087 signals
/// Emitted when someone starts exploring SCP-087: (mob/living/carbon/human/explorer, datum/scp087_level/level)
#define COMSIG_SCP087_EXPLORATION_STARTED "scp087_exploration_started"
/// Emitted when someone ends exploration of SCP-087: (mob/living/carbon/human/explorer, int/level_reached)
#define COMSIG_SCP087_EXPLORATION_ENDED "scp087_exploration_ended"
/// Emitted when someone descends to a new level in SCP-087: (mob/living/carbon/human/explorer, int/new_level)
#define COMSIG_SCP087_LEVEL_DESCENDED "scp087_level_descended"
/// Emitted when an entity spawns in SCP-087: (mob/living/carbon/human/explorer, mob/living/entity, datum/scp087_level/level)
#define COMSIG_SCP087_ENTITY_SPAWNED "scp087_entity_spawned"
/// Emitted when a portal is created in SCP-087: (mob/living/carbon/human/explorer)
#define COMSIG_SCP087_PORTAL_CREATED "scp087_portal_created"

// SCP-294 signals
/// Emitted when a liquid is requested from SCP-294: (mob/living/carbon/human/user, datum/scp294_liquid/liquid)
#define COMSIG_SCP294_LIQUID_REQUESTED "scp294_liquid_requested"
/// Emitted when a custom liquid is created by SCP-294: (string/liquid_name, datum/scp294_liquid/liquid)
#define COMSIG_SCP294_CUSTOM_LIQUID_CREATED "scp294_custom_liquid_created"
/// Emitted when liquid effects are applied by SCP-294: (mob/living/carbon/human/user, datum/scp294_liquid/liquid)
#define COMSIG_SCP294_LIQUID_EFFECTS_APPLIED "scp294_liquid_effects_applied"

// SCP-008 signals
/// Emitted when SCP-008 transforms a human into a zombie: (mob/living/carbon/human/victim)
#define COMSIG_SCP008_TRANSFORMATION "scp008_transformation"

// SCP-017 signals
/// Emitted when SCP-017 absorbs light: (int/light_level)
#define COMSIG_SCP017_LIGHT_ABSORBED "scp017_light_absorbed"
/// Emitted when SCP-017 creates a shadow trap: (obj/structure/shadow_trap/trap)
#define COMSIG_SCP017_TRAP_CREATED "scp017_trap_created"
/// Emitted when SCP-017 manipulates shadows: (int/shadow_intensity)
#define COMSIG_SCP017_SHADOWS_MANIPULATED "scp017_shadows_manipulated"

// SCP-131 signals
/// Emitted when SCP-131 provides comfort: (mob/living/carbon/human/comforted)
#define COMSIG_SCP131_COMFORT_PROVIDED "scp131_comfort_provided"
/// Emitted when SCP-131 shows curiosity: (obj/target)
#define COMSIG_SCP131_CURIOSITY_SHOWN "scp131_curiosity_shown"

// SCP-343 signals
/// Emitted when SCP-343 warps reality: (int/warp_intensity)
#define COMSIG_SCP343_REALITY_WARPED "scp343_reality_warped"
/// Emitted when SCP-343 heals a human: (mob/living/carbon/human/healed)
#define COMSIG_SCP343_HUMAN_HEALED "scp343_human_healed"
/// Emitted when SCP-343 protects a human: (mob/living/carbon/human/protected)
#define COMSIG_SCP343_HUMAN_PROTECTED "scp343_human_protected"
/// Emitted when SCP-343 blesses an area: (turf/area)
#define COMSIG_SCP343_AREA_BLESSED "scp343_area_blessed"

// SCP-420-J signals
/// Emitted when SCP-420-J tells a joke: (string/joke)
#define COMSIG_SCP420_J_JOKE_TOLD "scp420_j_joke_told"
/// Emitted when SCP-420-J increases intensity: (int/new_intensity)
#define COMSIG_SCP420_J_INTENSITY_INCREASED "scp420_j_intensity_increased"
/// Emitted when SCP-420-J spreads laughter: ()
#define COMSIG_SCP420_J_LAUGHTER_SPREAD "scp420_j_laughter_spread"

// SCP-500 signals
/// Emitted when SCP-500 is administered: (mob/living/carbon/human/target, mob/living/carbon/human/user)
#define COMSIG_SCP500_ADMINISTERED "scp500_administered"

// SCP-513 signals
/// Emitted when SCP-513 is rung: (mob/living/carbon/human/rung_by)
#define COMSIG_SCP513_RUNG "scp513_rung"
/// Emitted when SCP-513 increases intensity: (int/new_intensity)
#define COMSIG_SCP513_INTENSITY_INCREASED "scp513_intensity_increased"
/// Emitted when SCP-513 spawns a mysterious figure: (mob/living/simple_animal/hostile/mysterious_figure/figure)
#define COMSIG_SCP513_FIGURE_SPAWNED "scp513_figure_spawned"

// SCP-895 signals
/// Emitted when SCP-895 disturbs a camera: (obj/machinery/camera/camera, string/disturbing_image)
#define COMSIG_SCP895_CAMERA_DISTURBED "scp895_camera_disturbed"
/// Emitted when SCP-895 overrides a camera: (obj/machinery/camera/camera)
#define COMSIG_SCP895_CAMERA_OVERRIDDEN "scp895_camera_overridden"
/// Emitted when SCP-895 generator is toggled: (bool/active)
#define COMSIG_SCP895_GENERATOR_TOGGLED "scp895_generator_toggled"
/// Emitted when SCP-895 generates an area: (obj/effect/scp895_area/area)
#define COMSIG_SCP895_AREA_GENERATED "scp895_area_generated"
/// Emitted when SCP-895 increases intensity: (int/new_intensity)
#define COMSIG_SCP895_INTENSITY_INCREASED "scp895_intensity_increased"

// SCP-914 signals
/// Emitted when SCP-914 completes refinement: (obj/item/output_item, string/refinement_setting)
#define COMSIG_SCP914_REFINEMENT_COMPLETE "scp914_refinement_complete"

// SCP-999 signals
/// Emitted when SCP-999 tickles someone: (mob/living/carbon/human/tickled)
#define COMSIG_SCP999_TICKLED "scp999_tickled"
/// Emitted when SCP-999 heals someone: (mob/living/carbon/human/healed)
#define COMSIG_SCP999_HEALED "scp999_healed"
/// Emitted when SCP-999 plays with someone: (mob/living/carbon/human/played_with)
#define COMSIG_SCP999_PLAYED "scp999_played"
/// Emitted when SCP-999 comforts someone: (mob/living/carbon/human/comforted)
#define COMSIG_SCP999_COMFORTED "scp999_comforted"

// SCP-1048 signals
/// Emitted when SCP-1048 comforts someone: (mob/living/carbon/human/comforted)
#define COMSIG_SCP1048_COMFORTED "scp1048_comforted"
/// Emitted when SCP-1048 creates offspring: (mob/living/simple_animal/scp1048_offspring/offspring)
#define COMSIG_SCP1048_OFFSPRING_CREATED "scp1048_offspring_created"
/// Emitted when SCP-1048 protects someone: (mob/living/carbon/human/protected)
#define COMSIG_SCP1048_PROTECTING "scp1048_protecting"
/// Emitted when SCP-1048 plays with someone: (mob/living/carbon/human/played_with)
#define COMSIG_SCP1048_PLAYED "scp1048_played"

// SCP-1471 signals
/// Emitted when SCP-1471 app is activated: (mob/living/carbon/human/user)
#define COMSIG_SCP1471_APP_ACTIVATED "scp1471_app_activated"
/// Emitted when SCP-1471 takes a photo: (mob/living/carbon/human/user, int/photo_count)
#define COMSIG_SCP1471_PHOTO_TAKEN "scp1471_photo_taken"
/// Emitted when SCP-1471 app is deactivated: (mob/living/carbon/human/user)
#define COMSIG_SCP1471_APP_DEACTIVATED "scp1471_app_deactivated"

// SCP-1981 signals
/// Emitted when SCP-1981 triggers memory flash: (mob/living/carbon/human/affected)
#define COMSIG_SCP1981_MEMORY_FLASH_TRIGGERED "scp1981_memory_flash_triggered"

// SCP-3008 signals
/// Emitted when SCP-3008 generates a level: (int/level_number)
#define COMSIG_SCP3008_LEVEL_GENERATED "scp3008_level_generated"
/// Emitted when SCP-3008 spawns staff: (mob/living/simple_animal/hostile/ikea_staff/staff)
#define COMSIG_SCP3008_STAFF_SPAWNED "scp3008_staff_spawned"
/// Emitted when someone enters SCP-3008: (mob/living/carbon/human/entrant)
#define COMSIG_SCP3008_HUMAN_ENTERED "scp3008_human_entered"
/// Emitted when someone escapes SCP-3008: (mob/living/carbon/human/escapee)
#define COMSIG_SCP3008_FORCE_ESCAPE "scp3008_force_escape"

// Additional cross-SCP interaction signals
/// Emitted when SCP-049 is comforted: (mob/living/simple_animal/scp131_a/comforted_by)
#define COMSIG_SCP049_COMFORTED "scp049_comforted"
/// Emitted when SCP-096 is calmed: (mob/living/simple_animal/scp131_a/calmed_by)
#define COMSIG_SCP096_CALMED "scp096_calmed"
/// Emitted when SCP-049 is blessed: (mob/living/carbon/human/scp343/blessed_by)
#define COMSIG_SCP049_BLESSED "scp049_blessed"
/// Emitted when SCP-096 receives divine calm: (mob/living/carbon/human/scp343/calmed_by)
#define COMSIG_SCP096_DIVINE_CALM "scp096_divine_calm"
/// Emitted when SCP-049 hears a joke: (obj/item/scp420_j/joke_teller)
#define COMSIG_SCP049_JOKE_TOLD "scp049_joke_told"
/// Emitted when SCP-096 laughs: (obj/item/scp420_j/joke_teller)
#define COMSIG_SCP096_LAUGHED "scp096_laughed"
/// Emitted when SCP-049 hears a bell: (obj/item/scp513/bell_rung_by)
#define COMSIG_SCP049_BELL_RUNG "scp049_bell_rung"
/// Emitted when SCP-049's camera is disrupted: (obj/machinery/scp895_generator/disruptor)
#define COMSIG_SCP049_CAMERA_DISRUPTED "scp049_camera_disrupted"



// Sanity System Signals
/// Emitted when carbon mob's sanity changes: (int/old_sanity, int/new_sanity, string/reason)
#define COMSIG_CARBON_SANITY_CHANGED "carbon_sanity_changed"
