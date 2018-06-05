// kob_vessel - class to represent a vessel

// Constructor.
// Param1: kOS vessel instance
// Return: kob_vessel class instance
function kob_error {
	declare local parameter vess.

	local obj is lexicon().
	set obj["vessel"] to vess.
	set obj["stages"] to list().

	// class methods
	//set obj["print"] to kob_error_print@:bind(obj).

	return obj.
}

// Print error message to kOS terminal.
//function kob_error_print {
//	declare local parameter obj.
//	print "KOB-ERR: " + obj["kob_error_msg"].
//}
