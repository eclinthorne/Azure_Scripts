<#
.SYNOPSIS
    Export guest users from Microsoft Entra ID (Azure AD) with detailed information, including UPN, ObjectId, and sign-in types.

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
    The results are exported to a timestamped CSV file.

.NOTES
    Version:        1.3.0
    Author:         Your Name
    GitHub Repo:    (Link to your repository)

.REQUIREMENTS
    - Microsoft Graph PowerShell module (`Microsoft.Graph.Users`).
    - Admin permissions in Azure AD (`User.Read.All` scope).
    - Internet access.
#>

$ErrorActionPreference = "Stop"

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
    $outputFile = "$PSScript