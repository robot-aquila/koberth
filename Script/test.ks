@lazyglobal off.

run kobertlib.

local isp is kob_get_isp().
print "ISP is: " + isp.
local dur is kob_get_burn_duration(1000).
print "Duration of 1000D-V is: " + dur + "s.".
