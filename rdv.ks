// should be in a circular orbit
// should be orbitting same body as target_body
// should have same inclination as target_body
// should not be on the same orbit (sma is different)
parameter target_body.

runOncePath("functions.ks").


local target_radius is target_body:apoapsis + body:radius.

// transfer orbit
local orbit_velocity_at_pe is vis_visa(body:mu, body:radius + orbit:periapsis, orbit:semimajoraxis).
local transfer_sma is (ship:orbit:semimajoraxis + target_radius) / 2.
local transfer_velocity_at_pe is vis_visa(body:mu, body:radius + orbit:periapsis, transfer_sma).
local transfer_deltav is transfer_velocity_at_pe - orbit_velocity_at_pe.

// parking orbit
local transfer_velocity_at_ap is vis_visa(body:mu, target_radius, transfer_sma).
local parking_velocity_at_ap is vis_visa(body:mu, target_radius, target_radius).
local parking_deltav is parking_velocity_at_ap - transfer_velocity_at_ap.

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

// calculate time of next maneuver
local transfer_to_parking is nextNode:obt:period / 2. // duration of transfer orbit is half a period
local parking_node is node(start_time + transfer_to_parking, 0, 0, parking_deltav).
add parking_node.

// DEBUG BEGIN
until true {
  clearScreen.
  print "Phase angle         " + phase_angle.
  print "Difference speed    " + difference_angular_velocity.
  print "------------------------------------".
  //print "My argument of PE   " + orbit:argumentofperiapsis.
  //print "My true anomaly     " + orbit:trueanomaly.
  //print "My LAN              " + orbit:longitudeofascendingnode.
  print "My orbit angle      " + mod(orbit:longitudeofascendingnode + orbit:argumentofperiapsis + orbit:trueanomaly, 360).
  print "------------------------------------".
  //print "Target argument PE  " + target_body:orbit:argumentofperiapsis.
  //print "Target true anomaly " + target_body:orbit:trueanomaly.
  //print "Target LAN          " + target_body:orbit:longitudeofascendingnode.
  print "Target orbit angle  " + mod(target_body:orbit:longitudeofascendingnode + target_body:orbit:argumentofperiapsis + target_body:orbit:trueanomaly, 360).
  print "------------------------------------".
  //print "Difference TAs      " + (target_body:orbit:trueanomaly - orbit:trueanomaly).
  //print "Difference PEs      " + (target_body:orbit:argumentofperiapsis - orbit:argumentofperiapsis).
  //print "Difference LAN      " + (target_body:orbit:longitudeofascendingnode - orbit:longitudeofascendingnode).
  print "Diff TA + AOP + LAN " + (mod(target_body:orbit:longitudeofascendingnode + target_body:orbit:argumentofperiapsis + target_body:orbit:trueanomaly, 360) - mod(orbit:longitudeofascendingnode + orbit:argumentofperiapsis + orbit:trueanomaly, 360)).
  print "------------------------------------".
  print "Current vang phase  " + vang(-body:position, target_body:position - body:position).
  wait 0.5.
}
// DEBUG END
