// go up and collect science
// escape the atmosphere

runOncePath("0:/library/clib_gui.ks").
runOncePath("0:/library/clib_staging.ks").
runOncePath("0:/library/lib_navball.ks").

// TODO: SET HEADING AND ALTITUDE TO WAYPOINT

clearscreen.

global runmode is "idle".
on AG1 set runmode to "countdown".

deletepath("data.txt").

local v1 is 60.

local pitch is 0.
local rotation is 90.
local thr is 0.

lock steering to heading(rotation, pitch).
lock throttle to thr.

sas off.
rcs off.

init_staging_logic().

setup_hud().

until runmode = "done" {
  if runmode = "idle" {
  }
  else if runmode = "countdown" {
    countdown().
    set runmode to "engine start".
  }
  else if runmode = "engine start" {
    set thr to 1.
    set staging to true.
    set runmode to "initial ascent".
  }
  else if runmode = "initial ascent" {
    if ship:orbit:apoapsis > 75000 {
      announce_tr("REACHED SPACE.").
      set runmode to "done".
    }
  }
  else {
    set runmode to "done".
  }

  update_readouts().

  wait 0.
}
