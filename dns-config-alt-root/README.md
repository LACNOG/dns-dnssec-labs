# DNS CONFIG FILES FOR A PRIVATE ROOT

Author: carlos@lacnic.net 

These configuration files can be used to implement a lab environment with its own private root.

## Steps to use

- Create an empty bind install

- Always start with the "basic" configuration, copying it to /bind/etc
	# cp -v basic/* /bind/etc

- Then copy the lab-specific files
	# cp -v lab1/* /bind/etc

- Then make your own edits

- Start / restart BIND
