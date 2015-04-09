// lib_obtparams_empty.ks (v0.1)
//
// Create an empty orbit params structure.
// Arguments: none
// Return: retval - the orbit params structure
//
// Also initializes a field constants which allows to easy access to the
// structure fields. ALWAYS use those constants to get access to the elements of
// the orbit. It will make your program stable and independent of the possible
// future changes of the structure.
//

declare lib_obtparams_empty_const_initialized.
if not lib_obtparams_empty_const_initialized {
    set OBTP_APOAPSIS               to 0.
    set OBTP_PERIAPSIS              to 1.
    set OBTP_IS_HYPERBOLIC          to 2.   // Boolean true/false.

    set OBTP_PERIOD                 to 3.   // If the orbit is hyperbolic then
                                            // the orbital period is infinity.
                                            // Such periods are marked as -1.
    set OBTP_INCLINATION            to 4.
    set OBTP_ECCENTRICITY           to 5.
    set OBTP_SEMIMAJOR_AXIS         to 6.
    set OBTP_SEMIMINOR_AXIS         to 7.
    set OBTP_ARGUMENT_OF_PE         to 8.
    set OBTP_LAN                    to 9.
    set OBTP_TRUE_ANOMALY           to 10.
    set OBTP_MEAN_ANOMALY           to 11.

    set OBTP_STRUCTURE_SIZE         to 12.
    set lib_obtparams_empty_const_initialized to 1.
}

set retval to list().
set x to 0.
until x >= OBTP_STRUCTURE_SIZE {
    retval:add(0).
    set x to x + 1.
}

