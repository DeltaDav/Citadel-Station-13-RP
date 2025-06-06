/**
 * base BYOND type for an actor, if the game world is a scene.
 */
/mob
	datum_flags = DF_USE_TAG
	density = 1
	layer = MOB_LAYER
	plane = MOB_PLANE
	animate_movement = 2
	atom_flags = ATOM_HEAR
	pass_flags_self = ATOM_PASS_MOB | ATOM_PASS_OVERHEAD_THROW
	generic_canpass = FALSE
	sight = SIGHT_FLAGS_DEFAULT
	rad_flags = NONE

	//* -- System -- *//
	/// mobs use ids as ref tags instead of actual refs.
	var/static/next_mob_id = 0

	//* Actions *//
	/// our innate action holder; actions here aren't bound to what we're controlling / touching, but instead ourselves
	///
	/// * control and sight of these requires mindjacking, basically
	var/datum/action_holder/actions_innate
	/// our controlled action holder; actions here are bound to physical control, not our own body
	///
	/// * control and sight of these requires only control over motion / actions
	var/datum/action_holder/actions_controlled

	//* Rendering *//
	/// Fullscreen objects
	var/list/fullscreens = list()

	//* Intents *//
	//  todo: movement intents are complicated and will have to stay on the mob for quite a while
	//  todo: action intents should not be on /mob level, instead be on actor huds and passed through to click procs from the
	//        initiator's HUD.
	/// How are we intending to move? Walk / run / etc.
	var/m_intent = MOVE_INTENT_RUN
	/// How are we intending to act? Help / harm / etc.
	var/a_intent = INTENT_HELP

	//* Perspective & Vision *//
	/// using perspective - if none, it'll be self - when client logs out, if using_perspective has reset_on_logout, this'll be unset.
	var/datum/perspective/using_perspective
	/// current darksight modifiers.
	var/list/datum/vision/vision_modifiers
	/// override darksight datum - adminbus only
	var/datum/vision/vision_override

	//? Movement
	/// current datum that's entirely intercepting our movements. only can have one - this is usually used with perspective.
	var/datum/movement_intercept

	//* Buckling *//
	/// Atom we're buckled to
	var/atom/movable/buckled
	/// Atom we're buckl**ing** to. Used to stop stuff like lava from incinerating those who are mid buckle.
	//  todo: can this be put in an existing bitfield somewhere else?
	var/atom/movable/buckling

	//* HUD (Atom) *//
	/// HUDs to initialize, typepaths
	var/list/atom_huds_to_initialize

	//* HUD *//
	/// active, opened storage
	//  todo: doesn't clear from clients properly on logout, relies on login clearing screne.
	//  todo: we'll eventually need a system to handle ckey transfers properly.
	//  todo: this shouldn't be registered on the /mob probably? actor huds maybe?
	var/datum/object_system/storage/active_storage

	//? Movespeed
	/// Next world.time we will be able to move.
	var/move_delay = 0
	/// Last world.time we finished a normal, non relay/intercepted move
	var/last_self_move = 0
	/// Last world.time we turned in our spot without moving (see: facing directions)
	var/last_self_turn = 0
	/// Tracks if we have gravity from environment right now.
	var/in_gravity

	//? Physiology
	/// overall physiology - see physiology.dm
	var/datum/global_physiology/physiology
	/// physiology modifiers - see physiology.dm; set to list of paths at init to initialize into instances.
	var/list/datum/physiology_modifier/physiology_modifiers

	//? Pixel Offsets
	/// are we shifted by the user?
	var/shifted_pixels = FALSE
	/// shifted pixel x
	var/shift_pixel_x = 0
	/// shifted pixel y
	var/shift_pixel_y = 0
	/// pixel-shifted by user enough to let people through. this is a direction flag
	/// although set on /mob level, this is only actually used at /living level because base /mob should not have complex block
	/// mechanics by default.
	var/wallflowering = NONE

	//? Abilities
	/// our abilities - set to list of paths to init to intrinsic abilities.
	var/list/datum/ability/abilities

	//* Inventory *//
	/// our inventory datum, if any.
	var/datum/inventory/inventory
	/// active hand index - null or num. must always be in range of held_items indices!
	var/active_hand

	//* IFF *//
	/// our IFF factions
	///
	/// * Do not read directly, use [code/modules/mob/mob-iff.dm] helpers.
	/// * can be set to a string, or a list of strings.
	var/iff_factions = MOB_IFF_FACTION_NEUTRAL

	//! Size
	//! todo kill this with fire it should just be part of icon_scale_x/y.
	/// our size multiplier
	var/size_multiplier = 1

	//* Misc *//
	/// What we're interacting with right now, associated to list of reasons and the number of concurrent interactions for that reason.
	/// * Used by do_after().
	var/list/interacting_with

	//* Mobility / Stat *//
	/// mobility flags from [code/__DEFINES/mobs/mobility.dm], updated by update_mobility(). use traits to remove these.
	var/mobility_flags = MOBILITY_FLAGS_DEFAULT
	/// force-enabled mobility flags, usually updated by traits
	var/mobility_flags_forced = NONE
	/// force-blocked mobility flags, usually updated by traits
	var/mobility_flags_blocked = NONE
	/// Super basic information about a mob's stats - flags are in [code/__DEFINES/mobs/stat.dm], this is updated by update_stat().
	var/stat = CONSCIOUS
	//  todo: move to /living level, things should be checking mobility flags anyways.
	/// which way are we lying down right now? in degrees. 0 default since we're not laying down.
	var/lying = 0

	//* Status Effects *//
	/// A list of all status effects the mob has
	var/list/status_effects

	//* SSD Indicator *//
	/// current ssd overlay
	var/image/ssd_overlay
	/// do we use ssd overlays?
	var/ssd_visible = FALSE

	//? unsorted / legacy
	var/datum/mind/mind

	var/next_move = null // For click delay, despite the misleading name.

	var/atom/movable/screen/hands = null
	var/atom/movable/screen/pullin = null
	var/atom/movable/screen/purged = null
	var/atom/movable/screen/internals = null
	var/atom/movable/screen/oxygen = null
	var/atom/movable/screen/i_select = null
	var/atom/movable/screen/m_select = null
	var/atom/movable/screen/toxin = null
	var/atom/movable/screen/fire = null
	var/atom/movable/screen/bodytemp = null
	var/atom/movable/screen/healths = null
	var/atom/movable/screen/throw_icon = null
	var/atom/movable/screen/nutrition_icon = null
	var/atom/movable/screen/hydration_icon = null
	var/atom/movable/screen/synthbattery_icon = null
	var/atom/movable/screen/pressure = null
	var/atom/movable/screen/pain = null
	var/atom/movable/screen/crafting = null
	var/atom/movable/screen/gun/item/item_use_icon = null
	var/atom/movable/screen/gun/radio/radio_use_icon = null
	var/atom/movable/screen/gun/move/gun_move_icon = null
	var/atom/movable/screen/gun/run/gun_run_icon = null
	var/atom/movable/screen/gun/mode/gun_setting_icon = null
	var/atom/movable/screen/ling/chems/ling_chem_display = null
	var/atom/movable/screen/wizard/energy/wiz_energy_display = null
	var/atom/movable/screen/wizard/instability/wiz_instability_display = null

	/// Spells hud icons - this interacts with add_spell and remove_spell.
	var/list/atom/movable/screen/movable/spell_master/spell_masters = null
	/// Ability hud icons.
	var/atom/movable/screen/movable/ability_master/ability_master = null

	/**
	 * A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	 *
	 * A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	 * The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	 * I'll make some notes on where certain variable defines should probably go.
	 * Changing this around would probably require a good look-over the pre-existing code.
	 */
	var/atom/movable/screen/zone_sel/zone_sel = null

	/// Allows all mobs to use the me verb by default, will have to manually specify they cannot.
	var/use_me = 1
	var/damageoverlaytemp = 0
	var/computer_id = null
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/memory = ""
	var/sdisabilities = 0	//?Carbon
	var/disabilities = 0	//?Carbon
	var/transforming = null	//?Carbon
	var/eye_blurry = null	//?Carbon
	var/ear_deaf = null		//?Carbon
	var/ear_damage = null	//?Carbon
	var/stuttering = null	//?Carbon
	var/slurring = null		//?Carbon
	var/real_name = null
	var/nickname = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""
	var/exploit_addons = list()		//Assorted things that show up at the end of the exploit_record list
	var/bhunger = 0			//?Carbon
	var/ajourn = 0
	var/druggy = 0			//?Carbon
	var/confused = 0		//?Carbon
	var/antitoxs = null
	var/phoron = null

	/// Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = 0 //0 is off, 1 is normal, 2 is for ninjas.
	var/unacidable = 0
	/// For speaking/listening.
	var/list/languages = list()
	/// For species who want reset to use a specified default.
	var/species_language = null
	/// For species who can only speak their default and no other languages. Does not affect understanding.
	var/only_species_language  = 0
	/// Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/list/speak_emote = list("says")
	/// Define emote default type, 1 for seen emotes, 2 for heard emotes.
	var/emote_type = 1
	/// Used for the ancient art of moonwalking.
	var/facing_dir = null

	/// For admin things like possession.
	var/name_archive

	var/timeofdeath = 0 //?Living

	// todo: go to carbon, simple mobs don't need environmental stabilization
	var/bodytemperature = 310.055 //98.7 F or 36,905 C
	var/drowsyness = 0 //?Carbon

	var/nutrition = 400 //?Carbon
	var/hydration = 400 //?Carbon

	/// How long this guy is overeating. //?Carbon
	var/overeatduration = 0
	var/losebreath = 0 //?Carbon
	var/shakecamera = 0
	var/lastKnownIP = null

	var/seer = 0 //for cult//Carbon, probably Human

	var/datum/hud/hud_used = null

	var/list/grabbed_by = list(  )

	// todo: nuke from orbit
	var/job = null //?Living

	// todo: nuke from orbit
	var/const/blindness = 1 //?Carbon
	var/const/deafness = 2 //?Carbon
	var/const/muteness = 4 //?Carbon

	/// Maximum w_class the mob can pull.
	var/can_pull_size = WEIGHT_CLASS_HUGE
	/// Whether or not the mob can pull other mobs.
	var/can_pull_mobs = MOB_PULL_LARGER

	var/datum/dna/dna = null//?Carbon

	var/list/mutations = list() //?Carbon
	//see: setup.dm for list of mutations

	var/voice_name = "unidentifiable voice"

	/// To prevent pAIs/mice/etc from getting antag in autotraitor and future auto- modes. Uses inheritance instead of a bunch of typechecks.
	// todo: what the fuck
	var/can_be_antagged = FALSE

	/// The last mob/living/carbon to push/drag/grab this mob (mostly used by slimes friend recognition)
	var/mob/living/carbon/LAssailant = null

	/// Wizard's spell list, it can be used in other modes thanks to the "Give Spell" badmin button.
	var/list/spell/spell_list = list()

