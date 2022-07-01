// should be in a circular orbit
parameter target_ap.

runOncePath("functions.ks").


// equations from http://www.braeunig.us/space/

local target_radius is target_ap + body:radius.

// transfer orbit
local orbit_velocity_at_pe is vis_visa(body:mu, body:radius + orbit:periapsis, orbit:semimajoraxis).
local transfer_sma is (ship:orbit:semimajoraxis + target_radius) / 2.
local transfer_velocity_at_pe is vis_visa(body:mu, body:radius + orbit:periapsis, transfer_sma).
local transfer_deltav is transfer_velocity_at_pe - orbit_velocity_at_pe.

// parking orbit
local transfer_velocity_at_ap is vis_visa(body:mu, target_radius, transfer_sma).
local parking_velocity_at_ap is vis_visa(body:mu, target_radius, target_radius).
local parking_deltav is parking_velocity_at_ap - transfer_velocity_at_ap.

// calculate maneuver start time
local start_time is time:seconds + eta:periapsis.

// adding nodes
local transfer_node is node(start_time, 0, 0, transfer_deltav).
add transfer_node.

// calculate time of next maneuver
local transfer_to_parking is nextNode:obt:period / 2. // duration of transfer orbit is half a period
local parking_node is node(start_time + transfer_to_parking, 0, 0, parking_deltav).
add parking_node.
