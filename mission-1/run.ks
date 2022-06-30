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
local roll_control_pid is pidLoop(0.001, 0.05, 0.5, -1, 1).
local pitch_control_pid is pidLoop(0.01, 0.005, 0.005, -0.2, 0.2).

sas off.
rcs off.

init_staging_logic().

// setup_hud().
print "                       Flight Control Panel".
print " ".
print " +---------------------+    +--------------------+".
print " | Heading =      °    |    | Pitch  =      °    |".
print " | Roll    =      °    |    |                    |".
print " +---------------------+    +--------------------+".
print " ".
print " +---------------------+    +--------------------+".
print " | Speed    =      m/s |    | VSpeed =       m/s |".
print " | Altitude =        m |    |                    |".
print " +---------------------+    +--------------------+".
print " ".
print " +---------------------+    +--------------------+".
print " |                     |    |                    |".
print " +---------------------+    +--------------------+".
print " ".
print "Use Action group 1 to stop the autopilot.".

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
    // log time:seconds + " " + (compass_for(ship)-yaw_control_pid:setpoint) + " " + y_pid_output to "data.txt".
    set ship:control:wheelsteer to ship:control:wheelsteer + y_pid_output.
    if ship:velocity:surface:mag > 60 {
      set roll_control_pid:setpoint to 90. // roll angle = 90deg
      set pitch_control_pid:setpoint to 20. // pitch angle = 20deg
      set runmode to "ascent".
    }
  }
  else if runmode = "ascent" {
    //local r_pid_output is roll_control_pid:update(time:seconds, compass_for(ship)).
    //set ship:control:roll to ship:control:roll + r_pid_output.

    // maitain pitch for rotation ascent
    local p_pid_output to pitch_control_pid:update(time:seconds, pitch_for(ship)).
    set ship:control:pitch to ship:control:pitch + p_pid_output.

    // check for rotate finish
    if ship:altitude > 1000 {
      set ship:control:roll to 0.
      set ship:control:pitch to 0.
      set roll_control_pid:setpoint to 30. // heading = 30deg
      set pitch_control_pid:setpoint to 20. // vspeed = 20m/s
      set runmode to "heading".
    }
  }
  else if runmode = "heading" {
    // maitain vspeed
    local p_pid_output to pitch_control_pid:update(time:seconds, ship:verticalspeed).
    set ship:control:pitch to ship:control:pitch + p_pid_output.

    // go to course
    local r_pid_output is roll_control_pid:update(time:seconds, compass_for(ship)).
    log time:seconds + " " + (compass_for(ship)-roll_control_pid:setpoint) + " " + r_pid_output to "data.txt".
    set ship:control:roll to ship:control:roll + r_pid_output.

    // check for course and altitude
    if compass_for(ship) = 30 and ship:altitude > 3000 {
      set pitch_control_pid:setpoint to 0. // vspeed = 0m/s
      set runmode to "on course".
    }
  }
  else if runmode = "on course" {
    // maitain vspeed
    local p_pid_output to pitch_control_pid:update(time:seconds, ship:verticalspeed).
    set ship:control:pitch to ship:control:pitch + p_pid_output.
    // maitain course
    local r_pid_output is roll_control_pid:update(time:seconds, compass_for(ship)).
    set ship:control:roll to ship:control:roll + r_pid_output.
  }
  else {
    set runmode to "done".
  }

  // update_readouts().
  print round(compass_for(ship), 0) + "    " at (15, 3).
  print round(roll_for(ship), 0)    + "    " at (15, 4).
  print round(pitch_for(ship), 0)   + "    " at (40, 3).

  print round(ship:velocity:surface:mag, 0)   + "    " at (15, 8).
  print round(ship:altitude, 0)   + "    " at (15, 9).
  print round(verticalSpeed, 0)   + "    " at (40, 8).
  wait 0.
}
