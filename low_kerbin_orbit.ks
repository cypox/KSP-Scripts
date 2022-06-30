local runmode to "pre".

until runmode = "done" {
  if runmode = "pre" {
    print "Lockdown".
    set runmode to "ascent".
  }
  else if runmode = "ascent" {
    set runmode to "gravity".
  }
  else if runmode = "gravity" {
    set runmode to "circularize".
  }
  else {
    set runmode to "done".
  }
}