//Changlings, but can be used in other modes
//	var/obj/effect/proc_holder/changpower/list/power_list = list()

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	/// Bitflags defining which status effects can be inflicted. (replaces canweaken, canstun, etc)
	var/status_flags = STATUS_FLAGS_DEFAULT

	var/area/lastarea = null

	/// Can they be tracked by the AI?
	var/digitalcamo = FALSE

	/// Can they interact with station electronics?
	var/silicon_privileges = NONE

	///Used by admins to possess objects. All mobs should have this var.
	var/obj/control_object

	/// Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = FALSE //? Set to TRUE to enable the mob to speak to everyone.
	var/universal_understand = FALSE //? Set to TRUE to enable the mob to understand everyone, not necessarily speak

	/// Whether this mob's ability to stand has been affected.
	var/stance_damage = 0

	/**
	 * If set, indicates that the client "belonging" to this (clientless) mob is currently controlling some other mob
	 * so don't treat them as being SSD even though their client var is null.
	 */
	var/mob/teleop = null //? This is mainly used for adghosts to hear things from their actual body.

	var/list/active_genes=list()
	var/mob_size = MOB_MEDIUM
	// Used for lings to not see deadchat, and to have ghosting behave as if they were not really dead.
	var/forbid_seeing_deadchat = FALSE

	var/get_hardsuit_stats = 0

	/// Skip processing life() if there's just no players on this Z-level.
	var/low_priority = TRUE

	/// Icon to use when attacking w/o anything in-hand.
	var/attack_icon
	/// Icon State to use when attacking w/o anything in-hand.
	var/attack_icon_state

	var/registered_z

	var/last_radio_sound = -INFINITY

	//? vorestation legacy
	/// Allows flight.
	var/flying = FALSE
	/// For holding onto a temporary form.
	var/mob/temporary_form
	/// Time of client loss, set by Logout(), for timekeeping.
	var/disconnect_time = null

	var/atom/movable/screen/shadekin/shadekin_display = null
	var/atom/movable/screen/xenochimera/danger_level/xenochimera_danger_display = null

	var/muffled = 0 					// Used by muffling belly

	//? Unit Tests
	/// A mock client, provided by tests and friends
	var/datum/client_interface/mock_client

	//? Throwing
	/// whether or not we're prepared to throw stuff.
	var/in_throw_mode = THROW_MODE_OFF

	//? Typing Indicator
	var/typing = FALSE
	var/mutable_appearance/typing_indicator

	//? Movement
	/// Is self-moving.
	var/in_selfmove

	var/is_jittery = 0
	var/jitteriness = 0

	//handles up-down floaty effect in space and zero-gravity
	var/is_floating = 0
	var/floatiness = 0

	var/dizziness = 0
	var/is_dizzy = 0

	// used when venting rooms
	var/tmp/last_airflow_stun = 0

	catalogue_delay = 10 SECONDS

	var/mob/observer/eye/eyeobj

	//thou shall always be able to see the Geometer of Blood
	var/image/narsimage = null
	var/image/narglow = null

	//Moved from code\modules\detectivework\tools\rag.dm
	var/bloody_hands = 0
	var/mob/living/carbon/human/bloody_hands_mob
	var/track_blood = 0
	var/list/feet_blood_DNA
	var/track_blood_type
	var/feet_blood_color

	//Moved from code\modules\keybindings\focus.dm
	/// What receives our keyboard inputs, defaulting to src.
	var/datum/key_focus
	/// a singular thing that can intercept keyboard inputs
	var/datum/key_intercept

	//Moved from code\game\click\click.dm
	// 1 decisecond click delay (above and beyond mob/next_move)
	var/next_click = 0

	//Moved from code\game\rendering\legacy\alert.dm
	var/list/alerts = list() // contains /atom/movable/screen/alert only // On /mob so clientless mobs will throw alerts properly

	//Moved from code\game\verbs\suicide.dm
	var/suiciding = 0

	//Moved from code\modules\admin\admin_attack_log.dm
	var/lastattacker = null
	var/lastattacked = null
	var/attack_log = list( )
	var/dialogue_log = list( )

	//Moved from code\modules\mob\living\carbon\human\pain.dm
	var/list/pain_stored = list()
	var/last_pain_message = ""
	var/next_pain_time = 0

	//Moved from code\modules\nano\nanoexternal.dm
	// Used by the Nano UI Manager (/datum/nanomanager) to track UIs opened by this mob
	var/list/open_uis = list()

	///List of progress bars this mob is currently seeing for actions
	var/list/progressbars = null //for stacking do_after bars
