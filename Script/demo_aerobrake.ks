clearscreen.
if terminal:width < 80 { set terminal:width to 80. }

set sps to "             ".
set col1 to 19.
print "-------------------------------------------"+sps at (0, 0).
print " Aerobrake demo.                           "+sps at (0, 1).
print " Vessel: " + ship:name + "                 "+sps at (0, 2).
print "==========================================="+sps at (0, 3).
print "   theta_contact:                          "+sps at (0, 4).
print "    vcontact_mag:                          "+sps at (0, 5).
print "         theta_1:                          "+sps at (0, 6).
print "           theta:                          "+sps at (0, 7).
print "        vcontact:                          "+sps at (0, 8).
print "    vcontact_mag:                          "+sps at (0, 9).
print "        rcontact:                          "+sps at (0,10).
print "    rcontact_mag:                          "+sps at (0,11).
print "       dragForce:                          "+sps at (0,12).
print "       gravForce:                          "+sps at (0,13).
print "      atmDensity:                          "+sps at (0,14).
print "-------------------------------------------"+sps at (0,15).
print " Press AG9 to exit. If AG is not working   "+sps at (0,16).
print " check the kOS window it must be unfocused."+sps at (0,17).
print " AG is not working in the map mode.        "+sps at (0,18).
print "-------------------------------------------"+sps at (0,19).

set exit to 0.
if ag9="True" { toggle ag9. }
on ag9 {
    set exit to 1.
}

set prec to 4. // precision of the rounding
until exit=1 {
    set myPosition to ship:position - ship:body:position.
    set myVelocity to velocity:orbit.
    set myMass to ship:mass * 1000.
    run lib_obtparams_from_pos_and_vel(myPosition, myVelocity, body).
    //run lib_aerobrake_integrate_path(retval, ship:mass, 0.2).
    run lib_aerobrake_in_atmo_force(retval, myPosition, myVelocity, 0.2, myMass).

    set row to 4.
    
    //print round(theta_contact, prec)+sps at (col1, row).
    set row to row + 1.

    //print round(vcontact_mag, prec)+sps at (col1, row).
    set row to row + 1.

    //print round(theta_1, prec)+sps at (col1, row).
    set row to row + 1.

    //print round(theta, prec)+sps at (col1, row).
    set row to row + 1.

    //print "X="+round(curVel:x, prec)+", Y="+round(curVel:y, prec)+sps at (col1, row).
    set row to row + 1.

    //print round(curVel:mag, prec) at (col1, row).
    set row to row + 1.

    //print "X="+round(curPos:x, prec)+", Y="+round(curPos:y, prec)+sps at (col1, row).
    set row to row + 1.

    //print round(curPos:mag, prec) at (col1, row).
    set row to row + 1.

    print round(dragForce/myMass, prec) + sps at (col1, row).
    set row to row + 1.

    print round(gravForce/myMass, prec) + sps at (col1, row).
    set row to row + 1.

    print atmDensity + sps at (col1, row).
    set row to row + 1.

    wait 1.
}

