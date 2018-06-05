// kob_atm_ascent - class to show atmosperic ascent variables
runoncepath("class/kobert/kob_printer").

// Constructor.
// Param1: instance of kob_atm_ascent class
// Param2: x coordinate of table on terminal display
// Param3: y coordinate of table on terminal display
// Return: table instance
function kob_atm_ascent_table {
	declare local parameter ascent, x, y.

	local obj is lexicon().
	set obj["ascent"] to ascent.
	set obj["printer"] to kob_printer(x, y).

	// class methods
	set obj["update"] to kob_atm_ascent_table_update@:bind(obj).

	return obj.
}

// Display table in terminal window.
function kob_atm_ascent_table_update {
	declare local parameter obj.

	local ascent is obj["ascent"].
	local printer is obj["printer"].

	printer["reset_position"]().

	printer["print_text"]("Q(cur)").
	printer["print_text"]("Q(lim)").
	printer["print_text"]("Q(factor)").
	printer["next_row"]().

	printer["print_number"](ascent["q_cur"], 2).
	printer["print_number"](ascent["q_lim"], 2).
	printer["print_number"](ascent["q_factor"], 2).
	printer["next_row"]().

	printer["print_text"]("Vel(cur)").
	printer["print_text"]("Vel(lim)").
	printer["print_text"]("").
	printer["next_row"]().

	printer["print_number"](ascent["vel_cur"], 2).
	printer["print_number"](ascent["vel_lim"], 2).
	printer["print_text"]("").
	printer["next_row"]().

	printer["print_text"]("Mass kg.").
	printer["print_text"]("g(local)").
	printer["print_text"]("accel").
	printer["next_row"]().
	
	printer["print_number"](ascent["ship_mass_kg"]).
	printer["print_number"](ascent["ship_local_g"]).
	printer["print_number"](ascent["ship_acc"]).	
}
