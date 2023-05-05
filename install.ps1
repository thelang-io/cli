#
# Copyright (c) Aaron Delasy
# Licensed under the MIT License
#

Set-StrictMode -Version latest
$ErrorActionPreference = 'Stop'

function Get-SystemEnv ([string] $Name) {
  [Environment]::GetEnvironmentVariable($Name, [EnvironmentVariableTarget]::Machine)
}

function Request-File ([string] $Url, [string] $Path) {
  (New-Object -TypeName System.Net.WebClient).DownloadFile($DownloadUrl, $InstallPath)
}

function Set-ExecuteAcl ([string] $Path) {
  $Acl = Get-Acl -Path $Path
  $AccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList Users, Traverse, Allow

  $Acl.SetAccessRule($AccessRule)
  Set-Acl -Path $Path -AclObject $Acl
}

function Set-SystemEnv ([string] $Name, [string] $Value) {
  [System.Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::Machine)
}

function main {
  $DownloadUrl = 'https://cdn.thelang.io/cli-core-windows'
  $InstallDir = 'C:\Program Files\The'
  $InstallPath = "$InstallDir\the.exe"

  if (Test-Path -Path $InstallDir) {
    Write-Host 'The CLI is already installed'
    return
  }

  Write-Host 'Installing The CLI...'
  New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
  Request-File -Url $DownloadUrl -Path $InstallPath
  Set-ExecuteAcl -Path $InstallPath
  Set-SystemEnv -Name Path -Value "$(Get-SystemEnv -Name Path);$InstallDir"
  $env:Path += ";$InstallDir"
  Write-Host 'Successfully installed The CLI!'
  Write-Host '  Type `the -h` to explore available options'
}

main
