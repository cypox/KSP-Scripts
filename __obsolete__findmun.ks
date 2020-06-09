// should be in orbit with correct inclination (0)

@lazyGlobal off.

runOncePath("gui.ks").

function time_to_ta_from_pe {
  parameter true_anomaly. // target true anomaly in degrees
  local E is true_anomaly * (2 * constant:pi) / 360.
  local to_trueanomaly is 0.
  local n is sqrt(body:mu / obt:semimajoraxis ^ 3).
  set to_trueanomaly to (E - obt:eccentricity * sin(E)) / n. // Kepler's equation
  return to_trueanomaly.
}

function time_to_ta {
  parameter true_anomaly.
  local time_to_ta_from_position is time_to_ta_from_pe(true_anomaly) - time_to_ta_from_pe(obt:trueanomaly).
  if true_anomaly < obt:trueanomaly {
    set time_to_ta_from_position to time_to_ta_from_position + obt:period.
  }
  return time_to_ta_from_position.
}

local t is 0.
local rad is 0.
local norm is 0.
local prog is 0.

// find best starting time (90 degrees behind mun)
local behine_mun_90 is mod(mun:obt:trueanomaly - 90 + 360, 360). // add 360 mod 360 for negative values when mun's ta is below 90
//local speed_factor is mun:obt:period / obt:period.
set t to time_to_ta(behine_mun_90).
// draw vectors to show that it's 90 degrees
// draw_from_to(kerbin:position, mun:position-kerbin:position).
// draw_from_to(kerbin:position, positionAt(ship, time:seconds + t)-kerbin:position).

// find best burn deltavs
local reference_v is sqrt(body:mu * (2/(body:radius+80000) - 1/obt:semimajoraxis)). // reference speed at orbit of 80000 m altitude
local current_v is velocityat(ship, time:seconds + t):orbit:mag.
set prog to current_v - reference_v + 860. // from cheat sheet == kerbin low orbit to mun

// improve starting time and deltav
until hasnode = false {
  remove nextnode.
  wait 0.1.
}
wait 1.
add node(time:seconds + t, rad, norm, prog).
local current_best is node(time:seconds + t, rad, norm, prog).
local current_best_score is nextNode:deltav:mag.
local done is true.
print("starting with best " + current_best_score).

until false {
  remove nextNode.
  wait 0.1.
  // generate neighbourhood
  local neighbourhood is list().
  local _step is 10.
  local temp_node is node(time:seconds + t + _step, rad, norm, prog).
  neighbourhood:add(temp_node).
  set temp_node to node(time:seconds + t - _step, rad, norm, prog).
  neighbourhood:add(temp_node).
  set temp_node to node(time:seconds + t, rad, norm, prog + _step).
  neighbourhood:add(temp_node).
  set temp_node to node(time:seconds + t, rad, norm, prog - _step).
  neighbourhood:add(temp_node).
  // pick best
  for possible_node in neighbourhood {
    add possible_node.
    if possible_node:deltav:mag < current_best_score {
      set t to possible_node:eta.
      set rad to possible_node:radialout.
      set norm to possible_node:normal.
      set prog to possible_node:prograde.
      set current_best to node(time:seconds + t, rad, norm, prog).
      set current_best_score to possible_node:deltav:mag.
      set done to false.
      print("found new best " + current_best_score).
    }
    remove nextnode.
    wait 0.1.
  }
  // check if enough
  add current_best.
  if nextnode:orbit:hasnextpatch or done = true {
    break.
  }
}

set t to current_best:eta.
set rad to current_best:radialout.
set norm to current_best:normal.
set prog to current_best:prograde.

// add maneuver node
add node(time:seconds + t, rad, norm, prog).
