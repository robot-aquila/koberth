// lib_math_arcsinh.ks (v0.1)
//
// Inverse hyperbolic sine.
// Arguments:
// 1 - hyperbolic sine
// Return: retval - angle
//
// See also: http://en.wikipedia.org/wiki/Hyperbolic_function
//

declare parameter n.
set retval to ln(n + sqrt(n ^ 2 + 1).

