// lib_obtparams_from_pos_and_vel.ks (v0.1)
//
// Fill the orbit params structure from the position and velocity vectors.
// Arguments:
// 1 - position vector
// 2 - velocity vector
// 3 - mu
// Return: retval - the orbit params structure
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

declare parameter posVec, velVec, mu.
set TWO_PI to constant():PI ^ 2.
run lib_obtparams_empty.

// Swap Y and Z coordinate
set posVec to v(posVec:x, posVec:z, posVec:y).
set velVec to v(velVec:x, velVec:z, velVec:y).

set r to posVec:mag. // Radius
set v to velVec:mag. // Scalar velocity
set h to vcrs(posVec, velVec). // Specific angular momentum, Eq. 5.21

set nodeVec to v(-1 * h:y, h:x, 0):normalized. // Ascending node, Eq. 5.22

// Eccentricity vector, Eq. 5.23
set eVec to (1 / mu) * (((v * v - mu / r) * posVec) - vdot(posVec, velVec) * velVec).
set a to 1 / (2 / r - v * v / mu). // Semi-major axis, Eq. 5.24
set e to eVec:mag. // Eccentricity, Eq. 5.25
set i to arccos(h:z / h:mag). // Inclination, Eq. 5.26

 // Longitude of ascending node, Eq. 5.27
// The nodeVec is unit vector. Dividing by magnitude isn't needed.
set lan to arccos(nodeVec:x).
if nodeVec:y < 0 { set lan to 360 - lan. }

set aop to arccos(vdot(nodeVec, eVec) / e). // Argument of periapsis, Eq. 5.28
if eVec:z < 0 { set aop to 360 - aop. }

//set retval[OBTP_PERIOD] to ???.
set retval[OBTP_INCLINATION] to i.
set retval[OBTP_ECCENTRICITY] to e.
set retval[OBTP_SEMIMAJOR_AXIS] to a.
set retval[OBTP_SEMIMINOR_AXIS] to a * sqrt(1 - e * e).
set retval[OBTP_PERIAPSIS] to a * (1 - e).
set retval[OBTP_APOAPSIS] to a * (1 + e).
set retval[OBTP_ARGUMENT_OF_PE] to aop.
set retval[OBTP_LAN] to lan.
//set retval[OBTP_TRUE_ANOMALY] to ???.
//set retval[OBTP_MEAN_ANOMALY] to ???.

