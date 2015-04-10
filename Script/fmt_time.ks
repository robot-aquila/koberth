// Format time in seconds to human-readable string.
// Output: retval
declare parameter time2format. // time in seconds
// 1 year = ??? days = ????????????????????????????
//            1  day = 6 hours = 360 mins = 21600 s
//                     1  hour =  60 mins =  3600 s
//                                1  min =     60 s

set fmtD to floor(time2format/21600).
set x to time2format-fmtD*21600.
set fmtH to floor(x/3600).
set x to x-fmtH*3600.
set fmtM to floor(x/60).
set x to x-fmtM*60.
set fmtS to floor(x).

set fmtTime to "D".
if fmtD<100 { set fmtTime to fmtTime+"0". }
if fmtD< 10 { set fmtTime to fmtTime+"0". }
set fmtTime to fmtTime+fmtD+",".
if fmtH< 10 { set fmtTime to fmtTime+"0". }
set fmtTime to fmtTime+fmtH+":".
if fmtM< 10 { set fmtTime to fmtTime+"0". }
set fmtTime to fmtTime+fmtM+":".
if fmtS< 10 { set fmtTime to fmtTime+"0". }
set retval to fmtTime+fmtS.
