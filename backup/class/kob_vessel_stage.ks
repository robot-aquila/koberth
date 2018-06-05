// kob_vessel_stage - class to represent a set of parts of separate vessel stage 
// v0.0.1
//
// Despite it is called "vessel stage", it does not linked or based on kOS
// vessel. It is based on list of parts. Thereby, we are not limited to one
// vessel and can build any stages on the fly. Including stages combined from
// two or more vessels which are currently in space. Yes, we can calculate can
// we catch this thing in space and bring it to home. And yes, if there are some
// resources inside this flying thing which can be utilized we can also include
// them to calculations.
//
// Keep in mind, it operates with set of parts. This mean if you attach
// some new or remove existing parts from vessel on the fly (for example using
// KAS) this class instance become outdated. It will give wrong result for
// Delta-V calculation. You have to rebuild part lists using refresh method.
// Of course if you dropped stage off ship it will not work too. But you
// can transfer resources from and to those parts and it will not affect
// calculation correctness.
// 
// Stages numerated from higher to lower numbers. Let's assume example sattelite
// ship split on two parts: launch vehicle is bottom part and small sattelite
// itself on the top of the rocket. The launch vehicle is stage 1 and the
// sattelite is 0.
//
// Each stage contains parts of several categories:
// *) stage parts - all parts of this stage including engines, fuel tanks and
//    parts of next stages
// *) engines - all engines which is used to move this stage
// *) fuel tanks - all fuel tanks to store fuel for engines of this stage
// *) load parts - all parts of the next stages (means load of this stage)
//
// Engines are used to calculate ISP and thrust of the stage. Fuel tanks are
// used to calculate dry and wet mass of stage. Finally engines and fuel tanks
// are used to calculate Delta-V of the stage.
//
// Load parts are used to calculate masses. When this stage will done all its
// parts will be dropped away and ship will keep only mass of load. The load
// become the next stage.
//
// So we can calculate parameters of each stage at any time.


// Basic constructor.
// 
// Parameters 2, 3, 4 and 5 are part validators. Part validator is an anonymous
// functions with single argument - a kOS part. The result of that function
// should be true or false. True means that the part belongs to appropriate
// category.
//
// Param1: list of parts to analyse. This list may contain any parts. All of
//         them will be filtered and placed to the right category.
// Param2: stage parts validator. Stage parts means all parts of the stage
//         including engines, fuel tanks and load. This validator is used to
//         select all significant parts from initial part list and to exclude
//         parts which are on prior stages or parts we just not interested.
// Param3: stage engines validator
// Param4: stage fuel tanks validator
// Param5: stage load validator
// Return: kob_vessel_stage class instance
function kob_vessel_stage {
	declare local parameter all_parts, is_part, is_engine, is_fuel_tank, is_load.

	local obj is lexicon().
	set obj["all_parts"] to all_parts.
	set obj["stage_parts"] to list().
	set obj["stage_engines"] to list().
	set obj["stage_fuel_tanks"] to list().
	set obj["stage_load"] to list().

	// class methods
	set obj["is_stage_part"] to is_stage.
	set obj["is_stage_engine"] to is_engine.
	set obj["is_stage_fuel_tank"] to is_fuel_tank.
	set obj["is_stage_load"] to is_load.
	set obj["refresh"] to kob_vessel_stage_refresh@:bind(obj).

	obj["refresh"]().
	return obj.
}

function kob_vessel_stage_refresh {
	declare local parameter obj.
	local stage_parts is list().
	local stage_engines is list().
	local stage_fuel_tanks is list().
	local stage_load is list().
	local cur_part is 0.
	for cur_part in obj["all_parts"] {
		if obj["is_stage_part"](cur_part) {
			stage_parts:add(cur_part).
			// Including to one category does not mean it should be
			// excluded from all other. Keep in mind rocket solid boosters.
			if obj["is_stage_engine"](cur_part) {
				stage_engines:add(cur_part).
			}
			if obj["is_stage_fuel_tank"](cur_part) {
				stage_fuel_tanks:add(cur_part).
			}
			if obj["is_stage_load"](cur_part) {
				stage_load:add(cur_part).
			}
		}
	}
	set obj["stage_parts"] to stage_parts.
	set obj["stage_engines"] to stage_engines.
	set obj["stage_fuel_tanks"] to stage_fuel_tanks.
	set obj["stage_load"] to stage_load.
}

