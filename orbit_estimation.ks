// estimate inclination

// equations from http://control.asu.edu/Classes/MMAE441/Spacecraft/441Lecture21.pdf // 20 and 21
// and also from http://control.asu.edu/Classes/MMAE441/Spacecraft/441Lecture20.pdf // this is 21

function estimate_inclination { // estimate inclination from a given launch site
  parameter launch_latitude is ship:geoposition:lat. //latitude of the launch site
  parameter launch_azimuth is 90. // launch direction (90 degrees in most cases)

  local resulted_inclination is arccos(cos(launch_latitude) * sin(launch_azimuth)). // cos(inclination) = cos(latitude) * sin(direction)
  return resulted_inclination.
}

function estimate_launch_time { // estimate launch time given a desired inclination and LAN from a given launch site.
  parameter launch_latitude is ship:geoposition:lat.
  parameter launch_inclination is 0.01.
  parameter launch_longitude_of_ascending_node is 0.

  // SAFETY
  if launch_inclination = 0 {
    set launch_inclination to 0.01.
  } else if launch_inclination = 180 {
    set launch_inclination to 180.01.
  }

  local lambda_u is arccos(cos(launch_latitude) / sin(launch_inclination)). // lambda_u from page 18 http://control.asu.edu/Classes/MMAE441/Spacecraft/441Lecture21.pdf
  local launch_time is launch_longitude_of_ascending_node + lambda_u.
  local launch_time_reference is time:seconds + launch_time.
  return launch_time_reference.
}
