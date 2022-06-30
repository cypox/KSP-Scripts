local delay is 1.
local style is 2.
// Where to show the message on the screen:
//- 1 = upper left
//- 2 = upper center
//- 3 = upper right
//- 4 = lower center
// Note that all these locations have their own defined slightly different fonts and default sizes, enforced by the stock KSP game.
local size is 45.
local colour is RGBA(1, 0.2, 0.2, 1).
local echo is false.

function countdown {
  HUDTEXT("5", delay, style, size, colour, echo).
  wait 1.
  HUDTEXT("4", delay, style, size, colour, echo).
  wait 1.
  HUDTEXT("3", delay, style, size, colour, echo).
  wait 1.
  HUDTEXT("2", delay, style, size, colour, echo).
  wait 1.
  HUDTEXT("1", delay, style, size, colour, echo).
  wait 1.
  HUDTEXT("GO!", delay, style, size, colour, echo).
}

function announce_tr {
  parameter msg.
  HUDTEXT(msg, 5, 3, 30, rgba(0.2, 1, 0.2, 1), echo).
}

function draw_from_to {
  parameter from.
  parameter to.
  VECDRAW(from, to, rgba(1, 0, 0, 1), "", 1.0, true, 1.0, true).
}

clearVecDraws().

local debug_readouts is false.

when debug_readouts then {
  until false {
    print "Altitude : " + round(ship:altitude, 0) + " m                       " at (1, 1).
    print "Pitch    : " + round(ship:facing:pitch, 0) + "°                    " at (1, 2).
    print "Heading  : " + round(ship:facing:roll, 0) + "°                     " at (1, 3).
    wait 0.2.
  }
}

function enable_readouts {
  clearScreen.
  // set debug_readouts to true. // need a second CPU for this to work.
}

function setup_hud {
  clearscreen.
  PRINT " Current Mode =" AT (1,0).
  PRINT "==================================================" AT (0,2).
  PRINT "Sea Lvl.        | Ground         | Orbit" AT (0,3).
  PRINT "  Alt.          |  Dist.         | Incl." AT (0,4).
  PRINT "  [km]          |  [km]          | [deg]" AT (0,5).
  PRINT "----------------+----------------+----------------" AT (0,6).
  PRINT "Apoap.          |Periap.         |  TWR" AT (0,7).
  PRINT " [km]           | [km]           |Max TWR" AT (0,8).
  PRINT " (ETA)          | (ETA)          |% Term V" AT (0,9).
  PRINT "----------------+----------------+----------------" AT (0,10).
  PRINT " Total          | Stage          | Spent" AT (0,11).
  PRINT "Vac. dV         |  dV            |  dV" AT (0,12).
  PRINT " [m/s]          | [m/s]          | [m/s]" AT (0,13).
  PRINT "==================================================" AT (0,14).
}

function update_readouts {
  PRINT RUNMODE at (18,0).
  PRINT ROUND(ALTITUDE/1000,2)+" "   AT (8,4).
  //SET downRangeDist TO SQRT(launchLoc:Distance^2 - (ALTITUDE-launchAlt)^2). // #@ should update to use curvature
  //PRINT ROUND(downRangeDist/1000,2)+" " AT (25,4).
  PRINT ROUND(SHIP:OBT:INCLINATION,1)+"  " AT (44,4).
  PRINT ROUND(APOAPSIS/1000,2)+" " AT (8,8).
  PRINT ROUND(ETA:APOAPSIS) + "s " AT (9,9).
  PRINT ROUND(PERIAPSIS/1000,2)+"  " AT (24,8).
  PRINT ROUND(ETA:PERIAPSIS) + "s " AT (26,9).
  //SET engInfo TO activeEngineInfo().
  //SET currentTWR TO engInfo[0]/(SHIP:MASS*BODY:MU/(ALTITUDE+BODY:RADIUS)^2).
  //SET maxTWR TO engInfo[1]/(SHIP:MASS*BODY:MU/(ALTITUDE+BODY:RADIUS)^2).
  //PRINT ROUND(currentTWR,2)+"   " AT (44,7).
  //PRINT ROUND(maxTWR,2) + "  " AT (44,8).
  //IF pctTerminalVel = "N/A" OR pctTerminalVel = "NoAcc" {
  //    PRINT pctTerminalVel + "  " AT (44,9).
  //}.
  //ELSE {
  //    PRINT ROUND(pctTerminalVel,0) + "  " AT (44,9).
  //}.
  SET shipDeltaV TO "TBD". // ## TODO
  PRINT shipDeltaV AT (9,12).
  //SET stageDeltaV TO deltaVStage().
  //PRINT ROUND(stageDeltaV)+" " AT (26,12).
  //IF lastDVTime < TIME:SECONDS AND finalBurnTime = 0 {
  //    SET dVSpent TO dVSpent + ((engInfo[0]/SHIP:MASS) * (TIME:SECONDS - lastDVTime)).
  //    SET lastDVTime TO TIME:SECONDS.
  //}
  //ELSE IF finalBurnTime > 0 {
  //    SET dVSpent TO dVSpent + ((engInfo[1]/SHIP:MASS) * finalBurnTime).
  //}.
  //PRINT ROUND(dVSpent,0) + "   " AT (44,12).
}
