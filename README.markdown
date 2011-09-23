#Kevin Clicks

##Web interface to a Arduino controlled Remote Control / Door Opener / Coffee Maker

This project takes signals & taps from the internet and uses them to
control a bunch of stuff in my brother's house. The stuff includes his
television remote, the door to his house, a coffee maker, and some
lights

###Web Interface

Is written in python and relays commands to a redis queue for
processing

###Worker

Also in python, waits for commands to enter redis queue, reads them out
and sends them via serial to the Arduino

###Ardunio Sketch

Controls a bunch of stuff via a series of muxes


