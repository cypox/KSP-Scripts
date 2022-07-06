// takes off from runway and maitain a 1000m altitude with runway course

runOncePath("0:/library/clib_gui.ks").
runOncePath("0:/library/clib_staging.ks").
runOncePath("0:/library/lib_navball.ks").

parameter target_altitude is 1000.
parameter target_heading is 90.

local v1 is 60.

global runmode is "countdown".

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
      set roll_control_pid:setpoint to target_heading.
      set yaw_control_pid:setpoint to target_heading.
      set pitch_control_pid:setpoint to 20. // vspeed = 20m/s
      set runmode to "climb".
    }
  }
  else if runmode = "climb" {
    // maitain vspeed
    local p_pid_output to pitch_control_pid:update(time:seconds, ship:verticalspeed).
    set ship:control:pitch to ship:control:pitch + p_pid_output.

    // maitain course
    local r_pid_output is roll_control_pid:update(time:seconds, compass_for(ship)).
    set ship:control:roll to ship:control:roll + r_pid_output.

    local y_pid_output is yaw_control_pid:update(time:seconds, compass_for(ship)).
    set ship:control:yaw to ship:control:yaw + y_pid_output.

    if ship:altitude > target_altitude {
      set pitch_control_pid:setpoint to target_altitude.
      set runmode to "maintain".
    }
  }
  else if runmode = "maintain" {
    // maitain vspeed
    local p_pid_output to pitch_control_pid:update(time:seconds, target_altitude - ship:altitude).
    set ship:control:pitch to ship:control:pitch + p_pid_output.

    // maitain course
    local r_pid_output is roll_control_pid:update(time:seconds, compass_for(ship)).
    set ship:control:roll to ship:control:roll + r_pid_output.

    local y_pid_output is yaw_control_pid:update(time:seconds, compass_for(ship)).
    set ship:control:yaw to ship:control:yaw + y_pid_output.

    if ship:altitude > target_altitude {
      //set runmode to "done".
    }
  }

  update_readouts().

  wait 0.
}

unlock throttle.
unlock steering.
set ship:control:neutralize to true.
