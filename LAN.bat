@echo off
color 0a
title Network Monitor

:: ===== CONFIG =====
set ROUTER=192.168.1.1
set TARGET=8.8.8.8
set DEVICE1=192.168.1.100
set DEVICE2=192.168.1.101

:: ===== GET LOCAL IP =====
echo Getting local IP...
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr "IPv4"') do set LOCALIP=%%A
set LOCALIP=%LOCALIP:~1%

:: ===== GET PUBLIC IP =====
echo Getting public IP...
for /f %%A in ('curl -s ifconfig.me') do set PUBLICIP=%%A

:loop
cls
echo ===============================
echo        NETWORK MONITOR
echo ===============================
echo Local IP: %LOCALIP%
echo Public IP: %PUBLICIP%
echo.

:: ===== ROUTER LATENCY =====
for /f "tokens=7 delims== " %%A in ('ping -n 1 %ROUTER% ^| find "time="') do set ROUTERPING=%%A
echo Router (%ROUTER%): %ROUTERPING%

:: ===== INTERNET LATENCY =====
for /f "tokens=7 delims== " %%A in ('ping -n 1 %TARGET% ^| find "time="') do set TARGETPING=%%A
echo Internet (%TARGET%): %TARGETPING%

:: ===== DEVICE MONITOR =====
for /f "tokens=7 delims== " %%A in ('ping -n 1 %DEVICE1% ^| find "time="') do set DEV1PING=%%A
echo Device1 (%DEVICE1%): %DEV1PING%

for /f "tokens=7 delims== " %%A in ('ping -n 1 %DEVICE2% ^| find "time="') do set DEV2PING=%%A
echo Device2 (%DEVICE2%): %DEV2PING%

:: ===== LOGGING =====
echo %date% %time% | Router: %ROUTERPING% | Net: %TARGETPING% >> log.txt

timeout /t 2 >nul
goto loop
