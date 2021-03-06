// Kobert - The KOS script library
// v0.2
//
// See: Kerbal Space Program - https://kerbalspaceprogram.com/
// See: KerboScript - http://ksp-kos.github.io/KOS_DOC/index.html

@lazyglobal off.

// KOB_OBT_* - Basic orbit parameters
declare global KOB_OBT_ORIGIN			is 0.   // An orbit central body
declare global KOB_OBT_AP         		is 1.   // Apoapsis (meters above surface)
declare global KOB_OBT_PE               is 2.   // Periapsis (meters above surface)
declare global KOB_OBT_PERIOD           is 3.   // Orbital period (seconds)
declare global KOB_OBT_INC              is 4.   // Orbit inclination (grad)
declare global KOB_OBT_ECC              is 5.   // Orbit eccentricity
declare global KOB_OBT_SMAJA            is 6.	// Semi-major axis
declare global KOB_OBT_SMINA            is 7.   // Semi-minor axis
declare global KOB_OBT_APE              is 8.   // Argument of periapsis
                                                // (grad, relative to LAN)
declare global KOB_OBT_LAN              is 9.   // Longitude of ascending node
                                                // (grad, relative to solar
                                                // prime vector)
declare global KOB_OBT_STRUCTURE_SIZE   is 10.


// KOB_HTO_* - Hohmann transfer orbit parameters.
declare global KOB_HTO_TRANSFER_TIME	is 0.	// Transfer time (seconds).
declare global KOB_HTO_ANGULAR_ALIGN	is 1.	// Angular alignment (radians)
declare global KOB_HTO_BURN1_DV			is 2.	// Delta-V for initial burn.
declare global KOB_HTO_BURN2_DV			is 3.	// Delta-V for final burn.
declare global KOB_HTO_ANGULAR_VEL_SRC	is 4.	// Angular velocity on initial
												// orbit (radians per second).
declare global KOB_HTO_ANGULAR_VEL_DST	is 5.	// Angular velocity on target
												// orbit (radians per second).


// -----------------------------------------------------------------------------
// Create an empty orbit params structure.
// Return: initialized orbit structure
function kob_obt_empty {
    local retval is list().
    local dummy is 0.
    until dummy >= KOB_OBT_STRUCTURE_SIZE {
        retval:add(0).
        set dummy to dummy + 1.
    }
    return retval.
}

// -----------------------------------------------------------------------------
// Initialize an orbit structure using orbitable object instance.
// Param1: instance of an orbitable object (celestial body or vessel)
// Return: initialized orbit structure
function kob_obt_init_byKosBody {
	declare local parameter tgt.
	if not tgt:istype("Orbitable") {
		kob_print_error("Unexpected type: " + tgt:typename()).
		return 1 / 0.
	}
	local kosObt is tgt:orbit.
	local res is kob_obt_empty().
	set res[KOB_OBT_ORIGIN] to kosObt:BODY.
	set res[KOB_OBT_AP] to kosObt:APOAPSIS.
	set res[KOB_OBT_PE] to kosObt:PERIAPSIS.
	set res[KOB_OBT_PERIOD] to kosObt:PERIOD.
	set res[KOB_OBT_INC] to kosObt:INCLINATION.
	set res[KOB_OBT_ECC] to kosObt:ECCENTRICITY.
	set res[KOB_OBT_SMAJA] to kosObt:SEMIMAJORAXIS.
	set res[KOB_OBT_SMINA] to kosObt:SEMIMINORAXIS.
	set res[KOB_OBT_APE] to kosObt:ARGUMENTOFPERIAPSIS.
	set res[KOB_OBT_LAN] to kosObt:LAN.
	return res.
}

// -----------------------------------------------------------------------------
// Get eccentricity vector of an object on orbit. Eccentricity vector points
// from focus of the orbit to periapsis. It has length equals to orbit
// eccentricity.
// Param1: position vector
// Param2: velocity vector
// Param3: the body of origin
// Return: eccentricity vector
//
// Based on: http://www.braeunig.us/space/interpl.htm
// Eccentricity vector, Eq. 5.23
//
function kob_obt_get_eccVec_byPV {
    declare local parameter posVec.
    declare local parameter velVec.
    declare local parameter originBody.
    local mu is originBody:mu.
    local r is posVec:mag. // Radius
    local v is velVec:mag. // Scalar velocity
    local eVec is (1 / mu) * (((v * v - mu / r) * posVec) - vdot(posVec, velVec) * velVec).
    return eVec.
}

