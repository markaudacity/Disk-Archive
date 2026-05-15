echo off
cls
rem Install.Bat -- installs COMit on your hard disk
rem Expects the first parameter to be the target drive and directory

Echo þ COMit installation ...
if "%1"=="" goto Error
if not exist %1\NUL mkdir %1
if not exist %1\NUL goto Error
echo þ
echo þ Copying COMit files to %1
echo þ

for %%f in (*.*) do echo %%f
Echo Copying Nine Files to %1
copy comit.exe %1
if not exist %1\comit.exe goto NoInstall
echo Copying 2nd file....
copy help.exe %1
if not exist %1\help.exe goto NoInstall
echo Copying 3rd file....
copy comit.h! %1
if not exist %1\comit.h! goto NoInstall
echo Copying 4th file....
copy comith.bat %1
if not exist %1\comith.bat goto NoInstall
echo Copying 5th file....
copy comithp.bat %1
if not exist %1\comithp.bat goto NoInstall
echo Copying 6th file....
copy readme.bat %1
if not exist %1\readme.bat goto NoInstall
echo Copying 7th file....
copy install.bat %1
if not exist %1\install.bat goto NoInstall
echo Copying 8th file....
copy manual.exe %1
if not exist %1\manual.exe goto NoInstall
echo Copying 9th file....
copy Menu_key.bat %1
if not exist %1\menu_key.bat goto NoInstall
echo done...
goto NoError
:NoInstall
echo þ
echo þ Not all files were installed.  Disk full or File missing?
goto Error
:Error
echo þ
echo þ
echo þ Put the COMit disk in drive "A" or "B".  From the DOS prompt...
echo þ
echo þ Type a valid drive and pathname, eg: INSTALL C:\COMIT
echo þ Note: If the directory does not exist, it will be created.
echo þ
echo þ Or, you can enter just the drive if you want to make a
echo þ backup floppy, eg: INSTALL B:
echo þ this will make a backup copy on drive "B"
echo þ
:Failed
echo þ       
echo þ               ====--- COMit  not installed ---====
echo þ
echo þ    Please follow the instructions above. If you get this message
echo þ    after using the above instructions, consult your DOS manual
echo þ    and use the "COPY" command to transfer the files to your hard disk.
echo þ
echo þ
goto Done
:NoError
cls
echo þ
echo þ  COMit successfully copied.
echo þ
echo þ  Choices:
echo þ            COMIT [Enter]      (COMit, with No Help)
echo þ            HELP [Enter]       (Help by itself)
echo þ            README [Enter]     (The readme file)
echo þ            COMITH [Enter]     (COMit, with [Alt-Z] for Help)
echo þ
echo þ
echo þ                   =====----  N O T E  ----=====
echo þ
echo þ       The COMit Menu key is set at "/" (FORWARD SLASH) as a default.
echo þ       You can change this key by going to the "SETUP" menu
echo þ       after starting COMit and selecting the "F" (F KEYS) option.
echo þ       It's the last entry on that page.
echo þ
echo þ  Change your drive and directory to ====--- " %1 "
echo þ  Then enter one of the above choices.
echo þ
:Done
