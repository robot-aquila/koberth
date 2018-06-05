// lib_math_arccosh.ks (v0.1)
//
// Inverse hyperbolic cosine.
// Arguments:
// 1 - hyperbolic cosine
// Return: retval - angle
//
// See also: http://en.wikipedia.org/wiki/Hyperbolic_function
//

declare parameter n.
set retval to ln(n + sqrt(n ^ 2 - 1).

