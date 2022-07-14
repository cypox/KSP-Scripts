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

local start_time is 0.

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
  print "               Flight Control Panel               ".
  print " ".
  print " +------------------------+ +--------------------+".
  print " | Runmode =              | | Time =           s |".
  print " +------------------------+ +--------------------+".
  print " ".
  print " +---------------------+    +--------------------+".
  print " | Heading =         ° |    | Pitch  =         ° |".
  print " | Roll    =         ° |    |                    |".
  print " +---------------------+    +--------------------+".
  print " ".
  print " +---------------------+    +--------------------+".
  print " | Speed    =       m/s|    | VSpeed =        m/s|".
  print " | Altitude =        m |    |                    |".
  print " +---------------------+    +--------------------+".
  print " ".
  set start_time to time:seconds.
}

function update_readouts {
  print runmode at (13, 3).
  print round(time:seconds-start_time, 0) + "    " at (37, 3).

  print round(compass_for(ship), 0) + "  " at (15, 7).
  print round(roll_for(ship), 0) + "  " at (15, 8).
  print round(pitch_for(ship), 0) + "  " at (40, 7).

  print round(ship:velocity:surface:mag, 0) + "  " at (15, 12).
  print round(ship:altitude, 0) + "  " at (15, 13).
  print round(verticalSpeed, 0) + "  " at (40, 12).
}
