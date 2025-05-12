$url = "https://link.vex.com/vexcode-v5blocks-windows"
$response = Invoke-WebRequest -Uri $url -MaximumRedirection 0 -ErrorAction Ignore
if ($response.StatusCode -ge 300 -and $response.StatusCode -lt 400) {
    $redirectUrl = $response.Headers["Location"]
    Write-Output $redirectUrl
}
else {
    Write-Output "No redirect found or an error occurred."
}