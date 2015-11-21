// lib_aerobrake_integrate_path.ks (v0.1)
//
// Simulate the path through atmosphere.
// Arguments:
// 1 - initial orbit params (with an additional parameters of an orbiting body)
// 2 - mass of orbiting body
// 3 - drag coefficient of orbiting body (usual is 0.2)
// Return: retval - The apoapsis after the path simulation.
// The result will be negative if the body has no atmosphere.
//

declare parameter obtParams, mass, drag.

set finalApRadius to 0.
set body to obtParams[OBTP_ORIGIN].
set bodyRadius to body:radius.
set bodyAtm to body:atm.
if bodyAtm:exists {
    set mu to body:mu.
    set atmRadius to bodyRadius + bodyAtm:height.
    set peRadius to obtParams[OBTP_PE] + bodyRadius.
    set apRadius to obtParams[OBTP_AP] + bodyRadius.
    set spEnergy to obtParams[OBTP_SP_OBT_ENERGY].
    if peRadius < bodyRadius {
        // Initial suborbital.
        // The final AP radius will be zero.
        // Nothing to do.

    } else if peRadius > atmRadius {
        // No atmosphere entry.
        // The final AP radius will not changed.
        // Nothing to do.

        set finalApRadius to apRadius.

    } else {
        // Make a simulation.
        // NOTE: this works only if PE inside the atmosphere
        // Otherwise will get an errors with NaN's and cosine > 1

        set theta_contact to arccos((1/e) * (a * (1 - e^2) / atmRadius - 1)).
        set vcontact_mag to sqrt(2 * (spEnergy + mu / atmRadius)).
        set theta_1 to arcsin(obtParams[OBTP_SP_ANG_MOMENTUM]:mag / (atmRadius * vcontact_mag)).
        set theta to theta_1 + theta_contact.
        set curVel to vcontact_mag * v(-1 * cos(theta), -1 * sin(theta), 0).
        set curPos to atmRadius * v(cos(theta_contact), sin(theta_contact), 0).

        set dt to 1.
        until 0 {



            set curRadius to curVel:mag.
            if curRadius > atmRadius or curRadius <= bodyRadius {
                break.
            }
        }
        

    }
}
set retval to finalApRadius - bodyRadius.

