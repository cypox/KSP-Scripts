// Explorer-1 runfile

runOncePath("0:/gui.ks").
runOncePath("0:/staging.ks").
runOncePath("0:/KSLib/library/lib_navball.ks").


clearscreen.

global runmode is "countdown".
on AG1 set runmode to "done".

local start_time is time:seconds.

deletepath("data.txt").

local pitch is 0.
local rotation is 90.
local thr is 0.

lock steering to heading(rotation, pitch).
lock throttle to thr.

local yaw_control_pid is pidLoop(0.1, 0.005, 0.005, -0.1, 0.1).
local roll_control_pid is pidLoop(0.05, 0.005, 0.1, -0.05, 0.05).
local pitch_control_pid is pidLoop(0.01, 0.005, 0.005, -0.1, 0.1).

sas off.
rcs off.

init_staging_logic().

// setup_hud().
print "                       Flight Control Panel".
print " ".
print " +-----------------------------------------------+".
print " | Runmode =                  Time =           s |".
print " +-----------------------------------------------+".
print " ".
print " +---------------------+    +--------------------+".
print " | Heading =         ° |    | Pitch  =         ° |".
print " | Roll    =         ° |    |                    |".
print " +---------------------+    +--------------------+".
print " ".
print " +---------------------+    +--------------------+".
print " | Speed    =       m/s|    | VSpeed =        m/s|".
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
    set ship:control:wheelsteer to ship:control:wheelsteer + y_pid_output.

    if ship:velocity:surface:mag > 60 {
      set ship:control:wheelsteer to 0.
      set roll_control_pid:setpoint to 90. // roll angle = 90deg
      set pitch_control_pid:setpoint to 20. // pitch angle = 20deg
      set runmode to "rotate".
    }
  }
  else if runmode = "rotate" {
    // maitain pitch for rotation ascent
    local p_pid_output to pitch_control_pid:update(time:seconds, pitch_for(ship)).
    set ship:control:pitch to ship:control:pitch + p_pid_output.

    // check for rotate finish
    if ship:altitude > 1000 {
      set ship:control:pitch to 0.
      set roll_control_pid:setpoint to 0. // heading = 30deg
      set pitch_control_pid:setpoint to 20. // vspeed = 20m/s
      set runmode to "climb and vector".
    }
  }
  else if runmode = "climb and vector" {
    // maitain vspeed
    local p_pid_output to pitch_control_pid:update(time:seconds, ship:verticalspeed).
    set ship:control:pitch to ship:control:pitch + p_pid_output.

    // go to course
    local r_target is 30.
    local r_current is compass_for(ship).
    local r_error is 0.
    if r_target < 180 {
      set r_error to r_current - r_target.
      if r_error > 180 {
        set r_error to r_error - 360. // should go right
      }
      else {
        set r_error to r_error. // should go left
      }
    }
    else {
      set r_error to r_target - r_current.
      if r_error >= 0 and r_error < 180 {
        set r_error to -r_error. // should go right
      }
      else if r_error < 0 {
        set r_error to r_current - r_target. // should go left
      }
      else {
        set r_error to 360 - (r_target - r_current). // should go left
      }
    }
    local r_pid_output is roll_control_pid:update(time:seconds, r_error).
    log time:seconds + " " + r_error + " " + r_pid_output to "data.txt".
    if roll_for(ship) < 35 and roll_for(ship) > -35 { // limit bank angle
      set ship:control:roll to r_pid_output.
    }
    else { // go smoothly to zero if bank angle is hard
      if ship:control:roll > 0 {
        set ship:control:roll to ship:control:roll - 0.01.
      }
      else {
        set ship:control:roll to ship:control:roll + 0.01.
      }
    }

    if r_error > 0 {
      set ship:control:yaw to 0.1.
    }
    else {
      set ship:control:yaw to -0.1.
    }

    // check for course and altitude
    if compass_for(ship) = 30 and ship:altitude > 3000 {
      set pitch_control_pid:setpoint to 0. // vspeed = 0m/s
      set ship:control:pitch to 0.
      set ship:control:yaw to 0.
      set ship:control:roll to 0.
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
  print runmode at (13, 3).
  print round(time:seconds-start_time, 0) + "    " at (37, 3).

  print round(compass_for(ship), 0) + "  " at (15, 7).
  print round(roll_for(ship), 0) + "  " at (15, 8).
  print round(pitch_for(ship), 0) + "  " at (40, 7).

  print round(ship:velocity:surface:mag, 0) + "  " at (15, 12).
  print round(ship:altitude, 0) + "  " at (15, 13).
  print round(verticalSpeed, 0) + "  " at (40, 12).
  wait 0.
}
