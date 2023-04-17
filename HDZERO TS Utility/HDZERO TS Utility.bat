:: =============================================================================
:: === Utility Menu ========================================

@echo OFF
goto TASK_file_test

:MENU
cls
echo.
echo ...............................................
echo.
echo HDZERO video utility
echo.
echo ...............................................
echo.
echo 1 - Join TS into single large MP4 (FAST)
echo 2 - Join TS into single large MP4 and upscale to 1440p for Youtube
echo 3 - Display notes
echo 9 - EXIT
echo.
set /P M=Select choice and press ENTER:
if %M%==1 goto TASK1
if %M%==2 goto TASK2
if %M%==3 goto TASK3
if %M%==9 goto TASK_EXIT
goto MENU


:TASK1
set CALLRETURN=MENU
set PROCESSERROR=0
goto TASK_join_MP4
goto MENU

:TASK2
set CALLRETURN=MENU
set PROCESSERROR=0
goto TASK_join_MP4_and_upscale
goto MENU

:TASK3
set CALLRETURN=MENU
goto TASK_display_notes
goto MENU



:: =============================================================================
:: === Test for ability to process =============================================
:TASK_file_test

set PROCESSERROR=0

if exist ts_list_concat.txt del ts_list_concat.txt

if not exist ffmpeg.exe (SET PROCESSERROR=1)

for %%i in (*.ts) do echo file %%i >> ts_list_concat.txt
if not exist ts_list_concat.txt (SET PROCESSERROR=1)

echo test > ts_list_concat.txt
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

if exist ts_list_concat.txt del ts_list_concat.txt
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

if %PROCESSERROR% EQU 0 goto MENU

cls
echo.
echo HDZERO video utility
echo.
echo !!! WARNING !!! - this utility will no operate due to either:
echo  1 ffmpeg.exe is missing
echo  2 unable to save files
echo  3 no TS files to convert found
echo.
pause
goto MENU



:: =============================================================================
:: === Display Notes =========================================================
:TASK_display_notes

cls
echo.
echo HDZERO video utility
echo.
echo Join TS into single large MP4 (FAST):
echo  This joins multiple TS files into a single MP4 file. This is a fast
echo  process and maintains video quality.
echo.
echo Join TS into single large MP4 and upscale to 1440p for Youtube (SLOW):
echo  This create two files:-
echo   A MP4 file as above
echo   A second upscaled version of the file at 1440p for Youtube to force 
echo   YouTube into displaying at a higher quality.
echo   This is a slow process as attempts are made to improve quality during
echo   the upscaling process 
echo.
echo. To use:
echo   Place TS files you wish to join into the same folder as this utility.
echo   TS files must be numbered in order of joining (HDZERO default practice)
echo   File will be created with prefix of HDZERO or UPSCALED HDZERO
echo. 
pause
goto %CALLRETURN%



:: =============================================================================
:: === Display results =========================================================
:TASK_display_results

if %PROCESSERROR% NEQ 0 goto TASK_error_display_results
cls
echo.
echo Completed without errors!!
echo.
echo:
pause
goto %CALLRETURN%
:TASK_error_display_results
echo.
echo.
echo WARNING! CONVERSION FAILED!!
echo.
echo:
pause
goto %CALLRETURN%



:: === Task join TS to single MP4 =========================================
:TASK_join_MP4
cls
if exist ts_list_concat.txt del ts_list_concat.txt

:: Create TS File List
for %%i in (*.ts) do echo file %%i >> ts_list_concat.txt

:: Concatenate smaller TS Files to single large MP4 file
for /f "tokens=1-8 delims=:./ " %%G in ("%date%/%time%") do (set filedate=%%I_%%H_%%G_%%J_%%K)
if exist HDZERO_%filedate%.mp4 del HDZERO_%filedate%.mp4
ffmpeg -f concat -safe 0 -i ts_list_concat.txt -c copy HDZERO_%filedate%.mp4
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

goto TASK_display_results



:: === Task join TS to single MP4 and upscale ==================================
:TASK_join_MP4_and_upscale
cls
if exist ts_list_concat.txt del ts_list_concat.txt

:: Create TS File List
for %%i in (*.ts) do echo file %%i >> ts_list_concat.txt

:: Concatenate smaller TS Files to two MP4 files: straight join and upscaled
for /f "tokens=1-8 delims=:./ " %%G in ("%date%/%time%") do (set filedate=%%I_%%H_%%G_%%J_%%K)
ffmpeg -f concat -safe 0 -i ts_list_concat.txt -c copy HDZERO_%filedate%.mp4
ffmpeg -i HDZERO_%filedate%.mp4 -vf scale=iw*2:ih*2 -preset slow -crf 18 UPSCALED_HDZERO_%filedate%.mp4
if %ERRORLEVEL% NEQ 0 (SET PROCESSERROR=1)

goto TASK_display_results



:: =============================================================================
:: === Notes section ony =======================================================

rem dir ts /O=N /B *.ts > ts_list_concat.txt
     
:TASK_EXIT