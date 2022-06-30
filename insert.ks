// should be in intercept trajectory
// is orbitting the new body (got intercepted and is currently in escape trajectory)
// periapsis is above ground, is not in collision trajectory
parameter target_orbit_altitude.

runOncePath("functions.ks").


// calculate insertion burn
local insertion_sma is (body:radius + ship:periapsis + body:radius + target_orbit_altitude) / 2.
local target_velocity is vis_visa(body:mu, body:radius + ship:periapsis, insertion_sma).
local insertion_deltav is target_velocity - velocityAt(ship, time:seconds + eta:periapsis):orbit:mag.

// calculate circularization burn
local transfer_velocity is vis_visa(body:mu, body:radius + target_orbit_altitude, insertion_sma).
local circularization_velocity is vis_visa(body:mu, body:radius + target_orbit_altitude, body:radius + target_orbit_altitude).
local circularization_deltav is circularization_velocity - transfer_velocity.

// calculate insertion start time
local start_time is time:seconds + eta:periapsis.

// adding nodes
local insertion_node is node(start_time, 0, 0, insertion_deltav).
add insertion_node.

// circularization start time
local transfer_to_parking is nextNode:obt:period / 2.
local circularize_node is node(start_time + transfer_to_parking, 0, 0, circularization_deltav).
add circularize_node.
