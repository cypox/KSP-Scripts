runOncePath("flightos/libnav.ks").

parameter target_vspeed is 20.

// init
sas off.
rcs off.
//local t is 1.
//lock throttle to t.

// reset controls
set ship:control:roll to 0.
set ship:control:yaw to 0.
set ship:control:pitch to 0.

// maintain altitude
deletepath("flightos/data.txt").
local hdg_log is "flightos/data.txt".

set Kp to 0.001.
set Ki to 0.001.
set Kd to 0.0005.
set Mx to 0.1.
set Mn to -0.1.
set hdg_pid to pidloop(Kp, Ki, Kd, Mn, Mx).
set hdg_pid:setpoint to target_vspeed.
set start_time to time:seconds.
until false {
  set ship:control:pitch to hdg_pid:update(time:seconds, ship:verticalspeed).
  local logline to (time:seconds - start_time) + " " + hdg_pid:error + " " + hdg_pid:output.
  wait 0.05.

  log logline to hdg_log.
  clearScreen.
  print "Maintaining altitude".
  print "VSP: " + ship:verticalspeed.
  print "ERR: " + hdg_pid:error.
  print "OUT: " + hdg_pid:output.

  //set ship:control:pitch to 0.
  //wait 0.1.
}
