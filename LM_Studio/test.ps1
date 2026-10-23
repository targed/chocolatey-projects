$downloadPage = Invoke-WebRequest -Uri "https://lmstudio.ai/download" -UseBasicParsing
$downloadUrl = $downloadPage.Links | 
    Where-Object { $_.href -like "*LM-Studio*x64.exe" } | 
    Select-Object -ExpandProperty href

# print the download URL to the console
Write-Output $downloadUrl