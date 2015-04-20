// lib_obtparams_aerobrake.ks (v0.1)
//
// Calculate aerobrake.
// Arguments: 
// Return: retval - 

declare parameter obtParams, curAlt, curVel, desiredAp.
set DEG2RAD to constant():PI/180.
set RAD2DEG to 180/constant():PI.

set body to obtParams[OBTP_ORIGIN].
set bodyRadius to body:radius.
set atmRadius to bodyRadius + body:atm:height.
set mu to body:mu.
set hmag to obtParams[OBTP_SP_ANG_MOMENTUM]:mag.
set e to obtParams[OBTP_ECC].
set a to obtParams[OBTP_SEMIMAJOR_AXIS].

// e = 0.3313
// 1/e = 3.018412315
// (1 - e^2) = 0.89024031
// 3.018412315 * (a * 0.89024031 / atmRadius - 1) 
// a = 1179249
// atmRadius = 669000
// 3.018412315 * (1179249 * 0.89024031 / 669000 - 1)

if obtParams[OBTP_PE] + bodyRadius > atmRadius {
    // The path is outside of the atmosphere.
    set theta_contact to 0.
    set vcontact_mag to 0.
    set theta_1 to 0.
    set theta to 0.
    set vcontact to v(0, 0, 0).
    set rcontact to v(0, 0, 0).    

} else {

}

