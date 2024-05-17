#! /bin/bash

# Setup HUION WH1409, after bridged to wacom driver with Digimend Kernel module.
# License: CC-0/Public-Domain license
# author: deevad
# FROM https://www.davidrevoy.com/article331/setup-huion-giano-wh1409-tablet-on-linux-mint-18-1-ubuntu-16-04

# HARDWARE PARTS
# sudo apt install dkms git-core
# sudo git clone https://github.com/DIGImend/digimend-kernel-drivers.git /usr/src/digimend-9
# sudo dkms build digimend/9
# sudo dkms install digimend/9

# xinput --list
# dkms status

# CREATE FILE /usr/share/X11/xorg.conf.d/50-huion.conf
# xsetwacom --list

# Install also dev files for libwacom in synaptic

# PAD SHOULD HAVE NAME AS BELOW
# Tablet definition
tabletstylus="TABLET Pen Tablet stylus"
tabletpad="TABLET Pen Tablet Pad pad"
# tabletpad="TABLET Pen Tablet Touch Strip pad"

# Reset
xsetwacom --set "$tabletstylus" ResetArea
xsetwacom --set "$tabletstylus" RawSample 4

# Mapping
# get maximum size geometry with:
# xsetwacom --get "$tabletstylus" Area
# 0 0 55200 34500
tabletX=55200
tabletY=34500
# screen size:
screenX=1920
screenY=1080
# map to good screen (dual nvidia)
# xrandr command to obtain displays
# there is a nvidia bug -> use HEAD-0 -1 , n instead of output from xrandr

#xsetwacom --set "$tabletstylus" MapToOutput HEAD-0
xsetwacom --set "$tabletstylus" MapToOutput HDMI-A-0

# setup ratio :
newtabletY=$(( $screenY * $tabletX / $screenX ))
xsetwacom --set "$tabletstylus" Area 0 0 "$tabletX" "$newtabletY"

# Buttons  (optimized for xournal app)
# =======
xsetwacom --set "$tabletstylus" Button 2 2
xsetwacom --set "$tabletstylus" Button 3 3
# ---------
# | 1 | 2 |
# |---|---|
# | 3 | 8 |
# |=======|
# | 9 |10 |
# |---|---|
# |11 |12 |
# |=======|
# |13 |14 |
# |---|---|
# |15 |16 |
# |=======|
xsetwacom --set "$tabletpad" Button 1 "key Control" "key Shift" "key p"
xsetwacom --set "$tabletpad" Button 2 "key Control" "key Shift" "key e"
xsetwacom --set "$tabletpad" Button 3 "key Control" "key Shift" "key h"
xsetwacom --set "$tabletpad" Button 8 "key Control" "key Shift" "key l"

xsetwacom --set "$tabletpad" Button 9 "key Control" "key Shift" "key i"
xsetwacom --set "$tabletpad" Button 10 "key Control" "key Shift" "key t"
xsetwacom --set "$tabletpad" Button 11 "key Control" "key Shift" "key r"
xsetwacom --set "$tabletpad" Button 12 "key del"

xsetwacom --set "$tabletpad" Button 13 "key Control" "key Shift" "key a"
xsetwacom --set "$tabletpad" Button 14 "key Control" "key Shift" "key v"
xsetwacom --set "$tabletpad" Button 15 "key Control" "key z"
xsetwacom --set "$tabletpad" Button 16 "key Control" "key y"


# Xinput option  
# =============  
# for the list:  
# xinput --list  

# xinput list-props 'TABLET Pen Tablet Mouse'  
# xinput set-prop 'TABLET Pen Tablet Mouse' "Evdev Middle Button Emulation" 0  
# alternate way to map to a single screen  
# execute "xrander" in a terminal to get the screen name ( DVI-D-0 in this example )  
# xinput set-prop 'TABLET Pen Tablet Pen stylus' DVI-D-0
