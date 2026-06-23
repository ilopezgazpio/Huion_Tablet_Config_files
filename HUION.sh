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

# Monitor mapping:
#   ./HUION.sh left             -> HEAD-1 landscape
#   ./HUION.sh right            -> HEAD-0 landscape
#   ./HUION.sh left portrait    -> HEAD-1 portrait
#   ./HUION.sh portrait         -> HEAD-1 portrait
#   ./HUION.sh portrait normal  -> HEAD-1 portrait without axis inversion
# Default keeps the current working setup.
monitor_arg="${1:-left}"
orientation_arg="${2:-landscape}"
direction_arg="${3:-normal}"

if [ "$monitor_arg" = "portrait" ]; then
  monitor_arg="left"
  orientation_arg="portrait"
  direction_arg="${2:-invert}"
fi

case "$monitor_arg" in
  left|HEAD-1|1)
    monitor_output="HEAD-1"
    ;;
  right|HEAD-0|0)
    monitor_output="HEAD-0"
    ;;
  -h|--help|help)
    echo "Usage: $0 [left|right] [landscape|portrait] [invert|normal]"
    echo "  left             maps the tablet to HEAD-1 in landscape mode"
    echo "  right            maps the tablet to HEAD-0 in landscape mode"
    echo "  left portrait    maps the centered tablet area to HEAD-1 in portrait mode"
    echo "  portrait         shortcut for: left portrait invert"
    echo "  portrait normal  maps to portrait without inverting the axes"
    exit 0
    ;;
  *)
    echo "Unknown monitor '$1'. Use: left, right, HEAD-1, or HEAD-0." >&2
    exit 1
    ;;
esac

case "$orientation_arg" in
  landscape)
    screenX=1920
    screenY=1080
    map_to_output="$monitor_output"
    tablet_rotate="none"
    ;;
  portrait)
    screenX=1080
    screenY=1920
    map_to_output="$monitor_output"
    case "$direction_arg" in
      invert|inverted|half)
        tablet_rotate="half"
        ;;
      normal|none)
        tablet_rotate="none"
        ;;
      *)
        echo "Unknown portrait direction '$direction_arg'. Use: invert or normal." >&2
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Unknown orientation '$orientation_arg'. Use: landscape or portrait." >&2
    exit 1
    ;;
esac

if [ "$monitor_output" = "HEAD-1" ] && [ "$orientation_arg" = "portrait" ]; then
  # HEAD-1 still behaves like a 1920x1080 output here, so the right side
  # of the tablet spills into HEAD-0. Use the explicit rotated geometry.
  map_to_output="1080x1920+0+0"
fi

# Reset
xsetwacom --set "$tabletstylus" ResetArea
xsetwacom --set "$tabletstylus" RawSample 4
xsetwacom --set "$tabletstylus" Rotate "$tablet_rotate"

# Mapping
# get maximum size geometry with:
# xsetwacom --get "$tabletstylus" Area
# 0 0 55200 34500
tabletX=55200
tabletY=34500
# screen size is set by the selected orientation above.
# map to good screen (dual nvidia)
# xrandr command to obtain displays
# there is a nvidia bug -> use HEAD-0 -1 , n instead of output from xrandr

# HDMI-0 should work according to xrandr, but does not map correctly here.
# xsetwacom --set "$tabletstylus" MapToOutput HDMI-0
xsetwacom --set "$tabletstylus" MapToOutput "$map_to_output"


# setup ratio :
if [ "$orientation_arg" = "portrait" ]; then
  # Keep the full vertical range, but use a centered horizontal range with
  # the same physical scale as vertical movement on the portrait display.
  newtabletX=$(( screenX * tabletY / screenY ))
  tabletXOffset=$(( (tabletX - newtabletX) / 2 ))
  xsetwacom --set "$tabletstylus" Area "$tabletXOffset" 0 "$(( tabletXOffset + newtabletX ))" "$tabletY"
elif [ $(( screenY * tabletX / screenX )) -le "$tabletY" ]; then
  newtabletY=$(( screenY * tabletX / screenX ))
  xsetwacom --set "$tabletstylus" Area 0 0 "$tabletX" "$newtabletY"
else
  newtabletX=$(( screenX * tabletY / screenY ))
  tabletXOffset=$(( (tabletX - newtabletX) / 2 ))
  xsetwacom --set "$tabletstylus" Area "$tabletXOffset" 0 "$(( tabletXOffset + newtabletX ))" "$tabletY"
fi

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
