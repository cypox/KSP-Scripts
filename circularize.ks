// is in orbit

runOncePath("functions.ks").


// calculate velocity at target orbit
local target_velocity is vis_visa(body:mu, body:radius + ship:apoapsis, body:radius + ship:apoapsis).

// calculate deltav
local circularize_deltav is target_velocity - velocityAt(ship, time:seconds + eta:apoapsis):orbit:mag.

// calculate maneuver start time
local start_time is time:seconds + eta:apoapsis.

// adding node
local circularize_node is node(start_time, 0, 0, circularize_deltav).
add circularize_node.
