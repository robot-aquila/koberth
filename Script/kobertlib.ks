// Kobert - The KOS script library
// v0.2
//
// See: Kerbal Space Program - https://kerbalspaceprogram.com/
// See: KerboScript - http://ksp-kos.github.io/KOS_DOC/index.html

@lazyglobal off.

// Initialize a field constants to easy access to the orbit structure fields.
// ALWAYS use those constants to get access to the elements of the orbit.
// It will make your program stable and independent of the possible
// future changes of the structure.
declare global KOB_OBT_ORIGIN			is 0.
declare global KOB_OBT_AP         		is 1.
declare global KOB_OBT_PE             	is 2.
declare global KOB_OBT_IS_HYPERBOLIC  	is 3.  // Boolean true/false.
declare global KOB_OBT_PERIOD         	is 4.
declare global KOB_OBT_INCL           	is 5.
declare global KOB_OBT_ECC            	is 6.
declare global KOB_OBT_SEMIMAJOR_AXIS 	is 7.
declare global KOB_OBT_SEMIMINOR_AXIS 	is 8.
declare global KOB_OBT_ARG_OF_PE      	is 9.
declare global KOB_OBT_LAN            	is 10.
declare global KOB_OBT_SP_OBT_ENERGY  	is 11.  // Specific orbital energy
// Please note: The following parameters may be undefined (zeroed)
// if the just orbit is given without a body on it.
declare global KOB_OBT_TRUE_ANOMALY     is 12.  // True anomaly (degrees)
declare global KOB_OBT_SP_ANG_MOMENTUM  is 13.  // Specific angular momentum (vector)
declare global KOB_OBT_STRUCTURE_SIZE   is 14.

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
// Fill the orbit params structure from position and velocity vectors.
// Param1 - position vector
// Param2 - velocity vector
// Param3 - the body of origin
// Return: initialized orbit structure
// 
// The equations mostly from this page (based on):
//
//      http://www.braeunig.us/space/index.htm#elements
//
// NOTE: Just one very important moment.
// We have many great formulae from the site.
// But all of them  consider that the Z-axis is vertical.
// Actually the Y-axis is vertical ingame.
//
//      http://ksp-kos.github.io/KOS_DOC/math/ref_frame.html
//
// To avoid any difficulties just swap Y and Z component before calculations
// 
// Known issues: 
// - LAN angle is mismatched with the KOS-given value. 
//   Looking to vectors, value calculated by the library is correct.
//   lan_ingame_offset:
//                  LIB     KOS     DIF
//   Kerbin:
//      Y1D106      247     308     299
//      Y1D106       86     147     299
//      Y1D106      320      21     299
//      Y1D106      192     308     244
//      Y1D107       53     177     236     hyperbolic
//   Mun:
//      Y1D107      124     248     236     hyperbolic
//      Y1D107      124     248     236
//   Kerbol:
//      Y1D106      335      85     250
//
function kob_obt_from_pos_and_vel {
	declare local parameter posVec.
	declare local parameter velVec.
	declare local parameter originBody.

	// Swap Y and Z coordinate
	set posVec to v(posVec:x, posVec:z, posVec:y).
	set velVec to v(velVec:x, velVec:z, velVec:y).
	local mu is originBody:mu.
	local r is posVec:mag. // Radius
	local v is velVec:mag. // Scalar velocity
	local h is vcrs(posVec, velVec). // Specific angular momentum, Eq. 5.21
	local i is arccos(h:z / h:mag). // Inclination, Eq. 5.26
	local nodeVec is v(-1 * h:y, h:x, 0):normalized. // Ascending node, Eq. 5.22


	local hyperbolic is false.
	// Eccentricity vector, Eq. 5.23
	local a is 1 / (2 / r - v * v / mu). // Semi-major axis, Eq. 5.24
	local eVec is (1 / mu) * (((v * v - mu / r) * posVec) - vdot(posVec, velVec) * velVec).
	local e is eVec:mag. // Eccentricity, Eq. 5.25
	local b is 0.
	if e >= 1 {
	    set hyperbolic to true.
	    set b to a * sqrt(e * e - 1). // Semi-minor axis
	} else {
	    set b to a * sqrt(1 - e * e). // Semi-minor axis
	}
	
	// Note: the nodeVec is unit vector. Dividing by magnitude isn't needed.


	// Longitude of ascending node, Eq. 5.27
	local lan is arccos(nodeVec:x).
	if nodeVec:y < 0 { set lan to 360 - lan. }
	local aop is arccos(vdot(nodeVec, eVec) / e). // Argument of periapsis, Eq. 5.28
	if eVec:z < 0 { set aop to 360 - aop. }
	
	local trueAnomaly is arccos((eVec * posVec) / (e * r)). // True anomaly, Eq. 5.29
	if posVec * velVec < 0 { set trueAnomaly to 360 - trueAnomaly. }

	local retval is kob_obt_empty.
	set retval[KOB_OBT_ORIGIN] to originBody.
	set retval[KOB_OBT_IS_HYPERBOLIC] to hyperbolic.
	set retval[KOB_OBT_INCL] to i.
	set retval[KOB_OBT_ECC] to e.
	set retval[KOB_OBT_SEMIMAJOR_AXIS] to a.
	set retval[KOB_OBT_SEMIMINOR_AXIS] to b.
	set retval[KOB_OBT_PE] to a * (1 - e) - originBody:radius.
	set retval[KOB_OBT_AP] to a * (1 + e) - originBody:radius.
	set retval[KOB_OBT_ARG_OF_PE] to aop.
	set retval[KOB_OBT_LAN] to lan.
	// http://en.wikipedia.org/wiki/Specific_orbital_energy
	set retval[KOB_OBT_SP_OBT_ENERGY] to -1 * mu / (a * 2).
	// http://en.wikipedia.org/wiki/Orbital_period
	set retval[KOB_OBT_PERIOD] to constant():PI * 2 * sqrt(abs(a)^3 / mu).
	set retval[KOB_OBT_TRUE_ANOMALY] to trueAnomaly.
	set retval[KOB_OBT_SP_ANG_MOMENTUM] to v(h:x, h:z, h:y). // swap Y/Z
	return retval.
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
	print "by Lib" at (col1, 4).
	print "by KOS" at (col2, 4).
	print "err(max)" at (col3, 4).
	print "err(cur)" at (col4, 4).
	print "    Is hyperbolic:                         "+sps at (0, 5).
	print "        Periapsis:                         "+sps at (0, 6).
	print "         Apoapsis:                         "+sps at (0, 7).
	print "      Inclination:                         "+sps at (0, 8).
	print "     Eccentricity:                         "+sps at (0, 9).
	print "  Semi-major axis:                         "+sps at (0,10).
	print "  Semi-minor axis:                         "+sps at (0,11).
	print "              LAN:                         "+sps at (0,12).
	print "   Argument of PE:                         "+sps at (0,13).
	print "     True Anomaly:                         "+sps at (0,14).
	print "   Orbital period:                         "+sps at (0,15).
	print "           Origin:                         "+sps at (0,16).
	print "Sp.orbital energy:                         "+sps at (0,17).
	print "Sp. ang. momentum:                         "+sps at (0,18).
	print "-------------------------------------------"+sps at (0,19).
	print " Press AG9 to exit. If AG is not working   "+sps at (0,20).
	print " check the kOS window it must be unfocused."+sps at (0,21).
	print " AG is not working in the map mode.        "+sps at (0,22).
	print "-------------------------------------------"+sps at (0,23).
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
	
	local xAxis is VECDRAWARGS(origin , V(edge,0,0), RGB(1.0,0.5,0.5), "X axis", 1, TRUE ).
	local yAxis is VECDRAWARGS(origin, V(0,edge,0), RGB(0.5,1.0,0.5), "Y axis", 1, TRUE ).
	local zAxis is VECDRAWARGS(origin, V(0,0,edge), RGB(0.5,0.5,1.0), "Z axis", 1, TRUE ).
	
		
	local prec is 4. // precision of the rounding
	
	local errSemiMajorAxis is 0.
	local errSemiMinorAxis is 0.
	local errPeriapsis is 0.
	local errApoapsis is 0.
	until exit=1 {
	    local myPosition is ship:position - ship:body:position.
	    local myVelocity is velocity:orbit.
	    local myOrbit is kob_obt_from_pos_and_vel(myPosition, myVelocity, body).
	
	    set drawAngularMomentum:vec to myOrbit[KOB_OBT_SP_ANG_MOMENTUM]:normalized * edge.
	    set drawAngularMomentum:start to origin.
	    // WARN: nodeVec was in old version (Ascending Node)
	    //set drawNodeVector:vec to v(nodeVec:x, nodeVec:z, nodeVec:y) * edge.
	    //set drawNodeVector:start to origin.
	    // WARN: eVec was in old version (Eccentricity)
	    //set drawEccVector:vec to v(eVec:x, eVec:z, eVec:y):normalized * (kosOrbit:periapsis + body:radius).
	    //set drawEccVector:start to origin.
	    set xAxis:start to origin.
	    set yAxis:start to origin.
	    set zAxis:start to origin.
	    
	    local row is 5.
		local dummy is "".
		local err is 0.
			
	    set dummy to "N". if myOrbit[KOB_OBT_IS_HYPERBOLIC] { set dummy to "Y". }
	    print dummy at(col1, row).
	    set dummy to "N". if kosOrbit:ECCENTRICITY >= 1 { set dummy to "Y". }
	    print dummy at(col2, row).
	    set row to row + 1.

		set err to abs(myOrbit[KOB_OBT_PE] - kosOrbit:PERIAPSIS).
		if err > errPeriapsis { set errPeriapsis to err. }  	
	    print round(myOrbit[KOB_OBT_PE], prec) + sps at (col1, row).
	    print round(kosOrbit:PERIAPSIS, prec) + sps at (col2, row).
	    print round(errPeriapsis, prec) + sps at (col3, row).
	    print round(err, prec) + sps at (col4, row).
	    set row to row + 1.
	
		set err to abs(myOrbit[KOB_OBT_AP] - kosOrbit:APOAPSIS).
		if err > errApoapsis { set errApoapsis to err. }
	    print round(myOrbit[KOB_OBT_AP], prec) + sps at (col1, row).
	    print round(kosOrbit:APOAPSIS, prec) + sps at (col2, row).
	    print round(errApoapsis, prec) + sps at (col3, row).
	    print round(err, prec) + sps at (col4, row).
	    set row to row + 1.
	
	    print round(myOrbit[KOB_OBT_INCL], prec) + sps at (col1, row).
	    print round(kosOrbit:INCLINATION, prec) + sps at (col2, row).
	    set row to row + 1.
	
	    print round(myOrbit[KOB_OBT_ECC], prec) + sps at (col1, row).
	    print round(kosOrbit:ECCENTRICITY, prec) + sps at (col2, row).
	    set row to row + 1.
	
		set err to abs(myOrbit[KOB_OBT_SEMIMAJOR_AXIS] - kosOrbit:SEMIMAJORAXIS).
		if err > errSemiMajorAxis { set errSemiMajorAxis to err. }
	    print round(myOrbit[KOB_OBT_SEMIMAJOR_AXIS], prec) + sps at (col1, row).
	    print round(kosOrbit:SEMIMAJORAXIS, prec) + sps at (col2, row).
	    print round(errSemiMajorAxis, prec) + sps at (col3, row).
	    print round(err, prec) + sps at (col4, row).
	    set row to row + 1.
	
		set err to abs(myOrbit[KOB_OBT_SEMIMINOR_AXIS] - kosOrbit:SEMIMINORAXIS).
		if err > errSemiMinorAxis { set errSemiMinorAxis to err. }
	    print round(myOrbit[KOB_OBT_SEMIMINOR_AXIS], prec) + sps at (col1, row).
	    print round(kosOrbit:SEMIMINORAXIS, prec) + sps at (col2, row).
	    print round(errSemiMinorAxis, prec) + sps at (col3, row).
	    print round(err, prec) + sps at (col4, row).
	    set row to row + 1.
	
	    print round(myOrbit[KOB_OBT_LAN], prec) + sps at (col1, row).
	    print round(kosOrbit:LAN, prec) + sps at (col2, row).
	    set row to row + 1.
	
	    print round(myOrbit[KOB_OBT_ARG_OF_PE], prec) + sps at (col1, row).
	    print round(kosOrbit:ARGUMENTOFPERIAPSIS, prec) + sps at (col2, row).
	    set row to row + 1.
	
	    print round(myOrbit[KOB_OBT_TRUE_ANOMALY], prec) + sps at (col1, row).
	    print round(kosOrbit:TRUEANOMALY, prec) + sps at (col2, row).
	    set row to row + 1.
	
	    print kob_fmt_time(myOrbit[KOB_OBT_PERIOD]) + sps at (col1, row).
	    print kob_fmt_time(kosOrbit:PERIOD) + sps at (col2, row).
	    set row to row + 1.
	
	    print myOrbit[KOB_OBT_ORIGIN]:NAME + sps at(col1, row).
	    print "---" at (col2, row).
	    set row to row + 1.
	
	    print round(myOrbit[KOB_OBT_SP_OBT_ENERGY], prec) + sps at(col1, row).
	    print "---" at (col2, row).
	    set row to row + 1.
	
	    print round(myOrbit[KOB_OBT_SP_ANG_MOMENTUM]:mag, prec) + sps at(col1, row).
	    print "---" at (col2, row).
	    set row to row + 1.
	    
	    wait 1.
	}
	set drawAngularMomentum:show to false.
	set drawNodeVector:show to false.
	set drawEccVector:show to false.
	set xAxis:show to false.
	set yAxis:show to false.
	set zAxis:show to false.
}