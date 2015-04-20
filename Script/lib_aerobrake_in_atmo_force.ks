// lib_aerobrake_in_atmo_force.ks (v0.1)
//
// .
// Arguments:
// 1 - initial orbit params (with an additional parameters of an orbiting body)
// 2 - position vector (radius vector)
// 3 - velocity vector
// 4 - drag coefficient of orbiting body (usual is 0.2)
// 5 - mass (kg.)
// Return: retval - ???
//

declare parameter obtParams, curPos, curVel, drag, mass.

set body to obtParams[OBTP_ORIGIN].
set dragForce to 0.
if body:atm:exists {
    // The cross-section area is constant during simulation (A in formula).
    set csArea to 0.008 * mass.

    // Get atmospheric density at current height
    set curHeight to curPos:mag - body:radius.
    set atmScale to body:atm:scale * 1000.
    set atmDensity to 1.2230948554874 * body:atm:sealevelpressure * constant():E^(-curHeight / atmScale).
    set dragForce to 0.5 * atmDensity * curVel:mag^2 * drag * csArea.
}

// Note: We don't multiply mu and mass to get the force per kg.
// TODO: There's ^3 in alterbaron's code. To check it out
set gravForce to mass * mu / curPos:mag^2.

