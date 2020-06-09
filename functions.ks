
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
