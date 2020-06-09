// should be in ground with enough deltav to reach orbit

@lazyGlobal off.

// load functions
runOncePath("functions.ks").
// load staging logic
runOncePath("staging.ks").
// load hud logic
runOncePath("gui.ks").

local pitch is 90.
local rotation is 90.
local thr is 0.

lock steering to heading(rotation, pitch).
lock throttle to thr.

sas off.
rcs off.

set staging to false.
init_staging_logic().

enable_readouts().

// countdown
countdown().

// initial climb
announce_tr("Throttling up").
set thr to 1.
wait 0.1.
announce_tr("Ignition").
wait 0.1.
set staging to true.
wait until ship:altitude > 5000.
announce_tr("Liftoff successfull").

// gravity ascent
set pitch to 85.
wait until ship:altitude > 10000.
announce_tr("Pitching to " + 85 + " degrees").
set pitch to 75.
wait until ship:altitude > 15000.
announce_tr("Pitching to " + 45 + " degrees").
set pitch to 45.
wait until orbit:apoapsis > 105000.
set thr to 0.
announce_tr("We are in sub-orbital trajectory").

// calculate circularization burn
local desired_orbit is 100000.
local target_velocity is vis_visa(body:mu, body:radius + desired_orbit, body:radius + desired_orbit).
local current_velocity is velocityAt(ship, time:seconds + eta:apoapsis):orbit:mag.
local circularization_deltav is target_velocity - current_velocity.

// adding circularization node
local start_time is time:seconds + eta:apoapsis.
local circularization_node is node(start_time, 0, 0, circularization_deltav).
add circularization_node.

// finished
set thr to 0.
unlock throttle.
unlock steering.
