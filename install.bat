@echo off

::
:: Copyright (c) 2018 Aaron Delasy
:: Licensed under the MIT License
::

set cdn_url=https://cdn.thelang.io/cli-core-windows
set install_dir=C:\Program Files\The
set install_path=%install_dir%\the.exe

echo Installing The CLI...
if not exist "%install_dir%" mkdir "%install_dir%" || goto :error
powershell -c "iwr '%cdn_url%' -OutFile '%install_path%'" || goto :error
icacls "%install_path%" /grant:r "users:(X)" > nul || goto :error
setx PATH "%PATH%;%install_dir%" /M > nul || goto :error
echo Successfully installed The CLI!
echo   Type `the -h` to explore available options
goto :EOF

:error
exit /b %errorlevel%
