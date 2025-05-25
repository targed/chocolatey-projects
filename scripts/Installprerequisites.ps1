Set-ExecutionPolicy Bypass -Scope Process -Force
powershell.exe Install-PackageProvider -Name NuGet -Force
Install-Module AU -Force
choco install checksum -y
exit 0