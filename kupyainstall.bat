@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo Loading...
wpeinit
call :detectvm
if not defined VMNUM (
    echo Could not map this VM by IP.
    echo Expected 192.168.1.14, 192.168.1.15, or 192.168.1.16
    pause
    exit /b 1
)

net use Z: \\192.168.1.1\winsetup /user:WORKGROUP\netboot netboot
if errorlevel 1 (
    echo Failed to map setup share.
    pause
    exit /b 1
)

echo Detected IP : !THISIP!
echo VM number   : !VMNUM!
echo PC name     : !PCNAME!
echo Join user   : !JOINUSER!
echo Auto user   : !AUTOUSER!
echo.

echo KUPYA WINDOWS NET INSTALLER
echo ===========================
echo 0. Open cmd lol
echo 1. Windows 7 (Non-UEFI only!)
echo 2. Windows Server 2012
echo 3. Windows 8.1
echo 4. Windows 11
echo ===========================

:c
set /p opt=Choose OS:
if "%opt%"=="1" goto win7
if "%opt%"=="2" goto win12
if "%opt%"=="3" goto win81
if "%opt%"=="4" goto win11
if "%opt%"=="0" goto cmd
goto c

:win7
Z:\win7\sources\setup.exe
goto c

:win12
Z:\win2k12\sources\setup.exe
goto c

:win81
Z:\win8.1\sources\setup.exe
goto c

:win11
reg add HKLM\SYSTEM\Setup\LabConfig /f
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassCPUCheck /t REG_DWORD /d 1 /f
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassStorageCheck /t REG_DWORD /d 1 /f

Z:\win11\sources\setup.exe
goto c

:cmd
cmd
goto c

:detectvm
set "THISIP="
for /f "tokens=2 delims=:" %%A in ('X:\Windows\System32\ipconfig.exe ^| X:\Windows\System32\find.exe "IPv4"') do (
    if not defined THISIP set "THISIP=%%A"
)
set "THISIP=%THISIP: =%"

for /f "tokens=4 delims=." %%A in ("%THISIP%") do set "LASTOCTET=%%A"

if "%LASTOCTET%"=="14" (
    set "VMNUM=4"
    set "PCNAME=KUPYA4"
    set "JOINUSER=kupya4"
    set "JOINPASS="
    set "AUTOUSER=kupya4"
    set "AUTOPASS="
    goto :eof
)
if "%LASTOCTET%"=="15" (
    set "VMNUM=5"
    set "PCNAME=KUPYA5"
    set "JOINUSER=kupya5"
    set "JOINPASS="
    set "AUTOUSER=kupya5"
    set "AUTOPASS="
    goto :eof
)
if "%LASTOCTET%"=="16" (
    set "VMNUM=6"
    set "PCNAME=KUPYA6"
    set "JOINUSER=kupya6"
    set "JOINPASS="
    set "AUTOUSER=kupya6"
    set "AUTOPASS="
    goto :eof
)

goto :eof

:makeunattend
set "UA=%~1"
> "%UA%" (
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^>
    echo   ^<settings pass="windowsPE"^>
    echo     ^<component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"^>
    echo       ^<UserData^>
    echo         ^<AcceptEula^>true^</AcceptEula^>
    echo         ^<ProductKey^>
    echo           ^<WillShowUI^>Never^</WillShowUI^>
    echo         ^</ProductKey^>
    echo       ^</UserData^>
    echo     ^</component^>
    echo   ^</settings^>
    echo   ^<settings pass="specialize"^>
    echo     ^<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"^>
    echo       ^<ComputerName^>!PCNAME!^</ComputerName^>
    echo     ^</component^>
    echo     ^<component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"^>
    echo       ^<Identification^>
    echo         ^<Credentials^>
    echo           ^<Domain^>ad.collabnet.local^</Domain^>
    echo           ^<Username^>!JOINUSER!^</Username^>
    echo           ^<Password^>!JOINPASS!^</Password^>
    echo         ^</Credentials^>
    echo         ^<JoinDomain^>ad.collabnet.local^</JoinDomain^>
    echo       ^</Identification^>
    echo     ^</component^>
    echo   ^</settings^>
    echo ^</unattend^>
)
goto :eof

:makeunattend11
set "UA=%~1"
> "%UA%" (
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^>
    echo   ^<settings pass="windowsPE"^>
    echo     ^<component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"^>
    echo       ^<DynamicUpdate^>
    echo         ^<Enable^>false^</Enable^>
    echo         ^<WillShowUI^>Never^</WillShowUI^>
    echo       ^</DynamicUpdate^>
    echo       ^<UserData^>
    echo         ^<AcceptEula^>true^</AcceptEula^>
    echo         ^<ProductKey^>
    echo           ^<Key^>XGVPP-NMH47-7TTHJ-W3FW7-8HV2C^</Key^>
    echo           ^<WillShowUI^>Never^</WillShowUI^>
    echo         ^</ProductKey^>
    echo       ^</UserData^>
    echo     ^</component^>
    echo   ^</settings^>
    echo   ^<settings pass="specialize"^>
    echo     ^<component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^>
    echo       ^<RunSynchronous^>
    echo         ^<RunSynchronousCommand wcm:action="add"^>
    echo           ^<Order^>1^</Order^>
    echo           ^<Description^>Disable OOBE updates^</Description^>
    echo           ^<Path^>cmd /c reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE" /v AllowOOBEUpdates /t REG_DWORD /d 0 /f^</Path^>
    echo         ^</RunSynchronousCommand^>
    echo         ^<RunSynchronousCommand wcm:action="add"^>
    echo           ^<Order^>2^</Order^>
    echo           ^<Description^>Disable Automatic Updates^</Description^>
    echo           ^<Path^>cmd /c reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f^</Path^>
    echo         ^</RunSynchronousCommand^>
    echo       ^</RunSynchronous^>
    echo     ^</component^>
    echo     ^<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"^>
    echo       ^<ComputerName^>!PCNAME!^</ComputerName^>
    echo     ^</component^>
    echo     ^<component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"^>
    echo       ^<Identification^>
    echo         ^<Credentials^>
    echo           ^<Domain^>ad.collabnet.local^</Domain^>
    echo           ^<Username^>!JOINUSER!^</Username^>
    echo           ^<Password^>!JOINPASS!^</Password^>
    echo         ^</Credentials^>
    echo         ^<JoinDomain^>ad.collabnet.local^</JoinDomain^>
    echo       ^</Identification^>
    echo     ^</component^>
    echo   ^</settings^>
    echo ^</unattend^>
)
goto :eof
