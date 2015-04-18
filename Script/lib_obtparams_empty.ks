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
    set OBTP_ORIGIN             to  0.
    set OBTP_AP                 to  1.
    set OBTP_PE                 to  2.
    set OBTP_IS_HYPERBOLIC      to  3.  // Boolean true/false.
    set OBTP_PERIOD             to  4.
    set OBTP_INCL               to  5.
    set OBTP_ECC                to  6.
    set OBTP_SEMIMAJOR_AXIS     to  7.
    set OBTP_SEMIMINOR_AXIS     to  8.
    set OBTP_ARG_OF_PE          to  9.
    set OBTP_LAN                to 10.
    set OBTP_SP_OBT_ENERGY      to 11.  // Specific orbital energy

// Please note: The following parameters may be undefined (zeroed)
// if the just orbit is given without a body on it.

    set OBTP_TRUE_ANOMALY       to 12.  // True anomaly (degrees)
    set OBTP_SP_ANG_MOMENTUM    to 13.  // Specific angular momentum (vector)

    set OBTP_STRUCTURE_SIZE     to 14.
    set lib_obtparams_empty_const_initialized to 1.
}

set retval to list().
set dummy to 0.
until dummy >= OBTP_STRUCTURE_SIZE {
    retval:add(0).
    set dummy to dummy + 1.
}