// -----------------------------------------------------------------------------
// Get specific angular momentum vector using position and velocity vectors
// (Eq. 5.21)
// Param1: position vector
// Param2: velocity vector
// Return: vector of specific angular momentum
function kob_obt_get_samVec_byPV {
	declare local parameter posVec.
	declare local parameter velVec.
	return vcrs(posVec, velVec).	
}

// -----------------------------------------------------------------------------
// Get vector of ascending/descending nodes using vector of specific angular momentum
// (Eq. 5.22)
// Param1: vector of specific angular momentum
// Return: vector of ascending/descending nodes
function kob_obt_get_nodeVec_bySamVec {
    declare local parameter samVec.
    return vcrs(v(0, 1, 0), samVec):normalized.    
}

// -----------------------------------------------------------------------------
// Get vector of ascending/descending nodes using position and velocity vectors
// (Eq. 5.22)
// Param1: position vector
// Param2: velocity vector
// Return: vector of ascending/descending nodes
function kob_obt_get_nodeVec_byPV {
	declare local parameter posVec.
	declare local parameter velVec.
	local samVec is kob_obt_get_samVec_byPV(posVec, velVec).
	return kob_obt_get_nodeVec_bySamVec(samVec).
}

// -----------------------------------------------------------------------------
// Get orbit inclination using vector of specific angular momentum
// (Eq. 5.26)
// Param1: vector of specific angular momentum
// Return: orbit inclination degrees
function kob_obt_get_inclination_bySamVec {
	declare local parameter samVec.
	return arccos(-samVec:y / samVec:mag).
}

// -----------------------------------------------------------------------------
// Get orbit inclination using position and velocity vectors
// Param1: position vector
// Param2: velocity vector
// Return: orbit inclination degrees
function kob_obt_get_inclination_byPV {
	declare local parameter posVec, velVec.
	local samVec is kob_obt_get_samVec_byPV(posVec, velVec).
	return kob_obt_get_inclination_bySamVec(samVec).
}

// -----------------------------------------------------------------------------
// Initialize an orbit structure using position and velocity vectors.
// Param1 - position vector
// Param2 - velocity vector
// Param3 - the body of origin
// Return: initialized orbit structure
function kob_obt_init_byPV {
    declare local parameter posVec.
    declare local parameter velVec.
    declare local parameter originBody.

    local mu is originBody:mu.
    local r is posVec:mag. // Radius
    local v is velVec:mag. // Scalar velocity
    local h is kob_obt_get_samVec_byPV(posVec, velVec).
    local i is kob_obt_get_inclination_bySamVec(h).
    local nodeVec is kob_obt_get_nodeVec_bySamVec(h).
    local eccVec is kob_obt_get_eccVec_byPV(posVec, velVec, originBody).
    local e is eccVec:mag.
    local a is 1 / (2 / r - v * v / mu).
    local b is 0.
    if e >= 1 {
        set b to a * sqrt(e * e - 1). // Semi-minor axis
    } else {
        set b to a * sqrt(1 - e * e). // Semi-minor axis
    }
    local aop is arccos(vdot(nodeVec, eccVec) / e).
    local lan is vang(nodeVec, solarprimevector).
    if eccVec:y < 0 {
        set aop to 360 - aop.
        set lan to 360 - lan.
    }
    local res is kob_obt_empty().
    set res[KOB_OBT_ORIGIN] to originBody.
    set res[KOB_OBT_INC] to i.
    set res[KOB_OBT_ECC] to e.
    set res[KOB_OBT_SMAJA] to a.
    set res[KOB_OBT_SMINA] to b.
    set res[KOB_OBT_PE] to a * (1 - e) - originBody:radius.
    set res[KOB_OBT_AP] to a * (1 + e) - originBody:radius.
    set res[KOB_OBT_APE] to aop.
    set res[KOB_OBT_LAN] to lan.
    set res[KOB_OBT_PERIOD] to constant():PI * 2 * sqrt(abs(a)^3 / mu).
    return res.
}

// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// Calculate the Hohmann Transfer Orbit parameters.
// Based on: http://en.wikipedia.org/wiki/Hohmann_transfer_orbit
// http://forum.kerbalspaceprogram.com/threads/16511-Tutorial-Interplanetary-How-To-Guide
// https://docs.google.com/document/d/1IX6ykVb0xifBrB4BRFDpqPO6kjYiLvOcEo3zwmZL0sQ/edit
// Param1: Radius of an initial orbit (from center of origin body)
// Param2: Radius of a target orbit (same as r1)
// Param3: Gravitational parameter of origin body (Mu)
// Return: List of maneuver parameters.
// See KOB_HTO_* constants to decode and access the result.
function kob_hto_co_get_params {
	declare local parameter r1,r2,gravParam.
	local pi is constant():pi.
	local pi2 is 2*pi.
	local tpAV1 is sqrt(gravParam/r1^3).
	local tpAV2 is sqrt(gravParam/r2^3).
	local tpT is pi*sqrt((r1+r2)^3/(8*gravParam)).
	
	// method 0
	// http://en.wikipedia.org/wiki/Hohmann_transfer_orbit
	local tpA is pi-tpAV2*tpT.
	
	// method 1
	// http://forum.kerbalspaceprogram.com/threads/16511-Tutorial-Interplanetary-How-To-Guide
	//local tpA is pi-sqrt(gravParam/r2)*tpT/r2.
	
	// method 2
	// https://docs.google.com/document/d/1IX6ykVb0xifBrB4BRFDpqPO6kjYiLvOcEo3zwmZL0sQ/edit
	//local tpA is pi-pi2*(0.5*(((r1+r2)/(2*r2))^1.5)).
	
	local tpDV1 is sqrt(gravParam/r1)*(sqrt(2*r2/(r1+r2))-1).
	local tpDV2 is sqrt(gravParam/r2)*(1-sqrt(2*r1/(r1+r2))).

	local retval is list().
	retval:add(tpT). // KOB_HTO_TRANSFER_TIME
	retval:add(tpA). // KOB_HTO_ANGULAR_ALIGN
	retval:add(tpDV1). // KOB_HTO_BURN1_DV
	retval:add(tpDV2). // KOB_HTO_BURN2_DV
	retval:add(tpAV1). // KOB_HTO_ANGULAR_VEL_SRC
	retval:add(tpAV2). // KOB_HTO_ANGULAR_VEL_DST
	return retval.
}

// -----------------------------------------------------------------------------
// Calculate a phase angle between two objects on different circular orbits.
// Param1: Object position vector of a source orbit (i.g. body:position*-1)
// Param2: Object velocity vector of a source orbit (i.g. velocity:orbit)
// Param3: Object position vector of a target orbit (i.g. target:position-body:position)
// Param4: Object velocity vector of a target orbit (i.g. target:velocity)
// Return: phase angle in radians [0,2pi) when source on lower or (-2pi,0] when source on higher orbit
function kob_hto_co_get_phase_angle {
	declare local parameter srcPos,srcVel,dstPos,dstVel.
	local pi is constant():pi.
	local deg2rad is pi/180.
	
	// method 0
	local phaseAngle is vang(srcPos,dstPos)*deg2rad.
	
	// method 1
	//local phaseAngle is arccos(vdot(srcPos,dstPos)/(srcPos:mag*dstPos:mag))*deg2rad.
	
	if vdot(srcVel,srcPos-dstPos)>0 { set phaseAngle to 2*pi-phaseAngle. }
	if srcPos:mag>dstPos:mag { set phaseAngle to -2*pi+phaseAngle. }
	return phaseAngle.
}

// -----------------------------------------------------------------------------
// Calculate default orbit radius for relay sattelyte.
// Param1: Target body
// Return: Radius from center of body (meters).
function kob_sat_obt_get_default_radius {
	declare local parameter tgt.
	if tgt:typename() <> "Body" {
		kob_print_error("Target type must be Body but " + tgt:typename()).
		return 1 / 0.
	}
	local a is tgt:radius.
	print "a for " + tgt + " is " + a.
	if tgt:atm:exists {
		set a to a + tgt:atm:height.
	}
	set a to a * 1.1. // +10%
	print "a for " + tgt + " is " + a.
	// c = a / sin(A)
	return a / sin(30).
}

