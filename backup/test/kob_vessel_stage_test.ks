// kob_vessel_state_test - unit test of kob_vessel_stage class

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

