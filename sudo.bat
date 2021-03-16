@setlocal&goto entry
#! For this tool, this should be placed in C:\windows\sudo.bat

sudo [cmd|_hide|_unhide|_clean|_transform|_restore]

` cmd for default, some complex chars like spaces, quotes is not expected for the f**king cmd interpreter

` _hide, _unhide control the visiblity of the user "admin" (can be edited below, it can't be Administrator.)

` _transform, _restore make current user an Administrator to do some settings for current env.


. _hide needs relogin to refresh the list ( but takes effect immediately )
. _transform, _restore need relogin, and do it as soon as possible


, UAC should gray whole screen to gain better experience
# UserAccountControlSettings.exe

For cmd.exe, the special characters that require quotes are:
     <space>
     &()[]{}^=;!'+,`~

For cmd.exe, don't setup any autoruns according to "cmd/?"


:entry
@echo off&setlocal enabledelayedexpansion

set admin_name=admin
set magic_12byte=_To_Execute_
set tmp_prefix=sudo_neverconflict

set args_$UD0=%*
set args_$UD0=!args_$UD0:^"=^\^"!
if "!control_$UD0!"=="yes" set args_$UD0=
if "%~1"=="!magic_12byte!" goto:dosth
if "%~1"=="_hide"      (set unhide_$UD0=0& goto:control_admin)
if "%~1"=="_unhide"    (set unhide_$UD0=1& goto:control_admin)
if "%~1"=="_transform" (set trans_$UD0=add& goto:transform)
if "%~1"=="_restore"   (set trans_$UD0=delete& goto:transform)
if "%~1"=="_clean"     (goto:cleanup)
set pwwd_$UD0=!cd!
cd /d !windir!
runas /noprofile /env /user:!admin_name! "%~dpnx0 !magic_12byte! !args_$UD0!"
goto:end

:dosth
set pwwd_$UD0=!pwwd_$UD0:^"=!
if "!control_$UD0!"=="yes" cd /d "!tmp!" & set args_$UD0=!magic_12byte! reg.exe import !hide_$UD1!.reg
start /min powershell -Command "Start-Process cmd -Verb RunAs -WindowStyle Minimized -ArgumentList '/d /c cd /d !pwwd_$UD0!&&start !args_$UD0:~13!'"
endlocal
goto:end

:control_admin
set control_$UD0=yes
set hide_$UD1=!tmp_prefix!_%random%.tmp
cd /d "!tmp!"
del /f /s /q !tmp_prefix!_*.tmp.reg >nul 2>nul
rem cleanup previous data
if "!control_$UD0!"=="yes" (
echo Windows Registry Editor Version 5.00
echo;
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList]
echo "!admin_name!"=dword:0000000!unhide_$UD0!
)>!hide_$UD1!.reg
"%~dpnx0"
goto:end

:transform
"%~dpnx0" net localgroup Administrators !username! /!trans_$UD0!
rem cleanup by the way

:cleanup
cd /d "!tmp!"
del /f /s /q !tmp_prefix!_*.tmp.reg >nul 2>nul

:end
endlocal
