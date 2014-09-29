pi-jumpstart-id
===============

Sets Raspberry Pi hostname at startup based on GPIO jumpers. This is weird and esoteric, but a thing I actually needed, so sharing it here just in case it's useful to others. Also for posterity so I don't lose it.

Requires 'gpio' utility -- present in 2014-09-09 or later Raspbian, or optionally install WiringPi.

This is a drop-in replacement for the /etc/init.d/hostname.sh script.

Sets the hostname to the contents of /etc/hostname plus a number based on the state of one or more GPIO pins which may be jumpered to ground. For example, if /etc/hostname contains 'dragon', hostname will be set to 'dragon0' if no jumpers are set. First jumper adds 1 to the index, second jumper adds 2, third adds 4 and so forth. Can be any number and choice of GPIO pins, defined by the PINS variable near the top:

```
PINS="17 23 25"
```

Uses Broadcom pin numbers. Note that some pin numbers are different between revision 1 and revision 2 boards; best just to avoid those.

This was for a cluster of headless Pis where each had a specific physicality, operating in conjunction with avahi-daemon so each shows on the local network as 'dragon0.local', 'dragon1.local' ... 'dragon5.local', etc. This allows a single SD image to be configured with various settings and packages, then duplicated in bulk (plus spares). In the event of a failure -- either the SD card or the Raspberry Pi -- it's immediately replaced with an identical spare, no login or reconfiguration required. Only the jumpers need to be set. Idea then is to have a passive header 'key' for each system, simply a GPIO header plug with certain pins connected to ground, easily moved to a new system if a board needs replacing.