// -----------------------------------------------------------------------------
// Calculate default altitude for relay satellite.
// Param1: Target body
// Return: Altitude above ASL (meters).
function kob_sat_obt_get_default_alt {
	declare local parameter tgt.
	local r is kob_sat_obt_get_default_radius(tgt).
	return r - tgt:radius.
}

// -----------------------------------------------------------------------------
// Print error message.
// Param1: Message to print.
function kob_print_error {
	declare local parameter msg.
	print "> KOB-ERR".
	print "> KOB-ERR " + msg.
	print "> KOB-ERR Prepare to terminate!".
	print "> KOB-ERR".
}

// -----------------------------------------------------------------------------
// Warp to absolute time.
// Param1: Absolute time in seconds.
function kob_warp_to {
	declare local parameter target_time.
	warpto(target_time).
}

// -----------------------------------------------------------------------------
// Warp to relative time offset.
// Param1: Time in seconds to warp to off the current time.
function kob_warp_to_offset {
	declare local parameter time_offset.
	kob_warp_to(time:seconds + time_offset).
}

// Format time in seconds to human-readable string.
// Param1: time in seconds
// Return: time in human-readable format
function kob_fmt_time {
	declare local parameter time2format. // time in seconds
	// 1 year = ??? days = ????????????????????????????
	//            1  day = 6 hours = 360 mins = 21600 s
	//                     1  hour =  60 mins =  3600 s
	//                                1  min =     60 s
	
	local fmtD is floor(time2format/21600).
	local x is time2format-fmtD*21600.
	local fmtH is floor(x/3600).
	set x to x-fmtH*3600.
	local fmtM is floor(x/60).
	set x to x-fmtM*60.
	local fmtS is floor(x).
	
	local fmtTime is "D".
	if fmtD<100 { set fmtTime to fmtTime+"0". }
	if fmtD< 10 { set fmtTime to fmtTime+"0". }
	set fmtTime to fmtTime+fmtD+",".
	if fmtH< 10 { set fmtTime to fmtTime+"0". }
	set fmtTime to fmtTime+fmtH+":".
	if fmtM< 10 { set fmtTime to fmtTime+"0". }
	set fmtTime to fmtTime+fmtM+":".
	if fmtS< 10 { set fmtTime to fmtTime+"0". }
	return fmtTime+fmtS.
}

// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
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
    		print "WELCOME TO A STABLE SPACE ORBIT!".
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

// -----------------------------------------------------------------------------
// Print orbit info starting at specified position.
// Param1: starting column
// Param2: starting row
// Param3: orbit structure (KOB format)
function kob_obt_print_at {
	declare local parameter col, row, kobt.
	local prec is 4.
	local sps is "             ".

	print round(kobt[KOB_OBT_PE], prec)			+ sps at (col, row).
	print round(kobt[KOB_OBT_AP], prec)			+ sps at (col, row + 1).
	print round(kobt[KOB_OBT_INC], prec)		+ sps at (col, row + 2).
	print round(kobt[KOB_OBT_ECC], prec)		+ sps at (col, row + 3).
	print round(kobt[KOB_OBT_SMAJA], prec)		+ sps at (col, row + 4).
	print round(kobt[KOB_OBT_SMINA], prec)		+ sps at (col, row + 5).
	print round(kobt[KOB_OBT_APE], prec)		+ sps at (col, row + 6).
	print round(kobt[KOB_OBT_LAN], prec)        + sps at (col, row + 7).
	print kob_fmt_time(kobt[KOB_OBT_PERIOD])	+ sps at (col, row + 8).
	print kobt[KOB_OBT_ORIGIN]:NAME				+ sps at (col, row + 9). 
}

