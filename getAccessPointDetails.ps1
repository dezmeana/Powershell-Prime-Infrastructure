

# Create base64 encoded credentials
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

# Set up headers
$headers = @{
    Authorization = "Basic $base64AuthInfo"
    #Accept = "application/json"
}

# Make the API request
$uri = "https://$server/webacs/api/v4/data/AccessPointDetails?.full=true"

function PrettyPrintJson {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $json
    )
    $json | ConvertFrom-Json | ConvertTo-Json -Depth 100
}

try {
    # Send a GET request to the specified URI and parse the XML response
    [xml]$response = Invoke-WebRequest -Uri $uri -Headers $headers -ContentType 'application/xml' -Method Get -DisableKeepAlive
    
    # Extract the access point details from the response
    $output = $response.queryResponse.entity.accessPointDetailsDTO
         
    # Create a custom object for each access point with selected properties
    $apcsv = foreach ($ap in $output) {
        [PSCustomObject]@{
            'Serial Number' = $ap.serialNumber
            Model = $ap.model
            'Software Version' = $ap.softwareVersion
            'Host name' = $ap.name
            'Friendly Name' = $ap.name
            'IPv4 address' = $ap.ipAddress
         }
    }

    # Create a custom object for each access point with selected properties
    $clientcount = foreach ($ap in $output) {
        [PSCustomObject]@{
            'Host name' = $ap.name
            'Client count' = $ap.clientCount
         
        }
    }
    $apcsv | Export-CSV ".\results\AP_audit.csv" -NoTypeInformation
    $clientcount | Export-CSV ".\results\Client_count.csv" -NoTypeInformation
    } catch {
    Write-Error "An error occurred: $_"
}
