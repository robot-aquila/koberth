// lib_obtparams_mean_anomaly_at_true_anomaly.ks (v0.1)
//
// Calculate a mean anomaly at true anomaly.
// Arguments:
// 1 - eccenticity
// 2 - true anomaly
// Return: retval - mean anomaly
// Return: eccentricAnomaly - eccentric anomaly

declare parameter e, trueAnomaly.
run lib_obtparams_eccentric_anomaly_at_true_anomaly(e, trueAnomaly).
set eccentricAnomaly to retval.
if e >= 1 {
    // the orbit is hyperbolic
    run lib_math_sinh(eccentricAnomaly).
    set retval to e * retval - eccentricAnomaly.
} else {
    set retval to retval - e * sin(retval).
}

