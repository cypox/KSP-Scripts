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
local echo is true.

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
