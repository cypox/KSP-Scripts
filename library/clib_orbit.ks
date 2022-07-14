
function vis_visa {
  parameter u.
  parameter r.
  parameter a.
  return sqrt(u * (2/r - 1/a)).
}

function angular_velocity {
  parameter sma.
  return 360 * sqrt(body:mu / sma ^ 3) / (2 * constant:pi).
}

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
