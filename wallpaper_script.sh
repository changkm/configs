#!/bin/bash
export DISPLAY=:0.0
export XAUTHORITY=/run/user/1000/gdm/Xauthority
export DESKTOP_SESSION=i3
date >> /home/kmchang/repos/Daily-Reddit-Wallpaper/wallpaper.log
source /home/kmchang/repos/Daily-Reddit-Wallpaper/venv/bin/activate
#. /home/kmchang/discover_session_bus_address.sh unity
python /home/kmchang/repos/Daily-Reddit-Wallpaper/change_wallpaper_reddit.py >> /home/kmchang/repos/Daily-Reddit-Wallpaper/wallpaper.log 2>&1
deactivate
