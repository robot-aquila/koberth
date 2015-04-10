// lib_obtparams_eccentric_anomaly_at_true_anomaly.ks (v0.1)
//
// Calculate an eccentric anomaly at true anomaly.
// Arguments:
// 1 - eccenticity
// 2 - true anomaly
// Return: retval - eccentric anomaly

declare parameter e, trueAnomaly.
if e >= 1 {
    // the orbit is hyperbolic
    set cosTrueAnomaly to cos(trueAnomaly).
    run lib_math_arccos((e + cosTrueAnomaly) / (1 + e * cosTrueAnomaly)).
} else {
    set retval to 2 * arctan(tan(trueAnomaly/2) / sqrt((1 + e) / (1 - e))).
}
if retval < 0 { set retval to 360 + retval. }

