clearscreen.
if terminal:width < 80 { set terminal:width to 80. }

set sps to "             ".
set col1 to 19.
set col2 to 44.
print "-------------------------------------------"+sps at (0, 0).
print " Orbit params demo.                        "+sps at (0, 1).
print " Vessel: " + ship:name + "                 "+sps at (0, 2).
print "==========================================="+sps at (0, 3).
print "                                           "+sps at (0, 4).
print "by Lib" at (col1, 4). print "by KOS" at (col2, 4).
print "    Is hyperbolic:                         "+sps at (0, 5).
print "        Periapsis:                         "+sps at (0, 6).
print "         Apoapsis:                         "+sps at (0, 7).
print "      Inclination:                         "+sps at (0, 8).
print "     Eccentricity:                         "+sps at (0, 9).
print "  Semi-major axis:                         "+sps at (0,10).
print "  Semi-minor axis:                         "+sps at (0,11).
print "              LAN:                         "+sps at (0,12).
print "   Argument of PE:                         "+sps at (0,13).
print "-------------------------------------------"+sps at (0,14).
print " Press AG9 to exit. If AG is not working   "+sps at (0,15).
print " check the kOS window it must be unfocused."+sps at (0,16).
print " AG is not working in the map mode.        "+sps at (0,17).
print "-------------------------------------------"+sps at (0,18).

// Don't use the locks cuz is possible to face inconsistent state at calculation
//lock myPosition to ship:position - ship:body:position.
//lock myVelocity to velocity:orbit.
lock kosOrbit to ship:obt.

set exit to 0.
if ag9="True" { toggle ag9. }
on ag9 {
    set exit to 1.
}

//lock origin to ship:body:position.
set origin to v(0,0,0).
set edge to 2000000.
set drawAngularMomentum to VecDrawArgs(origin, v(1,0,0), rgb(1,0,0), "Angular Momentum", 1, true).
set drawNodeVector to VecDrawArgs(origin, v(1,0,0), rgb(0,1,0), "Ascending node", 1, true).
set drawEccVector to VecDrawArgs(origin, v(1,0,0), rgb(0,0,1), "Eccentricity vector", 1, true).

set xAxis to VECDRAWARGS(origin , V(edge,0,0), RGB(1.0,0.5,0.5), "X axis", 1, TRUE ).
set yAxis to VECDRAWARGS(origin, V(0,edge,0), RGB(0.5,1.0,0.5), "Y axis", 1, TRUE ).
set zAxis to VECDRAWARGS(origin, V(0,0,edge), RGB(0.5,0.5,1.0), "Z axis", 1, TRUE ).

set prec to 4. // precision of the rounding
until exit=1 {
    set myPosition to ship:position - ship:body:position.
    set myVelocity to velocity:orbit.
    run lib_obtparams_from_pos_and_vel(myPosition, myVelocity, body:mu).
    set myOrbit to retval.

    set drawAngularMomentum:vec to v(h:x, h:z, h:y):normalized * edge.
    set drawAngularMomentum:start to origin.
    set drawNodeVector:vec to v(nodeVec:x, nodeVec:z, nodeVec:y) * edge.
    set drawNodeVector:start to origin.
    set drawEccVector:vec to v(eVec:x, eVec:z, eVec:y):normalized * edge.
    set drawEccVector:start to origin.
    set xAxis:start to origin.
    set yAxis:start to origin.
    set zAxis:start to origin.
    
    set row to 5.

    set dummy to "N". if myOrbit[OBTP_IS_HYPERBOLIC] { set dummy to "Y". }
    print dummy at(col1, row).
    set dummy to "N". if kosOrbit:ECCENTRICITY >= 1 { set dummy to "Y". }
    print dummy at(col2, row).
    set row to row + 1.

    print round(myOrbit[OBTP_PE] - body:radius, prec) + sps at (col1, row).
    print round(kosOrbit:PERIAPSIS, prec) + sps at (col2, row).
    set row to row + 1.

    print round(myOrbit[OBTP_AP] - body:radius, prec) + sps at (col1, row).
    print round(kosOrbit:APOAPSIS, prec) at (col2, row).
    set row to row + 1.

    print round(myOrbit[OBTP_INCL], prec) at (col1, row).
    print round(kosOrbit:INCLINATION, prec) at (col2, row).
    set row to row + 1.

    print round(myOrbit[OBTP_ECC], prec) + sps at (col1, row).
    print round(kosOrbit:ECCENTRICITY, prec) + sps at (col2, row).
    set row to row + 1.

    print round(myOrbit[OBTP_SEMIMAJOR_AXIS], prec) at (col1, row).
    print round(kosOrbit:SEMIMAJORAXIS, prec) at (col2, row).
    set row to row + 1.

    print round(myOrbit[OBTP_SEMIMINOR_AXIS], prec) at (col1, row).
    print round(kosOrbit:SEMIMINORAXIS, prec) at (col2, row).
    set row to row + 1.

    print round(myOrbit[OBTP_LAN], prec) at (col1, row).
    print round(kosOrbit:LAN, prec) at (col2, row).
    set row to row + 1.

    print round(myOrbit[OBTP_ARG_OF_PE], prec) at (col1, row).
    print round(kosOrbit:ARGUMENTOFPERIAPSIS, prec) at (col2, row).
    set row to row + 1.

    wait 1.
}
set drawAngularMomentum:show to false.
set drawNodeVector:show to false.
set drawEccVector:show to false.
set xAxis:show to false.
set yAxis:show to false.
set zAxis:show to false.