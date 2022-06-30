// should be in a circular orbit
parameter target.
parameter target_inclination is target:orbit:inclination.
parameter target_lan is target:orbit:longitudeofascendingnode.

runOncePath("functions.ks").


// also check http://control.asu.edu/Classes/MMAE441/Spacecraft/441Lecture21.pdf
// Spacecraft and Aircraft Dynamics
// Matthew M. Peet
// Illinois Institute of Technology
// Lecture 9: Bi-elliptics and Out-of-Plane Maneuvers

// TODO DELETE ME
run delnodes.

local i_initial is orbit:inclination.
local i_final is target_inclination.
local omega_initial is orbit:longitudeofascendingnode.
local omega_final is target_lan.

// calculate angle between original orbit plane and desired orbit plane from 441Lecture21.pdf
local angle_change is arccos(cos(i_initial) * cos(i_final) + sin(i_initial) * sin(i_final) * cos(omega_final - omega_initial)).

// calculate angle of intersection point between two orbits
local angle_of_intersection is 0.
if angle_change < 0.5 { // orbits are coplanar
  set angle_of_intersection to 0.
} else if i_initial < 0.5 { // original orbit is equatorial
  set angle_of_intersection to 0.
} else {
  local numerator is cos(i_initial) * cos(angle_change) - cos(i_final).
  local denominator is sin(i_initial) * sin(angle_change).
  local fraction is numerator / denominator.
  if fraction > 1 { // solve numerical imprecisions
    set fraction to 1.
  } else if fraction < -1 {
    set fraction to -1.
  }
  set angle_of_intersection to arccos(fraction).
  set angle_of_intersection to mod(angle_of_intersection, 360).
  print "Intersection : " + angle_of_intersection.
}

// calculate maneuver start time
local true_anomaly_of_node is angle_of_intersection - orbit:argumentofperiapsis.
if true_anomaly_of_node < 0 {
  set true_anomaly_of_node to true_anomaly_of_node + 360.
}
local time_to_ascending_node is time_to_ta(true_anomaly_of_node).
local start_time is time:seconds + time_to_ascending_node.

// calculate deltav
// do the math in page 20 from http://control.asu.edu/Classes/MMAE441/Spacecraft/441Lecture21.pdf
// compute deltav then recover the normal and prograde components by using the angle theta (angle_change)
local velocity_at_node is velocityat(ship, time:seconds + time_to_ascending_node):orbit:mag.
local delta_v_required is 2 * velocity_at_node * sin(angle_change / 2).
set deltav_normal to delta_v_required * sin(90 - angle_change / 2).
set deltav_prograde to delta_v_required * cos(90 - angle_change / 2).

// adding nodes
local inclination_change_node is node(start_time, 0, - deltav_normal, - deltav_prograde).
add inclination_change_node.
