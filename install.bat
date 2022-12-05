::
:: Copyright (c) 2018 Aaron Delasy
:: Licensed under the MIT License
::

@echo off

set cdn_url="https://cdn.thelang.io/cli-core-windows"
set install_dir="C:\Program Files\The"
set install_path="%install_dir%\the.exe"

echo Installing The CLI...
if not exist "%install_dir%" mkdir "%install_dir%"
powershell -c "Invoke-WebRequest %cdn_url% -OutFile %install_path%" || goto :error
icacls %install_path% /grant:r "users:(X)" /C || goto :error
setx PATH "%PATH%%install_dir%;" /M || goto :error
echo Successfully installed The CLI!
echo   Type \`the -h\` to explore available options
goto :EOF

:error
exit /b %errorlevel%
