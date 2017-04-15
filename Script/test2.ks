@lazyglobal off.

run once kobertlib.
local r1 is body:radius+(periapsis+apoapsis)/2.
local r2 is body:radius+target:altitude.
local htoParams is kob_get_hto_params_co(r1, r2, body:mu).
print "TRANSFER TIME: " + htoParams[KOB_HTO_TRANSFER_TIME].
print "ANGULAR ALIGN: " + htoParams[KOB_HTO_ANGULAR_ALIGN].
print "BURN1 Delta-V: " + htoParams[KOB_HTO_BURN1_DV].
print "BURN2 Delta-V: " + htoParams[KOB_HTO_BURN2_DV].
print "ANG.VEL.SRC. : " + htoParams[KOB_HTO_ANGULAR_VEL_SRC].
print "ANG.VEL.DST. : " + htoParams[KOB_HTO_ANGULAR_VEL_DST].

local phaseAngle is kob_get_hto_phase_angle_co(body:position*-1, velocity:orbit, target:position-body:position, target:velocity).
local phaseAngleT is time:seconds.
// We want to be on same orbit but 120 grad behind the target.
// Then we have to point to that point.
// Just move the phase angle back to 120 grad.
set phaseAngle to phaseAngle - 120 * constant():pi / 180.

print "PHASE ANGLE  : " + (phaseAngle * 180 / constant():pi).

local pi2 is 2 * constant():pi.
local startAngle is phaseAngle - htoParams[KOB_HTO_ANGULAR_ALIGN].
if r1 > r2 and startAngle > 0 { set startAngle to -pi2 + startAngle. }
if r1 < r2 and startAngle < 0 { set startAngle to pi2 + startAngle. }
local t is startAngle / (htoParams[KOB_HTO_ANGULAR_VEL_SRC] - htoParams[KOB_HTO_ANGULAR_VEL_DST]).
local x to node(phaseAngleT + t, 0, 0, htoParams[KOB_HTO_BURN1_DV]).
add x.
