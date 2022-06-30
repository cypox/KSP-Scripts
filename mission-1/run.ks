// Explorer-1 runfile

runOncePath("gui.ks").
runOncePath("staging.ks").
runOncePath("KSLib/library/lib_navball.ks").


clearscreen.

global runmode is "countdown".
on AG1 set runmode to "done".


local pitch is 0.
local rotation is 90.
local thr is 0.

lock steering to heading(rotation, pitch).
lock throttle to thr.

local yaw_control_pid is pidLoop(0.1, 0.005, 0.005, -1, 1).
local roll_control_pid is pidLoop(0.1, 0.005, 0.005, -1, 1).
local pitch_control_pid is pidLoop(0.01, 0.005, 0.005, -0.2, 0.2).

sas off.
rcs off.

init_staging_logic().

// setup_hud().
print "Flight Control Panel".
print " ".
print " +-------------------------+".
print " | Compass ship =          |".
print " | Compass pro  =          |".
print " +-------------------------+".
print " ".
print " +-------------------------+".
print " | Pitch ship =            |".
print " | Pitch pro  =            |".
print " +-------------------------+".
print " ".
print " +-------------------------+".
print " |    Roll =               |".
print " +-------------------------+".
print " ".
print " +-------------------------+".
print " | Sideslip =              |".
print " +-------------------------+".
print " ".
print "Use Action group 1 to break.".

until runmode = "done" {
  if runmode = "countdown" {
    countdown().
    set runmode to "engine start".
  }
  else if runmode = "engine start" {
    set thr to 1.
    set staging to true.
    set yaw_control_pid:setpoint to 90.
    set runmode to "takeoff roll".
  }
  else if runmode = "takeoff roll" {
    local y_pid_output is yaw_control_pid:update(time:seconds, compass_for(ship)).
    set ship:control:wheelsteer to ship:control:wheelsteer + y_pid_output.
    if ship:velocity:surface:mag > 60 {

      set roll_control_pid:setpoint to 90.
      set pitch_control_pid:setpoint to 20.
      set runmode to "ascent".
    }
  }
  else if runmode = "ascent" {
    //local r_pid_output is roll_control_pid:update(time:seconds, compass_for(ship)).
    //set ship:control:roll to ship:control:roll + r_pid_output.
    local p_pid_output to pitch_control_pid:update(time:seconds, pitch_for(ship)).
    log time:seconds + " " + (pitch_for(ship)-pitch_control_pid:setpoint) + " " + p_pid_output to "data.txt".
    set ship:control:pitch to ship:control:pitch + p_pid_output.
    if ship:altitude > 1000 {
      set ship:control:roll to 0.
      set ship:control:pitch to 0.
      set runmode to "heading".
    }
  }
  else if runmode = "heading" {
    if compass_for(ship) <> 30 {
      set runmode to "in flight".
    }
  }
  else if runmode = "in flight" {
  }
  else {
    set runmode to "done".
  }

  // update_readouts().
  local srfPro is compass_and_pitch_for(ship,srfprograde).
  print round(compass_for(ship), 1) + "    " at (18,3).
  print round(srfPro[0], 1)         + "    " at (18,4).
  print round(pitch_for(ship), 1)   + "    " at (16,8).
  print round(srfPro[1], 1)         + "    " at (16,9).
  print round(roll_for(ship), 1)    + "    " at (13,13).
  print round(bearing_between(ship,srfprograde,ship:facing),1)    + "    " at (14,17).
  wait 0.
}
