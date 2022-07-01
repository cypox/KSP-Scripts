CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

// load functions
runOncePath("functions.ks").
runOncePath("staging.ks").
runOncePath("gui.ks").


local desired_orbit is 72000.

global runmode to "countdown".

local pitch is 90.
local rotation is 90.
local thr is 0.

lock steering to heading(rotation, pitch).
lock throttle to thr.

sas off.
rcs off.

print "waiting for signal to initiate countdown".
set ch to terminal:input:getchar().

init_staging_logic().
setup_hud().

until runmode = "done" {
  if runmode = "countdown" {
    countdown().
    set runmode to "ignition".
  }
  else if runmode = "ignition" {
    set thr to 1.
    set staging to true.
    set runmode to "initial climb".
  }
  else if runmode = "initial climb" {
    if ship:altitude > 5000 {
      set runmode to "gravity ascent".
    }
  }
  else if runmode = "gravity ascent" {
    if ship:altitude < 10000 {
      set pitch to 85.
    }
    else if ship:altitude < 15000 {
      set pitch to 75.
    }
    else if orbit:apoapsis < (desired_orbit + 2000) {
      set pitch to 45.
    }
    else {
      set thr to 0.
      set pitch to 6.
      set runmode to "circularize".
    }
  }
  else if runmode = "circularize" {
    if eta:apoapsis < 8 {
      set thr to 1.
    }
    if ship:periapsis > (desired_orbit - 1000) {
      set runmode to "inorbit".
    }
  }
  else {
    set runmode to "done".
  }

  update_readouts().
}
