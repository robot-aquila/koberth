// lib_math_sinh.ks (v0.1)
//
// Hyperbolic sine.
// Arguments:
// 1 - angle
// Return: retval - hyperbolic sine
//
// See also: http://en.wikipedia.org/wiki/Hyperbolic_function
//

declare parameter angle.

set dummy to constant():e ^ angle.
set retval to (dummy - (1 / dummy)) / 2.

