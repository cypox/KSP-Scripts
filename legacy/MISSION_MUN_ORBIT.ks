// from orbit to mun
run orbit.
run execute.
run circularize.
run execute.
//run hohmann(100000).
//run execute.
run transfer(mun, 20000).
run execute.
kuniverse:timewarp:warpto(time:seconds + obt:nextpatcheta).
wait until obt:transition = "ESCAPE".
run insert(20000).
run execute.
run circularize.
run execute.
