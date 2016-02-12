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
function kob_warp_to_offset {
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
	local node_p is v(0, 0, 0).
	local throttle_set is 0.
	local done is false.
	local dv0 is node:deltav.
	local max_accell is 0.
	local burn_time_offset is 0.
	local dummy is 0.
	lock max_accell to maxthrust / mass.
	lock burn_time_offset to node:eta - burn_duration / 2.
	
	print "DEBUG: Node in " + node:eta + " seconds".
	print "DEBUG: Burn duration is " + burn_duration + " seconds".
	
	// TODO: Use the calculated time offset based on ship's turnaround time.
	set dummy to burn_time_offset - 45.
	print "DEBUG: Warp for " + dummy + " seconds".
	kob_warp_to_offset(dummy).
	wait dummy.
	sas off.
	lock node_p to lookdirup(node:deltav, ship:facing:topvector).
	print "DEBUG: Start steering".
	lock steering to node_p.
	wait until abs(node_p:pitch - facing:pitch) < 0.15 and abs(node_p:yaw - facing:yaw) < 0.15.
	print "DEBUG: Steereng finisged, Wait " + burn_time_offset + " seconds to start burn...".
	wait burn_time_offset.
	print "DEBUG: Start burning".
	
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
	print "DEBUG: Maneuver finished".
}

// Launch to Kerbin orbit.
// Param1: target orbit altitude km.
// Author: TempusFugit42
// See: https://www.reddit.com/r/Kos/comments/31x3o8/kos_launch_script_works_with_any_staging_to_any/
function kob_launch_to_kerbin_orbit {
	DECLARE local PARAMETER orb.
	local targetPitch is 0.
	set orb to orb*1000.
	SAS off.
	RCS on.
	lights on.
	lock throttle to 0.
	gear off.
	clearscreen.
	local lock TTW to (maxthrust+0.1)/mass.
	 // ///////////////////////////////////
	local mode is 2.
	if ALT:RADAR < 50 { set mode to 1. }
	if periapsis > 70000 { set mode to 4. }
	until mode = 0 {
		if mode = 1 {
			// launch print "T-MINUS 10 seconds". lock steering to up. wait 1.
    		print "T-MINUS  9 seconds".
    		lock throttle to 1.
    		wait 1.

    		print "T-MINUS  8 seconds".
    		wait 1.

    		print "T-MINUS  7 seco...".
    		stage.
    		wait 1.

    		print "......and here we GO, i guess".
    		wait 2.

    		clearscreen.
    		set mode to 2.
		} else if mode = 2 { // fly up to 9km
    		lock steering to up.
    		if (ship:altitude > 9000) {
        		set mode to 3.
    		}
		} else if mode = 3{ // gravity turn
    		set targetPitch to max( 8, 90 * (1 - ALT:RADAR / 70000)). 
    		lock steering to heading (90, targetPitch).

    		if SHIP:APOAPSIS >= orb {
        		set mode to 4.
        	}
    		if TTW > 20 {
        		lock throttle to 20*mass/(maxthrust+0.1).
    		}
		} else if mode = 4{ // coast to orbit
    		lock throttle to 0.
    		if (SHIP:ALTITUDE > 70000) and (ETA:APOAPSIS > 60) and (VERTICALSPEED > 0) {
        		if WARP = 0 {        
            		wait 1.        
            		SET WARP TO 3. 
            	}
        	} else if ETA:APOAPSIS < 70 {
        		SET WARP to 0.
        		lock steering to heading(90,0).
        		wait 2.
        		set mode to 5.
        	} if (periapsis > 70000) and mode = 4 {
     			if WARP = 0 {
            		wait 1.         
            		SET WARP TO 3. 
				}
			}
		} else if mode = 5 {
    		if ETA:APOAPSIS < 15 or VERTICALSPEED < 0 {
        		lock throttle to 1.
        	}
    		if (ETA:APOAPSIS > 90) and (apoapsis > orb) {
    			set mode to 4.
    		}
    		if ship:periapsis > orb {
        		lock throttle to 0.
        		set mode to 6.
    		}
		} else if mode = 6 {
    		lock throttle to 0.
    		panels on.     //Deploy solar panels
    		lights on.
    		unlock steering.
    		//set mode to 0.
    		print "WELCOME TO A STABE SPACE ORBIT!".
    		wait 2.
		}

		// this is the staging code to work with all rockets //

		if stage:number > 0 {
    		if maxthrust = 0 {
        		stage.
    		}
    		local numOut is 0.
    		local engine_list is list().
    		LIST ENGINES IN engine_list. 
    		FOR eng IN engine_list {
        		IF eng:FLAMEOUT {
            		SET numOut TO numOut + 1.
        		}
    		}
    		if numOut > 0 { stage. }.
		}

		// HERE is the code for the control pannel //

		clearscreen.
		print "LAUNCH PLAN STAGE " + mode.
		print " ".
		print "Periapsis height: " + round(periapsis, 2) + " m".
		print " Apoapsis height: " + round(apoapsis, 2) + " m".
		print " ETA to Apoapsis: " + round(ETA:APOAPSIS) + " s".
		print "   Orbital speed: " + round(velocity:orbit:MAG, 2)+ " m/s".
		print "        altitude: " + round(altitude, 2) + " m".
		print "thrust to weight: " + round((throttle*maxthrust)/mass).
		print " ".
		print "Currently on Stage: " + stage:number.
		wait 0.2.
	}
}