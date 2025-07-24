<#
.SYNOPSIS
    Export guest users from Microsoft Entra ID (Azure AD) with detailed information, including UPN, ObjectId, sign-in types, and optional group membership filtering.

.DESCRIPTION
    This script connects to Microsoft Graph API to retrieve all guest users (`userType eq 'Guest'`) in Azure AD.
    It extracts:
    - DisplayName
    - Email
    - UPN (UserPrincipalName)
    - ObjectId (Id)
    - Account creation date
    - Days since account creation
    - Last interactive sign-in
    - Last non-interactive sign-in
    - Days since last login
    - Optionally filters out users not in any groups
    The results are exported to a timestamped CSV file.

.NOTES
    Version:        1.4.0
    Author:         Your Name
    GitHub Repo:    (Link to your repository)

.REQUIREMENTS
    - Microsoft Graph PowerShell module (`Microsoft.Graph.Users`).
    - Admin permissions in Azure AD (`User.Read.All`, `GroupMember.Read.All`).
    - Internet access.
#>

$ErrorActionPreference = "Stop"

# Toggle this to $true to exclude users not in any groups
$FilterByGroupMembership = $true

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor Cyan
}

function Escape-CsvField {
    param([string]$FieldValue)
    if ($FieldValue -and $FieldValue.Contains(",")) {
        return "`"$FieldValue`""
    } else {
        return $FieldValue
    }
}

Write-Log "Starting Guest User Export Script..."

Write-Log "Please choose where to save the export file..."
$FileBrowser = New-Object -ComObject Shell.Application
$Folder = $FileBrowser.BrowseForFolder(0, "Select Folder to Save CSV File", 0)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

if ($Folder) {
    $outputFolder = $Folder.Self.Path
    $outputFile = "$outputFolder\GuestUsers_$timestamp.csv"
} else {
    Write-Host "No folder selected. Using default script directory." -ForegroundColor Yellow
    $outputFile = "$PSScriptRoot\GuestUsers_$timestamp.csv"
}

Write-Log "File will be saved as: $outputFile"

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Write-Log "Microsoft Graph module not found. Installing now..."
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

Import-Module Microsoft.Graph.Users

Write-Log "Connecting to Microsoft Graph API..."
try {
    Connect-MgGraph -Scopes "User.Read.All", "GroupMember.Read.All" -ErrorAction Stop
    Write-Log "Connected successfully to Microsoft Graph."
} catch {
    Write-Host "ERROR: Failed to connect to Microsoft Graph. Ensure you have the correct permissions." -ForegroundColor Red
    exit
}

Write-Log "Retrieving guest users from Microsoft Entra ID (Azure AD)..."
try {
    $guestUsers = Get-MgUser -Filter "userType eq 'Guest'" -Property Id, DisplayName, Mail, SignInActivity, CreatedDateTime, UserPrincipalName -All
    Write-Log "Retrieved $($guestUsers.Count) guest users."
} catch {
    Write-Host "ERROR: Failed to retrieve guest users. Ensure you have the necessary permissions." -ForegroundColor Red
    exit
}

$results = @()
$today = Get-Date

Write-Log "Processing users and cleaning data..."
foreach ($user in $guestUsers) {
    # Skip users not in any groups if filtering is enabled
    if ($FilterByGroupMembership) {
        try {
            $groups = Get-MgUserMemberOf -UserId $user.Id -ErrorAction Stop
            if ($groups.Count -eq 0) {
                Write-Log "Skipping user $($user.DisplayName) — not in any groups."
                continue
            }
        } catch {
            Write-Log "Could not retrieve groups for user $($user.DisplayName). Skipping..."
            continue
        }
    }

    $displayName = if ($user.DisplayName) {
        Escape-CsvField($user.DisplayName.Trim() -replace "\s+", " ")
    } else {
        "Unknown Name"
    }

    $email = if ($user.Mail) {
        Escape-CsvField($user.Mail.Trim())
    } else {
        "No Email Provided"
    }

    $createdDate = $user.CreatedDateTime
    $interactiveSignIn = $user.SignInActivity.InteractiveSignInDateTime
    $nonInteractiveSignIn = $user.SignInActivity.NonInteractiveSignInDateTime

    $daysSinceLastLogin = if ($interactiveSignIn) {
        ($today - $interactiveSignIn).Days
    } elseif ($nonInteractiveSignIn) {
        ($today - $nonInteractiveSignIn).Days
    } else {
        "Never Logged In"
    }

    $daysSinceCreation = if (!$interactiveSignIn -and !$nonInteractiveSignIn -and $createdDate) {
        ($today - $createdDate).Days
    } else {
        ""
    }

    $results += [PSCustomObject]@{
        DisplayName              = $displayName
        Email                    = $email
        UPN                      = $user.UserPrincipalName
        ObjectId                 = $user.Id
        CreatedDate              = if ($createdDate) { $createdDate.ToString("dd-MM-yyyy HH:mm") } else { "Unknown" }
        DaysSinceCreation        = if ($daysSinceCreation -ne "") { $daysSinceCreation } else { "N/A" }
        LastInteractiveSignIn    = if ($interactiveSignIn) { $interactiveSignIn.ToString("dd-MM-yyyy HH:mm") } else { "Never" }
        LastNonInteractiveSignIn = if ($nonInteractiveSignIn) { $nonInteractiveSignIn.ToString("dd-MM-yyyy HH:mm") } else { "Never" }
        DaysSinceLastLogin       = $daysSinceLastLogin
    }
}

Write-Log "Exporting data to CSV file..."
try {
    $results | Export-Csv -Path $outputFile -NoTypeInformation
    Write-Log "Export completed successfully! File saved as: $outputFile"
} catch {
    Write-Host "ERROR: Failed to save the CSV file. Check file permissions." -ForegroundColor Red
}

Write-Log "Disconnecting from Microsoft Graph API..."
Disconnect-MgGraph
Write-Log "Script completed!"
