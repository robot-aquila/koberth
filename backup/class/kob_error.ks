// kob_error - class to represent errors

// Constructor.
// Param1: error text message
// Return: error class instance
function kob_error {
	declare local parameter msg.

	local obj is lexicon().
	set obj["kob_error_msg"] to msg.

	// class methods
	set obj["print"] to kob_error_print@:bind(obj).

	return obj.
}

// Print error message to kOS terminal.
function kob_error_print {
	declare local parameter obj.
	print "KOB-ERR: " + obj["kob_error_msg"].
}
