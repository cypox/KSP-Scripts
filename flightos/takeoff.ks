CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

runOncePath("flightos/libnav.ks").

// init
sas off.
rcs off.
local runway_hdg is 90.
local target_hdg is 70.
local vr is 40.
local t is 0.
lock throttle to t.

// reset controls
set ship:control:roll to 0.
set ship:control:yaw to 0.
set ship:control:pitch to 0.

// controls check - comment break line to use
until false {
  break.
  set ship:control:roll to 1.
  wait 1.
  set ship:control:roll to -1.
  wait 1.
  set ship:control:roll to 0.
  set ship:control:yaw to 1.
  wait 1.
  set ship:control:yaw to -1.
  wait 1.
  set ship:control:yaw to 0.
  set ship:control:pitch to 1.
  wait 1.
  set ship:control:pitch to -1.
  wait 1.
  set ship:control:pitch to 0.
  wait 1.
  set ship:control:pitch to 0.
  set ship:control:pilotwheelsteertrim to 1.
  wait 1.
  set ship:control:pilotwheelsteertrim to -1.
  wait 1.
  set ship:control:pilotwheelsteertrim to 0.
  wait 1.
}

// initial roll
//set ship:control:mainthrottle to 0.2.
set t to 0.2.
stage.
wait until ship:velocity:surface:mag > 2.
set t to 1.

// takeoff roll with pid maintaing runway heading (center line todo)
sas on.
local Kp is 0.1.
local Ki is 0.05.
local Kd is 1.
local Mx is 0.05.
local Mn is -0.05.
local hdg_pid is pidloop(Kp, Ki, Kd, Mn, Mx).
set hdg_pid:setpoint to 0.
local start_time is time:seconds.
deletepath("data.txt").
local hdg_log is "data.txt".
log Kp + " " + Ki + " " + Kd to hdg_log.
until ship:velocity:surface:mag > vr {
  local navball_heading is compass_for().
  local normalized_divergence is mod(navball_heading - runway_hdg + 180, 360) - 180. // gives readings from -180 to +180
  //set ship:control:yaw to hdg_pid:update(time:seconds, normalized_divergence).
  set ship:control:pilotwheelsteertrim to hdg_pid:update(time:seconds, -normalized_divergence).
  set ship:control:yaw to hdg_pid:output * 5.
  local logline to (time:seconds - start_time) + " " + hdg_pid:error + " " + hdg_pid:output.
  wait 0.1.

  log logline to hdg_log.
  clearScreen.
  print "Maintaining centerline".
  print "CMP: " + navball_heading.
  print "ERR: " + hdg_pid:error.
  print "OUT: " + hdg_pid:output.
}

sas off.
set ship:control:pilotwheelsteertrim to 0.
set ship:control:yaw to 0.

// VRotate
set ship:control:pitch to 1.
wait 1.
set ship:control:pitch to 0.6.
wait 2.
set ship:control:pitch to -0.4.
wait 1.
set ship:control:pitch to 0.

// positive rate

// maitain runway heading
deletepath("data.txt").
set Kp to 0.2.
set Ki to 0.05.
set Kd to 0.5.
set Mx to 0.5.
set Mn to -0.5.
set hdg_pid to pidloop(Kp, Ki, Kd, Mn, Mx).
set hdg_pid:setpoint to 0.
set start_time to time:seconds.
until alt:radar > 2000 {
  local navball_heading is compass_for().
  local normalized_divergence is mod(navball_heading - runway_hdg + 180, 360) - 180. // gives readings from -180 to +180
  set ship:control:roll to hdg_pid:update(time:seconds, normalized_divergence).
  set ship:control:pitch to 0.1.
  local logline to (time:seconds - start_time) + " " + hdg_pid:error + " " + hdg_pid:output.
  wait 0.1.

  log logline to hdg_log.
  clearScreen.
  print "Rolling to 90".
  print "CMP: " + navball_heading.
  print "ERR: " + hdg_pid:error.
  print "OUT: " + hdg_pid:output.

  set ship:control:roll to 0.
  set ship:control:pitch to -0.1.
  wait 0.08.
}

// maitain 70 degrees heading
deletepath("data.txt").
set Kp to 0.2.
set Ki to 0.05.
set Kd to 0.5.
set Mx to 0.5.
set Mn to -0.5.
set hdg_pid to pidloop(Kp, Ki, Kd, Mn, Mx).
set hdg_pid:setpoint to 0.
set start_time to time:seconds.
until false {
  local navball_heading is compass_for().
  local normalized_divergence is mod(navball_heading - target_hdg + 180, 360) - 180. // gives readings from -180 to +180
  set ship:control:roll to hdg_pid:update(time:seconds, normalized_divergence).
  set ship:control:pitch to 0.1.
  local logline to (time:seconds - start_time) + " " + hdg_pid:error + " " + hdg_pid:output.
  wait 0.08.

  log logline to hdg_log.
  clearScreen.
  print "Rolling to 90".
  print "CMP: " + navball_heading.
  print "ERR: " + hdg_pid:error.
  print "OUT: " + hdg_pid:output.

  set ship:control:roll to 0.
  set ship:control:pitch to -0.1.
  wait 0.1.
}

// final setup
set t to 1.
unlock throttle.
set ship:control:neutralize to true.
