// should be in a circular orbit
// should be orbitting same body as target_body
// should have same inclination as target_body
// should not be on the same orbit (sma is different)
parameter target_body.
parameter target_min_pe.

runOncePath("functions.ks").


local target_radius is target_body:apoapsis + body:radius.

// transfer orbit
local orbit_velocity_at_pe is vis_visa(body:mu, body:radius + orbit:periapsis, orbit:semimajoraxis).
local transfer_sma is (ship:orbit:semimajoraxis + target_radius) / 2.
local transfer_velocity_at_pe is vis_visa(body:mu, body:radius + orbit:periapsis, transfer_sma).
local transfer_deltav is transfer_velocity_at_pe - orbit_velocity_at_pe.

// calculate phase angle
local transfer_period is 2 * constant:pi * sqrt (transfer_sma ^ 3 / body:mu).
local target_angular_velocity is angular_velocity(target_body:orbit:semimajoraxis).
local phase_angle is 180 - transfer_period * target_angular_velocity / 2.

// calculate maneuver start time
local orbit_angular_velocity is angular_velocity(ship:orbit:semimajoraxis).
local time_to_phase_angle is -1.

local difference_angular_velocity is orbit_angular_velocity - target_angular_velocity.
local target_reference_orbit_angle is target_body:orbit:longitudeofascendingnode + target_body:orbit:argumentofperiapsis + target_body:orbit:trueanomaly.
local reference_orbit_angle is orbit:longitudeofascendingnode + orbit:argumentofperiapsis + orbit:trueanomaly.
set target_reference_orbit_angle to mod(target_reference_orbit_angle, 360).
set reference_orbit_angle to mod(reference_orbit_angle, 360).
local difference_phase_current is target_reference_orbit_angle - reference_orbit_angle.
set difference_phase_current to mod(difference_phase_current, 360).
if difference_phase_current < 0 {
  set difference_phase_current to difference_phase_current + 360.
}
set time_to_phase_angle to (difference_phase_current - phase_angle) / difference_angular_velocity.
local start_time is time:seconds + time_to_phase_angle.

// adding nodes
local transfer_node is node(start_time, 0, 0, transfer_deltav).
add transfer_node.

// raise intercept trajectory
local precision is 1.
local old_pe is nextnode:obt:nextpatch:periapsis.
until nextnode:obt:nextpatch:periapsis > target_min_pe {
  // improve node
  set nextNode:prograde to nextNode:prograde - precision.
  // vary the precision
  local difference is old_pe - nextnode:obt:nextpatch:periapsis.
  local direction is 1. // TODO VARY THE DIRECTION (INCREASE AND DECREASE)
  //if difference < 0 {
  //  set  direction to -1.
  //}
  if abs(difference) > 1000000 {
    set precision to direction * 0.05.
  } else if abs(difference) > 100000 {
    set precision to  direction * 0.1.
  } else if abs(difference) > 10000 {
    set precision to  direction * 0.5.
  } else if abs(difference) > 1000 {
    set precision to  direction * 1.
  } else {
    set precision to  direction * 2.
  }
  // DEBUG BEGIN
  //clearscreen.
  //print "Current PE             " + nextnode:obt:nextpatch:periapsis.
  //print "difference             " + difference.
  //print "precision              " + precision.
  // DEBUG END
  wait 0.1.
}
