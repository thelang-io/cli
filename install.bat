::
:: Copyright (c) 2018 Aaron Delasy
:: Licensed under the MIT License
::

@echo off

set cdn_url="https://cdn.thelang.io/cli-core-windows"
set install_dir="C:\Program Files (x86)\The"
set install_path="%install_dir%\the.exe"

echo "Installing The CLI..."

powershell -Command "Invoke-WebRequest %cdn_url% -OutFile %install_path%"
chmod "+x" "%install_path%"
setx /m PATH "%PATH%;%install_dir%"

echo "Successfully installed The CLI!"
echo "  Type \`the -h\` to explore available options"
