@echo off
wmic PATH Win32_VideoController get name /Value <nul
echo ,
wmic PATH Win32_VideoController get driverversion /Value <nul