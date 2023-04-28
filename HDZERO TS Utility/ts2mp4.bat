:: =============================================================================
:: === Configuration ===========================================================
set app_path=c:\hdzero\


:: =============================================================================
:: === Main ====================================================================
if [%1]==[] goto TASK_menu

:: Init
@echo off
cls
set PROCESSERROR=0
if exist running.txt del running.txt
if exist filelist.txt del filelist.txt
if exist *.hdz del /f *.hdz >NUL
timeout /t 2 /nobreak >NUL

:: Start
:TASK_start
for %%i in ("%*") do (
set fullname=%%~nxi
)

echo file %fullname% > %fullname%.hdz
if %ERRORLEVEL% NEQ 0 goto TASK_exit

if exist running.txt goto TASK_exit
echo 1 > running.txt
if %ERRORLEVEL% NEQ 0 goto TASK_exit

:: === Task join all TS files in folder to single a MP4 and upscale ============
:TASK_join_MP4_and_upscale

:: Create TS file list
timeout /t 1 /nobreak >NUL

for /F "delims= eol=" %%A IN ('dir *.hdz /A-D /B /O D') do echo file %%~nA >> filelist.txt
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

:: Concatenate smaller TS Files to a single MP4
for /f "tokens=1-8 delims=:./ " %%G in ("%date%/%time%") do (set filedate=%%I_%%H_%%G_%%J_%%K)

%app_path%ffmpeg -y -f concat -safe 0 -i filelist.txt -c copy HDZERO_%filedate%.mp4
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

:: Upscale if specified

if 2==%1 %app_path%ffmpeg -y -i HDZERO_%filedate%.mp4 -vf scale=iw*2:ih*2 -preset slow -crf 18 UPSCALED_HDZERO_%filedate%.mp4
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

:: Clean up

if exist running.txt del running.txt
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

if exist *.hdz del /f *.hdz >NUL

if exist filelist.txt del filelist.txt
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)


:: =============================================================================
:: === Display error ===========================================================
:TASK_display_results

if %PROCESSERROR% EQU 0 goto TASK_exit
rem cls
echo.
echo.
echo WARNING! CONVERSION FAILED!!
echo.
echo:
pause
goto TASK_exit


:: =============================================================================
:: === Menu ====================================================================
:TASK_menu

SET PROCESSERROR=0

@echo OFF


:MENU
cls
echo.
echo ...............................................
echo.
echo HDZERO video utility installer
echo.
echo ...............................................
echo.
echo 1 - Install
echo 8 - Display notes
echo 9 - EXIT
echo.
set /P M=Select choice and press ENTER:
if %M%==1 goto TASK1
if %M%==8 goto TASK8
if %M%==9 goto TASK_EXIT
goto MENU


:TASK1
goto TASK_install
goto MENU

:TASK8
goto TASK_display_notes
goto MENU



:: =============================================================================
:: === install =================================================================
:TASK_install

cls
echo.
echo ...............................................
echo.
echo When prompted, choose Yes to requests to allow / confirm the app can make changes
echo.  
echo This is required to be able to associated TS files with this app
echo.
echo ...............................................
echo.
pause
cls

SET PROCESSERROR=0

if not exist %app_path% md %app_path% >NUL
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

if not exist %app_path%ffmpeg.exe copy /y ffmpeg.exe %app_path%  >NUL
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

if not exist %app_path%hdzero.reg copy /y hdzero.reg %app_path%  >NUL
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

if not exist %app_path%ts2mp4.bat copy /y ts2mp4.bat %app_path%  >NUL
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

if PROCESSERROR NEQ 0 %app_path%hdzero.reg  
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

if %PROCESSERROR% EQU 0 goto MENU

cls
echo.
echo HDZERO video utility
echo.
echo !!! WARNING !!! - install failed due to either:
echo  1 unable to write to c:\hdzero
echo  2 missing files
echo  3 not being run as administrator
echo.
pause
goto MENU



:: =============================================================================
:: === Display Notes =========================================================
:TASK_display_notes

SET PROCESSERROR=0
cls
echo.
echo HDZERO video utility
echo.
echo.To install:
echo   copy utility files into c:\hdzero
echo   run ts2mp4.bat 
echo   Accept / cooses Yes to make changes 
echo.
echo.To use:
echo   Right click on TS files and select "Convert TS..."
echo   Converted file will be created
echo.
echo Convert TS into MP4 (FAST):
echo   This converts one or more TS files to MP4 files
echo   This is a fast process and maintains video quality.
echo.
echo Join TS into single large MP4 (FAST):
echo   This joins multiple TS files into a single MP4 file. 
echo   This is a fast process and maintains video quality.
echo.
echo Join TS into single large MP4 and upscale to 1440p for Youtube (SLOW):
echo   This create an MP4 file and an upscaled version of the file at 1440p
echo   for Youtube to force YouTube into encoding at a higher quality.
echo   This is a VERY SLOW process as attempts are made to improve quality 
echo   during the upscaling process. Improvements are minor. 
echo.
pause
goto MENU


:TASK_exit