// lib_obtparams_from_pos_and_vel.ks (v0.1)
//
// Fill the orbit params structure from the position and velocity vectors.
// Arguments:
// 1 - position vector
// 2 - velocity vector
// 3 - mu
// Return: retval - the orbit params structure
// -----------------------------------------------------------------------------
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
// -----------------------------------------------------------------------------
// Known issues: 
// - LAN angle is mismatched with the KOS-given value. 
//   Looking to vectors, value calculated by the library is correct.
//   lan_ingame_offset:
//   Kerbin: 245.7166 (but ~123 degrees at hyperbolic)
//   Kerbol: ~122 (123 ?)

declare parameter posVec, velVec, mu.
set TWO_PI to constant():PI ^ 2.
run lib_obtparams_empty.

// Swap Y and Z coordinate
set posVec to v(posVec:x, posVec:z, posVec:y).
set velVec to v(velVec:x, velVec:z, velVec:y).

set r to posVec:mag. // Radius
set v to velVec:mag. // Scalar velocity
set h to vcrs(posVec, velVec). // Specific angular momentum, Eq. 5.21
set i to arccos(h:z / h:mag). // Inclination, Eq. 5.26
set nodeVec to v(-1 * h:y, h:x, 0):normalized. // Ascending node, Eq. 5.22

set hyperbolic to false.
// Eccentricity vector, Eq. 5.23
set a to 1 / (2 / r - v * v / mu). // Semi-major axis, Eq. 5.24
set eVec to (1 / mu) * (((v * v - mu / r) * posVec) - vdot(posVec, velVec) * velVec).
set e to eVec:mag. // Eccentricity, Eq. 5.25
if e >= 1 {
    set hyperbolic to true.
    set b to a * sqrt(e * e - 1). // Semi-minor axis
} else {
    set b to a * sqrt(1 - e * e). // Semi-minor axis
}

// Note: the nodeVec is unit vector. Dividing by magnitude isn't needed.

// Longitude of ascending node, Eq. 5.27
set lan to arccos(nodeVec:x).
if nodeVec:y < 0 { set lan to 360 - lan. }
set aop to arccos(vdot(nodeVec, eVec) / e). // Argument of periapsis, Eq. 5.28
if eVec:z < 0 { set aop to 360 - aop. }

set retval[OBTP_IS_HYPERBOLIC] to hyperbolic.
set retval[OBTP_INCL] to i.
set retval[OBTP_ECC] to e.
set retval[OBTP_SEMIMAJOR_AXIS] to a.
set retval[OBTP_SEMIMINOR_AXIS] to b.
set retval[OBTP_PE] to a * (1 - e).
set retval[OBTP_AP] to a * (1 + e).
set retval[OBTP_ARG_OF_PE] to aop.
set retval[OBTP_LAN] to lan.
//set retval[OBTP_TRUE_ANOMALY] to ???.
//set retval[OBTP_MEAN_ANOMALY] to ???.
//set retval[OBTP_PERIOD] to ???.

