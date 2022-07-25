runOncePath("0:/library/clib_gui.ks").


function execute_node{
  parameter nd is nextnode.

  //print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

  local max_acc is ship:maxthrust/ship:mass.

  local burn_duration is nd:deltav:mag/max_acc.
  //print "Crude Estimated burn duration: " + round(burn_duration) + "s".

  kuniverse:timewarp:warpto(time:seconds + nd:eta - (burn_duration/2 + 20))..
  // wait until kuniverse:timewarp:issettled. // ADD THIS IF TIMEWARP IS CAUSING PROBLEMS

  wait until nd:eta <= (burn_duration/2 + 15).

  local np is nd:deltav.
  lock steering to np.

  wait until vang(np, ship:facing:vector) < 0.25.

  wait until nd:eta <= (burn_duration/2).

  local tset is 0.
  lock throttle to tset.

  local done is False.

  local dv0 is nd:deltav.
  until done
  {
    update_node_info(burn_duration, round(vdot(dv0, nd:deltav),1)).
  
    set max_acc to ship:maxthrust/ship:mass.

    set tset to min(nd:deltav:mag/max_acc, 1).

    if vdot(dv0, nd:deltav) < 0
    {
      //print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
      lock throttle to 0.
      break.
    }

    if nd:deltav:mag < 0.1
    {
      //print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
      wait until vdot(dv0, nd:deltav) < 0.5.

      lock throttle to 0.
      //print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
      set done to True.
    }
  }
  unlock steering.
  unlock throttle.
  wait 1.

  remove nd.

  set ship:control:pilotmainthrottle to 0.
}
