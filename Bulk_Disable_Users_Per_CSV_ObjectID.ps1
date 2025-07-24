# Connect to Azure AD
Connect-AzureAD

# Import the CSV
$CSVPath = "******YOURCSVPATH.csv************"
Write-Host "Importing CSV from: $CSVPath"
$CSVrecords = Import-Csv $CSVPath

# Arrays to track skipped and failed users
$SkippedUsers = @()
$FailedUsers = @()
$SuccessUsers = @()

# Loop through each record
foreach ($CSVrecord in $CSVrecords) {
    $ObjectID = $CSVrecord.ObjectID.Trim()

    if (-not $ObjectID) {
        Write-Warning "Empty ObjectID found, skipping..."
        continue
    }

    Write-Host "Processing ObjectID: $ObjectID"

    try {
        $user = Get-AzureADUser -ObjectID $ObjectID
        if ($user) {
            Set-AzureADUser -ObjectID $ObjectID -AccountEnabled $false
            Write-Host "✅ Successfully disabled: $ObjectID"
            $SuccessUsers += $ObjectID
        } else {
            Write-Warning "⚠️ $ObjectID not found, skipped"
            $SkippedUsers += $ObjectID
        }
    } catch {
        Write-Warning "❌ Failed to disable $ObjectID: $_"
        $FailedUsers += $ObjectID
    }
}

# Summary
Write-Host "`n--- Summary ---"
Write-Host "✅ Successfully disabled: $($SuccessUsers.Count)"
Write-Host "⚠️ Skipped (not found): $($SkippedUsers.Count)"
Write-Host "❌ Failed to disable: $($FailedUsers.Count)"
