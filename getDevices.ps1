# Set up authentication and server details
$username = "{{username}}"
$password = "{{api password}}"
$server = "{{PIurl}}"

# Create base64 encoded credentials
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

# Set up headers
$headers = @{
    Authorization = "Basic $base64AuthInfo"
    #Accept = "application/json"
}

# Make the API request
$uri = "https://$server/webacs/api/v1/data/Devices?.full=true"

function PrettyPrintJson {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $json
    )
    $json | ConvertFrom-Json | ConvertTo-Json -Depth 100
}

try {
    [xml]$response = Invoke-WebRequest -Uri $uri -Headers $headers -ContentType 'application/xml' -Method Get -DisableKeepAlive
    
    # Extract and display the total client count
    $output = $response.queryResponse.entity.devicesDTO #.Content 
    #$output | Out-File -FilePath .\test.txt
    #return $output | PrettyPrintJson
    return $output #| Format-Table -Property deviceName,deviceType, softwareType, softwareVersion -AutoSize
   
    } catch {
    Write-Error "An error occurred: $_"
}
