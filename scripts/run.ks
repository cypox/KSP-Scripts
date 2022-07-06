// Explorer-1 runfile
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

runOncePath("0:/library/clib_gui.ks").
runOncePath("0:/library/clib_staging.ks").
runOncePath("0:/library/lib_navball.ks").

// TODO: SET HEADING AND ALTITUDE TO WAYPOINT

clearscreen.

global runmode is "idle".
on AG1 set runmode to "countdown".
on AG2 set runmode to "idle".

local wpt is allwaypoints()[0]. // target waypoint
lock wpt_vector to wpt:position - ship:position.

deletepath("data.txt").

local v1 is 60.

local pitch is 0.
local rotation is 90.
local thr is 0.

lock steering to heading(rotation, pitch).
lock throttle to thr.

local yaw_control_pid is pidLoop(0.1, 0.005, 0.5, -0.005, 0.005).
local roll_control_pid is pidLoop(0.1, 0.005, 0.5, -0.01, 0.01).
local pitch_control_pid is pidLoop(0.1, 0.005, 0.5, -0.005, 0.005).
local centerline_pid is pidloop().

sas off.
rcs off.

init_staging_logic().

setup_hud().
// wpt realtive readouts
print " +---------------------+    +--------------------+".
print " | Wpt Hdg =         ° |    | Dist. =          m |".
print " +---------------------+    +--------------------+".
print " ".

until runmode = "done" {
  if runmode = "idle" {
    set ship:control:yaw to 0.
    set ship:control:roll to 0.
    set ship:control:pitch to 0.
    set ship:control:wheelsteer to 0.
  }
  else if runmode = "countdown" {
    countdown().
    set runmode to "engine start".
  }
  else if runmode = "engine start" {
    set thr to 1.
    set staging to true.
    set centerline_pid to pidLoop(0.1, 0.005, 0.5, -0.005, 0.005, 10).
    set centerline_pid:setpoint to 90.
    set runmode to "takeoff roll".
  }
  else if runmode = "takeoff roll" {
    local y_pid_output is centerline_pid:update(time:seconds, compass_for(ship)).
    set ship:control:wheelsteer to y_pid_output.

    if ship:velocity:surface:mag > v1 {
      announce_tr("V1.").
      set ship:control:wheelsteer to 0.
      set pitch_control_pid:setpoint to 20. // vspeed = 20m/s
      set runmode to "rotate".
      wait 1.
      announce_tr("ROTATE.").
    }
  }
  else if runmode = "rotate" {
    // maitain vspeed
    local p_pid_output to pitch_control_pid:update(time:seconds, ship:verticalspeed).
    set ship:control:pitch to ship:control:pitch + p_pid_output.

    // check for rotate finish
    if ship:altitude > 100 {
      announce_tr("POSITIVE RATE.").
      wait 1.
      announce_tr("GEAR UP.").
      wait 1.
      set ship:control:pitch to 0.
      set roll_control_pid:setpoint to 0. // heading = 30deg
      set yaw_control_pid:setpoint to 0. // heading = 30deg
      set pitch_control_pid:setpoint to 20. // vspeed = 20m/s
      set runmode to "climb and vector".
    }
  }
  else if runmode = "climb and vector" {
    // maitain vspeed
    local p_pid_output to pitch_control_pid:update(time:seconds, ship:verticalspeed).
    set ship:control:pitch to ship:control:pitch + p_pid_output.

    // go to course
    local r_target is 30. // go to a given heading (30deg)
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
    // local r_pid_output is roll_control_pid:update(time:seconds, r_error). // use this to go to a given course

    // use yaw to rotate to the given course
    // set ship:control:yaw to yaw_control_pid:update(time:seconds, r_error). // us this to go to a given course with roll

    // get angle to waypoint
    set r_target to vang(ship:facing:forevector, wpt_vector).
    local r_pid_output is roll_control_pid:update(time:seconds, r_target). // use this to go to a given target

    set ship:control:yaw to yaw_control_pid:update(time:seconds, r_target).

    log time:seconds + " " + r_error + " " + r_pid_output to "data.txt".
    if roll_for(ship) < 35 and roll_for(ship) > -35 { // limit bank angle
      set ship:control:roll to r_pid_output.
    }
    else { // go smoothly to zero if bank angle is hard
      if ship:control:roll > 0 {
        //set ship:control:roll to ship:control:roll - 0.005.
        set ship:control:roll to 0.
      }
      else {
        set ship:control:roll to ship:control:roll + 0.005.
        set ship:control:roll to 0.
      }
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

  // update heading vector
  clearVecDraws().
  draw_from_to(ship:position, wpt:position).

  update_readouts().
  // wpt relative readouts
  print round(vang(ship:facing:forevector, wpt_vector), 0) + "  " at (15, 17).
  print round(wpt:geoposition:distance, 0) + "  " at (38, 17).

  wait 0.
}
