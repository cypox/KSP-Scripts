// Explorer-1 runfile
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

runOncePath("0:/library/clib_gui.ks").
runOncePath("0:/library/clib_staging.ks").
runOncePath("0:/library/lib_navball.ks").
runOncePath("0:/library/clib_transfer.ks").


clearscreen.

global runmode is "idle".

on AG1 set runmode to "countdown".
on AG2 set runmode to "in orbit".

deletepath("data.txt").

local pitch is 90.
local rotation is 0.
local thr is 0.

lock steering to heading(rotation, pitch).
lock throttle to thr.

sas off.
rcs off.

init_staging_logic().

setup_hud().

print " +---------------------+    +--------------------+".
print " | Ap =              m |    | Pe =             m |".
print " +---------------------+    +--------------------+".
print " ".
print " +---------------------+    +--------------------+".
print " | Pitch =           ° |    | ETA =            s |".
print " +---------------------+    +--------------------+".

local desired_orbit is 90.

local ascent_profile_alts is list(5000, 10000, 20000, 30000, 50000, 70000).
local ascent_profile_pitch is list(85, 80, 70, 60, 40, 15).

local circ_pid is pidLoop(1, 0.1, 0.01, -5, 15).
set circ_pid:setpoint to 5.

until runmode = "done" {
  if runmode = "idle" {
    set thr to 0.
  }
  else if runmode = "countdown" {
    countdown().
    set runmode to "engine start".
  }
  else if runmode = "engine start" {
    set thr to 1.
    set staging to true.
    set runmode to "initial climb".
  }
  else if runmode = "initial climb" {
    set rotation to desired_orbit.
    if ship:altitude > 2000 {
      set runmode to "gravity ascent".
    }
  }
  else if runmode = "gravity ascent" {
    local p is 0.
    local i is 0.
    for i in range(0, 6) {
      set p to ascent_profile_pitch[i].
      if ascent_profile_alts[i] > ship:altitude {
        break.
      }
    }
    set pitch to p.
    if ship:apoapsis > 80000 {
      set thr to 0.
      set runmode to "coast to circularize".
    }
  }
  else if runmode = "coast to circularize" {
    set pitch to 5.
    if eta:apoapsis < 30 {
      set runmode to "circularize".
      set thr to 1.
    }
  }
  else if runmode = "circularize" {
    if eta:apoapsis < 1 or eta:apoapsis > 300
      set pitch to 20.
    else
    {
      set pitch to circ_pid:update(time:seconds, eta:apoapsis).
      log time:seconds + " " + eta:apoapsis + " " + pitch to "data.txt".
    }
    if ship:periapsis > 75000 {
      set thr to 0.
      set runmode to "in orbit".
    }
  }
  else if runmode = "in orbit" {
    local transfer_node is calculate_transfer_orbit(mun).
    add transfer_node.
    optimize_transfer(20000).
    set runmode to "waiting for node".
  }
  else if runmode = "waiting for node" {
    
  }
  else {
    set runmode to "done".
  }

  update_readouts().

  print round(ship:apoapsis, 0) + "  " at (10, 17).
  print round(ship:periapsis, 0) + "  " at (37, 17).

  print round(pitch, 0) + "  " at (13, 21).
  print round(eta:apoapsis, 0) + "  " at (38, 21).

  wait 0.001.
}
