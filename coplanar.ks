// should be in a circular orbit
parameter target_body.

runOncePath("functions.ks").


// equations from http://www.braeunig.us/space/
// also check http://control.asu.edu/Classes/MMAE441/Spacecraft/441Lecture21.pdf
// Spacecraft and Aircraft Dynamics
// Matthew M. Peet
// Illinois Institute of Technology
// Lecture 9: Bi-elliptics and Out-of-Plane Maneuvers

local i_initial is orbit:inclination.
local omega_initial is orbit:lan.
local i_final is target_body:orbit:inclination.
local omega_final is target_body:orbit:lan.

// calculate angle change (angle between the orbit's plane and the target orbit's plane)
local a1 is sin(i_initial) * cos(omega_initial).
local a2 is sin(i_initial) * sin(omega_initial).
local a3 is cos(i_initial).
local b1 is sin(i_final) * cos(omega_final).
local b2 is sin(i_final) * sin(omega_final).
local b3 is cos(i_final).
local angle_change is arccos(a1 * b1 + a2 * b2 + a3 * b3).
print angle_change.

// calculate position of ascending node relative to target plane
local c1 is a2 * b3 - a3 * b2.
local c2 is a3 * b1 - a1 * b3.
local c3 is a1 * b2 - a2 * b1.
local lat1 is arctan(c3 / sqrt(c1 * c1 + c2 * c2)).
local long1 is arctan(c2 / c1).
if c1 < 0 {
  set long1 to long1 + 90.
} else if c1 > 0 {
  set long1 to long1 + 270.
}
local lat2 is -lat1.
local long2 is long1 - 180.
local an_position is body:geopositionlatlng(lat1, long1):position.
local dn_position is body:geopositionlatlng(lat2, long2):position.
// DEBUG BEGIN
runOncePath("gui.ks").
clearVecDraws().
draw_from_to(body:position, an_position).
draw_from_to(body:position, dn_position).
// DEBUG END

// calculate time to ascending node
local orbital_period is ship:orbit:period/360. //calculates ship's speed in seconds per degree.
local degrees_to_lan is 360 - (orbit:argumentofperiapsis + orbit:trueanomaly). //returns number of degrees to lan.
if degrees_to_lan < 0 {
  set degrees_to_lan to degrees_to_lan + 360.
}
local time_to_lan is degrees_to_lan * orbital_period.

// calculate deltav
local velocity_at_node is velocityat(ship, time:seconds + time_to_lan):orbit:mag.
local deltav_normal is velocity:orbit:mag * sin(angle_change).
local deltav_prograde is velocity:orbit:mag * (1 - cos(angle_change)).

// calculate maneuver start time
local lan_difference is orbit:longitudeofascendingnode - target_body:orbit:longitudeofascendingnode.
local true_anomaly_of_ascending_node is mod(360 - orbit:argumentofperiapsis, 360).
if true_anomaly_of_ascending_node < 0 {
  set true_anomaly_of_ascending_node to true_anomaly_of_ascending_node + 360.
}
local time_to_ascending_node is time_to_ta(true_anomaly_of_ascending_node).
local start_time is time:seconds + time_to_ascending_node.

// adding nodes
local inclination_change_node is node(start_time, 0, deltav_normal, deltav_prograde).
add inclination_change_node.
