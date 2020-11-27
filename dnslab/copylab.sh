#!/bin/sh
############################################################

if  [ "x$1" = "xclean" ]; then
	echo "Cleaning /bind/etc"
	rm -v /bind/etc/*
else
	if  [ -d $1 ]; then
		echo Restoring "basic" configuration
		cp -v basic/* /bind/etc
		echo " "
		echo Copying lab name [$1]
		cp -v $1/* /bind/etc
	else
		echo Lab $1 does not exist
	fi
fi

############################################################
