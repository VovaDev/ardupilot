#!/bin/bash

# script to build cygwin binaries for using in MissionPlanner
# the contents of artifacts directory is uploaded to:
# https://firmware.ardupilot.org/Tools/MissionPlanner/sitl/

# the script assumes you start in the root of the ardupilot git tree

set -x

rm -rf artifacts
mkdir artifacts

(
    ./waf --color yes --toolchain i686-pc-cygwin --board sitl configure 2>&1
    ./waf plane 2>&1
    ./waf copter 2>&1
) | tee artifacts/build.txt

i686-pc-cygwin-g++ -print-sysroot

cp -v build/sitl/bin/arduplane artifacts/ArduPlane.elf
cp -v build/sitl/bin/arducopter artifacts/ArduCopter.elf

cp -v /usr/i686-pc-cygwin/sys-root/usr/bin/*.dll artifacts/

# Find all cyg*.dll files returned by cygcheck for each exe in artifacts
# and copy them over
for exe in artifacts/*.exe; do 
    echo $exe
    cygcheck $exe | grep -oP 'cyg[^\s\\/]+\.dll' | while read -r line; do
      cp -v /usr/bin/$line artifacts/
    done
done

git log -1 > artifacts/git.txt
