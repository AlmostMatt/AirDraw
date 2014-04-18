@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

set AIR_TARGET=
::set AIR_TARGET=-captive-runtime
::adt -package -target native c:\AirExe\myApp.exe c:\AirExe\myAirApp.air
set OPTIONS=
call bat\Packager.bat

pause