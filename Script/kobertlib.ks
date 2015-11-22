// Kobert - The KOS script library
// v0.2
//
// See: Kerbal Space Program - https://kerbalspaceprogram.com/
// See: KerboScript - http://ksp-kos.github.io/KOS_DOC/index.html

@lazyglobal off.

// Calculate summary ISP for currently active engines of current ship.
// Return: the ISP.
function kob_get_isp {
	local total_thrust is 0.
	local d is 0.
	local engine_list is list().
	
	list engines in engine_list.
	for eng in engine_list {
		// If ISP is zero then engine isn't activated.
		// It maybe included to other stages.
		if eng:isp > 0 {
			set total_thrust to total_thrust + eng:maxthrust.
			set d to d + (eng:maxthrust / eng:isp).
		}
	}
	if ( d > 0 ) {
		return total_thrust / d.
	}
	return 0.
}

// Calculate the burn duration for the current ship and specified delta-v.
// Based on: http://forum.kerbalspaceprogram.com/threads/40053-Estimate-the-duration-of-a-burn
// Param1: Delta-V
// Return: the burn duration seconds.
function kob_get_burn_duration {
	declare local parameter delta_v.
	local isp is kob_get_isp().
	local ve is isp * 9.81. // TODO: replace to kerbin g
	return (mass * ve / maxthrust) * (1 - (2.71828 ^ (0 - delta_v / ve))).
}

// Warp to absolute time.
// Param1: Absolute time in seconds.
function kob_warp_to {
	declare local parameter target_time.
	warpto(target_time).
}

// Warp to relative time offset.
// Param1: Time in seconds to warp to off the current time.
function kob_warp_to_relative {
	declare local parameter time_offset.
	kob_warp_to(time:seconds + time_offset).
}

// Execute a next maneuver node.
// TODO: The fair implementation based on duration of the burn.
// Thanks for ideas: http://ksp.baldev.de/kos/mtkv2/exenode.txt
//					 http://ksp-kos.github.io/KOS_DOC/tutorials/exenode.html
function kob_execute_node {
	local node is nextnode.
	local burn_duration is kob_get_burn_duration(node:deltav:mag).
	local node_p is r(0, 0, 0).
	local throttle_set is 0.
	local done is false.
	local dv0 is node:deltav.
	local max_accell is 0.
	lock max_accell to maxthrust / mass.
	
	// TODO: Use the calculated time offset based on ship's turnaround time.
	kob_warp_to_relative(node:eta + burn_duration / 2 - 45).
	sas off.
	rcs on. // TODO: Use global settings for this action.
	lock node_p to lookdirup(node:deltav, ship:facing:topvector).
	lock steering to node_p.
	// TODO: Add check of time duration.
	wait until abs(node_p:pitch - facing:pitch) < 0.1 and abs(node_p:yaw - facing:yaw) < 0.1.
	rcs off. // TODO: Use global settings for this action.
	
	wait until node:eta <= burn_duration / 2.
	
	lock throttle to throttle_set.
	until done {
		set throttle_set to min(node:deltav:mag / max_accell, 1).
		if vdot(dv0, node:deltav) < 0 {
			lock throttle to 0.
			break.
		}
		if node:deltav:mag < 0.1 {
			wait until vdot(dv0, node:deltav) < 0.5.
			lock throttle to 0.
			set done to true.
		}
	}
	unlock steering.
	unlock throttle.
}

