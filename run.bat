@echo off

cls

title Scratch Basic
echo Scratch Basic Console; We value efficiency, organization and speed

set "filename=%~dp0/src/params/quiet.txt"
set "q="

:getcontent
if exist "%filename%" (
    for /f "usebackq delims=" %%A in ("%filename%") do (
        set "q=%%A"
    )
) else (
    echo File
)

goto ask

:ask
set /a input=hello
set /p input="> "

for /f "tokens=1" %%w in ("%input%") do set command=%%w

if "%command%"=="exit" (
    cls
    title Command Prompt
    EXIT /B 0
)
if "%command%"=="help" (
    goto lovehelp
)
if "%command%"=="run" (
    goto run
)
if "%command%"=="cls" (
    cls
    goto ask
)
if "%command%"=="ping" (
    echo pong
    goto ask
)
if "%command%"=="quiet" (
    if "%q%"=="0" (
        echo 1> %~dp0/src/params/quiet.txt
        echo Quiet: ON
    ) else (
        echo 0> %~dp0/src/params/quiet.txt
        echo Quiet: OFF
    )
    goto getcontent
)
if "%command%"=="path" (
    echo %CD%
    goto ask
)

echo Command does not exist
goto ask

:run
cls
if "%q%"=="0" (
    echo Preparing Run Environment
)
del /Q /F "%~dp0/src/env\*"
xcopy "%CD%" "%~dp0/src/env" /I /Y /Q 
if "%q%"=="0" (
    echo Starting Scratch Basic
) else (
    cls
)
%LOVE% %~dp0/src
goto ask

:lovehelp
echo Unavailable
goto ask

goto ask