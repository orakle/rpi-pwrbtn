#!/bin/sh
#
###############################################################################
# Copyright 2012-2013 Guillermo A. Amaral B. All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
#  NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
#  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
#  DAMAGE.
#
## INSTALL ####################################################################
#
# Simply run as this script as a daemon on system start.
#
# Here's an example of how you could do just that on target.
#
# su # become root
# cp rpi-psu_client.sh /usr/local/bin
# chmod 700 /usr/local/bin/rpi-psu_client.sh
# echo "null::once:/root/rpi-psu_client.sh" >> /etc/inittab
#
## UBUNTU USERS ###############################################################
#
# Since ubuntu points /bin/sh to Dash, you will need to replace the top line
# from #!/bin/sh to #!/bin/bash or trap won't work.
#
###############################################################################

cleanup()
{
    echo "1" > /sys/class/gpio/gpio${RPI_READY}/value
    echo ${RPI_READY} > /sys/class/gpio/unexport
    echo ${RPI_SHUTDOWN} > /sys/class/gpio/unexport
}

# Pin defs
RPI_SHUTDOWN=23
RPI_READY=24

# RPI Shutdown Pin
echo ${RPI_SHUTDOWN} > /sys/class/gpio/export
echo "in"  > /sys/class/gpio/gpio${RPI_SHUTDOWN}/direction

# RPI Ready Pin
echo ${RPI_READY} > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio${RPI_READY}/direction
echo "0" > /sys/class/gpio/gpio${RPI_READY}/value

# Traps
trap 'cleanup; exit' SIGHUP SIGINT SIGTERM SIGQUIT

# Wait for shutdown signal
while [ `cat /sys/class/gpio/gpio${RPI_SHUTDOWN}/value` -lt 1 ]; do
	sleep 1
done

# Clean up
cleanup

# Shutdown RPI
shutdown -Ph now || poweroff
