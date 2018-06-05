// kob_printer is a class to help printing to terminal
runoncepath("class/kobert/kob_error").

// Constructor - create new printer.
// Param1: x printing position to start from. Optional. If omitted then start from 0.
// Param2: y printing position to start from. Optional. If omitted then start from 0.
// Return: printer class instance
function kob_printer {
	declare local parameter x is 0, y is 0.

	local obj is lexicon().
	// class attributes
	set obj["start_x"] to x.
	set obj["start_y"] to y.
	set obj["cur_x"] to x.
	set obj["cur_y"] to y.
	set obj["default_width"] to 12.

	// class methods
	set obj["reset_position"] to kob_printer_reset_position@:bind(obj).
	set obj["ensure_width"] to kob_printer_ensure_width@:bind(obj).
	set obj["print_text"] to kob_printer_print_text@:bind(obj).
	set obj["print_number"] to kob_printer_print_number@:bind(obj).
	set obj["shift_right"] to kob_printer_shift_right@:bind(obj).
	set obj["shift_down"] to kob_printer_shift_down@:bind(obj).
	set obj["print_and_shift_right"] to kob_printer_print_and_shift_right@:bind(obj).
	set obj["next_row"] to kob_printer_next_row@:bind(obj).
	set obj["next_line"] to kob_printer_next_row@:bind(obj).

	return obj.
}

function kob_printer_reset_position {
	declare local parameter obj.
	set obj["cur_x"] to obj["start_x"].
	set obj["cur_y"] to obj["start_y"].
}

function kob_printer_ensure_width {
	declare local parameter obj, width is -1.
	if width < 1 {
		set width to obj["default_width"].
	}
	if width < 1 {
		return kob_error("KOB printer unable to use such field width: " + width).
	}
	return width.
}

function kob_printer_print_text {
	declare local parameter obj, text, width is -1.
	set width to obj["ensure_width"](width).
	if text:length > width {
		set text to text:substring(0, width).
	} else if text:length < width {
		set text to text:padleft(width).
	}
	obj["print_and_shift_right"](text).
}

function kob_printer_print_number {
	declare local parameter obj, number, scale is 2, width is -1.
	set width to obj["ensure_width"](width).
	set number to "" + round(number, scale).
	if number:length > width {
		set number to "".
		from { local i is width. } until i = 0 step { set i to i - 1. } do {
			set number to number + "X".
		}
	} else if number:length < width {
		set number to number:padleft(width).
	}
	obj["print_and_shift_right"](number).
}

function kob_printer_shift_right {
	declare local parameter obj, shift_value.
	set obj["cur_x"] to obj["cur_x"] + shift_value.
}

function kob_printer_shift_down {
	declare local parameter obj, shift_value.
	set obj["cur_y"] to obj["cur_y"] + shift_value.
	set obj["cur_x"] to obj["start_x"].
}

function kob_printer_print_and_shift_right {
	declare local parameter obj, text.
	print text at (obj["cur_x"], obj["cur_y"]).
	obj["shift_right"](text:length).
}

function kob_printer_next_row {
	declare local parameter obj.
	obj["shift_down"](1).
}

