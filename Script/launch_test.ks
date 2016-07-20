@lazyglobal off.

function get_ship_max_accel {
	return ship:maxthrust / ship:mass.
}

// Calculate the target velocity for the given arguments.
// param1: current velocity
// param2: the path to cover
// return: the final velocity when the path is covered with max acceleration
function get_target_vel_VS {
	declare local parameter v0.
	declare local parameter S.
	declare local a to get_ship_max_accel().
	return sqrt(v0^2 + 2 * a * S).
}

// Calculate the time which required to cover the given arguments.
// param1: current velocity
// param2: the path to cover
// return: the time in seconds to cover the path with max acceleration
function get_time_of_path {
	declare local parameter v0.
	declare local parameter S.
	local v1 to get_target_vel_VS(v0, s).
	local g to body:mu / ((body:radius + alt:radar)^2).
	return (v1 - v0) / (get_ship_max_accel() - g).
}

clearscreen.
local target_orbit_height to 70000.
local target_orbit_vel to sqrt(body:mu / (body:radius + target_orbit_height)).
local sps to "                     ".
until alt:radar > target_orbit_height {
	local v0 to ship:verticalspeed.
	local Sr to target_orbit_height - alt:radar.
	local Vr to target_orbit_vel - ship:airspeed.
	local tH to -1.
	local tV to -1.
	if ( ship:maxthrust > 0 ) {
		set tH to get_time_of_path(v0, Sr).
		set tV to Vr / get_ship_max_accel().
	}
	print "  target height: " + target_orbit_height + " m" + sps at (0, 0).
	print "	   target vel.: " + target_orbit_vel + " m/s" + sps at (0, 1). 
	print "remained height: " + Sr + " m" + sps at (0, 2).
	print "  remained vel.: " + Vr + " m/s" + sps at (0, 3).
	print " time to height: " + tH + " sec" + sps at (0, 4).
	print "   time to vel.: " + tV + " sec" + sps at (0, 5).
}
print "target heigh reached" at (0, 6).
