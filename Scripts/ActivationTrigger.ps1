Write-Host "Welcome to Manage Users Script."

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('activate', 'deactivate')]
    [string]$Action
)

############################################################################################# Deactivation Function
function Manage-User {
    param (
        [Parameter(Mandatory)]
        [psobject]$User,
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Headers,
        [Parameter(Mandatory = $true)]
        [bool]$Status
    )

    $updateUrl = "https://graph.microsoft.com/v1.0/users/$($User.id)"
    $updateBody = @{
        accountEnabled = $Status
    } | ConvertTo-Json -Depth 1

    try {
        Invoke-RestMethod -Method PATCH -Uri $updateUrl -Headers $Headers -Body $updateBody
        return $true
    } catch {
        Log-Message "Failed to deactivate user: $($User.userPrincipalName). Error: $($_.Exception.Message)" -Type "Error"
        return $false
    }
}

#################################################################################### Initialization

# Configuration from environment variables
$attributeFilter  = $env:ATTRIBUTE_FILTER
$accessToken      = $env:SHADOW_ACCESS_TOKEN
$extensionName    = "ArcCustomExtension"

# Validate configuration
if (-not $attributeFilter) {
    throw "ATTRIBUTE_FILTER environment variable is not set."
}

if (-not $accessToken) {
    throw "ACCESS_TOKEN environment variable is not set."
}