// -----------------------------------------------------------------------------
// Demo: display the orbital parameters of the current vessel.
function kob_demo_obt_params_of_current_vessel {
	clearscreen.
	if terminal:width < 80 { set terminal:width to 80. }

	local sps is "             ".
	local col1 is 19.
	local col2 is 34.
	local col3 is 49.
	local col4 is 64.
	print "-------------------------------------------"+sps at (0, 0).
	print " Orbit params demo.                        "+sps at (0, 1).
	print " Vessel: " + ship:name + "                 "+sps at (0, 2).
	print "==========================================="+sps at (0, 3).
	print "                                           "+sps at (0, 4).
	print "by KOB(PV)" at (col1, 4).
	print "by KOS"  at (col2, 4).
	print "        Periapsis:                         "+sps at (0, 5).
	print "         Apoapsis:                         "+sps at (0, 6).
	print "      Inclination:                         "+sps at (0, 7).
	print "     Eccentricity:                         "+sps at (0, 8).
	print "  Semi-major axis:                         "+sps at (0, 9).
	print "  Semi-minor axis:                         "+sps at (0,10).
	print "   Argument of PE:                         "+sps at (0,11).
    print "              LAN:                         "+sps at (0,12).
	print "   Orbital period:                         "+sps at (0,13).
	print "           Origin:                         "+sps at (0,14).
	print "-------------------------------------------"+sps at (0,15).
	print " Press AG9 to exit. If AG is not working   "+sps at (0,16).
	print " check the kOS window it must be unfocused."+sps at (0,17).
	print " AG is not working in the map mode.        "+sps at (0,18).
	print "-------------------------------------------"+sps at (0,19).
	set ag9 to false.
	
	// Don't use the locks cuz is possible to face inconsistent state at calculation
	//lock myPosition to ship:position - ship:body:position.
	//lock myVelocity to velocity:orbit.
	local lock kosOrbit to ship:obt.

	local exit is 0.
	if ag9="True" { toggle ag9. }
	on ag9 {
    	set exit to 1.
	}
	
	local lock origin to ship:body:position.
	//set origin to v(0,0,0).
	local lock edge to kosOrbit:apoapsis + body:radius.
	local drawAngularMomentum is VecDrawArgs(origin, v(1,0,0), rgb(1,0,0), "Angular Momentum", 1, true).
	local drawNodeVector is VecDrawArgs(origin, v(1,0,0), rgb(0,1,0), "Ascending node", 1, true).
	local drawEccVector is VecDrawArgs(origin, v(1,0,0), rgb(0,0,1), "Eccentricity vector", 1, true).
	local drawSolPrime is VecDrawArgs(origin, solarprimevector, rgb(1, 1, 0), "Solar Prime vector", 1, true).
	
	local xAxis is VECDRAWARGS(origin , V(edge,0,0), RGB(1.0,0.5,0.5), "X axis", 1, TRUE ).
	local yAxis is VECDRAWARGS(origin, V(0,edge,0), RGB(0.5,1.0,0.5), "Y axis", 1, TRUE ).
	local zAxis is VECDRAWARGS(origin, V(0,0,edge), RGB(0.5,0.5,1.0), "Z axis", 1, TRUE ).
	
	until exit=1 {
	    local myPosition is ship:position - ship:body:position.
	    local myVelocity is velocity:orbit.
        local myOrbit is kob_obt_init_byPV(myPosition, myVelocity, body).
		local myOrbitByKOS is kob_obt_init_byKosBody(ship).
	
		local samVec to kob_obt_get_samVec_byPV(myPosition, myVelocity).
	    //set drawAngularMomentum:vec to myOrbit[KOB_OBT_SP_ANG_MOMENTUM]:normalized * edge.
		set drawAngularMomentum:vec to samVec:normalized * edge.
	    set drawAngularMomentum:start to origin.
		
		local nodeVec to kob_obt_get_nodeVec_byPV(myPosition, myVelocity).
	    set drawNodeVector:vec to nodeVec * edge.
	    set drawNodeVector:start to origin.
	    
	    local eVec to kob_obt_get_eccVec_byPV(myPosition, myVelocity, body).
	    set drawEccVector:vec to eVec:normalized * (kosOrbit:periapsis + body:radius).
	    set drawEccVector:start to origin.
	    
	    set drawSolPrime:vec to solarprimevector * edge * 2.
	    set drawSolPrime:start to origin.
	    
	    set xAxis:start to origin.
	    set yAxis:start to origin.
	    set zAxis:start to origin.

	    
	    local row is 5.
		kob_obt_print_at(col1, row, myOrbit).
		kob_obt_print_at(col2, row, myOrbitByKOS).
	    
	    wait 1.
	}
	set drawAngularMomentum:show to false.
	set drawNodeVector:show to false.
	set drawEccVector:show to false.
	set drawSolPrime:show to false.
	set xAxis:show to false.
	set yAxis:show to false.
	set zAxis:show to false.
}

